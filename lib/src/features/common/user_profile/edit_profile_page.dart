import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../auth/auth_cubit.dart';
import '../app_user/user_repository.dart';
import 'user_profile_cubit.dart';
import 'user_profile_state.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState.user == null) {
      return const Scaffold(
        body: Center(child: Text('Niste prijavljeni.')),
      );
    }

    return BlocProvider(
      create: (_) => UserProfileCubit(
        userRepository: GetIt.instance<UserRepository>(),
      )..loadProfile(authState.user!.id),
      child: const _EditProfileContent(),
    );
  }
}

class _EditProfileContent extends StatefulWidget {
  const _EditProfileContent();

  @override
  State<_EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<_EditProfileContent> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  File? _selectedImage;
  bool _initialized = false;

  final List<String> _genderOptions = ['Musko', 'Zensko', 'Ostalo'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);

    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: (context, state) {
        if (state.status == UserProfileStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil uspjesno azuriran!')),
          );
          context.pop();
        } else if (state.status == UserProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Greska'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        // Popuni polja sa trenutnim podacima
        if (!_initialized && state.user != null) {
          _firstNameController.text = state.user!.firstName;
          _lastNameController.text = state.user!.lastName;
          _phoneController.text = state.user!.phoneNumber ?? '';
          _selectedDateOfBirth = state.user!.dateOfBirth;
          _selectedGender = state.user!.gender;
          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Uredi Profil'),
          ),
          body: state.status == UserProfileStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profilna slika
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (state.user?.profileImageUrl != null
                                        ? NetworkImage(state.user!.profileImageUrl!)
                                            as ImageProvider
                                        : null),
                                child: _selectedImage == null &&
                                        state.user?.profileImageUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: 55,
                                        color: Colors.grey.shade500,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: fksBordo,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Ime
                        TextFormField(
                          controller: _firstNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Unesite ime';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Ime',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Prezime
                        TextFormField(
                          controller: _lastNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Unesite prezime';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Prezime',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email (read-only)
                        TextFormField(
                          initialValue: state.user?.email ?? '',
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email (ne moze se promijeniti)',
                            prefixIcon: const Icon(Icons.email_outlined),
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Telefon
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Broj telefona',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Datum rodjenja
                        InkWell(
                          onTap: () => _pickDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Datum rodjenja',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            child: Text(
                              _selectedDateOfBirth != null
                                  ? DateFormat('dd.MM.yyyy')
                                      .format(_selectedDateOfBirth!)
                                  : 'Odaberite datum',
                              style: TextStyle(
                                color: _selectedDateOfBirth != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Spol
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Spol',
                            prefixIcon: Icon(Icons.wc_outlined),
                          ),
                          items: _genderOptions.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedGender = value);
                          },
                        ),
                        const SizedBox(height: 32),

                        // Sacuvaj dugme
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _handleSave,
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'SACUVAJ PROMJENE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDateOfBirth = date);
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final user = context.read<UserProfileCubit>().state.user;
      if (user == null) return;

      context.read<UserProfileCubit>().updateProfile(
            currentUser: user,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            dateOfBirth: _selectedDateOfBirth,
            gender: _selectedGender,
            newProfileImage: _selectedImage,
          );
    }
  }
}
