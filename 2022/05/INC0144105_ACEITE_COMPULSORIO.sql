DECLARE
  CURSOR c_port_envia IS
  SELECT t.cdcooper,
         t.nrdconta,
         t.nrsolicitacao,
         t.dtsolicitacao,
         t.nrcpfcgc,
         t.nmprimtl,
         t.nrddd_telefone,
         t.nrtelefone,
         t.dsdemail,
         t.cdbanco_folha,
         t.cdagencia_folha,
         t.nrispb_banco_folha,
         t.nrcnpj_banco_folha,
         t.nrcnpj_empregador,
         t.dsnome_empregador,
         t.nrispb_destinataria,
         t.nrcnpj_destinataria,
         t.cdtipo_conta,
         t.cdagencia,
         t.idsituacao,
         t.nrnu_portabilidade,
         t.dtretorno,
         t.dsdominio_motivo,
         t.cdmotivo,
         t.cdoperador,
         t.nmarquivo_envia,
         t.nmarquivo_retorno,
         t.dtassina_eletronica,
         t.idseqttl,
         t.tppessoa_empregador
    FROM CECRED.TBCC_PORTABILIDADE_ENVIA T
   WHERE 1=1
     AND T.NRNU_PORTABILIDADE IN (202205050000229464642,
                                  202205050000229465378,
                                  202205050000229466037,
                                  202205050000229469411,
                                  202205050000229471090,
                                  202205050000229471251,
                                  202205050000229486044,
                                  202205050000229486835,
                                  202205050000229486836,
                                  202205050000229486839,
                                  202205050000229488501,
                                  202205050000229490815,
                                  202205050000229490821,
                                  202205050000229490823,
                                  202205050000229490827,
                                  202205050000229490830,
                                  202205050000229495777,
                                  202205050000229495780,
                                  202205050000229495781,
                                  202205050000229495789,
                                  202205050000229495791,
                                  202205050000229495792,
                                  202205050000229495797,
                                  202205050000229502590,
                                  202205050000229502592,
                                  202205050000229502593,
                                  202205050000229502595,
                                  202205050000229502596,
                                  202205050000229502602,
                                  202205050000229502603,
                                  202205050000229502610,
                                  202205050000229502611,
                                  202205050000229506227,
                                  202205050000229506228,
                                  202205050000229506229,
                                  202205050000229506230,
                                  202205050000229506234,
                                  202205050000229506243,
                                  202205050000229518746,
                                  202205050000229518755,
                                  202205050000229522916,
                                  202205050000229522920,
                                  202205050000229522923,
                                  202205050000229522924,
                                  202205050000229522926,
                                  202205050000229522931,
                                  202205050000229522934,
                                  202205050000229522935,
                                  202205050000229522936,
                                  202205050000229522937,
                                  202205050000229532841,
                                  202205050000229538187);
                                 
  CURSOR c_port_recebe IS
  SELECT t.nrnu_portabilidade,
         t.cdcooper,
         t.nrdconta,
         t.nrcpfcgc,
         t.nmprimtl,
         t.dstelefone,
         t.dsdemail,
         t.nrispb_banco_folha,
         t.nrcnpj_banco_folha,
         t.nrcnpj_empregador,
         t.dsnome_empregador,
         t.nrispb_destinataria,
         t.nrcnpj_destinataria,
         t.cdtipo_cta_destinataria,
         t.cdagencia_destinataria,
         t.nrdconta_destinataria,
         t.dtsolicitacao,
         t.idsituacao,
         t.dtavaliacao,
         t.dtretorno,
         t.dsdominio_motivo,
         t.cdmotivo,
         t.cdoperador,
         t.nmarquivo_solicitacao,
         t.nmarquivo_resposta,
         t.tppessoa_empregador
    FROM CECRED.TBCC_PORTABILIDADE_RECEBE T
   WHERE 1=1
     AND T.NRNU_PORTABILIDADE IN (202205050000229464642,
                                  202205050000229465378,
                                  202205050000229466037,
                                  202205050000229469411,
                                  202205050000229471090,
                                  202205050000229471251,
                                  202205050000229486044,
                                  202205050000229486835,
                                  202205050000229486836,
                                  202205050000229486839,
                                  202205050000229488501,
                                  202205050000229490815,
                                  202205050000229490821,
                                  202205050000229490823,
                                  202205050000229490827,
                                  202205050000229490830,
                                  202205050000229495777,
                                  202205050000229495780,
                                  202205050000229495781,
                                  202205050000229495789,
                                  202205050000229495791,
                                  202205050000229495792,
                                  202205050000229495797,
                                  202205050000229502590,
                                  202205050000229502592,
                                  202205050000229502593,
                                  202205050000229502595,
                                  202205050000229502596,
                                  202205050000229502602,
                                  202205050000229502603,
                                  202205050000229502610,
                                  202205050000229502611,
                                  202205050000229506227,
                                  202205050000229506228,
                                  202205050000229506229,
                                  202205050000229506230,
                                  202205050000229506234,
                                  202205050000229506243,
                                  202205050000229518746,
                                  202205050000229518755,
                                  202205050000229522916,
                                  202205050000229522920,
                                  202205050000229522923,
                                  202205050000229522924,
                                  202205050000229522926,
                                  202205050000229522931,
                                  202205050000229522934,
                                  202205050000229522935,
                                  202205050000229522936,
                                  202205050000229522937,
                                  202205050000229532841,
                                  202205050000229538187);                                 

  vc_idSituacaoEnvia             CONSTANT NUMBER(1)    := 3;
  vc_idSituacaoRecebe            CONSTANT NUMBER(1)    := 2;
  vc_dsmotivoaceite              CONSTANT VARCHAR2(30) := 'MOTVACTECOMPRIOPORTDDCTSALR';
  vc_cdmotivo                    CONSTANT VARCHAR(10)  := '1';
  vc_dtaceite                    CONSTANT DATE         := to_date('18/05/2022','dd/mm/yyyy');
  vc_dtarquiv                    CONSTANT DATE         := to_date('18/05/2022 21:07:54','dd/mm/yyyy HH24:MI:SS');
  vc_nmarquiv                    CONSTANT VARCHAR2(60) := 'APCS108_05463212_20220518_00075';
  vc_dttransa                    CONSTANT DATE         := trunc(sysdate);
  vc_hrtransa                    CONSTANT NUMBER(5)    := GENE0002.fn_busca_time;
  
  vr_nrnu_portabilidade          cecred.tbcc_portabilidade_recebe.nrnu_portabilidade%type;
  vr_cdoperad                    cecred.craplgm.cdoperad%TYPE;
  vr_dstransa                    VARCHAR2(4000);
  vr_nrdrowid                    ROWID;
  vr_cdcritic                     cecred.crapcri.cdcritic%type;
  vr_dscritic                     cecred.crapcri.dscritic%TYPE;
  vr_tabela                       VARCHAR2(4000);
  
  v_code NUMBER;
  v_errm VARCHAR2(64);
  
