DECLARE

  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida exception;

  CURSOR cr_craplcm IS
    SELECT b.dtvencto
          ,b.vlpagpar
          ,b.nrdconta
          ,b.nrctremp
          ,b.cdcooper
          ,b.nrparepr
          ,b.dtmvtolt
          ,b.idintegracao
      from crappep                    pep
          ,tbepr_consignado_pagamento b
     where trunc(b.dtincreg) >= TO_DATE('11/02/2022', 'DD/MM/YYYY')
       and pep.nrdconta = b.nrdconta
       and pep.nrctremp = b.nrctremp
       and pep.nrparepr = b.nrparepr
       and pep.cdcooper = b.cdcooper
       and b.instatus = 2
       and (pep.cdcooper, pep.nrdconta, pep.nrctremp, pep.nrparepr) in
           ((13, 22560, 84128, 15), (13, 60658, 148215, 4), (13, 545805, 105319, 11))
       and b.idintegracao = 1
     order by b.dtincreg;

  rw_craplcm cr_craplcm%ROWTYPE;

  CURSOR cr_crappep is
    SELECT b.dtvencto
          ,b.vlpagpar
          ,b.nrdconta
          ,b.nrctremp
          ,b.cdcooper
          ,b.nrparepr
          ,min(b.idsequencia) idsequencia
      from crappep                    pep
          ,tbepr_consignado_pagamento b
     where (pep.cdcooper, pep.nrdconta, pep.nrctremp, pep.nrparepr) IN
           ((13, 22560, 84128, 15), (13, 60658, 148215, 4), (13, 545805, 105319, 11))
       and pep.nrdconta = b.nrdconta
       and pep.nrctremp = b.nrctremp
       and pep.nrparepr = b.nrparepr
       and pep.cdcooper = b.cdcooper
       and pep.vlparepr = b.vlparepr
     group by b.dtvencto
             ,b.vlpagpar
             ,b.nrdconta
             ,b.nrctremp
             ,b.cdcooper
             ,b.nrparepr
             ,b.dtmvtolt
     order by b.cdcooper
             ,b.nrdconta
             ,b.nrctremp
             ,b.nrparepr;

  rw_crappep cr_crappep%rowtype;
