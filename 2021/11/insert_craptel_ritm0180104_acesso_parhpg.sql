BEGIN
  UPDATE craptel
  SET CDOPPTEL = '@,A,P',
  LSOPPTEL = 'Acesso,Alterar,Parametro'
  WHERE craptel.nmdatela = 'PARHPG';
  COMMIT;
END;
