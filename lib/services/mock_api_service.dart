import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/work.dart';
import '../models/session_task.dart';

class MockApiService implements ApiService {
  final Map<String, int> _turnIndexByWork = {};

  // 테스트용 지문 기반(테스트용 지문.txt) “튜터 응답” 스크립트
  static const List<String> _tutorScript = [
    "글에서 가장 눈에 띄는 단어나 구절은 무엇인가요? 그 단어나 구절이 반복되거나 다른 부분과 차별화되는 이유는 무엇일까요? 그 단어나 구절이 설명하는 바가 무엇이라고 생각하나요?",
    "춘향전에서 이별의 장면이 반복적으로 등장하는 이유는 무엇일까요? 춘향전은 단순한 사랑 이야기일까요? 아니면 다른 의미를 담고 있을까요? 이별이라는 상황이 춘향전의 주제와 어떻게 연결될 수 있을까요?",
    "춘향이가 이별의 상황에서 충절을 지킨다는 것은 당시 사회에서 여성에게 어떤 의미였을까요? 춘향이가 처한 시대적 배경을 고려해보세요. 만약 춘향이가 양반 가문의 여인이었다면, 그의 선택은 어떻게 달라졌을까요?",
    // 데모용 마무리(추가)
    "정확합니다. 당시 신분제의 한계 속에서도 춘향이 지킨 '충절'은 단순한 사랑을 넘어선, 자신의 신념을 증명하는 행위였다고 볼 수 있죠. 이 점을 정확히 짚어주셨네요. \n\n지금까지의 대화를 바탕으로 사고력 정밀 진단 리포트를 생성했습니다.",
  ];

  @override
  Future<List<Work>> getWorks() async {
    return [
      Work(
        id: 'simcheong',
        title: '심청전',
        author: '작자미상',
        category: '고전소설',
        baseColor: const Color(0xFFD7CCC8),
        patternColor: const Color(0xFF8D6E63),
        spineColor: const Color(0xFF5D4037),
      ),
      Work(
        id: 'gwandong',
        title: '관동별곡',
        author: '정철',
        category: '고전시가',
        baseColor: const Color(0xFFC8E6C9),
        patternColor: const Color(0xFF2E7D32),
        spineColor: const Color(0xFF1B5E20),
      ),
    ];
  }

