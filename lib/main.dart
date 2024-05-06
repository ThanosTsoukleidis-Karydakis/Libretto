import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "addNewEvent.dart";
import "editEvent.dart";
import "contacts.dart";
import "songs.dart";
import "achievements.dart";
import "addNewSong.dart";
import "addNewContact.dart";
import 'package:intl/intl.dart' as intl;
import 'package:open_file/open_file.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'camera.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:string_similarity/string_similarity.dart';
import 'package:flutter/services.dart';
import 'package:maps_launcher/maps_launcher.dart';

int len2 = 0;

late List<CameraDescription> cameras;
late CameraDescription firstCamera;

List<Event> pubevents = <Event>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp
  ]);
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  firstCamera = cameras.first;
  runApp(Libretto());
}

class Libretto extends StatelessWidget {
  Libretto({super.key});

  MaterialColor mycolor = MaterialColor(
    0xFF633B48,
    <int, Color>{
      50: Color(0xFF633B48),
      100: Color(0xFF633B48),
      200: Color(0xFF633B48),
      300: Color(0xFF633B48),
      400: Color(0xFF633B48),
      500: Color(0xFF633B48),
      600: Color(0xFF633B48),
      700: Color(0xFF633B48),
      800: Color(0xFF633B48),
      900: Color(0xFF633B48),
    },
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libretto',
      theme: ThemeData(
        primarySwatch: mycolor,
      ),
      home: TaskListScreenWidget(),
    );
  }
}

class TaskListScreenWidget extends StatefulWidget {
  const TaskListScreenWidget({Key? key}) : super(key: key);

  @override
  _TaskListScreenWidgetState createState() => _TaskListScreenWidgetState();
}

class _TaskListScreenWidgetState extends State<TaskListScreenWidget> {
  late CameraController controller;
  late SQLiteService sqLiteService;

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();

    sqLiteService = SQLiteService();

