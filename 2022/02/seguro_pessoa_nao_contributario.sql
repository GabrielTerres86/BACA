----------------------------Ribeiro------------------------------------------
--- Chave SEGPRE
BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'UTILIZA_REGRAS_SEGPRE', 'Utiliza novas regras prestamista SEGPRE S (SIM) e N (NÃO)', 'N');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('3 ERRO: ' || SQLERRM);
  ROLLBACK;
END;
/
-- TELA SEGPRE
BEGIN
  UPDATE CRAPACA SET LSTPARAM = LSTPARAM ||', PR_TPCUSTEI' where NMPACKAG = 'TELA_SEGPRE' AND NMDEACAO = 'SEGPRE_CONSULTAR';
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('4 ERRO: ' || SQLERRM);
  ROLLBACK;
END;
/
-- TELA SEGPRE
BEGIN
  UPDATE crapaca c
     SET c.lstparam = c.lstparam || ', PR_PAGSEGU, PR_SEQARQU'
   WHERE c.nmpackag = 'TELA_SEGPRE'
     AND c.nmproced = 'pc_alterar';
    COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('8 ERRO: ' || SQLERRM);
  ROLLBACK;
END;
/
BEGIN
  UPDATE CRAPACA SET LSTPARAM = REPLACE(LSTPARAM,'PR_VIGENCIA','PR_DTINIVIGENCIA') || ', PR_DTFIMVIGENCIA' WHERE NMPACKAG = 'TELA_SEGPRE' AND NMDEACAO = 'SEGPRE_ALTERAR';
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('12 ERRO: ' || SQLERRM);
  ROLLBACK;
END;
/
------------------RAIZA-------------------
-- PERMISSAO SEGPRE
BEGIN
  INSERT INTO crapace(nmdatela,
                      cddopcao,
                      cdoperad,
                      nmrotina,
                      cdcooper,
                      nrmodulo,
                      idevento,
                      idambace)
   (SELECT 'SEGPRE',
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace
      FROM CRAPACE 
     WHERE NMDATELA = 'TAB049');
  COMMIT;
EXCEPTION WHEN OTHERS THEN  
  DBMS_OUTPUT.PUT_LINE('11 ERRO: ' || SQLERRM);
  ROLLBACK;
END;
/
