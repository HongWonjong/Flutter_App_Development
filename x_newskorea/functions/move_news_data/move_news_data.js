const admin = require('firebase-admin');
const db = admin.firestore();

const moveNewsData = async (snap, context) => {
  const newsId = context.params.newsId; // 문서 ID 가져오기
  const untranslatedDocRef = db.collection('Untranslated News').doc(newsId);
  const translatedDocRef = db.collection('Translated News').doc(newsId);

  try {
    // Untranslated News 문서 가져오기
    const doc = await untranslatedDocRef.get();

    if (!doc.exists) {
      console.log('No such document!');
      return;
    }

    const data = doc.data();

    // response 필드가 생성된 경우에만 처리
    if (!data.response) {
      console.log('No response field found');
      return;
    }

    // 필요한 필드들 추출
    const { response, news_id, reporter, source, status } = data;
    const createdTime = status?.completeTime || admin.firestore.FieldValue.serverTimestamp();

    // Translated News에 문서 생성
    await translatedDocRef.set({
      response,
      news_id,
      reporter,
      source,
      createdTime
    });

    console.log(`Document moved to Translated News with ID: ${newsId}`);

  } catch (error) {
    console.error('Error moving document: ', error);
  }
};

module.exports = { moveNewsData };
