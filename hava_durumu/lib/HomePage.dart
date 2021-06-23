import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'SearchPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //JSON ayrıştırması yapabilmemiz için hazır kütüphane
import 'package:geolocator/geolocator.dart';

///Not: Bir fonksiyonun içerisinde bir tanım yaparsak onu sadece o fonksiyonda
///kullanabiliriz. Ancak fonksiyonun dışında bir tanım yaparsak fonksiyonda o
///tanıma bir atama yapmış oluruz.!.!

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = "Ankara";
  String image = "c";
  int sicaklik;
  var woeid;
  Position position;

  List temps = List(5); //ertesi günler
  List images = List(5); //ertesi günler
  List dates = List(5); //ertesi günler

  List<DateTime> datesDay = List(5); //ertesi günler

  Future<void> getDevicePosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    print("latitude = ${position.latitude}");
    print("longitude = ${position.longitude}");
  }

  Future<void> getLocationDataFromDevice() async {
    var locationData = await http.get(
        "https://www.metaweather.com/api/location/search/?lattlong=${position.latitude}, ${position.longitude}");
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes));
    ///Burada bytes tipinde yapmak zorundayız. onuda utf8.decode ile ayrıştırıyoruz.
    woeid = locationDataParsed[0]["woeid"];
    sehir = locationDataParsed[0]["title"];
  }

  Future<void> getLocationData() async {
    var locationData = await http.get(
      "https://www.metaweather.com/api/location/search/?query=$sehir",
    );
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]["woeid"];
  }

  void getFromAPIbyCity() async {
    await getLocationData();
    getWeatherForecast();
    //cihazdan konum bilgisi
  }

  Future<void> getWeatherForecast() async {
    var response =
        await http.get("https://www.metaweather.com/api/location/$woeid/");
    var responseDataParsed = jsonDecode(response.body);
    setState(
      () {
        sicaklik =
            responseDataParsed["consolidated_weather"][0]["the_temp"].round();
        image =
            responseDataParsed["consolidated_weather"][0]["weather_state_abbr"];

        for (int i = 0; i < temps.length; i++) {
          temps[i] = responseDataParsed["consolidated_weather"][i + 1]
                  ["the_temp"]
              .round();
          images[i] = responseDataParsed["consolidated_weather"][i + 1]
              ["weather_state_abbr"];
          dates[i] = responseDataParsed["consolidated_weather"][i + 1]
              ["applicable_date"];
          datesDay[i] = DateTime.parse(dates[i]);
        }
      },
    );
  }

  void getFromAPI() async {
    await getDevicePosition();
    await getLocationDataFromDevice(); //lat long konum
    await getLocationData();
    getWeatherForecast();
    //cihazdan konum bilgisi
  }

  @override
  void initState() {
    getFromAPI(); //bunu async yapamayız. Dolayısıyla bir fonksiyon oluşturduk

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List daysofWeek = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar"
    ];
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/$image.jpg"),
        ),
      ),
      child: SafeArea(
        ///sicaklik api üzerinden geldiği için hemen gelmiyor. O gelene kadar dönen çember efekti kullanabilirsin
        ///Ancak daha da güzel SpinKitWave paketidir ki çok güzel opsiyonları var. Kullanımı ise aşağıdaki gibidir.
        child: sicaklik == null
            ? Center(child: SpinKitWave(color: Colors.white, size: 50.0))
            : Scaffold(
                backgroundColor: Colors
                    .transparent, //Scaffold Containerin önüne geçmesini engelledik
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          child: Image.network(
                              "https://www.metaweather.com/static/img/weather/png/64/$image.png")),
                      Text(
                        "$sicaklik° C",
                        style: TextStyle(
                          fontSize: 80,
                          shadows: [
                            Shadow(
                              color: Colors.grey.shade900,
                              blurRadius: 5,
                              offset: Offset(-5, 5),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$sehir",
                            style: TextStyle(
                              fontSize: 40,
                              shadows: [
                                Shadow(
                                  color: Colors.grey.shade900,
                                  blurRadius: 5,
                                  offset: Offset(-3, 3),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.search, size: 40),
                            onPressed: () async {
                              sehir = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()));
                              ///şimcik burada. Navigasyondan geldikten sonra TextEditingControllerdan gelen
                              ///veri direk buraya navigasyona düşüyor. burda da set state içerisinde sehiri
                              ///kendisine atıyoruz. yani kendisini kendisine atıyoruz ki ordan gelen sehir
                              ///burayla eşitlensin. Ancak bunları yapmadan önce değişiklikleri görebilmek için
                              ///getFromAPIbyCity fonksiyonunu çağırmamız lazım. Çünkü şehir değişsin.
                              getFromAPIbyCity();
                              setState(() {
                                sehir = sehir;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        height: 120,
                        //width: MediaQuery.of(context).size.width*0.9,
                        child: FractionallySizedBox( ///bu yanyana gelen listviewlerin telefon kenarına olan
                          widthFactor: 0.9,         /// uzaklığını ayarlıyor. yüzde 90 uzat diyorsun.
                          child: ListView(
                            scrollDirection: Axis.horizontal, ///tam ne işe yarıyor anlamadım. Eğer kullanılmazsa tek bir tane gösteriyor. kullanılırsa 5 cartı da gösteriyor.
                            children: [
                              DailyWeather( ///bütün bunları tek tek yazmak yerine tek satırda hepsini halledebilirdik. Gerek yok şimdilik
                                date: daysofWeek[(datesDay[0].weekday) - 1], ///tarih bilgisi verildi.
                                temp: temps[0].toString(), ///sicaklık değeri verildi.
                                image: images[0], ///icon gösterildi.
                              ),
                              DailyWeather(
                                date: daysofWeek[(datesDay[1].weekday) - 1],
                                temp: temps[1].toString(),
                                image: images[1],
                              ),
                              DailyWeather(
                                date: daysofWeek[(datesDay[2].weekday) - 1],
                                temp: temps[2].toString(),
                                image: images[2],
                              ),
                              DailyWeather(
                                date: daysofWeek[(datesDay[3].weekday) - 1],
                                temp: temps[3].toString(),
                                image: images[3],
                              ),
                              DailyWeather(
                                date: daysofWeek[(datesDay[4].weekday) - 1],
                                temp: temps[4].toString(),
                                image: images[4],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather(
      {Key key, @required this.image, @required this.temp, @required this.date})
      : super(key: key);

  ///dışarıdan constructorda bu verilerin girilmesi isteniyor.

  @override
  Widget build(BuildContext context) {
    return Card( /// bu tarz şeyleri bir Card içerisinde tutmak çok daha mantıklı
      elevation: 2, ///hala bilmiyorum. Şeffaflığını, yüksekliğini ayarlıyor gibi bir şey.
      color: Colors.transparent, ///saydam olması lazım renginin. Hoş bir seda için.
      child: Container(
        height: 120,
        width: 100,
        child: Column( ///bir container içerisinde boyutlarını belirledik.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://www.metaweather.com/static/img/weather/png/64/$image.png",
              width: 50,
              height: 50,
            ),
            Text("$temp° C"),
            Text("$date"),
          ],
        ),
      ),
    );
  }
}
