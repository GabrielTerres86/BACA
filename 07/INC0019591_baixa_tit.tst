PL/SQL Developer Test script 3.0
81
declare 
 -- Local variables here 
 i           INTEGER; 
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
   WHERE cob.cdcooper = 1 
     AND cob.nrdconta = 10099492
     AND cob.dtvencto = '11/01/2019'
     AND cob.nrdocmto = 2
   ORDER BY COB.CDCOOPER, COB.NRDCONTA, COB.DSDOCCOP, COB.NRDOCMTO; 

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
