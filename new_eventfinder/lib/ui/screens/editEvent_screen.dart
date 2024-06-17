import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_eventfinder/config/config.dart';
import '../../model/events.dart';
import '../../services/eventService.dart';
import 'package:intl/intl.dart';

final EventService _eventService = EventService();

class EditEventScreen extends StatefulWidget {
  final Event event;
  final String uid;

  EditEventScreen({required this.event, required this.uid});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late DateTime date;
  late String capacity;
  late String mapsUrl;
  late String organizerType;
  late String imageUrl;
  late String status;
  late double rating;
  late String location;
  String? _selectedCategory;
  File? _image;
  bool _hasParticipantLimit = false;

  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    title = widget.event.title;
    description = widget.event.description;
    date = widget.event.date;
    capacity = widget.event.capacity;
    mapsUrl = widget.event.mapsUrl;
    organizerType = widget.event.organizerType;
    imageUrl = widget.event.imageUrl;
    status = widget.event.status;
    rating = widget.event.rating;
    location = widget.event.location;
    _hasParticipantLimit = capacity.isNotEmpty;
    _selectedDate = date;
    _selectedCategory = widget.event.category;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Using dark theme for date picker
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
        final now = DateTime.now();
        final selectedDateTime = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);

        if (selectedDateTime.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected date and time cannot be in the past')),
          );
        } else {
          setState(() {
            _selectedDate = selectedDateTime;
            date = _selectedDate!;
          });
        }
      }
    }
  }

  void _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _eventService.updateEvent(
          eventId: widget.event.id,
          title: title,
          description: description,
          date: date,
          capacity: _hasParticipantLimit ? capacity : '',
          mapsUrl: mapsUrl,
          organizerType: organizerType,
          status: status,
          eventImage: _image,
          category: _selectedCategory ?? '',
          location: location,
        );
        Navigator.pop(context, true); // true indicates that the event was updated
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update event: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        backgroundColor: Color(0xFF30244D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? (imageUrl.isNotEmpty
                        ? Image.network(
                            '${Config.apiUrl}$imageUrl',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: Icon(Icons.add_a_photo, size: 50),
                          ))
                    : Image.file(
                        _image!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                initialValue: description,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                onSaved: (value) => description = value!,
              ),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a date' : null,
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                    text: _selectedDate != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!)
                        : ''),
              ),
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
                ]
                    .map((label) => DropdownMenuItem(
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
              CheckboxListTile(
                title: Text('Has Participant Limit?'),
                value: _hasParticipantLimit,
                onChanged: (value) {
                  setState(() {
                    _hasParticipantLimit = value!;
                    if (!value) {
                      capacity = ''; // Clear capacity if participant limit is not selected
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_hasParticipantLimit)
                TextFormField(
                  initialValue: capacity,
                  decoration: InputDecoration(labelText: 'Capacity'),
                  validator: (value) => value!.isEmpty ? 'Please enter a capacity' : null,
                  onSaved: (value) => capacity = value!,
                ),
              TextFormField(
                initialValue: mapsUrl,
                decoration: InputDecoration(labelText: 'Google Maps URL'),
                validator: (value) => value!.isEmpty ? 'Please enter a Google Maps URL' : null,
                onSaved: (value) => mapsUrl = value!,
              ),
              TextFormField(
                initialValue: location,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Please enter a Location' : null,
                onSaved: (value) => location = value!,
              ),
              DropdownButtonFormField<String>(
                value: organizerType,
                decoration: InputDecoration(labelText: 'Organizer Type'),
                validator: (value) => value == null ? 'Please select an organizer type' : null,
                onChanged: (value) {
                  setState(() {
                    organizerType = value!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'Berbayar',
                    child: Text('Berbayar'),
                  ),
                  DropdownMenuItem(
                    value: 'Tidak Berbayar',
                    child: Text('Tidak Berbayar'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) => value == null ? 'Please select a status' : null,
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem(
                    value: 'Ongoing',
                    child: Text('Ongoing'),
                  ),
                  DropdownMenuItem(
                    value: 'Upcoming',
                    child: Text('Upcoming'),
                  ),
                  DropdownMenuItem(
                    value: 'Cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEvent,
                child: Text('Update Event'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFCBED54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
