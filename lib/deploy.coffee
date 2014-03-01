fstream = require 'fstream'
knox    = require 'knox'
mktemp  = require 'mktemp'
request = require 'request'
tar     = require 'tar'
zlib    = require 'zlib'
{Git}   = require 'atom'
build   = null

module.exports = ->
  if git = Git.open(atom.project.path)
    remote = git.getConfigValue('remote.heroku.url')
    app = remote.split(':')[1].replace(/\.git$/, '')
  else
    paths = atom.project.path.split('/')
    app = paths[paths.length - 1]

  if !app then throw('no app detected')

  s3Client = knox.createClient
    key   : atom.config.get('heroku.s3AccessId')
    secret: atom.config.get('heroku.s3Secret')
    bucket: atom.config.get('heroku.s3Bucket')

  tarTarget = mktemp.createFileSync("/tmp/heroku-atom-#{app}-XXXXXXXX")
  s3Target  = tarTarget.replace(/^\/tmp\//, '') + '.tar.gz'

  fstream.Reader(path: atom.project.path, type: 'Directory')
    .pipe(tar.Pack(noProprietary: true, prefix: '.'))
    .pipe(zlib.createGzip())
    .pipe(fstream.Writer(tarTarget))
    .on 'close', ->
      s3Client.putFile tarTarget, s3Target, 'x-amz-acl': 'public-read', (err, res) ->
        if (err) then throw err

        build app, s3Target, (err, res) ->
          if (err) then throw err
          if (res.statusCode != 201)
            throw 'received non-201 from build API'
          else
            console.log "successfully built #{app}"

build = (app, s3Target, cb) ->
  request
    method: 'POST'
    url   : "https://api.heroku.com/apps/#{app}/builds"
    auth  :
      user: ''
      pass: atom.config.get('heroku.herokuApiKey')
    headers:
      'Accept'      : 'application/vnd.heroku+json; version=3'
      'Content-type': 'application/json'
    body:
      JSON.stringify source_blob:
        url: "https://#{atom.config.get('heroku.s3Bucket')}.s3.amazonaws.com/#{s3Target}"
  , cb
