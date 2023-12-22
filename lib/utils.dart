Map<String, String> parseInputString(String inputString) {
  Map<String, String> result = {};

  RegExp regex = RegExp(r"server:([^&]+)&user:([^&]+)&password:([^&]+)");

  Match? match = regex.firstMatch(inputString);
  if (match != null) {
    result['server'] = match.group(1)!;
    result['user'] = match.group(2)!;
    result['password'] = match.group(3)!;
  }

  return result;
}

// const String localhost = "http://192.168.0.178:8080";
const String localhost = "http://192.168.1.45:8080";
const String host = "192.168.1.45";
