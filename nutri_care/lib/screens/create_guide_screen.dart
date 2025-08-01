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

class CreateGuideScreen extends StatefulWidget {
  final Guide? guide;
  
  const CreateGuideScreen({super.key, this.guide});

  @override
  State<CreateGuideScreen> createState() => _CreateGuideScreenState();
}

class _CreateGuideScreenState extends State<CreateGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _contentApi = FirestoreContentApi();

  File? _selectedImage;
  String? _imageUrl;
  String _selectedCategory = 'General';
  bool _loading = false;
  String? _error;
  bool get _isEditing => widget.guide != null;

  final List<String> _categories = [
    'General',
    'Weight Management',
    'Healthy Eating',
    'Supplements',
    'Meal Planning',
    'Special Diets',
    'Children\'s Nutrition',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.guide!.title;
      _descriptionController.text = widget.guide!.description;
      _contentController.text = widget.guide!.content;
      _selectedCategory = widget.guide!.category;
      _imageUrl = widget.guide!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image. Please try again.';
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final fileName = 'guide_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(
        'guides/${user.uid}/$fileName',
      );

      await ref.putFile(_selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      setState(() {
        _error = 'Failed to upload image. Please try again.';
      });
      return null;
    }
  }

  Future<void> _createGuide() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
        });
        return;
      }

      // Upload image if selected
      String imageUrl = '';
      if (_selectedImage != null) {
        final uploadedImageUrl = await _uploadImage();
        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        }
      }

      if (_isEditing) {
        // Update existing guide
        final updatedGuide = Guide(
          id: widget.guide!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : (_imageUrl ?? ''),
          creatorId: widget.guide!.creatorId,
          createdAt: widget.guide!.createdAt,
        );

        context.read<ContentBloc>().add(
          UpdateGuide(guide: updatedGuide, currentUserId: user.uid),
        );
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Create new guide
        final guide = Guide(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          imageUrl: imageUrl,
          creatorId: user.uid,
          createdAt: DateTime.now(),
        );

        final guideId = await _contentApi.createNewGuide(guide);

        if (mounted && guideId.isNotEmpty) {
          context.read<ContentBloc>().add(LoadGuides());
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to create guide');
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create guide: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Guide' : 'Create Nutrition Guide'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _createGuide,
              child: Text(
                _isEditing ? 'UPDATE' : 'PUBLISH',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              const Text(
                'Guide Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter a catchy title for your guide...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
                maxLines: 2,
                maxLength: 100,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Title must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Image Section
              const Text(
                'Cover Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _imageUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _imageUrl = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                        onTap: _loading ? null : _pickImage,
                        borderRadius: BorderRadius.circular(10),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add cover image',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '(Optional)',
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

              // Description Section
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Brief description of your guide...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Section
              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Content Section
              const Text(
                'Guide Content',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText:
                      'Share your nutrition knowledge and tips...\n\nInclude practical advice, scientific insights, or personal experiences that will help others on their nutrition journey.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                minLines: 5,
                maxLength: 2000,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Guide content is required';
                  }
                  if (value.trim().length < 50) {
                    return 'Content must be at least 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createGuide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Guide' : 'Publish Guide',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Helper Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Your guide will be visible to all app users immediately after publishing.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
