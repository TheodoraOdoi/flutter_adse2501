// Import the Flutter material package
import 'package:flutter/material.dart';

class DateInputScreen extends StatefulWidget {
  const DateInputScreen({super.key});

  @override
  State<DateInputScreen> createState() => _DateInputScreenState();
}

class _DateInputScreenState extends State<DateInputScreen> {
  // Variables to be used in the screen
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  int _guests = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if(args is Map && args['guests'] is int) {_guests = args['guests'] as int;}
  }

  Future<void> _selectDate(BuildContext context) async
  {
    try
        {
          // Get the current date
          final now = DateTime.now();
          final initialDate = _selectedDate ?? now;

          // Show the date picker dialog
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)), // One year from now/current date
              selectableDayPredicate: (DateTime date) {
                // Disable past dates and sundays(restaurant is usually closed on sundays)
                if (date.isBefore(DateTime(now.year, now.month, now.day)))
                {
                  return false;
                }
                if (date.weekday == DateTime.sunday) {
                  return false;
                }
                return true;
              },
              builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.deepPurple, // Header background color
                        onPrimary: Colors.white, // Header text color
                        onSurface: Colors.black, // Body text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple, // button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
              },
          );

          // when a date is picked/ chosen, update the state
          if (picked != null && picked != _selectedDate)
          {
            setState(() {
              _selectedDate = picked;
              _dateController.text = "${_getWeekday(picked.weekday)}, ${picked.day}"
                  "${_getMonth(picked.month)} ${picked.year}";
            });
          }
      } catch (e)
      {
        // Handle any errors that might
        if(context.mounted)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error selecting date'))
            );
          }
      }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {

      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  String _getMonth(int month) {
    return [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][month - 1];
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _bookTable()
  {
    if(_selectedDate == null)
      {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')),
        );
        return;
      }
    Navigator.pushNamed(context,
        "/time",
        arguments: {
          "guests": _guests,
          "date": _selectedDate
    });
  }

  @override //22-07-2026
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Reserve a table",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              const SizedBox(height: 10),
              const Text(
                "Select your preferred date and time for your dinning experience",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Date Selection
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      hintText: "Choose a date",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: const TextStyle(fontSize: 16),
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Guests display (passed from main)
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  Text('Guests: $_guests',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              const SizedBox(height: 40,),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _bookTable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Back to Home button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (route) => false
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Back to home",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
