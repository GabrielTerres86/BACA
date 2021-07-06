UPDATE crapslr l
   SET l.DTINIGER = NULL
      ,l.DTFIMGER = NULL
      ,l.FLGERADO = 'N'
      ,l.DSERRGER = ''
 WHERE TRUNC(l.DTSOLICI) >= '25/06/2021'
   AND UPPER(l.DSERRGER) LIKE UPPER('%GENE0002.pc_imprim--> GENE0002.pc_cria_pdf%');
   
COMMIT;   
   
   
