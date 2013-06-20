# Heroku OAuth

Command line plugin giving you commands to manage OAuth clients, authorizations and tokens.

To install:

``` bash
$ heroku plugins:install git@github.com:heroku/heroku-oauth.git
```

### Clients

To create a client:

``` bash
$ heroku clients:create Amazing https://amazing-client.herokuapp.com/auth/heroku/callback
=== Created client 'Amazing'.
created_at:   2013-06-20T22:04:01-00:00
id:           3e304bda-d376-4278-bdea-6d6c08aa1359
name:         Amazing
redirect_uri: http://localhost:3000
secret:       e6a5f58f-f8a9-49f1-a1a6-d1dd98930ef6
updated_at:   2013-06-20T22:04:01-00:00
```

Or use the `-s / --shell` option to pipe output straight to your `.env` file:

``` bash
$ heroku clients:create -s Amazing https://amazing-client.herokuapp.com/auth/heroku/callback >> .env
$ cat .env
...
HEROKU_KEY=3e304bda-d376-4278-bdea-6d6c08aa1359
HEROKU_SECRET=e6a5f58f-f8a9-49f1-a1a6-d1dd98930ef6
```

See OAuth clients under your account with:

``` bash
$ heroku clients
=== OAuth Clients
Amazing  3e304bda-d376-4278-bdea-6d6c08aa1359  https://amazing-client.herokuapp.com/auth/heroku/callback
```

Show a client:

``` bash
$ heroku clients:show 3e304bda-d376-4278-bdea-6d6c08aa1359
=== Client Amazing
created_at:   2013-06-20T22:04:01-00:00
id:           3e304bda-d376-4278-bdea-6d6c08aa1359
name:         Amazing
redirect_uri: http://localhost:3000
secret:       e6a5f58f-f8a9-49f1-a1a6-d1dd98930ef6
updated_at:   2013-06-20T22:04:01-00:00
```

Or use the `-s / --shell` option to pipe output straight to your `.env` file:

``` bash
$ heroku clients:show 3e304bda-d376-4278-bdea-6d6c08aa1359 -s >> .env
$ cat .env
...
HEROKU_KEY=3e304bda-d376-4278-bdea-6d6c08aa1359
HEROKU_SECRET=e6a5f58f-f8a9-49f1-a1a6-d1dd98930ef6
```

Update clients:

``` bash
$ heroku clients:update 3e304bda-d376-4278-bdea-6d6c08aa1359 --url https://amazing-client.herokuapp.com/auth/heroku/callback
Updated client Amazing
```

### Authorizations

List them:

``` bash
$ heroku authorizations
=== Authorizations
Amazing                        9e3a4063-b833-432e-ad75-4b0d7195be13  global
Heroku CLI                     676cb46c-7597-4be1-8a6a-f87b9f2f1065  global
```

#### Creating

You can create a special user-created authorization against your account that will come with an access token which doesn't expire:

``` bash
$ heroku authorizations:create --description "For use with Anvil"
Created OAuth authorization
  ID:          105a7bfa-34c3-476e-873a-b1ac3fdc12fb
  Description: For use with Anvil
  Token:       4cee516c-f8c6-4f14-9edf-fc6ef09cedc5
  Scope:       global
```

The procured token can now be used like an API key:

``` bash
$ curl -u ":4cee516c-f8c6-4f14-9edf-fc6ef09cedc5" https://api.heroku.com/apps
```


#### Revoking

Any authorization on your account can be revoked at any time:

``` bash
$ heroku authorizations:revoke 105a7bfa-34c3-476e-873a-b1ac3fdc12fb
Revoked authorization from 'Another App'
```
