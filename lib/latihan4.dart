import 'package:flutter/material.dart'; //import paket material untuk komponen UI Flutter
import 'package:http/http.dart' as http; // import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import paket json untuk parsing data JSON
import 'package:url_launcher/url_launcher.dart'; // import url launcher untuk membuka URL
import 'package:provider/provider.dart'; // Import paket provider untuk manajemen state 

//mendefinisikan kelas untuk merepresentasikan universitas dan situs webnya
class SitusUniv {
  String nama; //nama universitas
  String situs; //URL situs web univ
  //konstruktor
  SitusUniv({required this.nama, required this.situs});
}

//mendefinisikan kelas untuk memparsing data JSON dari daftar universitas dan situs web
class Situs {
  List<SitusUniv> ListPop = []; //daftar objek SitusUniv

  //konstruktor untuk memparsing data JSON  
  Situs.fromJson(List<dynamic> json) {
    for (var val in json) {
      var namaUniv = val["name"]; // ekstrak nama universitas dari JSON
      var situsUniv = val["web_pages"][0]; //Ekstrak URL situs web universitas dari JSON
      ListPop.add(SitusUniv(nama: namaUniv, situs: situsUniv)); //Tambahkan objek SitusUniv ke dalam daftar
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider( //membungkus widget root dengan ChangeNotifierProvider untuk manajemen state
      create: (context) => SitusProvider(), // memberikan instance SitusProvider
      child: MyApp(), //widget root
    ),
  );
}
//kelas untuk mengelola state menggunakan ChangeNotifier
class SitusProvider with ChangeNotifier { 
  String selectedCountry = 'Indonesia'; // negara terpilih secara default
  Future<Situs>? futureSitus; // future untuk menyimpan data yang diambil

//metode untuk mengubah negara terpilih dan mengambil data sesuai
  void changeCountry(String country) {
    selectedCountry = country; //Perbarui negara terpilih
    futureSitus = fetchData(); //ambil data untuk negara terpilih
    notifyListeners(); // Notify listeners  tentang perubahan
  }

  //metode untuk mengambil data dari API
  Future<Situs> fetchData() async {
    String url = "http://universities.hipolabs.com/search?country=$selectedCountry"; //URL API 
    final response = await http.get(Uri.parse(url)); //melakukan permintaan HTTP GET
    if (response.statusCode == 200) {
      return Situs.fromJson(jsonDecode(response.body)); //Memparsing respons JSON dan mengembalikan objek situs
    } else {
      throw Exception('Gagal load'); //pengecualian jika pengambilan data gagal
    }
  }
}

//Kelas MyApp, root widget dari aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas dan Situs Resminya', //judul aplikasi
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 202, 238, 255), //warna latar belakang
        appBar: AppBar(
          title: const Text('Universitas dan Situs Resminya'), //judul app bar
          backgroundColor: Colors.blue, //warna latar belakang app bar
        ),
        body: Column(
          children: [
            CountryDropdown(), // tambahkan widget CountryDropdown untuk memilih negara
            Expanded(
              child: Consumer<SitusProvider>( //gunakan Consumer untuk mendengarkan perubahan di SitusProvider
                builder: (context, situsProvider, child) { //builder function untuk Consumer
                  return FutureBuilder<Situs>( //widget FutureBuilder untuk menangani future data Situs
                    future: situsProvider.futureSitus, //future yang akan diproses
                    builder: (context, snapshot) { //builder function untuk FutureBuilder
                      if (snapshot.connectionState == ConnectionState.waiting) { //saat data masih diambil
                        return Center(child: CircularProgressIndicator()); // tampilkan indikator loading
                      }
                      if (snapshot.hasError) { //jika terjadi kesalahan saat mengambil data
                        return Center(child: Text('${snapshot.error}')); //tampilkan pesan kesalahan
                      }
                      if (snapshot.hasData) { //jika data telah tersedia
                        return ListView.builder( //widget listview untuk menampilkan daftar universitas
                          itemCount: snapshot.data!.ListPop.length, //jumlah item dalam daftar
                          itemBuilder: (context, index) { //builder function untuk setiap item dalam daftar
                            return GestureDetector( //widget GestureDetector untuk menangani ketukan
                              onTap: () {
                                _launchURL(snapshot.data!.ListPop[index].situs); //buka URL saat item diketuk
                              },
                              child: Container(// kontainer untuk menampilkan data universitas
                                decoration: BoxDecoration( //dekorasi kontainer
                                  color: Colors.white, //warna latar belakang kontainer
                                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0)),
                                  ),
                                  
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(snapshot.data!.ListPop[index].nama), //teks nama universitas
                                    Text(
                                      snapshot.data!.ListPop[index].situs, //teks URL situs web universitas
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Container(); // kembalikan kontainer kosong secara default
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //metode untuk membuka URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url); //Buka URL jika memungkinkan
    } else {
      throw 'Could not launch $url';//lempar pengecualian jika URL gagal
    }
  }
}

//widget dropdown untuk memilih negara
class CountryDropdown extends StatelessWidget {
  final List<String> countries = ['Indonesia', 'Malaysia', 'Thailand', 'Singapore', 'Philippines', 'Vietnam'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Pilih Negara', // Tambahkan teks "Pilih Negara" di sini
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
           padding: const EdgeInsets.all(14),
          child: DropdownButtonFormField<String>( // Widget DropdownButtonFormField untuk membuat dropdown
            value: Provider.of<SitusProvider>(context).selectedCountry, // Nilai terpilih diambil dari SitusProvider
            items: countries.map((String country) {// Mengonversi daftar negara menjadi daftar DropdownMenuItem
              return DropdownMenuItem<String>( // Membuat setiap item dalam dropdown
                value: country, // Nilai item
                child: Text(country), //Teks Item
              );
            }).toList(), // Konversi hasil pemetaan menjadi daftar
            onChanged: (String? newValue) { // Metode yang dipanggil ketika nilai dropdown berubah
              Provider.of<SitusProvider>(context, listen: false).changeCountry(newValue!); // Memanggil metode changeCountry di SitusProvider
            },
            decoration: InputDecoration( //dekorasi untuk warna latar belakang
              filled: true,
              fillColor: const Color.fromARGB(255, 202, 238, 255),  
            ),
          ),
        ),
      ],
    );
  }
}

