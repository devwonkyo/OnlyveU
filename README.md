# onlyveyou

only've you

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# 💡 Topic

- Riverpod을 활용한 실시간 토론 및 투표 앱
- 'UpDown' 앱은 특정 인물에 대한 토론을 하고 투표하는 기능을 제공하는 프로젝트입니다.
- 사용자들은 실시간으로 의견을 나누고, 투표를 통해 해당 인물이 '잘못했다'고 생각하는지 결정합니다.

# 📝 Summary

이 프로젝트는 riverpod 상태 관리, FCM 기능 사용, 실시간 데이터 반영 등의 다양한 기술적 경험을 쌓는 데 중점을 두었습니다.

# ⭐️ Key Function

- **소셜 로그인 기능(me : 페이스북 로그인 담당)**
- **채팅방 관리**
- **fcm 푸쉬알림 기능(담당 파트)**
    - 관리자가 채팅방을 생성하면 Firestore Database 에 저장된 모든 유저에게 방이 생성되었다고 FCM 푸쉬알림이 갑니다.
- **이미지 공유 기능**
- **실시간 투표 및 결과 반영(담당 파트)**
    - 사용자들은 실시간으로 투표를 할 수 있으며, 투표 결과는 Firebase Firestore를 통해 즉시 반영됩니다.
- **실시간 채팅 기능**

# 🛠 Tech Stack

`flutter`, `dart`, `firebase_auth`, `cloud_firestore`, `riverpod`, `go_router`, `image_picker`, `firebase_storage`, `riverpod_generator`, `freezed`, `build_runner`

# 🧑🏻‍💻 Team

- flutter 개발자 4명

# 🤚🏻 My Part

- **팀장**으로서 프로젝트 개발 총괄
- miro를 활용한 기획 주도 https://miro.com/app/board/uXjVKlx8Aoo=/
- Riverpod 상태 관리를 통한 실시간 투표 결과 기능 구현
- cloud function 배포 후 FCM 푸쉬알림 구현
- Firestore database 연동으로 FCM 설정
- facebook 소셜 로그인, 회원가입
- 인앱 알림
- 시연영상 제작과 발표

# 🤔 Learned

- **실시간 데이터 처리**: Firebase Firestore를 사용하여 실시간으로 데이터를 동기화하고, 이를 기반으로 투표 결과창을 구현하는 방법을 배웠습니다.
- **상태 관리 개선**: MVVM 아키텍처와 Riverpod 상태 관리 방식을 채택하여 코드의 가독성을 높이고 팀원 간의 협업을 수월하게 했습니다.
- **FCM**: Firebase에서 Function을 배포하면서 서버리스 개념에 대해 배웠습니다. firebase database 에서 user목록 모두 연결시켜서 모든 유저들에게 푸쉬알림 보내도록 하는 법을 배웠습니다.
- **Git을 활용한 협업**: Git 컨벤션을 지키며, 협업 시 발생하는 코드 충돌을 해결하고 효율적인 브랜치 관리를 배웠습니다.

# 📷 Screenshot
