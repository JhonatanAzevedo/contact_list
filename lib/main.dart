import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'model/contact_model.dart';
import 'repositories/contact_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController nameController = TextEditingController(text: "");
  ContactRepository contactRepository = ContactRepository();
  List<ContactModel> contacts = [];
  XFile? photo;

  @override
  void initState() {
    super.initState();
    showContacts();
  }

  void showContacts() async {
    contacts = await contactRepository.getContacts();
    setState(() {});
  }

  cropImage(XFile imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      photo = XFile(croppedFile.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Contatos"),
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: () async {
                showModal(context);
              },
              child: const Center(child: Text("Adicionar Contatos")),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  var contact = contacts[index];
                  return Dismissible(
                    onDismissed: (DismissDirection dismissDirection) async {
                      await contactRepository.removeContact(contact.id.toString());
                    },
                    key: Key(contact.id.toString()),
                    child: Column(
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.file(
                              File(contact.path),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(contact.name),
                          titleTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        const Divider(
                          thickness: 1,
                          color: Colors.black,
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  showModal(BuildContext context) async {
    bool modalResult = await showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 50,
                child: TextField(
                  controller: nameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    hintText: 'Digiti o nome',
                    contentPadding: EdgeInsets.only(top: 0, left: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: nameController.text.isNotEmpty,
              child: const Text(
                'Adicione uma Imagem de contato',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Visibility(
              visible: nameController.text.isNotEmpty,
              child: ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    String path = (await path_provider.getApplicationDocumentsDirectory()).path;
                    String name = basename(photo!.path);
                    await photo!.saveTo("$path/$name");
                    await GallerySaver.saveImage(photo!.path);
            
                    cropImage(photo!);
                  }
                },
              ),
            ),
            Visibility(
              visible: nameController.text.isNotEmpty,
              child: ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Galeria"),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  photo = await picker.pickImage(source: ImageSource.gallery);
                  cropImage(photo!);
                },
              ),
            ),
            Visibility(
              visible: nameController.text.isNotEmpty,
              child: ElevatedButton(
                child: const Text('Adicionar contato'),
                onPressed: () async {
                  await contactRepository.addContact(
                    ContactModel(
                      id: 0,
                      name: nameController.text,
                      path: photo!.path,
                    ),
                  );
                  Navigator.of(context).pop(true);
                },
              ),
            )
          ],
        );
      },
    );

    if (modalResult == true) {
      nameController.clear();
      photo = XFile('');
      showContacts();
    }
  }
}




