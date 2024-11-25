# onlyveyou

only've you


# 💡 Topic

- 원하는 화장품을 언제 어디서든 찾을 수 있는 **검색**
- 내가 사고 싶은 상품을 산 사람의 **생생 리뷰**
- 나만의 뷰티 꿀팁을 주고받는 코덕들의 **커뮤니티**
- 화장이 처음이라 뭘 검색할 지 몰라도 괜찮아! **AI추천**

# 📝 Summary

이 프로젝트는 Bloc 상태 관리, Firebase 기능 사용을 활용하여 다양한 기술적 경험을 쌓는 데 중점을 두었습니다.

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


# 🤔 Learned

- **실시간 데이터 처리**: Firebase Firestore를 사용하여 실시간으로 데이터를 동기화하고, 이를 기반으로 투표 결과창을 구현하는 방법을 배웠습니다.
- **상태 관리 개선**: MVVM 아키텍처와 Riverpod 상태 관리 방식을 채택하여 코드의 가독성을 높이고 팀원 간의 협업을 수월하게 했습니다.
- **FCM**: Firebase에서 Function을 배포하면서 서버리스 개념에 대해 배웠습니다. firebase database 에서 user목록 모두 연결시켜서 모든 유저들에게 푸쉬알림 보내도록 하는 법을 배웠습니다.
- **Git을 활용한 협업**: Git 컨벤션을 지키며, 협업 시 발생하는 코드 충돌을 해결하고 효율적인 브랜치 관리를 배웠습니다.

# 📷 Screenshot
