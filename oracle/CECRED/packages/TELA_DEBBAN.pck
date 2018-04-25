CREATE OR REPLACE PACKAGE CECRED.TELA_DEBBAN IS

  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_DEBBAN
  --  Sistema  : Rotinas utilizadas pela Tela DEBBAN
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Janeiro - 2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela DEBBAN
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  
  
  ------------------------------------ ROTINAS ------------------------------
  --> Rotina para retornar os agendamentos de debito do bancoob
  PROCEDURE pc_ret_agendeb_bancoob_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdcoptel IN crapcop.cdcooper%TYPE --> Codigo da cooperativa selecionada
                           ,pr_dtmvtopg IN VARCHAR2              --> data de movimento para o pagamento
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                           
  -->  Procedimento para sumarizar os agendamentos da debban 
  PROCEDURE pc_sumario_debban(pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                             ,pr_qtefetiv OUT NUMBER                     --> qtd de lancamentos efetuados
                             ,pr_qtnefeti OUT NUMBER                     --> Qtd de lancamentos nao efetuados
                             ,pr_qtpended OUT NUMBER                     --> Qtd de lancamentos pendentes
                             ,pr_qtdtotal OUT NUMBER                     --> Qtd de total de lancamentos
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE);    --> Descricao critica                                      
                             
  --> Rotina para retornar os dados de lançamento de agendamento de debito bancoob sumarizados
  PROCEDURE pc_sumario_bancoob_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdcoptel IN crapcop.cdcooper%TYPE --> Codigo da cooperativa selecionada
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                           
  
  --> Rotina para processar os agendamentos de debito do bancoob
  PROCEDURE pc_proces_agendeb_bancoob_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdcoptel IN crapcop.cdcooper%TYPE --> Codigo da cooperativa selecionada
                           ,pr_dtmvtopg IN VARCHAR2              --> data de movimento para o pagamento
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                                      
                                                                                              
