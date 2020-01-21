BEGIN
  
  UPDATE crapaca t
     SET t.lstparam = t.lstparam||',pr_nrsolici'
   WHERE t.nmdeacao = 'CANCELA_PORTABILIDADE';
  
  UPDATE crapaca t
     SET t.lstparam = t.lstparam||',pr_nrsolici'
       , t.nmdeacao = 'CONTESTA_PORTABILIDADE'
   WHERE t.nmdeacao = 'CANTESTA_PORTABILIDADE';
  
  COMMIT;
END;
