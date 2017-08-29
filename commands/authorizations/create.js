'use strict'

const co = require('co')
const cli = require('heroku-cli-util')
const authorizations = require('../../lib/authorizations')

function * run (context, heroku) {
  let promise = heroku.request({
    method: 'POST',
    path: '/oauth/authorizations',
    body: {
      description: context.flags.description,
      scope: context.flags.scope ? context.flags.scope.split(',') : undefined,
      expires_in: context.flags['expires-in']
    }
  })

  if (!context.flags.short && !context.flags.json) {
    promise = cli.action('Creating OAuth Authorization', promise)
  }

  let auth = yield promise

  if (context.flags.short) {
    cli.log(auth.access_token.token)
  } else if (context.flags.json) {
    cli.styledJSON(auth)
  } else {
    authorizations.display(auth)
  }
}

module.exports = {
  topic: 'authorizations',
  command: 'create',
  description: 'create a new OAuth authorization',
  help: 'This creates an authorization with access to your Heroku account.',
  needsAuth: true,
  flags: [
    {char: 'd', name: 'description', hasValue: true, description: 'set a custom authorization description'},
    {char: 's', name: 'scope', hasValue: true, description: 'set custom OAuth scopes'},
    {char: 'e', name: 'expires-in', hasValue: true, description: 'set expiration in seconds'},
    {name: 'short', description: 'only output token'},
    {name: 'json', description: 'output in json format'}
  ],
  run: cli.command(co.wrap(run)),
  help: `Example:

    $ heroku authorizations:create
    Creating OAuth Authorization... done
    Client:      <none>
    ID:          c896-8e45-d7-0abf08-3edc5f47bf15b038 
    Description: Long-lived user authorization
    Scope:       global
    Token:       61ffc98c4151-19-7-34e8914c7b7fb-d8b1`
}
