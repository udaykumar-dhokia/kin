import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../bills/widgets/add_bill_bottom_sheet.dart';
import '../models/super_app_category.dart';
import '../widgets/category_card.dart';
import '../widgets/category_coming_soon_bottom_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const CategoriesScreen({super.key, this.onNavigateTab});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SuperAppCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return SuperAppCategory.allCategories;
    return SuperAppCategory.allCategories.where((cat) {
      return cat.title.toLowerCase().contains(_searchQuery) ||
          cat.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _onCategoryTapped(SuperAppCategory category) {
    if (category.isAvailable && category.targetTabIndex != null) {
      if (widget.onNavigateTab != null) {
        widget.onNavigateTab!(category.targetTabIndex!);
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryComingSoonBottomSheet(category: category),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBillBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final categories = _filteredCategories;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                'Categories',
                style: theme.textTheme.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Super app modules for your personal & household life.',
                style: theme.textTheme.muted.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Search Bar
              ShadInput(
                controller: _searchController,
                placeholder: const Text('Search services & modules...'),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 8),
                  child: Icon(
                    LucideIcons.search,
                    size: 16,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid of Categories
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Text(
                          'No categories found matching "$_searchQuery"',
                          style: theme.textTheme.muted,
                        ),
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            category: category,
                            onTap: () => _onCategoryTapped(category),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.primaryForeground,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tooltip: 'Add Deadline',
        child: const Icon(LucideIcons.plus, size: 22),
      ),
    );
  }
}
