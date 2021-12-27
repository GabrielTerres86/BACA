DECLARE
  vr_dttransa cecred.craplgm.dttransa%type;
  vr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_valor    NUMBER(15,2);
  vr_dtini    DATE;
  vr_dtfim    DATE;  
  vr_dstransa VARCHAR(1000);

  vr_nrdrowid ROWID;

  CURSOR cr_crapsld(pr_cdcooper cecred.crapcop.cdcooper%type,
                    pr_nrdconta cecred.crapass.nrdconta%type) is
    SELECT a.*
      from CECRED.crapsld a
     WHERE a.nrdconta = pr_nrdconta
       AND a.cdcooper = pr_cdcooper;

  rg_crapsld crapsld%rowtype;

  CURSOR cr_crapsda(pr_cdcooper cecred.crapcop.cdcooper%type,
                    pr_nrdconta cecred.crapass.nrdconta%type,
                    pr_dtini    date,
                    pr_dtfim    date) is
    SELECT a.*
      from CECRED.crapsda a
     WHERE a.nrdconta = pr_nrdconta
       AND a.cdcooper = pr_cdcooper
       AND a.dtmvtolt BETWEEN pr_dtini AND pr_dtfim;

BEGIN
  --Inicializa Variáveis utilizadas no Script
  -- Setar aqui as variáveis conforme a necessidade do incidente atendido
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  vr_cdcooper := 11;
  vr_nrdconta := 422541;
  vr_dtini    := to_date('01/12/2021', 'dd/mm/yyyy');
  vr_dtfim    := trunc(sysdate);
  vr_valor    := 73.24;
  vr_dstransa := 'Alteracao da situacao de conta por script - INC0119220';

  open cr_crapsld(vr_cdcooper, vr_nrdconta);
  fetch cr_crapsld
    into rg_crapsld;
  close cr_crapsld;
  
  GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => vr_dstransa,
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 1,
                       pr_nmdatela => 'Atenda',
                       pr_nrdconta => vr_nrdconta,
                       pr_nrdrowid => vr_nrdrowid);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'crapsld.VLSDDISP',
                            pr_dsdadant => rg_crapsld.vlsddisp,
                            pr_dsdadatu => rg_crapsld.vlsddisp + vr_valor);
  UPDATE crapsld a
     SET a.VLSDDISP = a.vlsddisp + vr_valor
   WHERE a.nrdconta = vr_nrdconta
       AND a.cdcooper = vr_cdcooper;

  FOR rg_crapsda IN cr_crapsda(vr_cdcooper, vr_nrdconta, vr_dtini, vr_dtfim) LOOP
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapsda.VLSDDISP',
                              pr_dsdadant => rg_crapsda.vlsddisp,
                              pr_dsdadatu => rg_crapsda.vlsddisp + vr_valor);

    UPDATE crapsda a
       SET a.VLSDDISP = (a.vlsddisp + vr_valor)
     WHERE a.nrdconta = vr_nrdconta
       AND a.cdcooper = vr_cdcooper
       AND a.dtmvtolt  = rg_crapsda.dtmvtolt;

  END LOOP;
   
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;

