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

Created client Amazing
  ID:     66c0743078a45bda1ace505a
  Secret: 3a791be75df30f2b87bd0a8aff1528ec2441d546407b71a2
```

Or use the `-s / --shell` option to pipe output straight to your `.env` file:

``` bash
$ heroku clients:create -s Amazing https://amazing-client.herokuapp.com/auth/heroku/callback >> .env
$ cat .env
...
HEROKU_KEY=66c0743078a45bda1ace505a
HEROKU_SECRET=3a791be75df30f2b87bd0a8aff1528ec2441d546407b71a2
```

See OAuth clients under your account with:

``` bash
$ heroku clients
=== OAuth Clients
Amazing  66c0743078a45bda1ace505a  https://amazing-client.herokuapp.com/auth/heroku/callback
```

Update clients:

``` bash
$ heroku clients:update 66c0743078a45bda1ace505a --url https://amazing-client.herokuapp.com/auth/heroku/callback
Updated client Amazing
```

### Authorizations

List them:

``` bash
$ heroku authorizations
=== Authorizations
authorization14@heroku.com  Amazing      all
authorization15@heroku.com  Another App  read-only
```

#### Creating

You can create a special user-created authorization against your account that will come with an access token which doesn't expire:

``` bash
$ heroku authorizations:create --description "For use with Anvil"
Created OAuth authorization
  ID:          authorization16@heroku.com
  Description: For use with Anvil
  Token:       4cee516c-f8c6-4f14-9edf-fc6ef09cedc5
  Scope:       all
```

The procured token can now be used like an API key:

``` bash
$ curl -u ":4cee516c-f8c6-4f14-9edf-fc6ef09cedc5" https://api.heroku.com/apps
```

You can also create authorizations that have a more limited access scope (EXPERIMENTAL!):

``` bash
$ heroku authorizations:create --scope app:app2@heroku.com --description "Just for app2 access"
Created OAuth authorization
  ID:          authorization16@heroku.com
  Description: Just for app2 access
  Token:       b2a5b696-f0a0-4cb8-8184-27c319d8d9e3
  Scope:       app2@heroku.com
```

Attempting to access anything other than app2 will result in an error:

``` bash
curl -u ":b2a5b696-f0a0-4cb8-8184-27c319d8d9e3" https://api.heroku.com/apps/1@heroku.com
{"error":"The scope of this OAuth authorization does not allow access to this resource"}
```

#### Revoking

Any authorization on your account can be revoked at any time:

``` bash
$ heroku authorizations:revoke authorization15@heroku.com
Revoked authorization from 'Another App'
```
