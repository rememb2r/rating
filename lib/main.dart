// ignore_for_file: unnecessary_string_escapes, unnecessary_import

import 'dart:math';

import 'package:bucket_list_with_firebase/auth_service.dart';
import 'package:bucket_list_with_firebase/bucket_service.dart';
import 'package:bucket_list_with_firebase/keyword_threads_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => BucketService()),
        ChangeNotifierProvider(create: (context) => KeywordThreadsService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      theme: ThemeData(backgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => MainSearchPage(),
        '/second': (context) => HomePage(),
        '/write': (context) => WritePage(),
        '/create': (context) => WriteWithCreatePage(),
      },
    );
  }
}

// 게시판 생성
class WriteWithCreatePage extends StatefulWidget {
  const WriteWithCreatePage({Key? key}) : super(key: key);

  @override
  State<WriteWithCreatePage> createState() => _WriteWithCreatePageState();
}

class _WriteWithCreatePageState extends State<WriteWithCreatePage> {
  var nRating = 3.0;
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    //inspect(args);
    PassArgs passArgs;
    passArgs = args! as PassArgs;
    var strId = DateTime.now().toString();

    return Consumer<KeywordThreadsService>(
        builder: (context, keywordThreadsService, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(passArgs.title + '  생성'),
          backgroundColor: Color.fromARGB(255, 54, 136, 43),
          actions: [
            TextButton(
              child: Text(
                '등록',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  Random random = Random();
                  int randomNumber = random.nextInt(90) + 10;
                  // double rating =
                  // randomNumber / 20; // 현재 미구현 기능으로 난수를 별점으로 넣어준다.
                  strId = strId + randomNumber.toString();
                  keywordThreadsService.create(
                      passArgs.title, strId, nRating, textController.text);
                  // keywordThreadsService.createPosting(
                  // textController.text, strId, nRating,
                  // firstPosting: true);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            Column(
              children: [
                Text(nRating.toString(),
                    style: TextStyle(
                      fontSize: 40.0,
                    )),
                Center(
                  child: RatingBar.builder(
                    initialRating: 3,
                    minRating: 0.5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        nRating = rating;
                      });
                    },
                  ),
                ),
                Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    //           maxLines: 10,
                    controller: textController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              style: BorderStyle.solid, color: Colors.yellow)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            style: BorderStyle.solid, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class WritePage extends StatefulWidget {
  const WritePage({Key? key}) : super(key: key);

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  var nRating = 3.0;
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    //inspect(args);
    PassArgs passArgs;
    passArgs = args! as PassArgs;

    return Consumer<KeywordThreadsService>(
        builder: (context, keywordThreadsService, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(passArgs.title + '   평가 남기기'),
          backgroundColor: Color.fromARGB(255, 54, 136, 43),
          actions: [
            TextButton(
              child: Text(
                '등록',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  // Random random = Random();
                  // int randomNumber = random.nextInt(90) + 10;
                  // double rating =
                  // randomNumber / 20; // 현재 미구현 기능으로 난수를 별점으로 넣어준다.
                  keywordThreadsService.createPosting(
                      textController.text, passArgs.kid, nRating);

                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            Column(
              children: [
                Text(nRating.toString(),
                    style: TextStyle(
                      fontSize: 40.0,
                    )),
                Center(
                  child: RatingBar.builder(
                    initialRating: 3,
                    minRating: 0.5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        nRating = rating;
                      });
                    },
                  ),
                ),
                Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    //           maxLines: 10,
                    controller: textController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              style: BorderStyle.solid, color: Colors.yellow)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            style: BorderStyle.solid, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// 로그인 페이지
///
class MainSearchPage extends StatefulWidget {
  const MainSearchPage({Key? key}) : super(key: key);

  @override
  State<MainSearchPage> createState() => _MainSearchPageState();
}

class _MainSearchPageState extends State<MainSearchPage> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<KeywordThreadsService>(
      builder: (context, keywordThreadsService, child) {
        //User? user = authService.currentUser();

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add_to_drive_outlined),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("타이틀"),
                      content: Text("작성하시겠습니까?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [
                                    TextButton(
                                      child: Text("Real OK"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  });
            },
          ),
          appBar:
              AppBar(title: Text(" 실시간 핫 키워드"), backgroundColor: Colors.black),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 현재 유저 로그인 상태
              Visibility(
                visible: false,
                child: Center(
                  child: Text(
                    "환영합니다. 🙂",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36),

              /// 이메일
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 15.0),
                child: TextField(
                  maxLength: 24,
                  controller: searchTextController,
                  decoration: InputDecoration(
                    counterText: "",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear,
                          color: searchTextController.text.isNotEmpty
                              ? Colors.grey
                              : Colors.transparent),
                      onPressed: () {
                        setState(() {
                          searchTextController.clear();
                        });
                      },
                    ),
                    focusColor: Colors.black,
                    hintText: "제목 검색",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3.0),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3.0),
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                  onChanged: (text) {
                    //keywordThreadsService.preProcessing(text);  디버깅 용
                    keywordThreadsService.search(text);
                  },
                ),
              ),

              /// 비밀번호
              Visibility(
                visible: false,
                child: TextField(
                  controller: passwordController,
                  obscureText: false, // 비밀번호 안보이게
                  decoration: InputDecoration(hintText: "비밀번호"),
                ),
              ),
              //SizedBox(height: 6),

              /// 로그인 버튼
              Visibility(
                visible: false,
                child: ElevatedButton(
                  child: Text("검색", style: TextStyle(fontSize: 21)),
                  onPressed: () {
                    // 로그인
                    /*authService.signIn(
                      email: searchTextController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 로그인 성공
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("로그인 성공"),
                        ));
              
                        // HomePage로 이동
                        /* Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );*/
                      },
                      onError: (err) {
                        // 에러 발생
                      },
                    );*/
                  },
                ),
              ),

              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                    future:
                        keywordThreadsService.search(searchTextController.text),
                    builder: (context, snapshot) {
                      final documents = snapshot.data?.docs ?? [];
                      documents.sort((b, a) {
                        var alastUpdatedTime = a.get("lastUpdatedTime");
                        var blastUpdatedTime = b.get("lastUpdatedTime");
                        return alastUpdatedTime.compareTo(blastUpdatedTime);
                      });

                      if (documents.isEmpty) {
                        if (searchTextController.text.isEmpty) {
                          return Text('');
                        } else {
                          return Column(
                            children: [
                              Text(" 결과값이 없습니다."),
                              Text(searchTextController.text),
                              Text("게시판을 생성하시겠습니까?"),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                  ),
                                  onPressed: () {
                                    // create bucket
                                    // if (searchTextController.text.isNotEmpty) {
                                    // Random random = Random();
                                    // int randomNumber =
                                    //     random.nextInt(90) + 10;
                                    // double rating = randomNumber /
                                    //     20; // 현재 미구현 기능으로 난수를 별점으로 넣어준다.
                                    // keywordThreadsService.create(
                                    //     searchTextController.text,
                                    //     DateTime.now().toString(),
                                    //     rating);
                                    if (searchTextController.text.isNotEmpty) {
                                      Navigator.pushNamed(context, '/create',
                                          arguments: PassArgs(' ',
                                              searchTextController.text, 0));
                                    }
                                  },
                                  child: Text("만듭니다"))
                            ],
                          );
                        }
                      } else {}
                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          String title = doc.get("title");
                          double rate = doc.get("rating");
                          String kid = doc.get("kid");

