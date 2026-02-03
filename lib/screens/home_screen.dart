import 'package:flutter/material.dart';
import 'session_screen.dart';
import '../models/work.dart';
import '../services/api_service.dart';      // [추가] 인터페이스
import '../services/mock_api_service.dart'; // [추가] 구현체

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // [핵심] 서비스와 데이터 Future 선언
  late ApiService _apiService;
  late Future<List<Work>> _worksFuture;

  String _selectedFilter = '전체';
  String _currentCategoryTitle = "고전 문학";

  @override
  void initState() {
    super.initState();
    // 1. 서비스 구현체 주입 (나중에 여기만 HttpApiService로 바꾸면 끝!)
    _apiService = MockApiService();
    
    // 2. 데이터 요청 및 캐싱 (화면이 다시 그려져도 재요청 안 함)
    _worksFuture = _apiService.getWorks();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const primaryColor = Color(0xFF4E342E);
    const accentColor = Color(0xFF8D6E63);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        title: GestureDetector(
          onTap: () => _showCategorySheet(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentCategoryTitle,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded, 
                color: primaryColor,
                size: 28,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.grey),
            tooltip: "서재 정렬 및 필터",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("다음 업데이트에서 정렬/필터 기능이 추가됩니다!"),
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      // [핵심] FutureBuilder로 데이터를 기다림
      body: FutureBuilder<List<Work>>(
        future: _worksFuture,
        builder: (context, snapshot) {
          // 1. 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          // 2. 에러 났을 때
          else if (snapshot.hasError) {
            return Center(child: Text("데이터를 불러오지 못했습니다.\n${snapshot.error}"));
          }
          // 3. 데이터 없음
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("표시할 작품이 없습니다."));
          }

          // 4. 데이터 도착 완료!
          final works = snapshot.data!;
          
          // 필터링 로직
          final filteredWorks = _selectedFilter == '전체'
              ? works
              : works.where((w) => w.category == _selectedFilter).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                children: [
                  // Hero 섹션
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
                  // 첫 번째 작품을 추천작으로 표시 (데이터가 있다는 전제)
                  _buildRecentBookCard(context, works[0]),

                  const SizedBox(height: 32),

                  // 전체 작품 리스트
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
                    itemCount: filteredWorks.length,
                    itemBuilder: (context, index) {
                      return _buildBookCover(context, filteredWorks[index]);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: BottomNavigationBar(
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
      ),
    );
  }

  // (아래부터는 기존 UI 위젯들 - 그대로 유지)
  void _showCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                
                _buildSheetItem("📚 고전 문학", true),
                _buildSheetItem("📰 비문학 (뉴스/사설)", false, tagText: "Beta"),
                _buildSheetItem("💬 영어 지문 독해", false, tagText: "Coming Soon"),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetItem(String title, bool isSelected, {String? tagText}) {
    return ListTile(
      leading: isSelected 
          ? const Icon(Icons.check, color: Color(0xFF3E2723)) 
          : const SizedBox(width: 24),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF3E2723) : Colors.black87,
              fontSize: 16,
            ),
          ),
          if (tagText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
              child: Text(tagText, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            )
          ]
        ],
      ),
      onTap: () {
        if (tagText == null) {
          Navigator.pop(context);
        }
      },
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

  Widget _buildRecentBookCard(BuildContext context, Work work) {
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
          Container(
            width: 110,
            decoration: BoxDecoration(
              color: work.baseColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 12, top: 0, bottom: 0,
                  child: Container(width: 2, color: Colors.black.withOpacity(0.1)),
                ),
                Center(
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: ClipOval(
                      child: CustomPaint(
                        painter: CloudPatternPainter(
                          color: work.patternColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
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
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    work.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '이 작품: ${work.completedSets}세트 완료', 
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionScreen(id: work.id, title: work.title),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4037),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '학습 시작 (${work.studyTime})',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

  Widget _buildBookCover(BuildContext context, Work work) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionScreen(id: work.id, title: work.title),
        ),
      );
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: work.baseColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16), bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(4), bottomLeft: Radius.circular(4),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(4, 4))],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0, top: 0, bottom: 0, width: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: work.spineColor.withOpacity(0.6),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20, right: 20,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                      child: ClipOval(
                        child: CustomPaint(painter: CloudPatternPainter(color: work.patternColor.withOpacity(0.4))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                work.difficulty == '상' ? '난이도 상' : work.difficulty == '중' ? '난이도 중' : '입문 추천',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          work.title,
                          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF3E2723), height: 1.2, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '4문항 세트 · ${work.studyTime}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.5)),
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

class CloudPatternPainter extends CustomPainter {
  final Color color;
  CloudPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    var path = Path();
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