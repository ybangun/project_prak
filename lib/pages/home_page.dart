import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_akhir/models/database.dart';
import 'package:project_akhir/models/transaction_with_category.dart';
import 'package:project_akhir/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({super.key, required this.selectedDate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();
  int totalIncome = 0;
  int totalExpense = 0;
  Stream<List<TransactionWithCategory>>? transactionsStream;

  @override
  void initState() {
    super.initState();
    fetchTotals(); // Memanggil fetchTotals saat halaman dimuat
    transactionsStream = database.getTransactionByDateRepo(widget.selectedDate);
  }

  Future<void> fetchTotals() async {
    final income = await database.getTotalIncome();
    final expense = await database.getTotalExpense();

    setState(() {
      totalIncome = income;
      totalExpense = expense;
    });
  }

Future<void> saveTransaction() async {
  bool isTransactionSaved = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const TransactionPage(
        transactionsWithCategory: null, // Gunakan null jika menambahkan transaksi baru
      ),
    ),
  );

  if (isTransactionSaved) {
    fetchTotals(); // Update totals after adding/editing a transaction
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.download,
                                color: Colors.greenAccent[400],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Income',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.white)),
                                const SizedBox(height: 5),
                                Text('Rp ${totalIncome.toString()}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.upload,
                                color: Colors.redAccent[400],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expense',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12, color: Colors.white)),
                                const SizedBox(height: 5),
                                Text('Rp ${totalExpense.toString()}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Text("Belum ada transaksi",
                            style: GoogleFonts.montserrat()),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 10,
                          child: ListTile(
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await database.deleteTransactionRepo(
                                        snapshot.data![index].transaction.id);
                                    fetchTotals();
                                  },
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    var editedItem = await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => TransactionPage(
                                        transactionsWithCategory:
                                            snapshot.data![index],
                                      ),
                                    ));
                                    if (editedItem != null) {
                                      int id = editedItem.id;
                                      int amount = editedItem.amount;
                                      int categoryId = editedItem.categoryId;
                                      DateTime transactionDate =
                                          editedItem.transactionDate;
                                      String description = editedItem.description;

                                      await database.updateTransactionRepo(
                                          id,
                                          amount,
                                          categoryId,
                                          transactionDate,
                                          description);

                                      fetchTotals();
                                    }
                                  },
                                ),
                              ],
                            ),
                            subtitle: Text(snapshot.data![index].category.name),
                            leading: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: (snapshot.data![index].category.type == 1)
                                  ? Icon(
                                      Icons.download,
                                      color: Colors.greenAccent[400],
                                    )
                                  : Icon(
                                      Icons.upload,
                                      color: Colors.red[400],
                                    ),
                            ),
                            title: Text(
                              snapshot.data![index].transaction.amount.toString(),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
