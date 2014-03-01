deploy = require './deploy'

module.exports =
  configDefaults:
    herokuApiKey: null
    s3AccessId  : null
    s3Secret    : null
    s3Bucket    : null

  activate: ->
    atom.workspaceView.command 'heroku:deploy', deploy
