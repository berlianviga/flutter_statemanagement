import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//screen kedua
class ScreenDetil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detil'),
        ),
        body: BlocBuilder<DetilUmkmCubit, DetilUmkmModel>(
            builder: (context, detilUmkm) {
          return Column(children: [
            Text("Nama: ${detilUmkm.nama}"),
            Text("Detil: ${detilUmkm.jenis}"),
            Text("Member Sejak: ${detilUmkm.memberSejak}"),
            Text("Omzet per bulan: ${detilUmkm.omzet}"),
            Text("Lama usaha: ${detilUmkm.lamaUsaha}"),
            Text("Jumlah pinjaman sukses: ${detilUmkm.jumPinjamanSukses}"),
          ]);
        }));
  }
}

class DetilUmkmModel {
  String id;
  String jenis;
  String nama;
  String omzet;
  String lamaUsaha;
  String memberSejak;
  String jumPinjamanSukses;

  //lama_usaha":"1","member_sejak":"01-01-2019","jumlah_pinjaman_sukses":3}

  DetilUmkmModel(
      {required this.id,
      required this.nama,
      required this.jenis,
      required this.omzet,
      required this.jumPinjamanSukses,
      required this.lamaUsaha,
      required this.memberSejak}); //constructor
}

class Umkm {
  String id;
  String jenis;
  String nama;
  Umkm({required this.id, required this.nama, required this.jenis});
}

class UmkmModel {
  List<Umkm> dataUmkm;
  UmkmModel({required this.dataUmkm}); //constructor
}

class DetilUmkmCubit extends Cubit<DetilUmkmModel> {
  //String urlDetil = "http://127.0.0.1:8000/detil_umkm/";
  String urlDetil = "http://178.128.17.76:8000/detil_umkm/";
  DetilUmkmCubit()
      : super(DetilUmkmModel(
            id: '',
            jenis: '',
            nama: '',
            omzet: '',
            jumPinjamanSukses: '',
            lamaUsaha: '',
            memberSejak: ''));

  void setFromJson(Map<String, dynamic> json) {
    emit(DetilUmkmModel(
        id: json["id"],
        nama: json["nama"],
        jenis: json["jenis"],
        omzet: json["omzet_bulan"],
        jumPinjamanSukses: json["jumlah_pinjaman_sukses"],
        lamaUsaha: json["lama_usaha"],
        memberSejak: json["member_sejak"]));
  }

  void fetchDataDetil(String id) async {
    String urldet = "$urlDetil$id";
    final response = await http.get(Uri.parse(urldet));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class UmkmCubit extends Cubit<UmkmModel> {
  //String url = "http://127.0.0.1:8000/daftar_umkm";
  String url = "http://178.128.17.76:8000/daftar_umkm";

  UmkmCubit() : super(UmkmModel(dataUmkm: []));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    var arrData = json["data"];
    List<Umkm> arrOut = [];
    for (var el in arrData) {
      String id = el['id'];
      String jenis = el['jenis'];
      String nama = el['nama'];
      arrOut.add(Umkm(id: id, nama: nama, jenis: jenis));
    }
    emit(UmkmModel(dataUmkm: arrOut));
  }

  void setFromJsonDetil(Map<String, dynamic> json) {}

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider<UmkmCubit>(
          create: (BuildContext context) => UmkmCubit(),
        ),
        BlocProvider<DetilUmkmCubit>(
          create: (BuildContext context) => DetilUmkmCubit(),
        ),
      ],
      child: const HalamanUtama(),
    ));
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text(' My App'),
      ),
      body: Center(
        child: BlocBuilder<UmkmCubit, UmkmModel>(
          builder: (context, listUmkm) {
            return Center(
                child: Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  Container(
                      padding: const EdgeInsets.all(10), child: const Text("""
nim1,nama1; nim2,nama2; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang""")),

                  Container(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<UmkmCubit>().fetchData();
                      },
                      child: const Text("Reload Daftar UMKM"),
                    ),
                  ),
                  //Text(listUmkm.dataUmkm[0].nama),
                  Expanded(child: BlocBuilder<DetilUmkmCubit, DetilUmkmModel>(
                      builder: (context, detilUmkm) {
                    return ListView.builder(
                        itemCount: listUmkm.dataUmkm.length, //jumlah baris
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () {
                                context.read<DetilUmkmCubit>().fetchDataDetil(
                                    listUmkm.dataUmkm[index].id);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return ScreenDetil();
                                }));
                              },
                              leading: Image.network(
                                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                              trailing: const Icon(Icons.more_vert),
                              title: Text(listUmkm.dataUmkm[index].nama),
                              subtitle: Text(listUmkm.dataUmkm[index].jenis),
                              tileColor: Colors.white70);
                        });
                  }))
                ]));
          },
        ),
      ),
    ));
  }
}