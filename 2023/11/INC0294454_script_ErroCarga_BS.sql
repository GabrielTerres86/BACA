BEGIN

  UPDATE cecred.tbcrd_carga_score a
     SET a.qtregis_fisica = 1368734,
         a.qtregis_juridi = 182293
   WHERE a.dtbase = to_date('30/09/2023', 'DD/MM/RRRR')
     AND a.cdmodelo = 3
     AND a.dsmodelo = 'Score Comportamental'
     AND a.cdopcao = 'A';
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20001,'Erro ao atualizar tbcrd_carga_score',true);
END;
