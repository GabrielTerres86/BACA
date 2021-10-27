DECLARE
  CURSOR cr_crapass is
    SELECT a.nrdconta,
           a.cdcooper,
           a.cdsitdct,
           a.dtdemiss,
           a.cdmotdem,
           a.dtelimin,
           a.cdagenci
      FROM CECRED.CRAPASS a
     inner join CONTACORRENTE.Tbcc_Conta_Incorporacao t
        on (t.cdcooper = a.cdcooper and t.nrdconta = a.nrdconta)
     WHERE (a.cdcooper = 9 and a.nrdconta = 513130);

  rg_crapass cr_crapass%rowtype;

  vr_tbcotas_dev_cdcooper         NUMBER(5);
  vr_tbcotas_dev_nrdconta         NUMBER(10);
  vr_tbcotas_dev_tpdevolucao      NUMBER(1);
  vr_tbcotas_dev_vlcapital        NUMBER(15, 2);
  vr_tbcotas_dev_qtparcelas       NUMBER(2);
  vr_tbcotas_dev_dtinicio_credito DATE;
  vr_tbcotas_dev_vlpago           NUMBER(15, 2);
  vr_dttransa                     DATE;
  vr_hrtransa                     VARCHAR2(10);
  vr_log_script                   VARCHAR2(8000);
  vr_dstransa                     VARCHAR2(1000);
  vr_dtmvtolt                     DATE;
  vr_dtmvtolt_aplicada            DATE;
  vr_dtdemiss_ant                 DATE;
  vr_nrdocmto                     INTEGER;
  vr_nrseqdig                     INTEGER;
  vr_nrsequenlgi                  INTEGER;
  vr_nrsequenlgm                  INTEGER;
  vr_vldcotas                     NUMBER;
  vr_vldcotas_movtda              NUMBER;
  vr_vldcotas_crapcot             NUMBER;
  vr_exception exception;
  vr_qtde_tb_devolucao NUMBER;
  vr_tab_retorno       LANC0001.typ_reg_retorno;
  vr_incrineg          INTEGER;
  vr_cdcritic          PLS_INTEGER;
  vr_dscritic          varchar2(4000);
  vr_exc_lanc_conta EXCEPTION;

