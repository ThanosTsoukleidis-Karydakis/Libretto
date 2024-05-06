import 'dart:async';
import "editSong.dart";
import 'package:flutter/material.dart';
import 'addNewSong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import "achievements.dart";
import "main.dart";

import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:file/file.dart';
import 'package:flutter/services.dart';

int len = 0;
List<Song> pubsongs = <Song>[];

class SongsWidget extends StatefulWidget {
  const SongsWidget({Key? key}) : super(key: key);

  @override
  _SongsWidgetState createState() => _SongsWidgetState();
}

class _SongsWidgetState extends State<SongsWidget> {
  late SQLiteService2 sqLiteService1;

  void _openFile(String file) {
    OpenFile.open(file);
  }

  var songs;
  @override
  void initState() {
    super.initState();

    sqLiteService1 = SQLiteService2();

    sqLiteService1.initDB().whenComplete(() async {
      final songs = await sqLiteService1.getSongs();

      setState(() {
        pubsongs = songs;
        len = currlen;
      });
    });
  }

  void _addNewSong() async {
    Song? newSong = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddNewSong()));
    if (newSong != null) {
      final newId = await sqLiteService1.addSong(newSong);
      newSong.id = newId;

      pubsongs.add(newSong);
      setState(() {
        len++;
      });
    }
  }

  void _deleteSong(int idx) async {
    bool? delSong = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: const Text('Delete Song?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),

                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yes')),
              ],
            ));

    if (delSong!) {
      final song = pubsongs.elementAt(idx);

      try {
        int? test = song.id;

        sqLiteService1.deleteSong(test);

        pubsongs.removeAt(idx);
      } catch (err) {
        debugPrint('Could not delete song $song: $err');
      }

      setState(() {
        len--;
      });
    }
  }

  void _editSong(int idx) async {
    Song? newSong = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => editSong(id: idx)));
    if (newSong != null) {
      newSong.id = idx;
      pubsongs[idx] = newSong;
      final newId = await sqLiteService1.editSong(newSong, idx);
      setState(() {});
    }
  }

  Widget _buildSongList() {
    return ReorderableListView.builder(
       padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
      itemCount: pubsongs.length,
      itemBuilder: (context, index) {
        return  Container(
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
          ) ,
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Color(0xff633b48)), 
              borderRadius: BorderRadius.circular(20),
            ), 
            key: Key('$index'),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            title: Row(children: <Widget>[
              new Text(pubsongs[index].title),
              Visibility(
                  visible: pubsongs[index].pdf_link != '' ? true : false,
                  child: IconButton(
                    icon: Image.asset('assets/images/icons8-import-pdf-50.png'),
                    onPressed: () {
                      _openFile(pubsongs[index].pdf_link);
                    },
                    tooltip: pubsongs[index].pdf_link,
                  )),
            ]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editSong(index);
                },
                tooltip: 'Delete Event',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  HapticFeedback.vibrate();
                  _deleteSong(index);
                },
                tooltip: 'Delete Contact',
              ),
            ])));
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Song item = pubsongs.removeAt(oldIndex);
          pubsongs.insert(newIndex, item);
        });
      },
    );
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
          title: Text('Songs'),

          backgroundColor: Color(0xFFA65656),
          toolbarHeight: 68.0,
        ),
        body: _buildSongList(),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FloatingActionButton(
          onPressed: _addNewSong,
          tooltip: 'Add New Song',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class Song {
  int? id;
  String title;
  String pdf_link;

  Song({this.id, required this.title, required this.pdf_link});

  Song.fromMap(Map<String, dynamic> song)
      : id = song['id'],
        pdf_link = song['pdf_link'],
        title = song['title'];

  Map<String, dynamic> toMap() {
    final record = {'title': title, 'pdf_link': pdf_link};

    return record;
  }
}

class SQLiteService2 {
  Future<Database> initDB() async {
    return openDatabase(
      p.join(await getDatabasesPath(), 'libretto_songs.db'),

      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE songs(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, pdf_link TEXT)');
      },
      version: 1,
    );
  }

  Future<List<Song>> getSongs() async {
    final db = await initDB();

    final List<Map<String, Object?>> queryResult = await db.query('songs');

    return queryResult.map((e) => Song.fromMap(e)).toList();
  }

  Future<int> editSong(Song song, idx) async {
    final db = await initDB();
    return await db
        .update('songs', song.toMap(), where: 'id=?', whereArgs: [idx + 1]);
  }

  Future<int> addSong(Song song) async {
    final db = await initDB();

    return db.insert('songs', song.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSong(final id) async {
    final db = await initDB();
    await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }
}
