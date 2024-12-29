import 'package:board/Board.dart';
import 'package:board/creatBoardScreen.dart';
import 'package:board/editBoard.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final dio = Dio();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentsController = TextEditingController();
  List<Board> boards = [];
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadBord();
  } 

  Future<void> _loadBord() async {
    try{
      final data = await getBoard();
      setState(() {
        boards = data;
      });
    } catch(e) {
      print('Error loading Board infomation: $e');
    }
  }
  
  Future<List<Board>> getBoard() async{
    try {
      String? accesstoken = await storage.read(key: 'access_token');
      if (accesstoken == null) {
        throw Exception('No accesstoken found');
      }
      final response = await dio.get(
        'https://api.labyrinth30-tech.link/board',
        options: Options(
        headers: {'Authorization': 'Bearer $accesstoken'},
        ),
      );

      if (response.statusCode== 200){
      final List<dynamic> jsonData = response.data;
      return jsonData.map((board) => Board.fromJson(board)).toList(); 
      } else {
        throw Exception('Fail to load data');
      }
      } on DioException catch (e) {
        throw Exception('Fail to load data: ${e.response?.data['message'] ?? e.message}');
      }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'board',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Boards'),
          actions: [
            IconButton(
              onPressed:() async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const creatboardScreen()),
                );
                await _loadBord();
              }, 
              icon: Icon(Icons.add))
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 10,),
                ListView.builder(
                    shrinkWrap: true,
                    primary: false, 
                    itemCount: boards.length, 
                    itemBuilder: (_, index) {
                      final board = boards[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(board.title, style: TextStyle(fontSize: 23),),
                          subtitle: Text(board.contents),
                          onTap:() async{
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => editboardScreen(id: board.id))
                            );
                            await _loadBord();
                            },
                        ),
                      );
                    },
                  ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}