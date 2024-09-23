BEGIN 

UPDATE CECRED.crapaca a
   SET a.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctrseg,pr_nrctremp,pr_vlpremio,pr_nmsocio,pr_vlcobertura,pr_pecobertura,pr_totcobertura'
 WHERE a.nmdeacao = 'BUSCA_RESUMO_PRESTAMISTA_PJ';
 
COMMIT;
END;