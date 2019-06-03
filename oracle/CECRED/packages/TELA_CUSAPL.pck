CREATE OR REPLACE PACKAGE CECRED.TELA_CUSAPL AS

   /*
   Programa: TELA_CUSAPL
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Marcos - Envolti
   Data    : Mar�o/2018                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: On-line
   Objetivo  : Manter as rotinas para a tela CUSAPL - Que trazer insforma��es da
               Cust�dia das Aplica��es junto ao

   Alteracoes: 

   */  
   
   /* Procedimento para retornar os par�metros gravados em Sistema por Cooperativa */
   PROCEDURE pc_busca_parametros_coop(pr_tlcdcooper IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK        
                                
  /* Procedimento para retornar os par�metros gravados em Sistema por Cooperativa */
  PROCEDURE pc_gravac_parametros_coop(pr_tlcdcooper  IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_datab3    in VARCHAR2           -- Data de Habilita��o Cust�dia 
                                     ,pr_vlminb3   IN VARCHAR2           -- Valor m�nimo de aplica��o para cust�dia na B3
                                     ,pr_cdregtb3  in VARCHAR2           -- Padr�o do nome do arquivo 
                                     ,pr_cdfavrcb3 in VARCHAR2           -- Lista de email para alertas no processo
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK   
   
   /* Procedimento para retornar os par�metros gravados em Sistema */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK        
                                
  /* Procedimento para retornar os par�metros gravados em Sistema */
  PROCEDURE pc_gravac_parametros(pr_nomarq   in VARCHAR2           -- Padr�o do nome do arquivo 
                                ,pr_dsmail   in VARCHAR2           -- Lista de email para alertas no processo
                                ,pr_hrinicio in VARCHAR2           -- Hora de in�cio da comunica��o com B3
                                ,pr_hrfinal  in VARCHAR2           -- Hora final de comunica��o com B3
                                ,pr_reghab   in VARCHAR2           -- Envio Habilitado ? 
                                ,pr_rgthab   in VARCHAR2           -- Retorno Habilitado ? 
                                ,pr_cnchab   in VARCHAR2           -- Exclus�o Habilitada ? 
								,pr_perctolval IN NUMBER           -- Parametro de tolerancia de concilia��o																			  
                                ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar os arquivos para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_arquivos(pr_cdcooper in VARCHAR2           -- Cooperativa selecionada (0 para todas)
                             ,pr_nrdconta in VARCHAR2           -- Conta informada
                             ,pr_nraplica in VARCHAR2           -- Aplica��o Informada (0 para todas)
                             ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                             ,pr_datade   in VARCHAR2           -- Data de 
                             ,pr_datate   in VARCHAR2           -- Date at�
                             ,pr_nmarquiv in VARCHAR2           -- Nome do arquivo para busca
                             ,pr_dscodib3 in VARCHAR2           -- C�digo na B3
                             ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar o LOG do arquivo repassado nos par�metros */
  PROCEDURE pc_lista_log_arquivo(pr_idarquivo in VARCHAR2          -- C�digo na B3
                                ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar o conte�do do arquivo */
  PROCEDURE pc_lista_conteudo_arquivo(pr_idarquivo in VARCHAR2          -- C�digo na B3
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar a Opera��es para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_operacoes(pr_cdcooper in VARCHAR2           -- Cooperativa selecionada (0 para todas)
                              ,pr_nrdconta in VARCHAR2           -- Conta informada
                              ,pr_nraplica in VARCHAR2           -- Aplica��o Informada (0 para todas)
                              ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                              ,pr_datade   in VARCHAR2           -- Data de 
                              ,pr_datate   in VARCHAR2           -- Date at�
                              ,pr_nmarquiv in VARCHAR2           -- Nome do arquivo para busca
                              ,pr_dscodib3 in VARCHAR2           -- C�digo na B3
                              ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK
                                
  /* Procedimento para Solicitar o Envio de Arquivos Pendentes na hora */
  PROCEDURE pc_solicita_envio(pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK
                             
  /* Procedimento para Solicitar o Retorno e Processamento de Arquivos Pendentes na hora */
  PROCEDURE pc_solicita_retorno(pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK                                                              
                               
  /* Procedimento para Solicitar a altera��o da situa��o dos registros com erro para Reenvio */
  PROCEDURE pc_solicita_reenvio(pr_dsdlista IN VARCHAR2           -- Lista de Lan�amentos Selecionados
                               ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK
  
END TELA_CUSAPL;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CUSAPL AS
   
   /* Procedimento para retornar os par�metros gravados em Sistema por Cooperativa */
   PROCEDURE pc_busca_parametros_coop(pr_tlcdcooper IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS      -- Saida OK/NOK      
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_parametros_coop
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca par�metros do sistema por Cooperativa para retornar a tela PHP 
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_busca_parametros'); 
                                 
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
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Root'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'Dados'
      ,pr_tag_cont => NULL
      ,pr_des_erro => vr_dscritic);

    -- Par�metro Data Inicial
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'dataB3'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'INIC_CUSTODIA_APLICA_B3')
      ,pr_des_erro => vr_dscritic);
      
    -- Valor m�nimo
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'vlminB3'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'VLMIN_CUSTOD_APLICA_B3')
      ,pr_des_erro => vr_dscritic);    

    -- Par�metro Codigo Registrador
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'cdregtb3'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'CD_REGISTRADOR_CUSTOD_B3')
      ,pr_des_erro => vr_dscritic);

    -- Par�metro Codigo Favorecido
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'cdfavrcb3'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'CD_FAVORECIDO_CUSTOD_B3')
      ,pr_des_erro => vr_dscritic);

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_busca_parametros_coop;
  
  /* Procedimento para retornar os par�metros gravados em Sistema por Cooperativa */
  PROCEDURE pc_gravac_parametros_coop(pr_tlcdcooper  IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_datab3    in VARCHAR2           -- Data de Habilita��o Cust�dia 
                                     ,pr_vlminb3   IN VARCHAR2           -- Valor m�nimo de aplica��o para cust�dia na B3
                                     ,pr_cdregtb3  in VARCHAR2           -- Padr�o do nome do arquivo 
                                     ,pr_cdfavrcb3 in VARCHAR2           -- Lista de email para alertas no processo
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravac_parametros_coop
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Gravar par�metros do sistema por Cooperativa conforme preenchimento em tela PHP
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/ 
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    -- Variaveis para validar convers�o dos dados enviados
    vr_dsdata   DATE;
    vr_vlminimo NUMBER;
    -- Variaveis para LOG
    vr_dsvlrprm VARCHAR2(4000);
    vr_nmarqlog VARCHAR2(20) := gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'NOM_ARQUIVO_LOG_B3')||'.log';
     
  BEGIN    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_gravac_parametros');                                  
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
    -- Testar se todos os campos foram informados
    IF trim(pr_datab3) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Data inicial de Cust�dia deve ser informada!');
      RAISE vr_exc_erro;
    END IF;
    
    IF trim(pr_vlminb3) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Valor m�nimo de Cust�dia deve ser informada!');
      RAISE vr_exc_erro;
    END IF; 
    
    -- Converter data em texto para Date
    BEGIN
      vr_dsdata := TO_DATE(pr_datab3, 'dd/mm/rrrr');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Data inicial ['||pr_datab3||'] de Cust�dia Inv�lida!');
      RAISE vr_exc_erro;
    END;
    
    -- Converter texto em numero para number
    BEGIN
      vr_vlminimo := TO_NUMBER(pr_vlminb3, 'FM9999990D00');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Valor m�nimo ['||pr_vlminb3||'] de Cust�dia com B3 Inv�lido!');
      RAISE vr_exc_erro;
    END;
    
    -- Registrador deve ser um texto composto somente de n�meros e com 8 posi��es
    IF length(TRIM(pr_cdregtb3)) <> 8 OR NOT gene0002.fn_numerico(pr_cdregtb3) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Codigo Cliente Registrador ['||pr_cdregtb3||'] com B3 Inv�lido! Informe uma conta com 8 numeros!');
      RAISE vr_exc_erro;
    END IF;
    
    -- Favorecido deve ser um texto composto somente de n�meros e com 8 posi��es    
    IF length(TRIM(pr_cdfavrcb3)) <> 8 OR NOT gene0002.fn_numerico(pr_cdfavrcb3) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Codigo Cliente Favorecido ['||pr_cdfavrcb3||'] com B3 Inv�lido! Informe uma conta com 8 numeros!');
      RAISE vr_exc_erro;
    END IF;
    
    -- Finalmente efetuar a grava��o na tabela
    BEGIN
      
      /* Data de in�cio Cust�dia */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'INIC_CUSTODIA_APLICA_B3');
      IF vr_dsvlrprm <> to_char(vr_dsdata,'dd/mm/rrrr') THEN 
        UPDATE crapprm
           SET dsvlrprm = to_char(vr_dsdata,'dd/mm/rrrr')
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_tlcdcooper
           AND cdacesso = 'INIC_CUSTODIA_APLICA_B3'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_tlcdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Data Inicio Custodia" de ' || vr_dsvlrprm
                                                   || ' para ' || to_char(vr_dsdata,'dd/mm/rrrr') || '.');
      END IF;     
      
      /* Valor de in�cio Cust�dia */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'VLMIN_CUSTOD_APLICA_B3');
      IF vr_dsvlrprm <> to_char(vr_vlminimo,'FM999g990D00') THEN 
        UPDATE crapprm
           SET dsvlrprm = to_char(vr_vlminimo,'FM999g990D00')
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_tlcdcooper
           AND cdacesso = 'VLMIN_CUSTOD_APLICA_B3'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_tlcdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Valor Inicio Custodia" de ' || vr_dsvlrprm
                                                   || ' para ' || to_char(vr_vlminimo,'FM999g990D00') || '.');
      END IF;
      
      /* Codigo Cliente Registrador */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'CD_REGISTRADOR_CUSTOD_B3');
      IF vr_dsvlrprm <> pr_cdregtb3 THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_cdregtb3
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_tlcdcooper
           AND cdacesso = 'CD_REGISTRADOR_CUSTOD_B3'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_tlcdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Codigo Cliente Registrador" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_cdregtb3 || '.');
      END IF;  
      
      /* Codigo Cliente Registrador */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'CD_FAVORECIDO_CUSTOD_B3');
      IF vr_dsvlrprm <> pr_cdfavrcb3 THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_cdfavrcb3
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_tlcdcooper
           AND cdacesso = 'CD_FAVORECIDO_CUSTOD_B3'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_tlcdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Codigo Cliente Favorecido" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_cdfavrcb3 || '.');
      END IF;  
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na grava��o dos Par�metros de Cust�dia de Aplica��o: '
                    ||sqlerrm;
        RAISE vr_exc_erro;
    END; 
    -- Gravar no banco
    COMMIT;
    -- Retorno OK
    pr_des_erro := 'OK';  
  EXCEPTION
    WHEN vr_exc_erro THEN                      
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';                 
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                                                                     
    WHEN OTHERS THEN         
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravac_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_gravac_parametros_coop;

   /* Procedimento para retornar os par�metros gravados em Sistema */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_parametros
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca par�metros do sistema para retornar a tela PHP 
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_busca_parametros'); 
                                 
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
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Root'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'Dados'
      ,pr_tag_cont => NULL
      ,pr_des_erro => vr_dscritic);    

    -- Par�metro Nome Arquivo
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'nomarq'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'NOM_ARQUIVO_LOG_B3')
      ,pr_des_erro => vr_dscritic);

    -- Par�metro Emails
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'dsmail'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'DES_EMAILS_PROC_B3')
      ,pr_des_erro => vr_dscritic);

    -- Par�metro Hora De
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'hrinicio'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'HOR_INICIO_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

    -- Par�metro Hora At�
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'hrfinal'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'HOR_FINAL_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);


    -- Par�metro Envio Habilitado
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'reghab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FLG_ENV_REG_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

    -- Par�metro Retorno Habilitado
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'rgthab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FLG_ENV_RGT_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

    -- Par�metro Exclus�o Habilitada
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'cnchab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FLG_CONCILIA_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

	-- Par�metro Toler�ncia Concilia��o
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'perctolval'
      ,pr_tag_cont => TO_CHAR(gene0001.fn_param_sistema('CRED',0,'CD_TOLERANCIA_DIF_VALOR'), 'FM990D00000000')
      ,pr_des_erro => vr_dscritic);					   

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_busca_parametros;
  
  /* Procedimento para retornar os par�metros gravados em Sistema */
  PROCEDURE pc_gravac_parametros(pr_nomarq   in VARCHAR2           -- Padr�o do nome do arquivo 
                                ,pr_dsmail   in VARCHAR2           -- Lista de email para alertas no processo
                                ,pr_hrinicio in VARCHAR2           -- Hora de in�cio da comunica��o com B3
                                ,pr_hrfinal  in VARCHAR2           -- Hora final de comunica��o com B3
                                ,pr_reghab   in VARCHAR2           -- Envio Habilitado ? 
                                ,pr_rgthab   in VARCHAR2           -- Retorno Habilitado ? 
                                ,pr_cnchab   in VARCHAR2           -- Exclus�o Habilitada ? 
								,pr_perctolval IN NUMBER           -- Parametro de tolerancia de concilia��o 																			   
                                ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravac_parametros
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Gravar par�metros do sistema conforme preenchimento em tela PHP
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/ 
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    -- Variaveis para validar convers�o dos dados enviados
    vr_dshorain DATE;
    vr_dshorafi DATE;   
    vr_txemails gene0002.typ_split; --> Separa��o da linha em vetor
    vr_vlemails VARCHAR2(4000); --> Emails v�lidos
    -- Variaveis para LOG
    vr_dsvlrprm VARCHAR2(4000);
    vr_nmarqlog VARCHAR2(20) := gene0001.fn_param_sistema('CRED',0,'NOM_ARQUIVO_LOG_B3')||'.log';
	vr_perctolval NUMBER;					 
     
  BEGIN    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_gravac_parametros');                                  
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
    
    IF trim(pr_nomarq) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Nome do arquivo deve ser informado!');
      RAISE vr_exc_erro;
    END IF;
    
    IF trim(pr_dsmail) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Email para alerta deve ser informado!');
      RAISE vr_exc_erro;
    END IF;
    
    IF trim(pr_hrinicio) IS NULL OR trim(pr_hrfinal) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Hor�rio de Comunica��o de-at� deve ser informado!');
      RAISE vr_exc_erro;
    END IF;    
    
	IF TRIM(pr_perctolval) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Parametro de toler�ncia deve ser informado!');
      RAISE vr_exc_erro;
    END IF;   
	
    -- Converter hora em texto para Date
    BEGIN
      vr_dshorain := TO_DATE(pr_hrinicio, 'hh24:mi');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Hor�rio de ['||pr_hrinicio||'] de Comunica��o com B3 Inv�lido!');
      RAISE vr_exc_erro;
    END;
	
    -- Converter Hora em texto para Date
    BEGIN
      vr_dshorafi := TO_DATE(pr_hrfinal, 'hh24:mi');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Hor�rio at� ['||pr_hrfinal||'] de Comunica��o com B3 Inv�lido!');
      RAISE vr_exc_erro;
    END;    
    -- Hor�rio fim n�o pode ser inferior a hora de
    IF vr_dshorain > vr_dshorafi THEN 
      vr_dscritic := gene0007.fn_convert_db_web('Hor�rio de n�o pode ser superior a Hor�rio at�!');
      RAISE vr_exc_erro;  
    END IF;    
    
    -- Separar os emails enviados e tentar valid�-los
    vr_txemails := gene0002.fn_quebra_string(replace(pr_dsmail,',',';'),';');
    IF vr_txemails.COUNT() > 0 THEN
      FOR vr_idx IN vr_txemails.FIRST..vr_txemails.LAST LOOP
        -- Se o email atual possuir alguma informa��o
        IF trim(vr_txemails(vr_idx)) IS NOT NULL THEN 
          -- Validar o mesmo
          IF gene0003.fn_valida_email(vr_txemails(vr_idx)) = 1 THEN 
            vr_vlemails := vr_vlemails || lower(vr_txemails(vr_idx))||';';
          ELSE
            -- Gerar erro 
            vr_dscritic := gene0007.fn_convert_db_web('Endere�o de email ['||vr_txemails(vr_idx)||'] n�o � um endere�o v�lido!');
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;
    END IF;  
    
    -- Se n�o validou pelo menos um email
    IF vr_vlemails IS NULL THEN 
      vr_dscritic := gene0007.fn_convert_db_web('Email para alerta deve ser informado! Informe endere�os v�lidos e separados por Ponto e V�rgula(;), caso seja necess�rio!');
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Finalmente efetuar a grava��o na tabela
    BEGIN
      
      /* Nome arquivo LOG */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'NOM_ARQUIVO_LOG_B3');
      IF vr_dsvlrprm <> pr_nomarq THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_nomarq
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'NOM_ARQUIVO_LOG_B3';
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Nome Arquivo LOG" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_nomarq || '.');           
      END IF; 
        
      /* Emails */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'DES_EMAILS_PROC_B3');
      IF vr_dsvlrprm <> vr_vlemails THEN 
        UPDATE crapprm
           SET dsvlrprm = vr_vlemails
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'DES_EMAILS_PROC_B3';
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Lista Emails" de ' || vr_dsvlrprm
                                                   || ' para ' || vr_vlemails || '.');                      
      END IF;
      
      /* Hor�rio De */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'HOR_INICIO_CUSTODIA_B3');
      IF vr_dsvlrprm <> pr_hrinicio THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_hrinicio
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'HOR_INICIO_CUSTODIA_B3';
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Hor�rio Comunica��o de" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_hrinicio || '.');                    
      END IF;
      
      /* Hor�rio at� */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'HOR_FINAL_CUSTODIA_B3');
      IF vr_dsvlrprm <> pr_hrfinal THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_hrfinal
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'HOR_FINAL_CUSTODIA_B3';
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Hor�rio Comunica��o at�" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_hrfinal || '.');                               
      END IF;
      
      /* Registro Habilitado */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'FLG_ENV_REG_CUSTODIA_B3');
      IF vr_dsvlrprm <> pr_reghab THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_reghab
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'FLG_ENV_REG_CUSTODIA_B3';
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Registro Habilitado" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_reghab || '.');                                          
      END IF;
      
      /* Opera��es Habilitado */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'FLG_ENV_RGT_CUSTODIA_B3');
      IF vr_dsvlrprm <> pr_rgthab THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_rgthab
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'FLG_ENV_RGT_CUSTODIA_B3';
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Resgate Habilitado" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_rgthab || '.');                                                     
      END IF;   
      
      /* Concilia��o habilitada */
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'FLG_CONCILIA_CUSTODIA_B3');
      IF vr_dsvlrprm <> pr_cnchab THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_cnchab
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'FLG_CONCILIA_CUSTODIA_B3';
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Concilia��o Habilitada" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_cnchab || '.');            
        -- Se foi ativado
        IF pr_cnchab = 'S' THEN
          -- Atualizamos o registro que indica quando ocorreu a ultima concilia��o
          -- pois sea mesma � desabilitada, quando reativada temos de gravar o dia de ontem, 
          -- para que ao rodar o processo novamente tenhamos a concilia��o do arquivo de ontem
          UPDATE crapprm
             SET dsvlrprm = to_char(trunc(SYSDATE-1),'dd/mm/rrrr')
           WHERE nmsistem = 'CRED'
             AND cdcooper = 0
             AND cdacesso = 'DAT_CONCILIA_CUSTODIA_B3'; 
        END IF;                                                 
      END IF;   
	  
	/* Percentual de toler�ncia da concilia��o */
      vr_perctolval := gene0001.fn_param_sistema('CRED',0,'CD_TOLERANCIA_DIF_VALOR');                        
      IF vr_perctolval <> pr_perctolval THEN    
        UPDATE crapprm
             SET dsvlrprm = pr_perctolval
           WHERE nmsistem = 'CRED'
             AND cdcooper = 0
             AND cdacesso = 'CD_TOLERANCIA_DIF_VALOR'; 
      
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o par�metro "Percentual de Toler�ncia para Concilia��o" de ' || vr_perctolval
                                                   || ' para ' || pr_perctolval || ', para a cooperativa ' || vr_cdcooper || '.');
      END IF;											  	 
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na grava��o dos Par�metros de Cust�dia de Aplica��o: '
                    ||sqlerrm;
        RAISE vr_exc_erro;
    END; 
    -- Gravar no banco
    COMMIT;
    -- Retorno OK
    pr_des_erro := 'OK';  
  EXCEPTION
    WHEN vr_exc_erro THEN                      
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';                 
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                                                                     
    WHEN OTHERS THEN         
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravac_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_gravac_parametros;
  
  /* Procedimento para retornar os arquivos para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_arquivos(pr_cdcooper in VARCHAR2           -- Cooperativa selecionada (0 para todas)
                             ,pr_nrdconta in VARCHAR2           -- Conta informada
                             ,pr_nraplica in VARCHAR2           -- Aplica��o Informada (0 para todas)
                             ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                             ,pr_datade   in VARCHAR2           -- Data de 
                             ,pr_datate   in VARCHAR2           -- Date at�
                             ,pr_nmarquiv in VARCHAR2           -- Nome do arquivo para busca
                             ,pr_dscodib3 in VARCHAR2           -- C�digo na B3
                             ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_arquivos
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca Arquivos de Cust�dia gerados e seus retornos, tudo conforme os par�metros enviados
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
           
    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_posreg   PLS_INTEGER := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_datade   date;
    vr_dataat   date;
    
    -- Busca dos arquivos de cust�dia
    cursor cr_arquivos IS
      SELECT arq.*
        FROM(SELECT apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'A') dstiparq
                   ,apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'E') dstiparq_ext
                   ,arqEnv.dtregistro
                   /* Envio */
                   ,arqEnv.idarquivo idarqenv
                   ,substr(arqEnv.nmarquivo,1,26)||chr(13)||substr(arqEnv.nmarquivo,27) nmarqenv
                   ,decode(arqEnv.idsituacao,0,'N�o Env.',1,'Enviado') dssitenv
                   ,arqEnv.dtprocesso dtdenvio
                   ,'Envio' tpopeenv
                   /* Retorno */
                   ,arqRet.idarquivo idarqret
                   ,substr(arqRet.nmarquivo,1,25)||chr(13)||substr(arqRet.nmarquivo,26) nmarqret
                   ,decode(arqRet.idsituacao,0,'N�o Prc.',1,'Processado') dssitret
                   ,arqRet.dtprocesso dtdretor
                   ,'Retorno' tpoperet
                FROM tbcapt_custodia_arquivo arqEnv
                    ,tbcapt_custodia_arquivo arqRet
               WHERE arqEnv.idtipo_arquivo IN(1,2,3) 
                 AND arqEnv.idtipo_operacao = 'E'
                 AND arqEnv.idarquivo = arqRet.idarquivo_origem (+)
                 AND arqRet.idtipo_operacao (+) = 'R'
               UNION
              SELECT apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'A') 
                    ,apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'E') 
                    ,arqCnc.Dtregistro                  
                    /* Concilia��o n�o h� envio */
                    ,arqCnc.idarquivo 
                    ,null nmarqenv
                    ,null dssitenv
                    ,to_date(null) 
                    ,null tpopeenv
                    /* Dados da Concilia��o(Retorno) */
                    ,arqCnc.idarquivo 
                    ,substr(arqCnc.nmarquivo,1,26)||chr(13)||substr(arqCnc.nmarquivo,27)  
                    ,decode(arqCnc.idsituacao,0,'N�o Prc.',1,'Processado') 
                    ,nvl(arqCnc.dtprocesso,arqCnc.Dtcriacao) 
                    ,'Retorno' 
                FROM tbcapt_custodia_arquivo arqCnc
               WHERE arqCnc.idtipo_arquivo = 9 
                 AND arqCnc.idtipo_operacao = 'R') arq
        ORDER BY nvl(arq.dtdenvio,arq.dtdretor) DESC; 
    
    -- Garantir que a aplica��o vinculada esteja de acordo com 
    -- os filtros enviados ou que haja registro de cr�tica 
    CURSOR cr_aplica(pr_idarqenv number
                    ,pr_idarqret NUMBER) IS
      SELECT 1
        FROM tbcapt_custodia_conteudo_arq cntArq
            ,tbcapt_custodia_lanctos      lanctos
            ,tbcapt_custodia_aplicacao    aplica
       WHERE cntArq.idarquivo in(pr_idarqenv,pr_idarqret)
         AND cntArq.idlancamento = lanctos.idlancamento
         AND lanctos.idaplicacao = aplica.idaplicacao
         AND ( NVL(pr_flgcritic,'N') = 'N' OR cntArq.dscritica IS NOT NULL )
         AND ( trim(pr_dscodib3) IS NULL 
               or upper(aplica.dscodigo_b3) like '%'||upper(trim(pr_dscodib3))||'%')
         -- Incluir exists com as tabelas de aplica��es que s�o vinculadas a esta
         AND exists(SELECT 1
                      FROM craprda RDA
                     WHERE RDA.idaplcus = aplica.idaplicacao
                       AND (pr_cdcooper = 0 or RDA.cdcooper = pr_cdcooper)
                       AND (trim(pr_nrdconta) IS NULL or RDA.nrdconta = pr_nrdconta)
                       AND (pr_nraplica = '0' 
                            OR (    gene0002.fn_busca_entrada(1,pr_nraplica,'_') = 'A'
                                AND gene0002.fn_busca_entrada(3,pr_nraplica,'_') = to_char(RDA.nraplica)
                               )
                            )
                    UNION
                    SELECT 1
                      FROM craprac RAC
                     WHERE RAC.idaplcus = aplica.idaplicacao
                       AND (pr_cdcooper = 0 or RAC.cdcooper = pr_cdcooper)
                       AND (trim(pr_nrdconta) IS NULL or RAC.nrdconta = pr_nrdconta)
                       AND (pr_nraplica = '0' 
                            OR (    gene0002.fn_busca_entrada(1,pr_nraplica,'_') = 'N'
                                AND gene0002.fn_busca_entrada(3,pr_nraplica,'_') = to_char(RAC.nraplica)
                               )
                            )
                    );
    vr_idexiste NUMBER;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_lista_arquivos'); 
                                 
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
    
    -- Validar os par�metros data
    IF trim(pr_datade) IS NOT NULL THEN 
      Begin
        vr_datade := to_date(pr_datade,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data de ['||pr_datade||'] inv�lida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    -- Validar os par�metros data
    IF trim(pr_datate) IS NOT NULL THEN 
      Begin
        vr_dataat := to_date(pr_datate,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data at� ['||pr_datate||'] inv�lida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    -- Se enviada as duas datas, temos de validar se at� n�o � inferior a De
    IF vr_datade IS NOT NULL AND vr_dataat IS NOT NULL THEN       
      IF vr_datade > vr_dataat THEN
        vr_dscritic := 'Data De n�o pode ser superior a Data At�!';
        RAISE vr_exc_Erro;
      END IF;
    END IF;

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><lstarqv qtregist="0">');    

    -- Retornar os arquivos conforme filtros informados
    FOR rw_arquiv IN cr_arquivos LOOP 
      
      -- Caso algum par�metro de data tenha sido informado
      IF vr_datade IS NOT NULL OR vr_dataat IS NOT NULL THEN
        -- Garantir data de e at� quando temos as duas
        IF vr_datade IS NOT NULL AND vr_dataat IS NOT NULL THEN           
          -- Data Refere Ou Envio ou Retorno tem de estar no per�odo
          IF  trunc(rw_arquiv.dtregistro) NOT BETWEEN vr_datade AND vr_dataat
          AND trunc(nvl(rw_arquiv.dtdenvio,rw_arquiv.dtregistro)) NOT BETWEEN vr_datade AND vr_dataat  
          AND trunc(nvl(rw_arquiv.dtdretor,rw_arquiv.dtregistro)) NOT BETWEEN vr_datade AND vr_dataat THEN 
            -- Ignorar este
            CONTINUE;
          END IF;
        -- Garantir somente Data De
        ELSIF vr_datade IS NOT NULL THEN 
          -- Data Refere, envio e retorno tem de ser posterior A Data De
          IF trunc(rw_arquiv.dtregistro) < vr_datade 
          AND trunc(NVL(rw_arquiv.dtdenvio,rw_arquiv.dtregistro)) < vr_datade 
          AND trunc(nvl(rw_arquiv.dtdretor,rw_arquiv.dtregistro)) < vr_datade THEN 
            -- Ignorar este arquivo
            CONTINUE;
          END IF;                          
        -- Garantir somente data at�
        ELSIF vr_dataat IS NOT NULL THEN 
          -- Data Refere, envi ou retorno tem de ser inferior
          IF trunc(rw_arquiv.dtregistro) > vr_dataat 
          AND trunc(NVL(rw_arquiv.dtdenvio,rw_arquiv.dtregistro)) > vr_dataat 
          AND trunc(NVL(rw_arquiv.dtdretor,rw_arquiv.dtregistro)) > vr_dataat THEN 
            -- Ignorar este arquivo
            CONTINUE;
          END IF; 
        END IF; 
      END IF;
      
      -- Caso algum par�metro de filtro de aplica��o tenha sido informado
      IF pr_cdcooper <> '0' OR trim(pr_nrdconta) IS NOT NULL 
      OR pr_nraplica <> '0' OR pr_flgcritic <> 'N'  
      OR trim(pr_nmarquiv) IS NOT NULL OR trim(pr_dscodib3) IS NOT NULL THEN             
        -- Devemos testar se o arquivo de envio ou de retorno 
        -- atenda aos crit�rios dos filtros informados
        OPEN cr_aplica(rw_arquiv.idarqenv,rw_arquiv.idarqret);
        FETCH cr_aplica
         INTO vr_idexiste;
        -- Se n�o encontrar, ignorar este
        IF cr_aplica%NOTFOUND THEN
          CLOSE cr_aplica;
          CONTINUE;
        ELSE
          CLOSE cr_aplica;
        END IF;
      END IF;

      -- Incrementa o contador de registros
      vr_posreg := vr_posreg + 1;

      -- Carrega os dados
      GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<arq>'||
                                '<dstiparq>' || rw_arquiv.dstiparq ||'</dstiparq>'||
                                '<dstipext>' || rw_arquiv.dstiparq_ext ||'</dstipext>'||
                                '<dtrefere>' 
                                   || to_char(rw_arquiv.dtregistro,'dd/mm/rr')||
                                '</dtrefere>'||     
                                '<idarqenv>' || rw_arquiv.idarqenv ||'</idarqenv>'||
                                '<tpopeenv>' || rw_arquiv.tpopeenv ||'</tpopeenv>'||
                                '<nmarqenv>' || rw_arquiv.nmarqenv ||'</nmarqenv>'||
                                '<dssitenv>' || rw_arquiv.dssitenv ||'</dssitenv>'||
                                '<dtdenvio>' 
                                   || to_char(rw_arquiv.dtdenvio,'dd/mm/rr hh24:mi:ss')||
                                '</dtdenvio>'||
                                '<idarqret>' || rw_arquiv.idarqret ||'</idarqret>'||
                                '<tpoperet>' || rw_arquiv.tpoperet ||'</tpoperet>'||
                                '<nmarqret>' || rw_arquiv.nmarqret ||'</nmarqret>'||
                                '<dssitret>' || rw_arquiv.dssitret ||'</dssitret>'||
                                '<dtdretor>' 
                                   || to_char(rw_arquiv.dtdretor,'dd/mm/rr hh24:mi:ss')||
                                '</dtdretor>'||
                              '</arq>');
      vr_contador := vr_contador + 1;
    END LOOP;  

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</lstarqv></Root>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Atualizar o atributo com quantidade de registro caso maior que zero
    IF vr_contador > 0 THEN 
      -- Atualizar atributo contador
      gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'lstarqv'
                                 ,pr_atrib    => 'qtregist'
                                 ,pr_atval    => vr_contador
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);
    END IF;

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_arquivos --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_lista_arquivos;
  
  /* Procedimento para retornar o LOG do arquivo repassado nos par�metros */
  PROCEDURE pc_lista_log_arquivo(pr_idarquivo in VARCHAR2          -- C�digo na B3
                                ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_log_arquivo
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedimento para retornar o LOG do arquivo repassado nos par�metros
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
           
    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_posreg   PLS_INTEGER := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
   
    
    -- Busca dos Logs do Arquivo
    CURSOR cr_logs is
      SELECT to_char(dtlog,'dd/mm/rrrr hh24:mi:ss') dtlog
            ,dslog
            ,count(1) over() retorno
        FROM tbcapt_custodia_log
       WHERE idarquivo = pr_idarquivo
       ORDER by idlog;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_lista_log_arquivo'); 
                                 
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
    
    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root>');        

    -- Retornar todos os eventos de LOGs do Arquivo
    FOR rw_log IN cr_logs LOOP 
      
      -- Incrementa o contador de registros
      vr_posreg := vr_posreg + 1;

      -- Se for o primeiro registro, insere uma tag com o total de registros existentes 
      IF vr_posreg = 1 THEN
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<lstlogs qtregist="' 
                                                  || rw_log.retorno || '">');
      END IF;

      -- Carrega os dados
      GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<log>'||
                                '<dtlog>' || rw_log.dtlog ||'</dtlog>'||
                                '<dslog>' || rw_log.dslog ||'</dslog>'||
                              '</log>');
        vr_contador := vr_contador + 1;

    END LOOP;      

    -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
    IF vr_posreg = 0 THEN
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<lstlogs qtregist="0">');
    END IF;

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</lstlogs></Root>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_log_arquivo --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_lista_log_arquivo;
  
  /* Procedimento para retornar o conte�do do arquivo */
  PROCEDURE pc_lista_conteudo_arquivo(pr_idarquivo in VARCHAR2          -- C�digo na B3
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_conteudo_arquivo
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedimento para retornar o conte�do do arquivo repassado nos par�metros
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
           
    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_posreg   PLS_INTEGER := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_dssituac VARCHAR2(100);
   
    -- Busca do conte�do do Arquivo
    Cursor cr_cont is
      SELECT cont.nrseq_linha
            ,lancto.idlancamento
            ,NVL(aplica.dscodigo_b3,cont.dscodigo_b3) dscodigo_b3
            ,aplica.idaplicacao
            ,aplica.tpaplicacao
            ,lancto.cdhistorico
            ,apli0007.fn_tpregistro_custodia(lancto.idtipo_lancto,'A') cdtiplcto
            ,to_char(lancto.vlregistro,'fm999g999g999g990d00') vllancto
            ,lancto.idsituacao
            ,gene0007.fn_caract_controle(cont.dscritica) dscritic
            ,arq.idtipo_arquivo
            ,count(1) over() retorno
        FROM tbcapt_custodia_arquivo      arq 
            ,tbcapt_custodia_conteudo_arq cont
            ,tbcapt_custodia_lanctos      lancto
            ,tbcapt_custodia_aplicacao    aplica
       WHERE cont.idaplicacao  = aplica.idaplicacao (+)
         AND cont.idlancamento = lancto.idlancamento (+)
         AND cont.idarquivo = arq.idarquivo
         AND arq.idarquivo  = pr_idarquivo
         AND cont.idtipo_linha = 'L' /* Somente Linhas */ 
       ORDER by cont.nrseq_linha;

      
    -- Busca dos detalhes da Aplicacao
    Cursor cr_aplica(pr_tpaplica number
                    ,pr_idaplica number) is
      Select apl.cdcooper || '-' || Initcap(cop.nmrescop) dscooper
            ,gene0002.fn_mask_conta(apl.nrdconta) nrdconta
            ,apl.nraplica
            ,apli0007.fn_tip_aplica(cop.cdcooper,pr_tpaplica,apl.nrdconta,apl.nraplica) dstpapli
        from crapcop cop
            ,(Select rda.cdcooper
                    ,rda.nrdconta
                    ,rda.nraplica
                from craprda rda
               where pr_tpaplica in(1,2)
                 and rda.idaplcus = pr_idaplica
               union
              Select rac.cdcooper
                    ,rac.nrdconta
                    ,rac.nraplica
                from craprac rac 
               where pr_tpaplica = 3
                 and rac.idaplcus = pr_idaplica) apl
       where cop.cdcooper = apl.cdcooper;
    rw_aplica cr_aplica%rowtype; 
      
    -- Checar se existe envio posterior para o mesmo lan�amento
    CURSOR cr_reenvio(pr_idlancamento number) IS      
      SELECT 'Sim'
        FROM tbcapt_custodia_conteudo_arq cont
            ,tbcapt_custodia_arquivo arq
       WHERE cont.idarquivo    = arq.idarquivo
         AND cont.idarquivo    < pr_idarquivo
         AND cont.idlancamento = pr_idlancamento
         AND arq.idtipo_operacao = 'E'; /* Somente de Envio */
    vr_idreenvi Varchar2(3);
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_lista_conteudo_arquivo'); 
                                 
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
    
    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabe�alho do XML
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root>');

      
    -- Retornar todos os eventos de LOGs do Arquivo
    FOR rw_cont IN cr_cont LOOP 
      
      -- Incrementa o contador de registros
      vr_posreg := vr_posreg + 1;

      -- Se for o primeiro registro, insere uma tag com o total de registros existentes 
      IF vr_posreg = 1 THEN
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<lstcont qtregist="'||rw_cont.retorno||'">');
      END IF;

      -- Buscar dados da aplica��o
      rw_aplica := NULL;
      IF rw_cont.idaplicacao IS NOT NULL THEN 
        OPEN cr_aplica(rw_cont.tpaplicacao,rw_cont.idaplicacao);
        FETCH cr_aplica 
         INTO rw_aplica;
        CLOSE cr_aplica; 
      END IF;  

      -- Checar se existe envio posterior para o mesmo lan�amento
      vr_idreenvi := 'N�o';
      OPEN cr_reenvio(rw_cont.idlancamento);
      FETCH cr_reenvio
       INTO vr_idreenvi;
      CLOSE cr_reenvio; 
      
      vr_dssituac := '???';
      -- Caso tenhamos critica 
      IF rw_cont.dscritic IS NOT NULL OR rw_cont.idsituacao = 9 THEN
        vr_dssituac := 'Erro';
      ELSE
        -- Preencher situa��o conforme situa��o do lan�amento
        IF rw_cont.idsituacao = 0 THEN
          vr_dssituac := 'Pend. Envio';
        ELSIF rw_cont.idsituacao = 1 THEN
          vr_dssituac := 'Enviado';
        ELSIF rw_cont.idsituacao = 2 THEN
          vr_dssituac := 'Pend. Reenvio';
        ELSIF rw_cont.idsituacao = 3 THEN
          vr_dssituac := 'Reenviado';  
        ELSIF rw_cont.idsituacao = 8 THEN
          vr_dssituac := 'Custodiado';  
        ELSIF rw_cont.idsituacao IS NULL AND rw_cont.idtipo_arquivo = 9 THEN
          vr_dssituac := 'Conciliado'; 
        END IF;  
      END IF;
                                       

      -- Carrega os dados ao XML
      GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<cont>'||
                                '<nrseqlin>' || rw_cont.nrseq_linha || '</nrseqlin>'||
                                '<dscodib3>' || rw_cont.dscodigo_b3 ||'</dscodib3>'||
                                '<dscooper>' || rw_aplica.dscooper ||'</dscooper>'||                                
                                '<nrdconta>' || rw_aplica.nrdconta ||'</nrdconta>'||
                                '<nraplica>' || rw_aplica.nraplica ||'</nraplica>'||
                                '<dstpapli>' || rw_aplica.dstpapli ||'</dstpapli>'||
                                '<cdhistor>' || rw_cont.cdhistorico || '</cdhistor>'||
                                '<cdtipreg>'||rw_cont.cdtiplcto||'</cdtipreg>'||
                                '<vllancto>' || rw_cont.vllancto ||'</vllancto>'||
                                '<idreenvi>' || vr_idreenvi ||'</idreenvi>'||
                                '<dssituac>' || vr_dssituac ||'</dssituac>'||
                                '<dscritic>' || gene0007.fn_caract_acento(rw_cont.dscritic) ||'</dscritic>'||
                              '</cont>');
      vr_contador := vr_contador + 1;

    END LOOP;      

    -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
    IF vr_posreg = 0 THEN
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<lstcont qtregist="0">');
    END IF;

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</lstcont></Root>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_conteudo_arquivo --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_lista_conteudo_arquivo;
  
  /* Procedimento para retornar a Opera��es para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_operacoes(pr_cdcooper in VARCHAR2           -- Cooperativa selecionada (0 para todas)
                              ,pr_nrdconta in VARCHAR2           -- Conta informada
                              ,pr_nraplica in VARCHAR2           -- Aplica��o Informada (0 para todas)
                              ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                              ,pr_datade   in VARCHAR2           -- Data de 
                              ,pr_datate   in VARCHAR2           -- Date at�
                              ,pr_nmarquiv in VARCHAR2           -- Nome do arquivo para busca
                              ,pr_dscodib3 in VARCHAR2           -- C�digo na B3
                              ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                              ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_operacoes
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca Opera��es de Cust�dia pendentes conforme par�metros repassados
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
           
    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_posreg   PLS_INTEGER := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_datade   date;
    vr_dataat   date;
    
    -- Busca das Opera��es Pendentes
    cursor cr_operac IS
      SELECT lancto.idlancamento
            ,apl.idaplicacao
            ,apl.tpaplicacao
            ,apl.dscodigo_b3
            ,lancto.cdhistorico
            ,lancto.dtregistro
            ,apli0007.fn_tpregistro_custodia(lancto.idtipo_lancto,'A') cdtiplcto
            ,to_char(lancto.vlregistro,'fm999g999g999g990d00') vllancto
            ,lancto.idsituacao
            ,decode(lancto.idsituacao,0,'Pend. Envio'
                                     ,1,'Enviado'
                                     ,2,'Pend. Reenvio'
                                     ,3,'Reenviado'
                                     ,8,'Custodiado'
                                     ,9,'Erro'
                                     ,'???') dssituac
            
        FROM tbcapt_custodia_lanctos      lancto
            ,tbcapt_custodia_aplicacao    apl
       WHERE lancto.idaplicacao  = apl.idaplicacao
         AND lancto.idsituacao IN(0,2,9) -- Somente situa��es de erro
         AND ( NVL(pr_flgcritic,'N') = 'N' OR lancto.idsituacao = 9 )
         AND ( trim(pr_dscodib3) IS NULL 
               or upper(apl.dscodigo_b3) like '%'||upper(trim(pr_dscodib3))||'%')
       ORDER by lancto.idlancamento DESC;
    
    -- Caso enviado arquivo de filtro, garantir que o lan�amento esteja em algum arquivo com o padr�o de nome enviado
    CURSOR cr_arquivo(pr_idlancamento IN NUMBER) IS
      SELECT 'S'
        FROM tbcapt_custodia_arquivo arq
            ,tbcapt_custodia_conteudo_arq cnt
       WHERE arq.idarquivo = cnt.idarquivo
         AND cnt.idlancamento = pr_idlancamento
         AND arq.nmarquivo LIKE '%'||pr_nmarquiv||'%';
    vr_idexiste VARCHAR2(1);     
    
    -- Garantir que a aplica��o vinculada esteja de acordo com 
    -- os filtros enviados ou que haja registro de cr�tica 
    CURSOR cr_aplica(pr_tpaplicacao IN NUMBER
                    ,pr_idaplicacao IN NUMBER) IS
      SELECT aplica.cdcooper||'-'||Initcap(cop.nmrescop) dscooper
            ,aplica.nrdconta
            ,aplica.nraplica
            ,apli0007.fn_tip_aplica(aplica.cdcooper,pr_tpaplicacao,aplica.nrdconta,aplica.nraplica) dstpapli
        FROM( SELECT rda.cdcooper
                    ,rda.nrdconta
                    ,rda.nraplica
                FROM craprda RDA
               WHERE pr_tpaplicacao in(1,2)
                 AND RDA.idaplcus = pr_idaplicacao
                 AND (pr_cdcooper = 0 or RDA.cdcooper = pr_cdcooper)
                 AND (trim(pr_nrdconta) IS NULL or RDA.nrdconta = pr_nrdconta)
                 
                 AND (pr_nraplica = '0' 
                      OR (    gene0002.fn_busca_entrada(1,pr_nraplica,'_') = 'A'
                          AND gene0002.fn_busca_entrada(3,pr_nraplica,'_') = to_char(RDA.nraplica)
                         ) 
                     )
              UNION
              SELECT rac.cdcooper
                    ,rac.nrdconta
                    ,rac.nraplica
                FROM craprac RAC
               WHERE pr_tpaplicacao = 3
                 AND RAC.idaplcus = pr_idaplicacao
                 AND (pr_cdcooper = 0 or RAC.cdcooper = pr_cdcooper)
                 AND (trim(pr_nrdconta) IS NULL or RAC.nrdconta = pr_nrdconta)
                 AND (pr_nraplica = '0'
                      OR (    gene0002.fn_busca_entrada(1,pr_nraplica,'_') = 'N'
                          AND gene0002.fn_busca_entrada(3,pr_nraplica,'_') = to_char(RAC.nraplica)
                         )
                      )
              ) aplica
             ,crapcop cop
         WHERE aplica.cdcooper = cop.cdcooper;
    rw_aplica cr_aplica%ROWTYPE;
      
    -- Checar se existe envio posterior para o mesmo lan�amento
    CURSOR cr_reenvio(pr_idlancamento number) IS      
      SELECT COUNT(1) qtdenvios
        FROM tbcapt_custodia_conteudo_arq cont
            ,tbcapt_custodia_arquivo arq
       WHERE cont.idarquivo    = arq.idarquivo
         AND cont.idlancamento = pr_idlancamento
         AND arq.idtipo_operacao = 'E'; /* Somente de Envio */
    vr_idreenvio VARCHAR2(3);
    vr_qtdenvios NUMBER;
    
    -- Busca da Critica quando situa��o Erro 
    CURSOR cr_critica(pr_idlancamento number) IS      
      SELECT gene0007.fn_caract_controle(cont.dscritica) dscritica
        FROM tbcapt_custodia_conteudo_arq cont
       WHERE cont.idlancamento = pr_idlancamento
         AND cont.dscritica IS NOT NULL
       ORDER BY cont.idarquivo DESC, cont.nrseq_linha;
    vr_dscritica tbcapt_custodia_conteudo_arq.dscritica%TYPE; 

  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_lista_operacoes'); 
                                 
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
    
    -- Validar os par�metros data
    IF trim(pr_datade) IS NOT NULL THEN 
      Begin
        vr_datade := to_date(pr_datade,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data de ['||pr_datade||'] inv�lida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    -- Validar os par�metros data
    IF trim(pr_datate) IS NOT NULL THEN 
      Begin
        vr_dataat := to_date(pr_datate,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data at� ['||pr_datate||'] inv�lida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    -- Se enviada as duas datas, temos de validar se at� n�o � inferior a De
    IF vr_datade IS NOT NULL AND vr_dataat IS NOT NULL THEN       
      IF vr_datade > vr_dataat THEN
        vr_dscritic := 'Data De n�o pode ser superior a Data At�!';
        RAISE vr_exc_Erro;
      END IF;
    END IF;

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><lstaope qtregist="0">');    

    -- Retornar os arquivos conforme filtros informados
    FOR rw_ope IN cr_operac LOOP 
          
      -- Garantir data de e at� quando temos as duas
      IF vr_datade IS NOT NULL AND vr_dataat IS NOT NULL THEN           
        -- Data Registro tem de estar no per�odo
        IF rw_ope.dtregistro NOT BETWEEN vr_datade AND vr_dataat THEN 
          -- Ignorar este
          CONTINUE;
        END IF;
      -- Garantir somente Data De
      ELSIF vr_datade IS NOT NULL THEN 
        -- Data Registro tem de ser posterior A Data De
        IF rw_ope.dtregistro < vr_datade THEN 
          -- Ignorar este arquivo
          CONTINUE;
        END IF;                          
      -- Garantir somente data at�
      ELSIF vr_dataat IS NOT NULL THEN 
        -- Data Registro tem de ser inferior A Data At�
        IF rw_ope.dtregistro > vr_dataat THEN 
          -- Ignorar este arquivo
          CONTINUE;
        END IF; 
      END IF; 
      
      -- Buscar aplicaca��o correspondente
      OPEN cr_aplica(rw_ope.tpaplicacao,rw_ope.idaplicacao);
      FETCH cr_aplica
       INTO rw_aplica;
      -- Se n�o encontrar, ignorar o registro pois ele n�o satisfaz os filtros
      IF cr_aplica%NOTFOUND THEN
        CLOSE cr_aplica;
        continue;
      ELSE
        CLOSE cr_aplica;
      END IF;
      
      -- Caso enviado arquivo de filtro, garantir que o lan�amento esteja em algum arquivo com o padr�o de nome enviado
      IF pr_nmarquiv IS NOT NULL THEN 
        vr_idexiste := 'N';
        OPEN cr_arquivo(rw_ope.idlancamento);
        FETCH cr_arquivo
         INTO vr_idexiste;
        CLOSE cr_arquivo;
      END IF;      
      -- Se n�o encontrou  
      IF vr_idexiste = 'N' THEN 
        continue;
      END IF;
      
      -- Incrementa o contador de registros
      vr_posreg := vr_posreg + 1;

      -- Checar se existe envio posterior para o mesmo lan�amento
      vr_qtdenvios := 0;
      vr_idreenvio := 'N�o';
      OPEN cr_reenvio(rw_ope.idlancamento);
      FETCH cr_reenvio
       INTO vr_qtdenvios;
      CLOSE cr_reenvio;  
      IF vr_qtdenvios > 0 THEN
        vr_idreenvio := 'Sim';
      END IF;
      
      -- Caso registro tenha critica
      vr_dscritica := NULL;
      IF rw_ope.idsituacao = 9 THEN 
        -- Busca da Critica quando situa��o Erro 
        OPEN cr_critica(rw_ope.idlancamento);
        FETCH cr_critica
         INTO vr_dscritica;
        CLOSE cr_critica; 
      END IF;
      
      -- Carrega os dados
      GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<ope>'||
                                '<idlancto>' || rw_ope.idlancamento ||'</idlancto>'||
                                '<dscodib3>' || rw_ope.dscodigo_b3 ||'</dscodib3>'||
                                
                                '<dscooper>' || rw_aplica.dscooper ||'</dscooper>'||                                
                                '<nrdconta>' || rw_aplica.nrdconta ||'</nrdconta>'||
                                '<nraplica>' || rw_aplica.nraplica ||'</nraplica>'||
                                
                                '<dstpapli>' || rw_aplica.dstpapli ||'</dstpapli>'||
                                '<dtrefere>' || to_char(rw_ope.dtregistro,'dd/mm/rrrr') ||'</dtrefere>'||
                                
                                '<cdhistor>' || rw_ope.cdhistorico || '</cdhistor>'||
                                '<cdtipreg>' || rw_ope.cdtiplcto ||'</cdtipreg>'||
                                '<vllancto>' || rw_ope.vllancto ||'</vllancto>'||
                                '<idreenvi>' || vr_idreenvio ||'</idreenvi>'||
                                '<dssituac>' || rw_ope.dssituac ||'</dssituac>'||
                                '<dscritic>' || gene0007.fn_caract_acento(vr_dscritica) ||'</dscritic>'||
                              '</ope>');
      vr_contador := vr_contador + 1;
    END LOOP;  

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</lstaope></Root>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Atualizar o atributo com quantidade de registro caso maior que zero
    IF vr_contador > 0 THEN 
      -- Atualizar atributo contador
      gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'lstaope'
                                 ,pr_atrib    => 'qtregist'
                                 ,pr_atval    => vr_contador
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);
    END IF;

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_arquivos --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_lista_operacoes; 
  
    
  /* Procedimento para Solicitar o Envio de Arquivos Pendentes na hora */
  PROCEDURE pc_solicita_envio(pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_solicita_envio
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Efetuar a chamada a rotina de envio dos lan�amentos para a B3 na hora
    
    Altera��es : 

  -------------------------------------------------------------------------------------------------------------*/                                
  
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    -- Variaveis para a chamada do envio
    vr_dsinform VARCHAR2(4000);
  BEGIN 
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_solicita_envio'); 
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
    -- Direcionar a chamada a rotina de envio
    apli0007.pc_processo_controle(pr_tipexec  => 2 -- Envios pendentes
                                 ,pr_dsinform => vr_dsinform
                                 ,pr_dscritic => vr_dscritic);
    -- Em caso de erro 
    IF vr_dscritic IS NOT NULL THEN    
      RAISE vr_exc_erro;      
    END IF;     
    -- Criar retorno do aviso gerado no processo
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Aviso>' ||vr_dsinform|| '</Aviso></Root>');    
    -- Retorno OK
    pr_des_erro := 'OK';
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN 
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN 
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_solicita_envio --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_solicita_envio;  
  
   /* Procedimento para Solicitar o Retorno e Processamento de Arquivos Pendentes na hora */
   PROCEDURE pc_solicita_retorno(pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_solicita_retorno
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Efetuar a chamada a rotina de retorno e concilia��o dos arquivos da B3 na hora
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    -- Variaveis para a chamada do envio
    vr_dsinform VARCHAR2(4000);
  BEGIN 
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_solicita_concili'); 
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

    -- Direcionar a chamada a rotina de envio
    apli0007.pc_processo_controle(pr_tipexec  => 3 -- Retornos pendentes
                                 ,pr_dsinform => vr_dsinform
                                 ,pr_dscritic => vr_dscritic);
    -- Em caso de erro 
    IF vr_dscritic IS NOT NULL THEN    
      RAISE vr_exc_erro;      
    END IF;

    -- Criar retorno do aviso gerado no processo
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Aviso>' ||vr_dsinform|| '</Aviso></Root>');    
    -- Retorno OK
    pr_des_erro := 'OK';
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN 
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN 
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_solicita_retorno --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_solicita_retorno;
  
  /* Procedimento para Solicitar a altera��o da situa��o dos registros com erro para Reenvio */
  PROCEDURE pc_solicita_reenvio(pr_dsdlista IN VARCHAR2           -- Lista de Lan�amentos Selecionados
                               ,pr_xmllog   IN VARCHAR2           -- XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       -- C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2          -- Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_solicita_reenvio
    Autor    : Marcos - Envolti
    Data     : Mar�o/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Efetuar a altera��o da situa��o de registros com erro para Reenvio Solicitado.
    
    Altera��es : 

    -------------------------------------------------------------------------------------------------------------*/                                
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    -- Variaveis para retorno
    vr_dsinform VARCHAR2(4000);
    vr_qtdregis NUMBER := 0;
  BEGIN 
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_solicita_reenvio'); 
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
    
    -- Caso n�o tenha sido enviada a listadem de lan�amentos para solicitar re-envio
    IF trim(pr_dsdlista) IS NULL THEN 
      vr_dscritic := 'Lista de Opera��es para Re-envio n�o enviada!';
      RAISE vr_exc_erro;
    END IF;
    
    -- Efetuar UPDATE dos registros para alterar sua situa��o para Re-envio
    -- e fazer com que os registros sejam reprocessados no pr�ximo Envio
    BEGIN 
      UPDATE tbcapt_custodia_lanctos lct
         SET lct.idsituacao = 2 /*Pendente de Reenvio*/
       WHERE lct.idsituacao = 9 /*Erro*/
         AND ';'||pr_dsdlista  LIKE '%;'||lct.idlancamento||';%';
      vr_qtdregis := SQL%ROWCOUNT; -- Linhas afetadas
    EXCEPTION
      WHEN OTHERS THEN
        -- Erro n�o tratado 
        vr_cdcritic := 1035;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_lanctos: '
                    || 'idsituacao: 2' 
                    || ' com idsituacao = 9 '
                    || ' ,idlancamento like '|| pr_dsdlista ||'. '||sqlerrm;
        RAISE vr_exc_erro;     
    END;    
    
    -- Montagem do alerta conforme a quantidade de registros marcados 
    IF vr_qtdregis > 0 THEN 
      vr_dsinform := 'Processo efetuado com sucesso! '||'Total de registros marcados para Re-envio: '||vr_qtdregis;
    ELSE 
      vr_dsinform := 'Problema no processo de Re-envio! Nenhum registro selecionado estava com situa��o que permitisse Re-Envio';
    END IF;
      
    -- Criar retorno do aviso gerado no processo
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Aviso>' ||vr_dsinform|| '</Aviso></Root>');    
    -- Retorno OK
    pr_des_erro := 'OK';
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN 
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN 
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_solicita_concili --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_solicita_reenvio;
  
END TELA_CUSAPL;
/
