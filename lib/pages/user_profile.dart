import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/signup_page.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      try {
        // Re-authenticate the user with the old password
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(cred);

        // Update password if re-authentication is successful
        await user.updatePassword(newPassword);
        var snackbar = const SnackBar(
          content: Text("Password changed successfully"),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pop();
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
      } catch (e) {
        print("Error : $e");
        var snackbar = const SnackBar(
          content: Text("Old Password incorrect"),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  controller: _oldPasswordController,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Old Password',
                  ),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password';
                    }
                    if (value.length <= 6) {
                      return 'Password must have at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  controller: _newPasswordController,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'New Password',
                  ),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value.length <= 6) {
                      return 'Password must contain at least 6 characters';
                    }
                    if (value != _confirmNewPasswordController.text) {
                      return 'New passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  controller: _confirmNewPasswordController,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Confirm New Password',
                  ),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value.length <= 6) {
                      return 'Password must contain at least 6 characters';
                    }
                    if (value != _newPasswordController.text) {
                      return 'New passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: StatefulBuilder(
                                builder: (stfContext, stfSetState) {
                              return Container(
                                child: const Text(
                                    'Are you sure you want to change your password?'),
                              );
                            }),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  changePassword(_oldPasswordController.text,
                                      _newPasswordController.text);
                                },
                                child: const Text('Change'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text(
                    'UPDATE PROFILE',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
