//dependencies:
//  shared_preferences: ^2.1.1

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> userId;

  //ambil dari sharedpref
  //return userId
  Future<String> ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('userId') ?? "");
  }

  //simpan ke sharepref
  Future<void> simpanDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', "budiWati");
  }

  //hapus data sharedpref
  Future<void> hapusDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  @override
  void initState() {
    super.initState();
    userId = ambilDataUser(); //isi userid
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: FutureBuilder<String>(
                future: userId,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //user id belum ada di sharedpref
                    if (snapshot.data == "") {
                      return (Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("user belum login"),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  //set userid (simulasi)
                                  //simpan ke sharedpref
                                  //sekaligus refresh
                                  simpanDataUser();
                                  userId = ambilDataUser();
                                }); //refresh
                              },
                              child: const Text('Login'),
                            ),
                          ]));
                    } else {
                      //sudah ada datauser di sharedpref
                      return (Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("userid: ${snapshot.data!}"),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  //hapus sharedpref
                                  //sekaligus refresh
                                  hapusDataUser();
                                  userId = ambilDataUser();
                                }); //refresh
                              },
                              child: const Text('Logout'),
                            ),
                          ]));
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                })),
      ),
    );
  }
}