CREATE OR REPLACE PACKAGE CECRED.ESTE0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0001
      Sistema  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Mar�o/2016.                   Ultima atualizacao: 08/03/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                  pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                            
                                  pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operado
                                  pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                  pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                  pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                  pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                  ---- OUT ----
                                  pr_proposta OUT JSON,                   --> Retorno do clob em modelo json da proposta de emprestimo
                                  pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                  pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                  
  --> Procedimento para verificar se deve permitir o envio de email para o comite
  PROCEDURE pc_verifica_email_comite (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                      ---- OUT ----                                        
                                      pr_flgenvio OUT NUMBER,                 --> Retorno de deve permitir email de email (0-nao 1-sim)
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica

  --> Procedimento para verificar se deve permitir o envio de email para o comite versao web mensageria
  PROCEDURE pc_verifica_email_comite_web ( pr_nrdconta IN  VARCHAR2              -- Numero da conta do cooperado
                                          ,pr_nrctremp IN  craphis.cdhistor%TYPE -- Numero da proposta de emprestimo                                        
                                          ,pr_xmllog   IN  VARCHAR2              -- XML com informa��es de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           -- C�digo da cr�tica
                                          ,pr_dscritic OUT VARCHAR2              -- Descri��o da cr�tica
                                          ,pr_retxml   IN  OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);            -- Erros do processo
                                          
  PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                        pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                        pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                        ---- OUT ----                                        
                                        pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                        
  --> Rotina para alterar o numero da proposta no acionamento
  PROCEDURE pc_alter_nrctrprp_aciona( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                      
  --> Extrair a descricao de critica do jsson de retorno
  FUNCTION fn_retorna_critica (pr_jsonreto IN VARCHAR2) RETURN VARCHAR2;
   
  --> Rotina responsavel por gravar registro de log de acionamento
  PROCEDURE pc_grava_acionamento(pr_cdcooper                 IN tbepr_acionamento.cdcooper%TYPE, 
                                 pr_cdagenci                 IN tbepr_acionamento.cdagenci_acionamento%TYPE,
                                 pr_cdoperad                 IN tbepr_acionamento.cdoperad%TYPE, 
                                 pr_cdorigem                 IN tbepr_acionamento.cdorigem%TYPE, 
                                 pr_nrctrprp                 IN tbepr_acionamento.nrctrprp%TYPE, 
                                 pr_nrdconta                 IN tbepr_acionamento.nrdconta%TYPE, 
                                 pr_tpacionamento            IN tbepr_acionamento.tpacionamento%TYPE, 
                                 pr_dsoperacao               IN tbepr_acionamento.dsoperacao%TYPE, 
                                 pr_dsuriservico             IN tbepr_acionamento.dsuriservico%TYPE, 
                                 pr_dtmvtolt                 IN tbepr_acionamento.dtmvtolt%TYPE, 
                                 pr_cdstatus_http            IN tbepr_acionamento.cdstatus_http%TYPE, 
                                 pr_dsconteudo_requisicao    IN tbepr_acionamento.dsconteudo_requisicao%TYPE,
                                 pr_dsresposta_requisicao    IN tbepr_acionamento.dsresposta_requisicao%TYPE,
                                 pr_idacionamento           OUT tbepr_acionamento.idacionamento%TYPE,
                                 pr_dscritic                OUT VARCHAR2);
                                 
  -- Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_esteira ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctremp    IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_tpenvest    IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                                pr_dscritic   OUT VARCHAR2 );
                                
  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est (pr_cdcooper  IN crawepr.cdcooper%TYPE,
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,
                                      pr_cdorigem  IN INTEGER,
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,
                                      pr_nmarquiv  IN VARCHAR2,
                                      ---- OUT ----
                                      pr_cdcritic OUT NUMBER,
                                      pr_dscritic OUT VARCHAR2);

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  PROCEDURE pc_alterar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                    pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                    pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                    pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                    pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                    pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                    pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                    pr_flreiflx  IN INTEGER,                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                                    pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                    ---- OUT ----                           
                                    pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                    pr_dscritic OUT VARCHAR2);              --> Descricao da critica                                      
  
   --> Rotina responsavel por gerar a alteracao do numero da proposta para a esteira
  PROCEDURE pc_alter_numproposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica
  
 
  --> Rotina responsavel por gerar o cancelamento da proposta para a esteira
  PROCEDURE pc_cancelar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica 
                                      
  --> Rotina responsavel por gerar efetivacao da proposta para a esteira
  PROCEDURE pc_efetivar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica                                      
  
  --> Rotina responsavel por consultar informa��es da proposta na esteira
  PROCEDURE pc_consultar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,    --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,    --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,    --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                  --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,    --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,    --> Numero da proposta de emprestimo atual/antigo                          
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,    --> Data do movimento                                      
                                      ---- OUT ----                             
                                      pr_cdsitest OUT NUMBER,                   --> Retorna situacao da proposta
                                      pr_cdstatan OUT NUMBER,                   --> Retornoa status da proposta
                                      pr_cdcritic OUT NUMBER,                   --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);                --> Descricao da critica.                                    
