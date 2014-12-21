# Install Meteor
    curl https://install.meteor.com/ | sh

# Install nodejs
### Adding repositories and sources
    sudo apt-get install python-software-properties

    sudo apt-add-repository ppa:chris-lea/node.js

    sudo apt-get update

### Installing
    sudo apt-get install nodejs

### Checkings
    node -v

    npm -v

# Install mongodb
### Import the public key used by the package management system.
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

### Create a list file for MongoDB.
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

### Reload local package database.
    sudo apt-get update

### Install the MongoDB packages.
    sudo apt-get install -y mongodb-org

### MongoDB start / stop / restart.
    sudo service mongod start / stop / restart

# Setup a admin user in MongoDB
    mongo

    db = db.getSiblingDB('admin')

    db.addUser({ user: "adminuser", pwd: "adminpassword", roles: [ "userAdminAnyDatabase" ] })

# Configure MongoDB for our Meteor JS app
    sudo vim /etc/mongodb.conf

### add lines to file
    dbpath=/var/lib/mongodb
    logpath=/var/log/mongodb/mongodb.log
    logappend=true
    #port = 27017
    # Disables write-ahead journaling
    # nojournal = true
    # Turn on/off security.  Off is currently the default
    #noauth = false
    auth = true

### restart mongoDB
    sudo service mongod restart

### Change mongodb folder permissions
    sudo chown -R mongodb:mongodb /var/lib/mongodb

### mongoDB logs
    tail -f /var/log/mongodb/mongodb.log

# Add a user to MongoDB for our realtime Meteor JS application
    mongo -u adminuser -p --authenticationDatabase admin

    use testdatabase

    db.addUser({ user: "testuser", pwd: "testuserpass", roles: [ "readWrite" ] })

# Configure Apache2 to proxy a domain name to our future Node.js server
    sudo a2enmod proxy

    sudo a2enmod proxy_http

    sudo vim /etc/apache2/sites-available/meteorapp.yourdomain.com

### add lines to file
    <VirtualHost *:80>
            ServerName meteorapp.yourdomain.com
            ProxyRequests off

            <Proxy *>
                    Order deny,allow
                    Allow from all
            </Proxy>
            <Location />
                    ProxyPass http://localhost:58080/
                    ProxyPassReverse http://localhost:58080/
            </Location>
    </VirtualHost>

### eneble site
    sudo a2ensite meteorapp.yourdomain.com

    sudo service apache2 reload

# Get you Meteor JS app ready for deployment
    sudo npm install -g demeteorizer

    cd

    mkdir -p projects/meteor/deploy

    cd projects/meteor

    git clone https://github.com/bidadh/meteor-jade-coffeescript.git

    cd meteor-jade-coffeescript

    demeteorizer -o ../deploy

# Run our production Meteor JS application on Ubuntu 12.04 alongside with MongoDB
    sudo npm install -g forever

    sudo chown -R arthur:arthur .npm

    cd ~/projects/meteor/deploy

    npm install

    npm install fibers@1.0.0

    export MONGO_URL='mongodb://testuser:testuserpass@127.0.0.1:27017/testdatabase'

    export PORT=58080

    export ROOT_URL='http://meteorapp.yourdomain.com/'

    forever main.js

# Configure Upstart
    sudo vim /etc/init/meteorapp.conf

    # upstart service file at /etc/init/meteorapp.conf
    description "Meteor.js (NodeJS) application"
    author "Arthur Kazemi <bidadh@gmail.com>"

    # When to start the service
    start on started mongod and runlevel [2345]

    # When to stop the service
    #stop on shutdown

    # Automatically restart process if crashed
    respawn
    respawn limit 10 5

    # we don't use buil-in log because we use a script below
    # console log

    # drop root proviliges and switch to mymetorapp user
    setuid arthur
    setgid arthur

    script
        # set to home directory of the user Meteor will be running as
        export PWD=/home/arthur
        export HOME=/home/arthur
        # leave as 127.0.0.1 for security
        export BIND_IP=127.0.0.1
        # the port nginx is proxying requests to
        export PORT=58080
        # this allows Meteor to figure out correct IP address of visitors
        export HTTP_FORWARDED_COUNT=1
        # MongoDB connection string using todos as database name
        export MONGO_URL=mongodb://testuser:testuserpass@127.0.0.1:27017/testdatabase
        # The domain name as configured previously as server_name in nginx
        export ROOT_URL=http://meteorapp.raysazapps.com
        exec node $HOME/projects/meteor/deploy/main.js >> $HOME/projects/meteor/deploy/meteorapp.log
    end script
