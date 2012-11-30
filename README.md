= Heroku OAuth command line plugin

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