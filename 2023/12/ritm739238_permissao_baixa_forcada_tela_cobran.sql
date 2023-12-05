DECLARE
  vr_tpregist CECRED.craptab.tpregist%TYPE;
BEGIN
  SELECT MAX(tab.tpregist) + 1
    INTO vr_tpregist
    FROM CECRED.craptab tab
   WHERE tab.cdacesso = 'USRCOBRBAIXA';
  
INSERT INTO CECRED.craptab
  (nmsistem
  ,tptabela
  ,cdempres
  ,cdacesso
  ,tpregist
  ,dstextab
  ,cdcooper)
VALUES
  ('CRED'
  ,'GENERI'
  ,0
  ,'USRCOBRBAIXA'
  ,vr_tpregist
  ,'F0033746'
  ,3);
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => 'RITM739238 - Nao foi possivel localizar craptab.tpregist quando tab.cdacesso = USRCOBRBAIXA'); 
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => 'RITM739238 - Erro ao incluir a Permissao de Baixa Forcada para a Tela COBRAN'); 
END;
