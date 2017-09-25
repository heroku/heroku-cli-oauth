'use strict'

let co = require('co')
let cli = require('heroku-cli-util')
let authorizations = require('../../lib/authorizations')

function * run (context, heroku) {
  let auth = yield heroku.get(`/oauth/authorizations/${encodeURIComponent(context.args.id)}`)
  if (context.flags.json) {
    cli.styledJSON(auth)
  } else {
    authorizations.display(auth)
  }
}

module.exports = {
  topic: 'authorizations',
  command: 'info',
  description: 'show an existing OAuth authorization',
  needsAuth: true,
  flags: [
    {name: 'json', description: 'output in json format'}
  ],
  args: [{name: 'id'}],
  run: cli.command(co.wrap(run)),
  help: `Example:

    $ heroku authorizations:info 93614-b8d5ff7a84e-febdfc45b1832-5698
    Client:      <none>
    ID:         -3614-b8d5ff7a84e-febdfc45b1832-5698
    Description: Long-lived user authorization
    Scope:       global
    Token:       2-434e9-b-1e5de876512a-ad49f3f8f8f62`
}
