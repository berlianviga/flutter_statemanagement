import 'package:flutter/material.dart'; //import paket material untuk komponen UI Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // Import paket flutter_bloc untuk state management
import 'package:http/http.dart' as http; // import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import paket json untuk parsing data JSON
import 'package:url_launcher/url_launcher.dart'; // import url launcher untuk membuka URL

class SitusUniv { //mendefinisikan kelas untuk merepresentasikan universitas dan situs webnya
  String nama; //nama universitas
  String situs; //URL situs web univ
  SitusUniv({required this.nama, required this.situs});  //konstruktor
}

class Situs { // Deklarasi kelas Situs untuk merepresentasikan data universitas
  List<SitusUniv> ListPop = []; // List untuk menyimpan daftar universitas

  Situs.fromJson(List<dynamic> json) { //konstruktor untuk memparsing data JSON 
    for (var val in json) { // Loop untuk setiap item dalam JSON
      var namaUniv = val["name"]; // Ambil nama universitas
      var situsUniv = val["web_pages"][0]; // Ambil URL situs web universitas
      ListPop.add(SitusUniv(nama: namaUniv, situs: situsUniv)); // Tambahkan universitas ke dalam list
    }
  }
}

void main() { // Fungsi utama yang dijalankan saat aplikasi dimulai
  runApp( // Panggil fungsi runApp untuk menjalankan aplikasi Flutter
    BlocProvider( // Widget BlocProvider untuk memberikan akses ke state management dengan Bloc
      create: (context) => CountryCubit(),  // Buat instance dari CountryCubit dan berikan ke BlocProvider
      child: MyApp(),  // Widget root aplikasi
    ),
  );
}

class CountryCubit extends Cubit<String> { // Deklarasi kelas CountryCubit sebagai subclass dari Cubit
  CountryCubit() : super('Indonesia'); // Konstruktor untuk mengatur negara terpilih secara default

  void changeCountry(String country) => emit(country); // Metode untuk mengubah negara terpilih dan memancarkan perubahan

}

class MyApp extends StatelessWidget { // Deklarasi kelas MyApp sebagai StatelessWidget
  @override
  Widget build(BuildContext context) { // Override metode build untuk membangun tampilan aplikasi
    return MaterialApp(
      title: 'Universitas dan Situs Resminya', // Judul aplikasi
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 202, 238, 255), // Warna latar belakang
        appBar: AppBar(
          title: const Text('Universitas dan Situs Resminya'), // Judul appbar
          backgroundColor: Colors.blue, // Warna latar belakang appbar
        ),
        body: Column(
          children: [
            CountryDropdown(), // Widget untuk menampilkan dropdown negara
            Expanded(
              child: BlocBuilder<CountryCubit, String>( // Widget BlocBuilder untuk mendengarkan perubahan pada CountryCubit
                builder: (context, selectedCountry) { // Builder function untuk BlocBuilder
                  return FutureBuilder<Situs>( // Widget FutureBuilder untuk menangani future data Situs
                    future: fetchData(selectedCountry), // Future yang akan diproses
                    builder: (context, snapshot) { // Builder function untuk FutureBuilder
                      if (snapshot.connectionState == ConnectionState.waiting) { // Saat data masih diambil
                        return Center(child: CircularProgressIndicator()); // Tampilkan indikator loading
                      }
                      if (snapshot.hasError) { // Jika terjadi kesalahan saat mengambil data
                        return Center(child: Text('${snapshot.error}')); // Tampilkan pesan kesalahan
                      }
                      if (snapshot.hasData) { // Jika data telah tersedia
                        return ListView.builder( // Widget ListView untuk menampilkan daftar universitas
                          itemCount: snapshot.data!.ListPop.length, // Jumlah item dalam daftar
                          itemBuilder: (context, index) { // Builder function untuk setiap item dalam daftar
                            return GestureDetector( // Widget GestureDetector untuk menangani ketukan
                              onTap: () {
                                _launchURL(snapshot.data!.ListPop[index].situs); // Buka URL saat item diketuk
                              },
                              child: Container( // Kontainer untuk menampilkan data universitas
                                decoration: BoxDecoration( // Mendefinisikan dekorasi kontainer
                                  color: Colors.white,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.withOpacity(0.5),
                                          width: 1.0)),
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(snapshot.data!.ListPop[index].nama), // Menampilkan nama universitas
                                    Text(
                                      snapshot.data!.ListPop[index].situs, // Mendapatkan URL situs dari data universitas
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
                      return Container();
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

  Future<Situs> fetchData(String country) async { // Fungsi untuk mengambil data universitas berdasarkan negara
    String url = "http://universities.hipolabs.com/search?country=$country"; // URL endpoint API berdasarkan negara yang dipilih
    final response = await http.get(Uri.parse(url)); // Melakukan HTTP GET request
    if (response.statusCode == 200) {
      return Situs.fromJson(jsonDecode(response.body)); // Mengembalikan objek Situs dari data JSON yang diambil
    } else {
      throw Exception('Gagal load');
    }
  }

  void _launchURL(String url) async { // Fungsi untuk membuka URL
    if (await canLaunch(url)) { // Memeriksa apakah URL bisa dibuka
      await launch(url); // Membuka URL jika memungkinkan
    } else {  
      throw 'Could not launch $url'; // Melempar pengecualian dengan pesan bahwa URL tidak dapat dibuka
    }
  }
}

class CountryDropdown extends StatelessWidget { // Kelas widget untuk menampilkan dropdown negara
  final List<String> countries = [
    'Indonesia',
    'Malaysia',
    'Thailand',
    'Singapore',
    'Philippines',
    'Vietnam'
  ];

  @override
  Widget build(BuildContext context) { // Metode untuk membangun tampilan widget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text( // Widget Text untuk menampilkan teks
            'Pilih Negara',  
            style: TextStyle( // Mendefinisikan gaya teks
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: BlocBuilder<CountryCubit, String>( // Widget BlocBuilder untuk membangun UI berdasarkan state dari CountryCubit
            builder: (context, selectedCountry) { // Callback yang dipanggil untuk membangun UI dengan state terbaru dari CountryCubit
              return DropdownButtonFormField<String>( // Widget DropdownButtonFormField untuk menampilkan dropdown negara
                value: selectedCountry, // Nilai dropdown yang dipilih
                items: countries.map((String country) { // Membuat daftar item dropdown dari daftar negara
                  return DropdownMenuItem<String>( // Widget DropdownMenuItem untuk setiap item dropdown
                    value: country, // Nilai item dropdown
                    child: Text(country), // Teks yang ditampilkan untuk item dropdown
                  );
                }).toList(), // Mengonversi hasil pemetaan menjadi daftar
                onChanged: (String? newValue) { // Callback yang dipanggil ketika nilai dropdown berubah
                  context.read<CountryCubit>().changeCountry(newValue!); // Memanggil metode changeCountry di CountryCubit dengan nilai baru
                },
                decoration: InputDecoration( // Dekorasi untuk dropdown
                  filled: true,
                  fillColor: const Color.fromARGB(255, 202, 238, 255),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
