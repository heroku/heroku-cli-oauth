'use strict'

let co = require('co')
let cli = require('heroku-cli-util')

function * run (context, heroku) {
  let id = context.args.id
  yield cli.action(`Destroying ${cli.color.cyan(id)}`, co(function * () {
    yield heroku.request({
      method: 'DELETE',
      path: `/oauth/sessions/${id}`
    })
  }))
}

module.exports = {
  topic: 'sessions',
  command: 'destroy',
  description: 'delete (logout) OAuth session by ID',
  needsAuth: true,
  args: [{name: 'id'}],
  run: cli.command(co.wrap(run)),
  help: `Example:

    $ heroku sessions:destroy e4-c4f6b98d0d-57ca40279ef36c4-d-312b
    Destroying 2e3eac53-b82c-4a46-8c0e-e2edd404c1c8... done`
}
