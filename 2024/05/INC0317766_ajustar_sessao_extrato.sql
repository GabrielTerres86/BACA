DECLARE

  CURSOR cr_crapass IS
    SELECT ROWID dsdrowid
         , t.cdcooper
         , t.nrdconta
         , t.cdsecext
      FROM CECRED.crapass t
     WHERE NVL(t.cdsecext,0) = 0
       AND t.dtdemiss IS NULL;
  
  vr_nrdrowid     ROWID;
  
BEGIN

  FOR reg IN cr_crapass LOOP
    
    BEGIN
      UPDATE CECRED.crapass t
         SET t.cdsecext = 999
       WHERE ROWID = reg.dsdrowid;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001,'Erro ao atualizar conta ('||reg.dsdrowid||'): '||SQLERRM);
    END;
    
    INSERT INTO CECRED.craplgm(cdcooper
                             ,cdoperad
                             ,dscritic
                             ,dsorigem
                             ,dstransa
                             ,dttransa
                             ,flgtrans
                             ,hrtransa
                             ,idseqttl
                             ,nmdatela
                             ,nrdconta)
                       VALUES(reg.cdcooper
                             ,'1'
                             ,NULL
                             ,'AIMARO'
                             ,'Ajuste Secao para Extrato - Destino Extrato'
                             ,TRUNC(SYSDATE)
                             ,1
                             ,CECRED.GENE0002.fn_busca_time
                             ,0
                             ,NULL
                             ,reg.nrdconta)
                    RETURNING ROWID INTO vr_nrdrowid;
                      
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapass.cdsecext'
                                    ,pr_dsdadant => reg.cdsecext
                                    ,pr_dsdadatu => 999);

  END LOOP;

  COMMIT;

END;
