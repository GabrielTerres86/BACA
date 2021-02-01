DECLARE
  --
  CURSOR cr_crapass is 
    SELECT nrdconta
      , cdcooper
      , cdsitdct
    FROM CECRED.CRAPASS
    WHERE ( cdcooper = 1
            and nrdconta = 10601392
          )
      OR
      ( cdcooper = 16
        and nrdconta   IN ( 165522,
                            184373,
                            447897,
                            323713,
                            408590,
                            585904,
                            2886278,
                            584592,
                            383732,
                            510840,
                            494550 )
      );
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
                     || rg_crapass.cdcooper || ' - ' || rg_crapass.nrdconta 
                     || '). Movimentação do capital para valores a devolver.';
    --
    --
    vr_dstransa := 'Movimentando saldo de capital para valores a devolver por script. INC0076718.';
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
      vr_dstransa := vr_dstransa || ' R$ ' || to_char(vr_vldcotas, '9G999D99') || ' ' || vr_dtmvtolt;
      vr_log_script := vr_log_script || ' | ' || vr_dstransa;
      --
      -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
      vr_dttransa := trunc(sysdate);
      vr_hrtransa := to_char(sysdate,'SSSSS');
      --
      -- Inserindo log para a tela VERLOG
      INSERT INTO CECRED.craplgm(cdcooper
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
      -- Insere log com valores de antes x depois da TBCOTAS_DEVOLUCAO.
      INSERT INTO CECRED.craplgi(cdcooper
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
        ,2
        ,'crapcot.vldcotas'
        ,vr_vldcotas
        ,0 );
      --
    end if;
    --
  END LOOP;
  CLOSE cr_crapass;
  --
  dbms_output.put_line(vr_log_script);
  --
  COMMIT;
  --rollback;
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