BEGIN
  
  insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
  values (13, 22560, 84128, 15, 1, 612.65, 612.65, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('21-02-2022 17:36:39', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-02-2022 17:37:32', 'dd-mm-yyyy hh24:mi:ss'), 5, 0, '1', null, null, 1, to_date('21-02-2022', 'dd-mm-yyyy'));

  insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
  values (13, 545805, 105319, 11, 1, 363.57, 363.57, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('21-02-2022 17:36:40', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-02-2022 17:37:36', 'dd-mm-yyyy hh24:mi:ss'), 3, 0, '1', null, null, 1, to_date('21-02-2022', 'dd-mm-yyyy'));

  insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
  values (13, 60658, 148215, 4, 1, 197.66, 197.66, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('21-02-2022 17:36:44', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-02-2022 17:37:47', 'dd-mm-yyyy hh24:mi:ss'), 3, 0, '1', null, null, 1, to_date('21-02-2022', 'dd-mm-yyyy'));

  insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
  values (13, 22560, 84128, 15, 1, 598.49, 598.49, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 07:03:45', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 07:42:18', 'dd-mm-yyyy hh24:mi:ss'), 5, 0, '1', null, null, null, to_date('11-02-2022', 'dd-mm-yyyy'));

  insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
  values (13, 60658, 148215, 4, 1, 192.93, 192.93, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 07:04:02', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 07:28:15', 'dd-mm-yyyy hh24:mi:ss'), 3, 0, '1', null, null, null, to_date('11-02-2022', 'dd-mm-yyyy'));

  insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
  values (13, 545805, 105319, 11, 1, 354.90, 354.90, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 07:03:52', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 07:27:50', 'dd-mm-yyyy hh24:mi:ss'), 3, 0, '1', null, null, null, to_date('11-02-2022', 'dd-mm-yyyy'));

  COMMIT;

  FOR rw_craplcm IN cr_craplcm LOOP
    vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_craplcm.vlpagpar, '999999990.00')) ||
                      '</valor>';
    vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>' ||
                      to_char(rw_craplcm.dtmvtolt, 'yyyy-mm-dd') || 'T' ||
                      to_char(sysdate, 'hh24:mi:ss') ||
                      '</dataEfetivacao> 
                            <dataVencimento>' ||
                      to_char(rw_craplcm.dtvencto, 'yyyy-mm-dd') ||
                      '</dataVencimento>
                            <identificador>' || rw_craplcm.idintegracao ||
                      '</identificador>' || vr_tipo_pagto || '</parcela>';
    CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_craplcm.cdcooper,
                                                 pr_nrdconta     => rw_craplcm.nrdconta,
                                                 pr_nrctremp     => rw_craplcm.nrctremp,
                                                 pr_xml_parcelas => vr_xml_parcela,
                                                 pr_tpenvio      => 2,
                                                 pr_tptransa     => 'ESTORNO DEBITO',
                                                 pr_motenvio     => '',
                                                 pr_dsxmlali     => vr_dsxmlali,
                                                 pr_dscritic     => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    soap0003.pc_gerar_evento_soa(pr_cdcooper              => rw_craplcm.cdcooper,
                                 pr_nrdconta              => rw_craplcm.nrdconta,
                                 pr_nrctrprp              => rw_craplcm.nrctremp,
                                 pr_tpevento              => 'ESTORNO_ESTORN',
                                 pr_tproduto_evento       => 'CONSIGNADO',
                                 pr_tpoperacao            => 'INSERT',
                                 pr_dsconteudo_requisicao => vr_dsxmlali.getClobVal(),
                                 pr_idevento              => vr_idevento,
                                 pr_dscritic              => vr_dscritic);
  END LOOP;

  COMMIT;

  FOR rw_crappep IN cr_crappep LOOP
    vr_motenvio    := 'REENVIARPAGTO';
    vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_crappep.vlpagpar, '999999990.00')) ||
                      '</valor>';
    vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>' ||
                      to_char(rw_crappep.dtvencto, 'yyyy-mm-dd') || 'T' ||
                      to_char(sysdate, 'hh24:mi:ss') ||
                      '</dataEfetivacao> 
                            <dataVencimento>' ||
                      to_char(rw_crappep.dtvencto, 'yyyy-mm-dd') ||
                      '</dataVencimento>
                            <identificador>' || rw_crappep.idsequencia ||
                      '</identificador>' || vr_tipo_pagto || '</parcela>';
    CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_crappep.cdcooper,
                                                 pr_nrdconta     => rw_crappep.nrdconta,
                                                 pr_nrctremp     => rw_crappep.nrctremp,
                                                 pr_xml_parcelas => vr_xml_parcela,
                                                 pr_tpenvio      => 1,
                                                 pr_tptransa     => 'DEBITO',
                                                 pr_motenvio     => vr_motenvio,
                                                 pr_dsxmlali     => vr_dsxmlali,
                                                 pr_dscritic     => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    soap0003.pc_gerar_evento_soa(pr_cdcooper              => rw_crappep.cdcooper,
                                 pr_nrdconta              => rw_crappep.nrdconta,
                                 pr_nrctrprp              => rw_crappep.nrctremp,
                                 pr_tpevento              => 'PAGTO_PAGAR',
                                 pr_tproduto_evento       => 'CONSIGNADO',
                                 pr_tpoperacao            => 'INSERT',
                                 pr_dsconteudo_requisicao => vr_dsxmlali.getClobVal(),
                                 pr_idevento              => vr_idevento,
                                 pr_dscritic              => vr_dscritic);
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