BEGIN

  vr_log_script  := ' ** Início script' || chr(10);
    FOR rg_crapass IN cr_crapass LOOP
    vr_log_script := vr_log_script || chr(10) || 'Atualização da conta: (' || '[ ' ||
                     LPAD(rg_crapass.cdcooper, 2, ' ') || ' ] ' ||
                     LPAD(rg_crapass.nrdconta, 9, ' ') || ') da situação (' ||
                     rg_crapass.cdsitdct || ') para (1)';
  
    vr_dstransa          := 'Alterada situacao de conta por script. INC0108069.';
    vr_vldcotas          := 0;
    vr_qtde_tb_devolucao := 0;
    vr_nrsequenlgi       := 1;
    vr_nrsequenlgm       := 1;
    vr_dttransa          := trunc(sysdate);
    vr_hrtransa          := GENE0002.fn_busca_time;
  
    UPDATE CECRED.CRAPASS
       SET cdsitdct = 1, dtdemiss = NULL, dtelimin = NULL, cdmotdem = 0
     WHERE nrdconta = rg_crapass.nrdconta
       AND cdcooper = rg_crapass.cdcooper;
  
    INSERT INTO cecred.craplgm
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       dstransa,
       dsorigem,
       nmdatela,
       flgtrans,
       dscritic,
       cdoperad,
       nmendter)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       1,
       vr_nrsequenlgm,
       vr_dttransa,
       vr_hrtransa,
       vr_dstransa,
       'AIMARO',
       '',
       1,
       ' ',
       1,
       ' ');
  
    vr_nrsequenlgm := vr_nrsequenlgm + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       1,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       1,
       'crapass.cdsitdct',
       rg_crapass.cdsitdct,
       '1');
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       1,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       2,
       'crapass.dtdemiss',
       rg_crapass.dtdemiss,
       null);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       1,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       2,
       'crapass.dtelimin',
       rg_crapass.dtelimin,
       null);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       1,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       3,
       'crapass.cdmotdem',
       rg_crapass.cdmotdem,
       '0');
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
    -- Buscar o valor das cotas em CRAPCOT
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
  
    --Buscar data de movimento da cooperativa
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
  
    --Buscar registro em TBCOTAS_DEVOLUCAO
    BEGIN
    
      SELECT cdcooper,
             nrdconta,
             tpdevolucao,
             vlcapital,
             qtparcelas,
             dtinicio_credito,
             vlpago
        INTO vr_tbcotas_dev_cdcooper,
             vr_tbcotas_dev_nrdconta,
             vr_tbcotas_dev_tpdevolucao,
             vr_tbcotas_dev_vlcapital,
             vr_tbcotas_dev_qtparcelas,
             vr_tbcotas_dev_dtinicio_credito,
             vr_tbcotas_dev_vlpago
        FROM TBCOTAS_DEVOLUCAO
       WHERE nrdconta = rg_crapass.nrdconta
         AND cdcooper = rg_crapass.cdcooper
         AND TPDEVOLUCAO = 3;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(chr(10) ||
                             'Não encontrado TBCOTAS_DEVOLUCAO para cooperativa e conta ' ||
                             rg_crapass.cdcooper || ' ' ||
                             rg_crapass.nrdconta);
        Continue;
    END;
  
    vr_nrdocmto := fn_sequence('CRAPLCT',
                               'NRDOCMTO',
                               rg_crapass.cdcooper || ';' ||
                               TRIM(to_char(vr_dtmvtolt, 'DD/MM/YYYY')) || ';' || 61);
    vr_nrseqdig := fn_sequence('CRAPLCT',
                               'NRSEQDIG',
                               rg_crapass.cdcooper || ';' ||
                               TRIM(to_char(vr_dtmvtolt, 'DD/MM/YYYY')) || ';' || 61);
  
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
      (rg_crapass.cdcooper,
       rg_crapass.cdagenci,
       100,
       10102,
       vr_dtmvtolt,
       61,
       0,
       rg_crapass.nrdconta,
       vr_nrdocmto,
       vr_nrseqdig,
       vr_tbcotas_dev_vlcapital,
       1,
       sysdate);
  
    -- Insere log com valores de antes x depois da craplct.
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       2,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       4,
       'craplct.dtmvtolt',
       null,
       vr_dtmvtolt);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       2,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       5,
       'craplct.vllanmto',
       null,
       vr_tbcotas_dev_vlcapital);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    UPDATE CECRED.crapcot
       SET vldcotas =
           (vldcotas + vr_tbcotas_dev_vlcapital)
     WHERE cdcooper = rg_crapass.cdcooper
       AND nrdconta = rg_crapass.nrdconta;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       3,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       6,
       'crapcot.vldcotas',
       vr_vldcotas_crapcot,
       (vr_vldcotas_crapcot + vr_tbcotas_dev_vlcapital));
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    -- Excluir registro conforme cooperativa e conta
    DELETE FROM CECRED.TBCOTAS_DEVOLUCAO
     WHERE CDCOOPER = rg_crapass.cdcooper
       AND NRDCONTA = rg_crapass.nrdconta
       AND TPDEVOLUCAO = 3;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       4,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       7,
       'tbcotas_devolucao.cdcooper',
       vr_tbcotas_dev_cdcooper,
       NULL);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       4,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       8,
       'tbcotas_devolucao.nrdconta',
       vr_tbcotas_dev_nrdconta,
       NULL);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       4,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       9,
       'tbcotas_devolucao.tpdevolucao',
       vr_tbcotas_dev_tpdevolucao,
       NULL);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       4,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       10,
       'tbcotas_devolucao.vlcapital',
       vr_tbcotas_dev_vlcapital,
       NULL);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       4,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       11,
       'tbcotas_devolucao.qtparcelas',
       vr_tbcotas_dev_qtparcelas,
       NULL);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       4,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       12,
       'tbcotas_devolucao.dtinicio_credito',
       vr_tbcotas_dev_dtinicio_credito,
       NULL);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    INSERT INTO cecred.craplgi
      (cdcooper,
       nrdconta,
       idseqttl,
       nrsequen,
       dttransa,
       hrtransa,
       nrseqcmp,
       nmdcampo,
       dsdadant,
       dsdadatu)
    VALUES
      (rg_crapass.cdcooper,
       rg_crapass.nrdconta,
       4,
       vr_nrsequenlgi,
       vr_dttransa,
       vr_hrtransa,
       13,
       'tbcotas_devolucao.vlpago',
       vr_tbcotas_dev_vlpago,
       NULL);
  
    vr_nrsequenlgi := vr_nrsequenlgi + 1;
  
    BEGIN
      SELECT cdcooper,
             nrdconta,
             tpdevolucao,
             vlcapital,
             qtparcelas,
             dtinicio_credito,
             vlpago
        INTO vr_tbcotas_dev_cdcooper,
             vr_tbcotas_dev_nrdconta,
             vr_tbcotas_dev_tpdevolucao,
             vr_tbcotas_dev_vlcapital,
             vr_tbcotas_dev_qtparcelas,
             vr_tbcotas_dev_dtinicio_credito,
             vr_tbcotas_dev_vlpago
        FROM TBCOTAS_DEVOLUCAO
       WHERE nrdconta = rg_crapass.nrdconta
         AND cdcooper = rg_crapass.cdcooper
         AND TPDEVOLUCAO = 4;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(chr(10) ||
                             'Não encontrado TBCOTAS_DEVOLUCAO para cooperativa e conta ' ||
                             rg_crapass.cdcooper || ' ' ||
                             rg_crapass.nrdconta);
        Continue;
    END;
  
    IF vr_tbcotas_dev_vlcapital > 0 THEN
      cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => rg_crapass.cdcooper,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => rg_crapass.cdagenci,
                                                pr_cdbccxlt    => 1,
                                                pr_nrdolote    => 600040,
                                                pr_nrdctabb    => rg_crapass.nrdconta,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_cdhistor    => 2520,
                                                pr_vllanmto    => vr_tbcotas_dev_vlcapital,
                                                pr_nrdconta    => rg_crapass.nrdconta,
                                                pr_hrtransa    => vr_hrtransa,
                                                pr_cdorigem    => 0,
                                                pr_inprolot    => 1,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
    
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        raise vr_exc_lanc_conta;
      END IF;
    
      -- Excluir registro conforme cooperativa e conta
      DELETE FROM CECRED.TBCOTAS_DEVOLUCAO
       WHERE CDCOOPER = rg_crapass.cdcooper
         AND NRDCONTA = rg_crapass.nrdconta
         AND TPDEVOLUCAO = 4;
    
      INSERT INTO cecred.craplgi
        (cdcooper,
         nrdconta,
         idseqttl,
         nrsequen,
         dttransa,
         hrtransa,
         nrseqcmp,
         nmdcampo,
         dsdadant,
         dsdadatu)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.nrdconta,
         5,
         vr_nrsequenlgi,
         vr_dttransa,
         vr_hrtransa,
         7,
         'tbcotas_devolucao.cdcooper',
         vr_tbcotas_dev_cdcooper,
         NULL);
    
      vr_nrsequenlgi := vr_nrsequenlgi + 1;
    
      INSERT INTO cecred.craplgi
        (cdcooper,
         nrdconta,
         idseqttl,
         nrsequen,
         dttransa,
         hrtransa,
         nrseqcmp,
         nmdcampo,
         dsdadant,
         dsdadatu)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.nrdconta,
         5,
         vr_nrsequenlgi,
         vr_dttransa,
         vr_hrtransa,
         8,
         'tbcotas_devolucao.nrdconta',
         vr_tbcotas_dev_nrdconta,
         NULL);
    
      vr_nrsequenlgi := vr_nrsequenlgi + 1;
    
      INSERT INTO cecred.craplgi
        (cdcooper,
         nrdconta,
         idseqttl,
         nrsequen,
         dttransa,
         hrtransa,
         nrseqcmp,
         nmdcampo,
         dsdadant,
         dsdadatu)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.nrdconta,
         5,
         vr_nrsequenlgi,
         vr_dttransa,
         vr_hrtransa,
         9,
         'tbcotas_devolucao.tpdevolucao',
         vr_tbcotas_dev_tpdevolucao,
         NULL);
    
      vr_nrsequenlgi := vr_nrsequenlgi + 1;
    
      INSERT INTO cecred.craplgi
        (cdcooper,
         nrdconta,
         idseqttl,
         nrsequen,
         dttransa,
         hrtransa,
         nrseqcmp,
         nmdcampo,
         dsdadant,
         dsdadatu)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.nrdconta,
         5,
         vr_nrsequenlgi,
         vr_dttransa,
         vr_hrtransa,
         10,
         'tbcotas_devolucao.vlcapital',
         vr_tbcotas_dev_vlcapital,
         NULL);
    
      vr_nrsequenlgi := vr_nrsequenlgi + 1;
    
      INSERT INTO cecred.craplgi
        (cdcooper,
         nrdconta,
         idseqttl,
         nrsequen,
         dttransa,
         hrtransa,
         nrseqcmp,
         nmdcampo,
         dsdadant,
         dsdadatu)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.nrdconta,
         5,
         vr_nrsequenlgi,
         vr_dttransa,
         vr_hrtransa,
         11,
         'tbcotas_devolucao.qtparcelas',
         vr_tbcotas_dev_qtparcelas,
         NULL);
    
      vr_nrsequenlgi := vr_nrsequenlgi + 1;
    
      INSERT INTO cecred.craplgi
        (cdcooper,
         nrdconta,
         idseqttl,
         nrsequen,
         dttransa,
         hrtransa,
         nrseqcmp,
         nmdcampo,
         dsdadant,
         dsdadatu)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.nrdconta,
         5,
         vr_nrsequenlgi,
         vr_dttransa,
         vr_hrtransa,
         12,
         'tbcotas_devolucao.dtinicio_credito',
         vr_tbcotas_dev_dtinicio_credito,
         NULL);
    
      vr_nrsequenlgi := vr_nrsequenlgi + 1;
    
      INSERT INTO cecred.craplgi
        (cdcooper,
         nrdconta,
         idseqttl,
         nrsequen,
         dttransa,
         hrtransa,
         nrseqcmp,
         nmdcampo,
         dsdadant,
         dsdadatu)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.nrdconta,
         5,
         vr_nrsequenlgi,
         vr_dttransa,
         vr_hrtransa,
         13,
         'tbcotas_devolucao.vlpago',
         vr_tbcotas_dev_vlpago,
         NULL);
    
      vr_nrsequenlgi := vr_nrsequenlgi + 1;
    END IF;
  
  END LOOP;

 COMMIT;

EXCEPTION
  WHEN vr_exception THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, vr_log_script || CHR(10) || SQLERRM);
  WHEN vr_exc_lanc_conta THEN
    BEGIN
      vr_cdcritic := NVL(vr_cdcritic, 0);
    
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      RAISE_APPLICATION_ERROR(-20000,
                              'Atenção: ' || vr_dscritic || CHR(10) ||
                              vr_log_script);
    END;
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
  
END;

