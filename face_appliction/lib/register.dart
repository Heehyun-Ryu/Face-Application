import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:face_appliction/register_List.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:face_appliction/ImageHub.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Child_info {
  String? name;
  int age = 0;
  String? enroll_class;

  Child_info({this.name, this.age = 0, this.enroll_class});
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<void> numbre_of_register() async {
  var dio = new Dio();

  final SharedPreferences prefs = await _prefs;

  try {
    await dio.get(
      baseUri + '/numbre_of_register',
      queryParameters: {'Num': prefs.getKeys().length.toString()},
    );
    print("등록을 성공했습니다.");
  } catch (e) {
    print('Error during image upload: $e');
    if (e is DioException) {
      print('DioError respose: ${e.response}');
    }
  }
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

  final List<Child_info> Child_infoList = [];

  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // "upload\\Kim_5_A.jpg",
  Future<bool> saveData(String info) async {
    final SharedPreferences prefs = await _prefs;
    print(info);
    print('upload\\thumbnail_${info.split('_').first}.jpg');

    if (!prefs.containsKey(info)) {
      for (var c in prefs.getKeys()) {
        if (c.split('_')[0] == info.split('_')[0]) {
          return true;
        }
      }
      //laptop
      prefs.setString(info, 'upload\\thumbnail_${info.split('_').first}.jpg');

      //jetson
      // prefs.setString(info, 'upload/thumbnail_${info.split('_').first}.jpg');

      return false;
    } else {
      print("get a way");
      return true;
    }

    print(prefs.getKeys());
  }

  bool check = false;
  Future<void> saveDataFunc() async {
    check = await saveData(
        '${nameController.text}_${ageController.text}_${_selectedState}');
  }

  void removeall() async {
    final SharedPreferences remv = await _prefs;

    Set<String> keys = remv.getKeys();

    // keys.forEach((element) => remv.remove(element));
    remv.clear();

    print("RemoveAll");
    print(remv.getKeys());
  }

  // Duplication check!
  void _saveData() async {
    setState(() {
      // List<String> keys = _prefs.getKeys().where((k) => k.startsWith('item_'));
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
        print("Duplication");
      }
    });
  }

  Future<void> RegisterImage(File? img, String chif) async {
    var dio = new Dio();

    print("사진을 등록합니다.");
    print(chif);
    print(chif.split('_'));
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;

      var formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(img!.path),
        'Name': chif.split('_')[0],
        'Age': chif.split('_')[1],
        '_Class': chif.split('_')[2],
      });
      await dio.post(
        baseUri + '/register',
        data: formData,
      );
      print("등록을 성공했습니다.");
    } catch (e) {
      print('Error during image upload: $e');
      if (e is DioException) {
        print('DioError respose: ${e.response}');
      }
    }
  }

  XFile? _image;
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 230,
                    width: 200,
                    child: GestureDetector(
                        onTap: () {
                          getImage(ImageSource.gallery);
                        },
                        child: _image == null
                            ? Center(
                                child: Icon(
                                  Icons.add_box_rounded,
                                  color: Colors.grey,
                                  size: 200,
                                ),
                              )
                            : Center(
                                child: Image.file(File(_image!.path)),
                              )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
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
                  Container(
                    width: MediaQuery.of(context).size.width - 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Class',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: numbre_of_register, child: Text('temp')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(100, 50)),
                        onPressed: () async {
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

                          Child_info temp = Child_info(
                              name: nameController.text,
                              age: int.parse(ageController.text),
                              enroll_class: _selectedState);

                          // saveData('${nameController.text}_${ageController.text}_${_selectedState}');

                          await saveDataFunc();

                          if (check) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'duplication!',
                                textAlign: TextAlign.center,
                              ),
                              duration: Duration(seconds: 6),
                            ));
                            return;
                          }

                          // _saveData();
                          RegisterImage(File(_image!.path),
                              '${nameController.text}_${ageController.text}_${_selectedState}');
                          numbre_of_register();

                          for (var c in Child_infoList) {
                            print(
                                "Name: ${c.name}, Age: ${c.age}, Class: ${c.enroll_class}");
                          }
                          _image = null;
                          nameController.clear();
                          ageController.clear();
                          _selectedState = null;
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(100, 50)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => register_list()),
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
            ],
          ),
        ),
      ),
    );
  }
}
