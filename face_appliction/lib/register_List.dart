import 'package:face_appliction/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:face_appliction/ImageHub.dart';

class register_list extends StatefulWidget {
  @override
  State<register_list> createState() => _register_listState();
}

class _register_listState extends State<register_list> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<void> delete_register(String key) async {
    var dio = new Dio();

    try {
      await dio.get(
        baseUri + '/delete_register',
        queryParameters: {'loca': prefs?.getString(key)},
      );
    } catch (e) {
      print('Error during image upload: $e');
      if (e is DioException) {
        print('DioError respose: ${e.response}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (prefs == null) {
      return CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Children List'),
      ),
      body: ListView.separated(
        itemCount: prefs?.getKeys().length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          String key = prefs?.getKeys().elementAt(index) ?? '';
          String value = prefs?.getString(key) ?? '';

          return Container(
            padding: EdgeInsets.fromLTRB(6.0, 5.0, 20.0, 5.0),
            height: MediaQuery.of(context).size.height * 0.1,
            color: Colors.blueGrey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이름: ${key.split('_')[0]} 나이: ${key.split('_')[1]}  ${key.split('_')[2]}반',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // color: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        delete_register(key);
                        prefs?.remove(key);
                        numbre_of_register();
                      });
                    },
                    icon: Icon(
                      Icons.delete_forever,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
