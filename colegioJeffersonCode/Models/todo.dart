class ToDo {
  String id;
  String todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    required this.isDone,
  });

  static List<ToDo> todoList() {
    return [];
  }
}
