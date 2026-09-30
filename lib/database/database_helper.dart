import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/models/user_model.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';


class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await intiDB();
    await _database!.execute('''
      Create table if not exists session(
        user_id integer primary key
      )
    ''');
    return _database!;
  }

  Future<Database> intiDB() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        
        await db.execute('''
          Create table users(
            id integer primary key autoincrement,
            name text,
            email textunique ,
            password text
          )
        ''');

        
        await db.execute('''
          Create table categories(
            id integer primary key autoincrement,
            category_name text,
            icon text
          )
        ''');

        
        await db.execute('''
          Create table transactions(
            id integer primary key autoincrement,
            user_id integer,
            title text,
            amount real,
            type text,
            category_id integer,
            date text,
            notes text,
            payment_method text,
           foreign key  (user_id) references users (id) on delete cascade,
            foreign key  (category_id) references categories (id)
          )
        ''');


       
        final List<Map<String, String>> defaultCategories = [
          {'name': 'Food', 'icon': 'restaurant'},
          {'name': 'Transport', 'icon': 'directions_bus'},
          {'name': 'Shopping', 'icon': 'shopping_bag'},
          {'name': 'Bills', 'icon': 'receipt_long'},
          {'name': 'Entertainment', 'icon': 'movie'},
          {'name': 'Education', 'icon': 'school'},
          {'name': 'Healthcare', 'icon': 'medical_services'},
          {'name': 'Travel', 'icon': 'flight'},
          {'name': 'Salary', 'icon': 'payments'},
          {'name': 'Investment', 'icon': 'trending_up'},
          {'name': 'Others', 'icon': 'more_horiz'},
        ];

        for (var cat in defaultCategories) {
          await db.insert('categories', {
            'category_name': cat['name'],
            'icon': cat['icon'],
          });
        }
      },
    );
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUser(String email, String passwordHash) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, passwordHash],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<void> saveSession(int userId) async {
    final db = await database;
    await db.delete('session');
    await db.insert('session', {'user_id': userId});
  }

  Future<int?> getSessionUserId() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('session');
    if (maps.isEmpty) return null;
    return maps.first['user_id'] as int?;
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('session');
  }

  
  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [transaction.id, transaction.userId],
    );
  }

  Future<int> deleteTransaction(int transactionId, int userId) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [transactionId, userId],
    );
  }

  Future<int> deleteMultipleTransactions(List<int> transactionIds, int userId) async {
    final db = await database;
    if (transactionIds.isEmpty) return 0;
    String idList = transactionIds.join(',');
    return await db.delete(
      'transactions',
      where: 'id IN ($idList) AND user_id = ?',
      whereArgs: [userId],
    );
  }
}
 