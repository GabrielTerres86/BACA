--Baixa de Boleto
declare
 vr_dserro   VARCHAR2(100); 
 vr_dscritic VARCHAR2(4000); 

 CURSOR cr_crapcob IS 
   SELECT cob.rowid 
       ,cob.incobran 
       ,cob.cdcooper 
       ,cob.nrdconta 
       ,cob.nrcnvcob 
       ,cob.nrdocmto 
       ,cob.dsdoccop 
       ,cob.nrnosnum 
    FROM crapcob cob 
   WHERE cob.cdcooper = 9
     AND cob.nrdconta = 32700
     AND cob.nrcnvcob = 10811
     AND cob.nrnosnum IN (00032700000003547,
                          00032700000003550,
                          00032700000003555,
                          00032700000003709,
                          00032700000003714,
                          00032700000003718,
                          00032700000003721,
                          00032700000003724,
                          00032700000003760,
                          00032700000003961,
                          00032700000003964
                          );

BEGIN 

 -- Test statements here 
   FOR rw IN cr_crapcob LOOP 

     IF rw.incobran = 0 THEN 
       UPDATE crapcob 
          SET incobran = 3, 
              dtdbaixa = TRUNC(SYSDATE) 
        WHERE cdcooper = rw.cdcooper 
          AND nrdconta = rw.nrdconta 
          AND nrcnvcob = rw.nrcnvcob 
          AND nrdocmto = rw.nrdocmto; 

       paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                   , pr_cdoperad => '1' 
                                   , pr_dtmvtolt => trunc(SYSDATE) 
                                   , pr_dsmensag => 'Titulo baixado manualmente' 
                                   , pr_des_erro => vr_dserro 
                                   , pr_dscritic => vr_dscritic ); 

     END IF; 

     COMMIT; 

   END LOOP; 


  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      cecred.pc_internal_exception;
END;
