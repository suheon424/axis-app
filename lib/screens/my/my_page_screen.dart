import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/character_picker.dart';
import '../../widgets/kit/kit.dart';
import '../../widgets/status_bar_blur.dart';
import '../welcome_screen.dart';
import 'my_comments_screen.dart';
import 'my_data.dart';
import 'my_posts_screen.dart';
import 'my_widgets.dart';
import 'notice_screen.dart';
import 'notification_settings_screen.dart';
import 'inquiry_screen.dart';
import 'point_history_screen.dart';
import 'profile_edit_screen.dart';
import 'saved_templates_screen.dart';
import 'version_info_screen.dart';
import 'withdraw_screen.dart';

const _pageBg = AppColors.gray01;
const _labelGray = Color(0xFF999999);

/// 12_마이페이지(256:10494): 마이 탭 첫 화면. 프로필 + 보유 포인트 + 나의 활동·고객 지원 메뉴 + 로그아웃·탈퇴.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  /// 배지 보관함 화면(lib/screens/badge/ 담당)을 만드는 함수. main.dart에서 등록한다.
  /// 등록 전이면 "준비 중" 안내를 띄운다.
  static WidgetBuilder? openBadges;

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _logout(BuildContext context) async {
    final ok = await showAxisConfirm(
      context,
      title: '로그아웃할까요?',
      message: '다시 로그인하면 그대로 이어서 볼 수 있어요.',
      confirmLabel: '로그아웃',
      destructive: false,
    );
    if (ok != true || !context.mounted) return;
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  void _openBadges(BuildContext context) {
    final builder = openBadges;
    if (builder == null) {
      showAxisToast(context, '배지 보관함은 준비 중이에요.', bottom: 82);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: _pageBg),
      child: Scaffold(
        backgroundColor: _pageBg,
        bottomNavigationBar: const AxisTabBar(current: MainTab.my),
        // 상태바 자리까지 내용이 올라가고, 그 위에 살짝 블러를 깐다(실제 앱).
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              child: ValueListenableBuilder(
                valueListenable: myProfile,
                builder: (context, profile, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(
                      profile: profile,
                      onEdit: () => _push(context, const ProfileEditScreen()),
                      onPoints: () => _push(context, const PointHistoryScreen()),
                    ),
                    _MenuSection(
                      label: '나의 활동',
                      children: [
                        AxisMenuRow(icon: KitIcon.menuBadge, label: '배지 보관함', onTap: () => _openBadges(context)),
                        AxisMenuRow(
                          icon: KitIcon.menuPost,
                          label: '내가 쓴 게시물',
                          onTap: () => _push(context, const MyPostsScreen()),
                        ),
                        AxisMenuRow(
                          icon: KitIcon.menuComment,
                          label: '내가 쓴 댓글',
                          onTap: () => _push(context, const MyCommentsScreen()),
                        ),
                        AxisMenuRow(
                          icon: KitIcon.menuBookmark,
                          label: '저장한 템플릿',
                          onTap: () => _push(context, const SavedTemplatesScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MenuSection(
                      label: '고객 지원',
                      children: [
                        AxisMenuRow(
                          icon: KitIcon.menuNotice,
                          label: '공지사항',
                          onTap: () => _push(context, const NoticeScreen()),
                        ),
                        AxisMenuRow(
                          icon: KitIcon.menuAlarm,
                          label: '알림 설정',
                          onTap: () => _push(context, const NotificationSettingsScreen()),
                        ),
                        AxisMenuRow(
                          icon: KitIcon.menuSupport,
                          label: '1:1 문의',
                          onTap: () => _push(context, const InquiryScreen()),
                        ),
                        AxisMenuRow(
                          icon: KitIcon.menuInfo,
                          label: '버전 정보',
                          value: MyProfile.appVersion,
                          onTap: () => _push(context, const VersionInfoScreen()),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FooterLink(label: '로그아웃', onTap: () => _logout(context)),
                          const SizedBox(width: 4),
                          _FooterLink(label: '탈퇴하기', onTap: () => _push(context, const WithdrawScreen())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const StatusBarBlur(tint: _pageBg),
          ],
        ),
      ),
    );
  }
}

/// 위쪽 회색 바탕(피그마 12_마이페이지 Frame 170): 가운데 정렬 원형 캐릭터 70 → 10 → "수현 님" → 4 → 한 줄 소개
/// → 10 → 내 정보 수정 → 24 → 사선 모서리 보유 포인트 버튼(350×52) → 20.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.onEdit, required this.onPoints});

  final MyProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onPoints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          MyProfileAvatar(
            character: profile.character,
            background: profile.background == null ? null : characterBackgrounds[profile.background!],
          ),
          const SizedBox(height: 10),
          Text(
            '${profile.callName} 님',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              height: 1.3,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.intro,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: Color(0xFF191F28)),
          ),
          const SizedBox(height: 10),
          PressBuilder(
            semanticLabel: '내 정보 수정',
            onTap: onEdit,
            builder: (_, pressed) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pressed ? AppColors.gray02 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE2E7EE)),
              ),
              child: const Text(
                '내 정보 수정',
                style: TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: Color(0xFF4E5968)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PressBuilder(
            semanticLabel: '보유 포인트 ${formatPoints(profile.points)}P',
            onTap: onPoints,
            builder: (_, pressed) => CustomPaint(
              painter: _PointsButtonPainter(pressed: pressed),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Text(
                        'P',
                        style: TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w600, color: _pointBody),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('보유 포인트', style: _whiteLabel),
                    const SizedBox(width: 24),
                    Text('${formatPoints(profile.points)}P', style: _whiteLabel),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _whiteLabel = TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white);
}

const _pointBody = Color(0xFF004FED);
const _pointCorner = Color(0xFF0041B0);

/// 피그마 Button(보유 포인트)의 Body·Corner 벡터를 그대로 옮긴 모양: 왼쪽은 r8 사각형, 오른쪽 끝 31px는
/// 사선으로 잘린 진한 모서리(둘 사이 7px 사선 틈). 눌리면 조금 어두워진다.
class _PointsButtonPainter extends CustomPainter {
  const _PointsButtonPainter({required this.pressed});

  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const k = 2.66667;
    final body = Path()
      ..moveTo(8, 0)
      ..lineTo(w - 7, 0)
      ..lineTo(w - 38, h)
      ..lineTo(8, h)
      ..cubicTo(k, h, 0, h - k, 0, h - 8)
      ..lineTo(0, 8)
      ..cubicTo(0, k, k, 0, 8, 0)
      ..close();
    final corner = Path()
      ..moveTo(w, 0)
      ..lineTo(w, h - 8)
      ..cubicTo(w, h - k, w - k, h, w - 8, h)
      ..lineTo(w - 31, h)
      ..close();
    final dim = pressed ? Colors.black.withValues(alpha: 0.15) : null;
    Color c(Color base) => dim == null ? base : Color.alphaBlend(dim, base);
    canvas.drawPath(body, Paint()..color = c(_pointBody));
    canvas.drawPath(corner, Paint()..color = c(_pointCorner));
  }

  @override
  bool shouldRepaint(_PointsButtonPainter old) => old.pressed != pressed;
}

/// 흰 바탕 메뉴 묶음: 회색 라벨(14 Medium #999) + 메뉴 줄들.
class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: _labelGray),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: _labelGray),
          ),
        ),
      ),
    );
  }
}
