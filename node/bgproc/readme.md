### Create Directories

- `mkdir -p /tmp/{indir,outdir,meta}`

### Create sub-dir with big random file on indir

- `mkdir -p /tmp/indir/somedir && dd if=/dev/urandom of=/tmp/indir/somedir/abc.txt count=512 bs=1048576`

### Run app

- `node index.js`

### Open app on browser and input `somedir`

url: http://localhost:3000/front/

### Notes

- The frontend keeps on sending ajax without timeout (easily fixable, just lazy)
