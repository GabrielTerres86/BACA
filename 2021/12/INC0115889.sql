DECLARE
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_nrdconta    cecred.crapass.nrdconta%type := 126470;
  vr_cdcooper    cecred.crapcop.cdcooper%type := 12;
  vr_nrdocmto    cecred.craplau.nrdocmto%type := '10000037';
  vr_cdhistor    cecred.craplau.cdhistor%type := 508;
  vr_cdoperad    cecred.craplgm.cdoperad%TYPE;
  vr_dscritic    cecred.craplgm.dscritic%TYPE;
  vr_idlancto    cecred.craplau.idlancto%type;
  vr_insitlau    cecred.craplau.insitlau%type;
  vr_dtdebito    cecred.craplau.dtdebito%type;
  vr_dtmvtolt    cecred.craplau.dtmvtolt%type;
  vr_nrdrowid    ROWID;
  
  vr_erro_geralog exception;


BEGIN

  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;  
  
  --Busca a PK da tabela
  SELECT l.idlancto, l.insitlau, l.dtdebito, l.dtmvtolt
    INTO vr_idlancto, vr_insitlau, vr_dtdebito, vr_dtmvtolt
    FROM cecred.craplau l
   WHERE 1=1
     AND l.cdcooper = vr_cdcooper
     AND l.nrdconta = vr_nrdconta
     AND l.nrdocmto = vr_nrdocmto
     and l.cdhistor = vr_cdhistor
     and l.dtmvtolt = to_date('24/09/2020','dd/mm/yyyy') 
     and l.dtmvtopg = to_date('25/09/2020','dd/mm/yyyy') 
     AND l.dtdebito is null;
     

  GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'Remo��o lan�amento futuro por script - INC0115889',
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 0,
                       pr_nmdatela => NULL,
                       pr_nrdconta => vr_nrdconta,
                       pr_nrdrowid => vr_nrdrowid);
                       
  IF vr_dscritic IS NULL THEN
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'craplau.insitlau',
                              pr_dsdadant => vr_insitlau,
                              pr_dsdadatu => 3);
                              
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'craplau.dtdebito',
                              pr_dsdadant => null,
                              pr_dsdadatu => vr_dtmvtolt);                              
    
    UPDATE CECRED.CRAPLAU t
       SET t.insitlau = 3
         , t.dtdebito = vr_dtmvtolt
     WHERE t.idlancto = vr_idlancto;

    COMMIT;
    
  ELSE
    RAISE vr_erro_geralog;
  END IF;
  
  
EXCEPTION
  WHEN vr_erro_geralog THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20001, 'Erro chamada gene0001.pc_gera_log: ' || vr_dscritic);
    --    
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
