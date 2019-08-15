/*
-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

         Cooperativa |      Conta |        Nro Dcto |     Boleto |    Emissão | Vencimento |        Valor
          1-VIACREDI |    8700044 |           28497 |       7360 | 29/04/2019 | 09/05/2019 | R$    119,73
          1-VIACREDI |    8700044 |         28602/A |       7367 | 29/04/2019 | 09/05/2019 | R$    109,83
          1-VIACREDI |   10260447 |       2679/0001 |        759 | 29/04/2019 | 05/05/2019 | R$    448,00
          1-VIACREDI |   10260447 |       3476/0001 |        809 | 29/04/2019 | 05/05/2019 | R$     69,00
       9-TRANSPOCRED |     210714 |       4327/0001 |         25 | 27/03/2019 | 24/04/2019 | R$    900,00

(Lucas Ranghetti - INC0020761)

*/

declare 
  -- Local variables here
  i integer;
  vr_dserro VARCHAR2(100);
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
     WHERE (cob.cdcooper,cob.cdbandoc,cob.nrdctabb,cob.nrcnvcob,cob.nrdconta,cob.nrdocmto)
      IN (
           (           1,          85,      101004,      101004,     8700044,        7360)
          ,(           1,          85,      101004,      101004,     8700044,        7367)
          ,(           1,          85,      101002,      101002,    10260447,         759)
          ,(           1,          85,      101002,      101002,    10260447,         809)
          ,(           9,          85,      108002,      108002,      210714,          25)
         )
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
                         
     IF rw.incobran = 3 THEN
       UPDATE crapcob SET incobran = 0, 
                          dtdbaixa = null
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
  
  ----Rollback 
  
  update crapceb a
     set a.flgapihm = 0
   where a.nrdconta in (10605940, 10668225)
     and a.nrconven = 101004;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
