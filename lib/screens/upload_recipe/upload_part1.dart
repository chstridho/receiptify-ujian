import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receiptify/screens/home_page.dart';
import 'upload_part2.dart';

class UploadStep1 extends StatefulWidget {
const UploadStep1({super.key});

@override
State<UploadStep1> createState() => _UploadStep1State();
}

class _UploadStep1State extends State<UploadStep1> {
final _foodNameController = TextEditingController();
final _descriptionController = TextEditingController();
final ImagePicker _picker = ImagePicker();

XFile? _coverPhoto;
Uint8List? _coverPhotoBytes;

Future<void> _pickImage() async {
final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
if (picked != null) {
final bytes = await picked.readAsBytes();
setState(() {
_coverPhoto = picked;
_coverPhotoBytes = bytes;
});
}
}

void _goToNext() {
final foodName = _foodNameController.text.trim();
final desc = _descriptionController.text.trim();

if (foodName.isEmpty || desc.isEmpty || _coverPhoto == null || _coverPhotoBytes == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Isi semua bagian terlebih dahulu")),
  );
  return;
}

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UploadStep2(
      foodName: foodName,
      description: desc,
      coverPhoto: _coverPhoto!,
      coverPhotoBytes: _coverPhotoBytes!,
    ),
  ),
);
}

@override
void dispose() {
_foodNameController.dispose();
_descriptionController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
 TextButton(
  onPressed: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  },
  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
),

  const Text("1/2", style: TextStyle(fontWeight: FontWeight.bold)),
],

),
const SizedBox(height: 20),

          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: _coverPhotoBytes == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Add Cover Photo", style: TextStyle(color: Colors.grey)),
                          Text("(max 12 MB)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_coverPhotoBytes!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _foodNameController,
            decoration: const InputDecoration(
              labelText: "Food Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),

          ElevatedButton(
            onPressed: _goToNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Next", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  ),
);
}
}