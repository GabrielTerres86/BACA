DECLARE
  vr_exception  EXCEPTION;
  vr_qtdreg     NUMBER(5) DEFAULT 0;
BEGIN
  --
  -- Deleta registros desatualizados do DE-PARA de dados do MDM para o Aimaro.
  DELETE cadastro.tbcadast_precadastro_depara_mdm
  WHERE nmlookup_aimaro =  'TPPREFERENCIACONTATO'
    AND cdmdm           IN (1,2,3,4);
  --
  vr_qtdreg := SQL%ROWCOUNT;
  --
  IF vr_qtdreg <> 4 THEN
    --
    RAISE vr_exception;
    --
  END IF;
  --
  COMMIT;
  --
EXCEPTION
  WHEN vr_exception THEN
    RAISE_APPLICATION_ERROR(-20000, 'Alteração da quantidade incorreta de registros, esperado 4, alterando ' || vr_qtdreg);
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao rodar o delete: ' || SQLERRM);
END;
