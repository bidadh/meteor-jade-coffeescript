Posts = new Mongo.Collection('posts');

ownsDocument = function(userId, doc) {
    console.info('checking permission for user: ' + userId + ' to remove post: ' + doc);
    return doc && doc.userId == userId;
};

hasUnAuthorizedFields = function(properties) {
    return (_.without(Object.keys(properties), 'url', 'title').length > 0);
};

Posts.allow({
    update: ownsDocument,
    remove: ownsDocument
});

Posts.deny({
   update: function(userId, post, fieldNames) {
       return (_.without(fieldNames, 'url', 'title').length > 0);
   }
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

    postUpdate: function(postAttributes, postId) {
        console.info(postId);
        var currentPostId = postId;

        check(Meteor.userId(), String);
        check(postAttributes, {
            title: String,
            url: String
        });

        if(hasUnAuthorizedFields(postAttributes)) {
            return {
                accessDenied: true,
                _id: postId
            }
        }

        var postWithSameLink = Posts.findOne({url: postAttributes.url, _id:{$ne: postId}});
        if(postWithSameLink) {
            return {
                postExists: true,
                _id: postId
            };
        }

        var post = Posts.findOne({_id: postId});
        if(!ownsDocument(Meteor.userId(), post)) {
            return {
                accessDenied: true,
                _id: postId
            }
        }

        console.info('Updating post with id: ' + currentPostId);

        Posts.update(postId, {$set:postAttributes});
        return {
            _id: postId
        };
    },

    postRemove: function(postId) {
        var post = Posts.findOne({_id: postId});
        if(!ownsDocument(Meteor.userId(), post)) {
            return {
                accessDenied: true,
                _id: postId
            }
        }

        console.info('Removing post with id: ' + postId);
        Posts.remove(postId);
    }
});

validatePost = function(post) {
    var errors = {};
    if(!post.title) {
        errors.title = 'Please fill in a headline';
    }
    if(!post.url) {
        errors.url = 'Please fill in a URL';
    }

    return errors;
};