DECLARE

  CURSOR cr_tbcc_port_recebe is 
    SELECT cdcooper
      , nrdconta
    , nrnu_portabilidade
      , idsituacao
    , dsdominio_motivo
    , cdmotivo
    , dtretorno
    , nmarquivo_solicitacao
    FROM cecred.tbcc_portabilidade_recebe
    WHERE nrdconta = 10740511
    AND nrnu_portabilidade = 202104220000183741932
    AND cdcooper = 1;
  --
  rg_tbcc_port_recebe cr_tbcc_port_recebe%rowtype;
  
  
  CURSOR cr_tbcc_port_erro is 
    SELECT dsdominio_motivo
       , cdmotivo  
       , nrnu_portabilidade 
    FROM cecred.tbcc_portabilidade_rcb_erros
    WHERE nrnu_portabilidade = 202104220000183741932;

  --
  rg_tbcc_port_erro cr_tbcc_port_erro%rowtype;
  
  --
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(10);
  vr_log_script VARCHAR2(8000);
  vr_dstransa   varchar2(1000);
  vr_vldcotas   NUMBER(25,2);
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_data       DATE;
  vr_capdev_ant NUMBER(15,2);
  vr_insere     CHAR(1);
  
   
BEGIN

  vr_log_script := ' ** Início script' || chr(10);
  
  OPEN cr_tbcc_port_recebe;
  LOOP
    FETCH cr_tbcc_port_recebe INTO rg_tbcc_port_recebe;
    EXIT WHEN cr_tbcc_port_recebe%NOTFOUND;
  
  vr_log_script := vr_log_script || chr(10) || 'Atualização da conta portabilidade: (' 
                     || '[ ' || LPAD(rg_tbcc_port_recebe.cdcooper, 2, ' ') || ' ] '
                     || LPAD(rg_tbcc_port_recebe.nrdconta, 9, ' ') || ') da situação (' || rg_tbcc_port_recebe.idsituacao
                     || ') para (5)';
    --
  vr_dstransa := 'Alterada situacao de conta portabilidade por script. INC0095333.';  
  
  vr_data:=to_date('22/04/2021 14:31:39','DD/MM/YYYY hh24:mi:ss');
  
  
  OPEN cr_tbcc_port_erro;
    FETCH cr_tbcc_port_erro INTO rg_tbcc_port_erro;
    CLOSE cr_tbcc_port_erro;
  
  
  -- Atualizar apenas um registro
  -- Realiza o cancelamento da Portabilidade.
  UPDATE tbcc_portabilidade_recebe t 
  SET t.idsituacao = 5 
  ,t.dsdominio_motivo = 'MOTVCANCELTPORTDDCTSALR'
  ,t.cdmotivo = '1'
  ,t.dtretorno = vr_data
  ,t.nmarquivo_solicitacao = 'APCS106_05463212_20210422_00061'
  WHERE t.nrdconta = 10740511
    AND t.nrnu_portabilidade = 202104220000183741932
  AND t.cdcooper = 1;
  
  
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
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
    -- Insere log com valores de antes x depois da tbcc_portabilidade_recebe.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,1
      ,'tbcc_portabilidade_recebe.idsituacao'
      ,rg_tbcc_port_recebe.idsituacao
      ,'5');
    --
    -- Insere log com valores de antes x depois da tbcc_portabilidade_recebe.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,2
      ,'tbcc_portabilidade_recebe.dsdominio_motivo'
      ,rg_tbcc_port_recebe.dsdominio_motivo
      ,'MOTVCANCELTPORTDDCTSALR'); 
    --
    -- Insere log com valores de antes x depois da tbcc_portabilidade_recebe.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,3
      ,'tbcc_portabilidade_recebe.cdmotivo'
      ,rg_tbcc_port_recebe.cdmotivo
      ,'1');
    --
    -- Insere log com valores de antes x depois da tbcc_portabilidade_recebe.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,4
      ,'tbcc_portabilidade_recebe.dtretorno'
      ,rg_tbcc_port_recebe.dtretorno
      ,to_char(vr_data, 'dd/mm/rrrr') );

    --
    -- Insere log com valores de antes x depois da tbcc_portabilidade_recebe.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,5
      ,'tbcc_portabilidade_recebe.nmarquivo_solicitacao'
      ,rg_tbcc_port_recebe.nmarquivo_solicitacao
      ,'APCS106_05463212_20210422_00061');

    -- 
    -- Eliminar apenas um registro.
    -- Eliminar o log do erro.
    DELETE tbcc_portabilidade_rcb_erros 
    WHERE nrnu_portabilidade = 202104220000183741932;
  
        
    --
    -- Insere log com valores de antes x depois da tbcc_portabilidade_rcb_erros.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,6
      ,'tbcc_portabilidade_rcb_erros.nrnu_portabilidade'
      ,rg_tbcc_port_erro.nrnu_portabilidade
      ,null);
    --
    -- Insere log com valores de antes x depois da tbcc_portabilidade_rcb_erros.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,7
      ,'tbcc_portabilidade_rcb_erros.dsdominio_motivo'
      ,rg_tbcc_port_erro.dsdominio_motivo
      ,null);
  --
    -- Insere log com valores de antes x depois da tbcc_portabilidade_rcb_erros.
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
      (rg_tbcc_port_recebe.cdcooper
      ,rg_tbcc_port_recebe.nrdconta
      ,1
      ,1
      ,vr_dttransa
      ,vr_hrtransa
      ,8
      ,'tbcc_portabilidade_rcb_erros.cdmotivo'
      ,rg_tbcc_port_erro.cdmotivo
      ,null);  
    
  END LOOP;
  
  CLOSE cr_tbcc_port_recebe;    
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