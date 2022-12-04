import 'dart:convert';

/// YAML Writer.
class YAMLWriter extends Converter<Object?, String> {
  /// The indentation size.
  final int indentSize;

  @Deprecated("Use `indentSize`.")
  int get identSize => indentSize;

  /// If `true` it will allow unquoted strings.
  final bool allowUnquotedStrings;

  final String _ident;

  YAMLWriter(
      {int indentSize = 2,
      @Deprecated("Use `indentSize`.") int? identSize,
      this.allowUnquotedStrings = false})
      : indentSize = _resolveIndentSize(indentSize, identSize),
        _ident = ''.padLeft(_resolveIndentSize(indentSize, identSize), ' ');

  static int _resolveIndentSize(int indentSize, int? identSize) {
    var indent = (identSize ?? indentSize);
    return indent < 0 ? 0 : indent;
  }

  /// Used to convert objects to an encodable version.
  Object? Function(dynamic object)? toEncodable;

  /// Converts [input] to an YAML document as [String].
  ///
  /// This implements `dart:convert` [Converter].
  ///
  /// - Calls [write].
  @override
  String convert(Object? input) => write(input);

  /// Writes [node] to an YAML document as [String].
  String write(Object? node) {
    var s = StringBuffer();
    _writeTo(node, s);
    return s.toString();
  }

  bool _writeTo(Object? node, StringBuffer s, {String currentIdent = ''}) {
    if (node == null) {
      return _writeNull(s);
    } else if (node is num) {
      _writeNum(node, s);
      return false;
    } else if (node is bool) {
      _writeBool(node, s);
      return false;
    } else if (node is List) {
      return _writeList(node, s, currentIdent: currentIdent);
    } else if (node is Map) {
      return _writeMap(node, s, currentIdent: currentIdent);
    } else if (node is String) {
      return _writeString(node, s, currentIdent: currentIdent);
    } else {
      return _writeObject(node, s, currentIdent: currentIdent);
    }
  }

  bool _writeNull(StringBuffer s) {
    s.write('null');
    return false;
  }

  bool _writeNum(num node, StringBuffer s) {
    s.write(node);
    return false;
  }

  bool _writeBool(bool node, StringBuffer s) {
    s.write(node);
    return false;
  }

  bool _writeString(String node, StringBuffer s, {String currentIdent = ''}) {
    if (node.contains('\n')) {
      var nextIdent = currentIdent + _ident;

      var endsWithLineBreak = node.endsWith('\n');

      List<String> lines;
      if (endsWithLineBreak) {
        s.write('|\n');
        lines = node.substring(0, node.length - 1).split('\n');
      } else {
        s.write('|-\n');
        lines = node.split('\n');
      }

      for (var line in lines) {
        s.write(nextIdent);
        s.write(line);
        s.write('\n');
      }

      return true;
    } else {
      var containsSingleQuote = node.contains("'");

      if (allowUnquotedStrings &&
          !containsSingleQuote &&
          _isValidUnquotedString(node)) {
        s.write(node);
        return false;
      } else if (!containsSingleQuote) {
        s.write("'");
        s.write(node);
        s.write("'");
        return false;
      } else {
        var str = node.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
        s.write('"');
        s.write(str);
        s.write('"');
        return false;
      }
    }
  }

  static final _regexpInvalidUnquotedChars = RegExp(
      r'[^0-9a-zA-ZàèìòùÀÈÌÒÙáéíóúýÁÉÍÓÚÝâêîôûÂÊÎÔÛãñõÃÑÕäëïöüÿÄËÏÖÜŸçÇßØøÅåÆæœ@/. \t-]');

  bool _isValidUnquotedString(String s) =>
      !_regexpInvalidUnquotedChars.hasMatch(s) &&
      !s.startsWith('@') &&
      !s.startsWith('-');

  static dynamic _defaultToEncodable(dynamic object) => object.toJson();

  bool _writeObject(Object node, StringBuffer s, {String currentIdent = ''}) {
    var toEncodable = this.toEncodable ?? _defaultToEncodable;
    var o = toEncodable(node);
    return _writeTo(o, s, currentIdent: currentIdent);
  }

  bool _writeList(Iterable node, StringBuffer s, {String currentIdent = ''}) {
    if (node.isEmpty) {
      s.write('[]');
      return false;
    }
    if (s.isNotEmpty) {
      s.write('\n');
    }

    var nextIdent = currentIdent + _ident;

    var wroteLineBreak = false;

    for (var item in node) {
      s.write(currentIdent);
      s.write('- ');
      var ln = _writeTo(item, s, currentIdent: nextIdent);
      if (!ln) {
        s.write('\n');
        wroteLineBreak = true;
      }
    }

    return wroteLineBreak;
  }

  bool _writeMap(Map node, StringBuffer s, {String currentIdent = ''}) {
    if (s.isNotEmpty) {
      s.write('\n');
    }

    var nextIdent = currentIdent + _ident;

    var wroteLineBreak = false;

    for (var entry in node.entries) {
      s.write(currentIdent);
      s.write(entry.key);
      s.write(': ');
      var ln = _writeTo(entry.value, s, currentIdent: nextIdent);
      if (!ln) {
        s.write('\n');
        wroteLineBreak = true;
      }
    }

    return wroteLineBreak;
  }
}
