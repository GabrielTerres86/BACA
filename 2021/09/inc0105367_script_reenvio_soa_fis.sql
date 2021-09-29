DECLARE

  CURSOR cr_parcelas IS
    SELECT *
      FROM tbepr_consignado_pagamento tcp
     WHERE tcp.cdcooper = 13
       AND tcp.nrdconta = 500100
       AND tcp.nrctremp = 129765
       AND tcp.instatus = 3
       AND tcp.dtmvtolt = to_date('16/09/2021', 'dd/mm/yyyy');
  rw_parcelas cr_parcelas%ROWTYPE;

  vr_xml_parcela VARCHAR2(32600);
  vr_tipo_pagto  VARCHAR2(300);
  vr_idpagamento tbepr_consignado_pagamento.idsequencia%TYPE;
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLTYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  conta_61646_10_07 CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>5</codigo>
    </cooperativa>
    <numeroContrato>30944</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>61646</codigoContaSemDigito>
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
    <dataEfetivacao>2021-07-15T12:30:22</dataEfetivacao> 
    <dataVencimento>2021-07-10</dataVencimento>
    <identificador>44247</identificador>
    <valor>540.57</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-09-30T00:00:00</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

  conta_242470_10_07 CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>13</codigo>
    </cooperativa>
    <numeroContrato>53912</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>242470</codigoContaSemDigito>
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
    <dataEfetivacao>2021-07-15T17:31:30</dataEfetivacao> 
    <dataVencimento>2021-07-10</dataVencimento>
    <identificador>44259</identificador>
    <valor>182.56</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-09-30T00:00:00</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

  conta_156680_31_08 CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>13</codigo>
    </cooperativa>
    <numeroContrato>125327</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>156680</codigoContaSemDigito>
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
    <dataEfetivacao>2021-08-31T12:32:46</dataEfetivacao> 
    <dataVencimento>2021-08-10</dataVencimento>
    <identificador>361008</identificador>
    <valor>233.56</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-09-30T00:00:00</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

BEGIN

  OPEN cr_parcelas;
  LOOP
    vr_dsxmlali := NULL;
    FETCH cr_parcelas
      INTO rw_parcelas;
    EXIT WHEN cr_parcelas%NOTFOUND;
    -- Verifica se o valor que esta sendo pago é total ou parcial
    -- Compara o valor calculado na tela com o valor da parcela
    IF rw_parcelas.vlpagpar = rw_parcelas.vlparepr THEN
      vr_tipo_pagto := ' <valor>' || TRIM(to_char(rw_parcelas.vlpagpar, '999999990.00')) ||
                       '</valor>';
    ELSE
      vr_tipo_pagto := ' <valorParcial>' || TRIM(to_char(rw_parcelas.vlpagpar, '999999990.00')) ||
                       '</valorParcial>';
    END IF;
    vr_idpagamento := NULL;
    vr_xml_parcela := ' <parcela>
                         <dataEfetivacao>' ||
                      to_char( /*pr_dtmvtolt*/ rw_parcelas.dtmvtolt, 'yyyy-mm-dd') || 'T' ||
                      to_char(SYSDATE, 'hh24:mi:ss') || '</dataEfetivacao> 
                         <dataVencimento>' ||
                      to_char(rw_parcelas.dtvencto, 'yyyy-mm-dd') ||
                      '</dataVencimento>
                         <identificador>' || rw_parcelas.idsequencia ||
                      '</identificador>' || vr_tipo_pagto || '</parcela>';
  
    vr_motenvio := 'REENVIARPAGTO'; -- NULL
    -- Gera o XML do pagamento a ser gravado no evento SOA
    empr0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_parcelas.cdcooper, -- código da cooperativa
                                          pr_nrdconta     => rw_parcelas.nrdconta, -- Número da conta
                                          pr_nrctremp     => rw_parcelas.nrctremp, -- Número do contrato de emprestimo
                                          pr_xml_parcelas => vr_xml_parcela, -- xml com as parcelas
                                          pr_tpenvio      => 1, -- tipo de envio 1 - INSTALLMENT_SETTLEMENT
                                          pr_tptransa     => 'DEBITO', --
                                          pr_motenvio     => vr_motenvio,
                                          pr_dsxmlali     => vr_dsxmlali, -- XML de saida do pagamento
                                          pr_dscritic     => vr_dscritic);                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
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
      ,rw_parcelas.cdcooper
      ,rw_parcelas.nrdconta
      ,rw_parcelas.nrctremp
      ,'PAGTO_PAGAR'
      ,'CONSIGNADO'
      ,'INSERT'
      ,SYSDATE
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,vr_dsxmlali.getClobVal());
  END LOOP;
  CLOSE cr_parcelas;


  INSERT INTO TBGEN_EVENTO_SOA
    (CDCOOPER
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
    (5
    ,61646
    ,30944
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_61646_10_07);

  INSERT INTO TBGEN_EVENTO_SOA
    (CDCOOPER
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
    (13
    ,242470
    ,53912
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_242470_10_07);

  INSERT INTO TBGEN_EVENTO_SOA
    (CDCOOPER
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
    (13
    ,156680
    ,125327
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_156680_31_08);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
