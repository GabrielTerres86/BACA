DELETE crapris ris
 WHERE ris.cdcooper = 1
   AND ris.inddocto = 2
   AND ris.dtrefere = '30/04/2019';

UPDATE crapris ris
   SET ris.flgindiv = 0
 WHERE ris.cdcooper = 1
   AND ris.dtrefere = '30/04/2019';

COMMIT;