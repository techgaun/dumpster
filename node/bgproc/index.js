const express = require('express')
const path = require('path')
const utils = require('./utils')

const app = express()

app.use('/front', express.static(path.join(__dirname, 'front')))

app.get('/api/mkdownload/:dir', (req, res) => {
  utils.zip_background(req.params.dir)
  res.json({success: true, msg: 'ok'})
})

app.get('/download/:dir', (req, res, next) => {
  res.download(utils.get_tar_file(req.params.dir), 'backup.tar.gz', (err) => {
    if (err) {
      next(err)
    }
  })
})

app.get('/api/download/:dir', (req, res, next) => {
  if (utils.meta_exists(req.params.dir)) {
    res.json({success: true, msg: 'ok'})
  } else {
    res.json({success: false, msg: 'enoent'})
  }
})

app.listen(3000, () => {
  console.log('App started on port 3000')
})
