import 'package:flutter/material.dart';

class StripPart extends StatelessWidget {
  final VoidCallback? onAddBP;
  final VoidCallback? onAddSugar;
  final VoidCallback? onAddWeight;
  final VoidCallback? onAddMedicalCards;

  const StripPart({
    super.key,
    this.onAddBP,
    this.onAddSugar,
    this.onAddWeight,
    this.onAddMedicalCards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 12),

              _featureCard(
                title: "BP",
                icon: Icons.monitor_heart,
                color: Colors.red,
                onTap: onAddBP,
              ),

              _featureCard(
                title: "Sugar",
                icon: Icons.bloodtype,
                color: Colors.orange,
                onTap: onAddSugar,
              ),

              _featureCard(
                title: "Weight",
                icon: Icons.fitness_center,
                color: Colors.green,
                onTap: onAddWeight,
              ),

              _featureCard(
                title: "Medical Cards",
                icon: Icons.medical_information,
                color: Colors.blue,
                onTap: onAddMedicalCards,
              ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featureCard({
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
