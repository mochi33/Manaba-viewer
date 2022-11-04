enum PageType{
  signIn,
  home,
  courseNewsList,
  courseList,
  courseDetail,
  queryList,
  queryDetail,
  reportList,
  reportDetail,
  courseNewsDetail,
}

class AppInfo {
  static bool isUserChanged = false;
  static bool isLoading = false;
  static PageType pageType = PageType.signIn;
}