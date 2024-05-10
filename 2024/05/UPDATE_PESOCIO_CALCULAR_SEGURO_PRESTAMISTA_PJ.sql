BEGIN 

UPDATE CECRED.crapaca a
   SET a.lstparam = 'pr_cdcooper,pr_nmsocio,pr_dtnascsoc,pr_dtadmsoc,pr_pesocio'
 WHERE a.nmdeacao = 'CALCULAR_SEGURO_PRESTAMISTA_PJ';
 
COMMIT;
END;