BEGIN                                  
   UPDATE CECRED.craprda
      SET vlsdrdca = 0, 
          insaqtot = 1
    WHERE cdcooper = 1
      AND nrdconta = 10695931
      AND insaqtot = 0
      AND nraplica = 25;
   COMMIT;
   EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'INC0344382');
      ROLLBACK;
END;
