build   = require './build'
makeTar = require './makeTar'
upload  = require './upload'
mktemp  = require 'mktemp'
{Git}   = require 'atom'

module.exports = ->
  if git = Git.open(atom.project.path)
    remote = git.getConfigValue('remote.heroku.url')
    app = remote.split(':')[1].replace(/\.git$/, '')
  else
    paths = atom.project.path.split('/')
    app = paths[paths.length - 1]

  if !app then throw('no app detected')

  tarTarget = mktemp.createFileSync("/tmp/heroku-atom-#{app}-XXXXXXXX")

  makeTar tarTarget, ->
    upload app, tarTarget, (s3Target) ->
      build app, s3Target, ->
        console.log "successfully built #{app}"
