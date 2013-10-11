# Heroku - Mongo Sync

This is a plugin for the Heroku command line, adding commands to sync your
local and production mongo databases.

It was tested and should just work with Mongo HQ. If you host your mongo db
somewhere else, just make sure you have access from your local machine.

## Installation

    $ heroku plugins:install http://github.com/marcofognog/heroku-mongo-sync

## Config

The plugin assumes your local mongo db is running on your localhost with the
standard settings (port 27017, no auth). It will use a database named after
the current Heroku app name.

You can change any of these defining the URL it should connect to, like:

    export MONGO_URL = mongodb://user:pass@localhost:1234/db

For production, it will fetch the MONGO_URL from the Heroku app config vars.

## Usage

Get a copy of your production database with:

    $ heroku mongo:pull
    THIS WILL REPLACE ALL DATA IN myapp ON localhost WITH genesis.mongohq.com
    Syncing users (4)... done
    Syncing permissions (4)... done
    Syncing plans (17)... done

Update your production database with:

    $ heroku mongo:push
    THIS WILL REPLACE ALL DATA IN myapp ON genesis.mongohq.com WITH localhost
    Are you sure? (y/n) y
    Syncing users (4)... done
    Syncing permissions (4)... done
    Syncing plans (17)... done

To push or pull specific collections:

    $ heroku mongo:push users plans
    THIS WILL REPLACE users,posts IN myapp ON genesis.mongohq.com WITH localhost
    Syncing users (4)... done
    Syncing plans (17)... done

As usual, in case you're not inside the app checkout you can specify the app
you want to pull/push to:

    $ heroku mongo:pull --app myapp-staging

If you're inside a checkout with multiple apps deployed, you can also specify
the one to pull/push to by the git remote:

    $ heroku mongo:pull --remote staging


## Notes

Created by Pedro Belo. 
Support for indexes, users and more added by Ben Wyrosdick.
Maintained by Marco Antonio

Use at your own risk.

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
