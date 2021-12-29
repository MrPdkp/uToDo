import 'package:flutter/material.dart';
import 'helper.dart';

void main() {
  runApp(const uToDo());
}

class uToDo extends StatelessWidget {
  const uToDo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'uTodo',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  // All tasks
  List<Map<String, dynamic>> _tasks = [];

  bool _isLoading = true;

  // Fetch all data from the database
  void _reloadTasks() async {
    final data = await helper.getTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _reloadTasks(); // Loading the tasks when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Function triggers when the floating button is pressed
  // Triggers when want to update an task
  void _showForm(int? id) async {
    if (id != null) {
      final existingTask = _tasks.firstWhere((element) => element['id'] == id);
      _titleController.text = existingTask['title'];
      _descController.text = existingTask['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 220,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'Title'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descController,
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Save new task
                        if (id == null) {
                          await _addTask();
                        }

                        if (id != null) {
                          await _updateTask(id);
                        }

                        // Clear the text fields
                        _titleController.text = '';
                        _descController.text = '';

                        // Close the bottom sheet
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    )
                  ],
                ),
              ),
            ));
  }

// Insert a new task to the database
  Future<void> _addTask() async {
    await helper.createTask(_titleController.text, _descController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('New Task Created!'),
    ));
    _reloadTasks();
  }

  // Update an existing task
  Future<void> _updateTask(int id) async {
    await helper.updateTask(id, _titleController.text, _descController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task Updated!'),
    ));
    _reloadTasks();
  }

  // Delete a task
  void _deleteTask(int id) async {
    await helper.deleteTask(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task Deleted!'),
    ));
    _reloadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('uToDo'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_tasks[index]['title']),
                    subtitle: Text(_tasks[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_tasks[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTask(_tasks[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
