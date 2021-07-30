DECLARE

  CURSOR cr_crapass_cop is
    SELECT distinct cdcooper
    FROM crapass
    WHERE trim(dtdemiss) is not null
      AND cdsitdct != 4
    ORDER BY cdcooper;
	
  rg_crapass_cop cr_crapass_cop%rowtype;
  

  CURSOR cr_crapass (pr_cdcooper number) is 
    SELECT cdcooper
	, nrdconta 
	, cdsitdct
	, progress_recid
    FROM crapass
    WHERE dtdemiss is not null
      AND cdsitdct <> 4
	  AND cdcooper = pr_cdcooper
    ORDER BY cdcooper, nrdconta;
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
  
  OPEN cr_crapass_cop;
  LOOP
    FETCH cr_crapass_cop INTO rg_crapass_cop;
    EXIT WHEN cr_crapass_cop%NOTFOUND;
  
  
	OPEN cr_crapass(rg_crapass_cop.cdcooper);
	LOOP
	  FETCH cr_crapass INTO rg_crapass;
	  EXIT WHEN cr_crapass%NOTFOUND;
	  
	  vr_log_script := 'Atualizacao da situacao da conta : (' 
						 || '[ ' || LPAD(rg_crapass.cdcooper, 2, ' ') || ' ] '
						 || LPAD(rg_crapass.nrdconta, 9, ' ') || ') da situacao (' || rg_crapass.cdsitdct
						 || ') para (4)';
		--
	  
	  vr_dstransa := 'Alterada situacao da conta por script. INC0097529.';  
	  
	  
	  -- Atualizar apenas um registro
	  -- Realiza atualização da situação da conta.
	  UPDATE cecred.crapass t 
	  SET t.cdsitdct = 4 
	  WHERE t.nrdconta = rg_crapass.nrdconta
		AND t.progress_recid = rg_crapass.progress_recid
		AND t.cdcooper = rg_crapass.cdcooper;
	  
	  	  
	  -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
		vr_dttransa := trunc(sysdate);
		vr_hrtransa := substr(to_char(systimestamp,'FF'),1,10);  -- to_char(sysdate,'SSSSS');

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
		  ,rg_crapass.progress_recid);
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
    
  END LOOP;
  
  CLOSE cr_crapass_cop;  
  
  --dbms_output.put_line(vr_log_script);
  
  --
  COMMIT;
  --
  --DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    
    --
END;