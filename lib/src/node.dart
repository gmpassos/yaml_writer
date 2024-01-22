sealed class Node {
  bool get requiresNewLine => false;
}

class NullNode extends Node {}

class NumNode extends Node {
  final num number;

  NumNode(this.number);
}

class BoolNode extends Node {
  final bool boolean;

  BoolNode(this.boolean);
}

class StringNode extends Node {
  final String text;

  StringNode(this.text);
}

class ListNode extends Node {
  final List<Node> subnodes;

  ListNode(this.subnodes);

  @override
  bool get requiresNewLine => subnodes.isNotEmpty;
}

class MapNode extends Node {
  final Map<String, Node> subnodesMap;

  MapNode(this.subnodesMap);

  @override
  bool get requiresNewLine => subnodesMap.isNotEmpty;
}
