DECLARE
 
vr_xml_parcela VARCHAR2(1000);
vr_motenvio    VARCHAR2(50);
vr_dsxmlali    XMLType;
vr_dscritic    VARCHAR2(4000);
vr_idevento    tbgen_evento_soa.idevento%type;
vr_tipo_pagto  VARCHAR2(500);
vr_exc_saida   exception;

CURSOR cr_craplcm IS       
SELECT 
b.dtvencto,
b.vlpagpar,
b.nrdconta,
b.nrctremp,
b.cdcooper,
b.nrparepr,
b.dtmvtolt,
b.idintegracao 
from crappep pep, tbepr_consignado_pagamento b, tbepr_consig_contrato_tmp c
where trunc(b.dtincreg) >= TO_DATE('11/02/2022','DD/MM/YYYY')
and pep.nrdconta = b.nrdconta
and pep.nrctremp = b.nrctremp
and pep.nrparepr = b.nrparepr
and pep.cdcooper = b.cdcooper
and pep.cdcooper = c.cdcooper
and pep.nrdconta = c.nrdconta
and pep.nrctremp = c.nrctremp
and c.inclidesligado = 'N'
and b.instatus = 2
and pep.inliquid = 0
and c.dtmovimento = TO_DATE('14/02/2022','DD/MM/YYYY')
and pep.dtvencto = TO_DATE('10/02/2022','DD/MM/YYYY')
and (pep.cdcooper, pep.nrdconta, pep.nrctremp) NOT in  
((1,80346790,2502227),
(1,6683045,3919366),
(1,1705660,4310541),
(1,13189425,4506686),
(2,860301,270125),
(2,580830,265383),
(10,77038,32862),
(10,184047,37243),
(10,65242,35501),
(10,73164,26413),
(10,143324,14165),
(10,20206,14702),
(13,64955,98020),
(13,298875,58507),
(13,91251,51354),
(13,284220,102835),
(13,22560,84128),
(13,26590,61342),
(13,243477,68277),
(13,330248,172256),
(13,202657,163091),
(13,240990,125145),
(13,151980,155930),
(13,568350,153429),
(13,568350,116414),
(13,258636,165420),
(13,241164,86674),
(13,192503,96421),
(13,169404,51795),
(13,418978,97572),
(13,418978,98664),
(13,408042,74837),
(13,171824,60075),
(13,171824,88262),
(13,164135,72291),
(13,164135,72288),
(13,164135,72293),
(13,153265,64028),
(13,188662,62268),
(13,188662,88267),
(13,188662,80612),
(13,328375,52428),
(13,328375,58256),
(13,149764,73063),
(13,149764,96325),
(13,319864,91954),
(13,598410,132138),
(13,598410,144272),
(13,480568,139833),
(13,480568,100924),
(13,480568,105046),
(13,480568,113358),
(13,480568,122032),
(13,450294,135394),
(13,60658,148215),
(13,207497,160961),
(13,545805,105319),
(13,170119,119673),
(13,484067,100800),
(13,108901,80312),
(13,108901,164635),
(13,108901,122595),
(13,287806,159595),
(13,287806,85063),
(13,186805,63844),
(13,678856,171515),
(16,267252,164600),
(16,753793,323121),
(16,905194,373651),
(16,905194,304728),
(1,80476260,2816090),
(1,7519796,2955918),
(13,670324,167935))

order by b.cdcooper, b.nrdconta, b.nrctremp, b.nrparepr, b.idintegracao ;

    rw_craplcm cr_craplcm%ROWTYPE;
BEGIN
  
    FOR rw_craplcm IN cr_craplcm LOOP
        vr_tipo_pagto := ' <valor>'||trim(to_char(rw_craplcm.vlpagpar,'999999990.00'))||'</valor>' ;
        vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>'||to_char(rw_craplcm.dtmvtolt,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
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
