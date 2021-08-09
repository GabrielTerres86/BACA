DECLARE
  --
  CURSOR cr_crapass is 
    SELECT a.nrdconta
      , a.cdcooper
      , a.cdsitdct
	  , a.dtdemiss
	  , a.cdmotdem
    FROM CECRED.CRAPASS a
	inner join CONTACORRENTE.Tbcc_Conta_Incorporacao t
	on (t.cdcooper = a.cdcooper and t.nrdconta = a.nrdconta)
    WHERE ( a.cdcooper = 9
        and a.nrdconta IN (525979, 503665, 503673, 504297, 504572, 521396, 529133)
      );
	  
  rg_crapass cr_crapass%rowtype; 
	

  --
  vr_tbcotas_dev_cdcooper               NUMBER(5);
  vr_tbcotas_dev_nrdconta               NUMBER(10);
  vr_tbcotas_dev_tpdevolucao            NUMBER(1);
  vr_tbcotas_dev_vlcapital              NUMBER(15,2);
  vr_tbcotas_dev_qtparcelas             NUMBER(2);
  vr_tbcotas_dev_dtinicio_credito       DATE;
  vr_tbcotas_dev_vlpago                 NUMBER(15,2);
  
  --
  vr_dttransa            DATE;
  vr_hrtransa            VARCHAR2(10);
  vr_log_script          VARCHAR2(8000);
  vr_dstransa            VARCHAR2(1000);
  vr_dtmvtolt            DATE;
  vr_dtmvtolt_aplicada   DATE;
  vr_dtdemiss_ant        DATE;
  vr_nrdocmto            INTEGER;
  vr_nrseqdig            INTEGER;
  vr_vldcotas            NUMBER;
  vr_vldcotas_movtda     NUMBER;
  vr_vldcotas_crapcot    NUMBER;
  vr_exception           exception;
  --
