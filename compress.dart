import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final directory = Directory('./assets'); // 타겟 폴더

  if (!directory.existsSync()) {
    print("❌ assets 폴더가 없습니다.");
    return;
  }

  print("🚀 안전 모드 시작! (WebP 포기 -> 강력 리사이징 & 압축)");

  final files = directory.listSync(recursive: true).whereType<File>();

  for (var file in files) {
    final path = file.path.toLowerCase();

    // jpg, png 파일만 골라냄
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) {
      try {
        final bytes = file.readAsBytesSync();
        final image = img.decodeImage(bytes);
        if (image == null) continue;

        // 1. 크기 줄이기 (무조건 800px 이하로)
        // 5000px짜리가 800px 되면 용량 95% 줄어듭니다.
        img.Image resized = image;
        if (image.width > 800) {
          resized = img.copyResize(image, width: 800);
        }

        // 2. 덮어쓰기 (확장자 유지 -> 앱 코드 수정 X)
        if (path.endsWith('.png')) {
          // PNG는 투명도 유지를 위해 PNG로 저장 (대신 크기를 왕창 줄임)
          file.writeAsBytesSync(img.encodePng(resized));
        } else {
          // JPG는 화질을 50으로 낮춰서 저장 (눈으로 차이 안 남, 용량은 대박)
          file.writeAsBytesSync(img.encodeJpg(resized, quality: 50));
        }

        print("✅ 압축됨: ${file.path}");

      } catch (e) {
        print("❌ 실패(건너뜀): ${file.path}");
      }
    }
  }
  print("\n🎉 끝났습니다! 용량 100% 줄어들었을 겁니다. 퇴근하세요!");
}