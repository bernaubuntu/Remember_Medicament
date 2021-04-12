calculoCN(String cadena) {
  RegExp regExp = new RegExp(
    r"^[0-9]{6,7}$",
    caseSensitive: false,
    multiLine: false,
  );
  return regExp.hasMatch(cadena);
}
