DECLARE
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(5);
  vr_dstransa   VARCHAR2(1000);
  vr_cdcooper   cecred.crapsld.cdcooper%type := 9;
  vr_nrdconta   cecred.crapsld.nrdconta%type := 18732;
  vr_vlsdblfp   cecred.crapsld.vlsdblfp%type;
 
BEGIN

  UPDATE CECRED.CRAPSLD s
     SET s.vlsdblfp = s.vlsdblfp - 287
   WHERE s.cdcooper = vr_cdcooper
     AND s.nrdconta = vr_nrdconta
  RETURNING s.vlsdblfp into vr_vlsdblfp;

  -- Insere log de atualização para a VERLOG.
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := to_char(sysdate,'SSSSS');
  vr_dstransa := 'Alterado valor do Saldo bloqueado Fora Praca em ' ||  
                 to_char(vr_dttransa,'dd/mm/yyyy') || 
                 ' ' ||
                 cecred.gene0002.fn_converte_time_data(vr_hrtransa) ||  
                 ' por script - INC0102666.';
    
  INSERT INTO cecred.craplgm(cdcooper
    ,nrdconta
    ,idseqttl
    ,dttransa
    ,hrtransa
    ,dstransa
    ,dsorigem
    ,nmdatela)
  VALUES
    (vr_cdcooper
    ,vr_nrdconta
    ,1
    ,vr_dttransa
    ,vr_hrtransa
    ,vr_dstransa
    ,'AIMARO'
    ,'CRAPSLD');
  --
  -- Insere log com valores de antes x depois da atualizacao do Saldo
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
    (vr_cdcooper
    ,vr_nrdconta
    ,1
    ,1
    ,vr_dttransa
    ,vr_hrtransa
    ,1
    ,'crapsld.vlsdblfp'
    ,vr_vlsdblfp + 287
    ,vr_vlsdblfp);
    --
     
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script de Atualizacao do Saldo Bloqueado Fora Praca - INC0102666');
END;
