import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jemputah_app/API/FetchDataDriver.dart';
import 'package:jemputah_app/constants/color.dart';
import 'package:jemputah_app/constants/icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jemputah_app/screens/base_screen.dart';
import 'package:jemputah_app/extensions/time_code_converter.dart';
import 'package:jemputah_app/extensions/date_time_converter.dart';
import 'package:jemputah_app/API/FetchData.dart';
import 'package:jemputah_app/constants/variable.dart';

class PenjemputanScreen extends StatefulWidget {
  const PenjemputanScreen({super.key});

  @override
  State<StatefulWidget> createState() => InitState();
}

class InitState extends State<PenjemputanScreen> {
  var db = FirebaseFirestore.instance;
  var idSampah = '';
  var idDriver = '';
  var idJemput = '';
  var timecode = 0;
  TimeConverter timeConverter = TimeConverter();
  List<Map<String, dynamic>> dataAddress = [];
  var lokasiPengambilanItems = [''];

  DateTimeConverter dateTimeConverter = DateTimeConverter();
  var dateNow = DateTime.now().toString();

  double _beratSampahPlastik = 0;
  double _beratSampahKarton = 0;
  double _beratSampahKaca = 0;
  double _beratSampahKaleng = 0;

  int _totalPendapatan = 0;
  double _totalBerat = 0;

  List weightOfItems = [0.0, 0.0, 0.0, 0.0];

  int setDriverCoin(double totalBerat) {
    if (totalBerat <= 10) {
      return 1000;
    } else {
      return 1500;
    }
  }

  void _calculateCoin() {
    _totalPendapatan = (_beratSampahPlastik * 120 +
            _beratSampahKarton * 150 +
            _beratSampahKaca * 500 +
            _beratSampahKaleng * 550)
        .toInt();
  }

  void _calculateTotalWeight() {
    _totalBerat = _beratSampahPlastik +
        _beratSampahKarton +
        _beratSampahKaca +
        _beratSampahKaleng;
  }

  void setWeight() {
    _beratSampahPlastik = weightOfItems[0];
    _beratSampahKarton = weightOfItems[1];
    _beratSampahKaca = weightOfItems[2];
    _beratSampahKaleng = weightOfItems[3];
  }

  void setIdSampah(value) {
    idSampah = value;
  }

  void setAddress() {
    var address = FetchData().fetchListData('address', uid);
    address.then((value) {
      setState(() {
        dataAddress = value;
        lokasiPengambilanItems =
            dataAddress.map((e) => e['address'].toString()).toList();
        lokasiPengambilan = lokasiPengambilanItems[0];
      });
    });
  }

  void setDriver(int timecode) {
    Random random = Random();
    var driver = FetchDataDriver().fetchListDriver(timecode);
    driver.then((value) {
      setState(() {
        if (value.length > 1) {
          int num = random.nextInt(value.length);
          idDriver = value[num]['id_driver'];
        } else {
          idDriver = value[0]['id_driver'];
        }
      });
    });
  }

