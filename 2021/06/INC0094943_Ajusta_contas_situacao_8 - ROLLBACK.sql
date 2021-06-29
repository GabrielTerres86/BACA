DECLARE
  -- 
  CURSOR cr_craplgm IS
    SELECT lgm.cdcooper
      , lgm.nrdconta
      , lgm.idseqttl
      , lgm.nrsequen
      , lgm.dttransa
      , lgm.hrtransa
      , lgm.dstransa
    FROM CECRED.CRAPLGM LGM
    WHERE dstransa LIKE 'INC0094943 - Conta alterada para situacao 8.%'
      AND 
      ( cdcooper = 1 -- VIACRED
        and nrdconta   IN (8149186,10754423,9119736,7236450,10246940,10910735,9831312,10801634,10134298,10418121,9964134,10070311,9638288,10537970,10768190,10814507,
7943083,10116877,10764097,10056378,10770453,10656570,10777377,9514481)
      )
    order by cdcooper, nrdconta;
  --
  rg_craplgm cr_craplgm%ROWTYPE;
  --
  CURSOR cr_craplgi (pr_cdcooper    NUMBER
              , pr_nrdconta  NUMBER
              , pr_idseqttl  NUMBER
              , pr_nrsequen  NUMBER
              , pr_dttransa  DATE
              , pr_hrtransa  NUMBER
              , pr_nmdcampo  VARCHAR2 ) IS
    SELECT lgi.nrdconta
      , lgi.cdcooper
      , lgi.dsdadant
      , lgi.dsdadatu 
      , lgi.nmdcampo
    FROM CECRED.CRAPLGI LGI
    WHERE lgi.nmdcampo = pr_nmdcampo
      and lgi.idseqttl = pr_idseqttl
      and lgi.nrsequen = pr_nrsequen
      and lgi.hrtransa = pr_hrtransa
      and lgi.dttransa = pr_dttransa
      and cdcooper     = pr_cdcooper
      and nrdconta     = pr_nrdconta;
  --
  rg_craplgi cr_craplgi%ROWTYPE;
  --
  vr_dtmvtolt_aplicada   date;
  vr_vldcotas_movtda     NUMBER;
  vr_log_script          VARCHAR2(8000);
  vr_exception           exception;
  vr_qtatremvlgi         NUMBER;
  
  --
