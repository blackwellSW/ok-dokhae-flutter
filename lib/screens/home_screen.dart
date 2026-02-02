import 'package:flutter/material.dart';

// [데이터 모델]
class Book {
  final String title;
  final String author;
  final String category; // '고전소설', '고전시가'
  final Color baseColor; // 배경색
  final Color patternColor; // 문양 색상
  final Color spineColor; // 책등 색상
  final int completedSets;
  final String studyTime;
  final String difficulty;

  Book({
    required this.title,
    required this.author,
    required this.category,
    required this.baseColor,
    required this.patternColor,
    required this.spineColor,
    this.completedSets = 0,
    this.studyTime = '5분',
    this.difficulty = '중',
  });
}

// [더미 데이터]
final List<Book> allBooks = [
  Book(
    title: '심청전',
    author: '작자미상',
    category: '고전소설',
    baseColor: const Color(0xFFD7CCC8), // 베이지
    patternColor: const Color(0xFF8D6E63), // 갈색 문양
    spineColor: const Color(0xFF5D4037),
    completedSets: 3,
    studyTime: '7분',
    difficulty: '중',
  ),
  Book(
    title: '관동별곡',
    author: '정철',
    category: '고전시가',
    baseColor: const Color(0xFFC8E6C9), // 연두
    patternColor: const Color(0xFF2E7D32), // 녹색 문양
    spineColor: const Color(0xFF1B5E20),
    completedSets: 0,
    studyTime: '10분',
    difficulty: '상',
  ),
  Book(
    title: '홍길동전',
    author: '허균',
    category: '고전소설',
    baseColor: const Color(0xFFFFE0B2), // 오렌지
    patternColor: const Color(0xFFEF6C00),
    spineColor: const Color(0xFFE65100),
    completedSets: 0,
    studyTime: '6분',
    difficulty: '하',
  ),
  Book(
    title: '춘향전',
    author: '작자미상',
    category: '고전소설',
    baseColor: const Color(0xFFFFCCBC), // 살구
    patternColor: const Color(0xFFD84315),
    spineColor: const Color(0xFFBF360C),
    completedSets: 1,
    studyTime: '8분',
    difficulty: '중',
  ),
  Book(
    title: '청산별곡',
    author: '작자미상',
    category: '고전시가',
    baseColor: const Color(0xFFDCEDC8), // 라임
    patternColor: const Color(0xFF558B2F),
    spineColor: const Color(0xFF33691E),
    completedSets: 0,
    studyTime: '5분',
    difficulty: '중',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = '전체';

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const primaryColor = Color(0xFF4E342E);
    const accentColor = Color(0xFF8D6E63);

    List<Book> filteredBooks = _selectedFilter == '전체'
        ? allBooks
        : allBooks.where((b) => b.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            '나의 서재',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: primaryColor),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              // 1. Hero 섹션
              Row(
                children: [
                  const Icon(Icons.history_edu, size: 20, color: accentColor),
                  const SizedBox(width: 8),
                  const Text(
                    '오늘의 추천 학습',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecentBookCard(context),

              const SizedBox(height: 32),

              // 2. 전체 작품 리스트
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grid_view_rounded, size: 20, color: accentColor),
                      const SizedBox(width: 8),
                      const Text(
                        '전체 작품',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('전체'),
                        const SizedBox(width: 8),
                        _buildFilterChip('고전소설'),
                        const SizedBox(width: 8),
                        _buildFilterChip('고전시가'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 24,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  return _buildBookCover(context, filteredBooks[index]);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmarks_outlined), label: '저장'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'MY'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4E342E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  // [상단 카드] "심" 대신 중앙에 문양 배치
  Widget _buildRecentBookCard(BuildContext context) {
    final book = allBooks[0];

    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // [표지]
          Container(
            width: 110,
            decoration: BoxDecoration(
              color: book.baseColor, // 깔끔한 단색 배경
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                // 책등
                Positioned(
                  left: 12, top: 0, bottom: 0,
                  child: Container(width: 2, color: Colors.black.withOpacity(0.1)),
                ),
                // [핵심] 중앙 문양 (Emblem) - 글자 대신 들어감
                Center(
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), // 은은한 배경
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: ClipOval(
                      child: CustomPaint(
                        painter: CloudPatternPainter(
                          color: book.patternColor.withOpacity(0.6), // 문양 색상
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // [정보]
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E342E), 
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '4문항 실전 세트: 어휘·근거·Why·랜덤',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    '이 작품: ${book.completedSets}세트 완료', 
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                         print('${book.title} 학습 시작');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4037),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '학습 시작 (${book.studyTime})',
                            style: const TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // [목록 카드]
  Widget _buildBookCover(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        print('${book.title} 선택됨');
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: book.baseColor, // 깔끔한 단색
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(4), 
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 책등
                  Positioned(
                    left: 0, top: 0, bottom: 0, width: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: book.spineColor.withOpacity(0.6),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // 중앙 장식 문양 (작게)
                  Positioned(
                    top: 20, right: 20,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: CustomPaint(
                          painter: CloudPatternPainter(
                            color: book.patternColor.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 정보 텍스트
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.difficulty == '상' ? '난이도 상' : 
                                book.difficulty == '중' ? '난이도 중' : '입문 추천',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3E2723),
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '4문항 세트 · ${book.studyTime}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// [CustomPainter] 구름/물결 문양 (인장 안에 들어갈 패턴)
class CloudPatternPainter extends CustomPainter {
  final Color color;

  CloudPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var path = Path();
    // 부드러운 구름/물결 느낌의 곡선 반복
    for (double i = 0; i < size.height + 20; i += 15) {
      path.moveTo(0, i);
      for (double x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(x + 10, i - 8, x + 20, i);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}