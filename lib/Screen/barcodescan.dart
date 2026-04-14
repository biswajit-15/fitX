import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanned = false;

  //Initialize controller with restricted formats (NO QR)
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
      ],
      // Optional: Add resolution or facing properties here if needed
    );
  }

  @override
  void dispose() {
    //  Dispose of the controller to free up camera resources
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final barcode = capture.barcodes.first;

    //  Reject QR Codes explicitly (extra safety defense-in-depth)
    if (barcode.format == BarcodeFormat.qrCode) {
      return;
    }

    final String? value = barcode.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _isScanned = true);

    HapticFeedback.mediumImpact();

    // Return scanned barcode
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          //  Pass the configured controller to the scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Scan Barcode',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balances the close icon
                    ],
                  ),
                ),

                const Spacer(),

                // ✅ Updated Scan frame: Rectangular for 1D Barcodes
                Container(
                  width: 320,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _isScanned
                      ? '✓ Code Detected'
                      : 'Point camera at a barcode',
                  style: TextStyle(
                    color: _isScanned
                        ? const Color(0xFF4ADE80)
                        : Colors.white70,
                    fontSize: 14,
                    fontWeight: _isScanned ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),

                const Spacer(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}