    sqLiteService.initDB().whenComplete(() async {
      final events = await sqLiteService.getEvents();
      final count = await sqLiteService.getLen2() ?? 0;

      setState(() {
        pubevents = events;
        len2 = count;
      });
    });
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      for (var current_song in pubsongs) {
        if (_lastWords.similarityTo('open ' + current_song.title) > 0.5) {
          OpenFile.open(current_song.pdf_link);
        }
      }
      if (_lastWords.similarityTo('songs') > 0.35 ||
          _lastWords.similarityTo('sing') > 0.35) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SongsWidget()));
      }
      if (_lastWords.similarityTo('add event') > 0.35) {
        _addNewEvent();
      }
      if (_lastWords.similarityTo('contacts') > 0.35)
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ContactsWidget()));
      if (_lastWords.similarityTo('show my progress') > 0.35)
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AchievementsWidget()));
      if (_lastWords.similarityTo('delete checked') > 0.8) {
        sqLiteService.deleteChecked();
        setState(() {
          pubevents.removeWhere((element) => element.checked);
        });
      }
      if (_lastWords.similarityTo('sort') > 0.35) {
        pubevents.sort((a, b) {
          if (a.dateAlarm == null) return 1;
          if (b.dateAlarm == null) return -1;
          if (a.dateAlarm == b.dateAlarm) {
            if (a.alarm == null) return 1;
            if (b.alarm == null) return -1;
            return TimeOfDayToDouble(a.alarm!)
                .compareTo(TimeOfDayToDouble(b.alarm!));
          }
          return DateTime.parse(a.dateAlarm.toString())
              .compareTo(DateTime.parse(b.dateAlarm.toString()));
        });
      }
      if (_lastWords.similarityTo('Johann') > 0.5 ||
          _lastWords.similarityTo('Γιόχαν') > 0.5) {
        final player = AudioCache();
        player.play('sounds/Bach.mp3');
      }
      if (_lastWords.similarityTo('Ian') > 0.5 ||
          _lastWords.similarityTo('Ίαν') > 0.5) {
        final player = AudioCache();
        player.play('sounds/Curtis.mp3');
      }
      if (_lastWords.similarityTo('Koulis') > 0.5 ||
          _lastWords.similarityTo('Κούλης') > 0.5 ||
          _lastWords.similarityTo('Cooleys') > 0.5 ||
          _lastWords.similarityTo('cooties') > 0.5) {
        final player = AudioCache();
        player.play('sounds/Koulis.mp3');
      }
      if (_lastWords.similarityTo('Bob') > 0.5 ||
          _lastWords.similarityTo('Μπομπ') > 0.5) {
        final player = AudioCache();
        player.play('sounds/Dylan.mp3');
      }
      if (_lastWords.similarityTo('Australia') > 0.5 ||
          _lastWords.similarityTo('Αυστραλία') > 0.5) {
        final player = AudioCache();
        player.play('sounds/australia.mp3');
      }
      if (_lastWords.similarityTo('Sanremo') > 0.5 ||
          _lastWords.similarityTo('σαν Ρέμο') > 0.5 ||
          _lastWords.similarityTo('san remo') > 0.5 ||
          _lastWords.similarityTo('Italy') > 0.5) {
        final player = AudioCache();
        player.play('sounds/sanremo.mp3');
      }
      if (_lastWords.similarityTo('Cure') > 0.5 ||
          _lastWords.similarityTo('kurir') > 0.5 ||
          _lastWords.similarityTo('Q') > 0.5) {
        final player = AudioCache();
        player.play('sounds/cure.mp3');
      }
      if (_lastWords.similarityTo('Smiths') > 0.5 ||
          _lastWords.similarityTo('Σμιθς') > 0.5) {
        final player = AudioCache();
        player.play('sounds/smiths.mp3');
      }
      if (_lastWords.similarityTo('Alla ti') > 0.5 ||
          _lastWords.similarityTo('Αλλά τι') > 0.5) {
        final player = AudioCache();
        player.play('sounds/Mitsos.mp3');
      }
      if (_lastWords.similarityTo('delete all') > 0.8) {
        sqLiteService.deleteAll();
        setState(() {
          pubevents.clear();
        });
      }
    });
  }

  void _addNewEvent() async {
    Event? newEvent = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddNewEvent()));

    if (newEvent != null) {
      final newId = await sqLiteService.addEvent(newEvent);
      newEvent.id = newId;
      pubevents.add(newEvent);
      final help = await sqLiteService.getLen2() ?? 0;
      setState(() {
        len2 = help;
      });
    }
  }

  void _deleteTask(int idx) async {
    bool? delTask = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: const Text('Delete Event?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ));

    if (delTask!) {
      final event = pubevents.elementAt(idx);

      try {
        sqLiteService.deleteEvent(event.id);

        pubevents.removeAt(idx);
      } catch (err) {
        debugPrint('Could not delete event $event: $err');
      }
      final help2 = await sqLiteService.getLen2() ?? 0;
      setState(() {
        len2 = help2;
      });
    }
  }

  void _editTask(int idx) async {
    Event? newEvent = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => editEvent(id: idx)));
    if (newEvent != null) {
      newEvent.id = idx;
      pubevents[idx] = newEvent;
      final newId = await sqLiteService.editEvent(newEvent, idx);
      final help = await sqLiteService.getLen2() ?? 0;
      setState(() {
        len2 = help;
      });
    }
  }

  double TimeOfDayToDouble(TimeOfDay myTime) =>
      myTime.hour + myTime.minute / 60;

  Widget _buildEventList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
      itemCount: pubevents.length,
      itemBuilder: (context, index) {
        IconData iconData;
        String toolTip;
        if (pubevents[index].checked) {
          iconData = Icons.check_box_outlined;
          toolTip = 'Uncheck';
        } else {
          iconData = Icons.check_box_outline_blank_outlined;
          toolTip = 'Check';
        }
        return Container(
            key: Key('$index'),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7090B0).withOpacity(0.2),
                  blurRadius: 20.0,
                  offset: const Offset(0, 10.0),
                )
              ],
            ),
            child: ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: Color(0xff633b48)),
                  borderRadius: BorderRadius.circular(20),
                ),
                key: Key('$index'),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: IconButton(
                  icon: Icon(iconData),
                  onPressed: () {
                    pubevents[index].checked = !pubevents[index].checked;
                    sqLiteService.updateChecked(pubevents[index]);
                    setState(() {});
                  },
                  tooltip: toolTip,
                ),
                title: new Text(pubevents[index].type1 ?? ''),
                subtitle: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      Visibility(
                        visible: pubevents[index].alarm != null ? true : false,
                        child: Text(
                          pubevents[index].alarm != null
                              ? pubevents[index].alarm!.format(context) +
                                  '   |   '
                              : '',
                        ),
                      ),
                      Visibility(
                        visible:
                            pubevents[index].dateAlarm != null ? true : false,
                        child: Text(
                          pubevents[index].dateAlarm != null
                              ? intl.DateFormat.yMMMd().format(
                                  pubevents[index].dateAlarm ?? DateTime.now())
                              : '',
                        ),
                      ),
                    ]),
                    Row(
                      children: <Widget>[
                        Text(
                          pubevents[index].location,
                        ),
                        Visibility(
                          visible:
                              pubevents[index].location != '' ? true : false,
                          child: IconButton(
                            icon: Image.asset('assets/images/placeholder.png'),
                            onPressed: () {
                              MapsLauncher.launchQuery(
                                  pubevents[index].location);
                            },
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editTask(index);
                      },
                      tooltip: 'Edit Event',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        HapticFeedback.vibrate();
                        _deleteTask(index);
                      },
                      tooltip: 'Delete Event',
                    )
                  ],
                )));
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Event item = pubevents.removeAt(oldIndex);
          pubevents.insert(newIndex, item);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 52.0,
          leading: PopupMenuButton<int>(
            color: Color.fromARGB(255, 200, 189, 189),
            icon: const Icon(Icons.menu),
            itemBuilder: (context) => <PopupMenuEntry<int>>[
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  title: Text('Contacts'),
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  title: Text('Songs'),
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: ListTile(
                  title: Text('My Progress'),
                ),
              ),
            ],
            onSelected: (int value) {
              if (value == 1) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ContactsWidget()));
              } else if (value == 2) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SongsWidget()));
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AchievementsWidget()));
              }
            },
          ),
          centerTitle: true,
          title: Text('Libretto'),
        ),
        body: (Scaffold(
          backgroundColor: Color(0xFFEFD3D3),
          appBar: AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      HapticFeedback.vibrate();
                      bool? delchecked = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                content: const Text(
                                    'Are you sure you want to delete all checked events?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ));
                      if (delchecked!) {
                        sqLiteService.deleteChecked();
                        final help2 = await sqLiteService.getLen2() ?? 0;
                        setState(() {
                          pubevents.removeWhere((element) => element.checked);
                          len2 = help2;
                        });
                      }
                    },
                    icon: Image.asset('assets/images/bin.png'),
                    tooltip: 'Delete Checked',
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        pubevents.sort((a, b) {
                          if (a.dateAlarm == null) return 1;
                          if (b.dateAlarm == null) return -1;
                          if (a.dateAlarm == b.dateAlarm) {
                            if (a.alarm == null) return 1;
                            if (b.alarm == null) return -1;
                            return TimeOfDayToDouble(a.alarm!)
                                .compareTo(TimeOfDayToDouble(b.alarm!));
                          }
                          return DateTime.parse(a.dateAlarm.toString())
                              .compareTo(
                                  DateTime.parse(b.dateAlarm.toString()));
                        });
                      });
                    },
                    icon: Image.asset(
                        'assets/images/icons8-up-down-arrow-64.png'),
                    tooltip: 'Sort by Date',
                  ),
                  IconButton(
                    onPressed: () async {
                      HapticFeedback.vibrate();
                      bool? delall = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                content: const Text(
                                    'Are you sure you want to delete ALL events?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ));
                      if (delall!) {
                        sqLiteService.deleteAll();
                        final help2 = await sqLiteService.getLen2() ?? 0;
                        setState(() {
                          pubevents.clear();
                          len2 = help2;
                        });
                      }
                    },
                    icon: Image.asset('assets/images/cross.png'),
                    tooltip: 'Delete All',
                  ),
                ]),
            backgroundColor: Color(0xFFA65656),
            toolbarHeight: 68.0,
          ),
          body: _buildEventList(),
        )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              IconButton(
                iconSize: 50.0,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          CameraScreenWidget(camera: firstCamera)));
                },
                icon: Image.asset('assets/images/camera.png'),
                tooltip: 'Find your Song!',
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: IconButton(
                  iconSize: 50.0,
                  onPressed: _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
                  icon: Image.asset('assets/images/microphone.png'),
                  tooltip: 'Give A Voice Order!',
                ),
              ),
              Text(
                _speechToText.isListening
                    ? '$_lastWords'
                    : _speechEnabled
                        ? ''
                        : '',
              ),
              const Flexible(fit: FlexFit.tight, child: SizedBox()),
              FloatingActionButton(
                onPressed: _addNewEvent,
                tooltip: 'Add Event',
                child: Icon(Icons.add),
              ),
            ],
          ),
        ));
  }
}

