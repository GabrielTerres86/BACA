DECLARE
  
  --
  CURSOR cr_crapcot (p_nrdconta   NUMBER
                     , p_cdcooper number) is
    select vldcotas
    from crapcot
    where cdcooper = p_cdcooper
      and nrdconta = p_nrdconta;
  --
  
  
  
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(5);
  vr_log_script VARCHAR2(4000);
  vr_vldcotas   NUMBER(25,2);
  vr_dstransa   VARCHAR2(1000);
  vr_capdev_ant NUMBER(15,2);
  vr_dtdemiss_ant DATE;
  vr_dtelimin_ant DATE;
  vr_dtasitct_ant DATE;
  vr_cdmotdem_ant NUMBER(5);
  vr_insere     CHAR(1);
  vr_dtmvtolt   DATE;
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_cdcooper   NUMBER(1);
  vr_cdsitdct   NUMBER(1);
  vr_tppessoa   NUMBER(1);
  vr_cdhistor   NUMBER(4);
  vr_cdhistorenc  NUMBER(4);
  vr_cdcritic   NUMBER(5);
  vr_cdagenci   NUMBER(5);
  vr_vllimcre   NUMBER(25,2);
  vr_vlsddisp   NUMBER(25,2);
  vr_dscritic   VARCHAR2(1000);
  
  vr_clob            CLOB;
  vr_clob_line       VARCHAR2(4000);
  vr_clob_line_count NUMBER;
  vr_delimitador     NUMBER;
  vr_nrdconta        NUMBER;
  vr_registros       NUMBER;
  vr_index           NUMBER;
  vr_data_demissao   VARCHAR2(10);
  vr_des_reto        VARCHAR2(3);
  --
  
  rw_crapdat  CECRED.BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_sald CECRED.EXTR0001.typ_tab_saldos;
  vr_tab_erro CECRED.GENE0001.typ_tab_erro;
  vr_tab_retorno  lanc0001.typ_reg_retorno;
  vr_incrineg     NUMBER;
  vr_rowid        ROWID;
  
  -- Tratamento de erros
  vr_exc_lanc_conta               EXCEPTION;
  vr_exc_sem_registro_bloq        EXCEPTION;
  vr_exc_par_vazio                EXCEPTION;
  vr_exc_sem_data_cooperativa     EXCEPTION;
  vr_exc_associados               EXCEPTION;
  vr_exc_saldo                    EXCEPTION;
  --
