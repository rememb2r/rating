import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KeywordThreadsService extends ChangeNotifier {
  final keywordThreadsCollection =
      FirebaseFirestore.instance.collection('keyword_threads');
  final postingsCollection = FirebaseFirestore.instance.collection('postings');

  Future<QuerySnapshot> getContentsById(String inputId) async {
    notifyListeners();
    print('GetContentsById: {$inputId}');
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

  Future<String> getTitleByKid(String kid) async {
    String a;
    a = await keywordThreadsCollection
        .where('kid', isEqualTo: kid)
        .get()
        .toString();
    return a;
  }

  void create(String title, String kid, double rating) async {
    // bucket 만들기
    await keywordThreadsCollection.add({
      'title': title,
      'kid': kid,
      'rating': rating,
      'createTime': DateTime.now().toString(),
    });
    notifyListeners();
  }

  void createPosting(String contents, String motherId, double rating) async {
    // bucket 만들기
    await postingsCollection.add({
      'contents': contents,
      'motherId': motherId,
      'pRating': rating,
      'createTime': DateTime.now().toString(),
      'pid': DateTime.now().toString(),
      'nHate': 0,
      'nLike': 0,
      'nReport': 0,
      'IP': '165.213.*.*',
      'location': '경기도 화성시, 대한민국',
      'title': ' ',
    });
    notifyListeners();
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
