BEGIN
  UPDATE cecred.tbcrd_carga_score a
     SET a.qtregis_fisica = 1406761,
         a.qtregis_juridi = 187315
   WHERE a.dtbase = '01/01/2024'
     AND a.cdmodelo = 3
     AND a.dsmodelo = 'Score Comportamental'
     AND a.cdopcao = 'A';     
 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20001,'Erro ao atualizar tbcrd_carga_score',true);
END;
