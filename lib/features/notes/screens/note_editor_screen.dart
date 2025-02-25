import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/models/note_model.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/services/mock_storage_service.dart';
import 'package:prompt_note_app/services/mock_database_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;
  final String? initialContent;

  const NoteEditorScreen({
    Key? key,
    this.note,
    this.initialContent,
  }) : super(key: key);

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _contentFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isEdited = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _tagsController.text = widget.note!.tags.join(', ');
    }
    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (widget.note == null) {
          FocusScope.of(context).requestFocus(_contentFocusNode);
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _contentFocusNode.dispose();
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

  void _saveNote() {
    setState(() {
      _errorMessage = null;
    });
    
    final authService = Provider.of<MockAuthService>(context, listen: false);
    if (authService.user == null) {
      setState(() {
        _errorMessage = 'You must be logged in to save notes';
      });
      return;
    }
    
    final userId = authService.user!.uid;
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    final tagsList = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    
    final storageService = Provider.of<MockStorageService>(context, listen: false);
    
    if (widget.note == null) {
      final newNote = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        tags: tagsList,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
      );
      
      storageService.insertNote(newNote).then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to save note: $error';
        });
      });
    } else {
      final updatedNote = NoteModel(
        id: widget.note!.id,
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        tags: tagsList,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
      );
      
      storageService.updateNote(updatedNote).then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to update note: $error';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
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
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      autofocus: widget.note == null,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter note title',
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
                    const Divider(),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: 'Add tags (comma-separated)',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.tag),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _isEdited = true;
                        });
                      },
                    ),
                    const Divider(),
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Write your note here',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 16),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter note content';
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
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
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
            ),
    );
  }
} 