const { getSecrets } = require('../get_secret/get_secret');
const axios = require('axios');
const { sendPostsToFirestore } = require('../send_data_to_firestore/send_data_to_firestore');

async function fetchCommunityPosts() {
    try {
        console.log('Fetching secrets...');
        const secrets = await getSecrets('459934345714', ['bearer_token', 'access_token']);
        if (!secrets.bearer_token) {
            throw new Error('Bearer token is missing');
        }

        console.log('Secrets fetched successfully.');
        const config = {
            headers: {
                'Authorization': `Bearer ${secrets.bearer_token}`,
               // 'oauth_token': secrets.access_token, // 추가된 부분, bearer_token 과 api키 둘 다 있어야 접근 허가가 되는 듯?
            },
        };

        console.log('Sending API request...');
        const response = await axios.get(
            'https://api.twitter.com/2/tweets/search/recent?query=community_id:1830589331498737789',
            config
        );

        console.log('API response received:', response.data);
        const posts = response.data.data || [];
        if (posts.length === 0) {
            console.warn('No posts found for the given community.');
        }

        console.log('Posts to be saved:', posts);
        await sendPostsToFirestore(posts);
        console.log('Posts saved successfully to Firestore.');

        return posts;
    } catch (error) {
        console.error('Error fetching community posts:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Headers:', error.response.headers);
            console.error('Data:', error.response.data);
        }
        console.error('Request config:', error.config);
        throw new Error('Failed to fetch and save community posts');
    }
}

module.exports = { fetchCommunityPosts };

