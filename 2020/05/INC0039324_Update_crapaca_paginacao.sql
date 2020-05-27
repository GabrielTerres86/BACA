
/*
  INC0039324 - Inclusão de parâmetros para paginação
*/

BEGIN 

  UPDATE CRAPACA
  SET CRAPACA.LSTPARAM ='pr_cdcooperativa,pr_nrdconta,pr_dtinicial,pr_dtfinal,pr_cdestado,pr_cartorio,pr_flcustas,pr_nrregist,pr_nriniseq'
  WHERE CRAPACA.NMDEACAO = 'CONSULTA_CUSTAS'
  AND   CRAPACA.NMPACKAG = 'TELA_MANPRT';
  
  COMMIT;
END;  


