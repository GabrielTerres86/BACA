CREATE OR REPLACE PACKAGE CECRED.TELA_SOLPOR is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : TELA_SOLPOR
      Sistema  : Rotinas referentes a tela SOLPOR (PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO)
      Sigla    : SOLPOR
      Autor    : Augusto - Supero
      Data     : Outubro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas utilizadas pela tela SOLPOR para portabilidade de salário
  ---------------------------------------------------------------------------------------------------------------*/

        PROCEDURE pc_busca_solicitacoes_retorno(pr_cdcooper          IN tbcc_portabilidade_recebe.cdcooper%TYPE --> Cooperativa da portabilidade
                                           ,pr_nrdconta          IN tbcc_portabilidade_recebe.nrdconta%TYPE --> Conta da portabilidade
                                           ,pr_cdagenci          IN crapass.cdagenci%TYPE --> PA da portabilidade
                                           ,pr_dtsolicitacao_ini IN VARCHAR2 --> Inicio da data da solicitaçã da portabilidade
                                           ,pr_dtsolicitacao_fim IN VARCHAR2 --> Fim da data da solicitaçã da portabilidade
                                           ,pr_dtretorno_ini     IN VARCHAR2 --> Inicio da data do retorno da portabilidade
                                           ,pr_dtretorno_fim     IN VARCHAR2 --> Fim da data do retorno da portabilidade
                                           ,pr_idsituacao        IN tbcc_portabilidade_recebe.idsituacao%TYPE --> Situação da portabilidade
																					 ,pr_nuportabilidade   IN tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE --> Número da solicitação de portabilidade
																					 ,pr_pagina            IN PLS_INTEGER --> Página atual
																					 ,pr_tamanho_pagina    IN PLS_INTEGER --> Elementos por página
                                           ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG
                                           ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                           ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                           ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                           ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                           ,pr_des_erro          OUT VARCHAR2); --> Erros do processo
                                           
                                           
    PROCEDURE pc_busca_solicitacoes_envio(pr_cdcooper          IN tbcc_portabilidade_envia.cdcooper%TYPE --> Cooperativa da portabilidade
                                         ,pr_nrdconta          IN tbcc_portabilidade_envia.nrdconta%TYPE --> Conta da portabilidade
                                         ,pr_cdagenci          IN crapass.cdagenci%TYPE --> PA da portabilidade
                                         ,pr_dtsolicitacao_ini IN VARCHAR2 --> Inicio da data da solicitaçã da portabilidade
                                         ,pr_dtsolicitacao_fim IN VARCHAR2 --> Fim da data da solicitaçã da portabilidade
                                         ,pr_dtretorno_ini     IN VARCHAR2 --> Inicio da data do retorno da portabilidade
                                         ,pr_dtretorno_fim     IN VARCHAR2 --> Fim da data do retorno da portabilidade
                                         ,pr_idsituacao        IN tbcc_portabilidade_envia.idsituacao%TYPE --> Situação da portabilidade
																				 ,pr_nuportabilidade   IN tbcc_portabilidade_envia.nrsolicitacao%TYPE --> Número da solicitação de portabilidade
																				 ,pr_pagina            IN PLS_INTEGER --> Página atual
																				 ,pr_tamanho_pagina    IN PLS_INTEGER --> Elementos por página
                                         ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2); --> Erros do processo
																				 
    PROCEDURE pc_detalhe_solicitacao_retorno(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
                                            ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
 																					  ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                            ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                            ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                            ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                            ,pr_des_erro          OUT VARCHAR2); --> Erros do processo	
																						
    PROCEDURE pc_detalhe_solicitacao_envio(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
                                          ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
 																					,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                          ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                          ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                          ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro          OUT VARCHAR2); --> Erros do processo
																			
    PROCEDURE pc_busca_contas_direcionamento(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
																						,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
																						,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
																						,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
																						,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																						,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
																						,pr_des_erro          OUT VARCHAR2); --> Erros do processo
																						
    PROCEDURE pc_realiza_direcionamento(pr_cdcooper          IN crapttl.cdcooper%TYPE --> Cooperativa
			                                 ,pr_nrdconta          IN crapttl.nrdconta%TYPE --> Conta
																			 ,pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
																			 ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
																			 ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
																			 ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
																			 ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																			 ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
																			 ,pr_des_erro          OUT VARCHAR2); --> Erros do processo
																			 
																			 
    PROCEDURE pc_avalia_portabilidade(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
			                               ,pr_cdmotivo          IN tbcc_portabilidade_recebe.cdmotivo%TYPE --> Motivo da avaliação
																		 ,pr_idsituacao        IN tbcc_portabilidade_recebe.idsituacao%TYPE --> Situação da avaliação
																 		 ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
																		 ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		 ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
																		 ,pr_des_erro          OUT VARCHAR2); --> Erros do processo											 

