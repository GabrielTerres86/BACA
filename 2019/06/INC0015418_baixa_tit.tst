PL/SQL Developer Test script 3.0
102
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
      AND cob.nrcnvcob = 101002 
      AND cob.nrdconta = 8412901
      AND cob.nrdocmto IN ( 90, 91, 92, 93 , 94)
            
      OR ( cob.cdcooper = 1
       AND cob.nrdconta = 10296255
       AND cob.nrdocmto IN ( 170 )
       AND cob.nrcnvcob = 101002 )
       
      OR ( cob.cdcooper = 1
       AND cob.nrdconta = 10306366
       AND cob.nrdocmto IN ( 41 )
       AND cob.nrcnvcob = 101002 )
       
      OR ( cob.cdcooper = 1
       AND cob.nrdconta = 10064940 
       AND cob.nrdocmto IN ( 113 )
       AND cob.nrcnvcob = 101002 )

      OR ( cob.cdcooper = 1
       AND cob.nrdconta = 6858
       AND cob.nrdocmto IN ( 31 )
       AND cob.nrcnvcob = 101002 );
       
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
