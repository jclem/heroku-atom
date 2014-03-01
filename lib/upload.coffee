knox = require 'knox'

module.exports = (app, source, cb) ->
  target = source.replace(/^\/tmp\//, '') + '.tar.gz'

  s3Client = knox.createClient
    key   : atom.config.get('heroku.s3AccessId')
    secret: atom.config.get('heroku.s3Secret')
    bucket: atom.config.get('heroku.s3Bucket')

  s3Client.putFile source, target, 'x-amz-acl': 'public-read', (err, res) ->
    if err
      throw err
    else
      cb(target)
