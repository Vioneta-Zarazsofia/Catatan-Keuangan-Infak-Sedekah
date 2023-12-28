import 'package:catatan_keuangan/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
} //menginisialisasi Firebase dan menjalankan aplikasi

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Infak Dan Sedekah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FinancialHomePage(),
    );
  }
}

class FinancialHomePage extends StatefulWidget {
  @override
  _FinancialHomePageState createState() => _FinancialHomePageState();
}

class _FinancialHomePageState extends State<FinancialHomePage> {
  double totalIncome = 0;
  double totalExpense = 0;
  List<TransactionItem> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('transactions').get();

      setState(() {
        transactions = querySnapshot.docs
            .map((doc) => TransactionItem(
                  id: doc.id,
                  type: doc['type'],
                  amount: doc['amount'],
                  date: doc['date'].toDate(),
                  transactionType: doc['transactionType'],
                ))
            .toList();

        totalIncome = transactions
            .where((transaction) => transaction.transactionType == 'Pemasukan')
            .fold(0, (sum, transaction) => sum + transaction.amount);

        totalExpense = transactions
            .where(
                (transaction) => transaction.transactionType == 'Pengeluaran')
            .fold(0, (sum, transaction) => sum - transaction.amount);
      });
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  // Function to delete a transaction
  //Menghapus transaksi dari Firestore dan memperbarui data lokal.
  void _deleteTransaction(String transactionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .delete();

      setState(() {
        transactions
            .removeWhere((transaction) => transaction.id == transactionId);

        totalIncome = transactions
            .where((transaction) => transaction.transactionType == 'Pemasukan')
            .fold(0, (sum, transaction) => sum + transaction.amount);

        totalExpense = transactions
            .where(
                (transaction) => transaction.transactionType == 'Pengeluaran')
            .fold(0, (sum, transaction) => sum + transaction.amount);
      });
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  // Function to edit a transaction
  //Mengedit transaksi di Firestore dan memperbarui data lokal.
  void _editTransaction(
      String oldTransactionId, TransactionItem newTransaction) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(oldTransactionId)
          .update({
        'type': newTransaction.type,
        'amount': newTransaction.amount,
        'date': newTransaction.date,
        'transactionType': newTransaction.transactionType,
      });

      setState(() {
        if (newTransaction.transactionType == 'Pemasukan') {
          totalIncome -= newTransaction.amount;
        } else {
          totalExpense -= newTransaction.amount;
        }

        if (newTransaction.transactionType == 'Pemasukan') {
          totalIncome += newTransaction.amount;
        } else {
          totalExpense += newTransaction.amount;
        }

        transactions = transactions
            .map((transaction) => transaction.id == oldTransactionId
                ? newTransaction
                : transaction)
            .toList();
      });
    } catch (e) {
      print('Error editing transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello Vioneta'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Total Keseluruhan',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('Rp. ${(totalIncome - totalExpense).toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.white, fontSize: 30)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    child: InOutReportCard(
                      label: 'Pemasukan',
                      amount: 'Rp. $totalIncome',
                      color: Colors.green,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    child: InOutReportCard(
                      label: 'Pengeluaran',
                      amount: 'Rp. $totalExpense',
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TransactionHistory(
              transactions: transactions,
              onDelete: _deleteTransaction,
              onEdit: _editTransaction,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(),
            ),
          );

          if (result != null) {
            setState(() {
              if (result.transactionType == 'Pemasukan') {
                totalIncome += result.amount;
              } else {
                totalExpense += result.amount;
              }

              transactions.add(result);
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

//Widget untuk menampilkan laporan pemasukan dan pengeluaran.
class InOutReportCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  InOutReportCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              label == 'Pemasukan' ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
            ),
          ],
        ),
        subtitle: Text(
          amount,
          style: TextStyle(color: color),
        ),
        tileColor: color.withAlpha(50),
      ),
    );
  }
}

//Widget untuk menampilkan riwayat transaksi.
class TransactionHistory extends StatelessWidget {
  final List<TransactionItem> transactions;
  final Function(String) onDelete;
  final Function(String, TransactionItem) onEdit;

