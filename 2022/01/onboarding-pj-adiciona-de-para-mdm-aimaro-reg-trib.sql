BEGIN
  --
  INSERT INTO cadastro.tbcadast_precadastro_depara_mdm (
    nmlookup_mdm
    , nmlookup_aimaro
    , cdmdm
    , cdaimaro
  ) VALUES (
    'LKP_REGIMETRIBUTARIO'
    , 'TPREGIME_TRIBUTACAO'
    , 999
    , 0
  );
  --
  COMMIT;
  --
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ao atualizar de-para. ' || SQLERRM);
END;