CREATE OR REPLACE PACKAGE CECRED.TELA_CUSAPL AS

   /*
   Programa: TELA_CUSAPL
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Marcos - Envolti
   Data    : Março/2018                       Ultima atualizacao: 01/06/2019

   Dados referentes ao programa:

   Frequencia: On-line
   Objetivo  : Manter as rotinas para a tela CUSAPL - Que trazer insformações da
               Custódia das Aplicações junto ao

   Alteracoes: 
      01/06/2019 - Ajustes telas A e O (Envolti - David / Belli - PJ_411_Fase_2_Parte_2)

   */  
   
   /* Função que retorna concatenado código e descrição da cooperativa do arquivo informado */   
   FUNCTION fn_get_desc_cooper (pr_idarquivo IN tbcapt_custodia_conteudo_arq.idarquivo%type
                               ,pr_cdcooper  IN VARCHAR2   
     ) 
      RETURN VARCHAR2;
   
   
   /* Procedimento para retornar os parâmetros gravados em Sistema por Cooperativa */
   PROCEDURE pc_busca_parametros_coop(pr_tlcdcooper IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK        
                                
  /* Procedimento para retornar os parâmetros gravados em Sistema por Cooperativa */
  PROCEDURE pc_gravac_parametros_coop(pr_tlcdcooper  IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_datab3    in VARCHAR2           -- Data de Habilitação Custódia 
                                     ,pr_vlminb3   IN VARCHAR2           -- Valor mínimo de aplicação para custódia na B3
                                     ,pr_cdregtb3  in VARCHAR2           -- Padrão do nome do arquivo 
                                     ,pr_cdfavrcb3 in VARCHAR2           -- Lista de email para alertas no processo
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK   
   
   /* Procedimento para retornar os parâmetros gravados em Sistema */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK        
                                
  /* Procedimento para retornar os parâmetros gravados em Sistema */
  PROCEDURE pc_gravac_parametros(pr_nomarq   in VARCHAR2           -- Padrão do nome do arquivo 
                                ,pr_dsmail   in VARCHAR2           -- Lista de email para alertas no processo
                                ,pr_hrinicio in VARCHAR2           -- Hora de início da comunicação com B3
                                ,pr_hrfinal  in VARCHAR2           -- Hora final de comunicação com B3
                                ,pr_reghab   in VARCHAR2           -- Envio Habilitado ? 
                                ,pr_rgthab   in VARCHAR2           -- Retorno Habilitado ? 
                                ,pr_cnchab   in VARCHAR2           -- Exclusão Habilitada ? 
								,pr_perctolval IN NUMBER           -- Parametro de tolerancia de conciliação																			  
                                ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar os arquivos para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_arquivos(pr_cdcooper in VARCHAR2           -- Cooperativa selecionada (0 para todas)
                             ,pr_nrdconta in VARCHAR2           -- Conta informada
                             ,pr_nraplica in VARCHAR2           -- Aplicação Informada (0 para todas)
                             ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                             ,pr_datade   in VARCHAR2           -- Data de 
                             ,pr_datate   in VARCHAR2           -- Date até
                             ,pr_nmarquiv in VARCHAR2           -- Nome do arquivo para busca
                             ,pr_dscodib3 in VARCHAR2           -- Código na B3
                             ,pr_nriniseq  IN VARCHAR2           --> Numero do primeiro registro a ser retornado
                             ,pr_qtregist  IN VARCHAR2           --> Numero de registros a serem retornados
                             ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar o LOG do arquivo repassado nos parâmetros */
  PROCEDURE pc_lista_log_arquivo(pr_idarquivo in VARCHAR2          -- Código na B3
                                ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar o conteúdo do arquivo */
  PROCEDURE pc_lista_conteudo_arquivo(pr_cdcooper IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                     ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                     ,pr_nraplica IN VARCHAR2           -- Aplicação Informada (0 para todas)
                                     ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                                     ,pr_datade   IN VARCHAR2           -- Data de 
                                     ,pr_datate   IN VARCHAR2           -- Date até
                                     ,pr_nmarquiv IN VARCHAR2           -- Nome do arquivo para busca
                                     ,pr_dscodib3 IN VARCHAR2           -- Código na B3
                                     ,pr_inacao    IN VARCHAR2 DEFAULT 'TELA' -- Ação TELA-Nao ativa Expor., CSV-Ativa exportação csv
                                     ,pr_nrregist  IN VARCHAR2                -- Numero de registros a serem retornados
                                     ,pr_nriniseq  IN VARCHAR2                -- Numero do primeiro registro a ser retornado
                                     ,pr_idarquivo IN VARCHAR2                -- Identificação do arquivo
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar a Operações para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_operacoes(pr_cdcooper in VARCHAR2           -- Cooperativa selecionada (0 para todas)
                              ,pr_nrdconta in VARCHAR2           -- Conta informada
                              ,pr_nraplica in VARCHAR2 DEFAULT '0'  -- Aplicação Informada (0 para todas)
                              ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                              ,pr_datade   in VARCHAR2           -- Data de 
                              ,pr_datate   in VARCHAR2           -- Date até
                              ,pr_nmarquiv in VARCHAR2           -- Nome do arquivo para busca
                              ,pr_dscodib3 in VARCHAR2           -- Código na B3
                              ,pr_nrregist IN VARCHAR2           --> Numero de registros a serem retornados
                              ,pr_nriniseq IN VARCHAR2           --> Numero do primeiro registro a ser retornado
                              ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                              ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK
                                
  /* Procedimento para retornar o histórico da aplicação*/
  PROCEDURE pc_historico_aplicacao(pr_idaplicacao IN VARCHAR2        -- Aplicação Informada (0 para todas)
                                  ,pr_nriniseq IN VARCHAR2           --> Numero do primeiro registro a ser retornado
                                  ,pr_nrregist IN VARCHAR2           --> Numero de registros a serem retornados
                                  ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);       -- Saida OK/NOK
                                
  /* Procedimento para Solicitar o Envio de Arquivos Pendentes na hora */
  PROCEDURE pc_solicita_envio(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK
                             
  /* Procedimento para Solicitar o Retorno e Processamento de Arquivos Pendentes na hora */
  PROCEDURE pc_solicita_retorno(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK                                                              
                               
  /* Procedimento para Solicitar a alteração da situação dos registros com erro para Reenvio */
  PROCEDURE pc_solicita_reenvio(pr_dsdlista IN VARCHAR2           -- Lista de Lançamentos Selecionados
                               ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK
  
  -- Procedimento de Log - tabela: tbgen prglog ocorrencia - 03/04/2019 - PJ411_F2_P2
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscrilog IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN NUMBER   DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT 'TELA_CUSAPL' -- Null assume nome da Package
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  );  

  -- Procedimento para tratar custo fornecedor aplicação - B3 - 03/04/2019 - PJ411_F2_P2
  PROCEDURE pc_trt_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                 ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                 ,pr_dtde     IN VARCHAR2           -- Data de 
                                 ,pr_dtate    IN VARCHAR2           -- Date até
                                 ,pr_tpproces IN NUMBER             -- Tipo: 1 - Gera, 2 - Consulta, 3 - Caminho CSV
                                 ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                 );

  -- Executa geração do custo fornecedor aplicação - B3
  PROCEDURE pc_exe_grc_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                     ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                     ,pr_dtde     IN VARCHAR2           -- Data de 
                                     ,pr_dtate    IN VARCHAR2           -- Date até
                                     );
                                                                              
  -- Trata a tabela de parâmetro de custo de investidor para de conciliação - 01/04/2019 - PJ411_F2
  PROCEDURE pc_conciliacao_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
    );

  -- Trata a tabela de parâmetro de custo de investidor para de conciliação
  PROCEDURE pc_pos_faixa_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv IN NUMBER
    ,pr_vlentrad IN NUMBER
    ,pr_idasitua OUT NUMBER
    ,pr_pctaxmen OUT NUMBER
    ,pr_vladicio OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
    );

  -- 
  PROCEDURE pc_concil_tab_investidor(pr_cdmodulo IN VARCHAR2           -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa selecionada (0 para todas)
                                 ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                 );
    
  -- Atualiza tabela investidor
  PROCEDURE pc_atz_faixa_tab_investidor(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                       );

               

END TELA_CUSAPL;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CUSAPL AS
   
  vr_nmpackge  CONSTANT  VARCHAR2(100) := 'TELA_CUSAPL';
  -- Variaveis para e-mail
  vr_cdcooper  NUMBER       (2) := 0;
  vr_dsemldst  VARCHAR2  (4000) := NULL;
  vr_dsassunt  VARCHAR2  (4000) := NULL;
  vr_dscorpo   VARCHAR2 (32700) := NULL;
  --
  vr_fgtempro  BOOLEAN := FALSE;
  --
  vr_inabr_arq_cri_pro_con BOOLEAN      := false;
  vr_inabr_arq_msg_pro_con BOOLEAN      := false;
  vr_inabr_arq_cri_exe_cus BOOLEAN      := false;

  vr_inabr_arq_csv_exe_cus BOOLEAN      := false; 
  --
  vr_nmarq001_critic  VARCHAR2    (100);
  vr_nmdir001_critic  VARCHAR2    (100);
  vr_nmtip001_critic  VARCHAR2      (5);
  vr_dshan001_critic  utl_file.file_type;  
  --
  vr_nmarq001_csv     VARCHAR2    (100);
  vr_nmdir001_csv     VARCHAR2    (100);
  vr_nmtip001_csv     VARCHAR2      (5);
  vr_dshan001_csv     utl_file.file_type; 
  --
  vr_nmarq001_html   VARCHAR2    (100);
  vr_nmdir001_html   VARCHAR2    (100);

  -- Tratamento de criticas
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(32767);
  vr_des_reto  VARCHAR2(3);
  vr_tab_erro  cecred.gene0001.typ_tab_erro;
  -- Variavel para setar parametro para log - 03/04/2019 - PJ411_F2
  vr_nmaction  VARCHAR2    (32) := vr_nmpackge || '.pc_nao_definida';
  vr_dsparame  VARCHAR2  (4000) := NULL;
  -- Variavel para setar pck e e-mail de criticas - 03/04/2019 - PJ411_F2
  vr_dsacseml CONSTANT  VARCHAR2(30) := 'DES_EMAILS_PROC_B3'; 
  vr_dslisane  VARCHAR2  (4000);
  vr_dslinha   VARCHAR2  (4000); 
  -- Troca diretorio de 1 para 3 porque o executor é a coooper central - 03/04/2019 - PJ411_F2_P2
  vr_dsdirarq CONSTANT VARCHAR2(30) := gene0001.fn_diretorio('C',3,'arq'); -- Diretório temporário para arquivos
  -- 

  -- Variaveis gerais - 01/04/2019 - PJ411_F2
  vr_dtdiaapl     NUMBER (8);
  vr_vlacudia     NUMBER(25,9);
  vr_dtini        NUMBER (8);
  vr_dtfim        NUMBER (8);
  vr_cdacesso     crapprm.cdacesso%TYPE;

  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_reg_tabinv IS
        RECORD(idfrninv  tbcapt_custodia_frn_investidor.idfrninv%TYPE
              ,vlfaixde  tbcapt_custodia_frn_investidor.vlfaixade%TYPE
              ,vlfaixate tbcapt_custodia_frn_investidor.vlfaixaate%TYPE
              ,pctaxmen  tbcapt_custodia_frn_investidor.petaxa_mensal%TYPE
              ,vladicio  tbcapt_custodia_frn_investidor.vladicional%TYPE
              );
              
  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_tab_tabinv IS TABLE OF typ_reg_tabinv INDEX BY VARCHAR2(40);  
  vr_tab_tabinv  typ_tab_tabinv;  

  -- Type criado para acumular valores por dia e melhorar a performance
  TYPE typ_reg_diavlr IS
        RECORD(dtdiaapl NUMBER (8)
              ,vlacudia NUMBER(25,9)
              );              
  TYPE typ_tab_diavlr IS TABLE OF typ_reg_diavlr INDEX BY VARCHAR2(8);  
  vr_tab_diavlr  typ_tab_diavlr;
  


  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_reg_novtabinv IS
        RECORD(idfrninv  tbcapt_custodia_frn_investidor.idfrninv%TYPE
              ,vlfaixde  tbcapt_custodia_frn_investidor.vlfaixade%TYPE
              ,vlfaixate tbcapt_custodia_frn_investidor.vlfaixaate%TYPE
              ,pctaxmen  tbcapt_custodia_frn_investidor.petaxa_mensal%TYPE
              ,vladicio  tbcapt_custodia_frn_investidor.vladicional%TYPE
              );
              
  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_tab_novtabinv IS TABLE OF typ_reg_novtabinv INDEX BY VARCHAR2(40);  
  vr_tab_novtabinv  typ_tab_novtabinv;  
       
  /* Função que retorna código e descrição da cooperativa do arquivo informado */
  FUNCTION fn_get_desc_cooper (
     pr_idarquivo  IN tbcapt_custodia_conteudo_arq.idarquivo%type
    ,pr_cdcooper   IN VARCHAR2   
    ) 
    RETURN VARCHAR2 
    IS
      --
      vr_idaplicacao  tbcapt_custodia_conteudo_arq.idaplicacao%TYPE := NULL;
      vr_cdcooper     craprda.cdcooper%type := NULL;
      vr_dscooper     VARCHAR2(200);
      --
  BEGIN
    --
    IF pr_idarquivo IS NULL THEN
      RETURN 0;
    END IF;
    
    vr_idaplicacao := NULL;
    vr_cdcooper    := NULL;
    BEGIN
     SELECT  /*+ INDEX (cntArq TBCAPT_CUSTODIA_CONT_ARQ_PK cntArq.Idarquivo) */ 
             t1.idaplicacao INTO vr_idaplicacao
       FROM tbcapt_custodia_conteudo_arq t1
      WHERE t1.idarquivo = pr_idarquivo 
        AND t1.idaplicacao IS NOT NULL 
        AND ROWNUM = 1; 
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        NULL;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => 0);  
    END;  
    
    RETURN 0;
    --
    IF vr_idaplicacao IS NULL THEN
      RETURN NULL;
    ELSE
      --
      BEGIN
        SELECT rda.cdcooper INTO vr_cdcooper
          FROM CRAPRDA RDA
         WHERE RDA.IDAPLCUS = vr_idaplicacao
         AND ROWNUM = 1; 
      EXCEPTION
        WHEN NO_DATA_FOUND THEN 
          NULL;  
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => 0, pr_compleme => ' '  );             
      END;  
      --
      IF vr_cdcooper IS NULL THEN
       --
       BEGIN
         SELECT RAC.CDCOOPER INTO vr_cdcooper
         FROM CRAPRAC RAC
         WHERE RAC.IDAPLCUS = vr_idaplicacao
         AND ROWNUM = 1;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           null;    
         WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => 0);                                    
       END;  
        --
      END IF;
           
      IF vr_cdcooper IS NOT NULL THEN    
        -- Busca a cooperativa com descrição
        BEGIN
          SELECT LPAD(COOP.cdcooper,2,'0') || '-' || Initcap(COOP.NMRESCOP) into vr_dscooper            
          FROM   CRAPCOP COOP
          WHERE  COOP.CDCOOPER = vr_cdcooper;                
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            null;
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => 0);
         END;     
       end if;      
    END IF; 
      
    IF (    NVL(pr_cdcooper,0)   = 0 
         OR NVL(vr_cdcooper,0) = NVL(pr_cdcooper,0)) THEN         
      RETURN vr_dscooper;
    ELSE          
      RETURN NULL;                     
    END IF;     
   
  EXCEPTION  
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => 0);  
        RETURN NULL;  
  end;  
  
  
   /* Procedimento para retornar os parâmetros gravados em Sistema por Cooperativa */
   PROCEDURE pc_busca_parametros_coop(pr_tlcdcooper IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS      -- Saida OK/NOK      
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_parametros_coop
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca parâmetros do sistema por Cooperativa para retornar a tela PHP 
    
    Alterações : 

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
    
    -- Incluir nome do módulo logado
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

    -- Parâmetro Data Inicial
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'dataB3'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'INIC_CUSTODIA_APLICA_B3')
      ,pr_des_erro => vr_dscritic);
      
    -- Valor mínimo
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'vlminB3'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'VLMIN_CUSTOD_APLICA_B3')
      ,pr_des_erro => vr_dscritic);    

    -- Parâmetro Codigo Registrador
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'cdregtb3'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'CD_REGISTRADOR_CUSTOD_B3')
      ,pr_des_erro => vr_dscritic);

    -- Parâmetro Codigo Favorecido
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
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_busca_parametros_coop;
  
  /* Procedimento para retornar os parâmetros gravados em Sistema por Cooperativa */
  PROCEDURE pc_gravac_parametros_coop(pr_tlcdcooper  IN VARCHAR2           -- Cooperativa selecionada
                                     ,pr_datab3    in VARCHAR2           -- Data de Habilitação Custódia 
                                     ,pr_vlminb3   IN VARCHAR2           -- Valor mínimo de aplicação para custódia na B3
                                     ,pr_cdregtb3  in VARCHAR2           -- Padrão do nome do arquivo 
                                     ,pr_cdfavrcb3 in VARCHAR2           -- Lista de email para alertas no processo
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravac_parametros_coop
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Gravar parâmetros do sistema por Cooperativa conforme preenchimento em tela PHP
    
    Alterações : 

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
    -- Variaveis para validar conversão dos dados enviados
    vr_dsdata   DATE;
    vr_vlminimo NUMBER;
    -- Variaveis para LOG
    vr_dsvlrprm VARCHAR2(4000);
    vr_nmarqlog VARCHAR2(20) := gene0001.fn_param_sistema('CRED',pr_tlcdcooper,'NOM_ARQUIVO_LOG_B3')||'.log';
     
  BEGIN    
    -- Incluir nome do módulo logado
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
      vr_dscritic := gene0007.fn_convert_db_web('Data inicial de Custódia deve ser informada!');
      RAISE vr_exc_erro;
    END IF;
    
    IF trim(pr_vlminb3) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Valor mínimo de Custódia deve ser informada!');
      RAISE vr_exc_erro;
    END IF; 
    
    -- Converter data em texto para Date
    BEGIN
      vr_dsdata := TO_DATE(pr_datab3, 'dd/mm/rrrr');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Data inicial ['||pr_datab3||'] de Custódia Inválida!');
      RAISE vr_exc_erro;
    END;
    
    -- Converter texto em numero para number
    BEGIN
      vr_vlminimo := TO_NUMBER(pr_vlminb3, 'FM9999990D00');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Valor mínimo ['||pr_vlminb3||'] de Custódia com B3 Inválido!');
      RAISE vr_exc_erro;
    END;
    
    -- Registrador deve ser um texto composto somente de números e com 8 posições
    IF length(TRIM(pr_cdregtb3)) <> 8 OR NOT gene0002.fn_numerico(pr_cdregtb3) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Codigo Cliente Registrador ['||pr_cdregtb3||'] com B3 Inválido! Informe uma conta com 8 numeros!');
      RAISE vr_exc_erro;
    END IF;
    
    -- Favorecido deve ser um texto composto somente de números e com 8 posições    
    IF length(TRIM(pr_cdfavrcb3)) <> 8 OR NOT gene0002.fn_numerico(pr_cdfavrcb3) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Codigo Cliente Favorecido ['||pr_cdfavrcb3||'] com B3 Inválido! Informe uma conta com 8 numeros!');
      RAISE vr_exc_erro;
    END IF;
    
    -- Finalmente efetuar a gravação na tabela
    BEGIN
      
      /* Data de início Custódia */
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
                                                   || 'Alterou o parâmetro "Data Inicio Custodia" de ' || vr_dsvlrprm
                                                   || ' para ' || to_char(vr_dsdata,'dd/mm/rrrr') || '.');
      END IF;     
      
      /* Valor de início Custódia */
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
                                                   || 'Alterou o parâmetro "Valor Inicio Custodia" de ' || vr_dsvlrprm
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
                                                   || 'Alterou o parâmetro "Codigo Cliente Registrador" de ' || vr_dsvlrprm
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
                                                   || 'Alterou o parâmetro "Codigo Cliente Favorecido" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_cdfavrcb3 || '.');
      END IF;  
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na gravação dos Parâmetros de Custódia de Aplicação: '
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
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                                                                     
    WHEN OTHERS THEN         
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravac_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_gravac_parametros_coop;

   /* Procedimento para retornar os parâmetros gravados em Sistema */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_parametros
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca parâmetros do sistema para retornar a tela PHP 
    
    Alterações : 

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
    
    -- Incluir nome do módulo logado
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

    -- Parâmetro Nome Arquivo
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'nomarq'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'NOM_ARQUIVO_LOG_B3')
      ,pr_des_erro => vr_dscritic);

    -- Parâmetro Emails
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'dsmail'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'DES_EMAILS_PROC_B3')
      ,pr_des_erro => vr_dscritic);

    -- Parâmetro Hora De
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'hrinicio'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'HOR_INICIO_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

    -- Parâmetro Hora Até
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'hrfinal'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'HOR_FINAL_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);


    -- Parâmetro Envio Habilitado
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'reghab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FLG_ENV_REG_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

    -- Parâmetro Retorno Habilitado
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'rgthab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FLG_ENV_RGT_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

    -- Parâmetro Exclusão Habilitada
    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'cnchab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FLG_CONCILIA_CUSTODIA_B3')
      ,pr_des_erro => vr_dscritic);

	-- Parâmetro Tolerância Conciliação
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
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_busca_parametros;
  
  /* Procedimento para retornar os parâmetros gravados em Sistema */
  PROCEDURE pc_gravac_parametros(pr_nomarq   in VARCHAR2           -- Padrão do nome do arquivo 
                                ,pr_dsmail   in VARCHAR2           -- Lista de email para alertas no processo
                                ,pr_hrinicio in VARCHAR2           -- Hora de início da comunicação com B3
                                ,pr_hrfinal  in VARCHAR2           -- Hora final de comunicação com B3
                                ,pr_reghab   in VARCHAR2           -- Envio Habilitado ? 
                                ,pr_rgthab   in VARCHAR2           -- Retorno Habilitado ? 
                                ,pr_cnchab   in VARCHAR2           -- Exclusão Habilitada ? 
								,pr_perctolval IN NUMBER           -- Parametro de tolerancia de conciliação 																			   
                                ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravac_parametros
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Gravar parâmetros do sistema conforme preenchimento em tela PHP
    
    Alterações : 

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
    -- Variaveis para validar conversão dos dados enviados
    vr_dshorain DATE;
    vr_dshorafi DATE;   
    vr_txemails gene0002.typ_split; --> Separação da linha em vetor
    vr_vlemails VARCHAR2(4000); --> Emails válidos
    -- Variaveis para LOG
    vr_dsvlrprm VARCHAR2(4000);
    vr_nmarqlog VARCHAR2(20) := gene0001.fn_param_sistema('CRED',0,'NOM_ARQUIVO_LOG_B3')||'.log';
	vr_perctolval NUMBER;					 
     
  BEGIN    
    -- Incluir nome do módulo logado
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
      vr_dscritic := gene0007.fn_convert_db_web('Horário de Comunicação de-até deve ser informado!');
      RAISE vr_exc_erro;
    END IF;    
    
	IF TRIM(pr_perctolval) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Parametro de tolerância deve ser informado!');
      RAISE vr_exc_erro;
    END IF;   
	
    -- Converter hora em texto para Date
    BEGIN
      vr_dshorain := TO_DATE(pr_hrinicio, 'hh24:mi');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Horário de ['||pr_hrinicio||'] de Comunicação com B3 Inválido!');
      RAISE vr_exc_erro;
    END;
	
    -- Converter Hora em texto para Date
    BEGIN
      vr_dshorafi := TO_DATE(pr_hrfinal, 'hh24:mi');
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := gene0007.fn_convert_db_web('Horário até ['||pr_hrfinal||'] de Comunicação com B3 Inválido!');
      RAISE vr_exc_erro;
    END;    
    -- Horário fim não pode ser inferior a hora de
    IF vr_dshorain > vr_dshorafi THEN 
      vr_dscritic := gene0007.fn_convert_db_web('Horário de não pode ser superior a Horário até!');
      RAISE vr_exc_erro;  
    END IF;    
    
    -- Separar os emails enviados e tentar validá-los
    vr_txemails := gene0002.fn_quebra_string(replace(pr_dsmail,',',';'),';');
    IF vr_txemails.COUNT() > 0 THEN
      FOR vr_idx IN vr_txemails.FIRST..vr_txemails.LAST LOOP
        -- Se o email atual possuir alguma informação
        IF trim(vr_txemails(vr_idx)) IS NOT NULL THEN 
          -- Validar o mesmo
          IF gene0003.fn_valida_email(vr_txemails(vr_idx)) = 1 THEN 
            vr_vlemails := vr_vlemails || lower(vr_txemails(vr_idx))||';';
          ELSE
            -- Gerar erro 
            vr_dscritic := gene0007.fn_convert_db_web('Endereço de email ['||vr_txemails(vr_idx)||'] não é um endereço válido!');
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;
    END IF;  
    
    -- Se não validou pelo menos um email
    IF vr_vlemails IS NULL THEN 
      vr_dscritic := gene0007.fn_convert_db_web('Email para alerta deve ser informado! Informe endereços válidos e separados por Ponto e Vírgula(;), caso seja necessário!');
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Finalmente efetuar a gravação na tabela
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
                                                   || 'Alterou o parâmetro "Nome Arquivo LOG" de ' || vr_dsvlrprm
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
                                                   || 'Alterou o parâmetro "Lista Emails" de ' || vr_dsvlrprm
                                                   || ' para ' || vr_vlemails || '.');                      
      END IF;
      
      /* Horário De */
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
                                                   || 'Alterou o parâmetro "Horário Comunicação de" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_hrinicio || '.');                    
      END IF;
      
      /* Horário até */
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
                                                   || 'Alterou o parâmetro "Horário Comunicação até" de ' || vr_dsvlrprm
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
                                                   || 'Alterou o parâmetro "Registro Habilitado" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_reghab || '.');                                          
      END IF;
      
      /* Operações Habilitado */
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
                                                   || 'Alterou o parâmetro "Resgate Habilitado" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_rgthab || '.');                                                     
      END IF;   
      
      /* Conciliação habilitada */
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
                                                   || 'Alterou o parâmetro "Conciliação Habilitada" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_cnchab || '.');            
        -- Se foi ativado
        IF pr_cnchab = 'S' THEN
          -- Atualizamos o registro que indica quando ocorreu a ultima conciliação
          -- pois sea mesma é desabilitada, quando reativada temos de gravar o dia de ontem, 
          -- para que ao rodar o processo novamente tenhamos a conciliação do arquivo de ontem
          UPDATE crapprm
             SET dsvlrprm = to_char(trunc(SYSDATE-1),'dd/mm/rrrr')
           WHERE nmsistem = 'CRED'
             AND cdcooper = 0
             AND cdacesso = 'DAT_CONCILIA_CUSTODIA_B3'; 
        END IF;                                                 
      END IF;   
	  
	/* Percentual de tolerância da conciliação */
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
                                                   || 'Alterou o parâmetro "Percentual de Tolerância para Conciliação" de ' || vr_perctolval
                                                   || ' para ' || pr_perctolval || ', para a cooperativa ' || vr_cdcooper || '.');
      END IF;											  	 
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na gravação dos Parâmetros de Custódia de Aplicação: '
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
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                                                                     
    WHEN OTHERS THEN         
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravac_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_gravac_parametros;
  
  /* Procedimento para retornar os arquivos para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_arquivos(pr_cdcooper IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                             ,pr_nrdconta IN VARCHAR2           -- Conta informada
                             ,pr_nraplica IN VARCHAR2           -- Aplicação Informada (0 para todas)
                             ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                             ,pr_datade   IN VARCHAR2           -- Data de 
                             ,pr_datate   IN VARCHAR2           -- Date até
                             ,pr_nmarquiv IN VARCHAR2           -- Nome do arquivo para busca
                             ,pr_dscodib3 IN VARCHAR2           -- Código na B3                             
                             ,pr_nriniseq IN VARCHAR2           -- Numero do primeiro registro a ser retornado
                             ,pr_qtregist IN VARCHAR2           -- Numero de registros a serem retornados
                             ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_arquivos
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca Arquivos de Custódia gerados e seus retornos, tudo conforme os parâmetros enviados
    
    Alterações : 

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
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_datade_tela date;
    vr_dataat_tela date;
    -- O  cursor principla se divide em 3 cursores diferentes e só vai executar um deles depende dos parâmetros 
    vr_tpexecuc    VARCHAR2(1) := 'T'; -- Tipos: T- Sem código B3 ou Conta, B- Com codigo B3 e C- Com Cooper e Conta
    --
    vr_tot NUMBER(9) := 0;
    
      vr_nrregist      NUMBER(9) := 0;
      vr_nriniseq      NUMBER(9) := 0;
      vr_cdparcop      NUMBER(2) := 0;
      vr_dtparde       DATE := ADD_MONTHS(TO_CHAR(SYSDATE,'DD-MON-YYYY'),-3);
      vr_dtparate      DATE := TO_CHAR(SYSDATE,'DD-MON-YYYY');
      vr_dscodigo_b3   tbcapt_custodia_aplicacao.dscodigo_b3%TYPE;
      vr_nrdconta      craprac.nrdconta%TYPE;
      vr_prdt          NUMBER(1) := 0;
    
    -- Busca dos arquivos de custódia
    cursor cr_arquivos
      IS
    --
    -- vr_tpexecuc T 
    -- vr_cdparcop 0 ou especifica 
    --
    SELECT tab_montada_6.*
    FROM 
     (SELECT tab_montada_5.*
    FROM 
    (SELECT rownum linha
          ,COUNT(1) OVER (PARTITION BY 1) qtregist  --Quantidade de registros
          ,tab_montada_4.*
      FROM 
	     (SELECT tab_montada_3.*
              , ( SELECT t1.cdcooper  FROM craprda t1 
                  WHERE  t1.IDAPLCUS = tab_montada_3.idaplicacao2 AND ROWNUM = 1 ) cdcooper1
              , ( SELECT t1.cdcooper  FROM craprac t1 
                  WHERE  t1.IDAPLCUS = tab_montada_3.idaplicacao2 AND ROWNUM = 1 ) cdcooper2              
        FROM  
         (SELECT  tab_montada_2.*
                 ,( SELECT /*+ INDEX (cntArq TBCAPT_CUSTODIA_CONT_ARQ_PK cntArq.Idarquivo) */ 
                       t1.idaplicacao
                      FROM    tbcapt_custodia_conteudo_arq t1
                      WHERE   t1.idarquivo = tab_montada_2.idarqenv
                      AND     t1.idaplicacao IS NOT NULL
                      AND     ROWNUM = 1 )  idaplicacao2 
          FROM   
			     (SELECT tab_montada.*
            FROM   
				     (SELECT arq.*   
              FROM 
               (SELECT
                    apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'A') dstiparq
                   ,apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'E') dstiparq_ext
                   ,arqEnv.dtregistro
                   /* Envio */
                   ,arqEnv.idarquivo idarqenv
                   ,substr(arqEnv.nmarquivo,1,26)||chr(13)||substr(arqEnv.nmarquivo,27) nmarqenv
                   ,decode(arqEnv.idsituacao,0,'Não Env.',1,'Enviado') dssitenv
                   ,arqEnv.dtprocesso dtdenvio
                   ,'Envio' tpopeenv
                   /* Retorno */
                   ,arqRet.idarquivo idarqret
                   ,substr(arqRet.nmarquivo,1,25)||chr(13)||substr(arqRet.nmarquivo,26) nmarqret
                   ,decode(arqRet.idsituacao,0,'Não Prc.',1,'Processado') dssitret
                   ,arqRet.dtprocesso dtdretor
                   ,'Retorno' tpoperet
                   ,NULL      idaplicacao1
                FROM tbcapt_custodia_arquivo arqEnv
                    ,tbcapt_custodia_arquivo arqRet
               WHERE vr_tpexecuc = 'T'
               AND   arqEnv.idtipo_arquivo IN(1,2,3) 
                 AND arqEnv.idtipo_operacao = 'E'
                 AND arqEnv.idarquivo = arqRet.idarquivo_origem (+)
                 AND arqRet.idtipo_operacao (+) = 'R'
                 AND (   trunc(arqEnv.dtregistro)                         BETWEEN vr_dtparde AND vr_dtparate
                      OR trunc(nvl(arqEnv.Dtprocesso,arqEnv.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate  
                      OR trunc(nvl(arqRet.Dtprocesso,arqEnv.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate )
               UNION
              SELECT apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'A') 
                    ,apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'E') 
                    ,arqCnc.Dtregistro                  
                    /* Conciliação não há envio */
                    ,arqCnc.idarquivo 
                    ,null nmarqenv
                    ,null dssitenv
                    ,to_date(null) 
                    ,null tpopeenv
                    /* Dados da Conciliação(Retorno) */
                    ,arqCnc.idarquivo 
                    ,substr(arqCnc.nmarquivo,1,26)||chr(13)||substr(arqCnc.nmarquivo,27)  
                    ,decode(arqCnc.idsituacao,0,'Não Prc.',1,'Processado') 
                    ,nvl(arqCnc.dtprocesso,arqCnc.Dtcriacao) dtdretor
                    ,'Retorno' 
                   ,NULL      idaplicacao1
                FROM tbcapt_custodia_arquivo arqCnc
               WHERE vr_tpexecuc = 'T'
               AND   arqCnc.idtipo_arquivo = 9 
                 AND arqCnc.idtipo_operacao = 'R'
                 AND (   trunc(arqCnc.dtregistro)                         BETWEEN vr_dtparde AND vr_dtparate
                      OR trunc(nvl(arqCnc.Dtprocesso,arqCnc.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate ) 
                 ) arq               
               ORDER BY arq.dtregistro, arq.dtdretor
             ) tab_montada 
            ) tab_montada_2
           ) tab_montada_3
          ) tab_montada_4
            WHERE (   vr_cdparcop
                       = 0 
                   OR vr_cdparcop
                       = NVL(tab_montada_4.cdcooper1,0) 
                   OR vr_cdparcop
                       = NVL(tab_montada_4.cdcooper2,0)  )               
            ORDER BY tab_montada_4.dtregistro, tab_montada_4.dtdretor    
         ) tab_montada_5
    WHERE tab_montada_5.linha >= vr_nriniseq
    AND   tab_montada_5.linha <  vr_nrregist ) tab_montada_6 
    UNION
    --
    -- vr_tpexecuc B  Codigo B3 
    --
    SELECT tab_montada_6.*
    FROM 
     (SELECT tab_montada_5.*
    FROM 
      (SELECT rownum linha
          ,COUNT(1) OVER (PARTITION BY 1) qtregist  --Quantidade de registros
          ,tab_montada_4.*
      FROM 
	     (SELECT  tab_montada_3.*
               ,( SELECT t1.cdcooper  FROM craprda t1 WHERE t1.IDAPLCUS = tab_montada_3.idaplicacao1 AND ROWNUM = 1 ) cdcooper1
               ,( SELECT t1.cdcooper  FROM craprac t1 WHERE t1.IDAPLCUS = tab_montada_3.idaplicacao1 AND ROWNUM = 1 ) cdcooper2               
        FROM  
         (SELECT tab_montada_2.*
                ,NULL idaplicacao2
          FROM   
			     (SELECT tab_montada.*
            FROM   
				     (SELECT arq.*   
              FROM 
               (SELECT
                    apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'A') dstiparq
                   ,apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'E') dstiparq_ext
                   ,arqEnv.dtregistro
                   /* Envio */
                   ,arqEnv.idarquivo idarqenv
                   ,substr(arqEnv.nmarquivo,1,26)||chr(13)||substr(arqEnv.nmarquivo,27) nmarqenv
                   ,decode(arqEnv.idsituacao,0,'Não Env.',1,'Enviado') dssitenv
                   ,arqEnv.dtprocesso dtdenvio
                   ,'Envio' tpopeenv
                   /* Retorno */
                   ,arqRet.idarquivo idarqret
                   ,substr(arqRet.nmarquivo,1,25)||chr(13)||substr(arqRet.nmarquivo,26) nmarqret
                   ,decode(arqRet.idsituacao,0,'Não Prc.',1,'Processado') dssitret
                   ,arqRet.dtprocesso dtdretor
                   ,'Retorno' tpoperet
                   ,t4.idaplicacao idaplicacao1
                FROM tbcapt_custodia_arquivo arqEnv
                    ,tbcapt_custodia_arquivo arqRet
                      ,tbcapt_custodia_conteudo_arq t1
                      ,tbcapt_custodia_aplicacao    t4
               WHERE vr_tpexecuc = 'B'
               AND   arqEnv.idtipo_arquivo  IN (1,2,3) 
               AND   arqEnv.idtipo_operacao = 'E'
               AND   arqEnv.idarquivo       = arqRet.idarquivo_origem (+)
               AND   arqRet.idtipo_operacao (+) = 'R'
               AND   arqEnv.idarquivo  = t1.idarquivo
               AND    t4.idaplicacao   = t1.idaplicacao
               AND    vr_dscodigo_b3   = t4.dscodigo_b3
               AND  ( vr_prdt = 0 OR ( 
                       ( trunc(arqEnv.dtregistro)                         BETWEEN vr_dtparde AND vr_dtparate
                      OR trunc(nvl(arqEnv.Dtprocesso,arqEnv.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate  
                      OR trunc(nvl(arqRet.Dtprocesso,arqEnv.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate ) ) )
               UNION
              SELECT apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'A') 
                    ,apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'E') 
                    ,arqCnc.Dtregistro                  
                    /* Conciliação não há envio */
                    ,arqCnc.idarquivo 
                    ,null nmarqenv
                    ,null dssitenv
                    ,to_date(null) 
                    ,null tpopeenv
                    /* Dados da Conciliação(Retorno) */
                    ,arqCnc.idarquivo 
                    ,substr(arqCnc.nmarquivo,1,26)||chr(13)||substr(arqCnc.nmarquivo,27)  
                    ,decode(arqCnc.idsituacao,0,'Não Prc.',1,'Processado') 
                    ,nvl(arqCnc.dtprocesso,arqCnc.Dtcriacao) dtdretor
                    ,'Retorno' 
                   ,t4.idaplicacao idaplicacao1
                FROM tbcapt_custodia_arquivo        arqCnc
                      ,tbcapt_custodia_conteudo_arq t1
                      ,tbcapt_custodia_aplicacao    t4
               WHERE vr_tpexecuc = 'B'
               AND   arqCnc.idtipo_arquivo  = 9 
               AND   arqCnc.idtipo_operacao = 'R'
                   AND arqCnc.idarquivo = t1.idarquivo
                      AND    t4.idaplicacao = t1.idaplicacao
                      AND    vr_dscodigo_b3 = t4.dscodigo_b3
                 AND ( vr_prdt = 0 OR ( 
                     (   trunc(arqCnc.dtregistro)                         BETWEEN vr_dtparde AND vr_dtparate
                      OR trunc(nvl(arqCnc.Dtprocesso,arqCnc.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate ) ) )
                 ) arq 
               ORDER BY arq.dtregistro, arq.dtdretor   
             ) tab_montada 
            ) tab_montada_2
           ) tab_montada_3
          ) tab_montada_4
            WHERE (   vr_cdparcop
                       = 0 
                   OR vr_cdparcop
                       = NVL(tab_montada_4.cdcooper1,0) 
                   OR vr_cdparcop
                       = NVL(tab_montada_4.cdcooper2,0)  )               
            ORDER BY tab_montada_4.dtregistro, tab_montada_4.dtdretor    
         ) tab_montada_5
    WHERE tab_montada_5.linha >= vr_nriniseq
    AND   tab_montada_5.linha <  vr_nrregist ) tab_montada_6
    UNION
    --
    -- vr_tpexecuc C - Conta
    --
    SELECT tab_montada_6.*
    FROM 
     (SELECT tab_montada_5.*
    FROM 
      (SELECT rownum linha
          ,COUNT(1) OVER (PARTITION BY 1) qtregist  --Quantidade de registros
          ,tab_montada_4.*
      FROM 
	     (SELECT  tab_montada_3.*
               ,vr_cdparcop cdcooper1
               ,vr_cdparcop cdcooper2               
        FROM  
         (SELECT tab_montada_2.*
                ,NULL idaplicacao2
          FROM   
			     (SELECT tab_montada.*
            FROM   
				     (SELECT DISTINCT arq.*   
              FROM 
               (SELECT
                    apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'A') dstiparq
                   ,apli0007.fn_tparquivo_custodia(arqEnv.idtipo_arquivo,'E') dstiparq_ext
                   ,arqEnv.dtregistro
                   /* Envio */
                   ,arqEnv.idarquivo idarqenv
                   ,substr(arqEnv.nmarquivo,1,26)||chr(13)||substr(arqEnv.nmarquivo,27) nmarqenv
                   ,decode(arqEnv.idsituacao,0,'Não Env.',1,'Enviado') dssitenv
                   ,arqEnv.dtprocesso dtdenvio
                   ,'Envio' tpopeenv
                   /* Retorno */
                   ,arqRet.idarquivo idarqret
                   ,substr(arqRet.nmarquivo,1,25)||chr(13)||substr(arqRet.nmarquivo,26) nmarqret
                   ,decode(arqRet.idsituacao,0,'Não Prc.',1,'Processado') dssitret
                   ,arqRet.dtprocesso dtdretor
                   ,'Retorno' tpoperet
                   --,t4.idaplicacao idaplicacao1
                   ,NULL idaplicacao1
                FROM tbcapt_custodia_arquivo arqEnv
                    ,tbcapt_custodia_arquivo arqRet
                      ,tbcapt_custodia_conteudo_arq t1
                      , ( SELECT t1.IDAPLCUS  idaplicacao FROM craprda t1 
                          WHERE t1.Cdcooper = vr_cdparcop 
                          AND   t1.nrdconta = vr_nrdconta AND t1.IDAPLCUS IS NOT NULL
                          UNION ALL
                          SELECT t1.IDAPLCUS  idaplicacao FROM craprac t1 
                          WHERE t1.Cdcooper = vr_cdparcop 
                          AND   t1.nrdconta = vr_nrdconta AND t1.IDAPLCUS IS NOT NULL                      
                            )
                          t4
               WHERE vr_tpexecuc = 'C'
               AND   arqEnv.idtipo_arquivo  IN (1,2,3) 
               AND   arqEnv.idtipo_operacao = 'E'
               AND   arqEnv.idarquivo       = arqRet.idarquivo_origem (+)
               AND   arqRet.idtipo_operacao (+) = 'R'
               AND   arqEnv.idarquivo = t1.idarquivo
               AND   t4.idaplicacao   = t1.idaplicacao
               AND ( vr_prdt = 0 OR ( 
                       ( trunc(arqEnv.dtregistro)                         BETWEEN vr_dtparde AND vr_dtparate
                      OR trunc(nvl(arqEnv.Dtprocesso,arqEnv.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate  
                      OR trunc(nvl(arqRet.Dtprocesso,arqEnv.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate ) ) )
                    UNION
              SELECT apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'A') 
                    ,apli0007.fn_tparquivo_custodia(arqCnc.idtipo_arquivo,'E') 
                    ,arqCnc.Dtregistro                  
                    /* Conciliação não há envio */
                    ,arqCnc.idarquivo 
                    ,null nmarqenv
                    ,null dssitenv
                    ,to_date(null) 
                    ,null tpopeenv
                    /* Dados da Conciliação(Retorno) */
                    ,arqCnc.idarquivo 
                    ,substr(arqCnc.nmarquivo,1,26)||chr(13)||substr(arqCnc.nmarquivo,27)  
                    ,decode(arqCnc.idsituacao,0,'Não Prc.',1,'Processado') 
                    ,nvl(arqCnc.dtprocesso,arqCnc.Dtcriacao) dtdretor
                    ,'Retorno' 
                ---   ,t4.idaplicacao idaplicacao1
                   ,NULL idaplicacao1
                FROM tbcapt_custodia_arquivo        arqCnc
                      ,tbcapt_custodia_conteudo_arq t1
                      , ( SELECT t1.IDAPLCUS  idaplicacao FROM craprda t1 
                          WHERE t1.Cdcooper = vr_cdparcop 
                          AND   t1.nrdconta = vr_nrdconta AND t1.IDAPLCUS IS NOT NULL
                          UNION ALL
                          SELECT t1.IDAPLCUS  idaplicacao FROM craprac t1 
                          WHERE t1.Cdcooper = vr_cdparcop 
                          AND   t1.nrdconta = vr_nrdconta AND t1.IDAPLCUS IS NOT NULL                      
                            )
                          t4
               WHERE vr_tpexecuc = 'C'
               AND   arqCnc.idtipo_arquivo  = 9 
               AND   arqCnc.idtipo_operacao = 'R'
               AND   arqCnc.idarquivo = t1.idarquivo
               AND    t4.idaplicacao = t1.idaplicacao
                 AND ( vr_prdt = 0 OR ( 
                     (   trunc(arqCnc.dtregistro)                         BETWEEN vr_dtparde AND vr_dtparate
                      OR trunc(nvl(arqCnc.Dtprocesso,arqCnc.dtregistro))  BETWEEN vr_dtparde AND vr_dtparate ) ) )
                 ) arq 
               ORDER BY arq.dtregistro, arq.dtdretor    
             ) tab_montada 
            ) tab_montada_2
           ) tab_montada_3
          ) tab_montada_4
            WHERE vr_cdparcop = NVL(tab_montada_4.cdcooper1,0 ) OR 
                  vr_cdparcop = NVL(tab_montada_4.cdcooper2,0 )                   
            ORDER BY tab_montada_4.dtregistro, tab_montada_4.dtdretor    
         ) tab_montada_5
    WHERE tab_montada_5.linha >= vr_nriniseq
    AND   tab_montada_5.linha <  vr_nrregist ) tab_montada_6 
    ;
               
    vr_dscooper  VARCHAR2(100);
    vr_idArquivo NUMBER(20);  
    vr_idArquivo_ant number(20); 
    
  BEGIN   --- PRINCIPAL - INICIO
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_lista_arquivos'); 
                                 
    vr_cdparcop  := NVL(pr_cdcooper,0);
    vr_nrregist  := NULL;
    vr_nriniseq  := NULL; 
       
    vr_nriniseq := pr_nriniseq;
    vr_nrregist := pr_qtregist + pr_nriniseq;
      
    IF pr_dscodib3 IS NULL THEN
      vr_dscodigo_b3 := '0';
    ELSE
      vr_dscodigo_b3 := NVL(pr_dscodib3,'0');
    END IF;
      
    IF pr_nrdconta IS NULL THEN
      vr_nrdconta := 0;
    ELSE
      vr_nrdconta := NVL(pr_nrdconta,0);
    END IF;
    
    IF vr_cdparcop > 0 AND pr_nrdconta > 0 THEN
      vr_tpexecuc := 'C';
    ELSIF  vr_dscodigo_b3 <> '0' THEN
      vr_tpexecuc := 'B';    
    END IF;
        
    pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => '1201 - PREEE -INICIO ' ||
' pr_cdcooper  :' || pr_cdcooper  ||
',pr_nrdconta  :' || pr_nrdconta  ||
',pr_nraplica  :' || pr_nraplica  ||
',pr_flgcritic :' || pr_flgcritic ||
',pr_datade    :' || pr_datade    ||
',pr_datate    :' || pr_datate    ||
',pr_nmarquiv  :' || pr_nmarquiv  ||
',pr_dscodib3  :' || pr_dscodib3  ||
',pr_nriniseq  :' || pr_nriniseq  ||
',pr_qtregist  :' || pr_qtregist
 );
                                 
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
    
    -- Validar os parâmetros data
    IF trim(pr_datade) IS NOT NULL THEN 
      Begin
        vr_datade_tela := to_date(pr_datade,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data de ['||pr_datade||'] inválida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    -- Validar os parâmetros data
    IF trim(pr_datate) IS NOT NULL THEN 
      Begin
        vr_dataat_tela := to_date(pr_datate,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data até ['||pr_datate||'] inválida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    vr_prdt     := 0;  
--    vr_dtparde  := ADD_MONTHS(TO_CHAR(SYSDATE,'DD-MON-YYYY'),-3);
--    vr_dtparate := TO_CHAR(SYSDATE,'DD-MON-YYYY');
     
    -- Se enviada as duas datas, temos de validar se até não é inferior a De
    IF vr_datade_tela IS NOT NULL AND 
       vr_dataat_tela IS NOT NULL    THEN
      
      IF vr_tpexecuc = 'T' THEN  
        IF vr_datade_tela > vr_dataat_tela THEN
        vr_dscritic := 'Data De não pode ser superior a Data Até!';
        RAISE vr_exc_Erro;
        END IF;      
        IF ( vr_dataat_tela - vr_datade_tela ) > 92 THEN
          vr_dscritic := 'Intervalo maior que 92 dias, favor fazer em etapas de no máximo 3 meses!';
          RAISE vr_exc_Erro;
      END IF;
    END IF;
      
      vr_prdt      := 1;      
      vr_dtparde   := vr_datade_tela;
      vr_dtparate  := vr_dataat_tela;
      
    ELSIF vr_datade_tela IS NOT NULL THEN
      vr_prdt      := 1;
      vr_dtparate  := vr_dataat_tela;
      
      IF vr_tpexecuc = 'T' THEN    
        vr_dtparde   := ADD_MONTHS(TO_CHAR(vr_dataat_tela,'DD-MON-YYYY'),-3);
      ELSE              
        vr_dtparde   := ADD_MONTHS(TO_CHAR(vr_dataat_tela,'DD-MON-YYYY'),-60);
      END IF;
      
    ELSIF vr_dataat_tela IS NOT NULL THEN 
      vr_prdt      := 1;         
      vr_dtparde   := vr_datade_tela;
      
      IF vr_tpexecuc = 'T' THEN    
        vr_dtparate  := ADD_MONTHS(TO_CHAR(vr_datade_tela,'DD-MON-YYYY'),+3);
      ELSE              
        vr_dtparate  := ADD_MONTHS(TO_CHAR(vr_datade_tela,'DD-MON-YYYY'),+60);
      END IF;
    ELSE    
      IF vr_tpexecuc = 'T' THEN  
        vr_prdt := 1;
      END IF;    
    END IF;

      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => '1201 - INICIO ' ||
'  pr_cdcooper  :' || pr_cdcooper  ||
', pr_nrdconta  :' || pr_nrdconta  ||
', pr_nraplica  :' || pr_nraplica  ||
', pr_flgcritic :' || pr_flgcritic ||
', pr_datade    :' || pr_datade    ||
', pr_datate    :' || pr_datate    ||
', pr_nmarquiv  :' || pr_nmarquiv  ||
', pr_dscodib3  :' || pr_dscodib3  ||
', pr_nriniseq  :' || pr_nriniseq  ||
', pr_qtregist  :' || pr_qtregist  ||
', vr_dtparde   :' || TO_CHAR(vr_dtparde,'DD-MON-YYYY')  ||
', vr_dtparate  :' || TO_CHAR(vr_dtparate,'DD-MON-YYYY') ||
', vr_tpexecuc  :' || vr_tpexecuc  ||
', vr_prdt      :' || vr_prdt      ||
', vr_dscodigo_b3:' || vr_dscodigo_b3 ||
', vr_cdparcop   :' || vr_cdparcop    ||
', vr_nrdconta   :' || vr_nrdconta    ||
', vr_nriniseq   :' || vr_nriniseq    ||
', vr_nrregist   :' || vr_nrregist   
 );
                                     

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
      
      vr_tot := vr_tot + 1;
  
      -- Caso algum parâmetro de data tenha sido informado

      
      
    IF vr_tot IN ( 1,2,3,4,5,10,100,1000) THEN
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => '1201 - MEIO - vr_tot:' || vr_tot   ||
                            ', idarqenv:' || rw_arquiv.idarqenv ||
                            ', nmarqenv:' || rw_arquiv.nmarqenv ||
                            ', idarqret:' || rw_arquiv.idarqret ||
                            ', nmarqret:' || rw_arquiv.nmarqret       
            );
      END IF;
      
       
      -- Pega o ID do arquivo DE ENVIO OU RETORNO
      IF rw_arquiv.idarqret IS NOT NULL 
        OR rw_arquiv.idarqenv IS NOT NULL THEN            
        -- ID DO ARQUIVO
        vr_idArquivo := nvl(rw_arquiv.idarqret, rw_arquiv.idarqenv);
        -- Busca a cooprativa pelo ID DO ARQUIVO 
        if nvl(vr_idArquivo_ant,-1) <> vr_idArquivo then          
          vr_idArquivo_ant := vr_idArquivo;
        end if;
      END IF;

   --   vr_dscooper := tela_cusapl.fn_get_desc_cooper(vr_idArquivo, pr_cdcooper);     
   
      vr_dscooper := 'SEM COOPER';
      IF nvl(rw_arquiv.cdcooper1,0) > 0 OR nvl(rw_arquiv.cdcooper2,0) > 0 THEN
        -- Busca a cooperativa com descrição
        BEGIN
          SELECT LPAD(COOP.cdcooper,2,'0') || '-' || Initcap(COOP.NMRESCOP) 
          INTO   vr_dscooper            
          FROM   CRAPCOP COOP
          WHERE  COOP.CDCOOPER = nvl(rw_arquiv.cdcooper1,rw_arquiv.cdcooper2);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vr_dscooper := 'COOPER NAO CADASTRADA';
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => 0);
            vr_dscooper := 'ERRO NO CADASTRADO COOPER';
         END;     
       END IF; 

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
                                '<dscooper>' || vr_dscooper ||'</dscooper>'||                                
                              '</arq>');
                              
      vr_contador := rw_arquiv.qtregist;
       
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
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_arquivos --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_lista_arquivos;
  
  /* Procedimento para retornar o LOG do arquivo repassado nos parâmetros */
  PROCEDURE pc_lista_log_arquivo(pr_idarquivo in VARCHAR2          -- Código na B3
                                ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_log_arquivo
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedimento para retornar o LOG do arquivo repassado nos parâmetros
    
    Alterações : 

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
    
    -- Incluir nome do módulo logado
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
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_log_arquivo --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_lista_log_arquivo;
  
  
  /* Procedimento para retornar o conteúdo do arquivo */
  PROCEDURE pc_lista_conteudo_arquivo(pr_cdcooper IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                     ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                     ,pr_nraplica IN VARCHAR2           -- Aplicação Informada (0 para todas)
                                     ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                                     ,pr_datade   IN VARCHAR2           -- Data de 
                                     ,pr_datate   IN VARCHAR2           -- Data ate 
                                     ,pr_nmarquiv IN VARCHAR2           -- Nome do arquivo para busca
                                     ,pr_dscodib3 IN VARCHAR2           -- Código na B3
                                     ,pr_inacao    IN VARCHAR2 DEFAULT 'TELA' -- Ação TELA-Nao ativa Expor., CSV-Ativa exportação csv
                                     ,pr_nrregist  IN VARCHAR2                -- Numero de registros a serem retornados
                                     ,pr_nriniseq  IN VARCHAR2                -- Numero do primeiro registro a ser retornado
                                     ,pr_idarquivo IN VARCHAR2                -- Identificação do arquivo
                                     ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_conteudo_arquivo
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 01/06/2019
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedimento para retornar o conteúdo do arquivo repassado nos parâmetros
    
    Alterações : 
      01/06/2019 - Ajustes telas A e O (Envolti - David / Belli - PJ_411_Fase_2_Parte_2)

    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_arquivoCSV VARCHAR2(100);
    vr_linhaArquivoCSV VARCHAR2(4000); 
    -- Diretório temporário 
    vr_dshandle UTL_FILE.FILE_TYPE;

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
   
    -- Variaveis locais para a tela
    vr_dscooper  VARCHAR2  (100);
    --
    vr_dsparame  VARCHAR2 (4000) := NULL;
    vr_dspardet  VARCHAR2 (4000) := NULL;
    vr_dsparapl  VARCHAR2 (4000) := NULL;
    vr_dssqlerrm VARCHAR2 (4000);
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_lista_conteudo_arquivo'; -- Rotina e programa
     
    vr_fgproarq     VARCHAR2 (1) := 'S';
    vr_qttotlin     NUMBER   (9) := 0;
    vr_nrseqarq     NUMBER   (9) := 0;
   
    -- Busca do conteúdo do Arquivo
    
    CURSOR cr_cont IS
    --    
    SELECT         
           x12.*
          ,ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcgc
          ,GENE0002.fn_mask_cpf_cnpj(ass.nrcpfcgc, ass.inpessoa) nrcpfcnpj   
          ,cop.nmrescop 
          ,cop.cdcooper || '-' || Initcap(cop.nmrescop) dscooper
          ,apli0007.fn_tip_aplica(cop.cdcooper,x12.tpaplicacao,ass.nrdconta,x12.nraplica) dstpapli
          ,CASE x12.tpaplica WHEN 'RDCA' THEN nvl(x12.totAplica,0)  END totRDCA  
          ,CASE x12.tpaplica WHEN 'CAPT' THEN nvl(x12.totAplica,0)  END totCAPT                     
 FROM  
 ( SELECT x11.*
   FROM 
   ( SELECT  x10.*
     FROM 
     (  SELECT rownum           nrseq_linha
              ,con.nrseq_linha  nrseq_linhaxx
            --            
              ,NVL(NVL(rda.cdcooper,rac.cdcooper),3) cdcopapl
              ,NVL(NVL(rda.nrdconta,rac.nrdconta),0) nrctaapl              
              ,NVL(NVL(rda.nraplica,rac.nraplica),0) nraplica 
              ,to_char(NVL(rda.dtmvtolt,rac.dtmvtolt),'dd/mm/rrrr') data_envio 
              ,to_char(NVL(rda.dtvencto,rac.dtvencto),'dd/mm/rrrr') data_vencimento  
            --
                    ,DECODE(rda.cdcooper,NULL,rac.txaplica,rda.vlsltxmm) taxa2 -- rever campo taxa da aplicacao
                    ,DECODE(rda.cdcooper,NULL,'CAPT'      ,'RDCA' ) tpaplica
                    ,DECODE(rda.cdcooper,NULL,rac.nrctrrpp,0      ) nrctrrpp -- plano 
                    --                                     
                    ,CASE DECODE(rda.cdcooper,NULL,'CAPT','RDCA' ) 
                     WHEN 'CAPT' THEN nvl(DECODE(rda.cdcooper,NULL,rac.txaplica,rda.vlsltxmm),0) 
                     ELSE (SELECT lap.txaplmes FROM craplap lap
                      WHERE  lap.progress_recid = 
                      (SELECT MIN(lap.progress_recid) lap -- Retornar a primeira encontrada 
                       FROM   craplap lap
                       WHERE  lap.cdcooper    = NVL(rda.cdcooper,rac.cdcooper)
                       AND    lap.nrdconta    = NVL(rda.nrdconta,rac.nrdconta) 
                       AND    lap.nraplica    = NVL(rda.nraplica,rac.nraplica)  
                       AND    lap.dtmvtolt    = NVL(rda.dtmvtolt,rac.dtmvtolt)
                        ) )  
                      END taxa            
            --
            ,lancto.idlancamento
            ,NVL(apl.dscodigo_b3,con.dscodigo_b3) dscodigo_b3
            ,apl.idaplicacao
            ,apl.tpaplicacao
            ,lancto.cdhistorico
            ,apli0007.fn_tpregistro_custodia(lancto.idtipo_lancto,'A') cdtiplcto
            ,DECODE (arq.idtipo_arquivo,9,0,lancto.vlregistro) vllancto_misto  
            ,lancto.idsituacao
            ,gene0007.fn_caract_controle(con.dscritica)   dscritic
            ,arq.idtipo_arquivo
            ,DECODE (arq.idtipo_arquivo,9
                     , gene0002.fn_busca_entrada('14',con.dslinha,';')
                     , lancto.qtcotas )          qtdcotas
            ,DECODE (arq.idtipo_arquivo,9
                     , gene0002.fn_busca_entrada('16',con.dslinha,';')
                     , lancto.vlpreco_unitario ) valor_pu
            ,apl.dtregistro                      data_registro
            ,0 saldo           
            ,0 totVlrPuB3 
            ,count(1)         over() totAplica
            --,sum(apl.qtcotas) over() totalCotas
            ,sum(DECODE (arq.idtipo_arquivo,9
                     , gene0002.fn_busca_entrada('14',con.dslinha,';')
                     , lancto.qtcotas )) over() totalCotas
            ,SUM(DECODE(Apl.tpaplicacao,1, 1, DECODE(apl.tpaplicacao, 2, 1, 0 )) )  over() qt_totpospre
            ,SUM(DECODE(Apl.tpaplicacao,3, 1, DECODE(apl.tpaplicacao, 4, 1, 0 )) )  over() qt_totprogra
            ,SUM(DECODE(con.dscritica,NULL, 1, 0) )  over() qt_totsemcritica
            ,SUM(DECODE(con.dscritica,NULL, 0, 1) )  over() qt_totcomcritica                      
            --
            ,SUM(DECODE(arq.idtipo_arquivo, 9
                        ,(  gene0002.fn_busca_entrada('16',con.dslinha,';')  -- valor_pu
                          * gene0002.fn_busca_entrada('14',con.dslinha,';')) -- qtdcotas                                    
                        ,lancto.vlregistro ) )  over()      vl_totarquivo
            --
        FROM tbcapt_custodia_arquivo      arq 
            ,tbcapt_custodia_conteudo_arq con
            ,tbcapt_custodia_lanctos      lancto
            ,tbcapt_custodia_aplicacao    apl
            ,craprda                      rda
            ,craprac                      rac
       WHERE arq.idarquivo            = pr_idarquivo
         AND con.idarquivo            = arq.idarquivo        
         AND apl.idaplicacao     (+) = con.idaplicacao  
         AND lancto.idlancamento (+) = con.idlancamento         
         AND rda.idaplcus        (+) = DECODE(apl.tpaplicacao,1,NVL(apl.idaplicacao,0),2,NVL(apl.idaplicacao,0),0)
         AND rac.idaplcus        (+) = DECODE(apl.tpaplicacao,1,0,2,0,NVL(apl.idaplicacao,0))
         --
         AND ( NVL(pr_flgcritic,'N') = 'N' OR ( NVL(pr_flgcritic,'N') = 'S' AND con.dscritica IS NOT NULL ) )
         AND ( NVL(pr_dscodib3, '0') = '0' OR NVL(pr_dscodib3, '0') = NVL(apl.dscodigo_b3,con.dscodigo_b3) )
         AND ( NVL(pr_nrdconta,   0) =  0  OR NVL(pr_nrdconta,0)    = NVL(NVL(rda.nrdconta,rac.nrdconta),0) )
         AND con.idtipo_linha        = 'L' -- Somente Linhas
       ORDER by con.nrseq_linha
    ) x10    
    WHERE ( ( UPPER(pr_inacao) = 'TELA' AND
              X10.nrseq_linha BETWEEN pr_nriniseq AND (pr_nriniseq + pr_nrregist - 1) ) OR
            ( UPPER(pr_inacao) = 'CSV' ) )
      
      ) x11 
          ) x12  
            ,crapcop cop
            ,crapass ass                  
         WHERE ass.cdcooper (+) = x12.cdcopapl
         AND   ass.nrdconta (+) = x12.nrctaapl
         AND   cop.cdcooper (+) = x12.cdcopapl
         ;    
      
    -- Belli / Anderson - Não tratar reenvio -  01/06/2019 - PJ_411_Fase_2_Parte_2   
    -- Checar se existe envio posterior para o mesmo lançamento
    --CURSOR cr_reenvio(pr_idlancamento number) IS      
         
    vr_idreenvi Varchar2(3);
    vr_totconciliados NUMBER   (24,8);    -- Total de aplicações conciliadas
    vr_totcriticas    NUMBER   (24,8);    -- Total de aplicações com críticas
    vr_totalCotas     NUMBER   (24,8);    -- Total de cotas 
    vr_totVlrPuB3     NUMBER   (24,8);    -- Total de valor PU na B3
    vr_totalCAPT      NUMBER   (24,8);    -- Quantidade de aplicações programadas
    vr_totalRDCA      NUMBER   (24,8);    -- Quantidade de aplicações
    vr_qt_totpospre   NUMBER   (24,8);    -- Total de cotas 
    vr_qt_totprogra   NUMBER   (24,8);    -- Total de cotas 
    --
    vllancto_tot_item_n NUMBER   (24,8);
    vllancto_tot_item     Varchar2(50);
    vllancto_tot_item_csv Varchar2(50);
    
  PROCEDURE pc_finaliza_com_erro
    IS
  BEGIN 
    -- Propagar Erro 
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic) ||
                     vr_dssqlerrm         ||
                     ' '  || vr_nmaction  ||
                     ' '  || vr_dsparame  ||
                     ' '  || vr_dspardet;
    -- Log de erro de execucao
    pc_log(pr_cdcritic => vr_cdcritic
          ,pr_dscrilog => vr_dscritic);      
    pr_nmdcampo := NULL;
    -- Devolver criticas      
    pr_cdcritic := (CASE WHEN NVL(pr_cdcritic,0) = 9999 THEN 1464 ELSE NVL(pr_cdcritic,0) END);                                          
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    pr_des_erro := 'NOK';          
    -- Existe para satisfazer exigência da interface. 
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                   
  END pc_finaliza_com_erro;
  
  BEGIN  --          Principal  - Inicio
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CUSAPL'
                              ,pr_action => 'pc_lista_conteudo_arquivo'); 
                                 
    vr_dsparame := ', pr_cdcooper:'  || pr_cdcooper  ||
                   ', pr_nrdconta:'  || pr_nrdconta  ||
                   ', pr_nraplica:'  || pr_nraplica  ||
                   ', pr_flgcritic:' || pr_flgcritic ||
                   ', pr_datade:'    || pr_datade    ||
                   ', pr_datate:'    || pr_datate    ||
                   ', pr_nmarquiv:'  || pr_nmarquiv  ||
                   ', pr_dscodib3:'  || pr_dscodib3  ||
                   ', pr_inacao:'    || pr_inacao    ||
                   ', pr_nrregist:'  || pr_nrregist  ||
                   ', pr_nriniseq:'  || pr_nriniseq  ||
                   ', pr_idarquivo:' || pr_idarquivo;                                        
                           
    -- Totalizadores utilizado na montagem do XML
    vr_totconciliados := 0;
    vr_totcriticas    := 0;
    vr_totalCotas     := 0;
    vr_qt_totpospre   := 0; 
    vr_qt_totprogra   := 0; 
    vr_totVlrPuB3     := 0;                 
                                 
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

    -- Criar cabeçalho do XML
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root>');

    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(1201) || ' PRE -INICIO ' || vr_nmaction || vr_dsparame);  
      
    -- Retornar todos os eventos de LOGs do Arquivo
    FOR rw_cont IN cr_cont LOOP 
      
      -- Incrementa o contador de registros
      vr_posreg := vr_posreg + 1;

      vr_dspardet := ', idaplicacao:' || rw_cont.idaplicacao ||
                     ', tpaplicacao:' || rw_cont.tpaplicacao ||
                     ', dscodigo_b3:' || rw_cont.dscodigo_b3
      ;      
      
      IF rw_cont.idtipo_arquivo = 9 THEN
        vllancto_tot_item_n := rw_cont.valor_pu * rw_cont.qtdcotas;
      ELSE
        vllancto_tot_item_n := rw_cont.vllancto_misto;
      END IF;
      vllancto_tot_item     := to_char(vllancto_tot_item_n,'fm999g999g999g990d00');
      vllancto_tot_item_csv := to_char(vllancto_tot_item_n,'fm999g999g999g990d00000000');

      -- Se for o primeiro registro, insere uma tag com o total de registros existentes 
      IF vr_posreg = 1 THEN
        vr_totconciliados := rw_cont.qt_totsemcritica;
        vr_totcriticas    := rw_cont.qt_totcomcritica;
        vr_totVlrPuB3     := rw_cont.vl_totarquivo;
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<lstcont qtregist="'||rw_cont.totAplica||'">');
      END IF;

      IF vr_posreg IN ( 1,2,10,15,5000) THEN  
        pc_log(pr_cdcritic => 1201
              ,pr_dscrilog => '1201 - pc_lista_conteudo_arquivo PRE - INICIO ' ||
                              ' vr_posreg: ' || vr_posreg  ||
                              ' '  || vr_dspardet  ||
                              ' '  || vr_dsparapl); 
      END IF;  

      -- Checar se existe envio posterior para o mesmo lançamento
      vr_idreenvi := 'Não';
      
      -- Belli / Anderson - Não tratar reenvio -  01/06/2019 - PJ_411_Fase_2_Parte_2
      --OPEN cr_reenvio(rw_cont.idlancamento);
      --FETCH cr_reenvio
      --INTO vr_idreenvi;
      --CLOSE cr_reenvio; 
          
      vr_dssituac := '???';
      -- Caso tenhamos critica 
      IF rw_cont.dscritic IS NOT NULL OR rw_cont.idsituacao = 9 THEN
        vr_dssituac := 'Erro';
      ELSE
        -- Preencher situação conforme situação do lançamento
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
                                       
      IF rw_cont.dscooper IS NULL THEN
        vr_dscooper := rw_cont.cdcooper || ' *** Sem cooper *** ';  
      ELSE
        vr_dscooper := rw_cont.dscooper;
      END IF;

      
      IF( UPPER(pr_inacao)  = 'TELA' AND
          vr_posreg        <= 15       ) THEN
            
      -- Carrega os dados ao XML
      GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<cont>'||
                                '<nrseqlin>' || rw_cont.nrseq_linha || '</nrseqlin>'||
                                '<dscodib3>' || rw_cont.dscodigo_b3 || '</dscodib3>'||
                         --       '<dscooper>' || vr_dscooper || ' - idapl:' || rw_cont.idaplicacao || '</dscooper>'|| 
                                '<dscooper>' || vr_dscooper || '</dscooper>'||                                
                                '<nrdconta>' || rw_cont.nrdconta || '</nrdconta>'||
                                '<nraplica>' || rw_cont.nraplica || '</nraplica>'||
                                '<dstpapli>' || rw_cont.dstpapli || '</dstpapli>'||
                                '<cdhistor>' || rw_cont.cdhistorico || '</cdhistor>'||
                                '<cdtipreg>' || rw_cont.cdtiplcto|| '</cdtipreg>'||
                                '<vllancto>' || vllancto_tot_item || '</vllancto>'||
                                '<idreenvi>' || vr_idreenvi || '</idreenvi>'||
                                '<dssituac>' || vr_dssituac || '</dssituac>'||
                                '<qtregist>' || pr_nrregist || '</qtregist>'||
                                '<nriniseq>' || pr_nriniseq || '</nriniseq>'||
                                '<cpfcnpj>'  ||rw_cont.nrcpfcnpj ||'</cpfcnpj>'||
                                '<saldo>'    ||rw_cont.saldo       ||'</saldo>'||
                                '<qtdcotas>' ||to_char(to_number(rw_cont.qtdcotas),'999G999G999G990')||'</qtdcotas>'||
                                '<dtenvio>'  ||rw_cont.data_envio||'</dtenvio>'||
                                '<dtvencimento>'||rw_cont.data_vencimento||'</dtvencimento>'||
                                '<taxavalpu>'   ||rw_cont.taxa    ||'</taxavalpu>'||
                                '<valorpu>'     ||to_char(rw_cont.valor_pu,'fm9g999g990d00000000')||'</valorpu>'||                                
                                '<dscritic>'    ||rw_cont.dscritic  ||'</dscritic>'||
                                '<planoaplic>'  ||rw_cont.nrctrrpp||'</planoaplic>'||                                
                              '</cont>');
        
      END IF;                   
                                               
      -- Condição de exportação de arquivo CSV
      IF UPPER(pr_inacao) = 'CSV' THEN
        
        vr_qttotlin := vr_qttotlin + 1;
        IF vr_qttotlin >= 100000 THEN
          vr_fgproarq := 'S';
          vr_qttotlin := 0;
        END IF;
        
        IF vr_fgproarq = 'S' THEN
          
          IF utl_file.IS_OPEN(vr_dshandle) THEN
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_dshandle);
            pc_log(pr_cdcritic => 1201, pr_dscrilog => '1201 - vai iniciar novo arquivo ') ;
          END IF;
        END IF;
        
        IF vr_posreg = 1 OR vr_fgproarq = 'S' THEN
          
          vr_fgproarq := 'N';
          
          vr_nrseqarq := vr_nrseqarq + 1;
          
          --vr_arquivoCSV := dbms_random.string('a',20) || '.csv';
          vr_arquivoCSV := 'CP_' || NVL(pr_cdcooper  ,0) ||
                       '_CTA_' || NVL(pr_nrdconta  ,0) || 
                       '_APL_' || NVL(pr_nraplica  ,0) ||
                       '_CRI_' || NVL(pr_flgcritic ,0) ||
                       '_DE_'  || NVL(TO_CHAR(TO_DATE(pr_datade,'DD/MM/RRRR'),'RRRRMMDD') ,0) ||
                       '_ATE_' || NVL( TO_CHAR(TO_DATE(pr_datate,'DD/MM/RRRR'),'RRRRMMDD'),0) ||
                       '_ARQ_' || NVL(pr_nmarquiv  ,0) ||  
                       '_B3_'  || NVL(pr_dscodib3  ,0) ||
                       '_IDE_' || NVL(pr_idarquivo ,0) ||
                       '_S_'   || NVL(vr_nrseqarq ,0) ||
                       '.csv';
             
          -- Começa a geração de arquivo
          gene0001.pc_abre_arquivo(pr_nmdireto => 
                                    gene0002.fn_busca_entrada(1,gene0001.fn_param_sistema('CRED',0
                                                                  ,'NOM_CAMINHO_ARQ_BKP_B3')
                                                                       ,';') ||        'concilia'
                              ,pr_nmarquiv => vr_arquivoCSV
                              ,pr_tipabert => 'W'                -- Modo de abertura (R,W,A)
                              ,pr_flaltper => 0                  -- Não modifica permissões de arquivo
                              ,pr_utlfileh => vr_dshandle        -- Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  
        
          vr_linhaArquivoCSV := 'Sequencia'     || ';' ||
                                'Codigo B3'     || ';' || 
                                'Cooper'        || ';' ||
                                'Conta'         || ';' ||
                                'Nro Aplicao'   || ';' ||
                                'Tipo Aplicao'  || ';' ||
                                'Cod Historico' || ';' ||
                                'Tipo Lancto'   || ';' ||
                                'Valor Lancto'  || ';' ||
                                'Id Reenvio'    || ';' ||
                                'Situacao'      || ';' ||
                               -- 'Quant Reg'     || ';' ||
                               -- 'Nro Inic Reg'  || ';' ||
                                'CPF/CNPJ'      || ';' ||
                               -- 'Saldo'         || ';' ||
                                'Data Emissao'   || ';' ||
                                'Data Vencimento'|| ';' ||
                                'Quant Cotas'   || ';' ||
                                'Taxa'           || ';' ||
                                'Valor Pu'       || ';' ||                                
                                'Critica'        || ';' ||
                                'Plano';
         
         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_dshandle
                                        ,pr_des_text => vr_linhaArquivoCSV); 
                                                    
        END IF;
        
        vr_linhaArquivoCSV := rw_cont.nrseq_linha ||';'||
                              rw_cont.dscodigo_b3 ||';'||
                              vr_dscooper         ||';'||
                              rw_cont.nrdconta  ||';'||
                              rw_cont.nraplica  ||';'||
                              rw_cont.dstpapli  ||';'||
                              rw_cont.cdhistorico ||';'||
                              rw_cont.cdtiplcto   ||';'||
                              vllancto_tot_item_csv   ||';'||
                              vr_idreenvi ||';'||
                              vr_dssituac ||';'||
                            --  pr_nrregist ||';'||
                            --  pr_nriniseq ||';'||
                              rw_cont.nrcpfcnpj ||';'||
                            --  rw_cont.saldo       ||';'||
                              rw_cont.data_envio||';'||
                              rw_cont.data_vencimento ||';' ||
                              rw_cont.qtdcotas    ||';'||
                              rw_cont.taxa            ||';' ||
                              rw_cont.valor_pu          ||';' ||
                              rw_cont.dscritic          ||';' ||
                              rw_cont.nrctrrpp;                                                        
         
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_dshandle
                                      ,pr_des_text => vr_linhaArquivoCSV);                        
                              
      END IF;                        
                              
      vr_contador := vr_contador + 1;

      -- Totalizadores do XML
      vr_totalCotas   := rw_cont.totalCotas; 
      vr_qt_totpospre := rw_cont.qt_totpospre;
      vr_qt_totprogra := rw_cont.qt_totprogra;
      ---vr_totVlrPuB3 := rw_cont.totVlrPuB3;
      vr_totalRDCA    := rw_cont.totRDCA; 
      vr_totalCAPT    := rw_cont.totCAPT;
      
      IF ( UPPER(pr_inacao) = 'TELA' AND
           vr_posreg        >= 15       ) OR
         ( UPPER(pr_inacao) = 'CSV' AND
           vr_posreg        >= rw_cont.totAplica  ) THEN
        EXIT;
      END IF;
      
      
    END LOOP;      

    
    
    
    pc_log(pr_cdcritic => 1201, pr_dscrilog => '1201 - pos loop'||
            ', vr_contador: ' || vr_contador || 
            ', vr_posreg:'    || vr_posreg || 
            ', pr_nriniseq:'    || pr_nriniseq || 
            ', pr_nrregist:'    || pr_nrregist);
         

    -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
    IF vr_posreg = 0 THEN
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<lstcont qtregist="0">');
    END IF;

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</lstcont>'
                           ,pr_fecha_xml      => TRUE);
                           
    -- Encontrou registros, gera o totalizador
    IF vr_contador > 0   THEN
      
       -- Carrega os dados ao XML
      GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<totalizadores>' ||
                              '<totregistros>'  ||TO_CHAR((vr_totconciliados + vr_totcriticas),'999G999G999G990')
                                                                                              ||'</totregistros>'||
                              '<totregconcilia>'||TO_CHAR(vr_totconciliados,'999G999G999G990')||'</totregconcilia>'||
                              '<totregcritica>' ||TO_CHAR(vr_totcriticas,'999G999G999G990')   ||'</totregcritica>'||                                
                              '<totaplicprogramada>'||TO_CHAR(vr_qt_totprogra,'999G999G999G990')||'</totaplicprogramada>'||
                              '<totaplicacao>' ||TO_CHAR(vr_qt_totpospre,'999G999G999G990') ||'</totaplicacao>' ||
                              '<totqtdcotas>'  ||TO_CHAR(vr_totalCotas,'999G999G999G990')   ||'</totqtdcotas>'  ||
                              '<totvalorcotas>'||TO_CHAR(vr_totVlrPuB3,'999G999G999G990D00')||'</totvalorcotas>'||                                 
                              '</totalizadores>');
      
    END IF;
    
    
    pc_log(pr_cdcritic => 1201, pr_dscrilog => '1201 - List Cont Arqu, contador: ' || vr_contador || ', inacao:' || pr_inacao);
    
    -- Opção exportar em CSV
     IF UPPER(pr_inacao) = 'CSV' THEN -- 'TELA' THEN --   then 
       
        pc_log(pr_cdcritic => 1201, pr_dscrilog => '1201 - List Cont Arqu, 02 ') ;
       
        IF utl_file.IS_OPEN(vr_dshandle) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_dshandle);
          pc_log(pr_cdcritic => 1201, pr_dscrilog => '1201 - List Cont Arqu, 03 ') ;
        END IF;
        
        -- Carrega os dados ao XML
        GENE0002.pc_escreve_xml(pr_xml             => vr_clob
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '<Erro>' || 'Arquivo gerado' || '</Erro>');
                 
        /*
        --Enviar arquivo para Web
        GENE0002.pc_envia_arquivo_web (pr_cdcooper  => 3 -- vr_cdcooper  --Codigo Cooperativa
                                       ,pr_cdagenci => vr_cdagenci --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa --Numero do Caixa
                                       ,pr_nmarqimp => vr_arquivoCSV --Nome Arquivo Impressao
                                       ,pr_nmdireto => vr_dsdirarq   --Nome Diretorio
                                       ,pr_nmarqpdf => vr_arquivoCSV --Nome Arquivo PDF
                                       ,pr_des_reto => vr_des_reto   --Retorno OK/NOK
                                       ,pr_tab_erro => vr_tab_erro); 
                                       
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN                                   
          pc_log(pr_cdcritic => 1201, pr_dscrilog => '1201 - List Cont Arqu, vr_des_reto: ' || vr_des_reto 
          || ', CD:' ||vr_tab_erro(vr_tab_erro.first).cdcritic || ', DS:' || vr_tab_erro(vr_tab_erro.first).dscritic);
       
        ELSE                                       
          pc_log(pr_cdcritic => 1201, pr_dscrilog => '1201 - List Cont Arqu, vr_des_reto: ' || vr_des_reto);
        END IF;
        
        -- Carrega os dados ao XML
        GENE0002.pc_escreve_xml(pr_xml             => vr_clob
                                ,pr_texto_completo => vr_xml_temp
                                ,pr_texto_novo     => '<arquivoCSV>'||vr_arquivoCSV||'</arquivoCSV>');       
     
        */
     END IF;
    
     -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Root>'
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
      vr_dssqlerrm := NULL;
      pc_finaliza_com_erro;
                
    WHEN OTHERS THEN 
      -- Acionar log exceções internas
      cecred.pc_internal_exception (pr_cdcooper => NVL(vr_cdcooper,0));
      -- Propagar erro
      vr_cdcritic  := 9999;
      vr_dscritic  := NULL;
      vr_dssqlerrm := SQLERRM;
      pc_finaliza_com_erro;    
          
  END pc_lista_conteudo_arquivo;
  
  /* Procedimento para retornar a Operações para consulta em tela conforme a filtragem enviada */
  PROCEDURE pc_lista_operacoes(pr_cdcooper in VARCHAR2           -- Cooperativa selecionada (0 para todas)
                              ,pr_nrdconta in VARCHAR2           -- Conta informada
                              ,pr_nraplica in VARCHAR2 DEFAULT '0'    -- Aplicação Informada (0 para todas)
                              ,pr_flgcritic IN VARCHAR2          -- Se devemos mostrar somente arquivos com critica
                              ,pr_datade   in VARCHAR2           -- Data de 
                              ,pr_datate   in VARCHAR2           -- Date até
                              ,pr_nmarquiv in VARCHAR2           -- Nome do arquivo para busca
                              ,pr_dscodib3 in VARCHAR2           -- Código na B3
                              ,pr_nrregist IN VARCHAR2           --> Numero de registros a serem retornados
                              ,pr_nriniseq IN VARCHAR2           --> Numero do primeiro registro a ser retornado
                              ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                              ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                              ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_operacoes
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 01/06/2019
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca Operações de Custódia pendentes conforme parâmetros repassados
    
    Alterações : 
      01/06/2019 - Ajustes telas A e O (Envolti - David / Belli - PJ_411_Fase_2_Parte_2)

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
           
    -- Variaveis locais
    vr_contador INTEGER := 0;
    vr_clobxml  CLOB;
    vr_posreg   NUMBER(20) := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    
    vr_datade   date;
    vr_dataat   date;
    
    
    -- Busca das Operações Pendentes
    cursor cr_operac IS
    SELECT * FROM (
      SELECT row_number() OVER (ORDER BY rownum) linha
        ,X2.* FROM ( SELECT
          --  ,cont.nrseq_linha
             COUNT(1) OVER (PARTITION BY 1) qtdregis   
            , x1.* FROM ( SELECT 
             ( select NVL(x.cdcooper,0) from craprac x where x.idaplcus = apl.idaplicacao ) cp1
            ,( select NVL(x.cdcooper,0) from craprac x where x.idaplcus = apl.idaplicacao ) cp2
            ,DECODE (pr_nmarquiv,NULL,'S'
                    ,(SELECT 'S' FROM tbcapt_custodia_arquivo arq
                                     ,tbcapt_custodia_conteudo_arq cnt
                      WHERE arq.idarquivo      = cnt.idarquivo
                      AND cnt.idlancamento     = lancto.idlancamento
                      AND UPPER(arq.nmarquivo) LIKE UPPER('%'||pr_nmarquiv||'%')) ) idtemarq         
            , lancto.idlancamento
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
         AND lancto.idsituacao IN(0,2,9) -- Somente situações de erro
         AND ( NVL(pr_flgcritic,'N') = 'N' OR lancto.idsituacao = 9 )
         AND  ( vr_datade IS NULL OR vr_dataat IS NULL OR (
              lancto.dtregistro  BETWEEN vr_datade AND vr_dataat ) )
         AND ( trim(pr_dscodib3) IS NULL 
               or upper(apl.dscodigo_b3) like '%'||upper(trim(pr_dscodib3))||'%')
       ORDER by lancto.idlancamento DESC
       ) x1 WHERE ( x1.cp1 = pr_cdcooper OR x1.cp1 = pr_cdcooper ) 
            AND   x1.idtemarq = 'S'
       ) x2
      ORDER by rownum
    ) WHERE linha BETWEEN pr_nriniseq AND (pr_nriniseq + pr_nrregist - 1);       
    
    
    -- Garantir que a aplicação vinculada esteja de acordo com 
    -- os filtros enviados ou que haja registro de crítica 
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
               WHERE pr_tpaplicacao IN ( 3, 4)
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
      
    -- Belli / Anderson - Não tratar reenvio -  01/06/2019 - PJ_411_Fase_2_Parte_2  
    -- Checar se existe envio posterior para o mesmo lançamento
    --CURSOR cr_reenvio(pr_idlancamento number) IS      
    --  SELECT COUNT(1) qtdenvios
    --    FROM tbcapt_custodia_conteudo_arq cont
    --        ,tbcapt_custodia_arquivo arq
    --   WHERE cont.idarquivo    = arq.idarquivo
    --     AND cont.idlancamento = pr_idlancamento
    --     AND arq.idtipo_operacao = 'E'; -- Somente de Envio
     
    vr_idreenvio VARCHAR2(3);
    --vr_qtdenvios NUMBER;
    
    -- Busca da Critica quando situação Erro 
    CURSOR cr_critica(pr_idlancamento number) IS      
      SELECT gene0007.fn_caract_controle(cont.dscritica) dscritica
        FROM tbcapt_custodia_conteudo_arq cont
       WHERE cont.idlancamento = pr_idlancamento
         AND cont.dscritica IS NOT NULL
       ORDER BY cont.idarquivo DESC, cont.nrseq_linha;
    vr_dscritica tbcapt_custodia_conteudo_arq.dscritica%TYPE; 

  BEGIN 
    
    -- Incluir nome do módulo logado
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
    
    -- Validar os parâmetros data
    IF trim(pr_datade) IS NOT NULL THEN 
      Begin
        vr_datade := to_date(pr_datade,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data de ['||pr_datade||'] inválida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    -- Validar os parâmetros data
    IF trim(pr_datate) IS NOT NULL THEN 
      Begin
        vr_dataat := to_date(pr_datate,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data até ['||pr_datate||'] inválida!';
          RAISE vr_exc_Erro;
      End;     
    END IF;

    -- Se enviada as duas datas, temos de validar se até não é inferior a De
    IF vr_datade IS NOT NULL AND vr_dataat IS NOT NULL THEN       
      IF vr_datade > vr_dataat THEN
        vr_dscritic := 'Data De não pode ser superior a Data Até!';
        RAISE vr_exc_Erro;
      END IF;
    END IF;

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clobxml, TRUE);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
    
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_xml_temp
                               ,'<?xml version="1.0" encoding="UTF-8"?>' ||
                                    '<Root><Dados qtdregis="0">');  
    
        pc_log(pr_cdcritic => 1201
              ,pr_dscrilog => '1201 - PARAMES  A ' ||
                              ' pr_nriniseq: ' || pr_nriniseq ||
                              ' pr_nrregist:'  || pr_nrregist ); 

    -- Retornar os arquivos conforme filtros informados
    FOR rw_ope IN cr_operac LOOP 
          
      -- SOmente na primeira linha
      IF vr_contador = 0 THEN 
                                    
        -- Incrementa o contador de registros
        vr_posreg := rw_ope.qtdregis;
         
      END IF;
      -- Incrementar o contador
      vr_contador := vr_contador + 1;
      
        IF vr_contador = 1 THEN
        pc_log(pr_cdcritic => 1201
              ,pr_dscrilog => '1201 - PARAMES  A ' ||
                              ' tpaplicacao: ' || rw_ope.tpaplicacao  ||
                              ' idaplicacao:'  || rw_ope.idaplicacao||
                                    ', qtdregis:'||rw_ope.qtdregis); 
        END IF;   
      
      -- Checar paginação
      --IF pr_nrregist > 0 AND ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN
       
        IF vr_contador = 1 THEN
        pc_log(pr_cdcritic => 1201
              ,pr_dscrilog => '1201 - PARAMES B  ' ||
                              ' tpaplicacao: ' || rw_ope.tpaplicacao  ||
                              ' idaplicacao:'  || rw_ope.idaplicacao  ||
                              ' vr_datade:'  || vr_datade  ||
                              ' vr_dataat'  || vr_dataat  ||
                              ' dtregistro:'  || rw_ope.dtregistro); 
        END IF;
        /*   
      -- Garantir data de e até quando temos as duas
      IF vr_datade IS NOT NULL AND vr_dataat IS NOT NULL THEN           
        -- Data Registro tem de estar no período
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
      -- Garantir somente data até
      ELSIF vr_dataat IS NOT NULL THEN 
        -- Data Registro tem de ser inferior A Data Até
        IF rw_ope.dtregistro > vr_dataat THEN 
          -- Ignorar este arquivo
          CONTINUE;
        END IF; 
      END IF; 
        */
      
      -- Buscar aplicacação correspondente
      OPEN cr_aplica(rw_ope.tpaplicacao,rw_ope.idaplicacao);
      FETCH cr_aplica
       INTO rw_aplica;
      -- Se não encontrar, ignorar o registro pois ele não satisfaz os filtros
      IF cr_aplica%NOTFOUND THEN
        CLOSE cr_aplica;
          --continue;
          rw_aplica := null;
      ELSE
        CLOSE cr_aplica;
      END IF;
      
        -- Belli / Anderson - Não tratar reenvio -  01/06/2019 - PJ_411_Fase_2_Parte_2
        -- Checar se existe envio posterior para o mesmo lançamento
        --vr_qtdenvios := 0;
        --vr_idreenvio := 'Não';
        --OPEN cr_reenvio(rw_ope.idlancamento);
        --FETCH cr_reenvio
        -- INTO vr_qtdenvios;
        --CLOSE cr_reenvio;  
        --IF vr_qtdenvios > 0 THEN
        --  vr_idreenvio := 'Sim';
        --END IF;        
        
        -- Caso registro tenha critica
        vr_dscritica := NULL;
        IF rw_ope.idsituacao = 9 THEN 
          -- Busca da Critica quando situação Erro 
          OPEN cr_critica(rw_ope.idlancamento);
          FETCH cr_critica
           INTO vr_dscritica;
          CLOSE cr_critica; 
        END IF; 
                 
        -- Carrega os dados
        GENE0002.pc_escreve_xml
          (pr_xml            => vr_clobxml
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
                                  '<idaplicacao>' || rw_ope.idaplicacao ||'</idaplicacao>'||                                  
                                '</ope>'); 
                                
        --END IF;
      END LOOP;  
   
    -- Houveram registros, então finalizamos o XML
    gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_xml_temp
                             ,'</Dados></Root>'
                             ,TRUE);    

    -- Devolver o XML
    pr_retxml := xmltype.createXML(vr_clobxml);
    
    -- Atualizar atributo contador
    gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'Dados'
                                 ,pr_atrib    => 'qtdregis'
                                 ,pr_atval    => vr_posreg
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);
                                 
    --Fechar Clob e Liberar Memoria
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);    
    

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_arquivos --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_lista_operacoes; 
  
  /* Procedimento para retornar o histórico da aplicação*/
  PROCEDURE pc_historico_aplicacao(pr_idaplicacao IN VARCHAR2        -- Aplicação Informada (0 para todas)
                                  ,pr_nriniseq IN VARCHAR2           --> Numero do primeiro registro a ser retornado
                                  ,pr_nrregist IN VARCHAR2           --> Numero de registros a serem retornados
                                  ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_lista_operacoes
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 01/06/2019
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca Operações de Custódia pendentes conforme parâmetros repassados
    
    Alterações : 
      01/06/2019 - Ajustes telas A e O (Envolti - David / Belli - PJ_411_Fase_2_Parte_2)

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
           
    -- Variaveis locais
    vr_contador INTEGER := 0;
    vr_clobxml  CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
  
    -- Busca das Operações Pendentes
    cursor cr_operac IS
    SELECT * FROM (
      SELECT 
        row_number() OVER (ORDER BY rownum) linha
        ,x1.* 
        FROM (SELECT
             lancto.idlancamento
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
            ,COUNT(1) OVER (PARTITION BY 1) qtdregis             
        FROM tbcapt_custodia_lanctos      lancto
            ,tbcapt_custodia_aplicacao    apl
       WHERE lancto.idaplicacao  = apl.idaplicacao
         AND lancto.idaplicacao  = pr_idaplicacao
       ORDER by lancto.idlancamento DESC
       ) x1 
      ORDER by rownum
    ) WHERE linha BETWEEN pr_nriniseq AND (pr_nriniseq + pr_nrregist - 1);       
       
    -- Garantir que a aplicação vinculada esteja de acordo com 
    -- os filtros enviados ou que haja registro de crítica 
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
              UNION
              SELECT rac.cdcooper
                    ,rac.nrdconta
                    ,rac.nraplica
                FROM craprac RAC
               WHERE pr_tpaplicacao NOT IN ( 1 , 2 )
                 AND RAC.idaplcus = pr_idaplicacao                   
              ) aplica
             ,crapcop cop
         WHERE aplica.cdcooper = cop.cdcooper;          
    rw_aplica cr_aplica%ROWTYPE;
    
    -- Checar se existe envio posterior para o mesmo lançamento
    CURSOR cr_reenvio(pr_idlancamento number) IS      
      SELECT COUNT(1) qtdenvios
        FROM tbcapt_custodia_conteudo_arq cont
            ,tbcapt_custodia_arquivo arq
       WHERE cont.idarquivo    = arq.idarquivo
         AND cont.idlancamento = pr_idlancamento
         AND arq.idtipo_operacao = 'E'; /* Somente de Envio */
    vr_idreenvio VARCHAR2(3);
    vr_qtdenvios NUMBER;
    vr_qtdtot    NUMBER := 0;
    
    -- Busca da Critica quando situação Erro 
    CURSOR cr_critica(pr_idlancamento number) IS      
      SELECT gene0007.fn_caract_controle(cont.dscritica) dscritica
        FROM tbcapt_custodia_conteudo_arq cont
       WHERE cont.idlancamento = pr_idlancamento
         AND cont.dscritica IS NOT NULL
       ORDER BY cont.idarquivo DESC, cont.nrseq_linha;
    vr_dscritica tbcapt_custodia_conteudo_arq.dscritica%TYPE; 

  BEGIN 
    
    -- Incluir nome do módulo logado
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
        

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clobxml, TRUE);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_xml_temp
                               ,'<?xml version="1.0" encoding="UTF-8"?>' ||
                                    '<Root><Dados qtdregis="0">');    
                                                                             
    -- Retornar os arquivos conforme filtros informados
    FOR rw_ope IN cr_operac LOOP 
                        
      -- SOmente na primeira linha
      IF vr_contador = 0 THEN
        vr_qtdtot := rw_ope.qtdregis;
         
      END IF;
      -- Incrementar o contador
      vr_contador := vr_contador + 1;
      
      -- Checar paginação
    --  IF pr_nrregist > 0 AND ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

        -- Buscar aplicacação correspondente        
        OPEN cr_aplica(rw_ope.tpaplicacao,rw_ope.idaplicacao);
        FETCH cr_aplica
         INTO rw_aplica;
        -- Se não encontrar, ignorar o registro pois ele não satisfaz os filtros
        IF cr_aplica%NOTFOUND THEN
          CLOSE cr_aplica;
          ---continue;
          rw_aplica := NULL;
        ELSE
          CLOSE cr_aplica;
        END IF;
        
                
      -- Checar se existe envio posterior para o mesmo lançamento
      vr_qtdenvios := 0;
      vr_idreenvio := 'Não';
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
        -- Busca da Critica quando situação Erro 
        OPEN cr_critica(rw_ope.idlancamento);
        FETCH cr_critica
         INTO vr_dscritica;
        CLOSE cr_critica; 
      END IF;
      
        
        IF vr_contador IN ( 1 , 15 ) THEN
        pc_log(pr_cdcritic => 1201
              ,pr_dscrilog => '1201 - PARAMES C ' ||
                              ' tpaplicacao: ' || rw_aplica.nraplica  ||
                              ' cdtiplcto:'  || rw_ope.cdtiplcto ||
                              ' nrdconta:'  || rw_aplica.nrdconta ||
                              ', vr_contador: ' || vr_contador); 
        END IF;    
        
      -- Carrega os dados
      GENE0002.pc_escreve_xml
          (pr_xml            => vr_clobxml
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<ope>'||
                                '<nrdconta>' || rw_aplica.nrdconta ||'</nrdconta>'||
                                '<nraplica>' || rw_aplica.nraplica ||'</nraplica>'||
                                '<dstpapli>' || rw_aplica.dstpapli ||'</dstpapli>'||
                                '<dtrefere>' || to_char(rw_ope.dtregistro,'dd/mm/rrrr') ||'</dtrefere>'||
                                '<cdtipreg>' || rw_ope.cdtiplcto ||'</cdtipreg>'||
                                '<vllancto>' || rw_ope.vllancto ||'</vllancto>'||
                                '<idreenvi>' || vr_idreenvio ||'</idreenvi>'||
                                '<dssituac>' || rw_ope.dssituac ||'</dssituac>'||
                                '<dscritic>' || gene0007.fn_caract_acento(vr_dscritica) ||'</dscritic>'||
                              '</ope>');
                                
       -- END IF;
    END LOOP;  

    pc_log(pr_cdcritic => 1201
              ,pr_dscrilog => '1201 - PARAMES C2 ' ||
                              ' vr_contador: ' || vr_contador ||
                              ' vr_qtdtot:' || vr_qtdtot);

    -- Houveram registros, então finalizamos o XML
    gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_xml_temp
                             ,'</Dados></Root>'
                             ,TRUE);   
    -- Devolver o XML
    pr_retxml := xmltype.createXML(vr_clobxml);

      -- Atualizar atributo contador
      gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'Dados'
                                 ,pr_atrib    => 'qtdregis'
                                 ,pr_atval    => vr_qtdtot
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);

    --Fechar Clob e Liberar Memoria
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);        

    -- Retorno OK
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_lista_arquivos --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_historico_aplicacao; 
  
    
  /* Procedimento para Solicitar o Envio de Arquivos Pendentes na hora */
  PROCEDURE pc_solicita_envio(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                             ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_solicita_envio
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Efetuar a chamada a rotina de envio dos lançamentos para a B3 na hora
    
    Alterações : 

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
    -- Incluir nome do módulo logado
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
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN 
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_solicita_envio --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_solicita_envio;  
  
   /* Procedimento para Solicitar o Retorno e Processamento de Arquivos Pendentes na hora */
   PROCEDURE pc_solicita_retorno(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_solicita_retorno
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Efetuar a chamada a rotina de retorno e conciliação dos arquivos da B3 na hora
    
    Alterações : 

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
    -- Incluir nome do módulo logado
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
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN 
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_solicita_retorno --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_solicita_retorno;
  
  /* Procedimento para Solicitar a alteração da situação dos registros com erro para Reenvio */
  PROCEDURE pc_solicita_reenvio(pr_dsdlista IN VARCHAR2           -- Lista de Lançamentos Selecionados
                               ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_solicita_reenvio
    Autor    : Marcos - Envolti
    Data     : Março/2018                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Efetuar a alteração da situação de registros com erro para Reenvio Solicitado.
    
    Alterações : 

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
    -- Incluir nome do módulo logado
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
    
    -- Caso não tenha sido enviada a listadem de lançamentos para solicitar re-envio
    IF trim(pr_dsdlista) IS NULL THEN 
      vr_dscritic := 'Lista de Operações para Re-envio não enviada!';
      RAISE vr_exc_erro;
    END IF;
    
    -- Efetuar UPDATE dos registros para alterar sua situação para Re-envio
    -- e fazer com que os registros sejam reprocessados no próximo Envio
    BEGIN 
      UPDATE tbcapt_custodia_lanctos lct
         SET lct.idsituacao = 2 /*Pendente de Reenvio*/
       WHERE lct.idsituacao = 9 /*Erro*/
         AND ';'||pr_dsdlista  LIKE '%;'||lct.idlancamento||';%';
      vr_qtdregis := SQL%ROWCOUNT; -- Linhas afetadas
    EXCEPTION
      WHEN OTHERS THEN
        -- Erro não tratado 
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
      vr_dsinform := 'Problema no processo de Re-envio! Nenhum registro selecionado estava com situação que permitisse Re-Envio';
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
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN 
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_solicita_concili --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
  END pc_solicita_reenvio;
  
  --Procedures Rotina de Log - tabela: tbgen prglog ocorrencia
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscrilog IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN NUMBER DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT 'TELA_CUSAPL' -- Null assume nome da Package
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  ) 
  IS
    -- ..........................................................................
    --
    --  Programa : pc log
    --  Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    --  Sigla    : GENE
    --  Autor    : Envolti - Belli - Projeto 411 - Fase 2 - Conciliação Despesa
    --  Data     : 01/06/2019                       Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Chamar a rotina de Log para gravação de criticas.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
    vr_nmrotina VARCHAR2 (32)              := vr_nmpackge;
    vr_dscrilog crapcri.dscritic%TYPE;
  BEGIN
    vr_dscrilog := pr_dscrilog;
    IF pr_nmrotina IS NOT NULL THEN
      vr_nmrotina := pr_nmrotina;      
    END IF;
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => vr_dscrilog
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdprograma    => vr_nmrotina
                          ,pr_cdcooper      => pr_cdcooper 
                          ,pr_idprglog      => vr_idprglog
                          );
  EXCEPTION   
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_log;  


  --
  PROCEDURE pc_grava_linha(pr_nmarqger      IN VARCHAR2
                          ,pr_nmdirger      IN VARCHAR2
                          ,pr_utlfileh      IN OUT NOCOPY UTL_FILE.file_type
                          ,pr_des_text      IN VARCHAR2)
  IS
  /* ..........................................................................
    
  Procedure: pc_grava_linha
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar gravação de linha no arquivo
    
  Alteracoes: 
    
  ............................................................................. */
    
      vr_nmproint1               VARCHAR2 (100) := 'pc_grava_linha';
  BEGIN                 
    
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => pr_utlfileh
                                  ,pr_des_text => pr_des_text);
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
  EXCEPTION 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM     ||
                     ' ' || vr_nmaction ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame ||
                     ', pr_nmdirger:' || pr_nmdirger || 
                     ', pr_nmarqger:' || pr_nmarqger;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || '- vr_dscritic:' || vr_dscritic);
  END pc_grava_linha;      
  --  
            
  --
  PROCEDURE pc_abre_arquivo(pr_nmarqger  IN VARCHAR2
                           ,pr_nmdirger  IN VARCHAR2
                           ,pr_dstexcab  IN VARCHAR2 DEFAULT NULL
                           ,pr_tipabert  IN VARCHAR2 DEFAULT 'W' 
                           ,pr_dshandle  OUT UTL_FILE.FILE_TYPE)
  IS
  /* ..........................................................................
    
  Procedure: pc abre arquivo
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2    
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar abertura de arquivo
    
  Alteracoes:              
    
  ............................................................................. */
    --
    vr_nmproint1               VARCHAR2 (100) := 'pc_abre_arquivo';
    vr_dsparint1               VARCHAR2 (4000); 
    vr_exc_saida_abre_arq      EXCEPTION;
    
  PROCEDURE pc_efetiva_abertura
    IS
  BEGIN         
          
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdirger -- || pr_nmarqger 
                            ,pr_nmarquiv => pr_nmarqger
                            ,pr_tipabert => pr_tipabert         -- Modo de abertura (R,W,A)
                            ,pr_flaltper => 0                  -- Não modifica permissões de arquivo
                            ,pr_utlfileh => pr_dshandle        -- Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);                                
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := vr_dscritic;
      vr_dsparame := vr_dsparame  ||
                     ' ' || vr_dsparint1;
      RAISE vr_exc_saida_abre_arq;
    END IF;
                     
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
      pc_grava_linha(pr_nmarqger     => pr_nmarqger
                    ,pr_nmdirger     => pr_nmdirger
                    ,pr_utlfileh     => pr_dshandle
                    ,pr_des_text     => pr_dstexcab );
                    
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction); 
      pc_grava_linha(pr_nmarqger     => pr_nmarqger
                    ,pr_nmdirger     => pr_nmdirger
                    ,pr_utlfileh     => pr_dshandle
                    ,pr_des_text     => '' );
  END pc_efetiva_abertura;
    
  BEGIN    
    vr_dsparint1 := ', pr_nmdirger:' || pr_nmdirger || 
                    ', pr_nmarqger:' || pr_nmarqger || 
                    ', pr_dstexcab:' || pr_dstexcab ||
                    ', pr_tipabert:' || pr_tipabert || 
                    ', pr_flaltper:' || '0';
  
    -- Se for rotina 001 e arquivo de critica sem abrir, então abre 
    IF NOT vr_inabr_arq_cri_pro_con    THEN  
      vr_inabr_arq_cri_pro_con := true;    
      pc_efetiva_abertura;
    --
    ELSIF NOT vr_inabr_arq_msg_pro_con    THEN  
      vr_inabr_arq_msg_pro_con := true;
      pc_efetiva_abertura;
    END IF;    
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
  EXCEPTION 
    WHEN vr_exc_saida_abre_arq THEN 
      -- Monta mensagem
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame  ||
                     ' ' || vr_dsparint1;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM      ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame  ||
                     ' ' || vr_dsparint1;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
  END pc_abre_arquivo;   
  --
  PROCEDURE pc_fecha_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type)
  IS
  /* ..........................................................................
    
  Procedure: pc fecha arquivo
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar fechamento de arquivo
    
  Alteracoes: 
    
  ............................................................................. */

      vr_nmproint1               VARCHAR2 (100) := 'pc_fecha_arquivo';   
  BEGIN                   
    
    IF utl_file.IS_OPEN(pr_utlfileh) THEN
      gene0001.pc_fecha_arquivo(pr_utlfileh => pr_utlfileh);
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
    END IF;
  EXCEPTION 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM      ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || '- vr_dscritic:' || vr_dscritic);
  END pc_fecha_arquivo; 
  --

  --
  PROCEDURE pc_monta_e_mail
  IS
  /* ..........................................................................
    
  Procedure: pc monta e_mail
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Montar e-mails de retorno
    
  Alteracoes: 
    
  ............................................................................. */   
    --
    vr_nmproint1               VARCHAR2 (100) := 'pc_monta_e_mail';
    vr_exc_saida_email         EXCEPTION;
  BEGIN
    
    IF vr_dsemldst IS NULL THEN
      vr_cdcritic := 1230;  -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame ||
                     ' email não encontrado com o acesso:' || vr_dsacseml ||
                     ',vr_dsemldst:'    || vr_dsemldst ||
                     ',pr_des_assunto:' || vr_dsassunt ||
                     ',pr_des_corpo:'   || vr_dscorpo  ||
                     ',pr_des_anexo:'   || vr_dslisane;
      RAISE vr_exc_saida_email;
    END IF;
    
    -- email no Log    
    pc_log(pr_cdcritic => 1201
                         ,pr_dscrilog => 'Solicita email:' ||
                                         ' vr_nmaction:'    || vr_nmaction ||
                                         ',pr_des_destino:' || vr_dsemldst ||
                                         ',pr_des_assunto:' || vr_dsassunt ||
                                         ',pr_des_corpo:'   || vr_dscorpo  ||
                                         ',pr_des_anexo:'   || vr_dslisane
                          ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                         ); 
    --  
    IF vr_fgtempro THEN  
      gene0003.pc_solicita_email(pr_cdcooper        => CASE vr_cdcooper
                                                       WHEN NULL THEN 3
                                                       WHEN 0    THEN 3
                                                       ELSE vr_cdcooper
                                                     END
                              ,pr_cdprogra        => vr_nmpackge
                              ,pr_des_destino     => vr_dsemldst
                              ,pr_des_assunto     => vr_dsassunt
                              ,pr_des_corpo       => vr_dscorpo
                              ,pr_des_anexo       => vr_dslisane
                              ,pr_flg_remove_anex => 'N'
                              ,pr_flg_enviar      => 'S'
                              ,pr_des_erro        => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dsparame := vr_dsparame || 
                     ' pr_cdprogra:'     || vr_nmpackge ||
                     ', pr_des_destino:' || vr_dsemldst ||
                     ', pr_des_assunto:' || vr_dsassunt ||
                     ', pr_des_corpo:'   || vr_dscorpo  ||
                     ', pr_des_anexo:'   || vr_dslisane  ||
                     ', pr_flg_remove_anex:' || 'N' ||
                     ', pr_flg_enviar:'      || 'S';
        RAISE vr_exc_saida_email;
      END IF;
    END IF;
    
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);    
  EXCEPTION
    WHEN vr_exc_saida_email THEN 
      -- Monta mensagem
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || ' - vr_dscritic:' || vr_dscritic);
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => 0);
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || '- vr_dscritic:' || vr_dscritic);                                                  
  END pc_monta_e_mail;
  
  -- Executa geração do custo fornecedor aplicação - B3
  PROCEDURE pc_exe_grc_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                     ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                     ,pr_dtde     IN VARCHAR2           -- Data de 
                                     ,pr_dtate    IN VARCHAR2           -- Date até
                                     )
  IS 
  /* ..........................................................................
    
  Procedure: pc exe grc cst frn aplica
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Executa geração do custo fornecedor aplicação - B3
    
  Alteracoes: 
    
  ............................................................................. */   
    --
    pr_cdcritic  PLS_INTEGER;       -- Código da crítica
    pr_dscritic  VARCHAR2  (4000);  -- Descrição da crítica
    pr_retxml    XMLType;           -- Arquivo de retorno do XML                        
  
    vr_qtmaxerr  CONSTANT NUMBER     (5)  := 200;
    vr_qttoterr           NUMBER    (25,8):= 0;
    vr_prvlrreg           NUMBER    (25,8);
    vr_dtde               date;
    vr_dtate              date;   
        
    -- Busca saldo       
    cursor cr_cusdev IS
      SELECT 
         s.nrdconta
        ,s.dtmvtolt
        ,SUM(s.vlsaldo_concilia)     vlsalcon
        ,COUNT(*)                    qtlansal
      FROM     tbcapt_saldo_aplica s
              ,craprda t2 
              ,craprac t3 
              ,tbcapt_custodia_aplicacao apl
      WHERE    s.dtmvtolt BETWEEN vr_dtde AND vr_dtate
      AND      s.cdcooper = pr_cdcooper
      AND      s.nrdconta = DECODE(NVL(pr_nrdconta,0), 0, s.nrdconta, pr_nrdconta)
      AND      s.tpaplicacao IN (1,2) -- RDA e RAC
      AND      t2.cdcooper (+) = s.cdcooper
      AND      t2.nrdconta (+) = s.nrdconta
      AND      t2.nraplica (+) = s.nraplica
      AND      t3.cdcooper (+) = s.cdcooper
      AND      t3.nrdconta (+) = s.nrdconta
      AND      t3.nraplica (+) = s.nraplica
      AND      NVL(t2.idaplcus,t3.idaplcus) IS NOT NULL
                           AND  apl.idaplicacao  = NVL(t2.idaplcus,t3.idaplcus)
                           AND  apl.DSCODIGO_B3  IS NOT NULL
      GROUP BY s.nrdconta
              ,s.dtmvtolt 
      ORDER BY s.nrdconta
              ,s.dtmvtolt 
      ;
      
    -- Valor registrado para calcular o fator 2 da formula    
    CURSOR cr_vlrreg IS
      SELECT SUM ( t2.vlaplica )  vlaplica
      FROM    craprda t2 
      WHERE   t2.cdcooper        +0 = pr_cdcooper
      AND     ( NVL(pr_nrdconta,0)         = 0 OR 
                t2.nrdconta      +0 = NVL(pr_nrdconta,0) ) 
      AND     t2.idaplcus IN 
        ( SELECT DISTINCT t1.idaplicacao 
          FROM    tbcapt_custodia_lanctos  t1
          WHERE   t1.dtenvio       BETWEEN vr_dtde AND vr_dtate
          AND     t1.idtipo_lancto = 1
          AND     t1.idsituacao    = 8  )  
      UNION    
      SELECT SUM ( t2.vlaplica )  vlaplica
      FROM    craprac t2 
      WHERE   t2.cdcooper        +0 = pr_cdcooper
      AND     ( NVL(pr_nrdconta,0)         = 0 OR 
                t2.nrdconta      +0 = NVL(pr_nrdconta,0) ) 
      AND     t2.idaplcus IN 
        ( SELECT DISTINCT t1.idaplicacao 
          FROM    tbcapt_custodia_lanctos  t1
          WHERE   t1.dtenvio       BETWEEN vr_dtde AND vr_dtate
          AND     t1.idtipo_lancto = 1
          AND     t1.idsituacao    = 8  ) 
      ;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
              
    -- Variaveis gerais
    vr_qtdiauti NUMBER    (2)   := 0;
    vr_vlacucta NUMBER   (25,8) := 0;
    vr_vlmedcta NUMBER   (25,8) := 0;
    --
    vr_vlcusdev_01     NUMBER   (25,8) := 0;
    vr_vlcusdev_02     NUMBER   (25,8) := 0;
    vr_vlregcal        NUMBER   (25,8) := 0;
    --
    vr_vlregist NUMBER   (25,8) := 0;
    vr_qtdiager NUMBER    (2)   := 0;
    vr_vlsaltot NUMBER   (25,8) := 0;
    
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB; 
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_dsvlrprm  VARCHAR2 (100);
    vr_nrdconta  tbcapt_saldo_aplica.nrdconta%TYPE := 0;
    vr_vlcusfix  NUMBER    (25,8) := 0;
    vr_qttabinv  NUMBER     (2)   := 0;
    vr_pctaxmen  NUMBER    (25,8) := 0;
    vr_vladicio  NUMBER    (25,9) := 0;
    vr_idasitua  NUMBER     (1)   := 0;
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_exe_grc_cst_frn_aplica'; -- Rotina e programa
  
  PROCEDURE pc_trata_retorno
  IS
  BEGIN
      
    vr_dsemldst := gene0001.fn_param_sistema('CRED',0,'DES_EMAILS_PROC_B3');
      
    -- Se for rotina 001 e arquivo de critica aberto, então fecha 
    IF vr_inabr_arq_csv_exe_cus     THEN 
        
      pc_fecha_arquivo(vr_dshan001_csv);
      vr_inabr_arq_csv_exe_cus := false;
    END IF;
        
    IF vr_nmarq001_csv IS NOT NULL THEN
      IF vr_dslisane IS NULL THEN
        vr_dslisane := vr_nmdir001_csv || vr_nmarq001_csv;
      ELSE
        vr_dslisane := vr_dslisane || ',' || vr_nmdir001_csv || vr_nmarq001_csv;
      END IF;
    END IF;
    
    -- Se arquivo de critica aberto, então fecha 
    IF vr_inabr_arq_cri_exe_cus     THEN 
      pc_fecha_arquivo(vr_dshan001_critic);
      vr_inabr_arq_cri_exe_cus := false;
    END IF;
        
    IF vr_nmarq001_critic IS NOT NULL THEN
      IF vr_dslisane IS NULL THEN
        vr_dslisane := vr_nmdir001_critic || vr_nmarq001_critic;
      ELSE
        vr_dslisane := vr_dslisane || ',' || vr_nmdir001_critic || vr_nmarq001_critic;
      END IF;
    END IF;
    vr_fgtempro := TRUE;
    pc_monta_e_mail;
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
  END pc_trata_retorno;
  
  PROCEDURE pc_trata_conta 
  IS
    vr_nmrotint  VARCHAR2  (100) := 'pc_trata_conta'; -- Variavel para setar a rotina interna
  BEGIN
    IF vr_qtdiauti > 0 THEN
      -- Saldo medio da conta no perido inteiro
      vr_vlmedcta := vr_vlacucta / vr_qtdiauti;
      -- Aqui busca informac tabela investidor para cada conta
      pc_pos_faixa_tab_investidor(pr_nmmodulo => pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper => pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                 ,pr_qttabinv => vr_qttabinv
                                 ,pr_vlentrad => vr_vlmedcta
                                 ,pr_idasitua => vr_idasitua
                                 ,pr_pctaxmen => vr_pctaxmen
                                 ,pr_vladicio => vr_vladicio
                                 ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                 ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSIF vr_idasitua = 2 THEN
        vr_cdcritic := 891; -- Faixa de valores nao cadastrada
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
          
      -- Retorna do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;                
    -- Custo devido
    vr_vlcusdev_01 := vr_vlcusdev_01 + ( ( vr_vlmedcta * vr_pctaxmen) / 100 );
    
    vr_vlcusdev_02 := vr_vlcusdev_02 + vr_vladicio;    
    --    
    --    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_qttoterr <= vr_qtmaxerr THEN      
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic) ||
                       vr_nmrotint   ||
                       ', nrdconta:' || vr_nrdconta || 
                       ', qttabinv:' || vr_qttabinv ||
                       ', vlentrad:' || vr_vlmedcta ||
                       ', idasitua:' || vr_idasitua ||
                       ', pctaxmen:' || vr_pctaxmen ||
                       ', vladicio:' || vr_vladicio ||
                       '. ' || vr_dsparame;
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic);
      END IF;
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      vr_qttoterr := vr_qttoterr + 1;
      -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Se passar o limite de erros nem gera mais o Log - Chega ...
      IF vr_qttoterr <= vr_qtmaxerr THEN      
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       vr_nmrotint   ||
                       ', nrdconta:' || vr_nrdconta || 
                       ', qttabinv:' || vr_qttabinv ||
                       ', vlentrad:' || vr_vlmedcta ||
                       ', idasitua:' || vr_idasitua ||
                       ', pctaxmen:' || vr_pctaxmen ||
                       ', vladicio:' || vr_vladicio ||
                       '. ' || SQLERRM ||
                       '. ' || vr_dsparame;
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic);  
      END IF;
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      vr_qttoterr := vr_qttoterr + 1; 
      -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
  END pc_trata_conta; 
  --
  
  PROCEDURE pc_CSV
  IS
  BEGIN
   NULL;
  END pc_CSV;
  --
  
  PROCEDURE pc_consulta
  IS
  BEGIN
   NULL;
  END pc_consulta;
  --
  
  --         PRINCIPAL - INICIO DA ROTINA
  BEGIN
    -- Inclusão do módulo e ação logado
    ---gene0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction );
    gene0001.pc_informa_acesso(pr_module => null, pr_action => vr_nmaction);
    -- Variavel para setar ação - 03/04/2019 - PJ411_F2
    vr_dsparame := ', pr_cdmodulo:' || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper ||
                   ', pr_nrdconta:' || NVL(pr_nrdconta,0) ||
                   ', pr_dtde:'     || pr_dtde     ||   
                   ', pr_dtate:'    || pr_dtate;                   
   -- vr_dtde  := pr_dtde;
    --vr_dtate := pr_dtate;
    
    -- Log de erro de execucao
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction ||
                          ' ' || vr_dsparame);  
    
    -- Validar os parâmetros data
    BEGIN
      vr_dtde  := TO_DATE(pr_dtde,  'DD/MM/YYYY');
      vr_dtate := TO_DATE(pr_dtate, 'DD/MM/YYYY');
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 13; -- Data errada
        RAISE vr_exc_erro;
    END;

    -- Se enviada as duas datas, temos de validar se até não é inferior a De
    IF vr_dtde > vr_dtate THEN
      vr_cdcritic := 1233; -- Data inicial deve ser menor ou igual a final:
      RAISE vr_exc_erro;
    END IF;

    vr_nmtip001_csv := 'csv';
    vr_nmdir001_csv := gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                         ,pr_cdcooper => 3  -- Central
                                         ,pr_nmsubdir => 'rl');
    vr_nmarq001_csv := '/' || 'CUSAPL_CLC_INF'     || 
                       '_CP' || NVL(pr_cdcooper,'0') ||
                       '_CT' || NVL(pr_nrdconta,'0') ||
                       '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                    SUBSTR(pr_dtde, 4, 2 ) ||
                                    SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                       '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                    SUBSTR(pr_dtate, 4, 2 ) ||
                                    SUBSTR(pr_dtate, 1, 2 ), '0') ||
                       '.'   || vr_nmtip001_csv;
    pc_abre_arquivo(pr_nmarqger => vr_nmarq001_csv
                   ,pr_nmdirger => vr_nmdir001_csv
                   ,pr_dstexcab => 'Detalhes lista de custo'
                   ,pr_dshandle => vr_dshan001_csv);  
    vr_inabr_arq_csv_exe_cus := true;       
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);  
 
    vr_nmtip001_critic := 'txt';
    vr_nmdir001_critic := vr_dsdirarq;
    vr_nmarq001_critic := 
                   '/'   || 'CUSAPL_CLC_CRI'     || 
                   '_CP' || NVL(pr_cdcooper,'0') ||
                   '_CT' || NVL(pr_nrdconta,'0') ||
                   '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                SUBSTR(pr_dtde, 4, 2 ) ||
                                SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                   '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                SUBSTR(pr_dtate, 4, 2 ) ||
                                SUBSTR(pr_dtate, 1, 2 ), '0') ||
                   '_'   || TO_CHAR(SYSDATE,'DD HH24MISS') ||
                   '.'   || vr_nmtip001_critic;
                    
    pc_abre_arquivo(pr_nmarqger => vr_nmarq001_critic
                   ,pr_nmdirger => vr_nmdir001_critic
                   ,pr_dstexcab => 'Código e descrição das criticas'
                   ,pr_dshandle => vr_dshan001_critic) ;
    vr_inabr_arq_cri_exe_cus := true;  
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      
    IF NVL(pr_cdcooper,0) IN ( 0 , 3 ) THEN
      vr_cdcritic := 794; -- Cooperativa Invalida
      RAISE vr_exc_erro;
    END IF;
    
    -- Fator 1 - Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'CUSTO_FIXO_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper, vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_vlcusfix := TO_NUMBER(vr_dsvlrprm);
    
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'PERC_VLR_REG_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper ,vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_prvlrreg := TO_NUMBER(vr_dsvlrprm);
    --
    vr_dtdiaapl := 0;
    vr_tab_diavlr.DELETE;    
    vr_dtini    := TO_CHAR(vr_dtde, 'YYYYMMDD');
    vr_dtfim    := TO_CHAR(vr_dtate,'YYYYMMDD');
    
    IF vr_dtini IS NULL OR vr_dtfim IS NULL THEN
      vr_cdcritic := 13; -- 013 - Data errada.
      vr_dsparame := vr_dsparame || 
                     ', vr_dtde:'  || vr_dtde  ||
                     ', vr_dtate:' || vr_dtate ||
                     ', TO_CHAR(vr_dtde, YYYYMMDD):' || TO_CHAR(vr_dtde, 'YYYYMMDD')  ||
                     ', TO_CHAR(vr_dtate,YYYYMMDD):' || TO_CHAR(vr_dtate,'YYYYMMDD')  ||
                     ', vr_dtini:' || vr_dtini ||
                     ', vr_dtfim:' || vr_dtfim
                     ;
      RAISE vr_exc_erro;
      
    END IF;
         
    -- Iniciliza o valor por dia
    FOR vr_dtdiaapl IN vr_dtini..vr_dtfim LOOP
      vr_tab_diavlr(vr_dtdiaapl).vlacudia := 0;
    END LOOP;
     
    pc_conciliacao_tab_investidor(pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                 ,pr_qttabinv => vr_qttabinv
                                 ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                 ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>' ||
                             '<Root><dados><listacusdev qtdiager="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Retornar os arquivos conforme filtros informados
    FOR rw_cusdev IN cr_cusdev LOOP 
    BEGIN
      -- Custo Devido por conta
      IF vr_nrdconta = 0 THEN
        vr_nrdconta := rw_cusdev.nrdconta;
      ELSE
        IF vr_nrdconta <> rw_cusdev.nrdconta THEN
          
          pc_trata_conta;
    
          IF NVL(pr_nrdconta,0) = 0 THEN
            vr_qtdiauti := 0;
            vr_vlmedcta := 0;
            vr_vlacucta := 0;
            vr_pctaxmen := 0;
            vr_vladicio := 0;
            vr_nrdconta := rw_cusdev.nrdconta;
          END IF;
        END IF;
      END IF;
      
      -- Acumular valor por dia  
      vr_dtdiaapl := TO_CHAR(rw_cusdev.dtmvtolt,'YYYYMMDD');
      vr_vlacudia := rw_cusdev.vlsalcon;
      -- vr_tab_diavlr(lpad(vr_dtdiaapl, 2, '0')).vlacudia := 25;
      vr_tab_diavlr(vr_dtdiaapl).vlacudia := vr_tab_diavlr(vr_dtdiaapl).vlacudia + vr_vlacudia;
      
      -- Dias uteis por conta 
      vr_qtdiauti := vr_qtdiauti + 1;
      vr_vlacucta := vr_vlacucta + vr_vlacudia;

    EXCEPTION
      WHEN OTHERS THEN
        -- Quando erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Se passar o limite de erros nem gera mais o Log - Chega ...
        IF vr_qttoterr <= vr_qtmaxerr THEN      
          -- Efetuar retorno do erro não tratado
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         '. ' || SQLERRM ||
                         '. ' || vr_dsparame;
          -- Log de erro de execucao
          pc_log(pr_cdcritic => vr_cdcritic
                ,pr_dscrilog => vr_dscritic);  
        END IF;
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        vr_qttoterr := vr_qttoterr + 1;
        -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
      END;      
    END LOOP;
    
    -- Ultima conta busca informação da tabela investidor
    pc_trata_conta;
    
    vr_vlregcal := 0;
    vr_vlregist := 0;
    -- Fator 2
    FOR rw_vlrreg IN cr_vlrreg LOOP
      vr_vlregist := vr_vlregist + NVL(rw_vlrreg.vlaplica, 0);    
      vr_vlregcal := vr_vlregcal + ( ( NVL(rw_vlrreg.vlaplica, 0) * vr_prvlrreg ) / 100 );       
        
    END LOOP;
    
    -- Fator 3
    -- Montar os dias e valores acumulados para a saida
    FOR vr_dtdiaapl IN vr_dtini..vr_dtfim LOOP
      IF vr_tab_diavlr(vr_dtdiaapl).vlacudia > 0 THEN
        
        vr_qtdiager := vr_qtdiager + 1;

        vr_dslinha :=  SUBSTR(vr_dtdiaapl, 7, 8) || '/' ||
                       SUBSTR(vr_dtdiaapl, 5, 2) || '/' ||
                       SUBSTR(vr_dtdiaapl, 1, 4);
        -- Carrega os dados
        GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<dia>'||
                              '<dtmvtolt>' || vr_dslinha  || '</dtmvtolt>'||
                              '<vlsalcon>' || TO_CHAR(vr_tab_diavlr(vr_dtdiaapl).vlacudia,'999G999G999G990D00')||
                                              '</vlsalcon>'||
                              '</dia>');
        -- Retorno do módulo e ação logado
        GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
        
        -- BELLAO8
        pc_grava_linha(pr_nmarqger => vr_nmarq001_csv
                      ,pr_nmdirger => vr_nmdir001_csv
                      ,pr_utlfileh => vr_dshan001_csv
                      ,pr_des_text => vr_dslinha || ';' ||
                                      vr_tab_diavlr(vr_dtdiaapl).vlacudia
                      );
      
      END IF;
    END LOOP;
    
                       
    IF NVL(pr_nrdconta,0) = 0 THEN
      vr_vlmedcta := 0;
      vr_pctaxmen := 0;
      vr_vladicio := 0;      
      vr_qtdiauti := vr_qtdiager;
    ELSE  
      vr_vlcusfix := 0;
    END IF;
    -- Custo devido
    
    -- Valor devido final 
    vr_vlsaltot :=   vr_vlcusfix    -- Fator 1
                   + vr_vlregcal    -- Fator 2
                   + vr_vlcusdev_01 -- Fator 3 a
                   + vr_vlcusdev_02 -- Fator 3 b
                   ;  

