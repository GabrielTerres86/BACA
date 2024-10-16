DECLARE

  vc_cdcooper       CONSTANT NUMBER := 10;
  vc_cdhistor_PF    CONSTANT NUMBER := 4606;
  vc_cdhistor_PJ    CONSTANT NUMBER := 4607;
  vc_cdhistor_caixa CONSTANT NUMBER := 4608;
  vc_cdoperad       CONSTANT VARCHAR2(20) := 'f0033918';
  vc_diretorio      CONSTANT VARCHAR2(100) := gene0001.fn_diretorio('M',0)||'cpd/bacas/RITM0429819';
  vc_separador      CONSTANT VARCHAR2(20) := ';';

  CURSOR cd_cooperativa IS
    SELECT cop.cdcooper
         , dat.dtmvtolt
         , dat.dtmvtocd
         , DECODE(cop.cdcooper, 1,  1,  2, 14,  5,  9
                              , 6,  2,  7,  1,  8,  1
                              , 9,  1, 10,  3, 11, 95
                              , 12, 1, 13,  1, 14,  1, 16, 1) cdagenci
         , DECODE(cop.cdcooper, 1,  3,  2,  5,  5,  4
                              , 6,  1,  7,100,  8,  2
                              , 9,  7, 10,  1, 11,  1
                              , 12,10, 13,  6, 14, 10, 16, 1) nrdcaixa
         , DECODE(cop.cdcooper, 1,vc_cdoperad, 2,vc_cdoperad, 3,vc_cdoperad, 4,vc_cdoperad
                              , 5,vc_cdoperad, 6,vc_cdoperad, 7,vc_cdoperad, 8,vc_cdoperad
                              , 9,vc_cdoperad,10,vc_cdoperad,11,vc_cdoperad,12,vc_cdoperad
                              ,13,vc_cdoperad,14,vc_cdoperad,15,vc_cdoperad,16,vc_cdoperad
                              ,17,vc_cdoperad) cdoperad
      FROM cecred.crapcop cop
     INNER JOIN cecred.crapdat dat
        ON dat.cdcooper = cop.cdcooper
     WHERE cop.flgativo = 1 
       AND cop.cdcooper <> 3
       AND cop.cdcooper = vc_cdcooper;

  CURSOR cr_valor(pr_cdcooper NUMBER
                 ,pr_nrdconta NUMBER) IS
    SELECT ass.cdcooper
         , ass.nrdconta
         , decode(ass.inpessoa,1,vc_cdhistor_PF,vc_cdhistor_PJ) cdhistor
         , dev.dtinicio_credito
         , (dev.vlcapital - dev.vlpago) vldsaldo
      FROM cecred.crapass ass
     INNER JOIN cecred.tbcotas_devolucao dev
        ON dev.cdcooper    = ass.cdcooper
       AND dev.nrdconta    = ass.nrdconta
     WHERE ass.cdcooper    = pr_cdcooper
       AND ass.nrdconta    = pr_nrdconta
       AND dev.tpdevolucao = 4;
  rw_valor  cr_valor%ROWTYPE;
  
  CURSOR cr_crapbcx(pr_cdcooper  NUMBER
                   ,pr_dtmvtocd  DATE
                   ,pr_cdagenci  NUMBER
                   ,pr_nrdcaixa  NUMBER
                   ,pr_cdoperad  VARCHAR2) IS
    SELECT bcx.nrdmaqui
      FROM cecred.crapbcx bcx
     WHERE bcx.cdcooper = pr_cdcooper   
       AND bcx.dtmvtolt = pr_dtmvtocd     
       AND bcx.cdagenci = pr_cdagenci
       AND bcx.nrdcaixa = pr_nrdcaixa  
       AND bcx.cdopecxa = pr_cdoperad 
       AND bcx.cdsitbcx = 1;
  rw_crapbcx     cr_crapbcx%ROWTYPE;
  
  vr_nrdrowid    ROWID;
  vr_literal     VARCHAR2(100);
  vr_sequencia   INTEGER;
  vr_registro    ROWID;
  vr_cdcritic    INTEGER;
  vr_dscritic    VARCHAR2(2000);
  vr_nrdocmto    NUMBER;
  vr_vltotcop    NUMBER;
  vr_nrseqdig    NUMBER;
  
  vr_arqbase     UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;
  vr_linha_arq   VARCHAR2(100);
  vr_arqcoop     NUMBER;
  vr_arqconta    NUMBER;
  vr_arqvalor    NUMBER;
  vr_nrlinha     NUMBER;
  vr_vet_dados   gene0002.typ_split;
  
