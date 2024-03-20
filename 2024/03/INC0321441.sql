BEGIN
  UPDATE crapslr 
     SET dsarqsai = GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => crapslr.cdcooper) || crapslr.dsarqsai
       , dtiniger = NULL
       , dtfimger = NULL
       , flgerado = 'N'
       , dserrger = NULL          
   WHERE cdprogra = 'CRPS536' 
     AND TRUNC(DTSOLICI) = '20/03/2024';
  
  commit;
END;
