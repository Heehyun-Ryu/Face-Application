import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:face_appliction/ImageHub.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  late CustomOrientation cameraOrientation = CustomOrientation.portrait;

  late StreamSubscription<AccelerometerEvent> accelerometerSub;
  //Dorm
  // String baseUri = 'http://192.168.0.9:8080';

  //jetson
  // String baseUri = 'http://192.168.0.10:8080';

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera error $e");
    }
  }

  Future<File?> takePicture(CustomOrientation orientation) async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();

      int angle = 0;
      print(orientation);

      if (orientation != CustomOrientation.portrait) {
        angle = -90;
        if (orientation == CustomOrientation.leftLandScape) {
          angle = 90;
        }
      }

      List<int> rotatedByte = await picture.readAsBytes();
      img.Image? originImage = img.decodeImage(Uint8List.fromList(rotatedByte));
      img.Image? rotatedImage = img.copyRotate(originImage!, angle: angle);
      rotatedByte = img.encodeJpg(rotatedImage);

      File rotatedImageFile =
          await File(picture.path).writeAsBytes(rotatedByte);

      return rotatedImageFile;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  void Acc() {
    accelerometerSub = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        if (event.z < -8.0) {
          cameraOrientation = CustomOrientation.portrait;
        } else if (event.x > 5.0) {
          cameraOrientation = CustomOrientation.rightLandScape;
        } else if (event.x < -5.0) {
          cameraOrientation = CustomOrientation.leftLandScape;
        } else {
          cameraOrientation = CustomOrientation.portrait;
        }
      });
    });
  }

  // Future takePicture() async {
  //   if (!_cameraController.value.isInitialized) {
  //     return null;
  //   }
  //   if (_cameraController.value.isTakingPicture) {
  //     return null;
  //   }
  //   try {
  //     await _cameraController.setFlashMode(FlashMode.off);
  //     XFile picture = await _cameraController.takePicture();
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => PreviewPage(
  //                   picture: picture,
  //                 )));
  //   } on CameraException catch (e) {
  //     debugPrint('Error occured while taking picture: $e');
  //     return null;
  //   }
  // }

  Future<void> UplaodImage(File? picture) async {
    var dio = new Dio();
    print("프로필 사진을 서버에 업로드 합니다.");
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;

      var formData = FormData.fromMap(
          {'image': await MultipartFile.fromFile(picture!.path)});

      //dio.options.headers = {'token': token};     //api token 구현하지 않음.
      var response = await dio.post(
        baseUri + '/upload',
        // 'http://172.30.1.100:8080/upload',
        data: formData,
      );
      print('성공적으로 업로드했습니다');
      //return response.data;
    } catch (e) {
      print('Error during image upload: $e');
      if (e is DioException) {
        print('DioError respose: ${e.response}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
    Acc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: (_cameraController.value.isInitialized)
            ? CameraPreview(_cameraController)
            : Container(
                color: Colors.black,
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: const Icon(
                Icons.circle,
                color: Colors.white,
                size: 60,
              ),
              onPressed: () async {
                File? picture = await takePicture(cameraOrientation);
                if (picture != null) {
                  await UplaodImage(picture);
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 30),
              child: FloatingActionButton(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    _isRearCameraSelected
                        ? CupertinoIcons.switch_camera
                        : CupertinoIcons.switch_camera_solid,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(
                        () => _isRearCameraSelected = !_isRearCameraSelected);
                    initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                  },
                ),
                onPressed: () {},
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30),
              child: FloatingActionButton(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Icons.close_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      // body: SafeArea(
      //   child: Stack(
      //     children: [
      //       (_cameraController.value.isInitialized)
      //           ? CameraPreview(_cameraController)
      //           // ? Container(
      //           //     height: MediaQuery.of(context).size.height * 0.8,
      //           //     width: MediaQuery.of(context).size.width,
      //           //     child: CameraPreview(_cameraController),
      //           //   )
      //           : Container(
      //               color: Colors.black,
      //               child: const Center(
      //                 child: CircularProgressIndicator(),
      //               ),
      //             ),

      //       OrientationBuilder(builder: (context, orientaion) {
      //         var children = [
      //           Expanded(
      //             child: IconButton(
      //               padding: EdgeInsets.zero,
      //               iconSize: 30,
      //               icon: Icon(
      //                   _isRearCameraSelected
      //                       ? CupertinoIcons.switch_camera
      //                       : CupertinoIcons.switch_camera_solid,
      //                   color: Colors.white),
      //               onPressed: () {
      //                 setState(
      //                     () => _isRearCameraSelected = !_isRearCameraSelected);
      //                 initCamera(
      //                     widget.cameras![_isRearCameraSelected ? 0 : 1]);
      //               },
      //             ),
      //           ),
      //           Expanded(
      //             child: IconButton(
      //               onPressed: () async {
      //                 File? picture = await takePicture(cameraOrientation);
      //                 if (picture != null) {
      //                   await UplaodImage(picture);
      //                 }
      //               },
      //               iconSize: 50,
      //               padding: EdgeInsets.zero,
      //               constraints: const BoxConstraints(),
      //               icon: const Icon(Icons.circle, color: Colors.white),
      //             ),
      //           ),
      //           const Spacer(),
      //         ];
      //         return Align(
      //           alignment:
      //               (MediaQuery.of(context).orientation == Orientation.portrait)
      //                   ? Alignment.bottomCenter
      //                   : Alignment.centerRight,
      //           child: Container(
      //             height: (MediaQuery.of(context).orientation ==
      //                     Orientation.portrait)
      //                 ? MediaQuery.of(context).size.height * 0.2
      //                 : MediaQuery.of(context).size.width,
      //             width: (MediaQuery.of(context).orientation ==
      //                     Orientation.portrait)
      //                 ? MediaQuery.of(context).size.width
      //                 : MediaQuery.of(context).size.height * 0.3,
      //             decoration: const BoxDecoration(
      //               // borderRadius: (MediaQuery.of(context).orientation ==
      //               //         Orientation.portrait)
      //               //     ? BorderRadius.vertical(top: Radius.circular(24))
      //               //     : BorderRadius.horizontal(left: Radius.circular(24)),
      //               color: Colors.black,
      //             ),
      //             child: (MediaQuery.of(context).orientation ==
      //                     Orientation.portrait)
      //                 ? Row(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     children: children,
      //                   )
      //                 : Column(
      //                     mainAxisAlignment: MainAxisAlignment.start,
      //                     children: children,
      //                   ),
      //           ),
      //         );
      //       }),
      // Align(
      //   alignment: Alignment.bottomCenter,
      //   child: Container(
      //     height: MediaQuery.of(context).size.height * 0.2,
      //     decoration: const BoxDecoration(
      //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      //       color: Colors.black,
      //     ),
      //     child: Row(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         Expanded(
      //           child: IconButton(
      //             padding: EdgeInsets.zero,
      //             iconSize: 30,
      //             icon: Icon(
      //                 _isRearCameraSelected
      //                     ? CupertinoIcons.switch_camera
      //                     : CupertinoIcons.switch_camera_solid,
      //                 color: Colors.white),
      //             onPressed: () {
      //               setState(() =>
      //                   _isRearCameraSelected = !_isRearCameraSelected);
      //               initCamera(
      //                   widget.cameras![_isRearCameraSelected ? 0 : 1]);
      //             },
      //           ),
      //         ),
      //         Expanded(
      //           child: IconButton(
      //             onPressed: () async {
      //               File? picture = await takePicture();
      //               if (picture != null) {
      //                 await UplaodImage(picture);
      //               }
      //             },
      //             iconSize: 50,
      //             padding: EdgeInsets.zero,
      //             constraints: const BoxConstraints(),
      //             icon: const Icon(Icons.circle, color: Colors.white),
      //           ),
      //         ),
      //         const Spacer(),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    accelerometerSub.cancel();
    super.dispose();
  }
}

enum CustomOrientation { portrait, leftLandScape, rightLandScape }
