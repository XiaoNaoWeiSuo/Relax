import 'package:dio/dio.dart';

List processList(List myList, int maxLength) {
  if (myList.length <= maxLength) {
    return myList;
  }

  int excess = myList.length - maxLength;
  myList.removeRange(3, 3 + excess);

  return myList;
}

class GPT {
  //List initiallist;
  String model;
  double temperature;
  GPT({required this.model, required this.temperature});
  Dio dio = Dio();

  Future<dynamic> sendRequest(List<dynamic> messages) async {
    messages = processList(messages, 12); //限制会话保留的最大长度
    // ChatGPT API的URL
    String url = "https://api.closeai-proxy.xyz/v1/chat/completions";
    // ChatGPT API的访问密钥
    String apiKey = "sk-6TBCMKWB8Bu89kyMThnaP5kM6ECS9r43ut9vpPccPZGEtDRv";
    // 请求参数
    Map<String, dynamic> parameters = {
      "model": model,
      "messages": messages,
      "temperature": temperature
    };
    Options options = Options(
      contentType: "application/json",
      headers: {"Authorization": "Bearer $apiKey"},
    );
    try {
      Response response =
          await dio.post(url, data: parameters, options: options);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        //print(data);
        //String text = data["choices"][0]["message"]["content"];
        //print(text);
        return data;
      } else {
        //print(response);
        return "Sorry, something went wrong.";
      }
    } catch (error) {
      //print(error);
      return "Sorry, something went wrong.";
    }
  }
}
