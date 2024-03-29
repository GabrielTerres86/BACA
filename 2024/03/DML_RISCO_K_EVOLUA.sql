DECLARE
 pr_cdcooper NUMBER := 14;
 pr_dtrefere DATE   := to_date('31/03/2024','DD/MM/RRRR');
 pr_retfile  VARCHAR2(4000) := NULL;
 pr_dscritic VARCHAR2(4000) := NULL;
 
  
BEGIN 
  CECRED.RISC0001_3103.pc_risco_k(pr_cdcooper => pr_cdcooper,
                           pr_dtrefere => pr_dtrefere,
                           pr_retfile  => pr_retfile,
                           pr_dscritic => pr_dscritic);
                           
  IF pr_dscritic IS NOT NULL THEN
    raise_application_error(-20500,'ERRO: '||pr_dscritic);
    
  END IF;
  
  raise_application_error(-20500,'GERADO COM SUCESSO: '||pr_retfile);
    
  
                             
end;
