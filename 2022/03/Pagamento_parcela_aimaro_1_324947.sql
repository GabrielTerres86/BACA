DECLARE
  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida exception;
  CURSOR cr_coop is
    SELECT REGEXP_SUBSTR('1,1,1,1,1,1,2,14,14,13','[^,]+', 1, LEVEL) AS CDCOOPER, 
           REGEXP_SUBSTR('12127426,13545418,14169320,13545418,12752827,7519796,622435,42005,338370,116491','[^,]+', 1, LEVEL) AS NRDCONTA,
           REGEXP_SUBSTR('3319430,5183107,5104679,5183107,3960181,2955918,304265,40111,43589,114060','[^,]+', 1, LEVEL) AS NRCTRATO,
           REGEXP_SUBSTR('14,1,1,1,34,17,10,5,3,10','[^,]+', 1, LEVEL) AS NRPAREPR,
           REGEXP_SUBSTR('25/02/2022,25/02/2022,25/02/2022,25/02/2022,24/02/2022,25/02/2022,25/02/2022,02/03/2022,02/03/2022,25/02/2022,','[^,]+', 1, LEVEL) AS DTMVTOLT          
      FROM DUAL 
    CONNECT BY REGEXP_SUBSTR('1,1,1,1,1,1,2,14,14,13','[^,]+', 1, LEVEL) IS NOT NULL;  
  
  CURSOR cr_crappep (pr_cdcooper IN NUMBER
                    ,pr_nrdconta IN NUMBER
                    ,pr_nrctrato IN NUMBER
                    ,pr_nrparepr IN NUMBER)is
    SELECT b.dtvencto
          ,b.vlpagpar
          ,b.nrdconta
          ,b.nrctremp
          ,b.cdcooper
          ,b.nrparepr
          ,min(b.idsequencia) idsequencia
      from crappep                    pep
          ,tbepr_consignado_pagamento b
     where pep.cdcooper = pr_cdcooper 
       and pep.nrdconta = pr_nrdconta  
       and pep.nrctremp = pr_nrctrato 
       and pep.nrparepr = pr_nrparepr
       and pep.nrdconta = b.nrdconta
       and pep.nrctremp = b.nrctremp
       and pep.nrparepr = b.nrparepr
       and pep.cdcooper = b.cdcooper
     group by b.dtvencto
             ,b.vlpagpar
             ,b.nrdconta
             ,b.nrctremp
             ,b.cdcooper
             ,b.nrparepr
     order by b.cdcooper
             ,b.nrdconta
             ,b.nrctremp
             ,b.nrparepr;
  rw_crappep cr_crappep%rowtype;
BEGIN  
  FOR rw_coop IN cr_coop LOOP  
    FOR rw_crappep IN cr_crappep(pr_cdcooper => TO_NUMBER(rw_coop.cdcooper)
                                ,pr_nrdconta => TO_NUMBER(rw_coop.nrdconta)
                                ,pr_nrctrato => TO_NUMBER(rw_coop.nrctrato)
                                ,pr_nrparepr => TO_NUMBER(rw_coop.nrparepr)) LOOP
      vr_motenvio    := 'REENVIARPAGTO';
      vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_crappep.vlpagpar, '999999990.00')) ||
                        '</valor>';
      vr_xml_parcela := ' <parcela>
                              <dataEfetivacao>' ||
                        to_char(to_date(rw_coop.dtmvtolt,'DD/MM/RRRR'), 'yyyy-mm-dd') || 'T' ||
                        to_char(sysdate, 'hh24:mi:ss') ||
                        '</dataEfetivacao> 
                              <dataVencimento>' ||
                        to_char(to_date(rw_crappep.dtvencto,'DD/MM/RRRR'), 'yyyy-mm-dd') ||
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
  END LOOP;  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;  
END;
