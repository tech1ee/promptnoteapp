import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/models/dataset_model.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/services/mock_storage_service.dart';
import 'package:prompt_note_app/services/mock_database_service.dart';

class DatasetEditorScreen extends StatefulWidget {
  final DatasetModel? dataset;
  final String? initialContent;

  const DatasetEditorScreen({
    Key? key,
    this.dataset,
    this.initialContent,
  }) : super(key: key);

  @override
  _DatasetEditorScreenState createState() => _DatasetEditorScreenState();
}

class _DatasetEditorScreenState extends State<DatasetEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _prefixController = TextEditingController();
  final _suffixController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isLoading = false;
  bool _isEdited = false;
  String? _errorMessage;
  List<DatasetItemModel> _items = [];
  DatasetItemModel? _selectedItem;
  int _itemCounter = 0;
  
  // Template options for use in ItemEditorScreen
  static final Map<String, String> inlineTemplates = {
    'Square brackets': '[%s]',
    'Double square brackets': '[[%s]]',
    'Curly brackets': '{%s}',
    'Double curly brackets': '{{%s}}',
    'Ticks': '`%s`',
    'Triple ticks': '```%s```',
    'Quotes': '"%s"',
    'Triple quotes': '"""%s"""',
  };
  
  static final Map<String, List<String>> blockTemplates = {
    'Dashed lines': ['---', '%s', '---'],
    'Double lines': ['===', '%s', '==='],
    'Starred block': ['***', '%s', '***'],
    'Quoted block': ['"""', '%s', '"""'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.dataset != null) {
      _titleController.text = widget.dataset!.title;
      _prefixController.text = widget.dataset!.prefix;
      _suffixController.text = widget.dataset!.suffix;
      _tagsController.text = widget.dataset!.tags.join(', ');
      
      if (widget.dataset!.items.isNotEmpty) {
        _items = List.from(widget.dataset!.items);
        _itemCounter = _items.map((e) => e.position).reduce((a, b) => a > b ? a : b) + 1;
      }
    }
    
    if (_items.isEmpty) {
      // Add a default item if none exist
      _addNewItem('Text');
    }
    
    if (widget.initialContent != null && _items.isNotEmpty) {
      // Update the first item with the initial content
      final updatedItem = _items.first.copyWith(content: widget.initialContent!);
      _items[0] = updatedItem;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _prefixController.dispose();
    _suffixController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String tagsText) {
    if (tagsText.isEmpty) return [];
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
  
  void _addNewItem(String content) {
    final newItem = DatasetItemModel(
      id: null,
      content: content,
      position: _itemCounter++,
      disabled: false, // Always enabled by default
    );
    
    setState(() {
      _items.add(newItem);
      _isEdited = true;
    });
  }
  
  Future<void> _editItem(DatasetItemModel item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemEditorScreen(
          item: item,
          prefix: _prefixController.text,
          suffix: _suffixController.text,
        ),
      ),
    );
    
    if (result != null && result is DatasetItemModel) {
      final index = _items.indexWhere((i) => i.position == item.position);
      if (index != -1) {
        setState(() {
          // Preserve the disabled state unless explicitly changed
          _items[index] = result.copyWith(
            disabled: result.disabled != item.disabled ? result.disabled : item.disabled
          );
          _isEdited = true;
        });
      }
    }
  }
  
  void _deleteItem(DatasetItemModel item) {
    setState(() {
      _items.removeWhere((i) => i.position == item.position);
      _isEdited = true;
    });
  }
  
  void _toggleItemDisabled(int index) {
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(disabled: !item.disabled);
      _isEdited = true;
    });
  }

  void _saveDataset() {
    setState(() {
      _errorMessage = null;
    });
    
    final authService = Provider.of<MockAuthService>(context, listen: false);
    if (authService.user == null) {
      setState(() {
        _errorMessage = 'You must be logged in to save datasets';
      });
      return;
    }
    
    final userId = authService.user!.uid;
    
    final title = _titleController.text.trim();
    final prefix = _prefixController.text;
    final suffix = _suffixController.text;
    final content = _items.map((item) => item.content).join('\n\n');
    
    final tagsList = _parseTags(_tagsController.text);
    
    final storageService = Provider.of<MockStorageService>(context, listen: false);
    
    if (widget.dataset == null) {
      final newDataset = DatasetModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        tags: tagsList,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        items: _items,
        prefix: prefix,
        suffix: suffix,
      );
      
      storageService.insertDataset(newDataset).then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to save dataset: $error';
        });
      });
    } else {
      final updatedDataset = DatasetModel(
        id: widget.dataset!.id,
        firebaseId: widget.dataset!.firebaseId,
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        tags: tagsList,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        items: _items,
        prefix: prefix,
        suffix: suffix,
      );
      
      storageService.updateDataset(updatedDataset).then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to update dataset: $error';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dataset == null ? 'New Dataset' : 'Edit Dataset'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isEdited) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text('Your changes will be lost if you leave without saving.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('STAY'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('DISCARD'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addNewItem('New item');
            },
            tooltip: 'Add Item',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDataset,
            tooltip: 'Save Dataset',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _titleController,
                      autofocus: widget.dataset == null,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter dataset title',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _isEdited = true;
                        });
                      },
                    ),
                  ),
                  
                  // Tags
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.tag, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              hintText: 'Add tags (comma-separated)',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14),
                            onChanged: (value) {
                              setState(() {
                                _isEdited = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Main content area
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: const [
                              Tab(text: 'Items'),
                              Tab(text: 'Settings'),
                            ],
                            labelColor: Theme.of(context).primaryColor,
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Items Tab
                                _buildItemsTab(),
                                
                                // Settings Tab
                                _buildSettingsTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildItemsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Dataset Items (${_items.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_items.where((item) => !item.disabled).length} active',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () {
                  _addNewItem('New item');
                },
                tooltip: 'Add Item',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_list_bulleted,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items yet\nTap + to add your first item',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : ReorderableListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _items.length,
                buildDefaultDragHandles: false, // We'll use custom drag handles
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                    
                    // Update all positions based on new order
                    for (int i = 0; i < _items.length; i++) {
                      _items[i] = _items[i].copyWith(position: i);
                    }
                    
                    _isEdited = true;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  
                  return GestureDetector(
                    key: ValueKey(item.id ?? item.position),
                    onTap: () => _editItem(item),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 1.0),
                      decoration: BoxDecoration(
                        color: item.disabled ? Colors.grey[50] : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Drag handle
                          ReorderableDragStartListener(
                            index: index,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.drag_handle, 
                                color: Colors.grey, size: 20),
                            ),
                          ),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Item ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: item.disabled ? Colors.grey : null,
                                  ),
                                ),
                                if (item.content.isNotEmpty)
                                  Text(
                                    item.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: item.disabled ? Colors.grey : null,
                                      decoration: item.disabled ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: !item.disabled,
                                onChanged: (value) => _toggleItemDisabled(index),
                                activeColor: Theme.of(context).primaryColor,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteItem(item),
                                tooltip: 'Delete',
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affixation section
          const Text(
            'Affixation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add prefix/suffix to all items in this dataset',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // Prefix
          const Text('Prefix'),
          const SizedBox(height: 4),
          TextField(
            controller: _prefixController,
            decoration: const InputDecoration(
              hintText: 'e.g. [',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _isEdited = true;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Suffix
          const Text('Suffix'),
          const SizedBox(height: 4),
          TextField(
            controller: _suffixController,
            decoration: const InputDecoration(
              hintText: 'e.g. ]',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _isEdited = true;
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          // Preview section
          if (_items.isNotEmpty) ...[
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Example Item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_prefixController.text + _items.first.content + _suffixController.text),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Usage section
          const Text(
            'Usage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This dataset is not used in any prompts...',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// Separate screen for editing dataset items
class ItemEditorScreen extends StatefulWidget {
  final DatasetItemModel item;
  final String prefix;
  final String suffix;
  
  const ItemEditorScreen({
    Key? key,
    required this.item,
    this.prefix = '',
    this.suffix = '',
  }) : super(key: key);
  
  @override
  _ItemEditorScreenState createState() => _ItemEditorScreenState();
}

class _ItemEditorScreenState extends State<ItemEditorScreen> {
  late TextEditingController _contentController;
  late DatasetItemModel _currentItem;
  bool _isEdited = false;
  late bool _isDisabled;
  
  // Track text selection
  TextSelection? _currentSelection;
  
  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _contentController = TextEditingController(text: widget.item.content);
    _isDisabled = widget.item.disabled;
    
    // Initialize with empty selection
    _currentSelection = const TextSelection.collapsed(offset: 0);
    
    // Listen for selection changes
    _contentController.addListener(() {
      if (_contentController.selection.isValid) {
        _currentSelection = _contentController.selection;
      }
    });
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
  
  void _applyTemplate(String template) {
    // Get the current text
    final text = _contentController.text;
    
    // If there's a valid selection, only apply template to selected text
    if (_currentSelection != null && _currentSelection!.isValid && !_currentSelection!.isCollapsed) {
      final selectedText = text.substring(_currentSelection!.start, _currentSelection!.end);
      final formattedText = template.replaceAll('%s', selectedText);
      
      // Replace just the selected portion
      final newText = text.replaceRange(_currentSelection!.start, _currentSelection!.end, formattedText);
      
      // Calculate new cursor position to place after the templated text
      final newCursorPosition = _currentSelection!.start + formattedText.length;
      
      setState(() {
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newCursorPosition),
        );
        _isEdited = true;
      });
    } 
    // No selection - apply to all text
    else {
      final newText = template.replaceAll('%s', text);
      setState(() {
        _contentController.text = newText;
        _isEdited = true;
      });
    }
  }
  
  void _applyBlockTemplate(List<String> template) {
    // Get the current text
    final text = _contentController.text;
    
    // If there's a valid selection, only apply template to selected text
    if (_currentSelection != null && _currentSelection!.isValid && !_currentSelection!.isCollapsed) {
      final selectedText = text.substring(_currentSelection!.start, _currentSelection!.end);
      
      // Format with block template (first line + content + last line)
      final formattedText = template.isNotEmpty 
          ? template.join('\n').replaceAll('%s', selectedText)
          : selectedText;
      
      // Replace just the selected portion
      final newText = text.replaceRange(_currentSelection!.start, _currentSelection!.end, formattedText);
      
      // Calculate new cursor position
      final newCursorPosition = _currentSelection!.start + formattedText.length;
      
      setState(() {
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newCursorPosition),
        );
        _isEdited = true;
      });
    } 
    // No selection - apply to all text
    else {
      final newText = template.join('\n').replaceAll('%s', text);
      setState(() {
        _contentController.text = newText;
        _isEdited = true;
      });
    }
  }
  
  void _toggleDisabled() {
    setState(() {
      _isDisabled = !_isDisabled;
      _isEdited = true;
    });
  }
  
  void _saveChanges() {
    final updatedItem = _currentItem.copyWith(
      content: _contentController.text,
      disabled: _isDisabled,
    );
    Navigator.pop(context, updatedItem);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item ${_currentItem.position + 1}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isEdited) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text('Your changes will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('DISCARD'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          // Toggle enabled/disabled in app bar
          Row(
            children: [
              Text(
                _isDisabled ? 'Disabled' : 'Enabled',
                style: TextStyle(
                  color: _isDisabled ? Colors.grey : Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
              Switch(
                value: !_isDisabled,
                onChanged: (value) => _toggleDisabled(),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Edit area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  if (_isDisabled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This item is disabled and will not be included in prompts',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: !_isDisabled,
                            onChanged: (value) => _toggleDisabled(),
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  
                  // Preview with affixes
                  if (widget.prefix.isNotEmpty || widget.suffix.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview with affixes:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.prefix + _contentController.text + widget.suffix,
                            style: _isDisabled ? 
                              TextStyle(
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                              ) : null,
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Info about templates usage
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[800], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Select text to apply templates to specific parts only.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Main content editor
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isDisabled ? Colors.grey : null,
                        decoration: _isDisabled ? TextDecoration.lineThrough : null,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your content here...',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(16),
                        filled: _isDisabled,
                        fillColor: _isDisabled ? Colors.grey[50] : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isEdited = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Templates
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.grey[50],
                    child: TabBar(
                      tabs: const [
                        Tab(text: 'Inline Templates'),
                        Tab(text: 'Block Templates'),
                      ],
                      labelColor: Theme.of(context).primaryColor,
                      indicatorColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey[700],
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: TabBarView(
                      children: [
                        // Inline templates
                        _buildTemplateGrid(_DatasetEditorScreenState.inlineTemplates),
                        
                        // Block templates
                        _buildTemplateGrid(_DatasetEditorScreenState.blockTemplates, isBlock: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateGrid(Map<String, dynamic> templates, {bool isBlock = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final entry = templates.entries.elementAt(index);
        return InkWell(
          onTap: () {
            if (isBlock) {
              _applyBlockTemplate(entry.value as List<String>);
            } else {
              _applyTemplate(entry.value as String);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              entry.key,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
} 