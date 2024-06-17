import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/eventService.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _mapsUrlController = TextEditingController();
  final TextEditingController _locationsController = TextEditingController();
  File? _eventImage;
  DateTime? _selectedDate;
  String? _selectedOrganizerType;
  String? _selectedCategory;
  bool _hasParticipantLimit = false;

  final EventService _eventService = EventService();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _eventImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.dark(), // Menggunakan tema gelap untuk date picker
        child: child!,
      );
    },
  );
  if (picked != null) {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        _dateController.text = "${picked.day}/${picked.month}/${picked.year} ${pickedTime.format(context)}";
      });
    }
  }
}


  Future<void> _saveEvent() async {
  if (_formKey.currentState!.validate()) {
    try {
      await _eventService.createEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        capacity: _hasParticipantLimit ? _capacityController.text : '0', // Mengirim '0' jika tidak ada batas pengunjung
        mapsUrl: _mapsUrlController.text,
        organizerType: _selectedOrganizerType ?? '',
        eventImage: _eventImage,
        category: _selectedCategory ?? '',
        location: _locationsController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF30244D),
      appBar: AppBar(
        title: Text('Buat Acara'),
        titleTextStyle: TextStyle(color: Color(0xFFCBED54), fontSize: 16.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color(0xFFCBED54),
        ),
        backgroundColor: const Color(0xFF30244D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    image: _eventImage != null
                        ? DecorationImage(
                            image: FileImage(_eventImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _eventImage == null
                      ? Icon(Icons.camera_alt, color: Colors.white, size: 50)
                      : null,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Acara',
                  labelStyle: TextStyle(color: Color(0xFFCBED54)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: TextStyle(color: Color(0xFFCBED54)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan judul acara';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedOrganizerType,
                items: ['Berbayar', 'Tidak Berbayar']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                hint: Text(
                  'Tipe Acara',
                  style: TextStyle(color: Color(0xFFCBED54)),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedOrganizerType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Mohon pilih tipe penyelenggara';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: TextStyle(color: Color(0xFFCBED54)),
                dropdownColor: Color(0xFF30244D),
              ),
               SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: [
                  'Seminar',
                  'Workshop',
                  'Conference',
                  'Meetup',
                  'Webinar',
                  'Concert',
                  'Festival',
                  'Other',
                ].map((label) => DropdownMenuItem(
                      child: Text(label),
                      value: label,
                    ))
                    .toList(),
                hint: Text(
                  'Kategori Acara',
                  style: TextStyle(color: Color(0xFFCBED54)),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Mohon pilih kategori acara';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: TextStyle(color: Color(0xFFCBED54)),
                dropdownColor: Color(0xFF30244D),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Tanggal Acara',
                  labelStyle: TextStyle(color: Color(0xFFCBED54)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: TextStyle(color: Color(0xFFCBED54)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan tanggal acara';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Acara',
                  labelStyle: TextStyle(color: Color(0xFFCBED54)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: TextStyle(color: Color(0xFFCBED54)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan deskripsi acara';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: Text(
                  'Ada batas pengunjung?',
                  style: TextStyle(color: Color(0xFFCBED54)),
                ),
                value: _hasParticipantLimit,
                onChanged: (value) {
                  setState(() {
                    _hasParticipantLimit = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Color(0xFFCBED54),
                checkColor: Colors.black,
              ),
              if (_hasParticipantLimit)
                TextFormField(
                  controller: _capacityController,
                  decoration: InputDecoration(
                    labelText: 'Kapasitas Partisipan',
                    labelStyle: TextStyle(color: Color(0xFFCBED54)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCBED54)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFFCBED54)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan kapasitas partisipan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
              TextFormField(
                controller: _locationsController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Acara',
                  labelStyle: TextStyle(color: Color(0xFFCBED54)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: TextStyle(color: Color(0xFFCBED54)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan lokasi acara';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _mapsUrlController,
                decoration: InputDecoration(
                  labelText: 'URL Google Maps',
                  labelStyle: TextStyle(color: Color(0xFFCBED54)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: TextStyle(color: Color(0xFFCBED54)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan URL Google Maps';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Simpan Acara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCBED54),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
