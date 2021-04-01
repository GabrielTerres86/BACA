DECLARE
  --
  CURSOR cr_crapass is 
    SELECT nrdconta
      , cdcooper
      , cdsitdct
    FROM CECRED.CRAPASS
    WHERE ( cdcooper = 1
        and nrdconta   IN (   9799214
                            , 11011190
                            , 7581165
                            , 7077319
                            , 6632696
                            , 7437471
                            , 9944885
                            , 9226788)
      )
      OR ( cdcooper = 13
        and nrdconta   IN (   316059
                            , 259560
                            , 235369 )

      )
      OR ( cdcooper = 9
        and nrdconta   IN (   124338
                            , 38393 )

      )
      OR ( cdcooper = 16
        and nrdconta   IN ( 255106 )

      )
      OR ( cdcooper = 6
        and nrdconta   IN ( 825 )

      )
      OR ( cdcooper = 14
        and nrdconta   IN (69825)

      )
      OR ( cdcooper  = 11
        AND nrdconta = 465160
      );
  --
  rg_crapass cr_crapass%rowtype;
  --
  cursor cr_crapcot (p_nrdconta   NUMBER
                     , p_cdcooper number) is
    select vldcotas
    from CECRED.crapcot
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
  vr_insere     CHAR(1);
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
                     || '[ ' || LPAD(rg_crapass.cdcooper, 2, ' ') || ' ] '
                     || LPAD(rg_crapass.nrdconta, 9, ' ') || ') da situação (' || rg_crapass.cdsitdct
                     || ') para (4)';
    --
    vr_dstransa := 'Alterada situacao de conta por script. INC0084476.';
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
      vr_capdev_ant := 0;
      vr_insere     := 'N';
      --
      begin
        select VLCAPITAL
          into vr_capdev_ant
        from CECRED.TBCOTAS_DEVOLUCAO
        where TPDEVOLUCAO = 3
          and cdcooper = rg_crapass.cdcooper
          and nrdconta = rg_crapass.nrdconta;
      EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
          --
          vr_capdev_ant := 0;
          vr_insere     := 'S';
          dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO anterior para conta ' || rg_crapass.nrdconta);
          --
      end;
      --
      IF vr_insere = 'S' THEN
        --
        INSERT INTO CECRED.TBCOTAS_DEVOLUCAO
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
        -- Adiciona valor de cota capital para devolução.
        UPDATE CECRED.TBCOTAS_DEVOLUCAO
          SET VLCAPITAL = VLCAPITAL + vr_vldcotas
        WHERE CDCOOPER = rg_crapass.cdcooper
          AND NRDCONTA = rg_crapass.nrdconta
          AND TPDEVOLUCAO = 3;
        --
      END IF;
      --
      -- Remove valor de cota capital
      UPDATE CECRED.crapcot
        SET vldcotas = vldcotas - vr_vldcotas
      WHERE cdcooper = rg_crapass.cdcooper
        AND nrdconta = rg_crapass.nrdconta; 
      --
      vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';16;100;600040');
      vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';16;100;600040');
      --
      INSERT INTO CECRED.craplct(cdcooper
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






