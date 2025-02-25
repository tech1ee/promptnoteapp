import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/prompt_block_model.dart';

class PromptBlockWidget extends StatefulWidget {
  final PromptBlockModel block;
  final Function(PromptBlockModel) onUpdate;
  final Function() onRemove;
  final Function(PromptBlockModel) onAddAfter;

  const PromptBlockWidget({
    Key? key,
    required this.block,
    required this.onUpdate,
    required this.onRemove,
    required this.onAddAfter,
  }) : super(key: key);

  @override
  _PromptBlockWidgetState createState() => _PromptBlockWidgetState();
}

class _PromptBlockWidgetState extends State<PromptBlockWidget> {
  late TextEditingController _contentController;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.block.content);
    _isExpanded = false;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PromptBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content) {
      _contentController.text = widget.block.content;
    }
  }

  Widget _buildBlockContent() {
    switch (widget.block.type) {
      case BlockType.text:
        return TextField(
          controller: _contentController,
          decoration: const InputDecoration(
            hintText: 'Enter text...',
            border: InputBorder.none,
          ),
          maxLines: null,
          onChanged: (value) {
            widget.onUpdate(widget.block.copyWith(content: value));
          },
        );
      
      case BlockType.variable:
        final options = (widget.block.parameters?['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync_alt, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Variable name',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      widget.onUpdate(widget.block.copyWith(content: value));
                    },
                  ),
                ),
              ],
            ),
            if (_isExpanded) ...[
              const Divider(),
              const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: TextFormField(
                          initialValue: option,
                          decoration: InputDecoration(
                            hintText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (value) {
                            final newOptions = List<String>.from(options);
                            newOptions[index] = value;
                            final newParams = Map<String, dynamic>.from(widget.block.parameters ?? {});
                            newParams['options'] = newOptions;
                            widget.onUpdate(widget.block.copyWith(parameters: newParams));
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        final newOptions = List<String>.from(options);
                        newOptions.removeAt(index);
                        final newParams = Map<String, dynamic>.from(widget.block.parameters ?? {});
                        newParams['options'] = newOptions;
                        widget.onUpdate(widget.block.copyWith(parameters: newParams));
                      },
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
                onPressed: () {
                  final newOptions = List<String>.from(options);
                  newOptions.add('');
                  final newParams = Map<String, dynamic>.from(widget.block.parameters ?? {});
                  newParams['options'] = newOptions;
                  widget.onUpdate(widget.block.copyWith(parameters: newParams));
                },
              ),
            ],
          ],
        );
      
      case BlockType.conditional:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rule, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Condition (e.g., "user.isPremium")',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      widget.onUpdate(widget.block.copyWith(content: value));
                    },
                  ),
                ),
              ],
            ),
            if (_isExpanded && widget.block.children != null) ...[
              const Divider(),
              const Text('If True:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Recursive block rendering would go here
              const Text('If False:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Recursive block rendering would go here
            ],
          ],
        );
      
      case BlockType.template:
        return Row(
          children: [
            const Icon(Icons.auto_awesome, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Template name',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  widget.onUpdate(widget.block.copyWith(content: value));
                },
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockColor = _getBlockColor(widget.block.type, context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: blockColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: blockColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  _getBlockTypeLabel(widget.block.type),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: blockColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  tooltip: _isExpanded ? 'Collapse' : 'Expand',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showAddMenu(context);
                  },
                  tooltip: 'Add block after',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove block',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildBlockContent(),
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<BlockType>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: BlockType.text,
          child: Row(
            children: const [
              Icon(Icons.text_fields),
              SizedBox(width: 8),
              Text('Text Block'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BlockType.variable,
          child: Row(
            children: const [
              Icon(Icons.sync_alt),
              SizedBox(width: 8),
              Text('Variable Block'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BlockType.conditional,
          child: Row(
            children: const [
              Icon(Icons.rule),
              SizedBox(width: 8),
              Text('Conditional Block'),
            ],
          ),
        ),
        PopupMenuItem(
          value: BlockType.template,
          child: Row(
            children: const [
              Icon(Icons.auto_awesome),
              SizedBox(width: 8),
              Text('Template Block'),
            ],
          ),
        ),
      ],
    ).then((type) {
      if (type != null) {
        PromptBlockModel newBlock;
        switch (type) {
          case BlockType.text:
            newBlock = PromptBlockModel.text('');
            break;
          case BlockType.variable:
            newBlock = PromptBlockModel.variable('variable', ['Option 1']);
            break;
          case BlockType.conditional:
            newBlock = PromptBlockModel.conditional('condition', [], []);
            break;
          case BlockType.template:
            newBlock = PromptBlockModel.template('template', {});
            break;
        }
        widget.onAddAfter(newBlock);
      }
    });
  }

  String _getBlockTypeLabel(BlockType type) {
    switch (type) {
      case BlockType.text:
        return 'Text';
      case BlockType.variable:
        return 'Variable';
      case BlockType.conditional:
        return 'Conditional';
      case BlockType.template:
        return 'Template';
    }
  }

  Color _getBlockColor(BlockType type, BuildContext context) {
    switch (type) {
      case BlockType.text:
        return Colors.blue;
      case BlockType.variable:
        return Colors.green;
      case BlockType.conditional:
        return Colors.orange;
      case BlockType.template:
        return Colors.purple;
    }
  }
} 