const functions = require('firebase-functions');
const { getSecrets } = require('./get_secret/get_secret');
const { fetchCommunityPosts } = require('./get_x_data/get_x_data');
const logger = require('firebase-functions/logger');

// Firebase Function: 비밀을 가져오는 함수 (HTTP 호출)
exports.getSecretsFunction = functions.https.onCall(async (data, context) => {
    const projectId = '459934345714';
    const secretIds = data.secretIds || ['bearer_token', 'X_api_key', 'X_secret_api_key'];

    try {
        const secrets = await getSecrets(projectId, secretIds);
        logger.log('Successfully retrieved secrets');
        return { message: 'Secrets retrieved successfully', secrets };
    } catch (err) {
        logger.error('Error accessing secrets:', err.message);
        throw new functions.https.HttpsError('internal', 'Error accessing secrets');
    }
});

// Firebase Function: 커뮤니티 포스트를 5분마다 가져오는 함수 (Cloud Scheduler)
exports.fetchCommunityPostsFunction = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
    try {
        const posts = await fetchCommunityPosts();
        logger.log('Successfully fetched community posts');
        return { message: 'Community posts fetched successfully', posts };
    } catch (err) {
        logger.error('Error fetching community posts:', err.message);
        throw new functions.https.HttpsError('internal', 'Error fetching community posts');
    }
});

