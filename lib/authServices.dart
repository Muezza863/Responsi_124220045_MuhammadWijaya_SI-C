import 'package:shared_preferences/shared_preferences.dart';

class authServices {
  static void simpanAkun (String username, String password) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('username', username);
    sharedPref.setString('password', password);

    print(sharedPref.getString('username'));
    print(sharedPref.getString('password'));
  }

  static Future<bool> login(String username, String password) async{
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    if (username == sharedPref.get('username')&& password == sharedPref.getString('password')
    ) {
      return true;
    }
    else return false;
  }


}