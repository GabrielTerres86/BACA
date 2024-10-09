DECLARE
  vr_dscritic VARCHAR2(4000);
  
begin
  
  UPDATE tb_score_carga SET cdcpf_cnpj = '00000005405017' WHERE idscore_carga = 14101297;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00027396908' WHERE idscore_carga = 14520380;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00027845990' WHERE idscore_carga = 14520381;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00050760050' WHERE idscore_carga = 15351200;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00000027396908' WHERE idscore_carga = 15437949;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00000050760050' WHERE idscore_carga = 15432541;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00000027845990' WHERE idscore_carga = 14596923;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00000039477932' WHERE idscore_carga = 15423708;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00005405017' WHERE idscore_carga = 14164591;
  UPDATE tb_score_carga SET cdcpf_cnpj = '00039477932' WHERE idscore_carga = 14887270;
  
  commit;
  
  gestaoderisco.gerarCargaScore(pr_idscore => 1941,
                                pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    ROLLBACK;
    raise_application_error(-20000, 'ERRO: ' || vr_dscritic);
  END IF;

  COMMIT;
  
  begin
    UPDATE tbcrd_score c
       SET c.tppessoa = (SELECT MAX(ass.inpessoa) FROM crapass ass WHERE ass.nrcpfcnpj_base = c.nrcpfcnpjbase)
     WHERE c.dtbase = to_date('01/09/2024', 'DD/MM/RRRR')
       AND c.cdmodelo = 3;

    commit;
    
    update tbcrd_score_exclusao e
       SET e.tppessoa = (SELECT MAX(ass.inpessoa) FROM crapass ass WHERE ass.nrcpfcnpj_base = e.nrcpfcnpjbase)
     WHERE e.dtbase = to_date('01/09/2024', 'DD/MM/RRRR')
       AND e.cdmodelo = 3;
    
    commit;
    
  exception
    when others then
      rollback;
      raise_application_error(-20000, sqlerrm);
  end;
  
  commit;
  
exception
  when others then
    rollback;
    raise_application_error(-20000, sqlerrm);
end;
