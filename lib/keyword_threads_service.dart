// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KeywordThreadsService extends ChangeNotifier {
  final keywordThreadsCollection =
      FirebaseFirestore.instance.collection('keyword_threads');
  final postingsCollection = FirebaseFirestore.instance.collection('postings');

  Future<QuerySnapshot> getContentsById(String inputId) async {
    notifyListeners();
    return postingsCollection.where('motherId', isEqualTo: inputId).get();
  }

  Future<QuerySnapshot> search(String inputSearch) async {
    // 내 bucketList 가져오기
    //throw UnimplementedError(); // return 값 미구현 에러
    print('검색 $inputSearch');
    notifyListeners();

    return keywordThreadsCollection
        .where('title', isGreaterThanOrEqualTo: inputSearch)
        .where('title', isLessThan: inputSearch + '\uf7ff')
        .get();
  }

  Future<String> getRealIdFromPsuedoId(String psuedoId) async {
    String realId = 'abcd';
    print("real ps:" + psuedoId);
    await keywordThreadsCollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print("real:" + doc['kid']);
        if (doc['kid'] == psuedoId) {
          realId = doc.id;
          print("found real id: " + realId);
        }
      });
    });
    return Future.value(realId);
  }

  // Future<double> getRatingFromPsuedoId(String psuedoId) async {
  //   return Future.delayed(Duration(milliseconds: 100), () {
  //     double rating;
  //     try {
  //       keywordThreadsCollection.get().then((QuerySnapshot querySnapshot) {
  //         querySnapshot.docs.forEach((doc) {
  //           String realId;

  //           print("real:" + doc['kid']);
  //           if (doc['kid'] == psuedoId) {
  //             realId = doc.id;
  //             print("found real id: " + realId);
  //             DocumentReference _documentReference;
  //             _documentReference = keywordThreadsCollection.doc(realId);
  //             _documentReference
  //                 .get()
  //                 .then((DocumentSnapshot _documentSnapshot) async {
  //               if (_documentSnapshot.exists) {
  //                 try {
  //                   rating = _documentSnapshot.get(FieldPath(['rating']));
  //                   print("get rating " + rating.toString());
  //                   notifyListeners();
  //                 } on StateError catch (e) {
  //                   print("No nested field exits!");
  //                 }
  //               }
  //             });
  //           }
  //         });
  //         return rating;
  //       });
  //     } catch (e) {
  //       print(e);
  //     }
  //   });
  // }

  double getRatingDeprecated(String kid) {
    double rating = 0.0;

    print("returned real id:" + kid);
    DocumentReference drReviewCount;
    drReviewCount = keywordThreadsCollection.doc(kid);

    drReviewCount.get().then(
      (DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          try {
            rating = documentSnapshot.get(FieldPath(['rating']));
            print("get rating " + rating.toString());
            notifyListeners();
          } on StateError {
            print("No nested field exits!");
          }
        }
      },
    );
    return rating;
  }

  Future<String> getTitleByKid(String kid) async {
    String a;
    // ignore: await_only_futures
    a = await keywordThreadsCollection
        .where('kid', isEqualTo: kid)
        .get()
        .toString();
    return a;
  }

  Future<double> getRating(String kid) async {
    // ignore: prefer_typing_uninitialized_variables
    var rating;
    rating = await keywordThreadsCollection.doc(kid).get().then(
      (DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          try {
            return documentSnapshot.get(FieldPath(['rating']));
          } on StateError {
            print("No nested field exits!");
          }
        }
      },
    );
    // print("runtime:" + a.runtimeType.toString());
    return rating;
  }

  void create(String title, String kid, double rating, String contents) async {
    // 게시판 신규 생성
    await keywordThreadsCollection.add({
      'title': title,
      'kid': kid,
      'rating': rating,
      'createTime': DateTime.now().toString(),
      'lastUpdatedTime': DateTime.now().toString(),
      'reviewCount': 1,
    }).then((docRef) {
      print("DOCUMENT ID" + docRef.id);
      keywordThreadsCollection.doc(docRef.id).update({'kid': docRef.id});
      createPosting(contents, docRef.id, rating, firstPosting: true);
    });
    notifyListeners();
  }

  void createPosting(String contents, String motherId, double ratin,
      {bool firstPosting = false}) async {
    // bucket 만들기
    await postingsCollection.add({
      'contents': contents,
      'motherId': motherId,
      'pRating': ratin,
      'createTime': DateTime.now().toString(),
      'pid': DateTime.now().toString(),
      'nHate': 0,
      'nLike': 0,
      'nReport': 0,
      'IP': '165.213.*.*',
      'location': '경기도 화성시, 대한민국',
      'title': ' ',
    });

    QuerySnapshot midResult =
        await keywordThreadsCollection.where('kid', isEqualTo: motherId).get();
    final documents = midResult.docs;
    print("kid: " + motherId);
    print(documents[0].id);

    DocumentReference drReviewCount;
    int reviewCount = 0;
    double ratingToBeUpdated = 0.0;
    double ratingCurrent = 0.0;

    drReviewCount = keywordThreadsCollection.doc(documents[0].id);
    drReviewCount.get().then(
      (DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          try {
            reviewCount = documentSnapshot.get(FieldPath(['reviewCount']));
            print("reviewCount Read:" + (reviewCount + 1).toString());
            ratingCurrent = documentSnapshot.get(FieldPath(['rating']));
            print("reviewCount rating read:" + ratingCurrent.toString());
            ratingToBeUpdated =
                (ratingCurrent * reviewCount + ratin) / (reviewCount + 1);

            // await keywordThreadsCollection
            //     .doc(documents[0].id)
            //     .update({'reviewCount': reviewCount + 1});
            // // await keywordThreadsCollection
            //     .doc(documents[0].id)
            //     .update({'rating': ratingToBeUpdated});
            await keywordThreadsCollection.doc(documents[0].id).update({
              'lastUpdatedTime': DateTime.now().toString(),
              'reviewCount': firstPosting ? reviewCount : reviewCount + 1,
              'rating': ratingToBeUpdated
            });

            print("reviewCount:" + reviewCount.toString());
            notifyListeners();
          } on StateError {
            print("No nested field exits!");
          }
        }
      },
    );
  }

  void preProcessing(String inputSearch) async {
    // bucket 만들기
    QuerySnapshot midResult = await search(inputSearch);
    print('--------');
    print(midResult.docs.runtimeType);

    midResult.docs.forEach((element) {
      inspect(element.data());
    });

    notifyListeners();
  }
  /*void update(String docId, bool isDone) async {
    // bucket isDone 업데이트
    await keywordThreadsCollection.doc(docId).update({"isDone": isDone});
    notifyListeners();
  }

  void delete(String docId) async {
    // bucket 삭제
    await keywordThreadsCollection.doc(docId).delete();
    notifyListeners();
  }*/
}
