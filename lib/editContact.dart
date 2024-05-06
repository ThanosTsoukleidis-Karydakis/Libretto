import 'package:flutter/material.dart';
import 'contacts.dart';

class editContact extends StatefulWidget {
  int id;
  editContact({Key? key, required this.id}) : super(key: key);

  @override
  _AddNewContactState createState() => _AddNewContactState(id);
}

class _AddNewContactState extends State<editContact> {
  int id;
  String? ID;
  _AddNewContactState(this.id) : ID = id.toString();
  final _formKey2 = GlobalKey<FormState>();
  var _nameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: pubcontacts[id].name);
    _phoneController = TextEditingController(text: pubcontacts[id].phone);
    _roleController = TextEditingController(text: pubcontacts[id].role);
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
          title: Text('Edit Contact for ${pubcontacts[id].name}'),
          backgroundColor: Color(0xFFA65656),
          toolbarHeight: 68.0,
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Form(
          key: _formKey2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Name : ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Name',
                            border:
                                OutlineInputBorder(borderSide: BorderSide())),
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name cannot be empty!';
                          }
                          return null;
                        }),
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
                        'Phone Number : ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            border:
                                OutlineInputBorder(borderSide: BorderSide())),
                        controller: _phoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone Number cannot be empty!';
                          }
                          return null;
                        }),
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
                        'Role : ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          hintText: 'Role',
                          border: OutlineInputBorder(borderSide: BorderSide())),
                      controller: _roleController,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100, //<-- SEE HERE
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
                  if (_formKey2.currentState!.validate()) {
                    final contact = Contact(
                        name: _nameController.text,
                        phone: _phoneController.text,
                        role: _roleController.text);
                    Navigator.pop(context, contact);
                  }
                },
                icon: Image.asset('assets/images/icons8-done-144.png'),
                tooltip: 'Add the Contact!',
              ),
            ],
          ),
        ),
        //   ),
      ),
    );
  }
}
