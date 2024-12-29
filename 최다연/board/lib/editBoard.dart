import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class editboardScreen extends StatefulWidget {
  final int id;

  const editboardScreen({super.key, required this.id});

  @override
  State<editboardScreen> createState() => _editboardScreenState();
}

class _editboardScreenState extends State<editboardScreen> {
  final dio = Dio();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentsController = TextEditingController();
  final storage = FlutterSecureStorage();

    @override
  void initState() {
    super.initState();
    _loadBoard();
  }

  // 게시물 데이터 불러오기
  Future<void> _loadBoard() async {
    final storage = FlutterSecureStorage();
    try {
      String? accesstoken = await storage.read(key: 'access_token');
      if (accesstoken == null) {
        throw Exception('No accesstoken found');
      }
      final response = await dio.get(
        'https://api.labyrinth30-tech.link/board/${widget.id}',
        options: Options(headers: {'Authorization': 'Bearer $accesstoken'}),
      );
      if (response.statusCode == 200) {
        final boardData = response.data;
        titleController.text = boardData['title'];
        contentsController.text = boardData['contents'];
      } else {
        throw Exception('Failed to load board');
      }
    } catch (e) {
      print('Error loading board data: $e');
    }
  }

  Future<void> editPost() async{
    final title = titleController.text;
    final contents = contentsController.text;
    final viewCount = 0;

    try {
      String? accesstoken = await storage.read(key: 'access_token');
      if (accesstoken == null) {
        throw Exception('No accesstoken found');
      }
      await dio.patch(
        'https://api.labyrinth30-tech.link/board/${widget.id}',
        data: {'title': title, 'contents': contents, 'viewCount': viewCount},
        options: Options(headers: {'Authorization': 'Bearer $accesstoken'}),
      );
    } on DioException catch (e) {
        throw Exception(
          'Fail to create board: ${e.response?.data['message'] ?? e.message}'
        );
    }
  }

  Future<void> deletePost() async{
    try {
      String? accesstoken = await storage.read(key: 'access_token');
      if (accesstoken == null) {
        throw Exception('No accesstoken found');
      }
      await dio.delete(
        'https://api.labyrinth30-tech.link/board/${widget.id}',
        options: Options(headers: {'Authorization': 'Bearer $accesstoken'}),
      );
    } on DioException catch (e) {
        throw Exception(
          'Fail to create board: ${e.response?.data['message'] ?? e.message}'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'editboard',
      home: Scaffold(
        appBar: AppBar(
          leading:
            IconButton(
              onPressed: () {
                  Navigator.pop(context);},
              icon: Icon(Icons.arrow_back_ios)),
          title: const Text('Edit Board'),
          actions: [
            IconButton(
              onPressed:() async {
                    deletePost();
                    Navigator.of(context).pop();
                  },
              icon: Icon(Icons.delete))
          ],
        ),
        body: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [
                Column(
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
                    await editPost();
                    await _loadBoard();
                    Navigator.of(context).pop();
                  } ,child: const Text('Edit'),
              )],
            ),
          ),
        )
      ),
    );
  }
}