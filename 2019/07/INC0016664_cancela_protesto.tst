PL/SQL Developer Test script 3.0
81
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
    WHERE (cdcooper, nrdconta, nrcnvcob, nrdocmto) IN (  (13,112984,112001,176),                                                         
                                                         (09,905712,108031,979),
                                                         (1,9637265,101002,109),
                                                         (13,601780,11230,836), 
                                                         (1,8479445,101002,805),
                                                         (13,238066,112002,911)  );                        
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
      SET insitcrt = 0,
          dtsitcrt = null
    WHERE cdcooper = rw.cdcooper 
      AND nrdconta = rw.nrdconta 
      AND nrcnvcob = rw.nrcnvcob 
      AND nrdocmto = rw.nrdocmto; 

   paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                               , pr_cdoperad => '1' 
                               , pr_dtmvtolt => trunc(SYSDATE) 
                               , pr_dsmensag => 'Protesto cancelado manualmente' 
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
0
0
