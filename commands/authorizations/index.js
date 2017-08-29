'use strict'

const co = require('co')
const cli = require('heroku-cli-util')

function * run (context, heroku) {
  const _ = require('lodash')
  let authorizations = yield heroku.get('/oauth/authorizations')
  authorizations = _.sortBy(authorizations, 'description')

  if (context.flags.json) {
    cli.styledJSON(authorizations)
  } else if (authorizations.length === 0) {
    cli.log('No OAuth authorizations.')
  } else {
    cli.table(authorizations, {
      printHeader: null,
      columns: [
        {key: 'description', format: v => cli.color.green(v)},
        {key: 'id'},
        {key: 'scope', format: v => v.join(',')}
      ]
    })
  }
}

module.exports = {
  topic: 'authorizations',
  overview: 'The authorizations plugin is a collection of tools for managing Oauth and other authentication methods',
  description: 'list OAuth authorizations',
  needsAuth: true,
  flags: [
    {name: 'json', description: 'output in json format'}
  ],
  run: cli.command(co.wrap(run)),
  help: `Example:

    $ heroku authorizations
    Heroku CLI login from shinobi at Tue Jul 18 2017 14:30:40 GMT-0500 (CDT)                              db460-dc2d-49e3d-91d75d34059-693c958  global
    Heroku CLI login from aragami at Mon Jun 19 2017 14:36:09 GMT-0500 (CDT)                              ae-b5639-484a9d3fb-af-7ea4700b4e3034  global`
}
