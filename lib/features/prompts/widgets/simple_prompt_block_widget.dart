import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/prompt_block_model.dart';

class SimplePromptBlockWidget extends StatefulWidget {
  final PromptBlockModel block;
  final Function(PromptBlockModel) onUpdate;
  final Function() onRemove;
  final Function() onAddVariation;
  final bool isCollapsed;
  final Function(bool) onToggleCollapse;

  const SimplePromptBlockWidget({
    Key? key,
    required this.block,
    required this.onUpdate,
    required this.onRemove,
    required this.onAddVariation,
    required this.isCollapsed,
    required this.onToggleCollapse,
  }) : super(key: key);

  @override
  _SimplePromptBlockWidgetState createState() => _SimplePromptBlockWidgetState();
}

class _SimplePromptBlockWidgetState extends State<SimplePromptBlockWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.block.content);
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block header - simplified
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Block#${widget.block.id.substring(0, 6)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    widget.onToggleCollapse(!widget.isCollapsed);
                  },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      widget.isCollapsed 
                          ? Icons.keyboard_arrow_down 
                          : Icons.keyboard_arrow_up,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: widget.onRemove,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content area - focus on text
          if (!widget.isCollapsed)
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
                  fontSize: 16,
                  height: 1.5, // Better line spacing for readability
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
          
          // Variations buttons - lighter design
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Show variation buttons with improved UI - no square shape
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
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              fontSize: 13,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                
                // Add variation button - also circular and lightweight
                InkWell(
                  onTap: widget.onAddVariation,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 