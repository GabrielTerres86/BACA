BEGIN
  UPDATE cecred.tbcrd_carga_score a
     SET a.qtregis_fisica = (SELECT COUNT(1) from cecred.tbcrd_score x where x.cdmodelo = 3 AND x.TPPessoa = 1 AND x.dtbase = a.dtbase),
         a.qtregis_juridi = (SELECT COUNT(1) from cecred.tbcrd_score x where x.cdmodelo = 3 AND x.TPPessoa = 2 AND x.dtbase = a.dtbase)
   WHERE a.dtbase >= TO_DATE('01/01/2024','MM/DD/RRRR')
     AND a.cdmodelo = 3
     AND a.dsmodelo = 'Score Comportamental'
     AND a.cdopcao = 'A'  
     AND (a.qtregis_fisica = 0 OR a.qtregis_juridi = 0);
 
  dbms_output.put_line('tbcrd_carga_score = ' || to_char(SQL%ROWCOUNT) || ' atualizados');		 		 
  COMMIT;
	
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao tbcrd_carga_score: ' || SQLERRM);
END;