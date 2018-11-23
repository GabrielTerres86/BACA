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
END TELA_COBRAN;
/
