DECLARE
  --
  CURSOR cr_recarga_operacao is 
    SELECT idoperacao
      , cdcooper
	  , nrdconta
      , insit_operacao
    FROM CECRED.tbrecarga_operacao
    WHERE idoperacao = 1332242;
  --
  rg_recarga_operacao cr_recarga_operacao%rowtype;
  
  --
  vr_dttransa   DATE;
  vr_dtmvtolt   DATE;
  vr_hrtransa   VARCHAR2(5);
  vr_dstransa   VARCHAR2(1000);
  vr_log_script VARCHAR2(8000);
  vr_novasit    NUMBER(1);
  vr_capdev_ant NUMBER(15,2);
  vr_vldcotas   NUMBER(25,2);
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_insere     CHAR(1);
  
  --
  
BEGIN
  --
  vr_log_script := ' ** Início script' || chr(10);
  --
  OPEN cr_recarga_operacao;
  LOOP
    FETCH cr_recarga_operacao INTO rg_recarga_operacao;
    EXIT WHEN cr_recarga_operacao%NOTFOUND;
    --
    vr_log_script := vr_log_script || chr(10) || 'Atualização de registro: (' 
                     || '[ COOPERATIVA ' || LPAD(rg_recarga_operacao.cdcooper, 2, ' ') || ' , IDOPERACAO '
                     || LPAD(rg_recarga_operacao.idoperacao, 9, ' ') || ') da situação (' || rg_recarga_operacao.insit_operacao
                     || ') para (5) ]';
    --
    vr_dstransa := 'Alterada situacao da operacao por script. INC0107532.';
    --
   
    SELECT dtmvtolt
      INTO vr_dtmvtolt
    FROM crapdat 
    WHERE cdcooper = rg_recarga_operacao.cdcooper;
	
    --
    UPDATE CECRED.tbrecarga_operacao
        SET insit_operacao = 5
    WHERE cdcooper = rg_recarga_operacao.cdcooper
      AND idoperacao = rg_recarga_operacao.idoperacao; 
      --
           
    --
    -- Insere log de atualização para a VERLOG.
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := gene0002.fn_busca_time;

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
      (rg_recarga_operacao.cdcooper
      ,rg_recarga_operacao.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,vr_dstransa
      ,'AIMARO'
      ,'tbrecarga_op'
      ,1
      ,' '
      ,1
      ,to_char(rg_recarga_operacao.idoperacao));
    --
    -- Insere log com valores de antes x depois da tbrecarga_operacao.
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
      (rg_recarga_operacao.cdcooper
      ,rg_recarga_operacao.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,1
      ,'tbrecarga_operacao.insit_operacao'
      ,rg_recarga_operacao.insit_operacao
      ,'5');
    --
	--
  END LOOP;
  
  CLOSE cr_recarga_operacao;
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