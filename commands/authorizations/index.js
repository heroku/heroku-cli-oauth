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
  description: 'list OAuth authorizations',
  needsAuth: true,
  flags: [
    {name: 'json', description: 'output in json format'}
  ],
  run: cli.command(co.wrap(run)),
  help: `Example:

    $ heroku authorizations
    Heroku CLI                                                                                            48e44c6bbeded530997-e284866-d6-971-9  global
    Heroku CLI login from shinobi at Tue Jul 18 2017 14:30:40 GMT-0500 (CDT)                              d-97-de93859d-d4c904d1bcd3-650423695  global
    Heroku CLI login from aragami at Mon Jun 19 2017 14:36:09 GMT-0500 (CDT)                              6a83a-3b0443--de5074943feb047-aaefb9  global`
}
