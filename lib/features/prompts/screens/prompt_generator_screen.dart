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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompts'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saved prompts list header
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Prompts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                  onPressed: _createCustomPrompt,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          Icons.format_quote,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No saved prompts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _createCustomPrompt,
                          child: const Text('Create Your First Prompt'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    itemCount: _savedPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = _savedPrompts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _usePrompt(prompt['content'] as String),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        prompt['title'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 36,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            onPressed: () => _editPrompt(index),
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(8),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18),
                                            onPressed: () => _deletePrompt(index),
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(8),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prompt['content'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    height: 1.3,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
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