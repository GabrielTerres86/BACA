BEGIN 

UPDATE CECRED.crapaca a
   SET a.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_nmsocio,pr_nrcpfcgcsoc,pr_dtnascsoc,pr_dtadmsoc,pr_pesocio'
 WHERE a.nmdeacao = 'CALCULAR_SEGURO_PRESTAMISTA_PJ';
 
UPDATE CECRED.crapaca a
   SET a.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_vlcapseg,pr_vlpremio,pr_nmrepresentante,pr_dscargo,pr_nrcpfcgcrep,pr_nmsocio,pr_nrcpfcgcsoc,pr_pesocio,pr_dtadmsoc,pr_dtnascsoc,pr_vlcobertura,pr_pecobertura, pr_flgsegma'
 WHERE a.nmdeacao = 'CRIA_SEGURO_PRESTAMISTA_PJ'; 
 
UPDATE CECRED.crapaca a
   SET a.lstparam = 'pr_cdcooper,pr_vlpremio,pr_nmsocio,pr_vlcobertura,pr_pecobertura,pr_totcobertura'
 WHERE a.nmdeacao = 'BUSCA_RESUMO_PRESTAMISTA_PJ';  
 
COMMIT;
END;