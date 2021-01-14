/*

Cooperado precisa baixar o titulo em anexo, porem o sistema da a critica que esta Pendente de Processamento na CIP.

Cooperado solicita baixa manul do titulo.

C/C 217891 - Credcrea

Conforme solicitado pelo Rafael Imhof: Se trata do mesmo caso do CSC0042332. Em consulta verifiquei que nao ha esse titulo na cabine JD, pois nao esta registrado na CIP. Abrir um incidente para alterar o status no Aimaro para Baixado.

Ola,

Continuidade do protocolo 191226-005221.

Nao foi possivel a baixa do boleto n. 1348 pela tela Cobran. Cooperado nao tem mais acesso a conta e precisa da baixa do referido boleto.

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
         Cooperativa |      Conta |        Nro Dcto |     Boleto |    Emissao | Vencimento |        Valor
          7-CREDCREA |     217891 |      51944/0013 |       1348 | 02/06/2016 | 10/06/2017 | R$    299,00


(Heitor (Mouts) - INC0052560)
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
           (           7,          85,      106080,      106080,      217891,        1348)
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
