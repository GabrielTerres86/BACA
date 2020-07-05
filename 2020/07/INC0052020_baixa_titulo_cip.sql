/*

Cooperado deu instrucao de cancelamento do Serasa em 15/05 e agora esta tentando baixar o titulo.

Porem conforme o anexo a instrucao nao e possivel, pois da a critica de Pendente de Processamento na Cip.

Atenciosamente,
Central de Suporte ao Negocio - CSN
Central Ailos - Cooperativa Central de Credito

##########################################

Cooperado esta solicitando a baixa de boleto via site sem sucesso, devido sistema informar que titulo nao esta cadastrado na CIP. Em ligacao com a central de cobranca, fomos instruidos a solicitar a baixa via CRM.

Abaixo segue dados do boleto a ser baixado:

c/c 276.037-1 CINE FOTO MIDIA ME
Valor: R$420,00
Pagador: TUANE CAROLINA KOEHLER
Emissao: 06/12/2017
Nosso Numero: 02760371000000002

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
         Cooperativa |      Conta |        Nro Dcto |     Boleto |    Emissao | Vencimento |        Valor
          1-VIACREDI |    2760371 |        001/0001 |          2 | 06/12/2017 | 10/12/2017 | R$    420,00
          
(Heitor (Mouts) - INC0052020)
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
           (           1,          85,      101002,      101002,     2760371,           2)
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
