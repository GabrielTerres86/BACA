DECLARE
  vr_nrremessa credito.tbcred_pronampe_remessa.nrremessa%TYPE;
BEGIN
  vr_nrremessa := to_number(NVL(gene0001.fn_param_sistema('CRED', 0, 'NRSEQ_ARQUIVO_PRONAMPE'), '0') - 1);

  INSERT INTO credito.tbcred_pronampe_remessa
    (nrremessa
    ,dtremessa
    ,dhgeracao
    ,cdsituacao
    ,cdretorno
    ,dtprocessamento)
  VALUES
    (vr_nrremessa
    ,trunc(SYSDATE - 1)
    ,SYSDATE - 1
    ,4
    ,'000'
    ,trunc(SYSDATE - 1));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, 'Erro ao inicializar tabela TBCRED_PRONAMPE_REMESSA: ' || SQLERRM);
END;