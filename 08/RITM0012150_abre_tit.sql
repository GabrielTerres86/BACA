declare 
 -- Local variables here 
 i           INTEGER; 
 vr_dserro   VARCHAR2(100); 
 vr_dscritic VARCHAR2(4000); 

 CURSOR cr_crapcob IS 
    SELECT cob.rowid 
       ,cob.cdbandoc
       ,cob.nrdctabb
          ,cob.incobran 
          ,cob.cdcooper 
          ,cob.nrdconta 
          ,cob.nrcnvcob 
          ,cob.nrdocmto 
          ,cob.dsdoccop 
          ,cob.nrnosnum          
     FROM crapcob cob 
    WHERE cob.cdcooper = 1
      AND cob.nrdconta = 2029057
      AND cob.dtvencto = '26/11/2018'
      AND cob.nrcnvcob = 2280695
      AND cob.nrdocmto IN (42,43,44,45,46,47,49,50,51,52,53,54)
      AND cob.nrnosnum IN (22806958291000042
                          ,22806958291000043
                          ,22806958291000044
                          ,22806958291000045
                          ,22806958291000046
                          ,22806958291000047
                          ,22806958291000049
                          ,22806958291000050
                          ,22806958291000051
                          ,22806958291000052
                          ,22806958291000053
                          ,22806958291000054);       
                        
BEGIN 

 dbms_output.put_line('Situacao (0=A, 3=B, 5=L) - Cooperativa - Conta - Convenio - Boleto - Documento'); 

 -- Test statements here 
 FOR rw IN cr_crapcob LOOP 

   dbms_output.put_line(rw.incobran || ' - ' || 
   rw.cdcooper || ' - ' || 
   rw.nrdconta || ' - ' || 
   rw.nrcnvcob || ' - ' || 
   rw.nrdocmto || ' - ' || 
   rw.dsdoccop || ' - ' || 
   rw.nrnosnum ); 

   UPDATE crapcob 
      SET incobran = 3, 
          insitcrt = 5,
          dtdbaixa = TRUNC(SYSDATE) 
    WHERE cdcooper = rw.cdcooper 
      AND nrdconta = rw.nrdconta 
      AND nrcnvcob = rw.nrcnvcob 
      AND nrdocmto = rw.nrdocmto; 

   paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                               , pr_cdoperad => '1' 
                               , pr_dtmvtolt => trunc(SYSDATE) 
                               , pr_dsmensag => 'Titulo protestado manualmente' 
                               , pr_des_erro => vr_dserro 
                               , pr_dscritic => vr_dscritic ); 


   COMMIT; 

 END LOOP; 

 dbms_output.put_line(' '); 
 dbms_output.put_line('Apos atualizacao'); 

 FOR rw IN cr_crapcob LOOP 

   dbms_output.put_line(rw.incobran || ' - ' || 
   rw.cdcooper || ' - ' || 
   rw.nrdconta || ' - ' || 
   rw.nrcnvcob || ' - ' || 
   rw.nrdocmto || ' - ' || 
   rw.dsdoccop || ' - ' || 
   rw.nrnosnum); 

 END LOOP; 

 COMMIT; 

EXCEPTION 
 WHEN OTHERS THEN 
   ROLLBACK; 
   RAISE; 
END;
