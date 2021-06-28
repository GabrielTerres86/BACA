UPDATE crapslr l
   SET l.DTINIGER = NULL
      ,l.DTFIMGER = NULL
      ,l.FLGERADO = 'N'
      ,l.DSERRGER = ''
 WHERE TRUNC(l.DTSOLICI) = '28/06/2021'
   AND l.DSERRGER LIKE '%GENE0002.pc_imprim--> GENE0002.pc_cria_pdf%';
   
COMMIT;   
   
