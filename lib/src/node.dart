import 'dart:math';

import 'config.dart';

class YamlContext {
  final YamlWriterConfig config;

  const YamlContext({
    required this.config,
  });
}

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
    if (text.isEmpty) {
      // if the text is empty, use the empty string literal
      yamlLines.add(context.config.emptyStringLiteral.literal);
    } else if (text.contains('\n')) {
      // if the text is multiline, use the vertical bar
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
      final containsSingleQuote = text.contains("'");
      final containsDoubleQuote = text.contains('"');

      if (containsSingleQuote && containsDoubleQuote) {
        // if contains both single and double quote, use folded block scalar
        final result = text.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
        yamlLines.add('"$result"');
      } else if (containsSingleQuote) {
        // if contains single quote, use double quote
        yamlLines.add('"$text"');
      } else if (containsDoubleQuote) {
        // if contains double quote, use string quote
        yamlLines.add("'$text'");
      } else {
        if (!context.config.forceQuotedString && _isValidUnquotedString(text)) {
          // if allowUnquotedStrings is true and the string is valid unquoted, use no quote
          yamlLines.add(text);
        } else {
          // otherwise, use the preferred quote style
          if (context.config.quoteStyle == QuoteStyle.preferSingleQuote) {
            yamlLines.add("'$text'");
          } else {
            yamlLines.add('"$text"');
          }
        }
      }
    }

    return yamlLines;
  }

  static final _invalidCharsRegex = RegExp(
    r'^[:{}\[\]>,&*#?|@-]|^\s+|\s+$|\n|\t|^[0-9]+$|^[0-9]*\.[0-9]+$',
  );

  bool _isValidUnquotedString(String s) => !_invalidCharsRegex.hasMatch(s);
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

      final firstIndent = "-${' ' * max(1, context.config.indentSize - 1)}";
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

      final indent = ' ' * context.config.indentSize;

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
