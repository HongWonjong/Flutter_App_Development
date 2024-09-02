const { getSecrets } = require('../get_secret/get_secret');
const axios = require('axios');
const { sendPostsToFirestore } = require('../send_data_to_firestore/send_data_to_firestore');

async function fetchCommunityPosts() {
    try {
        const secrets = await getSecrets('459934345714', ['bearer_token']);
        const config = {
            headers: {
                'Authorization': `Bearer ${secrets.bearer_token}`,
            },
        };
        const response = await axios.get(
            'https://api.twitter.com/2/tweets/search/recent?query=from:1829767897495060991',
            config
        );
        const posts = response.data.data;
        console.log('Community Posts:', posts);
        await sendPostsToFirestore(posts);
        return posts;
    } catch (error) {
        console.error('Error fetching community posts:', error.message);
        throw new Error('Failed to fetch and save community posts');
    }
}

module.exports = { fetchCommunityPosts };
