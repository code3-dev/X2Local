import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:x2local/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('X2Local'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.toNamed('/about');
            },
          ),
        ],
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Download X Videos & Audio',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Paste the X (Twitter) URL and select download type',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // URL Input
                _buildUrlInput(),
                const SizedBox(height: 24),

                // Type Selection
                const Text(
                  'Select Download Type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildTypeSelection(),
                const SizedBox(height: 40),

                // Download Button
                _buildDownloadButton(),
                const SizedBox(height: 24),

                // Progress and Status
                _buildProgressSection(),
                const SizedBox(height: 24),

                // Single Format Section
                _buildSingleFormatSection(),

                // Formats Section
                _buildFormatsSection(),

                // Result Section
                _buildResultSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlInput() {
    return Obx(
      () => TextField(
        onChanged: controller.updateUrl,
        controller: TextEditingController()..text = controller.url.value,
        decoration: InputDecoration(
          labelText: 'X (Twitter) URL',
          hintText: 'https://x.com/username/status/123456789',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          prefixIcon: const Icon(Icons.link, size: 28),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.resetForm,
          ),
          filled: true,
          fillColor: Theme.of(Get.context!).cardColor,
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Obx(
      () => Row(
        children: [
          _buildTypeOption(controller, '.mp4', 'Video', Icons.video_library),
          const SizedBox(width: 20),
          _buildTypeOption(controller, '.mp3', 'Audio', Icons.audiotrack),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    HomeController controller,
    String type,
    String label,
    IconData icon,
  ) {
    final Color primaryColor =
        Theme.of(Get.context!).brightness == Brightness.dark
        ? const Color(0xFF6A0DAD)
        : Theme.of(Get.context!).colorScheme.primary;

    return Expanded(
      child: Card(
        color: controller.selectedType.value == type
            ? primaryColor
            : Theme.of(Get.context!).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          onTap: () => controller.updateType(type),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: controller.selectedType.value == type
                      ? Colors.white
                      : primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: controller.selectedType.value == type
                        ? Colors.white
                        : Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.selectedType.value == type
                        ? Colors.white70
                        : Theme.of(
                            Get.context!,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    final Color primaryColor =
        Theme.of(Get.context!).brightness == Brightness.dark
        ? const Color(0xFF6A0DAD)
        : Theme.of(Get.context!).colorScheme.primary;

    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.requestDownload,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Get Download Links',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final Color primaryColor =
        Theme.of(Get.context!).brightness == Brightness.dark
        ? const Color(0xFF6A0DAD)
        : Theme.of(Get.context!).colorScheme.primary;

    return Obx(
      () => Column(
        children: [
          if (controller.downloadStatus.value.isNotEmpty)
            Text(
              controller.downloadStatus.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          const SizedBox(height: 12),
          if (controller.downloadProgress.value > 0)
            LinearProgressIndicator(
              value: controller.downloadProgress.value / 100,
              borderRadius: BorderRadius.circular(12),
              backgroundColor: primaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 12,
            ),
        ],
      ),
    );
  }

  Widget _buildSingleFormatSection() {
    final Color primaryColor =
        Theme.of(Get.context!).brightness == Brightness.dark
        ? const Color(0xFF6A0DAD)
        : Theme.of(Get.context!).colorScheme.primary;

    return Obx(() {
      // Additional null check inside the Obx builder
      if (!controller.showFormats.value ||
          controller.response.value == null ||
          (controller.response.value!.formats.isNotEmpty) ||
          (controller.response.value!.filename.isEmpty)) {
        return const SizedBox.shrink();
      }

      final response = controller.response.value!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        response.type == '.mp4' ? 'Video' : 'Audio',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        response.type.toUpperCase(),
                        style: TextStyle(fontSize: 16, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Responsive action buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 400) {
                        // Wide screen - horizontal layout
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.download,
                                label: 'Download',
                                onPressed: controller.isWeb
                                    ? () => controller.downloadInBrowserDirect(
                                        'https://${response.host}/${response.filename}',
                                      )
                                    : controller.downloadInAppForSingleFormat,
                              ),
                            ),
                            if (!controller.isWeb) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.open_in_browser,
                                  label: 'Open',
                                  onPressed: () => controller.downloadInBrowser(
                                    'https://${response.host}/${response.filename}',
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.copy,
                                label: 'Copy',
                                onPressed: () => controller.copyLink(
                                  'https://${response.host}/${response.filename}',
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Narrow screen - vertical layout
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: _buildActionButton(
                                icon: Icons.download,
                                label: 'Download',
                                onPressed: controller.isWeb
                                    ? () => controller.downloadInBrowserDirect(
                                        'https://${response.host}/${response.filename}',
                                      )
                                    : controller.downloadInAppForSingleFormat,
                              ),
                            ),
                            if (!controller.isWeb) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: _buildActionButton(
                                  icon: Icons.open_in_browser,
                                  label: 'Open',
                                  onPressed: () => controller.downloadInBrowser(
                                    'https://${response.host}/${response.filename}',
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: _buildActionButton(
                                icon: Icons.copy,
                                label: 'Copy',
                                onPressed: () => controller.copyLink(
                                  'https://${response.host}/${response.filename}',
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFormatsSection() {
    final Color primaryColor =
        Theme.of(Get.context!).brightness == Brightness.dark
        ? const Color(0xFF6A0DAD)
        : Theme.of(Get.context!).colorScheme.primary;

    return Obx(() {
      // Additional null check inside the Obx builder
      if (!controller.showFormats.value ||
          controller.response.value == null ||
          controller.response.value!.formats.isEmpty) {
        return const SizedBox.shrink();
      }

      final response = controller.response.value!;
      // Sort formats by quality using the controller method
      final sortedFormats = controller.sortFormatsByQuality(response.formats);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Formats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedFormats.length,
            itemBuilder: (context, index) {
              final format = sortedFormats[index];
              final downloadUrl = 'https://${format.host}/${format.filename}';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Process format label to make it more user-friendly
                          Text(
                            controller.processFormatLabel(format.label),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            response.type.toUpperCase(),
                            style: TextStyle(fontSize: 16, color: primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Responsive action buttons
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 400) {
                            // Wide screen - horizontal layout
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.download,
                                    label: 'Download',
                                    onPressed: controller.isWeb
                                        ? () => controller
                                              .downloadInBrowserDirect(
                                                downloadUrl,
                                              )
                                        : () =>
                                              controller.downloadInApp(format),
                                  ),
                                ),
                                if (!controller.isWeb) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.open_in_browser,
                                      label: 'Open',
                                      onPressed: () => controller
                                          .downloadInBrowser(downloadUrl),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.copy,
                                    label: 'Copy',
                                    onPressed: () =>
                                        controller.copyLink(downloadUrl),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Narrow screen - vertical layout
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildActionButton(
                                    icon: Icons.download,
                                    label: 'Download',
                                    onPressed: controller.isWeb
                                        ? () => controller
                                              .downloadInBrowserDirect(
                                                downloadUrl,
                                              )
                                        : () =>
                                              controller.downloadInApp(format),
                                  ),
                                ),
                                if (!controller.isWeb) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _buildActionButton(
                                      icon: Icons.open_in_browser,
                                      label: 'Open',
                                      onPressed: () => controller
                                          .downloadInBrowser(downloadUrl),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildActionButton(
                                    icon: Icons.copy,
                                    label: 'Copy',
                                    onPressed: () =>
                                        controller.copyLink(downloadUrl),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final Color primaryColor =
        Theme.of(Get.context!).brightness == Brightness.dark
        ? const Color(0xFF6A0DAD)
        : Theme.of(Get.context!).colorScheme.primary;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(100, 40),
      ),
    );
  }

  Widget _buildResultSection() {
    return Obx(
      () => Visibility(
        visible:
            controller.showResult.value && controller.response.value != null,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Download Completed!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.resetForm,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Title: ${controller.response.value?.title ?? ""}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'File: \${controller.downloadedFilePath.value.split(RegExp(r"[/\\\\\\\\]")).last}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: controller.resetForm,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'Download Another',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        Theme.of(Get.context!).brightness == Brightness.dark
                        ? const Color(0xFF6A0DAD)
                        : Theme.of(Get.context!).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
