BEGIN

  UPDATE cecred.tbcrd_carga_score a
     SET a.qtregis_fisica = 1373144,
         a.qtregis_juridi = 183615
   WHERE a.dtbase = '03/10/2023'
     AND a.cdmodelo = 3
     AND a.dsmodelo = 'Score Comportamental'
     AND a.cdopcao = 'A';
     
  UPDATE cecred.tbcrd_carga_score a
     SET a.qtregis_fisica = 1384067,
         a.qtregis_juridi = 185260
   WHERE a.dtbase = '01/11/2023'
     AND a.cdmodelo = 3
     AND a.dsmodelo = 'Score Comportamental'
     AND a.cdopcao = 'A';
     
  UPDATE cecred.tbcrd_carga_score a
     SET a.qtregis_fisica = 1393770,
         a.qtregis_juridi = 186438
   WHERE a.dtbase = '01/12/2023'
     AND a.cdmodelo = 3
     AND a.dsmodelo = 'Score Comportamental'
     AND a.cdopcao = 'A';      
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20001,'Erro ao atualizar tbcrd_carga_score',true);
END;
