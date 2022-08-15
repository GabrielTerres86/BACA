DECLARE                                 
  CURSOR c_port_recebe IS
  SELECT t.nrnu_portabilidade,
         t.cdcooper,
         t.nrdconta,
         t.idsituacao,
         t.dtretorno,
         t.dsdominio_motivo,
         t.cdmotivo,
         t.nmarquivo_solicitacao
    FROM CECRED.TBCC_PORTABILIDADE_RECEBE T
   WHERE 1=1
     AND T.NRNU_PORTABILIDADE = '201907190000103699398';                                 

  vc_idSituacaoRecebe            CONSTANT NUMBER(1)    := 5;
  vc_dsmotivocancel              CONSTANT VARCHAR2(30) := 'MOTVCANCELTPORTDDCTSALR';
  vc_cdmotivo                    CONSTANT VARCHAR(10)  := '1';
  vc_dtcancel                    CONSTANT DATE         := to_date('19/07/2019','dd/mm/yyyy');
  vc_nmarquiv                    CONSTANT VARCHAR2(60) := 'ARQUIVO NAO IDENTIFICADO';
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

  vr_tabela := 'TBCC_PORTABILIDADE_RECEBE';
  vr_dstransa := 'Alteracao da situacao portabilidade - INC0201096 - ' || vr_tabela;

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
                              pr_dsdadatu => vc_idSituacaoRecebe);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.dsdominio_motivo',
                              pr_dsdadant => r_port_recebe.dsdominio_motivo,
                              pr_dsdadatu => vc_dsmotivocancel);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.cdmotivo',
                              pr_dsdadant => r_port_recebe.cdmotivo,
                              pr_dsdadatu => vc_cdmotivo);

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.dtretorno',
                              pr_dsdadant => to_char(r_port_recebe.dtretorno,'dd/mm/yyyy HH24:MI:SS'),
                              pr_dsdadatu => to_char(vc_dtcancel,'dd/mm/yyyy HH24:MI:SS'));

    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcc_portabilidade_recebe.nmarquivo_solicitacao',
                              pr_dsdadant => r_port_recebe.nmarquivo_solicitacao,
                              pr_dsdadatu => vc_nmarquiv);   
                               
    UPDATE CECRED.tbcc_portabilidade_recebe t
       SET t.idsituacao            = vc_idSituacaoRecebe
         , t.dsdominio_motivo      = vc_dsmotivocancel
         , t.cdmotivo              = vc_cdmotivo
         , t.dtretorno             = vc_dtcancel
         , t.nmarquivo_solicitacao = vc_nmarquiv
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
