import 'package:drift/drift.dart';

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(max: 250)();
  IntColumn get category_id => integer()();
  DateTimeColumn get transaction_date => dateTime()();
  IntColumn get amount => integer()();

  DateTimeColumn get created_at => dateTime()();
  DateTimeColumn get updated_at => dateTime()();
  DateTimeColumn get deleted_at => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // Tambahkan constructor untuk membuat objek Transaction dari baris database
  Transaction fromData(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'] as int?,
      description: data['description'] as String,
      category_id: data['category_id'] as int,
      transaction_date: data['transaction_date'] as DateTime,
      amount: data['amount'] as int,
      created_at: data['created_at'] as DateTime,
      updated_at: data['updated_at'] as DateTime,
      deleted_at: data['deleted_at'] != null ? data['deleted_at'] as DateTime : null,
    );
  }
}

// Buat kelas Transaction yang merepresentasikan objek transaksi
class Transaction {
  final int? id;
  final String description;
  final int category_id;
  final DateTime transaction_date;
  final int amount;
  final DateTime created_at;
  final DateTime updated_at;
  final DateTime? deleted_at;

  Transaction({
    this.id,
    required this.description,
    required this.category_id,
    required this.transaction_date,
    required this.amount,
    required this.created_at,
    required this.updated_at,
    this.deleted_at,
  });
}
