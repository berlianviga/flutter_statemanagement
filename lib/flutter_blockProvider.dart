import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class ActivityModel {
  String aktivitas;
  String jenis;
  ActivityModel({required this.aktivitas, required this.jenis}); //constructor
}

class ActivityCubit extends Cubit<ActivityModel> {
  String url = "https://www.boredapi.com/api/activity";
  ActivityCubit() : super(ActivityModel(aktivitas: "", jenis: ""));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    String aktivitas = json['activity'];
    String jenis = json['type'];
    emit(ActivityModel(aktivitas: aktivitas, jenis: jenis));
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ActivityCubit(),
        child: const HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlocBuilder<ActivityCubit, ActivityModel>(
            buildWhen: (previousState, state) {
              developer.log("${previousState.aktivitas} -> ${state.aktivitas}",
                  name: 'logyudi');
              return true;
            },
            builder: (context, aktivitas) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ActivityCubit>().fetchData();
                        },
                        child: const Text("Saya bosan ..."),
                      ),
                    ),
                    Text(aktivitas.aktivitas),
                    Text("Jenis: ${aktivitas.jenis}")
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}