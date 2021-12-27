import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: prefer_typing_uninitialized_variables
  var _controller;
  List<String> list = [];
  List<String> uplist = [];
  List<bool> _isDone = [];

  void saveData() async {
    SharedPreferences task = await SharedPreferences.getInstance();
    task.setString('task', _controller.text);
    _controller.text = '';
    Navigator.of(context).pop();
    list.add(task.getString('task').toString());
    task.setStringList('task', list);
    _getTask();
  }

  void _getTask() async {
    SharedPreferences task = await SharedPreferences.getInstance();
    list = task.getStringList('task')!;
    _isDone = List.generate(list.length, (index) => false);
    setState(() {});
  }

  void updatePending() async {
    SharedPreferences task = await SharedPreferences.getInstance();
    uplist = task.getStringList('task')!;
    for (var i = 0; i < _isDone.length; i++) {
      if (_isDone[i]) {
        uplist.remove(list[i]);
        task.setStringList('task', uplist);
      }
    }

    _getTask();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _getTask();
  }

  @override
  void dispose() {
    _controller.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Manager',
          style: GoogleFonts.robotoMono(),
        ),
        actions: [
          IconButton(
              onPressed: () => updatePending(), icon: const Icon(Icons.save)),
          IconButton(
              onPressed: () async {
                SharedPreferences task = await SharedPreferences.getInstance();
                task.setStringList('task', []);
                _getTask();
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: (list.isEmpty)
            ? Center(
                child: Text(
                  'No Tasks yet',
                  style: GoogleFonts.robotoMono(),
                ),
              )
            : Column(
                children: list
                    .map((e) => Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          padding: const EdgeInsets.only(left: 10.0),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(width: 0.5),
                              color: Colors.grey.shade700),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e,
                                style:
                                    GoogleFonts.robotoMono(color: Colors.white),
                              ),
                              Checkbox(
                                value: _isDone[list.indexOf(e)],
                                fillColor:
                                    MaterialStateProperty.all(Colors.white),
                                checkColor: Colors.blue,
                                onChanged: (value) {
                                  setState(() {
                                    _isDone[list.indexOf(e)] = value!;
                                  });
                                },
                              )
                            ],
                          ),
                        ))
                    .toList(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => Container(
                  height: 200,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Task',
                            style: GoogleFonts.robotoMono(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          GestureDetector(
                            child: const Icon(
                              Icons.remove_circle,
                              color: Colors.white,
                            ),
                            onTap: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              )),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter Task',
                          hintStyle: GoogleFonts.robotoMono(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 5.0),
                            width: (MediaQuery.of(context).size.width - 34) / 2,
                            child: ElevatedButton(
                                child: Text(
                                  'Reset',
                                  style: GoogleFonts.robotoMono(),
                                ),
                                onPressed: () => _controller.text = '',
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red)),
                          ),
                          Container(
                              padding: const EdgeInsets.only(left: 5.0),
                              width:
                                  (MediaQuery.of(context).size.width - 34) / 2,
                              child: ElevatedButton(
                                child: Text(
                                  'Add',
                                  style: GoogleFonts.robotoMono(),
                                ),
                                onPressed: () => saveData(),
                              )),
                        ],
                      )
                    ],
                  ),
                )),
      ),
    );
  }
}
