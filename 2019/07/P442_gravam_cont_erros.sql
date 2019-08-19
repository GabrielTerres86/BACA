BEGIN
   
   insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'GRAVAM_QTD_MAX_ERRO_LOTE','',9);  

  UPDATE crapaca aca
     SET aca.lstparam = 'pr_qterrlot,'||aca.lstparam
   WHERE aca.nmdeacao = 'GRAVAM_GRAVA_PRM';
               
  commit;
end;
