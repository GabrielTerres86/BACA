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

END TELA_MANPRT;
