import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:jemputah_app/API/FetchDataJemput.dart';
import 'package:jemputah_app/constants/color.dart';
import 'package:jemputah_app/constants/icons.dart';
import 'package:jemputah_app/constants/images.dart';
import 'package:jemputah_app/extensions/time_code_converter.dart';
import 'package:jemputah_app/screens/detail_penjemputan_screen.dart';
import 'package:jemputah_app/screens/penjemputan_screen.dart';
import 'package:jemputah_app/screens/transaksi_screen.dart';
import '../API/FetchData.dart';
import '../constants/variable.dart';
import 'package:jemputah_app/extensions/date_time_converter.dart';

// DateTimeConverter dateTimeConverter = DateTimeConverter();
// var n = DateTime.now().toString();
// String tgl = dateTimeConverter.format(n);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HistoryTransactionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.only(
        bottom: 40,
        right: 15,
      ),
      icon: Image.asset(
        iconTransaksi,
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return TransaksiScreen();
          },
        ));
      },
    );
  }
}

class _LeadAppBar extends StatelessWidget {
  final String username;

  _LeadAppBar(
    this.username,
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 200,
          child: Image.asset(
            homeLogo,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 25,
          ),
          child: Text(
            "Hai, $username",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 12,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}

class _JemputBox extends StatelessWidget {
  int berat;
  int jmlJemput;
  int koin;

  _JemputBox(
    this.koin,
    this.jmlJemput,
    this.berat,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromRGBO(178, 186, 159, 1),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        color: Color.fromRGBO(178, 186, 159, 1),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(
              left: 35,
              right: 35,
              top: 30,
            ),
            height: 35,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    koin.toString(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 21,
                    ),
                  ),
                ),
                const Text(
                  " Koin",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 21,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColors.black,
            margin: const EdgeInsets.symmetric(
              vertical: 10,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: 150,
                  height: 30,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: Text(
                          "$jmlJemput Jemput",
                        ),
                      ),
                      const VerticalDivider(
                        width: 10,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      Text(
                        "$berat Kg",
                      ),
                    ],
                  )),
              Container(
                margin: const EdgeInsets.only(
                  right: 28,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const PenjemputanScreen();
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    minimumSize: const Size(110, 35),
                  ),
                  child: const Text("Jemput"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _Carousel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CarouselState();
  }
}

class _CarouselState extends State<_Carousel> {
  CarouselController carouselButton = CarouselController();

  int currentPos = 0;
  List<String> carouselImg = [
    carousel1,
    carousel2,
    carousel3,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          height: 170,
          child: CarouselSlider.builder(
            itemCount: carouselImg.length,
            options: CarouselOptions(
              height: 154,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.6,
              onPageChanged: (index, reason) {
                setState(() {
                  currentPos = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return CarouselView(carouselImg[index]);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: carouselImg.map((url) {
            int index = carouselImg.indexOf(url);
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPos == index ? AppColors.black : AppColors.white,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CarouselView extends StatelessWidget {
  String path;

  CarouselView(this.path, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 275,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        child: Image.asset(
          path,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class _JadwalJemput extends StatelessWidget {
  List<Map<String, dynamic>> data;

  _JadwalJemput(
    this.data,
  );

  TimeCodeConverter timeCodeConverter = TimeCodeConverter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(
            top: 23.4,
            bottom: 10,
            left: 22,
          ),
          child: const Text(
            "Penjemputanmu Selanjutnya : ",
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 17,
          ),
          height: 250,
          child: ListView.separated(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 113,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  color: AppColors.jadwalCardBackground,
                  child: ListTile(
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: 4,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 10,
                      ),
                      child: Text(
                        data[index]["date"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Text(
                            timeCodeConverter
                                .timeCodeConverter(data[index]["time_code"]),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          data[index]["address"],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(
                        left: 5,
                      ),
                      child: Image.asset(
                        iconJadwal,
                        width: 64,
                        height: 64,
                        fit: BoxFit.fill,
                      ),
                    ),
                    trailing: const Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                        top: 5,
                      ),
                      child: Icon(
                        Icons.navigate_next,
                        size: 60,
                      ),
                    ),
                    minLeadingWidth: 64,
                    dense: true,
                    horizontalTitleGap: 8.5,
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return DetailPenjemputanScreen(
                                data[index]["id_jemput"]);
                          },
                        ),
                      ),
                    },
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(
              thickness: 1,
              height: 10,
              color: AppColors.backgroundGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  var username = "Account";
  var jml_koin_user = 0;
  var jml_jemput = 0;
  var jml_berat = 0;
  List<Map<String, dynamic>> data = [];

  void setJemput() {
    var penjemputan = FetchDataJemput().fetchListJemputNotDone(uid);
    penjemputan.then((value) {
      setState(() {
        data = value;
      });
    });
  }

  void set() {
    var user = FetchData().fetchMapData("user", uid);
    user.then((value) {
      setState(() {
        username = value["name_user"];
        jml_koin_user = value["jml_koin_user"];
        jml_jemput = value["jml_jemput"];
        jml_berat = value["jml_berat"];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    set();
    setJemput();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: AppBar(
        leadingWidth: 200,
        backgroundColor: AppColors.backgroundGreen,
        toolbarHeight: 87,
        elevation: 0,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_LeadAppBar(username)],
        ),
        actions: [
          _HistoryTransactionButton(),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Column(
                children: [
                  _JemputBox(jml_koin_user, jml_jemput, jml_berat),
                  _Carousel(),
                  _JadwalJemput(data),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
