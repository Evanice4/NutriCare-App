import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/content_models.dart';
import '../models/user_model.dart';
import '../constants/colors.dart';
import '../bloc/content/content_bloc.dart';

import '../bloc/content/content_state.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';
import 'create_guide_screen.dart';

class GuidesScreen extends StatefulWidget {
  final UserProfile? currentUser;
  
  const GuidesScreen({super.key, this.currentUser});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  UserProfile? _currentUser;
  final _searchController = TextEditingController();
  String? _selectedCategory;
  
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
    _currentUser = widget.currentUser;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    context.read<SearchBloc>().add(SearchGuides(
      query: _searchController.text,
      category: _selectedCategory,
    ));
  }

  Future<void> _navigateToCreateGuide() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CreateGuideScreen(),
      ),
    );

    // If guide was created successfully, the screen returns true
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guide published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  bool get _isCreator {
    return _currentUser?.userType == 'creator';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('Nutrition Guides'),
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.secondaryBackground,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search guides...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchBloc>().add(ClearSearch());
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Filter by category', style: TextStyle(color: Colors.white)),
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [null, ..._categories].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category ?? 'All Categories'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _performSearch();
                  },
                ),
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _isCreator
          ? FloatingActionButton(
              onPressed: _navigateToCreateGuide,
              backgroundColor: AppColors.homeBackground,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        if (searchState is SearchResults) {
          return _buildGuidesList(searchState.guides);
        }
        
        return BlocBuilder<ContentBloc, ContentState>(
          builder: (context, contentState) {
            if (contentState is ContentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (contentState is ContentError) {
              return Center(child: Text('Error: ${contentState.message}'));
            }
            
            final guides = contentState is ContentLoaded ? contentState.guides : <Guide>[];
            return _buildGuidesList(guides);
          },
        );
      },
    );
  }

  Widget _buildGuidesList(List<Guide> guides) {
    if (guides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No guides found', style: TextStyle(fontSize: 18, color: Colors.grey)),
            if (_isCreator) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToCreateGuide,
                icon: const Icon(Icons.add),
                label: const Text('Create Your First Guide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.homeBackground,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: InkWell(
            onTap: () => _showGuideDetails(guide),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (guide.imageUrl != null && guide.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      guide.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        guide.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              guide.category,
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(guide.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGuideDetails(Guide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (guide.imageUrl != null && guide.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            guide.imageUrl!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        guide.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              guide.category,
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Published ${_formatDate(guide.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        guide.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Content',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        guide.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

