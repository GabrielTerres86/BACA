CREATE OR REPLACE PACKAGE CECRED.TELA_MANCAR IS

  PROCEDURE pc_consulta_mancar(pr_nrcpf_cnpj           IN VARCHAR2 --> CPF ou CNPJ
                              ,pr_nmcartorio           IN VARCHAR2 --> Nome do cartório
                              ,pr_nrregist             IN NUMBER DEFAULT 30   --> Quantidade de registros
                              ,pr_nriniseq             IN NUMBER DEFAULT 1   --> Qunatidade inicial
                              ,pr_uf                   IN VARCHAR2 DEFAULT NULL
                              ,pr_idcidade             IN NUMBER DEFAULT 0
                              ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro             OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_atualiza_mancar(pr_idcartorio           IN tbcobran_cartorio_protesto.idcartorio%TYPE --> Identificador do cartório
                            ,pr_nrcpf_cnpj             IN VARCHAR2 --> CPF ou CNPJ
                            ,pr_nmcartorio             IN tbcobran_cartorio_protesto.nmcartorio%TYPE --> Nome do cartório
                            ,pr_idcidade               IN tbcobran_cartorio_protesto.idcidade%TYPE --> Id da cidade
                            ,pr_flgativo               IN INTEGER --> Flag ativo
                            ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic               OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic               OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml                 IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo               OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro               OUT VARCHAR2); --> Erros do processo
                            
  PROCEDURE pc_exclui_mancar(pr_idcartorio             IN tbcobran_cartorio_protesto.idcartorio%TYPE --> Identificador do cartório
                            ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic               OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic               OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml                 IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo               OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro               OUT VARCHAR2); --> Erros do processo

END TELA_MANCAR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MANCAR IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_MANCAR
  --  Sistema  : Ayllos Web
  --  Autor    : André Clemer
  --  Data     : Abril - 2018                 Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela MANCAR
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_mancar(pr_nrcpf_cnpj           IN VARCHAR2 --> CPF ou CNPJ
                              ,pr_nmcartorio           IN VARCHAR2 --> Nome do cartório
                              ,pr_nrregist             IN NUMBER DEFAULT 30   --> Quantidade de registros
                              ,pr_nriniseq             IN NUMBER DEFAULT 1   --> Qunatidade inicial
                              ,pr_uf                   IN VARCHAR2 DEFAULT NULL
                              ,pr_idcidade             IN NUMBER DEFAULT 0
                              ,pr_xmllog               IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic             OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic             OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro             OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_consulta_mancar
    Sistema : Ayllos Web
    Autor   : André Clemer
    Data    : Abril/2018                 Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar cartorios.

    Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados da parametrizacao
      CURSOR cr_cartorio(pr_nrcpf_cnpj IN VARCHAR2
                        ,pr_nmcartorio IN VARCHAR2
                        ,pr_uf         IN VARCHAR2
                        ,pr_idcidade   IN NUMBER) IS

              SELECT nrcpf_cnpj,
                     nmcartorio,
                     idcidade,
                     dscidade,
                     flgativo,
                     idcartorio,
                     rnum,
                     qtregtot
                FROM (SELECT tcp.nrcpf_cnpj,
                     tcp.nmcartorio,
                     tcp.idcidade,
                     mun.dscidade,
                     tcp.flgativo,
                     tcp.idcartorio,
                     ROW_NUMBER() OVER (ORDER BY tcp.nrcpf_cnpj, tcp.nmcartorio) rnum,
                     COUNT(1) over () qtregtot
                FROM tbcobran_cartorio_protesto tcp
          INNER JOIN crapmun mun ON tcp.idcidade = mun.idcidade
                WHERE tcp.idcidade = nvl(pr_idcidade, tcp.idcidade)
                 AND tcp.nmcartorio = nvl(pr_nmcartorio, tcp.nmcartorio)
                 AND tcp.nrcpf_cnpj = nvl(pr_nrcpf_cnpj, tcp.nrcpf_cnpj)
                 AND mun.cdestado = nvl(pr_uf, mun.cdestado)
            ORDER BY tcp.nrcpf_cnpj,
                     tcp.nmcartorio
        ) WHERE (rnum >= pr_nriniseq AND 
                rnum <= (pr_nriniseq + pr_nrregist-1))
             OR pr_nrregist = 0;

      rw_cartorio cr_cartorio%ROWTYPE;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_index INTEGER := 0;
      vr_auxconta INTEGER := 0;

    BEGIN

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
      FOR rw_cartorio IN cr_cartorio(pr_nrcpf_cnpj => pr_nrcpf_cnpj
                                    ,pr_nmcartorio => pr_nmcartorio
                                    ,pr_uf => pr_uf
                                    ,pr_idcidade => pr_idcidade) LOOP
                                    
              -- Incrementa o contador de registros
              vr_index := vr_index + 1;

                
              -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
              IF vr_index = 1 THEN
                    
                GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Root'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'Dados'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
                                          
                GENE0007.pc_insere_tag(pr_xml => pr_retxml
                                  ,pr_tag_pai => 'Root'
                                  ,pr_posicao => 0
                                  ,pr_tag_nova => 'qtregist'
                                  ,pr_tag_cont => rw_cartorio.qtregtot
                                  ,pr_des_erro => vr_dscritic);
              END IF;
                                    
              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cartorio'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
                                        
              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'cartorio'
                                    ,pr_posicao  => vr_auxconta
                                    ,pr_tag_nova => 'nrcpf_cnpj'
                                    ,pr_tag_cont => rw_cartorio.nrcpf_cnpj
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'cartorio'
                                    ,pr_posicao  => vr_auxconta
                                    ,pr_tag_nova => 'nmcartorio'
                                    ,pr_tag_cont => rw_cartorio.nmcartorio
                                    ,pr_des_erro => vr_dscritic);
                                      
              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'cartorio'
                                    ,pr_posicao  => vr_auxconta
                                    ,pr_tag_nova => 'idcidade'
                                    ,pr_tag_cont => rw_cartorio.idcidade
                                    ,pr_des_erro => vr_dscritic);
                                    
              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'cartorio'
                                    ,pr_posicao  => vr_auxconta
                                    ,pr_tag_nova => 'dscidade'
                                    ,pr_tag_cont => rw_cartorio.dscidade
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'cartorio'
                                    ,pr_posicao  => vr_auxconta
                                    ,pr_tag_nova => 'flgativo'
                                    ,pr_tag_cont => rw_cartorio.flgativo
                                    ,pr_des_erro => vr_dscritic);

              GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                    ,pr_tag_pai  => 'cartorio'
                                    ,pr_posicao  => vr_auxconta
                                    ,pr_tag_nova => 'idcartorio'
                                    ,pr_tag_cont => rw_cartorio.idcartorio
                                    ,pr_des_erro => vr_dscritic);
                                        
              vr_auxconta := vr_auxconta + 1;
                                    
              

      END LOOP;
      
      IF cr_cartorio%ISOPEN THEN
        CLOSE cr_cartorio;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela MANCAR: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_consulta_mancar;

  PROCEDURE pc_atualiza_mancar(pr_idcartorio           IN tbcobran_cartorio_protesto.idcartorio%TYPE --> Identificador do cartório
                            ,pr_nrcpf_cnpj             IN VARCHAR2 --> CPF ou CNPJ
                            ,pr_nmcartorio             IN tbcobran_cartorio_protesto.nmcartorio%TYPE --> Nome do cartório
                            ,pr_idcidade               IN tbcobran_cartorio_protesto.idcidade%TYPE --> Id da cidade
                            ,pr_flgativo               IN INTEGER --> Flag ativo
                            ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic               OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic               OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml                 IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo               OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro               OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_atualiza_mancar
    Sistema : Ayllos Web
    Autor   : André Clemer
    Data    : Abril/2018                 Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar cartorios

    Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN
    
      IF pr_idcartorio > 0 THEN
         BEGIN
            UPDATE tbcobran_cartorio_protesto
               SET idcidade    = pr_idcidade
                   ,nrcpf_cnpj = pr_nrcpf_cnpj
                   ,nmcartorio = pr_nmcartorio
                   ,flgativo   = NVL(pr_flgativo,1)
             WHERE idcartorio = pr_idcartorio;

          EXCEPTION
            WHEN OTHERS THEN
                 vr_dscritic := 'Problema ao atualizar cartorio: ' || SQLERRM;
                 RAISE vr_exc_saida;
          END;
      ELSE
         BEGIN
            INSERT INTO tbcobran_cartorio_protesto
                   (nrcpf_cnpj
                   ,nmcartorio
                   ,idcidade
                   ,flgativo)
             VALUES(pr_nrcpf_cnpj
                   ,pr_nmcartorio
                   ,pr_idcidade
                   ,NVL(pr_flgativo, 1));

          EXCEPTION
            WHEN OTHERS THEN
                 vr_dscritic := 'Problema ao incluir cartorio: ' || SQLERRM;
                 RAISE vr_exc_saida;
          END;
      END IF;
    
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela MANCAR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_atualiza_mancar;
  
  PROCEDURE pc_exclui_mancar(pr_idcartorio             IN tbcobran_cartorio_protesto.idcartorio%TYPE --> Identificador do cartório
                            ,pr_xmllog                 IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic               OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic               OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml                 IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo               OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro               OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_mancar
    Sistema : Ayllos Web
    Autor   : André Clemer
    Data    : Abril/2018                 Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir cartório

    Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN
    
      IF pr_idcartorio > 0 THEN
         BEGIN
            DELETE FROM tbcobran_cartorio_protesto WHERE idcartorio = pr_idcartorio;

          EXCEPTION
            WHEN OTHERS THEN
                 vr_dscritic := 'Problema ao excluir cartorio: ' || SQLERRM;
                 RAISE vr_exc_saida;
          END;
      ELSE
         vr_dscritic := 'Problema ao excluir cartorio';
         RAISE vr_exc_saida;
      END IF;
    
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela MANCAR: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_mancar;

END TELA_MANCAR;
/
