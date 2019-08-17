declare  

  /* 044 Grupos executaram em 015 segundos Dev2 */
  /* 037 Grupos executaram em 063 segundos Dev2 */  
  
  -- Parametros para execucao do script
  vr_idprglog            number := 0;
  vr_exc_saida           exception;
  vr_cdcritic            pls_integer;
  vr_nmarquivo_upload    varchar2(4000);
  vr_caminho_arq_upload  varchar2(255);
  vr_dscritic            varchar2(4000);
  vr_nmdcampo            varchar2(4000);
  vr_des_erro            varchar2(4000);
  vr_xmllog              varchar2(4000);
  vr_nmdirarq varchar2(1000) := gene0001.fn_diretorio(pr_tpdireto => 'C'     
                                                     ,pr_cdcooper => 3       
                                                     ,pr_nmsubdir => '/upload');
  vr_dtexibir_ate        date; -- Tabela Elton
  
  NMDATELA CONSTANT VARCHAR2(6) := 'PARBAN';

  -- Cursor que busca as agencias
  cursor cr_crapage is
  select age.cdcooper
       , age.cdagenci
       , age.nrdgrupo
    from tbevento_grupos age
   where age.cdcooper = 9
   order
      by age.cdcooper
       , age.cdagenci
       , age.nrdgrupo;

  -- Auxiliar para popular xml da rotina
  pr_retxml   xmltype;
  pr_auxiliar clob := '<Root>'                        ||
                      '<params>'                      ||
                      '<cdcooper>3</cdcooper>'        ||
                      '<nmprogra>UNDEFINED</nmprogra>'||
                      '<nmeacao>UNDEFINED</nmeacao>'  ||
                      '<cdagenci>1</cdagenci>'        ||
                      '<nrdcaixa>1</nrdcaixa>'        ||
                      '<idorigem>1</idorigem>'        ||
                      '<cdoperad>1</cdoperad>'        ||
                      '</params></Root>';
  
  PROCEDURE pc_manter_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                            ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                            ,pr_dstitulo_banner         in TBGEN_BANNER.DSTITULO_BANNER%TYPE
                            ,pr_insituacao_banner       in TBGEN_BANNER.INSITUACAO_BANNER%TYPE
                            ,pr_nmimagem_banner         in TBGEN_BANNER.NMIMAGEM_BANNER%TYPE
                            ,pr_inacao_banner           in TBGEN_BANNER.INACAO_BANNER%TYPE
                            ,pr_cdmenu_acao_mobile      in TBGEN_BANNER.CDMENU_ACAO_MOBILE%TYPE
                            ,pr_dslink_acao_banner      in TBGEN_BANNER.DSLINK_ACAO_BANNER%TYPE
                            ,pr_inexibe_msg_confirmacao in TBGEN_BANNER.INEXIBE_MSG_CONFIRMACAO%TYPE
                            ,pr_idacao_banner           IN NUMBER
                            ,pr_dsmensagem_acao_banner  in TBGEN_BANNER.DSMENSAGEM_ACAO_BANNER%TYPE
                            ,pr_tpfiltro                in TBGEN_BANNER.TPFILTRO%TYPE
                            ,pr_inexibir_quando         in TBGEN_BANNER.INEXIBIR_QUANDO%TYPE
                            ,pr_dtexibir_de             in varchar2
                            ,pr_dtexibir_ate            in VARCHAR2
                            ,pr_nmarquivo_upload        in TBGEN_BANNER.NMARQUIVO_UPLOAD%TYPE
                            ,pr_caminho_arq_upload      IN VARCHAR2
                            --
                            ,pr_dsfiltro_cooperativas   in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_COOPERATIVAS%TYPE
                            ,pr_dsfiltro_tipos_conta    in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_TIPOS_CONTA%TYPE
                            ,pr_inoutros_filtros        in TBGEN_BANNER_FILTRO_GENERICO.INOUTROS_FILTROS%TYPE
                            ,pr_dsfiltro_produto        in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_PRODUTO%TYPE
                            --
                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
                            
    vr_exc_erro EXCEPTION;                        
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
                              
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --
    vr_cdbanner      NUMBER; -- Código do banner
    vr_dtexibir_de   date; -- Data de vigencia inicial
    vr_dtexibir_ate  date;  -- Data de vigencia final
    vr_validacao     NUMBER; -- validação dos campos   
    vr_tbgen_banner             tbgen_banner%ROWTYPE;
    vr_tbgen_banner_param       tbgen_banner_param%ROWTYPE;
    vr_tbgen_banner_filtro_gen  tbgen_banner_filtro_generico%ROWTYPE;
    vr_tbgen_banner_filtro_esp  tbgen_banner_filtro_especifico%ROWTYPE;
    
    PROCEDURE pc_inserir_filtro_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                                      ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                                      ,pr_tpfiltro                in TBGEN_BANNER.TPFILTRO%TYPE
                                      --
                                      ,pr_dsfiltro_cooperativas   in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_COOPERATIVAS%TYPE
                                      ,pr_dsfiltro_tipos_conta    in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_TIPOS_CONTA%TYPE
                                      ,pr_inoutros_filtros        in TBGEN_BANNER_FILTRO_GENERICO.INOUTROS_FILTROS%TYPE
                                      ,pr_dsfiltro_produto        in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_PRODUTO%TYPE
                                      --
                                      ,pr_nmarquivo_upload        in TBGEN_BANNER.NMARQUIVO_UPLOAD%TYPE
                                      ,pr_caminho_arq_upload      IN VARCHAR2
                                      --
                                      ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS      --> Descrição da crítica
                                      
      vr_exc_erro EXCEPTION;                        
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      PROCEDURE pc_importar_arquivo_filtro(pr_cdbanner         in TBGEN_BANNER.CDBANNER%TYPE
                                          ,pr_cdcanal          in TBGEN_BANNER.CDCANAL%TYPE
                                          ,pr_arquivo          IN VARCHAR2 --> nome do arquivo de importação
                                          ,pr_dirarquivo       IN VARCHAR2 --> nome do diretório arquivo de importação
                                          ,pr_cdcritic         OUT PLS_INTEGER --> Código da crítica
                                          ,pr_dscritic         OUT VARCHAR2 --> Descrição da crítica
                                          ) IS --> Saida OK/NOK
        
        vr_nm_arquivo VARCHAR(2000);
              
        -- Variável de críticas
        vr_dscritic VARCHAR2(10000);
        vr_typ_said VARCHAR2(50);
              
        -- Variaveis padrao
        vr_cdcooper NUMBER:=3;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
        vr_dsdireto VARCHAR2(250);
              
        vr_linha_arq VARCHAR2(2000);
        vr_des_erro  VARCHAR2(2000);
        vr_dsorigem  VARCHAR2(20);
        vr_nrdrowid  ROWID;
              
        --Manipulação do texto do arquivo
        vr_tabtexto gene0002.typ_split;
              
        --Variáveis do split            
        vr_cdcooper_arq     NUMBER;
        vr_nrdconta_arq     NUMBER;
        vr_seqtitular_arq   NUMBER;      
        vr_erros            NUMBER := 0;
        vr_registros        NUMBER := 0;
        vr_registros_inexis NUMBER := 0;
              
        vr_handle_arq utl_file.file_type;
              
        --Controle de erro
        vr_exc_erro         EXCEPTION;
        vr_exc_erro_negocio EXCEPTION;
              
        separador VARCHAR2(1) := ';';
            
        TYPE vr_my_rec_filtro_espec IS RECORD ( cdbanner NUMBER  ,
                                                cdcanal  NUMBER ,
                                                cdcooper NUMBER(5) ,
                                                nrdconta NUMBER(10) ,
                                                idseqttl NUMBER(5) );
                                                    
        TYPE vr_my_table_filtro_espec IS TABLE OF vr_my_rec_filtro_espec;                                      
                                              
        vr_record_filtro_espec  vr_my_rec_filtro_espec;     

        vr_table_filtro_espec   vr_my_table_filtro_espec := vr_my_table_filtro_espec();
            
        vr_commit_interval       NUMBER:=10;
        vr_reg_process           NUMBER:=0;
                       
      BEGIN
        
        IF pr_arquivo IS NULL OR pr_dirarquivo IS NULL THEN
           vr_dscritic := 'Caminho do arquivo e nome são obrigatórios! ';
           RAISE vr_exc_erro;
        END IF;
            
        vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => 'upload');
        -- Realizar a cópia do arquivo
        GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dirarquivo||pr_arquivo||' N'
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => vr_des_erro);                                      
                                                             
        -- Testar erro
        IF vr_typ_said = 'ERR' THEN
            -- O comando shell executou com erro, gerar log e sair do processo
            vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
            --Gera log
            GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => NVL(pr_dscritic, ' ') || vr_dscritic,
                                 pr_dsorigem => vr_dsorigem,
                                 pr_dstransa => NMDATELA||' - Importação cadastros cooperados filtro banner',
                                 pr_dttransa => TRUNC(SYSDATE),
                                 --> ERRO/FALSE
                                 pr_flgtrans => 0,
                                 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                                 pr_idseqttl => 1,
                                 pr_nmdatela => vr_nmdatela,
                                 pr_nrdconta => 0,
                                 pr_nrdrowid => vr_nrdrowid);
            RAISE vr_exc_erro;
        END IF;
                
        vr_nm_arquivo := vr_dsdireto||'/'||pr_arquivo;
        --vr_nm_arquivo := pr_arquivo;
                
        IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) THEN
            -- Retorno de erro
            vr_dscritic := 'Erro no upload do arquivo: '||vr_des_erro;
                
            --Gera log
            GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => NVL(pr_dscritic, ' ') || vr_dscritic,
                                 pr_dsorigem => vr_dsorigem,
                                 pr_dstransa => NMDATELA||' - Importação cadastros cooperados filtro banner',
                                 pr_dttransa => TRUNC(SYSDATE),
                                 --> ERRO/FALSE
                                 pr_flgtrans => 0,
                                 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                                 pr_idseqttl => 1,
                                 pr_nmdatela => vr_nmdatela,
                                 pr_nrdconta => 0,
                                 pr_nrdrowid => vr_nrdrowid);
            --Levanta excessão
            RAISE vr_exc_erro;
        END IF;
                    
        --Abre o arquivo de saída 
        gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo,
                                 pr_tipabert => 'R',
                                 pr_utlfileh => vr_handle_arq,
                                 pr_des_erro => vr_des_erro);
            
        IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Erro abertura arquivo de importação! ' || vr_des_erro || ' ' ||
                           SQLERRM;
            RAISE vr_exc_erro;
        END IF;            
        
        --Tudo certo até aqui, importa o arquivo
        LOOP
          BEGIN
              --Lê a linha do arquivo
              gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);
              vr_linha_arq := TRIM(vr_linha_arq);
              vr_linha_arq := REPLACE(REPLACE(vr_linha_arq,chr(10),''),CHR(13),'');
              vr_linha_arq := vr_linha_arq||separador;
                                                       
              IF NVL(vr_linha_arq,' ') <> ' ' THEN                
                  --Explode no texto
                  vr_tabtexto := gene0002.fn_quebra_string(vr_linha_arq, separador);
                    
                  --Variáveis que serão usadas na atualização
                  vr_cdcooper_arq   := to_number(vr_tabtexto(1));
                  vr_nrdconta_arq   := to_number(vr_tabtexto(2));
                  vr_seqtitular_arq := to_number(vr_tabtexto(3));
                      
              END IF;
              --Faz a contagem até o limite do commit
              vr_reg_process:=nvl(vr_reg_process,0)+1;
              --Faz a contagem do total de registros      
              vr_registros := vr_registros + 1;
              --Popula o registro para importação
              vr_record_filtro_espec.cdbanner := pr_cdbanner;
              vr_record_filtro_espec.cdcanal  := pr_cdcanal;
              vr_record_filtro_espec.cdcooper := vr_cdcooper_arq;
              vr_record_filtro_espec.nrdconta := vr_nrdconta_arq;
              vr_record_filtro_espec.idseqttl := vr_seqtitular_arq;
              --inicializa e popula a table Type
              vr_table_filtro_espec.extend;
              vr_table_filtro_espec(vr_reg_process) := vr_record_filtro_espec;
              --Verifica se já atingiu a quantidade para efetur o insert
              IF vr_reg_process = vr_commit_interval THEN
                --
                FORALL i in vr_table_filtro_espec.first .. vr_table_filtro_espec.last
                INSERT INTO tbgen_banner_filtro_especifico VALUES vr_table_filtro_espec(i);
                -- Reseta a variavel
                vr_table_filtro_espec.Delete();
                vr_reg_process := 0;
                -- Efetua o commit
                COMMIT;
                --
              END IF;
                         
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                --Fecha o arquivo se não tem mais linhas para ler
                GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq); --> Handle do arquivo aberto
                EXIT;
          END;
        END LOOP;
          
        -- Termina o insert se ainda houver dados
        FORALL i in vr_table_filtro_espec.first .. vr_table_filtro_espec.last
        INSERT INTO tbgen_banner_filtro_especifico VALUES vr_table_filtro_espec(i);
                            
        COMMIT;
                
        IF (vr_erros + vr_registros_inexis) > 0 THEN
            -- Erro
            vr_dscritic := 'Arquivo foi processado, porém com erros de preenchimento. Linhas processadas: ' || vr_registros || 
                           '. Erros preenchimento: ' || vr_erros || '. Contas inexistentes: ' || vr_registros_inexis || 
                           '.';
            RAISE vr_exc_erro_negocio;
        END IF;
            
      EXCEPTION
          WHEN vr_exc_erro_negocio THEN
              ROLLBACK;
              --Log
              GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                   pr_cdoperad => vr_cdoperad,
                                   pr_dscritic => nvl(vr_dscritic,' ') || SQLERRM,
                                   pr_dsorigem => vr_dsorigem,
                                   pr_dstransa => NMDATELA||' - Importação cadastros cooperados filtro banner',
                                   pr_dttransa => TRUNC(SYSDATE),
                                   --> ERRO/FALSE
                                   pr_flgtrans => 0,
                                   pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                                   pr_idseqttl => 1,
                                   pr_nmdatela => vr_nmdatela,
                                   pr_nrdconta => 0,
                                   pr_nrdrowid => vr_nrdrowid);
              COMMIT;
              
              -- Erro
              pr_dscritic := vr_dscritic;
          WHEN vr_exc_erro THEN
              ROLLBACK;
              -- Erro
              pr_dscritic := vr_dscritic;
          WHEN OTHERS THEN
              ROLLBACK;
                
              -- Erro
              pr_cdcritic := 0;
              pr_dscritic := 'Erro na TELA_PARBAN.PC_IMPORTAR_ARQUIVO_FILTRO --> Veririque se o arquivo está em formato correto. ' || SQLERRM;
            
      END pc_importar_arquivo_filtro;
    --
      
    BEGIN
      
     -- Apaga os filtros anteriores
      DELETE FROM tbgen_banner_filtro_generico f
       WHERE f.cdbanner = pr_cdbanner
         AND f.cdcanal = pr_cdcanal;
         
      DELETE FROM tbgen_banner_filtro_especifico f
       WHERE f.cdbanner = pr_cdbanner
         AND f.cdcanal = pr_cdcanal;
    
      -- Se for filtro Genérico
      IF pr_tpfiltro = 0 THEN
        BEGIN
          INSERT INTO tbgen_banner_filtro_generico(cdbanner
                                                  ,cdcanal
                                                  ,dsfiltro_cooperativas
                                                  ,dsfiltro_tipos_conta
                                                  ,inoutros_filtros
                                                  ,dsfiltro_produto)
                                            VALUES(pr_cdbanner
                                                  ,pr_cdcanal
                                                  ,pr_dsfiltro_cooperativas
                                                  ,pr_dsfiltro_tipos_conta
                                                  ,pr_inoutros_filtros
                                                  ,pr_dsfiltro_produto);
          
        EXCEPTION
          WHEN OTHERS THEN
             pr_dscritic := 'Erro ao inserir registro (TBGEN_BANNER_FILTRO_GENERICO) - ' || pr_cdbanner || '. Erro: ' || SQLERRM;
             RAISE;  
        END;
      -- Se for filtro específico
      ELSIF pr_tpfiltro = 1 THEN
      
          pc_importar_arquivo_filtro(pr_cdbanner    => pr_cdbanner
                                    ,pr_cdcanal     => pr_cdcanal
                                    ,pr_arquivo     => pr_nmarquivo_upload
                                    ,pr_dirarquivo  => pr_caminho_arq_upload
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
                                    
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        ELSE  -- Senão, Dispara a EXCEPTION padrão
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina da tela PARBAN - '|| SQLERRM;
        END IF;
    END pc_inserir_filtro_banner;
    
    FUNCTION fn_valida_cadastro_banner(pr_tbgen_banner               IN tbgen_banner%ROWTYPE
                                  ,pr_tbgen_banner_filtro_gen    IN tbgen_banner_filtro_generico%ROWTYPE
                                  ,pr_tbgen_banner_filtro_esp    IN tbgen_banner_filtro_especifico%ROWTYPE
                                  ,pr_idacao_banner              IN NUMBER
                                  -- RETORNO
                                  ,pr_nmdcampo                   OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_dscritic                   OUT VARCHAR2 --> Mensagem de retorno de critica da validação
                                  ) RETURN NUMBER IS

      vr_exc_erro EXCEPTION;

    BEGIN
          
      /*VALIDA OS CAMPOS OBRIGATÓRIOS*/
      IF pr_tbgen_banner.DSTITULO_BANNER IS NULL THEN
        pr_dscritic:= 'Título é obrigatório';
      ELSIF pr_tbgen_banner.CDCANAL IS NULL THEN
        pr_dscritic:= 'Canal de atendimento é obrigatório';
      ELSIF pr_tbgen_banner.INSITUACAO_BANNER = 1 AND pr_tbgen_banner.NMIMAGEM_BANNER IS NULL THEN
        pr_dscritic:= 'Banner está ativo mas nenhuma imagem foi selecionada';
      ELSIF pr_tbgen_banner.INACAO_BANNER = 1 THEN -- Validações refetentes ao botão de ação
        IF pr_tbgen_banner.INEXIBE_MSG_CONFIRMACAO = 1 AND pr_tbgen_banner.DSMENSAGEM_ACAO_BANNER IS NULL THEN
        pr_dscritic:= 'O texto da mensagem de ação do Banner é obrigatório';
        ELSIF pr_idacao_banner = 1 AND pr_tbgen_banner.DSLINK_ACAO_BANNER IS NULL THEN
        pr_dscritic:= 'URL do banner é obrigatório';
        ELSIF pr_idacao_banner = 2 AND pr_tbgen_banner.CDMENU_ACAO_MOBILE IS NULL THEN
        pr_dscritic:= 'Tela do Ailos Mobile do Banner é obrigatória';
        END IF;
      ELSIF pr_tbgen_banner.INEXIBIR_QUANDO = 1 THEN
        IF pr_tbgen_banner.DTEXIBIR_DE > pr_tbgen_banner.DTEXIBIR_ATE THEN
          pr_dscritic:= 'Data inicial de exibição do banner é maior que a data final';
        END IF; 
      ELSIF pr_tbgen_banner.TPFILTRO = 0 THEN
        IF replace(pr_tbgen_banner_filtro_gen.dsfiltro_cooperativas,',','') IS NULL THEN
            pr_dscritic:= 'É necessário selecionar ao menos uma cooperativa';
        ELSIF replace(pr_tbgen_banner_filtro_gen.dsfiltro_tipos_conta,',','') IS NULL THEN
            pr_dscritic:= 'É necessário selecionar ao menos um tipo de conta';
        ELSIF  pr_tbgen_banner_filtro_gen.INOUTROS_FILTROS <> 0 AND pr_tbgen_banner_filtro_gen.DSFILTRO_PRODUTO IS NULL THEN
            pr_dscritic:= 'É necessário selecionar uma opção para outros filtros';
        END IF;
      ELSIF pr_tbgen_banner.TPFILTRO = 1 AND pr_tbgen_banner.cdbanner = 0 THEN
        IF pr_tbgen_banner.NMARQUIVO_UPLOAD IS NULL THEN
          pr_dscritic:= 'Arquivo de carga é obrigatório';   
        END IF;
      END IF;
          
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
          
      --Se passou por todas as validações
      RETURN 1;
          
    EXCEPTION
      WHEN OTHERS THEN
           RETURN 0;
    END fn_valida_cadastro_banner;

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    --Código do banner                        
    vr_cdbanner := nvl(pr_cdbanner,0);
    
    -- Converte parametro para tipo data  
    vr_dtexibir_de    := TRUNC(TO_DATE(pr_dtexibir_de,'dd/mm/RRRR'));
    vr_dtexibir_ate   :=  TRUNC(TO_DATE(pr_dtexibir_ate,'dd/mm/RRRR'));
    
    --RowType TBGEN_BANNER
    vr_tbgen_banner.CDBANNER                  := vr_cdbanner;
    vr_tbgen_banner.CDCANAL                   := pr_cdcanal;
    vr_tbgen_banner.DSTITULO_BANNER           := pr_dstitulo_banner;
    vr_tbgen_banner.INSITUACAO_BANNER         := pr_insituacao_banner;
    vr_tbgen_banner.NMIMAGEM_BANNER           := pr_nmimagem_banner;
    vr_tbgen_banner.INACAO_BANNER             := pr_inacao_banner;
    vr_tbgen_banner.CDMENU_ACAO_MOBILE        := pr_cdmenu_acao_mobile;
    vr_tbgen_banner.DSLINK_ACAO_BANNER        := pr_dslink_acao_banner;
    vr_tbgen_banner.INEXIBE_MSG_CONFIRMACAO   := pr_inexibe_msg_confirmacao;
    vr_tbgen_banner.DSMENSAGEM_ACAO_BANNER    := pr_dsmensagem_acao_banner;
    vr_tbgen_banner.TPFILTRO                  := pr_tpfiltro;
    vr_tbgen_banner.INEXIBIR_QUANDO           := pr_inexibir_quando;
    vr_tbgen_banner.DTEXIBIR_DE               := vr_dtexibir_de;
    vr_tbgen_banner.DTEXIBIR_ATE              := vr_dtexibir_ate;
    vr_tbgen_banner.NMARQUIVO_UPLOAD          := pr_nmarquivo_upload;
    --RowType TBGEN_BANNER_FILTRO_GENERICO
    vr_tbgen_banner_filtro_gen.CDBANNER               := vr_cdbanner;
    vr_tbgen_banner_filtro_gen.CDCANAL                := pr_cdcanal;
    vr_tbgen_banner_filtro_gen.DSFILTRO_COOPERATIVAS  := pr_dsfiltro_cooperativas;
    vr_tbgen_banner_filtro_gen.DSFILTRO_TIPOS_CONTA   := pr_dsfiltro_tipos_conta;
    vr_tbgen_banner_filtro_gen.INOUTROS_FILTROS       := pr_inoutros_filtros;
    vr_tbgen_banner_filtro_gen.DSFILTRO_PRODUTO       := pr_dsfiltro_produto;
    --RowType TBGEN_BANNER_FILTRO_ESPECIFICO
    vr_tbgen_banner_filtro_esp.CDBANNER          := vr_cdbanner;
    vr_tbgen_banner_filtro_esp.CDCANAL           := pr_cdcanal;
    
    --Efetua a validação dos dados
    vr_validacao := fn_valida_cadastro_banner(pr_tbgen_banner              => vr_tbgen_banner
                                             ,pr_tbgen_banner_filtro_gen   => vr_tbgen_banner_filtro_gen
                                             ,pr_tbgen_banner_filtro_esp   => vr_tbgen_banner_filtro_esp
                                             ,pr_idacao_banner             => pr_idacao_banner
                                             ,pr_nmdcampo                  => pr_nmdcampo   
                                             ,pr_dscritic                  => vr_dscritic);
                            
    IF vr_validacao = 0 THEN
      RAISE vr_exc_erro;
    END IF;
    
    --Cadastro novo do banner                        
    IF nvl(vr_cdbanner,0) = 0 THEN
      -- Gera o sequencial do Banner
      BEGIN
        SELECT seqgen_banner_id.nextval
         INTO  vr_cdbanner
         FROM  dual;
      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao gerar sequencial do banner (SEQGEN_BANNER_ID) - ' || '. Erro: ' || SQLERRM;
           RAISE;  
      END;
      --
      BEGIN
        INSERT INTO tbgen_banner(cdbanner
                                ,cdcanal
                                ,dstitulo_banner
                                ,insituacao_banner
                                ,nmimagem_banner
                                ,inacao_banner
                                ,cdmenu_acao_mobile
                                ,dslink_acao_banner
                                ,inexibe_msg_confirmacao
                                ,dsmensagem_acao_banner
                                ,tpfiltro
                                ,inexibir_quando
                                ,dtexibir_de
                                ,dtexibir_ate
                                ,nmarquivo_upload)
                          VALUES(vr_cdbanner
                                ,pr_cdcanal
                                ,pr_dstitulo_banner
                                ,pr_insituacao_banner
                                ,pr_nmimagem_banner
                                ,pr_inacao_banner
                                ,DECODE(pr_idacao_banner,2,pr_cdmenu_acao_mobile,NULL)
                                ,DECODE(pr_idacao_banner,1,pr_dslink_acao_banner,NULL)
                                ,pr_inexibe_msg_confirmacao
                                ,pr_dsmensagem_acao_banner
                                ,pr_tpfiltro
                                ,pr_inexibir_quando
                                ,vr_dtexibir_de
                                ,vr_dtexibir_ate
                                ,decode(pr_tpfiltro,1,pr_nmarquivo_upload,NULL));
        
      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir registro (TBGEN_BANNER) - ' || '. Erro: ' || SQLERRM;
           RAISE;  
      END;
      --
      
      BEGIN
        UPDATE tbgen_banner_param tbpa
           SET tbpa.dsbannerorder = vr_cdbanner || NVL2(tbpa.dsbannerorder, ',','') || tbpa.dsbannerorder
         WHERE tbpa.cdcanal = pr_cdcanal;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a ordem dos banners. '||' Erro: '||SQLERRM;
          RAISE;
      END;
      
    ELSE -- Atualização do banner
      BEGIN
        UPDATE tbgen_banner
           SET dstitulo_banner           = pr_dstitulo_banner
              ,insituacao_banner         = pr_insituacao_banner
              ,nmimagem_banner           = pr_nmimagem_banner
              ,inacao_banner             = pr_inacao_banner
              ,cdmenu_acao_mobile        = DECODE(pr_idacao_banner,2,pr_cdmenu_acao_mobile,NULL)
              ,dslink_acao_banner        = DECODE(pr_idacao_banner,1,pr_dslink_acao_banner,NULL)
              ,inexibe_msg_confirmacao   = pr_inexibe_msg_confirmacao
              ,dsmensagem_acao_banner    = DECODE(pr_inexibe_msg_confirmacao,1,pr_dsmensagem_acao_banner,NULL)
              ,tpfiltro                  = pr_tpfiltro
              ,inexibir_quando           = pr_inexibir_quando
              ,dtexibir_de               = DECODE(pr_inexibir_quando,1,vr_dtexibir_de,NULL)
              ,dtexibir_ate              = DECODE(pr_inexibir_quando,1,vr_dtexibir_ate,NULL)
              ,nmarquivo_upload          = CASE WHEN pr_tpfiltro = 1 AND pr_nmarquivo_upload IS NOT NULL THEN
                                              pr_nmarquivo_upload
                                              WHEN pr_tpfiltro = 0 THEN
                                                NULL
                                              ELSE
                                                nmarquivo_upload
                                           END     
        WHERE cdbanner = vr_cdbanner
          AND cdcanal  = pr_cdcanal;   
       EXCEPTION
        WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro (TBGEN_BANNER) - ' || vr_cdbanner || '. Erro: ' || SQLERRM;
         RAISE;                                     
      END;
    END IF;
    
    -- Insere os filtros do banner
    pc_inserir_filtro_banner(pr_cdbanner              => vr_cdbanner             
                            ,pr_cdcanal               => pr_cdcanal              
                            ,pr_tpfiltro              => pr_tpfiltro             
                            --
                            ,pr_dsfiltro_cooperativas => pr_dsfiltro_cooperativas
                            ,pr_dsfiltro_tipos_conta  => pr_dsfiltro_tipos_conta 
                            ,pr_inoutros_filtros      => pr_inoutros_filtros     
                            ,pr_dsfiltro_produto      => pr_dsfiltro_produto     
                            --
                            ,pr_nmarquivo_upload      => pr_nmarquivo_upload     
                            ,pr_caminho_arq_upload    => pr_caminho_arq_upload   
                            --
                            ,pr_cdcritic              => vr_cdcritic
                            ,pr_dscritic              => vr_dscritic);
    IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
                        
  EXCEPTION
      WHEN OTHERS THEN
        IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        ELSE  -- Senão, Dispara a EXCEPTION padrão
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||' - '|| SQLERRM;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;  
  END;
  
begin
  
  -- Gera log no início da execução
  pc_log_programa(pr_dstiplog   => 'I'         
                 ,pr_cdprograma => 'BACA-AGP-MSG'
                 ,pr_cdcooper   => 0
                 ,pr_tpexecucao => 0     
                 ,pr_idprglog   => vr_idprglog);

  begin
    -- Burla xml e passa coop
    pr_retxml := xmltype(pr_auxiliar);
  exception
    when others then
      vr_dscritic := 'Erro ao atribuir xml: '||sqlerrm;
      raise vr_exc_saida;
  end;

  begin
    -- Busca endereco do arquivo
    select prm.dsvlrprm
      into vr_caminho_arq_upload
      from crapprm prm
     where prm.cdacesso = 'SRVINTRA';
     vr_caminho_arq_upload := vr_caminho_arq_upload||'/upload_files/';
  exception
    when others then
      vr_dscritic := 'Erro ao buscar caminho para upload: '||sqlerrm;
      raise vr_exc_saida;
  end;

  for rw_crapage in cr_crapage loop

    begin
      -- Buscar data de fim de exibicao
      select adp.dtfineve
        into vr_dtexibir_ate
        from crapldp ldp
           , crapadp adp
       where ldp.cdcooper = rw_crapage.cdcooper
         and ldp.cdagenci = rw_crapage.cdagenci
         and adp.nrdgrupo = rw_crapage.nrdgrupo
         and ldp.cdcooper = adp.cdcooper
         and ldp.nrseqdig = adp.cdlocali
         and adp.idevento = 2
         and adp.dtanoage = 2019;
     -- Apresenta ate o dia seguinte
     vr_dtexibir_ate := vr_dtexibir_ate;
    exception
      when no_data_found then
        continue;
      when others then
        vr_dscritic := 'Erro ao buscar data fim da assembleia: '||sqlerrm;
        raise vr_exc_saida;
    end;
    
    if vr_dtexibir_ate <= trunc(sysdate) then
      continue;
    end if;

    -- Listar arquivos (retorna somente um)
    gene0001.pc_lista_arquivos(pr_path     => vr_nmdirarq
                              ,pr_pesq     => 'lst-arq-grp-'||lpad(rw_crapage.cdcooper,2,'0')||'-'||
                                                              lpad(rw_crapage.cdagenci,3,'0')||'-'||
                                                              lpad(rw_crapage.nrdgrupo,2,'0')||'-%'
                              ,pr_listarq  => vr_nmarquivo_upload
                              ,pr_des_erro => vr_dscritic);
                                
    -- Se ocorreu erro, cancela o programa
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
      
    -- Verifica retorno da rotina 
    if instr(vr_nmarquivo_upload,',') > 0 then
      vr_dscritic := 'Erro na rotina gene0001.pc_lista_arquivos: retorno de mais de um arquivo.';
      raise vr_exc_saida;
    elsif trim(vr_nmarquivo_upload) is null then
      vr_dscritic := 'Erro na rotina gene0001.pc_lista_arquivos: arquivo nao encontrado.';
      raise vr_exc_saida;
    end if;
      
    -- Procedure que insere o internet banking
    pc_manter_banner(pr_cdbanner                => 0
                    ,pr_cdcanal                 => 3
                    ,pr_dstitulo_banner         => 'Eventos Assembleares - 2019'
                    -- Variavel
                    ,pr_insituacao_banner       => 1
                    ,pr_nmimagem_banner         => 'AGC'||lpad(rw_crapage.cdcooper,2,'0')||'_'||
                                                   lpad(rw_crapage.cdagenci,3,'0')       ||'_'||
                                                   lpad(rw_crapage.nrdgrupo,2,'0')||'.jpg'
                    ,pr_inacao_banner           => 0
                    ,pr_cdmenu_acao_mobile      => null
                    ,pr_dslink_acao_banner      => null
                    ,pr_inexibe_msg_confirmacao => 0
                    ,pr_idacao_banner           => 0
                    ,pr_dsmensagem_acao_banner  => null
                    ,pr_tpfiltro                => 1
                    ,pr_inexibir_quando         => 1
                    ,pr_dtexibir_de             => to_date(trunc(sysdate),'dd/mm/yyyy')
                    ,pr_dtexibir_ate            => vr_dtexibir_ate
                    ,pr_nmarquivo_upload        => vr_nmarquivo_upload
                    ,pr_caminho_arq_upload      => vr_caminho_arq_upload
                    --
                    ,pr_dsfiltro_cooperativas   => rw_crapage.cdcooper
                    ,pr_dsfiltro_tipos_conta    => '1,2'
                    ,pr_inoutros_filtros        => 0
                    ,pr_dsfiltro_produto        => 0
                    --
                    ,pr_xmllog                  => vr_xmllog
                    ,pr_cdcritic                => vr_cdcritic
                    ,pr_dscritic                => vr_dscritic
                    ,pr_retxml                  => pr_retxml
                    ,pr_nmdcampo                => vr_nmdcampo
                    ,pr_des_erro                => vr_des_erro);

    -- Aborta em caso de critica
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      vr_dscritic := 'Erro na rotina pc_manter_banner: '||vr_dscritic;
      raise vr_exc_saida;
    end if;
  
    commit;

  end loop;

  commit;

  dbms_output.put_line('Sucesso!');

  -- Gera log no início da execução
  pc_log_programa(pr_dstiplog   => 'F'         
                 ,pr_cdprograma => 'BACA-AGP-MSG'
                 ,pr_cdcooper   => 0
                 ,pr_tpexecucao => 0     
                 ,pr_idprglog   => vr_idprglog);
  
exception
  
  when vr_exc_saida then

    rollback;
     
    dbms_output.put_line(vr_dscritic);
                  
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => 'ERRO-BACA-AGP-MSG-1'
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   -- Job
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critica
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                          ,pr_idprglog      => vr_idprglog);
  
    commit;  
  
  when others then

    rollback;

    vr_cdcritic:= 0;
    vr_dscritic:= 'Erro no baca de '||
                  'automatizacao de banners (P484) --> '||
                   vr_dscritic||' - '||sqlerrm;
                   
    dbms_output.put_line(vr_dscritic);
                   
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => 'ERRO-BACA-AGP-MSG-2'
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   -- Job
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critica
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                          ,pr_idprglog      => vr_idprglog);
  
    commit;  
  
end;