PL/SQL Developer Test script 3.0
181
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
    WHERE(cob.cdcooper = 1
      AND cob.nrcnvcob = 10120
      AND cob.nrdconta = 6584519
      AND cob.nrdocmto = 5540)
      OR (cob.cdcooper = 1
      AND cob.nrcnvcob = 101004
      AND cob.nrdconta = 8009597
      AND cob.nrdocmto = 22181)
      OR (cob.cdcooper = 1
      AND cob.nrcnvcob = 101002
      AND cob.nrdconta = 8479445
      AND cob.nrdocmto = 806)
      OR (cob.cdcooper = 1
      AND cob.nrcnvcob = 101004
      AND cob.nrdconta = 8995087
      AND cob.nrdocmto = 159)
      OR (cob.cdcooper = 1
      AND cob.nrcnvcob = 101004
      AND cob.nrdconta = 9220062
      AND cob.nrdocmto = 2412)      
      OR (cob.cdcooper = 2
      AND cob.nrcnvcob = 102002
      AND cob.nrdconta = 430048
      AND cob.nrdocmto = 537)
      OR (cob.cdcooper = 7
      AND cob.nrcnvcob = 106002
      AND cob.nrdconta = 156990
      AND cob.nrdocmto = 368)
      OR (cob.cdcooper = 9
      AND cob.nrcnvcob = 108002
      AND cob.nrdconta = 210714
      AND cob.nrdocmto = 25)
      OR (cob.cdcooper = 13
      AND cob.nrcnvcob = 112002
      AND cob.nrdconta = 128996
      AND cob.nrdocmto = 77)
      OR (cob.cdcooper = 13
      AND cob.nrcnvcob = 112002
      AND cob.nrdconta = 289051
      AND cob.nrdocmto = 22)
      OR (cob.cdcooper = 14
      AND cob.nrcnvcob = 113004
      AND cob.nrdconta = 9741
      AND cob.nrdocmto = 11031)
      OR (cob.cdcooper = 14
      AND cob.nrcnvcob = 113004
      AND cob.nrdconta = 9741
      AND cob.nrdocmto = 11032)
      OR (cob.cdcooper = 14
      AND cob.nrcnvcob = 113002
      AND cob.nrdconta = 30899
      AND cob.nrdocmto = 1154);       
      
 CURSOR cr_crapcob2 IS 
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
    WHERE(cob.cdcooper = 13
      AND cob.nrcnvcob = 112001
      AND cob.nrdconta = 61352
      AND cob.nrdocmto = 48);       
      
      
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
      SET incobran = 0, 
          dtdbaixa = NULL,
          insitcrt = 0,
          dtsitcrt = NULL
    WHERE cdcooper = rw.cdcooper 
      AND nrdconta = rw.nrdconta 
      AND nrcnvcob = rw.nrcnvcob 
      AND nrdocmto = rw.nrdocmto; 

   paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                               , pr_cdoperad => '1' 
                               , pr_dtmvtolt => trunc(SYSDATE) 
                               , pr_dsmensag => 'Titulo aberto manualmente' 
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

-- PROTESTADO ############################################
 -- Test statements here 
 FOR rw IN cr_crapcob2 LOOP 

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
          dtsitcrt = TO_DATE('07/05/2019','DD/MM/RRRR')
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

EXCEPTION 
 WHEN OTHERS THEN 
   ROLLBACK; 
   RAISE; 
END;
0
0
