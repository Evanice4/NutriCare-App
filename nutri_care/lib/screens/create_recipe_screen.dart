import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../api/firestore_content_api.dart';
import '../models/content_models.dart';
import '../bloc/content/content_bloc.dart';
import '../bloc/content/content_event.dart';

class CreateRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  
  const CreateRecipeScreen({super.key, this.recipe});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentApi = FirestoreContentApi();

  File? _selectedImage;
  String? _imageUrl;
  bool _loading = false;
  String? _error;

  final List<Ingredient> _ingredients = [Ingredient(name: '', amount: '')];
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.recipe!.title;
      _descriptionController.text = widget.recipe!.description;
      _imageUrl = widget.recipe!.imageUrl;
      _ingredients.clear();
      _ingredients.addAll(widget.recipe!.ingredients);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final fileName =
          'recipes/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      await ref.putFile(_selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      setState(() {
        _error = 'Failed to upload image: ${e.toString()}';
      });
      return null;
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(Ingredient(name: '', amount: ''));
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  void _updateIngredient(int index, String name, String amount) {
    setState(() {
      _ingredients[index] = Ingredient(name: name, amount: amount);
    });
  }

  Future<void> _publishRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate ingredients
    final validIngredients = _ingredients
        .where(
          (ing) => ing.name.trim().isNotEmpty && ing.amount.trim().isNotEmpty,
        )
        .toList();

    if (validIngredients.isEmpty) {
      setState(() {
        _error = 'Please add at least one ingredient';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload image if selected
      if (_selectedImage != null) {
        _imageUrl = await _uploadImage();
      }

      if (_isEditing) {
        // Update existing recipe
        final updatedRecipe = Recipe(
          id: widget.recipe!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrl ?? widget.recipe!.imageUrl,
          creatorId: widget.recipe!.creatorId,
          createdAt: widget.recipe!.createdAt,
          ingredients: validIngredients,
        );

        context.read<ContentBloc>().add(
          UpdateRecipe(recipe: updatedRecipe, currentUserId: user.uid),
        );
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Create new recipe
        final recipe = Recipe(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrl ?? '',
          creatorId: user.uid,
          createdAt: DateTime.now(),
          ingredients: validIngredients,
        );

        final recipeId = await _contentApi.createRecipe(recipe);

        if (mounted && recipeId.isNotEmpty) {
          context.read<ContentBloc>().add(LoadRecipes());
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to create recipe');
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to publish recipe: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'Create Recipe'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _publishRecipe,
              child: Text(
                _isEditing ? 'Update' : 'Publish',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Publishing recipe...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),

                    // Image selection
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (_imageUrl != null && _imageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Recipe Image',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Tap to select from gallery',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Title',
                        hintText: 'Enter a catchy recipe name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a recipe title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief description of your recipe',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Ingredients section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ingredients',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addIngredient,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Ingredients list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ingredients.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    initialValue: _ingredients[index].name,
                                    decoration: const InputDecoration(
                                      labelText: 'Ingredient',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      _updateIngredient(
                                        index,
                                        value,
                                        _ingredients[index].amount,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: _ingredients[index].amount,
                                    decoration: const InputDecoration(
                                      labelText: 'Amount',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      _updateIngredient(
                                        index,
                                        _ingredients[index].name,
                                        value,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_ingredients.length > 1)
                                  IconButton(
                                    onPressed: () => _removeIngredient(index),
                                    icon: const Icon(Icons.remove_circle),
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Publish button (mobile)
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _publishRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isEditing ? 'Update Recipe' : 'Publish Recipe',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
