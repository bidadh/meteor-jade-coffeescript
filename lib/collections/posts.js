Posts = new Mongo.Collection('posts');

ownsDocument = function(userId, doc) {
    console.info('checking permission for user: ' + userId + ' to remove post: ' + doc);
    return doc && doc.userId == userId;
};

Posts.allow({
    update: ownsDocument,
    remove: ownsDocument
});

Meteor.methods({
    postInsert: function(postAttributes) {
        check(Meteor.userId(), String);
        check(postAttributes, {
            title: String,
            url: String,
            category: String
        });

        var postWithSameLink = Posts.findOne({url: postAttributes.url});
        if(postWithSameLink) {
            return {
                postExists: true,
                _id: postWithSameLink._id
            };
        }

        var user = Meteor.user();
        var post = _.extend(postAttributes,{
            flagged: false,
            userId: user._id,
            author: user.username,
            submitted: new Date()
        });
        var postId = Posts.insert(post);
        return {
            _id: postId
        };
    },

    postUpdate: function(postAttributes) {
        var currentPostId = postAttributes._id;
        delete postAttributes._id;

        check(Meteor.userId(), String);
        check(postAttributes, {
            title: String,
            url: String
        });

        var postWithSameLink = Posts.findOne({url: postAttributes.url, _id:{$ne: currentPostId}});
        if(postWithSameLink) {
            return {
                postExists: true,
                _id: postWithSameLink._id
            };
        }

        console.info('Updating post with id: ' + currentPostId);

        Posts.update(currentPostId, {$set:postAttributes});
        return {
            _id: currentPostId
        };
    },

    postRemove: function(postId) {
        console.info('Removing post with id: ' + postId);
        Posts.remove(postId);
    }
});