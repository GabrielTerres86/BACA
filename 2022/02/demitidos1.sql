declare
  vr_cdcritic     crapcri.cdcritic%TYPE;
  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida   exception;
  vr_des_erro    VARCHAR2(100);   
  vr_tab_erro    GENE0001.typ_tab_erro;  
  vr_tab_saldo   EXTR0001.typ_tab_saldos;
  vr_vlsddisp    NUMBER:= 0;

  vr_nmdireto    VARCHAR2(100);
  vr_nmarqbkp    VARCHAR2(50) := 'validacademitidos1.csv';
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha   INTEGER := 0;  
  vr_ind_arquiv      utl_file.file_type;    

CURSOR cr_craplcm IS   
  SELECT b.dtvencto, B.VLPAGPAR, b.nrdconta, b.nrctremp, b.cdcooper, b.nrparepr, b.dtmvtolt,
         b.dtincreg, a.vllimcre, MIN(b.idsequencia) idsequencia
    from crappep pep, tbepr_consignado_pagamento b, tbepr_consig_contrato_tmp c, crapass a
   where trunc(b.dtincreg) >= TO_DATE('11/02/2022','DD/MM/YYYY')
     and pep.nrdconta = b.nrdconta
     and pep.nrctremp = b.nrctremp
     and pep.nrparepr = b.nrparepr
     and pep.cdcooper = b.cdcooper
     and pep.cdcooper = c.cdcooper
     and pep.nrdconta = c.nrdconta
     and pep.nrctremp = c.nrctremp
     and pep.cdcooper = a.cdcooper
     and pep.nrdconta = a.nrdconta
     and c.inclidesligado = 'S'
     and b.instatus = 3
     and c.dtmovimento = TO_DATE('14/02/2022','DD/MM/YYYY')
     and pep.dtvencto = TO_DATE('10/02/2022','DD/MM/YYYY')
group by b.dtvencto, B.VLPAGPAR, b.nrdconta, b.nrctremp, b.cdcooper, b.nrparepr, b.dtmvtolt,
         b.idintegracao, b.dtincreg, a.vllimcre   
ORDER BY b.cdcooper,b.nrdconta,b.nrctremp, b.dtincreg;

  rw_craplcm cr_craplcm%ROWTYPE;
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  
  PROCEDURE pc_escreve_ret(pr_cdcooper  IN crappep.cdcooper%type,
                           pr_nrdconta  IN crappep.nrdconta%type, 
                           pr_nrctremp  IN crappep.nrctremp%type,            
                           pr_dscmesg   IN VARCHAR2) IS
  BEGIN
      UPDATE TBEPR_CONSIGNADO_PAGAMENTO 
         SET INSTATUS = 2
       WHERE CDCOOPER = pr_cdcooper AND NRDCONTA = pr_nrdconta AND NRCTREMP = pr_nrctremp;
       gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_dscmesg); 
     commit;                                                        
  END; 
  
  
