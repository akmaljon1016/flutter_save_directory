import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<FileSystemEntity>>? fileList;
  late Color color;

  @override
  void initState() {
    fileList = readFilesFromStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Internal Storage"),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  copyImageToStorage();
                },
                child: Text("Save"),
                color: Colors.orange,
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    fileList = readFilesFromStorage();
                  });
                },
                child: Text("Read"),
                color: Colors.orange,
              ),
              Expanded(
                child: FutureBuilder(
                    future: fileList,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<FileSystemEntity>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              FileSystemEntity? file = snapshot.data?[index];
                              print(file?.path
                                  .split('.')
                                  .last);
                              if (file is File &&
                                  (file.path
                                      .split('.')
                                      .last == 'png' ||
                                      file.path
                                          .split('.')
                                          .last == 'jpg' ||
                                      file.path
                                          .split('.')
                                          .last == 'jpeg')) {
                                return Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    height: 50,
                                    color: Colors.deepOrange,
                                    margin: EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.file(file),
                                        MaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              file.deleteSync();
                                            });
                                          },
                                          child: Icon(Icons.delete),
                                        )
                                      ],
                                    ));
                              } else {
                                return SizedBox();
                              }
                            });
                      }
                      else {
                        return CircularProgressIndicator();
                      }
                    }),
              )
            ],
          ),
        ));
  }


  Future<void> copyImageToStorage() async {
    // Pick image from the gallery
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Get the directory for storing files
    Directory directory = await getApplicationDocumentsDirectory();
    String fileName = pickedFile.path
        .split('/')
        .last;
    print("Picked File path:${pickedFile.path}");
    String filePath = '${directory.path}/$fileName';

    // Copy the image file
    File originalFile = File(pickedFile.path);
    File newFile = await originalFile.copy(filePath);

    print('Image copied to: ${newFile.path}');
  }

  Future<List<FileSystemEntity>> readFilesFromStorage() async {
    // Get the directory for storing files
    Directory directory = await getApplicationDocumentsDirectory();

    // List files in the directory
    List<FileSystemEntity> fileList = directory.listSync();
    //
    // for (FileSystemEntity file in fileList) {
    //   if (file is File) {
    //     String fileName = file.path.split('/').last;
    //     // String fileContent = await file.readAsString();
    //     // print('File: ${file.path}');
    //   }
    // }
    return fileList;
  }
}
