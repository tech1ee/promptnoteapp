import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prompt_note_app/models/prompt_block_model.dart';
import 'package:prompt_note_app/models/dataset_model.dart';
import 'package:prompt_note_app/features/prompts/widgets/simple_prompt_block_widget.dart';
import 'package:prompt_note_app/services/mock_storage_service.dart';
import 'package:provider/provider.dart';

class PromptEditorScreen extends StatefulWidget {
  final List<PromptBlockModel>? initialBlocks;
  final String? title;

  const PromptEditorScreen({
    Key? key, 
    this.initialBlocks,
    this.title,
  }) : super(key: key);

  @override
  _PromptEditorScreenState createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends State<PromptEditorScreen> {
  late List<PromptBlockModel> _blocks;
  final TextEditingController _titleController = TextEditingController();
  bool _isDirty = false;
  Set<String> _collapsedBlocks = {};
  final FocusNode _titleFocusNode = FocusNode();
  bool _isAddingBlock = false;

  @override
  void initState() {
    super.initState();
    _blocks = widget.initialBlocks?.toList() ?? [PromptBlockModel.text('')];
    _titleController.text = widget.title ?? 'New Prompt';
    
    // Request focus on the title after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_titleFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _addTextBlock() {
    setState(() {
      _blocks.add(PromptBlockModel.text(''));
      _isDirty = true;
      _isAddingBlock = false;
    });
  }
  
  Future<void> _addDatasetBlock() async {
    final storageService = Provider.of<MockStorageService>(context, listen: false);
    final datasets = await storageService.getAllDatasets();
    
    if (!mounted) return;
    
    if (datasets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No datasets available. Create a dataset first.'),
        )
      );
      return;
    }
    
