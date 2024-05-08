import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';

//diambil dari: https://blog.logrocket.com/how-create-flutter-charts-with-charts-flutter/

class PopulasiTahun {
  String tahun; //perlu string
  int populasi;
  charts.Color barColor;
  PopulasiTahun(
      {required this.tahun, required this.populasi, required this.barColor});
}

class Populasi {
  List<PopulasiTahun> ListPop = <PopulasiTahun>[];

  Populasi(Map<String, dynamic> json) {
    // isi listPop disini
    var data = json["data"];
    for (var val in data) {
      var tahun = val["Year"];
      var populasi = val["Population"];
      var warna =
          charts.ColorUtil.fromDartColor(Colors.green); //satu warna dulu
      ListPop.add(
          PopulasiTahun(tahun: tahun, populasi: populasi, barColor: warna));
    }
  }

  //map dari json ke atribut
  factory Populasi.fromJson(Map<String, dynamic> json) {
    return Populasi(json);
  }
}

class PopulasiChart extends StatelessWidget {
  List<PopulasiTahun> listPop;

  PopulasiChart({required this.listPop});
  @override
  Widget build(BuildContext context) {
    List<charts.Series<PopulasiTahun, String>> series = [
      charts.Series(
          id: "populasi",
          data: listPop,
          domainFn: (PopulasiTahun series, _) => series.tahun,
          measureFn: (PopulasiTahun series, _) => series.populasi,
          colorFn: (PopulasiTahun series, _) => series.barColor)
    ];
    return charts.BarChart(series, animate: true);
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Chart-Http", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

//class state
class HomePageState extends State<HomePage> {
  late Future<Populasi> futurePopulasi;

  //https://datausa.io/api/data?drilldowns=Nation&measures=Population
  String url =
      "https://datausa.io/api/data?drilldowns=Nation&measures=Population";

  //fetch data
  Future<Populasi> fetchData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      return Populasi.fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futurePopulasi = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chart - http'),
      ),
      body: FutureBuilder<Populasi>(
        future: futurePopulasi,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
                child: PopulasiChart(listPop: snapshot.data!.ListPop));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}