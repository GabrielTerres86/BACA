BEGIN 

UPDATE CECRED.crapaca a
   SET a.lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_nmsocio,pr_nrcpfcgcsoc,pr_dtnascsoc,pr_dtadmsoc,pr_pesocio'
 WHERE a.nmdeacao = 'CALCULAR_SEGURO_PRESTAMISTA_PJ';
 
COMMIT;
END;