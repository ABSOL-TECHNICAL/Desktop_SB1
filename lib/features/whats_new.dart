// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:impal_desktop/features/login/controllers/login_controller.dart';

// class WhatsNewPage extends StatelessWidget {
//   const WhatsNewPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("What's New"),
//         backgroundColor: isDarkMode ? Colors.black : Colors.blue,
//       ),
//       backgroundColor: isDarkMode ? Colors.black : Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "✨ New Features in v1.0.0",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "• 🔁 E-Credit Approval Flow\n"
//               "• 📊 Sales Dashboard Summary\n"
//               "• ❌ Leave Rejection Reason Dialog\n"
//               "• 🌙 Dark Mode UI improvements\n"
//               "• 🧠 View Order",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: isDarkMode ? Colors.white70 : Colors.black87,
//               ),
//             ),
//             const Spacer(),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isDarkMode ? Colors.white : Colors.blue,
//                   foregroundColor: isDarkMode ? Colors.black : Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 ),
//                 // onPressed: () {
//                 //   final loginController = Get.find<LoginController>();
//                 //   loginController.navigateToHome();
//                 // },
//                 child: const Text(
//                   "Continue",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
