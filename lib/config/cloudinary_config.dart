/// Cloudinary Configuration
/// 
/// To use Cloudinary for image uploads, you need to:
/// 1. Create a Cloudinary account at https://cloudinary.com/
/// 2. Get your credentials from the Cloudinary Dashboard
/// 3. Update the values below with your actual credentials
/// 4. Create an upload preset in your Cloudinary dashboard for unsigned uploads
/// 
/// IMPORTANT: Never commit real credentials to version control!
/// Consider using environment variables or a secure configuration file.

class CloudinaryConfig {
  /// Your Cloudinary cloud name
  /// Found in your Cloudinary dashboard
  static const String cloudName = 'your-cloud-name';
  
  /// Your Cloudinary API key
  /// Found in your Cloudinary dashboard
  static const String apiKey = 'your-api-key';
  
  /// Your Cloudinary API secret
  /// Found in your Cloudinary dashboard
  /// KEEP THIS SECRET - only needed for signed uploads
  static const String apiSecret = 'your-api-secret';
  
  /// Your upload preset name
  /// Create this in your Cloudinary dashboard under Settings > Upload
  /// For unsigned uploads, this preset should be configured as "Unsigned"
  static const String uploadPreset = 'your-upload-preset';
  
  /// Base URL for Cloudinary API
  static const String baseUrl = 'https://api.cloudinary.com/v1_1';
  
  /// Folder name for organizing uploads
  static const String memberImagesFolder = 'societas_members';
  
  /// Image transformation for profile pictures
  /// This creates 400x400 images with face detection for better cropping
  static const String profileImageTransformation = 'c_fill,w_400,h_400,g_face';
  
  /// Maximum file size in bytes (10MB)
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
}