END TELA_DEBBAN;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_DEBBAN IS
  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_DEBBAN
  --  Sistema  : Rotinas utilizadas pela Tela DEBBAN
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Janeiro - 2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela DEBBAN
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/
  
  --> Rotina para retornar os agendamentos de debito do bancoob
  PROCEDURE pc_ret_agendeb_bancoob_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdcoptel IN crapcop.cdcooper%TYPE --> Codigo da cooperativa selecionada
                           ,pr_dtmvtopg IN VARCHAR2              --> data de movimento para o pagamento
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_ret_agendeb_bancoob_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Janeiro/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para retornar os agendamentos de debito do bancoob

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      --> Buscar dado da cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE )IS
        SELECT cop.cdcooper,
               cop.nmrescop,
               dat.inproces
          FROM crapcop cop,
               crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) 
           AND cop.flgativo = 1
           AND cop.cdcooper <> 3;            
           
      --> Verificar se existe coop em processo
      CURSOR cr_crapdat_inproces (pr_cdcooper IN crapcop.cdcooper%TYPE )IS
        SELECT dat.inproces
          FROM crapcop cop,
               crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) 
           AND cop.flgativo = 1
           AND cop.cdcooper <> 3
           AND dat.inproces > 1;            
      rw_crapdat_inproces cr_crapdat_inproces%ROWTYPE;
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_dtmvtopg DATE;
      
      vr_tab_agendamentos paga0003.typ_tab_agend_bancoob;
      vr_idx              VARCHAR2(100);
      
      TYPE typ_tab_agen_todos IS TABLE OF paga0003.typ_reg_agend_bancoob
        INDEX BY PLS_INTEGER; 
      vr_tab_agen_todos   typ_tab_agen_todos;
      
      
      
      --> variaveis auxiliares      
      vr_retxml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_retxml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;

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
        RAISE vr_exc_erro;
      END IF;
      
      --> Verificar se existe coop em processo
      OPEN cr_crapdat_inproces (pr_cdcooper => pr_cdcoptel);
      FETCH cr_crapdat_inproces INTO rw_crapdat_inproces;
      IF cr_crapdat_inproces%FOUND THEN
        vr_dscritic := 'Atenção: Processo noturno das singulares não finalizado.';
        RAISE vr_exc_erro;
      END IF;
      
      
      vr_dtmvtopg := to_date(pr_dtmvtopg,'DD/MM/RRRR');
      
      -- Listar cooperativas
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcoptel) LOOP
      
        --> Buscar agendamentos da cooperativa
        paga0003.pc_obtem_agendeb_bancoob( pr_cdcooper => rw_crapcop.cdcooper, 
                                           pr_nmrescop => rw_crapcop.nmrescop, 
                                           pr_dtmvtopg => vr_dtmvtopg, 
                                           pr_inproces => rw_crapcop.inproces, 
                                           pr_tab_agend_bancoob => vr_tab_agendamentos, 
                                           pr_cdcritic => vr_cdcritic, 
                                           pr_dscritic => vr_dscritic);
        
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
           
        END IF;   
        
        IF vr_tab_agendamentos.count() > 0 THEN 
          --> Agrupar agendamento de debitos de todas as coops,
          vr_idx := vr_tab_agendamentos.first;
          WHILE vr_idx IS NOT NULL LOOP
        
            vr_tab_agen_todos(vr_tab_agen_todos.count) := vr_tab_agendamentos(vr_idx); 
        
            vr_idx := vr_tab_agendamentos.next(vr_idx);
          END LOOP;
        
        END IF;
      
      END LOOP;     
      
      IF vr_tab_agen_todos.count() = 0 THEN
        vr_dscritic := 'Nao foram encontrados agendamentos pendentes.';
        RAISE vr_exc_erro;
      END IF;                                  
      
      -- Inicializar o CLOB
      vr_retxml := null;
      dbms_lob.createtemporary(vr_retxml, true);
      dbms_lob.open(vr_retxml, dbms_lob.lob_readwrite);      
      -- Inicilizar as informações do XML
      vr_texto_completo := null;     
      
      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<root><Dados>');
                   
      FOR idx IN vr_tab_agen_todos.first..vr_tab_agen_todos.last LOOP             
        pc_escreve_xml('<debito>'||                           
                           '<cdcooper>'|| vr_tab_agen_todos(idx).cdcooper  ||'</cdcooper>'  ||
                           '<dscooper>'|| vr_tab_agen_todos(idx).dscooper  ||'</dscooper>'  ||
                           '<cdagenci>'|| vr_tab_agen_todos(idx).cdagenci  ||'</cdagenci>'  ||
                           '<nrdconta>'|| gene0002.fn_mask_conta(vr_tab_agen_todos(idx).nrdconta)  ||'</nrdconta>'  ||
                           '<nmprimtl>'|| vr_tab_agen_todos(idx).nmprimtl  ||'</nmprimtl>'  ||
                           '<cdtiptra>'|| vr_tab_agen_todos(idx).cdtiptra  ||'</cdtiptra>'  ||
                           '<fltiptra>'|| (CASE vr_tab_agen_todos(idx).fltiptra WHEN TRUE THEN 1 ELSE 0 END)  ||'</fltiptra>'  ||
                           '<dstiptra>'|| vr_tab_agen_todos(idx).dstiptra  ||'</dstiptra>'  ||
                           '<fltipdoc>'|| vr_tab_agen_todos(idx).fltipdoc  ||'</fltipdoc>'  ||
                           '<dstransa>'|| vr_tab_agen_todos(idx).dstransa  ||'</dstransa>'  ||
                           '<vllanaut>'|| vr_tab_agen_todos(idx).vllanaut  ||'</vllanaut>'  ||
                           '<dttransa>'|| to_char(vr_tab_agen_todos(idx).dttransa,'DD/MM/RRRR')  ||'</dttransa>'  ||
                           '<hrtransa>'|| gene0002.fn_converte_time_data(pr_nrsegs   => vr_tab_agen_todos(idx).hrtransa,
                                                                         pr_tipsaida => 'S')  ||'</hrtransa>'  ||
                           '<nrdocmto>'|| vr_tab_agen_todos(idx).nrdocmto  ||'</nrdocmto>'  ||
                           '<dslindig>'|| vr_tab_agen_todos(idx).dslindig  ||'</dslindig>'  ||
                           '<dscritic>'|| vr_tab_agen_todos(idx).dscritic  ||'</dscritic>'  ||
                           '<fldebito>'|| vr_tab_agen_todos(idx).fldebito  ||'</fldebito>'  ||
                           '<dsorigem>'|| vr_tab_agen_todos(idx).dsorigem  ||'</dsorigem>'  ||
                           '<idseqttl>'|| vr_tab_agen_todos(idx).idseqttl  ||'</idseqttl>'  ||
                           '<nrseqagp>'|| vr_tab_agen_todos(idx).nrseqagp  ||'</nrseqagp>'  ||
                           '<dtmvtolt>'|| vr_tab_agen_todos(idx).dtmvtolt  ||'</dtmvtolt>'  ||
                           '<dshistor>'|| vr_tab_agen_todos(idx).dshistor  ||'</dshistor>'  ||
                           '<dtagenda>'|| vr_tab_agen_todos(idx).dtagenda  ||'</dtagenda>'  ||
                           '<dsdebito>'|| vr_tab_agen_todos(idx).dsdebito  ||'</dsdebito>'  ||                       
                       '</debito>');
      
      END LOOP;
      
      pc_escreve_xml('</Dados></root>',TRUE);
      pr_retxml := xmltype.createxml(vr_retxml);        
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_retxml);
      dbms_lob.freetemporary(vr_retxml);
      
       
  EXCEPTION
    WHEN vr_exc_erro THEN

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
  END pc_ret_agendeb_bancoob_web;
  
  -->  Procedimento para sumarizar os agendamentos da debban 
  PROCEDURE pc_sumario_debban(pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Codigo da cooperativa
                             ,pr_qtefetiv OUT NUMBER                     --> qtd de lancamentos efetuados
                             ,pr_qtnefeti OUT NUMBER                     --> Qtd de lancamentos nao efetuados
                             ,pr_qtpended OUT NUMBER                     --> Qtd de lancamentos pendentes
                             ,pr_qtdtotal OUT NUMBER                     --> Qtd de total de lancamentos
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Descricao critica                                      
     
  /* ..........................................................................
    
      Programa : pc_sumario_debsic    
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana - AMcom
      Data     : Janeiro/2018.                   Ultima atualizacao: 00/00/0000
    
      Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
       Objetivo  : Procedure utilizada sumarizar os agendamentos DEBBAN
    
       Alteração : 
    
     ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    
    --> Verifica o Lancamento agendados
    CURSOR cr_craplau(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_insitlau craplau.insitlau%TYPE
                     ,pr_dtmvtopg crapdat.dtmvtolt%TYPE) IS
        SELECT  craplau.*
          FROM  craplau, 
                craphis
          WHERE craplau.cdcooper = craphis.cdcooper
            AND craplau.cdhistor = craphis.cdhistor
            AND craplau.cdcooper = pr_cdcooper             
            AND craplau.insitlau = pr_insitlau
            AND craplau.tpdvalor = 2
            AND craplau.dtmvtopg = pr_dtmvtopg;
                         
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    CURSOR cr_crapcop1(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = DECODE(pr_cdcooper, 3, cop.cdcooper, pr_cdcooper)
         AND cop.cdcooper <> 3;
    rw_crapcop1 cr_crapcop1%ROWTYPE;   
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    ---------------> VARIAVEIS <-----------------
    vr_cdcooper     crapcop.cdcooper%TYPE;
    vr_qtefetivados DECIMAL(11)  := 0;
    vr_qtdpendentes DECIMAL(11)  := 0;
    vr_qtnaoefetiva DECIMAL(11) := 0;
    vr_insitlau craplau.insitlau%TYPE;
    
    
    --Variaveis de erro    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);    
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    
  BEGIN

    --Inicializar variaveis
    pr_qtefetiv := 0;
    pr_qtnefeti := 0; 
    pr_qtpended := 0; 
    pr_qtdtotal := 0;
    
    IF pr_cdcooper = 0 THEN
       vr_cdcooper := 3;
    ELSE
       vr_cdcooper := pr_cdcooper;   
    END IF;
    
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
      
    IF cr_crapcop%NOTFOUND THEN
       CLOSE cr_crapcop;         
       RAISE vr_exc_erro;
    END IF;
      
    CLOSE cr_crapcop;
          
    FOR rw_crapcop1 IN cr_crapcop1(pr_cdcooper => vr_cdcooper)  LOOP
    
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      END IF;
        
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      
      FOR vr_insitlau IN 1..4 LOOP

        --SOMAR OS LANCAMENTOS PARA ESCREVER DEPOIS NO XML
        FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapcop1.cdcooper
                                    ,pr_insitlau => vr_insitlau
                                    ,pr_dtmvtopg => rw_crapdat.dtmvtolt) LOOP

          CASE rw_craplau.insitlau

             WHEN 1 THEN vr_qtdpendentes := vr_qtdpendentes + 1; 
             WHEN 2 THEN vr_qtefetivados := vr_qtefetivados + 1;
             ELSE vr_qtnaoefetiva := vr_qtnaoefetiva + 1; 

          END CASE;
                                        
        END LOOP;

      END LOOP;
          
    END LOOP;
      
    pr_qtefetiv := vr_qtefetivados;
    pr_qtnefeti := vr_qtnaoefetiva;
    pr_qtpended := vr_qtdpendentes;
    pr_qtdtotal := vr_qtefetivados + vr_qtnaoefetiva + vr_qtdpendentes;
                                                     
  EXCEPTION
     WHEN vr_exc_erro THEN      
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao sumarizar agendamentos: '||SQLERRM;  
  END pc_sumario_debban;


  --> Rotina para retornar os dados de lançamento de agendamento de debito bancoob sumarizados
  PROCEDURE pc_sumario_bancoob_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdcoptel IN crapcop.cdcooper%TYPE --> Codigo da cooperativa selecionada
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_sumario_bancoob_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Janeiro/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para retornar os dados de lançamento de agendamento de debito bancoob sumarizados

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      
      
      
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_qtefetiv NUMBER := 0;
      vr_qtnefeti NUMBER := 0;
      vr_qtpended NUMBER := 0;
      vr_qtdtotal NUMBER := 0;
      
      --> variaveis auxiliares      
      vr_retxml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_retxml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;

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
        RAISE vr_exc_erro;
      END IF;
      
      -->  Procedimento para sumarizar os agendamentos da debban 
      pc_sumario_debban ( pr_cdcooper => pr_cdcoptel        --> Codigo da cooperativa
                         ,pr_qtefetiv => vr_qtefetiv        --> qtd de lancamentos efetuados
                         ,pr_qtnefeti => vr_qtnefeti        --> Qtd de lancamentos nao efetuados
                         ,pr_qtpended => vr_qtpended        --> Qtd de lancamentos pendentes
                         ,pr_qtdtotal => vr_qtdtotal        --> Qtd de total de lancamentos
                         ,pr_cdcritic => vr_cdcritic        --> Codigo da critica
                         ,pr_dscritic => vr_dscritic);      --> Descricao critica                                      
      
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
      
        RAISE vr_exc_erro;   
      END IF;   
      
      
      -- Inicializar o CLOB
      vr_retxml := null;
      dbms_lob.createtemporary(vr_retxml, true);
      dbms_lob.open(vr_retxml, dbms_lob.lob_readwrite);      
      -- Inicilizar as informações do XML
      vr_texto_completo := null;    
      
      
      -- Insere o cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');
  
      
      pc_escreve_xml('<qtefetivados>' || NVL(vr_qtefetiv,0) || '</qtefetivados>'||
                     '<qtnaoefetiva>' || NVL(vr_qtnefeti,0) || '</qtnaoefetiva>'||
                     '<qtdpendentes>' || NVL(vr_qtpended,0) || '</qtdpendentes>'||
                     '<qtdtotallanc>' || NVL(vr_qtdtotal,0) || '</qtdtotallanc>');

      -- Encerrar a tag raiz
      pc_escreve_xml('</raiz>', TRUE);
      pr_retxml := xmltype.createxml(vr_retxml);     
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_retxml);
      dbms_lob.freetemporary(vr_retxml);   
      

  EXCEPTION
    WHEN vr_exc_erro THEN

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
  END pc_sumario_bancoob_web;

  --> Rotina para processar os agendamentos de debito do bancoob
  PROCEDURE pc_proces_agendeb_bancoob
                           (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa selecionada
                           ,pr_dtmvtopg IN DATE                  --> data de movimento para o pagamento
                           ,pr_dsmensag OUT VARCHAR2             --> Retorna mensagens de erros de cada cooperativa
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ) IS
    /* .............................................................................

        Programa: pc_proces_agendeb_bancoob
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Janeiro/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para processar os agendamentos de debito do bancoob

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
    ---------->> CURSORES <<--------
    --> Verificar se existe coop em processo
    CURSOR cr_crapdat_inproces (pr_cdcooper IN crapcop.cdcooper%TYPE )IS
      SELECT dat.inproces
        FROM crapcop cop,
             crapdat dat
       WHERE cop.cdcooper = dat.cdcooper
         AND cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) 
         AND cop.flgativo = 1
         AND cop.cdcooper <> 3
         AND dat.inproces > 1;            
    rw_crapdat_inproces cr_crapdat_inproces%ROWTYPE;
      
    --> Buscar dado da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE )IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             dat.inproces
        FROM crapcop cop,
             crapdat dat
       WHERE cop.cdcooper = dat.cdcooper
         AND cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) 
         AND cop.flgativo = 1
         AND cop.cdcooper <> 3;            
      
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    vr_cdprogra VARCHAR2(80) := 'DEBBAN';
    vr_tempo    NUMBER;
    vr_dsmensag VARCHAR2(4000);
      
    --> LOG de execuaco dos programas prcctl
    PROCEDURE pc_gera_log_execucao(pr_nmprgexe  IN VARCHAR2,
                                   pr_indexecu  IN VARCHAR2,
                                   pr_cdcooper  IN INTEGER, 
                                   pr_tpexecuc  IN VARCHAR2,
                                   pr_idtiplog  IN VARCHAR2, -- I - inicio, E - erro ou F - Fim
                                   pr_dtmvtolt  IN DATE) IS
      vr_nmarqlog VARCHAR2(500);
      vr_desdolog VARCHAR2(2000);
    BEGIN    
      
      --> Definir nome do log
      vr_nmarqlog := 'prcctl_'||to_char(pr_dtmvtolt,'RRRRMMDD')||'.log';
      --> Definir descrição do log
      vr_desdolog := 'Manual - '||to_char(SYSDATE,'HH24:MI:SS')||
                     ' --> Coop.:'|| pr_cdcooper ||' '|| 
                     pr_tpexecuc ||' - '||pr_nmprgexe|| ': '|| pr_indexecu;
      
        
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => vr_desdolog, 
                                 pr_nmarqlog     => vr_nmarqlog,
                                 pr_cdprograma   => pr_nmprgexe);
      
                                
      -- Incluir log no proc_batch.log
      IF pr_idtiplog = 'I' THEN --> Inicio
        -- inicializar o tempo
        vr_tempo := to_char(SYSDATE,'SSSSS'); 
        
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> Inicio da execucao.';
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog,
                                   pr_dstiplog     => 'I',
                                   pr_cdprograma   => pr_nmprgexe); 
                                   
      ELSIF pr_idtiplog = 'E' THEN --> ERRO             
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> ERRO:'||pr_indexecu;
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog,
                                   pr_dstiplog     => 'E',
                                   pr_cdprograma   => pr_nmprgexe);
                                   
      ELSIF pr_idtiplog = 'F' THEN --> Fim         
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> Stored Procedure rodou em '|| 
                       -- calcular tempo de execução
                       to_char(to_date(to_char(SYSDATE,'SSSSS') - vr_tempo,'SSSSS'),'HH24:MI:SS');
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog,                                   
                                   pr_dstiplog     => 'F',
                                   pr_cdprograma   => pr_nmprgexe); 
      END IF; 
                                                                           
    END pc_gera_log_execucao;
    
  BEGIN

    --> Verificar se existe coop em processo
    OPEN cr_crapdat_inproces (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapdat_inproces INTO rw_crapdat_inproces;
    IF cr_crapdat_inproces%FOUND THEN
      vr_dscritic := 'Atenção: Processo noturno das singulares não finalizado.';
      RAISE vr_exc_erro;
    END IF;
    
    vr_dsmensag := NULL;
        
    -- Listar cooperativas
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP
      BEGIN
        -- Verifica se a data esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se não encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          CLOSE BTCH0001.cr_crapdat;
          RAISE vr_exc_erro;
        END IF;
          
        -- fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        
        -- Log de inicio de execucao
        pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                             pr_indexecu  => 'Inicio execucao',
                             pr_cdcooper  => rw_crapcop.cdcooper, 
                             pr_tpexecuc  => NULL,
                             pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                             pr_idtiplog  => 'I');  
      
        
        --> Procedimento para processar os debitos agendados de pagamento bancoob
        paga0003.pc_processa_agend_bancoob ( pr_cdcooper => rw_crapcop.cdcooper   --> Código da cooperativa
                                            ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                                            ,pr_dscritic => vr_dscritic);   --> descrição da critica
      
          
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN                                
          RAISE vr_exc_erro;              
        END IF;   
            
        --> Log de fim de execucao
        pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                             pr_indexecu  => 'Fim execucao',
                             pr_cdcooper  => rw_crapcop.cdcooper, 
                             pr_tpexecuc  => NULL,
                             pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                             pr_idtiplog  => 'F');
      
        COMMIT;
      EXCEPTION
        --> Gerar log e alimentar variavel de mensagem e ir para a proxima coop
        WHEN vr_exc_erro THEN
          ROLLBACK;
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                             pr_indexecu  => 'Fim execucao com critica: '||vr_dscritic ,
                             pr_cdcooper  => rw_crapcop.cdcooper, 
                             pr_tpexecuc  => NULL,
                             pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                             pr_idtiplog  => 'E');
                                
         
          IF vr_dsmensag IS NOT NULL THEN
            vr_dsmensag := vr_dsmensag ||chr(13);
          END IF;
          
          vr_dsmensag := 'Cooperativa '||rw_crapcop.cdcooper ||' - '|| rw_crapcop.nmrescop ||' -> '||
                         vr_dscritic; 
          vr_dscritic := NULL;
          vr_cdcritic := 0;
        --> Gerar log eabortar programa
        WHEN OTHERS THEN
          ROLLBACK;
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                             pr_indexecu  => 'Fim execucao com critica: '||vr_dscritic ,
                             pr_cdcooper  => rw_crapcop.cdcooper, 
                             pr_tpexecuc  => NULL,
                             pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                             pr_idtiplog  => 'E');
                                
          RAISE vr_exc_erro;              
          
      END;
    END LOOP;  
    
    pr_dsmensag := vr_dsmensag;
      
  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 AND 
         vr_dscritic  IS NULL THEN        
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
        
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;


      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina pc_proces_agendeb_bancoob: ' || SQLERRM;
      ROLLBACK;
  END pc_proces_agendeb_bancoob;
  

  --> Rotina para processar os agendamentos de debito do bancoob
  PROCEDURE pc_proces_agendeb_bancoob_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdcoptel IN crapcop.cdcooper%TYPE --> Codigo da cooperativa selecionada
                           ,pr_dtmvtopg IN VARCHAR2              --> data de movimento para o pagamento
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_proces_agendeb_bancoob_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Janeiro/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para processar os agendamentos de debito do bancoob

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      --> Verificar se existe coop em processo
      CURSOR cr_crapdat_inproces (pr_cdcooper IN crapcop.cdcooper%TYPE )IS
        SELECT dat.inproces
          FROM crapcop cop,
               crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) 
           AND cop.flgativo = 1
           AND cop.cdcooper <> 3
           AND dat.inproces > 1;            
      rw_crapdat_inproces cr_crapdat_inproces%ROWTYPE;
      
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_dtmvtopg DATE;
      vr_dsmensag VARCHAR2(500);      
      vr_retxml   CLOB;  
      

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
        RAISE vr_exc_erro;
      END IF;
      
      --> Verificar se existe coop em processo
      OPEN cr_crapdat_inproces (pr_cdcooper => pr_cdcoptel);
      FETCH cr_crapdat_inproces INTO rw_crapdat_inproces;
      IF cr_crapdat_inproces%FOUND THEN
        vr_dscritic := 'Atenção: Processo noturno das singulares não finalizado.';
        RAISE vr_exc_erro;
      END IF;
      
      vr_dtmvtopg := to_date(pr_dtmvtopg,'DD/MM/RRRR');
      
      
      --> processar os agendamentos de debito do bancoob
      pc_proces_agendeb_bancoob ( pr_cdcooper => pr_cdcoptel   --> Codigo da cooperativa selecionada
                                 ,pr_dtmvtopg => vr_dtmvtopg   --> data de movimento para o pagamento
                                 ,pr_dsmensag => vr_dsmensag   --> Retorna mensagens de erros de cada cooperativa
                                 ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                 ,pr_dscritic => vr_dscritic); --> Descrição da crítica
  
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN      
        RAISE vr_exc_erro;   
      END IF;
      
      IF vr_dsmensag IS NOT NULL THEN
        vr_dsmensag := 'Processo concluido com criticas, visualize criticas na tela PRCCTL.';
      ELSE
        vr_dsmensag := 'Processo concluido com sucesso.';
      END IF;
      
      vr_dsmensag := replace(vr_dsmensag,chr(13),'<br>');
      -- Inicializar o CLOB
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                   '<root><Dados>'|| 
                     '<dsmensag><![CDATA['|| vr_dsmensag ||']]></dsmensag>'||
                   '</Dados></root>';
      
      pr_retxml := xmltype.createxml(vr_retxml);        
      
      
       
  EXCEPTION
    WHEN vr_exc_erro THEN

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
  END pc_proces_agendeb_bancoob_web;
                                   
  
END TELA_DEBBAN;
/
