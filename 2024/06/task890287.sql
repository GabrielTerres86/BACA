BEGIN
  update crapprm 
     set dsvlrprm = ',31028551991,69309426934,07185171997,86700405904,85106844991,'
   where cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     and cdcooper = 16;
     
  COMMIT;
END;  
