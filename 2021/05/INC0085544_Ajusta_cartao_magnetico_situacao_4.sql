DECLARE
  --
  CURSOR cr_crapcrm (pr_cdcooper number, pr_nrdconta number, pr_nrcartao number) is 
    SELECT cdcooper 
      , nrdconta
	  , nrcartao
      , cdsitcar
    FROM CECRED.CRAPCRM
    WHERE nrcartao = pr_nrcartao
	  and nrdconta = pr_nrdconta
	  and cdcooper = pr_cdcooper;
  --
  rg_crapcrm cr_crapcrm%rowtype;
  --
  
  vr_nrcartao CONSTANT NUMBER := 1004323002475961;
  vr_nrdconta CONSTANT NUMBER := 247596;
  vr_cdcooper CONSTANT NUMBER := 9;
  
  -- variáveis
  
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(5);
  vr_log_script VARCHAR2(8000);
  vr_dstransa   varchar2(1000);
  
  --
BEGIN
  --
  vr_log_script := ' ** Início script' || chr(10);
  --
  OPEN cr_crapcrm (vr_cdcooper, vr_nrdconta, vr_nrcartao);
  LOOP
    FETCH cr_crapcrm INTO rg_crapcrm;
    EXIT WHEN cr_crapcrm%NOTFOUND;
    --
    vr_log_script := vr_log_script || chr(10) || 'Atualização do cartao: (' 
                     || '[ ' || LPAD(rg_crapcrm.cdcooper, 2, ' ') || ' ] '
                     || LPAD(rg_crapcrm.nrcartao, 9, ' ') || ') da situação (' || rg_crapcrm.cdsitcar
                     || ') para (4)';
    --
    vr_dstransa := 'Alterada situacao do cartao por script. INC0085544.';
	
	-- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := to_char(sysdate,'SSSSS');
    --
    --
    -- Atualiza crapcrm
    UPDATE cecred.CRAPCRM
      SET cdsitcar = 3,
	      dtcancel = vr_dttransa
    WHERE nrcartao = rg_crapcrm.nrcartao
	  AND nrdconta = rg_crapcrm.nrdconta
      AND cdcooper = rg_crapcrm.cdcooper;
    --
    

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
      (rg_crapcrm.cdcooper
      ,rg_crapcrm.nrdconta
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
      (rg_crapcrm.cdcooper
      ,rg_crapcrm.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,1
      ,'crapcrm.cdsitcar'
      ,rg_crapcrm.cdsitcar
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
      (rg_crapcrm.cdcooper
      ,rg_crapcrm.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,2
      ,'crapcrm.dtcancel'
      ,null
      ,vr_dttransa );
    --
    
    --
  END LOOP;
  CLOSE cr_crapcrm;
  --
  -- dbms_output.put_line(vr_log_script);
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