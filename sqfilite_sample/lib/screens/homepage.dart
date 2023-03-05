import 'package:flutter/material.dart';
import 'package:sqfilite_sample/resources/sqlite_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // creating an empty list for getting the data in this list
  List<Map<String, dynamic>> _journal = [];
  bool _isLoading = true;

  Future _addItem() async {
    await Sqlite.createItems(
        _titleController.text, _descriptionController.text);
    _refreshJournal();
  }

  Future<void> _updateItem(int id) async {
    await Sqlite.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournal();
  }

  Future _deleteItem(BuildContext context,int id) async {
    await Sqlite.deleteItems(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sucessfully deleted your notes")));
    _refreshJournal();
  }

  // method for getting data or all data
  void _refreshJournal() async {
    // calling method
    final data = await Sqlite.getAllItemsData();
    debugPrint(data.toString());
    // adding data to list
    setState(() {
      _journal = data;
      _isLoading = false;
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    _refreshJournal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqflite'),
      ),
      body: ListView.builder(
          itemCount: _journal.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.orange,
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(_journal[index]['title']),
                subtitle: Text(_journal[index]['description']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            _showForm(_journal[index]['id']);
                          },
                          icon: const Icon(Icons.edit)),
                      IconButton(
                          onPressed: () {
                            _deleteItem(context ,_journal[index]['id']);
                          },
                          icon: const Icon(Icons.delete))
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journal.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) {
          return Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'description'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }
                        _titleController.text = '';
                        _descriptionController.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'))
                ],
              ));
        });
  }
}
