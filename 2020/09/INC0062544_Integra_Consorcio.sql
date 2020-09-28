begin
UPDATE CRAPPRM PRM
       SET PRM.DSVLRPRM = 6796
     WHERE PRM.CDCOOPER = 0
       AND PRM.NMSISTEM = 'CRED'
       AND PRM.CDACESSO = 'CONSOR_SEQ_REMESSA' ;
  commit;       
end;
/

declare 
pr_cdcooper number := 3;
  pr_cdcritic number;
  pr_dscritic varchar2(2000);  
begin
  cecred.PC_CNS_RECEBE_ARQ(pr_cdcooper => pr_cdcooper,
                           pr_cdcritic => pr_cdcritic,
                           pr_dscritic => pr_dscritic);
  if nvl(pr_dscritic,' ') <> ' ' or nvl(pr_cdcritic ,0) <> 0 then
     DBMS_OUTPUT.PUT(pr_dscritic);     
  end if; 
end;
/