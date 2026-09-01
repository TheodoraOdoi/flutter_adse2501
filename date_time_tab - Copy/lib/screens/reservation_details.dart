// The application's reservation details screen

// Import required packages
import 'dart:math';
import 'package:flutter/material.dart';

class ReservationDetailsScreen extends StatelessWidget {
  // function to get a random available table number(1-25, excluding 6)
  int _getRandomTableNumber()
  {
    Random random = Random();
    int tableNumber;
    do
    {
      tableNumber = random.nextInt(25) + 1; // values 1-25
    } while (tableNumber == 6); // skip table 6 (broken or permanently reserved)
    return tableNumber;
  }

  const ReservationDetailsScreen({super.key});

  String _formatDate(DateTime? date)
  {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final int guests = (args != null && args['guests'] is int) ? args['guests'] as int : 1;
    final DateTime? date = (args != null && args['date'] is DateTime) ? args['date'] as DateTime : null;
    final TimeOfDay? time = (args != null && args['time'] is TimeOfDay) ? args['time'] as TimeOfDay : null;

    // Get a random table number for this reservation
    final int tableNumber = _getRandomTableNumber();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Reservation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.deepPurple,),
                const SizedBox(width: 8,),
                Text("Guests: $guests", style: const TextStyle(fontSize: 16),),
              ],
            ),
            const SizedBox(height: 16,),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, color: Colors.deepPurple,),
                const SizedBox(width: 8,),
                Text("Time: ${time != null? time.format(context): '-'}", style: const TextStyle(fontSize: 16),),
              ],
            ),
            const SizedBox(height: 12,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.table_restaurant_rounded, color: Colors.green,),
                  const SizedBox(width: 8,),
                  Text(
                    "Table: $tableNumber",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(12)),
                    child: Text("Reserved",
                      style: TextStyle( color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    ),
                ],
              ),
              ),

            const SizedBox(height: 30),

            // Restaurant Information
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.deepPurple, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Restaurant Information',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('• Operating Hours: Monday-Friday 8:00 AM - 10:00 PM'),
                    Text('• Saturday: 9:00 AM - 11:00 PM'),
                    Text('• Closed on Sundays'),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.deepPurple, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Important Information',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('• Please arrive 10 minutes before your reservation'),
                    Text('• Table will be held for 15 minutes after the reserved time'),
                    Text('• For parties of 8 or more, please call us directly'),
                    SizedBox(height: 10),
                    Text('• Table 6 is reserved for staff use'),
                    Text('• Table assignments are subject to change based on availability'),
                  ],
                ),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ()
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reservation Confirmed!')),
                  );
                },
                child: const Text("Confirm", style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),

    );
  }
}