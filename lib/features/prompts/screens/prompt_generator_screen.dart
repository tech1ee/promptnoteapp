import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/services/prompt_service.dart';
import 'package:prompt_note_app/features/prompts/screens/prompt_editor_screen.dart';
import 'package:prompt_note_app/models/prompt_block_model.dart';

class PromptGeneratorScreen extends StatefulWidget {
  const PromptGeneratorScreen({Key? key}) : super(key: key);

  @override
  _PromptGeneratorScreenState createState() => _PromptGeneratorScreenState();
}

class _PromptGeneratorScreenState extends State<PromptGeneratorScreen> {
  List<Map<String, dynamic>> _savedPrompts = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPrompts();
  }

  void _loadSavedPrompts() {
    // In a real app, load from database or service
    // For now, populate with a few examples
    setState(() {
      _savedPrompts = [
        {
          'id': '1',
          'title': 'Fantasy World Building',
          'content': 'Create a world where magic is fueled by emotions. What happens when someone experiences extreme joy?',
        },
        {
          'id': '2',
          'title': 'Sci-Fi Technology',
          'content': 'A new technology allows people to share memories. How does this transform society?',
        },
        {
          'id': '3',
          'title': 'Mystery Plot',
          'content': 'A small town experiences a complete communications blackout. When services are restored 24 hours later, something has changed.',
        },
      ];
    });
  }

  void _usePrompt(String prompt) {
    // Instead of opening a note, copy to clipboard
    Clipboard.setData(ClipboardData(text: prompt)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _createCustomPrompt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PromptEditorScreen(),
      ),
    ).then((result) {
      if (result != null && result.containsKey('prompt')) {
        // Add the new prompt to the list
        setState(() {
          _savedPrompts.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'title': result['title'] ?? 'New Prompt',
            'content': result['prompt'] as String,
          });
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt created!')),
        );
      }
    });
  }

  void _editPrompt(int index) {
    final prompt = _savedPrompts[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromptEditorScreen(
          title: prompt['title'] as String,
          initialBlocks: [
            PromptBlockModel.text(prompt['content'] as String),
          ],
        ),
      ),
    ).then((result) {
      if (result != null && result.containsKey('prompt')) {
        // Update the prompt
        setState(() {
          _savedPrompts[index] = {
            'id': prompt['id'],
            'title': result['title'] ?? 'Updated Prompt',
            'content': result['prompt'] as String,
          };
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt updated!')),
        );
      }
    });
  }

  void _deletePrompt(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: const Text(
          'Are you sure you want to delete this prompt?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _savedPrompts.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prompt deleted')),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompts'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createCustomPrompt,
            tooltip: 'Create Prompt',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saved prompts list header
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
                  'Your Prompts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Your prompts list
          Expanded(
            child: _savedPrompts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved prompts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _createCustomPrompt,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Create Your First Prompt'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _savedPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = _savedPrompts[index];
                      return InkWell(
                        onTap: () => _usePrompt(prompt['content'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      prompt['title'] as String,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20),
                                        onPressed: () => _editPrompt(index),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        visualDensity: VisualDensity.compact,
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        onPressed: () => _deletePrompt(index),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        visualDensity: VisualDensity.compact,
                                        tooltip: 'Delete',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.content_copy_outlined, size: 20),
                                        onPressed: () => _usePrompt(prompt['content'] as String),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        visualDensity: VisualDensity.compact,
                                        tooltip: 'Copy',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prompt['content'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 