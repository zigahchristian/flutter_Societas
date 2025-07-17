# Cloudinary Setup Guide

This guide explains how to set up Cloudinary for image uploads in the Societas Flutter app.

## Overview

The app uses Cloudinary for secure image uploads and transformations. Profile pictures are automatically resized to 400x400 pixels with face detection for optimal cropping.

## Setup Steps

### 1. Create a Cloudinary Account

1. Go to [https://cloudinary.com/](https://cloudinary.com/)
2. Sign up for a free account
3. Once logged in, go to your Dashboard

### 2. Get Your Credentials

From your Cloudinary Dashboard, you'll need:

- **Cloud Name**: Found at the top of your dashboard
- **API Key**: Found in the "Account Details" section
- **API Secret**: Found in the "Account Details" section (keep this secret!)

### 3. Create an Upload Preset

1. In your Cloudinary Dashboard, go to **Settings** > **Upload**
2. Scroll down to **Upload presets**
3. Click **Add upload preset**
4. Configure the preset:
   - **Preset name**: `societas_unsigned` (or any name you prefer)
   - **Signing Mode**: `Unsigned`
   - **Folder**: `societas_members` (optional but recommended)
   - **Access Mode**: `Public`
   - **Allowed formats**: `jpg,png,jpeg,webp`
   - **Max file size**: `10485760` (10MB)
   - **Image transformations**: You can add default transformations here if needed
5. Click **Save**

### 4. Update Configuration

1. Open `lib/config/cloudinary_config.dart`
2. Replace the placeholder values with your actual credentials:

```dart
class CloudinaryConfig {
  static const String cloudName = 'your-actual-cloud-name';
  static const String apiKey = 'your-actual-api-key';
  static const String apiSecret = 'your-actual-api-secret';
  static const String uploadPreset = 'societas_unsigned'; // or your preset name
  
  // ... other constants remain the same
}
```

### 5. Security Considerations

**Important**: Never commit real credentials to version control!

#### Option A: Environment Variables (Recommended)

1. Create a `.env` file in your project root:
```
CLOUDINARY_CLOUD_NAME=your-actual-cloud-name
CLOUDINARY_API_KEY=your-actual-api-key
CLOUDINARY_API_SECRET=your-actual-api-secret
CLOUDINARY_UPLOAD_PRESET=societas_unsigned
```

2. Add `.env` to your `.gitignore` file

3. Use a package like `flutter_dotenv` to load environment variables

#### Option B: Separate Config File

1. Create `lib/config/cloudinary_config_local.dart` with your real credentials
2. Add this file to `.gitignore`
3. Import this file instead of the template in your service

## How It Works

### Upload Process

1. User selects an image from gallery or camera
2. Image is validated (size, format, etc.)
3. Image is uploaded to Cloudinary using the unsigned upload preset
4. Cloudinary returns a secure URL
5. The URL is stored in the member's profile

### Image Transformations

The service automatically applies these transformations:
- **Crop**: `c_fill` - Fills the entire 400x400 area
- **Dimensions**: `w_400,h_400` - Resizes to 400x400 pixels
- **Gravity**: `g_face` - Uses face detection for better cropping
- **Quality**: `auto` - Automatic quality optimization
- **Format**: `auto` - Automatic format selection (WebP when supported)

### File Organization

- All member images are stored in the `societas_members` folder
- Images are automatically organized by upload date
- Each image gets a unique public ID for management

## API Methods

### CloudinaryService.uploadImage(File imageFile)

Uploads an image using unsigned upload (recommended for client-side).

```dart
final result = await CloudinaryService.uploadImage(imageFile);
if (result.isSuccess) {
  print('Image URL: ${result.secureUrl}');
} else {
  print('Error: ${result.error}');
}
```

### CloudinaryService.uploadImageSigned(File imageFile)

Uploads an image using signed upload (more secure, requires API secret).

### CloudinaryService.deleteImage(String publicId)

Deletes an image from Cloudinary (requires API secret).

```dart
final success = await CloudinaryService.deleteImage(publicId);
```

## Troubleshooting

### Common Issues

1. **"Upload failed (401): Unauthorized"**
   - Check your cloud name and upload preset
   - Ensure the upload preset is set to "Unsigned"

2. **"Upload failed (400): Invalid upload preset"**
   - Verify the upload preset name is correct
   - Make sure the preset exists in your Cloudinary dashboard

3. **"File size exceeds 10MB limit"**
   - The app limits file size to 10MB
   - You can adjust this in `CloudinaryConfig.maxFileSizeBytes`

4. **Network errors**
   - Check internet connection
   - Verify Cloudinary service status

### Debug Mode

Enable debug mode to see detailed upload information:

```dart
// In your CloudinaryService, add debug prints
print('Uploading to: ${uri.toString()}');
print('Upload preset: ${CloudinaryConfig.uploadPreset}');
print('File size: ${fileSizeInBytes} bytes');
```

## Pricing

Cloudinary offers a generous free tier:
- 25 GB storage
- 25 GB monthly bandwidth
- 25,000 monthly transformations

For production apps with high usage, consider upgrading to a paid plan.

## Additional Resources

- [Cloudinary Flutter Documentation](https://cloudinary.com/documentation/flutter_integration)
- [Upload Presets Guide](https://cloudinary.com/documentation/upload_presets)
- [Image Transformations Reference](https://cloudinary.com/documentation/image_transformation_reference)
