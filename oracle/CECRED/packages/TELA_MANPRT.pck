CREATE OR REPLACE PACKAGE CECRED.TELA_MANPRT IS

  PROCEDURE pc_consulta_teds(pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                         	  ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                            ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                            ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                            ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                            ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                            ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2);

  PROCEDURE pc_exporta_consulta_teds(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                        	  	    ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                    ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                                    ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2);   

  PROCEDURE pc_exporta_consulta_teds_pdf(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                        ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                         	  	        ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                        ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                        ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                        ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                        ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                        ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                        ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                        ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                        ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                        ,pr_des_erro      OUT VARCHAR2);
END TELA_MANPRT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MANPRT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_MANPRT
  --  Sistema  : Ayllos Web
  --  Autor    : Helinton Steffens (Supero)
  --  Data     : Janeiro - 2018                 Ultima atualizacao: 29/01/2018
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PARPRT
  --
  -- Alteracoes: Adaptado script para contemplar os parametros da tela PARPRT
  --
  ---------------------------------------------------------------------------
    CURSOR cr_tbfin_recursos_movimento(pr_dtinicial    IN VARCHAR2
                                     ,pr_dtfinal       IN VARCHAR2
                                     ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE
                                     ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE
              ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE) IS
    SELECT cartorio.nmcartorio as nome_cartorio
          ,ted.nmtitular_debitada as nome_remetente
          ,ted.nrcnpj_debitada as cnpj_cpf
          --,banco.nmresbcc as nome_banco
          ,banco.cdbccxlt  as nome_banco
          --,agencia.nmageban as nome_agencia
          ,agencia.cdageban as nome_agencia
          ,ted.dsconta_debitada as conta
          ,ted.dtmvtolt as data_recebimento
          ,ted.vllanmto as valor
          ,municipio.cdestado as nome_estado
          ,municipio.dscidesp as nome_cidade
          ,'PENDENTE' as status
    FROM tbfin_recursos_movimento ted
         inner join crapban banco on (ted.nmif_debitada = banco.nrispbif)
         inner join crapagb agencia on (agencia.cddbanco = banco.cdbccxlt and cdagenci_debitada = agencia.cdageban)
         left outer join crapmun municipio on (municipio.cdcidade = agencia.cdcidade)
         left outer join tbcobran_cartorio_protesto cartorio on (ted.nrcnpj_debitada = cartorio.nrcpf_cnpj 
                                                    and ted.nmtitular_debitada = cartorio.nmcartorio)
    WHERE ted.dsdebcre = 'C'
     and ((ted.dtmvtolt between to_date(pr_dtinicial,'DD/MM/RRRR') and to_date(pr_dtfinal,'DD/MM/RRRR')) 
         or (pr_dtinicial is null and pr_dtfinal is null))
     and ((ted.vllanmto >= pr_vlinicial and ted.vllanmto <= pr_vlfinal) 
         or (pr_vlinicial = 0 and pr_vlfinal = 0))
     and (ted.nrcnpj_debitada = pr_cartorio or pr_cartorio is null)
    ORDER BY ted.dtmvtolt, ted.nrcnpj_debitada;  
    rw_tbfin_recursos_movimento cr_tbfin_recursos_movimento%ROWTYPE;
    
  PROCEDURE pc_consulta_teds(pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                            ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                            ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                            ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                            ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                            ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                            ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                            ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                            ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                            ,pr_retxml        IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                            ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                            ,pr_des_erro      OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_busca_teds                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Helinton Steffens (Supero)
    Data     : Março/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Pesquisa de teds recebidas pelo IEPTB

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_nrregist INTEGER;
    vr_contador INTEGER :=0;
    vr_flgfirst BOOLEAN := TRUE;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

    BEGIN

      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Inicializar Variaveis
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'inf'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic); 

    FOR rw_tbfin_recursos_movimento IN cr_tbfin_recursos_movimento(pr_dtinicial => pr_dtinicial
                                                ,pr_dtfinal   => pr_dtfinal
                        ,pr_vlinicial => pr_vlinicial
                        ,pr_vlfinal   => pr_vlfinal
                        ,pr_cartorio  => pr_cartorio) LOOP

      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proxima TED
        CONTINUE;
      END IF;

      --Numero Registros
      IF vr_nrregist > 0 THEN
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmcartorio', pr_tag_cont => rw_tbfin_recursos_movimento.nome_cartorio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmremetente', pr_tag_cont => rw_tbfin_recursos_movimento.nome_remetente, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cnpj_cpf', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_tbfin_recursos_movimento.cnpj_cpf,1), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'banco', pr_tag_cont => rw_tbfin_recursos_movimento.nome_banco, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'agencia', pr_tag_cont => rw_tbfin_recursos_movimento.nome_agencia, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'conta', pr_tag_cont => rw_tbfin_recursos_movimento.conta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtrecebimento', pr_tag_cont => to_char(rw_tbfin_recursos_movimento.data_recebimento,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'valor', pr_tag_cont => rw_tbfin_recursos_movimento.valor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'estado', pr_tag_cont => rw_tbfin_recursos_movimento.nome_estado, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cidade', pr_tag_cont => rw_tbfin_recursos_movimento.nome_cidade, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'status', pr_tag_cont => rw_tbfin_recursos_movimento.status, pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
        vr_flgfirst := FALSE;

      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;
                                            
                          
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'             --> Nome do atributo
                             ,pr_atval => vr_qtregist    --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_teds --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_teds;
  
  PROCEDURE pc_exporta_consulta_teds(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            	      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted                       
                                    ,pr_nrregist      IN INTEGER                 -- Quantidade de registros
                                    ,pr_nriniseq      IN INTEGER                 -- Qunatidade inicial
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_teds
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de teds a conciliar - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_dsretorn VARCHAR2(1000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper_conectado NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    -- Variaveis gerais
    vr_dsxmlrel CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_dsdiretorio VARCHAR2(1000);      --> Local onde sera gerado o relatorio
    vr_nmarquivo   VARCHAR2(1000);      --> Nome do relatorio CSV
    
  BEGIN                                                  
    -- Cria a variavel CLOB
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Busca o diretorio onde esta os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO')||'/relatorios';
    vr_nmarquivo := 'MANPRT_'||to_char(SYSDATE,'HHMISS')||'.csv';
    -- Criar cabeçalho do CSV
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => 'Cartorio;Remetente;CPF/CNPJ;Banco;Agencia;Conta;Data Rec;Valor;Estado;Cidade;Status'||chr(10));
    
    FOR rw_tbfin_recursos_movimento IN cr_tbfin_recursos_movimento(pr_dtinicial => pr_dtinicial
                                                                  ,pr_dtfinal   => pr_dtfinal
                                                                  ,pr_vlinicial => pr_vlinicial
                                                                  ,pr_vlfinal   => pr_vlfinal
                                                                  ,pr_cartorio  => pr_cartorio) LOOP
      -- Carrega os dados
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => rw_tbfin_recursos_movimento.nome_cartorio      ||';'||
                                                   rw_tbfin_recursos_movimento.nome_remetente     ||';'||
                                                   rw_tbfin_recursos_movimento.cnpj_cpf           ||';'||
                                                   rw_tbfin_recursos_movimento.nome_banco         ||';'||
                                                   rw_tbfin_recursos_movimento.nome_agencia       ||';'||
                                                   rw_tbfin_recursos_movimento.conta              ||';'||
                                                   rw_tbfin_recursos_movimento.data_recebimento   ||';'||
                                                   rw_tbfin_recursos_movimento.valor              ||';'||
                                                   rw_tbfin_recursos_movimento.nome_estado        ||';'||
                                                   rw_tbfin_recursos_movimento.nome_cidade        ||';'||
                                                   rw_tbfin_recursos_movimento.status        ||chr(10));
    END LOOP;
    -- Encerrar o Clob
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => ' '
                           ,pr_fecha_xml      => TRUE);

    -- Gera o relatorio
    GENE0002.pc_clob_para_arquivo(pr_clob => vr_clob,
                                  pr_caminho => vr_dsdiretorio,
                                  pr_arquivo => vr_nmarquivo,
                                  pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;

    -- copia contrato pdf do diretorio da cooperativa para servidor web
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                               , pr_cdagenci => NULL
                               , pr_nrdcaixa => NULL
                               , pr_nmarqpdf => vr_dsdiretorio||'/'||vr_nmarquivo
                               , pr_des_reto => vr_des_reto
                               , pr_tab_erro => vr_tab_erro
                               );

    -- caso apresente erro na operação
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
       IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
     END IF;

     -- Remover relatorio do diretorio padrao da cooperativa
     gene0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => 'rm '||vr_dsdiretorio||'/'||vr_nmarquivo
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_dscritic);

     -- Se retornou erro
     IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
     END IF;

     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarquivo|| '</nmarqcsv>');

     -- Libera a memoria do CLOB
     dbms_lob.close(vr_clob);
     dbms_lob.freetemporary(vr_clob);
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_exporta_consulta_teds: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_exporta_consulta_teds;

  PROCEDURE pc_exporta_consulta_teds_pdf(pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa
                                    ,pr_dtinicial     IN VARCHAR2 -- Data inicial de recebimento de ted
                            	      ,pr_dtfinal       IN VARCHAR2 -- Data final de recebimento de ted
                                    ,pr_vlinicial     IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor inicial de comparação ted
                                    ,pr_vlfinal       IN tbfin_recursos_movimento.vllanmto%TYPE -- Valor final de comparação ted
                                    ,pr_cartorio      IN tbfin_recursos_movimento.nrcnpj_debitada%TYPE -- Cartorio da ted
                                    ,pr_xmllog        IN VARCHAR2                -- XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2               -- Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY xmltype      -- Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2               -- Nome do Campo
                                    ,pr_des_erro      OUT VARCHAR2) IS
	/* ............................................................................

       Programa: pc_exporta_consulta_teds
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Abril/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de teds a conciliar - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(10);
    vr_typ_saida      VARCHAR2(3);
    
    -- Tratamento de erros
    vr_exc_erro      EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Data do movimento
    vr_dtmvtolt      crapdat.dtmvtolt%type;
    
    -- Variável para armazenar as informações em XML
    vr_des_xml       clob;
    vr_typsaida     VARCHAR2(100); 
    
    -- Variável para o caminho e nome do arquivo base
    vr_dsdireto   varchar2(200);
    vr_nmarquivo  varchar2(200);
    vr_dscomand   varchar2(200);
    
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in clob) is
    begin
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    end;
    
  BEGIN                                                  
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><consulta_ted>');
    pc_escreve_xml('<cdcooper>'     ||pr_cdcooper	    ||'</cdcooper>'||
                   '<dtinicial>'    ||pr_dtinicial    ||'</dtinicial>'||
                   '<dtfinal>'      ||pr_dtfinal      ||'</dtfinal>'||
                   '<vlinicial>'    ||pr_vlinicial    ||'</vlinicial>'||
                   '<vlfinal>'      ||pr_vlfinal      ||'</vlfinal>'||
                   '<dscartorio>'   ||pr_cartorio     ||'</dscartorio>'||
                   '<Columns>'      ||
		               '<column1>'      ||'Cartório'      ||'</column1>'||
		               '<column2>'      ||'Remetente'     ||'</column2>'||
		               '<column3>'      ||'Banco'         ||'</column3>'||
		               '<column4>'      ||'Agência'       ||'</column4>'||
		               '<column5>'      ||'Conta'         ||'</column5>'||
		               '<column6>'      ||'Data Rec.'     ||'</column6>'||
		               '<column7>'      ||'Valor'         ||'</column7>'||
		               '<column8>'      ||'Estado'        ||'</column8>'||
		               '<column9>'      ||'Cidade'         ||'</column9>'||
		               '<column10>'     ||'Status Conc.'  ||'</column10>'||
	                 '</Columns>');
                   
    pc_escreve_xml('<teds>');
                   
    FOR rw_tbfin_recursos_movimento IN cr_tbfin_recursos_movimento(pr_dtinicial => pr_dtinicial
                                                                  ,pr_dtfinal   => pr_dtfinal
                                                                  ,pr_vlinicial => pr_vlinicial
                                                                  ,pr_vlfinal   => pr_vlfinal
                                                                  ,pr_cartorio  => pr_cartorio) LOOP
      pc_escreve_xml('<ted>');
      pc_escreve_xml('<nmcartorio>'     ||rw_tbfin_recursos_movimento.nome_cartorio                            ||'</nmcartorio>'||
                     '<nmremetente>'    ||rw_tbfin_recursos_movimento.nome_remetente                           ||'</nmremetente>'||
                     '<iddocumento>'    ||gene0002.fn_mask_cpf_cnpj(rw_tbfin_recursos_movimento.cnpj_cpf,1)    ||'</iddocumento>'||
                     '<banco>'          ||rw_tbfin_recursos_movimento.nome_banco                               ||'</banco>'||
                     '<agencia>'        ||rw_tbfin_recursos_movimento.nome_agencia                             ||'</agencia>'||
                     '<conta>'          ||rw_tbfin_recursos_movimento.conta                                    ||'</conta>'||
                     '<dtrecebimento>'  ||to_char(rw_tbfin_recursos_movimento.data_recebimento, 'DD/MM/RRRR')  ||'</dtrecebimento>'||
                     '<valor>'          ||rw_tbfin_recursos_movimento.valor                                    ||'</valor>'||
                     '<estado>'         ||rw_tbfin_recursos_movimento.nome_estado                              ||'</estado>'||
                     '<cidade>'         ||rw_tbfin_recursos_movimento.nome_cidade                              ||'</cidade>'||
                     '<status>'         ||rw_tbfin_recursos_movimento.status                                   ||'</status>');
      pc_escreve_xml('</ted>');
    END LOOP;
    
    pc_escreve_xml('</teds>'); 
    -- Fecha a tag principal para encerrar o XML
    pc_escreve_xml('</consulta_ted>');
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => '/rl');
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl739_' ||0 ||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    vr_nmarquivo := 'crrl739_'||0 || gene0002.fn_busca_time || '.pdf';
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'MANPRT'
                               , pr_dtmvtolt  => vr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/consulta_ted'
                               , pr_dsjasper  => 'crrl739.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||vr_nmarquivo
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 739
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
 
    --> AyllosWeb
    -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => NULL
                                ,pr_nrdcaixa => NULL
                                ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarquivo
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;
    
     -- Criar XML de retorno para uso na Web
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarquivo|| '</nmarqpdf>');

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarquivo
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;                                      
                                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_exporta_consulta_teds_pdf : '||SQLERRM;  	                                                                                     
  END pc_exporta_consulta_teds_pdf;
  
END TELA_MANPRT;
