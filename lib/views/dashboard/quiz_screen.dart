import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachmantra/views/dashboard/question_pageview.dart';
import '../../model/questions.dart';
import '../../model/quiz_question_model.dart';
import '../../model/shuffleanswers.dart';
import '../../routes/arguments.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../services/api_services.dart';
import '../../utils/app_color.dart';
import '../../utils/app_text_style.dart';
import '../../widgets/app_text.dart';
//todo change this name
typedef void Randomise(List options);

class QuizScreen extends StatefulWidget {
  final OtpArguments? arguments;
  QuizScreen({Key? key, this.arguments}) : super(key: key);
  List wrongRightList = [];



  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var getQuizTime;
  @override
  void initState() {

    super.initState();
    print("chapterID: ${widget.arguments?.chapterId}");
    callQuestionApi();


  }
  Future<List<Results>?> getStates() async {
    Uri url = Uri.parse("https://app.teachmantra.com/get_ajax/get_question_list");
    var response = await http.post(url, body:{"courseid": "${widget.arguments?.chapterId}"});
    if (response.statusCode == 200) {
      log('api worked ${response.body}');
      var body = response.body;
      var statesJsonArray = json.decode(body)['record'];

      try {
        List<Results> results =
        (statesJsonArray as List).map((e) => Results.fromJson(e)).toList();

        return results;
      } catch (e) {
        log('try failed $e');
      }
    } else {
      log('api request failed ${response.body}');

      return null;
    }
  }
  Future<void> callQuestionApi() async {

    FormData data() {
      return FormData.fromMap({
        "courseid": widget.arguments?.chapterId,
      });
    }
    ApiService().getQuizQuestion(context,data: data()).then((value){

      setState(() {
        getQuizTime=value.totalTime;
        print("TOTAL TIME ------------------->$getQuizTime");
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF053251),
      appBar: AppBar(
        centerTitle: true,
        title:  appText('Quiz questions',style:AppTextStyle.appBarTitle.copyWith(color: AppColor.black)),
        leading: BackButton(),
      ),
      body: _futureWidget(),
    );
  }

  _futureWidget() {
    return FutureBuilder(
      future: getStates(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List results = snapshot.data as List;
          ShuffleRight(
              result: results,
              Shuffler: (options) {
                widget.wrongRightList = options;
              });

          return QuestionsPageView(
              results: results, wrongRightList: widget.wrongRightList,getQuizTime: getQuizTime,);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

}
