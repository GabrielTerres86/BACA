BEGIN 

UPDATE CECRED.crapaca a
   SET a.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_vlpremio,pr_nmrepresentante,pr_dscargo,pr_nrcpfcgcrep,pr_nmsocio,pr_nrcpfcgcsoc,pr_pesocio,pr_dtadmsoc,pr_dtnascsoc'
 WHERE a.nmdeacao = 'CRIA_SEGURO_PRESTAMISTA_PJ';
 
COMMIT;
END;