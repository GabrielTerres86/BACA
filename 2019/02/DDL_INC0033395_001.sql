-- INC0033395 - Enviar relatórios em pdf para a intranet (Ana - 20/02/2019)

UPDATE crapslr s
   SET s.dtiniger = NULL
      ,s.dtfimger = NULL
      ,s.flgerado = 'N'
 WHERE s.cdrelato IN (214, 266, 272, 280)
   AND trunc(s.dtsolici) = '20/02/2019';

COMMIT;
