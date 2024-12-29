import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class creatboardScreen extends StatefulWidget {
  const creatboardScreen({super.key});

  @override
  State<creatboardScreen> createState() => _creatboardScreenState();
}

class _creatboardScreenState extends State<creatboardScreen> {
  final dio = Dio();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentsController = TextEditingController();

  Future<void> addPost() async{
    if (_formKey.currentState!.validate()) {
      final title = titleController.text;
      final contents = contentsController.text;
      final viewCount = 0;

      final storage = FlutterSecureStorage();

      try {
      String? accesstoken = await storage.read(key: 'access_token');
      if (accesstoken == null) {
        throw Exception('No accesstoken found');
      }
      await dio.post(
        'https://api.labyrinth30-tech.link/board',
        data: {'title': title, 'contents': contents, 'viewCount': viewCount},
        options: Options(headers: {'Authorization': 'Bearer $accesstoken'}),
      );
      } on DioException catch (e) {
        throw Exception(
          'Fail to create board: ${e.response?.data['message'] ?? e.message}'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'creatboard',
      home: Scaffold(
        appBar: AppBar(
          leading:
            IconButton(
              onPressed: () {
                  Navigator.pop(context);},
              icon: Icon(Icons.arrow_back_ios)),
          title: const Text('Creat Board'),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title', style: TextStyle(fontSize: 20),),
                  TextFormField(
                    controller: titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20,),
                  const Text('Contents', style: TextStyle(fontSize: 20),),
                  TextFormField(
                    maxLines: null,
                    controller: contentsController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Contents';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30,),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  await addPost();
                  Navigator.pop(context);
                }, child: const Text('Creat'),), 
              ]
            ),
          ),
        )
      ),
    );
  }
}