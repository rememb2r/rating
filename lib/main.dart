import 'dart:developer';
import 'dart:math';

import 'package:bucket_list_with_firebase/auth_service.dart';
import 'package:bucket_list_with_firebase/bucket_service.dart';
import 'package:bucket_list_with_firebase/keyword_threads_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final user = context.read<AuthService>().currentUser();
    return MaterialApp(
      initialRoute: '/',
      theme: ThemeData(backgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => LoginPage(),
        '/second': (context) => HomePage(),
      },
    );
  }
}

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<KeywordThreadsService>(
      builder: (context, keywordThreadsService, child) {
        //User? user = authService.currentUser();

        return Scaffold(
          appBar: AppBar(title: Text("몇점일까"), backgroundColor: Colors.black),
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
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextField(
                  maxLength: 24,
                  controller: emailController,
                  decoration: InputDecoration(
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
                    print(text.length);
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
                      email: emailController.text,
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
                    future: keywordThreadsService.search(emailController.text),
                    builder: (context, snapshot) {
                      final documents = snapshot.data?.docs ?? [];
                      if (documents.isEmpty) {
                        print("nodata");

                        if (emailController.text.length == 0) {
                          return Text('');
                        } else {
                          return Column(
                            children: [
                              Text(" 결과값이 없습니다."),
                              Text(emailController.text),
                              Text("게시판을 생성하시겠습니까?"),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                  ),
                                  onPressed: () {
                                    // create bucket
                                    if (emailController.text.isNotEmpty) {
                                      Random random = Random();
                                      int randomNumber =
                                          random.nextInt(90) + 10;
                                      double rating = randomNumber /
                                          20; // 현재 미구현 기능으로 난수를 별점으로 넣어준다.
                                      keywordThreadsService.create(
                                          emailController.text,
                                          DateTime.now().toString(),
                                          rating);
                                    }
                                  },
                                  child: Container(child: Text("만듭니다")))
                            ],
                          );
                        }
                      } else {
                        print("yesdata");
                      }
                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          String title = doc.get("title");
                          double rate = doc.get("rating");
                          String kid = doc.get("kid");
                          print(rate);
                          // bool isDone = doc.get("isDone");
                          return ListTile(
                            title: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 8),
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
                                    Text(' ' + rate.toString()),
                                  ],
                                ),
                              ],
                            ),
                            // 이동 아이콘 버튼
                            trailing: IconButton(
                              icon:
                                  Icon(CupertinoIcons.arrow_right_circle_fill),
                              onPressed: () {
                                Navigator.pushNamed(context, '/second',
                                    arguments: PassArgs(kid, title, rate));

                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                );*/

                                //  bucketService.show(doc.id);
                              },
                            ),
                            onTap: () {
                              // 아이템 클릭하여 isDone 업데이트
                              //bucketService.update(doc.id, !isDone);
                            },
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
                    print("sign out");
                    // 로그인 페이지로 이동
                    // 로그아웃
                    //    context.read<AuthService>().signOut();

                    Navigator.pop(context);
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
                            print("create bucket");
                            //bucketService.create(jobController.text, user.uid);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.grade, size: 60.0, color: Colors.yellow[800]),
                  (passArgs.rating >= 1.5)
                      ? Icon(Icons.grade, size: 60.0, color: Colors.yellow[800])
                      : Text(''),
                  (passArgs.rating >= 2.5)
                      ? Icon(Icons.grade, size: 60.0, color: Colors.yellow[800])
                      : Text(''),
                  (passArgs.rating >= 3.5)
                      ? Icon(Icons.grade, size: 60.0, color: Colors.yellow[800])
                      : Text(''),
                  (passArgs.rating >= 4.5)
                      ? Icon(Icons.grade, size: 60.0, color: Colors.yellow[800])
                      : Text(''),
                  Text(
                    ' ' + passArgs.rating.toString(),
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              /// 버킷 리스트
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: keywordThreadsService.getContentsById(passArgs.kid),
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return Center(child: Text("작성된 글이 없습니다."));
                    }
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        String job = doc.get("contents");
                        String loc = doc.get("location");
                        String ip = doc.get("IP");
                        double rating = doc.get("pRating");
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
                                          size: 15.0, color: Colors.yellow[800])
                                      : Text(''),
                                  (rating >= 2.5)
                                      ? Icon(Icons.grade,
                                          size: 15.0, color: Colors.yellow[800])
                                      : Text(''),
                                  (rating >= 3.5)
                                      ? Icon(Icons.grade,
                                          size: 15.0, color: Colors.yellow[800])
                                      : Text(''),
                                  (rating >= 4.5)
                                      ? Icon(Icons.grade,
                                          size: 15.0, color: Colors.yellow[800])
                                      : Text(''),
                                  Text(' ' + rating.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                      )),
                                ],
                              ),

                              Row(
                                children: [
                                  Text(
                                    job,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Text(loc + '  (' + ip + ')',
                                      style: TextStyle(
                                        fontSize: 14,
                                      )),
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
            ],
          ),
        );
      },
    );
  }
}