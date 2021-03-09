import 'package:path_provider/path_provider.dart';
import 'package:savings/StorageProvider.dart';
import 'package:savings/classes/Saving.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageProvider implements StorageProvider {
  static final _databaseName = 'savings.db';

  // savings table
  static final tableSavings = 'savings';
  static final idColumn = '_id';
  static final dateColumn = 'create_date';
  static final amountColumn = 'amount';
  static final descriptionColumn = 'description';

  // user settings table
  static final tableSettings = 'settings';
  static final idSettingsColumn = '_id';
  static final currencyColumn = 'currency';
  static final displayNameColumn = 'display_name';

  static final _version = 1;

  static final LocalStorageProvider _instance =
      LocalStorageProvider._internal();

  factory LocalStorageProvider() {
    return _instance;
  }

  LocalStorageProvider._internal();

  static Database _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database;
  }

  Future<Database> _initDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, _databaseName);

    return await openDatabase(path, version: _version, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE $tableSavings (
          $idColumn INTEGER PRIMARY KEY,
          $dateColumn TEXT,
          $amountColumn REAL,
          $descriptionColumn TEXT
        )
      ''');
      db.execute('''
        CREATE TABLE $tableSettings (
          $idSettingsColumn INTEGER PRIMARY KEY,
          $currencyColumn TEXT,
          $displayNameColumn TEXT
        );
      ''');
    });
  }

  @override
  Future<void> addSaving(Saving saving) async {
    var db = await database;
    await db.insert(tableSavings, saving.toSqliteEntry());
  }

  @override
  Future<String> getCurrency() async {
    var db = await database;
    List<Map> maps = await db.query(
      tableSettings,
      columns: [currencyColumn],
    );
    if (maps.isNotEmpty) {
      return maps.first[currencyColumn];
    }
    return '';
  }

  @override
  Future<Iterable<Saving>> getSavings() async {
    throw UnimplementedError();
  }

  @override
  Future<double> getTotal() async {
    var db = await database;
    var result = await db.rawQuery('''
      SELECT SUM($amountColumn) from $tableSavings
    ''');
    if (result.isNotEmpty) {
      return result.first['SUM($amountColumn)'];
    }
    return 0.0;
  }

  @override
  Future<void> setCurrency(String currency) async {
    var db = await database;
    List<Map> maps = await db.query(
      tableSettings,
      columns: [currencyColumn, idSettingsColumn],
    );
    if (maps.isNotEmpty) {
      await db.update(
          tableSettings,
          {
            currencyColumn: currency,
          },
          where: '$idSettingsColumn = ?',
          whereArgs: [maps.first[idSettingsColumn]]);
    }
    else {
      await db.insert(tableSettings, {currencyColumn: currency} );
    }
  }

  @override
  Future<void> updateTotal(double value) {
    // TODO: implement updateTotal
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Saving>> getLastWeeksSavings() async {
    var db = await database;
    var dateNow = DateTime.now();
    var dateTimeFiveDaysAgo = DateTime.now().add(Duration(days: -5, hours: dateNow.hour, minutes: dateNow.minute))
      .millisecondsSinceEpoch.toString();
    var maps = await db.query(
        tableSavings,
        orderBy: '$dateColumn DESC',
        where: '$dateColumn > ?',
        whereArgs: [dateTimeFiveDaysAgo]
    );
    var savingsList = new List<Saving>.empty(growable: true);
    for (var map in maps) {
      var date = map[dateColumn] as String;
      var amount = map[amountColumn] as double;
      var description = map[descriptionColumn] as String;
      var saving = Saving.withDate(amount, description, date);
      savingsList.add(saving);
    }
    return savingsList;
  }

  @override
  Future<Iterable<Saving>> getLast(int number) async {
    var db = await database;
    var maps = await db.query(tableSavings, orderBy: '$dateColumn DESC', limit: number);
    var savingsList = new List<Saving>.empty(growable: true);
    for (var map in maps) {
      var date = map[dateColumn] as String;
      var amount = map[amountColumn] as double;
      var description = map[descriptionColumn] as String;
      var saving = Saving.withDate(amount, description, date);
      savingsList.add(saving);
    }
    return savingsList;
  }

  @override
  Future<void> initialize() async {
    await database;
  }

  @override
  Future<void> setDisplayName(String name) async {
    var db = await database;
    List<Map> maps = await db.query(
      tableSettings,
      columns: [displayNameColumn, idSettingsColumn],
    );
    if (maps.isNotEmpty && maps != null) {
      await db.update(
          tableSettings,
          {
            displayNameColumn: name,
          },
          where: '$idSettingsColumn = ?',
          whereArgs: [maps.first[idSettingsColumn]]);
    }
    else {
      await db.insert(tableSettings, {displayNameColumn: name} );
    }
  }

  @override
  Future<String> getDisplayName() async {
    var db = await database;
    List<Map> maps = await db.query(
      tableSettings,
      columns: [displayNameColumn],
    );
    if (maps.isNotEmpty && maps != null) {
      return maps.first[displayNameColumn];
    }
    return '';
  }
}
