class PromptModel {
  final String id;
  final String template;
  final Map<String, List<String>> variables;
  final List<String> categories;
  
  PromptModel({
    required this.id,
    required this.template,
    required this.variables,
    required this.categories,
  });
  
  factory PromptModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> variablesMap = {};
    (json['variables'] as Map<String, dynamic>).forEach((key, value) {
      variablesMap[key] = List<String>.from(value);
    });
    
    return PromptModel(
      id: json['id'],
      template: json['template'],
      variables: variablesMap,
      categories: List<String>.from(json['categories'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template': template,
      'variables': variables,
      'categories': categories,
    };
  }
} 