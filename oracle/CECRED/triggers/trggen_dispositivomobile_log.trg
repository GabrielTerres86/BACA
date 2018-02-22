CREATE OR REPLACE TRIGGER CECRED.TRGGEN_DISPOSITIVOMOBILE_LOG
  BEFORE UPDATE ON DispositivoMobile
  FOR EACH ROW
DECLARE
  vr_nrdrowid ROWID;
BEGIN

  IF (:OLD.TIPOAUTENTICACAO <> :NEW.TIPOAUTENTICACAO) THEN
    GENE0001.pc_gera_log(pr_cdcooper => :NEW.COOPERATIVAID,
                         pr_nrdconta => :NEW.NUMEROCONTA,
                         pr_idseqttl => :NEW.TITULARID,
                         pr_cdoperad => '996',
                         pr_dscritic => '',
                         pr_dsorigem => gene0001.vr_vet_des_origens(10),
                         pr_dstransa => CASE
                                          WHEN :NEW.TIPOAUTENTICACAO = 0 THEN
                                           'Desativação de biometria'
                                          ELSE
                                           'Cadastramentro de biometria'
                                        END,
                         pr_dttransa => TRUNC(SYSDATE),
                         pr_flgtrans => 0,
                         pr_hrtransa => gene0002.fn_busca_time,
                         pr_nmdatela => 'INTERNETBANK',
                         pr_nrdrowid => vr_nrdrowid);
  
  END IF;
END;
