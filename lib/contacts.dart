import 'dart:async';
import 'package:flutter/material.dart';
import 'addNewContact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import "editContact.dart";
import 'package:flutter/services.dart';

List<Contact> pubcontacts = <Contact>[];

class ContactsWidget extends StatefulWidget {
  const ContactsWidget({Key? key}) : super(key: key);

  @override
  _ContactsWidgetState createState() => _ContactsWidgetState();
}

class _ContactsWidgetState extends State<ContactsWidget> {
  late SQLiteService3 sqLiteService;

  @override
  void initState() {
    super.initState();
    sqLiteService = SQLiteService3();
    sqLiteService.initDB().whenComplete(() async {
      final contacts = await sqLiteService.getContacts();

      setState(() {
        pubcontacts = contacts;
      });
    });
  }

  void _addNewContact() async {
    Contact? newContact = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddNewContact()));

    if (newContact != null) {
      final newId = await sqLiteService.addEvent(newContact);
      newContact.id = newId;

      pubcontacts.add(newContact);
      setState(() {});
    }
  }

  void _deleteContact(int idx) async {
    bool? delTask = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: const Text('Delete Contact?'),
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
      final contact = pubcontacts.elementAt(idx);

      try {
        sqLiteService.deleteContact(contact.id);

        pubcontacts.removeAt(idx);
      } catch (err) {
        debugPrint('Could not delete event $contact: $err');
      }

      setState(() {});
    }
  }

  void _editContact(int idx) async {
    Contact? newContact = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => editContact(id: idx)));
    if (newContact != null) {
      newContact.id = idx;
      pubcontacts[idx] = newContact;
      final newId = await sqLiteService.editContact(newContact, idx);
      setState(() {});
    }
  }

  Widget _buildContactList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
      itemCount: pubcontacts.length,
      itemBuilder: (context, index) {
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
          ) ,
          child:  ListTile(
           shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Color(0xff633b48)), 
              borderRadius: BorderRadius.circular(20),
            ), 
            key: Key('$index'),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            title: Row(children: <Widget>[
              new Text(pubcontacts[index].name),
              pubcontacts[index].role != '' ? Text(' ,  ') : Text(''),
              Text(
                pubcontacts[index].role ?? '',
              )
            ]),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        pubcontacts[index].phone,
                      ),
                      IconButton(
                        icon: Image.asset(
                            'assets/images/old-telephone-ringing.png'),
                        onPressed: () {
                          launchUrl(Uri.parse(
                              'tel:+${pubcontacts[index].phone.toString()}'));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, 
              children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editContact(index);
                },
                tooltip: 'Delete Contact',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  HapticFeedback.vibrate();
                  _deleteContact(index);
                },
                tooltip: 'Delete Contact',
              )
            ])));
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Contact item = pubcontacts.removeAt(oldIndex);
          pubcontacts.insert(newIndex, item);
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
          title: Text('Contacts'),

          backgroundColor: Color(0xFFA65656),
          toolbarHeight: 68.0,
        ),
        body: _buildContactList(),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FloatingActionButton(
          onPressed: _addNewContact,
          tooltip: 'Add New Contact',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class Contact {
  int? id;
  String name;
  String phone;
  String? role;

  Contact({this.id, required this.name, required this.phone, this.role});

  Contact.fromMap(Map<String, dynamic> contact)
      : id = contact['id'],
        name = contact['name'],
        phone = contact['phone'],
        role = contact['role'];

  Map<String, dynamic> toMap() {
    final record = {'name': name, 'phone': phone};

    if (role != null) {
      record.addAll({'role': '$role'});
    }

    return record;
  }
}

class SQLiteService3 {
  Future<Database> initDB() async {
    return openDatabase(
      p.join(await getDatabasesPath(), 'libretto_contacts.db'),

      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, role TEXT)');
      },
      version: 1,
    );
  }

  Future<int> editContact(Contact contact, idx) async {
    final db = await initDB();
    return await db.update('contacts', contact.toMap(),
        where: 'id=?', whereArgs: [idx + 1]);
  }

  Future<List<Contact>> getContacts() async {
    final db = await initDB();

    final List<Map<String, Object?>> queryResult = await db.query('contacts');

    return queryResult.map((e) => Contact.fromMap(e)).toList();
  }

  Future<int> addEvent(Contact contact) async {
    final db = await initDB();
    return db.insert('contacts', contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteContact(final id) async {
    final db = await initDB();
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
