declare 
  vr_cdcritic number;
  vr_dscritic varchar2(2000);  
BEGIN
  -- Atualizar para sequancia correta e commitar o ajusta da sequencia
  begin
    UPDATE CRAPPRM PRM
           SET PRM.DSVLRPRM = 6796
         WHERE PRM.CDCOOPER = 0
           AND PRM.NMSISTEM = 'CRED'
           AND PRM.CDACESSO = 'CONSOR_SEQ_REMESSA' ;
    commit;       
  end;
  
  -- Processar arquivos pendentes
  cecred.PC_CNS_RECEBE_ARQ(pr_cdcooper => 3,
                           pr_cdcritic => vr_cdcritic,
                           pr_dscritic => vr_dscritic);

  if TRIM(vr_dscritic) IS NOT NULL then
     DBMS_OUTPUT.PUT(vr_dscritic);     
  end if; 
end;
