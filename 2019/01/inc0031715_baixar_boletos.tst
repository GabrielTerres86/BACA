PL/SQL Developer Test script 3.0
108
/*

Dessa forma os títulos com instrução "01-Remessa de Titulos" ficam bloqueados no Ayllos e 
não aceitam baixa pela tela, tendo que ser baixados via script, conforme solicitação da área de cobrança.

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

         Cooperativa |      Conta |        Nro Dcto |     Boleto |    Emissão | Vencimento |        Valor
          1-VIACREDI |    7890290 |  000000103/0005 |         36 | 14/12/2017 | 20/04/2018 | R$  1.583,00
          1-VIACREDI |    7890290 |  000000104/0005 |         37 | 14/12/2017 | 20/04/2018 | R$    216,13
          1-VIACREDI |    6182550 |      CONTA/0001 |       1127 | 01/05/2018 | 23/05/2048 | R$  2.972,97
          1-VIACREDI |    6182550 |      CONTA/0002 |       1128 | 01/05/2018 | 07/06/2048 | R$  2.972,97
          1-VIACREDI |    6182550 |      CONTA/0003 |       1129 | 01/05/2018 | 22/06/2048 | R$  2.972,97
          1-VIACREDI |    6182550 |      CONTA/0004 |       1130 | 01/05/2018 | 07/07/2048 | R$  2.972,97
          1-VIACREDI |    6182550 |      CONTA/0005 |       1131 | 01/05/2018 | 22/07/2048 | R$  2.972,97




(Lucas Ranghetti - INC0031715 / INC0031717)

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
           (           1,           1,     1243373,     2280695,     7890290,          36)
          ,(           1,           1,     1243373,     2280695,     7890290,          37)
          ,(           1,          85,      101002,      101002,     6182550,        1127)
          ,(           1,          85,      101002,      101002,     6182550,        1128)
          ,(           1,          85,      101002,      101002,     6182550,        1129)
          ,(           1,          85,      101002,      101002,     6182550,        1130)
          ,(           1,          85,      101002,      101002,     6182550,        1131)
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
                         

       UPDATE crapcob SET incobran = 3, 
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
