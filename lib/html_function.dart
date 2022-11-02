class HtmlFunction {

  static const leftArrow = r'\u003C';
  static const asciiConverter = {
    '21' : '!',
    '22' : '"',
    '23' : '#',
    '24' : r'$',
    '25' : '%',
    '26' : '&',
    '27' : "'",
    '28' : '(',
    '29' : ')',
    '2A' : '*',
    '2B' : '+',
    '2C' : ',',
    '2D' : '-',
    '2E' : '.',
    '2F' : '/',
    '3A' : ':',
    '3B' : ';',
    '3C' : '<',
    '3D' : '=',
    '3E' : '>',
    '3F' : '?',
    '40' : '@',
    '5B' : '[',
    '5C' : r'\',
    '5D' : ']',
    '5E' : '^',
    '5F' : '_',
    '60' : '`',
    '7B' : '{',
    '7C' : '|',
    '7D' : '}',
    '7E' : '~',
  };

  static String parseHTML(String html) {
    final a = html.split(leftArrow);
    String b = '';
    for(int i = 0; i < a.length; i++) {
      if (i == 0) {
        b += a[i].replaceAll(r'\n', '').replaceAll('"', '');
      } else if(i == a.length - 1){
        b += '<';
        b += a[i].replaceAll(r'\n', '').replaceAll('"', '');
      } else {
        b += '<';
        b += a[i];
      }
    }
    return b.replaceAll(r'\n', '');

  }

  static String urlAsciiDecoder(String url) {
    final a = url.split('%');
    String decodedUrl = '';
    if (a.length > 1) {
      decodedUrl += a[0];
      for (String str in a.sublist(1)) {
        if (str.startsWith(RegExp(r'[0-9A-F][0-9A-F]'))) {
          print('asciiNum' + str.substring(0, 2));
          final b = asciiConverter[str.substring(0, 2)] ?? '';
          if (str.length > 2) {
            decodedUrl += b + str.substring(2);
          } else {
            decodedUrl += b;
          }
        }
      }
      return decodedUrl;
    }
    else {
      return a[0];
    }
  }
}