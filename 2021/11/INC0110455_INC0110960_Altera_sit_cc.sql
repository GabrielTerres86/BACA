DECLARE
  vr_dttransa            cecred.craplgm.dttransa%type;
  vr_hrtransa            cecred.craplgm.hrtransa%type;
  vr_nrsequen            cecred.craplgm.nrsequen%type;
  vr_nrseqcmp            cecred.craplgi.nrseqcmp%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vr_cdcooper            cecred.crapcop.cdcooper%type;
  
  procedure insere_lgm(pr_cdcooper   in cecred.crapcop.cdcooper%type,
                       pr_nrdconta   in cecred.crapass.nrdconta%type,
                       pr_nrsequen   in cecred.craplgm.nrsequen%type,
                       pr_dttransa   in cecred.craplgm.dttransa%type,
                       pr_hrtransa   in cecred.craplgm.hrtransa%type,
                       pr_dstransa   in cecred.craplgm.dstransa%type,
                       pr_dsorigem   in cecred.craplgm.dsorigem%type) IS
    
  begin
    INSERT INTO CECRED.CRAPLGM 
      (CDCOOPER,
       NRDCONTA,
       NRSEQUEN,
       DTTRANSA,
       HRTRANSA,
       DSTRANSA,
       DSORIGEM)
    VALUES
      (pr_cdcooper,
       pr_nrdconta,
       pr_nrsequen,
       pr_dttransa,
       pr_hrtransa,
       pr_dstransa,
       pr_dsorigem);
  end;
  
  procedure insere_lgi(pr_cdcooper   in cecred.craplgi.cdcooper%type,
                       pr_nrdconta   in cecred.craplgi.nrdconta%type,
                       pr_nrsequen   in cecred.craplgi.nrsequen%type,
                       pr_dttransa   in cecred.craplgi.dttransa%type,
                       pr_hrtransa   in cecred.craplgi.hrtransa%type,
                       pr_nrseqcmp   in cecred.craplgi.nrseqcmp%type,
                       pr_nmdcampo   in cecred.craplgi.nmdcampo%type,
                       pr_dsdadant   in cecred.craplgi.dsdadant%type,
                       pr_dsdadatu   in cecred.craplgi.dsdadatu%type) IS
  begin
    INSERT INTO CECRED.CRAPLGI
     (CDCOOPER,
      NRDCONTA,
      NRSEQUEN,
      DTTRANSA,
      HRTRANSA,
      NRSEQCMP,
      NMDCAMPO,
      DSDADANT,
      DSDADATU)
    VALUES
     (pr_cdcooper,
      pr_nrdconta,
      pr_nrsequen,
      pr_dttransa,
      pr_hrtransa,
      pr_nrseqcmp,
      pr_nmdcampo,
      pr_dsdadant,
      pr_dsdadatu);
  end;
  
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
  
  insere_lgm(vr_cdcooper,
             vr_nrdconta,
             vr_nrsequen,
             vr_dttransa,
             vr_hrtransa,
             'Alteracao da situacao de conta por script - INC0110455',
             'AIMARO');
               
  insere_lgi(vr_cdcooper,
             vr_nrdconta,
             vr_nrsequen,
             vr_dttransa,
             vr_hrtransa,
             vr_nrseqcmp,
             'cdsitdct',
             '2',
             '8');
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

  insere_lgm(vr_cdcooper,
             vr_nrdconta,
             vr_nrsequen,
             vr_dttransa,
             vr_hrtransa,
             'Alteracao da situacao de conta por script - INC0110960',
             'AIMARO');
             
  insere_lgi(vr_cdcooper,
             vr_nrdconta,
             vr_nrsequen,
             vr_dttransa,
             vr_hrtransa,
             vr_nrseqcmp,
             'cdsitdct',
             '2',
             '8');             
  -- Fim Chamado INC0110960 - Conta 312410 - Credcrea           
  -- #########################################################

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao alterar situação cooperativa/conta (' || vr_cdcooper || '/' || vr_nrdconta || ') para 8 : ' || SQLERRM);
END;  