BEGIN
  --
  dbms_output.enable(null);
  vr_log_script := ' ** Início script' || chr(10);
  --
  OPEN cr_craplgm;
  LOOP
    FETCH cr_craplgm INTO rg_craplgm;
    EXIT WHEN cr_craplgm%NOTFOUND;
    --
    vr_dtmvtolt_aplicada := rg_craplgm.dttransa;

    --
    OPEN cr_craplgi(pr_cdcooper    => rg_craplgm.cdcooper
                    , pr_nrdconta  => rg_craplgm.nrdconta
                    , pr_idseqttl  => rg_craplgm.idseqttl
                    , pr_nrsequen  => rg_craplgm.nrsequen
                    , pr_dttransa  => rg_craplgm.dttransa
                    , pr_hrtransa  => rg_craplgm.hrtransa
                    , pr_nmdcampo  => 'cdsitdct' );
    FETCH cr_craplgi INTO rg_craplgi;
    CLOSE cr_craplgi;
    --
    vr_log_script := vr_log_script || chr(10) || chr(10) || 'ROLL BACK da atualização da conta: (' 
                     || rg_craplgm.cdcooper || ' - ' || rg_craplgm.nrdconta 
                     || ') restaurando dado anterior  (' || rg_craplgi.dsdadant
                     || ').';
    --
    -- Atualiza crapass
    UPDATE CECRED.CRAPASS
      -- Em processo de demissão BACEN
      SET cdsitdct = rg_craplgi.dsdadant
    WHERE nrdconta = rg_craplgm.nrdconta
      AND cdcooper = rg_craplgm.cdcooper;
    --
    -- Retornando valor das cotas
    --
    OPEN cr_craplgi(pr_cdcooper    => rg_craplgm.cdcooper
                    , pr_nrdconta  => rg_craplgm.nrdconta
                    , pr_idseqttl  => rg_craplgm.idseqttl
                    , pr_nrsequen  => rg_craplgm.nrsequen
                    , pr_dttransa  => rg_craplgm.dttransa
                    , pr_hrtransa  => rg_craplgm.hrtransa
                    , pr_nmdcampo  => 'crapcot.vldcotas' );
    FETCH cr_craplgi INTO rg_craplgi;
    --
    IF cr_craplgi%FOUND THEN
      --
      -- Pega o valor de cota movimentado para fazer a transação oposta.
      vr_vldcotas_movtda := to_number(rg_craplgi.dsdadant);
      --
      -- logs
      vr_log_script := vr_log_script || chr(10) || 'Valor de cota para movimentar: ' || vr_vldcotas_movtda
                       || chr(10) || 'Data para remover CRAPLCT: ' || vr_dtmvtolt_aplicada;
      --
      -- Antes removeu o valor de cota, agora tem que adicionar novamente.
      UPDATE crapcot
        SET vldcotas = ( vldcotas + vr_vldcotas_movtda )
      WHERE cdcooper = rg_craplgm.cdcooper
        AND nrdconta = rg_craplgm.nrdconta;
      --
      vr_log_script := vr_log_script || chr(10) || '(' || SQL%ROWCOUNT || ') Devolvendo para CRAPCOT: R$ ' || vr_vldcotas_movtda;
      --
      -- Remove o valor de cota capital dos valores a devolver - TBCOTAS_DEVOLUCAO
      -- Antes adicionou valor no saldo de cotas para devolver. Agora tem que remover este valor
      UPDATE TBCOTAS_DEVOLUCAO
        SET VLCAPITAL = ( VLCAPITAL - vr_vldcotas_movtda )
      WHERE CDCOOPER = rg_craplgm.cdcooper
        AND NRDCONTA = rg_craplgm.nrdconta
        AND TPDEVOLUCAO = 3;
      --
      vr_log_script := vr_log_script || chr(10) || '(' || SQL%ROWCOUNT || ') Removendo da TBCOTAS_DEVOLUCAO: R$ ' || vr_vldcotas_movtda;
      --
      -- Desfaz o lançamento criado anteriormente na craplct
      DELETE cecred.CRAPLCT
      WHERE CDCOOPER                              = rg_craplgm.cdcooper
        and NRDCONTA                              = rg_craplgm.nrdconta
        and to_date(DTMVTOLT, 'dd/mm/rrrr')       = vr_dtmvtolt_aplicada
        AND vllanmto                              = vr_vldcotas_movtda
        and CDAGENCI                              = 16
        and CDBCCXLT                              = 100
        and NRDOLOTE                              = 600040;
      --
      vr_log_script := vr_log_script || chr(10) || '(' || SQL%ROWCOUNT || ') Removendo REGISTRO da CRAPLCT.';
      --
      -- Garante que apenas um registro foi removido da CRAPLCT.
      IF SQL%ROWCOUNT > 1 THEN 
        --
        vr_log_script := vr_log_script || chr(10) || 'ERRO AO DELETAR CRAPLCT. Total de Linhas para DELETE: ' 
                         || SQL%ROWCOUNT || ' onde deveria ser apenas uma.';
        --
        RAISE vr_exception;
        --
      END IF;
      --
      vr_log_script := vr_log_script || chr(10) || 'Total de Linhas removidas da CRAPLCT: ' || SQL%ROWCOUNT;
      --
      --
    END IF;
    --
    CLOSE cr_craplgi;
    --
    -- Deleta log de atualização.
    DELETE cecred.craplgm lgm
    WHERE lgm.cdcooper = rg_craplgm.cdcooper
      and lgm.nrdconta = rg_craplgm.nrdconta
      and lgm.idseqttl = rg_craplgm.idseqttl
      and lgm.nrsequen = rg_craplgm.nrsequen
      and lgm.dttransa = rg_craplgm.dttransa
      and lgm.hrtransa = rg_craplgm.hrtransa
      and lgm.dstransa = rg_craplgm.dstransa;
    --
    IF SQL%ROWCOUNT > 1 THEN 
      --
      vr_log_script := vr_log_script || chr(10) || 'ERRO AO DELETAR CRAPLGM. Total de Linhas para DELETE: ' 
                       || SQL%ROWCOUNT || ' onde deveria ser apenas uma.';
      --
      RAISE vr_exception;
      --
    END IF;
    --
    vr_log_script := vr_log_script || chr(10) || 'Total de Linhas removidas da CRAPLGM: ' || SQL%ROWCOUNT;
    --
    
	vr_qtatremvlgi :=0;
	
	BEGIN
	
	   SELECT count(*) into vr_qtatremvlgi
       FROM CECRED.craplgi lgi
       WHERE lgi.cdcooper = rg_craplgm.cdcooper
         and lgi.nrdconta = rg_craplgm.nrdconta
         and lgi.idseqttl = rg_craplgm.idseqttl
         and lgi.nrsequen = rg_craplgm.nrsequen
         and lgi.dttransa = rg_craplgm.dttransa
         and lgi.hrtransa = rg_craplgm.hrtransa;
		 
	   EXCEPTION
         WHEN OTHERS THEN	
           RAISE vr_exception;		 
	END;	
	
	-- Deleta log com valores de antes x depois.
    DELETE cecred.craplgi lgi
    WHERE lgi.cdcooper = rg_craplgm.cdcooper
      and lgi.nrdconta = rg_craplgm.nrdconta
      and lgi.idseqttl = rg_craplgm.idseqttl
      and lgi.nrsequen = rg_craplgm.nrsequen
      and lgi.dttransa = rg_craplgm.dttransa
      and lgi.hrtransa = rg_craplgm.hrtransa
      -- and lgi.nmdcampo = rg_craplgi.nmdcampo
      ;
    --
    IF SQL%ROWCOUNT > vr_qtatremvlgi THEN 
      --
      vr_log_script := vr_log_script || chr(10) || 'ERRO AO DELETAR CRAPLGI. Total de Linhas para DELETE: ' 
                       || SQL%ROWCOUNT || ' onde deveria ser no máximo três.';
      --
      RAISE vr_exception;
      --
    END IF;
    --
    --
    vr_log_script := vr_log_script || chr(10) || 'Total de Linhas removidas da CRAPLGI: ' || SQL%ROWCOUNT;
    --
  END LOOP;
  CLOSE cr_craplgm;
  --
  -- dbms_output.put_line(vr_log_script);
  --
  COMMIT;
  --
  -- DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
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