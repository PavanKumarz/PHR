import 'package:flutter/material.dart';

class AddDataTitleBar extends StatelessWidget {
  final TextEditingController controller;
  final String date;

  const AddDataTitleBar({
    super.key,
    required this.controller,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Title here…',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Container(
          height: 40,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Last\n$date",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
