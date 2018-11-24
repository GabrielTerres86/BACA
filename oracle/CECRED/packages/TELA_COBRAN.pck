CREATE OR REPLACE PACKAGE CECRED.TELA_COBRAN IS

  /*-------------------------------------------------------------------------
  --
  --  Programa : TELA_COBRAN
  --  Sistema  : Rotinas utilizadas pela Tela COBRAN
  --  Sigla    : Cobran
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Maio/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela COBRAN
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  TYPE typ_reg_crapceb IS RECORD(
     cdcooper  crapcop.cdcooper%TYPE
    ,nmrescop  crapcop.nmrescop%TYPE
    ,cdagenci  crapass.cdagenci%TYPE
    ,nrdconta  crapass.nrdconta%TYPE
    ,nrcpfcgc  crapass.nrcpfcgc%TYPE
    ,inpessoa  crapass.inpessoa%TYPE
    ,nmprimtl  crapass.nmprimtl%TYPE
    ,nrconven  crapceb.nrconven%TYPE
    ,nrcnvceb  crapceb.nrcnvceb%TYPE
    ,dsorgarq  crapcco.dsorgarq%TYPE
    ,dhanalis  crapceb.dhanalis%TYPE
    ,nmoperad  crapope.nmoperad%TYPE
    ,insitceb  crapceb.insitceb%TYPE
    ,dssitceb  VARCHAR2(50));
  TYPE typ_tab_crapceb IS TABLE OF typ_reg_crapceb
       INDEX BY PLS_INTEGER;

    -- Chamada AyllosWeb Rotina para retornar lista de convenios ceb e suas situações
  PROCEDURE pc_consulta_conv_sit_web (pr_telcdcop    IN crapcop.cdcooper%TYPE DEFAULT 0 --> cooperativa
                                     ,pr_nrconven    IN crapceb.nrconven%TYPE DEFAULT 0 --> Nr. do convenio
                                     ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. do cooperado
                                     ,pr_telcdage    IN crapage.cdagenci%TYPE DEFAULT 0 --> Agencia
                                     ,pr_dtinicio    IN VARCHAR2 DEFAULT NULL           --> Data inicio periodo da consulta   
                                     ,pr_dtafinal    IN VARCHAR2 DEFAULT NULL           --> Data fim periodo da consulta
                                     ,pr_insitceb    IN crapceb.insitceb%TYPE           --> Situacao ceb
                                     ,pr_nriniseq    IN NUMBER DEFAULT 1                --> Registro inicial para paginacao
                                     ,pr_nrregist    IN NUMBER DEFAULT 100              --> Qtd Registro inicial para paginacao
                                     ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER                     --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
                                     ,pr_retxml  IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2                        --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2);                      --> Erros do processo
                                     
  -- Rotina para retornar lista de convenios ceb e suas situações
  PROCEDURE pc_consulta_conv_sit (pr_cdcooper    IN crapcop.cdcooper%TYPE DEFAULT 0 --> Cooperativa
                                 ,pr_nrconven    IN crapceb.nrconven%TYPE DEFAULT 0 --> Nr. do convenio
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. do cooperado
                                 ,pr_cdagenci    IN crapage.cdagenci%TYPE DEFAULT 0 --> Agencia
                                 ,pr_dtinicio    IN DATE DEFAULT NULL               --> Data inicio periodo da consulta 
                                 ,pr_dtafinal    IN DATE DEFAULT NULL               --> Data fim periodo da consulta
                                 ,pr_insitceb    IN crapceb.insitceb%TYPE           --> Situacao ceb
                                 ,pr_nriniseq    IN NUMBER DEFAULT 1                --> Registro inicial para paginacao
                                 ,pr_nrregist    IN NUMBER DEFAULT 100              --> Qtd Registro inicial para paginacao
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Cód. Operador
                                 ,pr_cdcritic    OUT crapcri.cdcritic%TYPE          --> Cód. da crítica
                                 ,pr_dscritic    OUT crapcri.dscritic%TYPE          --> Descrição da crítica
                                 ,pr_qtdregtot   OUT NUMBER                         --> Quantidade total de registros
                                 ,pr_tab_crapceb OUT typ_tab_crapceb);              --> Pl/Table com os dados de cobrança de emprestimos

  -- Chamada AyllosWeb Rotina para exportar lista de convenios ceb e suas situações
  PROCEDURE pc_export_conv_sit_web (pr_telcdcop    IN crapcop.cdcooper%TYPE DEFAULT 0 --> cooperativa
                                   ,pr_nrconven    IN crapceb.nrconven%TYPE DEFAULT 0 --> Nr. do convenio
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. do cooperado
                                   ,pr_telcdage    IN crapage.cdagenci%TYPE DEFAULT 0 --> Agencia
                                   ,pr_dtinicio    IN VARCHAR2 DEFAULT NULL           --> Data inicio periodo da consulta
                                   ,pr_dtafinal    IN VARCHAR2 DEFAULT NULL           --> Data fim periodo da consulta
                                   ,pr_insitceb    IN crapceb.insitceb%TYPE --> Situacao ceb
                                   ,pr_nmarqdst    IN VARCHAR2              --> Diretorio e nome do arquivo destino
                                   ,pr_dtmvtolt    IN VARCHAR2              --> Data do movimento
                                   ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType       --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);              --> Erros do processo                                 
                                   
  --> Rotina para alterar situacao do convenio
  PROCEDURE pc_alterar_sit_conv( pr_telcdcop  IN crapcop.cdcooper%TYPE --> cooperativa
                                ,pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Ceb
                                ,pr_insitceb  IN crapceb.insitceb%TYPE --> Situacao do convenio
                                ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Erros do processo                                       
  -- Rotina para consultar os limites de dias para protesto
  PROCEDURE pc_busca_limite_dias(pr_cdcooper  IN crapcop.cdcooper%TYPE --> cooperativa
                                ,pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2
                                );

  --> Rotina responsavel por gerar o relatorio carta anuencia - Chamada ayllos Web                                    
  PROCEDURE pc_relat_carta_anuencia_web (pr_cdcooper   IN craptab.cdcooper%TYPE  --> Cooperativa                                  
                                        ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Número da conta
                                        ,pr_nrdocmto    IN crapcob.nrdocmto%TYPE  --> Número do documento
	                                      ,pr_cdbancoc    IN crapcob.cdbandoc%TYPE  --> Código do banco
                                        ,pr_dtcatanu    IN VARCHAR2               --> Data quitação divida 
                                        ,pr_nmrepres    IN VARCHAR2               --> Representantes
                                        ,pr_dtmvtolt    IN VARCHAR2               --> data do movimento                                     
                                        ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                        ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                        ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2);             --> Erros do processo           
  
  --> Rotina responsavel por gerar o relatorio carta anuencia                         
  PROCEDURE pc_relat_carta_anuencia (pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa                                  
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Número da conta
                                    ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE         --> Número do documento
                                    ,pr_cdbancoc  IN crapcob.cdbandoc%TYPE         --> Código do banco           
                                    ,pr_dtcatanu  IN VARCHAR2                      --> Data de liquidação da dívida
                                    ,pr_nmrepres  IN VARCHAR2                      --> Representantes
																		,pr_cdoperad  IN VARCHAR2 DEFAULT '1'          --> Operador
                                    --------->> OUT <<-----------
                                    ,pr_nmarqpdf OUT VARCHAR2                      --> Retorna o nome do relatorio gerado
                                    ,pr_dsxmlrel OUT CLOB                          --> Retorna xml do relatorio quando origem for 3 -InternetBank
                                    ,pr_cdcritic OUT NUMBER                        --> Retorna codigo de critica
                                    ,pr_dscritic OUT VARCHAR2);                    --> Retorno de critica                                 
  --
	PROCEDURE pc_consulta_cod_barras_web(pr_dtvencto    IN VARCHAR2
																			,pr_cdbandoc    IN INTEGER
																			,pr_vltitulo    IN crapcob.vltitulo%TYPE
																			,pr_nrcnvcob    IN crapcob.nrcnvcob%TYPE
																			,pr_nrdconta    IN crapcob.nrdconta%TYPE
																			,pr_nrdocmto    IN crapcob.nrdocmto%TYPE
																		  ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
																		  ,pr_cdcritic   OUT PLS_INTEGER                     --> Código da crítica
																		  ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
																		  ,pr_retxml  IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
																		  ,pr_nmdcampo   OUT VARCHAR2                        --> Nome do campo com erro
																		  ,pr_des_erro   OUT VARCHAR2                        --> Erros do processo
																			);
	--
	                                   
                                    
  PROCEDURE pc_gera_arq_remes_cnab240(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                     ,pr_nrdconta      IN crapcob.nrdconta%TYPE --> Numero da conta
                                     ,pr_flgregis      IN crapcob.flgregis%TYPE --> Cobranca registrada (0=Nao/1=Sim)
                                     ,pr_tipo_consulta IN INTEGER --> Tipo de consulta (1-NAO COBRADOS/2-COBRADOS/3-TODOS)
                                     ,pr_consulta      IN INTEGER --> Consulta (1-CONTA/2-DOCUMENTO/3-EMISSAO/4-PAGAMENTO/5-VENCIMENTO/6-PERIODO)
                                     ,pr_inestcri      IN crapret.inestcri%TYPE --> Somente crise (0=Nao/1=Sim)
                                     ,pr_ini_documento IN crapcob.nrdocmto%TYPE --> Numero inicial de documento
                                     ,pr_fim_documento IN crapcob.nrdocmto%TYPE --> Numero final de documento
                                     ,pr_stprogra      OUT PLS_INTEGER --> Saída de termino da execução
                                     ,pr_infimsol      OUT PLS_INTEGER --> Saída de termino da solicitação
                                     ,pr_nmarqrem      OUT VARCHAR2 --> Caminho e nome do arquivo de remessa a ser exportado
                                     ,pr_cdcritic      OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                     ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                                      );
                                      
  PROCEDURE pc_gera_arq_remes_cnab240_web(pr_nrdconta      IN VARCHAR2 --> Número da conta
                                         ,pr_flgregis      IN VARCHAR2 --> Cobranca registrada (0=Nao / 1=Sim)
                                         ,pr_tipo_consulta IN VARCHAR2 --> Tipo de consulta (1-NAO COBRADOS/2-COBRADOS/3-TODOS)
                                         ,pr_consulta      IN VARCHAR2 --> Consulta (1-CONTA/2-DOCUMENTO/3-EMISSAO/4-PAGAMENTO/5-VENCIMENTO/6-PERIODO)
                                         ,pr_inestcri      IN VARCHAR2 --> Somente crise (0=Nao/1=Sim)
                                         ,pr_ini_documento IN VARCHAR2 --> Numero inicial de documento
                                         ,pr_fim_documento IN VARCHAR2 --> Numero final de documento
                                         ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                                         ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                                         ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro      OUT VARCHAR2);

END TELA_COBRAN;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_COBRAN IS
  /*-------------------------------------------------------------------------
  --
  --  Programa : TELA_COBRAN
  --  Sistema  : Rotinas utilizadas pela Tela COBRAN
  --  Sigla    : Cobran
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Maio/2016.                   Ultima atualizacao: 20/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela COBRAN
  --
  -- Alteracoes:
  --             01/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
  --
  --             03/04/2018 - Inserido noti0001.pc_cria_notificacao
  --
	--             20/08/2018 - Inserido 
	--
  ---------------------------------------------------------------------------*/
  -- Chamada AyllosWeb Rotina para retornar lista de convenios ceb e suas situações
  PROCEDURE pc_consulta_conv_sit_web (pr_telcdcop    IN crapcop.cdcooper%TYPE DEFAULT 0 --> cooperativa
                                     ,pr_nrconven    IN crapceb.nrconven%TYPE DEFAULT 0 --> Nr. do convenio
                                     ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. do cooperado
                                     ,pr_telcdage    IN crapage.cdagenci%TYPE DEFAULT 0 --> Agencia
                                     ,pr_dtinicio    IN VARCHAR2 DEFAULT NULL           --> Data inicio periodo da consulta   
                                     ,pr_dtafinal    IN VARCHAR2 DEFAULT NULL           --> Data fim periodo da consulta
                                     ,pr_insitceb    IN crapceb.insitceb%TYPE           --> Situacao ceb
                                     ,pr_nriniseq    IN NUMBER DEFAULT 1                --> Registro inicial para paginacao
                                     ,pr_nrregist    IN NUMBER DEFAULT 100              --> Qtd Registro inicial para paginacao
                                     ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER                     --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
                                     ,pr_retxml  IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2                        --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2) IS                    --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_conv_sit_web
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Odirlei Busana (AMcom)
        Data    : Maio/2016.                    Ultima atualizacao: --/--/----
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
      
        Objetivo  : Rotina retorna lista de convenio e suas situacoes
      
        Observacao: -----
      
        Alteracoes:
      ..............................................................................*/
  
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- PL/Table
    vr_tab_crapceb typ_tab_crapceb; -- PL/Table com os dados retornados da procedure
    vr_idx          INTEGER := 0; -- Indice para a PL/Table retornada da procedure
      
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_dtinicio DATE;
    vr_dtafinal DATE;
    vr_qtregtot NUMBER;
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    vr_dtinicio := to_date(pr_dtinicio, 'DD/MM/RRRR');
    vr_dtafinal := to_date(pr_dtafinal, 'DD/MM/RRRR');
    
    pc_consulta_conv_sit (pr_cdcooper    => nvl(pr_telcdcop,0),
                          pr_nrconven    => nvl(pr_nrconven,0),
                          pr_nrdconta    => nvl(pr_nrdconta,0),
                          pr_cdagenci    => nvl(pr_telcdage,0),
                          pr_dtinicio    => vr_dtinicio,
                          pr_dtafinal    => vr_dtafinal,
                          pr_insitceb    => pr_insitceb,
                          pr_nriniseq    => pr_nriniseq,
                          pr_nrregist    => pr_nrregist,
                          pr_cdoperad    => vr_cdoperad,
                          pr_cdcritic    => vr_cdcritic,
                          pr_dscritic    => vr_dscritic,
                          pr_qtdregtot   => vr_qtregtot,
                          pr_tab_crapceb => vr_tab_crapceb);
    -- Se retornou alguma crítica
    IF vr_cdcritic <> 0 OR
       vr_dscritic IS NOT NULL THEN
      -- Levantar exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Se PL/Table possuir algum registro
    IF vr_tab_crapceb.count() > 0 THEN
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      vr_texto_completo := NULL;
      
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><root><dados>');
      -- Atribui registro inicial como indice
      vr_idx := vr_tab_crapceb.FIRST;              
      WHILE vr_idx IS NOT NULL  LOOP
      
        pc_escreve_xml('<inf>'||
                        '<cdcooper>' || vr_tab_crapceb(vr_idx).cdcooper ||'</cdcooper>' ||
                        '<nmrescop>' || vr_tab_crapceb(vr_idx).nmrescop ||'</nmrescop>' ||
                        '<cdagenci>' || vr_tab_crapceb(vr_idx).cdagenci ||'</cdagenci>' ||
                        '<nrdconta>' || gene0002.fn_mask_conta(vr_tab_crapceb(vr_idx).nrdconta) ||'</nrdconta>' ||
                        '<nrcpfcgc>' || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_crapceb(vr_idx).nrcpfcgc,
                                                                  pr_inpessoa => vr_tab_crapceb(vr_idx).inpessoa  ) ||'</nrcpfcgc>' ||
                        '<nmprimtl>' || substr(vr_tab_crapceb(vr_idx).nmprimtl,1,30) ||'</nmprimtl>' ||
                        '<nrconven>' || gene0002.fn_mask_contrato(vr_tab_crapceb(vr_idx).nrconven) ||'</nrconven>' ||
                        '<nrcnvceb>' || vr_tab_crapceb(vr_idx).nrcnvceb ||'</nrcnvceb>' ||
                        '<dsorgarq>' || vr_tab_crapceb(vr_idx).dsorgarq ||'</dsorgarq>' ||
                        '<dhanalis>' || to_char(vr_tab_crapceb(vr_idx).dhanalis,'DD/MM/RRRR') ||'</dhanalis>' ||
                        '<nmoperad>' || vr_tab_crapceb(vr_idx).nmoperad ||'</nmoperad>' ||
                        '<insitceb>' || vr_tab_crapceb(vr_idx).insitceb ||'</insitceb>' ||
                        '<dssitceb>' || vr_tab_crapceb(vr_idx).dssitceb ||'</dssitceb>' ||                       
                       '</inf>'); 
          
        -- Busca próximo indice
        vr_idx := vr_tab_crapceb.NEXT(vr_idx);
          
      END LOOP;
        
        pc_escreve_xml('</dados></root>',TRUE);        
        pr_retxml := XMLType.createXML(vr_des_xml);
      
        -- Quantidade total de registros
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Qtdregis',
                               pr_tag_cont => vr_qtregtot,
                               pr_des_erro => vr_dscritic);
    ELSE
      -- Atribui crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Dados nao encontrados!';
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_conv_sit_web;

  -- Rotina para retornar lista de convenios ceb e suas situações
  PROCEDURE pc_consulta_conv_sit (pr_cdcooper    IN crapcop.cdcooper%TYPE DEFAULT 0 --> Cooperativa
                                 ,pr_nrconven    IN crapceb.nrconven%TYPE DEFAULT 0 --> Nr. do convenio
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. do cooperado
                                 ,pr_cdagenci    IN crapage.cdagenci%TYPE DEFAULT 0 --> Agencia
                                 ,pr_dtinicio    IN DATE DEFAULT NULL               --> Data inicio periodo da consulta 
                                 ,pr_dtafinal    IN DATE DEFAULT NULL               --> Data fim periodo da consulta
                                 ,pr_insitceb    IN crapceb.insitceb%TYPE           --> Situacao ceb
                                 ,pr_nriniseq    IN NUMBER DEFAULT 1                --> Registro inicial para paginacao
                                 ,pr_nrregist    IN NUMBER DEFAULT 100              --> Qtd Registro inicial para paginacao
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Cód. Operador
                                 ,pr_cdcritic    OUT crapcri.cdcritic%TYPE          --> Cód. da crítica
                                 ,pr_dscritic    OUT crapcri.dscritic%TYPE          --> Descrição da crítica
                                 ,pr_qtdregtot   OUT NUMBER                         --> Quantidade total de registros
                                 ,pr_tab_crapceb OUT typ_tab_crapceb) IS            --> Pl/Table com os dados de cobrança de emprestimos
    /* .............................................................................
    
      Programa: pc_consulta_conv_sit
      Sistema : CECRED
      Sigla   : COBRAN
      Autor   : Odirlei Busana (AMcom)
      Data    : Maio/2016.                    Ultima atualizacao: --/--/----
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina retorna lista de convenio e suas situacoes
    
      Observacao: -----
    
      Alteracoes:
    ..............................................................................*/
      ----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      vr_idx       INTEGER := 0;
      vr_indachou  INTEGER := 0;
    
      ---------------------------- CURSORES -----------------------------------
      --> Buscar registros crapceb
      CURSOR cr_crapceb IS
        SELECT * 
          FROM (SELECT cop.nmrescop
                      ,cop.cdcooper
                      ,ass.cdagenci
                      ,ass.nrdconta
                      ,ass.nrcpfcgc
                      ,ass.inpessoa
                      ,ass.nmprimtl
                      ,ceb.nrconven
                      ,ceb.nrcnvceb
                      ,cco.dsorgarq
                      ,ceb.dhanalis
                      ,ope.nmoperad
                      ,ceb.insitceb
                      ,ROW_NUMBER() OVER ( ORDER BY cop.nmrescop,ass.cdagenci,ass.nrdconta,ceb.nrconven,ceb.progress_recid) rnum
                      ,COUNT(*) over () qtregtot
                  FROM crapcop cop
                      ,crapceb ceb
                      ,crapcco cco
                      ,crapass ass
                      ,crapope ope
                 WHERE (pr_cdcooper = 0 OR ceb.cdcooper = pr_cdcooper)
                   AND (pr_nrconven = 0 OR ceb.nrconven = pr_nrconven)           
                   AND (pr_nrdconta = 0 OR ceb.nrdconta = pr_nrdconta)
                   AND (pr_cdagenci = 0 OR ass.cdagenci = pr_cdagenci)
                   AND (pr_dtinicio IS NULL OR ceb.dtcadast >= pr_dtinicio)
                   AND (pr_dtafinal IS NULL OR ceb.dtcadast <= pr_dtafinal)
                   AND (pr_insitceb = 0 OR ceb.insitceb = pr_insitceb)
                   AND cop.cdcooper = ceb.cdcooper
                   AND ass.cdcooper = ceb.cdcooper
                   AND ass.nrdconta = ceb.nrdconta
                   AND cco.cdcooper = ceb.cdcooper
                   AND cco.nrconven = ceb.nrconven
                   AND ope.cdcooper(+) = ceb.cdcooper
                   AND ope.cdoperad(+) = ceb.cdopeana
                 ORDER BY cop.nmrescop
                         ,ass.cdagenci
                         ,ass.nrdconta
                         ,ceb.nrconven)
          WHERE (rnum >= pr_nriniseq AND 
                 rnum <= (pr_nriniseq + pr_nrregist-1))
             OR pr_nrregist = 0;
      rw_crapceb cr_crapceb%ROWTYPE;
      
      --> Validar associado
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE,
                         pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM crapass ass
         WHERE ass.cdcooper = decode(pr_cdcooper,0,ass.cdcooper,pr_cdcooper) 
           AND ass.nrdconta = pr_nrdconta;
      
      --> Validar agencia
      CURSOR cr_crapage (pr_cdcooper crapcop.cdcooper%TYPE,
                         pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT 1
          FROM crapage age
         WHERE age.cdcooper = decode(pr_cdcooper,0,age.cdcooper,pr_cdcooper) 
           AND age.cdagenci = pr_cdagenci;
                
      --> Validar convenio     
      CURSOR cr_crapcco (pr_cdcooper crapcop.cdcooper%TYPE,
                         pr_nrconven crapcco.nrconven%TYPE)IS
        SELECT 1
          FROM crapcco cco
         WHERE cco.cdcooper = decode(pr_cdcooper,0,cco.cdcooper,pr_cdcooper) 
           AND cco.nrconven = pr_nrconven;
    BEGIN
    
      ---------------------------------- VALIDACOES INICIAIS --------------------------
    
      --> Validar associado
      IF pr_nrdconta <> 0 THEN
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO vr_indachou;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_cdcritic := 9; -- associado nao encontrado
          -- Levanta exceção
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
      END IF;                   
      
      --> Validar agencia
      IF pr_cdagenci <> 0 THEN
        OPEN cr_crapage (pr_cdcooper => pr_cdcooper,
                         pr_cdagenci => pr_cdagenci);
        FETCH cr_crapage INTO vr_indachou;
        IF cr_crapage%NOTFOUND THEN
          CLOSE cr_crapage;
          vr_cdcritic := 015; -- Agencia nao cadastrada.
          -- Levanta exceção
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapage;
      END IF;       
                
      --> Validar convenio 
      IF pr_nrconven <> 0 THEN
        OPEN cr_crapcco (pr_cdcooper => pr_cdcooper,
                         pr_nrconven => pr_nrconven);
        FETCH cr_crapcco INTO vr_indachou;
        IF cr_crapcco%NOTFOUND THEN
          CLOSE cr_crapcco;
          vr_cdcritic := 563; -- Convenio nao cadastrado.
          -- Levanta exceção
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcco;
      END IF;
            
      -- Gera exceção se informar data de inicio e não informar data final e vice-versa
      IF pr_dtinicio IS NULL    AND 
         nvl(pr_nrdconta,0) = 0 AND 
         nvl(pr_cdagenci,0) = 0 AND 
         nvl(pr_nrconven,0) = 0 THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Inicial deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_dtafinal IS NULL AND 
         nvl(pr_nrdconta,0) = 0 AND 
         nvl(pr_cdagenci,0) = 0 AND 
         nvl(pr_nrconven,0) = 0 THEN        
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_dtafinal < pr_dtinicio THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser superior a Data Inicial.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      
      vr_idx := 0;
      
      -- Abre cursor para atribuir os registros encontrados na PL/Table
      FOR rw_crapceb IN cr_crapceb LOOP
      
        -- Incrementa contador para utilizar como indice da PL/Table
        vr_idx := vr_idx + 1;
        
        pr_tab_crapceb(vr_idx).cdcooper := rw_crapceb.cdcooper; 
        pr_tab_crapceb(vr_idx).nmrescop := rw_crapceb.nmrescop; 
        pr_tab_crapceb(vr_idx).cdagenci := rw_crapceb.cdagenci;
        pr_tab_crapceb(vr_idx).nrdconta := rw_crapceb.nrdconta;
        pr_tab_crapceb(vr_idx).nrcpfcgc := rw_crapceb.nrcpfcgc;
        pr_tab_crapceb(vr_idx).inpessoa := rw_crapceb.inpessoa;
        pr_tab_crapceb(vr_idx).nmprimtl := rw_crapceb.nmprimtl;
        pr_tab_crapceb(vr_idx).nrconven := rw_crapceb.nrconven;
        pr_tab_crapceb(vr_idx).nrcnvceb := rw_crapceb.nrcnvceb;
        pr_tab_crapceb(vr_idx).dsorgarq := rw_crapceb.dsorgarq;
        pr_tab_crapceb(vr_idx).dhanalis := rw_crapceb.dhanalis;
        pr_tab_crapceb(vr_idx).nmoperad := rw_crapceb.nmoperad;
        pr_tab_crapceb(vr_idx).insitceb := rw_crapceb.insitceb;
        
        SELECT CASE rw_crapceb.insitceb
                 WHEN 1 THEN 'ATIVO'    
                 WHEN 2 THEN 'INATIVO'
                 WHEN 3 THEN 'PENDENTE'
                 WHEN 4 THEN 'BLOQUEADO'
                 WHEN 5 THEN 'APROVADO'
                 WHEN 6 THEN 'NÃO APROV.'
               ELSE 'Descricao nao encontrada'
               END CASE
        INTO pr_tab_crapceb(vr_idx).dssitceb
        FROM dual;
        
        pr_qtdregtot := rw_crapceb.qtregtot;
      
      END LOOP;
      
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se possui código de crítica e não foi informado a descrição
      IF vr_cdcritic <> 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- Busca descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      -- Atribui exceção para os parametros de crítica
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Atribui exceção para os parametros de crítica
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro nao tratado na TELA_COBRAN.pc_consulta_conv_sit: ' || SQLERRM;
      
  END pc_consulta_conv_sit;
  
  -- Chamada AyllosWeb Rotina para exportar lista de convenios ceb e suas situações
  PROCEDURE pc_export_conv_sit_web (pr_telcdcop    IN crapcop.cdcooper%TYPE DEFAULT 0 --> cooperativa
                                   ,pr_nrconven    IN crapceb.nrconven%TYPE DEFAULT 0 --> Nr. do convenio
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. do cooperado
                                   ,pr_telcdage    IN crapage.cdagenci%TYPE DEFAULT 0 --> Agencia
                                   ,pr_dtinicio    IN VARCHAR2 DEFAULT NULL           --> Data inicio periodo da consulta
                                   ,pr_dtafinal    IN VARCHAR2 DEFAULT NULL           --> Data fim periodo da consulta
                                   ,pr_insitceb    IN crapceb.insitceb%TYPE --> Situacao ceb
                                   ,pr_nmarqdst    IN VARCHAR2              --> Diretorio e nome do arquivo destino
                                   ,pr_dtmvtolt    IN VARCHAR2              --> Data do movimento
                                   ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType       --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo
    /* .............................................................................
    
        Programa: pc_export_conv_sit_web
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Odirlei Busana (AMcom)
        Data    : Maio/2016.                    Ultima atualizacao: --/--/----
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
      
        Objetivo  : Rotina exportar lista de convenio e suas situacoes
      
        Observacao: -----
      
        Alteracoes:
      ..............................................................................*/
  
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- PL/Table
    vr_tab_crapceb typ_tab_crapceb; -- PL/Table com os dados retornados da procedure
    vr_idx          INTEGER := 0; -- Indice para a PL/Table retornada da procedure
      
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_dtinicio DATE;
    vr_dtafinal DATE;
    vr_dtmvtolt DATE;
    vr_qtregtot NUMBER;
    -- Variáveis para armazenar as informações 
    vr_dsarquiv         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    IF gene0001.fn_exis_arquivo(pr_caminho => pr_nmarqdst) THEN
      vr_dscritic := 'já existe um arquivo com esse nome';
      RAISE vr_exc_saida;
    END IF;
    
    -- Converter datas do parametro
    vr_dtinicio := to_date(pr_dtinicio, 'DD/MM/RRRR');
    vr_dtafinal := to_date(pr_dtafinal, 'DD/MM/RRRR');
    vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
    
    --> Rotina para retornar dados da consulta
    pc_consulta_conv_sit (pr_cdcooper    => nvl(pr_telcdcop,0),
                          pr_nrconven    => nvl(pr_nrconven,0),
                          pr_nrdconta    => nvl(pr_nrdconta,0),
                          pr_cdagenci    => nvl(pr_telcdage,0),
                          pr_dtinicio    => vr_dtinicio,
                          pr_dtafinal    => vr_dtafinal,
                          pr_insitceb    => pr_insitceb,
                          pr_nriniseq    => 0,
                          pr_nrregist    => 0,
                          pr_cdoperad    => vr_cdoperad,
                          pr_cdcritic    => vr_cdcritic,
                          pr_dscritic    => vr_dscritic,
                          pr_qtdregtot   => vr_qtregtot,
                          pr_tab_crapceb => vr_tab_crapceb);
    -- Se retornou alguma crítica
    IF vr_cdcritic <> 0 OR
       vr_dscritic IS NOT NULL THEN
      -- Levantar exceção
      RAISE vr_exc_saida;
    END IF;   
    
    -- Se PL/Table possuir algum registro
    IF vr_tab_crapceb.count() > 0 THEN
    
      -- Inicializar o CLOB
      vr_dsarquiv := NULL;
      dbms_lob.createtemporary(vr_dsarquiv, TRUE);
      dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
      vr_texto_completo := NULL; 
      -- Cabecalho
      pc_escreve_xml('Cooperativa;PA;Conta/DV;CPF/CNPJ;Razão Social;Convênio;Tipo de convênio;Dt Análise;Operador;Status');
      
      -- Atribui registro inicial como indice
      vr_idx := vr_tab_crapceb.FIRST;              
      WHILE vr_idx IS NOT NULL  LOOP
        --> Montar linhas
        pc_escreve_xml(  vr_tab_crapceb(vr_idx).nmrescop ||';' ||
                         vr_tab_crapceb(vr_idx).cdagenci ||';' ||
                         gene0002.fn_mask_conta(vr_tab_crapceb(vr_idx).nrdconta) ||';' ||
                         gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_crapceb(vr_idx).nrcpfcgc,
                                                   pr_inpessoa => vr_tab_crapceb(vr_idx).inpessoa  ) ||';' ||
                         vr_tab_crapceb(vr_idx).nmprimtl||';' ||
                         gene0002.fn_mask_contrato(vr_tab_crapceb(vr_idx).nrconven) ||';' ||
                         vr_tab_crapceb(vr_idx).dsorgarq ||';' ||
                         to_char(vr_tab_crapceb(vr_idx).dhanalis,'DD/MM/RRRR') ||';' ||
                         vr_tab_crapceb(vr_idx).nmoperad ||';' ||
                         vr_tab_crapceb(vr_idx).insitceb ||';' ||
                         vr_tab_crapceb(vr_idx).dssitceb || chr(10)); 
          
        -- Busca próximo indice
        vr_idx := vr_tab_crapceb.NEXT(vr_idx);
          
      END LOOP;
        
      pc_escreve_xml(chr(10),TRUE);        
      
      --Solicitar geracao do arquivo fisico
      GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper -- coop Cecred          --> Cooperativa conectada
                                         ,pr_cdprogra  => 'COBRAN'                  --> Programa chamador
                                         ,pr_dtmvtolt  => vr_dtmvtolt               --> Data do movimento atual
                                         ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                         ,pr_dsarqsaid => pr_nmarqdst               --> Path/Nome do arquivo PDF gerado
                                         ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                         ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                         ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                         ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                         ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                         ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                         ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviará o arquivo
                                         ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                         ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                         ,pr_flappend  => 'N'
                                         ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dsarquiv);
      dbms_lob.freetemporary(vr_dsarquiv); 
    
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      
      --> Garantir que o arquivo foi gerado
      IF gene0001.fn_exis_arquivo(pr_caminho => pr_nmarqdst) = FALSE THEN
        vr_dscritic := 'Não foi possivel gerar arquivo, tente novamente.';
        RAISE vr_exc_saida;
      END IF;      
      
    ELSE
      -- Atribui crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Dados nao encontrados!';
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_export_conv_sit_web;
  
  --> Rotina para alterar situacao do convenio
  PROCEDURE pc_alterar_sit_conv( pr_telcdcop  IN crapcop.cdcooper%TYPE --> cooperativa
                                ,pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Ceb
                                ,pr_insitceb  IN crapceb.insitceb%TYPE --> Situacao do convenio
                                ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo   
 
  /* .............................................................................

    Programa: pc_alterar_sit_conv          
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Abril/2016                 Ultima atualizacao: 08/12/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar a situacao do convenio.

    Alteracoes: 08/12/2017 - Inclusão de commit/rollback para finalizar a transação
                             e possibilitar a chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                             (SD#791193 - AJFink)

  ..............................................................................*/
    
    ------------> CURSORES <------------
    
    -- Cadastro de associados
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT to_char(crapass.nrdconta) nrdconta
            ,crapass.inpessoa
            ,decode(crapass.inpessoa,1,'F','J') dspessoa
            ,crapass.nmprimtl
            ,to_char(crapass.nrcpfcgc) nrcpfcgc
            ,to_char(crapcop.cdagectl) cdagectl
            ,crapcop.nmrescop 
        FROM crapass,
             crapcop 
       WHERE crapass.cdcooper = crapcop.cdcooper
         AND crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    
    -- Cadastro de Bloquetos
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                     ,pr_nrdconta IN crapceb.nrdconta%TYPE
                     ,pr_nrconven IN crapceb.nrconven%TYPE
                     ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE) IS
      SELECT crapceb.insitceb
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrdconta = pr_nrdconta
         AND crapceb.nrconven = pr_nrconven
         AND crapceb.nrcnvceb = pr_nrcnvceb;
    rw_crapceb cr_crapceb%ROWTYPE;
    
    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    ------------> VARIAVEIS <-----------  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(2000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(1000);
    vr_dsdmesag VARCHAR2(1000);
    vr_flgimpri PLS_INTEGER;
    
    vr_dtativac VARCHAR2(8);
    vr_nrconven VARCHAR2(10);
    vr_insitif  VARCHAR2(10);
    vr_insitcip VARCHAR2(10);    
    vr_dsdmensg     VARCHAR2(500);    
    vr_dsdemail_dst VARCHAR2(100);  
	
    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 8;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 5; 
     
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
  
    IF pr_insitceb NOT IN (5,6) THEN
      vr_dscritic := 'Nova situacao do convenio invalida.';          
      RAISE vr_exc_saida;             
    END IF;
    
    -- Seta a descricao da transacao
    CASE pr_insitceb
      WHEN 5 THEN vr_dstransa := 'Aprovar convenio de cobranca.';
      WHEN 6 THEN vr_dstransa := 'Reprovar convenio de cobranca.';
    END CASE;
    
    -- Cadastro de associados
    OPEN cr_crapass(pr_cdcooper => pr_telcdcop
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se NAO encontrou
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      CLOSE cr_crapass;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;
    
    -- Verificacao do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_telcdcop);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    --> Buscar situacao do benificiario na cip
    vr_insitif  := NULL;
    vr_insitcip := NULL;
    DDDA0001.pc_ret_sit_beneficiario( pr_inpessoa  => rw_crapass.inpessoa,  --> Tipo de pessoa
                                      pr_nrcpfcgc  => rw_crapass.nrcpfcgc,  --> CPF/CNPJ do beneficiario
                                      pr_insitif   => vr_insitif,           --> Retornar situação IF
                                      pr_insitcip  => vr_insitcip,          --> Retorna situação na CIP
                                      pr_dscritic  => vr_dscritic);         --> Retorna critica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;           
    
    -- Cadastro de bloquetos
    OPEN cr_crapceb(pr_cdcooper => pr_telcdcop
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven
                   ,pr_nrcnvceb => pr_nrcnvceb);
    FETCH cr_crapceb INTO rw_crapceb;
    CLOSE cr_crapceb;    
      
    IF rw_crapceb.insitceb <> 3 THEN
      vr_dscritic := 'Convenio nao esta pendente.';          
      RAISE vr_exc_saida;       
    END IF;
    
             
    
    IF pr_insitceb IN (5,6) AND vr_insitif = 'E' THEN 
      vr_dscritic := 'Situacao em analise pela Central.';          
      RAISE vr_exc_saida;             
    END IF;
    
    IF pr_insitceb = 5 AND vr_insitif = 'I' THEN 
      vr_dscritic := 'Cooperado Inapto.';          
      RAISE vr_exc_saida;             
    END IF;
    
    ------->> ATUALIZAR CONVENIO <<--------
    COBR0008.pc_alter_insitceb(pr_idorigem => vr_idorigem,               --> Sistema origem
                               pr_cdcooper => pr_telcdcop,               --> Codigo da cooperativa
                               pr_cdoperad => vr_cdoperad,               --> Codigo do operador
                               pr_nrdconta => pr_nrdconta,               --> Numero da conta do cooperado
                               pr_nrconven => pr_nrconven,               --> Numero do convenio
                               pr_nrcnvceb => pr_nrcnvceb,               --> Numero do bloqueto
                               pr_insitceb => pr_insitceb,               --> Nova situação(5 Aprovado, 6 Nao Aprovado)
                               pr_dscritic => vr_dscritic);              --> Retorna critica              
    
    -- Se o convenio foi aprovado
    IF pr_insitceb = 5 THEN
            
      ------->> GRAVAR MENSAGEM IBANK <<--------
      vr_dsdmensg := 'Seus convênios de cobrança foram Aprovados.' || '\n' ||
                     'Favor dirigir-se ao seu PA de relacionamento.';

      -- Insere na tabela de mensagens (CRAPMSG)
      GENE0003.pc_gerar_mensagem
                 (pr_cdcooper => pr_telcdcop
                 ,pr_nrdconta => pr_nrdconta
                 ,pr_idseqttl => 0           /* Titular */
                 ,pr_cdprogra => 'COBRAN'    /* Programa */
                 ,pr_inpriori => 0
                 ,pr_dsdmensg => vr_dsdmensg /* corpo da mensagem */
                 ,pr_dsdassun => 'Convênio de Cobrança Aprovado' /* Assunto */
                 ,pr_dsdremet => rw_crapass.nmrescop 
                 ,pr_dsdplchv => 'Cobranca'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdcadmsg => 0
                 ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Cria uma notificação
      noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                  ,pr_cdmotivo_mensagem => vr_notif_motivo
                                  ,pr_cdcooper => pr_telcdcop
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_variaveis => vr_variaveis_notif);
								                
      ------->> NOTIFICAR SAC <<--------
      vr_dsdmensg := 'Convênio de cobrança do cooperado: ' || pr_nrdconta || 
                     ' foi <b>Aprovado</b> - Cooperativa: ' || rw_crapass.nmrescop ||
                     '<br>Favor entrar em contato com o mesmo para dirigir-se ao'||
                     ' seu PA de relacionamento  e assinar o Termo de Adesão';
                      
      -->  Buscar destinatario de email
      vr_dsdemail_dst := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                    pr_cdcooper => pr_telcdcop, 
                                                    pr_cdacesso => 'EMAIL_CONV_APROVADO');  
              
      /* Envio do arquivo detalhado via e-mail */
      gene0003.pc_solicita_email(
                pr_cdcooper        => pr_telcdcop
               ,pr_cdprogra        => 'COBRAN'
               ,pr_des_destino     => vr_dsdemail_dst
               ,pr_des_assunto     => 'Aprovacao de Convenio de Cobranca - ' || rw_crapass.nmrescop
               ,pr_des_corpo       => vr_dsdmensg
               ,pr_des_anexo       => NULL
               ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
               ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
               ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
               ,pr_des_erro        => vr_dscritic);                  
            
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF; --> FIM IF pr_insitceb = 5        
    
    --> Tratar retorno
    CASE pr_insitceb
      WHEN 5 THEN vr_dsdmesag := gene0007.fn_acento_xml('Convênio aprovado com sucesso.');
      WHEN 6 THEN vr_dsdmesag := gene0007.fn_acento_xml('Convênio reprovado com sucesso.');
    END CASE;
    
    --> Condiçao nova proposta pelo Victor em 02/08/2016
    IF pr_insitceb = 6 THEN
      --> quando convenio for "reprovado", deverá ativar o convenio na cabine JDBNF
      --> para que a area de seguranca corporativa possa incluir indicio de fraude lá na cabine JDBNF      
      ddda0001.pc_atualiza_sit_JDBNF(pr_cdcooper => vr_cdcooper
                                   , pr_nrdconta => pr_nrdconta
                                   , pr_nrconven => pr_nrconven
                                   , pr_insitceb => 1 --> ativar convenio na cabine JDBNF
                                   , pr_cdcritic => vr_cdcritic
                                   , pr_dscritic => vr_dscritic);
                                   
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                                   
    END IF;
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dsdmesag'
                          ,pr_tag_cont => vr_dsdmesag
                          ,pr_des_erro => vr_dscritic); 
    
    COMMIT;
    npcb0002.pc_libera_sessao_sqlserver_npc('TELA_COBRAN_1');
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc('TELA_COBRAN_2');

      -- Gerar informacoes do log
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> FALSE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'COBRAN'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina pc_alterar_sit_conv: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc('TELA_COBRAN_3');
  END pc_alterar_sit_conv;  

  -- Rotina para consultar os limites de dias para protesto
  PROCEDURE pc_busca_limite_dias(pr_cdcooper  IN crapcop.cdcooper%TYPE --> cooperativa
                                ,pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2
                                ) IS          --> Erros do processo   
 
  /* .............................................................................

    Programa: pc_busca_limite_dias          
    Sistema : Ayllos Web
    Autor   : Supero
    Data    : Fevereiro/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para consultar os limites de dias minímo e máximo para protesto

    Alteracoes:
  ..............................................................................*/

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(2000);
    vr_des_erro VARCHAR2(100);
    --
    vr_qtlimmip crapceb.qtlimmip%TYPE;
    vr_qtlimaxp crapceb.qtlimaxp%TYPE;
    vr_exc_saida EXCEPTION;
    --
  BEGIN    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
      
    --
    BEGIN
      SELECT crapceb.qtlimmip
            ,crapceb.qtlimaxp
        INTO vr_qtlimmip
            ,vr_qtlimaxp
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrdconta = pr_nrdconta
         AND crapceb.nrconven = pr_nrconven;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE vr_exc_saida;
    END;
    
    IF vr_qtlimmip = 0 AND 
       vr_qtlimaxp = 0 THEN
         
       tela_parprt.pc_consulta_periodo_parprt(pr_cdcooper => pr_cdcooper
                                             ,pr_qtlimitemin_tolerancia => vr_qtlimmip
                                             ,pr_qtlimitemax_tolerancia => vr_qtlimaxp
                                             ,pr_des_erro => vr_des_erro
                                             ,pr_dscritic => vr_dscritic);
                                               
       -- se a cooperativa não possuir os limites, então utilizar os limites
       -- já utilizados nos convênios de cobrança BB
       IF vr_qtlimmip = 0 AND
          vr_qtlimaxp = 0 THEN
          vr_qtlimmip := 5;
          vr_qtlimaxp := 15;
       END IF;
    END IF;     
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');    
                  
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic
                          );
    --
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qtlimmip'
                          ,pr_tag_cont => vr_qtlimmip
                          ,pr_des_erro => vr_dscritic
                          ); 
    --
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qtlimaxp'
                          ,pr_tag_cont => vr_qtlimaxp
                          ,pr_des_erro => vr_dscritic
                          ); 
    --
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro ao buscar parametro do cooperado: ' || pr_nrconven;
      pr_dscritic := 'Erro ao buscar parametro do cooperado: ' || pr_nrconven;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro geral em TELA_COBRAN.PC_BUSCA_LIMITE_DIAS: ' || SQLERRM;
      pr_dscritic := 'Erro geral em TELA_COBRAN.PC_BUSCA_LIMITE_DIAS: ' || SQLERRM;
  END pc_busca_limite_dias; 

  --> Rotina para disponibilizar uma carta de anuencia - Chamada ayllos Web
  PROCEDURE pc_relat_carta_anuencia_web (pr_cdcooper   IN craptab.cdcooper%TYPE  --> Cooperativa                                  
                                        ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Número da conta
                                        ,pr_nrdocmto    IN crapcob.nrdocmto%TYPE  --> Número do documento
                                        ,pr_cdbancoc    IN crapcob.cdbandoc%TYPE  --> Código do banco
                                        ,pr_dtcatanu    IN VARCHAR2               --> Data quitação divida
                                        ,pr_nmrepres    IN VARCHAR2               --> Representantes
                                        ,pr_dtmvtolt    IN VARCHAR2               --> data do movimento                                     
                                        ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                        ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                        ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2) IS           --> Erros do processo
  /* ............................................................................

       Programa: pc_relat_carta_anuencia_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Fevereiro/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de carta anuencia - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
 
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_dsretorn VARCHAR2(1000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);
    -- Variaveis gerais
    vr_nmarqpdf VARCHAR2(1000);
    vr_dsxmlrel CLOB;
    
    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;        
    
    cursor cr_crapcob (pr_cdcooper crapcob.cdcooper%TYPE,

                     pr_nrdconta crapcob.nrdconta%TYPE,
                     pr_cdbandoc crapcob.cdbandoc%TYPE,
                     pr_nrdocmto crapcob.nrdocmto%TYPE) is
      SELECT cob.rowid
        FROM crapass pas, 
             crapcob cob, 
             crapsab sab,
             crapenc enc
        WHERE
             cob.cdcooper = pr_cdcooper 
       AND cob.cdbandoc = pr_cdbandoc 
       AND cob.nrdconta = pr_nrdconta 
       AND cob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%rowtype;

  BEGIN
    OPEN cr_crapcob(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_cdbandoc => pr_cdbancoc,
                    pr_nrdocmto => pr_nrdocmto);
    FETCH cr_crapcob INTO rw_crapcob;
  
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

    pc_relat_carta_anuencia (pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa 
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdocmto => pr_nrdocmto
                             ,pr_cdbancoc => pr_cdbancoc
                             ,pr_dtcatanu => pr_dtcatanu
                             ,pr_nmrepres => pr_nmrepres
														 ,pr_cdoperad => vr_cdoperad
                             --------->> OUT <<-----------
                             ,pr_nmarqpdf => vr_nmarqpdf    --> Retorna o nome do relatorio gerado
                             ,pr_dsxmlrel => vr_dsxmlrel    --> Retorna xml do relatorio quando origem for 3 -InternetBank
                             ,pr_cdcritic => vr_cdcritic    --> Retorna codigo de critica 
                             ,pr_dscritic => vr_dscritic);  --> Retorno de critica
                             
    -- Verificacao do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;                             
                                 
   COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                     ,pr_cdocorre => 98   -- Instrucao Rejeitada
                                     ,pr_cdmotivo => 'F2' -- Motivo
                                     ,pr_vltarifa => 0    -- Valor da Tarifa  
                                     ,pr_cdbcoctl => 0
                                     ,pr_cdagectl => 0
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdoperad => '1'
                                     ,pr_nrremass => 0
                                     ,pr_dtcatanu => to_date(pr_dtcatanu,'DD/MM/RRRR')
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);                                                  
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                      ,pr_tag_pai  => 'Dados'
                      ,pr_posicao  => 0
                      ,pr_tag_nova => 'nmarqpdf'
                      ,pr_tag_cont => vr_nmarqpdf
                      ,pr_des_erro => vr_dscritic);
                                                
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
      pr_dscritic := 'Erro geral na rotina da tela pc_relat_carta_anuencia_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_relat_carta_anuencia_web; 
  
  --> Rotina responsavel por gerar o relatorio carta anuência
  PROCEDURE pc_relat_carta_anuencia (pr_cdcooper  IN craptab.cdcooper%TYPE         --> Cooperativa                                  
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Número da conta
                                    ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE         --> Número do documento
                                    ,pr_cdbancoc  IN crapcob.cdbandoc%TYPE         --> Código do banco           
                                    ,pr_dtcatanu  IN VARCHAR2                      --> Data de liquidação da dívida
                                    ,pr_nmrepres  IN VARCHAR2                      --> Representantes
																		,pr_cdoperad  IN VARCHAR2 DEFAULT '1'          --> Operador
                                    --------->> OUT <<-----------
                                    ,pr_nmarqpdf OUT VARCHAR2                      --> Retorna o nome do relatorio gerado
                                    ,pr_dsxmlrel OUT CLOB                          --> Retorna xml do relatorio quando origem for 3 -InternetBank
                                    ,pr_cdcritic OUT NUMBER                        --> Retorna codigo de critica
                                    ,pr_dscritic OUT VARCHAR2) IS                  --> Retorno de critica)
	/* ............................................................................

       Programa: pc_relat_carta_anuencia
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Hélinton Steffens
       Data    : Fevereiro/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de carta de anuencia

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    -- Cursor para validação da cooperativa
    cursor cr_crapcop (pr_nrdconta   crapass.nrdconta%TYPE
                      ,pr_nrdocmto   crapcob.nrdocmto%TYPE
                      ,pr_cdbancoc   crapcob.cdbandoc%TYPE) is
      SELECT nmprimtl as nmcooper, 
             sab.nmcidsac as dscidade_cooper, 
             enc.dsendere as dsrua, 
             enc.nrendere as vlnumero, 
             enc.nmbairro as dsbairro, 
             enc.nmcidade as dscidade,
             enc.cdufende as dsuf, 
             null as nmsocioadm, 
             gene0002.fn_mask_cpf_cnpj(pas.nrcpfcgc,pas.inpessoa) as cnpj,
             sab.nmdsacad as nmpagador,
             sab.cdufsaca as dsufadm, 
             sab.nmcidsac as dscidadeadm, 
             sab.nmbaisac as dsbairroadm, 
             sab.dsendsac as dsruaadm,
             gene0002.fn_mask_cpf_cnpj(sab.nrinssac,sab.cdtpinsc)  as iddocumento, 
             nrendsac as vlnumadm, 
             cob.vltitulo as vlboleto, 
             cob.dtvencto as dtvencimento, 
             cob.dsdoccop as nrboleto,
             cob.nrnosnum as nrnossonmr,
						 cob.nrcnvcob AS nrcnvcob
        FROM crapass pas, 
             crapcob cob, 
             crapsab sab,
             crapenc enc
        WHERE
             cob.nrdconta = pas.nrdconta 
         AND sab.nrdconta = pas.nrdconta 
         AND sab.nrinssac = cob.nrinssac 
         AND pas.nrdconta = pr_nrdconta 
         AND cob.nrdocmto = pr_nrdocmto 
         AND cob.cdbandoc = pr_cdbancoc;
    rw_crapcop cr_crapcop%rowtype;
    --
    -- PL/Table contendo os tipos de dados
    type typ_tipo is record (vr_dscidade_cooper      varchar2(50),
                vr_nmcooper          varchar2(50),
                vr_cnpj            varchar2(50),
                vr_dsrua          varchar2(50),
                vr_vlnumero          varchar2(50),
                vr_dsbairro          varchar2(50),
                vr_dscidade          varchar2(50),
                vr_dsuf            varchar2(50),
                vr_nmsocioadm        varchar2(50),
                vr_nmpagador        varchar2(50),
                vr_iddocumento        varchar2(50),
                vr_dsruaadm          varchar2(50),
                vr_vlnumadm          varchar2(50),
                vr_dsbairroadm        varchar2(50),
                vr_dscidadeadm        varchar2(50),
                vr_dsufadm          varchar2(50),
                vr_nrboleto          varchar2(50),
                vr_vlboleto          varchar2(50),
                vr_nrnossonmr        varchar2(50),
                vr_dtvencimento        CRAPCOB.DTVENCTO%type);
    -- Definição da tabela para armazenar os tipos de conta
    type typ_tab_tipo is table of typ_tipo index by binary_integer;
    -- Instância da tabela. O índice é o tipo de conta
    vr_tab_tipo      typ_tab_tipo;
    -- Índice para leitura da PL/Table
    vr_ind           binary_integer;
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_exc_erro     EXCEPTION;
    vr_tab_erro     GENE0001.typ_tab_erro;
    -- Data do movimento
    vr_dtmvtolt      crapdat.dtmvtolt%type;
    -- Paramentros relatorio
    vr_dscidade_cooper      varchar2(50);
    vr_nmcooper          varchar2(50);
    vr_cnpj            varchar2(50);
    vr_dsrua          varchar2(50);
    vr_vlnumero          varchar2(50);
    vr_dsbairro          varchar2(50);
    vr_dscidade          varchar2(50);
    vr_dsuf            varchar2(50);
    vr_nmsocioadm        varchar2(50);
    vr_nmpagador        varchar2(50);
    vr_iddocumento        varchar2(50);
    vr_dsruaadm          varchar2(50);
    vr_vlnumadm          varchar2(50);
    vr_dsbairroadm        varchar2(50);
    vr_dscidadeadm        varchar2(50);
    vr_dsufadm          varchar2(50);
    vr_nrboleto          varchar2(50);
    vr_vlboleto          varchar2(50);
    vr_nrnossonmr        varchar2(50);
    vr_dtvencimento        CRAPCOB.DTVENCTO%type;
    vr_dtcatanu          varchar2(10);
		vr_xml_dsmsgerr      VARCHAR2(10000);
		--
		vr_nrcnvcob          crapcob.nrcnvcob%TYPE;
    -- Variável para armazenar as informações em XML
    vr_des_xml       clob;
    vr_typsaida     VARCHAR2(100);
    vr_des_reto     VARCHAR2(100); 
    -- Variável para o caminho e nome do arquivo base
    vr_dsdireto varchar2(200);
    vr_dscomand   varchar2(200);
		
		rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in clob) is
    begin
      dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    end;
    --
  begin
    -- Validar data cooper
		OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
		FETCH btch0001.cr_crapdat INTO rw_crapdat;
		
		vr_dtmvtolt := rw_crapdat.dtmvtolt;
		-- Se não encontrar
		IF btch0001.cr_crapdat%NOTFOUND THEN
			 CLOSE btch0001.cr_crapdat;

			vr_cdcritic := 0;
			vr_dscritic := 'Sistema sem data de movimento.';
			RAISE vr_exc_erro;
		ELSE
			 CLOSE btch0001.cr_crapdat;
		END IF;  
	
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_nrdconta, pr_nrdocmto, pr_cdbancoc);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    vr_dscidade_cooper := rw_crapcop.dscidade_cooper;
    vr_nmcooper := rw_crapcop.nmcooper;
    vr_cnpj := rw_crapcop.cnpj;
    vr_dsrua := rw_crapcop.dsrua;
    vr_vlnumero := rw_crapcop.vlnumero;
    vr_dsbairro := rw_crapcop.dsbairro;
    vr_dscidade := rw_crapcop.dscidade;
    vr_dsuf := rw_crapcop.dsuf;
    vr_nmsocioadm := rw_crapcop.nmsocioadm;
    vr_nmpagador := rw_crapcop.nmpagador;
    vr_iddocumento := rw_crapcop.iddocumento;
    vr_dsruaadm := rw_crapcop.dsruaadm;
    vr_vlnumadm := rw_crapcop.vlnumadm;
    vr_dsbairroadm := rw_crapcop.dsbairroadm;
    vr_dscidadeadm := rw_crapcop.dscidadeadm;
    vr_dsufadm := rw_crapcop.dsufadm;
    vr_nrboleto := rw_crapcop.nrboleto;
    vr_vlboleto := rw_crapcop.vlboleto;
    vr_nrnossonmr := rw_crapcop.nrnossonmr;
    vr_dtvencimento := rw_crapcop.dtvencimento;
    vr_dtcatanu := pr_dtcatanu;
		vr_nrcnvcob := rw_crapcop.nrcnvcob;

    -- Inicializar o CLOB para armazenar o arquivo XML
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><carta_anuencia>');
    pc_escreve_xml('<dscidade_cooper>'     ||vr_dscidade_cooper	    ||'</dscidade_cooper>'||
                   '<nmcooper>'            ||vr_nmcooper            ||'</nmcooper>'||
                   '<cnpj>'                ||vr_cnpj                ||'</cnpj>'||
                   '<dsrua>'               ||vr_dsrua               ||'</dsrua>'||
                   '<vlnumero>'            ||vr_vlnumero            ||'</vlnumero>'||
                   '<dsbairro>'            ||vr_dsbairro            ||'</dsbairro>'||
                   '<dscidade>'            ||vr_dscidade            ||'</dscidade>'||
                   '<dsuf>'                ||vr_dsuf                ||'</dsuf>'||
                   '<nmsocioadm>'          ||vr_nmsocioadm          ||'</nmsocioadm>'||
                   '<nmpagador>'           ||vr_nmpagador           ||'</nmpagador>'||
                   '<iddocumento>'         ||vr_iddocumento         ||'</iddocumento>'||
                   '<dsruaadm>'            ||vr_dsruaadm            ||'</dsruaadm>'||
                   '<vlnumadm>'            ||vr_vlnumadm            ||'</vlnumadm>'||
                   '<dsbairroadm>'         ||vr_dsbairroadm         ||'</dsbairroadm>'||
                   '<dscidadeadm>'         ||vr_dscidadeadm         ||'</dscidadeadm>'||
                   '<dsufadm>'             ||vr_dsufadm             ||'</dsufadm>'||
                   '<nrboleto>'            ||vr_nrboleto            ||'</nrboleto>'||
                   '<vlboleto>'            ||to_char(vr_vlboleto, 'FM999G999G999D90', 'nls_numeric_characters='',.''')            ||'</vlboleto>'||
                   '<vlboletoext>'         ||gene0002.fn_valor_extenso('M', vr_vlboleto)            ||'</vlboletoext>'||
                   '<nrnossonmr>'          ||vr_nrnossonmr            ||'</nrnossonmr>'||
                   '<dtcatanu>'            ||vr_dtcatanu            ||'</dtcatanu>'||
                   '<nmrepres>'            ||pr_nmrepres            ||'</nmrepres>'||
                   '<vr_dtvencimento>'     ||to_char(vr_dtvencimento,'DD/MM/RRRR')         ||'</vr_dtvencimento>');

    -- Fecha a tag principal para encerrar o XML
    pc_escreve_xml('</carta_anuencia>');
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => '/rl');
    --vr_dsdireto := '/microsd/cecred/faria'                                     
      
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl738_' ||0 ||'* 2>/dev/null';
      
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
      
      
    pr_nmarqpdf := 'crrl738_'||0 || gene0002.fn_busca_time || '.pdf';
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'COBRAN'
                               , pr_dtmvtolt  => vr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/carta_anuencia'
                               , pr_dsjasper  => 'carta_anuencia.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 738
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
                                ,pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||pr_nmarqpdf
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;
		
		-- Rotina para gerar log e tarifas
    cobr0010.pc_imp_carta_anuencia(pr_cdcooper     => pr_cdcooper                       -- IN
		                              ,pr_nrdconta     => pr_nrdconta                       -- IN
																	,pr_nrcnvcob     => vr_nrcnvcob                       -- IN
																	,pr_nrdocmto     => pr_nrdocmto                       -- IN
																	,pr_dtmvtolt     => vr_dtmvtolt                       -- IN
																	,pr_cdoperad     => pr_cdoperad                       -- IN
																	,pr_dtliqdiv     => to_date(pr_dtcatanu,'DD/MM/RRRR') -- IN
																	--
																	,pr_xml_dsmsgerr => vr_xml_dsmsgerr                   -- OUT
																	,pr_cdcritic     => vr_cdcritic                       -- OUT
																	,pr_dscritic     => vr_dscritic                       -- OUT
																	);
		--
		-- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro pc_imp_carta_anuencia: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_relat_carta_anuencia : '||SQLERRM;  	                                   
  END pc_relat_carta_anuencia;

	PROCEDURE pc_consulta_cod_barras_web(pr_dtvencto    IN VARCHAR2
																			,pr_cdbandoc    IN INTEGER
																			,pr_vltitulo    IN crapcob.vltitulo%TYPE
																			,pr_nrcnvcob    IN crapcob.nrcnvcob%TYPE
																			,pr_nrdconta    IN crapcob.nrdconta%TYPE
																			,pr_nrdocmto    IN crapcob.nrdocmto%TYPE
																		  ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
																		  ,pr_cdcritic   OUT PLS_INTEGER                     --> Código da crítica
																		  ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
																		  ,pr_retxml  IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
																		  ,pr_nmdcampo   OUT VARCHAR2                        --> Nome do campo com erro
																		  ,pr_des_erro   OUT VARCHAR2                        --> Erros do processo
																			) IS
    /* .............................................................................
    
        Programa: pc_consulta_cod_barras_web
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Adriano Nagasava
        Data    : Agosto/2018.                    Ultima atualizacao: --/--/----
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
      
        Objetivo  : Rotina para retornar o código de barras e a linha digitável
      
        Observacao: -----
      
        Alteracoes:
      ..............................................................................*/
  
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- PL/Table
    vr_tab_crapceb typ_tab_crapceb; -- PL/Table com os dados retornados da procedure
    vr_idx          INTEGER := 0; -- Indice para a PL/Table retornada da procedure
      
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		--
		vr_cdcartei crapcob.cdcartei%TYPE;
		vr_cdbarras VARCHAR2(100);
		vr_lindigit VARCHAR2(100);
    vr_dtvencto DATE;
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
		--
  BEGIN
    --
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
                            ,pr_dscritic => vr_dscritic
														 );
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
			--
    END IF;
    --
		BEGIN
			--
			SELECT crapcob.cdcartei
			  INTO vr_cdcartei
			  FROM crapcob
			 WHERE crapcob.nrdconta = pr_nrdconta
			   AND crapcob.nrdocmto = pr_nrdocmto
				 AND crapcob.nrcnvcob = pr_nrcnvcob
				 AND crapcob.cdcooper = vr_cdcooper;
			--
		EXCEPTION
			WHEN no_data_found THEN
				vr_dscritic := 'Boleto não encontrado!';
				RAISE vr_exc_saida;
			WHEN OTHERS THEN
				vr_dscritic := 'Erro ao buscar o boleto: ' || SQLERRM;
				RAISE vr_exc_saida;
		END;
		--
		vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
		--
		cobr0005.pc_calc_codigo_barras(pr_dtvencto => vr_dtvencto -- IN
																	,pr_cdbandoc => pr_cdbandoc -- IN
																	,pr_vltitulo => pr_vltitulo -- IN
																	,pr_nrcnvcob => pr_nrcnvcob -- IN
																	,pr_nrdconta => pr_nrdconta -- IN
																	,pr_nrdocmto => pr_nrdocmto -- IN
																	,pr_cdcartei => vr_cdcartei -- IN
																	,pr_cdbarras => vr_cdbarras -- OUT
																	);
    --
		cobr0005.pc_calc_linha_digitavel(pr_cdbarras => vr_cdbarras -- IN
																		,pr_lindigit => vr_lindigit -- Out
																		);    
		-- Inicializar o CLOB
		vr_des_xml := NULL;
		dbms_lob.createtemporary(vr_des_xml, TRUE);
		dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
		vr_texto_completo := NULL;
		--
		pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><root><dados>');
		--
		pc_escreve_xml('<inf>'||
										'<cdbarras>' || vr_cdbarras ||'</cdbarras>' ||
										'<lindigit>' || vr_lindigit ||'</lindigit>' ||
									 '</inf>');
		--
		pc_escreve_xml('</dados></root>',TRUE);        
    pr_retxml := XMLType.createXML(vr_des_xml);
    --
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_cod_barras_web;
  --

  PROCEDURE pc_gera_arq_remes_cnab240(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                     ,pr_nrdconta      IN crapcob.nrdconta%TYPE --> Numero da conta
                                     ,pr_flgregis      IN crapcob.flgregis%TYPE --> Cobranca registrada (0=Nao/1=Sim)
                                     ,pr_tipo_consulta IN INTEGER --> Tipo de consulta (1-NAO COBRADOS/2-COBRADOS/3-TODOS)
                                     ,pr_consulta      IN INTEGER --> Consulta (1-CONTA/2-DOCUMENTO/3-EMISSAO/4-PAGAMENTO/5-VENCIMENTO/6-PERIODO)
                                     ,pr_inestcri      IN crapret.inestcri%TYPE --> Somente crise (0=Nao/1=Sim)
                                     ,pr_ini_documento IN crapcob.nrdocmto%TYPE --> Numero inicial de documento
                                     ,pr_fim_documento IN crapcob.nrdocmto%TYPE --> Numero final de documento
                                     ,pr_stprogra      OUT PLS_INTEGER --> Saída de termino da execução
                                     ,pr_infimsol      OUT PLS_INTEGER --> Saída de termino da solicitação
                                     ,pr_nmarqrem      OUT VARCHAR2 --> Caminho e nome do arquivo de remessa a ser exportado
                                     ,pr_cdcritic      OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                     ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                                      ) IS
    BEGIN
        /* ............................................................................

          Programa: pc_gera_arq_remes_cnab240
          Sistema : Cobrança - Cooperativa de Credito
          Sigla   : CRED
          Autor   : Andre Clemer (Supero)
          Data    : Outubro/2018                      Ultima atualizacao: --/--/----

          Dados referentes ao programa:

          Frequencia: Sempre que for chamado.
          Objetivo  : Responsavel por gerar o arquivo de remessa padrao CNAB240.

          Alteracoes:

        .......................................................................... */

        DECLARE
            ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
            -- Codigo do Programa
            vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'COBRAN';

            -- Tratamento de Erros
            vr_exc_saida  EXCEPTION;
            vr_exc_fimprg EXCEPTION;
            vr_exc_next   EXCEPTION;
            vr_cdcritic PLS_INTEGER;
            vr_dscritic VARCHAR2(4000);
            vr_des_reto VARCHAR2(4000);
            vr_tab_erro gene0001.typ_tab_erro;

            -- Tratamento Mensagens Titulo
            vr_inform gene0002.typ_split;

            -- Declarando handle do Arquivo
            vr_ind_arquivo utl_file.file_type;
            vr_des_erro    VARCHAR2(4000);

            -- Variáveis para armazenar as informações em XML
            vr_des_xml CLOB;

            -- Variável para armazenar os dados do XML antes de incluir no CLOB
            vr_texto_completo VARCHAR2(32600);

            -- Variaveis Diversas
            vr_ultimo_remesa NUMBER;
            vr_nmarquiv      VARCHAR(100);
            vr_flg_gera_arq  BOOLEAN;
            vr_nrsequen      NUMBER;
            vr_nmdireto      VARCHAR2(4000);
            vr_nmdirrel      VARCHAR2(4000);
            vr_nmdirslv      VARCHAR2(4000);
            vr_nmdirmic      VARCHAR2(4000);
            vr_nmdirarq      VARCHAR2(4000);
            vr_setlinha      VARCHAR2(400);
            vr_cdageman      NUMBER;
            vr_nrdolote      NUMBER;
            vr_qtd_registro  NUMBER;
            vr_nro_seq_lote  NUMBER;
            vr_cddespec      VARCHAR2(02);
            vr_cdprotes      VARCHAR2(02);
            vr_uso_empresa   VARCHAR(25);
            vr_dias_protesto VARCHAR(02);
            vr_cddescto      VARCHAR(1);
            vr_dtdescto      VARCHAR(8);
            vr_endereco      VARCHAR2(400);
            -- vr_nrdocmto      gene0002.typ_split;
            vr_typ_saida VARCHAR2(3);

            vr_rowidcce ROWID;
            vr_rowidcob ROWID;

            vr_qtdtotal NUMBER;
            vr_vlrtotal NUMBER;

            vr_indice VARCHAR(25);

            vr_nrcalcul  NUMBER;
            vr_flgdigok1 BOOLEAN;
            -- Codigo Identificação do Job
            vr_cdidejob VARCHAR2(40);

            -- Tabela temporaria para os titulos
            TYPE typ_reg_crapcob IS RECORD(
                 cdcooper crapcob.cdcooper%TYPE
                ,cdbandoc crapcob.cdbandoc%TYPE
                ,nrdctabb crapcob.nrdctabb%TYPE
                ,nrcnvcob crapcob.nrcnvcob%TYPE
                ,nrdconta crapcob.nrdconta%TYPE
                ,nrdocmto crapcob.nrdocmto%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,vltitulo crapcob.vltitulo%TYPE);
            TYPE typ_tab_crapcob IS TABLE OF typ_reg_crapcob INDEX BY PLS_INTEGER;
            -- Vetor para armazenar os os titulos
            vr_tab_crapcob typ_tab_crapcob;

            -- Tabela temporaria para o relatorio
            TYPE typ_reg_relatorio IS RECORD(
                 cdcooper crapcob.cdcooper%TYPE
                ,nrcnvcob crapcob.nrcnvcob%TYPE
                ,nrdconta crapcob.nrdconta%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,vltitulo crapcob.vltitulo%TYPE
                ,qtdtotal NUMBER);
            TYPE typ_tab_relatorio IS TABLE OF typ_reg_relatorio INDEX BY VARCHAR2(25);
            -- Vetor para armazenar os os titulos
            vr_tab_relatorio typ_tab_relatorio;

            -- Array par Segmento S - Mensagens
            TYPE type_tab_mensagem IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
            -- Array de Mensagens
            vr_tab_mensagem type_tab_mensagem;

            -- Vetor para armazenar as tarifas de geracao dos boletos;
            vr_tab_lcm_consolidada paga0001.typ_tab_lcm_consolidada;

            ------------------------------- CURSORES ---------------------------------

            -- Busca Dados das Cooperativas
            CURSOR cr_crabcop IS
                SELECT cop.cdcooper
                      ,cop.nmrescop
                      ,cop.nmextcop
                      ,cop.dsdircop
                      ,cop.nrdocnpj
                      ,cop.dsnomscr
                      ,cop.dstelscr
                      ,cop.cdagectl
                  FROM crapcop cop
                 WHERE cop.cdcooper = pr_cdcooper;

            rw_crabcop cr_crabcop%ROWTYPE;

            -- Busca Dados das Cooperativas
            CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
                SELECT cop.cdcooper
                      ,cop.nmrescop
                      ,cop.nmextcop
                      ,cop.dsdircop
                      ,cop.nrdocnpj
                      ,cop.dsnomscr
                      ,cop.dstelscr
                      ,cop.cdagectl
                      ,cop.cdbcoctl
                  FROM crapcop cop
                 WHERE cop.cdcooper = pr_cdcooper
                   AND cop.flgativo = 1;

            -- Busca Numero Remessa/Retorno
            CURSOR cr_crapcce(pr_cdcooper IN crapcee.cdcooper%TYPE) IS
                SELECT nvl(MAX(cee.nrremret), 0) + 1 max_nrremret
                  FROM crapcee cee
                 WHERE cee.cdcooper = pr_cdcooper;
            rw_crapcee cr_crapcce%ROWTYPE;

            --Selecionar os dados da tabela de Associados
            CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT ass.nrdconta
                      ,ass.cdagenci
                      ,ass.nrcpfcgc
                      ,ass.inpessoa
                      ,ass.nmprimtl
                  FROM crapass ass
                 WHERE ass.cdcooper = pr_cdcooper
                   AND ass.nrdconta = pr_nrdconta;
            rw_crapass cr_crapass%ROWTYPE;

            -- Busca Registros Cobrança
            CURSOR cr_crapcob(pr_cdcooper      IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta      IN crapcob.nrdconta%TYPE
                             ,pr_flgregis      IN crapcob.flgregis%TYPE
                             ,pr_inestcri      IN crapret.inestcri%TYPE
                             ,pr_ini_documento IN crapcob.nrdocmto%TYPE
                             ,pr_fim_documento IN crapcob.nrdocmto%TYPE
                             ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE)  IS
                             
                SELECT cob.cdcooper
                      ,cob.cdbandoc
                      ,cob.nrdctabb
                      ,cob.nrcnvcob
                      ,cob.nrdconta
                      ,cob.nrdocmto
                      ,cob.cddespec
                      ,cob.nrnosnum
                      ,cob.dtvencto
                      ,cob.vltitulo
                      ,cob.flgdprot
                      ,cob.vlabatim
                      ,cob.vldescto
                      ,cob.qtdiaprt
                      ,cob.dtdocmto
                      ,cob.tpjurmor
                      ,cob.vljurdia
                      ,cob.nrinssac
                      ,cob.cdtpinav
                      ,cob.nrinsava
                      ,cob.nmdavali
                      ,cob.vlrmulta
                      ,cob.tpdmulta
                      ,cob.dsinform
                      ,cob.dsdoccop
                      ,cob.dtmvtolt
                      ,cob.rowid
                      ,row_number() over(PARTITION BY cob.nrdconta, cob.nrcnvcob ORDER BY cob.nrdconta, cob.nrcnvcob) nrseq
                      ,COUNT(1) over(PARTITION BY cob.nrdconta, cob.nrcnvcob ORDER BY cob.nrdconta, cob.nrcnvcob) qtreg
                  FROM crapcob cob
                      ,crapcco cco
                      ,crapceb ceb
                 WHERE cob.cdcooper = pr_cdcooper
                   AND cob.nrdconta = pr_nrdconta
                   AND cob.flgregis = pr_flgregis
                   AND cob.nrdocmto BETWEEN pr_ini_documento AND pr_fim_documento
                   -- incobran = Indicador de cobranca (0-em aberto/ 3-baixado/ 5-liquidado)
                   -- pr_tipo_consulta = Tipo de consulta (1-NAO COBRADOS/2-COBRADOS/3-TODOS)
                   AND ((pr_tipo_consulta = 1 AND
                        (cob.incobran = 0   OR
                         cob.incobran = 3)) OR
                        (pr_tipo_consulta = 2 AND
                         cob.incobran = 5)  OR
                        1 = 1)
                   AND cco.cddbanco = 085
                   AND cco.cdcooper = cob.cdcooper
                   AND ceb.cdcooper = cco.cdcooper
                   AND ceb.nrconven = cco.nrconven
                   AND cob.nrdconta = ceb.nrdconta
                   AND cob.nrcnvcob = ceb.nrconven
                   AND cob.dsinform NOT LIKE 'LIQAPOSB%'
                 ORDER BY cob.nrdconta
                         ,cob.nrcnvcob;

            -- Selecionar os dados da tabela de Associados
            CURSOR cr_crapsab(pr_cdcooper IN crapsab.cdcooper%TYPE
                             ,pr_nrdconta IN crapsab.nrdconta%TYPE
                             ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
                SELECT sab.nrdconta
                      ,sab.dsendsac
                      ,sab.cdtpinsc
                      ,nvl(sab.nmbaisac, ' ') nmbaisac
                      ,sab.nrendsac
                      ,sab.nrinssac
                      ,sab.complend
                      ,sab.nmdsacad
                      ,sab.nrcepsac
                      ,sab.nmcidsac
                      ,sab.cdufsaca
                  FROM crapsab sab
                 WHERE sab.cdcooper = pr_cdcooper
                   AND sab.nrdconta = pr_nrdconta
                   AND sab.nrinssac = pr_nrinssac;
            rw_crapsab cr_crapsab%ROWTYPE;

            -- Cursor Genérico de Calendario
            rw_crapdat btch0001.cr_crapdat%ROWTYPE;
            rw_crabdat btch0001.cr_crapdat%ROWTYPE;

            --------------------------- SUBROTINAS INTERNAS --------------------------
            -- Subrotina para escrever texto na variável CLOB do XML
            PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                                    ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS

            BEGIN
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
            END;

        BEGIN

            --------------- VALIDACOES INICIAIS -----------------

            -- Incluir Nome do Módulo Logado
            gene0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);

            -- Verifica se a cooperativa esta cadastrada
            OPEN cr_crabcop;
            FETCH cr_crabcop
                INTO rw_crabcop;
            -- Se não encontrar
            IF cr_crabcop%NOTFOUND THEN
                -- Fechar o cursor pois haverá raise
                CLOSE cr_crabcop;
                -- Montar mensagem de critica
                vr_cdcritic := 651;
                RAISE vr_exc_saida;
            ELSE
                -- Apenas fechar o cursor
                CLOSE cr_crabcop;
            END IF;

            -- Leitura do calendário da cooperativa
            OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crabcop.cdcooper);
            FETCH btch0001.cr_crapdat
                INTO rw_crapdat;
            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE btch0001.cr_crapdat;
                -- Montar mensagem de critica
                vr_cdcritic := 1;
                RAISE vr_exc_saida;
            ELSE
                -- Apenas fechar o cursor
                CLOSE btch0001.cr_crapdat;
            END IF;

            -- Validações Iniciais do Programa
            btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                                     ,pr_flgbatch => 1
                                     ,pr_cdprogra => vr_cdprogra
                                     ,pr_infimsol => pr_infimsol
                                     ,pr_cdcritic => vr_cdcritic);
            -- Caso tenha Erro
            IF vr_cdcritic <> 0 THEN
                -- Envio Centralizado de LOG de Erro
                RAISE vr_exc_saida;
            END IF;

            --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

            FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP

                BEGIN

                    -- Leitura do calendário da cooperativa
                    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
                    FETCH btch0001.cr_crapdat
                        INTO rw_crabdat;
                    -- Se não encontrar
                    IF btch0001.cr_crapdat%NOTFOUND THEN
                        -- Fechar o cursor pois efetuaremos raise
                        CLOSE btch0001.cr_crapdat;
                        -- Montar mensagem de critica
                        vr_cdcritic := 1;
                        RAISE vr_exc_saida;
                    ELSE
                        -- Apenas fechar o cursor
                        CLOSE btch0001.cr_crapdat;
                    END IF;

                    -- Inicializar o CLOB
                    vr_des_xml := NULL;
                    dbms_lob.createtemporary(vr_des_xml, TRUE);
                    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

                    -- Busca Numero da Ultima Remessa
                    OPEN cr_crapcce(pr_cdcooper => rw_crapcop.cdcooper);
                    FETCH cr_crapcce
                        INTO rw_crapcee;

                    CLOSE cr_crapcce;

                    -- Numero de Retorno
                    vr_ultimo_remesa := rw_crapcee.max_nrremret;

                    -- Monta Nome do Arquivo
                    vr_nmarquiv := upper(rw_crapcop.dsdircop) || '_' ||
                                   to_char(rw_crabdat.dtmvtolt, 'YYYYMMDD') || '_' ||
                                   TRIM(to_char(vr_ultimo_remesa, '000000')) || '.REM';

                    -- Inicilizar as informações do XML
                    vr_texto_completo := NULL;
                    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><crrl700>');

                    pc_escreve_xml('<arquivo>' || '<nmarquiv>' || vr_nmarquiv || '</nmarquiv>' ||
                                   '</arquivo>' || '<contas>');

                    -- Controle de Geração do Arquivo
                    vr_flg_gera_arq := FALSE;

                    -- Sequencial Registro Detalhe
                    vr_nrsequen := 0;

                    -- Numero do Lote
                    vr_nrdolote := 0;

                    -- Valores Totais Relatorio
                    vr_qtdtotal := 0;
                    vr_vlrtotal := 0;

                    -- Quantidade Total de Linhas Arquivo
                    vr_qtd_registro := 0;

                    -- Limpa Tabelas
                    vr_tab_crapcob.delete;
                    vr_tab_relatorio.delete;
                    vr_tab_lcm_consolidada.delete;

                    -- Diretorio Geração Arquivo
                    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                        ,pr_cdcooper => 3
                                                        , --rw_crapcop.cdcooper,
                                                         pr_nmsubdir => 'arq');
                    -- Diretorio Geração Relatorio
                    vr_nmdirrel := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                        ,pr_cdcooper => rw_crapcop.cdcooper
                                                        ,pr_nmsubdir => 'rl');
                    -- Diretorio Salvar
                    vr_nmdirslv := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                        ,pr_cdcooper => rw_crapcop.cdcooper
                                                        ,pr_nmsubdir => 'salvar');

                    -- Diretorio MICROS
                    vr_nmdirmic := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                                        ,pr_cdcooper => 3
                                                        , --rw_crapcop.cdcooper,
                                                         pr_nmsubdir => 'cobranca');

                    -- vr_nrdocmto := gene0002.fn_quebra_string(pr_ls_nrdocmto, ';');

                    -- Leitura de Titulos a serem Enviados
                    FOR rw_crapcob IN cr_crapcob(pr_cdcooper      => rw_crapcop.cdcooper
                                                ,pr_nrdconta      => pr_nrdconta
                                                ,pr_flgregis      => pr_flgregis
                                                ,pr_inestcri      => pr_inestcri
                                                ,pr_ini_documento => pr_ini_documento
                                                ,pr_fim_documento => pr_fim_documento
                                                ,pr_dtmvtolt      => rw_crabdat.dtmvtolt) LOOP

                        -- Gera Registro Header Apenas se Possui Titulos e Apenas uma Vez.
                        IF vr_flg_gera_arq = FALSE THEN

                            -- Flag de Controle se Arquivo deve ser Gerado
                            vr_flg_gera_arq := TRUE;

                            BEGIN
                                -- Inserir Header da Remessa
                                INSERT INTO crapcee
                                    (cdcooper
                                    ,nrremret
                                    ,intipmvt
                                    ,nmarquiv
                                    ,cdoperad
                                    ,dtmvtolt
                                    ,dttransa
                                    ,hrtransa
                                    ,insitmvt)
                                VALUES
                                    (rw_crapcop.cdcooper
                                    ,vr_ultimo_remesa
                                    ,1 -- Remessa
                                    ,vr_nmarquiv
                                    ,1 -- Super Usuario
                                    ,rw_crabdat.dtmvtolt
                                    ,NULL
                                    ,NULL
                                    ,1)
                                RETURNING ROWID INTO vr_rowidcce;

                            EXCEPTION
                                WHEN OTHERS THEN
                                    vr_dscritic := 'Erro ao inserir na tabela crapcee. ' || SQLERRM;
                                    --Sair do programa
                                    RAISE vr_exc_saida;
                            END;

                            -- Abre arquivo em modo de escrita (W)
                            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretório do arquivo
                                                    ,pr_nmarquiv => vr_nmarquiv --> Nome do arquivo
                                                    ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                                                    ,pr_utlfileh => vr_ind_arquivo --> Handle do arquivo aberto
                                                    ,pr_des_erro => vr_dscritic); --> Erro

                            IF vr_dscritic IS NOT NULL THEN
                                -- Levantar Excecao
                                RAISE vr_exc_saida;
                            END IF;

                            vr_qtd_registro := vr_qtd_registro + 1;

                            -- Calcula primeiro digito de controle
                            vr_nrcalcul := to_number(gene0002.fn_mask(rw_crapcop.cdagectl, '9999') || '0');

                            vr_flgdigok1 := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrcalcul);

                            vr_setlinha := '085' || -- 01.0 - Banco
                                           '0000' || -- 02.0 - Lote
                                           '0' || -- 03.0 - Tipo Registro
                                           lpad(' ', 9, ' ') || -- 04.0 - Brancos
                                           '2' || -- 05.0 - Tp Inscricao
                                           gene0002.fn_mask(rw_crapcop.nrdocnpj, '99999999999999') || -- 06.0 - CNPJ/CPF
                                           lpad(' ', 20, ' ') || -- 07.0 - Convenio
                                           gene0002.fn_mask(vr_nrcalcul, '999999') || -- 08.0 - Age Mantenedora
                                           lpad(' ', 13, ' ') || -- 10.0 - Conta/Digito
                                           lpad(' ', 1, ' ') || -- 12.0 - Dig Verf Age/Cta
                                           substr(rpad(rw_crapcop.nmextcop, 30, ' '), 1, 30) || -- 13.0 - Nome Empresa
                                           lpad('AILOS', 30, ' ') || -- 14.0 - Nome Banco
                                           lpad(' ', 10, ' ') || -- 15.0 - Brancos
                                           '1' || -- 16.0 - Código Remessa/Retorno
                                           to_char(SYSDATE, 'DDMMYYYY') || -- 17.0 - Data de Geração do Arquivo
                                           gene0002.fn_mask(to_char(SYSDATE, 'HH24MISS'), '999999') || -- 18.0 - Hora de Geração do Arquivo
                                           gene0002.fn_mask(vr_ultimo_remesa, '999999') || -- 19.0 - Numero Sequencial do Arquivo
                                           '088' || -- 20.0 - Layout do Arquivo
                                           '00000' || -- 21.0 - Densidade de Gravação do Arquivo
                                           lpad(' ', 20, ' ') || -- 22.0 - Uso Reservado do Banco
                                           lpad(' ', 20, ' ') || -- 23.0 - Uso Reservado da Empresa
                                           lpad(' ', 29, ' ') || -- 24.0 - Uso Exclusivo FEBRABAN
                                           chr(13);

                            -- Escrever Linha do Header do Arquivo CNAB240 - Item 1.0
                            gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);

                        END IF;

                        -- Verifica se o cooperado esta cadastrada
                        OPEN cr_crapass(pr_cdcooper => rw_crapcob.cdcooper
                                       ,pr_nrdconta => rw_crapcob.nrdconta);
                        FETCH cr_crapass
                            INTO rw_crapass;

                        -- Se não encontrar
                        IF cr_crapass%NOTFOUND THEN
                            -- Fechar o cursor pois haverá raise
                            CLOSE cr_crapass;
                            vr_des_erro := 'Cooperado nao cadastrado.';
                            RAISE vr_exc_saida;
                        ELSE
                            -- Apenas fechar o cursor
                            CLOSE cr_crapass;
                        END IF;

                        -- Primeiro Registro da Conta/Convenio
                        IF rw_crapcob.nrseq = 1 THEN

                            ------------- HEADER DO LOTE -------------

                            -- Inicializa Nro. Sequencial do Lote
                            vr_nro_seq_lote := 0;

                            -- Agencia Mantenedora
                            vr_cdageman := to_number(gene0002.fn_mask(rw_crapcop.cdagectl, '9999') || '0');

                            -- Adicionar o mesmo ajuste do header do arquivo;
                            vr_flgdigok1 := gene0005.fn_calc_digito(pr_nrcalcul => vr_cdageman);

                            -- Numero do Lote
                            vr_nrdolote := vr_nrdolote + 1;

                            -- Quantidade Total de Linhas no Arquivo
                            vr_qtd_registro := vr_qtd_registro + 1;

                            vr_setlinha := '085' || -- 01.1 - Banco
                                           gene0002.fn_mask(vr_nrdolote, '9999') || -- 02.1 - Lote
                                           '1' || -- 03.1 - Tipo Registro
                                           'T' || -- 04.1 - Tipo de Operação
                                           '06' || -- 05.1 - Tipo de Serviço
                                           lpad(' ', 2, ' ') || -- 06.1 - Uso Exclusivo FEBRABAN
                                           '010' || -- 07.1 - Versao do Arquivo
                                           lpad(' ', 1, ' ') || -- 08.1 - Uso Exclusivo FEBRABAN
                                           rw_crapass.inpessoa || -- 09.1 - Tipo de Inscricao Empresa
                                           gene0002.fn_mask(rw_crapass.nrcpfcgc, '999999999999999') || -- 10.1 - CNPJ/CPF da Empresa
                                           lpad(rw_crapcob.nrcnvcob, 20, ' ') || -- 11.1 - Convenio
                                           gene0002.fn_mask(vr_cdageman, '999999') || -- 12.1 - Agencia Mantenedora da Conta
                                           gene0002.fn_mask(rw_crapass.nrdconta, '9999999999999') || -- 14.1 - Conta/Digito
                                           lpad(' ', 1, ' ') || -- 16.1 - Digito Verfificador Ag/Conta
                                           substr(rpad(rw_crapass.nmprimtl, 30, ' '), 1, 30) || -- 17.1 - Nome da Empresa
                                           lpad(' ', 40, ' ') || -- 18.1 - Informacao 1
                                           lpad(' ', 40, ' ') || -- 19.1 - Informacao 2
                                           gene0002.fn_mask(vr_ultimo_remesa, '99999999') || -- 20.1 - Numero Sequencial do Arquivo
                                           to_char(SYSDATE, 'DDMMYYYY') || -- 21.1 - Data de Gravação Remessa/Retorno
                                           lpad(' ', 8, ' ') || -- 22.1 - Data do Credito
                                           lpad(' ', 33, ' ') || -- 23.1 - Uso Exclusivo FEBRABAN
                                           chr(13);

                            -- Escreve Linha do header do Lote CNAB240
                            gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);

                        END IF;

                        -- Incrementa Numero Sequencial
                        vr_nrsequen := vr_nrsequen + 1;

                        BEGIN
                            -- Inserir Detalhe da Remessa
                            INSERT INTO crapdee
                                (cdcooper
                                ,nrremret
                                ,intipmvt
                                ,nrdconta
                                ,nrcnvcob
                                ,nrdocmto
                                ,nrsequen
                                ,cdocorre)
                            VALUES
                                (rw_crapcob.cdcooper
                                ,vr_ultimo_remesa
                                ,1 -- Remessa
                                ,rw_crapcob.nrdconta
                                ,rw_crapcob.nrcnvcob
                                ,rw_crapcob.nrdocmto
                                ,vr_nrsequen
                                ,1);

                        EXCEPTION
                            WHEN OTHERS THEN
                                vr_dscritic := 'Erro ao inserir na tabela crapdee. ' || SQLERRM;
                                --Sair do programa
                                RAISE vr_exc_saida;
                        END;

                        -- Grava Registros na PL/Table
                        vr_tab_crapcob(vr_nrsequen).cdcooper := rw_crapcob.cdcooper;
                        vr_tab_crapcob(vr_nrsequen).cdbandoc := rw_crapcob.cdbandoc;
                        vr_tab_crapcob(vr_nrsequen).nrdctabb := rw_crapcob.nrdctabb;
                        vr_tab_crapcob(vr_nrsequen).nrcnvcob := rw_crapcob.nrcnvcob;
                        vr_tab_crapcob(vr_nrsequen).nrdconta := rw_crapcob.nrdconta;
                        vr_tab_crapcob(vr_nrsequen).nrdocmto := rw_crapcob.nrdocmto;
                        vr_tab_crapcob(vr_nrsequen).cdagenci := rw_crapass.cdagenci;
                        vr_tab_crapcob(vr_nrsequen).vltitulo := rw_crapcob.vltitulo;

                        -- Monta indice da PL/TABLE
                        vr_indice := lpad(rw_crapass.cdagenci, 5, '0') || lpad(rw_crapcob.nrdconta, 10, '0') ||
                                     lpad(rw_crapcob.nrcnvcob, 10, '0');

                        -- PL/Table Gerar Relatorio
                        IF vr_tab_relatorio.exists(vr_indice) THEN
                            vr_tab_relatorio(vr_indice).qtdtotal := vr_tab_relatorio(vr_indice).qtdtotal + 1;
                            vr_tab_relatorio(vr_indice).vltitulo := vr_tab_relatorio(vr_indice)
                                                                    .vltitulo + rw_crapcob.vltitulo;
                        ELSE
                            vr_tab_relatorio(vr_indice).cdagenci := rw_crapass.cdagenci;
                            vr_tab_relatorio(vr_indice).nrdconta := rw_crapcob.nrdconta;
                            vr_tab_relatorio(vr_indice).nrcnvcob := rw_crapcob.nrcnvcob;
                            vr_tab_relatorio(vr_indice).qtdtotal := 1;
                            vr_tab_relatorio(vr_indice).vltitulo := rw_crapcob.vltitulo;
                        END IF;

                        -- Valores Totais Para Relatorio
                        vr_qtdtotal := vr_qtdtotal + 1; -- Qtd Titulos
                        vr_vlrtotal := vr_vlrtotal + rw_crapcob.vltitulo; -- Valor Total

                        ------ REGISTRO DETALHE ------

                        -- Quantidade Total de Linhas no Arquivo
                        vr_qtd_registro := vr_qtd_registro + 1;

                        -- Nro. Sequencial no Lote
                        vr_nro_seq_lote := vr_nro_seq_lote + 1;

                        CASE rw_crapcob.cddespec
                            WHEN 1 THEN
                                vr_cddespec := '02';
                            WHEN 2 THEN
                                vr_cddespec := '04';
                            WHEN 3 THEN
                                vr_cddespec := '12';
                            WHEN 4 THEN
                                vr_cddespec := '21';
                            WHEN 5 THEN
                                vr_cddespec := '23';
                            WHEN 6 THEN
                                vr_cddespec := '17';
                            WHEN 7 THEN
                                vr_cddespec := '99';
                            ELSE
                                -- Deve Assumir o Valor de 99
                                vr_cddespec := '99';
                        END CASE;

                        IF rw_crapcob.flgdprot = 1 THEN
                            vr_cdprotes := '1'; -- Protestar
                        ELSE
                            vr_cdprotes := '3'; -- Não Protestar
                        END IF;

                        -- Monta Campo Uso da Empresa
                        vr_uso_empresa := gene0002.fn_mask(rw_crapcob.nrcnvcob, '9999999') ||
                                          gene0002.fn_mask(rw_crapcob.nrdconta, '99999999') ||
                                          gene0002.fn_mask(rw_crapcob.nrdocmto, '999999999');

                        -- Nro Dias Protesto
                        --IF rw_crapcob.qtdiaprt = 5 AND rw_crapcob.flgdprot = 1 THEN
                        --   vr_dias_protesto := '06';
                        --ELSE
                        IF rw_crapcob.qtdiaprt >= 5 AND rw_crapcob.flgdprot = 1 THEN
                            vr_dias_protesto := gene0002.fn_mask(rw_crapcob.qtdiaprt, '99');
                        ELSE
                            vr_dias_protesto := '00';
                        END IF;
                        --END IF;

                        -- Codigo do Desconto
                        IF rw_crapcob.vldescto > 0 THEN
                            vr_cddescto := '1';
                        ELSE
                            vr_cddescto := '0';
                        END IF;

                        -- Data Desconto
                        IF rw_crapcob.vldescto > 0 THEN
                            vr_dtdescto := to_char(rw_crapcob.dtvencto, 'DDMMYYYY');
                        ELSE
                            vr_dtdescto := ' ';
                        END IF;

                        -- Registro Detalhe - Segmento P
                        vr_setlinha := '085' || -- 01.3P - Banco
                                       gene0002.fn_mask(vr_nrdolote, '9999') || -- 02.3P - Lote
                                       '3' || -- 03.3P - Tipo Registro
                                       gene0002.fn_mask(vr_nro_seq_lote, '99999') || -- 04.3P - Nro. do Registro
                                       'P' || -- 05.3P - Segmento
                                       lpad(' ', 1, ' ') || -- 06.3P - Uso Exclusivo FEBRABAN
                                       '01' || -- 07.3P - Codigo de Movimento Remessa
                                       gene0002.fn_mask(vr_cdageman, '999999') || -- 08.3P - Agencia Mantenedora da Conta
                                       gene0002.fn_mask(rw_crapass.nrdconta, '9999999999999') || -- 10.3P - Número da Conta Corrente
                                       '0' || -- 12.3P - Dígito Verificador da Ag/Conta
                                       lpad(rw_crapcob.nrnosnum, 20, ' ') || -- 13.3P - Nosso Numero
                                       '1' || -- 14.3P - Carteira
                                       '1' || -- 15.3P - Forma de Cadastr. do Título no Banco
                                       '1' || -- 16.3P - Tipo de Documento
                                       '1' || -- 17.3P - Identificação da Emissão do Bloqueto
                                       '1' || -- 18.3P - Identificação da Distribuição
                                       rpad(rw_crapcob.dsdoccop, 15, ' ') || -- 19.3P Nro do Documento
                                       to_char(rw_crapcob.dtvencto, 'DDMMYYYY') || -- 20.3P Vencimento
                                       gene0002.fn_mask(nvl(rw_crapcob.vltitulo, 0) * 100, '999999999999999') || -- 21.3P Valor do Título
                                       gene0002.fn_mask(vr_cdageman, '999999') || -- 22.3P Ag. Cobradora
                                       vr_cddespec || -- 24.3P Espécie de Título
                                       'N' || -- 25.3P Aceite
                                       lpad(nvl(to_char(rw_crapcob.dtdocmto, 'DDMMYYYY'), ' '), 08, ' ') || -- 26.3P - Data Emissão do Título
                                       gene0002.fn_mask(rw_crapcob.tpjurmor, '9') || -- 27.3P - Código do Juros de Mora
                                       lpad(' ', 08, ' ') || -- 28.3P - Data Juros Mora
                                       gene0002.fn_mask(nvl(rw_crapcob.vljurdia, 0) * 100, '999999999999999') || -- 29.3P - Juros de Mora por Dia/Taxa
                                       vr_cddescto || -- 30.3P - Código do Desconto 1
                                       lpad(vr_dtdescto, 08, ' ') || -- 31.3P - Data do Desconto 1
                                       gene0002.fn_mask(nvl(rw_crapcob.vldescto, 0) * 100, '999999999999999') || -- 32.3P - Valor/Percentual a ser Concedido
                                       lpad(' ', 15, ' ') || -- 33.3P - Vlr IOF
                                       gene0002.fn_mask(nvl(rw_crapcob.vlabatim, 0) * 100, '999999999999999') || -- 34.3P - Vlr Abatimento
                                       lpad(vr_uso_empresa, 25, ' ') || -- 35.3P - Uso Empresa Cedente
                                       vr_cdprotes || -- 36.3P - Código p/ Protesto
                                       vr_dias_protesto || -- 37.3P - Prazo p/ Protesto
                                       '2' || -- 38.3P - Código p/ Baixa/Devolução
                                       '000' || -- 39.3P - Prazo p/ Baixa/Devolução
                                       '09' || -- 40.3P - Código da Moeda
                                       lpad(' ', 10, ' ') || -- 41.3P - Número do Contrato
                                       lpad(' ', 1, ' ') || -- 42.3P - Uso livre banco/empresa
                                       chr(13);

                        -- Escreve Linha
                        gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);

                        -- Verifica dados do Sacado
                        OPEN cr_crapsab(pr_cdcooper => rw_crapcob.cdcooper
                                       ,pr_nrdconta => rw_crapcob.nrdconta
                                       ,pr_nrinssac => rw_crapcob.nrinssac);
                        FETCH cr_crapsab
                            INTO rw_crapsab;

                        -- Se não encontrar
                        IF cr_crapsab%NOTFOUND THEN
                            -- Fechar o cursor pois haverá raise
                            CLOSE cr_crapsab;
                            vr_des_erro := 'Sacado nao cadastrado.';
                            RAISE vr_exc_saida;
                        ELSE
                            -- Apenas fechar o cursor
                            CLOSE cr_crapsab;
                        END IF;

                        -- Quantidade Total de Linhas no Arquivo
                        vr_qtd_registro := vr_qtd_registro + 1;

                        -- Nro. Sequencial no Lote
                        vr_nro_seq_lote := vr_nro_seq_lote + 1;

                        -- Monta Campo Endereço
                        vr_endereco := rw_crapsab.dsendsac || ' ' || rw_crapsab.nrendsac || '-' ||
                                       rw_crapsab.complend;
                        vr_endereco := substr(vr_endereco, 1, 40);

                        -- Registro Detalhe - Segmento Q
                        vr_setlinha := '085' || -- 01.3Q - Banco
                                       gene0002.fn_mask(vr_nrdolote, '9999') || -- 02.3Q - Lote
                                       '3' || -- 03.3Q - Tipo Registro
                                       gene0002.fn_mask(vr_nro_seq_lote, '99999') || -- 04.3Q - Nro. do Registro
                                       'Q' || -- 05.3Q - Segmento
                                       lpad(' ', 1, ' ') || -- 06.3Q - Uso Exclusivo FEBRABAN
                                       '01' || -- 07.3Q - Codigo de Movimento Remessa
                                       gene0002.fn_mask(rw_crapsab.cdtpinsc, '9') || -- 08.3Q - Tipo de Inscrição
                                       gene0002.fn_mask(rw_crapsab.nrinssac, '999999999999999') || -- 09.3Q - Número de Inscrição
                                       substr(rpad(rw_crapsab.nmdsacad, 40, ' '), 1, 40) || -- 10.3Q - Nome
                                       lpad(vr_endereco, 40, ' ') || -- 11.3Q - Endereço
                                       substr(rpad(rw_crapsab.nmbaisac, 15, ' '), 1, 15) || -- 12.3Q - Bairro
                                       gene0002.fn_mask(rw_crapsab.nrcepsac, '99999999') || -- 13.3Q - CEP
                                       substr(rpad(rw_crapsab.nmcidsac, 15, ' '), 1, 15) || -- 15.3Q - Cidade
                                       substr(rpad(rw_crapsab.cdufsaca, 02, ' '), 1, 02) || -- 16.3Q - UF
                                       gene0002.fn_mask(rw_crapcob.cdtpinav, '9') || -- 17.3Q - Tipo de Inscrição
                                       gene0002.fn_mask(rw_crapcob.nrinsava, '999999999999999') || -- 18.3Q - Numero da Inscrição
                                       substr(rpad(rw_crapcob.nmdavali, 40, ' '), 1, 40) || -- 19.3Q - Nome do Avalista
                                       '000' || -- 20.3Q - Banco Correspondente
                                       lpad(' ', 20, ' ') || -- 21.3Q - Nosso Núm. Bco. Correpondente
                                       lpad(' ', 8, ' ') || -- 22.3Q - Uso Exclusivo FEBRABAN/CNAB
                                       chr(13);

                        -- Escreve Linha
                        gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);

                        IF rw_crapcob.vlrmulta > 0 THEN

                            -- Quantidade Total de Linhas no Arquivo
                            vr_qtd_registro := vr_qtd_registro + 1;

                            -- Nro. Sequencial no Lote
                            vr_nro_seq_lote := vr_nro_seq_lote + 1;

                            -- Registro Detalhe - Segmento R
                            vr_setlinha := '085' || -- 01.3R - Banco
                                           gene0002.fn_mask(vr_nrdolote, '9999') || -- 02.3R - Lote
                                           '3' || -- 03.3R - Tipo Registro
                                           gene0002.fn_mask(vr_nro_seq_lote, '99999') || -- 04.3R - Nro. do Registro
                                           'R' || -- 05.3R - Segmento
                                           lpad(' ', 1, ' ') || -- 06.3R - Uso Exclusivo FEBRABAN
                                           '01' || -- 07.3R - Codigo de Movimento Remessa
                                           '0' || -- 08.3R - Código do Desconto 2
                                           lpad(' ', 08, ' ') || -- 09.3R - Data do Desconto 2
                                           lpad(' ', 15, ' ') || -- 10.3R - Valor/Percentual a ser Concedido
                                           '0' || -- 11.3R - Código do Desconto 3
                                           lpad(' ', 08, ' ') || -- 12.3R - Data do Desconto 3
                                           lpad(' ', 15, ' ') || -- 13.3R - Valor/Percentual a ser Concedido
                                           gene0002.fn_mask(rw_crapcob.tpdmulta, '9') || -- 14.3R - Codigo da Multa
                                           lpad(' ', 08, ' ') || -- 15.3R - Data da Multa
                                           gene0002.fn_mask(rw_crapcob.vlrmulta * 100, '999999999999999') || -- 16.3R - Valor/Percentual a Ser Aplicado
                                           lpad(' ', 10, ' ') || -- 17.3R - Informação ao Sacado
                                           lpad(' ', 40, ' ') || -- 18.3R - Mensagem 3
                                           lpad(' ', 40, ' ') || -- 19.3R - Mensagem 4
                                           lpad(' ', 20, ' ') || -- 20.3R - Uso Exclusivo FEBRABAN/CNAB
                                           lpad(' ', 08, ' ') || -- 21.3R - Cód. Ocor. do Sacado
                                           lpad('0', 03, '0') || -- 22.3R - Cód. do Banco na Conta do Débito
                                           lpad('0', 05, '0') || -- 23.3R - Código da Agência do Débito
                                           lpad(' ', 01, ' ') || -- 24.3R - Dígito Verificador da Agência
                                           lpad('0', 12, '0') || -- 25.3R - Conta Corrente para Débito
                                           lpad(' ', 01, ' ') || -- 26.3R - Dígito Verificador da Conta
                                           lpad(' ', 01, ' ') || -- 27.3R - Dígito Verificador Ag/Conta
                                           '2' || -- 28.3R - Aviso para Débito Automático
                                           lpad(' ', 9, ' ') || -- 29.3R - Uso Exclusivo FEBRABAN/CNAB
                                           chr(13);

                            -- Escreve Linha
                            gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);

                        END IF;

                        -- Registro Detalhe - Segmento S

                        -- Limpa Variaveis
                        vr_tab_mensagem.delete;
                        vr_tab_mensagem(1) := ' ';
                        vr_tab_mensagem(2) := ' ';
                        vr_tab_mensagem(3) := ' ';
                        vr_tab_mensagem(4) := ' ';

                        -- Busca Mensagem
                        vr_inform := gene0002.fn_quebra_string(REPLACE(rw_crapcob.dsinform, '__', '_'), '_');

                        -- Executa Apenas se Possuir Mensagem
                        IF vr_inform.count > 0 THEN

                            FOR idx IN 1 .. vr_inform.count LOOP
                                IF nvl(gene0002.fn_busca_entrada(1, vr_inform(idx), '#'), ' ') <> ' ' THEN
                                    vr_tab_mensagem(idx) := gene0002.fn_busca_entrada(1, vr_inform(idx), '#');
                                END IF;
                            END LOOP;

                            -- Quantidade Total de Linhas no Arquivo
                            vr_qtd_registro := vr_qtd_registro + 1;

                            -- Nro. Sequencial no Lote
                            vr_nro_seq_lote := vr_nro_seq_lote + 1;

                            -- O Layout Aplicado sera Diferente do Padrão FEBRABAN
                            -- Iremos Usar 4 Mensagens de 50 posições e não 5 de 40 posições
                            -- O valor da Identificação da Impressão será 4

                            -- Registro Detalhe - Segmento S
                            vr_setlinha := '085' || -- 01.3S - Banco
                                           gene0002.fn_mask(vr_nrdolote, '9999') || -- 02.3S - Lote
                                           '3' || -- 03.3S - Tipo Registro
                                           gene0002.fn_mask(vr_nro_seq_lote, '99999') || -- 04.3S - Nro. do Registro
                                           'S' || -- 05.3S - Segmento
                                           lpad(' ', 1, ' ') || -- 06.3S - Uso Exclusivo FEBRABAN
                                           '01' || -- 07.3S - Codigo de Movimento Remessa
                                           '4' || -- 08.3S - Identificação da Impressão
                                           lpad(nvl(vr_tab_mensagem(1), ' '), 50, ' ') || -- 09.3S - Mensagem 5
                                           lpad(nvl(vr_tab_mensagem(2), ' '), 50, ' ') || -- 10.3S - Mensagem 6
                                           lpad(nvl(vr_tab_mensagem(3), ' '), 50, ' ') || -- 11.3S - Mensagem 7
                                           lpad(nvl(vr_tab_mensagem(4), ' '), 50, ' ') || -- 12.3S - Mensagem 8
                                           '' || -- 13.3S - Mensagem 9
                                           lpad(' ', 22, ' ') || -- 14.3S - Uso Exclusivo FEBRABAN/CNAB
                                           chr(13);

                            -- Escreve Linha
                            gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);

                        END IF;

                        -- Quando Ultimo Registro da Conta/Convenio Escreve Trailer do Lote
                        IF rw_crapcob.nrseq = rw_crapcob.qtreg THEN

                            -- Quantidade Total de Linhas no Arquivo
                            vr_qtd_registro := vr_qtd_registro + 1;

                            -- Trailer do Lote
                            vr_setlinha := '085' || -- 01.5 - Banco
                                           '0001' || -- 02.5 - Lote de Serviço
                                           '5' || -- 03.5 - Registro Trailer de Lote
                                           lpad(' ', 9, ' ') || -- 04.5 - Uso Exclusivo FEBRABAN
                                           gene0002.fn_mask(vr_nro_seq_lote, '999999') || -- 05.5 - Qtd Registros do Lote
                                           lpad(' ', 06, ' ') || -- 06.5 - Quantidade de Títulos em Cobrança
                                           lpad(' ', 17, ' ') || -- 07.5 - Valor Total dosTítulos em Carteiras
                                           lpad(' ', 06, ' ') || -- 08.5 - Quantidade de Títulos em Cobrança
                                           lpad(' ', 17, ' ') || -- 09.5 - Valor Total dosTítulos em Carteiras
                                           lpad(' ', 06, ' ') || -- 10.5 - Quantidade de Títulos em Cobrança
                                           lpad(' ', 17, ' ') || -- 11.5 - Quantidade de Títulos em Carteiras
                                           lpad(' ', 06, ' ') || -- 12.5 - Quantidade de Títulos em Cobrança
                                           lpad(' ', 17, ' ') || -- 13.5 - Valor Total dosTítulos em Carteiras
                                           lpad(' ', 08, ' ') || -- 14.5 - Número do Aviso de Lançamento
                                           lpad(' ', 117, ' ') || -- 15.5 - Uso Exclusivo FEBRABAN/CNAB
                                           chr(13);

                            -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
                            gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);
                        END IF;

                    END LOOP; -- Fim loop crapcob

                    -- Verifica se foi Gerado Arquivo
                    IF vr_flg_gera_arq = TRUE THEN

                        ------------- TRAILER DO ARQUIVO -------------
                        -- Quantidade Total de Linhas no Arquivo
                        vr_qtd_registro := vr_qtd_registro + 1;

                        vr_setlinha := '085' || -- 01.9 - Banco
                                       '9999' || -- 02.9 - Lote de Serviço
                                       '9' || -- 03.9 - Tipo Registro
                                       lpad(' ', 9, ' ') || -- 04.9 - Uso Exclusivo FEBRABAN
                                       gene0002.fn_mask(vr_nrdolote, '999999') || -- 05.9 - Qtd de Lotes do Arquivo
                                       gene0002.fn_mask(vr_qtd_registro, '999999') || -- 06.9 - Qtd Registros do Arquivo
                                       gene0002.fn_mask(vr_nrdolote, '999999') || -- 07.9 - Qtd Contas p/ Conciliar
                                       lpad(' ', 205, ' ') || -- 08.9 - Uso Exclusivo FEBRABAN
                                       chr(13);

                        -- Escreve Linha do Trailer de Arquivo CNAB240 - Item 1.9
                        gene0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_setlinha);

                        -- Fechar o arquivo
                        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

                        -- Grava data/hora da Geração do Arquivo.
                        BEGIN
                            UPDATE crapcee
                               SET crapcee.dttransa = trunc(SYSDATE)
                                  ,crapcee.hrtransa = to_number(to_char(SYSDATE, 'SSSSS'))
                             WHERE crapcee.rowid = vr_rowidcce;

                        EXCEPTION
                            WHEN OTHERS THEN
                                vr_dscritic := 'Erro ao atualizar tabela crapcee. ' || SQLERRM;
                                --Sair do programa
                                RAISE vr_exc_saida;
                        END;

                        -- @CHANGE
                        /*vr_nmdirarq := 'mv ' || vr_nmdireto || '/' || vr_nmarquiv || ' ' ||
                                        vr_nmdirslv || '/' || vr_nmarquiv;

                        gene0001.pc_oscommand_shell(pr_des_comando => vr_nmdirarq
                                                   ,pr_flg_aguard  => 'S'
                                                   ,pr_typ_saida   => vr_typ_saida
                                                   ,pr_des_saida   => vr_dscritic);

                        -- Se retornou erro
                        IF vr_dscritic IS NOT NULL THEN
                            -- Concatena o erro que veio
                            vr_dscritic := 'Erro ao mover arquivo: ' || vr_dscritic;
                            RAISE vr_exc_saida; -- encerra programa
                        END IF;*/

                        -- copia contrato pdf do diretorio da cooperativa para servidor web
                        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                                   , pr_cdagenci => NULL
                                                   , pr_nrdcaixa => NULL
                                                   , pr_nmarqpdf => vr_nmdireto||'/'||vr_nmarquiv
                                                   , pr_des_reto => vr_des_reto
                                                   , pr_tab_erro => vr_tab_erro);

                        -- caso apresente erro na operação
                        IF nvl(vr_des_reto,'OK') <> 'OK' THEN
                           IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
                              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
                              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
                              RAISE vr_exc_saida; -- encerra programa
                            END IF;
                        END IF;

                        --pr_nmarqrem := vr_nmdirslv || '/' || vr_nmarquiv;
                        pr_nmarqrem := vr_nmarquiv;

                        -- Atualiza o campo cdidejob com o valor retornado. -- Daniel
                        BEGIN
                            UPDATE crapcee
                               SET crapcee.cdidejob = vr_cdidejob -- Codigo do JOB
                                  ,crapcee.insitmvt = 2 -- Enviado
                                  ,crapcee.dttransa = rw_crabdat.dtmvtolt
                                  ,crapcee.hrtransa = to_number(to_char(SYSDATE, 'SSSSS'))
                             WHERE crapcee.rowid = vr_rowidcce;

                        EXCEPTION
                            WHEN OTHERS THEN
                                vr_dscritic := 'Erro ao atualizar tabela crapcee. ' || SQLERRM;
                                --Sair do programa
                                RAISE vr_exc_saida;
                        END;

                        -- Atualiza Titulos
                        FOR idx IN 1 .. vr_tab_crapcob.count LOOP

                            BEGIN
                                UPDATE crapcob
                                   SET crapcob.inemiexp = 2, crapcob.dtemiexp = rw_crabdat.dtmvtolt
                                 WHERE crapcob.cdcooper = vr_tab_crapcob(idx).cdcooper
                                   AND crapcob.cdbandoc = vr_tab_crapcob(idx).cdbandoc
                                   AND crapcob.nrdctabb = vr_tab_crapcob(idx).nrdctabb
                                   AND crapcob.nrcnvcob = vr_tab_crapcob(idx).nrcnvcob
                                   AND crapcob.nrdconta = vr_tab_crapcob(idx).nrdconta
                                   AND crapcob.nrdocmto = vr_tab_crapcob(idx).nrdocmto
                                RETURNING ROWID INTO vr_rowidcob;

                            EXCEPTION
                                WHEN OTHERS THEN
                                    vr_dscritic := 'Erro ao atualizar tabela crapcob. ' || SQLERRM;
                                    --Sair do programa
                                    RAISE vr_exc_next;
                            END;

                        END LOOP;

                    END IF;

                    -- Liberando a memória alocada pro CLOB
                    dbms_lob.close(vr_des_xml);
                    dbms_lob.freetemporary(vr_des_xml);

                EXCEPTION
                    WHEN vr_exc_next THEN

                        -- Verifica se o arquivo esta aberto
                        IF utl_file.is_open(vr_ind_arquivo) THEN
                            -- Fechar o arquivo
                            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);
                        END IF;

                        -- Descrição do Erro
                        IF vr_dscritic IS NULL THEN
                            vr_dscritic := 'Erro na Geracao arquivo de impressao PG ';
                        END IF;

                        -- Envio Centralizado de Log de Erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2
                                                  , -- ERRO TRATATO
                                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' -' ||
                                                                      vr_cdprogra || ' --> ' || vr_dscritic || ' -' ||
                                                                      rw_crapcop.nmrescop);
                        -- Limpa variavel
                        vr_dscritic := NULL;

                        -- Desfaz
                        ROLLBACK;
                END;

            END LOOP; -- Fim LOOP crapcop

            ----------------- ENCERRAMENTO DO PROGRAMA -------------------

            -- Finaliza Execução do Programa
            btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                     ,pr_cdprogra => vr_cdprogra
                                     ,pr_infimsol => pr_infimsol
                                     ,pr_stprogra => pr_stprogra);

            -- Salvar Informações
            COMMIT;

        EXCEPTION
            WHEN vr_exc_fimprg THEN

                -- Se retornou apenas o codigo
                IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                    -- Busca Descrição
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                END IF;

                -- Se foi gerado critica para envio ao log
                IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

                    -- Envio Centralizado de Log de Erro
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2
                                              , -- ERRO TRATATO
                                               pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' -' ||
                                                                  vr_cdprogra || ' --> ' || vr_dscritic);

                END IF;

                -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
                btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                         ,pr_cdprogra => vr_cdprogra
                                         ,pr_infimsol => pr_infimsol
                                         ,pr_stprogra => pr_stprogra);

                -- Salva informações no banco de dados
                COMMIT;

            WHEN vr_exc_saida THEN
                -- Se foi retornado apenas código
                IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                    -- Buscar a descrição
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                END IF;
                -- Devolvemos código e critica encontradas
                pr_cdcritic := nvl(vr_cdcritic, 0);
                pr_dscritic := vr_dscritic;
                -- Efetuar rollback
                ROLLBACK;
            WHEN OTHERS THEN
                -- Efetuar retorno do erro não tratado
                pr_cdcritic := 0;
                pr_dscritic := SQLERRM;
                -- Efetuar rollback
                ROLLBACK;
        END;

    END pc_gera_arq_remes_cnab240;

    --> Rotina para disponibilizar uma carta de anuencia - Chamada ayllos Web
    PROCEDURE pc_gera_arq_remes_cnab240_web(pr_nrdconta      IN VARCHAR2 --> Número da conta
                                           ,pr_flgregis      IN VARCHAR2 --> Cobranca registrada (0=Nao / 1=Sim)
                                           ,pr_tipo_consulta IN VARCHAR2 --> Tipo de consulta (1-NAO COBRADOS/2-COBRADOS/3-TODOS)
                                           ,pr_consulta      IN VARCHAR2 --> Consulta (1-CONTA/2-DOCUMENTO/3-EMISSAO/4-PAGAMENTO/5-VENCIMENTO/6-PERIODO)
                                           ,pr_inestcri      IN VARCHAR2 --> Somente crise (0=Nao/1=Sim)
                                           ,pr_ini_documento IN VARCHAR2 --> Numero inicial de documento
                                           ,pr_fim_documento IN VARCHAR2 --> Numero final de documento
                                           ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                                           ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                                           ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                                           ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                           ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                           ,pr_des_erro      OUT VARCHAR2) IS
        --> Erros do processo
        /* ............................................................................

           Programa: pc_gera_arq_remes_cnab240_web
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : Andre Clemer (Supero)
           Data    : Outubro/2018                     Ultima atualizacao: --/--/----

           Dados referentes ao programa:

           Frequencia: Sempre que chamado
           Objetivo  : Rotina responsavel para gerar a exportacao de CNAB240 via Mensageria

           Alteracoes: ----

        ............................................................................ */

        -------------->> VARIAVEIS <<----------------
        -- Variavel de criticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_dsretorn VARCHAR2(1000);

        -- Tratamento de erros
        vr_exc_erro EXCEPTION;

        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
        -- Variaveis gerais
        vr_nmarqrem VARCHAR2(1000);
        vr_dsxmlrel CLOB;

        vr_stprogra PLS_INTEGER;
        vr_infimsol PLS_INTEGER;

    BEGIN

        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        pc_gera_arq_remes_cnab240(pr_cdcooper      => vr_cdcooper
                                 ,pr_nrdconta      => pr_nrdconta
                                 ,pr_flgregis      => pr_flgregis
                                 ,pr_tipo_consulta => pr_tipo_consulta
                                 ,pr_consulta      => pr_consulta
                                 ,pr_inestcri      => pr_inestcri
                                 ,pr_ini_documento => pr_ini_documento
                                 ,pr_fim_documento => pr_fim_documento
                                  --------->> OUT <<-----------
                                 ,pr_stprogra      => vr_stprogra --> Saída de termino da execução
                                 ,pr_infimsol      => vr_infimsol --> Saída de termino da solicitação
                                 ,pr_nmarqrem      => vr_nmarqrem --> Caminho e nome do arquivo de remessa a ser exportado
                                 ,pr_cdcritic      => vr_cdcritic --> Critica encontrada
                                 ,pr_dscritic      => vr_dscritic); --> Descricao da critica

        -- Se retornou erro
        IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
        END IF;

        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmarqrem'
                              ,pr_tag_cont => trim(vr_nmarqrem)
                              ,pr_des_erro => vr_dscritic);

    EXCEPTION
        WHEN vr_exc_erro THEN
            IF vr_cdcritic <> 0 THEN
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            END IF;

            vr_dscritic := '<![CDATA[' || vr_dscritic || ']]>';
            pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic, chr(13), ' '), chr(10), ' '), '''', '´');

            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela pc_relat_carta_anuencia_web: ' || SQLERRM;
            pr_dscritic := '<![CDATA[' || pr_dscritic || ']]>';
            pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic, chr(13), ' '), chr(10), ' '), '''', '´');

            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_gera_arq_remes_cnab240_web;
END TELA_COBRAN;
/
