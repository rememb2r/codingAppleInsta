import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import './style.dart' as style;
import "package:image_picker/image_picker.dart";
import "dart:io";
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Store1(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: style.themeData,
        initialRoute: '/',
        routes: {
          '/': (context) => MyApp(),
        },
      ),
    ),
  );
}

class User {
  var name;
  var follower;

  User({
    this.name,
    this.follower,
  });

  User.fromJson(Map json)
      : name = json['name'],
        follower = json['follower'];
}

class Store1 extends ChangeNotifier {
  var name = 'john kim';
  List<User> a = [];

  getFollowerByName(var name) {
    int i = a.indexWhere((item) => item.name == name);
    if (i != -1) {
      print("Found");
      notifyListeners();
      return a[i].follower;
    } else {
      print("Not Found");
      notifyListeners();
      return 0;
    }
  }

  addObjectAndRevertFollower(var name) {
    print('request name:' + name);
    if (a.length == 0) {
      User dummy = User(name: 'yuna kim', follower: 999);
      a.add(dummy);
    }
    print("size:" + a.length.toString());
    bool toBeChangeList = false;
    for (User object in a) {
      print('searched name:' + object.name);
      if (object.name == name) {
        print('case0');
        object.follower = object.follower == 0 ? 1 : 0;

        toBeChangeList = false;
      } else {
        print('case1');
        toBeChangeList = true;
        //a.add(d);
        //print(a);
      }
    }
    if (toBeChangeList == true) {
      User d = User(name: name, follower: 1);
      a.add(d);
      for (User object in a) {
        print("name: " + object.name);
      }
    }
    notifyListeners();
  }

  changeName(var a) {
    name = a;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var userImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Padding(
          padding: const EdgeInsets.only(top: 6),
          child:
              Image.asset('assets/insta_appbar_logo.png', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: Colors.black, size: 35.0),
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => Upload(userImage: userImage)),
              );
            },
          ),
          SizedBox(width: 5),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: tab,
        onTap: (index) {
          setState(() {
            tab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              activeIcon: Icon(Icons.home_rounded, color: Colors.black),
              icon: Icon(Icons.home_outlined),
              label: ' '),
          BottomNavigationBarItem(
              activeIcon: Icon(Icons.shopping_bag_rounded, color: Colors.black),
              icon: Icon(
                Icons.shopping_bag_outlined,
              ),
              label: ' '),
        ],
      ),
      body: IndexedStack(
        index: tab,
        children: [
          FirstHomeTab(),
          SecondHomeTab(),
        ],
      ),
    );
  }
}

class Upload extends StatefulWidget {
  const Upload({Key? key, this.userImage, this.addData}) : super(key: key);
  final userImage;
  final addData;

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  var _writerFieldController;
  var strId;
  var strContents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SizedBox(
            height: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(widget.userImage, height: 400),
                Icon(
                  Icons.abc_outlined,
                  color: Colors.black,
                ),
                Row(
                  children: [
                    Text('작성자',
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  ],
                ),
                TextFormField(onChanged: (String val) {
                  strId = val;
                }),
                TextFormField(onChanged: (val) {
                  strContents = val;
                }),
                IconButton(
                  icon: Icon(Icons.post_add),
                  onPressed: () {
                    singlePosting inputToJson = singlePosting(
                        4,
                        'na',
                        widget.userImage,
                        0,
                        DateTime.now().toString(),
                        strContents,
                        false,
                        strId);
                    print(inputToJson.toJson());
                    widget.addData(inputToJson.toJson());
                    //addData(inputToJson.toJson());
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class singlePosting {
  final int id;
  final String img;
  final File file;
  final int likes;
  final String date;
  final String contents;
  final bool liked;
  final String user;

  singlePosting(this.id, this.img, this.file, this.likes, this.date,
      this.contents, this.liked, this.user);

  singlePosting.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        img = json['img'],
        file = json['file'],
        likes = json['likes'],
        date = json['date'],
        contents = json['content'],
        liked = json['liked'],
        user = json['user'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': img,
        'file': file,
        'likes': likes,
        'date': date,
        'content': contents,
        'liked': liked,
        'user': user,
      };
}

class SecondHomeTab extends StatelessWidget {
  const SecondHomeTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('샵페이지');
  }
}

class FirstHomeTab extends StatefulWidget {
  const FirstHomeTab({
    Key? key,
  }) : super(key: key);

  @override
  State<FirstHomeTab> createState() => _FirstHomeTabState();
}

class _FirstHomeTabState extends State<FirstHomeTab> {
  var scroll = ScrollController();
  var dataReceived = [];
  var isRequestMoredata = false;
  var userImage;
  @override
  void initState() {
    super.initState();

    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent &&
          isRequestMoredata == false) {
        print('같음');
        isRequestMoredata = true;
        getmoreData();
      }
    });
    receiveData();
    saveData();
  }

  saveData() async {
    var storage = await SharedPreferences.getInstance();

    var map = [
      {'age': 20, 'name': 'john'},
      {'age': 21, 'name': 'park'},
    ];
    storage.setString('name', jsonEncode(map));
    var result = storage.getString('name') ?? '없는데요';
    var map2 = jsonDecode(result);
    print(map2.runtimeType);
    var a = map2.firstWhere((item) => item['age'] == 20);
    print(a['name']);
  }

  addData(dynamic a) {
    setState(() {
      dataReceived.add(a);
    });
    print(dataReceived.toString());
  }

  getmoreData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    print(result2);
    setState(() {
      dataReceived.add(result2);
    });
  }

