import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:face_appliction/photo_detail.dart';
import 'package:face_appliction/register.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:face_appliction/take_picture.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:face_appliction/ImageHub.dart';
import 'package:face_appliction/Classified_photo.dart';

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
  // var url = Uri.parse('http://192.168.0.9:8080/classify');
  var url = Uri.parse('$baseUri/classify');

  // var url = Uri.parse('http://192.168.0.79:8080/classify');

  ImageHub? imageHub;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    var res = await http.get(url);
    var decordedJSON = jsonDecode(res.body);

    setState(() {
      imageHub = ImageHub.fromJson(decordedJSON);
    });
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
    //세로로 고정하는 부분
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    print("object");
    print(imageHub?.data['cat']?[0].name);
    print(imageHub?.data['cat']?[0].path);
    print(imageHub?.data.keys.toList());

    return Scaffold(
      appBar: AppBar(
        title: Text("Face Applicaion"),
        backgroundColor: Colors.blue,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        // childAspectRatio: .9,
        children: (imageHub?.data.entries ?? [])
            .map((entry) => Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          // MaterialPageRoute(
                          SlideRoute(
                            builder: (context) => Classified_photo(
                              data: entry,
                            ),
                            settings: RouteSettings(name: '/classified_photo'),
                          ));
                    },
                    child: Card(
                        elevation: 3.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(entry.value
                                        .firstWhere(
                                            (element) =>
                                                element.name == entry.key,
                                            orElse: () => entry.value[0])
                                        .path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3.0),
                              ),
                            ),
                          ],
                        )),
                  ),
                ))
            .toList(),
      ),
      // children: (imageHub?.data.entries ?? [])
      //     .map((entry) => entry.value
      //         // .where((img) => entry.key == img.name)
      //         .map((img) => Padding(
      //               padding: const EdgeInsets.all(2.0),
      //               child: Card(
      //                   elevation: 3.0,
      //                   child: Column(
      //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                     children: <Widget>[
      //                       Container(
      //                         height: 160.0,
      //                         width: 160.0,
      //                         decoration: BoxDecoration(
      //                           image: DecorationImage(
      //                             image: NetworkImage(img.path),
      //                             fit: BoxFit.cover,
      //                           ),
      //                         ),
      //                       ),
      //                       Text(
      //                         img.name,
      //                         style: TextStyle(
      //                           fontSize: 23,
      //                           fontWeight: FontWeight.bold,
      //                           letterSpacing: 5.0,
      //                         ),
      //                       ),
      //                     ],
      //                   )),
      //             ))
      //         .toList())
      //     .expand((element) => element)
      //     .toList()),
      drawer: Drawer(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'refresh',
        onPressed: () {
          fetchData();
        },
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
                await availableCameras().then(
                  (value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraPage(cameras: value),
                    ),
                  ),
                );
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

class SlideRoute<T> extends MaterialPageRoute<T> {
  SlideRoute({required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == '/') {
      return child;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
