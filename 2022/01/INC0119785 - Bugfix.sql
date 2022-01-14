DECLARE
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_nrdconta    cecred.crapass.nrdconta%type;
  vr_cdcooper    cecred.crapcop.cdcooper%type;
  vr_cdoperad    cecred.craplgm.cdoperad%TYPE;
  vr_dscritic    cecred.craplgm.dscritic%TYPE;
  vr_cdcooperold cecred.crapcop.cdcooper%type;
  vr_nrdrowid    ROWID;

  vr_tbcotas_dev_cdcooper         NUMBER(5);
  vr_tbcotas_dev_nrdconta         NUMBER(10);
  vr_tbcotas_dev_tpdevolucao      NUMBER(1);
  vr_tbcotas_dev_vlcapital        NUMBER(15, 2);
  vr_tbcotas_dev_qtparcelas       NUMBER(2);
  vr_tbcotas_dev_dtinicio_credito DATE;
  vr_tbcotas_dev_vlpago           NUMBER(15, 2);
  vr_log_script                   VARCHAR2(8000);
  vr_dtmvtolt                     DATE;
  vr_nrdocmto                     INTEGER;
  vr_nrseqdig                     INTEGER;
  vr_vldcotas                     NUMBER;
  vr_vldcotas_crapcot             NUMBER;
  vr_exception exception;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_cdcritic    PLS_INTEGER;
  vr_exc_lanc_conta EXCEPTION;

  CURSOR cr_crapass is
    SELECT t.cdsitdct,
           t.cdcooper,
           t.nrdconta,
           t.dtdemiss,
           t.dtelimin,
           t.cdmotdem,
           t.cdagenci
      FROM CRAPASS t
     WHERE (t.nrdconta = 3904997 and t.cdcooper = 1)
        or (t.nrdconta = 118079 and t.cdcooper = 9);

  rg_crapass cr_crapass%rowtype;

BEGIN
  vr_cdcooperold := null;
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;

  FOR rg_crapass IN cr_crapass LOOP
  
    if vr_cdcooperold is null then
      vr_cdcooperold := rg_crapass.cdcooper;
    end if;
  
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;
  
    if vr_cdcooperold != vr_cdcooper then
      commit;
    end if;
  
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteracao da situacao de conta por script - INC0119785 - Bugfix',
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => vr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.cdsitdct',
                              pr_dsdadant => rg_crapass.cdsitdct,
                              pr_dsdadatu => 8);
  
    
    BEGIN
      SELECT dtmvtolt
        INTO vr_dtmvtolt
        FROM CECRED.crapdat
       WHERE cdcooper = rg_crapass.cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        dbms_output.put_line(chr(10) ||
                             'Não encontrado crapdat para cooperativa ' ||
                             rg_crapass.cdcooper);
    END;
  
    BEGIN
      SELECT vldcotas
        INTO vr_vldcotas_crapcot
        FROM CECRED.crapcot
       WHERE nrdconta = rg_crapass.nrdconta
         AND cdcooper = rg_crapass.cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        dbms_output.put_line(chr(10) ||
                             'Não encontrado registro em crapcot para conta ' ||
                             rg_crapass.nrdconta);
      
    END;
  
    vr_nrdocmto := fn_sequence('CRAPLCT',
                               'NRDOCMTO',
                               vr_cdcooper || ';' ||
                               TRIM(to_char(vr_dtmvtolt, 'DD/MM/YYYY')) || ';' || 2079);
    vr_nrseqdig := fn_sequence('CRAPLCT',
                               'NRSEQDIG',
                               vr_cdcooper || ';' ||
                               TRIM(to_char(vr_dtmvtolt, 'DD/MM/YYYY')) || ';' || 2079);
  
    INSERT INTO CECRED.craplct
      (cdcooper,
       cdagenci,
       cdbccxlt,
       nrdolote,
       dtmvtolt,
       cdhistor,
       nrctrpla,
       nrdconta,
       nrdocmto,
       nrseqdig,
       vllanmto,
       CDOPEORI,
       DTINSORI)
    VALUES
      (vr_cdcooper,
       rg_crapass.cdagenci,
       100,
       10102,
       vr_dtmvtolt,
       2079,
       0,
       vr_nrdconta,
       vr_nrdocmto,
       vr_nrseqdig,
       vr_vldcotas_crapcot,
       1,
       sysdate);
  
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteração de Cotas e devolução - INC0119785 - Bugfix',
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => vr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'craplct.dtmvtolt',
                              pr_dsdadant => null,
                              pr_dsdadatu => vr_dtmvtolt);
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'craplct.vllanmto',
                              pr_dsdadant => null,
                              pr_dsdadatu => vr_vldcotas_crapcot);
  
    UPDATE CECRED.crapcot
       SET vldcotas = 0
     WHERE cdcooper = rg_crapass.cdcooper
       AND nrdconta = rg_crapass.nrdconta;
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapcot.vldcotas',
                              pr_dsdadant => vr_vldcotas_crapcot,
                              pr_dsdadatu => 0);
  
    UPDATE CECRED.TBCOTAS_DEVOLUCAO a
       SET a.vlcapital =
           (a.vlcapital + vr_vldcotas_crapcot)
     WHERE CDCOOPER = rg_crapass.cdcooper
       AND NRDCONTA = rg_crapass.nrdconta
       AND TPDEVOLUCAO in (1, 3);
  
  end loop;

  --commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situação cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