END ESTE0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ESTE0001 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0001
      Sistema  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Mar�o/2016.                   Ultima atualizacao: 08/03/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  --> Funcao para formatar o numero em decimal conforme padrao da IBRATAN
  FUNCTION fn_decimal_ibra (pr_numero IN number) RETURN NUMBER IS --RETURN VARCHAR2 is
  BEGIN
    RETURN  pr_numero; 
    -- Desabilitado mascara para incrementar no Json o campo no padrao numeroco sem aspas
    -- pois o json incrementa conforme a tipagem da variavel
    -- to_char(pr_numero,'99999990D00','NLS_NUMERIC_CHARACTERS=''.,''');  
  END fn_decimal_ibra;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD"T"HH24:MI:SS".000Z"');
  END fn_DataTempo_ibra;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_Data_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD');
  END fn_Data_ibra;
  
  --> Procedimento para verificar se deve permitir o envio de email para o comite
  PROCEDURE pc_verifica_email_comite (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                      ---- OUT ----                                        
                                      pr_flgenvio OUT NUMBER,                 --> Retorno de deve permitir email de email (0-nao 1-sim)
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_verifica_email_comite        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Mar�o/2016.                   Ultima atualizacao: 14/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar se deve permitir o envio de email para o comite
    
    Altera��o : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------        
    vr_flgenvio     VARCHAR2(500);
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
  BEGIN
  
    --> Verificar se a Esteira esta em contigencia para a cooperativa
    vr_flgenvio := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                              pr_cdcooper => pr_cdcooper, 
                                              pr_cdacesso => 'ENVIA_EMAIL_COMITE');
    pr_flgenvio  := nvl(vr_flgenvio,0);     
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel verificar parametro ENVIA_EMAIL_COMITE: '||SQLERRM;
  END pc_verifica_email_comite;
  
  --> Procedimento para verificar se deve permitir o envio de email para o comite versao web mensageria
  PROCEDURE pc_verifica_email_comite_web ( pr_nrdconta IN  VARCHAR2                    -- Numero da conta do cooperado
                                          ,pr_nrctremp IN  craphis.cdhistor%TYPE       -- Numero da proposta de emprestimo                                        
                                          ,pr_xmllog   IN  VARCHAR2                    -- XML com informa��es de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                 -- C�digo da cr�tica
                                          ,pr_dscritic OUT VARCHAR2                    -- Descri��o da cr�tica
                                          ,pr_retxml   IN  OUT NOCOPY XMLType          -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                    -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS                -- Erros do processo
  /* ..........................................................................
    
    Programa : pc_verifica_email_comite        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Mar�o/2016.                   Ultima atualizacao: 14/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar se deve permitir o envio de email para o comite
                versao para ser utilizada no ayllos-web via mensageria
    
    Altera��o : 
        
  ..........................................................................*/
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000)       := NULL;

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
    
    vr_flgenvio NUMBER;
    
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
      RAISE vr_exc_erro;
    END IF;
    
    pc_verifica_email_comite (pr_cdcooper  => vr_cdcooper,  --> Codigo da cooperativa                                        
                              pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                              pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo                                        
                              ---- OUT ----                                        
                              pr_flgenvio  => vr_flgenvio,  --> Retorno de deve permitir email de email (0-nao 1-sim)
                              pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                              pr_dscritic  => vr_dscritic); --> Descricao da critica
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;   
    
    -- Retorna OK para cadastro efetuado com sucesso
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><flmail_comite>'|| vr_flgenvio || '</flmail_comite></Root>');   

    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel verificar parametro ENVIA_EMAIL_COMITE: '||SQLERRM;
  END pc_verifica_email_comite_web;
  
  
  
  PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                        pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                        pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                        ---- OUT ----                                        
                                        pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_verifica_regras_esteira        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Mar�o/2016.                   Ultima atualizacao: 09/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar as regras da esteira 
    
    Altera��o : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.insitest
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    vr_contige_este VARCHAR2(500);
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
  BEGIN
  
    --> Verificar se a Esteira esta em contigencia para a cooperativa
    vr_contige_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                  pr_cdcooper => pr_cdcooper, 
                                                  pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA');
    IF vr_contige_este IS NULL THEN
      vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_IBRA n�o encontrado.';
      RAISE vr_exc_erro;      
    END IF;
    
    IF vr_contige_este = '1' THEN
      vr_dscritic := 'Aten��o! A aprova��o da proposta deve ser feita pela tela CMAPRV.';
      RAISE vr_exc_erro;      
    END IF; 
    
    IF nvl(pr_tpenvest,' ') IN ('I','A') THEN    
      --> Buscar dados da proposta
      OPEN cr_crawepr (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
        RAISE vr_exc_erro;  
      
      END IF;
      
      IF rw_crawepr.insitest <> 0 THEN
        vr_dscritic := 'A proposta n�o pode ser enviada para esteira de cr�dito, verifique a situa��o da proposta.';
        RAISE vr_exc_erro;      
      END IF; 
    END IF;
    
  
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel verificar regras da esteira: '||SQLERRM;
  END pc_verifica_regras_esteira;
  
  PROCEDURE pc_carrega_param_ibra(pr_cdcooper       IN crapcop.cdcooper%TYPE,  -- Codigo da cooperativa
                                  pr_nrdconta       IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                  pr_nrctremp       IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                  pr_tpenvest       IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                  pr_host_esteira  OUT VARCHAR2,               -- Host da esteira
                                  pr_recurso_este  OUT VARCHAR2,               -- URI da esteira
                                  pr_contige_este  OUT VARCHAR2,               -- Verificar se esta em contigencia
                                  pr_dsdirlog      OUT VARCHAR2,               -- Diretorio de log dos arquivos 
                                  pr_chave_este    OUT VARCHAR2,               -- Chave de acesso
                                  pr_dscritic      OUT VARCHAR2) IS
  
    
  /* ..........................................................................
    
    Programa : pc_carrega_param_ibra        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Mar�o/2016.                   Ultima atualizacao: 08/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Carregar parametros para uso na comunicacao com a esteira
    
    Altera��o : 
        
  ..........................................................................*/  
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;
    
    
  BEGIN  
    
    pc_verifica_regras_esteira (pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa                                        
                                pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                                pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo                                        
                                pr_tpenvest  => pr_tpenvest,  --> Tipo de envio C - Consultar(Get)
                                ---- OUT ----                                        
                                pr_cdcritic => vr_cdcritic,                 --> Codigo da critica
                                pr_dscritic => vr_dscritic);            --> Descricao da critica
  
    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF; 
  
    --> Buscar hots so webservice da esteira
    pr_host_esteira := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                  pr_cdcooper => pr_cdcooper, 
                                                  pr_cdacesso => 'HOSWEBSRVCE_ESTEIRA_IBRA');
    IF pr_host_esteira IS NULL THEN      
      vr_dscritic := 'Parametro HOSWEBSRVCE_ESTEIRA_IBRA n�o encontrado.';
      RAISE vr_exc_erro;      
    END IF;
                                                  
    --> Buscar recurso uri da esteira
    pr_recurso_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                  pr_cdcooper => pr_cdcooper, 
                                                  pr_cdacesso => 'URIWEBSRVCE_RECURSO_IBRA');                                             
  
    IF pr_recurso_este IS NULL THEN      
      vr_dscritic := 'Parametro URIWEBSRVCE_RECURSO_IBRA n�o encontrado.';
      RAISE vr_exc_erro;      
    END IF;  
    
    --> Buscar chave de acesso da esteira
    pr_chave_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'KEYWEBSRVCE_ESTEIRA_IBRA');                                             
  
    IF pr_chave_este IS NULL THEN      
      vr_dscritic := 'Parametro KEYWEBSRVCE_ESTEIRA_IBRA n�o encontrado.';
      RAISE vr_exc_erro;      
    END IF;   
    
    --> Buscar diretorio do log
    pr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                         pr_cdcooper => 3, 
                                         pr_nmsubdir => '/log/webservices' ); 
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel buscar parametros da estira: '||SQLERRM;
  END; 
  
  --> Extrair a descricao de critica do json de retorno
  FUNCTION fn_retorna_critica (pr_jsonreto IN VARCHAR2) RETURN VARCHAR2 IS
  /* ..........................................................................
    
    Programa : fn_retorna_critica        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Maio/2016.                   Ultima atualizacao: 22/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Extrair a descricao de critica do json de retorno
    
    Altera��o : 
        
  ..........................................................................*/ 
  
    vr_obj_retorno   json := json();
    vr_obj_content   json := json();
    vr_dsretorn      VARCHAR2(32000);
    vr_auxctrl       BOOLEAN := FALSE;
    vr_exc_erro      EXCEPTION;
    vr_json          BOOLEAN;
    vr_xml           xmltype;
  BEGIN
    
    vr_dsretorn := pr_jsonreto;
    
    --> Transformar texto em objeto json
    LOOP
      BEGIN
        vr_obj_retorno := json(vr_dsretorn);
        vr_json := TRUE; --> Marcar como um json valido
        EXIT;
      EXCEPTION
        WHEN OTHERS THEN   
          --> Tentar ajustar json para tentar criar o objeto novamente
          IF vr_auxctrl = FALSE THEN  
            vr_auxctrl := TRUE;   
            vr_dsretorn := REPLACE(vr_dsretorn,'"StatusMessage"',',"StatusMessage"') ;
            vr_dsretorn := REPLACE(vr_dsretorn,'Bad Request','"Bad Request"') ;            
            vr_dsretorn := '{'||vr_dsretorn||'}';
          ELSE
            vr_json := FALSE;
            EXIT;
          END IF;
      END;
    END LOOP;  
    
    IF vr_json THEN
      --> buscar content
      IF vr_obj_retorno.exist('Content') THEN
        -- converter content em objeto
        vr_obj_content := json(vr_obj_retorno.get('Content').to_char());
        --> Extrair a critica encontrada
        RETURN replace(vr_obj_content.get('descricao').to_char(),'"');
      END IF;
    ELSE
      -- Verificar se � um xml(retorno da analise)
      BEGIN
        vr_xml := XMLType.createxml(pr_jsonreto);
        RETURN TRIM(vr_xml.extract('/Dados/inf/msg_detalhe/text()').getstringval());
      EXCEPTION
        WHEN OTHERS THEN 
          RAISE vr_exc_erro;    
      END;  
    END IF;
    
    -- Senao conseguir extrair critica retorna null
    RETURN NULL;
  
  EXCEPTION
    -- Senao conseguir extrair critica retorna null
    WHEN vr_exc_erro THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;  
  END;
  
  
  --> Rotina responsavel por gravar registro de log de acionamento
  PROCEDURE pc_grava_acionamento(pr_cdcooper                 IN tbepr_acionamento.cdcooper%TYPE, 
                                 pr_cdagenci                 IN tbepr_acionamento.cdagenci_acionamento%TYPE,
                                 pr_cdoperad                 IN tbepr_acionamento.cdoperad%TYPE, 
                                 pr_cdorigem                 IN tbepr_acionamento.cdorigem%TYPE, 
                                 pr_nrctrprp                 IN tbepr_acionamento.nrctrprp%TYPE, 
                                 pr_nrdconta                 IN tbepr_acionamento.nrdconta%TYPE, 
                                 pr_tpacionamento            IN tbepr_acionamento.tpacionamento%TYPE, 
                                 pr_dsoperacao               IN tbepr_acionamento.dsoperacao%TYPE, 
                                 pr_dsuriservico             IN tbepr_acionamento.dsuriservico%TYPE, 
                                 pr_dtmvtolt                 IN tbepr_acionamento.dtmvtolt%TYPE, 
                                 pr_cdstatus_http            IN tbepr_acionamento.cdstatus_http%TYPE, 
                                 pr_dsconteudo_requisicao    IN tbepr_acionamento.dsconteudo_requisicao%TYPE,
                                 pr_dsresposta_requisicao    IN tbepr_acionamento.dsresposta_requisicao%TYPE,
                                 pr_idacionamento           OUT tbepr_acionamento.idacionamento%TYPE,
                                 pr_dscritic                OUT VARCHAR2) IS
                                 
  /* ..........................................................................
    
    Programa : pc_grava_acionamento        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Mar�o/2016.                   Ultima atualizacao: 08/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Grava registro de log de acionamento
    
    Altera��o : 
        
  ..........................................................................*/
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO tbepr_acionamento 
                ( cdcooper, 
                  cdagenci_acionamento, 
                  cdoperad, 
                  cdorigem, 
                  nrctrprp, 
                  nrdconta, 
                  tpacionamento, 
                  dhacionamento, 
                  dsoperacao, 
                  dsuriservico, 
                  dtmvtolt, 
                  cdstatus_http, 
                  dsconteudo_requisicao,
                  dsresposta_requisicao)  
          VALUES( pr_cdcooper,        --cdcooper
                  pr_cdagenci,        -- cdagenci_acionamento, 
                  pr_cdoperad,        -- cdoperad, 
                  pr_cdorigem,        -- cdorigem
                  pr_nrctrprp,        -- nrctrprp
                  pr_nrdconta,        -- nrdconta
                  pr_tpacionamento,   -- tpacionamento 
                  SYSDATE,            -- dhacionamento
                  pr_dsoperacao,      -- dsoperacao
                  pr_dsuriservico,    -- dsuriservico
                  pr_dtmvtolt,        -- dtmvtolt
                  pr_cdstatus_http,   -- cdstatus_http
                  pr_dsconteudo_requisicao,
                  pr_dsresposta_requisicao) --dsresposta_requisicao       
           RETURNING tbepr_acionamento.idacionamento INTO pr_idacionamento;
   
    --> Commit para garantir que guarde as informa��es do log de acionamento
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao inserir tbepr_acionamento: '||SQLERRM;
      ROLLBACK;
  END pc_grava_acionamento;
  
  --> Rotina para alterar o numero da proposta no acionamento
  PROCEDURE pc_alter_nrctrprp_aciona( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_alter_nrctrprp_aciona        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2016.                   Ultima atualizacao: 14/04/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para alterar o numero da proposta no acionamento
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
  BEGIN
  
    UPDATE tbepr_acionamento aci
       SET aci.nrctrprp = pr_nrctremp_novo
     WHERE aci.cdcooper = pr_cdcooper
       AND aci.nrdconta = pr_nrdconta
       AND aci.nrctrprp = pr_nrctremp;        
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel atualizar acionamento: '||SQLERRM;  
  END;  
  
  
  --> Rotina para converter arquivo(pdf) para CLOB em base64 para ser enviado
   -- via JSON  
  PROCEDURE pc_arq_para_clob_base64(pr_nmarquiv     IN VARCHAR2,
                                    pr_clob_arquiv OUT CLOB,
                                    pr_json_value_arq OUT json_value, 
                                    pr_dscritic    OUT VARCHAR2  )IS
  
    vr_arquivo        BLOB;
    vr_json_valor     json_value;
    vr_nmdireto       VARCHAR2(4000);
    vr_nmarquiv       VARCHAR2(4000);
    vr_nomarqui       VARCHAR2(4000);
    vr_dsdircop       VARCHAR2(4000);
    
    vr_exec_erro EXCEPTION;
    vr_dscritic  VARCHAR2(4000);
    
  BEGIN
  
    -- Chamar rotina de separa��o do caminho do nome
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv
                                   ,pr_direto  => vr_nmdireto
                                   ,pr_arquivo => vr_nomarqui);  
  
    -- Verificar qual a base de execu��o
    IF gene0001.fn_database_name =
       gene0001.fn_param_sistema('CRED', 0, 'DB_NAME_PRODUC') THEN
      --> Produ��o
      vr_nmarquiv := pr_nmarquiv;
    ELSE
      --> Caso nao for produ��o, � necessario corrigir endere�o do arquivo,
      --> devido a diferen�a entre endereco progress e oracle
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                           pr_cdcooper => 0);
      IF vr_nmdireto NOT LIKE '%' || vr_dsdircop || '%' THEN
      
        vr_nmdireto := replace(vr_nmdireto, '/usr/coop/', vr_dsdircop);
        vr_nmarquiv := vr_nmdireto || '/' || vr_nomarqui;
      ELSE
        vr_nmarquiv := pr_nmarquiv;
      END IF;
    END IF;
  
    --> Verificar se existe arquivo
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmdireto || '/' ||
                                              vr_nomarqui /*vr_nmarquiv*/) =
       FALSE THEN
      vr_dscritic := 'Arquivo ' || vr_nmdireto || '/' || vr_nomarqui /*vr_nmarquiv*/
                     || ' n�o encontrado.';
      RAISE vr_exec_erro;
    END IF;
    
    /* Carrega o arquivo bin�rio a para mem�ria em uma variavel BLOB */
    vr_arquivo := gene0002.fn_arq_para_blob(vr_nmdireto, vr_nomarqui);
    /* Codifica o arquivo bin�rio da mem�ria em Base64 */
    vr_json_valor := json_ext.encode(vr_arquivo);
    pr_json_value_arq := vr_json_valor;
    /* Converte o arquivo bin�rio da mem�ria em Base 64 para Texto */
    pr_clob_arquiv := vr_json_valor.to_char();
    
    
  EXCEPTION
    WHEN vr_exec_erro THEN
      pr_dscritic := vr_dscritic;    
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi posssivel converter arquivo para CLOB: '|| SQLERRM;
      pr_clob_arquiv := NULL;
  END pc_arq_para_clob_base64;
  
  -- Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_esteira ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctremp    IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_tpenvest    IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                                pr_dscritic   OUT VARCHAR2 ) IS

    --Parametros
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_contige_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_chave_este    VARCHAR2(500);
    
    vr_dscritic      VARCHAR2(4000);
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;
    
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    
    vr_idacionamento  tbepr_acionamento.idacionamento%TYPE;
    
    
  BEGIN
    
    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                          pr_nrdconta      => pr_nrdconta,                   -- Numero da conta do cooperado
                          pr_nrctremp      => pr_nrctremp,                   -- Numero da proposta de emprestimo
                          pr_tpenvest      => pr_tpenvest,
                          pr_host_esteira  => vr_host_esteira,               -- Host da esteira
                          pr_recurso_este  => vr_recurso_este,               -- URI da esteira
                          pr_contige_este  => vr_contige_este,               -- Verificar se esta em contigencia
                          pr_dsdirlog      => vr_dsdirlog    ,               -- Diretorio de log dos arquivos 
                          pr_chave_este    => vr_chave_este  ,               -- Chave de acesso
                          pr_dscritic      => vr_dscritic    );
    
    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method := pr_dsmetodo;
    vr_request.timeout := 1000;
  --  vr_request.useproxy := TRUE;
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := 'Basic '||vr_chave_este;
        
    vr_request.content := pr_conteudo;
    
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato � o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                         pr_cdagenci              => pr_cdagenci,          
                         pr_cdoperad              => pr_cdoperad,          
                         pr_cdorigem              => pr_cdorigem,          
                         pr_nrctrprp              => pr_nrctremp,          
                         pr_nrdconta              => pr_nrdconta,          
                         pr_tpacionamento         => 1,  /* 1 - Envio, 2 � Retorno */      
                         pr_dsoperacao            => pr_dsoperacao,       
                         pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,       
                         pr_dtmvtolt              => pr_dtmvtolt,       
                         pr_cdstatus_http         => vr_response.status_code,
                         pr_dsconteudo_requisicao => pr_conteudo,
                         pr_dsresposta_requisicao => '{"Content":'||vr_response.content||
                                                     ',"StatusMessage":"'||vr_response.status_message||'"}',
                         pr_idacionamento         => vr_idacionamento,
                         pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      --> Definir mensagem de critica
      CASE 
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar proposta para Esteira.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN   
          vr_dscritic_aux := 'Nao foi possivel reenviar a proposta para a Esteira.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN   
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta.';  
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN   
          vr_dscritic_aux := 'Nao foi possivel excluir a proposta.';   
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN   
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao da proposta para a Esteira.';   
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para esteira.';  
      END CASE;    

      IF vr_response.status_code = 400 THEN
        pr_dscritic := fn_retorna_critica('{"Content":'||vr_response.content||'}');
        
        IF pr_dscritic IS NOT NULL THEN
          pr_dscritic := vr_dscritic_aux||' '||pr_dscritic;            
        ELSE
          pr_dscritic := vr_dscritic_aux;            
        END IF;
        
      ELSE  
        pr_dscritic := vr_dscritic_aux;    
      END IF;                       
      
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel enviar proposta para esteira: '||SQLERRM;  
  END pc_enviar_esteira;
  
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                  pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                            
                                  pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operado
                                  pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                  pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                  pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                  pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                  ---- OUT ----
                                  pr_proposta OUT json,                   --> Retorno do clob em modelo json da proposta de emprestimo
                                  pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                  pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
      Programa : pc_gera_json_proposta        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Mar�o/2016.                   Ultima atualizacao: 12/09/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por realizar as leituras no sistema cecred a fim
                  de montar o objeto json contendo a proposta de emprestimo
    
      Altera��o : 08/08/2016 Enviar sempre o PA de envio nas propostas de inclus�o/altera��o. (Oscar)
                  19/08/2016 Enviar 0 no parecer quando n�o existir parecer. (Oscar)

                  12/09/2016 Enviar o saldo do pre-aprovado se estiver liberado na conta
                  para ter pre-aprovado. (Oscar)
                  
                  27/02/2017 SD610862 - Enviar novas informa��es para a esteira:
                               - cooperadoColaborador: Flag se eh proposta de colaborador
                               - codigoCargo: Codigo do Cargo do Colaborador
                               - classificacaoRisco: Nivel de risco no momento da criacao
                               - renegociacao: Flag de renogocia��o ou n�o 
                               - faturamentoAnual: Faturamento dos ultimos 12 meses
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.cdagenci,
             epr.dtmvtolt,
             epr.vlemprst,
             epr.qtpreemp,
             epr.dtvencto,
             epr.vlpreemp,
             epr.hrinclus,
             epr.cdlcremp,
             lcr.dslcremp,
             epr.cdfinemp,
             fin.dsfinemp,
             lcr.tpctrato,
             epr.cdoperad,
             ope.nmoperad,
             pac.instatus,
             epr.dsnivris,
             TO_CHAR(NRCTRLIQ##1) || ',' || TO_CHAR(NRCTRLIQ##2) || ',' ||
             TO_CHAR(NRCTRLIQ##3) || ',' || TO_CHAR(NRCTRLIQ##4) || ',' ||
             TO_CHAR(NRCTRLIQ##5) || ',' || TO_CHAR(NRCTRLIQ##6) || ',' ||
             TO_CHAR(NRCTRLIQ##7) || ',' || TO_CHAR(NRCTRLIQ##8) || ',' ||
             TO_CHAR(NRCTRLIQ##9) || ',' || TO_CHAR(NRCTRLIQ##10) dsliquid,
             decode(epr.tpemprst,1,'PP','TR') tpproduto,
             -- Indica que am linha de credito eh CDC ou C DC
             DECODE(instr(replace(UPPER(lcr.dslcremp),'C DC','CDC'),'CDC'),0,0,1) inlcrcdc
        FROM crawepr epr,
             craplcr lcr,
             crapfin fin,
             crapope ope,
             crappac pac
       WHERE epr.cdcooper = lcr.cdcooper
         AND epr.cdlcremp = lcr.cdlcremp
         AND epr.cdcooper = fin.cdcooper
         AND epr.cdfinemp = fin.cdfinemp
         AND epr.cdcooper = ope.cdcooper
         AND upper(epr.cdoperad) = upper(ope.cdoperad)
         AND epr.nrseqpac = pac.nrseqpac(+)
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    --> Selecionar os associados da cooperativa por CPF/CGC
    CURSOR cr_crapass_cpfcgc(pr_cdcooper crapass.cdcooper%TYPE,
                             pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT cdcooper,
             nrdconta,
             flgcrdpa               
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrcpfcgc = pr_nrcpfcgc -- CPF/CGC passado
         AND dtelimin IS NULL;
    
    --> Buscar valor de propostas pendentes
    CURSOR cr_crawepr_pend (pr_cdcooper crawepr.cdcooper%TYPE,
                            pr_nrdconta crawepr.nrdconta%TYPE,
                            pr_nrctremp crawepr.nrctremp%TYPE) IS
      SELECT nvl(SUM(w.vlemprst),0) vlemprst
        FROM crawepr w
        JOIN craplcr l
          ON l.cdlcremp = w.cdlcremp
         AND l.cdcooper = w.cdcooper               
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.insitapr IN(1,3)        -- j� estao aprovadas
         AND w.insitest <> 4           -- Expiradas
         AND w.nrctremp <> pr_nrctremp -- desconsiderar a proposta que esta sendo enviada no momento
         AND NOT EXISTS ( SELECT 1
                            FROM crapepr p
                           WHERE w.cdcooper = p.cdcooper
                             AND w.nrdconta = p.nrdconta
                             AND w.nrctremp = p.nrctremp);
    
    rw_crawepr_pend cr_crawepr_pend%ROWTYPE;
    
    --> Selecionar o saldo disponivel do pre-aprovado da conta em quest�o  da carga ativa
    CURSOR cr_crapcpa (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE) IS
      SELECT cpa.vllimdis
            ,cpa.vlcalpre
            ,cpa.vlctrpre
        FROM crapcpa              cpa
            ,tbepr_carga_pre_aprv carga
       WHERE carga.cdcooper = pr_cdcooper
         AND carga.indsituacao_carga = 1
         AND carga.flgcarga_bloqueada = 0
         AND cpa.cdcooper = carga.cdcooper
         AND cpa.iddcarga = carga.idcarga
         AND cpa.nrdconta = pr_nrdconta;
    rw_crapcpa cr_crapcpa%ROWTYPE;            
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad,
             ope.cdoperad  
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    --> Buscar se a conta � de Colaborador Cecred
    CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS 
      SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
        FROM tbcadast_colaborador col
       WHERE col.cdcooper = pr_cdcooper
         AND col.nrcpfcgc = pr_nrcpfcgc
         AND col.flgativo = 'A';                                          
    vr_flgcolab BOOLEAN;
    vr_cddcargo tbcadast_colaborador.cdcooper%TYPE;
    
    --> Calculo do faturamento PJ
    CURSOR cr_crapjfn(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT vlrftbru##1+vlrftbru##2+vlrftbru##3+vlrftbru##4+vlrftbru##5+vlrftbru##6
            +vlrftbru##7+vlrftbru##8+vlrftbru##9+vlrftbru##10+vlrftbru##11+vlrftbru##12 vltotfat
       FROM crapjfn
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;

    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -- Objeto json da proposta
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();
    vr_obj_imagem   json := json();
    vr_json_valor   json_value;
    
    -- Variaveis auxiliares
    vr_data_aux     DATE := NULL;
    vr_dstpgara     craptab.dstextab%TYPE;
    vr_dstextab     craptab.dstextab%TYPE;
    vr_nrctremp     crawepr.nrctremp%TYPE;
    vr_inusatab     BOOLEAN;
    vr_vlutiliz     NUMBER;
    vr_clob_arquiv  CLOB;
    vr_vlprapne     NUMBER;
    vr_vllimdis     NUMBER;
    
      
  BEGIN
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se n�o encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;
    
    --> Criar objeto json para agencia da proposta
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', pr_cdagenci);    
    vr_obj_proposta.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_proposta.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_proposta.put('cooperadoContaNum',to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_proposta.put('cooperadoContaDv' ,to_number(substr(rw_crapass.nrdconta,-1)));
    
    -- apenas se nao for CDC
    IF rw_crawepr.inlcrcdc = 0 THEN
      vr_obj_proposta.put('cooperadoNome'    , rw_crapass.nmprimtl);
    END IF;
    
    vr_obj_proposta.put('cooperadoTipoPessoa', rw_crapass.inpessoa_ibra);
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;
    vr_obj_proposta.put('numero'             , rw_crawepr.nrctremp);
    vr_obj_proposta.put('valor'              , fn_decimal_ibra(rw_crawepr.vlemprst));
    vr_obj_proposta.put('parcelaQuantidade'  , rw_crawepr.qtpreemp);
    vr_obj_proposta.put('parcelaPrimeiroVencimento', fn_Data_ibra(rw_crawepr.dtvencto));
    vr_obj_proposta.put('parcelaValor'       , fn_decimal_ibra(rw_crawepr.vlpreemp));
    
    --> Data e hora da inclusao da proposta
    vr_data_aux := to_date(to_char(rw_crawepr.dtmvtolt,'DD/MM/RRRR') ||' '||
                           to_char(to_date(rw_crawepr.hrinclus,'SSSSS'),'HH24:MI:SS'),
                           'DD/MM/RRRR HH24:MI:SS');    
    vr_obj_proposta.put('dataHora'           , fn_DataTempo_ibra(vr_data_aux));    
    vr_data_aux := NULL;
    
    
    /* 0 � CDC Diversos
       1 � CDC Ve�culos 
       2 � Empr�stimos /Financiamentos 
       3 � Desconto Cheques 
       4 � Desconto T�tulos 
       5 � Cart�o de Cr�dito 
       6 � Limite de Cr�dito) */
       
    -- Se for CDC
    IF rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_proposta.put('produtoCreditoSegmentoCodigo'    ,0); -- CDC Diversos
      vr_obj_proposta.put('produtoCreditoSegmentoDescricao' ,'CDC Diversos');
    ELSE
      vr_obj_proposta.put('produtoCreditoSegmentoCodigo' ,2); -- Emprestimos/Financiamento
      vr_obj_proposta.put('produtoCreditoSegmentoDescricao' ,'Emprestimos/Financiamento');      
    END IF;
    
    -- Se for CDC
    IF rw_crawepr.inlcrcdc = 1 THEN    
      vr_obj_proposta.put('linhaCreditoCodigo'    ,'');
      vr_obj_proposta.put('linhaCreditoDescricao' ,'');
      vr_obj_proposta.put('finalidadeCodigo'      ,''); 
      vr_obj_proposta.put('finalidadeDescricao'   ,'');
    ELSE
      vr_obj_proposta.put('linhaCreditoCodigo'    ,rw_crawepr.cdlcremp);
      vr_obj_proposta.put('linhaCreditoDescricao' ,rw_crawepr.dslcremp);
      vr_obj_proposta.put('finalidadeCodigo'      ,rw_crawepr.cdfinemp);       
      vr_obj_proposta.put('finalidadeDescricao'   ,rw_crawepr.dsfinemp);      
    END IF;
    
    vr_obj_proposta.put('tipoProduto'           ,rw_crawepr.tpproduto);
    vr_obj_proposta.put('tipoGarantiaCodigo'    ,rw_crawepr.tpctrato );
    
    --> Buscar desci��o do tipo de garantia
    vr_dstpgara := NULL;
    vr_dstpgara  := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'CTRATOEMPR', 
                                               pr_tpregist => rw_crawepr.tpctrato);    
    vr_obj_proposta.put('tipoGarantiaDescricao'    ,TRIM(vr_dstpgara) );
    
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;  
    
    vr_obj_proposta.put('loginOperador'         ,lower(rw_crapope.cdoperad));
    vr_obj_proposta.put('nomeOperador'          ,rw_crapope.nmoperad );
    
    -- Vazio se for CDC
    IF rw_crawepr.inlcrcdc = 0 THEN
      /*1-pre-aprovado, 2-analise manual, 3-nao conceder */
      vr_obj_proposta.put('parecerPreAnalise', NVL(rw_crawepr.instatus, 0));
    ELSE
      vr_obj_proposta.put('parecerPreAnalise', 0);
    END IF; 
    
    
    IF rw_crawepr.inlcrcdc = 0 THEN
      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se a primeira posi��o do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';
      
      -- Busca endividamento do cooperado
      RATI0001.pc_calcula_endividamento( pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                                        ,pr_cdagenci   => pr_cdagenci     --> C�digo da ag�ncia
                                        ,pr_nrdcaixa   => 0               --> N�mero do caixa
                                        ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                                        ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de par�metro (CRAPDAT)
                                        ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                        ,pr_dsliquid   => rw_crawepr.dsliquid --> Lista de contratos a liquidar
                                        ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                        ,pr_idorigem   => 1 /*AYLLOS*/    --> Indicador da origem da chamada
                                        ,pr_inusatab   => vr_inusatab     --> Indicador de utiliza��o da tabela de juros
                                        ,pr_tpdecons   => 3               --> Tipo da consulta 3 - Considerar a data atual
                                        ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
                                        ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                        ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
      -- Se houve erro
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;
      
      vr_vllimdis := 0.0;
      vr_vlprapne := 0.0;
      FOR rw_crapass_cpfcgc IN cr_crapass_cpfcgc(pr_cdcooper => pr_cdcooper,
                                                 pr_nrcpfcgc => rw_crapass.nrcpfcgc) LOOP

          IF rw_crapass_cpfcgc.nrdconta = pr_nrdconta THEN
             vr_nrctremp := pr_nrctremp;
          ELSE
             vr_nrctremp := 0;
          END IF;

          rw_crawepr_pend := NULL;
          OPEN cr_crawepr_pend(pr_cdcooper => rw_crapass_cpfcgc.cdcooper,
                               pr_nrdconta => rw_crapass_cpfcgc.nrdconta,
                               pr_nrctremp => vr_nrctremp);
          FETCH cr_crawepr_pend INTO rw_crawepr_pend;        
          CLOSE cr_crawepr_pend; 
          
          vr_vlprapne := nvl(rw_crawepr_pend.vlemprst, 0) + vr_vlprapne; 
          
          --> Selecionar o saldo disponivel do pre-aprovado da conta em quest�o  da carga ativa
          IF rw_crapass_cpfcgc.flgcrdpa = 1 THEN
          rw_crapcpa := NULL;
          OPEN cr_crapcpa (pr_cdcooper => rw_crapass_cpfcgc.cdcooper,
                           pr_nrdconta => rw_crapass_cpfcgc.nrdconta);
          FETCH cr_crapcpa INTO rw_crapcpa;
          CLOSE cr_crapcpa;                  
          vr_vllimdis := nvl(rw_crapcpa.vllimdis, 0) + vr_vllimdis;
	        END IF;
      END LOOP;
      
      
      vr_obj_proposta.put('endividamentoContaValor'     ,vr_vlutiliz);
      vr_obj_proposta.put('propostasPendentesValor'     ,fn_decimal_ibra(vr_vlprapne) );
      vr_obj_proposta.put('limiteCooperadoValor'        ,fn_decimal_ibra(nvl(vr_vllimdis,0)) );
      
      
      IF pr_nmarquiv IS NOT NULL THEN
        --> converter arquivo PDF para clob em base64 para enviar via json
        pc_arq_para_clob_base64(pr_nmarquiv    => pr_nmarquiv,
                                pr_clob_arquiv => vr_clob_arquiv, 
                                pr_json_value_arq =>  vr_json_valor, 
                                pr_dscritic    => vr_dscritic);
                                
        IF TRIM(vr_dscritic) IS NOT NULL THEN                        
          RAISE vr_exc_erro;
        END IF;
        
--        vr_json_valor := json_ext.to_json_value(,vr_clob_arquiv);
        
        -- Gerar objeto json para a imagem 
        vr_obj_imagem.put('codigo'      , 'PROPOSTA_PDF');
        vr_obj_imagem.put('imagem'      , vr_json_valor);--to_char(vr_clob_arquiv));
        vr_obj_imagem.put('emissaoData' , fn_Data_ibra(SYSDATE));
        vr_obj_imagem.put('validadeData', '');
        -- incluir objeto imagem na proposta
        vr_obj_proposta.put('imagem'    ,vr_obj_imagem);
      END IF;
                 
    ELSE -- caso for CDC, enviar vazio
      vr_obj_proposta.put('endividamentoContaValor'     ,'');
      vr_obj_proposta.put('propostasPendentesValor'     ,'');
      vr_obj_proposta.put('endividamentoContaValor'     ,'');
    END IF;            
    
    vr_obj_proposta.put('contratoNumero'     ,rw_crawepr.nrctremp);
    
    -- Verificar se a conta � de colaborador do sistema Cecred
    vr_cddcargo := NULL;
    OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                   ,pr_nrcpfcgc => rw_crapass.nrcpfcgc);
    FETCH cr_tbcolab
     INTO vr_cddcargo;
    IF cr_tbcolab%FOUND THEN 
      vr_flgcolab := TRUE;
    ELSE
      vr_flgcolab := FALSE;
    END IF;
    CLOSE cr_tbcolab; 
    
    -- Enviar tag indicando se � colaborador
    vr_obj_proposta.put('cooperadoColaborador',vr_flgcolab);
    
    -- Enviar o cargo somente se colaborador
    IF vr_flgcolab THEN 
      vr_obj_proposta.put('codigoCargo',vr_cddcargo);
    END IF;
    
    -- Enviar nivel de risco no momento da criacao 
    vr_obj_proposta.put('classificacaoRisco',rw_crawepr.dsnivris);
    
    -- Enviar flag se a proposta � de renogocia��o
    vr_obj_proposta.put('renegociacao',(rw_crawepr.dsliquid != '0,0,0,0,0,0,0,0,0,0'));
    
    -- BUscar faturamento se pessoa Juridica
    IF rw_crapass.inpessoa = 2 THEN 
      -- Buscar faturamento 
      OPEN cr_crapjfn(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjfn
       INTO rw_crapjfn;
      CLOSE cr_crapjfn;
      vr_obj_proposta.put('faturamentoAnual ',fn_decimal_ibra(rw_crapjfn.vltotfat));
    END IF;
    
    -- Devolver o objeto criado
    pr_proposta := vr_obj_proposta;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'N�o foi possivel montar objeto proposta: '||SQLERRM;
  END pc_gera_json_proposta;
  
  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est (pr_cdcooper  IN crawepr.cdcooper%TYPE,
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,
                                      pr_cdorigem  IN INTEGER,
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,
                                      pr_nmarquiv  IN VARCHAR2,
                                      ---- OUT ----
                                      pr_cdcritic OUT NUMBER,
                                      pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
    
      Programa : pc_incluir_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Mar�o/2016.                   Ultima atualizacao: 08/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira    
      Altera��o : 
        
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    vr_obj_proposta  json := json();
    
    vr_idacionamento  tbepr_acionamento.idacionamento%TYPE;
    
  BEGIN    
    
    --> Gerar informa��es no padrao JSON da proposta de emprestimo
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  --> Codigo da agencia                                            
                          pr_cdoperad  => pr_cdoperad,  --> codigo do operado
                          pr_cdorigem  => pr_cdorigem,  --> Origem da operacao
                          pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                          pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo
                          pr_nmarquiv  => pr_nmarquiv,  --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  --> Retorno do clob em modelo json da proposta de emprestimo
                          pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                          pr_dscritic  => vr_dscritic); --> Descricao da critica
    
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;           
    

    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,          --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,          --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,          --> Data do movimento                                      
                        pr_comprecu    => NULL,                 --> Complemento do recuros da URI
                        pr_dsmetodo    => 'POST',               --> Descricao do metodo
                        pr_conteudo    => vr_obj_proposta.to_char(), --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA A ESTEIRA DE CREDITO',   --> Operacao realizada
                        pr_tpenvest    => 'I',                  --> Tipo de envio
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    --> Atualizar proposta
    BEGIN
      UPDATE crawepr epr 
         SET epr.insitest = 1, -->  1 � Enviada para Analise 
             epr.dtenvest = trunc(SYSDATE), 
             epr.hrenvest = to_char(SYSDATE,'sssss'),
             epr.cdopeste = pr_cdoperad
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;      
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para a esteira: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    COMMIT;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'N�o foi possivel realizar inclusao da proposta na esteira: '||SQLERRM;
  END pc_incluir_proposta_est;
    
  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  PROCEDURE pc_alterar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                    pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                    pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                    pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                    pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                    pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                    pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                    pr_flreiflx  IN INTEGER,                --> Indica se deve reiniciar o fluxo de aprovacao na esteira (1-true, 0-false)
                                    pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                    ---- OUT ----                           
                                    pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                    pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_alterar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Mar�o/2016.                   Ultima atualizacao: 09/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao da proposta para a esteira    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
      
    -- Objeto json da proposta
    vr_obj_alter    json := json();
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();            
    
    
  BEGIN                  
    
    --> Gerar informa��es no padrao JSON da proposta de emprestimo
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  --> Codigo da agencia                                            
                          pr_cdoperad  => pr_cdoperad,  --> codigo do operado
                          pr_cdorigem  => pr_cdorigem,  --> Origem da operacao
                          pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                          pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo
                          pr_nmarquiv  => pr_nmarquiv,  --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  --> Retorno do clob em modelo json da proposta de emprestimo
                          pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                          pr_dscritic  => vr_dscritic); --> Descricao da critica
    
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;  
    
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    -- Incluir objeto proposta
    vr_obj_alter.put('dadosAtualizados'      ,vr_obj_proposta);
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
    vr_obj_alter.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;
    vr_obj_alter.put('reiniciaFluxo'         ,(pr_flreiflx = 1) ) ;
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_alter.put('operadorAlteracaoPA'      , vr_obj_agencia);
    vr_obj_agencia := json();    
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,          --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,          --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,          --> Data do movimento                                      
                        pr_comprecu    => NULL,                 --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                --> Descricao do metodo
                        pr_conteudo    => vr_obj_alter.to_char, --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'REENVIO DA PROPOSTA PARA ESTEIRA DE CREDITO', --> Operacao realizada
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    --> Atualizar proposta
    BEGIN
      UPDATE crawepr epr 
         SET epr.insitest = 2, -->  2 � Reenviado para Analise
             epr.cdopeste = pr_cdoperad
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;      
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para a esteira: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'N�o foi possivel realizar alteracao da proposta na esteira: '||SQLERRM;
  END pc_alterar_proposta_est;
  
  --> Rotina responsavel por gerar a alteracao do numero da proposta para a esteira
  PROCEDURE pc_alter_numproposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_alter_numproposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Mar�o/2016.                   Ultima atualizacao: 09/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao do numero da proposta para a esteira    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.cdagenci
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;        
    
    -- Objeto json da proposta
    vr_obj_alter    json := json();
    vr_obj_agencia  json := json();
    
  BEGIN                  
       
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;        
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr; 
    
    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crawepr.cdagenci);    
    vr_obj_alter.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_alter.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_alter.put('cooperadoContaNum'     , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_alter.put('cooperadoContaDv'      , to_number(substr(rw_crapass.nrdconta,-1)));
    vr_obj_alter.put('numero'                , pr_nrctremp);
    vr_obj_alter.put('propostaNovoNumero'    , pr_nrctremp_novo);
    vr_obj_alter.put('contratoNumero'        , pr_nrctremp_novo); 
    vr_obj_alter.put('cooperadoTipoPessoa'   , rw_crapass.inpessoa_ibra);
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_alter.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_alter.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF; 
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_alter.put('operadorAlteracaoPA'   , vr_obj_agencia);
    vr_obj_agencia := json();   
    vr_obj_alter.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;        
    
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,                  --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,                  --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,                  --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,                  --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,                  --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,                  --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,                  --> Data do movimento                                      
                        pr_comprecu    => '/numeroProposta',            --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                        --> Descricao do metodo
                        pr_conteudo    => vr_obj_alter.to_char,         --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA ALTERACAO DO NUMERO DA PROPOSTA PARA ESTEIRA CREDITO',  --> Operacao realizada
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'N�o foi possivel realizar alteracao do numero da proposta na esteira: '||SQLERRM;
  END pc_alter_numproposta_est;
  
  --> Rotina responsavel por gerar o cancelamento da proposta para a esteira
  PROCEDURE pc_cancelar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_cancelar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Mar�o/2016.                   Ultima atualizacao: 09/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar o cancelamento da proposta para a esteira
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.cdagenci
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    
    -- Objeto json da proposta
    vr_obj_cancelar json := json();
    vr_obj_agencia  json := json();
    -- Auxiliares
    
    
    
  BEGIN
     
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;  
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr; 
          
    
    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crawepr.cdagenci);    
    vr_obj_cancelar.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_cancelar.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_cancelar.put('cooperadoContaNum'     , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_cancelar.put('cooperadoContaDv'      , to_number(substr(rw_crapass.nrdconta,-1)));    
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_cancelar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_cancelar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;
    
    vr_obj_cancelar.put('numero'                , pr_nrctremp);
    vr_obj_cancelar.put('operadorCancelamentoLogin',lower(pr_cdoperad));
    vr_obj_cancelar.put('operadorCancelamentoNome' ,rw_crapope.nmoperad) ;
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_cancelar.put('operadorCancelamentoPA'   , vr_obj_agencia);    
    vr_obj_agencia := json();   
    vr_obj_cancelar.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;        
   
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,               --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,               --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,               --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,               --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,               --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,               --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,               --> Data do movimento                                      
                        pr_comprecu    => '/cancelar',               --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                     --> Descricao do metodo
                        pr_conteudo    => vr_obj_cancelar.to_char,   --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DO CANCELAMENTO DA PROPOSTA PARA ESTEIRA DE CREDITO',       --> Operacao realizada
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'N�o foi possivel realizar o cancelamento da proposta na esteira: '||SQLERRM;
  END pc_cancelar_proposta_est;
  
  --> Rotina responsavel por gerar efetivacao da proposta para a esteira
  PROCEDURE pc_efetivar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_efetivar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Mar�o/2016.                   Ultima atualizacao: 20/09/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a efetivacao da proposta para a esteira
      Altera��o : 20/09/2016 - Atualizar a data de envio da efetiva��o da proposta 
                  no Oracle, no Progress estava gerando erro (Oscar).
                  
                  22/09/2016 - Enviar a data em que a proposta foi efetivada ao inv�s
                  da data do dia.
        
    ..........................................................................*/ 
    
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT wepr.nrctremp,
             wepr.vlemprst,
             wepr.qtpreemp,
             wepr.dtvencto,
             wepr.vlpreemp,
             wepr.hrinclus,
             wepr.cdagenci,
             wepr.cdlcremp,
             lcr.dslcremp,
             wepr.cdfinemp,
             lcr.tpctrato,
             epr.cdopeefe,
             ope.nmoperad nmoperad_efet,
             epr.cdagenci cdagenci_efet,             
             decode(wepr.tpemprst,1,'PP','TR') tpproduto,
             -- Indica que am linha de credito eh CDC ou C DC
             DECODE(instr(replace(UPPER(lcr.dslcremp),'C DC','CDC'),'CDC'),0,0,1) inlcrcdc,
             epr.dtmvtolt
        FROM crawepr wepr,
             craplcr lcr,
             crapope ope,
             crapepr epr
       WHERE wepr.cdcooper = lcr.cdcooper
         AND wepr.cdlcremp = lcr.cdlcremp
         AND wepr.cdcooper = epr.cdcooper
         AND wepr.nrdconta = epr.nrdconta
         AND wepr.nrctremp = epr.nrctremp
         AND  epr.cdcooper = ope.cdcooper(+)
         AND  upper(epr.cdopeefe) = upper(ope.cdoperad(+))
         AND wepr.cdcooper = pr_cdcooper
         AND wepr.nrdconta = pr_nrdconta
         AND wepr.nrctremp = pr_nrctremp
         ; 
    rw_crawepr cr_crawepr%ROWTYPE;    
    
    
   CURSOR cr_craplem (pr_cdcooper craplem.cdcooper%TYPE,
                      pr_nrdconta craplem.nrdconta%TYPE,
                      pr_nrctremp craplem.nrctremp%TYPE,
                      pr_dtmvtolt craplem.dtmvtolt%TYPE)IS  
                        
    SELECT dthrtran
      FROM craplem
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND dtmvtolt = pr_dtmvtolt
       AND cdhistor IN (99, 1032, 1036, 1059) /* Efetiva��o */
       AND rownum = 1;
       
    rw_craplem cr_craplem%ROWTYPE;  
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    -- Objeto json da proposta
    vr_obj_efetivar json := json();
    vr_obj_agencia  json := json();
    vr_obj_imagem   json := json(); 
    
    -- Auxiliares
    vr_json_valor   json_value;
    vr_clob_arquiv  CLOB;
    
    
  BEGIN
    
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;  
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;    
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_craplem(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp,
                    pr_dtmvtolt => rw_crawepr.dtmvtolt);
    FETCH cr_craplem INTO rw_craplem;
    
    -- Caso nao encontrar abortar proceso
    IF cr_craplem%NOTFOUND THEN
      CLOSE cr_craplem;
      vr_cdcritic := 0; 
      vr_dscritic := 'Proposta nao foi efetivada.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craplem;
    
        
    
    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crawepr.cdagenci);    
    vr_obj_efetivar.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_efetivar.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_efetivar.put('cooperadoContaNum'      , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_efetivar.put('cooperadoContaDv'       , to_number(substr(rw_crapass.nrdconta,-1)));
    
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;
    
    --> Verificar se possui o operador que realizou a efetivacao
    IF TRIM(rw_crawepr.cdopeefe) IS NULL THEN
      vr_dscritic := 'Operador da efetivacao da proposta nao encontrado.'; 
      RAISE vr_exc_erro; 
    END IF;
    
    vr_obj_efetivar.put('numero'                 , pr_nrctremp);
    vr_obj_efetivar.put('operadorEfetivacaoLogin', rw_crawepr.cdopeefe);
    vr_obj_efetivar.put('operadorEfetivacaoNome' , rw_crawepr.nmoperad_efet) ;
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'       , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'                , rw_crawepr.cdagenci_efet);    
    vr_obj_efetivar.put('operadorEfetivacaoPA'   , vr_obj_agencia);    
    vr_obj_agencia := json();   
    vr_obj_efetivar.put('dataHora'               ,fn_DataTempo_ibra(COALESCE(rw_craplem.dthrtran, SYSDATE))) ; 
    vr_obj_efetivar.put('contratoNumero'         , pr_nrctremp);
    vr_obj_efetivar.put('valor'                  , rw_crawepr.vlemprst);
    vr_obj_efetivar.put('parcelaQuantidade'      , rw_crawepr.qtpreemp);
    vr_obj_efetivar.put('parcelaPrimeiroVencimento' , fn_Data_ibra( rw_crawepr.dtvencto));
    vr_obj_efetivar.put('parcelaValor'           , fn_decimal_ibra(rw_crawepr.vlpreemp));
    
    -- Gerar imagem apensa se nao for CDC
    IF rw_crawepr.inlcrcdc = 0 THEN
      IF pr_nmarquiv IS NOT NULL THEN
        --> converter arquivo PDF para clob em base64 para enviar via json
        pc_arq_para_clob_base64(pr_nmarquiv       => pr_nmarquiv,
                                pr_clob_arquiv    => vr_clob_arquiv, 
                                pr_json_value_arq => vr_json_valor, 
                                pr_dscritic       => vr_dscritic);
                                
        IF TRIM(vr_dscritic) IS NOT NULL THEN                        
          RAISE vr_exc_erro;
        END IF;
        
        -- Gerar objeto json para a imagem 
        vr_obj_imagem.put('codigo'      , 'PROPOSTA_PDF');
        vr_obj_imagem.put('imagem'      , vr_json_valor);--to_char(vr_clob_arquiv));
        vr_obj_imagem.put('emissaoData' , fn_Data_ibra(SYSDATE));
        vr_obj_imagem.put('validadeData', '');
        -- incluir objeto imagem na proposta
        vr_obj_efetivar.put('imagem'    ,vr_obj_imagem);
      END IF;
                 
    END IF;
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,               --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,               --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,               --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,               --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,               --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,               --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,               --> Data do movimento                                      
                        pr_comprecu    => '/efetivar',               --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                     --> Descricao do metodo
                        pr_conteudo    => vr_obj_efetivar.to_char,   --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA EFETIVACAO DA PROPOSTA PARA ESTEIRA CREDITO',       --> Operacao realizada
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
     --> Atualizar proposta
    BEGIN
      UPDATE crawepr epr 
         SET epr.dtenefes = trunc(SYSDATE)
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;      
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da efetivacao para a esteira: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    COMMIT;         
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'N�o foi possivel realizar efetivacao da proposta na esteira: '||SQLERRM;
  END pc_efetivar_proposta_est;
  
  --> Rotina responsavel por consultar informa��es da proposta na esteira
  PROCEDURE pc_consultar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,    --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,    --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,    --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                  --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,    --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,    --> Numero da proposta de emprestimo atual/antigo                          
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,    --> Data do movimento                                      
                                      ---- OUT ----                             
                                      pr_cdsitest OUT NUMBER,                   --> Retorna situacao da proposta    
                                      pr_cdstatan OUT NUMBER,                   --> Retornoa status da proposta                                                                            
                                      pr_cdcritic OUT NUMBER,                   --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS              --> Descricao da critica.
    /* .........................................................................
    
      Programa : pc_consultar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Mar�o/2016.                   Ultima atualizacao: 09/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por buscar informa��es da proposta na esteira
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------        
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.vlemprst,
             epr.qtpreemp,
             epr.dtvencto,
             epr.vlpreemp,
             epr.hrinclus,
             epr.cdlcremp,
             epr.cdfinemp,
             epr.cdagenci,
             decode(epr.tpemprst,1,'PP','TR') tpproduto
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_contige_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_chave_este    VARCHAR2(500);
    
    vr_obj_proposta  json := json();
    vr_obj_retorno   json := json();
    
    vr_cdsitest      NUMBER;    
    vr_cdstatan      NUMBER;
    vr_cdsegpro_ret  NUMBER;
    vr_cdlcremp_ret  NUMBER;
    vr_cdfinemp_ret  NUMBER;
    vr_cdtpprod_ret  VARCHAR2(100);
    vr_nrctremp_ret  crawepr.nrctremp%TYPE;
    vr_nrctremp_ret2 crawepr.nrctremp%TYPE;
    vr_idacionamento tbepr_acionamento.idacionamento%TYPE;    
    
    
  BEGIN
    
    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                          pr_nrdconta      => pr_nrdconta,                   -- Numero da conta do cooperado
                          pr_nrctremp      => pr_nrctremp,                   -- Numero da proposta de emprestimo
                          pr_tpenvest      => 'C',                           -- Tipo de envio C - Consultar(Get)
                          pr_host_esteira  => vr_host_esteira,               -- Host da esteira
                          pr_recurso_este  => vr_recurso_este,               -- URI da esteira
                          pr_contige_este  => vr_contige_este,               -- Verificar se esta em contigencia
                          pr_dsdirlog      => vr_dsdirlog    ,               -- Diretorio de log dos arquivos 
                          pr_chave_este    => vr_chave_este  ,               -- Chave de acesso
                          pr_dscritic      => vr_dscritic    );
    
    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;           
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;        
        
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este;
    vr_request.method := 'GET';
    vr_request.timeout := 1000;
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := 'Basic '||vr_chave_este;
    
    vr_request.parameters('numero') := pr_nrctremp; 
    -- Nr. conta sem o digito
    vr_request.parameters('cooperadoContaNum') := to_number(substr(pr_nrdconta,1,length(pr_nrdconta)-1));
    -- Somente o digito
    vr_request.parameters('cooperadoContaDv')  := to_number(substr(pr_nrdconta,-1));
    vr_request.parameters('cooperativaCodigo') := pr_cdcooper;
    vr_request.parameters('valor')             := fn_decimal_ibra(rw_crawepr.vlemprst);      
    vr_request.parameters('parcelaQuantidade') := rw_crawepr.qtpreemp;
    
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato � o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                         pr_cdagenci              => pr_cdagenci,          
                         pr_cdoperad              => pr_cdoperad,          
                         pr_cdorigem              => pr_cdorigem,          
                         pr_nrctrprp              => pr_nrctremp,          
                         pr_nrdconta              => pr_nrdconta,          
                         pr_tpacionamento         => 1,  /* 1 - Envio, 2 � Retorno */      
                         pr_dsoperacao            => 'CONSULTA DA PROPOSTA NA ESTEIRA DE CREDITO',
                         pr_dsuriservico          => vr_recurso_este,       
                         pr_dtmvtolt              => pr_dtmvtolt,       
                         pr_cdstatus_http         => vr_response.status_code,
                         pr_dsconteudo_requisicao => vr_obj_proposta.to_char,
                         pr_dsresposta_requisicao => '"Content":'||vr_response.content||
                                                     ' "StatusMessage":'||vr_response.status_message,
                         pr_idacionamento         => vr_idacionamento,
                         pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    --> Commit para garantir que guarde as informa��es do log de acionamento
    COMMIT;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      vr_dscritic := 'N�o foi possivel consultar informa��es na Esteira, '||
                     'favor entrar em contato com a equipe responsavel.(Cod:'||vr_response.status_code||')';    
      RAISE vr_exc_erro;
    END IF;
      
    ---- Estrair dados retorno    
    vr_obj_retorno := json(vr_response.content);
    IF vr_obj_retorno.exist('numero') THEN
      vr_nrctremp_ret := vr_obj_retorno.get('numero').to_char();
    END IF;
    -- Situa��o da proposta 
    -- (0-Aguardando Analise, 1 -Agendado, 2 - Em An�lise, 3 - Aprovada, 4 - N�o Aprovada, 5-Efetivada, 6 - Refazer,
    --  7 - Aguardando Aliena��o/Gravame, 8 - Cancelada, 9 - Entregue PA, 10 - Aguardando Informa��o, 11 - Encerrada por Rean�lise, 
    -- 12 - Agendado Aliena��o/Gravame, 13 - Registrando Aliena��o/Gravame, 14 - Aguardando Informa��o Aliena��o/Gravame, 
    -- 15 - Aguardando An�lise Superior, 16 - Agendado An�lise Superior, 17 - Em An�lise Superior, 18 - Aprovada condicionalmente)
    IF vr_obj_retorno.exist('situacao') THEN
      vr_cdsitest   := vr_obj_retorno.get('situacao').to_char();
    END IF;
    
    --> C�digo do segmento de produto de cr�dito 
    -- (0 � CDC Diversos, 1 � CDC Ve�culos, 2 � Empr�stimos/Financiamentos, 
    -- 3 � Desconto Cheques, 4 � Desconto T�tulos, 5 � Cart�o de Cr�dito, 6 � Limite de Cr�dito) 
    IF vr_obj_retorno.exist('produtoCreditoSegmentoCodigo') THEN
      vr_cdsegpro_ret := vr_obj_retorno.get('produtoCreditoSegmentoCodigo').to_char();    
    END IF;
    IF vr_obj_retorno.exist('linhaCreditoCodigo') THEN
      vr_cdlcremp_ret := vr_obj_retorno.get('linhaCreditoCodigo').to_char();    
    END IF;
    IF vr_obj_retorno.exist('finalidadeCodigo') THEN
      vr_cdfinemp_ret := vr_obj_retorno.get('finalidadeCodigo').to_char();    
    END IF;
    -- Tipo de Produto (PP ou TR)    
    IF vr_obj_retorno.exist('tipoProduto') THEN
      vr_cdtpprod_ret := vr_obj_retorno.get('tipoProduto').to_char();    
    END IF;
    IF vr_obj_retorno.exist('contratoNumero') AND 
       upper(vr_obj_retorno.get('contratoNumero').to_char()) <> 'NULL' THEN
      vr_nrctremp_ret2:= vr_obj_retorno.get('contratoNumero').to_char();        
    END IF;

    --> Status da An�lise (0 - Aguardando Analise, 1 - Em Analise, 2 - Aprovada, 
    --                     3 - N�o Aprovada, 4 - Refazer, 5 � Expirado, 6 � Aprovado Condicional) 
    IF vr_obj_retorno.exist('statusAnalise') THEN
      vr_cdstatan   := vr_obj_retorno.get('statusAnalise').to_char();
    END IF;
    
    --> Retornar valores
    pr_cdstatan := vr_cdstatan;
    pr_cdsitest := vr_cdsitest;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'N�o foi possivel realizar consulta da proposta na esteira: '||SQLERRM;
  END pc_consultar_proposta_est;

    
END ESTE0001;
/
