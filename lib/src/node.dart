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
      // if the text is empty, wrap with preferred quotes.
      final quote = context.config.quoteStyle.char;
      yamlLines.add("$quote$quote");
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
        // if contains both single and double quote, escape the double quote,
        // and use double quote
        var result = text.replaceAll(r'\', r'\\');
        switch (context.config.quoteStyle) {
          case QuoteStyle.preferSingleQuote:
            result = result.replaceAll("'", "''");
            yamlLines.add("'$result'");
            break;
          case QuoteStyle.preferDoubleQuote:
            result = result.replaceAll('"', r'\"');
            yamlLines.add('"$result"');
            break;
        }
      } else if (containsSingleQuote) {
        // if contains single quote, use double quote
        yamlLines.add('"$text"');
      } else if (containsDoubleQuote) {
        // if contains double quote, use string quote
        yamlLines.add("'$text'");
      } else {
        if (!context.config.forceQuotedString && isValidUnquotedString(text)) {
          // if forceQuotedString is false and the string is valid unquoted,
          // don't use any quote
          yamlLines.add(text);
        } else {
          // otherwise, use the preferred quote
          final quote = context.config.quoteStyle.char;
          yamlLines.add("$quote$text$quote");
        }
      }
    }

    return yamlLines;
  }

  static final _invalidCharsRegex = RegExp(
    r"^(true|false|null|~|\?|:|-)$|^\s+|\s+$|\n|\r|^[{}\[\]>,&*#|@%]|^-?(?:\d+(?:\.\d+)?|\.\d+)$|^(- |\? )|:\s*$|:\s+\S|\s+#",
  );

  /// ## Quoting Rules
  /// ### Numbers
  /// 1. Integer and decimals (including negative) are invalid.
  ///
  /// ### at sign
  /// 1. Starting with at sign is invalid.
  ///
  /// ### Question mark
  /// 1. Only a single question mark is invalid.
  /// 2. Starting with question mark+whitespace is invalid.
  ///
  /// ### Dash
  /// 1. Only a single dash is invalid.
  /// 2. Starting with dash+whitespace is invalid.
  ///
  /// ### Colon
  /// 1. Only a single colon is invalid.
  /// 2. Colon+whitespace is invalid.
  /// 3. Colon+1+whitespace+non-whitespace is invalid.
  ///
  /// ### Brackets
  /// 1. Starting with square brackets is invalid.
  /// 2. Starting with curly brackets is invalid.
  /// 3. Starting with angle bracket closing part is invalid.
  /// 4. Starting with angle bracket closing part+dash (>-) is invalid.
  ///
  /// ### Comma
  /// 1. Starting with comma is invalid.
  ///
  /// ### Ampersand
  /// 1. Starting with ampersand is invalid.
  ///
  /// ### Star
  /// 1. Starting with star is invalid.
  ///
  /// ### Pipe
  /// 1. Starting with pipe is invalid.
  /// 2. Starting with pipe+dash (|-) is invalid.
  ///
  /// ### Hash
  /// 1. Starting with hash is invalid.
  /// 2. Ending with whitespace+hash is invalid.
  ///
  /// ### Whitespace
  /// 1. Starting with one or more whitespace is invalid.
  /// 2. Ending with one or more whitespace is invalid.
  /// 3. Containing \n, \t, \r is invalid.
  ///
  /// ### Percentage
  /// 1. Starting with percentage is invalid.
  ///
  /// ### Builtin Literal
  /// 1. Only a single tide is invalid.
  /// 2. `true`, `false`, and `null` are invalid.
  ///
  static bool isValidUnquotedString(String s) =>
      !_invalidCharsRegex.hasMatch(s);
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
