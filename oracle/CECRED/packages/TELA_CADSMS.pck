CREATE OR REPLACE PACKAGE CECRED.TELA_CADSMS IS

  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_CADSMS
  --  Sistema  : Rotinas utilizadas pela Tela CADSMS
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Outubro - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CADSMS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  TYPE typ_campo_mensagem IS
    RECORD (dstipo_mensagem VARCHAR2(100)
           ,cdtipo_mensagem tbgen_mensagem.cdtipo_mensagem%TYPE
           ,dsmensagem      tbgen_mensagem.dsmensagem%TYPE
           ,dsobservacao    tbgen_mensagem.dsmensagem%TYPE
           ,qtmaxcar        INTEGER
           ,dsareatela      VARCHAR2(255)
           );
  TYPE typ_tab_campo_mensagem IS
    TABLE OF typ_campo_mensagem
    INDEX BY VARCHAR2(8);
    
    
  --> Rotina para consultar dados para a tela CADSMS
  PROCEDURE pc_buscar_dados_cadsms_web
                           (pr_cddopcao IN VARCHAR2           --> Opcao informada na tela
                           ,pr_cdcoptel IN INTEGER            --> Cooperativa informada na tela
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);       --> Erros do processo
 
  --> Rotina para gravar dados de params sms
  PROCEDURE pc_gravar_sms_param_web
                           (pr_cddopcao           IN VARCHAR2                                   --> Opcao informada na tela
                           ,pr_cdcoptel           IN INTEGER                                    --> Cooperativa informada na tela                           
                           ,pr_flgoferta_sms      IN tbcobran_sms_param_coop.flgoferta_sms%TYPE      --> Indica se a cooperativa irá ofertar o serviço de sms
                           ,pr_flglinha_digitavel IN tbcobran_sms_param_coop.flglinha_digitavel%TYPE --> Indica se a cooperativa envia linha digitável por sms
                           ,pr_dtini_oferta       IN VARCHAR2                                   --> Data de início da oferta do serviço de sms
                           ,pr_dtfim_oferta       IN VARCHAR2                                   --> Data que termina a oferta do serviço de sms
                           ,pr_nrdiaslautom       IN tbcobran_sms_param_coop.nrdiaslautom%TYPE  --> Número de dias que o débito pode ficar pendente na lautom
                           ,pr_json_mensagens     IN VARCHAR2                                   --> Json contendo as mensagens de sms                             
                           ,pr_xmllog             IN VARCHAR2                                   --> XML com informações de LOG
                           ,pr_cdcritic          OUT PLS_INTEGER                                --> Código da crítica
                           ,pr_dscritic          OUT VARCHAR2                                   --> Descrição da crítica
                           ,pr_retxml         IN OUT NOCOPY XMLType                             --> Arquivo de retorno do XML
                           ,pr_nmdcampo          OUT VARCHAR2                                   --> Nome do campo com erro
                           ,pr_des_erro          OUT VARCHAR2);                                 --> Erros do processo
                           
  PROCEDURE pc_gravar_opcaoM(pr_cdcoptel           IN crapcop.cdcooper%TYPE --> Cooperativa informada na tela
                            ,pr_flglinha_digitavel IN VARCHAR2              --> Indicado de envia linha digitavel
                            ,pr_json_mensagens     IN VARCHAR2              --> Json contendo as mensagens de sms                             
                            ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic          OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml         IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                            ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro          OUT VARCHAR2);            --> Erros do processo                           

  --> Rotina para inserir/alterar as informacoes da opcao P da tela CADSMS
  PROCEDURE pc_gravar_opcaoP(pr_cdcoptel           IN crapcop.cdcooper%TYPE --> Cooperativa informada na tela
                            ,pr_nrdiaslautom       IN INTEGER               --> Numer de dia para lautom
                            ,pr_json_mensagens     IN VARCHAR2              --> Json contendo as mensagens de sms                             
                            ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic          OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml         IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                            ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro          OUT VARCHAR2);           --> Erros do processo                            
                            
  --> Rotina para reenviar lote de SMS de cobrança
  PROCEDURE pc_reenviar_lote_sms(pr_cdcoptel           IN crapcop.cdcooper%TYPE --> Cooperativa informada na tela                            
                                ,pr_json_lotesReenv    IN VARCHAR2              --> Json contendo as mensagens de sms                             
                                ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml         IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro          OUT VARCHAR2);            --> Erros do processo                            
                                
