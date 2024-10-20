import 'dart:math';

import 'yaml_context.dart';

sealed class Node {
  bool get requiresNewLine => false;

  List<String> toYaml(YamlContext context);
}

class NullNode extends Node {
  @override
  List<String> toYaml(YamlContext context) => ['null'];
}

class NumNode extends Node {
  final num number;

  NumNode(this.number);

  @override
  List<String> toYaml(YamlContext context) => ['$number'];
}

class BoolNode extends Node {
  final bool boolean;

  BoolNode(this.boolean);

  @override
  List<String> toYaml(YamlContext context) => ['$boolean'];
}

class StringNode extends Node {
  final String text;

  StringNode(this.text);

  @override
  List<String> toYaml(YamlContext context) {
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

      if (context.allowUnquotedStrings &&
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
}

class ListNode extends Node {
  final List<Node> subnodes;

  ListNode(this.subnodes);

  @override
  bool get requiresNewLine => subnodes.isNotEmpty;

  @override
  List<String> toYaml(YamlContext context) {
    if (subnodes.isEmpty) {
      return ['[]'];
    }

    final List<String> lines = [];

    for (final node in subnodes) {
      final nodeYaml = node.toYaml(context);

      final firstIndent = "-${' ' * max(1, context.indentSize - 1)}";
      final subsequentIndent = ' ' * firstIndent.length;

      lines.add("$firstIndent${nodeYaml.first}");
      for (int i = 1; i < nodeYaml.length; i++) {
        lines.add("$subsequentIndent${nodeYaml[i]}");
      }
    }

    return lines;
  }
}

class MapNode extends Node {
  final Map<String, Node> subnodesMap;

  MapNode(this.subnodesMap);

  @override
  bool get requiresNewLine => subnodesMap.isNotEmpty;

  @override
  List<String> toYaml(YamlContext context) {
    if (subnodesMap.isEmpty) {
      return ['{}'];
    }

    final List<String> lines = [];

    for (final entry in subnodesMap.entries) {
      final key = entry.key;
      final node = entry.value;

      final nodeYaml = node.toYaml(context);

      final indent = ' ' * context.indentSize;

      if (node.requiresNewLine) {
        lines.add("$key:");
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
