DECLARE
  -- 
  CURSOR cr_craplgm IS
    SELECT lgm.cdcooper
      , lgm.nrdconta
      , lgm.idseqttl
      , lgm.nrsequen
      , lgm.nmdatela
      , lgm.dttransa
      , lgm.hrtransa
      , lgm.dstransa
      , lgm.nmendter
    FROM CECRED.CRAPLGM LGM
    WHERE dstransa LIKE 'Alteracao codigo da cooperativa cash para 7 - INC0097604.%'
    AND (
         cdcooper = 16 -- VIACREDI ALTO VALE
         AND nrdconta = 243361
        )
    ORDER BY cdcooper, nrdconta;
  --
  rg_craplgm cr_craplgm%ROWTYPE;
  --
  CURSOR cr_craplgi (pr_cdcooper    NUMBER
              , pr_nrdconta  NUMBER
              , pr_idseqttl  NUMBER
              , pr_nrsequen  NUMBER
              , pr_dttransa  DATE
              , pr_hrtransa  NUMBER
              , pr_nmdcampo  VARCHAR2
              , pr_valor     NUMBER ) IS
    SELECT lgi.nrdconta
      , lgi.cdcooper
      , lgi.dsdadant
      , lgi.dsdadatu 
      , lgi.nmdcampo
    FROM CECRED.CRAPLGI LGI
    WHERE lgi.nmdcampo = pr_nmdcampo
      and lgi.idseqttl = pr_idseqttl
      and lgi.nrsequen = pr_nrsequen
      and lgi.hrtransa = pr_hrtransa
      and lgi.dttransa = pr_dttransa
      and cdcooper     = pr_cdcooper
      and nrdconta     = pr_nrdconta
      and nrseqcmp     = pr_valor;
  --
  rg_craplgi cr_craplgi%ROWTYPE;
  --
  vr_dtmvtolt_aplicada   date;
  vr_vldcotas_movtda     NUMBER;
  vr_log_script          VARCHAR2(3000);
  vr_exception           exception;
  vr_qtatremvlgi         NUMBER;
  --
BEGIN
  dbms_output.enable(null);
  vr_log_script := ' ** Início script' || chr(10);
  --
  OPEN cr_craplgm;
  LOOP
    FETCH cr_craplgm INTO rg_craplgm;
    EXIT WHEN cr_craplgm%NOTFOUND;
    --
    -- volta a situação da conta
    OPEN cr_craplgi(pr_cdcooper    => rg_craplgm.cdcooper
                    , pr_nrdconta  => rg_craplgm.nrdconta
                    , pr_idseqttl  => rg_craplgm.idseqttl
                    , pr_nrsequen  => rg_craplgm.nrsequen
                    , pr_dttransa  => rg_craplgm.dttransa
                    , pr_hrtransa  => rg_craplgm.hrtransa
                    , pr_nmdcampo  => 'craplcm.cdcoptfn'
                    , pr_valor     => rg_craplgm.nmendter);
          
    FETCH cr_craplgi INTO rg_craplgi;
    CLOSE cr_craplgi;
    --
    vr_log_script := vr_log_script || chr(10) || chr(10) || 'ROLL BACK da atualização da conta: (' 
                     || '[' || LPAD(rg_craplgm.cdcooper, 2, ' ') || ' ] '
                     || rg_craplgm.nrdconta || ')' || CHR(10) 
                     || 'Restaurando cdcoptfn anterior (' || rg_craplgi.dsdadant || ').';
    --
    -- Atualiza craplcm
    UPDATE CECRED.CRAPLCM
      -- Em processo de demissão BACEN
      SET cdcoptfn = rg_craplgi.dsdadant
    WHERE cdcoptfn = rg_craplgi.dsdadatu
      AND vllanmto = rg_craplgm.nmendter
      AND dtmvtolt = to_date(rg_craplgm.nmdatela,'DD/MM/YYYY')
      AND nrdconta = rg_craplgm.nrdconta
      AND cdcooper = rg_craplgm.cdcooper;
    --
      
    -- Deleta log de atualização.
    DELETE CECRED.craplgm lgm
    WHERE lgm.cdcooper = rg_craplgm.cdcooper
      and lgm.nrdconta = rg_craplgm.nrdconta
      and lgm.idseqttl = rg_craplgm.idseqttl
      and lgm.nrsequen = rg_craplgm.nrsequen
      and lgm.dttransa = rg_craplgm.dttransa
      and lgm.hrtransa = rg_craplgm.hrtransa
      and lgm.dstransa = rg_craplgm.dstransa
      and lgm.nmdatela = rg_craplgm.nmdatela
      and lgm.nmendter = rg_craplgm.nmendter;
    --
    IF SQL%ROWCOUNT > 1 THEN 
      --
      vr_log_script := vr_log_script || chr(10) || 'ERRO AO DELETAR CRAPLGM. Total de Linhas para DELETE: ' 
                       || SQL%ROWCOUNT || ' onde deveria ser apenas uma.';
      --
      RAISE vr_exception;
      --
    END IF;
    --
    vr_log_script := vr_log_script || chr(10) || 'Total de Linhas removidas da CRAPLGM: ' || SQL%ROWCOUNT;
    --
  
    vr_qtatremvlgi :=0;
  
  BEGIN
  
     SELECT count(*) into vr_qtatremvlgi
       FROM CECRED.craplgi lgi
       WHERE lgi.cdcooper = rg_craplgm.cdcooper
         and lgi.nrdconta = rg_craplgm.nrdconta
         and lgi.idseqttl = rg_craplgm.idseqttl
         and lgi.nrsequen = rg_craplgm.nrsequen
         and lgi.dttransa = rg_craplgm.dttransa
         and lgi.hrtransa = rg_craplgm.hrtransa
         and lgi.nrseqcmp = rg_craplgm.nmendter;
     
     EXCEPTION
         WHEN OTHERS THEN 
           RAISE vr_exception;     
  END;   
  
    -- Deleta log com valores de antes x depois.
    DELETE CECRED.craplgi lgi
    WHERE lgi.cdcooper = rg_craplgm.cdcooper
      and lgi.nrdconta = rg_craplgm.nrdconta
      and lgi.idseqttl = rg_craplgm.idseqttl
      and lgi.nrsequen = rg_craplgm.nrsequen
      and lgi.dttransa = rg_craplgm.dttransa
      and lgi.hrtransa = rg_craplgm.hrtransa
      and lgi.nrseqcmp = rg_craplgm.nmendter;
    --
    IF SQL%ROWCOUNT > vr_qtatremvlgi THEN 
      --
      vr_log_script := vr_log_script || chr(10) || 'ERRO AO DELETAR CRAPLGI. Total de Linhas para DELETE: ' 
                       || SQL%ROWCOUNT || ' onde deveria ser apenas uma.';
      --
      RAISE vr_exception;
      --
    END IF;
    --
    --
    vr_log_script := vr_log_script || chr(10) || 'Total de Linhas removidas da CRAPLGI: ' || SQL%ROWCOUNT;
    --
  END LOOP;
  
  CLOSE cr_craplgm;
  --
  -- DBMS_OUTPUT.PUT_LINE(vr_log_script);
  --
  COMMIT;
  --
  -- DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN vr_exception THEN
    --
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, vr_log_script || CHR(10) || SQLERRM);
    --
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;