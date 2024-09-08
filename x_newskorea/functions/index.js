const functions = require('firebase-functions');
const { getSecrets } = require('./get_secret/get_secret');
const { fetchCommunityPosts } = require('./get_x_data/get_x_data');
const logger = require('firebase-functions/logger');
const { moveNewsData } = require('./move_news_data/move_news_data');

// Firestore의 뉴스 이동 트리거 설정
exports.detectResponseField = functions.firestore
  .document('Untranslated News/{newsId}')
  .onUpdate((change, context) => {
    const newValue = change.after.data();

    // response 필드가 추가된 경우에만 실행
    if (!change.before.data().response && newValue.response) {
      return moveNewsData(change.after, context);
    }
    return null;
  });


// Firebase Function: 비밀을 가져오는 함수 (HTTP 호출)
exports.getSecretsFunction = functions.https.onCall(async (data, context) => {
    const projectId = '459934345714';
    const secretIds = data.secretIds || ['bearer_token', 'access_token','X_api_key', 'X_secret_api_key'];

    try {
        const secrets = await getSecrets(projectId, secretIds);
        logger.log('Successfully retrieved secrets');
        return { message: 'Secrets retrieved successfully', secrets };
    } catch (err) {
        logger.error('Error accessing secrets:', err.message);
        throw new functions.https.HttpsError('internal', 'Error accessing secrets');
    }
});

// Firebase Function: 커뮤니티 포스트를 24시간마다 가져오는 함수 (Cloud Scheduler)
exports.fetchCommunityPostsFunction = functions.pubsub.schedule('every 24 hours').onRun(async (context) => { // 시간은 나중에 바꾸지
    try {
        const posts = await fetchCommunityPosts();
        logger.log('Successfully fetched community posts');
        return { message: 'Community posts fetched successfully', posts };
    } catch (err) {
        logger.error('Error fetching community posts:', err.message);
        throw new functions.https.HttpsError('internal', 'Error fetching community posts');
    }
});

