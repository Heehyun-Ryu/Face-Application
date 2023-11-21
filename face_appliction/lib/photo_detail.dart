import 'package:flutter/material.dart';
import 'package:face_appliction/ImageHub.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

class Photo_detail extends StatefulWidget {
  final data;
  final int? idx;
  Photo_detail({this.data, this.idx});

  @override
  State<Photo_detail> createState() =>
      _Photo_detailState(entry: data, idx: idx);
}

class _Photo_detailState extends State<Photo_detail> {
  final entry;
  int? idx;
  _Photo_detailState({this.entry, this.idx});

  List<dynamic> photoList = [];

  @override
  void initState() {
    super.initState();
    // photoList = entry.value.map((img) => img.path).toList();
    print(entry.map((img) => img.path).toList().runtimeType);
    print(entry.map((img) => img.path).toString());
    print(entry[0].name);

    photoList = entry.map((img) => img.path).toList();
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: idx ?? 0);
    return SafeArea(
      child: Container(
        child: ExpandablePageView.builder(
          itemCount: photoList.length,
          controller: controller,
          itemBuilder: (context, index) {
            final item = photoList[index];
            return Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: item,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    // child: Text(item),
                    child: Center(
                      child: Image.network(
                        // item,
                        '${item}?t=${DateTime.now().millisecond}',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //     image: NetworkImage(item),
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                  ),
                ),
                Positioned(
                  top: 35,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

//CarouselSlider를 활용해서 슬라이드로 사진 이동하기. -> 가로 세로 조절 문제 발생
// class _Photo_detailState extends State<Photo_detail> {
//   final entry;
//   int? idx;
//   _Photo_detailState({this.entry, this.idx});

//   List<dynamic> photoList = [];

//   @override
//   void initState() {
//     super.initState();
//     // photoList = entry.value.map((img) => img.path).toList();
//     print(entry.map((img) => img.path).toList().runtimeType);
//     print(entry.map((img) => img.path).toString());
//     print(entry[0].name);

//     photoList = entry.map((img) => img.path).toList();
//   }

//   //List<Image> recived
//   // final photoList = entry.map((img) => img.path).toList();

  // @override
  // Widget build(BuildContext context) {
  //   return CarouselSlider(
  //     options: CarouselOptions(
  //       // height: MediaQuery.of(context).size.height,
  //       aspectRatio: 1 / MediaQuery.of(context).devicePixelRatio,
  //       // enlargeCenterPage: true,
  //       viewportFraction: 1.0,
  //       enableInfiniteScroll: false,
  //       initialPage: idx ?? 0,
  //     ),
  //     items: photoList.map((img) {
  //       return Builder(builder: (context) {
  //         return Hero(
  //           tag: img,
  //           child: Expanded(
  //             child: Container(
  //               // height: MediaQuery.of(context).size.height,
  //               // width: MediaQuery.of(context).size.width,
  //               decoration: BoxDecoration(
  //                 image: DecorationImage(
  //                   image: NetworkImage(img),
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               // child: Image.network(img),
  //             ),
  //           ),
  //         );
  //       });
  //     }).toList(),
  //   );
  // }

//그냥 사진 한장 크게 보여주기.
// class _Photo_detailState extends State<Photo_detail> {
//   final entry;
  // _Photo_detailState({this.entry});

  // @override
  // Widget build(BuildContext context) {
  //   return Stack(
  //     children: [
  //       Hero(
  //         tag: entry,
  //         child: Container(
  //           decoration: BoxDecoration(
  //               image: DecorationImage(image: NetworkImage(entry))),
  //         ),
  //       ),
  //       Positioned(
  //         top: 35,
  //         left: 20,
  //         child: GestureDetector(
  //           onTap: () => Navigator.pop(context),
  //           child: Icon(
  //             Icons.arrow_back,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
