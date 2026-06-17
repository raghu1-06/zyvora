import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZeniBottomSheet extends StatefulWidget {
  const ZeniBottomSheet({super.key});

  @override
  State<ZeniBottomSheet> createState() => _ZeniBottomSheetState();
}

class _ZeniBottomSheetState extends State<ZeniBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String _parsedTitle = "";
  String _parsedDate = "";
  String _parsedTime = "";

  void _onTextChanged(String val) {
    if (mounted) {
      setState(() {
        _parsedTitle = val;
        _parsedDate = val.toLowerCase().contains("tomorrow") ? "Tomorrow" : "Today";
        _parsedTime = val.contains("8pm") ? "20:00" : (val.contains("3:30") ? "15:30" : "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(50))),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              Text("Quick Capture", style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _onTextChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Type naturally...",
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFF7C3AED)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          if (_parsedTitle.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Parsed Task", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(4)),
                        child: Text("High Confidence", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_parsedTitle, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B33))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(_parsedDate, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7C3AED))),
                        backgroundColor: const Color(0xFFEDE9FE),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                      ),
                      if (_parsedTime.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(_parsedTime, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFF59E0B))),
                          backgroundColor: const Color(0xFFFEF3C7),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF6B7280))),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Confirm", style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
