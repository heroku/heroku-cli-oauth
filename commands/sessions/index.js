'use strict'

const co = require('co')
const cli = require('heroku-cli-util')

function * run (context, heroku) {
  const _ = require('lodash')
  let sessions = yield heroku.get('/oauth/sessions')
  sessions = _.sortBy(sessions, 'description')

  if (context.flags.json) {
    cli.styledJSON(sessions)
  } else if (sessions.length === 0) {
    cli.log('No OAuth sessions.')
  } else {
    cli.table(sessions, {
      printHeader: null,
      columns: [
        {key: 'description', format: name => cli.color.green(name)},
        {key: 'id'}
      ]
    })
  }
}

module.exports = {
  topic: 'sessions',
  description: 'list your OAuth sessions',
  needsAuth: true,
  flags: [
    {name: 'json', description: 'output in json format'}
  ],
  run: cli.command(co.wrap(run)),
  help: `Example:

   $ heroku sessions
    Session @ 12.34.56.789 e4-c4f6b98d0d-57ca40279ef36c4-d-310
    Session @ 12.34.56.789 e4-c4f6b98d0d-57ca40279ef36c4-d-312
    Session @ 12.34.56.789 e4-c4f6b98d0d-57ca40279ef36c4-d-313
    Session @ 12.34.56.789 e4-c4f6b98d0d-57ca40279ef36c4-d-314
    Session @ 12.34.56.789 e4-c4f6b98d0d-57ca40279ef36c4-d-319
    Session @ 12.34.56.789 e4-c4f6b98d0d-57ca40279ef36c4-d-311`
}
