declare 
 -- Local variables here 
  vr_dscritic VARCHAR2(4000); 
  vr_cdcritic INTEGER:=0;
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;  
 
 
  CURSOR cr_crapcob IS  
  SELECT c.*, c.rowid
  FROM crapcob c
  WHERE (c.cdcooper = 1
   AND  c.nrdconta = 6815111
   AND  c.nrdocmto = 44173
   AND  c.nrcnvcob = 10171   
   AND  c.incobran = 0)
   -- 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 52
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 53
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 54
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 55
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 56
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 57
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 58
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 59
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 60
   AND  c.incobran = 0) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 61
   AND  c.incobran = 0) 
   --
    OR (c.cdcooper = 11
   AND  c.nrdconta = 232360
   AND  c.nrcnvcob = 110030
   AND  c.nrdocmto = 835
   AND  c.incobran = 0) 
    OR (c.cdcooper = 11
   AND  c.nrdconta = 232360
   AND  c.nrcnvcob = 110030
   AND  c.nrdocmto = 836
   AND  c.incobran = 0) 
    OR (c.cdcooper = 11
   AND  c.nrdconta = 232360
   AND  c.nrcnvcob = 110030
   AND  c.nrdocmto = 837
   AND  c.incobran = 0) 
   --
    OR (c.cdcooper = 1
   AND  c.nrdconta = 8356688
   AND  c.nrcnvcob = 101001
   AND  c.nrdocmto = 37
   AND  c.incobran = 0) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 8532737
   AND  c.nrcnvcob = 101090
   AND  c.nrdocmto = 501
   AND  c.incobran = 0) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 9051481
   AND  c.nrcnvcob = 101004
   AND  c.nrdocmto = 517
   AND  c.incobran = 0) 
   --
    OR (c.cdcooper = 7
   AND  c.nrdconta = 212121
   AND  c.nrcnvcob = 10620
   AND  c.nrdocmto = 16762
   AND  c.incobran = 0) 
   --
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103061
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103145
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103251
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102913
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102602
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103060
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102953
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103241
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102627
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102734
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103249
   AND  c.incobran = 0) 
   --INC0052733
    OR (c.cdcooper = 11
   AND  c.nrdconta = 291986
   AND  c.nrcnvcob = 109004
   AND  c.nrdocmto = 5189
   AND  c.incobran = 0)    
   ORDER BY c.CDCOOPER, c.NRDCONTA, c.DSDOCCOP, c.NRDOCMTO; 
   
  CURSOR cr_crapcob_atz IS  
  SELECT c.*, c.rowid
  FROM crapcob c
  WHERE (c.cdcooper = 1
   AND  c.nrdconta = 6815111
   AND  c.nrdocmto = 44173
   AND  c.nrcnvcob = 10171   
   )
   -- 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 52
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 53
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 54
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 55
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 56
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 57
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 58
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 59
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 60
   ) 
    OR (c.cdcooper = 14
   AND  c.nrdconta = 85340
   AND  c.nrcnvcob = 113001
   AND  c.nrdocmto = 61
   ) 
   --
    OR (c.cdcooper = 11
   AND  c.nrdconta = 232360
   AND  c.nrcnvcob = 110030
   AND  c.nrdocmto = 835
   ) 
    OR (c.cdcooper = 11
   AND  c.nrdconta = 232360
   AND  c.nrcnvcob = 110030
   AND  c.nrdocmto = 836
   ) 
    OR (c.cdcooper = 11
   AND  c.nrdconta = 232360
   AND  c.nrcnvcob = 110030
   AND  c.nrdocmto = 837
   ) 
   --
    OR (c.cdcooper = 1
   AND  c.nrdconta = 8356688
   AND  c.nrcnvcob = 101001
   AND  c.nrdocmto = 37
   ) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 8532737
   AND  c.nrcnvcob = 101090
   AND  c.nrdocmto = 501
   ) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 9051481
   AND  c.nrcnvcob = 101004
   AND  c.nrdocmto = 517
   ) 
   --
    OR (c.cdcooper = 7
   AND  c.nrdconta = 212121
   AND  c.nrcnvcob = 10620
   AND  c.nrdocmto = 16762
   ) 
   --
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103061
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103145
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103251
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102913
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102602
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103060
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102953
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103241
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102627
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 102734
   ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 204609
   AND  c.nrcnvcob = 108003
   AND  c.nrdocmto = 103249
   ) 
   --INC0052733
    OR (c.cdcooper = 11
   AND  c.nrdconta = 291986
   AND  c.nrcnvcob = 109004
   AND  c.nrdocmto = 5189)    
   ORDER BY c.CDCOOPER, c.NRDCONTA, c.DSDOCCOP, c.NRDOCMTO; 
   
BEGIN 

  dbms_output.put_line('Situacao (0=A, 3=B, 5=L) - Cooperativa - Conta - Convenio - Boleto - Documento'); 

  FOR rw IN cr_crapcob LOOP 

    dbms_output.put_line(rw.incobran || ' - ' || 
    rw.cdcooper || ' - ' || 
    rw.nrdconta || ' - ' || 
    rw.nrcnvcob || ' - ' || 
    rw.nrdocmto || ' - ' || 
    rw.dsdoccop || ' - ' || 
    rw.nrnosnum ); 

    cobr0007.pc_inst_pedido_baixa ( pr_idregcob  => rw.rowid       --Rowid da Cobranca
                                   ,pr_cdocorre => '02'            --Codigo Ocorrencia
                                   ,pr_dtmvtolt => trunc(sysdate)  --Data pagamento
                                   ,pr_cdoperad => '1'             --Operador
                                   ,pr_nrremass =>  0              --Numero da Remessa
                                   ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                   ,pr_cdcritic => vr_cdcritic --Codigo da Critica
                                   ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      DBMS_OUTPUT.put_line('Erro - INC0052733 - '||vr_dscritic|| ' Boleto/Conta - '||rw.nrdocmto||' / '||rw.nrdconta);
    END IF;                      
  END LOOP; 

  COMMIT;    
 
  dbms_output.put_line(' '); 
  dbms_output.put_line('Situacao apos atualizacao'); 

  FOR rw IN cr_crapcob_atz LOOP 

   dbms_output.put_line(rw.incobran || ' - ' || 
   rw.cdcooper || ' - ' || 
   rw.nrdconta || ' - ' || 
   rw.nrcnvcob || ' - ' || 
   rw.nrdocmto || ' - ' || 
   rw.dsdoccop || ' - ' || 
   rw.nrnosnum); 

  END LOOP; 

EXCEPTION 
 WHEN OTHERS THEN 
   ROLLBACK; 
   dbms_output.put_line('Erro no script - INC0052733: '||sqlerrm);                                
   RAISE; 
END;