END TELA_CADSMS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADSMS IS
  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_CADSMS
  --  Sistema  : Rotinas utilizadas pela Tela CADSMS
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Outubro - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CADSMS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/
  PROCEDURE pc_busca_mensagens_produto(pr_cdcooper       IN tbgen_mensagem.cdcooper%TYPE
                                      ,pr_cdproduto      IN tbgen_mensagem.cdproduto%TYPE
                                      ,pr_cddopcao       IN VARCHAR2
                                      ,pr_tab_mensagens OUT typ_tab_campo_mensagem) IS
  /* .............................................................................
    
    Programa: pc_busca_mensagens_produto
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Outubro/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar as mensagens de cada produto para SMS/Minhas Mensagens(Internet Bank)
    
    Alteracoes: -----
    ..............................................................................*/
    
    CURSOR cr_msg(pr_cdcooper  tbgen_mensagem.cdcooper%TYPE
                 ,pr_cdproduto tbgen_mensagem.cdproduto%TYPE
                 ,pr_cddopcao  VARCHAR2) IS
    SELECT tip.cdtipo_mensagem
          ,tip.dstipo_mensagem
          ,msg.idmensagem
          ,msg.dsmensagem
          ,DECODE(tip.cdtipo_mensagem
                 , 8, 'Os campos #Nome# e #LinhaDigitavel# são preenchidos automaticamente pelo sistema.<p style="margin-left:10px">#Nome# ocupa 15 caracteres e #LinhaDigitavel# ocupa 54 caracteres.'
                 , 9, 'Os campos #Nome# e #LinhaDigitavel# são preenchidos automaticamente pelo sistema.<p style="margin-left:10px">#Nome# ocupa 15 caracteres e #LinhaDigitavel# ocupa 54 caracteres.'
                 ,10, 'Os campos #Nome# e #LinhaDigitavel# são preenchidos automaticamente pelo sistema.<p style="margin-left:10px">#Nome# ocupa 15 caracteres e #LinhaDigitavel# ocupa 54 caracteres.'
                 ,11, 'O campo #Nome# é preenchido automaticamente pelo sistema e ocupa 15 caracteres.'
                 ,12, 'O campo #Nome# é preenchido automaticamente pelo sistema e ocupa 15 caracteres.'
                 ,13, 'O campo #Nome# é preenchido automaticamente pelo sistema e ocupa 15 caracteres.'
                 ) dsobservacao
          ,CASE WHEN tip.cdtipo_mensagem IN (8,9,10) THEN
                    'Texto para SMS com linha digitável'
                WHEN tip.cdtipo_mensagem IN (11,12,13) THEN
                    'Texto para SMS sem linha digitável'    
                WHEN tip.cdtipo_mensagem IN (14, 15) THEN
                    'Minhas Mensagens'
                WHEN tip.cdtipo_mensagem IN (16) THEN
                    'Internet Bank'
                ELSE NULL
            END dsareatela
          ,CASE WHEN tip.cdtipo_mensagem IN (8,9,10) THEN
                    1
                WHEN tip.cdtipo_mensagem IN (11,12,13) THEN
                    2
                WHEN tip.cdtipo_mensagem IN (14, 15) THEN
                    1
                WHEN tip.cdtipo_mensagem IN (16) THEN
                    2
                ELSE 0
            END nrordemtela
      FROM tbgen_tipo_mensagem tip
          ,tbgen_mensagem      msg
     WHERE tip.cdtipo_mensagem = msg.cdtipo_mensagem(+)
       AND msg.cdcooper(+) = pr_cdcooper
       AND msg.cdproduto(+) = pr_cdproduto
       AND ((pr_cddopcao = 'M' AND pr_cdproduto = 19 AND tip.cdtipo_mensagem IN (8, 9, 10, 11, 12, 13)) OR
            (pr_cddopcao = 'P' AND pr_cdproduto = 19 AND tip.cdtipo_mensagem IN ( 15, 16 /*,14 - desativado*/)))
     ORDER BY nrordemtela, cdtipo_mensagem;
    rw_msg cr_msg%ROWTYPE;
    
    vr_idx_mensagem VARCHAR2(8);
    vr_dstipo_mensagem VARCHAR2(100);
    vr_qtmaxcar        INTEGER;
    
  BEGIN
    
    FOR rw_msg IN cr_msg(pr_cdcooper  => pr_cdcooper 
                        ,pr_cdproduto => pr_cdproduto
                        ,pr_cddopcao  => pr_cddopcao) LOOP
      
      vr_dstipo_mensagem := rw_msg.dstipo_mensagem;
      vr_qtmaxcar        := 0;
      
      IF rw_msg.cdtipo_mensagem IN (8,9,10) THEN
        vr_dstipo_mensagem := vr_dstipo_mensagem ||' (max. 95 caracteres)';
        vr_qtmaxcar        := 95;
      ELSIF  rw_msg.cdtipo_mensagem IN (11,12,13) THEN
        vr_dstipo_mensagem := vr_dstipo_mensagem ||' (max. 127 caracteres)';
        vr_qtmaxcar        := 127;
      END IF;
    
      vr_idx_mensagem := lpad(rw_msg.nrordemtela,3,'0')||lpad(rw_msg.cdtipo_mensagem,5,'0');
      pr_tab_mensagens(vr_idx_mensagem).cdtipo_mensagem := rw_msg.cdtipo_mensagem;
      pr_tab_mensagens(vr_idx_mensagem).dstipo_mensagem := vr_dstipo_mensagem;
      pr_tab_mensagens(vr_idx_mensagem).dsmensagem      := rw_msg.dsmensagem;
      pr_tab_mensagens(vr_idx_mensagem).dsobservacao    := rw_msg.dsobservacao;
      pr_tab_mensagens(vr_idx_mensagem).dsareatela      := rw_msg.dsareatela;
      pr_tab_mensagens(vr_idx_mensagem).qtmaxcar        := vr_qtmaxcar;
    
    END LOOP;
  
  END;
  
  --> Rotina para consultar dados para a tela CADSMS
  PROCEDURE pc_buscar_dados_cadsms_web
                           (pr_cddopcao IN VARCHAR2           --> Opcao informada na tela
                           ,pr_cdcoptel IN INTEGER            --> Cooperativa informada na tela
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_dados_cadsms_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Outubro/2016.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar dados para a tela CADSMS

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_sms_param(pr_cdcooper IN crapope.cdcooper%TYPE) IS
        SELECT nvl(sms.flgoferta_sms,0) flgoferta_sms,
               sms.dtini_oferta,
               sms.dtfim_oferta,
               nvl(sms.flglinha_digitavel,0) flglinha_digitavel,
               sms.nrdiaslautom,
               msg.dsmensagem
          FROM tbcobran_sms_param_coop sms,
               TBGEN_MENSAGEM msg
         WHERE sms.cdcooper   = decode(pr_cdcooper,0,1,pr_cdcooper) -- se informado todos, buscar dados viacredi
           AND sms.cdcooper   = msg.cdcooper(+)
           AND msg.cdtipo_mensagem(+) = 7
           AND msg.cdproduto(+)       = 19;
      rw_sms_param cr_sms_param%ROWTYPE;
      
      --> Buscar lotes pendentes
      CURSOR cr_sms_lote IS       
        SELECT idlote_sms
              ,dhretorno
              ,dsagrupador
          FROM tbgen_sms_lote lot,
               crapcop cop
         WHERE lot.dsagrupador = cop.nmrescop
           AND cop.cdcooper = decode(pr_cdcoptel,0,cop.cdcooper,pr_cdcoptel)
           AND lot.cdproduto  = 19
           AND lot.idsituacao = 'F'
           AND lot.idtpreme   = 'SMSCOBRAN';
      
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdcoptel crapcop.cdcooper%TYPE;
      
      vr_retxml   VARCHAR2(20000);
      vr_tab_mensagens typ_tab_campo_mensagem;
      vr_idx_mensagem  VARCHAR2(20);
      

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
      
      -- Criar cabeçalho do XML
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                   '<root><Dados><inf>';
                             
      --> Se for opcao O - Ofertar Serviço
      IF pr_cddopcao = 'O' THEN
      
        --> Buscar dados do parametro sms
        OPEN cr_sms_param(pr_cdcooper => pr_cdcoptel);
        FETCH cr_sms_param INTO rw_sms_param;
        CLOSE cr_sms_param;
        
        vr_retxml := vr_retxml ||
                     '<flofesms>'|| rw_sms_param.flgoferta_sms                      ||'</flofesms>' ||
                     '<dtiniofe>'|| to_char(rw_sms_param.dtini_oferta,'DD/MM/RRRR') ||'</dtiniofe>' ||
                     '<dtfimofe>'|| to_char(rw_sms_param.dtfim_oferta,'DD/MM/RRRR') ||'</dtfimofe>' ||
                     '<dsmensag>'|| rw_sms_param.dsmensagem                         ||'</dsmensag>';
      
      --> Opcao M - Manutenção de Mensagens para SMS                                            
      ELSIF pr_cddopcao = 'M' THEN
        -- Se for cooperativa 0 (Todas as cooperativas), busca os dados da cooperativa 1
        vr_cdcoptel := CASE pr_cdcoptel WHEN 0 THEN 1 ELSE pr_cdcoptel END;
        
        --> Buscar dados do parametro sms
        OPEN cr_sms_param(pr_cdcooper => pr_cdcoptel);
        FETCH cr_sms_param INTO rw_sms_param;
        CLOSE cr_sms_param;
        
        -- Busca as mensagens para exibir em tela
        pc_busca_mensagens_produto(pr_cdcooper  => vr_cdcoptel
                                  ,pr_cdproduto => 19 
                                  ,pr_cddopcao  => pr_cddopcao
                                  ,pr_tab_mensagens => vr_tab_mensagens);
                
        -- Cria o XML de retorno        
        vr_retxml := vr_retxml || '<flglinha_digitavel>' || rw_sms_param.flglinha_digitavel || '</flglinha_digitavel>';
        vr_retxml := vr_retxml || '<mensagens>';
        
        -- Percorre todas as mensagens
        vr_idx_mensagem := vr_tab_mensagens.FIRST;
        WHILE vr_idx_mensagem IS NOT NULL LOOP
            
          -- Cria a tag <MENSAGEM> no xml de retorno
          vr_retxml := vr_retxml ||   '<mensagem cdtipo_mensagem="' || vr_tab_mensagens(vr_idx_mensagem).cdtipo_mensagem || '">';
          vr_retxml := vr_retxml ||     '<dscampo>'      || vr_tab_mensagens(vr_idx_mensagem).dstipo_mensagem || '</dscampo>';
          vr_retxml := vr_retxml ||     '<dsmensagem>'   || vr_tab_mensagens(vr_idx_mensagem).dsmensagem      || '</dsmensagem>';
          vr_retxml := vr_retxml ||     '<dsobservacao><![CDATA[' || vr_tab_mensagens(vr_idx_mensagem).dsobservacao    || ']]></dsobservacao>';
          vr_retxml := vr_retxml ||     '<dsareatela>'   || vr_tab_mensagens(vr_idx_mensagem).dsareatela      || '</dsareatela>';
          vr_retxml := vr_retxml ||     '<qtmaxcar>'     || vr_tab_mensagens(vr_idx_mensagem).qtmaxcar        || '</qtmaxcar>';
          vr_retxml := vr_retxml ||   '</mensagem>';
          
          --Encontrar o proximo registro
          vr_idx_mensagem:= vr_tab_mensagens.NEXT(vr_idx_mensagem);
          
        END LOOP;
        vr_retxml := vr_retxml || '</mensagens>';
      
      --> Opcao P - Cadastrar parametro
      ELSIF pr_cddopcao = 'P' THEN
        -- Se for cooperativa 0 (Todas as cooperativas), busca os dados da cooperativa 1
        vr_cdcoptel := CASE pr_cdcoptel WHEN 0 THEN 1 ELSE pr_cdcoptel END;
        
        --> Buscar dados do parametro sms
        OPEN cr_sms_param(pr_cdcooper => pr_cdcoptel);
        FETCH cr_sms_param INTO rw_sms_param;
        CLOSE cr_sms_param;
        
        -- Busca as mensagens para exibir em tela
        pc_busca_mensagens_produto(pr_cdcooper  => vr_cdcoptel
                                  ,pr_cdproduto => 19 
                                  ,pr_cddopcao  => pr_cddopcao
                                  ,pr_tab_mensagens => vr_tab_mensagens);
                
        -- Cria o XML de retorno        
        vr_retxml := vr_retxml || '<nrdiaslautom>' || rw_sms_param.nrdiaslautom || '</nrdiaslautom>';
        vr_retxml := vr_retxml || '<mensagens>';
        
        -- Percorre todas as mensagens
        vr_idx_mensagem := vr_tab_mensagens.FIRST;
        WHILE vr_idx_mensagem IS NOT NULL LOOP
            
          -- Cria a tag <MENSAGEM> no xml de retorno
          vr_retxml := vr_retxml ||   '<mensagem cdtipo_mensagem="' || vr_tab_mensagens(vr_idx_mensagem).cdtipo_mensagem || '">';
          vr_retxml := vr_retxml ||     '<dscampo>'      || vr_tab_mensagens(vr_idx_mensagem).dstipo_mensagem || '</dscampo>';
          vr_retxml := vr_retxml ||     '<dsmensagem>'   || vr_tab_mensagens(vr_idx_mensagem).dsmensagem      || '</dsmensagem>';
          vr_retxml := vr_retxml ||     '<dsobservacao>' || vr_tab_mensagens(vr_idx_mensagem).dsobservacao    || '</dsobservacao>';
          vr_retxml := vr_retxml ||     '<dsareatela>'   || vr_tab_mensagens(vr_idx_mensagem).dsareatela      || '</dsareatela>';
          vr_retxml := vr_retxml ||   '</mensagem>';
          
          --Encontrar o proximo registro
          vr_idx_mensagem:= vr_tab_mensagens.NEXT(vr_idx_mensagem);
          
        END LOOP;
        vr_retxml := vr_retxml || '</mensagens>';  
      
      --> Opcao Z - Enviar Zenvia
      ELSIF pr_cddopcao = 'Z' THEN
        
        vr_retxml := vr_retxml || '<lotes>';  
        --> Buscar lotes pendentes
        FOR rw_sms_lote  IN cr_sms_lote LOOP
          vr_retxml := vr_retxml ||   '<lote>';
          vr_retxml := vr_retxml ||     '<idlote_sms>'  || rw_sms_lote.idlote_sms   || '</idlote_sms>';
          vr_retxml := vr_retxml ||     '<dhretorno>'   || to_char(rw_sms_lote.dhretorno,'DD/MM/RRRR HH24:MI:SS')    || '</dhretorno>';
          vr_retxml := vr_retxml ||     '<dsagrupador>' || rw_sms_lote.dsagrupador  || '</dsagrupador>';
          vr_retxml := vr_retxml ||   '</lote>';
          
        END LOOP;  
        vr_retxml := vr_retxml || '</lotes>';  
      
      END IF;

      vr_retxml := vr_retxml || '</inf></Dados></root>';
      pr_retxml := xmltype.createxml(vr_retxml);



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
  END pc_buscar_dados_cadsms_web;
  
  --> Rotina para gravar dados na tabela tbcobran_sms_param_coop
  PROCEDURE pc_gravar_sms_param ( pr_cdcooper           IN INTEGER                                    --> Cooperativa informada na tela
                                 ,pr_flgoferta_sms      IN tbcobran_sms_param_coop.flgoferta_sms%TYPE      --> Indica se a cooperativa irá ofertar o serviço de sms
                                 ,pr_flglinha_digitavel IN tbcobran_sms_param_coop.flglinha_digitavel%TYPE --> Indica se a cooperativa envia linha digitável por sms
                                 ,pr_dtini_oferta       IN tbcobran_sms_param_coop.dtini_oferta%TYPE       --> Data de início da oferta do serviço de sms
                                 ,pr_dtfim_oferta       IN tbcobran_sms_param_coop.dtfim_oferta%TYPE       --> Data que termina a oferta do serviço de sms
                                 ,pr_nrdiaslautom       IN tbcobran_sms_param_coop.nrdiaslautom%TYPE       --> Número de dias que o débito pode ficar pendente na lautom
                                 ,pr_cdoperad           IN crapope.cdoperad%TYPE                      --> Codigo do Operador
                                 ,pr_dscritic          OUT VARCHAR2                                   --> Retorna critica
                                 ) IS
  
  /* .............................................................................

      Programa: pc_gravar_sms_param
      Sistema : CECRED
      Sigla   : COBR
      Autor   : Odirlei Busana
      Data    : Outubro/2016.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para gravar dados na tabela tbcobran_sms_param_coop

      Observacao: -----

      Alteracoes:
  ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------
      
    -- Variável de críticas
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  BEGIN
    BEGIN
      UPDATE tbcobran_sms_param_coop sms
         SET sms.flgoferta_sms      = nvl(pr_flgoferta_sms     ,sms.flgoferta_sms)     
            ,sms.flglinha_digitavel = nvl(pr_flglinha_digitavel,sms.flglinha_digitavel)
            ,sms.dtini_oferta       = nvl(pr_dtini_oferta      ,sms.dtini_oferta)
            ,sms.dtfim_oferta       = nvl(pr_dtfim_oferta      ,sms.dtfim_oferta)
            ,sms.nrdiaslautom       = nvl(pr_nrdiaslautom      ,sms.nrdiaslautom)
            ,sms.dhultima_atu       = SYSDATE
            ,sms.cdoperad           = pr_cdoperad                  
       WHERE sms.cdcooper = pr_cdcooper;
           
       --> Se nao foi alterado nenhum registro, fazer insersão
       IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO tbcobran_sms_param_coop
                     (cdcooper, 
                      flgoferta_sms, 
                      flglinha_digitavel, 
                      dtini_oferta, 
                      dtfim_oferta, 
                      nrdiaslautom, 
                      dhinclusao, 
                      dhultima_atu, 
                      cdoperad)
             VALUES  (pr_cdcooper,           --> cdcooper          
                      pr_flgoferta_sms,      --> flgoferta_sms     
                      pr_flglinha_digitavel, --> flglinha_digitavel
                      pr_dtini_oferta,       --> dtini_oferta
                      pr_dtfim_oferta,       --> dtfim_oferta
                      nvl(pr_nrdiaslautom,0),--> nrdiaslautom
                      SYSDATE,               --> dhinclusao
                      SYSDATE,               --> dhultima_atu
                      pr_cdoperad);          --> cdoperad
            
       END IF;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel atualizar parametro do sms: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel gravar parametro: '|| SQLERRM;  
  END pc_gravar_sms_param;
  
  --> Rotina para gravar dados na tabela tbgen_mensagem
  PROCEDURE pc_gravar_mensagem (pr_cdcooper           IN INTEGER                                    --> Cooperativa informada na tela                               
                               ,pr_cdproduto          IN tbgen_mensagem.cdproduto%TYPE              --> Codigo do produto
                               ,pr_cdtipo_mensagem    IN tbgen_mensagem.cdtipo_mensagem%TYPE        --> Tipo de mensagem
                               ,pr_dsmensagem         IN tbgen_mensagem.dsmensagem%TYPE             --> descrição da Mensagem
                               ,pr_dscritic          OUT VARCHAR2                                   --> Retorna critica
                                ) IS
  
  /* .............................................................................

      Programa: pc_gravar_mensagem
      Sistema : CECRED
      Sigla   : COBR
      Autor   : Odirlei Busana
      Data    : Outubro/2016.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para gravar dados na tabela tbgen_mensagem

      Observacao: -----

      Alteracoes:
  ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  BEGIN    
        
    BEGIN
      UPDATE tbgen_mensagem msg
         SET msg.dsmensagem      = pr_dsmensagem 
       WHERE msg.cdcooper        = pr_cdcooper
         AND msg.cdproduto       = pr_cdproduto
         AND msg.cdtipo_mensagem = pr_cdtipo_mensagem;
             
      --> Se nao foi alterado nenhum registro, fazer insersão
      IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tbgen_mensagem
                    (cdcooper, 
                     cdproduto, 
                     cdtipo_mensagem, 
                     dsmensagem)
             VALUES (pr_cdcooper,        --> cdcooper
                     pr_cdproduto,       --> cdproduto
                     pr_cdtipo_mensagem, --> cdtipo_mensagem
                     pr_dsmensagem);     --> dsmensagem
          
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel atualizar a mensagem de sms: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel gravar mensagem: '|| SQLERRM;  
  END pc_gravar_mensagem;
  
  --> Rotina para gravar dados de params sms
  PROCEDURE pc_gravar_sms_param_web
                           (pr_cddopcao           IN VARCHAR2                                   --> Opcao informada na tela
                           ,pr_cdcoptel           IN INTEGER                                    --> Cooperativa informada na tela                           
                           ,pr_flgoferta_sms      IN tbcobran_sms_param_coop.flgoferta_sms%TYPE      --> Indica se a cooperativa irá ofertar o serviço de sms
                           ,pr_flglinha_digitavel IN tbcobran_sms_param_coop.flglinha_digitavel%TYPE --> Indica se a cooperativa envia linha digitável por sms
                           ,pr_dtini_oferta       IN VARCHAR2                                   --> Data de início da oferta do serviço de sms
                           ,pr_dtfim_oferta       IN VARCHAR2                                   --> Data que termina a oferta do serviço de sms
                           ,pr_nrdiaslautom       IN tbcobran_sms_param_coop.nrdiaslautom%TYPE  --> Número de dias que o débito pode ficar pendente na lautom
                           ,pr_json_mensagens     IN VARCHAR2                                   --> Json contendo as mensagens de sms                             
                           ,pr_xmllog             IN VARCHAR2                                   --> XML com informações de LOG
                           ,pr_cdcritic          OUT PLS_INTEGER                                --> Código da crítica
                           ,pr_dscritic          OUT VARCHAR2                                   --> Descrição da crítica
                           ,pr_retxml         IN OUT NOCOPY XMLType                             --> Arquivo de retorno do XML
                           ,pr_nmdcampo          OUT VARCHAR2                                   --> Nome do campo com erro
                           ,pr_des_erro          OUT VARCHAR2) IS                               --> Erros do processo
    /* .............................................................................

        Programa: pc_gravar_sms_param_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Outubro/2016.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para gravar dados de params sms

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;


      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_json_mensagens json_list := json_list();
      vr_json_msg json   := json();
      vr_dsmensagem      tbgen_mensagem.dsmensagem%TYPE;
      
      vr_dtini_oferta  DATE;
      vr_dtfim_oferta  DATE;
      
      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.flgativo = 1;
      
    --------------->> SUB-ROTINAS <<-----------------
          
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
    
    vr_dtini_oferta := to_date(pr_dtini_oferta,'DD/MM/RRRR');  
    vr_dtfim_oferta := to_date(pr_dtfim_oferta,'DD/MM/RRRR');
    
    -- Percorre as mensagens no JSON e insere os registros
    BEGIN
      vr_json_mensagens := json_list(REPLACE(pr_json_mensagens,'&quot;','"'));
    EXCEPTION
      --> Se apresentar critica de dados nao encontrado não deve abortar o programa
      WHEN no_data_found THEN
        NULL;
    END;
    
    
    --> se foi informado a cooperativa
    IF pr_cdcoptel <> 0 THEN
      pc_gravar_sms_param ( pr_cdcooper           => pr_cdcoptel           --> Cooperativa informada na tela
                           ,pr_flgoferta_sms      => pr_flgoferta_sms      --> Indica se a cooperativa irá ofertar o serviço de sms
                           ,pr_flglinha_digitavel => pr_flglinha_digitavel --> Indica se a cooperativa envia linha digitável por sms
                           ,pr_dtini_oferta       => vr_dtini_oferta       --> Data de início da oferta do serviço de sms
                           ,pr_dtfim_oferta       => vr_dtfim_oferta       --> Data que termina a oferta do serviço de sms
                           ,pr_nrdiaslautom       => pr_nrdiaslautom       --> Número de dias que o débito pode ficar pendente na lautom                           
                           ,pr_cdoperad           => vr_cdoperad           --> Codigo do Operador        
                           ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      --> Varrer as mensagem    
      FOR i IN 1..vr_json_mensagens.count LOOP
          
        vr_json_msg := json(vr_json_mensagens.get(i));          
        vr_dsmensagem := json_ext.get_string(vr_json_msg,'dsmensagem');
        
        --> Gravar mensagem
        pc_gravar_mensagem (pr_cdcooper         => pr_cdcoptel        --> Cooperativa informada na tela                               
                           ,pr_cdproduto        => 19                 --> codigo do produto
                           ,pr_cdtipo_mensagem  => 7                  --> Tipo de mensagem
                           ,pr_dsmensagem       => vr_dsmensagem      --> descrição da Mensagem
                           ,pr_dscritic         => vr_dscritic);      --> Retorna critica
                           
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;                          
      END LOOP;
    ELSE
      
      --> Buscar cooperativa ativas
      FOR rw_crapcop IN cr_crapcop LOOP
        pc_gravar_sms_param ( pr_cdcooper           => rw_crapcop.cdcooper   --> Cooperativa informada na tela
                             ,pr_flgoferta_sms      => pr_flgoferta_sms      --> Indica se a cooperativa irá ofertar o serviço de sms
                             ,pr_flglinha_digitavel => pr_flglinha_digitavel --> Indica se a cooperativa envia linha digitável por sms
                             ,pr_dtini_oferta       => vr_dtini_oferta       --> Data de início da oferta do serviço de sms
                             ,pr_dtfim_oferta       => vr_dtfim_oferta       --> Data que termina a oferta do serviço de sms
                             ,pr_nrdiaslautom       => pr_nrdiaslautom       --> Número de dias que o débito pode ficar pendente na lautom        
                             ,pr_cdoperad           => vr_cdoperad           --> Codigo do Operador        
                             ,pr_dscritic           => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        --> Varrer as mensagem    
        FOR i IN 1..vr_json_mensagens.count LOOP
          
          vr_json_msg := json(vr_json_mensagens.get(i));          
          vr_dsmensagem := json_ext.get_string(vr_json_msg,'dsmensagem');
          
          --> Gravar mensagem
          pc_gravar_mensagem (pr_cdcooper         => rw_crapcop.cdcooper--> Cooperativa informada na tela                               
                             ,pr_cdproduto        => 19                 --> codigo do produto
                             ,pr_cdtipo_mensagem  => 7                  --> Tipo de mensagem
                             ,pr_dsmensagem       => vr_dsmensagem      --> descrição da Mensagem
                             ,pr_dscritic         => vr_dscritic);      --> Retorna critica
                             
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF; 
        END LOOP;
        
      END LOOP;
      
    END IF;
      
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => 'Registro atualizado com sucesso.',
                           pr_des_erro => vr_dscritic);
    
    
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
      pr_dscritic := REPLACE(pr_dscritic,'"');
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      pr_dscritic := REPLACE(pr_dscritic,'"');
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gravar_sms_param_web;
  
  --> Rotina para inserir/alterar as informacoes da opcao M da tela CADSMS
  PROCEDURE pc_gravar_opcaoM(pr_cdcoptel           IN crapcop.cdcooper%TYPE --> Cooperativa informada na tela
                            ,pr_flglinha_digitavel IN VARCHAR2              --> Indicado de envia linha digitavel
                            ,pr_json_mensagens     IN VARCHAR2              --> Json contendo as mensagens de sms                             
                            ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic          OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml         IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                            ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro          OUT VARCHAR2) IS          --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_gravar_opcaoM
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Outubro/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para inserir/alterar as informacoes da opcao M da tela CADSMS
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Variaveis auxiliares
    
    vr_json_mensagens json_list := json_list();
    vr_json_msg json   := json();
    vr_cdtipo_mensagem tbgen_mensagem.cdtipo_mensagem%TYPE;
    vr_dsmensagem      tbgen_mensagem.dsmensagem%TYPE;
    vr_dsmensagem_aux  tbgen_mensagem.dsmensagem%TYPE;
    vr_retxml VARCHAR2(4000);
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    ---------->> CURSORES <<--------
    
    --> Buscar dados operador
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE)IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1
         AND cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper);
    
    --> Buscar descricao do tipo mensagem 
    CURSOR cr_tpmsg(pr_cdtipo_msg  tbgen_tipo_mensagem.cdtipo_mensagem%TYPE) IS
      SELECT tpm.dstipo_mensagem
        FROM tbgen_tipo_mensagem tpm
       WHERE tpm.cdtipo_mensagem = pr_cdtipo_msg;
    rw_tpmsg cr_tpmsg%ROWTYPE;   
    
  BEGIN
    
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- VALIDAÇÕES
    
    -- Percorre as mensagens no JSON e insere os registros
    BEGIN
      vr_json_mensagens := json_list(REPLACE(pr_json_mensagens,'&quot;','"'));
    EXCEPTION
      --> Se apresentar critica de dados nao encontrado não deve abortar o programa
      WHEN no_data_found THEN
        NULL;
    END;
    -- Buscar coops para gravar dados
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcoptel ) LOOP
      
      pc_gravar_sms_param ( pr_cdcooper           => rw_crapcop.cdcooper   --> Cooperativa informada na tela
                           ,pr_flgoferta_sms      => NULL                  --> Indica se a cooperativa irá ofertar o serviço de sms
                           ,pr_flglinha_digitavel => pr_flglinha_digitavel --> Indica se a cooperativa envia linha digitável por sms
                           ,pr_dtini_oferta       => NULL                  --> Data de início da oferta do serviço de sms
                           ,pr_dtfim_oferta       => NULL                  --> Data que termina a oferta do serviço de sms
                           ,pr_nrdiaslautom       => NULL                  --> Número de dias que o débito pode ficar pendente na lautom                           
                           ,pr_cdoperad           => vr_cdoperad           --> Codigo do Operador        
                           ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;  
      
      --> Varrer as mensagem    
      FOR i IN 1..vr_json_mensagens.count LOOP
        
        vr_json_msg := json(vr_json_mensagens.get(i));
        vr_cdtipo_mensagem := to_number(json_ext.get_string(vr_json_msg,'cdtipo_mensagem'));
        vr_dsmensagem := json_ext.get_string(vr_json_msg,'dsmensagem');
        
        vr_dsmensagem_aux := REPLACE(REPLACE(vr_dsmensagem,
                                             '#Nome#',lpad('A',15,'A')),
                                             '#LinhaDigitavel#',lpad('0',54,'0'));
        
        IF length(vr_dsmensagem_aux) > 160 THEN
          --> Buscar descricao do tipo mensagem 
          OPEN cr_tpmsg(pr_cdtipo_msg => vr_cdtipo_mensagem);
          FETCH cr_tpmsg INTO rw_tpmsg;
          CLOSE cr_tpmsg;
        
          vr_dscritic := '<![CDATA[<span>'|| rw_tpmsg.dstipo_mensagem||
                         ':<br>Quantidade de caracteres maior que o '||
                         'permitido devido ao Termos utilizados.</span>]]>';
          RAISE vr_exc_saida;
        END IF;
        
        --> Gravar mensagem
        pc_gravar_mensagem (pr_cdcooper         => rw_crapcop.cdcooper --> Cooperativa informada na tela                               
                           ,pr_cdproduto        => 19                  --> codigo do produto
                           ,pr_cdtipo_mensagem  => vr_cdtipo_mensagem  --> Tipo de mensagem
                           ,pr_dsmensagem       => vr_dsmensagem       --> descrição da Mensagem
                           ,pr_dscritic         => vr_dscritic);       --> Retorna critica
                           
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;              
        
      END LOOP;
    END LOOP;
    
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root><Dados>';
    vr_retxml := vr_retxml || '<mensagem>Registros atualizados com sucesso. </mensagem>';
    vr_retxml := vr_retxml || '</Dados></Root>';
  
    pr_retxml := xmltype.createxml(vr_retxml);
  
    COMMIT;
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
    
      pr_des_erro := 'NOK';
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
    WHEN OTHERS THEN
    
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_gravar_opcaoM;
  
  --> Rotina para inserir/alterar as informacoes da opcao P da tela CADSMS
  PROCEDURE pc_gravar_opcaoP(pr_cdcoptel           IN crapcop.cdcooper%TYPE --> Cooperativa informada na tela
                            ,pr_nrdiaslautom       IN INTEGER               --> Numer de dia para lautom
                            ,pr_json_mensagens     IN VARCHAR2              --> Json contendo as mensagens de sms                             
                            ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic          OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml         IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                            ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro          OUT VARCHAR2) IS          --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_gravar_opcaoP
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Outubro/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para inserir/alterar as informacoes da opcao P da tela CADSMS
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Variaveis auxiliares
    
    vr_json_mensagens json_list := json_list();
    vr_json_msg json   := json();
    vr_cdtipo_mensagem tbgen_mensagem.cdtipo_mensagem%TYPE;
    vr_dsmensagem      tbgen_mensagem.dsmensagem%TYPE;
    vr_retxml VARCHAR2(4000);
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
    
    ---------->> CURSORES <<--------
    
    --> Buscar dados operador
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE)IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1
         AND cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper);
    
  BEGIN
    
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- VALIDAÇÕES
    
    -- Percorre as mensagens no JSON e insere os registros
    BEGIN
      vr_json_mensagens := json_list(REPLACE(pr_json_mensagens,'&quot;','"'));
    EXCEPTION
      --> Se apresentar critica de dados nao encontrado não deve abortar o programa
      WHEN no_data_found THEN
        NULL;
    END;
    -- Buscar coops para gravar dados
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcoptel ) LOOP
      
      pc_gravar_sms_param ( pr_cdcooper           => rw_crapcop.cdcooper   --> Cooperativa informada na tela
                           ,pr_flgoferta_sms      => NULL                  --> Indica se a cooperativa irá ofertar o serviço de sms
                           ,pr_flglinha_digitavel => NULL                  --> Indica se a cooperativa envia linha digitável por sms
                           ,pr_dtini_oferta       => NULL                  --> Data de início da oferta do serviço de sms
                           ,pr_dtfim_oferta       => NULL                  --> Data que termina a oferta do serviço de sms
                           ,pr_nrdiaslautom       => pr_nrdiaslautom       --> Número de dias que o débito pode ficar pendente na lautom                           
                           ,pr_cdoperad           => vr_cdoperad           --> Codigo do Operador        
                           ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;  
      
      --> Varrer as mensagem    
      FOR i IN 1..vr_json_mensagens.count LOOP
        
        vr_json_msg := json(vr_json_mensagens.get(i));
        vr_cdtipo_mensagem := to_number(json_ext.get_string(vr_json_msg,'cdtipo_mensagem'));
        vr_dsmensagem := json_ext.get_string(vr_json_msg,'dsmensagem');
        
        --> remover tag cdata para a mensagem 15
        IF vr_cdtipo_mensagem = 15 THEN
          vr_dsmensagem := gene0007.fn_remove_cdata(vr_dsmensagem);
        END IF;
        
        --> Gravar mensagem
        pc_gravar_mensagem (pr_cdcooper         => rw_crapcop.cdcooper --> Cooperativa informada na tela                               
                           ,pr_cdproduto        => 19                  --> codigo do produto
                           ,pr_cdtipo_mensagem  => vr_cdtipo_mensagem  --> Tipo de mensagem
                           ,pr_dsmensagem       => vr_dsmensagem       --> descrição da Mensagem
                           ,pr_dscritic         => vr_dscritic);       --> Retorna critica
                           
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;              
        
      END LOOP;
    END LOOP;
    
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root><Dados>';
    vr_retxml := vr_retxml || '<mensagem>Registros atualizados com sucesso. </mensagem>';
    vr_retxml := vr_retxml || '</Dados></Root>';
  
    pr_retxml := xmltype.createxml(vr_retxml);
  
    COMMIT;
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
    
      pr_des_erro := 'NOK';
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
    WHEN OTHERS THEN
    
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_gravar_opcaoP;
  
  --> Rotina para reenviar lote de SMS de cobrança
  PROCEDURE pc_reenviar_lote_sms(pr_cdcoptel           IN crapcop.cdcooper%TYPE --> Cooperativa informada na tela                            
                                ,pr_json_lotesReenv    IN VARCHAR2              --> Json contendo as mensagens de sms                             
                                ,pr_xmllog             IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml         IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro          OUT VARCHAR2) IS          --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_reenviar_lote_sms
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Novembro/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para reenviar lote de SMS de cobrança
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Variaveis auxiliares
    
    vr_json_lotes json_list := json_list();
    vr_json_lote json   := json();    
    vr_retxml VARCHAR2(4000);
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
    
    vr_idlote_sms tbgen_sms_lote.idlote_sms%TYPE;
    
    ---------->> CURSORES <<--------
    
    
  BEGIN
    
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- VALIDAÇÕES
    
    -- Percorre as mensagens no JSON e insere os registros
    BEGIN
      vr_json_lotes := json_list(REPLACE(pr_json_lotesReenv,'&quot;','"'));
    EXCEPTION
      --> Se apresentar critica de dados nao encontrado não deve abortar o programa
      WHEN no_data_found THEN
        NULL;
    END;      
      
    --> Varrer as mensagem    
    FOR i IN 1..vr_json_lotes.count LOOP
          
      vr_json_lote := json(vr_json_lotes.get(i));
      vr_idlote_sms := to_number(json_ext.get_string(vr_json_lote,'idlote_sms'));        
          
      --> Atualizar lote
      BEGIN
        UPDATE tbgen_sms_lote lot
           SET lot.idsituacao = 'A'
         WHERE lot.idlote_sms = vr_idlote_sms;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar o lote de SMS: '||SQLERRM;
      END;
          
      --> Necessario commit para que o Aymaru consiga consultar
      --> as informações Atualizadas
      COMMIT;      
          
      --> Enviar lote de SMS para o Aymaru
      COBR0005.pc_enviar_lote_SMS ( pr_idlotsms  => vr_idlote_sms
                                   ,pr_dscritic  => vr_dscritic
                                   ,pr_cdcritic  => vr_cdcritic );
                                
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
         
        vr_dscritic := GENE0007.fn_convert_db_web(substr(vr_dscritic,1,150)); 
        RAISE vr_exc_saida;
      END IF;
          
    END LOOP;
    
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root><Dados>';
    vr_retxml := vr_retxml || '<mensagem>Lotes reenviados com sucesso. </mensagem>';
    vr_retxml := vr_retxml || '</Dados></Root>';
  
    pr_retxml := xmltype.createxml(vr_retxml);
  
    COMMIT;
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
    
      pr_des_erro := 'NOK';
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_dscritic := REPLACE(pr_dscritic,chr(10));
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro><![CDATA[' || pr_dscritic ||']]>'||
                                     '</Erro></Root>');
      ROLLBACK;
    
    WHEN OTHERS THEN
    
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_dscritic := REPLACE(pr_dscritic,chr(10));
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_reenviar_lote_sms;
  
  
    
END TELA_CADSMS;
/
