import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/prompt_block_model.dart';
import 'package:prompt_note_app/models/dataset_model.dart';
import 'package:prompt_note_app/services/mock_storage_service.dart';
import 'package:provider/provider.dart';

class SimplePromptBlockWidget extends StatefulWidget {
  final PromptBlockModel block;
  final Function(PromptBlockModel) onUpdate;
  final Function() onRemove;
  final Function() onAddVariation;
  final bool isCollapsed;
  final Function(bool) onToggleCollapse;
  final int index;

  const SimplePromptBlockWidget({
    Key? key,
    required this.block,
    required this.onUpdate,
    required this.onRemove,
    required this.onAddVariation,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.index,
  }) : super(key: key);

  @override
  _SimplePromptBlockWidgetState createState() => _SimplePromptBlockWidgetState();
}

class _SimplePromptBlockWidgetState extends State<SimplePromptBlockWidget> {
  late TextEditingController _textController;
  DatasetModel? _dataset;
  bool _isLoadingDataset = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.block.content);
    
    // Load dataset if this is a dataset block
    if (widget.block.type == BlockType.dataset) {
      _loadDataset();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimplePromptBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update text controller only when switching variations
    if (oldWidget.block.selectedVariation != widget.block.selectedVariation) {
      _textController.text = widget.block.content;
    }
    
    // Reload dataset if dataset ID changed
    if (widget.block.type == BlockType.dataset &&
        oldWidget.block.parameters?['datasetId'] != widget.block.parameters?['datasetId']) {
      _loadDataset();
    }
  }
  
  Future<void> _loadDataset() async {
    if (widget.block.parameters == null || widget.block.parameters!['datasetId'] == null) {
      return;
    }
    
    setState(() {
      _isLoadingDataset = true;
    });
    
    try {
      final storageService = Provider.of<MockStorageService>(context, listen: false);
      final datasetId = widget.block.parameters!['datasetId'] as int;
      final dataset = await storageService.getDataset(datasetId);
      
      if (mounted) {
        setState(() {
          _dataset = dataset;
          _isLoadingDataset = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDataset = false;
        });
      }
    }
  }

  Widget _buildDatasetContent() {
    if (_isLoadingDataset) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_dataset == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Dataset not found'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dataset: ${_dataset!.title}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_dataset!.items.where((item) => !item.disabled).length} active items',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine block icon and color based on type
    IconData blockIcon;
    Color blockColor;
    String blockTypeName;
    
    switch (widget.block.type) {
      case BlockType.dataset:
        blockIcon = Icons.data_array;
        blockColor = Colors.blue;
        blockTypeName = 'Dataset';
        break;
      case BlockType.text:
      default:
        blockIcon = Icons.text_fields;
        blockColor = Colors.grey;
        blockTypeName = 'Text';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 1.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: widget.index,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.drag_handle, 
                    color: Colors.grey, size: 20),
                ),
              ),
              // Block type indicator
              Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  blockIcon,
                  size: 18,
                  color: blockColor,
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Block ${widget.index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.block.type == BlockType.text)
                    IconButton(
                      icon: const Icon(Icons.copy_all, size: 20),
                      onPressed: widget.onAddVariation,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      tooltip: 'Add Variation',
                    ),
                  IconButton(
                    icon: Icon(
                      widget.isCollapsed ? Icons.expand_more : Icons.expand_less,
                      size: 20,
                    ),
                    onPressed: () => widget.onToggleCollapse(!widget.isCollapsed),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: widget.onRemove,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Content area based on block type
          if (!widget.isCollapsed) ...[
            if (widget.block.type == BlockType.dataset)
              _buildDatasetContent()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Prompt text...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                  onChanged: (value) {
                    // Update content and current variation
                    final variations = List<String>.from(widget.block.variations);
                    variations[widget.block.selectedVariation] = value;
                    
                    widget.onUpdate(widget.block.copyWith(
                      content: value,
                      variations: variations,
                    ));
                  },
                ),
              ),
          ],
          
          // Variations buttons only for text blocks
          if (widget.block.type == BlockType.text && !widget.isCollapsed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  // Show variation buttons with improved UI
                  ...widget.block.variations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final isSelected = index == widget.block.selectedVariation;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          // Select this variation
                          if (!isSelected) {
                            final newContent = widget.block.variations[index];
                            
                            // Set text controller text first
                            _textController.text = newContent;
                            
                            // Then update the model
                            widget.onUpdate(widget.block.copyWith(
                              content: newContent,
                              selectedVariation: index,
                            ));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            'v${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 