DECLARE
  CURSOR cr_craplgm IS
    SELECT lgm.cdcooper,
           lgm.nrdconta,
           lgm.idseqttl,
           lgm.nrsequen,
           lgm.dttransa,
           lgm.hrtransa,
           lgm.dstransa,
           lgm.nmendter
      FROM cecred.CRAPLGM LGM
     WHERE dstransa like
           'Alterada situacao de conta por script. INC0108069.%'
     ORDER BY cdcooper, nrdconta;

  rg_craplgm cr_craplgm%ROWTYPE;

  CURSOR cr_craplgi(pr_cdcooper NUMBER,
                    pr_nrdconta NUMBER,
                    pr_idseqttl NUMBER,
                    pr_nrsequen NUMBER,
                    pr_dttransa DATE,
                    pr_hrtransa NUMBER,
                    pr_nmdcampo VARCHAR2) IS
    SELECT lgi.nrdconta,
           lgi.cdcooper,
           lgi.dsdadant,
           lgi.dsdadatu,
           lgi.nmdcampo,
           lgi.idseqttl
      FROM CECRED.CRAPLGI LGI
     WHERE lgi.nmdcampo = pr_nmdcampo
       and lgi.dttransa = pr_dttransa
       and cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta;
  rg_craplgi cr_craplgi%ROWTYPE;

  vr_tbcotas_dev_cdcooper         NUMBER(5);
  vr_tbcotas_dev_nrdconta         NUMBER(10);
  vr_tbcotas_dev_tpdevolucao      NUMBER(1);
  vr_tbcotas_dev_vlcapital        NUMBER(15, 2);
  vr_tbcotas_dev_qtparcelas       NUMBER(2);
  vr_tbcotas_dev_dtinicio_credito DATE;
  vr_tbcotas_dev_vlpago           NUMBER(15, 2);

  vr_log_script        VARCHAR2(8000);
  vr_dtretorno_ant     DATE;
  vr_dtmvtolt_aplicada DATE;
  vr_dtdemiss_ant      DATE;
  vr_vldcotas_movtda   NUMBER;
  vr_exception exception;

  vr_qtatremvlgi NUMBER;

