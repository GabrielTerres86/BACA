/*

Dessa forma os títulos com instrução "01-Remessa de Titulos" ficam bloqueados no Ayllos e 
não aceitam baixa pela tela, tendo que ser baixados via script, conforme solicitação da área de cobrança.

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

         Cooperativa |      Conta |      Boletos    |
          1-VIACREDI |    9878300 |  12336 a 12361  |


(Daniel Lombardi (Mouts) - INC0048542)

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
           (           1,          85,      101002,      101002,     9878300,       12336),
           (           1,          85,      101002,      101002,     9878300,       12337),
           (           1,          85,      101002,      101002,     9878300,       12338),
           (           1,          85,      101002,      101002,     9878300,       12339),
           (           1,          85,      101002,      101002,     9878300,       12340),
           (           1,          85,      101002,      101002,     9878300,       12341),
           (           1,          85,      101002,      101002,     9878300,       12342),
           (           1,          85,      101002,      101002,     9878300,       12343),
           (           1,          85,      101002,      101002,     9878300,       12344),
           (           1,          85,      101002,      101002,     9878300,       12345),
           (           1,          85,      101002,      101002,     9878300,       12346),
           (           1,          85,      101002,      101002,     9878300,       12347),
           (           1,          85,      101002,      101002,     9878300,       12348),
           (           1,          85,      101002,      101002,     9878300,       12349),
           (           1,          85,      101002,      101002,     9878300,       12350),
           (           1,          85,      101002,      101002,     9878300,       12351),
           (           1,          85,      101002,      101002,     9878300,       12352),
           (           1,          85,      101002,      101002,     9878300,       12353),
           (           1,          85,      101002,      101002,     9878300,       12354),
           (           1,          85,      101002,      101002,     9878300,       12355),
           (           1,          85,      101002,      101002,     9878300,       12356),
           (           1,          85,      101002,      101002,     9878300,       12357),
           (           1,          85,      101002,      101002,     9878300,       12358),
           (           1,          85,      101002,      101002,     9878300,       12359),
           (           1,          85,      101002,      101002,     9878300,       12360),
           (           1,          85,      101002,      101002,     9878300,       12361)
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
