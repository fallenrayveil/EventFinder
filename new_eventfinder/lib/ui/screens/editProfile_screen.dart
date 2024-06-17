import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../services/userProfile.dart'; // Import layanan yang baru dibuat
import '../../model/userProfille.dart';
import '../../config/config.dart';
class EditProfileScreen extends StatefulWidget {
  final String uid;

  EditProfileScreen({required this.uid});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _profileImage;
  String? _currentProfileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      UserProfile userProfile = await ProfileService.fetchUserProfile(widget.uid);

      setState(() {
        _nameController.text = userProfile.name;
        _phoneController.text = userProfile.phone;
        _addressController.text = userProfile.address;
        _currentProfileImage = userProfile.profileImage;
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfileData() async {
    final response = await ProfileService.saveProfileData(
      uid: widget.uid,
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      profileImage: _profileImage,
    );

    if (response.statusCode == 200) {
      // Berhasil
      final responseBody = jsonDecode(response.body);
      print('Profile updated: ${responseBody['message']}');
    } else {
      // Gagal
      print('Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF30244D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF30244D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color(0xFFCBED54),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _currentProfileImage != null
                        ? NetworkImage('${Config.apiUrl}/${_currentProfileImage!}')
                        : AssetImage('assets/image/welcome_image.png') as ImageProvider,
                child: _profileImage == null && _currentProfileImage == null
                    ? Icon(Icons.camera_alt, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Ganti Data Baru Mu Yuk!',
              style: TextStyle(color: Color(0xFFCBED54), fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Color(0xFFCBED54), fontFamily: 'Magra'),
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                labelStyle: TextStyle(color: Color(0xFFCBED54)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCBED54)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              style: TextStyle(color: Color(0xFFCBED54), fontFamily: 'Magra'),
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                labelStyle: TextStyle(color: Color(0xFFCBED54)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCBED54)),

                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _addressController,
              style: TextStyle(color: Color(0xFFCBED54), fontFamily: 'Magra'),
              decoration: InputDecoration(
                labelText: 'Alamat',
                labelStyle: TextStyle(color: Color(0xFFCBED54)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCBED54)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                _saveProfileData();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCBED54),
              ),
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
