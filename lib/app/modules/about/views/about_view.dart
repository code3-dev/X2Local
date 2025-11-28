import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.download_outlined,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'X2Local',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Developed by Hossein Pira',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A powerful and easy-to-use X (Twitter) video and audio downloader.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.telegram,
                  title: 'Telegram',
                  subtitle: '@h3dev',
                  onTap: () async {
                    final Uri telegramUrl = Uri.parse('https://t.me/h3dev');
                    if (await canLaunchUrl(telegramUrl)) {
                      await launchUrl(
                        telegramUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open Telegram. Please make sure Telegram is installed.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: 'h3dev.pira@gmail.com',
                  onTap: () async {
                    final Uri emailUrl = Uri.parse(
                      'mailto:h3dev.pira@gmail.com',
                    );
                    if (await canLaunchUrl(emailUrl)) {
                      await launchUrl(emailUrl);
                    } else {
                      // Show error message if email app is not available
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No email app found. Please install an email app to send emails.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.camera_alt,
                  title: 'Instagram',
                  subtitle: '@h3dev.pira',
                  onTap: () async {
                    final Uri instagramUrl = Uri.parse(
                      'https://instagram.com/h3dev.pira',
                    );
                    if (await canLaunchUrl(instagramUrl)) {
                      await launchUrl(
                        instagramUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open Instagram. Please make sure Instagram is installed.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'License',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This application is provided as-is without any warranties. '
                  'You are free to use and distribute this application in accordance with the applicable laws and regulations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
