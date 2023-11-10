//import 'dart:html';
import 'package:flutter/material.dart';
//import 'package:face_appliction/photo_detail.dart';
import 'package:face_appliction/register.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:face_appliction/take_picture.dart';

void main() => runApp(MaterialApp(
      title: "Face Applicaion",
      home: Homepage(),
      debugShowCheckedModeBanner: false,
    ));

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
  }

  XFile? _image;
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  // multi images
  // final ImagePicker picker = ImagePicker();
  // List<XFile> _image = [];
  // Future<void> getImage() async {
  //   List<XFile>? image = await picker.pickMultiImage();
  //   if (image != null) {
  //     setState(() {
  //       _image = image;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Applicaion"),
        backgroundColor: Colors.blue,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        //child: 얼굴 썸네일 부분
      ),
      drawer: Drawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.cyan,
        child: Icon(Icons.refresh),
      ),
      //camera button, register button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(10, 50)),
              onPressed: () async {
                await availableCameras().then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CameraPage(cameras: value))));
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => CameraPage(cameras: ,)),
                // );
                // getImage(ImageSource.camera);    //image_picker
              },
              child: Text(
                'Camera',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(10, 50)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => register_page()),
                  );
                },
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                )),
          ),
        ]),
      ),
    );
  }
}
