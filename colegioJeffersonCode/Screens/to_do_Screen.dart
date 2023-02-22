//con esta clase puede cambiar su apariencia en respuesta a eventos desencadenados por interacciones del usuario o cuando recibe datos
class to_doScreen extends StatefulWidget {
  const to_doScreen({super.key});

  @override
  State<to_doScreen> createState() => _to_doScreenState();
}

class _to_doScreenState extends State<to_doScreen> {
  final todosList =
      ToDo.todoList(); //es para llamar a la lista que tiene en la funcion ToDO
  bool completed =
      false; //declaramos la variable que usa verdero o falso llamado bool si esta completado la tare si o no
  List<ToDo> _foundToDo =
      []; //esta es una lista que la declaramos para usarla aca para no usar el todolist
  final _todoController =
      TextEditingController(); //esto es en el TextField para saber que escribes

  @override
  //este initState es una funcion que se activa cuando entras a la pagina, solo pasa una vez
  void initState() {
    _foundToDo = todosList;
    //print(FirebaseAuth.instance.currentUser!.uid);

    super.initState();
  }

//esta funcion la creamos para llamar a la base de datos firebase y que sepa que ese usuario tenga esas tareas
  void listedTodo(String title) async {
    await OurDatabase()
        .createList(title, FirebaseAuth.instance.currentUser!.uid);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context,
        listen:
            false); //hacemos esta variable para llamar al por ahora usuario que esta conectado

    return Scaffold(
        body: StreamBuilder<List<ToDo>>(
            //este stream builder es para solo que aparezca en la pagina la lista de ToDo y que no aparezca cosas que no existen y no se han escrito
            stream: OurDatabase().listTodos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<ToDo>? todos = snapshot.data;
              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(children: [
                      Container(
                        child: Text(
                          "To-do List",
                          style: TextStyle(fontSize: 40),
                        ),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(top: 40),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          onChanged: (value) => _runFilter(value),
                          decoration: InputDecoration(
                              fillColor: Colors.blue,
                              labelText: "Search",
                              hintText: "Search",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(26.0)))),
                        ),
                      ),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 160),
                    // ignore: sort_child_properties_last
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[800],
                      ),
                      shrinkWrap: true,
                      itemCount: todos!.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(todos[index]
                              .todoText), //esto es el texto que tiene en base de datos
                          child: ListTile(
                            onTap: () {
                              // la funcion setState siempre esta pasando y para cuando te sales de esta pagina
                              setState(() {
                                OurDatabase().completeTask(todos[index].id,
                                    completed); // esto es para saber si en la base de datos esa tarea esta terminado o no
                                completed =
                                    !completed; // el ! en completed es decir que esta al reves, entonces si completed es True con el ! dices que es falso
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            tileColor: Colors.white,
                            leading: Icon(
                              todos[index]
                                      .isDone //esto es en el icono con check y aqui llama si esta listo o no
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Colors.black87,
                            ),
                            title: Text(
                              todos[index]
                                  .todoText, // es el texto que esta en la base de datos y que se ponga en la pagina
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                decoration: todos[index].isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.symmetric(vertical: 12),
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: IconButton(
                                color: Colors.white,
                                iconSize: 18,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  OurDatabase().delteTask(todos[index]
                                      .id); // con esto borramos el trabajo en la base de datos y en la pagina a tiempo real
                                  // print('Clicked on delete icon');
                                  print("deleted");
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 15, bottom: 17),
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      //con este boton es para agregar una nueva tarea o trabajo y nos aparece una mini pagina para escribir la tarea
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: const Text("Add Todo"),
                                content: Container(
                                  width: 400,
                                  height: 100,
                                  child: Column(
                                    children: [
                                      //aqui escribimos la nueva tarea
                                      TextFormField(
                                        decoration: InputDecoration(
                                            fillColor: Colors.blue,
                                            labelText: "Search",
                                            hintText: "Search",
                                            disabledBorder: InputBorder.none,
                                            prefixIcon: Icon(Icons.search),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(26.0)))),
                                        controller:
                                            _todoController, //con esto podemos mandar en cualquier funcion lo que pusimos en la tarea
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        //con este if es para decirle al codigo que no haga nada aun porque no tenemos nada escrito en el textField
                                        if (_todoController.text.isNotEmpty) {
                                          _addToDoItem(_todoController
                                              .text); //agregamos en la lista
                                          listedTodo(_todoController
                                              .text); //agregamos en la base de datos
                                        }
                                      },
                                      child: const Text("Add"))
                                ],
                              );
                            });
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              );
            }));
  }

//esta funcion es para decir si esta listo o no (true or false)
  void _handleToDoChange(ToDo todo, uid) {
    setState(() async {
      todo.isDone = !todo.isDone;
    });
  }

//borramos el trbajo en la lista
  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
    });
  }

//agregamos trabajo en la lista
  void _addToDoItem(String toDo) {
    setState(() {
      todosList.add(ToDo(
        isDone: false,
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), //esto usamos el dia y lo ponemos en miilisegundos para ponerlo como si es un codigo
        todoText: toDo,
      ));
    });
  }

//esta funcion es para el buscador y con esto bsucamso en la lista el nombre que pongmos en el buscador
  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }
}
