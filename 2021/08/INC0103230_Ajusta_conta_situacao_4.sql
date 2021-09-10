DECLARE

  CURSOR cr_crapass is 
    SELECT nrdconta
      , cdcooper
      , cdsitdct
    FROM CECRED.CRAPASS
    WHERE 
      ( cdcooper = 2 -- ACREDICOOP
        AND nrdconta IN (473910, 442739, 385441)
      );
  
  
  --
  rg_crapass cr_crapass%rowtype;
       
  --
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(10);
  vr_log_script VARCHAR2(1000);
  vr_dstransa   VARCHAR2(1000);
  vr_vldcotas   NUMBER(25,2);
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_data       DATE;
  vr_capdev_ant NUMBER(15,2);
  vr_insere     CHAR(1);

   
BEGIN

  vr_log_script := ' ** Início script' || chr(10);
  
  -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := to_char(sysdate,'SSSSS');

    
  OPEN cr_crapass;
  LOOP
    FETCH cr_crapass INTO rg_crapass;
    EXIT WHEN cr_crapass%NOTFOUND;
    
    vr_log_script := 'Atualizacao da situacao da conta : (' 
             || '[ ' || LPAD(rg_crapass.cdcooper, 2, ' ') || ' ] '
             || LPAD(rg_crapass.nrdconta, 9, ' ') || ') da situacao (' || rg_crapass.cdsitdct
             || ') para (4)';
    --
    
    vr_dstransa := 'Alteracao da conta para situacao 4 INC0103230.';  
    
    
    -- Atualizar apenas um registro
    -- Realiza atualização da situação da conta.
    UPDATE cecred.crapass t 
    SET t.cdsitdct = 4 
    WHERE t.nrdconta = rg_crapass.nrdconta
    AND t.cdcooper = rg_crapass.cdcooper;
    
   
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
    
  END LOOP;

  CLOSE cr_crapass;   
      
  -- DBMS_OUTPUT.PUT_LINE(vr_log_script);
  
  --
  COMMIT;
  --
  -- DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    
    --
END;