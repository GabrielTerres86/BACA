DECLARE
 
vr_xml_parcela VARCHAR2(1000);
vr_motenvio    VARCHAR2(50);
vr_dsxmlali    XMLType;
vr_dscritic    VARCHAR2(4000);
vr_idevento    tbgen_evento_soa.idevento%type;
vr_tipo_pagto  VARCHAR2(500);
vr_exc_saida   exception;

CURSOR cr_craplcm IS       
        SELECT b.dtvencto,
b.vlpagpar,
b.nrdconta,
b.nrctremp,
b.cdcooper,
b.nrparepr,
b.dtmvtolt,
b.idintegracao 
from crappep pep, tbepr_consignado_pagamento b
where trunc(b.dtincreg) >= TO_DATE('10/02/2022','DD/MM/YYYY')
and pep.nrdconta = b.nrdconta
and pep.nrctremp = b.nrctremp
and pep.nrparepr = b.nrparepr
and pep.cdcooper = b.cdcooper
and pep.cdcooper in (10)
and pep.nrdconta = 142786
and pep.nrctremp = 27174
and b.instatus = 2
order by b.cdcooper, b.nrdconta, b.nrctremp, b.nrparepr,b.dtmvtolt, b.idintegracao ;
    rw_craplcm cr_craplcm%ROWTYPE;
BEGIN
insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (10, 142786, 27174, 8, 1, 499.76, 68.22, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 07:00:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 07:34:06', 'dd-mm-yyyy hh24:mi:ss'), 2, 0, '1', null, null, 1, to_date('11-02-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (10, 142786, 27174, 8, 1, 441.73, 68.22, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 17:30:47', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 17:36:43', 'dd-mm-yyyy hh24:mi:ss'), 2, 0, '1', null, null, 2, to_date('11-02-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (10, 142786, 27174, 8, 1, 373.51, 8.22, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 21:00:51', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 21:04:01', 'dd-mm-yyyy hh24:mi:ss'), 2, 0, '1', null, null, 3, to_date('11-02-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (10, 142786, 27174, 8, 1, 305.64, 68.22, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('14-02-2022 17:30:59', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-02-2022 17:31:52', 'dd-mm-yyyy hh24:mi:ss'), 2, 0, '1', null, null, 1, to_date('14-02-2022', 'dd-mm-yyyy'));


  
  commit;
    FOR rw_craplcm IN cr_craplcm LOOP
        vr_tipo_pagto := ' <valor>'||trim(to_char(rw_craplcm.vlpagpar,'999999990.00'))||'</valor>' ;
        vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>'||to_char(rw_craplcm.dtvencto,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
                            <dataVencimento>'||to_char(rw_craplcm.dtvencto,'yyyy-mm-dd')||'</dataVencimento>
                            <identificador>'||rw_craplcm.idintegracao||'</identificador>'||
                            vr_tipo_pagto|| 
                        '</parcela>';
        CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper    => rw_craplcm.cdcooper, 
                                    pr_nrdconta     => rw_craplcm.nrdconta, 
                                    pr_nrctremp     => rw_craplcm.nrctremp, 
                                    pr_xml_parcelas => vr_xml_parcela, 
                                    pr_tpenvio      => 2,           
                                    pr_tptransa     =>'ESTORNO DEBITO',     
                                    pr_motenvio     => '', 
                                    pr_dsxmlali     => vr_dsxmlali, 
                                    pr_dscritic     => vr_dscritic); 
        IF vr_dscritic IS NOT NULL  THEN
            RAISE vr_exc_saida;
        END IF;
                                    
        soap0003.pc_gerar_evento_soa(pr_cdcooper               => rw_craplcm.cdcooper
                                    ,pr_nrdconta               => rw_craplcm.nrdconta
                                    ,pr_nrctrprp               => rw_craplcm.nrctremp
                                    ,pr_tpevento               => 'ESTORNO_ESTORN'
                                    ,pr_tproduto_evento        => 'CONSIGNADO'
                                    ,pr_tpoperacao             => 'INSERT'
                                    ,pr_dsconteudo_requisicao  => vr_dsxmlali.getClobVal()
                                    ,pr_idevento               => vr_idevento
                                    ,pr_dscritic               => vr_dscritic);
    END LOOP;    
                                
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
      RAISE_application_error(-20500,SQLERRM);
         ROLLBACK;
    
end;