/*
<td>Dias Uteis</td>	              'qtdiauti') 
<td>Base Volume</td>		          'vlsalmed') 
<td>Taxa Mensal</td>		          'prtaxmen') 
<td>Valor Base C/Taxa Mensal      'vladicio') 
<td>Valor Adicional  </td>		    'vltotadi') 
<td>Valor Fixo</td>		            'vlcusfix') 
<td>Valor Registrado Total</td>	  'vlregist') 
<td>Percentual P/Valor Registrado 'prvlrreg') 
<td>Valor Registrado a pagar</td> 'vlregcal')
<td>Valor Devido Total</td>		  'vlsaltot')
*/
                                                                                             
        
    -- Carrega os "Dados  Finais"
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '</listacusdev><dadosfinais>'||
                              '<qtdiauti>' || vr_qtdiauti ||'</qtdiauti>'|| -- Dias Uteis - Só por conta
                              '<vlsalmed>' || TO_CHAR(vr_vlmedcta,'999G999G999G990D00') ||'</vlsalmed>'||     -- Base Volume - Só por conta
                              '<vlregist>' || TO_CHAR(vr_vlregist,'999G999G999G990D00') ||'</vlregist>'||    -- vlregtot - Só por conta
                              --
                              '<prtaxmen>' || TO_CHAR(vr_pctaxmen,'9G999G990D00000000') ||'</prtaxmen>'|| -- Taxa Mensal - Só por conta
                              '<vladicio>' || TO_CHAR(vr_vlcusdev_01,'999G999G999G990D00') ||'</vladicio>'|| -- Valor Adicional - Só por conta
                              '<vltotadi>' || TO_CHAR(vr_vlcusdev_02,'999G999G999G990D00') ||'</vltotadi>'|| -- Valor Devido Parcial - Fator 3
                              ---                             
                              '<vlcusfix>' || TO_CHAR(vr_vlcusfix,'999G999G999G990D00') ||'</vlcusfix>'|| -- Valor fixo - Fator 1 
                              '<vlregcal>' || TO_CHAR(vr_vlregcal,'999G999G999G990D00') ||'</vlregcal>'|| -- Valor registrado - Fator 2 
                              '<vlsaltot>' || TO_CHAR(vr_vlsaltot,'999G999G999G990D00') ||'</vlsaltot>'|| -- Valor Devido Total
                              --
                              '<prvlrreg>' || TO_CHAR(vr_prvlrreg,'9G999G999G990D0000') ||'</prvlrreg>'|| -- Percentual - Fator 2
                              '</dadosfinais>');
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</dados></Root>'
                           ,pr_fecha_xml      => TRUE);
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    

    -- Buscar Diretorio Padrao da Cooperativa
    vr_nmdir001_html := gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                         ,pr_cdcooper => 3  -- Central
                                         ,pr_nmsubdir => 'rl');
                                         
    vr_nmarq001_html := '/' || 'CUSAPL_CLC_INF'     || 
                       '_CP' || NVL(pr_cdcooper,'0') ||
                       '_CT' || NVL(pr_nrdconta,'0') ||
                       '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                    SUBSTR(pr_dtde, 4, 2 ) ||
                                    SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                       '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                    SUBSTR(pr_dtate, 4, 2 ) ||
                                    SUBSTR(pr_dtate, 1, 2 ), '0') ||
                       '.xml';    
            
    -- Gerar o arquivo na pasta converte
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob
                                 ,pr_caminho  => vr_nmdir001_html
                                 ,pr_arquivo  => vr_nmarq001_html
                                 ,pr_des_erro => vr_dscritic);
                                                                          

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Atualizar o atributo com quantidade de registro caso maior que zero
    IF vr_qtdiager > 0 THEN 
      -- Atualizar atributo contador
      gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'listacusdev'
                                 ,pr_atrib    => 'qtdiager'
                                 ,pr_atval    => vr_qtdiager
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);
      -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
    
    -- Retorno OK
    ---pr_des_erro := 'OK';
        
    --
    ROLLBACK;
    vr_dsassunt := 'Calculo do valor devido ao B3';
    IF vr_qttoterr > 0 THEN
      vr_dscorpo := '<br>' ||
                    'Processo com erro parcial.'    || '<br>' ||
                    'Verificar os erros no anexo.'  || '<br>' ||
                    'Também as informações calculadas estão em anexo'  || 
                    ' ou consulte na tela CUSAPL.';
    ELSE
      vr_dscorpo := '<br>' ||
                    'Processo Com Sucesso' || '<br>' ||
                    'As informações calculadas estão em anexo.'  || 
                    ' ou consulte na tela CUSAPL.';
    END IF;
    pc_trata_retorno;
    COMMIT;
                                 
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                     vr_nmaction ||
                     '. ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);   
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
      ROLLBACK;
      vr_dsassunt := 'Erro de processamento no calculo do valor devido ao B3';
      vr_dscorpo  := 'Erro: ' || vr_cdcritic || ' => ' || vr_dscritic;
      pc_trata_retorno;
      COMMIT;                                                                                                     
    WHEN OTHERS THEN 
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmaction ||
                     ' ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
      -                              '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      ROLLBACK;
      vr_dsassunt := 'Erro de processamento no calculo do valor devido ao B3';
      vr_dscorpo  := 'Erro: ' || vr_cdcritic || ' => ' || vr_dscritic;
      pc_trata_retorno;
      COMMIT;
  END pc_exe_grc_cst_frn_aplica;    


  -- Procedimento para tratar custo fornecedor aplicação - B3
  PROCEDURE pc_trt_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                 ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                 ,pr_dtde     IN VARCHAR2           -- Data de 
                                 ,pr_dtate    IN VARCHAR2           -- Date até
                                 ,pr_tpproces IN NUMBER             -- Tipo: 1 - Gera, 2 - Consulta, 3 - Caminho CSV
                                 ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                 )
  IS
  /* ..........................................................................
    
  Procedure: pc trt cst frn_aplica
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Procedimento para tratar custo fornecedor aplicação - B3
    
  Alteracoes: 
    
  ............................................................................. */   
    ----vr_qttoterr           NUMBER    (25,8):= 0;
    vr_prvlrreg           NUMBER    (25,8);
    vr_dtde               date;
    vr_dtate              date;
    vr_dstipo             VARCHAR2(10);   
        
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
    vr_exc_erro_trt_cst  EXCEPTION;
              
    -- Variaveis gerais
    
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB; 
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_dsvlrprm  VARCHAR2 (100);
    vr_vlcusfix  NUMBER    (25,8) := 0;
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_trt_cst_frn_aplica'; -- Rotina e programa
   
  --
  
  PROCEDURE pc_passagem_nome_arq
  IS
    -- Variaveis de controle de erro e modulo
    vr_dsparint  VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotint  VARCHAR2  (100) := 'pc_passagem_nome_arq'; -- Rotina e programa 
    
  BEGIN
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction );
    
    --IF vr_dstipo = 'csv' THEN
    --  vr_nmdir001_csv := vr_dsdirarq;
    --ELSE
    --  vr_nmdir001_csv := gene0001.fn_diretorio('C',3,'rl');
    -- IF;
    
    vr_nmdir001_csv := vr_dsdirarq;
    vr_nmarq001_csv := 'CUSAPL_CLC_INF'     || 
                       '_CP' || NVL(pr_cdcooper,'0') ||
                       '_CT' || NVL(pr_nrdconta,'0') ||
                       '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                    SUBSTR(pr_dtde, 4, 2 ) ||
                                    SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                       '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                    SUBSTR(pr_dtate, 4, 2 ) ||
                                    SUBSTR(pr_dtate, 1, 2 ), '0') ||
                       '.'   || vr_dstipo; -- 'csv'; 
                             
    vr_dsparint := ', vr_nmdir001:'   || vr_nmdir001_csv || 
                   ', vr_nmarq001:' || vr_nmarq001_csv ||
                   ', vr_dstipo:'   || vr_dstipo;
                   

    -- Log de erro de execucao
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          ', ' || vr_nmaction ||
                          ', ' || vr_dsparame ||
                          ', ' || vr_dsparint ||
                          ', pr_cdcooper: ' || '3' ||
                          ', pr_cdagenci: ' || vr_cdagenci ||    
                          ', pr_nrdcaixa: ' || vr_nrdcaixa  ||   
                          ', pr_nmarqimp: ' || vr_nmarq001_csv ||
                          ', pr_nmdireto: ' || vr_nmdir001_csv ); 

    --Enviar arquivo para Web
    GENE0002.pc_envia_arquivo_web(pr_cdcooper => 3               
                         ,pr_cdagenci => vr_cdagenci     
                         ,pr_nrdcaixa => vr_nrdcaixa     
                         ,pr_nmarqimp => vr_nmarq001_csv 
                         ,pr_nmdireto => vr_nmdir001_csv 
                         ,pr_nmarqpdf => vr_nmarq001_csv 
                         ,pr_des_reto => vr_des_reto     
                         ,pr_tab_erro => vr_tab_erro);   
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN                  
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao devolver arquivo ' ||  vr_dstipo || ' para AimaroWeb.';  
          END IF;                   
          --Sair 
          RAISE vr_exc_erro_trt_cst;                  
    END IF; 
                       
    -- Carrega os dados
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<arq>'||
                              CASE vr_dstipo
                              WHEN 'csv' THEN
                                '<nmarq001csv>' || vr_nmarq001_csv || '</nmarq001csv>'
                              ELSE
                                '<nmarq001xml>' || vr_nmarq001_csv || '</nmarq001xml>'
                              END ||
                              '</arq>');
                              
    -- Limpa nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL ); 
  EXCEPTION
    WHEN OTHERS THEN
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     ' ' || SQLERRM     ||
                     vr_nmaction        ||
                     ' ' || vr_nmrotint ||
                     ' ' || vr_dsparame ||
                     ' ' || vr_dsparint;      
      RAISE vr_exc_erro_trt_cst;                     
  END pc_passagem_nome_arq;
  --
  
  PROCEDURE pc_consulta
  IS                        
      vr_utl_file         utl_file.file_type;                        --> Handle
      ---vr_typ_saida        VARCHAR2(3);                               --> Saída do comando no OS
      vr_qtdregist        NUMBER;                                    --> Quantidade de registros
      vr_dslinha          tbcapt_custodia_conteudo_arq.dslinha%TYPE; --> Conteudo das linhas
      --
      vr_aux        VARCHAR2(1000) := ' -- ';    
  BEGIN   
    vr_qtdregist := 0;
    
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction         ||
                          ' pc_consulta '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq);    
      
    --                           
    pc_abre_arquivo(pr_nmarqger =>  '/' || 'CUSAPL_CLC_INF_CP13_CT0_20181201_A_20181231.csv'
                   ,pr_nmdirger => vr_dsdirarq 
                   ,pr_tipabert => 'R'
                   ,pr_dshandle => vr_utl_file) ;
   
    -- Buscar todas as linhas do arquivo
    LOOP
    BEGIN
      -- Adicionar linha ao arquivo
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utl_file
                                  ,pr_des_text => vr_dslinha);


      -- Incrementar o contador
      vr_qtdregist := vr_qtdregist + 1;
      vr_aux := vr_aux || ' - ' || vr_dslinha;
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;           
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        pc_log(pr_cdcritic => 9999
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 9999)      ||
                          ' ' || SQLERRM      ||
                          vr_nmaction         ||
                          ' pc_consulta - LOOP '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq);                      
    END;
    END LOOP;
    
    pc_fecha_arquivo(vr_utl_file);
    
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction         ||
                          ' pc_consulta FIM OK '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq  ||
                          ' ' || vr_qtdregist ||
                          ' ' || vr_aux  );
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      pc_log(pr_cdcritic => 9999
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 9999)      ||
                          ' ' || SQLERRM      ||
                          vr_nmaction         ||
                          ' pc_consulta '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq);
  END pc_consulta;
  --
  
  -- pc_cria_job
  PROCEDURE pc_cria_job
  IS                              
    vr_jobname        VARCHAR2  (100);
    vr_qtparametros   PLS_INTEGER      := 1;
    -- Variaveis de controle de erro e modulo
    vr_dsparint       VARCHAR2 (4000)  := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotint       VARCHAR2  (100)  := 'pc_cria_job'; -- Rotina e programa 
  BEGIN    
        
    -- Geração do custo do fornecedor de movimentação ee aplicações         
    vr_jobname  := 'JBCAPT_CSLFRMAPL_' || '$';
                    
    -- Job que se start e depois se autodestroi
    vr_jobname := dbms_scheduler.generate_job_name(vr_jobname);    
                  
    dbms_scheduler.create_job(job_name     => vr_jobname
                             ,job_type     => 'STORED_PROCEDURE'
                             ,job_action   => 'CECRED.TELA_CUSAPL.pc_exe_grc_cst_frn_aplica'
                             ,enabled      => FALSE
                             ,number_of_arguments => 5
                             ,start_date          => null--( SYSDATE + (vr_qtminuto /1440) ) --> Horario da execução
                             ,repeat_interval     => NULL                              --> apenas uma vez
                              );                                   
    
    vr_qtparametros := 1;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        ,argument_value    => anydata.ConvertVarchar2(pr_cdmodulo)
                                        );                                       
    vr_qtparametros := 2;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        ,argument_value    => anydata.ConvertNumber(pr_cdcooper)
                                        );
    vr_qtparametros := 3;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        ,argument_value    => anydata.ConvertVarchar2(NVL(pr_nrdconta,0))
                                        );      
    vr_qtparametros := 4;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        --,argument_value    => anydata.ConvertVarchar2(vr_tab_nmarqtel(1))
                                        ,argument_value    => anydata.ConvertVarchar2(pr_dtde)
                                        );
    vr_qtparametros := 5;    
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        --,argument_value    => anydata.ConvertCollection(vr_typ_craprej_array)
                                        ,argument_value    => anydata.ConvertVarchar2(pr_dtate)
                                        );     
    
    dbms_scheduler.enable(  name => vr_jobname );
    
    vr_cdcritic := 912;            
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          
    -- Carrega os dados
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<Sucesso>' || vr_dscritic || '</Sucesso>');  
    vr_cdcritic := NULL;            
    vr_dscritic := NULL;
                                          
  EXCEPTION
    WHEN OTHERS THEN
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     vr_nmaction         ||
                     '. ' || vr_nmrotint ||
                     '. ' || SQLERRM     ||
                     '. ' || vr_dsparame ||
                     '. ' || vr_dsparint;      
      RAISE vr_exc_erro_trt_cst;                        
  END pc_cria_job;  
  
  --    
  PROCEDURE pc_gera
  IS
  BEGIN
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    -- Variavel para setar ação - 03/04/2019 - PJ411_F2
    vr_dsparame := vr_dsparame || ' - pc_gera'; 
      
    IF NVL(pr_cdcooper,0) IN ( 0 , 3 ) THEN
      vr_cdcritic := 794; -- Cooperativa Invalida
      RAISE vr_exc_erro_trt_cst;
    END IF;
    
    -- Fator 1 - Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'CUSTO_FIXO_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper, vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro_trt_cst;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_vlcusfix := TO_NUMBER(vr_dsvlrprm);
    
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'PERC_VLR_REG_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper ,vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro_trt_cst;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_prvlrreg := TO_NUMBER(vr_dsvlrprm);
    
    vr_dtini := TO_CHAR(vr_dtde, 'YYYYMMDD');
    vr_dtfim := TO_CHAR(vr_dtate,'YYYYMMDD');
    
    
    -----  negocio NEGOCIO -----------------
    
    /*
    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>' ||
                             '<Root><dados><listacusdev qtdiager="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

   */
   
   
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<listacusdev qtdiager="0">');   
   
   
    -- Fator 3
    -- Montar os dias e valores acumulados para a saida
    ---FOR vr_dtdiaapl IN vr_dtini..vr_dtfim LOOP      
        -- Carrega os dados
        GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<dia>'||
                              '<dtmvtolt>' || vr_dslinha  || '</dtmvtolt>'||
                              '<vlsalcon>' || vr_tab_diavlr(vr_dtdiaapl).vlacudia ||'</vlsalcon>'||
                              '</dia>');
        -- Retorno do módulo e ação logado
        GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    ---END LOOP;  
           
    -- Carrega os "Dados  Finais"
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '</listacusdev><dadosfinais>'||
                       ---       '<qtdiauti>' || vr_qtdiauti ||'</qtdiauti>'|| -- Dias Uteis - Só por conta                              
                         ---    '<prvlrreg>' || vr_prvlrreg ||'</prvlrreg>'|| -- Percentual - Fator 2
                              '</dadosfinais>');
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
   
    
  end pc_gera;           
                   
               ---   ROTINA PRINCIPAL INICIO
  BEGIN
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    -- Variavel para setar ação - 03/04/2019 - PJ411_F2
    vr_dsparame := 'pr_cdmodulo:'   || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper ||
                   ', pr_nrdconta:' || NVL(pr_nrdconta,0) ||
                   ', pr_dtde:'     || pr_dtde   ||
                   ', pr_dtate:'    || pr_dtate  ||
                   ', pr_tpproces:' || pr_tpproces;

    
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
      vr_cdcritic := 0;
      RAISE vr_exc_erro_trt_cst;      
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    
    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>' ||
                             '<Root><dados>'); --<listacusdev qtdiager="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    -- Validar os parâmetros data
    BEGIN
      vr_dtde  := TO_DATE(pr_dtde,  'DD/MM/YYYY');
      vr_dtate := TO_DATE(pr_dtate, 'DD/MM/YYYY');
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 13; -- Data errada
        RAISE vr_exc_erro_trt_cst;
    END;

    -- Se enviada as duas datas, temos de validar se até não é inferior a De
    IF vr_dtde > vr_dtate THEN
      vr_cdcritic := 1233; -- Data inicial deve ser menor ou igual a final:
      RAISE vr_exc_erro_trt_cst;
    END IF;
                       
    IF pr_tpproces = 1 THEN
      --pc_gera;
      pc_cria_job;
    ELSIF pr_tpproces = 2 THEN
      
    -- ATENCAO ESTA OPCAO A TEAL VAI LER DIRETO O BLABLA .HTML E LANÇAR NA TELA SEM O BACK
    -- POIS A OPCAO GERAR JA´GRAVOU O HTML NO DIRETORIO   PARA TELA LER,,, ALEM DO CSV 
    
    ---NULL;
      vr_dstipo := 'xml';
      pc_passagem_nome_arq;
    
    --  pc_consulta;
      
      
    ELSIF pr_tpproces = 3 THEN
      vr_dstipo := 'csv';
      pc_passagem_nome_arq;
    ELSE
      vr_cdcritic := 513;
      RAISE vr_exc_erro_trt_cst;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</dados></Root>'
                           ,pr_fecha_xml      => TRUE);
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
    
    -- Limpa do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
                     
  EXCEPTION
    WHEN vr_exc_erro_trt_cst THEN                     
      -- Propagar Erro       
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
      IF vr_cdcritic <> 9999 THEN 
        vr_dscritic := vr_dscritic ||
                       vr_nmaction ||
                       '. ' || vr_dsparame;
      END IF;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic); 
      -- Devolver criticas      
      --     pr_nmdcampo := NULL;
      IF vr_cdcritic <> 1233 THEN      
        pr_cdcritic := 1495;
      ELSE   
        pr_cdcritic := vr_cdcritic;        
      END IF; 
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
                                                                                                              
    WHEN OTHERS THEN 
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     '. ' || SQLERRM ||
                     vr_nmaction ||
                     '. ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
            
  END pc_trt_cst_frn_aplica; 
  
  -- Trata a tabela de parâmetro de custo de investidor para de conciliação
  PROCEDURE pc_conciliacao_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
    )
  IS    
    -- ..........................................................................
    --
    --  Programa : pc conciliacao tab investidor
    --  Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    --  Sigla    : GENE
    --  Autor    : Envolti - Belli - Projeto 411 - Fase 2 - Conciliação Despesa
    --  Data     : 03/04/2019                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Trata a tabela de parâmetro de custo de investidor para de conciliação
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --

    -- Buscar dados tabela investidor
    CURSOR cr_tabinv
    IS 
        SELECT
               rownum nrrownum
              ,t1.idfrninv
              ,t1.vlfaixade
              ,t1.vlfaixaate
              ,t1.petaxa_mensal
              ,t1.vladicional
        FROM     tbcapt_custodia_frn_investidor t1
        WHERE    t1.flgativo = '1'
        ORDER BY t1.vlfaixade
        ;
        
    rw_tabinv  cr_tabinv%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    --           
    vr_qtrownum NUMBER(2) := 0;  
    -- Variaveis de controle de erro e modulo
    vr_dsparame  VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro  VARCHAR2  (100) := 'TELA_CUSAPL.pc_conciliacao_tab_investidor'; -- Rotina e programa 
    
  BEGIN
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => pr_nmmodulo, pr_action => vr_nmrotpro );        
    vr_dsparame := 'pr_nmmodulo:'  || pr_nmmodulo || 
                   ',pr_cdcooper:' || pr_cdcooper;
                   
    -- CUSAPL_CADASTRO       - faz o tratamento do cadastro
    -- CUSAPL_CALCULO_DEVIDO - gera type                
    IF pr_nmmodulo = 'CUSAPL_CALCULO_DEVIDO' THEN
      NULL;
    END IF;
    
    vr_tab_tabinv.delete;
    FOR rw_tabinv IN cr_tabinv
    LOOP
      vr_qtrownum := vr_qtrownum + 1;
      vr_tab_tabinv(vr_qtrownum).idfrninv  := rw_tabinv.idfrninv;
      vr_tab_tabinv(vr_qtrownum).vlfaixde  := rw_tabinv.vlfaixade;
      vr_tab_tabinv(vr_qtrownum).vlfaixate := rw_tabinv.vlfaixaate;
      vr_tab_tabinv(vr_qtrownum).pctaxmen  := rw_tabinv.petaxa_mensal;
      vr_tab_tabinv(vr_qtrownum).vladicio  := rw_tabinv.vladicional;
    END LOOP;
    
    pr_qttabinv := vr_qtrownum;

    -- Zera nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL );   
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                     vr_nmrotpro     ||
                     '. ' || vr_dsparame; 
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     '. ' || SQLERRM ||
                     vr_nmrotpro     || 
                     '. ' || vr_dsparame;     
  END pc_conciliacao_tab_investidor;  


  -- Trata a tabela de parâmetro de custo de investidor para de conciliação
  PROCEDURE pc_pos_faixa_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv IN NUMBER
    ,pr_vlentrad IN NUMBER
    ,pr_idasitua OUT NUMBER
    ,pr_pctaxmen OUT NUMBER
    ,pr_vladicio OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
   
    )
  IS   
  /* ..........................................................................
    
  Procedure: pc pos faixa tab investidor
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Trata a tabela de parâmetro de custo de investidor para de conciliação
    
  Alteracoes: 
    
  ............................................................................. */ 
      
    -- Variaveis de controle de erro e modulo
    vr_dsparame  VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro  VARCHAR2  (100) := 'TELA_CUSAPL.pc_pos_faixa_tab_investidor'; -- Rotina e programa 

  BEGIN
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => pr_nmmodulo, pr_action => vr_nmrotpro );        
    vr_dsparame := 'pr_nmmodulo:'  || pr_nmmodulo || 
                   ',pr_cdcooper:' || pr_cdcooper;
     
    -- 
    pr_idasitua := 2;
    FOR vr_nrrownum IN 1..pr_qttabinv LOOP
    --  dbms_output.put_line('vlfaixde  :' || vr_tab_tabinv(vr_nrrownum).vlfaixde );
      IF pr_vlentrad >= vr_tab_tabinv(vr_nrrownum).vlfaixde  AND
         pr_vlentrad <= vr_tab_tabinv(vr_nrrownum).vlfaixate     THEN
     --   dbms_output.put_line('vlfaixde:' || vr_tab_tabinv(vr_nrrownum).vlfaixde );
        pr_pctaxmen := vr_tab_tabinv(vr_nrrownum).pctaxmen;
        pr_vladicio := vr_tab_tabinv(vr_nrrownum).vladicio;
        pr_idasitua := 1;
    
        EXIT;
      END IF;
    END LOOP;

    -- Zera nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL );   
  EXCEPTION 
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmrotpro     || 
                     ' ' || vr_dsparame;
  END pc_pos_faixa_tab_investidor; 

  -- 
  PROCEDURE pc_concil_tab_investidor(pr_cdmodulo IN VARCHAR2           -- Tela e qual consulta, 48 caractere
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa selecionada (0 para todas)
                                    ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                    )
  IS
  /* ..........................................................................
    
  Procedure: pc concil tab investidor
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Carrega a tabela de parâmetro de custo de investidor para de conciliação
    
  Alteracoes: 
    
  ............................................................................. */ 
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
    
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB; 
    
    vr_qttabinv  NUMBER     (2)   := 0;
    
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_concil_tab_investidor'; -- Rotina e programa
    
    FUNCTION  fn_format2
      ( vr_vlentrada IN NUMBER )  RETURN VARCHAR2
    IS
    BEGIN
     IF vr_vlentrada = 0 THEN
       RETURN '0.00';
     ELSIF vr_vlentrada < 1 THEN
       --RETURN RTRIM((REPLACE(REPLACE(TO_CHAR( vr_vlentrada,'0.00000000'),'.',',') ,' ','')),'0');
       RETURN RTRIM((
                REPLACE(
                    --REPLACE(
                            TO_CHAR( vr_vlentrada,'0.00000000')
                    --       ,'.',',')
                 ,' ','')
              ),'0');
     ELSE
       RETURN vr_vlentrada;
     END IF;
    END;
    ----
    FUNCTION  fn_format
      ( vr_vlentrada IN NUMBER )  RETURN VARCHAR2
    IS
    BEGIN
     RETURN REPLACE(REPLACE(TO_CHAR( vr_vlentrada,'000000000000000.00000000'),'.',',') ,' ','');
    END;
    --
  BEGIN  ---   ROTINA PRINCIPAL INICIO
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction );
     
    -- Variavel para setar ação
    vr_dsparame := 'pr_cdmodulo:'   || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper;
                   
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
      vr_cdcritic := 0;
      RAISE vr_exc_erro;      
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
     
    pc_conciliacao_tab_investidor(pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                 ,pr_qttabinv => vr_qttabinv
                                 ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                 ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><listatabinv qttabinv="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    -- 
    IF NVL(vr_qttabinv,0) = 0 THEN
      NULL;
    ELSE
      FOR vr_nrrownum IN 1..vr_qttabinv LOOP   
        
        -- Carrega os dados
        GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<faixas>'||
                              '<idfrninv>' || vr_tab_tabinv(vr_nrrownum).idfrninv  || '</idfrninv>'||
                              '<vlfaixde>' || TO_CHAR(fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixde) ,'999G999G999G999D99') || '</vlfaixde>' ||
                              '<vlfaixate>'|| TO_CHAR(fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixate),'999G999G999G999D99') || '</vlfaixate>'||
                              '<pctaxmen>' || TO_CHAR(vr_tab_tabinv(vr_nrrownum).pctaxmen ,'9G999G990D00000000') || '</pctaxmen>' ||       
                              '<vladicio>' || TO_CHAR(fn_format2(vr_tab_tabinv(vr_nrrownum).vladicio) ,'999G999G999G999D99') || '</vladicio>' ||
                              '</faixas>');
        -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
        
      END LOOP;
    END IF;


    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</listatabinv></Root>'
                           ,pr_fecha_xml      => TRUE);
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Atualizar o atributo com quantidade de registro caso maior que zero
    IF vr_qttabinv > 0 THEN 
      -- Atualizar atributo contador
      gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'listatabinv'
                                 ,pr_atrib    => 'qttabinv'
                                 ,pr_atval    => vr_qttabinv
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);
      -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
    --
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                     vr_nmaction ||
                     '. ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');         
    WHEN OTHERS THEN 
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmaction ||
                     ' ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 
  END pc_concil_tab_investidor;
      
  
  -- Atualiza tabela investidor
  PROCEDURE pc_atz_faixa_tab_investidor(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                       )
  IS
    /* .............................................................................
     Procedure: pc atz faixa tab investidor
     Sistema  : Rotina de aplicações
     Autor    : Belli/Envolti
     Data    : Abril/2019.                  Ultima atualizacao: 

     Dados referentes ao programa:
     Frequencia: Sempre que for chamado
     Objetivo  : Atualizar o cadastro de investidor de origem do fornecedor que nesta data de criação 
     
     Alteracoes:                 
    ..............................................................................*/ 
    
    pr_cdmodulo  VARCHAR2(10)          := 'CUSAPL'; -- Tela e qual consulta, 48 caractere
    pr_cdcooper  crapcop.cdcooper%TYPE := 3;                  
    --Variaveis locais
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);  
    x1 VARCHAR2(100);   
    
    vr_id_acesso PLS_INTEGER    := 0;
    vr_qttabinv  NUMBER   (2)   := 0;
    vr_flgativo  NUMBER   (1)   := 2; -- 1 ativado, 2 Inativado
    
    vr_idfrninv  tbcapt_custodia_frn_investidor.idfrninv%TYPE;
    vr_vlfaixde  tbcapt_custodia_frn_investidor.vlfaixade%TYPE;
    vr_vlfaixate tbcapt_custodia_frn_investidor.vlfaixaate%TYPE;
    vr_pctaxmen  tbcapt_custodia_frn_investidor.petaxa_mensal%TYPE;
    vr_vladicio  tbcapt_custodia_frn_investidor.vladicional%TYPE;
    
    vr_qtinclus  NUMBER(2) := 0;
    vr_qtexclus  NUMBER(2) := 0;
    vr_qtaltera  NUMBER(2) := 0;
    vr_qtnaoalt  NUMBER(2) := 0;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_exc_saida EXCEPTION;
    
    -- Variáveis para tratamento do XML
    vr_node_list xmldom.DOMNodeList;
    vr_parser    xmlparser.Parser;
    vr_doc       xmldom.DOMDocument;
    vr_lenght    NUMBER;
    vr_node_name VARCHAR2(100);
    vr_item_node xmldom.DOMNode;    
    
    -- Arq XML
    vr_xmltype sys.xmltype;
    
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_atz_faixa_tab_investidor'; -- Rotina e programa
  
    --vr_tab_contas_demitidas typ_tab_contas_demitidas;    
    
    -- Retornar o valor do nodo tratando casos nulos
    FUNCTION fn_extract(pr_nodo  VARCHAR2) RETURN VARCHAR2 IS
      
    BEGIN
      -- Extrai e retorna o valor... retornando null em caso de erro ao ler
      RETURN pr_retxml.extract(pr_nodo).getstringval();
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    --
  BEGIN                                  ---   ROTINA PRINCIPAL INICIO
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction );
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '',.''';     
      
    -- Variavel para setar ação
    vr_dsparame := 'pr_cdmodulo:'   || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper;
                       
    -- extrair informações padrão do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml 
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao 
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction);
    
    -- Inicializa variavel
    vr_id_acesso := 0;
    vr_xmltype  := pr_retxml;

    -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
    vr_parser := xmlparser.newParser;
    xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
    vr_doc    := xmlparser.getDocument(vr_parser);
    xmlparser.freeParser(vr_parser);

    -- Faz o get de toda a lista de elementos
    vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
    vr_lenght    := xmldom.getLength(vr_node_list);
    
    -- Inicioando Varredura do XML.
    BEGIN
          
      -- Percorrer os elementos
      FOR i IN 0..vr_lenght LOOP
         -- Pega o item
         vr_item_node := xmldom.item(vr_node_list, i);            
             
         -- Captura o nome do nodo
         vr_node_name := xmldom.getNodeName(vr_item_node);
         -- Verifica qual nodo esta sendo lido
         IF vr_node_name IN ('Root') THEN
            CONTINUE; -- Descer para o próximo filho
         ELSIF vr_node_name IN ('Dados') THEN
            CONTINUE; -- Descer para o próximo filho
         ELSIF vr_node_name = 'faixas' THEN 
            vr_id_acesso := vr_id_acesso + 1;
            CONTINUE; 
         ELSIF vr_node_name = 'idfrninv' THEN 
            vr_tab_novtabinv(vr_id_acesso).idfrninv := NVL(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),0);
            CONTINUE;  
         ELSIF vr_node_name = 'vlfaixde' THEN
            x1  := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            
            vr_tab_novtabinv(vr_id_acesso).vlfaixde :=  NVL(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),0);
            CONTINUE;
         ELSIF vr_node_name = 'vlfaixate' THEN 
            vr_tab_novtabinv(vr_id_acesso).vlfaixate :=  NVL(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),0);
            CONTINUE;  
         ELSIF vr_node_name = 'pctaxmen' THEN 
            vr_tab_novtabinv(vr_id_acesso).pctaxmen :=  NVL(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),0);
            CONTINUE;  
         ELSIF vr_node_name = 'vladicio' THEN 
            vr_tab_novtabinv(vr_id_acesso).vladicio :=  NVL(TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))),0);
            CONTINUE; 
         ELSE
            CONTINUE; -- Descer para o próximo filho
         END IF;                       
                                          
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- Quando erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       'Loop lista XML, '    ||
                       vr_dsparame    || 
                       ', x1:' || x1 ||
                       ', vr_id_acesso:' || vr_id_acesso ||
                       ', vr_lenght:' || vr_lenght ||
                       '. ' || SQLERRM;    
        RAISE vr_exc_saida;
    END;
    
    IF vr_id_acesso > 0 THEN
      pc_conciliacao_tab_investidor(pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                   ,pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                   ,pr_qttabinv => vr_qttabinv
                                   ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;
    
    -- Loop para verificar 
    -- se a faixa ainda esta valendo se não encontrar deve ser inativada
    -- se encontrar a faixa verificar se algum campo mudou se sim alterar o registro
    FOR vr_nrrownum IN 1..vr_qttabinv LOOP

      vr_idfrninv  := vr_tab_tabinv(vr_nrrownum).idfrninv;
      
      vr_flgativo  := 2;
      -- Posiciona no primeiro registro
      vr_id_acesso := vr_tab_novtabinv.FIRST(); 
      WHILE vr_id_acesso IS NOT NULL LOOP
        
        vr_vlfaixde  := vr_tab_novtabinv(vr_id_acesso).vlfaixde;
        vr_vlfaixate := vr_tab_novtabinv(vr_id_acesso).vlfaixate;
        vr_pctaxmen  := vr_tab_novtabinv(vr_id_acesso).pctaxmen;
        vr_vladicio  := vr_tab_novtabinv(vr_id_acesso).vladicio;
        
        --Efetua a reversão da situação da conta
        IF vr_tab_novtabinv(vr_id_acesso).idfrninv IS NULL OR
           vr_tab_novtabinv(vr_id_acesso).idfrninv = 0         THEN
                
          -- Vai incluir depois para não provocar erro na logica
          -- Alem disso no Loop de inclusao é vistoriada se as faixas estão corretas
          NULL;
        ELSIF vr_tab_tabinv(vr_nrrownum).idfrninv = vr_tab_novtabinv(vr_id_acesso).idfrninv THEN
          
          vr_flgativo := 1;
          -- Ver se algum diferente
          IF vr_tab_tabinv(vr_nrrownum).vlfaixde  = vr_tab_novtabinv(vr_id_acesso).vlfaixde  AND
             vr_tab_tabinv(vr_nrrownum).vlfaixate = vr_tab_novtabinv(vr_id_acesso).vlfaixate AND
             vr_tab_tabinv(vr_nrrownum).pctaxmen  = vr_tab_novtabinv(vr_id_acesso).pctaxmen  AND
             vr_tab_tabinv(vr_nrrownum).vladicio  = vr_tab_novtabinv(vr_id_acesso).vladicio      THEN
            ----
            vr_qtnaoalt   := vr_qtnaoalt + 1;
          ELSE
            -- Altera A-Inativa
            BEGIN
              UPDATE tbcapt_custodia_frn_investidor t1
              SET
                 t1.flgativo       = '2'
                ,t1.dhatual        = SYSDATE
                ,t1.dsusuario      = 'User:' || USER || ', usuario:' || vr_cdoperad
              WHERE   t1.idfrninv = vr_idfrninv;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log
                CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
                -- Monta Log
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor:' ||
                         ' vr_idfrninv:'   || vr_idfrninv  || 
                         ', vr_vlfaixde:'  || vr_vlfaixde  || 
                         ', vr_vlfaixate:' || vr_vlfaixate || 
                         ', vr_pctaxmen:'  || vr_pctaxmen  || 
                         ', vr_vladicio:'  || vr_vladicio  ||
                         '. ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            -- B - Gera outro para ficar historico
            BEGIN
              INSERT INTO tbcapt_custodia_frn_investidor t1 (
           t1.idfrninv
          ,t1.vlfaixade
          ,t1.vlfaixaate
          ,t1.petaxa_mensal
          ,t1.vladicional
          ,t1.flgativo
          ,t1.dtinclusao
          ,t1.dsusuario
          ) VALUES (
           NULL -- vr_idfrninv 
          ,vr_vlfaixde 
          ,vr_vlfaixate
          ,vr_pctaxmen 
          ,vr_vladicio
          ,'1'
          ,SYSDATE
          ,'User:' || USER || ', usuario:' || vr_cdoperad
          );
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log
                CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
                -- Monta Log
                vr_cdcritic := 1034;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor:' ||
                         ' vr_idfrninv:'   || vr_idfrninv  || 
                         ', vr_vlfaixde:'  || vr_vlfaixde  || 
                         ', vr_vlfaixate:' || vr_vlfaixate || 
                         ', vr_pctaxmen:'  || vr_pctaxmen  || 
                         ', vr_vladicio:'  || vr_vladicio  ||
                         '. ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
        
            vr_qtaltera := vr_qtaltera + 1;
        
          END IF;
          EXIT;
        END IF;
        
        -- Proximo registro
        vr_id_acesso:= vr_tab_novtabinv.NEXT(vr_id_acesso); 
        
      END LOOP;
      
      IF vr_flgativo = 2 THEN
        -- Inativa
        BEGIN
          UPDATE tbcapt_custodia_frn_investidor t1
          SET
             t1.flgativo    = '2'
            ,t1.dhatual     = SYSDATE
            ,t1.dsusuario   = 'User:' || USER || ', usuario:' || vr_cdoperad
          WHERE   t1.idfrninv = vr_idfrninv;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
            -- Monta Log
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor(2):' ||
                         ' vr_idfrninv:'   || vr_idfrninv  ||
                         ', flgativo:'     || '2'          ||
                         '. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        vr_qtexclus := vr_qtexclus + 1;
      END IF;   
      
    END LOOP;
    
    -- Posiciona no primeiro registro
    vr_id_acesso := vr_tab_novtabinv.FIRST(); 

    WHILE vr_id_acesso IS NOT NULL LOOP
      
      IF vr_id_acesso > 1 THEN
        -- Se "valor De" da faixa 1 for maior que o "valor De" da faixa 2 critica
        -- Se "valor Até" da faixa 2 for menor que "valor Até" da faixa 1 critica
        IF NVL(vr_tab_novtabinv(vr_id_acesso-1).vlfaixde,0) >= 
           NVL(vr_tab_novtabinv(vr_id_acesso).vlfaixde,0)    THEN
          vr_cdcritic := 1465; -- Faixa com valor invalido
          RAISE vr_exc_saida;
        END IF;
        IF vr_id_acesso <  vr_tab_novtabinv.LAST() THEN
          IF NVL(vr_tab_novtabinv(vr_id_acesso).vlfaixate,0)  <= 
             NVL(vr_tab_novtabinv(vr_id_acesso-1).vlfaixate,0)  THEN
            vr_cdcritic := 1465; -- Faixa com valor invalido
            RAISE vr_exc_saida;
          END IF;
        END IF;
        -- Se "valor De" da faixa 2 menos o "valor Até" da faixa 1 der maior que 0,01 critica
        IF (NVL(vr_tab_novtabinv(vr_id_acesso).vlfaixde,0) - 
            NVL(vr_tab_novtabinv(vr_id_acesso-1).vlfaixate,0) ) > 0.01 THEN
          vr_cdcritic := 1465; -- Faixa com valor invalido
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      IF vr_id_acesso < vr_tab_novtabinv.LAST() THEN
        -- Se "valor ate" da faixa 1 maior que o "valor de" da faixa 2  critica
        IF NVL(vr_tab_novtabinv(vr_id_acesso  ).vlfaixate,0) >
           NVL(vr_tab_novtabinv(vr_id_acesso+1).vlfaixde ,0)  THEN
          vr_cdcritic := 1465; -- Faixa com valor invalido
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      IF vr_id_acesso = vr_tab_novtabinv.LAST() AND 
         NVL(vr_tab_novtabinv(vr_id_acesso ).vlfaixate,0) <> 0 THEN
          vr_cdcritic := 1465; -- Faixa com valor invalido
          RAISE vr_exc_saida;
      END IF;
      
      IF vr_id_acesso = 1 AND 
         NVL(vr_tab_novtabinv(vr_id_acesso ).vlfaixde,0) <> 0 THEN
          vr_cdcritic := 1465; -- Faixa com valor invalido
          RAISE vr_exc_saida;
      END IF;
      
      --Efetua a reversão da situação da conta
      IF vr_tab_novtabinv(vr_id_acesso).idfrninv IS NULL OR
         vr_tab_novtabinv(vr_id_acesso).idfrninv = 0         THEN
          
        vr_idfrninv  := vr_tab_novtabinv(vr_id_acesso).idfrninv;      
        vr_vlfaixde  := vr_tab_novtabinv(vr_id_acesso).vlfaixde;
        vr_vlfaixate := vr_tab_novtabinv(vr_id_acesso).vlfaixate;
        vr_pctaxmen  := vr_tab_novtabinv(vr_id_acesso).pctaxmen;
        vr_vladicio  := vr_tab_novtabinv(vr_id_acesso).vladicio;
           /*
        dbms_output.put_line(
        'vr_idfrninv:'    || vr_idfrninv  || 
        ', vr_vlfaixde:'  || vr_vlfaixde  || 
        ', vr_vlfaixate:' || vr_vlfaixate || 
        ', vr_pctaxmen:'  || vr_pctaxmen  || 
        ', vr_vladicio:'  || vr_vladicio 
        ); */
        
        BEGIN
          INSERT INTO tbcapt_custodia_frn_investidor t1 (
           t1.idfrninv
          ,t1.vlfaixade
          ,t1.vlfaixaate
          ,t1.petaxa_mensal
          ,t1.vladicional
          ,t1.flgativo
          ,t1.dtinclusao
          ,t1.dsusuario
          ) VALUES (
           NULL -- vr_idfrninv 
          ,NVL(vr_vlfaixde,0) 
          ,NVL(vr_vlfaixate,0)
          ,NVL(vr_pctaxmen,0) 
          ,NVL(vr_vladicio,0)
          ,'1'
          ,SYSDATE
          ,'User:' || USER || ', usuario:' || vr_cdoperad
          );
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
            -- Monta Log
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor(2):' ||
                         ' vr_idfrninv:'   || vr_idfrninv  || 
                         ', vr_vlfaixde:'  || vr_vlfaixde  || 
                         ', vr_vlfaixate:' || vr_vlfaixate || 
                         ', vr_pctaxmen:'  || vr_pctaxmen  || 
                         ', vr_vladicio:'  || vr_vladicio  ||
                         '. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        vr_qtinclus := vr_qtinclus + 1;
        
      END IF;
        
      -- Proximo registro
      vr_id_acesso:= vr_tab_novtabinv.NEXT(vr_id_acesso); 
        
    END LOOP;
    /*
    dbms_output.put_line(
    'vr_qtinclus:'   || vr_qtinclus  || 
    ', vr_qtaltera:' || vr_qtaltera  || 
    ', vr_qtexclus:' || vr_qtexclus  || 
    ', vr_qtnaoalt:' || vr_qtnaoalt  ); */
        
    IF vr_qtinclus > 0 OR
       vr_qtaltera > 0 OR
       vr_qtexclus > 0    THEN
      --Efetua o commit das informções
      COMMIT; 
      pr_cdcritic := 912;  -- Solicitacao efetuada com sucesso 
    ELSE
      pr_cdcritic := 1466; -- Informacoes passadas iguais as informacoes da base de dadaos 
    END IF;
        
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    pr_des_erro := 'OK';
    -- Existe para satisfazer exigência da interface. 
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Sucesso>' || pr_cdcritic||'-'||pr_dscritic || '</Sucesso></Root>');  

    -- Zera nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL );   
  EXCEPTION
    WHEN vr_exc_saida THEN
      --
      IF vr_qtinclus > 0 OR
         vr_qtaltera > 0 OR
         vr_qtexclus > 0    THEN  
        ROLLBACK; 
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic); 
      -- Log de erro de execucao
      pc_log(pr_cdcritic => pr_cdcritic
            ,pr_dscrilog => pr_dscritic ||
                            ' '  || vr_nmaction     ||
                            ' '  || vr_dsparame);      
      -- Devolver criticas 
      -- Como chega aqui criticas 9999 e outras passar um mensagem generica, 
      -- caso precise passar a especifica programando ela mas deixar a generica
      pr_des_erro := 'NOK';          
      IF pr_cdcritic IN ( 1034, 1035, 1037, 9999) THEN
        pr_cdcritic := 1495;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 
      --
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmaction    || 
                     ' ' || vr_dsparame;
      --
      IF vr_qtinclus > 0 OR
         vr_qtaltera > 0 OR
         vr_qtexclus > 0    THEN  
        ROLLBACK; 
      END IF;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                
    
  END pc_atz_faixa_tab_investidor;
   
    
END TELA_CUSAPL;
/
