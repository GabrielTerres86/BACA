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
     WHERE (a.cdcooper = 16 and a.nrdconta = 3669580);

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
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_nrdrowid ROWID;
BEGIN
    FOR rg_crapass IN cr_crapass LOOP  
    vr_dstransa          := 'Alterada situacao de conta por script. INC0119902.';
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
  
  GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'Alteracao da situacao de conta por script - INC0119902',
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 1,
                       pr_nmdatela => 'Atenda',
                       pr_nrdconta => rg_crapass.nrdconta,
                       pr_nrdrowid => vr_nrdrowid);                      
    
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.cdsitdct',
                              pr_dsdadant => rg_crapass.cdsitdct,
                              pr_dsdadatu => 1);

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.dtdemiss',
                              pr_dsdadant => rg_crapass.dtdemiss,
                              pr_dsdadatu => null);

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.dtelimin',
                              pr_dsdadant => rg_crapass.dtelimin,
                              pr_dsdadatu => null);                              

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.cdmotdem',
                              pr_dsdadant => rg_crapass.cdmotdem,
                              pr_dsdadatu => 0);  
                              
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
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'craplct.dtmvtolt',
                              pr_dsdadant => null,
                              pr_dsdadatu => vr_dtmvtolt);  
                              
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'craplct.vllanmto',
                              pr_dsdadant => null,
                              pr_dsdadatu => vr_tbcotas_dev_vlcapital);                                
  
    UPDATE CECRED.crapcot
       SET vldcotas =
           (vldcotas + vr_tbcotas_dev_vlcapital)
     WHERE cdcooper = rg_crapass.cdcooper
       AND nrdconta = rg_crapass.nrdconta;
  
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapcot.vldcotas',
                              pr_dsdadant => vr_vldcotas_crapcot,
                              pr_dsdadatu => (vr_vldcotas_crapcot + vr_tbcotas_dev_vlcapital));    
                              
    -- Excluir registro conforme cooperativa e conta
    DELETE FROM CECRED.TBCOTAS_DEVOLUCAO
     WHERE CDCOOPER = rg_crapass.cdcooper
       AND NRDCONTA = rg_crapass.nrdconta
       AND TPDEVOLUCAO = 3;
  
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcotas_devolucao.cdcooper',
                              pr_dsdadant => vr_tbcotas_dev_cdcooper,
                              pr_dsdadatu => null);    
                              
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'tbcotas_devolucao.nrdconta',
                              pr_dsdadant => vr_tbcotas_dev_nrdconta,
                              pr_dsdadatu => null);                                                                
  
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                          pr_nmdcampo => 'tbcotas_devolucao.tpdevolucao',
                          pr_dsdadant => vr_tbcotas_dev_tpdevolucao,
                          pr_dsdadatu => null);   
                              

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                          pr_nmdcampo => 'tbcotas_devolucao.vlcapital',
                          pr_dsdadant => vr_tbcotas_dev_vlcapital,
                          pr_dsdadatu => null);   
  
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                          pr_nmdcampo => 'tbcotas_devolucao.qtparcelas',
                          pr_dsdadant => vr_tbcotas_dev_qtparcelas,
                          pr_dsdadatu => null);   
  
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                          pr_nmdcampo => 'tbcotas_devolucao.dtinicio_credito',
                          pr_dsdadant => vr_tbcotas_dev_dtinicio_credito,
                          pr_dsdadatu => null);   

  
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                          pr_nmdcampo => 'tbcotas_devolucao.vlpago',
                          pr_dsdadant => vr_tbcotas_dev_vlpago,
                          pr_dsdadatu => null);       
  
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
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'tbcotas_devolucao.cdcooper',
                            pr_dsdadant => vr_tbcotas_dev_cdcooper,
                            pr_dsdadatu => null);    
                              
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'tbcotas_devolucao.nrdconta',
                            pr_dsdadant => vr_tbcotas_dev_nrdconta,
                            pr_dsdadatu => null);                                                                
  
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                        pr_nmdcampo => 'tbcotas_devolucao.tpdevolucao',
                        pr_dsdadant => vr_tbcotas_dev_tpdevolucao,
                        pr_dsdadatu => null);   
                              

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                        pr_nmdcampo => 'tbcotas_devolucao.vlcapital',
                        pr_dsdadant => vr_tbcotas_dev_vlcapital,
                        pr_dsdadatu => null);   
  
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                        pr_nmdcampo => 'tbcotas_devolucao.qtparcelas',
                        pr_dsdadant => vr_tbcotas_dev_qtparcelas,
                        pr_dsdadatu => null);   
  
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                        pr_nmdcampo => 'tbcotas_devolucao.dtinicio_credito',
                        pr_dsdadant => vr_tbcotas_dev_dtinicio_credito,
                        pr_dsdadatu => null);   

  
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                        pr_nmdcampo => 'tbcotas_devolucao.vlpago',
                        pr_dsdadant => vr_tbcotas_dev_vlpago,
                        pr_dsdadatu => null);       
              
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

