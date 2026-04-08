import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/language_provider.dart';
import '../core/providers/accessibility_provider.dart';

class VisitOptimizerScreen extends StatelessWidget {
  const VisitOptimizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final accessibility = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
        title: const Text(
          'Visit Optimizer',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3D62),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CURRENT STATUS',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Optimal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Visit now: Low traffic',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Average wait time: 12 mins',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Traffic Forecast
                    const Text(
                      'TRAFFIC FORECAST — TODAY',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _buildTrafficBarChart(),
                    const SizedBox(height: 12),

                    // Warning Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Busy: Wait between 10 AM and 12 PM',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Book Virtual Queue
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3D62),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book Virtual Queue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Reserve your spot remotely',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Best Times per Office
              const Text(
                'Best Times per Office',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // CNAM Belvédère Card
              _buildOfficeTimeCard(
                officeName: 'CNAM Belvédère',
                distance: '1.2 km away',
                accessible: true,
                bestTime: 'Best Now',
                timeSlots: '8:00-9:30 AM     2:30-4:00 PM',
              ),

              const SizedBox(height: 12),

              // CNSS Tunis Centre Card
              _buildOfficeTimeCard(
                officeName: 'CNSS Tunis Centre',
                distance: '2.1 km away',
                accessible: true,
                bestTime: 'Moderate',
                timeSlots: '9:00-10:30 AM     3:00-5:00 PM',
                isModerate: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF0A3D62),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Assistant'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Optimizer'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Traffic Bar Chart (Simple horizontal bars)
  Widget _buildTrafficBarChart() {
    final hours = ['8am', '10am', 'Now', '2pm', '5pm'];
    final values = [25, 45, 85, 55, 30]; // percentage

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (index) {
        return Column(
          children: [
            Container(
              width: 28,
              height: values[index].toDouble() * 1.2,
              decoration: BoxDecoration(
                color: index == 2 ? Colors.red : const Color(0xFF4FC3F7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hours[index],
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOfficeTimeCard({
    required String officeName,
    required String distance,
    required bool accessible,
    required String bestTime,
    required String timeSlots,
    bool isModerate = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  officeName,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isModerate ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bestTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              distance,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (accessible)
                  const Row(
                    children: [
                      Icon(Icons.accessible, color: Colors.blue, size: 20),
                      SizedBox(width: 6),
                      Text('Accessible', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                const Spacer(),
                Text(
                  timeSlots,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}