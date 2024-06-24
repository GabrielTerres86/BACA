BEGIN                                  
   UPDATE CECRED.craprac SET vlsldatl = 0, 
                             vlslfmes = 0, 
                             idsaqtot = 1
                          WHERE cdcooper = 1
                            AND nrdconta = 10830308
                            AND idsaqtot = 0
                            AND nraplica = 60;
   COMMIT;
   EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'INC0340420');
      ROLLBACK;
END;
