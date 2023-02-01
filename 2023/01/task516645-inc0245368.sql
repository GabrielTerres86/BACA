BEGIN                                  
   UPDATE CECRED.craprac SET vlsldatl = 0, 
                             vlslfmes = 0, 
                             idsaqtot = 1
                          WHERE cdcooper = 1
                          AND nrdconta = 12361577
                          AND idsaqtot = 0
						  AND nraplica = 82;
   COMMIT;
   EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'INC0245368');
      ROLLBACK;
END;