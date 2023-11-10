import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:face_appliction/reivew.dart';
//import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  // String baseUri = 'http://192.168.0.2:8080';
  //String baseUri = 'http://10.0.0.2:8080';
  //String baseUri = 'https://172.30.1.68:8080';
  String baseUri = 'https://172.30.1.100:8080';

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

  Future<XFile?> takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off); //
      XFile picture = await _cameraController.takePicture();
      return picture;
      // var formData;
      // if (picture != null) {
      //   dynamic sendData = picture.path;
      //   formData = //이미지의 경로로 변환
      //       FormData.fromMap({
      //     'image': await MultipartFile.fromFile(sendData)
      //   }); //formData 형식으로 변환
      // }

      // return formData;

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PreviewPage(picture: picture)));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
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

  Future<void> UplaodImage(XFile? picture) async {
    var dio = new Dio();
    print("프로필 사진을 서버에 업로드 합니다.");
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;

      var formData = FormData.fromMap(
          {'image': await MultipartFile.fromFile(picture!.path)});

      //dio.options.headers = {'token': token};     //api token 구현하지 않음.
      var response = await dio.post(
        //baseUri + '/upload',
        'http://172.30.1.100:8080/upload',
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
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(children: [
        (_cameraController.value.isInitialized)
            ? CameraPreview(_cameraController)
            : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              color: Colors.black,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 30,
                    icon: Icon(
                        _isRearCameraSelected
                            ? CupertinoIcons.switch_camera
                            : CupertinoIcons.switch_camera_solid,
                        color: Colors.white),
                    onPressed: () {
                      setState(
                          () => _isRearCameraSelected = !_isRearCameraSelected);
                      initCamera(
                          widget.cameras![_isRearCameraSelected ? 0 : 1]);
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      XFile? picture = await takePicture();
                      if (picture != null) {
                        await UplaodImage(picture);
                      }
                    },
                    iconSize: 50,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.circle, color: Colors.white),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        )
      ])),
    );
  }
}