                          // bool isDone = doc.get("isDone");
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Color.fromARGB(99, 185, 184, 184),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            margin: EdgeInsets.only(
                                left: 20.0, right: 20.0, bottom: 8.0),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 3),
                                      SizedBox(
                                        width: 142,
                                        child: Text(
                                          title,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize:
                                                title.length < 10 ? 16 : 13,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      // SizedBox(width: 8),
                                      Icon(Icons.grade,
                                          color: Colors.yellow[800]),
                                      (rate >= 1.5)
                                          ? Icon(Icons.grade,
                                              color: Colors.yellow[800])
                                          : Text(''),
                                      (rate >= 2.5)
                                          ? Icon(Icons.grade,
                                              color: Colors.yellow[800])
                                          : Text(''),
                                      (rate >= 3.5)
                                          ? Icon(Icons.grade,
                                              color: Colors.yellow[800])
                                          : Text(''),
                                      (rate >= 4.5)
                                          ? Icon(Icons.grade,
                                              color: Colors.yellow[800])
                                          : Text(''),
                                      Text(' ' + rate.toStringAsFixed(2)),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  FutureBuilder<QuerySnapshot>(
                                      future: keywordThreadsService
                                          .getContentsById(kid),
                                      builder: (context, snapshot) {
                                        final documents =
                                            snapshot.data?.docs ?? [];
                                        documents.sort((b, a) {
                                          var aCreateTime = a.get("createTime");
                                          var bCreateTime = b.get("createTime");
                                          return aCreateTime
                                              .compareTo(bCreateTime);
                                        });

                                        if (documents.isEmpty) {
                                          return Text('');
                                        }
                                        if (documents.length == 1) {
                                          final doc = documents[0];
                                          String strFromDoc =
                                              doc.get('contents');
                                          strFromDoc =
                                              strFromDoc.replaceAll('\n', '');
                                          // if (strFromDoc[
                                          //         strFromDoc.length - 1] ==
                                          //     '\n') {
                                          //   strFromDoc = strFromDoc.substring(
                                          //       0, strFromDoc.length - 1);
                                          // }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Text(
                                                '\"' + strFromDoc + '\"',
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey[600],
                                                  fontSize: 10.0,
                                                )),
                                          );
                                        } else {
                                          final doc = documents[0];
                                          final doc2 = documents[1];
                                          String strFromDoc =
                                              doc.get('contents');
                                          String strFromDoc2 =
                                              doc2.get('contents');
                                          strFromDoc =
                                              strFromDoc.replaceAll('\n', ' ');
                                          strFromDoc2 =
                                              strFromDoc2.replaceAll('\n', ' ');

                                          // if (strFromDoc[
                                          //         strFromDoc.length - 1] ==
                                          //     '\n') {
                                          //   strFromDoc = strFromDoc.substring(
                                          //       0, strFromDoc.length - 1);
                                          // }
                                          // if (strFromDoc2[
                                          //         strFromDoc2.length - 1] ==
                                          //     '\n') {
                                          //   strFromDoc2 = strFromDoc2.substring(
                                          //       0, strFromDoc2.length - 1);
                                          // }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('\"' + strFromDoc + '\"',
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.grey[600],
                                                      fontSize: 10,
                                                    )),
                                                Text('\"' + strFromDoc2 + '\"',
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.grey[600],
                                                      fontSize: 10,
                                                    )),
                                              ],
                                            ),
                                          );
                                        }
                                      }),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                              // 이동 아이콘 버튼
                              // trailing: IconButton(
                              //   icon: Icon(
                              //       CupertinoIcons.arrow_right_circle_fill),
                              //   onPressed: () {
                              //     Navigator.pushNamed(context, '/second',
                              //         arguments: PassArgs(kid, title, rate));

                              //     //  bucketService.show(doc.id);
                              //   },
                              // ),
                              onTap: () {
                                Navigator.pushNamed(context, '/second',
                                    arguments: PassArgs(kid, title, rate));

                                // 아이템 클릭하여 isDone 업데이트
                                //bucketService.update(doc.id, !isDone);
                              },
                            ),
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PassArgs {
  PassArgs(this.kid, this.title, this.rating);

  final String kid;
  final String title;
  final double rating;
}

