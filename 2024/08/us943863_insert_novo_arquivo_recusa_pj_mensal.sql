BEGIN
  INSERT INTO cecred.crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
  VALUES ('CRED', 0, 'RECUSA_SEG_CONTR_MES_PJ', 'Nome do arquivo de recusa mensal para seguro prestamista contributario pj', 'AILOS_NRAPOLICE_RECUSASPRESTAMISTAMENSAL_DDMMAAAA.txt');
  
  COMMIT;
END;
