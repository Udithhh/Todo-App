import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_todo_app/screens/add_pages.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Todo App",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: fetchTodo,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map<String, dynamic>;
                  final id = item['_id'] as String;
                  return Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),
                      title: Text(item['title'] ?? 'No Title'),
                      subtitle: Text(item['description'] ?? 'No Description'),
                      trailing: PopupMenuButton(onSelected: (value) {
                        if (value == "edit") {
                          //perform edit
                          navigateToEditPage(item);
                        } else if (value == "delete") {
                          //perform delete operation
                          deleteById(id);
                        }
                      }, itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: "edit",
                            child: Text("Edit"),
                          ),
                          const PopupMenuItem(
                            value: "delete",
                            child: Text("Delete"),
                          )
                        ];
                      }),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: navigateToAddPage,
        child: const Text(
          "ADD",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTodoList(todo: item)),
    );

    // Check if the result indicates an update and refresh the list if needed

    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoList()),
    );
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    //Delete the item
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      //Remove the item from the current list
      final filteredItem =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItem;
      });
    } else {
      //show error
      showErrorMessage("Enable to delete");
    }
  }

  Future<void> fetchTodo() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json['items'] as List? ?? [];
      setState(() {
        items = result.reversed.toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
