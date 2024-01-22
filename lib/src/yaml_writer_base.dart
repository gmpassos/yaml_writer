import 'dart:convert';
import 'dart:math';

import 'package:yaml_writer/src/node.dart';

@Deprecated('Use YamlWriter.')
typedef YAMLWriter = YamlWriter;

/// YAML Writer.
class YamlWriter extends Converter<Object?, String> {
  static dynamic _defaultToEncodable(dynamic object) => object.toJson();

  /// The indentation size.
  ///
  /// Must be greater or equal to `1`.
  ///
  /// Defaults to `2`.
  final int indentSize;

  /// If `true` it will allow unquoted strings.
  final bool allowUnquotedStrings;

  /// Used to convert objects to an encodable version.
  final Object? Function(dynamic object) toEncodable;

  YamlWriter({
    int indentSize = 2,
    this.allowUnquotedStrings = false,
    Object? Function(dynamic object)? toEncodable,
  })  : indentSize = max(1, indentSize),
        toEncodable = toEncodable ?? _defaultToEncodable;

  /// Converts [input] to an YAML document as [String].
  ///
  /// This implements `dart:convert` [Converter].
  ///
  /// - Calls [write].
  @override
  String convert(Object? input) => write(input);

  /// Writes [object] to an YAML document as [String].
  String write(Object? object) {
    final node = _parseNode(object);
    final yaml = _nodeToYaml(node);
    return '${yaml.join('\n')}\n';
  }

  Node _parseNode(Object? object) {
    if (object == null) {
      return NullNode();
    } else if (object is num) {
      return NumNode(object);
    } else if (object is bool) {
      return BoolNode(object);
    } else if (object is String) {
      return StringNode(object);
    } else if (object is List) {
      return ListNode(object.map(_parseNode).toList());
    } else if (object is Map) {
      return MapNode(object.map((k, v) => MapEntry(k, _parseNode(v))));
    } else {
      return _parseNode(toEncodable(object));
    }
  }

  List<String> _nodeToYaml(Node node) {
    switch (node) {
      case NullNode():
        return ['null'];
      case NumNode():
        return ['${node.number}'];
      case BoolNode():
        return ['${node.boolean}'];
      case StringNode():
        return _stringNodeToYaml(node);
      case ListNode():
        return _listNodeToYaml(node);
      case MapNode():
        return _mapNodeToYaml(node);
    }
  }

  List<String> _stringNodeToYaml(StringNode node) {
    final text = node.text;

    List<String> yamlLines = [];

    if (text.contains('\n')) {
      bool endsWithLineBreak = text.endsWith('\n');

      List<String> lines;
      if (endsWithLineBreak) {
        yamlLines.add('|');
        lines = text.substring(0, text.length - 1).split('\n');
      } else {
        yamlLines.add('|-');
        lines = text.split('\n');
      }

      for (int index = 0; index < lines.length; index++) {
        yamlLines.add(lines[index]);
      }
    } else {
      var containsSingleQuote = text.contains("'");

      if (allowUnquotedStrings &&
          !containsSingleQuote &&
          _isValidUnquotedString(text)) {
        yamlLines.add(text);
      } else if (!containsSingleQuote) {
        yamlLines.add('\'$text\'');
      } else {
        var str = text.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
        yamlLines.add('"$str"');
      }
    }

    return yamlLines;
  }

  static final _regexpInvalidUnquotedChars = RegExp(
      r'[^0-9a-zA-ZàèìòùÀÈÌÒÙáéíóúýÁÉÍÓÚÝâêîôûÂÊÎÔÛãñõÃÑÕäëïöüÿÄËÏÖÜŸçÇßØøÅåÆæœ@/. \t-]');

  bool _isValidUnquotedString(String s) =>
      !_regexpInvalidUnquotedChars.hasMatch(s) &&
      !s.startsWith('@') &&
      !s.startsWith('-');

  List<String> _listNodeToYaml(ListNode node) {
    if (node.subnodes.isEmpty) {
      return ['[]'];
    }

    final List<String> lines = [];

    for (final node in node.subnodes) {
      final nodeYaml = _nodeToYaml(node);

      final firstIndent = "-${' ' * max(1, indentSize - 1)}";
      final subsequentIndent = ' ' * firstIndent.length;

      lines.add("$firstIndent${nodeYaml.first}");
      for (int i = 1; i < nodeYaml.length; i++) {
        lines.add("$subsequentIndent${nodeYaml[i]}");
      }
    }

    return lines;
  }

  List<String> _mapNodeToYaml(MapNode node) {
    if (node.subnodesMap.isEmpty) {
      return ['{}'];
    }

    final List<String> lines = [];

    for (final entry in node.subnodesMap.entries) {
      final key = entry.key;
      final node = entry.value;

      final nodeYaml = _nodeToYaml(node);

      final indent = ' ' * indentSize;

      if (node.requiresNewLine) {
        lines.add("$key: ");
        for (final line in nodeYaml) {
          lines.add("$indent$line");
        }
      } else {
        lines.add("$key: ${nodeYaml.first}");
        for (int i = 1; i < nodeYaml.length; i++) {
          lines.add("$indent${nodeYaml[i]}");
        }
      }
    }

    return lines;
  }
}
