import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const version = "0.1.0";
const jokesApiUrl = "https://official-joke-api.appspot.com";
const magic = "\x1B[1A\x1B[2K";

Future<void> main(List<String> args) async {
  if (args.isNotEmpty && (args.first == "-v" || args.first == "--version")) {
    print("jokes_cli version $version");
    return;
  }

  bool wantAnotherJoke = false;

  do {
    await tellJoke();

    print("\nWant another joke? (y/n)");
    final String answer = stdin.readLineSync()?.toLowerCase() ?? "";
    wantAnotherJoke = answer.isEmpty ? false : answer[0] == 'y';
  } while (wantAnotherJoke == true);
}

Future<void> tellJoke() async {
  String loadingMsg = "\nLoading...";
  print(loadingMsg);

  Joke joke = await fetchRandomJoke();
  stdout.write(magic);
  print(joke.setup.padRight(loadingMsg.length));
  stdin.readLineSync();
  stdout.write(magic); // undo the \n written by readLineSync
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
