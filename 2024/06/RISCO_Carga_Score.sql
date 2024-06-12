DECLARE
  vr_dscritic VARCHAR2(4000);
  
begin
  

  gestaoderisco.gerarCargaScore(pr_idscore => 221,
                                pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    dbms_output.put_line('ERRO: ' || vr_dscritic);
    ROLLBACK;
  END IF;

  COMMIT;
end;