BEGIN
  
  vr_tabela := 'TBCC_PORTABILIDADE_ENVIA';
  vr_dstransa := 'Alteracao da situacao portabilidade - INC0144105 - ' || vr_tabela;
  
  FOR r_port_envia in c_port_envia LOOP
    
    vr_nrdrowid := null;
    vr_nrnu_portabilidade := r_port_envia.nrnu_portabilidade;
  
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => r_port_envia.cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => vc_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vc_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => r_port_envia.nrdconta,
                         pr_nrdrowid => vr_nrdrowid);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_envia.nrnu_portabilidade',
                              pr_dsdadant => r_port_envia.nrnu_portabilidade,
                              pr_dsdadatu => r_port_envia.nrnu_portabilidade);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_envia.idsituacao',
                              pr_dsdadant => r_port_envia.idsituacao,
                              pr_dsdadatu => vc_idSituacaoEnvia);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_envia.dsdominio_motivo',
                              pr_dsdadant => r_port_envia.dsdominio_motivo,
                              pr_dsdadatu => vc_dsmotivoaceite);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_envia.cdmotivo',
                              pr_dsdadant => r_port_envia.cdmotivo,
                              pr_dsdadatu => vc_cdmotivo);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_envia.dtretorno',
                              pr_dsdadant => r_port_envia.dtretorno,
                              pr_dsdadatu => to_char(vc_dtarquiv,'dd/mm/yyyy HH24:MI:SS'));

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_envia.nmarquivo_retorno',
                              pr_dsdadant => r_port_envia.nmarquivo_retorno,
                              pr_dsdadatu => vc_nmarquiv);
    
    UPDATE cecred.tbcc_portabilidade_envia t
       SET t.idsituacao        = vc_idSituacaoEnvia
         , t.dsdominio_motivo  = vc_dsmotivoaceite
         , t.cdmotivo          = vc_cdmotivo
         , t.dtretorno         = vc_dtarquiv
         , t.nmarquivo_retorno = vc_nmarquiv
     WHERE nrnu_portabilidade = r_port_envia.nrnu_portabilidade;
     
    COMMIT;
    
  END LOOP;

  vr_tabela := 'TBCC_PORTABILIDADE_RECEBE';
  vr_dstransa := 'Alteracao da situacao portabilidade - INC0144105 - ' || vr_tabela;

  FOR r_port_recebe in c_port_recebe LOOP
    
    vr_nrdrowid := null;
    vr_nrnu_portabilidade := r_port_recebe.nrnu_portabilidade;
  
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => r_port_recebe.cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => vc_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vc_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => r_port_recebe.nrdconta,
                         pr_nrdrowid => vr_nrdrowid);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.nrnu_portabilidade',
                              pr_dsdadant => r_port_recebe.nrnu_portabilidade,
                              pr_dsdadatu => r_port_recebe.nrnu_portabilidade);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.idsituacao',
                              pr_dsdadant => r_port_recebe.idsituacao,
                              pr_dsdadatu => vc_idSituacaoEnvia);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.dsdominio_motivo',
                              pr_dsdadant => r_port_recebe.dsdominio_motivo,
                              pr_dsdadatu => vc_dsmotivoaceite);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.cdmotivo',
                              pr_dsdadant => r_port_recebe.cdmotivo,
                              pr_dsdadatu => vc_cdmotivo);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.dtavaliacao',
                              pr_dsdadant => r_port_recebe.dtavaliacao,
                              pr_dsdadatu => vc_dtaceite);


    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.dtretorno',
                              pr_dsdadant => r_port_recebe.dtretorno,
                              pr_dsdadatu => to_char(vc_dtarquiv,'dd/mm/yyyy HH24:MI:SS'));

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.nmarquivo_resposta',
                              pr_dsdadant => r_port_recebe.nmarquivo_resposta,
                              pr_dsdadatu => vc_nmarquiv);   
                               
    UPDATE cecred.tbcc_portabilidade_recebe t
       SET t.idsituacao         = vc_idSituacaoRecebe
         , t.dsdominio_motivo   = vc_dsmotivoaceite
         , t.cdmotivo           = vc_cdmotivo
         , t.dtavaliacao        = vc_dtaceite
         , t.dtretorno          = vc_dtarquiv
         , t.nmarquivo_resposta = vc_nmarquiv
     WHERE NRNU_PORTABILIDADE = r_port_recebe.nrnu_portabilidade;
     
    COMMIT;
    
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao executar update em ' || vr_tabela || ' e nrnu_portabilidade: ' || vr_nrnu_portabilidade||  ' - ' || v_code || ' - ' || v_errm);
END;  