END TELA_SOLPOR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_SOLPOR IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : TELA_SOLPOR
      Sistema  : Rotinas referentes a tela SOLPOR (PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO)
      Sigla    : SOLPOR
      Autor    : Augusto - Supero
      Data     : Outubro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas utilizadas pela tela SOLPOR para portabilidade de salário
  ---------------------------------------------------------------------------------------------------------------*/
    PROCEDURE pc_busca_solicitacoes_retorno(pr_cdcooper          IN tbcc_portabilidade_recebe.cdcooper%TYPE --> Cooperativa da portabilidade
                                           ,pr_nrdconta          IN tbcc_portabilidade_recebe.nrdconta%TYPE --> Conta da portabilidade
                                           ,pr_cdagenci          IN crapass.cdagenci%TYPE --> PA da portabilidade
                                           ,pr_dtsolicitacao_ini IN VARCHAR2 --> Inicio da data da solicitaçã da portabilidade
                                           ,pr_dtsolicitacao_fim IN VARCHAR2 --> Fim da data da solicitaçã da portabilidade
                                           ,pr_dtretorno_ini     IN VARCHAR2 --> Inicio da data do retorno da portabilidade
                                           ,pr_dtretorno_fim     IN VARCHAR2 --> Fim da data do retorno da portabilidade
                                           ,pr_idsituacao        IN tbcc_portabilidade_recebe.idsituacao%TYPE --> Situação da portabilidade
																					 ,pr_nuportabilidade   IN tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE --> Número da solicitação de portabilidade
																					 ,pr_pagina            IN PLS_INTEGER --> Página atual
																					 ,pr_tamanho_pagina    IN PLS_INTEGER --> Elementos por página
                                           ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
																					 ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                           ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                           ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                           ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                           ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_busca_solicitacoes_retorno
          Sistema : CECRED
          Sigla   : SOLPOR
          Autor   : Augusto (Supero)
          Data    : Outubro/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar lista de retornos das solicitações de portabilidade.
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_cont_tag PLS_INTEGER := 0;
        vr_dtsolicitacao_ini DATE;
        vr_dtsolicitacao_fim DATE;
        vr_dtretorno_ini DATE;
        vr_dtretorno_fim DATE;
    
        CURSOR cr_lista_solicitacoes(pr_cdcooper tbcc_portabilidade_recebe.cdcooper%TYPE
                                    ,pr_nrdconta tbcc_portabilidade_recebe.nrdconta%TYPE
                                    ,pr_cdagenci crapass.cdagenci%TYPE
                                    ,pr_dtsolicitacao_ini tbcc_portabilidade_recebe.dtsolicitacao%TYPE
                                    ,pr_dtsolicitacao_fim tbcc_portabilidade_recebe.dtsolicitacao%TYPE
                                    ,pr_dtretorno_ini tbcc_portabilidade_recebe.dtretorno%TYPE
                                    ,pr_dtretorno_fim tbcc_portabilidade_recebe.dtretorno%TYPE
                                    ,pr_idsituacao tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE
                                    ,pr_nuportabilidade tbcc_portabilidade_recebe.nrnu_portabilidade%TYPE) IS        
            
        SELECT *
          FROM (SELECT a.*
                      ,rownum nrrownum
                  FROM (SELECT tpr.nrnu_portabilidade nusolicitacao
                              ,tpr.dtsolicitacao
                              ,ban.nmextbcc           participante
                              ,dom.dscodigo           situacao
                              ,tpr.dtretorno
															,tpr.nrdconta
															,tpr.idsituacao
                              ,dcp.dscodigo           motivo
                              ,COUNT(1)               over (PARTITION BY 1) qtdesolicitacoes
															,tpr.ROWID              dsrowid
                          FROM tbcc_portabilidade_recebe tpr
                              ,crapban                   ban
                              ,tbcc_dominio_campo        dom
                              ,tbcc_dominio_campo        dcp
                         WHERE tpr.nrispb_destinataria = ban.nrispbif
                           AND tpr.idsituacao = dom.cddominio
                           AND dom.nmdominio = 'SIT_PORTAB_SALARIO_RECEBE'
                           AND dcp.nmdominio(+) = tpr.dsdominio_motivo
                           AND dcp.cddominio(+) = tpr.cdmotivo
                           AND tpr.cdcooper = nvl(pr_cdcooper, tpr.cdcooper)
                           AND tpr.nrdconta = nvl(pr_nrdconta, tpr.nrdconta)
                           AND (EXISTS(SELECT 1
																				FROM crapass ass
																			 WHERE ass.cdcooper = tpr.cdcooper
																				 AND ass.nrdconta = tpr.nrdconta
																				 AND ass.cdagenci = nvl(pr_cdagenci, ass.cdagenci)
																			) OR pr_cdagenci IS NULL
																)
                           AND tpr.dtsolicitacao BETWEEN nvl(pr_dtsolicitacao_ini, tpr.dtsolicitacao) AND
                               nvl(pr_dtsolicitacao_fim, tpr.dtsolicitacao)
                           AND nvl(tpr.dtretorno, trunc(SYSDATE)) BETWEEN
                               nvl(pr_dtretorno_ini, nvl(tpr.dtretorno, trunc(SYSDATE))) AND
                               nvl(pr_dtretorno_fim, nvl(tpr.dtretorno, trunc(SYSDATE)))
                           AND tpr.idsituacao = nvl(pr_idsituacao, tpr.idsituacao)
                           AND tpr.nrnu_portabilidade = nvl(pr_nuportabilidade, tpr.nrnu_portabilidade)
                           ORDER BY tpr.nrnu_portabilidade) a
                 WHERE rownum < ((pr_pagina * pr_tamanho_pagina) + 1))
         WHERE nrrownum >= (((pr_pagina - 1) * pr_tamanho_pagina) + 1);
        rw_lista_solicitacoes cr_lista_solicitacoes%ROWTYPE;
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
                              
        GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Solicitacoes'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
                            
        vr_dtsolicitacao_ini := TO_DATE(pr_dtsolicitacao_ini,'DD/MM/RRRR');
        vr_dtsolicitacao_fim := TO_DATE(pr_dtsolicitacao_fim,'DD/MM/RRRR');
        vr_dtretorno_ini := TO_DATE(pr_dtretorno_ini,'DD/MM/RRRR');
        vr_dtretorno_fim := TO_DATE(pr_dtretorno_fim,'DD/MM/RRRR');
    
        FOR rw_lista_solicitacoes IN cr_lista_solicitacoes(pr_cdcooper          => pr_cdcooper
                                                          ,pr_nrdconta          => pr_nrdconta
                                                          ,pr_cdagenci          => pr_cdagenci
                                                          ,pr_dtsolicitacao_ini => vr_dtsolicitacao_ini
                                                          ,pr_dtsolicitacao_fim => vr_dtsolicitacao_fim
                                                          ,pr_dtretorno_ini     => vr_dtretorno_ini
                                                          ,pr_dtretorno_fim     => vr_dtretorno_fim
                                                          ,pr_idsituacao        => pr_idsituacao
                                                          ,pr_nuportabilidade   => pr_nuportabilidade) LOOP
          GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Solicitacoes'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Solicitacao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
                            
                            
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nrrownum'
                                ,pr_tag_cont => rw_lista_solicitacoes.nrrownum
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nusolicitacao'
                                ,pr_tag_cont => rw_lista_solicitacoes.nusolicitacao
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'participante'
                                ,pr_tag_cont => rw_lista_solicitacoes.participante
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dtsolicitacao'
                                ,pr_tag_cont => to_char(rw_lista_solicitacoes.dtsolicitacao, 'DD/MM/RRRR')
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'situacao'
                                ,pr_tag_cont => rw_lista_solicitacoes.situacao
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dtretorno'
                                ,pr_tag_cont => to_char(rw_lista_solicitacoes.dtretorno, 'DD/MM/RRRR')
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'motivo'
                                ,pr_tag_cont => rw_lista_solicitacoes.motivo
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'qtdesolicitacoes'
                                ,pr_tag_cont => rw_lista_solicitacoes.qtdesolicitacoes
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nrdconta'
                                ,pr_tag_cont => rw_lista_solicitacoes.nrdconta
                                ,pr_des_erro => vr_dscritic);
																
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'idsituacao'
                                ,pr_tag_cont => rw_lista_solicitacoes.idsituacao
                                ,pr_des_erro => vr_dscritic);																

         GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dsrowid'
                                ,pr_tag_cont => rw_lista_solicitacoes.dsrowid
                                ,pr_des_erro => vr_dscritic);

          -- Incrementa o contador de tags
          vr_cont_tag := vr_cont_tag + 1;
        END LOOP;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_SOLPOR.pc_busca_solicitacoes_retorno. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_busca_solicitacoes_retorno;
    
    PROCEDURE pc_busca_solicitacoes_envio(pr_cdcooper          IN tbcc_portabilidade_envia.cdcooper%TYPE --> Cooperativa da portabilidade
                                         ,pr_nrdconta          IN tbcc_portabilidade_envia.nrdconta%TYPE --> Conta da portabilidade
                                         ,pr_cdagenci          IN crapass.cdagenci%TYPE --> PA da portabilidade
                                         ,pr_dtsolicitacao_ini IN VARCHAR2 --> Inicio da data da solicitaçã da portabilidade
                                         ,pr_dtsolicitacao_fim IN VARCHAR2 --> Fim da data da solicitaçã da portabilidade
                                         ,pr_dtretorno_ini     IN VARCHAR2 --> Inicio da data do retorno da portabilidade
                                         ,pr_dtretorno_fim     IN VARCHAR2 --> Fim da data do retorno da portabilidade
                                         ,pr_idsituacao        IN tbcc_portabilidade_envia.idsituacao%TYPE --> Situação da portabilidade
                                         ,pr_nuportabilidade   IN tbcc_portabilidade_envia.nrsolicitacao%TYPE --> Número da solicitação de portabilidade
                                         ,pr_pagina            IN PLS_INTEGER --> Página atual
                                         ,pr_tamanho_pagina    IN PLS_INTEGER --> Elementos por página
                                         ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_busca_solicitacoes_envio
          Sistema : CECRED
          Sigla   : SOLPOR
          Autor   : Augusto (Supero)
          Data    : Outubro/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar lista de envios das solicitações de portabilidade.
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_cont_tag PLS_INTEGER := 0;
        vr_dtsolicitacao_ini DATE;
        vr_dtsolicitacao_fim DATE;
        vr_dtretorno_ini DATE;
        vr_dtretorno_fim DATE;

        CURSOR cr_lista_solicitacoes(pr_cdcooper tbcc_portabilidade_envia.cdcooper%TYPE
                                    ,pr_nrdconta tbcc_portabilidade_envia.nrdconta%TYPE
                                    ,pr_cdagenci crapass.cdagenci%TYPE
                                    ,pr_dtsolicitacao_ini tbcc_portabilidade_envia.dtsolicitacao%TYPE
                                    ,pr_dtsolicitacao_fim tbcc_portabilidade_envia.dtsolicitacao%TYPE
                                    ,pr_dtretorno_ini tbcc_portabilidade_envia.dtretorno%TYPE
                                    ,pr_dtretorno_fim tbcc_portabilidade_envia.dtretorno%TYPE
                                    ,pr_idsituacao tbcc_portabilidade_envia.idsituacao%TYPE
                                    ,pr_nuportabilidade tbcc_portabilidade_envia.nrsolicitacao%TYPE) IS        
          SELECT *
            FROM (SELECT a.*
                        ,rownum nrrownum
                        FROM (SELECT tpe.nrnu_portabilidade nusolicitacao
                                  ,tpe.dtsolicitacao
                                  ,ban.nmresbcc      participante
                                  ,dom.dscodigo      situacao
                                  ,tpe.dtretorno
                                  ,dcp.dscodigo      motivo
																	,tpe.nrdconta
                                  ,COUNT(1)          over (PARTITION BY 1) qtdesolicitacoes
																	,tpe.idsituacao
																	,tpe.ROWID         dsrowid
                              FROM tbcc_portabilidade_envia tpe
                                  ,crapban                  ban
                                  ,tbcc_dominio_campo       dom
                                  ,crapass                  ass
                                  ,tbcc_dominio_campo       dcp
                             WHERE tpe.cdbanco_folha = ban.cdbccxlt
                               AND tpe.idsituacao = dom.cddominio
                               AND dom.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
                               AND dcp.nmdominio(+) = tpe.dsdominio_motivo
                               AND dcp.cddominio(+) = to_char(tpe.cdmotivo)
                               AND tpe.cdcooper = nvl(pr_cdcooper, tpe.cdcooper)
                               AND tpe.nrdconta = nvl(pr_nrdconta, tpe.nrdconta)
                               AND ass.cdcooper = tpe.cdcooper
                               AND ass.nrdconta = tpe.nrdconta
                               AND ass.cdagenci = nvl(pr_cdagenci, ass.cdagenci)
                               AND tpe.dtsolicitacao BETWEEN nvl(pr_dtsolicitacao_ini, tpe.dtsolicitacao) AND
                                   nvl(pr_dtsolicitacao_fim, tpe.dtsolicitacao)
                               AND nvl(tpe.dtretorno, TRUNC(SYSDATE)) BETWEEN nvl(pr_dtretorno_ini, nvl(tpe.dtretorno, TRUNC(SYSDATE))) AND
                                   nvl(pr_dtretorno_fim, nvl(tpe.dtretorno, TRUNC(SYSDATE)))
                               AND tpe.idsituacao = nvl(pr_idsituacao, tpe.idsituacao)
                               AND nvl(tpe.nrnu_portabilidade,0) = nvl(pr_nuportabilidade, nvl(tpe.nrnu_portabilidade,0))
                               ORDER BY tpe.nrnu_portabilidade, tpe.nrsolicitacao) a
                             WHERE rownum < ((pr_pagina * pr_tamanho_pagina) + 1)
                  )
        WHERE nrrownum >= (((pr_pagina - 1) * pr_tamanho_pagina) + 1);
        rw_lista_solicitacoes cr_lista_solicitacoes%ROWTYPE;
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
 
        GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Solicitacoes'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
 
        vr_dtsolicitacao_ini := TO_DATE(pr_dtsolicitacao_ini,'DD/MM/RRRR');
        vr_dtsolicitacao_fim := TO_DATE(pr_dtsolicitacao_fim,'DD/MM/RRRR');
        vr_dtretorno_ini := TO_DATE(pr_dtretorno_ini,'DD/MM/RRRR');
        vr_dtretorno_fim := TO_DATE(pr_dtretorno_fim,'DD/MM/RRRR');

        FOR rw_lista_solicitacoes IN cr_lista_solicitacoes(pr_cdcooper          => pr_cdcooper
                                                          ,pr_nrdconta          => pr_nrdconta
                                                          ,pr_cdagenci          => pr_cdagenci
                                                          ,pr_dtsolicitacao_ini => vr_dtsolicitacao_ini
                                                          ,pr_dtsolicitacao_fim => vr_dtsolicitacao_fim
                                                          ,pr_dtretorno_ini     => vr_dtretorno_ini
                                                          ,pr_dtretorno_fim     => vr_dtretorno_fim
                                                          ,pr_idsituacao        => pr_idsituacao
                                                          ,pr_nuportabilidade   => pr_nuportabilidade) LOOP
          GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Solicitacoes'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Solicitacao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
                             
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nrrownum'
                                ,pr_tag_cont => rw_lista_solicitacoes.nrrownum
                                ,pr_des_erro => vr_dscritic);
 
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nusolicitacao'
                                ,pr_tag_cont => rw_lista_solicitacoes.nusolicitacao
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'participante'
                                ,pr_tag_cont => rw_lista_solicitacoes.participante
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dtsolicitacao'
                                ,pr_tag_cont => to_char(rw_lista_solicitacoes.dtsolicitacao, 'DD/MM/RRRR')
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'situacao'
                                ,pr_tag_cont => rw_lista_solicitacoes.situacao
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dtretorno'
                                ,pr_tag_cont => to_char(rw_lista_solicitacoes.dtretorno, 'DD/MM/RRRR')
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'motivo'
                                ,pr_tag_cont => rw_lista_solicitacoes.motivo
                                ,pr_des_erro => vr_dscritic);
                                
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'qtdesolicitacoes'
                                ,pr_tag_cont => rw_lista_solicitacoes.qtdesolicitacoes
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nrdconta'
                                ,pr_tag_cont => rw_lista_solicitacoes.nrdconta
                                ,pr_des_erro => vr_dscritic);
																
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'idsituacao'
                                ,pr_tag_cont => rw_lista_solicitacoes.idsituacao
                                ,pr_des_erro => vr_dscritic);
																
         GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Solicitacao'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dsrowid'
                                ,pr_tag_cont => rw_lista_solicitacoes.dsrowid
                                ,pr_des_erro => vr_dscritic);																																
        
          -- Incrementa o contador de tags
          vr_cont_tag := vr_cont_tag + 1;
        END LOOP;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_SOLPOR.pc_busca_solicitacoes_envio. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_busca_solicitacoes_envio;
		
		PROCEDURE pc_detalhe_solicitacao_retorno(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
                                            ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
 																					  ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                            ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                            ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                            ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                            ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_detalhe_solicitacao_retorno
          Sistema : CECRED
          Sigla   : SOLPOR
          Autor   : Augusto (Supero)
          Data    : Outubro/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar detalhe do retorno de uma solicitação de portabilidade.
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
    
        CURSOR cr_solicitacao(pr_dsrowid VARCHAR2) IS
					SELECT tpr.dtsolicitacao
								,tpr.nrnu_portabilidade nusolicitacao
								,GENE0002.fn_mask_conta(tpr.nrdconta) nrdconta
								,GENE0002.fn_mask_cpf_cnpj(tpr.nrcpfcgc, 1) nrcpfcgc
								,tpr.dstelefone telefone
								,tpr.nmprimtl
								,GENE0002.fn_mask_cpf_cnpj(tpr.nrcnpj_empregador, 2) nrcnpj_empregador
								,tpr.dsnome_empregador
								,lpad(ban.cdbccxlt, 3, '0') || ' - ' || ban.nmresbcc banco
								,tpr.cdagencia_destinataria
								,GENE0002.fn_mask_conta(tpr.nrdconta_destinataria) nrdconta_destinataria
								,dom.dscodigo situacao
								,tpr.dtavaliacao
								,tpr.dtretorno
								,dcp.dscodigo motivo
						FROM tbcc_portabilidade_recebe tpr
								,crapban                   ban
								,tbcc_dominio_campo        dom
								,tbcc_dominio_campo        dcp
					 WHERE tpr.nrispb_destinataria = ban.nrispbif
						 AND tpr.idsituacao = dom.cddominio
						 AND dom.nmdominio = 'SIT_PORTAB_SALARIO_RECEBE'
						 AND dcp.nmdominio(+) = tpr.dsdominio_motivo
						 AND dcp.cddominio(+) = tpr.cdmotivo
             AND tpr.rowid = pr_dsrowid;
				rw_solicitacao cr_solicitacao%ROWTYPE;
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
                            
        GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Solicitacao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
														
														
        OPEN cr_solicitacao(pr_dsrowid => pr_dsrowid);
				FETCH cr_solicitacao INTO rw_solicitacao;
				
				IF cr_solicitacao%NOTFOUND THEN
					CLOSE cr_solicitacao;
					vr_dscritic := 'Solicitacao nao encontrada.';
					RAISE vr_exc_saida;
				END IF;
				
				CLOSE cr_solicitacao;
                                
				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
          ,pr_tag_pai  => 'Solicitacao'
          ,pr_posicao  => 0
          ,pr_tag_nova => 'dtsolicitacao'
          ,pr_tag_cont => to_char(rw_solicitacao.dtsolicitacao, 'DD/MM/RRRR')
          ,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'nusolicitacao'
									,pr_tag_cont => rw_solicitacao.nusolicitacao
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'nrdconta'
									,pr_tag_cont => rw_solicitacao.nrdconta

									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'nrcpfcgc'
									,pr_tag_cont => rw_solicitacao.nrcpfcgc
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'telefone'
									,pr_tag_cont => rw_solicitacao.telefone
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'nmprimtl'
									,pr_tag_cont => rw_solicitacao.nmprimtl
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'nrcnpj_empregador'
									,pr_tag_cont => rw_solicitacao.nrcnpj_empregador
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'dsnome_empregador'
									,pr_tag_cont => rw_solicitacao.dsnome_empregador
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'banco'
									,pr_tag_cont => rw_solicitacao.banco

									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'cdagencia_destinataria'
									,pr_tag_cont => rw_solicitacao.cdagencia_destinataria
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'nrdconta_destinataria'
									,pr_tag_cont => rw_solicitacao.nrdconta_destinataria
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'situacao'
									,pr_tag_cont => rw_solicitacao.situacao
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'dtavaliacao'
									,pr_tag_cont => to_char(rw_solicitacao.dtavaliacao, 'DD/MM/RRRR HH24:MI')
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'dtretorno'
									,pr_tag_cont => to_char(rw_solicitacao.dtretorno, 'DD/MM/RRRR HH24:MI')
									,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao => 0
									,pr_tag_nova => 'motivo'
									,pr_tag_cont => rw_solicitacao.motivo
									,pr_des_erro => vr_dscritic);
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_SOLPOR.pc_detalhe_solicitacao_retorno. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_detalhe_solicitacao_retorno;
		
    PROCEDURE pc_detalhe_solicitacao_envio(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
                                          ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
 		  																	  ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                          ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
                                          ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                          ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_detalhe_solicitacao_envio
          Sistema : CECRED
          Sigla   : SOLPOR
          Autor   : Augusto (Supero)
          Data    : Outubro/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar detalhe do envio de uma solicitação de portabilidade.
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
    
        CURSOR cr_solicitacao(pr_dsrowid VARCHAR2) IS
					SELECT tpe.dtsolicitacao
								,tpe.nrnu_portabilidade nusolicitacao
								,GENE0002.fn_mask_conta(tpe.nrdconta) nrdconta
								,GENE0002.fn_mask_cpf_cnpj(tpe.nrcpfcgc, 1) nrcpfcgc
								,'(' || lpad(tpe.nrddd_telefone, 2, '0') || ')' || tpe.nrtelefone telefone
								,tpe.nmprimtl
								,GENE0002.fn_mask_cpf_cnpj(tpe.nrcnpj_empregador, 2) nrcnpj_empregador
								,tpe.dsnome_empregador
								,lpad(ban.cdbccxlt, 3, '0') || ' - ' || ban.nmresbcc banco
								,tpe.nrispb_banco_folha
								,GENE0002.fn_mask_cpf_cnpj(tpe.nrcnpj_banco_folha, 2) nrcnpj_banco_folha
								,dom.dscodigo situacao
								,tpe.dtretorno
								,dcp.dscodigo motivo
					FROM tbcc_portabilidade_envia tpe
							,crapban                  ban
							,tbcc_dominio_campo       dom
							,tbcc_dominio_campo       dcp
					WHERE tpe.nrispb_banco_folha = ban.nrispbif
					 AND tpe.idsituacao = dom.cddominio
					 AND dom.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
					 AND dcp.nmdominio(+) = tpe.dsdominio_motivo
					 AND dcp.cddominio(+) = tpe.cdmotivo
					 AND tpe.rowid = pr_dsrowid;
				rw_solicitacao cr_solicitacao%ROWTYPE;
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
                            
        GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Solicitacao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
														
														
        OPEN cr_solicitacao(pr_dsrowid => pr_dsrowid);
				FETCH cr_solicitacao INTO rw_solicitacao;
				
				IF cr_solicitacao%NOTFOUND THEN
					CLOSE cr_solicitacao;
					vr_dscritic := 'Solicitacao nao encontrada.';
					RAISE vr_exc_saida;
				END IF;
				
				CLOSE cr_solicitacao;
                                
				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
									,pr_tag_pai  => 'Solicitacao'
									,pr_posicao  => 0
									,pr_tag_nova => 'dtsolicitacao'
									,pr_tag_cont => rw_solicitacao.dtsolicitacao
									,pr_des_erro => vr_dscritic);
									
				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'nusolicitacao'
													,pr_tag_cont => rw_solicitacao.nusolicitacao
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrdconta'
													,pr_tag_cont => rw_solicitacao.nrdconta
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrcpfcgc'
													,pr_tag_cont => rw_solicitacao.nrcpfcgc
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'telefone'
													,pr_tag_cont => rw_solicitacao.telefone
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'nmprimtl'
													,pr_tag_cont => rw_solicitacao.nmprimtl
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrcnpj_empregador'
													,pr_tag_cont => rw_solicitacao.nrcnpj_empregador
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'dsnome_empregador'
													,pr_tag_cont => rw_solicitacao.dsnome_empregador
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'banco'
													,pr_tag_cont => rw_solicitacao.banco
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrispb_banco_folha'
													,pr_tag_cont => rw_solicitacao.nrispb_banco_folha
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrcnpj_banco_folha'
													,pr_tag_cont => rw_solicitacao.nrcnpj_banco_folha
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'situacao'
													,pr_tag_cont => rw_solicitacao.situacao
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'dtretorno'
													,pr_tag_cont => to_char(rw_solicitacao.dtretorno, 'DD/MM/RRRR HH24:MI')
													,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Solicitacao'
													,pr_posicao  => 0
													,pr_tag_nova => 'motivo'
													,pr_tag_cont => rw_solicitacao.motivo
													,pr_des_erro => vr_dscritic);
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_SOLPOR.pc_detalhe_solicitacao_envio. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_detalhe_solicitacao_envio;		
		
    PROCEDURE pc_busca_contas_direcionamento(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
																						,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
																						,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
																						,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
																						,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																						,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
																						,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_busca_contas_direcionamento
          Sistema : CECRED
          Sigla   : SOLPOR
          Autor   : Augusto (Supero)
          Data    : Outubro/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que houver um direcionamento de conta
        
          Objetivo  : Retornar as contas possíveis para determinado CPF
        
          Observacao: -----
        
          Alteracoes: 					
          ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_cont_tag PLS_INTEGER := 0;
    
        CURSOR cr_lista_contas(pr_dsrowid VARCHAR2) IS            
					SELECT cop.nmrescop
					      ,cop.cdcooper
								,GENE0002.fn_mask_conta(ass.nrdconta) nrdconta
								,gene0002.fn_mask_cpf_cnpj(ass.nrcpfcgc, ass.inpessoa) nrcpfcgc
								,ass.nmprimtl
								,gene0002.fn_mask_cpf_cnpj(ttl.nrcpfemp, 2) nrcpfemp
								,ttl.nmextttl
						FROM tbcc_portabilidade_recebe tpr
								,crapass                   ass
								,crapcop                   cop
								,crapttl                   ttl
					 WHERE tpr.nrcpfcgc = ass.nrcpfcgc
						 AND ass.dtdemiss IS NULL
						 AND ass.cdcooper = cop.cdcooper
						 AND ttl.cdcooper = cop.cdcooper
						 AND ttl.nrdconta = ass.nrdconta
						 AND ttl.idseqttl = 1
						 AND tpr.rowid = pr_dsrowid
					  ORDER BY cop.cdcooper, ass.nrdconta;
        rw_lista_contas cr_lista_contas%ROWTYPE;
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
                              
        GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Contas'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
    
        FOR rw_lista_contas IN cr_lista_contas(pr_dsrowid => pr_dsrowid) LOOP
          GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Contas'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Conta'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
                            
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Conta'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nmrescop'
                                ,pr_tag_cont => rw_lista_contas.nmrescop
                                ,pr_des_erro => vr_dscritic);
																
         GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Conta'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'cdcooper'
                                ,pr_tag_cont => rw_lista_contas.cdcooper
                                ,pr_des_erro => vr_dscritic);																
																
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Conta'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nrdconta'
                                ,pr_tag_cont => rw_lista_contas.nrdconta
                                ,pr_des_erro => vr_dscritic);
																
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Conta'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nrcpfcgc'
                                ,pr_tag_cont => rw_lista_contas.nrcpfcgc
                                ,pr_des_erro => vr_dscritic);
																
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Conta'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nmprimtl'
                                ,pr_tag_cont => rw_lista_contas.nmprimtl
                                ,pr_des_erro => vr_dscritic);
																
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Conta'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nrcpfemp'
                                ,pr_tag_cont => rw_lista_contas.nrcpfemp
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Conta'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'nmextttl'
                                ,pr_tag_cont => rw_lista_contas.nmextttl
                                ,pr_des_erro => vr_dscritic);

          -- Incrementa o contador de tags
          vr_cont_tag := vr_cont_tag + 1;
        END LOOP;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_SOLPOR.pc_busca_contas_direcionamento. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_busca_contas_direcionamento;					
		
		PROCEDURE pc_realiza_direcionamento(pr_cdcooper          IN crapttl.cdcooper%TYPE --> Cooperativa
			                                 ,pr_nrdconta          IN crapttl.nrdconta%TYPE --> Conta
																			 ,pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
																			 ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
																			 ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
																			 ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
																			 ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																			 ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
																			 ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_realiza_direcionamento
          Sistema : CECRED
          Sigla   : SOLPOR
          Autor   : Augusto (Supero)
          Data    : Outubro/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que houver um direcionamento de conta
        
          Objetivo  : Realizar o direcionamento de contas
        
          Observacao: -----
        
          Alteracoes: 					
          ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_nrdrowid  ROWID;
    
        CURSOR cr_solicitacao(pr_dsrowid VARCHAR2
				                     ,pr_cdcooper crapttl.cdcooper%TYPE
				                     ,pr_nrdconta crapttl.nrdconta%TYPE) IS            
					SELECT 1
						FROM tbcc_portabilidade_recebe tpr
						    ,crapttl ttl
					 WHERE ttl.nrcpfemp = tpr.nrcnpj_empregador
					   AND ttl.cdcooper = pr_cdcooper
						 AND ttl.nrdconta = pr_nrdconta
						 AND ttl.idseqttl = 1
					   AND tpr.rowid = pr_dsrowid;
        rw_solicitacao cr_solicitacao%ROWTYPE;
				
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
				
        OPEN cr_solicitacao(pr_dsrowid => pr_dsrowid
				                   ,pr_cdcooper => pr_cdcooper
				                   ,pr_nrdconta => pr_nrdconta);
				FETCH cr_solicitacao INTO rw_solicitacao;
				
				IF cr_solicitacao%NOTFOUND THEN
					CLOSE cr_solicitacao;
					vr_dscritic := 'Divergencia no CNPJ do empregador.';
					RAISE vr_exc_saida;
				END IF;
				
				CLOSE cr_solicitacao;
				
				UPDATE tbcc_portabilidade_recebe
				   SET nrdconta = pr_nrdconta 
					    ,cdcooper = pr_cdcooper
				WHERE ROWID = pr_dsrowid;

				GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
									,pr_cdoperad => vr_cdoperad
									,pr_dscritic => NULL
									,pr_dsorigem => 'AYLLOS'
									,pr_dstransa => 'Direcionamento de solicitacao de portabilidade'
									,pr_dttransa => TRUNC(SYSDATE)
									,pr_flgtrans => 1
									,pr_hrtransa => gene0002.fn_busca_time
									,pr_idseqttl => 1
									,pr_nmdatela => vr_nmdatela
									,pr_nrdconta => pr_nrdconta
									,pr_nrdrowid => vr_nrdrowid);
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><Retorno>1</Retorno></Dados></Root>');
				
				COMMIT;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
						
						ROLLBACK;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
 						ROLLBACK;
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_SOLPOR.pc_realiza_direcionamento. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_realiza_direcionamento;
		
    PROCEDURE pc_avalia_portabilidade(pr_dsrowid           IN VARCHAR2 --> Rowid da tabela
			                               ,pr_cdmotivo          IN tbcc_portabilidade_recebe.cdmotivo%TYPE --> Motivo da avaliação
																		 ,pr_idsituacao        IN tbcc_portabilidade_recebe.idsituacao%TYPE --> Situação da avaliação
																 		 ,pr_xmllog            IN VARCHAR2 --> XML com informações de LOG                                           
																		 ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic          OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml            IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		 ,pr_nmdcampo          OUT VARCHAR2 --> Nome do campo com erro
																		 ,pr_des_erro          OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_avalia_portabilidade
          Sistema : CECRED
          Sigla   : SOLPOR
          Autor   : Augusto (Supero)
          Data    : Outubro/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que houver um direcionamento de conta
        
          Objetivo  : Realiza a avaliação da portabilidade, podendo rejeitar ou aprovar
        
          Observacao: -----
        
          Alteracoes: 					
          ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
				vr_nrdrowid  ROWID;
    
        CURSOR cr_solicitacao(pr_dsrowid VARCHAR2) IS            
					SELECT tpr.nrdconta
					      ,tpr.idsituacao
								,tpr.cdcooper
						FROM tbcc_portabilidade_recebe tpr
					 WHERE tpr.rowid = pr_dsrowid;
        rw_solicitacao cr_solicitacao%ROWTYPE;
				
				CURSOR cr_dominio(pr_cdmotivo tbcc_dominio_campo.cddominio%TYPE) IS            
					SELECT tdc.dscodigo
						FROM tbcc_dominio_campo tdc
					 WHERE tdc.nmdominio = 'MOTVREPRVCPORTDDCTSALR'
						AND  tdc.cddominio = pr_cdmotivo;
        rw_dominio cr_dominio%ROWTYPE;

    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
				
				IF pr_idsituacao IS NULL THEN
					vr_dscritic := 'Situacao da avaliacao nao informada.';
					RAISE vr_exc_saida;
				END IF;
				
				OPEN cr_solicitacao(pr_dsrowid => pr_dsrowid);
				FETCH cr_solicitacao INTO rw_solicitacao;
				
				IF cr_solicitacao%NOTFOUND THEN
					CLOSE cr_solicitacao;
					vr_dscritic := 'Solicitacao nao encontrada.';
					RAISE vr_exc_saida;
				END IF;
				
				CLOSE cr_solicitacao;
				
				GENE0001.pc_gera_log(pr_cdcooper => rw_solicitacao.cdcooper
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => NULL
														,pr_dsorigem => 'AYLLOS'
														,pr_dstransa => 'Avaliacao de solicitacao de portabilidade'
														,pr_dttransa => TRUNC(SYSDATE)
														,pr_flgtrans => 1
														,pr_hrtransa => gene0002.fn_busca_time
														,pr_idseqttl => 1
														,pr_nmdatela => vr_nmdatela
														,pr_nrdconta => rw_solicitacao.nrdconta
														,pr_nrdrowid => vr_nrdrowid);

        -- aprovação
        IF pr_idsituacao = 2 THEN					
					UPDATE tbcc_portabilidade_recebe
						 SET idsituacao = 2
								,cdoperador = vr_cdoperad
								,dtavaliacao = SYSDATE
					WHERE ROWID = pr_dsrowid;
					
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 	 ,pr_nmdcampo => 'Situacao'
																	 ,pr_dsdadant => rw_solicitacao.idsituacao
																	 ,pr_dsdadatu => 2);
        END IF;
				
				-- rejeição
				IF pr_idsituacao = 3 THEN
					
				  IF pr_cdmotivo IS NULL THEN
						vr_dscritic := 'Motivo nao informado.';
					  RAISE vr_exc_saida;
					END IF;
					
					UPDATE tbcc_portabilidade_recebe
						 SET idsituacao = 3
								,cdoperador = vr_cdoperad
								,dtavaliacao = SYSDATE
								,dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
								,cdmotivo = pr_cdmotivo
					WHERE ROWID = pr_dsrowid;
					
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 	 ,pr_nmdcampo => 'Situacao'
																	 ,pr_dsdadant => rw_solicitacao.idsituacao
																	 ,pr_dsdadatu => 3);


          OPEN cr_dominio(pr_cdmotivo => pr_cdmotivo);
					FETCH cr_dominio INTO rw_dominio;
					CLOSE cr_dominio;

																	 
					GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
																 	 ,pr_nmdcampo => 'Motivo'
																	 ,pr_dsdadant => NULL
																	 ,pr_dsdadatu => rw_dominio.dscodigo);																	 					
				END IF;
				
				

				
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados><Retorno>1</Retorno></Dados></Root>');
        COMMIT;
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
 						ROLLBACK;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_SOLPOR.pc_avalia_portabilidade. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
						ROLLBACK;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_avalia_portabilidade;
	  
END TELA_SOLPOR;
/
