import 'package:flutter/material.dart';
import 'main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_form_builder/flutter_form_builder.dart' as frm;
import 'achievements.dart';
import "editEvent.dart";
import 'songs.dart';

String? type1;

class AddNewEvent extends StatefulWidget {
  const AddNewEvent({Key? key}) : super(key: key);

  @override
  _AddNewEventState createState() => _AddNewEventState();
}

class _AddNewEventState extends State<AddNewEvent> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  TimeOfDay? _alarmTime;
  DateTime? _alarmDate;
  bool _visibleAlarmTime = false;
  bool _visibleAlarmDate = false;
  bool _visibleVal = false;

  void _showTime() async {
    final TimeOfDay? result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (result != null) {
      setState(() {
        _alarmTime = result;
        _visibleAlarmTime = true;
      });
    }
  }

  void _showDate() async {
    final DateTime? result = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2042, 1, 1));

    if (result != null) {
      setState(() {
        _alarmDate = result;
        _visibleAlarmDate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Libretto'),
      ),
      body: Scaffold(
        backgroundColor: Color(0xFFEFD3D3),
        appBar: AppBar(
          centerTitle: true,
          title: Text('Add A New Event'),
          backgroundColor: Color(0xFFA65656),
          toolbarHeight: 68.0,
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Type: ',
                      style: TextStyle(fontSize: 18),
                    ),
                    RadioListTile(
                      title: Text("Rehearsal"),
                      value: "Rehearsal",
                      groupValue: type1,
                      onChanged: (value) {
                        setState(() {
                          type1 = value.toString();
                          _visibleVal = false;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text("Concert"),
                      value: "Concert",
                      groupValue: type1,
                      onChanged: (value) {
                        setState(() {
                          type1 = value.toString();
                          _visibleVal = false;
                        });
                      },
                    ),
                    Visibility(
                      visible: _visibleVal,
                      child: Text('Type of event cannot be empty!',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.red)),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date : ',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: _showDate,
                      icon: Image.asset('assets/images/icons8-calendar-50.png'),
                      tooltip: 'Pick the Date',
                    ),
                    Visibility(
                        visible: _visibleAlarmDate,
                        child: Text(_alarmDate != null
                            ? intl.DateFormat.yMMMd()
                                .format(_alarmDate ?? DateTime.now())
                            : '')),
                    Visibility(
                        visible: _visibleAlarmDate,
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                _alarmDate = null;
                                _visibleAlarmDate = false;
                              });
                            },
                            icon: const Icon(Icons.cancel))),
                    const Flexible(fit: FlexFit.tight, child: SizedBox()),
                    Text(
                      'Time : ',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: _showTime,
                      icon: Image.asset(
                          'assets/images/icons8-square-clock-50.png'),
                      tooltip: 'Pick the Time',
                    ),
                    Visibility(
                        visible: _visibleAlarmTime,
                        child: Text(_alarmTime != null
                            ? _alarmTime!.format(context)
                            : '')),
                    Visibility(
                        visible: _visibleAlarmTime,
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                _alarmTime = null;
                                _visibleAlarmTime = false;
                              });
                            },
                            icon: const Icon(Icons.cancel))),
                  ],
                ),
              ),
              Divider(
                thickness: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Location : ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Location',
                          border: OutlineInputBorder(borderSide: BorderSide())),
                      controller: _locationController,
                    ),
                    SizedBox(
                      height: 100, //<-- SEE HERE
                    ),
                  ],
                ),
              ),
            ],
          ),
        ))),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: IconButton(
                  iconSize: 20.0,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset('assets/images/cross.png'),
                  tooltip: 'Cancel',
                ),
              ),
              IconButton(
                iconSize: 33.0,
                onPressed: () {
                  if (type1 != null) {
                    _visibleVal = false;
                    final event = Event(
                        type1: type1,
                        location: _locationController.text,
                        alarm: _alarmTime,
                        dateAlarm: _alarmDate,
                        checked: false);
                    if ((((len * 0.3) + ((len2 + 1) * 0.7)) / 10) >= 1.0) {
                      len = 0;
                      len2 = 0;
                      percentage = 0;
                      counter++;
                    }
                    Navigator.pop(context, event);
                  } else {
                    setState(() {
                      _visibleVal = true;
                    });
                  }
                },
                icon: Image.asset('assets/images/icons8-done-144.png'),
                tooltip: 'Add the Task!',
              ),
            ],
          ),
        ),
        //   ),
      ),
    );
  }
}
