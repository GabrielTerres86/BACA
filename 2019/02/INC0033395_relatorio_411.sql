UPDATE crapslr s
   SET s.dtiniger = NULL
      ,s.dtfimger = NULL
      ,s.flgerado = 'N'
 WHERE s.cdrelato IN (411) 
   AND trunc(s.dtsolici) = '20/02/2019';

COMMIT;