BEGIN
  --
  vr_log_script := ' ** Início script' || chr(10);
  --
  FOR rg_crapass IN cr_crapass LOOP
    --
    vr_log_script := vr_log_script || chr(10) || 'Atualização da conta: (' 
                     || '[ ' || LPAD(rg_crapass.cdcooper, 2, ' ') || ' ] '
                     || LPAD(rg_crapass.nrdconta, 9, ' ') || ') da situação (' || rg_crapass.cdsitdct
                     || ') para (1)';
    --
    vr_dstransa := 'Alterada situacao de conta por script. INC0100990.';
    --
    -- Verificar o valor de cotas a devolver ao cooperado.
    vr_vldcotas := 0;
    --
	
	-- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := substr(to_char(systimestamp,'FF'),1,10);
	
    -- Atualiza crapass
    UPDATE CECRED.CRAPASS
      SET cdsitdct = 1,
          dtdemiss = NULL,
		  cdmotdem= 0
    WHERE nrdconta = rg_crapass.nrdconta
      AND cdcooper = rg_crapass.cdcooper;
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
      ,'1');
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
      ,rg_crapass.dtdemiss
      ,null);  
	
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
      ,3
      ,'crapass.cdmotdem'
      ,rg_crapass.cdmotdem
      ,'0');
	

    -- Buscar o valor das cotas em CRAPCOT
	 BEGIN
	    SELECT vldcotas
	      INTO vr_vldcotas_crapcot
        FROM CECRED.crapcot
        WHERE nrdconta = rg_crapass.nrdconta
          AND cdcooper = rg_crapass.cdcooper;		  
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN 
         
          dbms_output.put_line(chr(10) || 'Não encontrado registro em crapcot para conta ' || rg_crapass.nrdconta);
          --
     END;

	
	-- Buscar o valor das cotas em TBCOTAS_DEVOLUCAO
	 BEGIN
        SELECT VLCAPITAL
          INTO vr_vldcotas
        FROM CECRED.TBCOTAS_DEVOLUCAO
        WHERE nrdconta = rg_crapass.nrdconta
          AND cdcooper = rg_crapass.cdcooper;
        EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
          --
         
          dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO anterior para conta ' || rg_crapass.nrdconta);
          --
     END;
	
	
	--Buscar data de movimento da cooperativa
	 BEGIN
        SELECT dtmvtolt
          INTO vr_dtmvtolt
        FROM CECRED.crapdat
        WHERE cdcooper = rg_crapass.cdcooper;
        EXCEPTION 
         WHEN NO_DATA_FOUND THEN 
          --
          
          dbms_output.put_line(chr(10) || 'Não encontrado crapdat para cooperativa ' || rg_crapass.cdcooper);
          --
     END;
	
	
		
	--Buscar registro em TBCOTAS_DEVOLUCAO
	 BEGIN
	
	    SELECT cdcooper, nrdconta, tpdevolucao, vlcapital, qtparcelas, dtinicio_credito, vlpago
          INTO vr_tbcotas_dev_cdcooper, vr_tbcotas_dev_nrdconta, vr_tbcotas_dev_tpdevolucao,
               vr_tbcotas_dev_vlcapital, vr_tbcotas_dev_qtparcelas, vr_tbcotas_dev_dtinicio_credito, vr_tbcotas_dev_vlpago
	    FROM TBCOTAS_DEVOLUCAO
	    WHERE nrdconta = rg_crapass.nrdconta
          AND cdcooper = rg_crapass.cdcooper;
	    EXCEPTION 
          WHEN NO_DATA_FOUND THEN 
          --
          dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO para cooperativa e conta ' || rg_crapass.cdcooper||' '||rg_crapass.nrdconta);
          --
     END;
		
	vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';16;100;600040');
    vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';16;100;600040');
    
	
	
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
	
	
    -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := substr(to_char(systimestamp,'FF'),1,10);
	
	
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
	  
	
	
	-- Insere log com valores de antes x depois da craplct.
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
      ,'craplct.dtmvtolt'
      ,null
      ,vr_dtmvtolt);
    --
    -- Insere log com valores de antes x depois da craplct.
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
      ,'craplct.vllanmto'
      ,null
      ,vr_vldcotas);  
	
		
	
	UPDATE CECRED.crapcot
        SET vldcotas = ( vldcotas + vr_vldcotas )
      WHERE cdcooper = rg_crapass.cdcooper
        AND nrdconta = rg_crapass.nrdconta;
	
	
	-- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := substr(to_char(systimestamp,'FF'),1,10);
	
	
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
	  
		
	-- Insere log com valores de antes x depois da crapcot.
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
      ,'crapcot.vldcotas'
      ,vr_vldcotas_crapcot
      ,(vr_vldcotas_crapcot + vr_vldcotas) );
	
	
	
	-- Excluir registro conforme cooperativa e conta
	DELETE 
	FROM CECRED.TBCOTAS_DEVOLUCAO
    WHERE CDCOOPER = rg_crapass.cdcooper
      AND NRDCONTA = rg_crapass.nrdconta;

	
	-- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := substr(to_char(systimestamp,'FF'),1,10);
	
	
    
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
	  
		
	-- Insere log com valores de antes x depois da tbcotas_devolucao.
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
      ,'tbcotas_devolucao.cdcooper'
      ,vr_tbcotas_dev_cdcooper
      ,NULL );
    
	
	-- Insere log com valores de antes x depois da tbcotas_devolucao.
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
      ,'tbcotas_devolucao.nrdconta'
      ,vr_tbcotas_dev_nrdconta
      ,NULL );
	
	
	-- Insere log com valores de antes x depois da tbcotas_devolucao.
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
      ,'tbcotas_devolucao.tpdevolucao'
      ,vr_tbcotas_dev_tpdevolucao
      ,NULL );
	
	
	
	-- Insere log com valores de antes x depois da tbcotas_devolucao.
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
      ,'tbcotas_devolucao.vlcapital'
      ,vr_tbcotas_dev_vlcapital
      ,NULL );
	
	
	-- Insere log com valores de antes x depois da tbcotas_devolucao.
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
      ,5
      ,'tbcotas_devolucao.qtparcelas'
      ,vr_tbcotas_dev_qtparcelas
      ,NULL );
	
	
	-- Insere log com valores de antes x depois da tbcotas_devolucao.
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
      ,6
      ,'tbcotas_devolucao.dtinicio_credito'
      ,vr_tbcotas_dev_dtinicio_credito
      ,NULL );
	
	
	-- Insere log com valores de antes x depois da tbcotas_devolucao.
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
      ,7
      ,'tbcotas_devolucao.vlpago'
      ,vr_tbcotas_dev_vlpago
      ,NULL );
	
		
  END LOOP;
  
  COMMIT;
  --
  --dbms_output.put_line(vr_log_script);
  --
  --
  --DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN vr_exception THEN
    --
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, vr_log_script || CHR(10) || SQLERRM);
    --
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;