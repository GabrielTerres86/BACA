declare
  
  procedure estornoparcela_spr(
    p_cdcooper    in crappep.cdcooper%type,
    p_nrdconta    in crappep.nrdconta%type,
    p_nrctremp    in crappep.nrctremp%type,
    p_nrparepr    in crappep.nrparepr%type,
    p_dtincreg    in tbepr_consignado_pagamento.dtincreg%type,
    p_dtmovimento in tbepr_consig_contrato_tmp.dtmovimento%type,
    p_dtvencto    in crappep.dtvencto%type
  )
  is
    vr_xml_parcela varchar2(1000);
    vr_motenvio    varchar2(50);
    vr_dscritic    varchar2(4000);
    vr_tipo_pagto  varchar2(500);
    vr_idevento    tbgen_evento_soa.idevento%type;
    vr_dsxmlali    xmltype;
    vr_exc_saida   exception;
  
    cursor cr_craplcm is
      select b.dtvencto,
             b.vlpagpar,
             b.nrdconta,
             b.nrctremp,
             b.cdcooper,
             b.nrparepr,
             b.dtmvtolt,
             nvl(b.idintegracao, 0) idintegracao
        from crappep pep, tbepr_consignado_pagamento b, tbepr_consig_contrato_tmp c
       where trunc(b.dtincreg) >= p_dtincreg
         and pep.nrdconta = b.nrdconta
         and pep.nrctremp = b.nrctremp
         and pep.nrparepr = b.nrparepr
         and pep.cdcooper = b.cdcooper
         and pep.cdcooper = c.cdcooper
         and pep.nrdconta = c.nrdconta
         and pep.nrctremp = c.nrctremp
         and c.inclidesligado = 'N'
         and b.instatus = 2
         and pep.inliquid in (0, 1)
         and c.dtmovimento = p_dtmovimento
         and pep.dtvencto = p_dtvencto
         and (pep.cdcooper, pep.nrdconta, pep.nrctremp, pep.nrparepr) in ((p_cdcooper, p_nrdconta, p_nrctremp, p_nrparepr))
      order by b.dtincreg, b.nrdconta, b.nrctremp, b.nrparepr, b.idintegracao;
    
    rw_craplcm cr_craplcm%rowtype;
    
  begin
    for rw_craplcm in cr_craplcm loop
      vr_tipo_pagto := ' <valor>'||trim(to_char(rw_craplcm.vlpagpar,'999999990.00'))||'</valor>' ;
      vr_xml_parcela := ' <parcela>
                          <dataEfetivacao>'||to_char(rw_craplcm.dtmvtolt,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
                          <dataVencimento>'||to_char(rw_craplcm.dtvencto,'yyyy-mm-dd')||'</dataVencimento>
                          <identificador>'||rw_craplcm.idintegracao||'</identificador>'||
                          vr_tipo_pagto|| 
                      '</parcela>';
      
      cecred.empr0020.pc_gera_xml_pagamento_consig(pr_cdcooper    => rw_craplcm.cdcooper, 
                                                   pr_nrdconta     => rw_craplcm.nrdconta, 
                                                   pr_nrctremp     => rw_craplcm.nrctremp, 
                                                   pr_xml_parcelas => vr_xml_parcela, 
                                                   pr_tpenvio      => 2,           
                                                   pr_tptransa     =>'ESTORNO DEBITO',     
                                                   pr_motenvio     => '', 
                                                   pr_dsxmlali     => vr_dsxmlali, 
                                                   pr_dscritic     => vr_dscritic); 
        
      if vr_dscritic is not null  then
        raise vr_exc_saida;
      end if;
                                    
      soap0003.pc_gerar_evento_soa(pr_cdcooper               => rw_craplcm.cdcooper
                                  ,pr_nrdconta               => rw_craplcm.nrdconta
                                  ,pr_nrctrprp               => rw_craplcm.nrctremp
                                  ,pr_tpevento               => 'ESTORNO_ESTORN'
                                  ,pr_tproduto_evento        => 'CONSIGNADO'
                                  ,pr_tpoperacao             => 'INSERT'
                                  ,pr_dsconteudo_requisicao  => vr_dsxmlali.getclobval()
                                  ,pr_idevento               => vr_idevento
                                  ,pr_dscritic               => vr_dscritic);
    end loop;
  end estornoparcela_spr;
  
  procedure reenvioparcela_spr(p_cdcooper     in crappep.cdcooper%type,
                               p_nrdconta     in crappep.nrdconta%type,
                               p_nrctremp     in crappep.nrctremp%type,
                               p_nrparepr_ini in crappep.nrparepr%type,
                               p_nrparepr_fim in crappep.nrparepr%type,
                               p_dtvencto     in crappep.dtvencto%type default null)
  is
    vr_xml_parcela varchar2(1000);
    vr_motenvio    varchar2(50);
    vr_dscritic    varchar2(4000);
    vr_tipo_pagto  varchar2(500);
    vr_idevento    tbgen_evento_soa.idevento%type;
    vr_dsxmlali    xmltype;
    vr_exc_saida   exception;
    
    cursor cr_craplcm is       
      select b.dtvencto,
             b.vlpagpar,
             b.nrdconta,
             b.nrctremp,
             b.cdcooper,
             b.nrparepr,
             case
               when p_dtvencto is not null then p_dtvencto else b.dtmvtolt
             end as dtmvtolt,
             min(b.idsequencia) idsequencia
        from tbepr_consignado_pagamento b,
            (select cdcooper, nrdconta, nrctremp, nrparepr
               from crappep
              where (cdcooper, nrdconta, nrctremp) in ((p_cdcooper, p_nrdconta, p_nrctremp))
                and nrparepr between p_nrparepr_ini and p_nrparepr_fim
                and inliquid = 0
             ) pep
       where pep.nrdconta = b.nrdconta
         and pep.nrctremp = b.nrctremp
         and pep.cdcooper = b.cdcooper
         and pep.nrparepr = b.nrparepr
         and b.instatus <> 2
      group by b.dtvencto,
               b.vlpagpar,
               b.nrdconta,
               b.nrctremp,
               b.cdcooper,
               b.nrparepr,
               b.dtmvtolt
      order by b.cdcooper, b.nrdconta, b.nrctremp, b.nrparepr;
                  
    rw_craplcm cr_craplcm%rowtype;
    
  begin
    
    for rw_craplcm in cr_craplcm loop
        vr_motenvio := 'REENVIARPAGTO';
        vr_tipo_pagto := ' <valor>'||trim(to_char(rw_craplcm.vlpagpar,'999999990.00'))||'</valor>' ;
        vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>'||to_char(rw_craplcm.dtmvtolt,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
                            <dataVencimento>'||to_char(rw_craplcm.dtvencto,'yyyy-mm-dd')||'</dataVencimento>
                            <identificador>'||rw_craplcm.idsequencia||'</identificador>'||
                            vr_tipo_pagto|| 
                        '</parcela>';
        cecred.empr0020.pc_gera_xml_pagamento_consig(pr_cdcooper    => rw_craplcm.cdcooper,
                             pr_nrdconta     => rw_craplcm.nrdconta,
                             pr_nrctremp     => rw_craplcm.nrctremp,
                             pr_xml_parcelas => vr_xml_parcela,
                             pr_tpenvio      => 1,
                             pr_tptransa     =>'DEBITO',
                             pr_motenvio     => vr_motenvio,
                             pr_dsxmlali     => vr_dsxmlali,
                             pr_dscritic     => vr_dscritic); 
        if vr_dscritic is not null  then
            raise vr_exc_saida;
        end if;
                                        
        soap0003.pc_gerar_evento_soa(pr_cdcooper               => rw_craplcm.cdcooper
                                    ,pr_nrdconta               => rw_craplcm.nrdconta
                                    ,pr_nrctrprp               => rw_craplcm.nrctremp
                                    ,pr_tpevento               => 'PAGTO_PAGAR'
                                    ,pr_tproduto_evento        => 'CONSIGNADO'
                                    ,pr_tpoperacao             => 'INSERT'
                                    ,pr_dsconteudo_requisicao  => vr_dsxmlali.getclobval()
                                    ,pr_idevento               => vr_idevento
                                    ,pr_dscritic               => vr_dscritic);
    end loop;
  end reenvioparcela_spr;
  
begin
  estornoparcela_spr(p_cdcooper     => 13,
                     p_nrdconta     => 246190,
                     p_nrctremp     => 78967,
                     p_nrparepr     => 17,
                     p_dtincreg     => to_date('25/02/2022','DD/MM/YYYY'),
                     p_dtmovimento  => to_date('25/02/2022','DD/MM/YYYY'),
                     p_dtvencto     => to_date('10/02/2022','DD/MM/YYYY'));  

  commit;
  
  reenvioparcela_spr(p_cdcooper     => 13,
                     p_nrdconta     => 246190,
                     p_nrctremp     => 78967,
                     p_nrparepr_ini => 17,
                     p_nrparepr_fim => 96,
                     p_dtvencto     => to_date('25/02/2022','DD/MM/YYYY'));
  commit;

exception
  when others then
    raise_application_error(-20500, sqlerrm);
    rollback;    
end;