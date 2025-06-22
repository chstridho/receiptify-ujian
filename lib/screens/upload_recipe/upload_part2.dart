import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadStep2 extends StatefulWidget {
  final String foodName;
  final String description;
  final XFile coverPhoto;
  final Uint8List coverPhotoBytes;

  const UploadStep2({
    super.key,
    required this.foodName,
    required this.description,
    required this.coverPhoto,
    required this.coverPhotoBytes,
  });

  @override
  State<UploadStep2> createState() => _UploadStep2State();
}

class _UploadStep2State extends State<UploadStep2> {
  final _picker = ImagePicker();
  final stepsController = TextEditingController();
  List<TextEditingController> ingredientControllers = [TextEditingController()];

  XFile? _stepImage;
  Uint8List? _stepImageBytes;
  bool isSubmitting = false;

  void addIngredientField() {
    setState(() {
      ingredientControllers.add(TextEditingController());
    });
  }

  void removeIngredientField(int index) {
    setState(() {
      ingredientControllers.removeAt(index);
    });
  }

  Future<void> pickStepImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _stepImage = picked;
        _stepImageBytes = bytes;
      });
    }
  }

  Future<void> handleSubmit() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    final ingredients = ingredientControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final steps = stepsController.text
        .trim()
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (ingredients.isEmpty || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua bagian ingredients dan steps")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Upload cover image
      final coverPath = 'covers/${timestamp}_cover_${widget.coverPhoto.name}';
      await supabase.storage
          .from('recipe-images')
          .uploadBinary(coverPath, widget.coverPhotoBytes);
      final coverUrl = supabase.storage
          .from('recipe-images')
          .getPublicUrl(coverPath);

      // Upload optional step image
      String? stepImageUrl;
      if (_stepImage != null && _stepImageBytes != null) {
        final stepPath = 'steps/${timestamp}_step_${_stepImage!.name}';
        await supabase.storage
            .from('recipe-images')
            .uploadBinary(stepPath, _stepImageBytes!);
        stepImageUrl = supabase.storage
            .from('recipe-images')
            .getPublicUrl(stepPath);
      }

      final inserted = await supabase.from('recipes').insert({
        'food_name': widget.foodName,
        'description': widget.description,
        'ingredients': ingredients,
        'steps': steps,
        'cover_url': coverUrl,
        'step_image_url': stepImageUrl,
      }).select();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resep berhasil di-upload!")),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/homepage', (route) => false);
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (var c in ingredientControllers) {
      c.dispose();
    }
    stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const Text(
                    '2/2',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.group_add, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              ...ingredientControllers.asMap().entries.map((entry) {
                int i = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: entry.value,
                          decoration: const InputDecoration(
                            hintText: 'Enter ingredient',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (i > 0)
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () => removeIngredientField(i),
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Ingredient'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Steps',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stepsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Pisahkan langkah dengan enter baris baru',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: pickStepImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _stepImageBytes == null
                      ? const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _stepImageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
