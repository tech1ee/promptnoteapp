import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum BlockType {
  text,
  variable,
  conditional,
  template
}

class PromptBlockModel {
  final String id;
  final BlockType type;
  String content;
  Map<String, dynamic>? parameters;
  List<PromptBlockModel>? children;
  List<String> variations;
  int selectedVariation;

  PromptBlockModel({
    String? id,
    required this.type,
    required this.content,
    this.parameters,
    this.children,
    List<String>? variations,
    this.selectedVariation = 0,
  }) : 
    id = id ?? const Uuid().v4(),
    variations = variations ?? [content];

  factory PromptBlockModel.text(String content, {List<String>? variations}) {
    return PromptBlockModel(
      type: BlockType.text,
      content: content,
      variations: variations ?? [content],
    );
  }

  factory PromptBlockModel.variable(String name, List<String> options) {
    return PromptBlockModel(
      type: BlockType.variable,
      content: name,
      parameters: {
        'options': options,
        'defaultValue': options.isNotEmpty ? options.first : '',
      },
    );
  }

  factory PromptBlockModel.conditional(String condition, List<PromptBlockModel> ifBlocks, List<PromptBlockModel> elseBlocks) {
    return PromptBlockModel(
      type: BlockType.conditional,
      content: condition,
      children: [...ifBlocks, ...elseBlocks],
      parameters: {
        'ifCount': ifBlocks.length,
        'elseCount': elseBlocks.length,
      },
    );
  }

  factory PromptBlockModel.template(String templateName, Map<String, dynamic> templateParams) {
    return PromptBlockModel(
      type: BlockType.template,
      content: templateName,
      parameters: templateParams,
    );
  }

  void addVariation(String variation) {
    variations.add(variation);
  }

  void selectVariation(int index) {
    if (index >= 0 && index < variations.length) {
      selectedVariation = index;
      content = variations[index];
    }
  }

  PromptBlockModel copyWith({
    BlockType? type,
    String? content,
    Map<String, dynamic>? parameters,
    List<PromptBlockModel>? children,
    List<String>? variations,
    int? selectedVariation,
  }) {
    return PromptBlockModel(
      id: id,
      type: type ?? this.type,
      content: content ?? this.content,
      parameters: parameters ?? this.parameters,
      children: children ?? this.children,
      variations: variations ?? this.variations,
      selectedVariation: selectedVariation ?? this.selectedVariation,
    );
  }
} 