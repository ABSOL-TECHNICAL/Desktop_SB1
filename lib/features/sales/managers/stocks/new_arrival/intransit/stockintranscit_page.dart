import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/branch_transfers/view/branctransfers.dart';
import 'package:impal_desktop/features/sales/managers/stocks/new_arrival/intransit/grn1/view/grn1.dart';

class IntranscitPage extends StatefulWidget {
  const IntranscitPage({super.key});

  @override
  _IntranscitPageState createState() => _IntranscitPageState();
}

class _IntranscitPageState extends State<IntranscitPage>
    with TickerProviderStateMixin {
  bool _isHoveredInward = false;
  bool _isHoveredIntransit = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'In Transit',
          style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedCard(
                icon: Icons.input,
                title: 'Branch Transfers'.tr,
                isHovered: _isHoveredInward,
                iconColor: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BranchTransfersPage(),
                    ),
                  );
                },
                onHover: (isHovered) {
                  setState(() {
                    _isHoveredInward = isHovered;
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildAnimatedCard(
                icon: Icons.insert_drive_file,
                title: 'GRN1'.tr,
                isHovered: _isHoveredIntransit,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Grn1Page()),
                  );
                },
                onHover: (isHovered) {
                  setState(() {
                    _isHoveredIntransit = isHovered;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required IconData icon,
    required String title,
    required bool isHovered,
    required Color iconColor,
    required VoidCallback onTap,
    required ValueChanged<bool> onHover,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: AnimatedScale(
          scale: isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.5),
            child: SizedBox(
              width: 250,
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 60, color: iconColor),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
