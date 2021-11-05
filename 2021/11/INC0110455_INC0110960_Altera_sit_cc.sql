DECLARE
  vr_dttransa            cecred.craplgm.dttransa%type;
  vr_hrtransa            cecred.craplgm.hrtransa%type;
  vr_nrsequen            cecred.craplgm.nrsequen%type;
  vr_nrseqcmp            cecred.craplgi.nrseqcmp%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vr_cdcooper            cecred.crapcop.cdcooper%type;
  vr_nrdrowid            rowid;
  
BEGIN
  -- Inicialização de variáveis globais utilizadas no script
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  
  -- #########################################################
  -- Início Chamado INC0110455 - Conta 167010 - Unilos
  vr_cdcooper := 6;
  vr_nrdconta := 167010;
  vr_nrsequen := 1; -- Para a Cooperativa,conta,data e horario da transacao incluimos apenas um registro - Assumir 1
  vr_nrseqcmp := 1; -- Vide acima, o sequencial do campo do detalhamento do log da transacao é incluído apenas uma vez - Assume 1
  
  UPDATE crapass a
     SET a.cdsitdct = 8
   WHERE a.cdcooper = vr_cdcooper
     AND a.nrdconta = vr_nrdconta;

  -- Limpo o rowid
  vr_nrdrowid := null;
  
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                              pr_cdoperad => NULL,
                              pr_dscritic => NULL,
                              pr_dsorigem => 'AIMARO',
                              pr_dstransa => 'Alteracao da situacao de conta por script - INC0110455',
                              pr_dttransa => vr_dttransa,
                              pr_flgtrans => 1,
                              pr_hrtransa => vr_hrtransa,
                              pr_idseqttl => 0,
                              pr_nmdatela => NULL,
                              pr_nrdconta => vr_nrdconta,
                              pr_nrdrowid => vr_nrdrowid);
  
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                   pr_nmdcampo => 'cdsitdct',
                                   pr_dsdadant => '2',
                                   pr_dsdadatu => '8');

  -- Fim Chamado INC0110455 - Conta 167010 - Unilos
  -- #########################################################

  -- #########################################################
     -- Início Chamado INC0110960 - Conta 312410 - Credcrea 
  vr_cdcooper := 7;
  vr_nrdconta := 312410;
  vr_nrsequen := 1; -- Para a Cooperativa,conta,data e horario da transacao incluimos apenas um registro - Assumir 1
  vr_nrseqcmp := 1; -- Vide acima, o sequencial do campo do detalhamento do log da transacao é incluído apenas uma vez - Assume 1
  
  UPDATE crapass a
     SET a.cdsitdct = 8
   WHERE a.cdcooper = vr_cdcooper
     AND a.nrdconta = vr_nrdconta;
  
  -- Limpo o rowid
  vr_nrdrowid := null;
  
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                              pr_cdoperad => NULL,
                              pr_dscritic => NULL,
                              pr_dsorigem => 'AIMARO',
                              pr_dstransa => 'Alteracao da situacao de conta por script - INC0110960',
                              pr_dttransa => vr_dttransa,
                              pr_flgtrans => 1,
                              pr_hrtransa => vr_hrtransa,
                              pr_idseqttl => 0,
                              pr_nmdatela => NULL,
                              pr_nrdconta => vr_nrdconta,
                              pr_nrdrowid => vr_nrdrowid);
             
  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                   pr_nmdcampo => 'cdsitdct',
                                   pr_dsdadant => '2',
                                   pr_dsdadatu => '8');
  -- Fim Chamado INC0110960 - Conta 312410 - Credcrea           
  -- #########################################################

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao alterar situação cooperativa/conta (' || vr_cdcooper || '/' || vr_nrdconta || ') para 8 : ' || SQLERRM);
END;  
