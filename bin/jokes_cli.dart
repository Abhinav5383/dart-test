import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const version = "0.1.0";
const jokesApiUrl = "https://official-joke-api.appspot.com";
const magic = "\x1B[1A\x1B[2K";

const _reset = "\x1B[0m";
const _dim = "\x1B[2m";
const _yellow = "\x1B[33m";
const _green = "\x1B[32m";

Future<void> main(List<String> args) async {
  if (args.isNotEmpty && (args.first == "-v" || args.first == "--version")) {
    print("jokes_cli version $version");
    return;
  }

  while (true) {
    await tellJoke();

    String promptMsg = "${_dim}Want another joke? (Y/n): $_reset";
    print("");
    stdout.write(promptMsg);

    final String answer = stdin.readLineSync()?.toLowerCase() ?? "";
    if (answer.isNotEmpty && answer[0] == 'n') break;

    stdout.write(magic);
  }
}

Future<void> tellJoke() async {
  String loadingMsg = "${_dim}Loading joke...$_reset";
  print(loadingMsg);

  try {
    Joke joke = await fetchRandomJoke();

    stdout.write(magic);
    print("$_yellow${joke.setup}$_reset".padRight(loadingMsg.length));
    stdout.write("$_dim(press Enter for punchline)$_reset");
    stdin.readLineSync();

    stdout.write(magic);
    print("$_green${joke.punchline}$_reset");
  } on Exception catch (e) {
    stdout.write(magic);
    print(e);
  }
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
