BEGIN

  UPDATE crapaca aca 
     SET aca.lstparam = aca.lstparam || ',pr_vropcao'
   WHERE aca.nmdeacao = 'TAB057_DET_ARRECADA_AILOS';
  COMMIT;
	
END;