    final DatasetModel? selected = await showDialog<DatasetModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Dataset'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: datasets.length,
            itemBuilder: (context, index) {
              final dataset = datasets[index];
              return ListTile(
                title: Text(dataset.title),
                subtitle: Text('${dataset.items.length} items'),
                onTap: () => Navigator.pop(context, dataset),
              );
            },
          ),
        ),
      ),
    );
    
    if (selected != null && selected.id != null) {
      setState(() {
        _blocks.add(PromptBlockModel.dataset(selected.id!, selected.title));
        _isDirty = true;
        _isAddingBlock = false;
      });
    }
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
      _isDirty = true;
    });
  }

  void _updateBlock(int index, PromptBlockModel updatedBlock) {
    setState(() {
      _blocks[index] = updatedBlock;
      _isDirty = true;
    });
  }

  void _addVariation(int blockIndex) {
    setState(() {
      final block = _blocks[blockIndex];
      final variations = List<String>.from(block.variations);
      
      // Make each variation distinctly different by adding a version number
      final variationNumber = variations.length + 1;
      final baseContent = block.variations[0].trim(); // Use first variation as base
      final newVariation = baseContent.isEmpty 
          ? "Variation $variationNumber" 
          : "$baseContent (v$variationNumber)";
      
      variations.add(newVariation);
      
      // Set the newly created variation as selected
      final newSelectedIndex = variations.length - 1;
      
      _blocks[blockIndex] = block.copyWith(
        content: newVariation, // Select the new content
        variations: variations,
        selectedVariation: newSelectedIndex, // Select the new variation
      );
      
      _isDirty = true;
    });
  }

  void _toggleBlockCollapse(int index, bool isCollapsed) {
    setState(() {
      final blockId = _blocks[index].id;
      if (isCollapsed) {
        _collapsedBlocks.add(blockId);
      } else {
        _collapsedBlocks.remove(blockId);
      }
    });
  }

  String _generatePrompt() {
    StringBuffer prompt = StringBuffer();
    
    for (final block in _blocks) {
      if (block.type == BlockType.dataset) {
        // For dataset blocks, we need to fetch the actual dataset
        final datasetId = block.parameters?['datasetId'] as int?;
        final datasetTitle = block.parameters?['datasetTitle'] as String? ?? 'Dataset';
        
        // In a real app, you'd fetch the dataset here and include its content
        // For now, we'll just include a placeholder
        prompt.write('[Dataset: $datasetTitle]');
      } else {
        prompt.write(block.content);
      }
      prompt.write(' ');
    }
    
    return prompt.toString().trim();
  }
  
  Future<String> _generatePromptWithDatasets() async {
    StringBuffer prompt = StringBuffer();
    final storageService = Provider.of<MockStorageService>(context, listen: false);
    
    for (final block in _blocks) {
      if (block.type == BlockType.dataset) {
        final datasetId = block.parameters?['datasetId'] as int?;
        
        if (datasetId != null) {
          try {
            final dataset = await storageService.getDataset(datasetId);
            if (dataset != null) {
              // Include all enabled dataset items with prefix/suffix
              final enabledItems = dataset.items.where((item) => !item.disabled).toList();
              
              if (enabledItems.isEmpty) {
                prompt.write('[No enabled items in dataset: ${dataset.title}]\n');
              } else {
                for (final item in enabledItems) {
                  prompt.write('${dataset.prefix}${item.content}${dataset.suffix}\n');
                }
              }
            } else {
              prompt.write('[Dataset not found]\n');
            }
          } catch (e) {
            prompt.write('[Error loading dataset]\n');
          }
        } else {
          prompt.write('[Invalid dataset reference]\n');
        }
      } else {
        prompt.write('${block.content}\n');
      }
    }
    
    return prompt.toString().trim();
  }
  
  void _copyPromptToClipboard() async {
    final prompt = await _generatePromptWithDatasets();
    Clipboard.setData(ClipboardData(text: prompt)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
  
  void _savePrompt() async {
    if (_isDirty) {
      final promptText = await _generatePromptWithDatasets();
      Navigator.pop(context, {
        'title': _titleController.text,
        'blocks': _blocks,
        'prompt': promptText,
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialBlocks == null ? 'Create Prompt' : 'Edit Prompt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isDirty) {
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
            icon: const Icon(Icons.check),
            onPressed: _savePrompt,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Column(
        children: [
          // Title section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              autofocus: true,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter prompt title...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _isDirty = true;
                });
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Blocks section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerTheme.color ?? Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prompt Blocks (${_blocks.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    setState(() {
                      _isAddingBlock = true;
                    });
                  },
                  tooltip: 'Add Block',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          
          // Blocks list
          Expanded(
            child: _blocks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No blocks yet\nTap + to add your first block',
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
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final block = _blocks.removeAt(oldIndex);
                      _blocks.insert(newIndex, block);
                      _isDirty = true;
                    });
                  },
                  itemCount: _blocks.length,
                  itemBuilder: (context, index) {
                    final block = _blocks[index];
                    final isCollapsed = _collapsedBlocks.contains(block.id);
                    
                    return SimplePromptBlockWidget(
                      key: ValueKey(block.id),
                      block: block,
                      index: index,
                      isCollapsed: isCollapsed,
                      onToggleCollapse: (collapsed) => _toggleBlockCollapse(index, collapsed),
                      onUpdate: (updatedBlock) => _updateBlock(index, updatedBlock),
                      onRemove: () => _removeBlock(index),
                      onAddVariation: () => _addVariation(index),
                    );
                  },
                ),
          ),
          
          // Add block menu
          if (_isAddingBlock)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.text_fields, color: Colors.blue),
                    ),
                    title: const Text('Text Block'),
                    subtitle: const Text('Add simple text to your prompt'),
                    onTap: () {
                      _addTextBlock();
                      setState(() {
                        _isAddingBlock = false;
                      });
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.data_array, color: Colors.green),
                    ),
                    title: const Text('Dataset Block'),
                    subtitle: const Text('Insert items from a dataset'),
                    onTap: () {
                      _addDatasetBlock();
                      setState(() {
                        _isAddingBlock = false;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 