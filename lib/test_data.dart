class TestData {
  static List<Map<String, String>> courseList = [{
    'ID' : "111111",
    'title' : "33333:ビッグデータ解析(A1) § 33334:データマイニング(A1)",
    'isHomework' : "false",
    'dayOfWeek' : "月",
    'period' : "3",
    'place' : "C111",
  },
    {
      'ID' : "111112",
      'title' : "30000:論理と思考(C)",
      'isHomework' : "false",
      'dayOfWeek' : "月",
      'period' : "4",
      'place' : "C112",
    },
    {
      'ID' : "1111200",
      'title' : "90775:技術経営論Ⅰ(MA)	",
      'isHomework' : "false",
      'dayOfWeek' : "金",
      'period' : "3",
      'place' : "P201",
    },
    {
      'ID' : "111113",
      'title' : "33333:確率・統計(K1) § 33334:確率統計A(A1)",
      'isHomework' : "false",
      'dayOfWeek' : "火",
      'period' : "1",
      'place' : "P121",
    },
    {
      'ID' : "111114",
      'title' : "35000:化学２(K2)",
      'isHomework' : "false",
      'dayOfWeek' : "火",
      'period' : "2",
      'place' : "P220",
    },
    {
      'ID' : "111115",
      'title' : "22222:人工知能(Q) § 99999:人工知能概論(K1)",
      'isHomework' : "false",
      'dayOfWeek' : "水",
      'period' : "3",
      'place' : "P201",
    },
    {
      'ID' : "111116",
      'title' : "22222:人工知能(Q) § 99999:人工知能概論(K1)",
      'isHomework' : "false",
      'dayOfWeek' : "木",
      'period' : "1",
      'place' : "C303",
    }];
  static List<Map<String, String>> reportData = [
    {
      'ID' : "111111",
      'courseID' : "111111",
      'title' : "第一回レポート",
      'deadline' : "2023-3-14",
      'courseTitle' : '22222:人工知能(Q) § 99999:人工知能概論(K1)',
      'isRead' : 'true',
    },
    {
      'ID' : "111111",
      'courseID' : "111111",
      'title' : "第1回レポート",
      'deadline' : "2023-3-14",
      'courseTitle' : '35000:化学２(K2)',
      'isRead' : 'false',
    },
    {
      'ID' : "111112",
      'courseID' : "111112",
      'title' : "第二回レポート",
      'courseTitle' : '22222:人工知能(Q) § 99999:人工知能概論(K1)',
      'deadline' : "2023-3-21",
      'isRead' : 'true',
    },
  ];
  static List<Map<String, String>> queryData = [
    {
      'ID' : "111111",
      'courseID' : "111111",
      'title' : "第一回小テスト課題",
      'courseTitle' : '35000:化学２(K2)',

      'deadline' : "2023-3-15",
      'isRead' : 'true',
    },
    {
      'ID' : "111111",
      'courseID' : "111112",
      'title' : "第一回ミニテスト",
      'courseTitle' : '35000:化学２(K2)',
      'deadline' : "2023-3-15",
      'isRead' : 'true',
    },
  ];
  static List<Map<String, String>> courseNewsList = [];
  static List<Map<String, String>> contentsList = [];
  static List<Map<String, String>> contentsDetailList = [];
  static List<Map<String, String>> otherNewsList = [];
}