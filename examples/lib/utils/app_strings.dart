// 앱 전체에서 사용되는 문자열을 한 곳에 모아두는 클래스
class AppStrings {
  // 공통 문자열
  static const cancel = '취소';
  static const confirm = '확인';
  static const save = '저장';
  static const add = '추가';
  static const back = '돌아가기';
  static const close = '닫기';
  static const share = '공유하기';

  // 메모 관련
  static const memo = '메모';
  static const memoEdit = '메모 편집';
  static const memoModify = '메모 수정';
  static const newMemo = '새 메모';
  static const memoNotFound = '메모를 찾을 수 없습니다.';
  static const memoHint = '메모 내용을 입력하세요...';
  static const memoSaved = '메모가 저장되었습니다';
  static const memoSaving = '저장 중...';
  static const memoChanged = '변경 감지됨';

  // 요소 관련
  static const elementImage = '이미지';
  static const elementCode = '코드';
  static const elementLink = '링크';
  static const elementTable = '표';
  static const pasteImage = '클립보드 이미지 붙여넣기';
  static const noImageInClipboard = '클립보드에 이미지가 없습니다';
  static const imageAdded = '이미지가 메모에 추가되었습니다';
  static const imagePasteFailed = '이미지 붙여넣기 실패';

  // 코드 추가 관련
  static const addCode = '코드 추가';
  static const languageHint = '언어 (예: python, javascript)';
  static const codeHint = '코드';
  static const defaultLanguage = 'text';

  // 링크 추가 관련
  static const addLink = '링크 추가';
  static const urlHint = 'URL (예: https://example.com)';
  static const titleHint = '제목';
  static const linkLabel = '링크:';
  static const openLink = '열기';

  // 표 관련
  static const addTable = '표 크기 설정';
  static const tableContent = '표 내용 입력';
  static const rows = '행: ';
  static const columns = '열: ';
  static const next = '다음';
  static const cellPrefix = '셀 ';
}
