/*import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class LocalProfilePictureWidget extends StatefulWidget {
  final double size;
  final bool showEditButton;
  final List<Color> gradient;

  const LocalProfilePictureWidget({
    super.key,
    this.size = 80,
    this.showEditButton = false,
    this.gradient = const [Color(0xFF6366F1), Color(0xFFEC4899)],
  });

  @override
  State<LocalProfilePictureWidget> createState() =>
      _LocalProfilePictureWidgetState();
}

class _LocalProfilePictureWidgetState extends State<LocalProfilePictureWidget> {
  final LocalStorageService _storageService = LocalStorageService();
  String? _profilePictureData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  void _loadProfilePicture() {
    setState(() {
      _profilePictureData = _storageService.getProfilePicture();
    });
  }

  Future<void> _uploadProfilePicture() async {
    setState(() => _isLoading = true);

    try {
      final imageData = await _storageService.pickAndSaveImage();

      if (imageData != null) {
        setState(() {
          _profilePictureData = imageData;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture updated successfully!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: _profilePictureData == null
                ? LinearGradient(colors: widget.gradient)
                : null,
            color: _profilePictureData != null ? Colors.grey[300] : null,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : _profilePictureData != null
              ? ClipOval(
                  child: Image.network(
                    _profilePictureData!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: widget.size * 0.5,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
        ),

        // Edit button
        if (widget.showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _uploadProfilePicture,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.gradient),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E293B), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient[0].withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}*/
