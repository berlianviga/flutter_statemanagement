import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

//screen kedua
class ScreenDetil extends StatelessWidget {
  const ScreenDetil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(' Detil '),
        ),
        body: BlocBuilder<DetilJenisPinjamanCubit, DetilJenisPinjamanModel>(
            builder: (context, detilPinjaman) {
          return Column(children: [
            Text("id: ${detilPinjaman.id}"),
            Text("nama: ${detilPinjaman.nama}"),
            Text("bunga: ${detilPinjaman.bunga}"),
            Text("Syariah: ${detilPinjaman.isSyariah}"),
          ]);
        }));
  }
}

class DetilJenisPinjamanModel {
  String id;
  String nama;
  String bunga;
  String isSyariah;

  DetilJenisPinjamanModel({
    required this.id,
    required this.nama,
    required this.bunga,
    required this.isSyariah,
  }); //constructor
}

class DetilJenisPinjamanCubit extends Cubit<DetilJenisPinjamanModel> {
  //String url = "http://127.0.0.1:8000/detil_jenis_pinjaman/";
  String url = "http://178.128.17.76:8000/detil_jenis_pinjaman/";

  DetilJenisPinjamanCubit()
      : super(DetilJenisPinjamanModel(
            bunga: '', isSyariah: '', id: '', nama: ''));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    emit(DetilJenisPinjamanModel(
      id: json["id"],
      nama: json["nama"],
      bunga: json["bunga"],
      isSyariah: json["is_syariah"],
    ));
  }

  void fetchData(String id) async {
    String urlJenis = "$url$id";
    final response = await http.get(Uri.parse(urlJenis));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

// --------

class JenisPinjaman {
  String id;
  String nama;
  JenisPinjaman({required this.id, required this.nama});
}

class JenisPinjamanModel {
  String strPilihanJenis = "0"; //untuk drop down
  List<JenisPinjaman> dataPinjaman;
  JenisPinjamanModel(
      {required this.dataPinjaman,
      required this.strPilihanJenis}); //constructor
}

class JenisPinjamanCubit extends Cubit<JenisPinjamanModel> {
  //String url = "http://127.0.0.1:8000/jenis_pinjaman/";
  String url = "http://178.128.17.76:8000/jenis_pinjaman/";

  JenisPinjamanCubit()
      : super(JenisPinjamanModel(dataPinjaman: [], strPilihanJenis: "0"));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json, String jenis) {
    var arrData = json["data"];
    List<JenisPinjaman> arrOut = [];
    for (var el in arrData) {
      String id = el["id"];
      String nama = el['nama'];
      arrOut.add(JenisPinjaman(id: el["id"], nama: el["nama"]));
    }
    emit(JenisPinjamanModel(dataPinjaman: arrOut, strPilihanJenis: jenis));
  }

  void fetchData(String jenis) async {
    String urlJenis = "$url$jenis";
    final response = await http.get(Uri.parse(urlJenis));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body), jenis);
    } else {
      throw Exception('Gagal load');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider<JenisPinjamanCubit>(
          create: (BuildContext context) => JenisPinjamanCubit(),
        ),
        BlocProvider<DetilJenisPinjamanCubit>(
          create: (BuildContext context) => DetilJenisPinjamanCubit(),
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
        title: const Text(' My App P2P '),
      ),
      body: Center(
        child: BlocBuilder<JenisPinjamanCubit, JenisPinjamanModel>(
          builder: (context, jenisPinjaman) {
            //init combo
            List<DropdownMenuItem<String>> jenis = [];
            var itm0 = const DropdownMenuItem<String>(
              value: "0",
              child: Text("Pilih jenis pinjaman"),
            );
            var itm1 = const DropdownMenuItem<String>(
              value: "1",
              child: Text("Jenis pinjaman 1"),
            );
            var itm2 = const DropdownMenuItem<String>(
              value: "2",
              child: Text("Jenis pinjaman 2"),
            );
            var itm3 = const DropdownMenuItem<String>(
              value: "3",
              child: Text("Jenis pinjaman 3"),
            );

            jenis.add(itm0);
            jenis.add(itm1);
            jenis.add(itm2);
            jenis.add(itm3);

            //String pilihanJenis = "0";

            return Center(
                child: Column(children: [
              Container(padding: const EdgeInsets.all(10), child: const Text("""
nim1,nama1; nim2,nama2; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang""")),
              Container(
                padding: const EdgeInsets.all(20),
                child: DropdownButton(
                  value: jenisPinjaman.strPilihanJenis,
                  items: jenis,
                  onChanged: (String? newValue) {
                    if ((newValue != null) && (newValue != "0")) {
                      context.read<JenisPinjamanCubit>().fetchData(newValue);
                    }
                  },
                ),
              ),
              BlocBuilder<DetilJenisPinjamanCubit, DetilJenisPinjamanModel>(
                  builder: (context, detilPinjaman) {
                return Expanded(
                    child: ListView.builder(
                        itemCount:
                            jenisPinjaman.dataPinjaman.length, //jumlah baris
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () {
                                context
                                    .read<DetilJenisPinjamanCubit>()
                                    .fetchData(
                                        jenisPinjaman.dataPinjaman[index].id);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return ScreenDetil();
                                }));
                              },
                              leading: Image.network(
                                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                              trailing: const Icon(Icons.more_vert),
                              title:
                                  Text(jenisPinjaman.dataPinjaman[index].nama),
                              subtitle: Text(
                                  " id: ${jenisPinjaman.dataPinjaman[index].id}  "),
                              tileColor: Colors.white70);
                        }));
              })
            ]));
          },
        ),
      ),
    ));
  }
}