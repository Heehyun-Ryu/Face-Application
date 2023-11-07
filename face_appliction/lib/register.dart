import 'package:flutter/material.dart';
import 'package:face_appliction/register_List.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class Child_info {
  String? name;
  int age = 0;
  String? enroll_class;

  Child_info({this.name, this.age = 0, this.enroll_class});
}

class register_page extends StatefulWidget {
  @override
  State<register_page> createState() => _register_pageState();
}

class _register_pageState extends State<register_page> {
  final enroll_classList = ['A', 'B', 'C', 'D', 'E', 'F'];

  //var _selectedState = 'A';
  String? _selectedState;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final _nameformkey = GlobalKey<FormState>();
  final _ageformkey = GlobalKey<FormState>();
  String _nameTextFormFieldValue = '';
  String _ageTextFormFieldValue = '';

  //final Child Child_info = Child();
  final List<Child_info> Child_infoList = [];

  void _saveData() {
    setState(() {
      // Child.name = nameController.text;
      // Child.age = int.tryParse(ageController.text) ?? 0;
      // Child.enroll_class = _selectedState;
      if (!Child_infoList.any(
          (element) => element.name == nameController.text)) {
        // if (ageController.text == '') {
        //   return;
        // }
        Child_infoList.add(Child_info(
            name: nameController.text,
            age: int.parse(ageController.text),
            enroll_class: _selectedState));
      } else {
        print("duplication");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Form(
                  key: _nameformkey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        print("Name: $value");
                        return 'Enter name';
                      }
                    },
                    onSaved: (value) {
                      setState(() {
                        _nameTextFormFieldValue = value!;
                      });
                    },
                    //obscureText: true,
                    controller: nameController,
                    decoration: InputDecoration(
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      hintText: "Input child name",
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Form(
                  key: _ageformkey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter age';
                      }
                    },
                    onSaved: (value) {
                      setState(() {
                        _ageTextFormFieldValue = value!;
                      });
                    },
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                        hintText: "Input child age",
                        labelText: 'Age',
                        border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width - 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Class',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton(
                      //padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      hint: Text('What class are him/her in?'),
                      alignment: Alignment.center,
                      value: _selectedState,
                      items: enroll_classList.map(
                        (value) {
                          return DropdownMenuItem(
                            alignment: Alignment.center,
                            child: Text(value),
                            value: value,
                          );
                        },
                      ).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedState = value ?? "Not String";
                        });
                      }),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(100, 50)),
                  onPressed: () {
                    final formKeyState = _nameformkey.currentState;
                    if (formKeyState!.validate()) {
                      formKeyState?.save();
                    }
                    final formkeyState2 = _ageformkey.currentState;
                    if (formkeyState2!.validate()) {
                      formkeyState2?.save();
                    }

                    if (nameController.text == '') {
                      print("name: null");
                      return;
                    } else if (ageController.text == '') {
                      print("age: null");
                      return;
                    } else if (_selectedState == null) {
                      print("class null");
                      return;
                    }

                    _saveData();

                    for (var c in Child_infoList) {
                      print(
                          "Name: ${c.name}, Age: ${c.age}, Class: ${c.enroll_class}");
                    }
                    nameController.clear();
                    ageController.clear();
                    _selectedState = null;
                  },
                  child: Text(
                    'Register',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(100, 50)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                register_list(child_infoList: Child_infoList)),
                      );
                    },
                    child: Text(
                      'List',
                      style: TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
