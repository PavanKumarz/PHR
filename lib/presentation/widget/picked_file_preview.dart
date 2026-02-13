import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class PickedFilePreview extends StatelessWidget {
  final String filePath;
  final VoidCallback onRemove;

  const PickedFilePreview({
    super.key,
    required this.filePath,
    required this.onRemove,
  });

  bool _isImage(String path) {
    return path.endsWith(".png") ||
        path.endsWith(".jpg") ||
        path.endsWith(".jpeg");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await OpenFilex.open(filePath);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _isImage(filePath)
                ? Image.file(
                    File(filePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.insert_drive_file, size: 40),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                filePath.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