/// 홈페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    //inspect(args);
    PassArgs passArgs;
    passArgs = args! as PassArgs;
    print(passArgs.title);

    return Consumer<KeywordThreadsService>(
      builder: (context, keywordThreadsService, child) {
        //final keywordThreadsService = context.read<AuthService>();
        //User user = authService.currentUser()!;
        //print(user.uid);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 80, 28, 28),
            title: Text(passArgs.title),
            actions: [
              Visibility(
                visible: true,
                child: TextButton(
                  child: Text(
                    "작성하기",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    // 로그인 페이지로 이동
                    // 로그아웃
                    //    context.read<AuthService>().signOut();

                    Navigator.pushNamed(context, '/write',
                        arguments: PassArgs(
                            passArgs.kid, passArgs.title, passArgs.rating));
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              /// 입력창
              Visibility(
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      /// 텍스트 입력창
                      Expanded(
                        child: TextField(
                          controller: jobController,
                          decoration: InputDecoration(
                            hintText: "검색",
                          ),
                        ),
                      ),

                      /// 추가 버튼
                      ElevatedButton(
                        child: Icon(Icons.search),
                        onPressed: () {
                          // create bucket
                          if (jobController.text.isNotEmpty) {
                            //bucketService.create(jobController.text, user.uid);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1),
              SizedBox(height: 10),

              FutureBuilder<double>(
                future: keywordThreadsService.getRating(passArgs.kid),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) return Text("Has no Data");
                  final rating = snapshot.data ?? 0.0;
                  return Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(Icons.grade, size: 40.0, color: Colors.yellow[800]),
                      (rating >= 1.5)
                          ? Icon(Icons.grade,
                              size: 40.0, color: Colors.yellow[800])
                          : Text(''),
                      (rating >= 2.5)
                          ? Icon(Icons.grade,
                              size: 40.0, color: Colors.yellow[800])
                          : Text(''),
                      (rating >= 3.5)
                          ? Icon(Icons.grade,
                              size: 40.0, color: Colors.yellow[800])
                          : Text(''),
                      (rating >= 4.5)
                          ? Icon(Icons.grade,
                              size: 40.0, color: Colors.yellow[800])
                          : Text(''),
                      Text(
                        ' ' + rating.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 10),

              /// 리스트
              SizedBox(
                height: 360,
                child: Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: keywordThreadsService.getContentsById(passArgs.kid),
                    builder: (context, snapshot) {
                      final documents = snapshot.data?.docs ?? [];
                      if (documents.isEmpty) {
                        return Center(child: Text("작성된 글이 없습니다."));
                      }
                      documents.sort((b, a) {
                        var aCreateTime = a.get("createTime");
                        var bCreateTime = b.get("createTime");
                        return aCreateTime.compareTo(bCreateTime);
                      });

                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          String job = doc.get("contents");
                          String loc = doc.get("location");
                          String ip = doc.get("IP");
                          double rating = doc.get("pRating");
                          if (job[job.length - 1] == '\n') {
                            job = job.substring(0, job.length - 1);
                          }

                          return ListTile(
                            title: Column(
                              children: [
                                Divider(height: 5.0),
                                Row(
                                  children: [
                                    Icon(Icons.grade,
                                        size: 15.0, color: Colors.yellow[800]),
                                    (rating >= 1.5)
                                        ? Icon(Icons.grade,
                                            size: 15.0,
                                            color: Colors.yellow[800])
                                        : Text(''),
                                    (rating >= 2.5)
                                        ? Icon(Icons.grade,
                                            size: 15.0,
                                            color: Colors.yellow[800])
                                        : Text(''),
                                    (rating >= 3.5)
                                        ? Icon(Icons.grade,
                                            size: 15.0,
                                            color: Colors.yellow[800])
                                        : Text(''),
                                    (rating >= 4.5)
                                        ? Icon(Icons.grade,
                                            size: 15.0,
                                            color: Colors.yellow[800])
                                        : Text(''),
                                    Text(' ' + rating.toString(),
                                        style: TextStyle(
                                          fontSize: 13,
                                        )),
                                  ],
                                ),
                                // 게시판 안에 본문 글
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 360,
                                      child: Text(
                                        job,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Text(
                                      loc + '  (' + ip + ')',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                // 삭제 아이콘 버튼
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Divider(height: 5.0),
            ],
          ),
        );
      },
    );
  }
}
