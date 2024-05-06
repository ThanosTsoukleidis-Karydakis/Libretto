import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'songs.dart';
import 'main.dart';
import 'achievements.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math';
import 'package:info_popup/info_popup.dart';

String? type;
var my_pdf = '';

class AddNewSong extends StatefulWidget {
  const AddNewSong({Key? key}) : super(key: key);

  @override
  _AddNewSongState createState() => _AddNewSongState();
}

class _AddNewSongState extends State<AddNewSong> {
  final _formKey3 = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';
  double textSize = 20;
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _image = [];

  File? image;
  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() => this.image = imageTemp);
    GallerySaver.saveImage(image.path);
  }

  getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image.add(File(pickedFile.path));
      } else {
        print('No image selected');
      }
    });
  }

  createPDF() async {
    for (var img in _image) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.Center(child: pw.Image(image));
          }));
    }
  }

  savePDF() async {
    try {
      var rng = Random().nextInt(10000);
      final dir = await getExternalStorageDirectory();
      final file = File('${dir?.path}/MusicScore${rng}.pdf');

      await file.writeAsBytes(await pdf.save());
      my_pdf = '${dir?.path}/MusicScore${rng}.pdf';
    } catch (e) {}
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
          title: Text('Add A New Song'),
          backgroundColor: Color(0xFFA65656),
          toolbarHeight: 68.0,
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Form(
          key: _formKey3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Title : ',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Title',
                            border:
                                OutlineInputBorder(borderSide: BorderSide())),
                        controller: _titleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title cannot be empty!';
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
                child: Row(
                  children: [
                    Text(
                      'Music Score : ',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () {
                        pickImage();
                      },
                      icon: Image.asset('assets/images/camera.png'),
                      tooltip: 'Post a photo of the music score!',
                    ),
                    IconButton(
                      icon:
                          Image.asset('assets/images/icons8-add-image-48.png'),
                      onPressed: getImageFromGallery,
                    ),
                    IconButton(
                      onPressed: () {
                        createPDF();
                        savePDF();
                      },
                      icon:
                          Image.asset('assets/images/icons8-import-pdf-50.png'),
                      tooltip: 'Create PDF',
                    ),
                  ],
                ),
              ),
              InfoPopupWidget(
                customContent: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: const <Widget>[
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'To add a file to the song follow these instructions: Firstly, take all photographs you need to take using the camera button. Then start adding photos from your gallery one by one to the file using the second button. Finally click the third button to create the PDF file',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                arrowTheme: const InfoPopupArrowTheme(
                  color: Colors.pink,
                  arrowDirection: ArrowDirection.up,
                ),
                dismissTriggerBehavior: PopupDismissTriggerBehavior.onTapArea,
                areaBackgroundColor: Colors.transparent,
                indicatorOffset: Offset.zero,
                contentOffset: Offset.zero,
                onControllerCreated: (controller) {
                  print('Info Popup Controller Created');
                },
                onAreaPressed: (InfoPopupController controller) {
                  print('Area Pressed');
                },
                infoPopupDismissed: () {
                  print('Info Popup Dismissed');
                },
                onLayoutMounted: (Size size) {
                  print('Info Popup Layout Mounted');
                },
                child: Icon(
                  Icons.info,
                  color: Colors.pink,
                ),
              ),
              SizedBox(
                height: 140, //<-- SEE HERE
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
                  if (_formKey3.currentState!.validate()) {
                    final contact =
                        Song(title: _titleController.text, pdf_link: my_pdf);
                    my_pdf = '';
                    if (((((len + 1) * 0.3) + (len2 * 0.7)) / 10) >= 1.0) {
                      len = 0;
                      len2 = 0;
                      percentage = 0;
                      counter++;
                    }
                    Navigator.pop(context, contact);
                  }
                },
                icon: Image.asset('assets/images/icons8-done-144.png'),
                tooltip: 'Add the Song!',
              ),
            ],
          ),
        ),
        //   ),
      ),
    );
  }
}
