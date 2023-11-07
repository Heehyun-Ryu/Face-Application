import 'package:flutter/material.dart';
import 'package:face_appliction/register.dart';

class register_list extends StatefulWidget {
  final List<Child_info>? child_infoList;

  const register_list({this.child_infoList});

  @override
  State<register_list> createState() => _register_listState();
}

class _register_listState extends State<register_list> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Children List'),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 0,
          childAspectRatio: 2.2,
          children: (widget.child_infoList ?? [])
              .map((info) => Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 3.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Text(
                                'Name: ${info.name ?? '?'}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Age: ${info.age}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Class: ${info.enroll_class ?? '???'}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ))
              .toList(),
        ));
  }
}
