import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'songs.dart';
import 'main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

int currlen = 0;
int currlen2 = 0;
double percentage = 0;
int counter = 0;

class AchievementsWidget extends StatefulWidget {
  const AchievementsWidget({Key? key}) : super(key: key);

  @override
  _AchievementsWidgetState createState() => _AchievementsWidgetState();
}

class _AchievementsWidgetState extends State<AchievementsWidget> {
  double percentDisplay() {
    currlen = len;
    currlen2 = len2;
    percentage = ((len * 0.3) + (len2 * 0.7)) / 10;
    counter = percentage.floor();
    if (percentage < 0) percentage = 0;
    return (percentage - counter) >= 0 ? (percentage - counter) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 52.0,
        centerTitle: true,
        title: Text('Libretto'),
      ),
      body: (Scaffold(
        backgroundColor: Color(0xFFEFD3D3),
        appBar: AppBar(
          centerTitle: true,
          title: Text('My Progress'),
          backgroundColor: Color(0xFFA65656),
          toolbarHeight: 68.0,
        ),
        body: Container(
            child: SingleChildScrollView(
                child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Text('Awesome!',
                          style:
                              TextStyle(fontFamily: 'Raleway', fontSize: 18)),
                    ),
                    Center(
                      child: CircularPercentIndicator(
                        animateFromLastPercent: true,
                        radius: 100.0,
                        lineWidth: 15.0,
                        percent: percentDisplay(),
                        animation: true,
                        header: Text('My Productivity',
                            style: TextStyle(
                                color: Color.fromARGB(255, 86, 5, 5),
                                fontWeight: FontWeight.w500,
                                fontSize: 30,
                                fontFamily: 'Baloo')),
                        center: Text('%',
                            style: TextStyle(
                              color: Color.fromARGB(255, 86, 5, 5),
                              fontWeight: FontWeight.w900,
                              fontSize: 30,
                              fontFamily: 'Baloo',
                            )),
                        backgroundColor: Color(0xFFA65656),
                        progressColor: Color.fromARGB(255, 10, 174, 13),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Text('Good!',
                          style:
                              TextStyle(fontFamily: 'Raleway', fontSize: 18)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 23.0),
                  child: Text('Great!',
                      style: TextStyle(fontFamily: 'Raleway', fontSize: 18)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: IconButton(
                      icon: Image.asset('assets/images/music-note.png'),
                      color: Colors.red,
                      onPressed: () {},
                      tooltip:
                          'Make the bar reach 100% to earn one musical note!'),
                ),
                Text('$counter', style: TextStyle(fontSize: 18)),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: const LinearGradient(colors: [
                          Color(0xFFA65656),
                          Color.fromARGB(255, 248, 126, 126)
                        ]),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2.0,
                              offset: Offset(2.0, 2.0))
                        ]),
                    child: Row(
                      children: <Widget>[
                        Visibility(
                          visible: (counter >= 1) ? true : false,
                          child: IconButton(
                            icon: Image.asset('assets/images/happy-face.png'),
                            color: Colors.red,
                            onPressed: () {},
                            iconSize: 60.0,
                          ),
                        ),
                        Visibility(
                          visible: (counter < 1) ? true : false,
                          child: IconButton(
                            icon: Image.asset('assets/images/worried.png'),
                            color: Colors.red,
                            onPressed: () {},
                            iconSize: 60.0,
                          ),
                        ),
                        Visibility(
                          visible: (counter >= 1) ? true : false,
                          child: Text('Good job! Keep being productive!',
                              style: TextStyle(
                                  fontFamily: 'Raleway', fontSize: 18)),
                        ),
                        Visibility(
                          visible: (counter < 1) ? true : false,
                          child: Text('I am sure you can do better!',
                              style: TextStyle(
                                  fontFamily: 'Raleway', fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ))),
      )),
    );
  }
}
