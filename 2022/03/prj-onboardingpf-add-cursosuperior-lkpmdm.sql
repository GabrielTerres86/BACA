BEGIN
  
  INSERT INTO cadastro.tbcadast_precadastro_depara_mdm (
    nmlookup_mdm
    , nmlookup_aimaro
    , cdmdm
    , cdaimaro
  ) VALUES (
    'LKP_CD_CURSO_SUPERIOR'
    , 'GNCDFRM'
    , 999
    , 0
  );
  
  INSERT INTO cadastro.tbcadast_precadastro_depara_mdm (
    nmlookup_mdm
    , nmlookup_aimaro
    , cdmdm
    , cdaimaro
  ) VALUES (
    'LKP_CD_CURSO_SUPERIOR'
    , 'GNCDFRM'
    , 998
    , 0
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