  Future<void> aturPenjemputan() async {
    timecode = timeConverter.format(waktuPengambilan);
    final sampah = <String, dynamic>{
      "berat1": _beratSampahPlastik,
      "berat2": _beratSampahKarton,
      "berat3": _beratSampahKaca,
      "berat4": _beratSampahKaleng,
    };
    DocumentReference docRef = await db.collection("sampah").add(sampah);
    idSampah = docRef.id.toString();
    final jemput = <String, dynamic>{
      "address": lokasiPengambilan,
      "date": dateTimeConverter.format(dateNow),
      "done": false,
      "id_driver": idDriver,
      "id_sampah": idSampah,
      "id_user": uid,
      "time_code": timecode,
      "total_berat": _totalBerat,
      "total_koin_driver": setDriverCoin(_totalBerat),
      "total_koin_user": _totalPendapatan,
    };
    DocumentReference ref = await db.collection("jemput").add(jemput);
    idJemput = ref.id.toString();
    db.collection("driver").doc(idDriver).update({'slot_$timecode': idJemput});
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const BaseScreen()));
  }

  Widget _incrementWeight(int index) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      onPressed: () {
        setState(() {
          weightOfItems[index] += 0.5;
          setWeight();
          _calculateCoin();
          _calculateTotalWeight();
        });
      },
      heroTag: null,
      child: const Icon(Icons.add),
    );
  }

  Widget _decrementWeight(int index) {
    return FloatingActionButton(
      backgroundColor: AppColors.grayDecrement,
      onPressed: () {
        if (weightOfItems[index] == 0.0) {
          const snackBar = SnackBar(
            content: Text('Berat minimal adalah 0.0 Kg'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          setState(() {
            weightOfItems[index] -= 0.5;
            setWeight();
            _calculateCoin();
            _calculateTotalWeight();
          });
        }
      },
      heroTag: null,
      child: const Icon(Icons.remove),
    );
  }

  String lokasiPengambilan = '';

  String waktuPengambilan = '08:00 - 10.00';
  final waktuPengambilanItems = [
    '08:00 - 10.00',
    '10:00 - 12.00',
    '12:00 - 14.00',
    '14:00 - 16.00',
    '16:00 - 18.00',
  ];

  @override
  void initState() {
    super.initState();
    setAddress();
  }

  @override
  Widget build(BuildContext context) {
    return initWidget();
  }

  Widget initWidget() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 246, 233, 1),
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: AppColors.mainGreen,
        title: const Text('Pesan Penjemputan'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(left: 24, top: 30),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Jenis Daur Ulang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Container(
              height: 42,
              margin: const EdgeInsets.only(left: 24, right: 24, top: 20),
              padding: const EdgeInsets.only(left: 10, right: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(178, 186, 159, 1),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: Color(0xffEEEEEE)),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    width: 34,
                    height: 34,
                    child: Image.asset(
                      iconPlastik,
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                    child: Text('Plastik'),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 84, right: 18),
                          height: 30,
                          width: 30,
                          child: _decrementWeight(0),
                        ),
                        Text("$_beratSampahPlastik"),
                        const Text('Kg'),
                        Container(
                            margin: const EdgeInsets.only(left: 18),
                            height: 30,
                            width: 30,
                            child: _incrementWeight(0)),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              height: 42,
              margin: const EdgeInsets.only(left: 24, right: 24, top: 8),
              padding: const EdgeInsets.only(left: 10, right: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(178, 186, 159, 1),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: Color(0xffEEEEEE)),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    width: 34,
                    height: 34,
                    child: Image.asset(
                      iconKarton,
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                    child: Text('Karton'),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 84, right: 18),
                          height: 30,
                          width: 30,
                          child: _decrementWeight(1),
                        ),
                        Text("$_beratSampahKarton"),
                        const Text('Kg'),
                        Container(
                          margin: const EdgeInsets.only(left: 18),
                          height: 30,
                          width: 30,
                          child: _incrementWeight(1),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              height: 42,
              margin: const EdgeInsets.only(left: 24, right: 24, top: 8),
              padding: const EdgeInsets.only(left: 10, right: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(178, 186, 159, 1),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: Color(0xffEEEEEE)),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    width: 34,
                    height: 34,
                    child: Image.asset(
                      iconKaca,
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                    child: Text('Kaca'),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 84, right: 18),
                          height: 30,
                          width: 30,
                          child: _decrementWeight(2),
                        ),
                        Text("$_beratSampahKaca"),
                        const Text('Kg'),
                        Container(
                          margin: const EdgeInsets.only(left: 18),
                          height: 30,
                          width: 30,
                          child: _incrementWeight(2),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              height: 42,
              margin: const EdgeInsets.only(left: 24, right: 24, top: 8),
              padding: const EdgeInsets.only(left: 10, right: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(178, 186, 159, 1),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: Color(0xffEEEEEE)),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    width: 34,
                    height: 34,
                    child: Image.asset(
                      iconKaleng,
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                    child: Text('Kaleng'),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 84, right: 18),
                          height: 30,
                          width: 30,
                          child: _decrementWeight(3),
                        ),
                        Text("$_beratSampahKaleng"),
                        const Text('Kg'),
                        Container(
                          margin: const EdgeInsets.only(left: 18),
                          height: 30,
                          width: 30,
                          child: _incrementWeight(3),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
            margin: const EdgeInsets.only(left: 24, top: 30),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Lokasi Pengambilan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Container(
              height: 42,
              margin: const EdgeInsets.only(left: 24, right: 24, top: 8),
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(178, 186, 159, 1),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: Color(0xffEEEEEE)),
                ],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  width: 34,
                  height: 34,
                  child: const Icon(Icons.location_on),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    // Initial Value
                    value: lokasiPengambilan,
                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),
                    // Array list of items
                    dropdownColor: const Color.fromRGBO(178, 186, 159, 1),
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    items: lokasiPengambilanItems.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        lokasiPengambilan = newValue!;
                      });
                    },
                  ),
                ),
              ])),
          Container(
            margin: const EdgeInsets.only(left: 24, top: 30),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Waktu Pengambilan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Container(
              height: 42,
              margin: const EdgeInsets.only(left: 24, right: 24, top: 8),
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(178, 186, 159, 1),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: Color(0xffEEEEEE)),
                ],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  width: 34,
                  height: 34,
                  child: const Icon(Icons.timer),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButton(
                    isExpanded: true,
                    // Initial Value
                    value: waktuPengambilan,
                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),
                    // Array list of items
                    dropdownColor: const Color.fromRGBO(178, 186, 159, 1),
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                    items: waktuPengambilanItems.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        waktuPengambilan = newValue!;
                      });
                    },
                  ),
                ),
              ])),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 70, left: 24),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Total Pendapatan Anda',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 70, right: 24),
                child: Text(("$_totalPendapatan Koin"),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          GestureDetector(
              onTap: () {
                if (_beratSampahPlastik == 0 &&
                    _beratSampahKarton == 0 &&
                    _beratSampahKaca == 0 &&
                    _beratSampahKaleng == 0) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppColors.secondaryBorder,
                          title: const Text(
                            "Error",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                          content: const Text(
                            "Mohon isi terlebih dahulu berat sampah daur ulang.",
                            textAlign: TextAlign.center,
                          ),
                        );
                      });
                } else {
                  setDriver(timeConverter.format(waktuPengambilan));
                  aturPenjemputan();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppColors.secondaryBorder,
                          title: const Text(
                            "Berhasil",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                          content: const Text(
                            "Pemesanan Anda sudah berhasil.",
                            textAlign: TextAlign.center,
                          ),
                        );
                      });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(left: 24, right: 24, top: 20),
                height: 42,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(62, 75, 42, 1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 10),
                        blurRadius: 50,
                        color: Color(0xffEEEEEE)),
                  ],
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                    width: 300,
                    child: Text(
                      'Atur Penjemputan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.arrow_circle_right,
                      color: Colors.white,
                    ),
                  )
                ]),
              )),
        ]),
      ),
    );
  }
}
