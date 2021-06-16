DECLARE
  --
  CURSOR cr_craplau is 
    SELECT nrdconta
      , cdcooper
      , insitlau
	  , nrdocmto
    FROM CECRED.CRAPLAU
    WHERE cdcooper = 5 -- ACENTRA
      AND nrdconta = 177199
	  AND nrdocmto IN (166,167,168);
  --
  rg_craplau cr_craplau%rowtype;
  
  --
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(10);
  vr_dstransa   VARCHAR2(1000);
  vr_log_script VARCHAR2(8000);
  vr_novasit    NUMBER(1);
  vr_capdev_ant NUMBER(15,2);
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  
  --
  
BEGIN
    --
    vr_log_script := ' ** Início script' || chr(10);
    
    --
    OPEN cr_craplau;
    LOOP
    FETCH cr_craplau INTO rg_craplau;
    EXIT WHEN cr_craplau%NOTFOUND;
    --
    vr_log_script := vr_log_script || chr(10) || 'Atualização do lancamento: (' 
                     || '[ ' || LPAD(rg_craplau.cdcooper, 2, ' ') || ' ] '
                     || LPAD(rg_craplau.nrdocmto, 9, ' ') || ') da situação (' || rg_craplau.insitlau
                     || ') para (3)';
    --
    vr_dstransa := 'Alterada situacao do lancamento por script. INC0091575.';
    --
   	
	
    UPDATE CECRED.craplau
        SET insitlau = 3
    WHERE nrdocmto = rg_craplau.nrdocmto
	  AND nrdconta = rg_craplau.nrdconta
      AND cdcooper = rg_craplau.cdcooper;
      --
           
    --
    -- Insere log de atualização para a VERLOG.
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := substr(to_char(systimestamp,'FF'),1,10); --to_char(sysdate,'SSSSS');

    INSERT INTO cecred.craplgm(cdcooper
      ,nrdconta
      ,idseqttl
      ,dttransa
      ,hrtransa
      ,nrsequen
	  ,dstransa
      ,dsorigem
      ,nmdatela
      ,flgtrans
      ,dscritic
      ,cdoperad
      ,nmendter)
    VALUES
      (rg_craplau.cdcooper
      ,rg_craplau.nrdconta
      ,rg_craplau.nrdocmto
      ,vr_dttransa
      ,vr_hrtransa
      ,1
	  ,vr_dstransa
      ,'AIMARO'
      ,'craplau'
      ,1
      ,' '
      ,1
      ,' ');
    --
    -- Insere log com valores de antes x depois da craplau.
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
      (rg_craplau.cdcooper
      ,rg_craplau.nrdconta
      ,rg_craplau.nrdocmto
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,1
      ,'insitlau'
      ,rg_craplau.insitlau
      ,'3');
    --
	
  END LOOP;
  
  --
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