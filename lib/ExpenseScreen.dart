import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DashBoard.dart';

class Note {
  late String expense;
  late String text;
  late DateTime dateTime;

  Note({
    required this.expense,
    required this.text,
    required this.dateTime,
  });
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final String _noteKey = 'user_notes';
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  double _totalExpense = 0.0;
  int? _longPressedNoteIndex;
  DateTimeRange? _selectedDateRange;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = (prefs.getStringList(_noteKey) ?? []).map((note) {
        final parts = note.split(';');
        return Note(
          expense: parts[0],
          text: parts[1],
          dateTime: DateTime.parse(parts[2]),
        );
      }).toList();
      _filteredNotes = List.from(_notes);
      _calculateTotalExpense();
    });
  }

  double _calculateTodayTotalExpense() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var note in _notes) {
      if (note.dateTime.day == now.day &&
          note.dateTime.month == now.month &&
          note.dateTime.year == now.year) {
        total += double.tryParse(note.expense) ?? 0.0;
      }
    }
    return total;
  }

  void _calculateTotalExpense() {
    double total = 0.0;
    for (var note in _filteredNotes) {
      total += double.tryParse(note.expense) ?? 0.0;
    }
    setState(() {
      _totalExpense = total;
    });
  }

  Future<void> _saveNote(String expense, String text, DateTime date, [int? index]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (expense.isEmpty || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Both Expense and Note fields are required'),
        ),
      );
      return;
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(expense)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense field must contain only numbers'),
        ),
      );
      return;
    }

    final newNote = Note(
      expense: expense,
      text: text,
      dateTime: date,
    );

    setState(() {
      if (index != null) {
        _notes[index] = newNote;
      } else {
        _notes.add(newNote);
      }
      _applyFilter();
    });

    await prefs.setStringList(
      _noteKey,
      _notes
          .map((note) =>
      '${note.expense};${note.text};${note.dateTime.toIso8601String()}')
          .toList(),
    );
    _calculateTotalExpense();
    await prefs.setDouble("totalExpense", _totalExpense);
  }

  Future<void> _deleteNoteConfirmation(int index) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: const Color(0xffead1cf),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await _deleteNote(index);
    }
  }

  Future<void> _deleteNote(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes.removeAt(index);
      _applyFilter();
    });
    await prefs.setStringList(
      _noteKey,
      _notes
          .map((note) =>
      '${note.expense};${note.text};${note.dateTime.toIso8601String()}')
          .toList(),
    );
    _calculateTotalExpense();
  }

  void _navigateToAddExpenseScreen([int? index]) async {
    if (index != null) {
      setState(() {});
    } else {
      setState(() {});
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          isEditing: index != null,
          initialExpense: index != null ? _notes[index].expense : '',
          initialText: index != null ? _notes[index].text : '',
          initialDate: index != null ? _notes[index].dateTime : DateTime.now(),
          onSave: (expense, text, date) {
            _saveNote(
              expense,
              text,
              date,
              index,
            );
          },
        ),
      ),
    );

    if (result != null) {
      // Optionally handle the result here if needed
    }
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    setState(() {
      if (_selectedFilter == 'Today') {
        _filteredNotes = _notes.where((note) => note.dateTime.day == now.day &&
            note.dateTime.month == now.month && note.dateTime.year == now.year).toList();
      } else if (_selectedFilter == 'Last 7 Days') {
        _filteredNotes = _notes.where((note) => note.dateTime.isAfter(now.subtract(const Duration(days: 7)))).toList();
      } else if (_selectedFilter == 'This Month') {
        _filteredNotes = _notes.where((note) => note.dateTime.month == now.month && note.dateTime.year == now.year).toList();
      } else if (_selectedFilter == 'Custom Range' && _selectedDateRange != null) {
        _filteredNotes = _notes.where((note) => note.dateTime.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            note.dateTime.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList();
      } else {
        _filteredNotes = List.from(_notes);
      }
      _calculateTotalExpense();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _selectedFilter = 'Custom Range';
        _applyFilter();
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedFilter = 'All';
      _selectedDateRange = null;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    double todayTotalExpense = _calculateTodayTotalExpense();

    return GestureDetector(
      onTap: () {
        setState(() {
          _longPressedNoteIndex = null;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff069f87),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          title: const Text(
            'Expenses',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Dashboard(role: 'admin', stockItems: [],),
                ),
              );
              _clearFilter();
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Total Expense TK: ",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$_totalExpense',
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _navigateToAddExpenseScreen(),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xff4ad7c1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Today's Expense TK: ",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$todayTotalExpense',
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.black),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            onChanged: (value) {
                              if (value == 'Custom Range') {
                                _selectDateRange(context);
                              } else {
                                setState(() {
                                  _selectedFilter = value!;
                                  _applyFilter();
                                });
                              }
                            },
                            items: <String>[
                              'All',
                              'Today',
                              'Last 7 Days',
                              'This Month',
                              'Custom Range',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(value),
                                ),
                              );
                            }).toList(),
                            underline: Container(),
                            icon: const Icon(Icons.filter_list),
                            isExpanded: true,
                            dropdownColor: const Color(0xffead1cf),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _longPressedNoteIndex = null;
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        _longPressedNoteIndex = index;
                      });
                    },
                    child: Card(
                      color: _longPressedNoteIndex == index
                          ? Colors.red.withOpacity(0.2)
                          : const Color(0xffead1cf),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: ListTile(
                        title: Text(
                          'TK: ${note.expense}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${note.text}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "${DateFormat.yMMMd().add_jm().format(note.dateTime)}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: _longPressedNoteIndex == index
                            ? Wrap(
                          spacing: 8.0,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _navigateToAddExpenseScreen(index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _deleteNoteConfirmation(index);
                              },
                            ),
                          ],
                        )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  final bool isEditing;
  final String initialExpense;
  final String initialText;
  final DateTime initialDate;
  final Function(String expense, String text, DateTime date) onSave;

  const AddExpenseScreen({
    super.key,
    required this.isEditing,
    required this.initialExpense,
    required this.initialText,
    required this.initialDate,
    required this.onSave,
  });

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _expenseController.text = widget.initialExpense;
    _textController.text = widget.initialText;
    _selectedDate = widget.initialDate;
  }

  void _save() {
    final expense = _expenseController.text;
    final text = _textController.text;
    widget.onSave(expense, text, _selectedDate);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _expenseController,
              decoration: const InputDecoration(
                labelText: 'Expense',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Text('Select Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
            ),
          ],
        ),
      ),
    );
  }
}
