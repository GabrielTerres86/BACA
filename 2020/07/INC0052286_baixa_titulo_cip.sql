/*

Cooperado esta tentando baixar 2 titulos de 2017, foi dado instrucao de cancelamento de negativacao, porem quando tenta baixar o boleto o sistema apresenta a critica de instrucao pendente de processamento na CIP.

Cooperado solicita baixa manual desses dois titulos.

C/C 311804 - Credifoz

Atenciosamente,
Central de Suporte ao Negocio - CSN
Central Ailos - Cooperativa Central de Credito

Cooperado em questao esta com problema na baixa dos seguintes boletos:

 pagador :Juliana Nigro

nosso numero: 00311804000000112  numero do documento: 5689/0005  vencimento 10/09/2017
nosso numero: 00311804000000113  numero do documento:  5689/0006 vencimento 10/10/2017

na baixa tanto no nosso sistema quanto no sistema do cooperado informa que instrucao pendente de processamento na cip.

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
         Cooperativa |      Conta |        Nro Dcto |     Boleto |    Emissao | Vencimento |        Valor
         11-CREDIFOZ |     311804 |     	5689/0005 |        112 | 17/04/2017 | 10/09/2017 | R$    575,00
         11-CREDIFOZ |     311804 |       5689/0006 |        113 | 17/04/2017 | 10/10/2017 | R$    575,00

(Heitor (Mouts) - INC0052286)
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
           (          11,          85,      110090,      110090,      311804,         112),
           (          11,          85,      110090,      110090,      311804,         113)
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
