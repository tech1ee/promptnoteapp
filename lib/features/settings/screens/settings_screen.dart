import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/services/mock_database_service.dart';
import 'package:prompt_note_app/services/mock_purchase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  
  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Provider.of<MockAuthService>(context, listen: false).signOut();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _managePremium() async {
    // This will be connected to in-app purchases
    final purchaseService = Provider.of<MockPurchaseService>(context, listen: false);
    
    if (!purchaseService.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('In-app purchases are not available on this device')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Subscription'),
        content: const Text(
          'Subscribe for \$5/month to get:\n'
          '• Cloud syncing of notes\n'
          '• Unlimited prompt generation\n'
          '• Future premium features',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Integrate with purchaseService.purchaseSubscription()
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription feature coming soon!')),
              );
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<MockAuthService>(context);
    final user = authService.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // User profile section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                // Premium subscription section
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Premium Subscription'),
                  subtitle: Text(
                    user?.isPremium == true
                        ? 'You are a premium subscriber'
                        : 'Upgrade to premium for cloud sync and unlimited prompts',
                  ),
                  trailing: ElevatedButton(
                    onPressed: _managePremium,
                    child: Text(
                      user?.isPremium == true ? 'Manage' : 'Subscribe',
                    ),
                  ),
                ),
                const Divider(),
                
                // About section
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  subtitle: Text('Prompt Note App v1.0.0'),
                ),
                
                const Divider(),
                
                // Sign out button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 