DECLARE
  
  CURSOR cr_craptab IS  
    
    SELECT tab.* 
      FROM craptab tab
      WHERE tab.cdcooper = 1
     AND UPPER(tab.nmsistem) = 'CRED'
     AND UPPER(tab.tptabela) = 'GENERI'
     AND tab.cdempres = 0
     AND UPPER(tab.cdacesso) = 'HRTRTITULO';           
  
BEGIN
  FOR rw_craptab IN cr_craptab LOOP
   
      insert into craptab (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO, TPREGIST, DSTEXTAB, CDCOOPER)
      values (rw_craptab.nmsistem, rw_craptab.tptabela, rw_craptab.cdempres, 'HRTRFATURA', rw_craptab.tpregist, rw_craptab.dstextab, rw_craptab.cdcooper);
      
  END LOOP;
  
  COMMIT; 
  
  EXCEPTION 
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
    ROLLBACK;
END;