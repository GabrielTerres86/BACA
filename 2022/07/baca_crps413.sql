﻿UPDATE CECRED.crapprg p
   SET p.NRSOLICI = 86
      ,p.INLIBPRG = 1
 WHERE p.CDPROGRA = 'CRPS413'
   AND p.INLIBPRG = 2
   AND p.NRSOLICI = 91086;

COMMIT;      