BEGIN

  FOR coop IN cd_cooperativa LOOP
    
    vr_vltotcop := 0;
    
    OPEN  cr_crapbcx(coop.cdcooper, coop.dtmvtocd, coop.cdagenci, coop.nrdcaixa, coop.cdoperad);
    FETCH cr_crapbcx INTO rw_crapbcx;
    
    IF cr_crapbcx%NOTFOUND THEN
      CLOSE cr_crapbcx;
      vr_cdcritic := 698;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      raise_application_error(-20005,vr_cdcritic||' - '||vr_dscritic);
    END IF;
    
    CLOSE cr_crapbcx;
    
    gene0001.pc_abre_arquivo(pr_nmdireto => vc_diretorio
                            ,pr_nmarquiv => 'log_processo_'||LPAD(coop.cdcooper,2,'0')||'.log'
                            ,pr_tipabert => 'A'
                            ,pr_utlfileh => vr_arqlog
                            ,pr_des_erro => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20010,'Erro ao abrir o arquivo de log para escrita: '||vr_dscritic);
    END IF;
    
    IF NOT utl_file.IS_OPEN(vr_arqlog) THEN
      raise_application_error(-20011,'Arquivo de log não está aberto para escrita de dados.');
    END IF;
    
    vr_nrlinha := 0;
    
    gene0001.pc_abre_arquivo(pr_nmdireto => vc_diretorio
                            ,pr_nmarquiv => 'base_retencao_'||LPAD(coop.cdcooper,2,'0')||'.txt'
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_arqbase
                            ,pr_des_erro => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20012,'Erro ao abrir o arquivo base: '||vr_dscritic);
    END IF;
    
    IF NOT utl_file.IS_OPEN(vr_arqbase) THEN
      raise_application_error(-20013,'Arquivo base não está aberto para consulta e processamento.');
    END IF;
    
    LOOP
      
      BEGIN
        vr_nrlinha := NVL(vr_nrlinha,0) + 1;
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqbase
                                    ,pr_des_text => vr_linha_arq); 
        vr_linha_arq := REPLACE(REPLACE(vr_linha_arq,chr(10),NULL),chr(13),NULL);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          EXIT;
        WHEN OTHERS THEN
          raise_application_error(-20014,'Erro ao ler linha '||vr_nrlinha||' do arquivo.');
      END;
      
      IF TRIM(vr_linha_arq) IS NULL THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Linha em branco.');
        CONTINUE;
      END IF;
      
      BEGIN
        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_linha_arq, pr_delimit => vc_separador);
        
        vr_arqcoop  := to_number(TRIM(vr_vet_dados(1)));
        vr_arqconta := to_number(TRIM(vr_vet_dados(2)));
        vr_arqvalor := gene0002.fn_char_para_number(TRIM(vr_vet_dados(3)));
      
      EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                        ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Erro ao quebrar linha. '||SQLERRM);
          CONTINUE;
      END;
      
      IF vc_cdcooper <> vr_arqcoop THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Cooperativa do script, diferente da cooperativa do arquivo.');
        CONTINUE;
      END IF;
      
      IF NVL(vr_arqvalor,0) <= 0 THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Valor não informado ou zerado no arquivo.');
        CONTINUE;
      END IF;
      
      OPEN  cr_valor(vr_arqcoop,vr_arqconta);
      FETCH cr_valor INTO rw_valor;
      
      IF cr_valor%NOTFOUND THEN
        CLOSE cr_valor;
        
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Dados de valores a devolver não encontrados para a conta '||vr_arqconta);
        CONTINUE;
      END IF;
      
      CLOSE cr_valor;
      
      IF rw_valor.vldsaldo <= 0 THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Valor da conta '||vr_arqconta||' zerado.');
        
        CONTINUE;
      ELSIF rw_valor.vldsaldo < vr_arqvalor THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Valor da conta '||vr_arqconta||' menor que o solicitado. Arquivo: '||vr_arqvalor||' - Conta: '||rw_valor.vldsaldo);
                                      
        vr_arqvalor := rw_valor.vldsaldo;
      END IF;
      
      BEGIN
        UPDATE cecred.tbcotas_devolucao dev
           SET dev.dtinicio_credito = coop.dtmvtolt
             , dev.vlpago           = (dev.vlpago + vr_arqvalor)
         WHERE dev.cdcooper         = rw_valor.cdcooper
           AND dev.nrdconta         = rw_valor.nrdconta
           AND dev.tpdevolucao      = 4;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001,'Erro ao atualizar tbcotas_devolucao('||rw_valor.cdcooper||'/'||rw_valor.nrdconta||'): '||SQLERRM);
      END;
      
      BEGIN
        INSERT INTO contacorrente.tbcc_controle_devolucao
                         (cdcooper
                         ,nrdconta
                         ,dtcreant 
                         ,vldsaldo)
                   VALUES(rw_valor.cdcooper
                         ,rw_valor.nrdconta
                         ,rw_valor.dtinicio_credito
                         ,vr_arqvalor);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20002,'Erro ao incluir tbcc_controle_devolucao('||rw_valor.cdcooper||'/'||rw_valor.nrdconta||'): '||SQLERRM);
      END;
      
      geralog(pr_cdcooper => rw_valor.cdcooper
             ,pr_nrdconta => rw_valor.nrdconta
             ,pr_cdoperad => coop.cdoperad
             ,pr_dscritic => NULL
             ,pr_dsorigem => 'SCRIPT'
             ,pr_dstransa => 'Captação de Recursos Esquecidos para União conf. Lei 14973/23 arts. 45-47'
             ,pr_dttransa => TRUNC(SYSDATE)
             ,pr_flgtrans => 1
             ,pr_hrtransa => gene0002.fn_busca_time
             ,pr_idseqttl => 1
             ,pr_nmdatela => 'ATENDA'
             ,pr_nrdrowid => vr_nrdrowid);

      geralogitem(pr_nrdrowid => vr_nrdrowid
                 ,pr_nmdcampo => 'Valor Total Captado'
                 ,pr_dsdadant => vr_arqvalor
                 ,pr_dsdadatu => 0);
      
      vr_nrdocmto := gene0002.fn_busca_time;
      vr_vltotcop := NVL(vr_vltotcop,0) + vr_arqvalor;
      
      BEGIN
          
        CXON0000.pc_grava_autenticacao(pr_cooper       => rw_valor.cdcooper
                                      ,pr_cod_agencia  => coop.cdagenci 
                                      ,pr_nro_caixa    => coop.nrdcaixa
                                      ,pr_cod_operador => coop.cdoperad
                                      ,pr_valor        => vr_arqvalor
                                      ,pr_docto        => vr_nrdocmto
                                      ,pr_operacao     => TRUE
                                      ,pr_status       => 1
                                      ,pr_estorno      => FALSE
                                      ,pr_histor       => rw_valor.cdhistor
                                      ,pr_data_off     => NULL
                                      ,pr_sequen_off   => 0
                                      ,pr_hora_off     => 0
                                      ,pr_seq_aut_off  => 0
                                      ,pr_literal      => vr_literal  
                                      ,pr_sequencia    => vr_sequencia
                                      ,pr_registro     => vr_registro 
                                      ,pr_cdcritic     => vr_cdcritic 
                                      ,pr_dscritic     => vr_dscritic );
        
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          IF TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          raise_application_error(-20003,'Erro gravar autenticação('||rw_valor.cdcooper||'/'||rw_valor.nrdconta||'): '||vr_cdcritic||' - '||vr_dscritic);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20004,'Erro pc_grava_autenticacao('||rw_valor.cdcooper||'/'||rw_valor.nrdconta||'): '||SQLERRM);
      END;
      
      vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(rw_valor.cdcooper)
                                ,pr_flgdecre => 'N');
      
      BEGIN
        INSERT INTO cecred.craplcx
                           (cdagenci
                           ,cdhistor
                           ,cdopecxa
                           ,dtmvtolt
                           ,nrdcaixa
                           ,nrdmaqui
                           ,nrdocmto
                           ,nrseqdig
                           ,vldocmto
                           ,dsdcompl
                           ,nrautdoc
                           ,cdcooper
                           ,nrdconta)
                    VALUES (coop.cdagenci
                           ,rw_valor.cdhistor
                           ,coop.cdoperad
                           ,coop.dtmvtolt
                           ,coop.nrdcaixa
                           ,rw_crapbcx.nrdmaqui
                           ,vr_nrdocmto
                           ,vr_nrseqdig
                           ,vr_arqvalor
                           ,'Agencia: ' || LPAD(coop.cdagenci,3,'0') || ' Conta/DV: ' || LPAD(rw_valor.nrdconta,8,'0')
                           ,vr_sequencia
                           ,rw_valor.cdcooper
                           ,rw_valor.nrdconta);
                        
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20006,'Erro incluir lançamento craplcx('||rw_valor.cdcooper||'/'||rw_valor.nrdconta||'): '||SQLERRM);
      END;
      
    END LOOP;
    
    vr_nrdocmto := gene0002.fn_busca_time;
    
    BEGIN
          
      CXON0000.pc_grava_autenticacao(pr_cooper       => coop.cdcooper
                                    ,pr_cod_agencia  => coop.cdagenci 
                                    ,pr_nro_caixa    => coop.nrdcaixa
                                    ,pr_cod_operador => coop.cdoperad
                                    ,pr_valor        => vr_vltotcop
                                    ,pr_docto        => vr_nrdocmto
                                    ,pr_operacao     => TRUE
                                    ,pr_status       => 1
                                    ,pr_estorno      => FALSE
                                    ,pr_histor       => vc_cdhistor_caixa
                                    ,pr_data_off     => NULL
                                    ,pr_sequen_off   => 0
                                    ,pr_hora_off     => 0
                                    ,pr_seq_aut_off  => 0
                                    ,pr_literal      => vr_literal  
                                    ,pr_sequencia    => vr_sequencia
                                    ,pr_registro     => vr_registro 
                                    ,pr_cdcritic     => vr_cdcritic 
                                    ,pr_dscritic     => vr_dscritic );
        
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        IF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        raise_application_error(-20007,'Erro gravar autenticação('||coop.cdcooper||'): '||vr_cdcritic||' - '||vr_dscritic);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20008,'Erro pc_grava_autenticacao('||coop.cdcooper||'): '||SQLERRM);
    END;
    
    vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRSEQDIG'
                              ,pr_dsdchave => to_char(coop.cdcooper)
                              ,pr_flgdecre => 'N');
    BEGIN
      INSERT INTO cecred.craplcx
                         (cdagenci
                         ,cdhistor
                         ,cdopecxa
                         ,dtmvtolt
                         ,nrdcaixa
                         ,nrdmaqui
                         ,nrdocmto
                         ,nrseqdig
                         ,vldocmto
                         ,dsdcompl
                         ,nrautdoc
                         ,cdcooper
                         ,nrdconta)
                  VALUES (coop.cdagenci
                         ,vc_cdhistor_caixa
                         ,coop.cdoperad
                         ,coop.dtmvtolt
                         ,coop.nrdcaixa
                         ,rw_crapbcx.nrdmaqui
                         ,vr_nrdocmto
                         ,vr_nrseqdig
                         ,vr_vltotcop
                         ,'VALORES A DEVOLVER'
                         ,vr_sequencia
                         ,coop.cdcooper
                         ,0);
                        
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20009,'Erro incluir lançamento craplcx('||coop.cdcooper||'): '||SQLERRM);
    END;

    COMMIT;
  END LOOP;

  COMMIT;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqbase);
  
  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - PROCESSAMENTO DA COOPERATIVA '||vc_cdcooper||' ENCERRADO.');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqlog);
  
END;
