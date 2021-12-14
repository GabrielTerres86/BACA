DECLARE
BEGIN
update crappro set dscedent = 'SUREK CIA LTDA - ME' where progress_recid = 298646427 ;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.put_line(SQLERRM);
    sistema.excecaoInterna(pr_compleme => 'INC0114189');  
END;                            