BEGIN
  DBMS_OUTPUT.ENABLE(buffer_size => NULL);

  vr_log_script := ' ** Início script' || chr(10);

  OPEN cr_craplgm;
  LOOP
    FETCH cr_craplgm
      INTO rg_craplgm;
    EXIT WHEN cr_craplgm%NOTFOUND;
  
    OPEN cr_craplgi(pr_cdcooper => rg_craplgm.cdcooper,
                    pr_nrdconta => rg_craplgm.nrdconta,
                    pr_idseqttl => rg_craplgm.idseqttl,
                    pr_nrsequen => rg_craplgm.nrsequen,
                    pr_dttransa => rg_craplgm.dttransa,
                    pr_hrtransa => rg_craplgm.hrtransa,
                    pr_nmdcampo => 'crapass.cdsitdct');
    FETCH cr_craplgi
      INTO rg_craplgi;
    CLOSE cr_craplgi;
  
    vr_log_script := vr_log_script || chr(10) || chr(10) ||
                     'ROLL BACK da atualização da conta: (' || '[' ||
                     LPAD(rg_craplgm.cdcooper, 2, ' ') || ' ] ' ||
                     rg_craplgm.nrdconta || ')' || CHR(10) ||
                     'Restaurando cdsitdct anterior (' ||
                     rg_craplgi.dsdadant || ').';
  
    -- Atualiza crapass
    UPDATE CECRED.CRAPASS
    -- Em processo de demissão BACEN
       SET cdsitdct = rg_craplgi.dsdadant
     WHERE nrdconta = rg_craplgm.nrdconta
       AND cdcooper = rg_craplgm.cdcooper;
  
    -- Volta a data demissão
    OPEN cr_craplgi(pr_cdcooper => rg_craplgm.cdcooper,
                    pr_nrdconta => rg_craplgm.nrdconta,
                    pr_idseqttl => rg_craplgm.idseqttl,
                    pr_nrsequen => rg_craplgm.nrsequen,
                    pr_dttransa => rg_craplgm.dttransa,
                    pr_hrtransa => rg_craplgm.hrtransa,
                    pr_nmdcampo => 'crapass.dtdemiss');
    FETCH cr_craplgi
      INTO rg_craplgi;
    CLOSE cr_craplgi;
  
    vr_log_script := vr_log_script || chr(10) ||
                     'Restaurando dtdemiss anterior (' ||
                     rg_craplgi.dsdadant || ').';
  
    -- Recebe a dtmvtolt utilizada na aplicação anterior para buscar lançamento da craplct
  
    vr_dtdemiss_ant      := null;
    vr_dtmvtolt_aplicada := null;
  
    if rg_craplgi.dsdadatu is not null then
      vr_dtmvtolt_aplicada := to_date(rg_craplgi.dsdadatu, 'dd/mm/rrrr');
    end if;
  
    if rg_craplgi.dsdadant is not null then
      vr_dtdemiss_ant := to_date(rg_craplgi.dsdadant, 'dd/mm/rrrr');
    end if;
  
    -- Atualiza crapass
    UPDATE CECRED.CRAPASS
    -- Em processo de demissão BACEN
       SET dtdemiss = vr_dtdemiss_ant
     WHERE nrdconta = rg_craplgm.nrdconta
       AND cdcooper = rg_craplgm.cdcooper;
  
    -- Volta o motivo
    OPEN cr_craplgi(pr_cdcooper => rg_craplgm.cdcooper,
                    pr_nrdconta => rg_craplgm.nrdconta,
                    pr_idseqttl => rg_craplgm.idseqttl,
                    pr_nrsequen => rg_craplgm.nrsequen,
                    pr_dttransa => rg_craplgm.dttransa,
                    pr_hrtransa => rg_craplgm.hrtransa,
                    pr_nmdcampo => 'crapass.cdmotdem');
    FETCH cr_craplgi
      INTO rg_craplgi;
    CLOSE cr_craplgi;
  
    vr_log_script := vr_log_script || chr(10) ||
                     'Restaurando cdmotdem anterior (' ||
                     rg_craplgi.dsdadant || ').';
  
    -- Atualiza crapass
    UPDATE CECRED.CRAPASS
    -- Em processo de demissão BACEN
       SET cdmotdem = rg_craplgi.dsdadant
     WHERE nrdconta = rg_craplgm.nrdconta
       AND cdcooper = rg_craplgm.cdcooper;
  
    OPEN cr_craplgi(pr_cdcooper => rg_craplgm.cdcooper,
                    pr_nrdconta => rg_craplgm.nrdconta,
                    pr_idseqttl => rg_craplgm.idseqttl,
                    pr_nrsequen => rg_craplgm.nrsequen,
                    pr_dttransa => rg_craplgm.dttransa,
                    pr_hrtransa => rg_craplgm.hrtransa,
                    pr_nmdcampo => 'crapass.dtelimin');
    FETCH cr_craplgi
      INTO rg_craplgi;
    CLOSE cr_craplgi;
  
    vr_log_script := vr_log_script || chr(10) ||
                     'Restaurando dtelimin anterior (' ||
                     rg_craplgi.dsdadant || ').';
  
    -- Atualiza crapass
    UPDATE CECRED.CRAPASS
    -- Em processo de demissão BACEN
       SET dtelimin = rg_craplgi.dsdadant
     WHERE nrdconta = rg_craplgm.nrdconta
       AND cdcooper = rg_craplgm.cdcooper;
  
    -- Volta o valor de cota capital - crapcot
    OPEN cr_craplgi(pr_cdcooper => rg_craplgm.cdcooper,
                    pr_nrdconta => rg_craplgm.nrdconta,
                    pr_idseqttl => rg_craplgm.idseqttl,
                    pr_nrsequen => rg_craplgm.nrsequen,
                    pr_dttransa => rg_craplgm.dttransa,
                    pr_hrtransa => rg_craplgm.hrtransa,
                    pr_nmdcampo => 'crapcot.vldcotas');
    FETCH cr_craplgi
      INTO rg_craplgi;
    CLOSE cr_craplgi;
  
    -- Pega o valor de cota movimentado para fazer a transação oposta.
    vr_vldcotas_movtda := to_number(rg_craplgi.dsdadant);
  
    -- Busca e insere o valor de cota capital dos valores a devolver - TBCOTAS_DEVOLUCAO
  
    vr_tbcotas_dev_qtparcelas       := NULL;
    vr_tbcotas_dev_dtinicio_credito := NULL;
    vr_tbcotas_dev_vlcapital        := NULL;
    vr_tbcotas_dev_vlpago           := NULL;
    vr_tbcotas_dev_tpdevolucao      := NULL;
    vr_tbcotas_dev_nrdconta         := NULL;
    vr_tbcotas_dev_cdcooper         := NULL;
  
    BEGIN
      select max(parcelas),
             max(data1),
             max(vlcapital),
             max(vlpago),
             max(tpdevolucao),
             max(nrdconta),
             max(cdcooper)
        into vr_tbcotas_dev_qtparcelas,
             vr_tbcotas_dev_dtinicio_credito,
             vr_tbcotas_dev_vlcapital,
             vr_tbcotas_dev_vlpago,
             vr_tbcotas_dev_tpdevolucao,
             vr_tbcotas_dev_nrdconta,
             vr_tbcotas_dev_cdcooper
        from (SELECT decode(lgi.nmdcampo,
                            'tbcotas_devolucao.qtparcelas',
                            lgi.dsdadant) as parcelas,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.dtinicio_credito',
                            lgi.dsdadant) as data1,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.vlcapital',
                            lgi.dsdadant) as vlcapital,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.vlpago',
                            lgi.dsdadant) as vlpago,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.tpdevolucao',
                            lgi.dsdadant) as tpdevolucao,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.nrdconta',
                            lgi.dsdadant) as nrdconta,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.cdcooper',
                            lgi.dsdadant) as cdcooper
                FROM CECRED.CRAPLGI LGI
               WHERE (lgi.nmdcampo = 'tbcotas_devolucao.dtinicio_credito' or
                     lgi.nmdcampo = 'tbcotas_devolucao.qtparcelas' or
                     lgi.nmdcampo = 'tbcotas_devolucao.vlcapital' or
                     lgi.nmdcampo = 'tbcotas_devolucao.vlpago' or
                     lgi.nmdcampo = 'tbcotas_devolucao.tpdevolucao' or
                     lgi.nmdcampo = 'tbcotas_devolucao.nrdconta' or
                     lgi.nmdcampo = 'tbcotas_devolucao.cdcooper')
                 and lgi.hrtransa = rg_craplgm.hrtransa
                 and lgi.dttransa = rg_craplgm.dttransa
                 and cdcooper = rg_craplgm.cdcooper
                 and nrdconta = rg_craplgm.nrdconta
                    -- Código definido no script para poder separar os valores a devolver
                 and IDSEQTTL = 4);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(chr(10) ||
                             'Conta não possui cotas para devolução: ' ||
                             rg_craplgm.cdcooper || ' ' ||
                             rg_craplgm.nrdconta || sqlerrm);
    END;
  
    IF vr_tbcotas_dev_cdcooper is not null THEN
      BEGIN
        INSERT INTO TBCOTAS_DEVOLUCAO
          (cdcooper,
           nrdconta,
           tpdevolucao,
           vlcapital,
           qtparcelas,
           dtinicio_credito,
           vlpago)
        VALUES
          (vr_tbcotas_dev_cdcooper,
           vr_tbcotas_dev_nrdconta,
           vr_tbcotas_dev_tpdevolucao,
           vr_tbcotas_dev_vlcapital,
           vr_tbcotas_dev_qtparcelas,
           vr_tbcotas_dev_dtinicio_credito,
           vr_tbcotas_dev_vlpago);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(chr(10) ||
                               'Erro ao inserir registro na TBCOTAS_DEVOLUCAO para cooperativa e conta ' ||
                               rg_craplgm.cdcooper || ' ' ||
                               rg_craplgm.nrdconta || sqlerrm);
      END;
    END IF;
    vr_tbcotas_dev_qtparcelas       := NULL;
    vr_tbcotas_dev_dtinicio_credito := NULL;
    vr_tbcotas_dev_vlcapital        := NULL;
    vr_tbcotas_dev_vlpago           := NULL;
    vr_tbcotas_dev_tpdevolucao      := NULL;
    vr_tbcotas_dev_nrdconta         := NULL;
    vr_tbcotas_dev_cdcooper         := NULL;
  
    BEGIN
      select max(parcelas),
             max(data1),
             max(vlcapital),
             max(vlpago),
             max(tpdevolucao),
             max(nrdconta),
             max(cdcooper)
        into vr_tbcotas_dev_qtparcelas,
             vr_tbcotas_dev_dtinicio_credito,
             vr_tbcotas_dev_vlcapital,
             vr_tbcotas_dev_vlpago,
             vr_tbcotas_dev_tpdevolucao,
             vr_tbcotas_dev_nrdconta,
             vr_tbcotas_dev_cdcooper
        from (SELECT decode(lgi.nmdcampo,
                            'tbcotas_devolucao.qtparcelas',
                            lgi.dsdadant) as parcelas,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.dtinicio_credito',
                            lgi.dsdadant) as data1,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.vlcapital',
                            lgi.dsdadant) as vlcapital,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.vlpago',
                            lgi.dsdadant) as vlpago,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.tpdevolucao',
                            lgi.dsdadant) as tpdevolucao,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.nrdconta',
                            lgi.dsdadant) as nrdconta,
                     decode(lgi.nmdcampo,
                            'tbcotas_devolucao.cdcooper',
                            lgi.dsdadant) as cdcooper
                FROM CECRED.CRAPLGI LGI
               WHERE (lgi.nmdcampo = 'tbcotas_devolucao.dtinicio_credito' or
                     lgi.nmdcampo = 'tbcotas_devolucao.qtparcelas' or
                     lgi.nmdcampo = 'tbcotas_devolucao.vlcapital' or
                     lgi.nmdcampo = 'tbcotas_devolucao.vlpago' or
                     lgi.nmdcampo = 'tbcotas_devolucao.tpdevolucao' or
                     lgi.nmdcampo = 'tbcotas_devolucao.nrdconta' or
                     lgi.nmdcampo = 'tbcotas_devolucao.cdcooper')
                 and lgi.hrtransa = rg_craplgm.hrtransa
                 and lgi.dttransa = rg_craplgm.dttransa
                 and cdcooper = rg_craplgm.cdcooper
                 and nrdconta = rg_craplgm.nrdconta
                    -- Código definido no script para poder separar os valores a devolver
                 and IDSEQTTL = 5);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(chr(10) ||
                             'Conta não possui cotas para devolução: ' ||
                             rg_craplgm.cdcooper || ' ' ||
                             rg_craplgm.nrdconta || sqlerrm);
    END;
  
    IF vr_tbcotas_dev_cdcooper is not null THEN
      BEGIN
        INSERT INTO TBCOTAS_DEVOLUCAO
          (cdcooper,
           nrdconta,
           tpdevolucao,
           vlcapital,
           qtparcelas,
           dtinicio_credito,
           vlpago)
        VALUES
          (vr_tbcotas_dev_cdcooper,
           vr_tbcotas_dev_nrdconta,
           vr_tbcotas_dev_tpdevolucao,
           vr_tbcotas_dev_vlcapital,
           vr_tbcotas_dev_qtparcelas,
           vr_tbcotas_dev_dtinicio_credito,
           vr_tbcotas_dev_vlpago);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(chr(10) ||
                               'Erro ao inserir registro na TBCOTAS_DEVOLUCAO para cooperativa e conta ' ||
                               rg_craplgm.cdcooper || ' ' ||
                               rg_craplgm.nrdconta || sqlerrm);
      END;
    
      -- Remove lançamento 2520 gerado no script.
      DELETE CRAPLCM A
       WHERE A.CDCOOPER = rg_craplgm.cdcooper
         and A.NRDCONTA = rg_craplgm.nrdconta
         and A.HRTRANSA = rg_craplgm.hrtransa
         and A.CDHISTOR = 2520
         and A.Nrdolote = 600040;
    
      vr_log_script := vr_log_script || chr(10) ||
                       'Total de Linhas removidas da CRAPLCT: ' ||
                       SQL%ROWCOUNT;
    
    END IF;
    
    
    -- Volta o valor de cotas para zero, pois a conta está encerrada.
    UPDATE CECRED.crapcot
       SET vldcotas = 0
     WHERE cdcooper = rg_craplgm.cdcooper
       AND nrdconta = rg_craplgm.nrdconta;
  
    -- Deleta log de atualização.
    DELETE CECRED.craplgm lgm
     WHERE lgm.cdcooper = rg_craplgm.cdcooper
       and lgm.nrdconta = rg_craplgm.nrdconta
       and lgm.idseqttl = rg_craplgm.idseqttl
       and lgm.nrsequen = rg_craplgm.nrsequen
       and lgm.dttransa = rg_craplgm.dttransa
       and lgm.hrtransa = rg_craplgm.hrtransa
       and lgm.dstransa = rg_craplgm.dstransa;
    IF SQL%ROWCOUNT > 1 THEN
      vr_log_script := vr_log_script || chr(10) ||
                       'ERRO AO DELETAR CRAPLGM. Total de Linhas para DELETE: ' ||
                       SQL%ROWCOUNT || ' onde deveria ser apenas uma.';
    
      RAISE vr_exception;
    
    END IF;
  
    vr_log_script := vr_log_script || chr(10) ||
                     'Total de Linhas removidas da CRAPLGM: ' ||
                     SQL%ROWCOUNT;
  
    vr_qtatremvlgi := 0;
  
    BEGIN
    
      SELECT count(*)
        into vr_qtatremvlgi
        FROM CECRED.craplgi lgi
       WHERE lgi.cdcooper = rg_craplgm.cdcooper
         and lgi.nrdconta = rg_craplgm.nrdconta
         and lgi.idseqttl = rg_craplgm.idseqttl
         and lgi.nrsequen = rg_craplgm.nrsequen
         and lgi.dttransa = rg_craplgm.dttransa
         and lgi.hrtransa = rg_craplgm.hrtransa;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE vr_exception;
    END;
  
    -- Deleta log com valores de antes x depois.
    DELETE CECRED.craplgi lgi
     WHERE lgi.cdcooper = rg_craplgm.cdcooper
       and lgi.nrdconta = rg_craplgm.nrdconta
       and lgi.dttransa = rg_craplgm.dttransa
       and lgi.hrtransa = rg_craplgm.hrtransa
    -- and lgi.nmdcampo = rg_craplgi.nmdcampo
    ;
  
    vr_log_script := vr_log_script || chr(10) ||
                     'Total de Linhas removidas da CRAPLGI: ' ||
                     SQL%ROWCOUNT;
  
  END LOOP;

  CLOSE cr_craplgm;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');

EXCEPTION
  WHEN vr_exception THEN
  
    ROLLBACK;
  
    RAISE_APPLICATION_ERROR(-20001,
                            vr_log_script || chr(10) || SQLCODE || ' ' ||
                            SQLERRM);
  
  WHEN OTHERS THEN
  
    ROLLBACK;
  
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
  
END;
