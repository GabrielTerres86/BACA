DECLARE
  --
  CURSOR cr_crapass is 
    SELECT nrdconta
      , cdcooper
      , cdsitdct
    FROM cecred.crapass t
    WHERE (t.cdcooper,t.nrdconta) IN ((14, 56332)   -- Evolua
                                     ,(7,92010)
                                     ,(11,429171)
                                     ,(11,499528));   -- CredCrea
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
  vr_log_script VARCHAR2(4000);
  vr_vldcotas   NUMBER(25,2);
  vr_dstransa   varchar2(1000);
  vr_capdev_ant NUMBER(15,2);
  vr_insere     CHAR(1);
  vr_dtmvtolt   DATE;
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  --
BEGIN
  --
  vr_log_script := ' ** In�cio script' || chr(10);
  --
  OPEN cr_crapass;
  LOOP
    FETCH cr_crapass INTO rg_crapass;
    EXIT WHEN cr_crapass%NOTFOUND;
    --
    vr_log_script := vr_log_script || chr(10) || 'Atualiza��o da conta: (' 
                     || '[' || LPAD(rg_crapass.cdcooper, 2, ' ') || ' ] '
                     || LPAD(rg_crapass.nrdconta, 9, ' ') || ') da situa��o (' || rg_crapass.cdsitdct
                     || ') para (8)';
    --
    vr_dstransa := 'INC0093573 - Conta alterada para situacao 8.';
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
    IF NVL(vr_vldcotas, 0) > 0 then 
      --
      vr_capdev_ant := 0;
      vr_insere     := 'N';
      --
      begin
        select VLCAPITAL
          into vr_capdev_ant
        from TBCOTAS_DEVOLUCAO
        where TPDEVOLUCAO = 3
          and cdcooper = rg_crapass.cdcooper
          and nrdconta = rg_crapass.nrdconta;
      exception 
        when no_data_found then
          vr_capdev_ant := 0;
          dbms_output.put_line(chr(10) || 'N�o encontrado TBCOTAS_DEVOLUCAO anterior para conta ' || rg_crapass.nrdconta);
          vr_insere := 'S';
      end;
      --
      IF vr_insere = 'S' THEN
        --
        INSERT INTO TBCOTAS_DEVOLUCAO
        ( cdcooper, 
          nrdconta, 
          tpdevolucao, 
          vlcapital, 
          qtparcelas, 
          dtinicio_credito, 
          vlpago)
        VALUES 
          ( rg_crapass.cdcooper, 
            rg_crapass.nrdconta, 
            3, 
            vr_vldcotas, 
            1, 
            null, 
            0);
        --
        dbms_output.put_line('inserindo na TBCOTAS_DEVOLUCAO (' || rg_crapass.cdcooper || ') ' || rg_crapass.nrdconta);
        --
      ELSE 
        -- Adiciona valor de cota capital para devolu��o.
        UPDATE TBCOTAS_DEVOLUCAO
          SET VLCAPITAL = VLCAPITAL + vr_vldcotas
        WHERE CDCOOPER = rg_crapass.cdcooper
          AND NRDCONTA = rg_crapass.nrdconta
          AND TPDEVOLUCAO = 3;
      END IF;
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
      vr_dstransa := vr_dstransa || ' Movimentando saldo de capital para valores a devolver por script. R$ ' || to_char(vr_vldcotas, '9G999D99') || ' ' || vr_dtmvtolt;
      --
    END IF;
    --
    vr_log_script := vr_log_script || ' | ' || vr_dstransa;
    --
    -- Atualiza crapass
    UPDATE CRAPASS
      -- Em processo de demiss�o BACEN
      SET cdsitdct = 8
    WHERE nrdconta = rg_crapass.nrdconta
      AND cdcooper = rg_crapass.cdcooper;
    --
    -- Insere log de atualiza��o para a VERLOG. Ex: CADA0003 (6708)
    vr_hrtransa := to_char(sysdate,'SSSSS');

    INSERT INTO craplgm(cdcooper
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
      ,vr_dtmvtolt
      ,vr_hrtransa
      ,vr_dstransa
      ,'AIMARO'
      ,''
      ,1
      ,' '
      ,1
      ,' ');
    --
    -- Insere log com valores de antes x depois.
    INSERT INTO craplgi(cdcooper
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
      ,vr_dtmvtolt
      ,vr_hrtransa
      ,1
      ,'cdsitdct'
      ,rg_crapass.cdsitdct
      ,'8');
    --
    IF NVL(vr_vldcotas, 0) > 0 then
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,2
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,3
        ,'crapcot.vldcotas'
        ,vr_vldcotas
        ,0 );
      --
    END IF;
    --
  END LOOP;
  CLOSE cr_crapass;
  --
  -- dbms_output.put_line(vr_log_script);
  --
  COMMIT;
  --
  -- DBMS_OUTPUT.PUT_LINE('Sucesso na atualiza��o.');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;