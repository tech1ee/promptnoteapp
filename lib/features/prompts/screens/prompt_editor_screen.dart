import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prompt_note_app/models/prompt_block_model.dart';
import 'package:prompt_note_app/features/prompts/widgets/simple_prompt_block_widget.dart';

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

  void _addBlock() {
    setState(() {
      _blocks.add(PromptBlockModel.text(''));
      _isDirty = true;
    });
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
      prompt.write(block.content);
      prompt.write(' ');
    }
    
    return prompt.toString().trim();
  }

  void _copyPromptToClipboard() {
    final prompt = _generatePrompt();
    Clipboard.setData(ClipboardData(text: prompt)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _savePrompt() {
    if (_isDirty) {
      Navigator.pop(context, {
        'title': _titleController.text,
        'blocks': _blocks,
        'prompt': _generatePrompt(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialBlocks == null ? 'Create Prompt' : 'Edit Prompt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: _copyPromptToClipboard,
            tooltip: 'Copy',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePrompt,
            tooltip: 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 4.0, right: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter prompt title...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isDirty = true;
                    });
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          
          ...List.generate(_blocks.length, (index) {
            final block = _blocks[index];
            final isCollapsed = _collapsedBlocks.contains(block.id);
            
            return SimplePromptBlockWidget(
              key: ValueKey(block.id),
              block: block,
              isCollapsed: isCollapsed,
              onToggleCollapse: (collapsed) => _toggleBlockCollapse(index, collapsed),
              onUpdate: (updatedBlock) => _updateBlock(index, updatedBlock),
              onRemove: () => _removeBlock(index),
              onAddVariation: () => _addVariation(index),
            );
          }),
          
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: InkWell(
              onTap: _addBlock,
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Add block...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
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
} 