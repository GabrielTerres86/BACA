BEGIN  
  UPDATE tbseg_parametros_prst p
     SET p.tppessoa = DECODE(p.tppessoa,0,1,1,2);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
BEGIN
  UPDATE crapaca c
     SET c.lstparam = REPLACE(c.lstparam, 'NRAPOLIC', 'APOLICO')
   WHERE c.nmpackag = 'TELA_SEGPRE'
     AND c.lstparam LIKE '%NRAPOLIC%';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
BEGIN
  UPDATE crapaca c
     SET c.lstparam = c.lstparam || ', PR_PAGSEGU, PR_SEQARQU, PR_APOLINC'
   WHERE c.nmpackag = 'TELA_SEGPRE'
     AND c.nmproced = 'pc_alterar';
    COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/