import 'package:flutter/material.dart';
import 'package:new_eventfinder/ui/screens/userEvents_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_eventfinder/services/userProfile.dart';
import 'package:new_eventfinder/ui/screens/editProfile_screen.dart';
import 'package:new_eventfinder/model/userProfille.dart';
import '../../config/config.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _futureUserProfile;
  String? uid;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    email = prefs.getString('email');

    if (uid != null) {
      setState(() {
        _futureUserProfile = ProfileService.fetchUserProfile(uid!);
      });
      print('User ID: $uid');
      var userProfile = await ProfileService.fetchUserProfile(uid!);
      print(userProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF30244D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color(0xFFCBED54),
        ),
      ),
      backgroundColor: Color(0xFF30244D),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<UserProfile>(
          future: _futureUserProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              UserProfile userProfile = snapshot.data!;

              return Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: NetworkImage('${Config.apiUrl}/${userProfile.profileImage}'),
                  ),
                  SizedBox(height: 16.0),
                  _buildProfileItem(
                    icon: Icons.person,
                    label: userProfile.name,
                    fallback: "segera isi data mu",
                  ),
                  SizedBox(height: 16.0),
                  _buildProfileItem(
                    icon: Icons.email,
                    label: email!,
                    fallback: "segera isi data mu",
                  ),
                  SizedBox(height: 8.0),
                  _buildProfileItem(
                    icon: Icons.phone,
                    label: userProfile.phone,
                    fallback: "segera isi data mu",
                  ),
                  SizedBox(height: 8.0),
                  _buildProfileItem(
                    icon: Icons.location_on,
                    label: userProfile.address,
                    fallback: "segera isi data mu",
                  ),
                  SizedBox(height: 12.0),
                  ListTile(
                    leading: Icon(Icons.edit, color: Color(0xFFCBED54)),
                    title: Text('Edit Profile', style: TextStyle(color: Color(0xFFCBED54))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen(uid: uid!)),
                      );
                    },
                  ),
                  SizedBox(height: 12.0),
                  ListTile(
                    leading: Icon(Icons.event, color: Color(0xFFCBED54)),
                    title: Text('Acara Mu', style: TextStyle(color: Color(0xFFCBED54))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserEventsScreen(uid: uid!)),
                      );
                    },
                  ),
                  // Add more list tiles for other actions
                ],
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileItem({required IconData icon, required String label, required String fallback}) {
    final displayText = label.isEmpty ? fallback : label;
    final displayColor = label.isEmpty ? Colors.grey : Color(0xFFCBED54);
    
    return Row(
      children: <Widget>[
        Icon(icon, color: displayColor),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 16,
              color: displayColor,
            ),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