  @override
  Future<List<String>> getWorkContent(String workId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (workId == 'simcheong') {
      return [
        "심청이 거동 봐라.",
        "밥 빌러 나갈 제, 치마 자락을 거둠거둠 안고...",
        "\"아가 아가 심청 아가. 이리 와서 점심이나 먹고 가라.\"",
        "심청이 생각한들 아니 슬플소냐.",
      ];
    }

    return [
      "춘향이별가",
      "만금 같은 너를 만나 백년해로하잤더니, 금일 이별 어이하리! 너를 두고 어이 가잔 말이냐? 나는 아마도 못 살겠다! 내 마음에는 어르신네 공조참의 승진 말고, 이 고을 풍헌(風憲)만 하신다면 이런 이별 없을 것을, 생눈 나올 일을 당하니, 이를 어이한단 말인고? 귀신이 장난치고 조물주가 시기 하니, 누구를 탓하겠냐마는 속절없이 춘향을 어찌할 수 없네! 네 말이 다 못 될 말이니, 아무튼 잘 있거라! 춘향이 대답하되, 우리 당초에 광한루에서 만날 적에 내가 먼저 도련님더러 살자 하였소? 도련님이 먼저 나에게 하신 말씀은 다 잊어 계시오? 이런 일이 있겠기로 처음부터 마다 하지 아니하였소? 우리가 그때 맺은 금석 같은 약속 오늘날 다 허사로세! 이리해서 분명 못 데려가겠소? 진정 못 데려가 겠소? 떠보려고 이리하시오? 끝내 아니 데려가시려 하오? 정 아니 데려가실 터이면 날 죽이고 가오! 그렇지 않으면 광한루에서 날 호리려고 명문(明文) 써 준 것이 있으니, 소지(所志) 지어 가지고 본관 원님께 이 사연을 하소연하겠소. 원님이 만일 당신의 귀공자 편을 들어 패소시키시면, 그 소지를 덧붙이고 다시 글을 지어 전주 감영에 올라가서 순사또께 소장(訴狀)을 올리겠소. 도련님은 양반이기에 편지 한 장만 부치면 순사또도 같은 양반이라 또 나를 패소시키거든, 그 글을 덧붙여 한양 안에 들어가서, 형조와 한성부와 비변사까지 올리면 도련님은 사대부라 여기저기 청탁하여 또다시 송사에서 지게 하겠지요. 그러면 그 판결문을 모두 덧보태어 똘똘 말아 품에 품고 팔만장안 억만가호마다 걸식하며 다니다가, 돈 한 푼씩 빌어 얻어서 동이전에 들어가 바리뚜껑 하나 사고, 지전으로 들어가 장지 한 장 사서 거기에다 언문으로 상언(上言)을 쓸 때, 마음속에 먹은 뜻을 자세히 적어 이월이나 팔월이나, 동교(東郊)로나 서교(西郊)로나 임금님이 능에 거둥하실 때, 문밖으로 내달아 백성의 무리 속에 섞여 있다가, 용대기(龍大旗)가 지나가고, 협연군(挾輦軍)의 자개창이 들어서며, 붉은 양산이 따라오며, 임금님이 가마나 말 위에 당당히 지나가실제, 왈칵 뛰어 내달아서 바리뚜껑 손에 들고, 높이 들어 땡땡하고 세 번만 쳐서 억울함을 하소연하는 격쟁(擊錚)을 하오리다! 애고애고 설운지고! 그것도 안 되거든, 애쓰느라 마르고 초조해하다 죽은 후에 넋이라도 삼수갑산 험한 곳을 날아다니는 제비가 되어 도련님 계신 처마에 집을 지어, 밤이 되면 집으로 들어가는 체하고 도련님 품으로 들어가 볼까! 이별 말이 웬 말이오? 이별이란 두 글자 만든 사람은 나와 백 년 원수로다! 진시황이 분서(焚書)할 때 이별 두 글자를 잊었던가? 그때 불살랐다면 이별이 있을쏘냐? 박랑사(博浪沙)*에서 쓰고 남은 철퇴를 천하장사 항우에게 주어 힘껏 둘러메어 이별 두 글자를 깨치고 싶네! 옥황전에 솟아올라 억울함을 호소하여, 벼락을 담당하는 상좌가 되어 내려와 이별 두 글자를 깨치고 싶네! - 작자 미상, 춘향전- * 박랑사 : 중국 지명. 장량이 진시황을 암살하려 했던 곳. 이별이라네 이별이라네 이 도령 춘향이가 이별이로다 춘향이가 도련님 앞에 바짝 달려들어 눈물짓고 하는 말이 도련님 들으시오 나를 두고 못 가리다 나를 두고 가겠으면 홍로화(紅爐火) 모진 불에 다 사르겠으면 사르고 가시오 날 살려 두고는 못 가시리라 잡을 데 없으시면 삼단같이 좋은 머리를 휘휘칭칭 감아쥐고라도 날 데리고 가시오 살려 두고는 못 가시리다 날 두고 가겠으면 용천검(龍泉劍) 드는 칼로다 요 내 목을 베겠으면 베고 가시오 날 살려 두고는 못 가시리라 두어 두고는 못 가시리다 날 두고 가겠으면 영천수(潁川水) 맑은 물에다 던지겠으면 던지고나 가시오 날 살려 두고는 못 가시리다 이리 한참 힐난하다 할 수 없이 도련님이 떠나실 때 방자 놈 분부하여 나귀 안장 고이 지으니 도련님이 나귀 등에 올라앉으실 때 춘향이 기가 막혀 미칠 듯이 날뛰다가 우르르 달려들어 나귀 꼬리를 부여잡으니 나귀 네 발로 동동 굴러 춘향 가슴을 찰 때 안 나던 생각이 절로 나 그때에 이별 별(別) 자 내인 사람 나와 한백 년 대원수로다 깨치리로다 깨치리로다 박랑사 중 쓰고 남은 철퇴로 천하장사 항우 주어 이별 두 자를 깨치리로다 할 수 없이 도련님이 떠나실 때 향단이 준비했던 주안을 갖추어 놓고 풋고추 겨리김치 문어 전복을 곁들여 놓고 잡수시오 잡수시오 이별 낭군이 잡수시오 언제는 살자 하고 화촉동방(華燭洞房) 긴긴 밤에 청실홍실로 인연을 맺고 백 년 살자 언약할 때 물을 두고 맹세하고 산을 두고 증삼(曾參)* 되자더니 산수 증삼은 간 곳이 없고 이제 와서 이별이란 웬 말이오 잘 가시오 잘 있거라 산첩첩(山疊疊) 수중중(水重重)한데 부디 편안히 잘 가시오 나도 명년 양춘가절*이 돌아오면 또다시 상봉할까나 - 작자 미상, 춘향이별가- * 증삼 : 공자의 제자. 고지식하여 약속을 반드시 지킴. * 양춘가절 : 따뜻하고 좋은 봄철.",
    ];
  }

  // 세션 시작 시 보여줄 첫 안내 멘트
  @override
  Future<String> startThinkingSession(String workId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    _turnIndexByWork[workId] = 0;

    return "좋아요. 먼저 학생이 궁금한 걸 질문해보세요. 예: \"이 구절이 왜 중요한지 모르겠어.\"";
  }

  @override
  Future<Map<String, dynamic>> getGuidance(String workId, String userAnswer) async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final trimmed = userAnswer.trim();

    // 너무 짧으면 턴 진행 X
    if (trimmed.length < 5) {
      return {
        "text": "조금 더 구체적으로 이야기해 줄래요? 가능하면 본문 표현(단어/구절)을 같이 언급해보면 좋아요.",
        "is_finish": false,
      };
    }

    // 세션 시작을 안 거쳤더라도 안전하게 초기화
    _turnIndexByWork.putIfAbsent(workId, () => 0);

    final idx = _turnIndexByWork[workId]!;
    if (idx < _tutorScript.length) {
      _turnIndexByWork[workId] = idx + 1;

      final isLast = (idx == _tutorScript.length - 1);
      return {
        "text": _tutorScript[idx],
        "is_finish": isLast, // 마지막 멘트는 종료(true)
      };
    }

    return {
      "text": "좋아요. 여기까지 내용을 바탕으로 리포트를 생성해볼까요?",
      "is_finish": true,
    };
  }

  @override
  Future<List<Task>> getTasks(String workId) async => [];

  @override
  Future<Map<String, dynamic>> submitResult(String workId, dynamic logs) async => {};
}
