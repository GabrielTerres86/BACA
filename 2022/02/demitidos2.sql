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
  vr_nmarqbkp    VARCHAR2(50) := 'validacademitidos2.csv';
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha   INTEGER := 0;  
  vr_ind_arquiv      utl_file.file_type;    

CURSOR cr_craplcm IS   
SELECT b.dtvencto, B.VLPAGPAR, b.nrdconta, b.nrctremp, b.cdcooper, a.vllimcre,
       b.nrparepr, b.dtmvtolt, b.idintegracao, b.dtincreg, MIN(b.idsequencia) idsequencia
  from crappep pep, tbepr_consignado_pagamento b, crapass a
 where trunc(b.dtincreg) >= TO_DATE('11/02/2022','DD/MM/YYYY')
   and pep.nrdconta = b.nrdconta
   and pep.nrctremp = b.nrctremp
   and pep.nrparepr = b.nrparepr
   and pep.cdcooper = b.cdcooper
   and pep.cdcooper = a.cdcooper
   and pep.nrdconta = a.nrdconta   
   and b.instatus in (3)
   and pep.dtvencto = TO_DATE('10/02/2022','DD/MM/YYYY')
   and (b.cdcooper, b.nrdconta, b.nrctremp ) in
      ((1,80346790,2502227),
      (1,11035528,4901280),
      (1,7486090,4887550),
      (1,10278630,4778376),
      (2,860301,270125),
      (2,580830,265383),
      (7,31038,49365),
      (7,427497,68493),
      (9,529524,19100179),
      (9,511358,20100239),
      (9,500895,20100431),
      (9,500410,20100439),
      (9,501646,20100441),
      (9,515558,20100495),
      (9,530042,20100507),
      (9,514640,20100508),
      (9,525774,20100533),
      (9,511293,20100547),
      (9,514373,20100578),
      (9,502987,20100614),
      (9,507806,20100630),
      (9,501239,20200572),
      (9,500917,20300019),
      (9,506648,20300042),
      (9,503045,20400653),
      (9,526096,21100115),
      (9,504521,21100152),
      (9,530026,21100168),
      (9,525820,21100180),
      (9,504530,21100253),
      (9,503126,21200019),
      (9,502464,21200155),
      (9,505897,21300019),
      (9,502928,21300035),
      (10,77038,32862),
      (10,184047,37243),
      (10,65242,35501),
      (10,73164,26413),
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
      (13,450294,135394),
      (13,60658,148215),
      (13,207497,160961),
      (13,545805,105319),
      (13,170119,119673),
      (13,484067,100800),
      (13,186805,63844),
      (13,678856,171515),
      (13,561142,134641),
      (13,561142,122251),
      (13,561142,113595),
      (13,325791,134294),
      (13,216151,51022),
      (13,391549,112758),
      (13,391549,112749),
      (16,267252,164600))
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
