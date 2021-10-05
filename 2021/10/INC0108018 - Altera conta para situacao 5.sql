DECLARE
  --
  CURSOR cr_crapass is 
    SELECT a.nrdconta
      , a.cdcooper
      , a.cdsitdct
	  , a.dtdemiss
	  , a.cdmotdem
    FROM CECRED.CRAPASS a
    WHERE a.cdcooper = 9
      AND a.nrdconta = 7838;
	  
  rg_crapass cr_crapass%rowtype; 
	

  CURSOR cr_craplct is 
    SELECT  a.dtmvtolt,
	  a.cdagenci,
	  a.cdbccxlt,
	  a.nrdolote,
	  a.nrdconta,
	  a.nrdocmto,
	  a.cdhistor,
	  a.nrseqdig,
	  a.vllanmto,
	  a.nrctrpla,
	  a.qtlanmfx,
	  a.nrautdoc,
	  a.nrsequni,
	  a.cdcooper,
	  a.cdageori
    FROM CECRED.CRAPLCT a
	WHERE a.cdcooper = 9
      AND a.nrdconta = 7838;
	  
  rg_craplct cr_craplct%rowtype;

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
  
  vr_qtde_tb_devolucao   NUMBER;
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
                     || ') para (5)';
    --
    vr_dstransa := 'Alterada situacao de conta por script. INC0108018.';
    --
    -- Verificar o valor de cotas a devolver ao cooperado.
    vr_vldcotas := 0;
    --
	vr_qtde_tb_devolucao:=0;
	--
	-- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := GENE0002.fn_busca_time;
	
	-- carrega registro craplct
	OPEN cr_craplct;
    FETCH cr_craplct INTO rg_craplct;
	CLOSE cr_craplct;
	
    -- Atualiza crapass
    UPDATE CECRED.CRAPASS
      SET cdsitdct = 5,
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
          AND cdcooper = rg_crapass.cdcooper
          AND TPDEVOLUCAO = 3;
	    EXCEPTION 
          WHEN NO_DATA_FOUND THEN 
          --
          dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO para cooperativa e conta ' || rg_crapass.cdcooper||' '||rg_crapass.nrdconta);
          Continue;
          --
     END;
		
	vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';28;100;600040');
    vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';28;100;600040');   
	
		
    DELETE 
	FROM CECRED.craplct
	WHERE nrdolote = rg_craplct.nrdolote
	  AND cdhistor = rg_craplct.cdhistor
	  AND dtmvtolt = to_date(rg_craplct.dtmvtolt,'DD/MM/YYYY')
	  AND nrdconta = rg_craplct.nrdconta
	  AND cdcooper = rg_craplct.cdcooper;
	  
  	
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
      ,4
      ,'rg_craplct.dtmvtolt'
      ,rg_craplct.dtmvtolt
      ,null);
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
      ,5
      ,'rg_craplct.cdagenci'
      ,rg_craplct.cdagenci
      ,null);  
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
      ,6
      ,'rg_craplct.cdbccxlt'
      ,rg_craplct.cdbccxlt
      ,null);
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
      ,7
      ,'rg_craplct.nrdolote'
      ,rg_craplct.nrdolote
      ,null);
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
      ,8
      ,'rg_craplct.nrdconta'
      ,rg_craplct.nrdconta
      ,null);
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
      ,9
      ,'rg_craplct.nrdocmto'
      ,rg_craplct.nrdocmto
      ,null);
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
      ,10
      ,'rg_craplct.cdhistor'
      ,rg_craplct.cdhistor
      ,null);
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
      ,11
      ,'rg_craplct.nrseqdig'
      ,rg_craplct.nrseqdig
      ,null);
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
      ,12
      ,'rg_craplct.vllanmto'
      ,rg_craplct.vllanmto
      ,null);
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
      ,13
      ,'rg_craplct.nrctrpla'
      ,rg_craplct.nrctrpla
      ,null);
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
      ,14
      ,'rg_craplct.qtlanmfx'
      ,rg_craplct.qtlanmfx
      ,null);
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
      ,15
      ,'rg_craplct.nrautdoc'
      ,rg_craplct.nrautdoc
      ,null);
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
      ,16
      ,'rg_craplct.nrsequni'
      ,rg_craplct.nrsequni
      ,null);
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
      ,17
      ,'rg_craplct.cdcooper'
      ,rg_craplct.cdcooper
      ,null);
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
      ,18
      ,'rg_craplct.cdageori'
      ,rg_craplct.cdageori
      ,null);

	
	UPDATE CECRED.crapcot
        SET vldcotas = ( vldcotas + vr_tbcotas_dev_vlcapital )
      WHERE cdcooper = rg_crapass.cdcooper
        AND nrdconta = rg_crapass.nrdconta;
	
		  
		
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
      ,19
      ,'crapcot.vldcotas'
      ,vr_vldcotas_crapcot
      ,(vr_vldcotas_crapcot + vr_tbcotas_dev_vlcapital) );
		
		-- Excluir registro conforme cooperativa e conta
		DELETE 
		FROM CECRED.TBCOTAS_DEVOLUCAO
		WHERE CDCOOPER = rg_crapass.cdcooper
		  AND NRDCONTA = rg_crapass.nrdconta
          AND TPDEVOLUCAO = 3;
		 
			
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
		  ,20
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
		  ,21
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
		  ,22
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
		  ,23
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
		  ,24
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
		  ,25
		  ,'tbcotas_devolucao.dtinicio_credito'
		  ,vr_tbcotas_dev_dtinicio_credito
		  ,NULL);
		
		
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
		  ,26
		  ,'tbcotas_devolucao.vlpago'
		  ,vr_tbcotas_dev_vlpago
		  ,NULL);
		  	
  END LOOP;
  
  COMMIT;
  --
  -- DBMS_OUTPUT.PUT_LINE(vr_log_script);
  --
  --
  DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
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
