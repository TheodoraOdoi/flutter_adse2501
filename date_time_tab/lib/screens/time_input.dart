// Import the Flutter material package
import 'package:flutter/material.dart';

class TimeInputScreen extends StatefulWidget{
  const TimeInputScreen({super.key});

  @override
  State<TimeInputScreen> createState() => _TimeInputScreenState();
}

class _TimeInputScreenState extends State<TimeInputScreen>{
  // Variables to be used in this screen
  TimeOfDay? _selectedTime;
  final TextEditingController _timeController = TextEditingController();
  int _guests = 1;
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if(args is Map)
    {
      if(args['guests'] is int) _guests = args['guests'] as int;
      if(args['date'] is DateTime) _selectedDate = args['date'] as DateTime;
    }
  }

  Future<void> _selectTime(BuildContext context) async
  {
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: TimeOfDay.now()
    );
    if (!mounted) return;
    if (!context.mounted) return;

    if (picked != null && picked != _selectedTime) {
      // validate the time based on our restaurant's opening hours
      if (_isValidTime(picked)) {
        setState(() {
          _selectedTime = picked;
          _timeController.text = _selectedTime!.format(context);
        });
      } else {
        // Show an error message for invalid time
        String errorMessage = _getTimeErrorMessage();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  bool _isValidTime(TimeOfDay time) {
    if (_selectedDate == null) return false;

    int weekday = _selectedDate!.weekday;
    int hour = time.hour;
    int minute = time.minute;

    // Monday to Friday: 8:00 AM - 10:00 PM
    if (weekday >= DateTime.monday && weekday <= DateTime.friday) {
      if (hour < 8 || (hour == 10 && minute > 0) || hour > 22) {
        return false;
      }
    }
    // Saturday: 9:00 AM - 11:00 PM
    else if (weekday == DateTime.saturday) {
      if (hour < 9 || (hour == 11 && minute > 0) || hour > 23) {
        return false;
      }
    }
    // Sunday: Closed
    else if (weekday == DateTime.sunday) {
      return false;
    }

    return true;
  }

  String _getTimeErrorMessage() {
    if (_selectedDate == null) return 'Please select a date first';

    int weekday = _selectedDate!.weekday;

    if (weekday >= DateTime.monday && weekday <= DateTime.friday) {
      return 'Restaurant is open Monday-Friday from 8:00 AM to 10:00 PM';
    } else if (weekday == DateTime.saturday) {
      return 'Restaurant is open Saturday from 9:00 AM to 11:00 PM';
    } else if (weekday == DateTime.sunday) {
      return 'Restaurant is closed on Sundays';
    }

    return 'Invalid time selected';
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Time'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
          body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Select a Time",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_rounded, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text('Guests: $_guests'),
                        ],
                      ),
                      const SizedBox(height: 12,),
                      if(_selectedDate !=null)
                        Text(
                          "Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Time',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(context),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedTime != null)
                        Text(
                          'Selected: ${_selectedTime!.format(context)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a time')),
                            );
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: {
                              'guests': _guests,
                              'date': _selectedDate,
                              'time': _selectedTime,
                            },
                          );
                        },
                        child: const Text('Review Reservation'),
                      ),
                    ],
                  ),
                ),
              ),
          ),
      );
  }
}