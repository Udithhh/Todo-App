// ignore_for_file: avoid_print, prefer_const_declarations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoList extends StatefulWidget {
  final Map? todo;
  const AddTodoList({super.key, this.todo});

  @override
  State<AddTodoList> createState() => _AddTodoListState();
}

class _AddTodoListState extends State<AddTodoList> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  //prefilling and changes one page into two use
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final descrption = todo['description'];
      titleController.text = title;
      descriptionController.text = descrption;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40))),
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          isEdit ? "Edit Todo" : "Add Todo",
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(35),
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(hintText: "Title"),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: descriptionController,
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: "Description",
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
                onPressed: isEdit ? updateData : submitData,
                child: Text(
                  isEdit ? "UPDATE" : "SUBMIT",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 2),
                )),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    // Get the data from the form
    final todo = widget.todo;
    if (todo == null) {
      print('You cannot call update on null data');
      return;
    }

    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    // Update data to the server
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    // Show success or error message
    if (response.statusCode == 200 || response.statusCode == 204) {
      titleController.clear();
      descriptionController.clear();
      showSuccessMessage("Successfully updated");
    } else {
      print('Failed to update data: ${response.statusCode} - ${response.body}');
      showErrorMessage("Update failed");
    }
  }

  Future<void> submitData() async {
    // Get data from the form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    // Submit data to the server
    final url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    //show success or failmessage based onstatus
    if (response.statusCode == 201) {
      titleController.clear();
      descriptionController.clear();
      showSuccessMessage("Succesfully added");
    } else {
      showErrorMessage("Failed");
    }
  }

  //succes message
  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //error message
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
