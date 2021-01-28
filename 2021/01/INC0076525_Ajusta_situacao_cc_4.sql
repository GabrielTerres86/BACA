DECLARE
  --
  CURSOR cr_crapass is 
    SELECT nrdconta
      , cdcooper
      , cdsitdct
    FROM CECRED.CRAPASS
    WHERE cdcooper = 16
      and nrdconta   IN ( 1835793,
                          2036878,
                          2005000,
                          276448,
                          2534380,
                          2689189,
                          37958,
                          349615,
                          6556078,
                          186350,
                          222127,
                          245011,
                          343242,
                          167746,
                          895784 );
  --
  rg_crapass cr_crapass%rowtype;
  --
  cursor cr_crapcot (p_nrdconta   NUMBER
                     , p_cdcooper number) is
    select vldcotas
    from crapcot
    where cdcooper = p_cdcooper
      and nrdconta = p_nrdconta;
  --
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(5);
  vr_log_script VARCHAR2(8000);
  vr_dstransa   varchar2(1000);
  vr_vldcotas   NUMBER(25,2);
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_dtmvtolt   DATE;
  vr_capdev_ant NUMBER(15,2);
  --
BEGIN
  --
  vr_log_script := ' ** Início script' || chr(10);
  --
  OPEN cr_crapass;
  LOOP
    FETCH cr_crapass INTO rg_crapass;
    EXIT WHEN cr_crapass%NOTFOUND;
    --
    vr_log_script := vr_log_script || chr(10) || 'Atualização da conta: (' 
                     || rg_crapass.nrdconta || ') da situação (' || rg_crapass.cdsitdct
                     || ') para (4)';
    --
    vr_dstransa := 'Alterada situacao de conta por script. RITM0113109.';
    --
    -- Verificar o valor de cotas a devolver ao cooperado.
    vr_vldcotas := 0;
    --
    open cr_crapcot(rg_crapass.nrdconta
                    , rg_crapass.cdcooper);
    fetch cr_crapcot into vr_vldcotas;
    close cr_crapcot;
    --
    SELECT dtmvtolt
      INTO vr_dtmvtolt
    FROM crapdat 
    WHERE cdcooper = rg_crapass.cdcooper;
    --
    if nvl(vr_vldcotas, 0) > 0 then 
      --
      select VLCAPITAL
        into vr_capdev_ant
      from TBCOTAS_DEVOLUCAO
      where TPDEVOLUCAO = 3
        and cdcooper = rg_crapass.cdcooper
        and nrdconta = rg_crapass.nrdconta;
      --
      -- Adiciona valor de cota capital para devolução.
      UPDATE TBCOTAS_DEVOLUCAO
        SET VLCAPITAL = VLCAPITAL + vr_vldcotas
      WHERE CDCOOPER = rg_crapass.cdcooper
        AND NRDCONTA = rg_crapass.nrdconta
        AND TPDEVOLUCAO = 3;
      --
      -- Remove valor de cota capital
      UPDATE crapcot
        SET vldcotas = vldcotas - vr_vldcotas
      WHERE cdcooper = rg_crapass.cdcooper
        AND nrdconta = rg_crapass.nrdconta; 
      --
      vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';16;100;600040');
      vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';16;100;600040');
      --
      INSERT INTO craplct(cdcooper
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,dtmvtolt
        ,cdhistor
        ,nrctrpla
        ,nrdconta
        ,nrdocmto
        ,nrseqdig
        ,vllanmto)
      VALUES (rg_crapass.cdcooper
        ,16
        ,100
        ,600040
        ,vr_dtmvtolt
        ,2080
        ,0
        ,rg_crapass.nrdconta 
        ,vr_nrdocmto
        ,vr_nrseqdig
        ,vr_vldcotas); 
      --
      vr_dstransa := vr_dstransa || ' Movimentado capital de ' || to_char(vr_vldcotas, '9G999D99') || ' para Valores a Devolver.';
      vr_log_script := vr_log_script || ' | ' || vr_dstransa;
      --
    end if;
    
    --
    -- Atualiza crapass
    UPDATE cecred.CRAPASS
      -- Em processo de demissão BACEN
      SET cdsitdct = 4
        , dtdemiss = vr_dtmvtolt
    WHERE nrdconta = rg_crapass.nrdconta
      AND cdcooper = rg_crapass.cdcooper;
    --
    -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := to_char(sysdate,'SSSSS');

    INSERT INTO cecred.craplgm(cdcooper
      ,nrdconta
      ,idseqttl
      ,nrsequen
      ,dttransa
      ,hrtransa
      ,dstransa
      ,dsorigem
      ,nmdatela
      ,flgtrans
      ,dscritic
      ,cdoperad
      ,nmendter)
    VALUES
      (rg_crapass.cdcooper
      ,rg_crapass.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,vr_dstransa
      ,'AIMARO'
      ,''
      ,1
      ,' '
      ,1
      ,' ');
    --
    -- Insere log com valores de antes x depois da crapass.
    INSERT INTO cecred.craplgi(cdcooper
      ,nrdconta
      ,idseqttl
      ,nrsequen
      ,dttransa
      ,hrtransa
      ,nrseqcmp
      ,nmdcampo
      ,dsdadant
      ,dsdadatu)
    VALUES
      (rg_crapass.cdcooper
      ,rg_crapass.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,1
      ,'crapass.cdsitdct'
      ,rg_crapass.cdsitdct
      ,'4');
    --
    -- Insere log com valores de antes x depois da crapass.
    INSERT INTO cecred.craplgi(cdcooper
      ,nrdconta
      ,idseqttl
      ,nrsequen
      ,dttransa
      ,hrtransa
      ,nrseqcmp
      ,nmdcampo
      ,dsdadant
      ,dsdadatu)
    VALUES
      (rg_crapass.cdcooper
      ,rg_crapass.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,2
      ,'crapass.dtdemiss'
      ,null
      ,to_char(vr_dtmvtolt, 'dd/mm/rrrr') );
    --
    if nvl(vr_vldcotas, 0) > 0 then 
      --
      -- Insere log com valores de antes x depois da TBCOTAS_DEVOLUCAO.
      INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
      VALUES
        (rg_crapass.cdcooper
        ,rg_crapass.nrdconta
        ,1
        ,1
        ,vr_dttransa
        ,vr_hrtransa
        ,3
        ,'tbcotas_devolucao.VLCAPITAL'
        ,vr_capdev_ant
        ,(vr_capdev_ant + vr_vldcotas) );
      --
      -- Insere log com valores de antes x depois da CRAPCOT.
      INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
      VALUES
        (rg_crapass.cdcooper
        ,rg_crapass.nrdconta
        ,1
        ,1
        ,vr_dttransa
        ,vr_hrtransa
        ,4
        ,'crapcot.vldcotas'
        ,vr_vldcotas
        ,0 );
    end if;
    --
  END LOOP;
  CLOSE cr_crapass;
  --
  dbms_output.put_line(vr_log_script);
  --
  COMMIT;
  --
  DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
