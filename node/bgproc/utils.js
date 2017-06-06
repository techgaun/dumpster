const spawn = require('child_process').spawn
const Path = require('path')
const fs = require('fs')

const opts = {
  detached: true,
  stdio: 'ignore',
}

const source_dir = "/tmp/indir"
const out_dir = "/tmp/outdir"
const meta_dir = "/tmp/meta"

function zip_background(dir) {
  const child = spawn(Path.join(__dirname, 'compress.sh'), [Path.join(source_dir, dir), get_tar_file(dir), Path.join(meta_dir, dir)], opts)
  child.on('error', (err) => {
    console.log('Failed to execute command', err)
  })
  child.unref()
}

function meta_exists(dir) {
  const meta_file = Path.join(meta_dir, dir)
  if (fs.existsSync(meta_file)) {
    return true
  }
  return false
}

function get_tar_file(dir) {
  return Path.join(out_dir, `${dir}.tar.gz`)
}

exports.zip_background = zip_background
exports.meta_exists = meta_exists
exports.get_tar_file = get_tar_file