BEGIN
  --
  vr_log_script := ' ** Início script' || chr(10);
  --
  
  -- TRANSPORCRED
  vr_cdcooper:=9;
  
  -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := gene0002.fn_busca_time;
  
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
vr_clob := '502480;30/11/2018
502553;04/06/2021
502561;04/06/2021
502790;04/06/2021
502804;04/06/2021
502812;04/06/2021
502839;07/06/2021
502863;07/06/2021
508110;18/11/2012
505340;04/06/2021
505633;10/06/2021
505641;10/06/2021
505650;10/06/2021
505668;10/06/2021
505676;10/06/2021
530972;22/08/2017
531014;31/05/2021
533343;31/05/2021
533475;30/12/2016';
 
 vr_clob_line_count := length(vr_clob) - nvl(length(replace(vr_clob,chr(10))),0) + 1;
 
 -- buscar a data de movimentação da cooperativa
 OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat INTO rw_crapdat;

   -- Se nao encontrar
   IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE cecred.btch0001.cr_crapdat;
      raise vr_exc_sem_data_cooperativa;
   ELSE
      CLOSE cecred.btch0001.cr_crapdat;
   END IF;

 vr_dtmvtolt:=rw_crapdat.dtmvtolt;
     
 
 FOR vr_indice IN 1.. vr_clob_line_count LOOP
   
   BEGIN
  
    vr_registros :=vr_indice;
  
    vr_clob_line :=regexp_substr(vr_clob,'^.*$',1,vr_indice,'m');
  
    vr_delimitador :=instr(vr_clob_line,';');
  
    vr_nrdconta :=substr(vr_clob_line,1,vr_delimitador - 1);
  
    vr_data_demissao :=substr(vr_clob_line,vr_delimitador + 1, 10);
  
    
  vr_cdsitdct:=NULL;
  vr_tppessoa:=NULL;
  vr_cdagenci:=NULL; 
  vr_vllimcre:=NULL; 
  vr_dtdemiss_ant:=NULL; 
  vr_cdmotdem_ant:=NULL;
  vr_dtelimin_ant:=NULL;
  vr_dtasitct_ant:=NULL;
  
  -- Verificando a situação da conta
    
  BEGIN 
    
      SELECT cdsitdct, inpessoa, cdagenci, vllimcre, dtdemiss, cdmotdem, dtelimin, dtasitct
        into vr_cdsitdct, vr_tppessoa, vr_cdagenci, vr_vllimcre, vr_dtdemiss_ant, vr_cdmotdem_ant, vr_dtelimin_ant, vr_dtasitct_ant
      FROM cecred.crapass
      WHERE nrdconta = vr_nrdconta
        AND cdcooper = vr_cdcooper;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vr_cdsitdct:=NULL;
        WHEN OTHERS THEN
        raise vr_exc_associados;
  END;
          
    
  IF (vr_cdsitdct is not null) and (vr_cdsitdct != 4) THEN  
  
      vr_dstransa := 'Alteradas contas para situacao 4 INC0103839.%';
      
      -- Obter saldo do dia
        cecred.EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper
                   ,pr_rw_crapdat => rw_crapdat
                   ,pr_cdagenci   => vr_cdagenci
                   ,pr_nrdcaixa   => 0 -- pr_nrdcaixa
                   ,pr_cdoperad   => 1 -- pr_cdoperad
                   ,pr_nrdconta   => vr_nrdconta
                   ,pr_vllimcre   => vr_vllimcre
                   ,pr_dtrefere   => vr_dtmvtolt
                   ,pr_flgcrass   => FALSE --pr_flgcrass  -- true
                   ,pr_tipo_busca => 'A' -- pr_tipo_busca -- pode ser A, I, P
                   ,pr_des_reto   => vr_des_reto
                   ,pr_tab_sald   => vr_tab_sald
                   ,pr_tab_erro   => vr_tab_erro);

        IF vr_des_reto = 'OK' THEN
         IF vr_tab_sald.count() > 0 THEN
          begin
           vr_index    := vr_tab_sald.first();
           vr_vlsddisp := vr_tab_sald(vr_index).vlsddisp;
          end;
         END IF;
        ELSE
         IF vr_tab_erro.count() > 0 THEN
         begin
           vr_index    := vr_tab_erro.first();
           vr_cdcritic := vr_tab_erro(vr_index).cdcritic;
           vr_dscritic := vr_tab_erro(vr_index).dscritic;
           raise vr_exc_saldo;
         end;
         END IF;

        END IF;
      
      
      -- verifica se a conta é PF E PJ, e define o códigos dos históricos
         
      IF vr_tppessoa = 1 THEN
        BEGIN
           vr_cdhistor:=2079;
           vr_cdhistorenc:=2061;
          END;
        ELSIF vr_tppessoa = 2 THEN
         BEGIN
            vr_cdhistor:=2080;
            vr_cdhistorenc:=2062;
         END;
        END IF;
      --
      
      -- se o saldo for positivo, debita valor
      IF vr_vlsddisp > 0 THEN
      
         vr_capdev_ant := 0;
         vr_insere     := 'N';
        
         cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper => vr_cdcooper
                                         , pr_dtmvtolt => vr_dtmvtolt
                                         , pr_cdagenci => vr_cdagenci
                                         , pr_cdbccxlt => 1 --rw_craplot_rvt.cdbccxlt
                                         , pr_nrdolote => 37000 --vr_nrdolote --rw_craplot_rvt.nrdolote
                                         , pr_nrdctabb => vr_nrdconta
                                         , pr_nrdocmto => vr_nrdconta || vr_cdcooper
                                         , pr_cdhistor => vr_cdhistorenc

                                         , pr_vllanmto => vr_vlsddisp
                                         , pr_nrdconta => vr_nrdconta
                                         , pr_hrtransa => gene0002.fn_busca_time --TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                         , pr_nrdctitg => TO_CHAR(gene0002.fn_mask(vr_nrdconta,'99999999'))
                                         , pr_cdorigem => 0 --pr_idorigem
                                         , pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                         --, pr_tplotmov  => 1
                                         , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                         , pr_incrineg  => vr_incrineg      -- OUT Indicador de cr?tica de neg?cio
                                         , pr_cdcritic  => vr_cdcritic      -- OUT
                                         , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lan?amento (CRAPLCM, conta transit?ria, etc)
  
           
      
            IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                     raise vr_exc_lanc_conta;
                  ELSE
                BEGIN
              SELECT VLCAPITAL
                 into vr_capdev_ant
              FROM CECRED.TBCOTAS_DEVOLUCAO
              WHERE TPDEVOLUCAO = 4
                AND cdcooper = vr_cdcooper
                AND nrdconta = vr_nrdconta;
                EXCEPTION 
                WHEN no_data_found THEN
               BEGIN
                     vr_capdev_ant := 0;
                     dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO anterior para conta ' || vr_nrdconta);
                     vr_insere := 'S';
               END;
              END;  

                    IF vr_insere = 'S' THEN
            --
              INSERT INTO CECRED.TBCOTAS_DEVOLUCAO
              ( cdcooper, 
                nrdconta, 
                tpdevolucao, 
                vlcapital, 
                qtparcelas, 
                dtinicio_credito, 
                vlpago)
              VALUES 
             ( vr_cdcooper, 
             vr_nrdconta, 
             4, 
             vr_vlsddisp, 
             1, 
             null, 
             0);
             --
             dbms_output.put_line('inserindo na TBCOTAS_DEVOLUCAO (' || vr_cdcooper || ') ' || vr_nrdconta);
            --
              ELSE 
              -- Adiciona valor de cota capital para devolução.
              UPDATE CECRED.TBCOTAS_DEVOLUCAO
                SET VLCAPITAL = VLCAPITAL + vr_vlsddisp
              WHERE CDCOOPER = vr_cdcooper
                AND NRDCONTA = vr_nrdconta
               AND TPDEVOLUCAO = 4;
              END IF;
          
          END IF;   
            
      END IF;
      
      
      -- Verificar o valor de cotas a devolver ao cooperado.
      vr_vldcotas := 0;
      --
      OPEN cr_crapcot(vr_nrdconta
              , vr_cdcooper);
      FETCH cr_crapcot into vr_vldcotas;
      CLOSE cr_crapcot;
      --
            
      --
      IF NVL(vr_vldcotas, 0) > 0 THEN 
        --
        vr_capdev_ant := 0;
        vr_insere     := 'N';
        --
        BEGIN
        SELECT VLCAPITAL
          into vr_capdev_ant
        FROM CECRED.TBCOTAS_DEVOLUCAO
        where TPDEVOLUCAO = 3
          and cdcooper = vr_cdcooper
          and nrdconta = vr_nrdconta;
        EXCEPTION 
        WHEN no_data_found THEN
          vr_capdev_ant := 0;
          dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO anterior para conta ' || vr_nrdconta);
          vr_insere := 'S';
        END;
        
        --
        IF vr_insere = 'S' THEN
        --
        INSERT INTO CECRED.TBCOTAS_DEVOLUCAO
        ( cdcooper, 
          nrdconta, 
          tpdevolucao, 
          vlcapital, 
          qtparcelas, 
          dtinicio_credito, 
          vlpago)
        VALUES 
          ( vr_cdcooper, 
          vr_nrdconta, 
          3, 
          vr_vldcotas, 
          1, 
          null, 
          0);
        --
        dbms_output.put_line('inserindo na TBCOTAS_DEVOLUCAO (' || vr_cdcooper || ') ' || vr_nrdconta);
        --
        ELSE 
        -- Adiciona valor de cota capital para devolução.
        UPDATE CECRED.TBCOTAS_DEVOLUCAO
          SET VLCAPITAL = VLCAPITAL + vr_vldcotas
        WHERE CDCOOPER = vr_cdcooper
          AND NRDCONTA = vr_nrdconta
          AND TPDEVOLUCAO = 3;
        END IF;
        --
                
        -- Remove valor de cota capital
        UPDATE cecred.crapcot
           SET vldcotas = vldcotas - vr_vldcotas
        WHERE cdcooper = vr_cdcooper
          AND nrdconta = vr_nrdconta; 
        
        --
        vr_nrdocmto := vr_nrdconta || vr_cdcooper;
        vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', vr_cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';16;100;600040');
        --
                 
        -- efetua o lançamento do extrato
        INSERT INTO cecred.craplct(cdcooper
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
        VALUES (vr_cdcooper
        ,16
        ,100
        ,600040
        ,vr_dtmvtolt
        ,vr_cdhistor
        ,0
        ,vr_nrdconta 
        ,vr_nrdocmto
        ,vr_nrseqdig
        ,vr_vldcotas); 
        --
        vr_dstransa := vr_dstransa || ' Movimentando saldo de capital para valores a devolver por script. R$ ' || to_char(vr_vldcotas, '9G999D99') || ' ' || vr_dtmvtolt;
        --
      END IF;
      --
      --vr_log_script := vr_log_script || ' | ' || vr_dstransa;
      --
      -- Atualiza crapass
      UPDATE CECRED.CRAPASS
        SET cdsitdct = 4, 
            dtdemiss = to_date(vr_data_demissao,'DD/MM/YYYY'),
          dtelimin = to_date(vr_data_demissao,'DD/MM/YYYY'),
                dtasitct = to_date(vr_data_demissao,'DD/MM/YYYY'),
                  cdmotdem = 11
      WHERE nrdconta = vr_nrdconta
        AND cdcooper = vr_cdcooper;
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
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,vr_dstransa
        ,'AIMARO'
        ,''
        ,1
        ,' '
        ,1
        ,' ');
      --
      
      -- Insere log com valores de antes x depois.
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,1
        ,'crapass.cdsitdct'
        ,vr_cdsitdct
        ,'4');
      
      -- Insere log com valores de antes x depois.
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,2
        ,'crapass.dtdemiss'
        ,to_char(vr_dtdemiss_ant,'DD/MM/YYYY')
        ,vr_data_demissao);
        
        
      -- Insere log com valores de antes x depois.
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,3
        ,'crapass.cdmotdem'
        ,vr_cdmotdem_ant
        ,'11');
            
      -- Insere log com valores de antes x depois.
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,4
        ,'crapass.dtelimin'
        ,to_char(vr_dtelimin_ant,'DD/MM/YYYY')
        ,vr_data_demissao);
        
      -- Insere log com valores de antes x depois.
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,5
        ,'crapass.dtasitct'
        ,to_char(vr_dtasitct_ant,'DD/MM/YYYY')
        ,vr_data_demissao);  
          
        
      --
      IF NVL(vr_vldcotas, 0) > 0 then
        --
        -- Insere log com valores de antes x depois da TBCOTAS_DEVOLUCAO.
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,6
        ,'tbcotas_devolucao.VLCAPITAL'
        ,vr_capdev_ant
        ,(vr_capdev_ant + vr_vldcotas) );
        --
        -- Insere log com valores de antes x depois da CRAPCOT.
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
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,7
        ,'crapcot.vldcotas'
        ,vr_vldcotas
        ,0 );
        --
      END IF;
      
      COMMIT;
      --
  END IF;
      
   END;     
  
  END LOOP;  
  --
  --DBMS_OUTPUT.PUT_LINE(vr_log_script);
  --
  --
  DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN vr_exc_lanc_conta THEN
      BEGIN
         vr_cdcritic := NVL(vr_cdcritic, 0);

         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
         RAISE_APPLICATION_ERROR(-20000, 'Atenção: ' || vr_dscritic);
      END;
  WHEN vr_exc_saldo THEN
     BEGIN
       vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
     RAISE_APPLICATION_ERROR(-20000, 'Atenção: ' || vr_dscritic);
     END;
  WHEN vr_exc_sem_data_cooperativa THEN
     BEGIN
        vr_cdcritic := 1;
        vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE_APPLICATION_ERROR(-20000, 'Atenção: ' || vr_dscritic);
     END;
  WHEN vr_exc_associados THEN
     BEGIN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao consultar associados: ' || SQLERRM);
     END;
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
