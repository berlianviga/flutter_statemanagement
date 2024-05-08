import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => UserCubit(),
        child: const HalamanUtama(),
      ),
    );
  }
}

//model berisi data/state
class UserModel {
  String userId;
  UserModel({required this.userId}); //constructor
}

//cubit untuk userModel
class UserCubit extends Cubit<UserModel> {
  //UserCubit(super.initialState);

  UserCubit() : super(UserModel(userId: "")) {
    //penting: inisialiasi
    ambilDataUser();
  }

  Future<void> ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    emit(UserModel(userId: prefs.getString('userId') ?? ""));
  }

  //simpan ke sharepref
  Future<void> simpanDataUser() async {
    String user = "budiWati";
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user);
    emit(UserModel(userId: user));
  }

  //hapus data sharedpref
  Future<void> hapusDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    emit(UserModel(userId: ""));
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Center(
        child: BlocBuilder<UserCubit, UserModel>(builder: (context, user) {
      if (user.userId == "") {
        return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("user belum login"),
          ElevatedButton(
            onPressed: () {
              context.read<UserCubit>().simpanDataUser();
            },
            child: Text("Login"),
          ),
        ]));
      } else {
        return (Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("user id: ${user.userId}"),
          ElevatedButton(
            onPressed: () {
              context.read<UserCubit>().hapusDataUser();
            },
            child: Text("Logout"),
          ),
        ])));
      }
    }))));
  }
}