  receiveData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result2 = jsonDecode(result.body);

    setState(() {
      dataReceived = result2;
    });
  }

  Future<List<dynamic>> getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result2 = jsonDecode(result.body);
    print(result2);
    return result2;
  }

  var styleLike =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14);
  var styleText1 = TextStyle(color: Colors.black, fontSize: 14);
  @override
  Widget build(BuildContext context) {
    if (dataReceived.isNotEmpty) {
      return Stack(
        children: [
          ListView.builder(
              itemCount: dataReceived.length,
              controller: scroll,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Builder(
                        builder: (context) {
                          if (dataReceived[index]['image'] != 'na') {
                            return Image.network(dataReceived[index]['image']);
                          } else {
                            return Image.file(
                              dataReceived[index]['file'],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("     좋아요 " + dataReceived[index]['likes'].toString(),
                        style: styleLike),
                    GestureDetector(
                      child: Text("     글쓴이 " + dataReceived[index]['user'],
                          style: styleText1),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (c, a1, a2) {
                                context
                                    .read<Store1>()
                                    .changeName(dataReceived[index]['user']);
                                return showProfile();
                              },
                              transitionsBuilder: (context, a1, a2, child) =>
                                  SlideTransition(
                                    position: Tween(
                                      begin: Offset(1.0, 1.0),
                                      end: Offset(0.0, 0.0),
                                    ).animate(a1),
                                    child: child,
                                  ),
                              transitionDuration: Duration(milliseconds: 200)),
                        );
                      },
                    ),
                    Text("     글내용 " + dataReceived[index]['content'],
                        style: styleText1),
                  ],
                );
              }),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    userImage = File(image.path);
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => Upload(
                        userImage: userImage,
                        addData: addData,
                      ),
                    ),
                  );
                }
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class showProfile extends StatelessWidget {
  const showProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<Store1>().name)),
      body: Column(
        children: [
          Text('프로필 페이지'),
          Row(
            children: [
              Text(context.watch<Store1>().name),
              ElevatedButton(
                onPressed: () {
                  // context
                  //     .read<Store1>()
                  //     .addObjectAndRevertFollower(context.watch<Store1>().name);
                  var name = context.read<Store1>().name;
                  Provider.of<Store1>(context, listen: false)
                      .addObjectAndRevertFollower(name);
                },
                child: Text('팔로우'),
              ),
              Text('팔로워:' +
                  context
                      .read<Store1>()
                      .getFollowerByName(context.watch<Store1>().name)
                      .toString()),
            ],
          ),
        ],
      ),
    );
  }
}
