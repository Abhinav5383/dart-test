import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const version = "0.1.0";
const jokesApiUrl = "https://official-joke-api.appspot.com";

Future<void> main(List<String> args) async {
  if (args.isNotEmpty && (args.first == "-v" || args.first == "--version")) {
    print("jokes_cli version $version");
    return;
  }

  Joke joke = await fetchRandomJoke();
  print(joke.setup);
  stdin.readLineSync();
  stdout.write('\x1B[1A\x1B[2K'); // undo the \n written by readLineSync
  print(joke.punchline);
}

typedef Joke = ({String setup, String punchline});

Future<Joke> fetchRandomJoke() async {
  final fetchUrl = Uri.parse("$jokesApiUrl/jokes/random");
  final res = await http.get(fetchUrl);

  String resText = res.body.toString();
  final jsonResponse = jsonDecode(resText) as Map<String, dynamic>;

  if (!jsonResponse.containsKey("setup") ||
      !jsonResponse.containsKey("punchline")) {
    throw Exception("Invalid joke format received from API");
  }

  return (
    setup: jsonResponse["setup"] as String,
    punchline: jsonResponse["punchline"] as String,
  );
}
