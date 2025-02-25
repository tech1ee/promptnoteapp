import 'package:flutter/material.dart';

class PromptService with ChangeNotifier {
  final Map<String, List<String>> _templatePrompts = {
    'fantasy': [
      'Create a world where magic is fueled by emotions. What happens when someone experiences extreme joy?',
      'A dragon has been hiding as a human for centuries. Today, they reveal themselves because...',
      'In a world where everyone has a magical familiar, your character discovers theirs is actually a legendary creature thought to be extinct.'
    ],
    'sci-fi': [
      'Humanity discovers a signal from deep space that contains instructions to build a device. What does the device do?',
      'A new technology allows people to share memories. How does this transform society?',
      'Time travelers from the future arrive, but they\'re not here to change history—they\'re refugees from a future catastrophe.'
    ],
    'mystery': [
      'A detective investigates a series of thefts where nothing valuable was taken, but each victim finds something new in their home afterward.',
      'A small town experiences a complete communications blackout. When services are restored 24 hours later, something has changed.',
      'Every year on the same date, someone in town receives an anonymous gift that somehow predicts their future.'
    ],
    'romance': [
      'Two rivals in a cooking competition find themselves drawn to each other despite their fierce competition.',
      'Your character discovers that their anonymous online friend is actually someone they know in real life.',
      'A chance meeting during a city-wide power outage leads to an unexpected connection.'
    ]
  };

  List<String> getCategories() {
    return _templatePrompts.keys.toList();
  }

  String generatePrompt(String category) {
    if (!_templatePrompts.containsKey(category)) {
      return 'Please select a valid category.';
    }
    
    final prompts = _templatePrompts[category]!;
    final index = DateTime.now().millisecondsSinceEpoch % prompts.length;
    return prompts[index];
  }

  // Save custom prompt template
  Future<void> savePromptTemplate(String title, List<dynamic> blocks) async {
    // Here you would typically save to a database
    // For now, we'll just print
    print('Saved prompt template: $title with ${blocks.length} blocks');
  }
} 