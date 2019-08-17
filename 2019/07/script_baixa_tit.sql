
declare 
 -- Local variables here 
 i           INTEGER; 
 vr_dserro   VARCHAR2(100); 
 vr_dscritic VARCHAR2(4000);
 vr_cdcritic NUMBER;
  

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
      AND cob.nrcnvcob = 101070 
      AND cob.nrdconta = 7326890 
      AND cob.nrdocmto BETWEEN 1235 AND 2917
      AND cob.vltitulo = 5013.32;    
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
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
    /* UPDATE crapcob 
        SET incobran = 3, 
            dtdbaixa = TRUNC(SYSDATE) 
      WHERE cdcooper = rw.cdcooper 
        AND nrdconta = rw.nrdconta 
        AND nrcnvcob = rw.nrcnvcob 
        AND nrdocmto = rw.nrdocmto;*/ 
        
     cobr0007.pc_inst_pedido_baixa_titulo(pr_idregcob => rw.rowid
                                        , pr_cdocorre => 2
                                        , pr_dtmvtolt => TRUNC(SYSDATE)
                                        , pr_cdoperad => 1
                                        , pr_nrremass => 0
                                        , pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic);

                                        
     
     paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                 , pr_cdoperad => '1' 
                                 , pr_dtmvtolt => trunc(SYSDATE) 
                                 , pr_dsmensag => 'Titulo baixado manualmente' 
                                 , pr_des_erro => vr_dserro 
                                 , pr_dscritic => vr_dscritic ); 

   END IF; 

    

 END LOOP; 
 
 COMMIT;
 
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
