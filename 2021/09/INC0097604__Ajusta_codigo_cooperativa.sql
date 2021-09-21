DECLARE

  CURSOR cr_craplcm is 
    SELECT cdcooper, nrdconta, cdcoptfn, vllanmto, dtmvtolt
    FROM cecred.craplcm
    WHERE dtmvtolt BETWEEN to_date('14/06/2021','DD/MM/YYYY') AND to_date('15/06/2021','DD/MM/YYYY')
      AND vllanmto IN (40,900)
	  AND nrdconta = 243361
      AND cdcooper = 16
    ORDER BY cdcooper, nrdconta, cdcoptfn, vllanmto, dtmvtolt;
	
  
  
  --
  rg_craplcm cr_craplcm%rowtype;
       
  --
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(10);
  vr_log_script VARCHAR2(3000);
  vr_dstransa   VARCHAR2(1000);
  vr_vldcotas   NUMBER(25,2);
  vr_nrsequen   NUMBER(2);
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_data       DATE;
  vr_capdev_ant NUMBER(15,2);
  vr_insere     CHAR(1);

   
BEGIN

  vr_log_script := ' ** Início script' || chr(10);
  
  vr_nrsequen:=0;
      
  OPEN cr_craplcm;
  LOOP
    FETCH cr_craplcm INTO rg_craplcm;
    EXIT WHEN cr_craplcm%NOTFOUND;
    
    vr_log_script := vr_log_script || chr(10) || chr(10) || 'Atualizacao codigo da cooperativa cash: ('	
             || '[ ' || LPAD(rg_craplcm.cdcooper, 2, ' ') || ' ] '
             || LPAD(rg_craplcm.nrdconta, 9, ' ') || ') do codigo (' || rg_craplcm.cdcoptfn
             || ') para (7)';
    --
    
    vr_dstransa := 'Alteracao codigo da cooperativa cash para 7 - INC0097604.';  
    
	-- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := to_char(sysdate,'SSSSS');
	
	
	IF vr_nrsequen = 0 THEN
	   vr_nrsequen :=1;
	ELSE
	   vr_nrsequen:= vr_nrsequen + 1;
	END IF;
	
    
    -- Atualizar apenas um registro
    -- Realiza atualização da situação da conta.
    UPDATE cecred.craplcm t 
      SET t.cdcoptfn = 7 
    WHERE t.cdcoptfn = rg_craplcm.cdcoptfn
      AND t.vllanmto = rg_craplcm.vllanmto
      AND t.dtmvtolt = rg_craplcm.dtmvtolt
      AND t.nrdconta = rg_craplcm.nrdconta
      AND t.cdcooper = rg_craplcm.cdcooper;
        
   
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
      (rg_craplcm.cdcooper
      ,rg_craplcm.nrdconta
      ,1
      ,vr_nrsequen
      ,vr_dttransa
      ,vr_hrtransa
      ,vr_dstransa
      ,'AIMARO'
      ,to_char(rg_craplcm.dtmvtolt,'DD/MM/YYYY')
      ,1
      ,' '
      ,1
      ,rg_craplcm.vllanmto);
    --
    -- Insere log com valores de antes x depois da craplcm.
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
      (rg_craplcm.cdcooper
      ,rg_craplcm.nrdconta
      ,1
      ,vr_nrsequen
      ,vr_dttransa
      ,vr_hrtransa
      ,rg_craplcm.vllanmto
      ,'craplcm.cdcoptfn'
      ,rg_craplcm.cdcoptfn
      ,'7');
    --
    
  END LOOP;

  CLOSE cr_craplcm;   
      
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