class Event {
  int? id;
  String? type1;
  String location;
  TimeOfDay? alarm;
  DateTime? dateAlarm;
  bool checked;

  Event(
      {this.id,
      this.type1,
      required this.location,
      this.alarm,
      this.dateAlarm,
      required this.checked});

  Event.fromMap(Map<String, dynamic> event)
      : id = event['id'],
        type1 = event['type1'],
        location = event['location'],
        alarm = (event['alarm'] != null)
            ? TimeOfDay(
                hour: int.parse(event['alarm'].split(':')[0]),
                minute: int.parse(event['alarm'].split(':')[1]))
            : null,
        dateAlarm = (event['dateAlarm'] != null)
            ? DateTime(
                int.parse(event['dateAlarm'].split(':')[0]),
                int.parse(event['dateAlarm'].split(':')[1]),
                int.parse(event['dateAlarm'].split(':')[2]))
            : null,
        checked = event['checked'] == 1 ? true : false;

  Map<String, dynamic> toMap() {
    final record = {'type1': type1, 'checked': checked ? 1 : 0};

    if (location != null) {
      record.addAll({'location': '$location'});
    }

    if (alarm != null) {
      record.addAll({'alarm': '${alarm!.hour}:${alarm!.minute}'});
    }

    if (dateAlarm != null) {
      record.addAll({
        'dateAlarm': '${dateAlarm!.year}:${dateAlarm!.month}:${dateAlarm!.day}'
      });
    }

    return record;
  }
}