  TransactionHistory({
    required this.transactions,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Column(
          children: transactions.map((transaction) {
            Color textColor = transaction.transactionType == 'Pemasukan'
                ? Colors.green
                : Colors.red;

            return ListTile(
              title: Text(
                '${transaction.type} - Rp. ${transaction.amount}',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                'Date: ${transaction.date.toLocal()}',
                style: TextStyle(color: textColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () =>
                        _navigateToEditScreen(context, transaction.id),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => onDelete(transaction.id),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _navigateToEditScreen(BuildContext context, String transactionId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditTransactionScreen(transactionId: transactionId),
      ),
    );

    if (result != null) {
      onEdit(transactionId, result);
    }
  }
}

//Halaman untuk menambahkan transaksi baru.
class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String selectedType = 'Infak';
  double amount = 0.0;
  DateTime selectedDate = DateTime.now();
  String selectedTransactionType = 'Pemasukan';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _addTransactionToFirestore(TransactionItem transaction) async {
    try {
      CollectionReference transactions =
          FirebaseFirestore.instance.collection('transactions');
      await transactions.add({
        'type': transaction.type,
        'amount': transaction.amount,
        'date': transaction.date,
        'transactionType': transaction.transactionType,
      });
      print('Transaction added to Firestore!');
    } catch (e) {
      print('Error adding transaction to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              value: selectedType,
              items: ['Infak', 'Sedekah']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value.toString();
                });
              },
              decoration: InputDecoration(labelText: 'Jenis Transaksi'),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0.0;
                });
              },
              decoration: InputDecoration(labelText: 'Jumlah'),
            ),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Radio(
                  value: 'Pemasukan',
                  groupValue: selectedTransactionType,
                  onChanged: (value) {
                    setState(() {
                      selectedTransactionType = value.toString();
                    });
                  },
                ),
                Text('Pemasukan'),
                Radio(
                  value: 'Pengeluaran',
                  groupValue: selectedTransactionType,
                  onChanged: (value) {
                    setState(() {
                      selectedTransactionType = value.toString();
                    });
                  },
                ),
                Text('Pengeluaran'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newTransaction = TransactionItem(
                  type: selectedType,
                  amount: amount,
                  date: selectedDate,
                  transactionType: selectedTransactionType,
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                );

                await _addTransactionToFirestore(newTransaction);

                Navigator.pop(context, newTransaction);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTransactionScreen extends StatefulWidget {
  final String transactionId;

  EditTransactionScreen({required this.transactionId});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late String selectedType;
  late double amount;
  late DateTime selectedDate;
  late String selectedTransactionType;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _loadTransactionDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transactionId)
          .get();

      setState(() {
        selectedType = documentSnapshot['type'];
        amount = documentSnapshot['amount'];
        selectedDate = documentSnapshot['date'].toDate();
        selectedTransactionType = documentSnapshot['transactionType'];
      });
    } catch (e) {
      print('Error loading transaction details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Set a default value for selectedType if it's not initialized
    selectedType = 'Infak';

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              value: selectedType,
              items: ['Infak', 'Sedekah']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value.toString();
                });
              },
              decoration: InputDecoration(labelText: 'Jenis Transaksi'),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0.0;
                });
              },
              decoration: InputDecoration(labelText: 'Jumlah'),
              initialValue: amount.toString(),
            ),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Radio(
                  value: 'Pemasukan',
                  groupValue: selectedTransactionType,
                  onChanged: (value) {
                    setState(() {
                      selectedTransactionType = value.toString();
                    });
                  },
                ),
                Text('Pemasukan'),
                Radio(
                  value: 'Pengeluaran',
                  groupValue: selectedTransactionType,
                  onChanged: (value) {
                    setState(() {
                      selectedTransactionType = value.toString();
                    });
                  },
                ),
                Text('Pengeluaran'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  TransactionItem(
                    id: widget.transactionId,
                    type: selectedType,
                    amount: amount,
                    date: selectedDate,
                    transactionType: selectedTransactionType,
                  ),
                );
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

//Model data untuk menyimpan informasi transaksi.
class TransactionItem {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String transactionType;

  TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.transactionType,
  });
}
