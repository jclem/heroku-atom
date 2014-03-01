request = require 'request'

module.exports = (app, s3Target, cb) ->
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
  , (err, res) ->
    if err
      throw err
    else if res.statusCode != 201
      throw 'received non-201 from build API'
    else
      cb()
