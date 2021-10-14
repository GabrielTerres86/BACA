DECLARE

  conta_84891_06_08 CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>5</codigo>
    </cooperativa>
    <numeroContrato>26038</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>84891</codigoContaSemDigito>
      </contaCorrente>
    </emitente>
  </propostaContratoCredito>
  <lote>
    <tipoInteracao>
      <codigo>INSTALLMENT_SETTLEMENT</codigo>
    </tipoInteracao>
  </lote>
  <transacaoContaCorrente>
    <tipoInteracao>
      <codigo>DEBITO</codigo>
    </tipoInteracao>
  </transacaoContaCorrente>
  <parcela>
    <dataEfetivacao>2021-08-06T15:38:41</dataEfetivacao>
    <dataVencimento>2021-07-10</dataVencimento>
    <identificador>60826</identificador>
    <valor>83.62</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-10-07T00:00:00</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

  CURSOR cr_parcelas IS
    SELECT pep.cdcooper
          ,pep.nrdconta
          ,pep.nrctremp
          ,pep.dtultpag
          ,pep.vlsdvatu
          ,pep.inliquid
          ,pep.nrparepr
          ,pep.vlsdvpar
          ,pep.vlpagpar
      FROM tbepr_consignado_pagamento tcp
          ,crappep                    pep
     WHERE tcp.cdcooper = pep.cdcooper
       AND tcp.nrdconta = pep.nrdconta
       AND tcp.nrctremp = pep.nrctremp
       AND tcp.nrparepr = pep.nrparepr
       AND pep.inliquid = 0
       AND tcp.instatus = 3
       AND tcp.cdcooper = 13
       AND tcp.nrdconta = 500100
       AND tcp.nrctremp = 129765;
  rw_parcelas cr_parcelas%ROWTYPE;

BEGIN
  
    INSERT INTO TBGEN_EVENTO_SOA
      (IDEVENTO
      ,CDCOOPER
      ,NRDCONTA
      ,NRCTRPRP
      ,TPEVENTO
      ,TPRODUTO_EVENTO
      ,TPOPERACAO
      ,DHOPERACAO
      ,DSPROCESSAMENTO
      ,DSSTATUS
      ,DHEVENTO
      ,DSERRO
      ,NRTENTATIVAS
      ,DSCONTEUDO_REQUISICAO)
    VALUES
      (NULL
      ,5
      ,84891
      ,26038
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,conta_84891_06_08);
           
      
    UPDATE crappep a
       SET a.vlsdvpar = 0
          ,a.vlpagpar = to_char('190,80')
          ,a.vlsdvatu = 0
          ,a.inliquid = 1
     WHERE a.cdcooper = 13
       AND a.nrdconta = 242470
       AND a.nrctremp = 53912
       AND a.inliquid = 0
       and a.nrparepr = 18;
       
         
    UPDATE crapepr a
       SET a.inliquid = 1
          ,a.vlsdeved = 0
          ,a.vlsdvctr = 0
          ,a.vlsdevat = 0
          ,a.vlpapgat = 0 
     WHERE a.cdcooper = 13
       AND a.nrdconta = 242470
       AND a.nrctremp = 53912;    

 OPEN cr_parcelas;
  LOOP
  
    FETCH cr_parcelas
      INTO rw_parcelas;
    EXIT WHEN cr_parcelas%NOTFOUND;

    UPDATE crappep
       SET vlsdvpar = 0
          ,vlpagpar = to_char(rw_parcelas.vlsdvpar)
          ,vlsdvatu = 0
          ,inliquid = 1
     WHERE cdcooper = rw_parcelas.cdcooper
       AND nrdconta = rw_parcelas.nrdconta
       AND nrctremp = rw_parcelas.nrctremp
       AND inliquid = 0
       AND nrparepr = rw_parcelas.nrparepr;
  
  END LOOP;
  CLOSE cr_parcelas;

  UPDATE crapepr
     SET inliquid = 1
        ,vlsdeved = 0
        ,vlsdvctr = 0
        ,vlsdevat = 0
        ,vlpapgat = 0
   WHERE cdcooper = 13
     AND nrdconta = 242470
     AND nrctremp = 53912;

  UPDATE crapepr
     SET inliquid = 1
        ,vlsdeved = 0
        ,vlsdvctr = 0
        ,vlsdevat = 0
        ,vlpapgat = 0
   WHERE cdcooper = 13
     AND nrdconta = 500100
     AND nrctremp = 129765;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
