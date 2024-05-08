import 'package:flutter/material.dart'; //import paket material untuk komponen UI Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // Import paket flutter_bloc untuk state management
import 'package:http/http.dart' as http; // import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import paket json untuk parsing data JSON
import 'package:url_launcher/url_launcher.dart'; // import url launcher untuk membuka URL

class SitusUniv {  //mendefinisikan kelas untuk merepresentasikan universitas dan situs webnya
  String nama; //nama universitas
  String situs; //URL situs web univ
  SitusUniv({required this.nama, required this.situs}); //konstruktor
}

class Situs { // Deklarasi kelas Situs untuk merepresentasikan data universitas
  List<SitusUniv> ListPop = []; // List untuk menyimpan daftar universitas

  Situs.fromJson(List<dynamic> json) { //konstruktor untuk memparsing data JSON 
    for (var val in json) { // Loop untuk setiap item dalam JSON
      var namaUniv = val["name"]; // Ambil nama universitas
      var situsUniv = val["web_pages"][0]; // Ambil URL situs web universitas
      ListPop.add(SitusUniv(nama: namaUniv, situs: situsUniv));// Tambahkan universitas ke dalam list
    }
  }
}

abstract class SitusEvent {} // Kelas abstrak untuk Events SitusBloc 

class FetchData extends SitusEvent { // Event untuk meminta data berdasarkan negara
  final String country;

  FetchData(this.country);
}

abstract class SitusState {} // Kelas abstrak untuk state SitusBloc

class SitusInitial extends SitusState {} // State awal

class SitusLoading extends SitusState {} // State ketika sedang memuat

class SitusLoaded extends SitusState { // State ketika data telah dimuat
  final Situs situs;

  SitusLoaded(this.situs);
}

class SitusError extends SitusState { // Status ketika terjadi kesalahan
  final String error;

  SitusError(this.error);
}

class SitusBloc extends Bloc<SitusEvent, SitusState> { // Kelas SitusBloc untuk logika bisnis dan state management
  SitusBloc() : super(SitusInitial()) { // Konstruktor untuk inisialisasi state awal
    on<FetchData>((event, emit) async { // Handler untuk state FetchData
      await _handleFetchData(event, emit);
    });
  }

  Future<void> _handleFetchData( // Fungsi async untuk menangani permintaan data
      FetchData event, Emitter<SitusState> emit) async {
    try {
      emit(SitusLoading());  // Mengirim status loading
      final Situs situs = await fetchData(event.country); // Mendapatkan data dari sumber eksternal
      emit(SitusLoaded(situs)); // Mengirim status data berhasil dimuat
    } catch (e) {
      emit(SitusError('Gagal load'));  // Mengirim status kesalahan
    }
  }

  Future<Situs> fetchData(String country) async { // Fungsi untuk meminta data dari API
    String url = "http://universities.hipolabs.com/search?country=$country";
    final response = await http.get(Uri.parse(url)); // Melakukan permintaan HTTP
    if (response.statusCode == 200) {
      return Situs.fromJson(jsonDecode(response.body)); // Parsing data JSON ke objek Situs
    } else {
      throw Exception('Gagal load'); // Melemparkan pengecualian jika gagal memuat data
    }
  }
}

void main() { // Fungsi main untuk menjalankan aplikasi Flutter
  runApp(
    BlocProvider( // Membungkus aplikasi dengan BlocProvider untuk menyediakan SitusBloc ke seluruh aplikasi
      create: (context) => SitusBloc(), // Membuat instance SitusBloc dan menyediakannya ke aplikasi
      child: MyApp(), // Menjalankan aplikasi utama, MyApp
    ),
  );
}

class MyApp extends StatelessWidget { // Kelas MyApp yang merupakan root dari aplikasi
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas dan Situs Resminya',
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 202, 238, 255),
        appBar: AppBar(
          title: const Text('Universitas dan Situs Resminya'),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            CountryDropdown(),  // Widget dropdown negara
            Expanded(
              child: BlocBuilder<SitusBloc, SitusState>(
                builder: (context, state) {
                  if (state is SitusLoading) {
                    return Center(child: CircularProgressIndicator()); // Tampilan saat memuat data
                  } else if (state is SitusError) {
                    return Center(child: Text(state.error)); // Tampilan saat terjadi kesalahan
                  } else if (state is SitusLoaded) {
                    return ListView.builder(
                      itemCount: state.situs.ListPop.length, // Menampilkan daftar universitas
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _launchURL(state.situs.ListPop[index].situs); // Membuka tautan situs web universitas
                          },
                          child: Container(
                            decoration: BoxDecoration(
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
                                Text(state.situs.ListPop[index].nama), // Menampilkan nama universitas
                                Text(
                                  state.situs.ListPop[index].situs, // Menampilkan situs universitas
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class CountryDropdown extends StatelessWidget { // Widget dropdown negara
  final List<String> countries = [ // Daftar negara yang akan ditampilkan dalam dropdown
    'Indonesia',
    'Malaysia',
    'Thailand',
    'Singapore',
    'Philippines',
    'Vietnam'
  ];

  @override
  Widget build(BuildContext context) {
    // Menggunakan Set untuk menghapus nilai duplikat
    Set<String> uniqueCountries = Set<String>.from(countries); // Mengonversi List ke Set untuk menghapus nilai duplikat
    List<String> uniqueCountriesList = uniqueCountries.toList(); // Mengonversi kembali Set ke List
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Pilih Negara',  // Label untuk dropdown negara
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<SitusBloc, SitusState>(
            builder: (context, state) {
              String initialValue = 'Indonesia'; // Nilai awal default
              if (state is SitusLoaded && state.situs.ListPop.isNotEmpty) { // Jika data universitas telah dimuat dan tidak kosong
                initialValue = state.situs.ListPop
                    .firstWhere(
                      (univ) =>
                          univ.nama ==
                          'NamaUnivTertentu', // Ganti dengan logika yang sesuai
                      orElse: () => SitusUniv(
                          nama: 'Indonesia',
                          situs:
                              ''), // Nilai default jika tidak ada nilai yang cocok
                    )
                    .nama;
              }

              return DropdownButtonFormField<String>(
                value: initialValue, // Nilai awal dropdown
                items: uniqueCountries.map((String country) { // Membuat item-item dropdown berdasarkan daftar negara yang unik
                  // Menggunakan uniqueCountries
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) { // Handler saat nilai dropdown berubah
                  context.read<SitusBloc>().add(FetchData(newValue!)); // Meminta data universitas berdasarkan negara yang dipilih
                },
              );
            },
          ),
        )
      ],
    );
  }
}
