BEGIN
  update cecred.crapprm 
     set dsvlrprm = ',27261441015,95333843953,05633307917,05196722912,'
   where cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     and cdcooper = 11;
     
  update cecred.crapprm 
     set dsvlrprm = ',19453302872,00744768900,02577766998,23443332900,'
   where cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     and cdcooper = 7;
     
  COMMIT;
END;
