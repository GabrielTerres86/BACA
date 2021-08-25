DECLARE
  --
  CURSOR cr_crapass is 
    SELECT a.nrdconta
      , a.cdcooper
      , a.cdsitdct
      , a.dtdemiss
      , a.cdmotdem
      , a.dtelimin
    FROM CECRED.CRAPASS a
    WHERE ( a.cdcooper = 9
        and a.nrdconta IN (525979, 503665, 503673, 504297, 504572, 521396, 529133)
          );
    
  rg_crapass cr_crapass%rowtype;
  
  vr_dtmvtolt                           DATE;
  vr_nrdocmto                           INTEGER;
  vr_incrineg                           INTEGER;
  vr_cdcritic                           PLS_INTEGER;
  vr_dscritic                           VARCHAR2(200);
  vr_log_script                         VARCHAR2(8000);
  vr_tab_retorno                        lanc0001.typ_reg_retorno;
  vr_tbcotas_dev_cdcooper               NUMBER(5);
  vr_tbcotas_dev_nrdconta               NUMBER(10);
  vr_tbcotas_dev_tpdevolucao            NUMBER(1);
  vr_tbcotas_dev_vlcapital              NUMBER(15,2);
  vr_tbcotas_dev_qtparcelas             NUMBER(2);
  vr_tbcotas_dev_dtinicio_credito       DATE;
  vr_tbcotas_dev_vlpago                 NUMBER(15,2);
  vr_dttransa                           DATE;
  vr_hrtransa                           VARCHAR2(10);
  vr_exception                          exception;
  vr_dstransa                           VARCHAR2(1000);
  
  BEGIN
    vr_log_script := ' ** Início script' || chr(10); 
    vr_dstransa := 'Alterada situacao de conta por script. INC0102423.';
      
    FOR rg_crapass IN cr_crapass LOOP
        vr_log_script := vr_log_script || chr(10) || 'Atualização da conta: (' 
                         || '[ ' || LPAD(rg_crapass.cdcooper, 2, ' ') || ' ] '
                         || LPAD(rg_crapass.nrdconta, 9, ' ') || ') da situação (' || rg_crapass.cdsitdct
                         || ') para (1)';
                         
        vr_dttransa := trunc(sysdate);
        vr_hrtransa := GENE0002.fn_busca_time;
        
        
        --Buscar data de movimento da cooperativa
        BEGIN
                 SELECT dtmvtolt
                 INTO vr_dtmvtolt
                 FROM CECRED.crapdat
                 WHERE cdcooper = rg_crapass.cdcooper;
                 EXCEPTION 
                       WHEN NO_DATA_FOUND THEN           
                            dbms_output.put_line(chr(10) || 'Não encontrado crapdat para cooperativa ' || rg_crapass.cdcooper);

        END;
        
        
        UPDATE CECRED.CRAPASS
        SET dtelimin = NULL    
        WHERE nrdconta = rg_crapass.nrdconta
        AND cdcooper = rg_crapass.cdcooper;
        
        --Insere log de alteração dos dados do cooperado
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
        
        --Insere log de alteração do campo dtelimin da crapass
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
        ,'crapass.dtelimin'
        ,rg_crapass.dtelimin
        ,null);
        
        --Buscar registro em TBCOTAS_DEVOLUCAO
        BEGIN  
                 SELECT cdcooper, nrdconta, tpdevolucao, vlcapital, qtparcelas, dtinicio_credito, vlpago
                  INTO vr_tbcotas_dev_cdcooper, vr_tbcotas_dev_nrdconta, vr_tbcotas_dev_tpdevolucao,
                  vr_tbcotas_dev_vlcapital, vr_tbcotas_dev_qtparcelas, vr_tbcotas_dev_dtinicio_credito, vr_tbcotas_dev_vlpago
                 FROM TBCOTAS_DEVOLUCAO
                 WHERE nrdconta = rg_crapass.nrdconta
                  AND cdcooper = rg_crapass.cdcooper
                  AND TPDEVOLUCAO = 4 AND VLCAPITAL > 0;
                 EXCEPTION 
                 WHEN NO_DATA_FOUND THEN 
                      Continue;                                    
        END;
        
        vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';28;100;600040');
        
        -- Efetua o crédito da cota em capital disponivel
        lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => vr_dtmvtolt,
                                           pr_cdagenci    => 1,
                                           pr_cdbccxlt    => 100,
                                           pr_nrdolote    => 4598,
                                           pr_nrdconta    => rg_crapass.nrdconta,
                                           pr_nrdocmto    => vr_nrdocmto,
                                           pr_cdhistor    => 3636,
                                           pr_vllanmto    => vr_tbcotas_dev_vlcapital,
                                           pr_nrdctabb    => rg_crapass.nrdconta,
                                           pr_cdcooper    => rg_crapass.cdcooper,
                                           pr_inprolot    => 1,
                                           pr_tab_retorno => vr_tab_retorno,
                                           pr_incrineg    => vr_incrineg,
                                           pr_cdcritic    => vr_cdcritic,
                                           pr_dscritic    => vr_dscritic);
                                           
        -- Remove o valor de cotas a devolver
        DELETE
        FROM CECRED.TBCOTAS_DEVOLUCAO
        WHERE CDCOOPER = rg_crapass.cdcooper
        AND NRDCONTA = rg_crapass.nrdconta
        AND TPDEVOLUCAO = 4;
        
        -- Insere log com valores de antes x depois da tbcotas_devolucao campo cdcooper.
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
          ,'tbcotas_devolucao.cdcooper'
          ,vr_tbcotas_dev_cdcooper
          ,NULL );
      
      
        -- Insere log com valores de antes x depois da tbcotas_devolucao campo nrdconta.
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
          ,'tbcotas_devolucao.nrdconta'
          ,vr_tbcotas_dev_nrdconta
          ,NULL );      
      
        -- Insere log com valores de antes x depois da tbcotas_devolucao campo tpdevolucao.
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
          ,'tbcotas_devolucao.tpdevolucao'
          ,vr_tbcotas_dev_tpdevolucao
          ,NULL );        
      
        -- Insere log com valores de antes x depois da tbcotas_devolucao campo vlcapital.
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
          ,'tbcotas_devolucao.vlcapital'
          ,vr_tbcotas_dev_vlcapital
          ,NULL );      
      
        -- Insere log com valores de antes x depois da tbcotas_devolucao campo qtdparcelas.
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
          ,'tbcotas_devolucao.qtparcelas'
          ,vr_tbcotas_dev_qtparcelas
          ,NULL );      
      
        -- Insere log com valores de antes x depois da tbcotas_devolucao campo dtinicio_credito.
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
          ,'tbcotas_devolucao.dtinicio_credito'
          ,vr_tbcotas_dev_dtinicio_credito
          ,NULL);      
      
        -- Insere log com valores de antes x depois da tbcotas_devolucao campo vlpago.
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
          ,'tbcotas_devolucao.vlpago'
          ,vr_tbcotas_dev_vlpago
          ,NULL);
         
    END LOOP;
    
--    COMMIT;    
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
