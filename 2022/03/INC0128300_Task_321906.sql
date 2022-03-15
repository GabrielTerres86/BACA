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

  insert into tbepr_consig_parcelas_tmp (IDSEQPARC, CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLSALDOPARC, VLMORAATRASO, VLMULTAATRASO, VLIOFATRASO, VLDESCANTEC, DTPAGTOPARC, INPARCELALIQ, INSTATUSPROCES, DSERROPROCES)
values (112452190, 13, 246190, 78967, 17, to_date('25-02-2022', 'dd-mm-yyyy'), to_date('03-03-2022', 'dd-mm-yyyy'), 174.77, 0.85, 3.41, 0.00, 0.00, null, '0', null, null);

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1170623, 13, 246190, 78967, 16, 2, 169.93, 169.93, to_date('10-01-2022', 'dd-mm-yyyy'), 2, to_date('27-12-2021 10:51:11', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-12-2021 10:51:13', 'dd-mm-yyyy hh24:mi:ss'), 0, 0, 'f0130223', null, null, 1, to_date('27-12-2021', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1071670, 13, 246190, 78967, 15, 2, 170.26, 170.26, to_date('10-12-2021', 'dd-mm-yyyy'), 2, to_date('30-11-2021 14:30:40', 'dd-mm-yyyy hh24:mi:ss'), to_date('30-11-2021 14:30:41', 'dd-mm-yyyy hh24:mi:ss'), 0, 0, 'f0130455', null, null, 1, to_date('30-11-2021', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1069902, 13, 246190, 78967, 14, 1, 174.58, 174.58, to_date('10-11-2021', 'dd-mm-yyyy'), 2, to_date('11-11-2021 07:06:15', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-11-2021 07:09:50', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, 1, to_date('11-11-2021', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179312, 13, 246190, 78967, 17, 1, 174.77, 174.77, to_date('10-02-2022', 'dd-mm-yyyy'), 3, to_date('02-03-2022 17:33:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('02-03-2022 17:33:57', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179314, 13, 246190, 78967, 17, 4, 174.77, 174.77, to_date('10-02-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:03:59', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179315, 13, 246190, 78967, 18, 4, 170.01, 170.01, to_date('10-03-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:01', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179316, 13, 246190, 78967, 19, 4, 167.45, 167.45, to_date('10-04-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:01', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179317, 13, 246190, 78967, 20, 4, 165.01, 165.01, to_date('10-05-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:03', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179318, 13, 246190, 78967, 21, 4, 162.53, 162.53, to_date('10-06-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:05', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179319, 13, 246190, 78967, 22, 4, 160.16, 160.16, to_date('10-07-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:31', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179320, 13, 246190, 78967, 23, 4, 157.75, 157.75, to_date('10-08-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:32', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179321, 13, 246190, 78967, 24, 4, 155.37, 155.37, to_date('10-09-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:35', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179322, 13, 246190, 78967, 25, 4, 153.10, 153.10, to_date('10-10-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:38', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179323, 13, 246190, 78967, 26, 4, 150.80, 150.80, to_date('10-11-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:38', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179324, 13, 246190, 78967, 27, 4, 148.60, 148.60, to_date('10-12-2022', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:41', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179325, 13, 246190, 78967, 28, 4, 146.36, 146.36, to_date('10-01-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:44', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179326, 13, 246190, 78967, 29, 4, 144.16, 144.16, to_date('10-02-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:43', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179327, 13, 246190, 78967, 30, 4, 142.20, 142.20, to_date('10-03-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:45', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179328, 13, 246190, 78967, 31, 4, 140.05, 140.05, to_date('10-04-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:46', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179329, 13, 246190, 78967, 32, 4, 138.01, 138.01, to_date('10-05-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:50', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179330, 13, 246190, 78967, 33, 4, 135.93, 135.93, to_date('10-06-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:51', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179331, 13, 246190, 78967, 34, 4, 133.95, 133.95, to_date('10-07-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:04:56', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179332, 13, 246190, 78967, 35, 4, 131.93, 131.93, to_date('10-08-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:27', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179333, 13, 246190, 78967, 36, 4, 129.95, 129.95, to_date('10-09-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:29', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179334, 13, 246190, 78967, 37, 4, 128.05, 128.05, to_date('10-10-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:32', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179335, 13, 246190, 78967, 38, 4, 126.12, 126.12, to_date('10-11-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:32', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179336, 13, 246190, 78967, 39, 4, 124.29, 124.29, to_date('10-12-2023', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:35', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179337, 13, 246190, 78967, 40, 4, 122.41, 122.41, to_date('10-01-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:37', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179338, 13, 246190, 78967, 41, 4, 120.57, 120.57, to_date('10-02-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:41', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179339, 13, 246190, 78967, 42, 4, 118.87, 118.87, to_date('10-03-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:42', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179340, 13, 246190, 78967, 43, 4, 117.08, 117.08, to_date('10-04-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:43', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179341, 13, 246190, 78967, 44, 4, 115.37, 115.37, to_date('10-05-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:45', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179342, 13, 246190, 78967, 45, 4, 113.64, 113.64, to_date('10-06-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:47', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179343, 13, 246190, 78967, 46, 4, 111.98, 111.98, to_date('10-07-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:49', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179344, 13, 246190, 78967, 47, 4, 110.29, 110.29, to_date('10-08-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:05:49', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179345, 13, 246190, 78967, 48, 4, 108.63, 108.63, to_date('10-09-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:15', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179346, 13, 246190, 78967, 49, 4, 107.05, 107.05, to_date('10-10-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:17', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179347, 13, 246190, 78967, 50, 4, 105.43, 105.43, to_date('10-11-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:19', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179348, 13, 246190, 78967, 51, 4, 103.90, 103.90, to_date('10-12-2024', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:21', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179349, 13, 246190, 78967, 52, 4, 102.33, 102.33, to_date('10-01-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:23', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179350, 13, 246190, 78967, 53, 4, 100.79, 100.79, to_date('10-02-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:25', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179351, 13, 246190, 78967, 54, 4, 99.42, 99.42, to_date('10-03-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:26', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179352, 13, 246190, 78967, 55, 4, 97.92, 97.92, to_date('10-04-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:26', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179353, 13, 246190, 78967, 56, 4, 96.49, 96.49, to_date('10-05-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:29', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179354, 13, 246190, 78967, 57, 4, 95.04, 95.04, to_date('10-06-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:31', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179355, 13, 246190, 78967, 58, 4, 93.66, 93.66, to_date('10-07-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:33', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179356, 13, 246190, 78967, 59, 4, 92.24, 92.24, to_date('10-08-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:35', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179357, 13, 246190, 78967, 60, 4, 90.86, 90.86, to_date('10-09-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:37', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179358, 13, 246190, 78967, 61, 4, 89.53, 89.53, to_date('10-10-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:48', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179359, 13, 246190, 78967, 62, 4, 88.18, 88.18, to_date('10-11-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:49', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179360, 13, 246190, 78967, 63, 4, 86.90, 86.90, to_date('10-12-2025', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:50', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179361, 13, 246190, 78967, 64, 4, 85.59, 85.59, to_date('10-01-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:53', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179362, 13, 246190, 78967, 65, 4, 84.30, 84.30, to_date('10-02-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:55', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179363, 13, 246190, 78967, 66, 4, 83.15, 83.15, to_date('10-03-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:55', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179364, 13, 246190, 78967, 67, 4, 81.90, 81.90, to_date('10-04-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:57', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179365, 13, 246190, 78967, 68, 4, 80.71, 80.71, to_date('10-05-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:06:59', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179366, 13, 246190, 78967, 69, 4, 79.49, 79.49, to_date('10-06-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:01', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179367, 13, 246190, 78967, 70, 4, 78.33, 78.33, to_date('10-07-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:01', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179368, 13, 246190, 78967, 71, 4, 77.15, 77.15, to_date('10-08-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:07', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179369, 13, 246190, 78967, 72, 4, 75.99, 75.99, to_date('10-09-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:07', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179370, 13, 246190, 78967, 73, 4, 74.88, 74.88, to_date('10-10-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:09', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179371, 13, 246190, 78967, 74, 4, 73.75, 73.75, to_date('10-11-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:11', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179372, 13, 246190, 78967, 75, 4, 72.68, 72.68, to_date('10-12-2026', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:13', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179373, 13, 246190, 78967, 76, 4, 71.58, 71.58, to_date('10-01-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:13', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179374, 13, 246190, 78967, 77, 4, 70.51, 70.51, to_date('10-02-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:14', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179375, 13, 246190, 78967, 78, 4, 69.55, 69.55, to_date('10-03-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:20', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179376, 13, 246190, 78967, 79, 4, 68.50, 68.50, to_date('10-04-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:20', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179377, 13, 246190, 78967, 80, 4, 67.50, 67.50, to_date('10-05-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:25', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179378, 13, 246190, 78967, 81, 4, 66.48, 66.48, to_date('10-06-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:27', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179379, 13, 246190, 78967, 82, 4, 65.51, 65.51, to_date('10-07-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:32', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179380, 13, 246190, 78967, 83, 4, 64.53, 64.53, to_date('10-08-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:07:35', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179381, 13, 246190, 78967, 84, 4, 63.56, 63.56, to_date('10-09-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:03', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179382, 13, 246190, 78967, 85, 4, 62.63, 62.63, to_date('10-10-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:03', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179383, 13, 246190, 78967, 86, 4, 61.69, 61.69, to_date('10-11-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:05', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179384, 13, 246190, 78967, 87, 4, 60.79, 60.79, to_date('10-12-2027', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:07', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179385, 13, 246190, 78967, 88, 4, 59.87, 59.87, to_date('10-01-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:11', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179386, 13, 246190, 78967, 89, 4, 58.97, 58.97, to_date('10-02-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:11', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179387, 13, 246190, 78967, 90, 4, 58.14, 58.14, to_date('10-03-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:13', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179388, 13, 246190, 78967, 91, 4, 57.26, 57.26, to_date('10-04-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:23', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179389, 13, 246190, 78967, 92, 4, 56.43, 56.43, to_date('10-05-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:35', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179184, 13, 246190, 78967, 17, 1, 175.37, 0.60, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('25-02-2022 12:41:55', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-02-2022 12:43:08', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, 1, to_date('25-02-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179390, 13, 246190, 78967, 93, 4, 55.58, 55.58, to_date('10-06-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:41', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179391, 13, 246190, 78967, 94, 4, 54.77, 54.77, to_date('10-07-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:53', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179392, 13, 246190, 78967, 95, 4, 53.94, 53.94, to_date('10-08-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:00:58', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1179393, 13, 246190, 78967, 96, 4, 53.13, 53.13, to_date('10-09-2028', 'dd-mm-yyyy'), 3, to_date('03-03-2022 07:00:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-03-2022 15:01:06', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, null, to_date('02-03-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1176898, 13, 246190, 78967, 17, 1, 174.20, 0.38, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 17:34:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 17:49:46', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, 2, to_date('11-02-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1175941, 13, 246190, 78967, 17, 1, 171.10, 0.38, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 07:04:03', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 07:33:22', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, 1, to_date('11-02-2022', 'dd-mm-yyyy'));

insert into tbepr_consignado_pagamento (IDSEQUENCIA, CDCOOPER, NRDCONTA, NRCTREMP, NRPAREPR, INORGPGT, VLPAREPR, VLPAGPAR, DTVENCTO, INSTATUS, DTINCREG, DTUPDREG, CDAGENCI, CDBCCXLT, CDOPERAD, INCONCILIADO, IDSEQPAGAMENTO, IDINTEGRACAO, DTMVTOLT)
values (1177379, 13, 246190, 78967, 17, 1, 173.83, 0.38, to_date('10-02-2022', 'dd-mm-yyyy'), 2, to_date('11-02-2022 21:05:28', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-02-2022 21:06:07', 'dd-mm-yyyy hh24:mi:ss'), 12, 0, '1', null, null, 3, to_date('11-02-2022', 'dd-mm-yyyy'));

commit;

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