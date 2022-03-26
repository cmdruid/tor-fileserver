
import { access }    from 'fs/promises'
import { constants } from 'fs'
import nanoexpress   from 'nanoexpress';

const router = nanoexpress();

router.get('/', (req, res) => {
  console.log(req)
  return res.send({ status: 'ok' });
});

router.get('/files/*', async (req, res) => {
  /* Serve script files from the scripts folder.
   */

  const basePath = '/root/files'
  const filename = req.path.split('/').pop()
  const filepath = `${basePath}/${filename}`
  
  try {
    await access(filepath, constants.R_OK)
    return res.sendFile(filepath)
  } catch { return res.status(404).end() }
});

console.info('Node Environment:', process.env.NODE_ENV || 'PRODUCTION')
router.listen(3000);