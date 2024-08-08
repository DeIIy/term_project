import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._internal();

  String tblRegister = "register";
  String colId = "id";
  String colUsername = "username";
  String colPassword = "password";
  String colReligion = "religion";
  String colLifestyle = "lifestyle";
  String colAllergy = "allergy";

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  static Future<Database>? _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "register.db";
    var registerDatabase =
    await openDatabase(path, version: 1, onCreate: _createDb);
    return registerDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblRegister($colId INTEGER PRIMARY KEY, $colUsername TEXT," +
            "$colPassword TEXT, $colReligion TEXT, $colLifestyle TEXT, $colAllergy TEXT" +
            ")");
  }

  Future<int> insertRegister(Map<String, dynamic> register) async {
    Database db = await this.database;
    var result = await db.insert(tblRegister, register);
    print('Inserted into register table: $result'); // Eklenen veriyi konsola yazdır
    return result;
  }

  Future<List<Map<String, dynamic>>> getRegisters() async {
    Database db = await this.database;
    var result = await db.query(tblRegister);
    return result;
  }

  Future<int?> getCount() async {
    Database db = await this.database;
    var result =
    Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $tblRegister"));
    return result;
  }

  Future<int> updateRegister(Map<String, dynamic> register) async {
    Database db = await this.database;
    var result = await db.update(tblRegister, register,
        where: "$colId = ?", whereArgs: [register[colId]]);
    return result;
  }

  Future<int> deleteRegister(int id) async {
    Database db = await this.database;
    var result = await db.delete(tblRegister, where: "$colId = ?", whereArgs: [id]);
    return result;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result =
    await db.query(tblRegister, where: "$colId = ?", whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<bool> checkUserCredentials(int id, String username, String password) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(tblRegister, where: "$colId = ? AND $colUsername = ? AND $colPassword = ?", whereArgs: [id, username, password]);
    return result.isNotEmpty;
  }

  Future<bool> isUsernameAvailable(String username) async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.query(tblRegister, where: "$colUsername = ?", whereArgs: [username]);
    return result.isEmpty;
  }

  Future<int> updateReligion(int userId, String newReligion) async {
    Database db = await this.database;
    int result = await db.update(tblRegister, {colReligion: newReligion}, where: "$colId = ?", whereArgs: [userId]);
    return result;
  }

  Future<int> updateLifestyle(int userId, String newLifestyle) async {
    Database db = await this.database;
    int result = await db.update(tblRegister, {colLifestyle: newLifestyle}, where: "$colId = ?", whereArgs: [userId]);
    return result;
  }

  Future<int> updateAllergy(int userId, String newAllergy) async {
    Database db = await this.database;
    int result = await db.update(tblRegister, {colAllergy: newAllergy}, where: "$colId = ?", whereArgs: [userId]);
    return result;
  }

  Future<int> updatePassword(int userId, String newPassword) async {
    Database db = await this.database;
    int result = await db.update(tblRegister, {colPassword: newPassword}, where: "$colId = ?", whereArgs: [userId]);
    return result;
  }

  Future<int> deleteUser(int userId) async {
    Database db = await this.database;
    int result = await db.delete(tblRegister, where: "$colId = ?", whereArgs: [userId]);
    return result;
  }
}














