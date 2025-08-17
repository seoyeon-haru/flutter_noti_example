import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 백그라운드에서 실행될 함수
/// LocalNotification 백그라운드에서 실행되는 함수는
/// 런 타임 내 앱 내에서 실행이 되지 않고 백그라운드에서 실행이 됨
/// 그래서 앱 내부적으로 notificationTapOnBackground 함수를 직접적으로 호츨하는 곳
/// 함수가 직접적으로 호출되지 않을 때 다트 컴파일러가 릴리즈 모드로 빌드를 할 때= 기계어로 직접 바꿀 때
/// 그 때 사용하지 않는 함수를 제거하게 됨
/// 그 때 @pragma('vm: entry-point') 붙여주면 이 함수가 지금 앱 내에서 사용하지는 않지만
/// 나중에 사용되는 함수니까 지우지 말라고 다트 컴파일러에게 알려주는 역할을 하게 됨
@pragma('vm: entry-point')
void notificationTapOnBackground(NotificationResponse response) {
  // 백그라운드에서 푸시알림 터치했을 때 실행할 로직 작성
  print(response.payload);
}

class NotificationHelper {
  /// FlutterLocalNotificationsPlugin 객체 생성
  /// FlutterLocalNotificationsPlugin 을 사용하려면 초기화 해줘야 함
  static final flutterNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. 안드로이드 초기화 설정 만들어야 됨
    /// @mipmap/ic_launcher 는 android-> app -> src -> main -> res
    /// 다 담겨있는 폴더며 안에 앱 아이콘들을 가르킴
    final androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    // 2. IOS 초기화 설정
    final darwinSetting = DarwinInitializationSettings(
      // 각각 알림 권한 요청
      requestAlertPermission: true,
      // 뱃지 권한
      requestBadgePermission: true,
      // 사운드 권한
      requestSoundPermission: true,
    );

    final initSetting = InitializationSettings(
      android: androidSetting,
      iOS: darwinSetting,
    );

    /// 만든 세팅들을 기반으로 FlutterLocalNotificationsPlugin 초기화 해줘야 함
    await flutterNotificationsPlugin.initialize(
      initSetting,
      // 포그라운드 (앱이 열려있을 때) 푸시알림 터치했을 때 실행되는 함수
      onDidReceiveNotificationResponse: (details) {
        print(details.payload);
      },
      // 백그라운드 (앱이 닫혀있을 때) 푸시알림 터치하면 앱이 실행되면서 이 속성에 정의한 함수가 실행됨
      onDidReceiveBackgroundNotificationResponse: notificationTapOnBackground,
    );

    /// initialize 가 끝나면 안드로이드 33 이상부터 권한을 요청해야함
    /// resolvePlatformSpecificImplementation 는 flutterNotificationsPlugin 안에서
    /// AndroidFlutterLocalNotificationsPlugin 타입을 찾아서 리턴해주는 역할을 하게 됨
    final androidPlugin =
        flutterNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> show(String title, String content) async {
    // 실제로 푸시 알림 보내는 기능 구현
    flutterNotificationsPlugin.show(
      // 알림 ID => 중복된 알림 관리하기 위한 고유 ID
      0,
      title,
      content,
      NotificationDetails(
        // 상세 정보 넣을 수 있음
        android: AndroidNotificationDetails(
          // 안드로이드 8.0 이상에서 알림을 그룹화하는데 사용되는 ID
          'test channel id',
          // 설정에서 보여지는 알림 채널 이름
          'General Notifications',
          // 알림에 우선 순위를 결정함
          importance: Importance.high,
          // 알림 울렸을 때 소리 나도록 설정
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          // 알림 소리 재생 여부
          presentSound: true,
          // 알림 표시 여부
          presentAlert: true,
          // 배지 표시 여부
          presentBadge: true,
        ),
      ),

      /// 사용자가 알림 터치했을 때 payload 값이 백그라운드 함수나 위에서 설정한
      /// onDidReceiveNotificationResponse
      ///  함수에 details 부분에 담겨서 넘어오게 됨
      // 알림에 부가적인 데이터 담는 용도
      payload: 'hi',
    );
  }
}
