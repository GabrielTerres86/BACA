BEGIN
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
  VALUES('CRED',0,'EMAIL_INTEGRA_PROGNUM','Email para envio de avisos de erro ao importar arquivo crédtio imobiliário PROGNUM','marjelli.prada@ailos.coop.br');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
