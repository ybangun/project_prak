import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:project_akhir/models/category.dart';
import 'package:project_akhir/models/transaction.dart';
import 'package:project_akhir/models/transaction_with_category.dart';

part 'database.g.dart';

@DriftDatabase(
  // relative import for the drift file. Drift also supports `package:`
  // imports
  tables: [Categories, Transactions],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  // CRUD Category
  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String newName) async {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(newName),
      ),
    );
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future updateTransactionRepo(int id, int amount, int categoryId,
      DateTime transactionDate, String Description) async {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amount: Value(amount),
        category_id: Value(categoryId),
        transaction_date: Value(transactionDate),
        name : Value(Description))
    );
  }

  Future deleteTransactionRepo (int id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getTotalIncome() async {
    final result = await (select(transactions)
        .join([innerJoin(categories, categories.id.equalsExp(transactions.category_id))])
      ..where(categories.type.equals(1)))
        .map((row) => row.read(transactions.amount))
        .get();

    final sum = result.fold<int>(0, (previous, amount) => previous + (amount ?? 0));

    return sum;
  }

  Future<void> insertTransaction(Transaction transaction) async {
    await into(transactions).insert(transaction);
  }

  Future<int> getTotalExpense() async {
    final result = await (select(transactions)
        .join([innerJoin(categories, categories.id.equalsExp(transactions.category_id))])
      ..where(categories.type.equals(2)))
        .map((row) => row.read(transactions.amount))
        .get();

    final sum = result.fold<int>(0, (previous, amount) => previous + (amount ?? 0));

    return sum;
  }



  // CRUD Transaction
  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_date.equals(date)));
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }
}



LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
