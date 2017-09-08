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
  needsAuth: true,
  flags: [
    {char: 'd', name: 'description', hasValue: true, description: 'set a custom authorization description'},
    {char: 's', name: 'scope', hasValue: true, description: 'set custom OAuth scopes'},
    {char: 'e', name: 'expires-in', hasValue: true, description: 'set expiration in seconds'},
    {name: 'short', description: 'only output token'},
    {name: 'json', description: 'output in json format'}
  ],
  run: cli.command(co.wrap(run))
  help: `This creates an authorization with access to your Heroku account.

  Example:

    $ heroku authorizations:create
    Creating OAuth Authorization... done
    Client:      <none>
    ID:         -3614-b8d5ff7a84e-febdfc45b1832-5698
    Description: Long-lived user authorization
    Scope:       global
    Token:       2-434e9-b-1e5de876512a-ad49f3f8f8f62`
}
