DECLARE
  vr_dscritic VARCHAR2(4000);
BEGIN

  insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'LINHA_PEAC_3040_SOLIDARI', 'Parametro linha LINHA_PEAC_3040_SOLIDARIO', '4627,4626');

  COMMIT;
  
  gestaoderisco.gerarCargaScore(pr_idscore => 1021,
                                pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    dbms_output.put_line('ERRO: ' || vr_dscritic);
    ROLLBACK;
  END IF;
  commit;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro no script de inser CRAPPRM: ' || SQLERRM);
    ROLLBACK;
END;	

