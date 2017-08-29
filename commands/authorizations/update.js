'use strict'

let co = require('co')
let cli = require('heroku-cli-util')
let authorizations = require('../../lib/authorizations')

function * run (context, heroku) {
  let client
  if (context.flags['client-id']) {
    client = {
      id: context.flags['client-id'],
      secret: context.flags['client-secret']
    }
  }
  let auth = yield cli.action('Updating OAuth Authorization', heroku.request({
    method: 'PATCH',
    path: `/oauth/authorizations/${encodeURIComponent(context.args.id)}`,
    body: {
      client,
      description: context.flags.description
    }
  }))

  authorizations.display(auth)
}

module.exports = {
  topic: 'authorizations',
  command: 'update',
  description: 'updates an OAuth authorization',
  needsAuth: true,
  args: [{name: 'id'}],
  flags: [
    {char: 'd', name: 'description', hasValue: true, description: 'set a custom authorization description'},
    {name: 'client-id', hasValue: true, description: 'identifier of OAuth client to set'},
    {name: 'client-secret', hasValue: true, description: 'secret of OAuth client to set'}
  ],
  run: cli.command(co.wrap(run)),
  help: `Example:

    $ heroku authorizations:update c896-8e45-d7-0abf08-3edc5f47bf15b038
    Updating OAuth Authorization... done
    Client:      <none>
    ID:          c896-8e45-d7-0abf08-3edc5f47bf15b038
    Description: Long-lived user authorization
    Scope:       global
    Token:       61ffc98c4151-19-7-34e8914c7b7fb-d8b1`

}
