
/*
  INC0039324 - Inclus�o de par�metros para pagina��o
*/

BEGIN 

  UPDATE CRAPACA
  SET CRAPACA.LSTPARAM ='pr_cdcooperativa,pr_nrdconta,pr_dtinicial,pr_dtfinal,pr_cdestado,pr_cartorio,pr_flcustas,pr_nrregist,pr_nriniseq'
  WHERE CRAPACA.NMDEACAO = 'CONSULTA_CUSTAS'
  AND   CRAPACA.NMPACKAG = 'TELA_MANPRT';
  
  COMMIT;
END;  


