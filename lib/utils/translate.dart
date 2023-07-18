import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

sendReq(String message, String source, String target) async {
  message = message.replaceAll(" ", "%20");
  String url =
      "https://translate.google.com/m?sl=$source&tl=$target&q=$message";
  final response = await http.get(Uri.parse(url));
  var output = parse(response.body);
  return output.getElementsByClassName("result-container")[0].text;
}

translate(String message, String source, String target) async {
  if (target == "ben" || target == "hen") {
    target = "bn";
  }
  if (source == 'ben') {
    String finalTarget = target;
    //Benglish to Bengali
    source = "en";
    target = "bn";
    message = await sendReq(message, source, target);
    message = message..replaceAll(" ", "%20");
    // Bengali to English
    source = "bn";
    target = finalTarget;
    String result = await sendReq(message, source, target);
    return result;
  } else if (source == "hen") {
    String finalTarget = target;
    //Hinglish to Hindi
    source = "en";
    target = "hi";
    message = await sendReq(message, source, target);
    message = message..replaceAll(" ", "%20");
    // Hindi to English
    source = "hi";
    target = finalTarget;
    String result = await sendReq(message, source, target);
    return result;
  } else {
    String result = await sendReq(message, source, target);
    return result;
  }
}
