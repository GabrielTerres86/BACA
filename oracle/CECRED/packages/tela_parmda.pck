CREATE OR REPLACE PACKAGE cecred.tela_parmda IS

  PROCEDURE pc_busca_parmda(pr_cdcooperalt IN crapcop.cdcooper%TYPE
                            
                           ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_mantem_parmda(pr_cdcooperalt     IN crapcop.cdcooper%TYPE
                            ,pr_flgenvia_sms    IN VARCHAR2
                            ,pr_flgcobra_tarifa IN VARCHAR2
                            ,pr_hrenvio_sms_fmt IN VARCHAR2
                            ,pr_cdtarifa_pf     IN VARCHAR2
                            ,pr_cdtarifa_pj     IN VARCHAR2
                            ,pr_json_mensagens  IN VARCHAR2
                             
                            ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                            ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_parmda(pr_cdcooperalt IN crapcop.cdcooper%TYPE
                             
                            ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                            ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_valor_tarifa(pr_cdcooperalt IN crapcop.cdcooper%TYPE
                                 ,pr_cdtarifa    IN craptar.cdtarifa%TYPE
  
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

END tela_parmda;
/
CREATE OR REPLACE PACKAGE BODY cecred.tela_parmda IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARMDA
  --  Sistema  : Ayllos Web
  --  Autor    : Dionathan Henchel
  --  Data     : Dezembro - 2015.                Ultima atualizacao: 20/01/2017
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela parmda
  --
  -- Alteracoes: 20/01/2017 - Incluir replace dos caractered de enter e quebra de linha por
  --                          nada, pois estava afetando na consulta das informa��es
  --                          (Lucas Ranghetti #581389)
  ---------------------------------------------------------------------------

  vr_nmdatela VARCHAR(6) := 'PARMDA';
  
  TYPE typ_campo_mensagem IS
    RECORD (dstipo_mensagem tbgen_tipo_mensagem.dstipo_mensagem%TYPE
           ,cdtipo_mensagem tbgen_mensagem.cdtipo_mensagem%TYPE
           ,dsmensagem      tbgen_mensagem.dsmensagem%TYPE
           ,dsobservacao    tbgen_mensagem.dsmensagem%TYPE
           ,dsareatela      VARCHAR2(255)
           );
  TYPE typ_tab_campo_mensagem IS
    TABLE OF typ_campo_mensagem
    INDEX BY VARCHAR2(8);
  
  FUNCTION fn_obtem_valor_tarifa(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_cdtarifa IN craptar.cdtarifa%TYPE) RETURN NUMBER IS
    /* .............................................................................
    
    Programa: fn_obtem_valor_tarifa
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Maio/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar o valor de uma tarifa
    
    Alteracoes: -----
    ..............................................................................*/
    vr_cdhistar INTEGER;  --Codigo Historico
    vr_cdhisest NUMBER;   --Historico Estorno
    vr_vltarifa NUMBER;   --Valor tarifa
    vr_dtdivulg DATE;     --Data Divulgacao
    vr_dtvigenc DATE;     --Data Vigencia
    vr_cdfvlcop INTEGER;  --Codigo faixa valor cooperativa
    vr_tab_erro GENE0001.typ_tab_erro; --Tabela erros
    
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000);
    
  BEGIN
    
    -- Busca valor da tarifa
    TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                          ,pr_cdtarifa  => pr_cdtarifa  --Codigo Tarifa
                                          ,pr_vllanmto  => 0            --Valor Lancamento
                                          ,pr_cdprogra  => NULL         --Codigo Programa
                                          ,pr_cdhistor  => vr_cdhistar  --Codigo Historico da tarifa
                                          ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                          ,pr_vltarifa  => vr_vltarifa  --Valor tarifa
                                          ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                          ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                          ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                          ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                          ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                          ,pr_tab_erro  => vr_tab_erro); --Tabela erros
    
    -- N�O TRATA EXCE��O, APENAS IGNORA E RETORNA VALOR VAZIO
    /*--Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
        pr_dscritic:= vr_tab_erro(1).dscritic;
      ELSE
        pr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;*/
    
    RETURN vr_vltarifa;
    
  END;
  
  PROCEDURE pc_busca_mensagens_produto(pr_cdcooper IN tbgen_mensagem.cdcooper%TYPE
                                      ,pr_cdproduto IN tbgen_mensagem.cdproduto%TYPE
                                      ,pr_tab_mensagens OUT typ_tab_campo_mensagem) IS
  /* .............................................................................
    
    Programa: pc_busca_mensagens_produto
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Maio/2015                 Ultima atualizacao: 20/01/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar as mensagens de cada produto para SMS/Minhas Mensagens(Internet Bank)
    
    Alteracoes: 20/01/2017 - Incluir replace dos caractered de enter e quebra de linha por
                             nada, pois estava afetando na consulta das informa��es
                             (Lucas Ranghetti #581389)
    ..............................................................................*/
    
    CURSOR cr_msg(pr_cdcooper tbgen_mensagem.cdcooper%TYPE
                 ,pr_cdproduto tbgen_mensagem.cdproduto%TYPE) IS
    SELECT tip.cdtipo_mensagem
          ,tip.dstipo_mensagem
          ,msg.idmensagem
          ,REPLACE(REPLACE(msg.dsmensagem,chr(10),''),chr(13),'') dsmensagem
          ,DECODE(tip.cdtipo_mensagem
                 ,3, 'Os campos #Cooperativa#, #Convenio#, #Data# e #Valor# s�o preenchidos automaticamente pelo sistema.'
                 ,5, 'Os campos #Cooperativa#, #Convenio#, #Data# e #Valor# s�o preenchidos automaticamente pelo sistema.'
                 ,4, 'Os campos #Cooperativa#, #Convenio#, #Data#, #Valor# e #Limite# s�o preenchidos automaticamente pelo sistema.'
                 ,6, 'Os campos #Cooperativa#, #Convenio#, #Data#, #Valor# e #Limite# s�o preenchidos automaticamente pelo sistema.'
                 ) dsobservacao
          ,CASE WHEN UPPER(tip.dstipo_mensagem) LIKE '%SMS%'
                THEN 'SMS'
                WHEN UPPER(tip.dstipo_mensagem) LIKE '%MINHAS MENSAGENS%'
                THEN 'Minhas Mensagens'
                ELSE NULL
            END dsareatela
          ,CASE WHEN UPPER(tip.dstipo_mensagem) LIKE '%SMS%'
                THEN 1
                WHEN UPPER(tip.dstipo_mensagem) LIKE '%MINHAS MENSAGENS%'
                THEN 2
                ELSE 0
            END nrordemtela
      FROM tbgen_tipo_mensagem tip
          ,tbgen_mensagem      msg
     WHERE tip.cdtipo_mensagem = msg.cdtipo_mensagem(+)
       AND msg.cdcooper(+) = pr_cdcooper
       AND msg.cdproduto(+) = pr_cdproduto
       AND (pr_cdproduto = 10 AND tip.cdtipo_mensagem IN (1, 2, 3, 4, 5, 6))
     ORDER BY nrordemtela, cdtipo_mensagem;
    rw_msg cr_msg%ROWTYPE;
    
    vr_idx_mensagem VARCHAR2(8);
    
  BEGIN
    
    FOR rw_msg IN cr_msg(pr_cdcooper => pr_cdcooper 
                        ,pr_cdproduto => pr_cdproduto)
    LOOP
      
      vr_idx_mensagem := lpad(rw_msg.nrordemtela,3,'0')||lpad(rw_msg.cdtipo_mensagem,5,'0');
      pr_tab_mensagens(vr_idx_mensagem).cdtipo_mensagem := rw_msg.cdtipo_mensagem;
      pr_tab_mensagens(vr_idx_mensagem).dstipo_mensagem := rw_msg.dstipo_mensagem;
      pr_tab_mensagens(vr_idx_mensagem).dsmensagem      := rw_msg.dsmensagem;
      pr_tab_mensagens(vr_idx_mensagem).dsobservacao    := rw_msg.dsobservacao;
      pr_tab_mensagens(vr_idx_mensagem).dsareatela      := rw_msg.dsareatela;
    
    END LOOP;
  
  END;

  PROCEDURE pc_busca_parmda(pr_cdcooperalt IN crapcop.cdcooper%TYPE
                            
                           ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_busca_parmda
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Maio/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar os par�metros de mensagem do d�bito automatico
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Selecionar os dados de indexadores pelo nome
    CURSOR cr_parmda(pr_cdcooper IN tbgen_sms_param.cdcooper%TYPE) IS
      SELECT parmda.*
            ,to_char(to_date(parmda.hrenvio_sms, 'SSSSS'), 'hh24:mi') hrenvio_sms_fmt
        FROM tbgen_sms_param parmda
       WHERE parmda.cdcooper = pr_cdcooper;
    rw_parmda cr_parmda%ROWTYPE;
    
    -- Variaveis auxiliares
    vr_cdcooperalt crapcop.cdcooper%TYPE;
    vr_tab_mensagens typ_tab_campo_mensagem;
    vr_vltarifapf crapfco.vltarifa%TYPE;
    vr_vltarifapj crapfco.vltarifa%TYPE;
    vr_idx_mensagem VARCHAR(8);
    vr_retxml VARCHAR2(4000);
  
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    /* vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);*/
  
  BEGIN
    -- N�o precisa executar pois neste processo n�o utilizamos estes dados
    /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
    ,pr_cdcooper => vr_cdcooper
    ,pr_nmdatela => vr_nmdatela
    ,pr_nmeacao  => vr_nmeacao
    ,pr_cdagenci => vr_cdagenci
    ,pr_nrdcaixa => vr_nrdcaixa
    ,pr_idorigem => vr_idorigem
    ,pr_cdoperad => vr_cdoperad
    ,pr_dscritic => vr_dscritic);*/
    
    -- Se for cooperativa 0 (Todas as cooperativas), busca os dados da cooperativa 1
    vr_cdcooperalt := CASE pr_cdcooperalt WHEN 0 THEN 1 ELSE pr_cdcooperalt END;
    
    OPEN cr_parmda(pr_cdcooper => vr_cdcooperalt);
    FETCH cr_parmda
      INTO rw_parmda;
    CLOSE cr_parmda;
    
    -- Busca as mensagens para exibir em tela
    pc_busca_mensagens_produto(pr_cdcooper  => vr_cdcooperalt
                              ,pr_cdproduto => 10 -- D�bito autom�tico
                              ,pr_tab_mensagens => vr_tab_mensagens);
    
    -- Busca os valores das tarifas
    vr_vltarifapf := fn_obtem_valor_tarifa(pr_cdcooper => vr_cdcooperalt --Codigo Cooperativa
                                          ,pr_cdtarifa  => rw_parmda.cdtarifa_pf);  --Codigo Tarifa
    
    vr_vltarifapj := fn_obtem_valor_tarifa(pr_cdcooper => vr_cdcooperalt --Codigo Cooperativa
                                          ,pr_cdtarifa  => rw_parmda.cdtarifa_pj);  --Codigo Tarifa
    
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<Dados>';
    vr_retxml := vr_retxml || '<flgenvia_sms>' || rw_parmda.flgenvia_sms || '</flgenvia_sms>';
    vr_retxml := vr_retxml || '<flgcobra_tarifa>' || rw_parmda.flgcobra_tarifa || '</flgcobra_tarifa>';
    vr_retxml := vr_retxml || '<hrenvio_sms>' || rw_parmda.hrenvio_sms_fmt || '</hrenvio_sms>';
    vr_retxml := vr_retxml || '<cdtarifa_pf>' || rw_parmda.cdtarifa_pf || '</cdtarifa_pf>';
    vr_retxml := vr_retxml || '<vltarifa_pf>' || vr_vltarifapf || '</vltarifa_pf>';
    vr_retxml := vr_retxml || '<cdtarifa_pj>' || rw_parmda.cdtarifa_pj || '</cdtarifa_pj>';
    vr_retxml := vr_retxml || '<vltarifa_pj>' || vr_vltarifapj || '</vltarifa_pj>';
    vr_retxml := vr_retxml || '<mensagens>';
    
    -- Percorre todas as mensagens
    vr_idx_mensagem := vr_tab_mensagens.FIRST;
    WHILE vr_idx_mensagem IS NOT NULL
      LOOP
        
      -- Cria a tag <MENSAGEM> no xml de retorno
        vr_retxml := vr_retxml ||   '<mensagem cdtipo_mensagem="' || vr_tab_mensagens(vr_idx_mensagem).cdtipo_mensagem || '">';
        vr_retxml := vr_retxml ||     '<dscampo>' || vr_tab_mensagens(vr_idx_mensagem).dstipo_mensagem || '</dscampo>';
        vr_retxml := vr_retxml ||     '<dsmensagem>'|| vr_tab_mensagens(vr_idx_mensagem).dsmensagem || '</dsmensagem>';
        vr_retxml := vr_retxml ||     '<dsobservacao>' || vr_tab_mensagens(vr_idx_mensagem).dsobservacao || '</dsobservacao>';
        vr_retxml := vr_retxml ||     '<dsareatela>' || vr_tab_mensagens(vr_idx_mensagem).dsareatela || '</dsareatela>';
        vr_retxml := vr_retxml ||   '</mensagem>';
      
        --Encontrar o proximo registro
        vr_idx_mensagem:= vr_tab_mensagens.NEXT(vr_idx_mensagem);
      END LOOP;
    
    vr_retxml := vr_retxml || '</mensagens>';
    vr_retxml := vr_retxml || '</Dados>';
    vr_retxml := vr_retxml || '</Root>';
  
    pr_retxml := xmltype.createxml(vr_retxml);
  
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
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
    
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
  
  END pc_busca_parmda;

  PROCEDURE pc_mantem_parmda(pr_cdcooperalt     IN crapcop.cdcooper%TYPE
                            ,pr_flgenvia_sms    IN VARCHAR2
                            ,pr_flgcobra_tarifa IN VARCHAR2
                            ,pr_hrenvio_sms_fmt IN VARCHAR2
                            ,pr_cdtarifa_pf     IN VARCHAR2
                            ,pr_cdtarifa_pj     IN VARCHAR2
                            ,pr_json_mensagens  IN VARCHAR2
                             
                            ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                            ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_mantem_parmda
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Maio/2015                 Ultima atualizacao: 20/01/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para inserir/alterar os par�metros de mensagem do d�bito automatico
    
    Alteracoes: 20/01/2017 - Incluir replace dos caractered de enter e quebra de linha por
                             nada, pois estava afetando na consulta das informa��es
                             (Lucas Ranghetti #581389)
    ..............................................................................*/
  
    -- Variaveis auxiliares
    vr_hrenvio_sms tbgen_sms_param.hrenvio_sms%TYPE;
    vr_json_mensagens json_list := json_list();
    vr_json_msg json   := json();
    vr_cdtipo_mensagem tbgen_mensagem.cdtipo_mensagem%TYPE;
    vr_dsmensagem      tbgen_mensagem.dsmensagem%TYPE;
    vr_retxml VARCHAR2(4000);
  
    -- Vari�vel de cr�ticas
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
    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    CURSOR cr_hora_sssss(pr_hora VARCHAR2) IS
    SELECT to_char(to_date(pr_hora, 'hh24:mi'), 'SSSSS')
      FROM dual;
    
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
    
    -- VALIDA��ES
    -- Valida os campos obrigat�rios caso envia SMS
    IF pr_flgenvia_sms = 1 THEN
        IF pr_hrenvio_sms_fmt IS NULL THEN
          vr_dscritic := 'Horario de envio e obrigatorio.';
          pr_nmdcampo := 'hrenvio_sms';
          RAISE vr_exc_saida;
        END IF;
    END IF;
    
    -- Valida os campos obrigat�rios caso cobra tarifa de SMS
    IF pr_flgcobra_tarifa = 1 THEN
        IF pr_cdtarifa_pf IS NULL THEN
          vr_dscritic := 'Tarifa de pessoa fisica e obrigatoria.';
          pr_nmdcampo := 'cdtarifa_pf';
          RAISE vr_exc_saida;
        END IF;
        
        IF pr_cdtarifa_pj IS NULL THEN
          vr_dscritic := 'Tarifa de pessoa juridica e obrigatoria.';
          pr_nmdcampo := 'cdtarifa_pj';
          RAISE vr_exc_saida;
        END IF;
    END IF;
    
    BEGIN
      
      -- Extrai a hora em formato de num�rico
      OPEN cr_hora_sssss(TRIM(pr_hrenvio_sms_fmt));
      FETCH cr_hora_sssss
      INTO vr_hrenvio_sms;
      CLOSE cr_hora_sssss;
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Horario de envio em formato invalido.';
        pr_nmdcampo := 'hrenvio_sms';
        RAISE vr_exc_saida;
    END;
    
    -- Apaga os registros antigos, pois sempre insere novos registros devido � op��o 0 (Todas as cooperativas)
    BEGIN
      DELETE tbgen_sms_param parmda
       WHERE parmda.cdcooper = pr_cdcooperalt OR pr_cdcooperalt = 0;
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Ocorreu um erro ao atualizar os parametros.';
        RAISE vr_exc_saida;
    END;
    
    -- Caso a cooperativa recebida para alterar for 0 (Todas), insere o registro para todas as cooperativas
    BEGIN
      INSERT INTO tbgen_sms_param parmda
        (parmda.cdcooper
        ,parmda.flgenvia_sms
        ,parmda.flgcobra_tarifa
        ,parmda.hrenvio_sms
        ,parmda.cdoperad
        ,parmda.dtultima_atu
        ,parmda.cdproduto
        ,parmda.cdtarifa_pf
        ,parmda.cdtarifa_pj)
        (SELECT cop.cdcooper
               ,pr_flgenvia_sms
               ,pr_flgcobra_tarifa
               ,vr_hrenvio_sms
               ,vr_cdoperad
               ,SYSDATE
               ,10 -- D�bito Autom�tico
               ,DECODE(pr_flgcobra_tarifa,1,pr_cdtarifa_pf,NULL)
               ,DECODE(pr_flgcobra_tarifa,1,pr_cdtarifa_pj,NULL)
           FROM crapcop cop
          WHERE (cop.cdcooper = pr_cdcooperalt OR pr_cdcooperalt = 0));
      
      vr_auxconta := SQL%ROWCOUNT;
    EXCEPTION
      WHEN OTHERS THEN
        
        vr_dscritic := 'Ocorreu um erro ao alterar os parametros.';
        
        -- Caso o erro for de FK n�o encontrada
        IF SQLCODE = -02291 THEN 
          
          IF UPPER(SQLERRM) LIKE '%TBGEN_SMS_PARAM_FK01%' THEN -- Verifica se � a FK de tarifa de Pessoa F�sica
             vr_dscritic := 'Tarifa para Pessoa Fisica Inexistente';
             
          ELSIF UPPER(SQLERRM) LIKE '%TBGEN_SMS_PARAM_FK02%' THEN -- Verifica se � a FK de tarifa de Pessoa Jur�dica
             vr_dscritic := 'Tarifa para Pessoa Juridica Inexistente';
          END IF;
          
        END IF;
        
        RAISE vr_exc_saida;
    END;
    
    -- Exclui as mensagens atuais
    DELETE FROM tbgen_mensagem msg
     WHERE (msg.cdcooper = pr_cdcooperalt OR pr_cdcooperalt = 0)
       AND msg.cdproduto = 10; -- D�bito Autom�tico
    
    -- Percorre as mensagens no JSON e insere os registros
    vr_json_mensagens := json_list(REPLACE(pr_json_mensagens,'&quot;','"'));
    
    FOR i IN 1..vr_json_mensagens.count
    LOOP
      
      vr_json_msg := json(vr_json_mensagens.get(i));
      vr_cdtipo_mensagem := to_number(json_ext.get_string(vr_json_msg,'cdtipo_mensagem'));
      vr_dsmensagem := json_ext.get_string(vr_json_msg,'dsmensagem');
      vr_dsmensagem:= REPLACE(REPLACE(vr_dsmensagem,chr(10),''),chr(13),'');
      BEGIN
        
        --Insere as mensagens recebidas no JSON
        INSERT INTO tbgen_mensagem msg
          (cdcooper
          ,cdproduto
          ,cdtipo_mensagem
          ,dsmensagem
          )
          (SELECT cop.cdcooper
                 ,10 -- D�bito Autom�tico
                 ,vr_cdtipo_mensagem
                 ,vr_dsmensagem
             FROM crapcop cop
            WHERE (cop.cdcooper = pr_cdcooperalt OR pr_cdcooperalt = 0));
        
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Ocorreu um erro ao alterar as mensagens.';
          RAISE vr_exc_saida;
      END;
    END LOOP;
    
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<qtdregis>' || vr_auxconta || '</qtdregis>';
    vr_retxml := vr_retxml || '</Root>';
  
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
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
    WHEN OTHERS THEN
    
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_mantem_parmda;

  PROCEDURE pc_exclui_parmda(pr_cdcooperalt IN crapcop.cdcooper%TYPE
                             
                            ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                            ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_exclui_parmda
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Maio/2015                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para excluir os par�metros de mensagem do d�bito automatico
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Variaveis auxiliares
    vr_retxml VARCHAR2(4000);
  
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    /* vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);*/
    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
  
  BEGIN
    -- N�o precisa executar pois neste processo n�o utilizamos estes dados
    /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
    ,pr_cdcooper => vr_cdcooper
    ,pr_nmdatela => vr_nmdatela
    ,pr_nmeacao  => vr_nmeacao
    ,pr_cdagenci => vr_cdagenci
    ,pr_nrdcaixa => vr_nrdcaixa
    ,pr_idorigem => vr_idorigem
    ,pr_cdoperad => vr_cdoperad
    ,pr_dscritic => vr_dscritic);*/
  
    BEGIN
      DELETE tbgen_sms_param parmda
       WHERE (parmda.cdcooper = pr_cdcooperalt OR pr_cdcooperalt = 0);
    
      vr_auxconta := SQL%ROWCOUNT;
      
      DELETE tbgen_mensagem msg
       WHERE msg.cdproduto = 10 -- D�bito Autom�tico
         AND (msg.cdcooper = pr_cdcooperalt OR pr_cdcooperalt = 0);
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Ocorreu um erro ao excluir os parametros.';
        RAISE vr_exc_saida;
    END;
  
    IF vr_auxconta = 0 THEN
      vr_dscritic := 'Nenhum registro encontrado';
      RAISE vr_exc_saida;
    END IF;
  
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<qtdregis>' || vr_auxconta || '</qtdregis>';
    vr_retxml := vr_retxml || '</Root>';
  
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
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
    WHEN OTHERS THEN
    
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_exclui_parmda;
  
  PROCEDURE pc_busca_valor_tarifa(pr_cdcooperalt IN crapcop.cdcooper%TYPE
                                 ,pr_cdtarifa    IN craptar.cdtarifa%TYPE
  
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    
    vr_cdcooperalt crapcop.cdcooper%TYPE;
    vr_vltarifa NUMBER;   --Valor tarifa
    
    -- Variaveis de log
    /*vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);*/
    vr_retxml VARCHAR2(4000);
    
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    -- N�o precisa executar pois neste processo n�o utilizamos estes dados
    /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);*/
    
    -- Se for cooperativa 0 (Todas as cooperativas), busca os dados da cooperativa 1
    vr_cdcooperalt := CASE pr_cdcooperalt WHEN 0 THEN 1 ELSE pr_cdcooperalt END;
    
    vr_vltarifa := fn_obtem_valor_tarifa(pr_cdcooper => vr_cdcooperalt --Codigo Cooperativa
                                        ,pr_cdtarifa  => pr_cdtarifa);  --Codigo Tarifa
    
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<vltarifa>' || vr_vltarifa || '</vltarifa>';
    vr_retxml := vr_retxml || '</Root>';
  
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
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
  END pc_busca_valor_tarifa;
  
END tela_parmda;
/
