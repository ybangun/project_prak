import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_akhir/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool? isExpense;
  int? type;
  final AppDatabase database = AppDatabase();
  List<Category> listCategory = [];
  TextEditingController categoryNameController = TextEditingController();

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updatedAt: now));
  }

  Future update(int categoryId, String newName) async {
    await database.updateCategoryRepo(categoryId, newName);
  }

  @override
  void initState() {
    isExpense = true;
    type = (isExpense!) ? 2 : 1;
    super.initState();
  }

  void openDialog(Category? category) {
    categoryNameController.clear();
    if (category != null) {
      categoryNameController.text = category.name;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Center(
                    child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  ((category != null) ? 'Edit ' : 'Add ') +
                      ((isExpense!) ? "Outcome" : "Income"),
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: (isExpense!) ? Colors.red : Colors.green),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: categoryNameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Name"),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      (category == null)
                          ? insert(categoryNameController.text,
                              isExpense! ? 2 : 1)
                          : update(category.id, categoryNameController.text);
                      setState(() {});

                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: const Text("Save"))
              ],
            ))),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              child: Text(
                "Categories",
                style: GoogleFonts.montserrat(fontSize: 20),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: isExpense!,
                        inactiveTrackColor: Colors.green[200],
                        inactiveThumbColor: Colors.green,
                        activeColor: Colors.red,
                        onChanged: (bool value) {
                          setState(() {
                            isExpense = value;
                            type = (value) ? 2 : 1;
                          });
                        },
                      ),
                      Text(
                        isExpense! ? "Expense" : "Income",
                        style: GoogleFonts.montserrat(fontSize: 14),
                      )
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        openDialog(null);
                      },
                      icon: const Icon(Icons.add))
                ],
              ),
            ),
            FutureBuilder<List<Category>>(
              future: getAllCategory(type!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
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
                                        onPressed: () {
                                          database.deleteCategoryRepo(
                                              snapshot.data![index].id);
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          openDialog(snapshot.data![index]);
                                        },
                                      )
                                    ],
                                  ),
                                  leading: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: (isExpense!)
                                          ? Icon(Icons.upload,
                                              color: Colors.redAccent[400])
                                          : Icon(
                                              Icons.download,
                                              color: Colors.greenAccent[400],
                                            )),
                                  title: Text(snapshot.data![index].name)),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("No has data"),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text("No has data"),
                    );
                  }
                }
              },
            ),
          ])),
        ));
  }
}
