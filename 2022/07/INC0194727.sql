declare
      
 vr_cdcooper          cecred.crapcop.cdcooper%type;
 vr_nrdconta          cecred.crapass.nrdconta%type;
 rw_crapdat           cecred.BTCH0001.cr_crapdat%ROWTYPE;
 
 vr_cdcritic          cecred.crapcri.cdcritic%type;
 vr_dscritic          cecred.crapcri.dscritic%type;
 vr_nrdrowid          ROWID;
 vr_cdoperad          cecred.craplgm.cdoperad%TYPE;
 vr_dttransa          cecred.craplgm.dttransa%type;
 vr_hrtransa          cecred.craplgm.hrtransa%type;
 
 vc_dstransaStone       CONSTANT VARCHAR2(4000) := 'Baixa do Credito de Venda com Cartao STONE - INC0194727';
 vc_dstransaRecarga     CONSTANT VARCHAR2(4000) := 'Baixa da Recarga de Celular pendente a lancar em Conta encerrada - INC0194727';
 vc_insitlau            CONSTANT cecred.craplau.insitlau%TYPE := 3;
 vc_insit_ope_cancelado CONSTANT cecred.tbrecarga_operacao.insit_operacao%TYPE := 4;
 
 CURSOR cr_stone(pr_cdcooper in cecred.crapcop.cdcooper%type,
                 pr_nrdconta in cecred.crapass.nrdconta%type) IS
 select l.dtmvtolt,
        l.nrdconta,
        l.insitlau,
        l.dtdebito,
        l.cdcooper,
        l.idlancto
   from craplau l
  where 1=1
    and l.nrdconta = pr_nrdconta
    and cdcooper = pr_cdcooper
    AND l.dtdebito IS NULL
    and l.vllanaut > 0;    
      
 CURSOR cr_recarga_fut(pr_cdcooper in cecred.crapcop.cdcooper%type,
                       pr_nrdconta in cecred.crapass.nrdconta%type) IS
   SELECT topr.idoperacao
         ,topr.insit_operacao
     FROM tbrecarga_operacao topr
    WHERE topr.cdcooper = pr_cdcooper
      AND topr.nrdconta = pr_nrdconta
      AND topr.insit_operacao = 1;
      
Begin
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
  vr_cdcooper    := 5;
  vr_nrdconta    := 134732;
  OPEN CECRED.BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH CECRED.BTCH0001.cr_crapdat INTO rw_crapdat;
  IF CECRED.BTCH0001.cr_crapdat%NOTFOUND THEN
     CLOSE CECRED.BTCH0001.cr_crapdat;
     RAISE_APPLICATION_ERROR(-20001,'Erro abrir data para cooperativa:' || vr_cdcooper || ' - ' || sqlerrm);
  ELSE
     CLOSE CECRED.BTCH0001.cr_crapdat;
  END IF;
  
  FOR rw_stone in cr_stone(vr_cdcooper, vr_nrdconta) LOOP
   
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => vr_dscritic,
                           pr_dsorigem => 'AIMARO',
                           pr_dstransa => vc_dstransaStone,
                           pr_dttransa => vr_dttransa,
                           pr_flgtrans => 1,
                           pr_hrtransa => vr_hrtransa,
                           pr_idseqttl => 0,
                           pr_nmdatela => NULL,
                           pr_nrdconta => vr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
                           
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'CRAPLAU.CDCOOPER',
                                     pr_dsdadant => vr_cdcooper,
                                     pr_dsdadatu => vr_cdcooper);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'CRAPLAU.NRDCONTA',
                                     pr_dsdadant => vr_nrdconta,
                                     pr_dsdadatu => vr_nrdconta);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'CRAPLAU.IDLANCTO',
                                     pr_dsdadant => rw_stone.idlancto,
                                     pr_dsdadatu => rw_stone.idlancto);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'CRAPLAU.INSITLAU',
                                     pr_dsdadant => rw_stone.insitlau,
                                     pr_dsdadatu => vc_insitlau);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'CRAPLAU.DTDEBITO',
                                     pr_dsdadant => rw_stone.dtdebito,
                                     pr_dsdadatu => rw_stone.dtmvtolt);
    UPDATE CECRED.CRAPLAU t
       SET t.insitlau = vc_insitlau
         , t.dtdebito = t.dtmvtolt
     WHERE cdcooper = rw_stone.cdcooper
       AND nrdconta = rw_stone.nrdconta
       and idlancto = rw_stone.idlancto;
   
  END LOOP;      
  
  vr_cdcooper    := 1;
  vr_nrdconta    := 2204029;
  FOR rw_recarga_fut in cr_recarga_fut(vr_cdcooper, vr_nrdconta) LOOP
   
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => vr_dscritic,
                           pr_dsorigem => 'AIMARO',
                           pr_dstransa => vc_dstransaRecarga,
                           pr_dttransa => vr_dttransa,
                           pr_flgtrans => 1,
                           pr_hrtransa => vr_hrtransa,
                           pr_idseqttl => 0,
                           pr_nmdatela => NULL,
                           pr_nrdconta => vr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
                           
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'tbrecarga_operacao.IDOPERACAO',
                                     pr_dsdadant => rw_recarga_fut.idoperacao,
                                     pr_dsdadatu => rw_recarga_fut.idoperacao);
                                     
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'tbrecarga_operacao.INSIT_OPERACAO',
                                     pr_dsdadant => rw_recarga_fut.insit_operacao,
                                     pr_dsdadatu => vc_insit_ope_cancelado);
                                     
    UPDATE cecred.tbrecarga_operacao
       SET insit_operacao = vc_insit_ope_cancelado
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta
       AND idoperacao = rw_recarga_fut.idoperacao;
   
  END LOOP;   
  
  COMMIT;
  
Exception
  when others then
    RAISE_APPLICATION_ERROR(-20000,'Erro baixar lancamento futuro da Cooperativa/Conta: ' || vr_cdcooper || '/' || vr_nrdconta || ' - ' || sqlerrm);
end; 
