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
           
      
    UPDATE crappep
       SET vlsdvpar = 0
          ,vlpagpar = to_char('190,80')
          ,vlsdvatu = 0
          ,inliquid = 1                      
     WHERE a.cdcooper = 13
       AND a.nrdconta = 242470
       AND a.nrctremp = 53912
       AND a.inliquid = 0;
       
         
    UPDATE crapepr
       SET inliquid = 1
          ,vlsdeved = 0
          ,vlsdvctr = 0
          ,vlsdevat = 0
          ,vlpapgat = 0 
     WHERE a.cdcooper = 13
       AND a.nrdconta = 242470
       AND a.nrctremp = 53912;    

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
