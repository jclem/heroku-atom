fstream = require 'fstream'
tar     = require 'tar'
zlib    = require 'zlib'

module.exports = (target, cb) ->
  fstream.Reader(path: atom.project.path, type: 'Directory')
    .pipe(tar.Pack(noProprietary: true, prefix: '.'))
    .pipe(zlib.createGzip())
    .pipe(fstream.Writer(target))
    .on 'close', cb
