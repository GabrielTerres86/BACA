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
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(5);
  vr_log_script VARCHAR2(1000);
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
    -- Atualiza crapass
    UPDATE CRAPASS
      -- Em processo de demissão BACEN
      SET cdsitdct = 4
    WHERE nrdconta = rg_crapass.nrdconta
      AND cdcooper = rg_crapass.cdcooper;
    --
    -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
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
      ,vr_dttransa
      ,vr_hrtransa
      ,'Alterada situacao de conta por script. RITM0113109'
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
      ,vr_dttransa
      ,vr_hrtransa
      ,1
      ,'cdsitdct'
      ,rg_crapass.cdsitdct
      ,'4');
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