BEGIN
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0127185/';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqbkp        
                          ,pr_tipabert => 'W'                
                          ,pr_utlfileh => vr_ind_arquiv      
                          ,pr_des_erro => vr_dscritic);      
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_saida;
  END IF;    
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COOP;CONTA;CONTRATO;VALOR;SALDO;RESULTADO');   
  
  FOR rw_craplcm IN cr_craplcm LOOP
    vr_vlsddisp := 0;
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_craplcm.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_saida;
    END IF;
    CLOSE btch0001.cr_crapdat;
  
    EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_craplcm.cdcooper 
                               ,pr_rw_crapdat => rw_crapdat
                               ,pr_cdagenci   => 1 
                               ,pr_nrdcaixa   => 0
                               ,pr_cdoperad   => '1'
                               ,pr_nrdconta   => rw_craplcm.nrdconta
                               ,pr_vllimcre   => rw_craplcm.vllimcre
                               ,pr_dtrefere   => rw_crapdat.dtmvtolt
                               ,pr_flgcrass   => FALSE 
                               ,pr_tipo_busca => 'A' 
                               ,pr_des_reto   => vr_des_erro 
                               ,pr_tab_sald   => vr_tab_saldo
                               ,pr_tab_erro   => vr_tab_erro);  
    IF vr_des_erro = 'NOK' THEN
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craplcm.nrdconta;
        pc_escreve_ret(rw_craplcm.cdcooper, rw_craplcm.nrdconta,rw_craplcm.nrctremp, rw_craplcm.cdcooper || ';' || rw_craplcm.nrdconta || ';' || rw_craplcm.nrctremp || ';' ||
                                     TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || ';' ||
                                     TRIM(to_char(vr_vlsddisp, '999999990.00'))  || ';' || 'Alterada Flag de processamento - '|| vr_dscritic);                                      
      continue;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_craplcm.nrdconta;
        pc_escreve_ret(rw_craplcm.cdcooper, rw_craplcm.nrdconta,rw_craplcm.nrctremp, rw_craplcm.cdcooper || ';' || rw_craplcm.nrdconta || ';' || rw_craplcm.nrctremp || ';' ||
                       TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || ';' ||
                       TRIM(to_char(vr_vlsddisp, '999999990.00'))  || ';' ||'Alterada Flag de processamento - '|| vr_dscritic);        
      continue;     
      END IF;
    END IF;
    IF vr_tab_saldo.Count = 0 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';    
      pc_escreve_ret(rw_craplcm.cdcooper, rw_craplcm.nrdconta,rw_craplcm.nrctremp, rw_craplcm.cdcooper || ';' || rw_craplcm.nrdconta || ';' || rw_craplcm.nrctremp || ';' ||
                     TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || ';' ||
                     TRIM(to_char(vr_vlsddisp, '999999990.00'))  || ';' ||'Alterada Flag de processamento - '|| vr_dscritic);          
      continue;
    ELSE
      vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0);
    END IF;                                
    
    IF (vr_vlsddisp >= rw_craplcm.vlpagpar) THEN
      vr_motenvio    := 'REENVIARPAGTO';
      vr_tipo_pagto  := ' <valor>' || TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || '</valor>';
      vr_xml_parcela := ' <parcela>
                <dataEfetivacao>' || to_char(rw_craplcm.dtvencto,'yyyy-mm-dd') || 'T' || to_char(SYSDATE, 'hh24:mi:ss') || '</dataEfetivacao>
                <dataVencimento>' || to_char(rw_craplcm.dtvencto, 'yyyy-mm-dd') || '</dataVencimento>
                <identificador>' || rw_craplcm.idsequencia || '</identificador>' || vr_tipo_pagto || 
              '</parcela>';
    
      CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_craplcm.cdcooper, 
                                                   pr_nrdconta     => rw_craplcm.nrdconta, 
                                                   pr_nrctremp     => rw_craplcm.nrctremp,
                                                   pr_xml_parcelas => vr_xml_parcela, 
                                                   pr_tpenvio      => 1, 
                                                   pr_tptransa     => 'DEBITO',
                                                   pr_motenvio     => vr_motenvio, 
                                                   pr_dsxmlali     => vr_dsxmlali, 
                                                   pr_dscritic     => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      soap0003.pc_gerar_evento_soa(pr_cdcooper              => rw_craplcm.cdcooper,
                                   pr_nrdconta              => rw_craplcm.nrdconta,
                                   pr_nrctrprp              => rw_craplcm.nrctremp,
                                   pr_tpevento              => 'PAGTO_PAGAR',
                                   pr_tproduto_evento       => 'CONSIGNADO',
                                   pr_tpoperacao            => 'INSERT',
                                   pr_dsconteudo_requisicao => vr_dsxmlali.getClobVal(),
                                   pr_idevento              => vr_idevento,
                                   pr_dscritic              => vr_dscritic);
                                     
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, rw_craplcm.cdcooper || ';' || rw_craplcm.nrdconta || ';' || rw_craplcm.nrctremp || ';' ||
                                     TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || ';' ||
                                     TRIM(to_char(vr_vlsddisp, '999999990.00'))  || ';' || 'Pagamento enviado a FIS');
      COMMIT;                                    
    ELSE
        pc_escreve_ret(rw_craplcm.cdcooper, rw_craplcm.nrdconta,rw_craplcm.nrctremp, rw_craplcm.cdcooper || ';' || rw_craplcm.nrdconta || ';' || rw_craplcm.nrctremp || ';' ||
                       TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || ';' ||
                       TRIM(to_char(vr_vlsddisp, '999999990.00'))  || ';' ||'Alterada Flag de processamento');       
    end if;   
  END LOOP;

  COMMIT;
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
EXCEPTION
  WHEN vr_exc_saida THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); 
  WHEN OTHERS THEN
    raise_application_error(-20050, SQLERRM);
    cecred.pc_internal_exception;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);      
    ROLLBACK;
END;
