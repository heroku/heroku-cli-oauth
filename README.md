# Heroku OAuth

Command line plugin giving you commands to manage OAuth clients, authorizations and tokens.


### Clients

To create a client:

```
$ heroku clients:create Amazing https://amazing-client.herokuapp.com/oauth/callback/heroku
Created client Amazing
  ID:     66c0743078a45bda1ace505a
  Secret: 3a791be75df30f2b87bd0a8aff1528ec2441d546407b71a2
```

See OAuth clients under your account with:

```
$ heroku clients
=== OAuth Clients
Amazing  66c0743078a45bda1ace505a  https://amazing-client.herokuapp.com/oauth/callback
```

Update clients:

```
$ heroku clients:update 66c0743078a45bda1ace505a --url https://amazing.herokuapp.com/callback
Updated client Amazing
```


### Authorizations

List them:

```
$ heroku authorizations
=== Authorizations
authorization14@heroku.com  Amazing      all
authorization15@heroku.com  Another App  read-only
```

And revoke an authorization at anytime:

```
$ heroku authorizations:revoke authorization15@heroku.com
Revoked authorization from Another App
```

### Tokens

You can also use OAuth to get a unique key to access your account:

```
$ heroku tokens:create
Created OAuth token
  Scope:   all
  Access:  4cee516c-f8c6-4f14-9edf-fc6ef09cedc5
  Refresh: fc63e5c3-6a2a-46e0-a9ff-6df0df3a68de
  Expires: 7199
```

Then just use it like a password:

```
curl -u ":4cee516c-f8c6-4f14-9edf-fc6ef09cedc5" https://api.heroku.com/apps
```

You can also get more limited tokens (EXPERIMENTAL!):

```
$ heroku tokens:create --scope app:app2@heroku.com
Created OAuth token
  Scope:   app2@heroku.com
  Access:  b2a5b696-f0a0-4cb8-8184-27c319d8d9e3
  Refresh: 5c376a70-1291-4d49-b183-54b9c44bd6ef
  Expires: 7199
```

And then you can't use this token to access other apps:

```
curl -u ":4cee516c-f8c6-4f14-9edf-fc6ef09cedc5" https://api.heroku.com/apps/1@heroku.com
{"error":"The scope of this OAuth authorization does not allow access to this resource"}
```
