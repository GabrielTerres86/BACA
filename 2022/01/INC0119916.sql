declare
  vr_nrsequenlgi INTEGER;
  vr_nrsequenlgm INTEGER;
  vr_nrdrowid    ROWID;
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_dscritic cecred.craplgm.dscritic%TYPE;

  CURSOR cr_tbrecarga_operacao is
    SELECT a.*
      from CECRED.tbrecarga_operacao a
     WHERE a.cdcooper = 1
       AND a.idoperacao = 1326682
       AND a.nrdconta = 8454396;

  rg_tbrecarga_operacao cr_tbrecarga_operacao%rowtype;

begin
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;
  vr_nrsequenlgi := 1;
  vr_nrsequenlgm := 1;

  open cr_tbrecarga_operacao;
  fetch cr_tbrecarga_operacao
    into rg_tbrecarga_operacao;

  UPDATE CECRED.tbrecarga_operacao
     SET insit_operacao = 5
   WHERE cdcooper = rg_tbrecarga_operacao.cdcooper
     AND idoperacao = rg_tbrecarga_operacao.idoperacao
     AND nrdconta = rg_tbrecarga_operacao.nrdconta;

  GENE0001.pc_gera_log(pr_cdcooper => rg_tbrecarga_operacao.cdcooper,
                       pr_cdoperad => Null,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'INC0119916 - Lançamento futuro de recarga da TIM não está sendo possível a exclusão.',
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 0,
                       pr_nmdatela => NULL,
                       pr_nrdconta => rg_tbrecarga_operacao.nrdconta,
                       pr_nrdrowid => vr_nrdrowid);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'tbrecarga_operacao.insit_operacao',
                            pr_dsdadant => rg_tbrecarga_operacao.insit_operacao,
                            pr_dsdadatu => 5);

  close cr_tbrecarga_operacao;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;
