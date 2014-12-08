ownsDocument = function(userId, doc) {
    console.info('checking permission for user: ' + userId + ' to remove post: ' + doc);
    return doc && doc.userId == userId;
};
