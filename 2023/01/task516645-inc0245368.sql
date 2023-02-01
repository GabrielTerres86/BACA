BEGIN                                  
   UPDATE CECRED.craprac SET vlsldatl = 0, 
                             vlslfmes = 0, 
                             idsaqtot = 1
                          WHERE cdcooper = 1
                          AND nrdconta = 87638363
                          AND idsaqtot = 0;
   COMMIT;
   EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'INC0245368');
      ROLLBACK;
END;
