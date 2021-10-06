DECLARE
  --
  CURSOR cr_craplau is 
    SELECT nrdconta
      , cdcooper
      , insitlau
	  , nrdocmto
	  , dtdebito
    FROM CECRED.CRAPLAU
    WHERE nrdconta = 1921304
	  AND nrdocmto IN (45806,390926)
	  AND cdcooper = 1; -- VIACREDI;
  --
  
  rg_craplau cr_craplau%rowtype;
  
  --
  vr_dttransa   DATE;
  vr_dtmvtolt   DATE;
  vr_hrtransa   VARCHAR2(10);
  vr_dstransa   VARCHAR2(1000);
  vr_log_script VARCHAR2(8000);
  vr_novasit    NUMBER(1);
  vr_capdev_ant NUMBER(15,2);
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_nrsequen   NUMBER(2);					  
  
  --
  
BEGIN
    --
    vr_log_script := ' ** Início script' || chr(10);
 
	vr_nrsequen:=0;			
    
		
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
    vr_dstransa := 'Alterada situacao dos lancamentos por script. INC0107532.';
    --
   	-- status do campo insitlau (1 - Pendentes, 2 - Efetivados, 3 - Cancelados, 31 - Cancelados por Fraude, 4 - Não Efetivados)
	
	-- busca a data da cooperativa
	SELECT dtmvtolt
      INTO vr_dtmvtolt
    FROM crapdat 
    WHERE cdcooper = rg_craplau.cdcooper;
	
	IF vr_nrsequen = 0 THEN
	   vr_nrsequen :=1;
	ELSE
	   vr_nrsequen:= vr_nrsequen + 1;
	END IF;
		
 
    UPDATE CECRED.craplau
        SET insitlau = 3, dtdebito = vr_dtmvtolt
    WHERE nrdocmto = rg_craplau.nrdocmto
	  AND nrdconta = rg_craplau.nrdconta
      AND cdcooper = rg_craplau.cdcooper;
	--
    
	-- Insere log de atualização para a VERLOG.
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := gene0002.fn_busca_time;
	
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
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,vr_nrsequen
	  ,vr_dstransa
      ,'AIMARO'
      ,'craplau'
      ,1
      ,' '
      ,rg_craplau.nrdocmto
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
      ,1
	  ,vr_nrsequen		  
      ,vr_dttransa
      ,vr_hrtransa
      ,1 --rg_craplau.nrdocmto
      ,'craplau.insitlau'
      ,rg_craplau.insitlau
      ,'3');
	  
	  
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
      ,1
      ,vr_nrsequen
      ,vr_dttransa
      ,vr_hrtransa
      ,2 --rg_craplau.nrdocmto
      ,'craplau.dtdebito'
      ,rg_craplau.dtdebito
      ,vr_dtmvtolt);
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