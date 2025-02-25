import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/prompt_block_model.dart';

class AddBlockMenu extends StatelessWidget {
  final Function(PromptBlockModel) onAddBlock;

  const AddBlockMenu({
    Key? key,
    required this.onAddBlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showAddBlockDialog(context);
      },
      tooltip: 'Add Block',
      child: const Icon(Icons.add),
    );
  }

  void _showAddBlockDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Add Block',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildBlockOption(
                context,
                icon: Icons.text_fields,
                title: 'Text Block',
                subtitle: 'Add simple text to your prompt',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  onAddBlock(PromptBlockModel.text(''));
                },
              ),
              _buildBlockOption(
                context,
                icon: Icons.sync_alt,
                title: 'Variable Block',
                subtitle: 'Add a variable with multiple options',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  onAddBlock(PromptBlockModel.variable('variable', ['Option 1']));
                },
              ),
              _buildBlockOption(
                context,
                icon: Icons.rule,
                title: 'Conditional Block',
                subtitle: 'Add logic based on conditions',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  onAddBlock(PromptBlockModel.conditional('condition', [], []));
                },
              ),
              _buildBlockOption(
                context,
                icon: Icons.auto_awesome,
                title: 'Template Block',
                subtitle: 'Insert a pre-defined template',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  onAddBlock(PromptBlockModel.template('template', {}));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
    );
  }
} 