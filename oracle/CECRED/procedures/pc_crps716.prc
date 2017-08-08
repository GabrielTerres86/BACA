CREATE OR REPLACE PROCEDURE CECRED.pc_crps716 (pr_cdcooper IN crapcop.cdcooper%TYPE ) IS   --> Cooperativa solicitada
  /* .............................................................................

     Programa: pc_crps716
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Mar�o/2017                     Ultima atualizacao: 27/03/2017

     Dados referentes ao programa:

     Frequencia: Executado via Job
     Objetivo  : Realizar importa��o do arquivo de faturas atrasadas de cart�o de credito.

     Alteracoes: 27/07/2017 - Adicionado gera��o do arquivo log para conferencia pela area
                              de negocio. Adicionado envio de e-mail quando problemas forem
                              encontrados (Anderson).

  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- C�digo do programa
  vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS716';
  vr_cdcooper   NUMBER  := 3;

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_erro   EXCEPTION;  
  vr_exc_prox   EXCEPTION;  
  vr_exc_fimcoop EXCEPTION;  
  vr_exc_email  EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  vr_dslinha    VARCHAR2(100);
  vr_qttotal    NUMERIC;
  vr_qtimport   NUMERIC;
  vr_dsdirarq   VARCHAR2(500);
  vr_dscomand   VARCHAR2(2000);
  vr_typ_saida  VARCHAR2(4000); 
  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.cdcooper
          ,cop.cdagebcb
      FROM crapcop cop
     WHERE cop.cdcooper = decode(pr_cdcooper,3,cop.cdcooper,pr_cdcooper)
       AND cop.cdcooper <> 3
       AND cop.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;


  -- buscar nome do programa
  CURSOR cr_crapprg IS
    SELECT lower(crapprg.dsprogra##1) dsprogra##1
      FROM crapprg
     WHERE cdcooper = vr_cdcooper
       AND cdprogra = vr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;
  
  --> Verificar se existe cartao cadastrado
  CURSOR cr_crapcrd (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrcartao NUMBER)  IS      
    SELECT nrdconta
      FROM tbcrd_conta_cartao crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrconta_cartao = pr_nrcartao;
  rw_crapcrd cr_crapcrd%ROWTYPE;

  -- Cursor gen�rico de calend�rio
  rw_crapdat btch0001.cr_crapdat%ROWTYPE; 
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  vr_tab_linhas   gene0009.typ_tab_linhas;
  vr_tab_arquivo  gene0002.typ_split;
  ------------------------------- VARIAVEIS -------------------------------
  
  -- Nome do diretorio da cooperativa
  vr_nmdireto     VARCHAR2(500);  
  vr_nmarqdat     VARCHAR2(500);
  vr_listdarq     VARCHAR2(500);
  vr_nmarqlog     VARCHAR2(500);
  vr_nmlogtmp     VARCHAR2(500);

  vr_cdagebcb     crapcop.cdagebcb%TYPE;
  vr_vlsldfat     crapepr.vlemprst%TYPE;  
  vr_qtdiaatr     INTEGER;  
  vr_nrcartao     NUMBER;
  vr_dtdatual     DATE;
  vr_flgemail     BOOLEAN;
  
  --------------------------- SUBROTINAS INTERNAS --------------------------

  vr_nomdojob    VARCHAR2(40) := 'JBCRD_ARQ_FAT_ATRASO';
  vr_flgerlog    BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --> Controlar gera��o de log de execu��o dos jobs
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => vr_nomdojob    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_nmarqlog     => vr_nmlogtmp
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch;
  
  --> Gerar log 
  PROCEDURE pc_gerar_log (pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
     
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                               pr_ind_tipo_log => 1, 
                               pr_cdprograma   => vr_nomdojob,
                               pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| pr_dscritic,
                               pr_nmarqlog     => vr_nmlogtmp,
                               pr_dsdirlog     => vr_dsdirarq);
  
  
  END pc_gerar_log;
  
  --> Envio de e-mail de alerta
  PROCEDURE pc_envia_email_alerta(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dscritic IN VARCHAR2) IS
    vr_dscritica_aux VARCHAR2(2000) := '';
  BEGIN
    gene0003.pc_solicita_email(pr_cdcooper    => nvl(pr_cdcooper,3)
                              ,pr_cdprogra    => 'CRPS716'
                              ,pr_des_destino => gene0001.fn_param_sistema('CRED',nvl(pr_cdcooper,3), 'CRED_EMAIL_FAT_ATRASO')
                              ,pr_des_assunto => 'Problemas durante a importa��o de Faturas de Cart�o de Cr�dito em Atraso'
                              ,pr_des_corpo   => 'Ol�, <br><br>'
                                                 || 'Foram encontrados problemas durante o processo de importa��o das Faturas '
                                                 || 'de Cart�o de Cr�dito em Atraso, referente a cooperativa '||nvl(pr_cdcooper,3)||'.<br> '
                                                 || 'Por favor, verifique o LOG de importa��o.<br><br>'
                                                 || 'Situa��o encontrada: ' || pr_dscritic
                              ,pr_des_anexo   => ''
                              ,pr_flg_enviar  => 'N'
                              ,pr_des_erro    => vr_dscritica_aux);
    IF TRIM(vr_dscritica_aux) IS NOT NULL THEN
      pc_gerar_log(nvl(pr_cdcooper,3),vr_dscritic);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
        pc_gerar_log(nvl(pr_cdcooper,3),'N�o foi poss�vel solicitar o envio do e-mail corretamente! '||SQLERRM);
  END pc_envia_email_alerta;

BEGIN

  --------------- VALIDACOES INICIAIS -----------------
  
  -- Incluir nome do m�dulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);

  -- Buscar nome do programa
  OPEN cr_crapprg;
  FETCH cr_crapprg INTO rw_crapprg;
  CLOSE cr_crapprg;

  vr_dtdatual := trunc(SYSDATE);

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  vr_dsdirarq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'NMDIRETO_LOG_FAT_ATRASO');
  IF vr_dsdirarq IS NULL THEN
    vr_dscritic := 'Diretorio do arquivo de log nao encontrado.';
    RAISE vr_exc_saida;  
  END IF;
  
  --> Nome do arquivo de log temporario
  vr_nmlogtmp := to_char(SYSDATE,'RRRRMMDD')||'_ATRASO_temp';  
  --> Nome do arquivo de log oficial
  vr_nmarqlog := to_char(SYSDATE,'RRRRMMDD')||'_ATRASO_'||to_char(SYSDATE, 'hh24miss');
  
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN
      vr_flgerlog   := FALSE;
      
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN

        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;

      --Rodar apenas em dias uteis
      --Se esta rodando o processo, vamos usar a data de amanha na validacao
      IF rw_crapdat.inproces > 1 THEN 
        IF rw_crapdat.dtmvtopr <> vr_dtdatual THEN
          continue;
        END IF;
      ELSE
        IF rw_crapdat.dtmvtolt <> vr_dtdatual THEN
          continue;
        END IF;        
      END IF;
      
      -- Log de in�cio da execu��o
      pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dstiplog => 'I');
                            
      pc_gerar_log(rw_crapcop.cdcooper, 'In�cio importa��o do arquivo de faturas em atraso - Cooperativa: '||rw_crapcop.cdcooper);      
      
      -- Busca do diret�rio do arquivo
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'M', --> micros
                                           pr_cdcooper => rw_crapcop.cdcooper,
                                           pr_nmsubdir => '/cecred_cartoes');

      vr_nmarqdat := '756-2011-'|| rw_crapcop.cdagebcb ||'-RELTCABALCARTOESATRASO%'||
                     to_char(rw_crapdat.dtmvtolt,'DDMMRRRR')||'.TXT';
                     
      --> Listar arquivos localizados
      gene0001.pc_lista_arquivos(pr_path     => vr_nmdireto, 
                                 pr_pesq     => vr_nmarqdat, 
                                 pr_listarq  => vr_listdarq, 
                                 pr_des_erro => vr_dscritic);
  
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro na busca dos arquivos para importa��o! Detalhes: ' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_listdarq IS NULL THEN
        vr_dscritic := 'Nenhum arquivo '||vr_nmarqdat||' encontrado.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Quebrar lista em tabela
      vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listdarq, 
                                                  pr_delimit => ',');
      
      IF vr_tab_arquivo.count > 0 THEN
      
        --> Limpar tabela de alerta
        BEGIN
          DELETE tbcrd_alerta_atraso alt
           WHERE alt.cdcooper = rw_crapcop.cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel limpar tabela de alerta: '||SQLERRM;
            RAISE vr_exc_erro;
        END; 
      
        --> Importar arquivos
        FOR i IN vr_tab_arquivo.first..vr_tab_arquivo.last LOOP
          BEGIN
            
            pc_gerar_log(rw_crapcop.cdcooper, 'In�cio importa��o do arquivo '||vr_tab_arquivo(i)||' da Cooperativa: '||rw_crapcop.cdcooper);
          
            --> Importar o arquivo texto
            gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CARTAO_ATRASO', 
                                           pr_dsdireto   => vr_nmdireto, 
                                           pr_nmarquiv   => vr_tab_arquivo(i), 
                                           pr_dscritic   => vr_dscritic, 
                                           pr_tab_linhas => vr_tab_linhas);
            
            
            IF vr_tab_linhas.count = 0 THEN
              vr_dscritic := 'Arquivo ' || vr_tab_arquivo(i) || '.csv n�o possui conte�do!';    
              RAISE vr_exc_email;
            END IF;            
            
            vr_qttotal  := 0;
            vr_qtimport := 0;
            
            --> ler linhas do arquivo
            FOR vr_idx IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
              BEGIN

                /* Busca a linha completa para verificar se � o totalizador */
                vr_dslinha := substr(vr_tab_linhas(vr_idx)('$LINHA$').texto,1,100);
                IF substr(vr_dslinha,1,18) = 'Total de registros' THEN
                  BEGIN 
                    vr_qttotal := cast(trim(substr(vr_dslinha,21,length(vr_dslinha)-21)) as numeric);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao importar linha '|| vr_idx ||' com os totalizadores! '||SQLERRM;
                      RAISE vr_exc_prox;
                  END;
                  CONTINUE;
                END IF;

                --> Ignorar o cabecalho 
                IF vr_idx <= 21 OR               
                   nvl(vr_tab_linhas(vr_idx)('CDEMISSOR').NUMERO,0) <> 756 THEN
                  CONTINUE;
                END IF;
                
                --Problemas com importacao do layout
                IF vr_tab_linhas(vr_idx).exists('$ERRO$') THEN 
                  vr_dscritic := 'Erro ao importar linha '|| vr_idx ||': '||
                                  vr_tab_linhas(vr_idx)('$ERRO$').texto;
                  RAISE vr_exc_prox;
                END IF;
                  
                vr_cdagebcb := vr_tab_linhas(vr_idx)('CDAGEBCB').NUMERO;              
                vr_nrcartao := vr_tab_linhas(vr_idx)('NRCARTAO').NUMERO;
                vr_vlsldfat := to_number(TRIM(vr_tab_linhas(vr_idx)('VLSLDFAT').TEXTO),
                                         'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''');
                vr_qtdiaatr := vr_tab_linhas(vr_idx)('QTDIAATRASO').NUMERO;
                
                
                --> Identificar numero da conta do cooperado
                OPEN cr_crapcrd(pr_cdcooper => rw_crapcop.cdcooper,
                                pr_nrcartao => vr_nrcartao);
                FETCH cr_crapcrd INTO rw_crapcrd;
                
                IF cr_crapcrd%NOTFOUND THEN
                  CLOSE cr_crapcrd;
                  vr_dscritic := 'Erro ao processar linha '||vr_idx||' - N�o foi possivel identificar conta para a conta cart�o '||vr_nrcartao;
                  RAISE vr_exc_prox;
                END IF;
                
                CLOSE cr_crapcrd;
                                
                --> Gravar informa��es na tabela
                BEGIN
                  INSERT INTO tbcrd_alerta_atraso
                              (  cdcooper
                                ,nrdconta
                                ,nrconta_cartao
                                ,qtdias_atraso
                                ,vlsaldo_devedor)
                       VALUES (  rw_crapcop.cdcooper  --> cdcooper
                                ,rw_crapcrd.nrdconta  --> nrdconta
                                ,vr_nrcartao          --> nrconta_cartao
                                ,vr_qtdiaatr          --> qtdias_atraso
                                ,vr_vlsldfat);        --> vlsaldo_devedor
                                  
                EXCEPTION
                  WHEN OTHERS THEN 
                    vr_dscritic := 'Erro ao processar linha '||vr_idx||' - Nao foi possivel inserir tbcrd_alerta_atraso: '||SQLERRM;
                    RAISE vr_exc_prox;
                END;
                vr_qtimport := vr_qtimport + 1;
                
              EXCEPTION
                WHEN vr_exc_prox THEN
                  pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                                pr_dscritic => vr_dscritic);
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao processar linha '||vr_idx||': '||SQLERRM;
                  pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                                pr_dscritic => vr_dscritic);
              END;
            END LOOP; --> Fim loop linhas
            
            /* Caso n�o conseguiu contar a qtd. de registros total, vamos enviar um e-mail */
            IF vr_qttotal = 0 THEN
              vr_dscritic := 'ATEN��O: N�o foi poss�vel realizar a confer�ncia da quantidade de registros importados!';
              RAISE vr_exc_email; 
            /* Caso n�o importou todos os registros, vamos enviar um e-mail */
            ELSIF vr_qtimport <> vr_qttotal THEN
              vr_dscritic := 'ATEN��O: Foram importados apenas '||vr_qtimport||' registros do total de '||vr_qttotal||' registros presente no arquivo de atrasos!';
              RAISE vr_exc_email; 
            ELSE
              pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dscritic => 'Foram importados '||vr_qtimport||' registros com sucesso do total de '||vr_qttotal|| ' registros do arquivo.');
            END IF;
            
          EXCEPTION
            WHEN vr_exc_prox THEN
              pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dscritic => vr_dscritic);
            WHEN vr_exc_email THEN
              pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dscritic => vr_dscritic);
              pc_envia_email_alerta(rw_crapcop.cdcooper, vr_dscritic);
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao processar arquivo '||vr_tab_arquivo(i)||': '||SQLERRM;
              pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dscritic => vr_dscritic);
              pc_envia_email_alerta(rw_crapcop.cdcooper, vr_dscritic);
          END;
          
        END LOOP; --> Fim loop arquivos
      
      ELSE
        vr_dscritic := 'Nenhum arquivo '||vr_listdarq||' encontrado.';
        RAISE vr_exc_erro;
      END IF;  
            
      -- Log de fim da execu��o
      pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dstiplog =>'F');

      -- Salvar informa��es atualizadas
      COMMIT;
      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pc_gerar_log (pr_cdcooper => rw_crapcop.cdcooper,
                      pr_dscritic => vr_dscritic);  
      
        pc_envia_email_alerta(rw_crapcop.cdcooper, vr_dscritic);
        
        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
        vr_dscritic := NULL;
        
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel importar arquivo de faturas em atraso: '||SQLERRM;
        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
        pc_envia_email_alerta(rw_crapcop.cdcooper, vr_dscritic);
        vr_dscritic := NULL;    
       
    END;
  END LOOP; -- crapcop
  ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  --> Converte log temporario para log oficial (DOS)
  vr_dscomand := 'ux2dos '|| vr_dsdirarq || '/' || vr_nmlogtmp || '.log > '
                          || vr_dsdirarq || '/' || vr_nmarqlog || '.log';

  -- Converter de UNIX para DOS o arquivo
  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                       ,pr_des_comando => vr_dscomand
                       ,pr_typ_saida   => vr_typ_saida
                       ,pr_des_saida   => vr_dscritic);

  IF vr_typ_saida = 'ERR' THEN
     -- O comando shell executou com erro, gerar log e sair do processo
     vr_dscritic := 'Erro ao converter arquivo de log: ' || vr_dscritic;
     RAISE vr_exc_saida;
  END IF;
  
  --> Remove arquivo de log temporario
  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                       ,pr_des_comando => 'rm -f '|| vr_dsdirarq || '/' || vr_nmlogtmp || '.log'
                       ,pr_typ_saida   => vr_typ_saida
                       ,pr_des_saida   => vr_dscritic);

  IF vr_typ_saida = 'ERR' THEN
     -- O comando shell executou com erro, gerar log e sair do processo
     vr_dscritic := 'Erro ao remover arquivo de log: ' || vr_dscritic;
     RAISE vr_exc_saida;
  END IF;
                 
  -- Salvar informa��es atualizadas
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas c�digo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;

    pc_controla_log_batch('E', vr_dscritic);
    
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro n�o tratado
    vr_dscritic := sqlerrm;

    -- Envio centralizado de log de erro
    vr_flgerlog := TRUE;
    pc_controla_log_batch('E', vr_dscritic);
    -- Efetuar rollback
    ROLLBACK;

END pc_crps716;
/
