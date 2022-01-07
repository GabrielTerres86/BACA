BEGIN
  UPDATE crapaca a SET a.lstparam = 'pr_dtinicionotificacoes, pr_dtfimnotificacoes, pr_flgcalcestatistica'
   WHERE a.nmdeacao = 'LISTA_CONSULTA'
     AND a.nmpackag = 'TELA_ENVNOT';

  COMMIT;   
END;
