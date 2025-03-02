import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/services/mock_storage_service.dart';
import 'package:prompt_note_app/features/datasets/screens/dataset_editor_screen.dart';
import 'package:prompt_note_app/features/prompts/screens/prompt_generator_screen.dart';
import 'package:prompt_note_app/features/settings/screens/settings_screen.dart';
import 'package:prompt_note_app/features/datasets/widgets/dataset_card.dart';
import 'package:prompt_note_app/models/dataset_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<DatasetModel>? _searchResults;
  int _currentIndex = 0;
  List<DatasetModel> _datasets = [];
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    // We'll load datasets in didChangeDependencies instead,
    // since we need access to the Provider context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load datasets after the widget is fully initialized
    // and we have access to the Provider context
    _loadDatasets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDatasets() {
    try {
      final authService = Provider.of<MockAuthService>(context, listen: false);
      if (authService.user == null) return; // Skip if no user
      
      final userId = authService.user!.uid;
      
      // Get current timestamp as int (milliseconds since epoch)
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Use mock data for now instead of potentially problematic service
      setState(() {
        _datasets = [
          DatasetModel(
            id: 1,
            title: 'Welcome to Prompt Notes',
            content: 'This is a sample note to help you get started.',
            tags: ['welcome', 'getting-started'],
            lastUpdated: now,
            userId: userId,
          ),
          DatasetModel(
            id: 2,
            title: 'Ideas for my novel',
            content: 'Main character should have a mysterious background...',
            tags: ['writing', 'novel'],
            lastUpdated: now,
            userId: userId,
          ),
        ];
        _refreshKey++; // Increment refresh key
      });
    } catch (e) {
      print('Error loading datasets: $e');
      // Show a user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading datasets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final storageService = Provider.of<MockStorageService>(context, listen: false);
    final authService = Provider.of<MockAuthService>(context, listen: false);
    
    if (authService.user != null) {
      storageService.searchDatasets(authService.user!.uid, query).then((results) {
        if (mounted) {
          setState(() {
            _searchResults = results;
          });
        }
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = null;
    });
  }

  void _createDataset() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DatasetEditorScreen(),
      ),
    ).then((result) {
      // Refresh the datasets list if a dataset was successfully created
      if (result == true) {
        // Reload datasets from storage
        _loadDatasets();
        
        // Show a confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dataset saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<MockAuthService>(context);
    
    if (authService.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userId = authService.user!.uid;
    // Use local datasets list instead of relying directly on the service
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search datasets...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
                ),
                onChanged: _search,
                autofocus: true,
              )
            : const Text('Your Datasets'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createDataset,
              tooltip: 'Create Dataset',
            ),
        ],
      ),
      body: _currentIndex == 0
          ? _isSearching && _searchResults != null
              ? _buildDatasetsList(_searchResults!)
              : _buildDatasetsList(_datasets) // Use cached datasets list instead of future
          : _currentIndex == 1
              ? const PromptGeneratorScreen()
              : const SettingsScreen(),
    );
  }

  Widget _buildDatasetsList(List<DatasetModel> datasets) {
    if (datasets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching
                  ? 'No results found'
                  : 'No datasets yet\nTap the + button to create one',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: datasets.length,
      itemBuilder: (context, index) {
        final dataset = datasets[index];
        return _buildDatasetItem(dataset);
      },
    );
  }
  
  Widget _buildDatasetItem(DatasetModel dataset) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DatasetEditorScreen(
              dataset: dataset,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _loadDatasets();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerTheme.color ?? Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dataset.title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              dataset.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Tags
                if (dataset.tags.isNotEmpty) ...[
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: dataset.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                // Date
                Text(
                  _formatDate(dataset.lastUpdated),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
} 