class SQLiteService {
  Future<Database> initDB() async {
    return openDatabase(
      p.join(await getDatabasesPath(), 'libretto.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE events(id INTEGER PRIMARY KEY AUTOINCREMENT, type1 TEXT, location TEXT, alarm TEXT, dateAlarm TEXT, checked INTEGER)');
      },
      version: 1,
    );
  }

  Future<List<Event>> getEvents() async {
    final db = await initDB();

    final List<Map<String, Object?>> queryResult = await db.query('events');

    return queryResult.map((e) => Event.fromMap(e)).toList();
  }

  Future<int?> getLen2() async {
    final db = await initDB();

    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM events'));

    return count;
  }

  Future<int> addEvent(Event event) async {
    final db = await initDB();

    return db.insert('events', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  double TimeOfDayToDouble(TimeOfDay? myTime) {
    if (myTime != null)
      return myTime.hour + myTime.minute / 60;
    else
      return 0;
  }

  Future<int> editEvent(Event event, idx) async {
    final db = await initDB();
    String where = 'id=${event.id}';

    return await db
        .update('events', event.toMap(), where: 'id=?', whereArgs: [idx + 1]);
  }

  Future<void> deleteEvent(final id) async {
    final db = await initDB();

    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateChecked(Event event) async {
    final db = await initDB();

    await db.update('events', {'checked': event.checked ? 1 : 0},
        where: 'id = ?',
        whereArgs: [event.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteChecked() async {
    final db = await initDB();

    await db.delete('events', where: 'checked = 1');
  }

  Future<void> deleteAll() async {
    final db = await initDB();

    await db.delete('events');
  }
}
