import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/widgets/FunCard.dart';
import 'package:vocabsimple/src/components/homepage/vocabulary/voca_main.dart';
import 'package:vocabsimple/src/components/grammar/grammar_list_page.dart';
import 'package:vocabsimple/src/components/test/test_list_page.dart';
=======
import 'package:vocabsimple/src/components/widgets/FunCard.dart';
import 'package:vocabsimple/src/components/homepage/vocabulary/voca_main.dart';
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff

class FunctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // Header: Logo + Tên app
=======
    return Container(
      margin: const EdgeInsets.only(top: 60.0, right: 25.0, left: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo + Tên app + Avatar
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
<<<<<<< HEAD
                        Image.asset("assets/images/LogoApp.png", width: 50, height: 50),
                        const SizedBox(width: 12),
                        Text(
                          "Vocabsimple",
                          style: GoogleFonts.poppins(
                            color: Colors.blue[700],
                            fontSize: 24,
                        fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, color: Colors.blue[700], size: 28),
=======
                  Image.asset("assets/images/LogoApp.png", width: 60, height: 60),
                  const SizedBox(width: 10),
                  Text("Vocabsimple",
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("assets/images/avatar.png"),
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
              ),
            ],
          ),

<<<<<<< HEAD
                const SizedBox(height: 24),
                
                // Tiêu đề Trang chủ
                Text(
                  'Trang chủ',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),
                
=======
          const SizedBox(height: 20),
          const Text('Trang chủ',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

          const SizedBox(height: 15),
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
          // Search bar + Notification
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
<<<<<<< HEAD
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                  ),
                        child: TextField(
                          style: GoogleFonts.inter(fontSize: 15),
                    decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      hintText: 'Tìm kiếm',
                            hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                      border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
=======
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm kiếm',
                      border: InputBorder.none,
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
                    ),
                  ),
                ),
              ),
<<<<<<< HEAD
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                children: [
                          Icon(Icons.notifications_outlined, color: Colors.grey[700], size: 26),
                  Positioned(
                            top: 8,
                            right: 8,
                    child: Container(
                              width: 18,
                              height: 18,
                      decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "2",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                  )
                ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Card Học từ vựng
                InkWell(
=======
              const SizedBox(width: 15),
              Stack(
                children: [
                  const Icon(Icons.notifications_none, size: 27),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle),
                      child: const Text("2",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  )
                ],
              )
            ],
          ),

          const SizedBox(height: 40),

          // List of function (ví dụ: nút học từ vựng)
          FunCard(
            image: 'assets/images/vocabulary.png',
            title: 'Học từ vựng',
            subtitle: 'Theo chủ đề',
            color: Colors.blue.shade400,
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VocaMainPage()),
              );
            },
<<<<<<< HEAD
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background image với opacity
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              'assets/images/vocabulary.png',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Học từ vựng',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Theo chủ đề',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Bắt đầu học',
                                      style: GoogleFonts.inter(
                                        color: Colors.blue[700],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.blue[700], size: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card Học ngữ pháp
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GrammarListPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.purple[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Opacity(
                            opacity: 0.2,
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 180,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Học ngữ pháp',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Các điểm ngữ pháp cơ bản',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Khám phá',
                                        style: GoogleFonts.inter(
                                          color: Colors.purple[700],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, color: Colors.purple[700], size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card Làm bài kiểm tra
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TestListPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[400]!, Colors.green[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Opacity(
                            opacity: 0.2,
                            child: Icon(
                              Icons.quiz_rounded,
                              size: 180,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Làm bài kiểm tra',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kiểm tra kiến thức đã học',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Bắt đầu test',
                                        style: GoogleFonts.inter(
                                          color: Colors.green[700],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.play_arrow, color: Colors.green[700], size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
=======
          ),
        ],
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
      ),
    );
  }
}
