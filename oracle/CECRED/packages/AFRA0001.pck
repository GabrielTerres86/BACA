CREATE OR REPLACE PACKAGE CECRED.AFRA0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : AFRA0001
      Sistema  : Rotinas referentes a Analise de Fraude
      Sigla    : AFRA
      Autor    : Odirlei Busana - AMcom
      Data     : Novembro/2016.                   Ultima atualizacao: 15/08/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Analise de Fraude.

      Alteracoes:		02/02/2018 - Ajuste na variável pr_dhoperac para que sejam desconsiderados
								     os segundos, desta forma a cursor se torna compatível com  os 
									 intervalos cadastrados na Tela CADFRA.
									 Chamado 789957 - Gabriel (Mouts).

                   03/04/2018 - Inclusao de novo parametro na pc_criar_analise_antifraude 
                                que possitibilite armazenar o iddispositivo 
                                PRJ381 - Antifraude (Teobaldo J. - AMcom)

                   04/04/2018 - Criacao das rotinas pc_ler_parametros_fraude e fn_envia_analise,
                                e alteracoes na rotina pc_crias_analise_antifraude             
                                PRJ381 - Antifraude (Teobaldo J. - AMcom) 
																
                   20/07/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA
                                Everton Souza - Mouts
																
                   15/08/2018 - Alterada procedure pc_aprovacao_analise para enviar campo 
				                "IdentificacaoPessoa" com o formato correto. (Reinert)

  ---------------------------------------------------------------------------------------------------------------*/
  
  --- Armazenar os campos alterados
  TYPE typ_rec_campo_alt
       IS RECORD(dsdadant craplgi.dsdadant%TYPE,
                 dsdadatu craplgi.dsdadatu%TYPE);
  TYPE typ_tab_campo_alt IS TABLE OF typ_rec_campo_alt
       INDEX BY VARCHAR2(50); 
         
  ---> Manter parametros analise de fraude em memoria
  ---> 03/04/2018 - Teobaldo
  TYPE typ_tab_AnaliseFraudeParam IS TABLE OF tbgen_analise_fraude_param%rowtype
       INDEX BY varchar2(10);
  vr_tab_AnaliseFraudeParam  typ_tab_AnaliseFraudeParam;
  
  TYPE typ_tab_limfimope IS TABLE OF NUMBER
       INDEX BY PLS_INTEGER;
  vr_tab_limfimope typ_tab_limfimope;
  
  TYPE typ_tab_campos IS TABLE OF VARCHAR2(2000)
         INDEX BY VARCHAR2(100);
  
  TYPE typ_tab_dsopefra IS TABLE OF VARCHAR2(200)
       INDEX BY PLS_INTEGER;
  vr_tab_dsopefra typ_tab_dsopefra;
         
         
  -- Rotina para buscar o descrição da operacao de fraude
  FUNCTION fn_dsoperacao_fraude(pr_cdoperacao IN NUMBER) 
    RETURN VARCHAR2;

  
  --> Funcao que retorna flag indicando se operacao deve ser enviada para analide de fraude
  FUNCTION fn_envia_analise (pr_cdoperacao IN tbgen_analise_fraude_param.cdoperacao%TYPE,
                             pr_tpoperacao IN tbgen_analise_fraude_param.tpoperacao%TYPE) RETURN NUMBER;
    
  --> Rotina para atualizar os dados da analise
  PROCEDURE pc_atualizar_analise ( pr_rowid     IN ROWID,
                                   pr_dhdenvio  IN tbgen_analise_fraude.dhenvio_analise%TYPE   DEFAULT NULL,
                                   pr_dhlimana  IN tbgen_analise_fraude.dhlimite_analise%TYPE  DEFAULT NULL,
                                   pr_dhretorn  IN tbgen_analise_fraude.dhretorno_analise%TYPE DEFAULT NULL,
                                   pr_cdstatus  IN tbgen_analise_fraude.cdstatus_analise%TYPE  DEFAULT NULL,
                                   pr_cdparece  IN tbgen_analise_fraude.cdparecer_analise%TYPE DEFAULT NULL,
                                   pr_dsfinger  IN tbgen_analise_fraude.dsfingerprint%TYPE     DEFAULT NULL,
                                   pr_cdcanal   IN NUMBER DEFAULT NULL,                        --> Canal origem da operação
                                   pr_flganama  IN NUMBER DEFAULT 0,                           --> Indicador analise efetuada manualmente
                                   pr_dstransa  IN VARCHAR2,                                   --> Descrição da trasaçao para log                                            
                                   pr_dscrilog  IN VARCHAR2,                                   --> Em caso de status de erro, apresentar critica para log
                                   pr_dscritic OUT VARCHAR2 );                                   
  
  --> Rotina para carregar no objeto json os dados da conta
  PROCEDURE pc_carregar_conta_json ( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                     pr_nrdconta     IN crapass.nrdconta%TYPE, --> Numero da conta do cooperaro
                                     pr_dstpctdb     IN VARCHAR2,              --> Tipo de conta 
                                     pr_json     IN OUT NOCOPY json ,          --> Json a ser incrementado
                                     pr_cdcritic    OUT INTEGER,               --> Retorno de codigo de critica
                                     pr_dscritic    OUT VARCHAR2 );            --> retorno de descricao de critica
                                     
  --> Procedure para envio da TED para analise de fraude
  PROCEDURE pc_enviar_ted_analise (pr_idanalis     IN INTEGER,
                                   pr_Fingerprint OUT VARCHAR2, 
                                   pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                   pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                   pr_cdcritic    OUT INTEGER,
                                   pr_dscritic    OUT VARCHAR2 );
  
  --> Procedure para envio dos agendamentos de TED para analise de fraude
  PROCEDURE pc_enviar_agend_ted_analise (pr_idanalis     IN INTEGER,
                                         pr_Fingerprint OUT VARCHAR2, 
                                         pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                         pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic    OUT INTEGER,
                                         pr_dscritic    OUT VARCHAR2);                                
                                        
  --> Procedure para envio da GPS para analise de fraude 
  PROCEDURE pc_enviar_gps_analise (pr_idanalis     IN INTEGER
                                  ,pr_Fingerprint OUT VARCHAR2 
                                  ,pr_dhdenvio    OUT TIMESTAMP   --> Data hora do envio para a analise
                                  ,pr_dhlimana    OUT TIMESTAMP   --> Data hora de limite de aguardo para a analise
                                  ,pr_cdcritic    OUT INTEGER
                                  ,pr_dscritic    OUT VARCHAR2);

  --> Procedure para envio da GPS para analise de fraude
  PROCEDURE pc_enviar_agend_gps_analise (pr_idanalis     IN INTEGER,
                                         pr_Fingerprint OUT VARCHAR2, 
                                         pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                         pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic    OUT INTEGER,
                                         pr_dscritic    OUT VARCHAR2 );

  --> Rotina responsavel em enviar as analises de fraude pendentes
  PROCEDURE pc_enviar_analise_fraude (pr_cdcritic  OUT INTEGER,
                                      pr_dscritic  OUT VARCHAR2 ); 
                                      
  --> Rotina responsavel em enviar as analises de fraude pendentes
  PROCEDURE pc_enviar_analise_fraude (pr_idanalis   IN INTEGER DEFAULT 0,
                                      pr_cdoperac   IN INTEGER,
                                      pr_idparale   IN NUMBER DEFAULT 0,
                                      pr_cdcritic  OUT INTEGER,
                                      pr_dscritic  OUT VARCHAR2 ); 
                                      
  --> Rotina para retornar situação do parecer da analise de fraude
  PROCEDURE pc_ret_sit_analise_fraude (pr_idanafra  IN tbgen_analise_fraude.idanalise_fraude%TYPE,
                                       pr_cdparece OUT tbgen_analise_fraude.cdparecer_analise%TYPE,
                                       pr_dscritic OUT VARCHAR2 );

  --> Excecutar rotinas referentes a aprovação da analise de fraude
  PROCEDURE pc_aprovacao_analise (pr_idanalis   IN INTEGER,    --> Indicador da analise de fraude
                                  pr_cdcritic  OUT INTEGER,
                                  pr_dscritic  OUT VARCHAR2 ) ;
                                  
  --> Excecutar rotinas referentes a reprovação da analise de fraude
  PROCEDURE pc_reprovacao_analise (pr_idanalis   IN INTEGER,    --> Indicador da analise de fraude
                                   pr_cdcritic  OUT INTEGER,
                                   pr_dscritic  OUT VARCHAR2 );
                                   
  --> Rotina para Inclusao do registro de analise de fraude
  PROCEDURE pc_criar_analise_antifraude (pr_cdcooper    IN tbgen_analise_fraude.cdcooper%TYPE,    --> Cooperativa da transação 
                                        pr_cdagenci    IN tbgen_analise_fraude.cdagenci%TYPE,    --> PA da transanção 
                                        pr_nrdconta    IN tbgen_analise_fraude.nrdconta%TYPE,    --> Número da conta da transação 
                                        pr_cdcanal     IN tbgen_analise_fraude.cdcanal_operacao%TYPE,     --> Código da origem fk com a tabela tbgen_canal_entrada 
                                        pr_iptransacao IN tbgen_analise_fraude.iptransacao%TYPE, --> IP da transação 
                                        pr_dtmvtolt    IN tbgen_analise_fraude.dtmvtolt%TYPE,    --> Data da movimentação do sistema 
                                        pr_cdproduto   IN tbgen_analise_fraude.cdproduto%TYPE,   --> Código do produto fk com a tabela tbcc_produto 
                                        pr_cdoperacao  IN tbgen_analise_fraude.cdoperacao%TYPE,  --> Codigo de operacao de conta corrente
                                        pr_dstransacao IN tbgen_analise_fraude.dstransacao%TYPE, --> Descrição da transação 
                                        pr_tptransacao IN tbgen_analise_fraude.tptransacao%TYPE, --> Tipo de transação (1-online/ 2-agendada)                                         
                                        pr_iddispositivo IN VARCHAR2 DEFAULT NULL,  --> identificador dispositivo                                        
                                        pr_dstoken     IN VARCHAR2 DEFAULT NULL,                 --> Token de acesso
                                        pr_idanalise_fraude OUT tbgen_analise_fraude.idanalise_fraude%TYPE, --> identificador único da transação  
                                        pr_dscritic   OUT VARCHAR2 );                                        
                                        
  --> Rotina responsavel por registrar o parecer de retorno da análise do sistema antifraude
  PROCEDURE pc_reg_reto_analise_antifraude(pr_idanalis    IN  NUMBER,       --> Id Unico da transação 
                                           pr_cdparece    IN  NUMBER,       --> Parecer da análise antifraude 
                                                                               --> 1 - Aprovada
                                                                               --> 2 - Reprovada
                                           pr_flganama   IN  NUMBER,        --> Indentificador de analise manual 
                                           pr_cdcanal    IN  NUMBER,        --> Canal origem da operação
                                           pr_fingerpr   IN  VARCHAR2,      --> Identifica a comunicação partiu do antifraude 
                                           pr_cdcritic   OUT  NUMBER,       --> Código da Crítica 
                                           pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica 
                                           pr_dsdetcri   OUT VARCHAR2);    --> Detalhe da critica    
                                           
  --> Rotina responsavel por registrar a confirmação de entrega da análise ao sistema antifraude
  PROCEDURE pc_reg_conf_entrega_antifraude(pr_idanalis    IN  NUMBER,       --> Id Unico da transação 
                                           pr_cdentreg    IN  NUMBER,       -->  Codigo de confirmação de entrega 
                                                                               --> 3 - Entrega confirmada antifraude
                                                                               --> 4 - Erro na comunicação com antifraude
                                           pr_cdcritic   OUT  NUMBER,       --> Código da Crítica 
                                           pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica 
                                           pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica                                            
                                           
  --> Rotina para estornar TED reprovada pela analise de fraude
  PROCEDURE pc_estornar_ted_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, -->Id da análise de fraude
                                     pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                     pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                     pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                     pr_dscritic  OUT VARCHAR2 ); 
                                     
  --> Rotina para estornar GPS reprovada pela analise de fraude
  PROCEDURE pc_estornar_gps_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Id da análise de fraude
                                     pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                     pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                     pr_dscritic  OUT VARCHAR2 );                                           

  --> Rotina para estornar Titulo reprovada pela analise de fraude
  PROCEDURE pc_estornar_titulo_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Id da análise de fraude
                                        pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                        pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                        pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                        pr_dscritic  OUT VARCHAR2 );
                                        
  --> Rotina para estornar Convenio reprovado pela analise de fraude  
  PROCEDURE pc_estornar_convenio_analise(pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Id da análise de fraude
                                         pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                         pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                         pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                         pr_dscritic  OUT VARCHAR2 );
                                         
  --> Rotina para estornar Tributos reprovada pela analise de fraude
  PROCEDURE pc_estornar_Tributo_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Id da análise de fraude
                                         pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                         pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                         pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                         pr_dscritic  OUT VARCHAR2 );
                                        
  

  PROCEDURE pc_notificar_seguranca (pr_idanalis   IN tbgen_analise_fraude.idanalise_fraude%TYPE,
                                    pr_tpalerta   IN INTEGER, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                    pr_dsalerta   IN VARCHAR2 DEFAULT NULL,
                                    pr_dscritic  OUT VARCHAR2 );
                                    
  --> Retornar a data limite da analise
  PROCEDURE pc_ret_data_limite_analise ( pr_cdoperac   IN tbcc_operacao.cdoperacao%TYPE  --> Codigo da operação
                                        ,pr_tpoperac   IN INTEGER                        --> Tipo de operacao 1 -online 2-agendamento
                                        ,pr_dhoperac   IN TIMESTAMP                      --> Data hora da operação      
                                        ,pr_dtefeope   IN DATE DEFAULT NULL              --> Data que sera efetivada a operacao agendada
                                        ,pr_cdcooper   IN NUMBER DEFAULT 1               --> Codigo da cooperativa, para uso do limite de operacao
                                        ,pr_tplimite   IN NUMBER DEFAULT 0               --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao
                                        ,pr_dhlimana  OUT TIMESTAMP                      --> Retorna data hora limite da operacao
                                        ,pr_qtsegret  OUT NUMBER                         --> Retorna tempo em segundo de retenção da analise
                                        ,pr_dscritic  OUT VARCHAR2);   
                                        
  --> Procedimento para carregar em memoria parametros da analise de fraude */
  PROCEDURE pc_ler_parametros_fraude (pr_atualizar IN INTEGER DEFAULT 0);
  
  --> Extrair os dados do campo complementar
  PROCEDURE pc_extrair_dscomple (pr_dscomple      IN VARCHAR2,
                                 pr_tab_dscomple OUT typ_tab_campos);
  
END;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AFRA0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : AFRA0001
      Sistema  : Rotinas referentes a Analise de Fraude
      Sigla    : AFRA
      Autor    : Odirlei Busana - AMcom
      Data     : Novembro/2016.                   Ultima atualizacao: 15/08/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Analise de Fraude.  - PRJ335 - Analise de Fraude

      Alteracoes:  03/04/2018 - Inclusao de novo parametro na pc_criar_analise_antifraude 
                                que possibilite armazenar o iddispositivo 
                                PRJ381 - Antifraude (Teobaldo J. - AMcom)
                   04/04/2018 - Criacao das rotinas pc_ler_parametros_fraude e fn_envia_analise,
                                e alteracoes na rotina pc_crias_analise_antifraude             
                                PRJ381 - Antifraude (Teobaldo J. - AMcom)

                   15/08/2018 - Alterada procedure pc_aprovacao_analise para enviar campo 
				                "IdentificacaoPessoa" com o formato correto. (Reinert)
  ---------------------------------------------------------------------------------------------------------------*/
  
  ---> Formatos utilizados para montagem do Json
  vr_dsformat_data   VARCHAR2(30) := 'DD/MM/RRRR';
  vr_dsformat_dthora VARCHAR2(30) := 'DD/MM/RRRR HH24:MI:SS';
  
  vr_time_param      NUMBER;
  
  --> Funcao para formatar numero no padrão da OFSSA - Aymaru
  FUNCTION fn_format_number ( pr_campo IN VARCHAR2
                             ,pr_valor IN NUMBER) RETURN VARCHAR2 IS
  
  BEGIN
    
    RETURN TRIM(to_char(pr_valor,'9999999999999990D00','NLS_NUMERIC_CHARACTERS='',.'''));     
    
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20200,'Erro ao formatar campo '||pr_campo||' valor:'||
                                                                pr_valor||': '||SQLERRM);
  END fn_format_number;
  
  
  --> Funcao para retornar a base do CNPJ da cooperativa Central
  FUNCTION fn_base_cnpj_central (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2 IS
  
    vr_basecnpj  VARCHAR2(20);
    vr_dstextab  craptab.dstextab%TYPE;
    
    
  BEGIN
    
    --> buscar craptab
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                              pr_nmsistem => 'CRED',
                                              pr_tptabela => 'GENERI',
                                              pr_cdempres => 0,
                                              pr_cdacesso => 'CNPJCENTRL',
                                              pr_tpregist => 0);
                                              
    
    --> Extrair apensa base do CNPJ                                          
    vr_basecnpj := SUBSTR(to_char(TO_NUMBER(vr_dstextab),'fm00000000000000'),1,8);
    
    RETURN vr_basecnpj;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_base_cnpj_central;
  
    --> Funcao que retorna flag indicando se operacao deve ser enviada para analise de fraude
  FUNCTION fn_envia_analise (pr_cdoperacao IN tbgen_analise_fraude_param.cdoperacao%TYPE,
                             pr_tpoperacao IN tbgen_analise_fraude_param.tpoperacao%TYPE) RETURN NUMBER IS
    /* ..........................................................................
    --
    --  Programa : fn_envia_analise       
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Teobaldo Jamunda (AMcom)
    --  Data     : Abril/2018.                   Ultima atualizacao: 03/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar se operacao deve ser enviada para analise de fraude
    --               (PRJ381 - Analise de Fraude)
    --
    --  Alteração  : 
    --
    -- ..........................................................................*/

    vr_index    VARCHAR2(10);
    vr_flgativo NUMBER;
    vr_time     NUMBER;
                            
  BEGIN
    vr_time := dbms_utility.get_time;
    
    -- atualizar parametros de analise em memoria a cada 10min (600 segundos)
    IF nvl(vr_time_param,0) = 0 OR 
       (vr_time - Nvl(vr_time_param,0)) > (60 * 100) THEN
        pc_ler_parametros_fraude(1);
        vr_time_param := vr_time;
    END IF;
    
    vr_index :=  pr_cdoperacao || '|' || pr_tpoperacao;
    Begin
       vr_flgativo := Nvl(vr_tab_AnaliseFraudeParam(vr_Index).flgativo, 0);
    Exception
       When NO_DATA_FOUND Then
            vr_flgativo := 0;
       When Others Then 
            vr_flgativo := 0;
    End;
    
    Return vr_flgativo;                           
  END fn_envia_analise;
  
  -- Rotina para buscar o descrição da operacao de fraude
  FUNCTION fn_dsoperacao_fraude(pr_cdoperacao IN NUMBER) 
    RETURN VARCHAR2 IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : fn_dsoperacao_fraude
    --  Autor    : Odirlei Busana (AMcom)
    --  Data     : Abril/2018.                   Ultima atualizacao: --/--/----
    --
    -- Objetivo  : Rotina para buscar o descrição da operacao de fraude
    ---------------------------------------------------------------------------------------------------------------
 
    vr_tab_dominios gene0010.typ_tab_dominio;
    vr_dscritic     VARCHAR2(4000);
  BEGIN
  
    IF vr_tab_dsopefra.count = 0 THEN
      GENE0010.pc_retorna_dominios ( pr_nmmodulo   => 'CC',                      --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'CDOPERAC_ANALISE_FRAUDE', --> Nome do dominio
                                     -----> OUT <------
                                     pr_tab_dominios => vr_tab_dominios,         --> retorna os dados dos dominios
                                     pr_dscritic     => vr_dscritic);            --> retorna descricao da critica
      IF vr_tab_dominios.count > 0 THEN
        FOR i IN vr_tab_dominios.first..vr_tab_dominios.last LOOP
          vr_tab_dsopefra(vr_tab_dominios(i).cddominio) := gene0007.fn_caract_acento(vr_tab_dominios(i).dscodigo);
        END LOOP;
      END IF;
    
    END IF;
  
  
    IF vr_tab_dsopefra.exists(pr_cdoperacao) THEN
      RETURN vr_tab_dsopefra(pr_cdoperacao);
    ELSE
      RETURN 'OUTROS';
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'OUTROS';  
  END fn_dsoperacao_fraude;  

  
  --> Rotina para carregar no objeto Json os telefones do cooperado  
  PROCEDURE pc_carregar_fone_json ( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                   pr_nrdconta     IN crapass.nrdconta%TYPE, --> Numero da conta do cooperaro
                                   pr_dsprefix     IN VARCHAR2,              --> Prefixo do campo dos telefones no json
                                   pr_json     IN OUT NOCOPY json ,           --> Json a ser incrementado
                                   pr_cdcritic    OUT INTEGER,               --> Retorno de codigo de critica
                                   pr_dscritic    OUT VARCHAR2 )IS           --> retorno de descricao de critica
  /* ..........................................................................
    
      Programa : pc_carregar_fone_json        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel em carregar no objeto Json os telefones do cooperado  
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar telefones do cooperado
    CURSOR cr_craptfc IS
      SELECT DECODE(tfc.tptelefo,
                    1,'Residencial',
                    2,'Celular',
                    3,'Comercial',
                    4,'Contato') dstptele,
             tfc.tptelefo,
             tfc.nmpescto,
             to_char(tfc.nrdddtfc, 'fm99') nrdddtfc,
             to_char(tfc.nrtelefo, 'fm999999999') nrtelefo,
             rownum seq 
        FROM craptfc tfc
       WHERE tfc.idseqttl = 1
         AND tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         -- Apresentar apenas 4 numeros
         AND rownum <= 4
       ORDER BY tfc.tptelefo;
    
  BEGIN    
  
    --> buscar telefones
    FOR rw_craptfc IN cr_craptfc LOOP
      pr_json.put(pr_dsprefix||'_Phn'||rw_craptfc.seq||'_Type'   ,to_char(rw_craptfc.tptelefo));
      pr_json.put(pr_dsprefix||'_Phn'||rw_craptfc.seq||'_Contact',rw_craptfc.dstptele);
      pr_json.put(pr_dsprefix||'_Phn'||rw_craptfc.seq||'_DDD'    ,rw_craptfc.nrdddtfc);
      pr_json.put(pr_dsprefix||'_Phn'||rw_craptfc.seq||'_Number' ,rw_craptfc.nrtelefo);
    END LOOP;
  EXCEPTION 
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel carregar telefones do cooperado: '||SQLERRM;
      
  END pc_carregar_fone_json;
  
  --> Rotina para carregar no objeto json os dados da conta
  PROCEDURE pc_carregar_conta_json ( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                     pr_nrdconta     IN crapass.nrdconta%TYPE, --> Numero da conta do cooperaro
                                     pr_dstpctdb     IN VARCHAR2,              --> Tipo de conta 
                                     pr_json     IN OUT NOCOPY json ,          --> Json a ser incrementado
                                     pr_cdcritic    OUT INTEGER,               --> Retorno de codigo de critica
                                     pr_dscritic    OUT VARCHAR2 )IS           --> retorno de descricao de critica
  /* ..........................................................................
    
      Programa : pc_carregar_conta_json        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 10/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para carregar no objeto json os dados da conta
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar cooperado
    CURSOR cr_crapass( pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS                                            
      SELECT ass.cdagenci,
             age.nmresage, 
             cop.cdagectl,
             pes.nmpessoa,
             pes.tppessoa,
             pes.idpessoa,
             decode(pes.tppessoa,1,'F','J') dstippes, 
             decode(pes.tppessoa,1,lpad(pes.nrcpfcgc,11,'0'),
                                   lpad(pes.nrcpfcgc,14,'0')) dscpfcgc      
        FROM crapass ass,
             crapage age,
             crapcop cop,
             tbcadast_pessoa pes
       WHERE ass.nrcpfcgc = pes.nrcpfcgc 
         AND ass.cdcooper = cop.cdcooper
         AND ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;   
    
    --> Buscar titular
    CURSOR cr_crapttl( pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS   
      SELECT pes.nmpessoa,
             ttl.idseqttl
        FROM crapttl ttl,
             tbcadast_pessoa pes
       WHERE ttl.nrcpfcgc = pes.nrcpfcgc 
         AND ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl > 1
         AND ttl.idseqttl <= 4
         ORDER BY idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;   
      
    --> Buscar representantes da empresa
    CURSOR cr_repres( pr_idpessoa  crapass.cdcooper%TYPE) IS   
      SELECT pes.nmpessoa
        FROM tbcadast_pessoa_juridica_rep rep,
             tbcadast_pessoa pes
       WHERE rep.idpessoa_representante = pes.idpessoa
         AND rep.idpessoa = pr_idpessoa 
       ORDER BY rep.persocio;     
                                                                    
    
    -----------> VARIAVEIS <----------- 
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(1000);
      
    vr_basecnpj   VARCHAR2(20);
    vr_seq        INTEGER;   
    
  BEGIN    
      
    OPEN cr_crapass( pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    ----> ACCOUNT DEBIT
    vr_basecnpj := fn_base_cnpj_central(pr_cdcooper);
    pr_json.put('DBT_Acct_Bank'       , to_char(vr_basecnpj));     
    pr_json.put('DBT_Acct_Branch'     , to_char(rw_crapass.cdagectl));    
    --Tipo da conta de debito        
    pr_json.put('DBT_Acct_Type'       , pr_dstpctdb);        
    pr_json.put('DBT_Acct_Number'     , to_char(pr_nrdconta));        
    pr_json.put('DBT_Acct_CreditUnion', to_char(pr_cdcooper));
    pr_json.put('DBT_Acct_PA'         , to_char(rw_crapass.cdagenci));
    pr_json.put('DBT_Acct_PA_Desc'    , to_char(rw_crapass.nmresage));
    
    ----> HOLDER
    pr_json.put('DBT_Hldr_Type'       , rw_crapass.dstippes);
    pr_json.put('DBT_Hldr_Document'   , nvl(rw_crapass.dscpfcgc,'0'));        
    pr_json.put('DBT_Hldr_Name'       , rw_crapass.nmpessoa);
    
    --> Se for pessoa fisica
    IF rw_crapass.tppessoa = 1 THEN
      --> Buscar outro titular da conta
      rw_crapttl := NULL;
      FOR rw_crapttl IN cr_crapttl( pr_cdcooper  => pr_cdcooper,
                                    pr_nrdconta  => pr_nrdconta) LOOP
      
        IF rw_crapttl.nmpessoa IS NOT NULL THEN
          pr_json.put('Trxn_Contact_'||rw_crapttl.idseqttl||'_Info'       , rw_crapttl.nmpessoa);      
        END IF;
                                                      
      END LOOP;                     
      
    
    ELSE
      --> inicializar seq, que compoem nome do campo
      vr_seq := 2;
      --> Buscar representantes da empresa
      FOR rw_repres IN cr_repres(pr_idpessoa => rw_crapass.idpessoa) LOOP
       -- Deve exibir apenas dois Socios/Representantes
       IF vr_seq > 4 THEN
         EXIT;
       END IF;   
       pr_json.put('Trxn_Contact_'||vr_seq||'_Info'  , rw_repres.nmpessoa);       
      
       vr_seq := vr_seq +1 ;
      END LOOP;
    
    END IF;
    
    
    --> carregar os telefones do cooperado  
    pc_carregar_fone_json ( pr_cdcooper    => pr_cdcooper,     --> Codigo da cooperativa
                           pr_nrdconta     => pr_nrdconta,     --> Numero da conta do cooperaro
                           pr_dsprefix     => 'DBT_Hldr',      --> Prefixo do campo dos telefones no json
                           pr_json         => pr_json,          --> Json a ser incrementado
                           pr_cdcritic     => vr_cdcritic,     --> Retorno de codigo de critica
                           pr_dscritic     => vr_dscritic);    --> Retorno de descricao de critica    
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
      pr_dscritic := 'Não foi possivel carregar dados do cooperado: '||SQLERRM;
      
  END pc_carregar_conta_json;
  
  
  --> Procedure para envio da TED para analise de fraude
  PROCEDURE pc_enviar_ted_analise (pr_idanalis     IN INTEGER,
                                   pr_Fingerprint OUT VARCHAR2, 
                                   pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                   pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                   pr_cdcritic    OUT INTEGER,
                                   pr_dscritic    OUT VARCHAR2 )IS
  /* ..........................................................................
    
      Programa : pc_enviar_ted_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 17/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio da TED para analise de fraude
      
      Alteração : 17/05/2017 - Ajustado rotina para incluir hora no campo Trxn_Date(Odirlei-AMcom)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações da TED
    CURSOR cr_craptvl (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tvl.cdcooper,
             cop.cdagectl,
             decode(tvl.tpdctadb,2,'PP','CC') dstpctdb,
             ass.cdagenci,             
             
             --> Holder
             decode(tvl.flgpesdb,1,'F','J') dspesemi,
             decode(tvl.flgpesdb,1,lpad(tvl.cpfcgemi,11,'0'),
                                   lpad(tvl.cpfcgemi,14,'0')) ds_cpfcgemi,             
             --tvl.cpfcgemi,
             tvl.nrdconta,
             tvl.nmpesemi,
             
             -- account credit
             decode(tvl.tpdctacr,2,'PP','CC')  dstpctcr,
             to_char(tvl.nrcctrcb, 'fm9999999999999') nrcctrcb,
             decode(flgpescr,1,'F','J') dspescrd,
             tvl.cdbccrcb,
             tvl.cdagercb,
             --Solicitdo pela Segurança Enviar o municipio, pois é mais significativo
             trim(caf.nmcidade) ||' - '||caf.cdufresd nmageban,
             --tvl.cpfcgrcb,
             decode(tvl.flgpescr,1,lpad(tvl.cpfcgrcb,11,'0'),
                                   lpad(tvl.cpfcgrcb,14,'0')) ds_cpfcgrcb,
             tvl.nmpesrcb,
             
             -- transaction
             tvl.progress_recid,
             tvl.idopetrf,
             decode(substr(tvl.idopetrf, length(tvl.idopetrf), 1), 'M','10','3') dsdcanal,
             (CASE
               WHEN cop.flgoppag = 1 AND cop.inioppag <= tvl.hrtransa AND
                    cop.fimoppag >= tvl.hrtransa AND ban.FLGOPPAG = 1 THEN
                'PAG0108'
               ELSE
                'STR0008'
              END) dscodmsg,
              tvl.vldocrcb,
              tvl.cdfinrcb,
              tvl.dshistor
        FROM craptvl tvl,
             crapcop cop,
             crapass ass,
             crapban ban,
             crapagb agb,
             crapcaf caf
       WHERE tvl.cdcooper = cop.cdcooper
         AND tvl.cdcooper = ass.cdcooper
         AND tvl.nrdconta = ass.nrdconta 
         AND tvl.cdbccrcb = ban.cdbccxlt
         AND tvl.cdbccrcb = agb.cddbanco(+)
         AND tvl.cdagercb = agb.cdageban(+)
         AND agb.cdcidade = caf.cdcidade(+)
         AND tvl.idanafrd = pr_idanalis
         AND tvl.cdcooper = pr_cdcooper
         AND tvl.nrdconta = pr_nrdconta;         
         
    rw_craptvl cr_craptvl%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta   AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_ted        json := json();
    vr_code       VARCHAR2(10);
    vr_Message    VARCHAR2(1000);
    vr_qtsegret   NUMBER;
    vr_nmarqlog   VARCHAR2(500);
    vr_cdprogra   VARCHAR2(50) := 'pc_enviar_ted_analise';
    
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
  
    OPEN cr_craptvl( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craptvl INTO rw_craptvl;
    
    IF cr_craptvl%NOTFOUND THEN
      CLOSE cr_craptvl;
      vr_dscritic := 'Não foi possivel localizar craptvl';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craptvl;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craptvl.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    --> Validar Numero da operacao de transferencia no SPB.
    IF TRIM(rw_craptvl.idopetrf) IS NULL THEN
      vr_dscritic := 'TED não possui Numero da operacao de transferencia no SPB.';
      RAISE vr_exc_erro;
    END IF;    
    
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => NULL                   --> Data que sera efetivada a operacao agendada
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_ted.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    
    ----> ACCOUNT DEBIT
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craptvl.cdcooper, --> Codigo da cooperativa
                           pr_nrdconta     => rw_craptvl.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => rw_craptvl.dstpctdb, --> Tipo de conta 
                           pr_json         => vr_ted,              --> Json a ser incrementado
                           pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                           pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    ---->  ACCOUNT CREDIT
    vr_ted.put('CDT_Acct_Bank'       , to_char(rw_craptvl.cdbccrcb));
    vr_ted.put('CDT_Acct_Branch'     , to_char(rw_craptvl.cdagercb));
    vr_ted.put('CDT_Acct_Branch_Desc', rw_craptvl.nmageban);
    vr_ted.put('CDT_Acct_Type'       , rw_craptvl.dstpctcr);
    vr_ted.put('CDT_Acct_Number'     , rw_craptvl.nrcctrcb);
    vr_ted.put('CDT_Acct_CreditUnion', '');
    vr_ted.put('CDT_Hldr_Type'       , rw_craptvl.dspescrd);
    vr_ted.put('CDT_Hldr_Document'   , nvl(rw_craptvl.ds_cpfcgrcb,'0'));
    vr_ted.put('CDT_Hldr_Name'       , rw_craptvl.nmpesrcb);
    
    ----> TRANSACTION
    vr_ted.put('Trxn_Id'             , to_char(pr_idanalis));
    vr_ted.put('Trxn_Channel'        , rw_craptvl.dsdcanal);
    vr_ted.put('Trxn_MessageCode'    , rw_craptvl.dscodmsg);
    vr_ted.put('Trxn_ControlNumber'  , rw_craptvl.idopetrf);
    vr_ted.put('Trxn_Date'           , to_char(SYSDATE,vr_dsformat_dthora));
    vr_ted.put('Trxn_Value'          , fn_format_number('Trxn_Value',rw_craptvl.vldocrcb));
    vr_ted.put('Trxn_Purpose'        , to_char(rw_craptvl.cdfinrcb) );
    vr_ted.put('Trxn_History'        , rw_craptvl.dshistor);
    vr_ted.put('Trxn_ScheduledDate'  , '');
    vr_ted.put('Trxn_ScheduledTime'  , '');
    vr_ted.put('Trxn_PreferenceLevel', '');
    vr_ted.put('Trxn_MovementDate'   , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_ted.put('Trxn_Scheduled'      , '0');
    vr_ted.put('Token_ID   '         , rw_fraude.dstoken);
    vr_ted.put('Tracking_IP'         , rw_fraude.iptransacao);
    vr_ted.put('Mobile_Device_ID'    , to_char(rw_fraude.iddispositivo));
    vr_ted.put('Trxn_NLS_Start_Date'   , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_ted.put('Trxn_NLS_End_Date'     , to_char(pr_dhlimana,vr_dsformat_dthora));
    
    vr_ted.print();
              
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarTedParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_ted
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio da TED para analise: '||SQLERRM;
  END pc_enviar_ted_analise;    
  
  --> Procedure para envio dos agendamentos de TED para analise de fraude
  PROCEDURE pc_enviar_agend_ted_analise (pr_idanalis     IN INTEGER,
                                         pr_Fingerprint OUT VARCHAR2, 
                                         pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                         pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic    OUT INTEGER,
                                         pr_dscritic    OUT VARCHAR2 )IS
  /* ..........................................................................
    
      Programa : pc_enviar_agend_ted_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 17/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio dos agendamentos de TED 
                  para analise de fraude
                  
      Alteração : 17/05/2017 - Ajustado rotina para incluir hora no campo Trxn_Date(Odirlei-AMcom)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.idanalise_fraude,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken      
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do agendamento de TED
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,
             cop.cdagectl,
             'CC' dstpctdb,
             ass.cdagenci,             
             
             --> Holder
             decode(ass.inpessoa,1,'F','J') dspesemi,
             ass.inpessoa,
             --ass.nrcpfcgc,
             decode(ass.inpessoa,1,lpad(ass.nrcpfcgc,11,'0'),
                                   lpad(ass.nrcpfcgc,14,'0')) ds_nrcpfcgc, 
             lau.nrdconta,
             ass.nmprimtl,
             lau.idseqttl,
             
             -- account credit
             decode(cti.intipcta,2,'PP','CC')  dstpctcr,
             to_char(lau.nrctadst, 'fm9999999999999') nrcctrcb,
             decode(cti.inpessoa,1,'F','J') dspescrd,
             lau.cddbanco,
             lau.cdageban,
             trim(caf.nmcidade) ||' - '||caf.cdufresd nmageban,
             --cti.nrcpfcgc cpfcgrcb,
             decode(cti.inpessoa,1,lpad(cti.nrcpfcgc,11,'0'),
                                   lpad(cti.nrcpfcgc,14,'0')) ds_cpfcgrcb,
             cti.nmtitula nmpesrcb,
             
             -- transaction
             lau.progress_recid,
             decode(lau.flmobile,1,10,3) dsdcanal,             
             (CASE --> Para agendamento não é necessario verificar horario de efetivação do TED
               WHEN cop.flgoppag = 1 AND ban.FLGOPPAG = 1 THEN
                'PAG0108'
               ELSE
                'STR0008'
              END) dscodmsg,
             lau.flmobile,
             lau.nrdocmto,
             lau.vllanaut,
             lau.dtmvtopg
              
        FROM craplau lau,
             crapcop cop,
             crapass ass,
             crapban ban,
             crapcti cti,
             crapagb agb,
             crapcaf caf
       WHERE lau.cdcooper = cop.cdcooper
         AND lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta 
         AND lau.cddbanco = ban.cdbccxlt         
         AND lau.cdcooper = cti.cdcooper
         AND lau.nrdconta = cti.nrdconta
         AND lau.cddbanco = cti.cddbanco
         AND lau.cdageban = cti.cdageban
         AND lau.nrctadst = cti.nrctatrf 
         AND lau.cddbanco = agb.cddbanco(+)
         AND lau.cdageban = agb.cdageban(+)
         AND agb.cdcidade = caf.cdcidade(+)
         AND lau.cdtiptra = 4    
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
        
    --> Buscar dados do titular
    CURSOR cr_crapttl (pr_cdcooper  crapttl.cdcooper%TYPE,
                       pr_nrdconta  crapttl.nrdconta%TYPE,
                       pr_idseqttl  crapttl.idseqttl%TYPE) IS
      SELECT ttl.nrcpfcgc,
             ttl.nmextttl,
             ttl.inpessoa
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;
    
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro   EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta   AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_ted        json := json();
    vr_code       VARCHAR2(10);
    vr_Message    VARCHAR2(1000);
    
    vr_nmextttl      crapass.nmprimtl%TYPE;
    vr_ds_nrcpfcgc   VARCHAR2(25);
    vr_nrctrlif      VARCHAR2(80);
    vr_qtsegret      NUMBER;
    vr_nmarqlog   VARCHAR2(500);
    vr_cdprogra   VARCHAR2(50) := 'pc_enviar_agend_ted_analise';
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    OPEN cr_craplau (pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplau INTO rw_craplau;
    
    IF cr_craplau%NOTFOUND THEN
      CLOSE cr_craplau;
      vr_dscritic := 'Não foi possivel localizar agendamento de TED';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplau;
    END IF;
    
    vr_nmextttl := rw_craplau.nmprimtl;
    vr_ds_nrcpfcgc := rw_craplau.ds_nrcpfcgc;
    
    -- Se for pessoa fisica, usar dados do titular
    IF rw_craplau.inpessoa = 1 THEN
    
      --> Buscar dados do titular
      OPEN cr_crapttl (pr_cdcooper  => rw_craplau.cdcooper,
                       pr_nrdconta  => rw_craplau.nrdconta,
                       pr_idseqttl  => rw_craplau.idseqttl);
      FETCH cr_crapttl INTO rw_crapttl;
      
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Titular nao cadastrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapttl;
        
      vr_nmextttl := rw_crapttl.nmextttl;
      
      IF rw_crapttl.inpessoa = 1 THEN
        vr_ds_nrcpfcgc := lpad(rw_crapttl.nrcpfcgc,11,'0');
      ELSE
        vr_ds_nrcpfcgc := lpad(rw_crapttl.nrcpfcgc,14,'0');
      END IF;
      
    END IF; 
   
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplau.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => rw_craplau.dtmvtopg    --> Data que sera efetivada a operacao agendada
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_ted.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    
    ----> ACCOUNT DEBIT
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craplau.cdcooper, --> Codigo da cooperativa
                           pr_nrdconta     => rw_craplau.nrdconta, --> Numero da conta do cooperaro
                           pr_dstpctdb     => rw_craplau.dstpctdb, --> Tipo de conta 
                           pr_json         => vr_ted,              --> Json a ser incrementado
                           pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                           pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
                           
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;   
       
    
    ---->  ACCOUNT CREDIT
    vr_ted.put('CDT_Acct_Bank'       , to_char(rw_craplau.cddbanco));
    vr_ted.put('CDT_Acct_Branch'     , to_char(rw_craplau.cdageban));
    vr_ted.put('CDT_Acct_Branch_Desc', rw_craplau.nmageban);
    vr_ted.put('CDT_Acct_Type'       , rw_craplau.dstpctcr);
    vr_ted.put('CDT_Acct_Number'     , rw_craplau.nrcctrcb);
    vr_ted.put('CDT_Acct_CreditUnion', '');
    vr_ted.put('CDT_Hldr_Type'       , rw_craplau.dspescrd);
    vr_ted.put('CDT_Hldr_Document'   , nvl(rw_craplau.ds_cpfcgrcb,'0'));
    vr_ted.put('CDT_Hldr_Name'       , rw_craplau.nmpesrcb);
    
    ----> TRANSACTION
    vr_ted.put('Trxn_Id'             , to_char(pr_idanalis));
    vr_ted.put('Trxn_Channel'        , rw_craplau.dsdcanal);
    vr_ted.put('Trxn_MessageCode'    , rw_craplau.dscodmsg);
    
    vr_nrctrlif := '1'||to_char(rw_crapdat.dtmvtocd,'RRMMDD')
                      ||to_char(rw_craplau.cdagectl,'fm0000')
                      ||to_char(rw_craplau.nrdocmto,'fm00000000');
    --> Canal Mobile 
    IF rw_craplau.flmobile = 1 THEN 
      vr_nrctrlif := vr_nrctrlif ||'M';
    ELSE 
      --> Canal InternetBank
      vr_nrctrlif := vr_nrctrlif ||'I';
    END IF;
    
    
    vr_ted.put('Trxn_ControlNumber'  , vr_nrctrlif);
    vr_ted.put('Trxn_Date'           , to_char(SYSDATE,vr_dsformat_dthora));
    vr_ted.put('Trxn_Value'          , fn_format_number('Trxn_Value',rw_craplau.vllanaut));
    vr_ted.put('Trxn_Purpose'        , '10');
    vr_ted.put('Trxn_History'        , '');
    vr_ted.put('Trxn_ScheduledDate'  , to_char(rw_craplau.dtmvtopg,vr_dsformat_data));
    vr_ted.put('Trxn_ScheduledTime'  , '');
    vr_ted.put('Trxn_PreferenceLevel', '');
    vr_ted.put('Trxn_MovementDate'   , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_ted.put('Trxn_Scheduled'      , '1');
    vr_ted.put('Tracking_IP'         , rw_fraude.iptransacao);  
    vr_ted.put('Trxn_NLS_Start_Date' , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_ted.put('Trxn_NLS_End_Date'   , to_char(pr_dhlimana,vr_dsformat_dthora));      
    vr_ted.put('Token_ID   '         , rw_fraude.dstoken);
    vr_ted.put('Mobile_Device_ID'    , to_char(rw_fraude.iddispositivo));
     
              
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarTedParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_ted
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
                                                 
    --> vr_resposta.conteudo.Print();     
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
        
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
        vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
        vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio do agendamento de TED para analise: '||SQLERRM;
  END pc_enviar_agend_ted_analise;    
  
  --> Rotina para retornar dados do destinatario do titulo
  PROCEDURE pc_ret_dados_benef_titulo (pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE,
                                       pr_nrcpfcgc OUT NUMBER,
                                       pr_tppessoa OUT VARCHAR2,
                                       pr_nmpessoa OUT VARCHAR2) IS
    /* ..........................................................................
    
      Programa : pc_ret_dados_dest_titulo        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 12/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar dados do destinatario do titulo
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_npc IS
      SELECT con.flgcontingencia,
             con.dsxml
        FROM tbcobran_consulta_titulo con
       WHERE con.cdctrlcs = pr_cdctrlcs;  
    rw_npc cr_npc%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    vr_flnpc    BOOLEAN;
    vr_tbTitulo NPCB0001.typ_reg_TituloCIP;
    vr_des_erro VARCHAR2(500);
    vr_dscritic VARCHAR2(1000);
    vr_nrcpfcgc NUMBER;
    
    
    
  BEGIN
  
    --> Buscar dados da consulta 
    OPEN cr_npc;
    FETCH cr_npc INTO rw_npc;
    vr_flnpc := cr_npc%FOUND;
    CLOSE cr_npc;
              
    --> Senao estiver em contigencia
    IF vr_flnpc AND rw_npc.flgcontingencia = 0 THEN
      npcb0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => rw_npc.dsxml
                                       , pr_tbtitulo => vr_tbtitulo
                                       , pr_des_erro => vr_des_erro
                                       , pr_dscritic => vr_dscritic);
                                               
      IF vr_dscritic IS NOT NULL THEN
        pr_nrcpfcgc := 0;
        pr_tppessoa := NULL;
        pr_nmpessoa := NULL;
      ELSE
        pr_nrcpfcgc := vr_tbtitulo.CNPJ_CPFBenfcrioOr;
        pr_tppessoa := vr_tbtitulo.TpPessoaBenfcrioOr;
        pr_nmpessoa := vr_tbtitulo.Nom_RzSocBenfcrioOr;
      
      END IF;
      
    ELSE
      pr_nrcpfcgc := 0;
      pr_tppessoa := NULL;
      pr_nmpessoa := NULL;
    END IF;  

  EXCEPTION 
    WHEN OTHERS THEN
      pr_nrcpfcgc := 0;
      pr_tppessoa := NULL;
      pr_nmpessoa := NULL;
  END pc_ret_dados_benef_titulo;
   
  --> Procedure para envio de titulo para analise de fraude
  PROCEDURE pc_enviar_titulo_analise ( pr_idanalis     IN INTEGER,
                                       pr_Fingerprint OUT VARCHAR2, 
                                       pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                       pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                       pr_cdcritic    OUT INTEGER,
                                       pr_dscritic    OUT VARCHAR2 )IS
  /* ..........................................................................
    
      Programa : pc_enviar_titulo_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 12/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio de titulo para analise de fraude
      
      Alteração : 06/07/2018 - Ajustado para buscar cedente da tabela de lancamento(CRAPLCM).
	                           PRJ381 - Antifraude(Odirlei-AMcom)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do lancamento
    CURSOR cr_craptit (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tit.cdcooper,
             tit.nrdconta,
             tit.dscodbar,
             tit.nrcpfcgc,
             tit.vldpagto,
             tit.nrautdoc,
             tit.cdctrlcs,
             tit.cdbandst,
             pro.dscedent
        FROM crappro pro,
             craptit tit      
       WHERE pro.nrseqaut = tit.nrautdoc
         AND pro.dtmvtolt = tit.dtmvtolt
         AND pro.cdcooper = tit.cdcooper
         AND pro.nrdconta = tit.nrdconta
         AND tit.idanafrd = pr_idanalis
         AND tit.cdcooper = pr_cdcooper
         AND tit.nrdconta = pr_nrdconta;                
    rw_craptit cr_craptit%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta   AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_titulo     json := json();
    vr_code       VARCHAR2(10);
    vr_Message    VARCHAR2(1000);
    vr_qtsegret   NUMBER;
    
    vr_nmarqlog   VARCHAR2(500);
    vr_cdprogra   VARCHAR2(50) := 'pc_enviar_titulos_analise';
    
    vr_lindigit   VARCHAR2(100);
    vr_nrcpfcgc_bnf NUMBER;
    vr_tppessoa_bnf VARCHAR2(10);
    vr_nmpessoa_bnf VARCHAR2(200);
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
  
    OPEN cr_craptit( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craptit INTO rw_craptit;
    
    IF cr_craptit%NOTFOUND THEN
      CLOSE cr_craptit;
      vr_dscritic := 'Não foi possivel localizar craplft';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craptit;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craptit.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    vr_nrcpfcgc_bnf := NULL;
    vr_tppessoa_bnf := NULL;
    vr_nmpessoa_bnf := NULL;
    
    IF TRIM(rw_craptit.cdctrlcs) IS NOT NULL THEN
      --> Retornar dados do destinatario do titulo
      pc_ret_dados_benef_titulo (pr_cdctrlcs => rw_craptit.cdctrlcs,
                                 pr_nrcpfcgc => vr_nrcpfcgc_bnf,
                                 pr_tppessoa => vr_tppessoa_bnf,
                                 pr_nmpessoa => vr_nmpessoa_bnf);
    END IF;    
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação                                      
                                ,pr_dtefeope  => NULL                   --> Data que sera efetivada a operacao agendada
                                ,pr_cdcooper  => rw_fraude.cdcooper    --> Codigo da cooperativa, para uso do limite de operacao
                                ,pr_tplimite  => 2                      --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao                                        
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_titulo.put('Trxn_TransferIdentifier', (fn_dsoperacao_fraude(rw_fraude.cdoperacao)));
    
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craptit.cdcooper, --> Codigo da cooperativa
                             pr_nrdconta     => rw_craptit.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => 'CC',                --> Tipo de conta 
                             pr_json         => vr_titulo,           --> Json a ser incrementado
                             pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                             pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    
    ---->  ACCOUNT CREDIT
    vr_titulo.put('CDT_Acct_Bank'       , to_char(rw_craptit.cdbandst));
    vr_titulo.put('CDT_Acct_Branch'     , '0'); 
       
    vr_titulo.put('CDT_Hldr_Type'       , nvl(vr_tppessoa_bnf,'0'));
    vr_titulo.put('CDT_Hldr_Document'   , nvl((CASE upper(vr_tppessoa_bnf) 
                                             WHEN 'F' THEN lpad(vr_nrcpfcgc_bnf,11,'0')
                                             WHEN 'J' THEN lpad(vr_nrcpfcgc_bnf,14,'0')
                                                 ELSE '0'
                                               END),'0'));
    vr_titulo.put('CDT_Hldr_Name'       , coalesce(TRIM(rw_craptit.dscedent),vr_nmpessoa_bnf,'0'));
    
    
    ----> TRANSACTION
    vr_titulo.put('Trxn_Id'                   , to_char(pr_idanalis));
    vr_titulo.put('Trxn_Channel'              , to_char(rw_fraude.cdcanal_operacao));
    vr_titulo.put('BillPayment_Bar_Code'      , rw_craptit.dscodbar);
    
    vr_lindigit := NULL;
    COBR0005.pc_calc_linha_digitavel (pr_cdbarras => rw_craptit.dscodbar, 
                                      pr_lindigit => vr_lindigit);
                                      
    vr_titulo.put('BillPayment_Sequence_ID'   , vr_lindigit);
    vr_titulo.put('Trxn_Value'                , fn_format_number('Trxn_Value',rw_craptit.vldpagto));
    vr_titulo.put('Trxn_History'              , rw_craptit.dscedent);
    vr_titulo.put('BillPayment_Authentication' , to_char(rw_craptit.nrautdoc));
    vr_titulo.put('Trxn_Date'                 , to_char(SYSDATE,vr_dsformat_dthora));
    vr_titulo.put('Trxn_ScheduledDate'        , '');
    vr_titulo.put('Trxn_ScheduledTime'        , '');
    vr_titulo.put('Trxn_PreferenceLevel'      , '');
    vr_titulo.put('Trxn_MovementDate'         , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_titulo.put('Trxn_Scheduled'            , '0');
    vr_titulo.put('Token_ID   '               , rw_fraude.dstoken);
    vr_titulo.put('Tracking_IP'               , rw_fraude.iptransacao);
    vr_titulo.put('Mobile_Device_ID'          , to_char(rw_fraude.iddispositivo));
    vr_titulo.put('Trxn_NLS_Start_Date'       , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_titulo.put('Trxn_NLS_End_Date'         , to_char(pr_dhlimana,vr_dsformat_dthora));
            
    
    --> Campos obrigatorios
    vr_titulo.put('Trxn_MessageCode'       , '0'); 
    vr_titulo.put('Trxn_ControlNumber'     , '0'); 
    vr_titulo.put('CDT_Acct_Type'          , '0'); 
    vr_titulo.put('CDT_Acct_Number'        , '0'); 
    vr_titulo.put('Trxn_Purpose'           , '0'); 
    
            
--    vr_titulo.print();
      
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarTituloParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_titulo
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio da Titulo para analise: '||SQLERRM;
  END pc_enviar_titulo_analise;    
  
  --> Procedure para envio de agendamento de pagamento de titulo para analise de fraude
  PROCEDURE pc_enviar_agend_titulo_analise ( pr_idanalis     IN INTEGER,
                                             pr_Fingerprint OUT VARCHAR2, 
                                             pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                             pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                             pr_cdcritic    OUT INTEGER,
                                             pr_dscritic    OUT VARCHAR2 )IS
  /* ..........................................................................
    
      Programa : pc_enviar_agend_titulo_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 12/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Procedure para envio de agendamento de pagamento de titulo para analise de fraude
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do lancamento
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,
             lau.nrdconta,
             lau.dscodbar,
             lau.dslindig,
             lau.idlancto,
             lau.cdtiptra,
             lau.cdctrlcs,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.idlancto nrautdoc,
             lau.dscedent
        FROM craplau lau      
       WHERE lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;                
    rw_craplau cr_craplau%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta   AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_titulo     json := json();
    vr_code       VARCHAR2(10);
    vr_Message    VARCHAR2(1000);
    vr_qtsegret   NUMBER;
    
    vr_nmarqlog   VARCHAR2(500);
    vr_cdprogra   VARCHAR2(50) := 'pc_enviar_tributos_analise';
    vr_nrcpfcgc_bnf NUMBER;
    vr_tppessoa_bnf VARCHAR2(10);
    vr_nmpessoa_bnf VARCHAR2(200);
    vr_cdbandst     NUMBER;
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
  
    OPEN cr_craplau( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplau INTO rw_craplau;
    
    IF cr_craplau%NOTFOUND THEN
      CLOSE cr_craplau;
      vr_dscritic := 'Não foi possivel localizar craplau';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplau;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplau.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    vr_nrcpfcgc_bnf := NULL;
    vr_tppessoa_bnf := NULL;
    vr_nmpessoa_bnf := NULL;
    
    IF TRIM(rw_craplau.cdctrlcs) IS NOT NULL THEN
      --> Retornar dados do destinatario do titulo
      pc_ret_dados_benef_titulo (pr_cdctrlcs => rw_craplau.cdctrlcs,
                                 pr_nrcpfcgc => vr_nrcpfcgc_bnf,
                                 pr_tppessoa => vr_tppessoa_bnf,
                                 pr_nmpessoa => vr_nmpessoa_bnf);
    END IF;
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => rw_craplau.dtmvtopg    --> Data que sera efetivada a operacao agendada
                                ,pr_cdcooper  => rw_fraude.cdcooper     --> Codigo da cooperativa, para uso do limite de operacao
                                ,pr_tplimite  => 2                      --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao                                                                        
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_titulo.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craplau.cdcooper, --> Codigo da cooperativa
                             pr_nrdconta     => rw_craplau.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => 'CC',                --> Tipo de conta 
                             pr_json         => vr_titulo,           --> Json a ser incrementado
                             pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                             pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    --Determinar codigo barras    
    vr_cdbandst:= to_number(SUBSTR(rw_craplau.dscodbar,01,03));
    
    ---->  ACCOUNT CREDIT
    vr_titulo.put('CDT_Acct_Bank'       , to_char(vr_cdbandst));
    vr_titulo.put('CDT_Acct_Branch'     , '0'); 
       
    vr_titulo.put('CDT_Hldr_Type'       , nvl(vr_tppessoa_bnf,'0'));
    vr_titulo.put('CDT_Hldr_Document'   , nvl((CASE upper(vr_tppessoa_bnf) 
                                             WHEN 'F' THEN lpad(vr_nrcpfcgc_bnf,11,'0')
                                             WHEN 'J' THEN lpad(vr_nrcpfcgc_bnf,14,'0')
                                             ELSE '0'
                                           END),'0'));
    vr_titulo.put('CDT_Hldr_Name'       , coalesce(trim(rw_craplau.dscedent),vr_nmpessoa_bnf,'0'));
    
    
    ----> TRANSACTION
    vr_titulo.put('Trxn_Id'                   , to_char(pr_idanalis));
    vr_titulo.put('Trxn_Channel'              , to_char(rw_fraude.cdcanal_operacao));
    vr_titulo.put('BillPayment_Bar_Code'      , rw_craplau.dscodbar);                                      
    vr_titulo.put('BillPayment_Sequence_ID'   , rw_craplau.dslindig);
    vr_titulo.put('Trxn_Value'                , fn_format_number('Trxn_Value',rw_craplau.vllanaut));
    vr_titulo.put('Trxn_History'              , rw_craplau.dscedent);
    vr_titulo.put('BillPayment_Authentication' , to_char(rw_craplau.nrautdoc));
    vr_titulo.put('Trxn_Date'                 , to_char(SYSDATE,vr_dsformat_dthora));
    
    vr_titulo.put('Trxn_ScheduledDate'        , to_char(rw_craplau.dtmvtopg,vr_dsformat_data));
    vr_titulo.put('Trxn_ScheduledTime'        , '');
    vr_titulo.put('Trxn_PreferenceLevel'      , '');
    vr_titulo.put('Trxn_MovementDate'         , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_titulo.put('Trxn_Scheduled'            , '1');

    vr_titulo.put('Token_ID   '               , rw_fraude.dstoken);
    vr_titulo.put('Tracking_IP'               , rw_fraude.iptransacao);
    vr_titulo.put('Mobile_Device_ID'          , to_char(rw_fraude.iddispositivo));
    vr_titulo.put('Trxn_NLS_Start_Date'       , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_titulo.put('Trxn_NLS_End_Date'         , to_char(pr_dhlimana,vr_dsformat_dthora));
    
    --> Campos obrigatorios
    vr_titulo.put('Trxn_MessageCode'       , '0'); 
    vr_titulo.put('Trxn_ControlNumber'     , '0'); 
    vr_titulo.put('CDT_Acct_Type'          , '0'); 
    vr_titulo.put('CDT_Acct_Number'        , '0'); 
    vr_titulo.put('Trxn_Purpose'           , '0'); 
              
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarTituloParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_titulo
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio de agendamento de Titulo para analise: '||SQLERRM;
  END pc_enviar_agend_titulo_analise;    
  
  --> Procedure para envio de tributos para analise de fraude
  PROCEDURE pc_enviar_tributo_analise ( pr_idanalis     IN INTEGER,
                                         pr_Fingerprint OUT VARCHAR2, 
                                         pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                         pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic    OUT INTEGER,
                                         pr_dscritic    OUT VARCHAR2 )IS
  /* ..........................................................................
    
      Programa : pc_enviar_tributo_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 10/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio de tributos para analise de fraude
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do lancamento
    CURSOR cr_craplft (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lft.cdcooper,
             lft.nrdconta,
             lft.cdbarras,
             lft.dtapurac,
             lft.nrcpfcgc,
             lft.cdempcon cdempcon_ori,
             lft.cdempcon ||'-'|| lft.cdsegmto cdempcon,
             con.nmextcon,
             con.tparrecd,
             --Icluir valor de multa e fatura para DARF
             decode(lft.tpfatura,2,lft.vllanmto + nvl(lft.vlrmulta,0) + nvl(lft.vlrjuros,0),
                                   lft.vllanmto) vllanmto,
             lft.nrautdoc,
             lft.cdtribut,
             pro.dscedent
        FROM crappro pro,
             crapcon con,
             craplft lft      
       WHERE pro.nrseqaut = lft.nrautdoc
         AND pro.dtmvtolt = lft.dtmvtolt
         AND pro.cdcooper = lft.cdcooper
         AND pro.nrdconta = lft.nrdconta
         AND lft.cdcooper = con.cdcooper(+)
         AND lft.cdempcon = con.cdempcon(+)
         AND lft.cdsegmto = con.cdsegmto(+)
         AND lft.idanafrd = pr_idanalis
         AND lft.cdcooper = pr_cdcooper
       AND lft.nrdconta = pr_nrdconta;                
    rw_craplft cr_craplft%ROWTYPE;
    
    --> Buscar dados convenio sicredi
		CURSOR cr_crapscn(pr_cdempres crapscn.cdempres%TYPE,
		                  pr_tpmeiarr crapstn.tpmeiarr%TYPE)IS
    SELECT scn.dsnomcnv,
           scn.cdempcon ||'-'|| scn.cdsegmto cdempcon
      FROM crapscn scn,
		       crapstn stn
     WHERE scn.cdempres = pr_cdempres
		   AND stn.cdempres = scn.cdempres
		   AND stn.tpmeiarr = pr_tpmeiarr;
    rw_crapscn cr_crapscn%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta   AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_trib       json := json();
    vr_code       VARCHAR2(10);
    vr_Message    VARCHAR2(1000);
    vr_qtsegret   NUMBER;
    
    vr_nmarqlog   VARCHAR2(500);
    vr_cdprogra   VARCHAR2(50) := 'pc_enviar_tributos_analise';
    
    vr_lindigit   VARCHAR2(100);
    vr_cdempcon   VARCHAR2(100);
    
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
  
    OPEN cr_craplft( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplft INTO rw_craplft;
    
    IF cr_craplft%NOTFOUND THEN
      CLOSE cr_craplft;
      vr_dscritic := 'Não foi possivel localizar craplft';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplft;
    END IF;
    
    vr_cdempcon := rw_craplft.cdempcon;
    IF nvl(rw_craplft.cdempcon_ori,0) = 0 THEN
      -- Pega o nome do convenio
      OPEN cr_crapscn (pr_cdempres => CASE rw_craplft.cdtribut
                                           WHEN '6106' THEN 'D0'
                                           ELSE 'A0' 
                                      END,
                       pr_tpmeiarr => CASE rw_fraude.cdcanal_operacao
                                           WHEN 3 THEN 'D'
                                           ELSE 'C'
                                           END);
      FETCH cr_crapscn INTO rw_crapscn;      
      CLOSE cr_crapscn;
			vr_cdempcon := rw_crapscn.cdempcon;      
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplft.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => NULL                   --> Data que sera efetivada a operacao agendada
                                ,pr_cdcooper  => rw_fraude.cdcooper     --> Codigo da cooperativa, para uso do limite de operacao
                                ,pr_tplimite  => (CASE rw_craplft.tparrecd
                                                    WHEN 1 THEN 3 -- Sicredi
                                                    WHEN 2 THEN 4 -- Bancoob
                                                    WHEN 3 THEN 2 -- Cecred
                                                    ELSE 0
                                                  END )                 --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_trib.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    --> Campos Obrigatorios
    vr_trib.put('Trxn_MessageCode'    , '0');   
    vr_trib.put('Trxn_ControlNumber'  , '0');   
    vr_trib.put('CDT_Acct_Bank'       , '0');   
    vr_trib.put('CDT_Acct_Branch'     , '0');   
    vr_trib.put('CDT_Acct_Type'       , '0');   
    vr_trib.put('CDT_Acct_Number'     , '0');
    vr_trib.put('CDT_Hldr_Type'       , '0');
    vr_trib.put('CDT_Hldr_Document'   , '0');
    vr_trib.put('CDT_Hldr_Name'       , rw_craplft.dscedent);
    vr_trib.put('Trxn_Purpose'        , '0');
    
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craplft.cdcooper, --> Codigo da cooperativa
                             pr_nrdconta     => rw_craplft.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => 'CC',                --> Tipo de conta 
                             pr_json         => vr_trib,             --> Json a ser incrementado
                             pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                             pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    ----> TRANSACTION
    vr_trib.put('Trxn_Id'                   , to_char(pr_idanalis));
    vr_trib.put('Trxn_Channel'              , to_char(rw_fraude.cdcanal_operacao));
    vr_trib.put('BillPayment_Bar_Code'      , rw_craplft.cdbarras);
    
    vr_lindigit := NULL;
    CXON0014.pc_calc_lindig_fatura (pr_cdbarras => rw_craplft.cdbarras, 
                                    pr_lindigit => vr_lindigit);
    vr_trib.put('BillPayment_Sequence_ID'   , vr_lindigit);
    vr_trib.put('BillPayment_Reference_Date', rw_craplft.dtapurac);
    vr_trib.put('CDT_Hldr_Document'         , nvl(rw_craplft.nrcpfcgc,'0'));
    vr_trib.put('BillPayment_Consorcy_ID'   , vr_cdempcon);
    vr_trib.put('BillPayment_Consorcy_Desc' , nvl(rw_craplft.nmextcon,rw_crapscn.dsnomcnv));
    vr_trib.put('Trxn_Value'                , fn_format_number('Trxn_Value',rw_craplft.vllanmto));
    vr_trib.put('Trxn_History'              , rw_craplft.dscedent);
    vr_trib.put('BillPayment_Authentication' , to_char(rw_craplft.nrautdoc));
    vr_trib.put('Trxn_Date'                 , to_char(SYSDATE,vr_dsformat_dthora));
    vr_trib.put('Trxn_ScheduledDate'        , '');
    vr_trib.put('Trxn_ScheduledTime'        , '');
    vr_trib.put('Trxn_PreferenceLevel'      , '');
    vr_trib.put('Trxn_MovementDate'         , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_trib.put('Trxn_Scheduled'            , '0');
    vr_trib.put('Token_ID   '               , rw_fraude.dstoken);
    vr_trib.put('Tracking_IP'               , rw_fraude.iptransacao);
    vr_trib.put('Mobile_Device_ID'          , to_char(rw_fraude.iddispositivo));
    vr_trib.put('Trxn_NLS_Start_Date'       , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_trib.put('Trxn_NLS_End_Date'         , to_char(pr_dhlimana,vr_dsformat_dthora));
              
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarTributoParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_trib
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio da Tributo para analise: '||SQLERRM;
  END pc_enviar_tributo_analise;    
  
  --> Procedure para envio de tributos para analise de fraude
  PROCEDURE pc_enviar_agend_trib_analise ( pr_idanalis     IN INTEGER,
                                           pr_Fingerprint OUT VARCHAR2, 
                                           pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                           pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                           pr_cdcritic    OUT INTEGER,
                                           pr_dscritic    OUT VARCHAR2 )IS
  /* ..........................................................................
    
      Programa : pc_enviar_agend_trib_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 10/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio de tributos para analise de fraude
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do agendamento
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,
             lau.nrdconta,
             lau.dscodbar,
             lau.idlancto,
             lau.cdtiptra,
             SUBSTR(lau.dscodbar,16,4) cdempcon,
             SUBSTR(lau.dscodbar, 2,1) cdsegmto,
             con.cdempcon ||'-'||con.cdsegmto cdempcon_2,             
             con.nmextcon,
             con.tparrecd,
             lau.vllanaut,
             lau.dtmvtopg,
--           lau.nrautdoc,
             lau.dscedent
        FROM craplau lau,
             crapcon con      
       WHERE lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta         
         AND lau.cdcooper = con.cdcooper(+)
         AND SUBSTR(lau.dscodbar,16,4) = con.cdempcon(+)
         AND SUBSTR(lau.dscodbar, 2,1) = con.cdsegmto(+);                
    rw_craplau cr_craplau%ROWTYPE;
    
    --> Buscar detalhes de agend. DARF/DAS
    CURSOR cr_darf (pr_idlancto craplau.idlancto%TYPE) IS
      SELECT darf.dtapuracao,
             darf.nrcpfcgc
        FROM tbpagto_agend_darf_das darf
       WHERE darf.idlancto = pr_idlancto;
    rw_darf cr_darf%ROWTYPE;
    
    --> Buscar detalhes de agend. trib
    CURSOR cr_tributos (pr_idlancto craplau.idlancto%TYPE) IS
      SELECT trib.dtcompetencia,
             trib.nridentificacao
        FROM tbpagto_agend_tributos trib
       WHERE trib.idlancto = pr_idlancto;
    rw_tributos cr_tributos%ROWTYPE;
    
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta   AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_trib       json := json();
    vr_code       VARCHAR2(10);
    vr_Message    VARCHAR2(1000);
    vr_qtsegret   NUMBER;
    
    vr_nmarqlog   VARCHAR2(500);
    vr_cdprogra   VARCHAR2(50) := 'pc_enviar_agend_tributo_analise';
    
    vr_lindigit   VARCHAR2(100);
    vr_dtapurac   DATE;
    vr_nrcpfcgc   NUMBER;
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
  
    OPEN cr_craplau( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplau INTO rw_craplau;
    
    IF cr_craplau%NOTFOUND THEN
      CLOSE cr_craplau;
      vr_dscritic := 'Não foi possivel localizar craplau';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplau;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplau.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    IF rw_craplau.cdtiptra = 10 THEN
    
      --> Buscar detalhes de agend. DARF/DAS
      rw_darf := NULL;
      OPEN cr_darf (pr_idlancto => rw_craplau.idlancto);
      FETCH cr_darf INTO rw_darf;
      CLOSE cr_darf;
      
      vr_dtapurac := rw_darf.dtapuracao;
      vr_nrcpfcgc := trim(rw_darf.nrcpfcgc);
      
    ELSE
    
      --> Buscar detalhes de agend. trib
      rw_tributos := NULL;
      OPEN cr_tributos (pr_idlancto => rw_craplau.idlancto);
      FETCH cr_tributos INTO rw_tributos;
      CLOSE cr_tributos;
      
      vr_dtapurac := rw_tributos.dtcompetencia;
      vr_nrcpfcgc := trim(rw_tributos.nridentificacao);
    
    END IF;
    
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => rw_craplau.dtmvtopg    --> Data que sera efetivada a operacao agendada
                                ,pr_cdcooper  => rw_fraude.cdcooper    --> Codigo da cooperativa, para uso do limite de operacao
                                ,pr_tplimite  => (CASE rw_craplau.tparrecd
                                                    WHEN 1 THEN 3 -- Sicredi
                                                    WHEN 2 THEN 4 -- Bancoob
                                                    WHEN 3 THEN 2 -- Cecred
                                                    ELSE 0
                                                  END )                 --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao                                
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_trib.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craplau.cdcooper, --> Codigo da cooperativa
                             pr_nrdconta     => rw_craplau.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => 'CC',                --> Tipo de conta 
                             pr_json         => vr_trib,             --> Json a ser incrementado
                             pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                             pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;

    ----> TRANSACTION
    vr_trib.put('Trxn_Id'                   , to_char(pr_idanalis));
    vr_trib.put('Trxn_Channel'              , to_char(rw_fraude.cdcanal_operacao));
    vr_trib.put('BillPayment_Bar_Code'      , rw_craplau.dscodbar);
    
    vr_lindigit := NULL;
    CXON0014.pc_calc_lindig_fatura (pr_cdbarras => rw_craplau.dscodbar, 
                                    pr_lindigit => vr_lindigit);
    vr_trib.put('BillPayment_Sequence_ID'   , vr_lindigit);
    vr_trib.put('BillPayment_Reference_Date', vr_dtapurac);
    vr_trib.put('CDT_Hldr_Document'         , nvl(vr_nrcpfcgc,'0'));
    vr_trib.put('BillPayment_Consorcy_ID'   , rw_craplau.cdempcon_2);
    vr_trib.put('BillPayment_Consorcy_Desc' , rw_craplau.nmextcon);
    vr_trib.put('Trxn_Value'                , fn_format_number('Trxn_Value',rw_craplau.vllanaut));
    vr_trib.put('Trxn_History'              , rw_craplau.dscedent);
    vr_trib.put('BillPayment_Authentication' , to_char(rw_craplau.idlancto));
    vr_trib.put('Trxn_Date'                 , to_char(SYSDATE,vr_dsformat_dthora));
    vr_trib.put('Trxn_ScheduledDate'        , to_char(rw_craplau.dtmvtopg,vr_dsformat_data));
    vr_trib.put('Trxn_ScheduledTime'        , '');
    vr_trib.put('Trxn_PreferenceLevel'      , '');
    vr_trib.put('Trxn_MovementDate'         , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_trib.put('Trxn_Scheduled'            , '1');
    vr_trib.put('Token_ID   '               , rw_fraude.dstoken);
    vr_trib.put('Tracking_IP'               , rw_fraude.iptransacao);
    vr_trib.put('Mobile_Device_ID'          , to_char(rw_fraude.iddispositivo));
    vr_trib.put('Trxn_NLS_Start_Date'       , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_trib.put('Trxn_NLS_End_Date'         , to_char(pr_dhlimana,vr_dsformat_dthora));
    
    --> Campos obrigatorios
    vr_trib.put('Trxn_MessageCode'    , '0');   
    vr_trib.put('Trxn_ControlNumber'  , '0');   
    vr_trib.put('CDT_Acct_Bank'       , '0');   
    vr_trib.put('CDT_Acct_Branch'     , '0');   
    vr_trib.put('CDT_Acct_Type'       , '0');   
    vr_trib.put('CDT_Acct_Number'     , '0');
    vr_trib.put('CDT_Hldr_Type'       , '0');
    vr_trib.put('CDT_Hldr_Document'   , '0');
    vr_trib.put('CDT_Hldr_Name'       , rw_craplau.dscedent);
    vr_trib.put('Trxn_Purpose'        , '0');

 
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarTributoParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_trib
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio de Agendamento Tributos para analise: '||SQLERRM;
  END pc_enviar_agend_trib_analise;    
  

  --> Procedure para envio da GPS para analise de fraude 
  PROCEDURE pc_enviar_gps_analise (pr_idanalis    IN  INTEGER
                                  ,pr_Fingerprint OUT VARCHAR2 
                                  ,pr_dhdenvio    OUT TIMESTAMP   --> Data hora do envio para a analise
                                  ,pr_dhlimana    OUT TIMESTAMP   --> Data hora de limite de aguardo para a analise
                                  ,pr_cdcritic    OUT INTEGER
                                  ,pr_dscritic    OUT VARCHAR2) IS
  /* ..........................................................................
    
      Programa : pc_enviar_gps_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Teobaldo Jamunda (AMcom)
      Data     : Abril/2018.                   Ultima atualizacao: 05/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio da GPS para analise de fraude
                  (PRJ381 - Analise de Fraude)
                   
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informacoes GPS
    CURSOR cr_craplgp (pr_idanalis  craplgp.idanafrd%TYPE,
                       pr_cdcooper  craplgp.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT lgp.cdcooper,
             ass.nrdconta,
             cop.cdagectl,
             ass.cdagenci,
             decode(pes.tppessoa, 1, 'F', 'J') dspessoa,
             decode(pes.tppessoa, 1, lpad(pes.nrcpfcgc,11,'0'),
                                     lpad(pes.nrcpfcgc,14,'0')) dscpfcgc,
             pes.nmpessoa,    
            -- Trxn_Contact_2_info --> melhor forma de obter
            -- Trxn_Contact_3_info
            -- Trxn_Contact_4_info
            lgp.cdbarras,
            lgp.dslindig,
            lgp.mmaacomp,
            lgp.vlrtotal,
            lgp.nrautdoc,
            lgp.vlrdinss
       FROM craplgp lgp,
            crapcop cop,
            crapass ass,
            tbcadast_pessoa pes
      WHERE lgp.cdcooper = cop.cdcooper
        AND lgp.cdcooper = ass.cdcooper
        AND lgp.nrctapag = ass.nrdconta
        AND ass.nrcpfcgc = pes.nrcpfcgc
        AND lgp.idanafrd = pr_idanalis  
        AND lgp.cdcooper = pr_cdcooper  -- 1
        AND lgp.nrctapag = pr_nrdconta; -- 8199124      
    rw_craplgp cr_craplgp%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta   AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_gps        json := json();
    vr_code       VARCHAR2(10);
    vr_Message    VARCHAR2(1000);
    vr_qtsegret   NUMBER;
    vr_lindigit   VARCHAR2(80);
        
    vr_dtapurac   date;
    vr_nmarqlog   VARCHAR2(500);
    vr_cdprogra   VARCHAR2(50) := 'pc_enviar_gps_analise';
    
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    OPEN cr_craplgp( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplgp INTO rw_craplgp;
    
    IF cr_craplgp%NOTFOUND THEN
      CLOSE cr_craplgp;
      vr_dscritic := 'Não foi possivel localizar craplgp';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplgp;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplgp.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => NULL                   --> Data que sera efetivada a operacao agendada
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_gps.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    ---->  ACCOUNT CREDIT
    --> Carregar no objeto json os dados da conta
    AFRA0001.pc_carregar_conta_json (pr_cdcooper     => rw_craplgp.cdcooper, --> Codigo da cooperativa
                                     pr_nrdconta     => rw_craplgp.nrdconta, --> Numero da conta do cooperaro
                                     pr_dstpctdb     => 'CC',                --> Tipo de conta 
                                     pr_json         => vr_gps,             --> Json a ser incrementado
                                     pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                                     pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    ----> TRANSACTION
    vr_gps.put('Trxn_Id'             , to_char(pr_idanalis));    
    vr_gps.put('Trxn_ScheduledDate'  , '');
    vr_gps.put('Trxn_ScheduledTime'  , '');
    vr_gps.put('Trxn_PreferenceLevel', '');
    vr_gps.put('Trxn_MovementDate'   , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_gps.put('Trxn_Scheduled'      , '0');
    vr_gps.put('Trxn_Channel'        , to_char(rw_fraude.cdcanal_operacao));
    vr_gps.put('Trxn_Date'           , to_char(SYSDATE,vr_dsformat_dthora));
    vr_gps.put('Trxn_Value'          , fn_format_number('Trxn_Value',rw_craplgp.vlrtotal));
    vr_gps.put('Trxn_History'        , '');
    
    vr_lindigit := NULL;
    cxon0014.pc_calc_lindig_fatura (pr_cdbarras => rw_craplgp.cdbarras, 
                                    pr_lindigit => vr_lindigit);
                               
    vr_gps.put('BillPayment_Sequence_ID'   , vr_lindigit);
    vr_gps.put('BillPayment_Bar_Code', rw_craplgp.cdbarras); 
    
    BEGIN
      vr_dtapurac := to_date(lpad(rw_craplgp.mmaacomp,6,0),'MMRRRR');     
    EXCEPTION  
      when others then
          vr_dtapurac := null;
    END;
    
    vr_gps.put('BillPayment_Reference_Date', to_char(vr_dtapurac,vr_dsformat_dthora) ); 
    vr_gps.put('BillPayment_Authentication', to_char(rw_craplgp.nrautdoc)); 
    vr_gps.put('BillPayment_Consorcy_ID'   , '270-5');
    vr_gps.put('BillPayment_Consorcy_Desc' , 'GPS');
    
    vr_gps.put('Token_ID'            , rw_fraude.dstoken);
    vr_gps.put('Tracking_IP'         , rw_fraude.iptransacao);
    vr_gps.put('Mobile_Device_ID'    , to_char(rw_fraude.iddispositivo));
    vr_gps.put('Trxn_NLS_Start_Date' , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_gps.put('Trxn_NLS_End_Date'   , to_char(pr_dhlimana,vr_dsformat_dthora));
    
    
    --> Campos obrigatorios
    vr_gps.put('Trxn_MessageCode'    , '0');
    vr_gps.put('Trxn_ControlNumber'  , '0');
    vr_gps.put('CDT_Acct_Bank'       , '0');
    vr_gps.put('CDT_Acct_Type'       , '0');
    vr_gps.put('CDT_Acct_Number'     , '0');  
    vr_gps.put('CDT_Hldr_Type'       , '0');
    vr_gps.put('CDT_Hldr_Name'       , '0');
    vr_gps.put('CDT_Hldr_Document'   , '0');
    vr_gps.put('Trxn_Purpose'        , '0');

    
    vr_gps.print();
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarGPSParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_gps
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio da GPS para analise: '||SQLERRM;
      
  END pc_enviar_gps_analise;
  

  --> Procedure para envio da GPS para analise de fraude
  PROCEDURE pc_enviar_agend_gps_analise (pr_idanalis     IN INTEGER,
                                         pr_Fingerprint OUT VARCHAR2, 
                                         pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                         pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic    OUT INTEGER,
                                         pr_dscritic    OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_enviar_agend_gps_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Teobaldo Jamunda (AMcom)
      Data     : Abril/2018                     Ultima atualizacao: 06/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio dos agendamentos de GPS
                  para analise de fraude   (PRJ381 - Analise de Fraude)
                  
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.idanalise_fraude,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao, 
             fra.iddispositivo,
             fra.cdcanal_operacao,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do agendamento de GPS
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,
             lau.nrdconta,
             lau.dscodbar,
             lau.idlancto,
             lau.cdtiptra,
             SUBSTR(lau.dscodbar,16,4) cdempcon,
             SUBSTR(lau.dscodbar, 2,1) cdsegmto,
             con.cdempcon ||'-'||con.cdsegmto cdempcon_2,
             lau.dslindig,
             con.nmextcon,
             con.tparrecd,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.dscedent,
             lau.idlancto nrautdoc,
             (select lgp.mmaacomp
                from craplgp lgp
               where lgp.cdcooper = lau.cdcooper
                 and lgp.nrctapag = lau.nrdconta
                 and lgp.nrseqagp = lau.nrseqagp
                 and rownum = 1
             ) mmaacomp
        FROM craplau lau,
             crapcon con      
       WHERE lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta
         AND lau.cdcooper = con.cdcooper(+)
         AND SUBSTR(lau.dscodbar,16,4) = con.cdempcon(+)
         AND SUBSTR(lau.dscodbar, 2,1) = con.cdsegmto(+);                
    rw_craplau cr_craplau%ROWTYPE;
        
    --> Buscar dados do titular
    CURSOR cr_crapttl (pr_cdcooper  crapttl.cdcooper%TYPE,
                       pr_nrdconta  crapttl.nrdconta%TYPE,
                       pr_idseqttl  crapttl.idseqttl%TYPE) IS
      SELECT ttl.nrcpfcgc,
             ttl.nmextttl,
             ttl.inpessoa
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;
    
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic_aux NUMBER;
    vr_dscritic_aux VARCHAR2(4000);
    vr_exc_erro     EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta     AYMA0001.typ_http_response_aymaru;
    vr_parametros   WRES0001.typ_tab_http_parametros;
    vr_gps          json := json();
    vr_code         VARCHAR2(10);
    vr_Message      VARCHAR2(1000);
    
    vr_qtsegret     NUMBER;
    vr_nmarqlog     VARCHAR2(500);
    vr_cdprogra     VARCHAR2(50) := 'pc_enviar_agend_gps_analise';
    vr_cdbandst     NUMBER;
    vr_dtapurac   date;
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    OPEN cr_craplau (pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplau INTO rw_craplau;
    
    IF cr_craplau%NOTFOUND THEN
      CLOSE cr_craplau;
      vr_dscritic := 'Não foi possivel localizar agendamento de GPS';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplau;
    END IF; 
   
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplau.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => rw_craplau.dtmvtopg    --> Data que sera efetivada a operacao agendada
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_gps.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    
    ----> ACCOUNT DEBIT
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craplau.cdcooper, --> Codigo da cooperativa
                             pr_nrdconta     => rw_craplau.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => 'CC',                --> Tipo de conta 
                             pr_json         => vr_gps,              --> Json a ser incrementado
                             pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                             pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    ---->  ACCOUNT CREDIT
    vr_gps.put('CDT_Acct_Bank'       , to_char(vr_cdbandst));
    
    ----> TRANSACTION
    vr_gps.put('Trxn_Id'             , to_char(pr_idanalis));
    vr_gps.put('Trxn_Channel'        , to_char(rw_fraude.cdcanal_operacao));
    
    vr_gps.put('Trxn_Date'           , to_char(SYSDATE,vr_dsformat_dthora));
    vr_gps.put('Trxn_Value'          , fn_format_number('Trxn_Value',rw_craplau.vllanaut));
    vr_gps.put('Trxn_History'        , rw_craplau.dscedent);
    vr_gps.put('Trxn_ScheduledDate'  , to_char(rw_craplau.dtmvtopg,vr_dsformat_data));
    vr_gps.put('Trxn_ScheduledTime'  , '');
    vr_gps.put('Trxn_PreferenceLevel', '');
    vr_gps.put('Trxn_MovementDate'   , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_gps.put('Trxn_Scheduled'      , '1');
   
    BEGIN
      vr_dtapurac := to_date(lpad(rw_craplau.mmaacomp,6,0),'MMRRRR');     
    EXCEPTION  
      when others then
          vr_dtapurac := null;
    END;
    
    vr_gps.put('BillPayment_Bar_Code'      , rw_craplau.dscodbar); 
    vr_gps.put('BillPayment_Sequence_ID'   , rw_craplau.dslindig); 
    vr_gps.put('BillPayment_Reference_Date', vr_dtapurac); 
    vr_gps.put('BillPayment_Authentication', to_char(rw_craplau.nrautdoc));    
    vr_gps.put('BillPayment_Consorcy_ID'   , '270-5');
    vr_gps.put('BillPayment_Consorcy_Desc' , nvl(rw_craplau.nmextcon,'GPS'));   
    vr_gps.put('Token_ID'            , rw_fraude.dstoken);  
    vr_gps.put('Tracking_IP'         , rw_fraude.iptransacao);  
    vr_gps.put('Mobile_Device_ID'    , to_char(rw_fraude.iddispositivo));  
    vr_gps.put('Trxn_NLS_Start_Date' , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_gps.put('Trxn_NLS_End_Date'   , to_char(pr_dhlimana,vr_dsformat_dthora));      
    vr_gps.print();
    
    --> Campos obrigatorios
    vr_gps.put('Trxn_MessageCode'    , '0');
    vr_gps.put('Trxn_ControlNumber'  , '0');
    vr_gps.put('CDT_Acct_Bank'       , '0');
    vr_gps.put('CDT_Acct_Type'       , '0');
    vr_gps.put('CDT_Acct_Number'     , '0');  
    vr_gps.put('CDT_Hldr_Type'       , '0');
    vr_gps.put('CDT_Hldr_Name'       , rw_craplau.dscedent);
    vr_gps.put('CDT_Hldr_Document'   , '0');
    vr_gps.put('Trxn_Purpose'        , '0');
              
              
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarGPSParaAnalise'
                                       ,pr_verbo => WRES0001.POST 
                                       ,pr_servico => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo => vr_gps
                                       ,pr_resposta => vr_resposta
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_cdcritic => vr_cdcritic); 
                                                 
    --> vr_resposta.conteudo.Print();     
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
        
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
        vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
        vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio do agendamento de GPS para analise: '||SQLERRM;
  END pc_enviar_agend_gps_analise;    
  
  
  --> Procedure para envio de titulo para analise de fraude
  PROCEDURE pc_enviar_convenio_analise(pr_idanalis    IN  INTEGER,
                                       pr_Fingerprint OUT VARCHAR2, 
                                       pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                       pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                       pr_cdcritic    OUT INTEGER,
                                       pr_dscritic    OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_enviar_convenio_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Teobaldo Jamunda (AMcom)
      Data     : Abril/2018.                   Ultima atualizacao: 17/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio de convenio para analise de fraude
                  (PRJ381 - Antifraude, Teobaldo J. - AMcom)
                  
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do lancamento
    CURSOR cr_craplft (pr_idanalis  craplft.idanafrd%TYPE,
                       pr_cdcooper  craplft.cdcooper%TYPE,
                       pr_nrdconta  craplft.nrdconta%TYPE) IS
      SELECT lft.cdcooper,
             lft.nrdconta,
             lft.cdbarras,
             lft.dtapurac,
             lft.nrcpfcgc,
             lft.cdempcon ||'-'|| lft.cdsegmto cdempcon,
             con.nmextcon,
             con.tparrecd,
             lft.vllanmto,
             lft.nrautdoc,
             nvl(TRIM(lcm.dscedent), pro.dscedent) dscedent
        FROM crappro pro,
             crapcon con,
             craplft lft,
             craplcm lcm      
       WHERE pro.nrseqaut = lft.nrautdoc
         AND pro.dtmvtolt = lft.dtmvtolt
         AND pro.cdcooper = lft.cdcooper
         AND pro.nrdconta = lft.nrdconta
         AND lft.cdcooper = con.cdcooper(+)
         AND lft.cdempcon = con.cdempcon(+)
         AND lft.cdsegmto = con.cdsegmto(+)
         AND pro.cdcooper = lcm.cdcooper
         AND pro.dtmvtolt = lcm.dtmvtolt
         AND pro.nrdconta = lcm.nrdconta
         AND pro.nrdocmto = lcm.nrdocmto         
         AND pro.vldocmto = lcm.vllanmto
         AND lft.idanafrd = pr_idanalis
         AND lft.cdcooper = pr_cdcooper
         AND lft.nrdconta = pr_nrdconta;                
    rw_craplft cr_craplft%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta     AYMA0001.typ_http_response_aymaru;
    vr_parametros   WRES0001.typ_tab_http_parametros;
    vr_convenio       json := json();
    vr_code         VARCHAR2(10);
    vr_Message      VARCHAR2(1000);
    vr_qtsegret     NUMBER;
    
    vr_nmarqlog     VARCHAR2(500);
    vr_cdprogra     VARCHAR2(50) := 'pc_enviar_convenio_analise';
    
    vr_lindigit     VARCHAR2(100);
    vr_cdbandst     NUMBER;
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
  
    OPEN cr_craplft( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplft INTO rw_craplft;
    
    IF cr_craplft%NOTFOUND THEN
      CLOSE cr_craplft;
      vr_dscritic := 'Não foi possivel localizar craplft';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplft;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplft.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => NULL                   --> Data que sera efetivada a operacao agendada
                                ,pr_cdcooper  => rw_fraude.cdcooper     --> Codigo da cooperativa, para uso do limite de operacao
                                ,pr_tplimite  => (CASE rw_craplft.tparrecd
                                                    WHEN 1 THEN 3 -- Sicredi
                                                    WHEN 2 THEN 4 -- Bancoob
                                                    WHEN 3 THEN 2 -- Cecred
                                                    ELSE 0
                                                  END )                 --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;
    
    vr_convenio.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    vr_convenio.put('Trxn_MessageCode'       , '0');
    vr_convenio.put('Trxn_ControlNumber'     , '0');    
    
    
    --> Carregar no objeto json os dados da conta (dados DBT e fone)
    pc_carregar_conta_json ( pr_cdcooper     => rw_craplft.cdcooper, --> Codigo da cooperativa
                             pr_nrdconta     => rw_craplft.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => 'CC',                --> Tipo de conta 
                             pr_json         => vr_convenio,         --> Json a ser incrementado
                             pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                             pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    
    ---->  ACCOUNT CREDIT
    vr_cdbandst:= to_number(SUBSTR(rw_craplft.cdbarras,01,03)); 
    vr_convenio.put('CDT_Acct_Bank'    , '0');
    vr_convenio.put('CDT_Acct_Branch'  , '0');   
    vr_convenio.put('CDT_Acct_Type'    , '0');   
    vr_convenio.put('CDT_Acct_Number'  , '0');
    vr_convenio.put('CDT_Hldr_Type'    , '0');
    vr_convenio.put('CDT_Hldr_Document', '0');
    vr_convenio.put('CDT_Hldr_Name'    , rw_craplft.dscedent);
    vr_convenio.put('Trxn_Purpose'     , '0');
    
   
    
    ----> TRANSACTION
    vr_convenio.put('Trxn_Id'                   , to_char(pr_idanalis));
    vr_convenio.put('Trxn_Channel'              , to_char(rw_fraude.cdcanal_operacao));
    vr_convenio.put('BillPayment_Bar_Code'      , rw_craplft.cdbarras);
    
    vr_lindigit := NULL;
    cxon0014.pc_calc_lindig_fatura (pr_cdbarras => rw_craplft.cdbarras, 
                                    pr_lindigit => vr_lindigit);
                                      
    vr_convenio.put('BillPayment_Sequence_ID'   , vr_lindigit);
    vr_convenio.put('BillPayment_Reference_Date', to_char(nvl(rw_craplft.dtapurac,trunc(SYSDATE)),vr_dsformat_data));
    vr_convenio.put('BillPayment_Authentication' , to_char(rw_craplft.nrautdoc));
    vr_convenio.put('BillPayment_Consorcy_ID'   , rw_craplft.cdempcon);  
    vr_convenio.put('BillPayment_Consorcy_Desc' , rw_craplft.nmextcon);
    vr_convenio.put('Trxn_Value'                , fn_format_number('Trxn_Value',rw_craplft.vllanmto));
    vr_convenio.put('Trxn_History'              , rw_craplft.dscedent);
    vr_convenio.put('Trxn_Date'                 , to_char(SYSDATE,vr_dsformat_dthora));
    vr_convenio.put('Trxn_ScheduledDate'        , '');
    vr_convenio.put('Trxn_ScheduledTime'        , '');
    vr_convenio.put('Trxn_PreferenceLevel'      , '');
    vr_convenio.put('Trxn_MovementDate'         , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_convenio.put('Trxn_Scheduled'            , '0');
    vr_convenio.put('Token_ID'                  , rw_fraude.dstoken);
    vr_convenio.put('Tracking_IP'               , rw_fraude.iptransacao);
    vr_convenio.put('Mobile_Device_ID'          , to_char(rw_fraude.iddispositivo));
    vr_convenio.put('Trxn_NLS_Start_Date'       , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_convenio.put('Trxn_NLS_End_Date'         , to_char(pr_dhlimana,vr_dsformat_dthora));
            
    -- vr_convenio.print();
      
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarConvenioParaAnalise'
                                       ,pr_verbo      => WRES0001.POST 
                                       ,pr_servico    => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo   => vr_convenio
                                       ,pr_resposta   => vr_resposta
                                       ,pr_dscritic   => vr_dscritic
                                       ,pr_cdcritic   => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio de Convenio para analise: '||SQLERRM;
      
  END pc_enviar_convenio_analise;  
  

  --> Procedure para envio de agendamento de pagamento de convenio para analise de fraude
  PROCEDURE pc_enviar_agend_conv_analise (pr_idanalis     IN INTEGER,
                                          pr_Fingerprint OUT VARCHAR2, 
                                          pr_dhdenvio    OUT TIMESTAMP,  --> Data hora do envio para a analise
                                          pr_dhlimana    OUT TIMESTAMP,  --> Data hora de limite de aguardo para a analise
                                          pr_cdcritic    OUT INTEGER,
                                          pr_dscritic    OUT VARCHAR2 )IS
  /* ..........................................................................
    
      Programa : pc_enviar_agend_conv_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Teobaldo Jamunda (AMcom)
      Data     : Abril/2018.                   Ultima atualizacao: 17/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Envio de agendamento de pagamento de convenio para analise de fraude
                  (PRJ381 - Antifraude, Teobaldo J. - AMcom)
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao,
             fra.iddispositivo,
             fra.dstoken
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do agendamento
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,
             lau.nrdconta,
             lau.dscodbar,
             lau.dslindig,
             lau.idlancto,
             lau.cdtiptra,
             SUBSTR(lau.dscodbar,16,4) cdempcon,
             SUBSTR(lau.dscodbar, 2,1) cdsegmto,
             con.cdempcon ||'-'||con.cdsegmto cdempcon_2,
             con.nmextcon,
             con.tparrecd,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.idlancto nrautdoc,
             lau.dscedent
        FROM craplau lau,
             crapcon con      
       WHERE lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta         
         AND lau.cdcooper = con.cdcooper(+)
         AND SUBSTR(lau.dscodbar,16,4) = con.cdempcon(+)
         AND SUBSTR(lau.dscodbar, 2,1) = con.cdsegmto(+);                
    rw_craplau cr_craplau%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    vr_cdcritic_aux  NUMBER;
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;    
    
    --> variaveis para comunicacao AYmaru
    vr_resposta      AYMA0001.typ_http_response_aymaru;
    vr_parametros    WRES0001.typ_tab_http_parametros;
    vr_convenio      json := json();
    vr_code          VARCHAR2(10);
    vr_Message       VARCHAR2(1000);
    vr_qtsegret      NUMBER;
    
    vr_nmarqlog      VARCHAR2(500);
    vr_cdprogra      VARCHAR2(50) := 'pc_enviar_agend_convenio_analise';
    vr_cdbandst      NUMBER;
    vr_dtapurac      DATE;
    
    
  BEGIN
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
  
    OPEN cr_craplau( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craplau INTO rw_craplau;
    
    IF cr_craplau%NOTFOUND THEN
      CLOSE cr_craplau;
      vr_dscritic := 'Não foi possivel localizar craplau';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplau;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craplau.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pr_dhdenvio := SYSTIMESTAMP;
        
    --> Retornar a data limite da analise
    pc_ret_data_limite_analise ( pr_cdoperac  => rw_fraude.cdoperacao   --> Codigo da operação
                                ,pr_tpoperac  => rw_fraude.tptransacao  --> Tipo de operacao 1 -online 2-agendamento
                                ,pr_dhoperac  => pr_dhdenvio            --> Data hora da operação      
                                ,pr_dtefeope  => rw_craplau.dtmvtopg    --> Data que sera efetivada a operacao agendada
                                ,pr_cdcooper  => rw_fraude.cdcooper     --> Codigo da cooperativa, para uso do limite de operacao
                                ,pr_tplimite  => (CASE rw_craplau.tparrecd
                                                    WHEN 1 THEN 3 -- Sicredi
                                                    WHEN 2 THEN 4 -- Bancoob
                                                    WHEN 3 THEN 2 -- Cecred
                                                    ELSE 0
                                                  END )                 --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao                                
                                ,pr_dhlimana  => pr_dhlimana            --> Retorna data hora limite da operacao
                                ,pr_qtsegret  => vr_qtsegret            --> Retorna tempo em segundo de retenção da analise
                                ,pr_dscritic  => vr_dscritic);
      
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    --> Incluir analise na fila  
    AFRA0002.pc_incluir_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                      pr_qtsegret => vr_qtsegret,                --> Tempo em segundos que irá aguardar na fila
                                      pr_cdcritic => vr_dscritic,
                                      pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;

    vr_convenio.put('Trxn_TransferIdentifier', fn_dsoperacao_fraude(rw_fraude.cdoperacao));
    
    --> Carregar no objeto json os dados da conta
    pc_carregar_conta_json ( pr_cdcooper     => rw_craplau.cdcooper, --> Codigo da cooperativa
                             pr_nrdconta     => rw_craplau.nrdconta, --> Numero da conta do cooperaro
                             pr_dstpctdb     => 'CC',                --> Tipo de conta 
                             pr_json         => vr_convenio,         --> Json a ser incrementado
                             pr_cdcritic     => vr_cdcritic,         --> Retorno de codigo de critica
                             pr_dscritic     => vr_dscritic);        --> Retorno de descricao de critica
   
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;
    
    --Determinar codigo barras    
    vr_cdbandst:= to_number(SUBSTR(rw_craplau.dscodbar,01,03));
    
    ---->  ACCOUNT CREDIT
    vr_convenio.put('Trxn_MessageCode'  , '0');    
   	vr_convenio.put('Trxn_ControlNumber', '0');    
    vr_convenio.put('CDT_Acct_Bank'    , '0');    
    vr_convenio.put('CDT_Acct_Branch'  , '0');   
    vr_convenio.put('CDT_Acct_Type'    , '0');   
    vr_convenio.put('CDT_Acct_Number'  , '0');
    vr_convenio.put('CDT_Hldr_Type'    , '0');
    vr_convenio.put('CDT_Hldr_Document', '0');
    vr_convenio.put('CDT_Hldr_Name'    , rw_craplau.dscedent);
    vr_convenio.put('Trxn_Purpose'     , '0');
    
    ----> TRANSACTION
    vr_convenio.put('Trxn_Id'                   , to_char(pr_idanalis));
    vr_convenio.put('Trxn_Channel'              , to_char(rw_fraude.cdcanal_operacao));
    vr_convenio.put('BillPayment_Bar_Code'      , rw_craplau.dscodbar);    
    vr_convenio.put('BillPayment_Sequence_ID'   , rw_craplau.dslindig);
--    vr_convenio.put('BillPayment_Reference_Date', vr_dtapurac);
    vr_convenio.put('BillPayment_Reference_Date', to_char(nvl(vr_dtapurac,trunc(SYSDATE)),vr_dsformat_data));
    vr_convenio.put('BillPayment_Authentication' , to_char(rw_craplau.nrautdoc));
    vr_convenio.put('BillPayment_Consorcy_ID'   , rw_craplau.cdempcon_2);
    vr_convenio.put('BillPayment_Consorcy_Desc' , rw_craplau.nmextcon);
    vr_convenio.put('Trxn_Value'                , fn_format_number('Trxn_Value',rw_craplau.vllanaut));
    vr_convenio.put('Trxn_History'              , rw_craplau.dscedent);
    vr_convenio.put('Trxn_Date'                 , to_char(SYSDATE,vr_dsformat_dthora));
    vr_convenio.put('Trxn_ScheduledDate'        , to_char(rw_craplau.dtmvtopg,vr_dsformat_data));
    vr_convenio.put('Trxn_ScheduledTime'        , '');
    vr_convenio.put('Trxn_PreferenceLevel'      , '');
    vr_convenio.put('Trxn_MovementDate'         , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_convenio.put('Trxn_Scheduled'            , '1');
    vr_convenio.put('Token_ID'                  , rw_fraude.dstoken);
    vr_convenio.put('Tracking_IP'               , rw_fraude.iptransacao);
    vr_convenio.put('Mobile_Device_ID'          , to_char(rw_fraude.iddispositivo));
    vr_convenio.put('Trxn_NLS_Start_Date'       , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_convenio.put('Trxn_NLS_End_Date'         , to_char(pr_dhlimana,vr_dsformat_dthora));

              
    AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Transacoes/AntiFraude/EnviarConvenioParaAnalise'
                                       ,pr_verbo  => WRES0001.POST 
                                       ,pr_servico    => 'ANTIFRAUDE'
                                       ,pr_parametros => vr_parametros
                                       ,pr_conteudo   => vr_convenio
                                       ,pr_resposta   => vr_resposta
                                       ,pr_dscritic   => vr_dscritic
                                       ,pr_cdcritic   => vr_cdcritic); 
    
    IF TRIM(vr_dscritic) IS NOT NULL OR      
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
      vr_code    := vr_resposta.conteudo.get('Code').to_char();
      vr_Message := vr_resposta.conteudo.get('Message').get_string();
        
      IF TRIM(vr_code) IS NOT NULL THEN
         vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
         vr_dscritic := REPLACE(vr_dscritic,CHR(14));
      END IF;

      RAISE vr_exc_erro;
    ELSE
      --> se retornou Sucesso, buscar fingerprint
      pr_Fingerprint  := vr_resposta.conteudo.get('Fingerprint').get_string();
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_cdcritic_aux,
                                        pr_dscritic => vr_dscritic_aux);
                
      IF TRIM(vr_dscritic_aux) IS NOT NULL OR
         nvl(vr_cdcritic_aux,0) > 0 THEN
                
        --> Se apresentar erro, deve apenas logar e garantir que seja aprovada a analise          
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch( pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - '||vr_cdprogra ||' --> ' || vr_dscritic_aux,
                                    pr_nmarqlog     => vr_nmarqlog);
             
      END IF;
      
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
      pr_dscritic := 'Não foi possivel realizar o envio de agendamento de Convenio para analise: '||SQLERRM;
      
  END pc_enviar_agend_conv_analise;
  
  
  --> Rotina responsavel em enviar as analises de fraude pendentes
  PROCEDURE pc_enviar_analise_fraude (pr_cdcritic  OUT INTEGER,
                                      pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_enviar_analise_fraude        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel em enviar as analises de fraude pendentes
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude pendente
    CURSOR cr_fraude IS
      SELECT fra.cdoperacao
        FROM tbgen_analise_fraude fra,
             tbgen_analise_fraude_param prm
       WHERE fra.cdstatus_analise  = 0  --> Aguardando envio
         AND fra.cdparecer_analise = 0 --> Pendente 
         GROUP BY fra.cdoperacao;
    rw_fraude cr_fraude%ROWTYPE;
    
    vr_cdprogra      VARCHAR2(100) := 'JBGEN_ENVFRA';
    vr_jobname       VARCHAR2(100);
    vr_nmarqlog      VARCHAR2(100);
    vr_idparale      INTEGER; 
    vr_dsplsql       VARCHAR2(1000);
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    vr_exc_erro      EXCEPTION;
    
  BEGIN
  
  
    vr_idparale := gene0001.fn_gera_id_paralelo;
    -- Se houver algum erro, vr_idparale será 0 (Zero)
    IF vr_idparale = 0 THEN
       -- Levantar exceção
       vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
      RAISE vr_exc_erro;
    END IF;
    
    --> listar operações pendentes
    FOR rw_fraude IN cr_fraude LOOP
    
      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := vr_cdprogra ||'_'|| rw_fraude.cdoperacao || '$'; 
      
      -- Cadastra o programa paralelo
      gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                ,pr_idprogra => LPAD(rw_fraude.cdoperacao,3,'0') --> Utiliza a cdoperacao como id programa
                                ,pr_des_erro => vr_dscritic);
    
      -- Testar saida com erro
      IF vr_dscritic is not null THEN
        -- Levantar exceçao
        raise vr_exc_erro;
      END IF;
      
      vr_dsplsql := 'declare 
                       vr_cdcritic integer; 
                       vr_dscritic varchar2(4000); 
                     begin 
                       AFRA0001.pc_enviar_analise_fraude (pr_cdoperac  => '||rw_fraude.cdoperacao||',
                                                          pr_idparale  => '||vr_idparale||',
                                                          pr_cdcritic  => vr_cdcritic,
                                                          pr_dscritic  => vr_dscritic ); 
                    end;';
      
      
      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper => 3            --> Código da cooperativa
                            ,pr_cdprogra => vr_cdprogra  --> Código do programa
                            ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                            ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                            ,pr_jobname  => vr_jobname   --> Nome randomico criado
                            ,pr_des_erro => vr_dscritic);    
    
      -- Testar saida com erro
      IF vr_dscritic is not null THEN 
        -- Levantar exceçao
        raise vr_exc_erro;
      END IF; 
    
    END LOOP;
    
    --Chama rotina de aguardo agora passando 0, para esperar
    --até que todos os Jobs tenha finalizado seu processamento
    gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                ,pr_qtdproce => 0
                                ,pr_des_erro => vr_dscritic);
                                  
    -- Testar saida com erro
    IF  vr_dscritic is not null THEN  
      -- Levantar exceçao
      raise vr_exc_erro;
    END IF;
    
    
  EXCEPTION  
    WHEN vr_exc_erro THEN
      ROLLBACK;
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra ||' --> ' || pr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);
      
    
    WHEN OTHERS THEN
    
      ROLLBACK;
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao enviar analise de fraude: '||SQLERRM;
      
      vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra ||' --> ' || pr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);     
  END pc_enviar_analise_fraude;
  
  --> Rotina responsavel em enviar as analises de fraude pendentes
  PROCEDURE pc_enviar_analise_fraude (pr_idanalis   IN INTEGER DEFAULT 0,
                                      pr_cdoperac   IN INTEGER,
                                      pr_idparale   IN NUMBER DEFAULT 0,
                                      pr_cdcritic  OUT INTEGER,
                                      pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_enviar_analise_fraude        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel em enviar as analises de fraude pendentes
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude pendente
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.cdcooper,
             fra.cdagenci,
             fra.nrdconta,
             fra.idanalise_fraude,
             fra.tptransacao,
             fra.cdproduto,
             fra.cdoperacao,
             decode(fra.tptransacao, 1, 0, 1) flgagend, /* 1=True, 0=False (indicador agendamento) */
             prm.flgemail_entrega
        FROM tbgen_analise_fraude fra,
             tbgen_analise_fraude_param prm
       WHERE fra.cdoperacao  = prm.cdoperacao
         AND fra.tptransacao = prm.tpoperacao
         AND fra.cdstatus_analise  = 0  --> Aguardando envio
         AND fra.cdparecer_analise = 0 --> Pendente 
         AND fra.cdoperacao        = decode(nvl(pr_cdoperac,0),0,fra.cdoperacao,pr_cdoperac) 
         AND fra.idanalise_fraude  = decode(pr_idanalis,0,fra.idanalise_fraude,pr_idanalis)
         ORDER BY fra.idanalise_fraude;
    rw_fraude cr_fraude%ROWTYPE;
    
    CURSOR cr_fraude_lock (pr_rowid ROWID) IS
      SELECT fra.cdoperacao, fra.dhenvio_analise
        FROM tbgen_analise_fraude fra
       WHERE fra.rowid = pr_rowid
         FOR UPDATE NOWAIT; 
    rw_fraude_lock cr_fraude_lock%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(4000);
    vr_dscritic_aux    VARCHAR2(4000);
    vr_flgerro         BOOLEAN;
    vr_exc_erro        EXCEPTION;    
    vr_exc_envio       EXCEPTION;    
    
    vr_dsfingerprint   tbgen_analise_fraude.dsfingerprint%TYPE;    
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nmarqlog        VARCHAR2(500);
    vr_cdprogra        VARCHAR2(50) := 'JBGEN_ENVIAR_AFRAUDE';
    
    vr_dhdenvio        TIMESTAMP;
    vr_dhlimana        TIMESTAMP;
    
  BEGIN
  
    -- Buscar analise de fraude pendente
    FOR rw_fraude IN cr_fraude LOOP
      BEGIN
      
        --> Lockar registro
        --> Garantir que não seja atualizado situação de confirmação
        --> antes de gerar status de envio
        BEGIN
          OPEN cr_fraude_lock(pr_rowid => rw_fraude.rowid );
          FETCH cr_fraude_lock INTO rw_fraude_lock;
          CLOSE cr_fraude_lock;
        EXCEPTION
          WHEN OTHERS THEN
            IF rw_fraude_lock.dhenvio_analise IS NOT NULL THEN
              continue;
            END IF;            
            vr_dscritic := 'Analise de fraude esta em uso.';
            RAISE vr_exc_envio;
        END;
      
        vr_dsfingerprint := NULL;
        vr_flgerro       := FALSE;        
        vr_dstransa := 'Envio de analise de fraude de ';
                
        --> Verificar se o produto for TED
        IF rw_fraude.cdproduto = 30 THEN
        
          --> Enviar TED Agendada
          IF rw_fraude.tptransacao = 2 THEN
            vr_dstransa := vr_dstransa || 'TED Agendada';
            pc_enviar_agend_ted_analise (pr_idanalis     => rw_fraude.idanalise_fraude,
                                         pr_Fingerprint  => vr_dsfingerprint, 
                                         pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                         pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic     => vr_cdcritic,
                                         pr_dscritic     => vr_dscritic); 
         
          ELSE
            -- Enviar TED Online
            vr_dstransa := vr_dstransa || 'TED Online';
            pc_enviar_ted_analise (pr_idanalis     => rw_fraude.idanalise_fraude,
                                   pr_Fingerprint  => vr_dsfingerprint, 
                                   pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                   pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                   pr_cdcritic     => vr_cdcritic,
                                   pr_dscritic     => vr_dscritic);
                                    
           
              
          END IF;
          
          IF nvl(vr_cdcritic,0) > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_envio; 
          END IF; 
          
        --> Verificar se o produto for Pagamento Convenio
        ELSIF rw_fraude.cdproduto = 43 THEN
        
          --> Enviar Convenio Agendada
          IF rw_fraude.tptransacao = 2 THEN
            vr_dstransa := vr_dstransa || 'Pagamento de Convenio Agendado';
            pc_enviar_agend_conv_analise ( pr_idanalis     => rw_fraude.idanalise_fraude,
                                           pr_Fingerprint  => vr_dsfingerprint, 
                                           pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                           pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                           pr_cdcritic     => vr_cdcritic,
                                           pr_dscritic     => vr_dscritic); 
         
          ELSE
            -- Enviar Convenio Online
            vr_dstransa := vr_dstransa || 'Pagamento de Convenio Online';
            pc_enviar_Convenio_analise ( pr_idanalis     => rw_fraude.idanalise_fraude,
                                         pr_Fingerprint  => vr_dsfingerprint, 
                                         pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                         pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic     => vr_cdcritic,
                                         pr_dscritic     => vr_dscritic);
                                    
          END IF; 
          IF nvl(vr_cdcritic,0) > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_envio; 
          END IF; 
        
        --> Verificar se o produto for Pagamento Titulo
        ELSIF rw_fraude.cdproduto = 44 THEN
        
          --> Enviar titulo Agendada
          IF rw_fraude.tptransacao = 2 THEN
            vr_dstransa := vr_dstransa || 'Pagamento de Titulo Agendado';
            pc_enviar_agend_titulo_analise ( pr_idanalis     => rw_fraude.idanalise_fraude,
                                             pr_Fingerprint  => vr_dsfingerprint, 
                                             pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                             pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                             pr_cdcritic     => vr_cdcritic,
                                             pr_dscritic     => vr_dscritic); 
         
          ELSE
            -- Enviar Titulo Online
            vr_dstransa := vr_dstransa || 'Pagamento de Titulo Online';
            pc_enviar_titulo_analise ( pr_idanalis     => rw_fraude.idanalise_fraude,
                                       pr_Fingerprint  => vr_dsfingerprint, 
                                       pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                       pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                       pr_cdcritic     => vr_cdcritic,
                                       pr_dscritic     => vr_dscritic);
                                    
          END IF; 
          IF nvl(vr_cdcritic,0) > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_envio; 
          END IF; 
          
        --> Verificar se o produto for Pagamento de tributos
        ELSIF rw_fraude.cdproduto IN (46,45) THEN
        
          --> Enviar Tributo Agendada
          IF rw_fraude.tptransacao = 2 THEN
            vr_dstransa := vr_dstransa || 'Pagamento de Tributo Agendado';
            pc_enviar_agend_Trib_analise ( pr_idanalis     => rw_fraude.idanalise_fraude,
                                           pr_Fingerprint  => vr_dsfingerprint, 
                                           pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                           pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                           pr_cdcritic     => vr_cdcritic,
                                           pr_dscritic     => vr_dscritic); 
         
          ELSE
            -- Enviar Tributo Online
            vr_dstransa := vr_dstransa || 'Pagamento de Tributo Online';
            pc_enviar_Tributo_analise (pr_idanalis     => rw_fraude.idanalise_fraude,
                                       pr_Fingerprint  => vr_dsfingerprint, 
                                       pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                       pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                       pr_cdcritic     => vr_cdcritic,
                                       pr_dscritic     => vr_dscritic);
                                    
           
                  
          END IF;
          
          IF nvl(vr_cdcritic,0) > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_envio; 
          END IF; 
          
        --> Verificar se o produto for GPS
        ELSIF rw_fraude.cdproduto = 47 THEN
        
          --> Enviar GPS Agendada
          IF rw_fraude.tptransacao = 2 THEN
            vr_dstransa := vr_dstransa || 'GPS Agendada';
            pc_enviar_agend_GPS_analise (pr_idanalis     => rw_fraude.idanalise_fraude,
                                         pr_Fingerprint  => vr_dsfingerprint, 
                                         pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                         pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                         pr_cdcritic     => vr_cdcritic,
                                         pr_dscritic     => vr_dscritic); 
         
          ELSE
            -- Enviar TED Online
            vr_dstransa := vr_dstransa || 'GPS Online';
            pc_enviar_GPS_analise (pr_idanalis     => rw_fraude.idanalise_fraude,
                                   pr_Fingerprint  => vr_dsfingerprint, 
                                   pr_dhdenvio     => vr_dhdenvio,                --> Data hora do envio para a analise
                                   pr_dhlimana     => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                                   pr_cdcritic     => vr_cdcritic,
                                   pr_dscritic     => vr_dscritic);
                                               
          END IF;
          
          IF nvl(vr_cdcritic,0) > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_envio; 
          END IF; 
          
        
        END IF;
            
        /*
        Situação da entrega :
            0-Aguardando envio
            1-Entrega confirmada midleware
            2-Erro na comunicação midleware 
            3-Entrega confirmada antifraude
            4-Erro na comunicação antifraude
        */
        
        pc_atualizar_analise ( pr_rowid => rw_fraude.rowid,
                               pr_dhdenvio => vr_dhdenvio,
                               pr_dhlimana => vr_dhlimana,                --> Data hora de limite de aguardo para a analise
                               pr_cdstatus => 1, --> Entrega confirmada midleware
                               pr_dsfinger => vr_dsfingerprint,
                               pr_dstransa => vr_dstransa,                --> Descrição da trasaçao para log                                            
                               pr_dscrilog => NULL,                       --> Em caso de status de erro, apresentar critica para log
                               pr_dscritic => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_envio;
        END IF;
      
      EXCEPTION
        WHEN vr_exc_envio THEN          
          vr_dscritic_aux := vr_dscritic;
          vr_flgerro := TRUE;
        WHEN OTHERS THEN
          vr_dscritic_aux := 'Erro ao enviar analise de fraude: '||SQLERRM;
          vr_flgerro := TRUE;
       END;
      
      IF vr_flgerro = TRUE THEN
        
        vr_dscritic := 'Falha envio ao Middleware: '||vr_dscritic_aux;

        --> Verificar se deve notificar area de segurança
        IF rw_fraude.flgemail_entrega = 1 THEN
          pc_notificar_seguranca (pr_idanalis   => rw_fraude.idanalise_fraude,
                                  pr_tpalerta   => 1, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                  pr_dscritic   => vr_dscritic_aux); 
        END IF;
        
        
        
        --> Atualizar analise e gerar log 
        pc_atualizar_analise ( pr_rowid => rw_fraude.rowid,
                               pr_dhdenvio => NULL,
                               pr_cdstatus => 2,                --> erro comuicação midleware
                               pr_cdparece => 1,                --> Aprovado
                               pr_cdcanal  => 1, -- Ayllos      --> Canal do parecer da analise  
                               pr_dstransa => vr_dstransa,      --> Descrição da trasaçao para log                                            
                               pr_dscrilog => vr_dscritic,      --> Em caso de status de erro, apresentar critica para log
                               pr_dscritic => vr_dscritic_aux);
        
        IF TRIM(vr_dscritic_aux) IS NOT NULL THEN
          vr_dscritic := vr_dscritic_aux;
          RAISE vr_exc_erro;
        END IF;
        
        --> Chamar rotina de aprovação da analise
        pc_aprovacao_analise (pr_idanalis  => rw_fraude.idanalise_fraude,    --> Indicador da analise de fraude
                              pr_cdcritic  => vr_cdcritic,
                              pr_dscritic  => vr_dscritic );
      
        IF TRIM(vr_dscritic) IS NOT NULL OR 
           nvl(vr_cdcritic,0) > 0 THEN          
           
          --> Caso não consiga aprovar, tentará reprovar a analise
          ROLLBACK; 
          
          --> Atualizar analise e gerar log 
          pc_atualizar_analise ( pr_rowid => rw_fraude.rowid,
                                 pr_dhdenvio => NULL,
                                 pr_cdstatus => 2,                --> erro comuicação midleware
                                 pr_cdparece => 2,                --> Reprovado
                                 pr_cdcanal  => 1, -- Ayllos      --> Canal do parecer da analise  
                                 pr_dstransa => vr_dstransa,      --> Descrição da trasaçao para log                                            
                                 pr_dscrilog => vr_dscritic,      --> Em caso de status de erro, apresentar critica para log
                                 pr_dscritic => vr_dscritic_aux);
          
          IF TRIM(vr_dscritic_aux) IS NOT NULL THEN
            vr_dscritic := vr_dscritic_aux;
            RAISE vr_exc_erro;
          END IF; 
          
          --> Excecutar rotinas referentes a reprovação da analise de fraude
          pc_reprovacao_analise (pr_idanalis  => rw_fraude.idanalise_fraude,    --> Indicador da analise de fraude
                                 pr_cdcritic  => vr_cdcritic,
                                 pr_dscritic  => vr_dscritic );
          
          IF TRIM(vr_dscritic) IS NOT NULL OR 
             nvl(vr_cdcritic,0) > 0 THEN    
            RAISE vr_exc_erro;
          END IF;
        ELSE
        
          --> Verificar se o produto for TED
            --> Notificar monitoração 
          --> pc_monitora_ted ( pr_idanalis => rw_fraude.idanalise_fraude); 
          BEGIN                                
            AFRA0004.pc_monitora_operacao (pr_cdcooper   => rw_fraude.cdcooper    -- Codigo da cooperativa
                                          ,pr_nrdconta   => rw_fraude.nrdconta    -- Numero da conta
                                          ,pr_idseqttl   => NULL                  -- Sequencial titular
                                          ,pr_vlrtotal   => NULL                  -- Valor total lancamento 
                                          ,pr_flgagend   => rw_fraude.flgagend    -- Flag agendado /* 1-True, 0-False */ 
                                          ,pr_idorigem   => rw_fraude.tptransacao -- Indicador de origem
                                          ,pr_cdoperacao => rw_fraude.cdoperacao  -- Codigo operacao (tbcc_dominio_campo-CDOPERAC_ANALISE_FRAUDE)
                                          ,pr_idanalis   => rw_fraude.idanalise_fraude  -- ID Analise Fraude
                                          ,pr_lgprowid   => NULL                  -- Rowid craplgp
                                          ,pr_cdcritic   => vr_cdcritic           -- Codigo da critica
                                          ,pr_dscritic   => vr_dscritic);         -- Descricao da critica
                                         
            vr_cdcritic := NULL;                         
            vr_dscritic := NULL;                         
          EXCEPTION
            WHEN OTHERS THEN 
                 vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
                 btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                            pr_ind_tipo_log => 2, --> erro tratado
                                            pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                               ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                            pr_nmarqlog     => vr_nmarqlog);
                                             
                 vr_cdcritic := NULL;                         
                 vr_dscritic := NULL;                         
          END;                             
                                         
        END IF; 
        
        
      END IF;
      
      --> Commit a cada registro, visto que apos enviar dados
      --> para o AYmaru não pode ser dado Rollback
      COMMIT;
      
    END LOOP;
    
    
    IF nvl(pr_idparale,0) > 0 THEN
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdoperac,3,'0')
                                  ,pr_des_erro => vr_dscritic);    
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra ||' --> ' || pr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);
      
      -- Encerrar o job do processamento paralelo
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdoperac,3,'0')
                                  ,pr_des_erro => vr_dscritic);
    
    WHEN OTHERS THEN
    
      ROLLBACK;
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao enviar analise de fraude: '||SQLERRM;
      
      vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra ||' --> ' || pr_dscritic,
                                 pr_nmarqlog     => vr_nmarqlog);
                                 
      -- Encerrar o job do processamento paralelo
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdoperac,3,'0')
                                  ,pr_des_erro => vr_dscritic);
      
  END pc_enviar_analise_fraude; 
  
  --> Gerar log de analise de fraude
  PROCEDURE pc_log_analise_fraude(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_nrdconta IN crapass.nrdconta%TYPE,
                                  pr_idorigem IN INTEGER,
                                  pr_dstransa IN VARCHAR2,
                                  pr_idanalis IN tbgen_analise_fraude.idanalise_fraude%TYPE,
                                  pr_campoalt IN typ_tab_campo_alt,
                                  pr_dscrilog IN VARCHAR2)IS
                                       
    vr_nrdrowid  ROWID;
    vr_dsorigem  VARCHAR2(30) := NULL;
    vr_idx       VARCHAR2(50);
    vr_dstransa  craplgm.dstransa%TYPE;
      
  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    
    BEGIN
    
      vr_dstransa := pr_dstransa ||'- ID '||pr_idanalis;
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dstransa := pr_dstransa;    
    END;
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => 1
                        ,pr_dscritic => substr(pr_dscrilog,1,245)
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => (CASE WHEN pr_dscrilog IS NULL THEN 1 ELSE 0 END)
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ' '
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
        
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'Indicador de analise de fraude',
                              pr_dsdadant => pr_idanalis,
                              pr_dsdadatu => pr_idanalis);
    
    --> verificar se contem campos alterados
    IF pr_campoalt.count > 0 THEN
          
      --> ler todos os campos
      vr_idx := pr_campoalt.first;
      WHILE vr_idx IS NOT NULL LOOP
              
        --> Verificar se valor foi modificado
        IF nvl(pr_campoalt(vr_idx).dsdadant,' ') <> 
           nvl(pr_campoalt(vr_idx).dsdadatu,' ') OR 
           --> Sempre apresentar estes 3 campos
           vr_idx IN ('cdparecer_analise','cdcanal_analise','flganalise_manual')
           THEN
           
          --> Gravar log 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => vr_idx,
                              pr_dsdadant => pr_campoalt(vr_idx).dsdadant,
                              pr_dsdadatu => pr_campoalt(vr_idx).dsdadatu);
        ELSIF vr_idx = 'cdoperacao' THEN
        
          --> Gravar log 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => vr_idx,
                                    pr_dsdadant => pr_campoalt(vr_idx).dsdadant ||' - '|| fn_dsoperacao_fraude(pr_campoalt(vr_idx).dsdadant),
                                    pr_dsdadatu => pr_campoalt(vr_idx).dsdadatu ||' - '|| fn_dsoperacao_fraude(pr_campoalt(vr_idx).dsdadatu));
        
        END IF;
             
        vr_idx := pr_campoalt.next(vr_idx);
      END LOOP;
            
    END IF;
  END pc_log_analise_fraude;
  
  --> Rotina para atualizar os dados da analise
  PROCEDURE pc_atualizar_analise ( pr_rowid     IN ROWID,
                                   pr_dhdenvio  IN tbgen_analise_fraude.dhenvio_analise%TYPE   DEFAULT NULL,
                                   pr_dhlimana  IN tbgen_analise_fraude.dhlimite_analise%TYPE  DEFAULT NULL,
                                   pr_dhretorn  IN tbgen_analise_fraude.dhretorno_analise%TYPE DEFAULT NULL,
                                   pr_cdstatus  IN tbgen_analise_fraude.cdstatus_analise%TYPE  DEFAULT NULL,
                                   pr_cdparece  IN tbgen_analise_fraude.cdparecer_analise%TYPE DEFAULT NULL,
                                   pr_dsfinger  IN tbgen_analise_fraude.dsfingerprint%TYPE     DEFAULT NULL,
                                   pr_cdcanal   IN NUMBER DEFAULT NULL,                        --> Canal origem da operação
                                   pr_flganama  IN NUMBER DEFAULT 0,                           --> Indicador analise efetuada manualmente
                                   pr_dstransa  IN VARCHAR2,                                   --> Descrição da trasaçao para log                                            
                                   pr_dscrilog  IN VARCHAR2,                                   --> Em caso de status de erro, apresentar critica para log
                                   pr_dscritic OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_atualizar_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para atualizar os dados da analise
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT  fra.dhenvio_analise  
             ,fra.dhlimite_analise 
             ,fra.dhretorno_analise
             ,fra.cdstatus_analise 
             ,fra.cdparecer_analise
             ,fra.dsfingerprint    
             ,fra.cdcanal_operacao
             ,fra.cdcooper
             ,fra.nrdconta  
             ,fra.idanalise_fraude  
             ,fra.cdcanal_analise  
             ,fra.flganalise_manual
             ,fra.cdoperacao
        FROM tbgen_analise_fraude fra
       WHERE fra.rowid =  pr_rowid;
    rw_fraude cr_fraude%ROWTYPE;
    
    
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
                      
    vr_tab_campo_alt typ_tab_campo_alt;
    
    -----------> SUBROTINA <-----------    
    
  BEGIN
    
    vr_tab_campo_alt.delete;
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    CLOSE cr_fraude;
    
    --> Armazenar valores antes da alteração
    vr_tab_campo_alt('dhenvio_analise'  ).dsdadant := to_char(rw_fraude.dhenvio_analise  ,'DD/MM/RRRR HH24:MI:SS');  
    vr_tab_campo_alt('dhlimite_analise' ).dsdadant := to_char(rw_fraude.dhlimite_analise ,'DD/MM/RRRR HH24:MI:SS');  
    vr_tab_campo_alt('dhretorno_analise').dsdadant := to_char(rw_fraude.dhretorno_analise,'DD/MM/RRRR HH24:MI:SS'); 
    vr_tab_campo_alt('cdstatus_analise' ).dsdadant := rw_fraude.cdstatus_analise;  
    vr_tab_campo_alt('cdparecer_analise').dsdadant := rw_fraude.cdparecer_analise; 
    vr_tab_campo_alt('dsfingerprint'    ).dsdadant := rw_fraude.dsfingerprint;
    vr_tab_campo_alt('cdcanal_analise'  ).dsdadant := rw_fraude.cdcanal_analise;
    vr_tab_campo_alt('flganalise_manual').dsdadant := rw_fraude.flganalise_manual;
    vr_tab_campo_alt('cdoperacao'       ).dsdadant := rw_fraude.cdoperacao;
    
  
    --> Atualizar tabela
    UPDATE tbgen_analise_fraude fra
       SET fra.dhenvio_analise   = decode(pr_dhdenvio,NULL,fra.dhenvio_analise  ,pr_dhdenvio),
           fra.dhlimite_analise  = decode(pr_dhlimana,NULL,fra.dhlimite_analise  ,pr_dhlimana),
           fra.dhretorno_analise = decode(pr_dhretorn,NULL,fra.dhretorno_analise,pr_dhretorn),
           fra.cdstatus_analise  = decode(pr_cdstatus,NULL,fra.cdstatus_analise ,pr_cdstatus),
           fra.cdparecer_analise = decode(pr_cdparece,NULL,fra.cdparecer_analise,pr_cdparece),
           fra.dsfingerprint     = decode(pr_dsfinger,NULL,fra.dsfingerprint    ,pr_dsfinger),
           fra.cdcanal_analise   = decode(pr_cdcanal ,NULL,fra.cdcanal_analise  ,pr_cdcanal ),
           fra.flganalise_manual = decode(pr_flganama,NULL,fra.flganalise_manual,pr_flganama)
     WHERE ROWID = pr_rowid
       RETURNING to_char(fra.dhenvio_analise,'DD/MM/RRRR HH24:MI:SS'),  
                 to_char(fra.dhlimite_analise ,'DD/MM/RRRR HH24:MI:SS'),                   
                 to_char(fra.dhretorno_analise,'DD/MM/RRRR HH24:MI:SS'),
                 fra.cdstatus_analise, 
                 fra.cdparecer_analise,
                 fra.dsfingerprint,
                 fra.cdcanal_analise,
                 flganalise_manual,
                 cdoperacao    
            INTO vr_tab_campo_alt('dhenvio_analise'  ).dsdadatu,
                 vr_tab_campo_alt('dhlimite_analise' ).dsdadatu,
                 vr_tab_campo_alt('dhretorno_analise').dsdadatu,
                 vr_tab_campo_alt('cdstatus_analise' ).dsdadatu,
                 vr_tab_campo_alt('cdparecer_analise').dsdadatu,
                 vr_tab_campo_alt('dsfingerprint'    ).dsdadatu,
                 vr_tab_campo_alt('cdcanal_analise'  ).dsdadatu,
                 vr_tab_campo_alt('flganalise_manual').dsdadatu,  
                 vr_tab_campo_alt('cdoperacao'       ).dsdadatu;
     
     IF SQL%ROWCOUNT = 0 THEN
       vr_dscritic := 'Registro de analise de fraude não encontrado.';
       RAISE vr_exc_erro;
     END IF;
     
     --> caso for analise manual pelo ayllos é devido a expiração do tempo
     IF pr_flganama = 1 AND pr_cdcanal = 1 THEN
       -- Gerar log especial na verlog
       vr_tab_campo_alt('Expirou Tempo Analise' ).dsdadatu := 'SIM';
     END IF;
     
     --> Gerar log de analise de fraude
     pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                           pr_nrdconta => rw_fraude.nrdconta,
                           pr_idorigem => rw_fraude.cdcanal_operacao,
                           pr_dstransa => pr_dstransa,
                           pr_idanalis => rw_fraude.idanalise_fraude,
                           pr_dscrilog => pr_dscrilog,
                           pr_campoalt => vr_tab_campo_alt);
     
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel atualizar analise de fraude: '||SQLERRM;
  END pc_atualizar_analise; 
  
  --> Extrair os dados do campo complementar
  PROCEDURE pc_extrair_dscomple (pr_dscomple      IN VARCHAR2,
                                 pr_tab_dscomple OUT typ_tab_campos) IS
  
    
    vr_idx VARCHAR2(40);
    vr_split_reg   gene0002.typ_split;
    vr_split_campo gene0002.typ_split;
  
  BEGIN
  
    pr_tab_dscomple.delete;  
  
    --> Quebrar registros para não pegar posicional
    vr_split_reg := gene0002.fn_quebra_string(pr_dscomple,'|');
      
    --> Varrer dados
    IF vr_split_reg.count > 0 THEN
      FOR i IN vr_split_reg.first..vr_split_reg.last LOOP
        vr_split_campo := NULL;
        vr_split_campo := gene0002.fn_quebra_string(vr_split_reg(i),';');
          
        IF vr_split_campo.count > 0 THEN
          
          pr_tab_dscomple(vr_split_campo(1)) := vr_split_campo(2);          
             
        END IF;
      END LOOP;
    END IF;
  END pc_extrair_dscomple;
  
  --> Rotina para retornar situação do parecer da analise de fraude
  PROCEDURE pc_ret_sit_analise_fraude (pr_idanafra  IN tbgen_analise_fraude.idanalise_fraude%TYPE,
                                       pr_cdparece OUT tbgen_analise_fraude.cdparecer_analise%TYPE,
                                       pr_dscritic OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_ret_sit_analise_fraude        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar situação do parecer  da analise de fraude
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT  fra.dhenvio_analise  
             ,fra.dhlimite_analise 
             ,fra.dhretorno_analise
             ,fra.cdstatus_analise 
             ,fra.cdparecer_analise
             ,fra.dsfingerprint    
             ,fra.cdcanal_operacao
             ,fra.cdcooper
             ,fra.nrdconta  
             ,fra.idanalise_fraude  
             ,fra.cdcanal_analise  
             ,fra.flganalise_manual
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude =  pr_idanafra;
    rw_fraude cr_fraude%ROWTYPE;
    
    
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
                      
    -----------> SUBROTINA <-----------    
    
  BEGIN
    
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    CLOSE cr_fraude;
    
    pr_cdparece := nvl(rw_fraude.cdparecer_analise,0);
    
     
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel consultar analise de fraude: '||SQLERRM;
  END pc_ret_sit_analise_fraude; 
  
  
  --> Excecutar rotinas referentes a aprovação da analise de fraude
  PROCEDURE pc_aprovacao_analise (pr_idanalis   IN INTEGER,    --> Indicador da analise de fraude
                                  pr_cdcritic  OUT INTEGER,
                                  pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_aprovacao_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 06/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Excecutar rotinas referentes a aprovação da analise de fraude
      
      Alteração : 06/04/2018 - Incluido tratamento para aprovacao de GPS
      
                  03/05/2019 - Incluído tratamento para TED Judicial.
                               Jose Dill (Mouts) - REQ39
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdproduto,
             fra.tptransacao,
             fra.cdcooper,
             fra.nrdconta,
             fra.dscomplementar,
             fra.dtmvtolt
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações da TED
    CURSOR cr_craptvl (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tvl.*
        FROM craptvl tvl,
             crapcop cop,
             crapass ass,
             crapban ban
       WHERE tvl.cdcooper = cop.cdcooper
         AND tvl.cdcooper = ass.cdcooper
         AND tvl.nrdconta = ass.nrdconta 
         AND tvl.cdbccrcb = ban.cdbccxlt
         AND tvl.idanafrd = pr_idanalis
         AND tvl.cdcooper = pr_cdcooper
         AND tvl.nrdconta = pr_nrdconta;         
    rw_craptvl cr_craptvl%ROWTYPE;
    
    --> Buscar informacoes GPS
    CURSOR cr_craplgp (pr_idanalis  craplgp.idanafrd%TYPE,
                       pr_cdcooper  craplgp.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT lgp.*,
             lgp.rowid lgprowid,
             ass.nrdconta,
             cop.cdagectl,
             cop.cdagesic
        FROM craplgp lgp,
             crapcop cop,
             crapass ass,
             crapban ban,
             tbcadast_pessoa pes
       WHERE lgp.cdcooper = cop.cdcooper
         AND lgp.cdcooper = ass.cdcooper
         AND lgp.nrctapag = ass.nrdconta 
         AND lgp.cdbccxlt = ban.cdbccxlt
         AND ass.nrcpfcgc = pes.nrcpfcgc
         AND lgp.idanafrd = pr_idanalis  
         AND lgp.cdcooper = pr_cdcooper  
         AND lgp.nrctapag = pr_nrdconta; 
    rw_craplgp cr_craplgp%ROWTYPE;
    
    --> Buscar informacao 
    CURSOR cr_crapaut (pr_cdcooper crapaut.cdcooper%TYPE,
                       pr_cdagenci crapaut.cdagenci%TYPE,
                       pr_nrdcaixa crapaut.nrdcaixa%TYPE,
                       pr_dtmvtolt crapaut.dtmvtolt%TYPE,
                       pr_nrsequen crapaut.nrsequen%TYPE) IS
      SELECT aut.rowid autrowid
        FROM crapaut aut
       WHERE aut.cdcooper = pr_cdcooper
         AND aut.cdagenci = pr_cdagenci
         AND aut.nrdcaixa = pr_nrdcaixa
         AND aut.dtmvtolt = pr_dtmvtolt
         AND aut.nrsequen = pr_nrsequen;    
    rw_crapaut cr_crapaut%ROWTYPE;
    
    -- Marcelo Telles Coelho - Projeto 475
    CURSOR cr_craptvl_OFSAA IS
      SELECT c.nrcontrole_if
        FROM craptvl a,
             tbspb_msg_enviada c
       WHERE a.idanafrd = pr_idanalis
         and a.idmsgenv = c.nrseq_mensagem;

    rw_craptvl_OFSAA cr_craptvl_OFSAA%ROWTYPE;
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    vr_tab_dscomple  typ_tab_campos;
    vr_tab_protocolo gene0006.typ_tab_protocolo;  
    vr_ind           PLS_INTEGER;
    vr_dsinform      crappro.dsinform##3%TYPE;
    vr_cdidtran      crappro.dsinform##3%TYPE;
    
    vr_dslitera      VARCHAR2(4000);
    vr_des_reto      VARCHAR2(4000);
    vr_dtdenvio      VARCHAR2(19);
    vr_raizcoop      VARCHAR2(255);
    vr_msgenvio      VARCHAR2(255);
    vr_msgreceb      VARCHAR2(255);
    vr_movarqto      VARCHAR2(255);
    vr_nmarqlog      VARCHAR2(255);
    vr_dstiparr      VARCHAR2(255);
    vr_mmaacomp      VARCHAR2(6);
    vr_cdidenti      VARCHAR2(20);
    
    
    --Variaveis Projeto 475
    vr_nrseq_mensagem      tbspb_msg_enviada_fase.nrseq_mensagem%type;
    vr_nrseq_mensagem_fase tbspb_msg_enviada_fase.nrseq_mensagem_fase%type;
    vr_cdtiptra      INTEGER; --REQ39

  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;

    --> TED
    IF rw_fraude.cdproduto = 30 THEN
      --> Online
      IF rw_fraude.tptransacao = 1 THEN

        --> Buscar registro craptvl
        OPEN cr_craptvl( pr_idanalis => pr_idanalis,
                         pr_cdcooper => rw_fraude.cdcooper,
                         pr_nrdconta => rw_fraude.nrdconta);
        FETCH cr_craptvl INTO rw_craptvl;
        
        IF cr_craptvl%NOTFOUND THEN
          CLOSE cr_craptvl;
          vr_dscritic := 'Não foi possivel localizar craptvl';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_craptvl;
        END IF;
        
        --> Alterar a situação do comprovante no IB/Mobile para ESTORNADO.  
        GENE0006.pc_busca_protocolo( pr_cdcooper  => rw_craptvl.cdcooper
                                    ,pr_dtmvtolt  => rw_craptvl.dtmvtolt
                                    ,pr_nrdconta  => rw_craptvl.nrdconta
                                    ,pr_cdtippro  => 9
                                    ,pr_cdorigem  => 7
                                    ,pr_nrdocmto  => rw_craptvl.nrdocmto 
                                    ,pr_protocolo => vr_tab_protocolo
                                    ,pr_cdcritic  => vr_cdcritic
                                    ,pr_dscritic  => vr_dscritic);
        
        vr_ind := vr_tab_protocolo.first; -- Vai para o primeiro registro
        IF vr_tab_protocolo.exists(vr_ind) THEN
          vr_dsinform := vr_tab_protocolo(vr_ind).dsinform##3;
          vr_cdidtran := gene0002.fn_busca_entrada(pr_postext     => 4,
                                                   pr_dstext      => vr_dsinform,
                                                   pr_delimitador => '#');
        
        END IF;
        
        /*REQ39 - Quando for uma TED Judicial, deve passar o tipo de transação como 22, caso contrário nulo.
                  Para validar se é uma TED Judicial, utilizar a codigo da finalidade (Finalidade TED Judicial = 100) */
        IF rw_craptvl.cdfinrcb = 100 THEN
           vr_cdtiptra := 22;
        ELSE
           vr_cdtiptra := null;
        END IF;
        --                        
        --> Enviar TED SPB
        -- Procedimento para envio do TED para o SPB
        
        SSPB0001.pc_proc_envia_tec_ted 
                              (pr_cdcooper =>  rw_craptvl.cdcooper       --> Cooperativa
                              ,pr_cdagenci =>  rw_craptvl.cdagenci       --> Cod. Agencia  
                              ,pr_nrdcaixa =>  900                       --> Numero  Caixa  
                              ,pr_cdoperad =>  rw_craptvl.cdoperad       --> Operador     
                              ,pr_titulari =>  (rw_craptvl.flgtitul = 1) --> Mesmo Titular.
                              ,pr_vldocmto =>  rw_craptvl.vldocrcb       --> Vlr. DOCMTO    
                              ,pr_nrctrlif =>  rw_craptvl.idopetrf       --> NumCtrlIF   
                              ,pr_nrdconta =>  rw_craptvl.nrdconta       --> Nro Conta
                              ,pr_cdbccxlt =>  rw_craptvl.cdbccrcb       --> Codigo Banco 
                              ,pr_cdagenbc =>  rw_craptvl.cdagercb       --> Cod Agencia 
                              ,pr_nrcctrcb =>  rw_craptvl.nrcctrcb       --> Nr.Ct.destino   
                              ,pr_cdfinrcb =>  rw_craptvl.cdfinrcb       --> Finalidade     
                              ,pr_tpdctadb =>  rw_craptvl.tpdctadb       --> Tp. conta deb 
                              ,pr_tpdctacr =>  rw_craptvl.tpdctacr       --> Tp conta cred  
                              ,pr_nmpesemi =>  rw_craptvl.nmpesemi       --> Nome Do titular 
                              ,pr_nmpesde1 =>  NULL                      --> Nome De 2TTT 
                              ,pr_cpfcgemi =>  rw_craptvl.cpfcgemi       --> CPF/CNPJ Do titular 
                              ,pr_cpfcgdel =>  0                         --> CPF sec TTL
                              ,pr_nmpesrcb =>  rw_craptvl.nmpesrcb       --> Nome Para 
                              ,pr_nmstlrcb =>  NULL                      --> Nome Para 2TTL
                              ,pr_cpfcgrcb =>  rw_craptvl.cpfcgrcb       --> CPF/CNPJ Para
                              ,pr_cpstlrcb =>  0                         --> CPF Para 2TTL
                              ,pr_tppesemi => (CASE rw_craptvl.flgpesdb 
                                                  WHEN 1 THEN 1 
                                                  ELSE 2
                                               END)                      --> Tp. pessoa De  
                              ,pr_tppesrec =>  (CASE rw_craptvl.flgpescr 
                                                  WHEN 1 THEN 1 
                                                  ELSE 2
                                               END)                      --> Tp. pessoa Para 
                              ,pr_flgctsal =>  FALSE                     --> CC Sal
                              ,pr_cdidtran =>  vr_cdidtran               --> tipo de transferencia
                              ,pr_cdorigem =>  rw_craptvl.idorigem       --> Cod. Origem    
                              ,pr_dtagendt =>  NULL                      --> data egendamento
                              ,pr_nrseqarq =>  0                         --> nr. seq arq.
                              ,pr_cdconven =>  0                         --> Cod. Convenio
                              ,pr_dshistor =>  rw_craptvl.dshistor       --> Dsc do Hist.  
                              ,pr_hrtransa =>  rw_craptvl.hrtransa       --> Hora transacao 
                              ,pr_cdispbif =>  rw_craptvl.nrispbif       --> ISPB Banco
                              ,pr_flvldhor =>  0 -- Nao valida           --> Flag para verificar se deve validar o horario permitido para TED
                              ,pr_cdtiptra =>  vr_cdtiptra               --> Tipo de transação /*REQ39*/
                              --------- SAIDA  --------
                              ,pr_cdcritic =>  vr_cdcritic               --> Codigo do erro
                              ,pr_dscritic =>  vr_dscritic );	           --> Descricao do erro
                              
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
        
      END IF;
    ELSIF rw_fraude.cdproduto = 43 THEN
      --> Para operaçãoes de 2 - Convenios e 6 Convenios Recorrentes
      NULL;  
      --> Para operaçãoes de 4 - Titulos
    ELSIF rw_fraude.cdproduto IN (44) THEN
      
      --> Online
      IF rw_fraude.tptransacao = 1 AND 
         --> e possui dados complementares
         TRIM(rw_fraude.dscomplementar) IS NOT NULL THEN
         
        vr_tab_dscomple.delete;
        --> Extrair os dados do campo complementar
        pc_extrair_dscomple (pr_dscomple     => rw_fraude.dscomplementar,
                             pr_tab_dscomple => vr_tab_dscomple);
                               
        --> Verificar se possui informacao e se é diferente de 0                     
        IF vr_tab_dscomple.exists('indpagto') AND 
           vr_tab_dscomple('indpagto') <> 0 THEN
             
          IF vr_tab_dscomple.exists('rowidcob') THEN
            --> Gravar solicitação de envio da jdda 
            PAGA0001.pc_solicita_crapdda (pr_cdcooper  => rw_fraude.cdcooper         -- Codigo Cooperativa
                                         ,pr_dtmvtolt  => rw_fraude.dtmvtolt  -- Data pagamento
                                         ,pr_cobrowid  => vr_tab_dscomple('rowidcob')         -- rowid de cobranca
                                         ,pr_dscritic  => vr_dscritic);       -- Descricao da critica

            IF TRIM(vr_dscritic) IS NOT NULL THEN
              --Nao mostrar erro para usuario., somente gerar log
              btch0001.pc_gera_log_batch(pr_cdcooper     => rw_fraude.cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || 'PAGA0001.pc_paga_titulo --> '
                                                          || 'erro ao gravar crapdda(crapcob.rowid = '||vr_tab_dscomple('rowidcob')||'): '
                                                          || vr_dscritic );

              vr_dscritic := null;
            END IF;
          END IF;
            
        END IF;
      END IF; --> FIM IF tptransacao = 1                     
      
      
    ELSIF rw_fraude.cdproduto IN (45,46) THEN
      --> Para operaçãoes de 45 - DARF/DAS e 46 - FGTS/DAE, não é necessario nenhuma ação adicional
      NULL;
    --> GPS
    ELSIF rw_fraude.cdproduto = 47 THEN
      --> Online
      IF rw_fraude.tptransacao = 1 THEN
        
        --> Buscar registro craptlg
        OPEN cr_craplgp( pr_idanalis => pr_idanalis,
                         pr_cdcooper => rw_fraude.cdcooper,
                         pr_nrdconta => rw_fraude.nrdconta);
        FETCH cr_craplgp INTO rw_craplgp;
        
        IF cr_craplgp%NOTFOUND THEN
          CLOSE cr_craplgp;
          vr_dscritic := 'Não foi possivel localizar craplgp';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_craplgp;
        END IF;
        
        vr_cdidenti := rw_craplgp.cdidenti;
        IF LENGTH(vr_cdidenti) = 0 THEN
          vr_cdidenti := CASE
                           WHEN LENGTH(rw_craplgp.cdbarras) > 0 THEN
                            SUBSTR(rw_craplgp.cdbarras, 24, 14)
                           ELSE
                            SUBSTR(rw_craplgp.dslindig, 26, 14)
                         END;
        END IF;

				vr_cdidenti := LPAD(vr_cdidenti, 14, '0');

        -- Mantido tratamento de dados obtidos de INS0002.pc_gps_arrecadar_sicredi
        vr_mmaacomp := lpad(rw_craplgp.mmaacomp,6,'0');

        vr_raizcoop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => rw_fraude.cdcooper
                                            ,pr_nmsubdir => NULL);
                                            
        vr_nmarqlog := vr_raizcoop || '/log/' || 'SICREDI_Soap_LogErros.log';

        -- Mantido o alterado por Renato Darosci - 05/09/2016 - SD 514294
        -- da INS0002.pc_gps_arrecadar_sicredi
        vr_msgenvio := vr_raizcoop || '/arq/' ||
                       'GPS.' ||   -- ENVIO ARRECADACAO
                       LPAD(vr_cdidenti,14,'0') || '.' ||
                       to_char(rw_craplgp.dtmvtolt, 'RRRRMMDD') || '.' ||
                       to_char(SYSTIMESTAMP, 'hh24miss.FF6') || '.' ||
                       'E.A.' ||
                       rw_craplgp.cdopecxa;
                       
        vr_msgreceb := vr_raizcoop || '/arq/' ||
                       'GPS.' ||   -- RECEBIMENTO ARRECADACAO
                       LPAD(vr_cdidenti,14,'0') || '.' ||
                       to_char(rw_craplgp.dtmvtolt, 'RRRRMMDD') || '.' ||
                       to_char(SYSTIMESTAMP, 'hh24miss.FF6') || '.' ||
                       'R.A.' ||
                       rw_craplgp.cdopecxa;

        vr_movarqto := vr_raizcoop || '/salvar/gps/';
        
        /* APESAR DE A TAG DataVencimento SIGNIFICAR  QUE DEVE SER INFORMADA
        A DATA DE VENCIMENTO DA GUIA GPS, O SICREDI UTILIZA ESSA TAG PARA
        A DATA DE PAGAMENTO DA GUIA GPS JUNTO A RECEITA FEDERAL. POR ISSO
        DEVE SER INFORMADA A DATA DO DIA NESSA TAG AO ENVIAR PARA SICREDI  */
        vr_dtdenvio := to_char(rw_craplgp.dtmvtolt,'YYYY-MM-DD') || 'T' || to_char(sysdate,'hh24:mi:ss');
        
        IF rw_craplgp.tpdpagto = 2 THEN -- 2-Sem Cod Barras
          vr_dstiparr := 'ELETRONICA';
        ELSE
          vr_dstiparr := 'GPS COM CODIGO DE BARRAS ELETRONICA';
        END IF;
        
        
         --> Buscar registro crapaut
        OPEN cr_crapaut( pr_cdcooper => rw_fraude.cdcooper,
                         pr_cdagenci => rw_craplgp.cdagenci,
                         pr_nrdcaixa => rw_craplgp.nrdcaixa,
                         pr_dtmvtolt => rw_craplgp.dtmvtolt,
                         pr_nrsequen => rw_craplgp.nrautdoc );
        FETCH cr_crapaut INTO rw_crapaut;
        
        IF cr_crapaut%NOTFOUND THEN
          CLOSE cr_crapaut;
          vr_dscritic := 'Não foi possivel localizar cr_crapaut';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapaut;
        END IF;
        
        
        INSS0002.pc_gps_enviar_pagamento (pr_cdcooper => rw_fraude.cdcooper   --> Cooperativa 
                                         ,pr_cdagenci => rw_craplgp.cdagenci     --> Cod. Agencia
                                         ,pr_nrdcaixa => rw_craplgp.nrdcaixa     --> Nr Caixa
                                         ,pr_cdoperad => rw_craplgp.cdopecxa     --> Operador
                                         ,pr_nrdconta => rw_craplgp.nrdconta     --> Nr Conta
                                         ,pr_idorigem => rw_fraude.tptransacao   --> Cod. Origem
                                         ,pr_cdagesic => rw_craplgp.cdagesic     --> Nr Agencia Sicredi
                                         ,pr_cdidenti => vr_cdidenti             --> Nr Identificador GPS
                                         ,pr_nmdatela => 'INTERNETBANK'          --> fixo
                                         ,pr_cddpagto => rw_craplgp.cddpagto     --> Cod pgto da GPS
                                         ,pr_dtdenvio => vr_dtdenvio             --> data de pagamento GPS para Sicredi  
                                         ,pr_cdbarras => rw_craplgp.cdbarras     --> Codigo de barras
                                         ,pr_dslindig => rw_craplgp.dslindig     --> Linha digitavel
                                         ,pr_vlrdinss => rw_craplgp.vlrdinss     --> Valor GPS
                                         ,pr_vlrouent => rw_craplgp.vlrouent     --> Valor Outros
                                         ,pr_vlrjuros => rw_craplgp.vlrjuros     --> Valor dos Juros
                                         ,pr_registro => rw_crapaut.autrowid     --> Rowid crapaut
                                         ,pr_nrautsic => rw_craplgp.nrautsic     --> Nr Autenticacao Pgto envio Sicredi
                                         ,pr_dstiparr => vr_dstiparr             --> Descricao tipo de pagamento/arrecadacao
                                         ,pr_lgprowid => rw_craplgp.lgprowid     --> Rowid craplgp
                                         ,pr_msgenvio => vr_msgenvio             --> msg envio arrecadacao (arquivo)
                                         ,pr_msgreceb => vr_msgreceb             --> msg recebimento arrecadacao (arquivo)
                                         ,pr_movarqto => vr_movarqto             --> 
                                         ,pr_nmarqlog => vr_nmarqlog             --> arquivo de log
                                         ,pr_mmaacomp => vr_mmaacomp             --> Mes e ano competencia pgto guia
                                         ---- SAIDA ----
                                         ,pr_cdcritic => vr_cdcritic             --> Codigo do erro
                                         ,pr_dscritic => vr_dscritic             --> Descricao do erro
                                         ,pr_dslitera => vr_dslitera 
                                         ,pr_des_reto => vr_des_reto);           --> Saida OK/NOK

        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 

      END IF;
    END IF;   
    
    -- Marcelo Telles Coelho - Projeto 475
    -- Buscar número de controle da instuição financeira
    OPEN cr_craptvl_OFSAA;
    FETCH cr_craptvl_OFSAA INTO rw_craptvl_OFSAA;

    IF cr_craptvl_OFSAA%NOTFOUND THEN
      CLOSE cr_craptvl_OFSAA;
    ELSE
      CLOSE cr_craptvl_OFSAA;
      --
      -- Fase 20 - controle mensagem SPB
      sspb0003.pc_grava_trace_spb(pr_cdfase                 => 20
                                 ,pr_nmmensagem             => 'Aprovada pelo OFSAA'
                                 ,pr_nrcontrole             => rw_craptvl_OFSAA.nrcontrole_if
                                 ,pr_nrcontrole_str_pag     => NULL
                                 ,pr_nrcontrole_dev_or      => NULL
                                 ,pr_dhmensagem             => sysdate
                                 ,pr_insituacao             => 'OK'
                                 ,pr_dsxml_mensagem         => null
                                 ,pr_dsxml_completo         => null
                                 ,pr_nrseq_mensagem_xml     => null
                                 ,pr_nrdconta               => rw_craplgp.nrdconta
                                 ,pr_cdcooper               => rw_fraude.cdcooper
                                 ,pr_cdproduto              => 30 -- TED
                                 ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                 ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                 ,pr_dscritic               => vr_dscritic
                                 ,pr_des_erro               => vr_des_erro);
      --
      -- Se ocorreu erro
      IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar Excecao
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Fim Projeto 475
    
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
      pr_dscritic := 'Não foi possivel realizar aprovação da analise de fraude: '||SQLERRM;
  END pc_aprovacao_analise; 
  
  --> Excecutar rotinas referentes a reprovação da analise de fraude
  PROCEDURE pc_reprovacao_analise (pr_idanalis   IN INTEGER,    --> Indicador da analise de fraude
                                   pr_cdcritic  OUT INTEGER,
                                   pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_reprovacao_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 09/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Excecutar rotinas referentes a reprovação da analise de fraude
      Alteração : 
        
      Alteração : 06/06/2017 - Ajustado para usar a data dtmvtocd para estornar a TED.
                               PRJ335- Analise de fraude(Odirlei-AMcom)
        
                  09/04/2018 - Inclusao de chamada para pc_estornar_gps_analise .
                               PRJ381 Analise de fraude (Teobaldo - AMcom)
                               
                  03/05/2019 - Incluído tratamento para TED Judicial.
                               Jose Dill (Mouts) - REQ39
                     
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdproduto,
             fra.tptransacao,
             fra.cdcooper,
             fra.nrdconta,
             fra.idanalise_fraude
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    --> Buscar informações da TED
    CURSOR cr_craptvl (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tvl.*
        FROM craptvl tvl,
             crapcop cop,
             crapass ass,
             crapban ban
       WHERE tvl.cdcooper = cop.cdcooper
         AND tvl.cdcooper = ass.cdcooper
         AND tvl.nrdconta = ass.nrdconta 
         AND tvl.cdbccrcb = ban.cdbccxlt
         AND tvl.idanafrd = pr_idanalis
         AND tvl.cdcooper = pr_cdcooper
         AND tvl.nrdconta = pr_nrdconta;         
    rw_craptvl cr_craptvl%ROWTYPE;


    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    --Variaveis Projeto 475
    vr_nrseq_mensagem      tbspb_msg_enviada_fase.nrseq_mensagem%type;
    vr_nrseq_mensagem_fase tbspb_msg_enviada_fase.nrseq_mensagem_fase%type;
    vr_nrseq_mensagem_xml  tbspb_msg_xml.nrseq_mensagem_xml%type;
    vr_cdtiptra      INTEGER; --REQ39
    
  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_fraude.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    
    --> TED
    IF rw_fraude.cdproduto = 30 THEN
    
      --> Rotina para estornar TED reprovada pela analise de fraude
      pc_estornar_ted_analise (pr_idanalis  => rw_fraude.idanalise_fraude, -->Id da análise de fraude
                               pr_dtmvtolt  => rw_crapdat.dtmvtocd,  --> Data do sistema
                               pr_inproces  => rw_crapdat.inproces,  --> Indicar de execução do processo batch
                               pr_cdcritic  => vr_cdcritic,  --> Retorno de critica
                               pr_dscritic  => vr_dscritic);          
        
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
        
    --> Convenio
    ELSIF rw_fraude.cdproduto = 43 THEN
    
      --> Rotina para estornar convenio reprovado pela analise de frude
      pc_estornar_convenio_analise (pr_idanalis  => rw_fraude.idanalise_fraude, --> Id da análise de fraude
                                    pr_dtmvtolt  => rw_crapdat.dtmvtocd,        --> Data do sistema
                                    pr_inproces  => rw_crapdat.inproces,        --> Indicar de execução do processo batch
                                    pr_cdcritic  => vr_cdcritic,                --> Retorno de critica
                                    pr_dscritic  => vr_dscritic);          
        
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;        
    
    --> Titulo
    ELSIF rw_fraude.cdproduto = 44 THEN
    
      --> Rotina para estornar titulo reprovada pela analise de frude
      pc_estornar_Titulo_analise ( pr_idanalis  => rw_fraude.idanalise_fraude, -->Id da análise de fraude
                                   pr_dtmvtolt  => rw_crapdat.dtmvtocd,        --> Data do sistema
                                   pr_inproces  => rw_crapdat.inproces,        --> Indicar de execução do processo batch
                                   pr_cdcritic  => vr_cdcritic,                --> Retorno de critica
                                   pr_dscritic  => vr_dscritic);          
        
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
    --> Tributos
    ELSIF rw_fraude.cdproduto IN(45,46) THEN
    
      --> Rotina para estornar Tributos reprovada pela analise de frude
      pc_estornar_Tributo_analise (pr_idanalis  => rw_fraude.idanalise_fraude, --> Id da análise de fraude
                                   pr_dtmvtolt  => rw_crapdat.dtmvtocd,        --> Data do sistema
                                   pr_inproces  => rw_crapdat.inproces,        --> Indicar de execução do processo batch
                                   pr_cdcritic  => vr_cdcritic,                --> Retorno de critica
                                   pr_dscritic  => vr_dscritic);          
        
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;  
    END IF;        
    
    
    --> GPS
    IF rw_fraude.cdproduto = 47 THEN
    
      --> Rotina para estornar TED reprovada pela analise de fraude
      pc_estornar_gps_analise (pr_idanalis  => rw_fraude.idanalise_fraude, --> Id da análise de fraude
                               pr_dtmvtolt  => rw_crapdat.dtmvtocd,        --> Data do sistema
                               pr_cdcritic  => vr_cdcritic,                --> Retorno de critica
                               pr_dscritic  => vr_dscritic);          
    END IF;
        
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> TED
    IF rw_fraude.cdproduto = 30 THEN
    -- Marcelo Telles Coelho - Projeto 475
    -- Buscar número de controle da instuição financeira
    OPEN cr_craptvl( pr_idanalis => pr_idanalis,
                     pr_cdcooper => rw_fraude.cdcooper,
                     pr_nrdconta => rw_fraude.nrdconta);
    FETCH cr_craptvl INTO rw_craptvl;

      IF cr_craptvl%NOTFOUND THEN
        CLOSE cr_craptvl;
      ELSE
        --
      CLOSE cr_craptvl;
        -- Fase 20 - controle mensagem SPB
        sspb0003.pc_grava_trace_spb(pr_cdfase                 => 20
                                   ,pr_nmmensagem             => 'Reprovada pelo OFSAA'
                                 ,pr_nrcontrole             => rw_craptvl.idopetrf
                                   ,pr_nrcontrole_str_pag     => NULL
                                   ,pr_nrcontrole_dev_or      => NULL
                                   ,pr_dhmensagem             => sysdate
                                   ,pr_insituacao             => 'NOK'
                                   ,pr_dsxml_mensagem         => null
                                   ,pr_dsxml_completo         => null
                                   ,pr_nrseq_mensagem_xml     => null
                                   ,pr_nrdconta               => rw_fraude.nrdconta
                                   ,pr_cdcooper               => rw_fraude.cdcooper
                                   ,pr_cdproduto              => 30 -- TED
                                   ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                   ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                   ,pr_dscritic               => vr_dscritic
                                   ,pr_des_erro               => vr_des_erro);
        --
        -- Se ocorreu erro
        IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levantar Excecao
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
        
        /*REQ39 - Quando for uma TED Judicial, deve passar o tipo de transação como 22, caso contrário nulo.
          Para validar se é uma TED Judicial, utilizar a codigo da finalidade (Finalidade TED Judicial = 100) */
        IF rw_craptvl.cdfinrcb = 100 THEN
           vr_cdtiptra := 22;
        ELSE
           vr_cdtiptra := null;
        END IF;
        
        -- Projeto 475 Sprint C2 - Jose Dill
        -- Procedimento para envio do TED para o SPB
        -- Neste caso será invocada prc somente para gerar o arquivo xml e não será enviado para o SPB    
        SSPB0001.pc_proc_envia_tec_ted 
                              (pr_cdcooper =>  rw_craptvl.cdcooper       --> Cooperativa
                              ,pr_cdagenci =>  rw_craptvl.cdagenci       --> Cod. Agencia  
                              ,pr_nrdcaixa =>  900                       --> Numero  Caixa  
                              ,pr_cdoperad =>  rw_craptvl.cdoperad       --> Operador     
                              ,pr_titulari =>  (rw_craptvl.flgtitul = 1) --> Mesmo Titular.
                              ,pr_vldocmto =>  rw_craptvl.vldocrcb       --> Vlr. DOCMTO    
                              ,pr_nrctrlif =>  rw_craptvl.idopetrf       --> NumCtrlIF   
                              ,pr_nrdconta =>  rw_craptvl.nrdconta       --> Nro Conta
                              ,pr_cdbccxlt =>  rw_craptvl.cdbccrcb       --> Codigo Banco 
                              ,pr_cdagenbc =>  rw_craptvl.cdagercb       --> Cod Agencia 
                              ,pr_nrcctrcb =>  rw_craptvl.nrcctrcb       --> Nr.Ct.destino   
                              ,pr_cdfinrcb =>  rw_craptvl.cdfinrcb       --> Finalidade     
                              ,pr_tpdctadb =>  rw_craptvl.tpdctadb       --> Tp. conta deb 
                              ,pr_tpdctacr =>  rw_craptvl.tpdctacr       --> Tp conta cred  
                              ,pr_nmpesemi =>  rw_craptvl.nmpesemi       --> Nome Do titular 
                              ,pr_nmpesde1 =>  NULL                      --> Nome De 2TTT 
                              ,pr_cpfcgemi =>  rw_craptvl.cpfcgemi       --> CPF/CNPJ Do titular 
                              ,pr_cpfcgdel =>  0                         --> CPF sec TTL
                              ,pr_nmpesrcb =>  rw_craptvl.nmpesrcb       --> Nome Para 
                              ,pr_nmstlrcb =>  NULL                      --> Nome Para 2TTL
                              ,pr_cpfcgrcb =>  rw_craptvl.cpfcgrcb       --> CPF/CNPJ Para
                              ,pr_cpstlrcb =>  0                         --> CPF Para 2TTL
                              ,pr_tppesemi => (CASE rw_craptvl.flgpesdb 
                                                  WHEN 1 THEN 1 
                                                  ELSE 2
                                               END)                      --> Tp. pessoa De  
                              ,pr_tppesrec =>  (CASE rw_craptvl.flgpescr 
                                                  WHEN 1 THEN 1 
                                                  ELSE 2
                                               END)                      --> Tp. pessoa Para 
                              ,pr_flgctsal =>  FALSE                     --> CC Sal
                              ,pr_cdidtran =>  ''                        --> tipo de transferencia
                              ,pr_cdorigem =>  rw_craptvl.idorigem       --> Cod. Origem    
                              ,pr_dtagendt =>  NULL                      --> data egendamento
                              ,pr_nrseqarq =>  0                         --> nr. seq arq.
                              ,pr_cdconven =>  0                         --> Cod. Convenio
                              ,pr_dshistor =>  rw_craptvl.dshistor       --> Dsc do Hist.  
                              ,pr_hrtransa =>  rw_craptvl.hrtransa       --> Hora transacao 
                              ,pr_cdispbif =>  rw_craptvl.nrispbif       --> ISPB Banco
                              ,pr_flvldhor =>  0 -- Nao valida           --> Flag para verificar se deve validar o horario permitido para TED
                              ,pr_inenvio  =>  0 -- Não envia SPB        --> Flag para indicar se envia TEC/TED para SBP   
                              ,pr_cdtiptra =>  vr_cdtiptra               --> Tipo de transação /*REQ39*/                       
                              --------- SAIDA  --------
                              ,pr_cdcritic =>  vr_cdcritic               --> Codigo do erro
                              ,pr_dscritic =>  vr_dscritic );	           --> Descricao do erro

    IF nvl(vr_cdcritic,0) <> 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Fim Projeto 475
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
      pr_dscritic := 'Não foi possivel realizar reprovação da analise de fraude: '||SQLERRM;
  END pc_reprovacao_analise; 
  
  --> Rotina para Inclusao do registro de analise de fraude
  PROCEDURE pc_criar_analise_antifraude (pr_cdcooper    IN tbgen_analise_fraude.cdcooper%TYPE,    --> Cooperativa da transação 
                                        pr_cdagenci    IN tbgen_analise_fraude.cdagenci%TYPE,    --> PA da transanção 
                                        pr_nrdconta    IN tbgen_analise_fraude.nrdconta%TYPE,    --> Número da conta da transação 
                                        pr_cdcanal     IN tbgen_analise_fraude.cdcanal_operacao%TYPE,     --> Código da origem fk com a tabela tbgen_canal_entrada 
                                        pr_iptransacao IN tbgen_analise_fraude.iptransacao%TYPE, --> IP da transação 
                                        pr_dtmvtolt    IN tbgen_analise_fraude.dtmvtolt%TYPE,    --> Data da movimentação do sistema 
                                        pr_cdproduto   IN tbgen_analise_fraude.cdproduto%TYPE,   --> Código do produto fk com a tabela tbcc_produto 
                                        pr_cdoperacao  IN tbgen_analise_fraude.cdoperacao%TYPE,  --> Codigo de operacao de conta corrente
                                        pr_dstransacao IN tbgen_analise_fraude.dstransacao%TYPE, --> Descrição da transação 
                                        pr_tptransacao IN tbgen_analise_fraude.tptransacao%TYPE, --> Tipo de transação (1-online/ 2-agendada)                                         
                                        pr_iddispositivo IN VARCHAR2 DEFAULT NULL,               --> identificador dispositivo                                        
                                        pr_dstoken     IN VARCHAR2 DEFAULT NULL,                 --> Token de acesso
                                        pr_idanalise_fraude OUT tbgen_analise_fraude.idanalise_fraude%TYPE, --> identificador único da transação  
                                        pr_dscritic   OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_Criar_Analise_Antifraude        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 05/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para Inclusao do registro de analise de fraude
      Alteração : 03/04/2018 - Inclusão de novo parâmetro que possibilite 
                               armazenar o ID do dispositivo (Teobaldo J)
                  04/04/2018 - Inclusao de verificacao para decidir se deve 
                               criar Analise de Fraude
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    vr_criar_analise Number;
    
  BEGIN
     
    --> Verifica se deve criar analise para codigo e tipo de operacao (transacao)
    vr_criar_analise := fn_envia_analise(pr_cdoperacao, pr_tptransacao); 
    IF vr_criar_analise > 0 THEN  
  
      --> inserir registro
      INSERT INTO tbgen_analise_fraude
                  (cdcanal_operacao
                  ,dstransacao
                  ,iptransacao
                  ,dhinicio_analise 
                  ,dtmvtolt
                  ,dhlimite_analise 
                  ,cdstatus_analise
                  ,cdparecer_analise
                  ,cdproduto
                  ,cdcooper
                  ,cdagenci
                  ,nrdconta
                  ,tptransacao
                  ,cdoperacao
                  ,iddispositivo
                  ,dstoken) 
           VALUES( pr_cdcanal       --> cdcanal
                  ,pr_dstransacao   --> dstransacao
                  ,pr_iptransacao   --> iptransacao
                  ,SYSTIMESTAMP     --> dhinicio_analise 
                  ,pr_dtmvtolt      --> dtmvtolt
                  ,NULL             --> dhlimite_analise
                  ,0 --> Aguardando envio --> cdstatus_analise
                  ,0 --> Pendente         --> cdparecer_analise
                  ,pr_cdproduto     --> cdproduto
                  ,pr_cdcooper      --> cdcooper
                  ,pr_cdagenci      --> cdagenci
                  ,pr_nrdconta      --> nrdconta
                  ,pr_tptransacao   --> tptransacao
                  ,pr_cdoperacao    --> cdoperacao
                  ,TRIM(pr_iddispositivo) --> iddispositivo
                  ,TRIM(pr_dstoken)       --> dstoken
                  )RETURNING idanalise_fraude INTO pr_idanalise_fraude ;
    END IF;   
     
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel criar analise de fraude: '||SQLERRM;

  END pc_criar_analise_antifraude;
  
  
  --> Rotina responsavel por registrar o parecer de retorno da análise do sistema antifraude
  PROCEDURE pc_reg_reto_analise_antifraude(pr_idanalis    IN  NUMBER,       --> Id Unico da transação 
                                           pr_cdparece    IN  NUMBER,       --> Parecer da análise antifraude 
                                                                               --> 1 - Aprovada
                                                                               --> 2 - Reprovada
                                           pr_flganama   IN  NUMBER,        --> Indentificador de analise manual 
                                           pr_cdcanal    IN  NUMBER,        --> Canal origem da operação
                                           pr_fingerpr   IN  VARCHAR2,      --> Identifica a comunicação partiu do antifraude 
                                           pr_cdcritic   OUT  NUMBER,       --> Código da Crítica 
                                           pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica 
                                           pr_dsdetcri   OUT VARCHAR2) IS   --> Detalhe da critica    
  /* ..........................................................................
    
      Programa : pc_reg_reto_analise_antifraude        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por registrar o parecer de retorno da análise do sistema antifraude
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.idanalise_fraude,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.tptransacao,
             fra.dhenvio_analise,
             fra.dhlimite_analise,
             fra.dhretorno_analise,
             fra.cdstatus_analise,
             fra.cdcanal_analise,
             fra.cdproduto,
             fra.cdoperacao,
             fra.flganalise_manual,
             decode(fra.tptransacao, 1, 0, 1) flgagend, /* 1=True, 0=False (indicador agendamento) */
             prm.flgemail_retorno
        FROM tbgen_analise_fraude fra,
             tbgen_analise_fraude_param prm
       WHERE fra.cdoperacao  = prm.cdoperacao
         AND fra.tptransacao = prm.tpoperacao
         AND fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_dscritic_aux VARCHAR2(4000);
    vr_dsdetcri VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    vr_exc_apro EXCEPTION;    
    vr_exc_repro EXCEPTION;    
    
    vr_dstransa craplgm.dstransa%TYPE;  
    vr_campoalt typ_tab_campo_alt;
    vr_nmarqlog VARCHAR2(200);
    
    vr_cdprogra   VARCHAR2(50) := 'pc_reg_reto_analise_antifraude';

    
    ----------> SUB-ROTINAS <----------
    --> Tratar erro na aprovação
    PROCEDURE pc_tratar_erro_aprovacao IS
    BEGIN
        --> Verificar se deve notificar area de segurança
        IF rw_fraude.flgemail_retorno = 1 THEN
          pc_notificar_seguranca (pr_idanalis   => pr_idanalis,
                                  pr_tpalerta   => 2, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                  pr_dsalerta   => vr_dscritic,
                                  pr_dscritic   => vr_dscritic_aux); 
        END IF;

        vr_dscritic_aux := NULL;
        
        pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                              pr_nrdconta => rw_fraude.nrdconta,
                              pr_idorigem => pr_cdcanal,
                              pr_dstransa => vr_dstransa,
                              pr_idanalis => rw_fraude.idanalise_fraude,
                              pr_dscrilog => 'Falha ao realizar aprovacao analise, AFRA0001.pc_reg_reto_analise_antifraude: '||vr_dsdetcri,
                              pr_campoalt => vr_campoalt);
          
         --> Atualizar analise e gerar log 
        pc_atualizar_analise ( pr_rowid => rw_fraude.rowid,
                               pr_dhdenvio => NULL,
                               pr_cdstatus => NULL,                --> erro comuicação midleware
                               pr_cdparece => 2,                --> Reprovado
                               pr_cdcanal  => 1, -- Ayllos      --> Canal do parecer da analise  
                               pr_dstransa => vr_dstransa,      --> Descrição da trasaçao para log                                            
                               pr_dscrilog => vr_dscritic,      --> Em caso de status de erro, apresentar critica para log
                               pr_dscritic => vr_dscritic_aux);
         
        IF TRIM(vr_dscritic_aux) IS NOT NULL THEN
            vr_dscritic := vr_dscritic_aux;
            ROLLBACK;
            RAISE vr_exc_erro;
        END IF;

        --> Excecutar rotinas referentes a reprovação da analise de fraude
        pc_reprovacao_analise (pr_idanalis  => rw_fraude.idanalise_fraude,    --> Indicador da analise de fraude
                               pr_cdcritic  => vr_cdcritic,
                               pr_dscritic  => vr_dscritic_aux );
             
        IF TRIM(vr_dscritic) IS NOT NULL OR 
           nvl(vr_cdcritic,0) > 0 THEN    
           vr_dscritic := vr_dscritic_aux;
           ROLLBACK;
           RAISE vr_exc_erro;
        END IF;
        
        COMMIT;
    
    END pc_tratar_erro_aprovacao;
    
    --> Tratar erro na reprovação    
    PROCEDURE pc_tratar_erro_reprovacao IS
    BEGIN
        --> Verificar se deve notificar area de segurança
        IF rw_fraude.flgemail_retorno = 1 THEN
          pc_notificar_seguranca (pr_idanalis   => pr_idanalis,
                                  pr_tpalerta   => 2, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                  pr_dsalerta   => vr_dscritic,
                                  pr_dscritic   => vr_dscritic_aux); 
        END IF;

        vr_dscritic_aux := NULL;
        
        pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                              pr_nrdconta => rw_fraude.nrdconta,
                              pr_idorigem => pr_cdcanal,
                              pr_dstransa => vr_dstransa,
                              pr_idanalis => rw_fraude.idanalise_fraude,
                              pr_dscrilog => 'Falha ao reprovar/estornar analise AFRA0001.pc_reg_reto_analise_antifraude: '||vr_dsdetcri,
                              pr_campoalt => vr_campoalt);
          
         --> Atualizar analise e gerar log 
        pc_atualizar_analise ( pr_rowid => rw_fraude.rowid,
                               pr_dhdenvio => NULL,
                               pr_cdstatus => NULL,             --> erro comuicação midleware
                               pr_cdparece => 1,                --> Aprovado
                               pr_cdcanal  => 1, -- Ayllos      --> Canal do parecer da analise  
                               pr_dstransa => vr_dstransa,      --> Descrição da trasaçao para log                                            
                               pr_dscrilog => vr_dscritic,      --> Em caso de status de erro, apresentar critica para log
                               pr_dscritic => vr_dscritic_aux);
         
        IF TRIM(vr_dscritic_aux) IS NOT NULL THEN
            vr_dscritic := vr_dscritic_aux;
            ROLLBACK;
            RAISE vr_exc_erro;
        END IF;

        --> Excecutar rotinas referentes a reprovação da analise de fraude
        pc_aprovacao_analise (pr_idanalis  => rw_fraude.idanalise_fraude,    --> Indicador da analise de fraude
                              pr_cdcritic  => vr_cdcritic,
                              pr_dscritic  => vr_dscritic_aux );
             
        IF TRIM(vr_dscritic) IS NOT NULL OR 
           nvl(vr_cdcritic,0) > 0 THEN    
           vr_dscritic := vr_dscritic_aux;
           ROLLBACK;
           RAISE vr_exc_erro;
        END IF;
        
        COMMIT;
    
    END pc_tratar_erro_reprovacao;
    
    --> Tratar erro caso seja requisição da fila exception
    PROCEDURE pc_tratar_erro_fila_excep(pr_dscritic IN VARCHAR2) IS
    
    BEGIN
    
      IF pr_cdcanal = 1 AND   
         pr_fingerpr = 'NOFINGERPRINT' AND   
         pr_flganama = 1  THEN

        --> Armazenar valores antes da alteração
        vr_campoalt('dhenvio_analise'  ).dsdadant := to_char(rw_fraude.dhenvio_analise  ,'DD/MM/RRRR HH24:MI:SS');  
        vr_campoalt('dhlimite_analise' ).dsdadant := to_char(rw_fraude.dhlimite_analise ,'DD/MM/RRRR HH24:MI:SS');  
        vr_campoalt('dhretorno_analise').dsdadant := to_char(rw_fraude.dhretorno_analise,'DD/MM/RRRR HH24:MI:SS'); 
        vr_campoalt('cdstatus_analise' ).dsdadant := rw_fraude.cdstatus_analise;  
        vr_campoalt('cdparecer_analise').dsdadant := rw_fraude.cdparecer_analise; 
        vr_campoalt('dsfingerprint'    ).dsdadant := rw_fraude.dsfingerprint;
        vr_campoalt('cdcanal_analise'  ).dsdadant := rw_fraude.cdcanal_analise;
        vr_campoalt('flganalise_manual').dsdadant := rw_fraude.flganalise_manual;


        pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                              pr_nrdconta => rw_fraude.nrdconta,
                              pr_idorigem => pr_cdcanal,
                              pr_dstransa => vr_dstransa,
                              pr_idanalis => pr_idanalis,
                              pr_dscrilog => 'Falha na procedure AFRA0001.pc_reg_reto_analise_antifraude: '||pr_dscritic,
                              pr_campoalt => vr_campoalt);


        --> Verificar se deve notificar area de segurança
        IF rw_fraude.flgemail_retorno = 1 THEN
          pc_notificar_seguranca (pr_idanalis   => pr_idanalis,
                                  pr_tpalerta   => 2, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                  pr_dsalerta   => pr_dscritic,
                                  pr_dscritic   => vr_dscritic); 
        END IF;
                
        --> Caso não conseguiu enviar para o sistema de analise de fraude, 
        --> deve tratar operacao como aprovada
        vr_dstransa := 'Aprovação analise devido a falha ao processar retorno.';
        pc_atualizar_analise ( pr_rowid    => rw_fraude.rowid,
                               pr_dhretorn => SYSDATE,
                               pr_cdparece => 1,     --> Parecer da análise antifraude 
                                                                   --> 0 - Pendente
                                                                   --> 1 - Aprovada
                                                                   --> 2 - Reprovada
                               pr_cdcanal  => pr_cdcanal,      --> Canal origem da operação
                               pr_flganama => pr_flganama,     --> Indicador analise efetuada manualmente
                               pr_dstransa => vr_dstransa,     --> Descrição da trasaçao para log                                            
                               pr_dscrilog => NULL,            --> Em caso de status de erro, apresentar critica para log
                               pr_dscritic => vr_dsdetcri);
        IF TRIM(vr_dsdetcri) IS NOT NULL THEN
          vr_cdcritic := 996;
          RAISE vr_exc_erro;
        END IF;
                
        pc_aprovacao_analise (pr_idanalis  => pr_idanalis,    --> Indicador da analise de fraude
                              pr_cdcritic  => vr_cdcritic,
                              pr_dscritic  => vr_dsdetcri );
                
        IF TRIM(vr_dsdetcri) IS NOT NULL OR 
           nvl(vr_cdcritic,0) > 0 THEN
          RAISE vr_exc_apro;
        ELSE
           
          --> Notificar monitoração 
          ---pc_monitora_ted ( pr_idanalis => pr_idanalis);
          BEGIN                                
            AFRA0004.pc_monitora_operacao (pr_cdcooper   => rw_fraude.cdcooper    -- Codigo da cooperativa
                                          ,pr_nrdconta   => rw_fraude.nrdconta    -- Numero da conta
                                          ,pr_idseqttl   => NULL                  -- Sequencial titular
                                          ,pr_vlrtotal   => NULL                  -- Valor total lancamento 
                                          ,pr_flgagend   => rw_fraude.flgagend    -- Flag agendado /* 1-True, 0-False */ 
                                          ,pr_idorigem   => rw_fraude.tptransacao -- Indicador de origem
                                          ,pr_cdoperacao => rw_fraude.cdoperacao  -- Codigo operacao (tbcc_dominio_campo-CDOPERAC_ANALISE_FRAUDE)
                                          ,pr_idanalis   => rw_fraude.idanalise_fraude  -- ID Analise Fraude
                                          ,pr_lgprowid   => NULL                  -- Rowid craplgp
                                          ,pr_cdcritic   => vr_cdcritic           -- Codigo da critica
                                          ,pr_dscritic   => vr_dscritic);         -- Descricao da critica
                                         
            vr_cdcritic := NULL;                         
            vr_dscritic := NULL;                         
          EXCEPTION
            WHEN OTHERS THEN 
                 vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
                 btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                            pr_ind_tipo_log => 2, --> erro tratado
                                            pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                               ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                            pr_nmarqlog     => vr_nmarqlog);
                                             
                 vr_cdcritic := NULL;                         
                 vr_dscritic := NULL;                         
             
          END;                                             

         END IF; 
      
      END IF;    
    
    END pc_tratar_erro_fila_excep;
    
    
  BEGIN
    BEGIN
    
    vr_campoalt.delete;
    CASE 
      WHEN pr_flganama = 0 THEN
        vr_dstransa := 'Retorno Automatico do parecer da Analise de Fraude';
      WHEN pr_flganama = 1 AND pr_cdcanal = 12 THEN
        vr_dstransa := 'Retorno Manual do parecer da Analise de Fraude';
      WHEN pr_flganama = 1 AND pr_cdcanal = 1 THEN  
        vr_dstransa := 'Expiração do parecer da Analise de Fraude';
      ELSE
        vr_dstransa := 'Retorno do parecer da Analise de Fraude';
    END CASE;     
          
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 996;
      vr_dscritic := NULL;
      vr_dsdetcri := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    --> Armazenar valores antes da alteração
    vr_campoalt('dhenvio_analise'  ).dsdadant := to_char(rw_fraude.dhenvio_analise  ,'DD/MM/RRRR HH24:MI:SS');  
    vr_campoalt('dhlimite_analise' ).dsdadant := to_char(rw_fraude.dhlimite_analise ,'DD/MM/RRRR HH24:MI:SS');  
    vr_campoalt('dhretorno_analise').dsdadant := to_char(rw_fraude.dhretorno_analise,'DD/MM/RRRR HH24:MI:SS'); 
    vr_campoalt('cdstatus_analise' ).dsdadant := rw_fraude.cdstatus_analise;  
    vr_campoalt('cdparecer_analise').dsdadant := rw_fraude.cdparecer_analise; 
    vr_campoalt('dsfingerprint'    ).dsdadant := rw_fraude.dsfingerprint;
    vr_campoalt('cdcanal_analise'  ).dsdadant := rw_fraude.cdcanal_analise;
    vr_campoalt('flganalise_manual').dsdadant := rw_fraude.flganalise_manual;

    --> Validar fingerprint
    IF (pr_cdcanal <> 1 AND nvl(rw_fraude.dsfingerprint,'') <> pr_fingerpr OR 
       (pr_cdcanal = 1 AND pr_fingerpr <> 'NOFINGERPRINT')) THEN
      vr_cdcritic := 996;
      vr_dscritic := NULL;
      vr_dsdetcri := 'Requisição não é legitima.';
      RAISE vr_exc_erro;    
    END IF;
    
     IF (pr_flganama = 1) THEN /*  É analise manual */
      
      IF (rw_fraude.cdparecer_analise IN (0,2) AND rw_fraude.flganalise_manual = 0) THEN /* Está 0-Pendente ou 2-Reprovada */
        
         IF (pr_cdparece = 0) THEN /* Chamado pelo proprio Ayllos para 
                                     tomar decisão baseado no parecer automatico, 
                                     pois nao veio analise manual. */

             IF rw_fraude.cdparecer_analise = 0 THEN /* Aprovar */
               
                --> Atualizar analise
                pc_atualizar_analise ( pr_rowid    => rw_fraude.rowid,
                                       pr_dhretorn => SYSDATE,
                                       pr_cdparece => 1,     --> Parecer da análise antifraude 
                                                                           --> 0 - Pendente
                                                                           --> 1 - Aprovada
                                                                           --> 2 - Reprovada
                                       pr_cdcanal  => pr_cdcanal,      --> Canal origem da operação
                                       pr_flganama => pr_flganama,     --> Indicador analise efetuada manualmente
                                       pr_dstransa => vr_dstransa,     --> Descrição da trasaçao para log                                            
                                       pr_dscrilog => NULL,            --> Em caso de status de erro, apresentar critica para log
                                       pr_dscritic => vr_dsdetcri);
                IF TRIM(vr_dsdetcri) IS NOT NULL THEN
                  vr_cdcritic := 996;
                  RAISE vr_exc_erro;
                END IF;
                
                --> Chamar rotina de aprovação da analise
                pc_aprovacao_analise (pr_idanalis  => pr_idanalis,    --> Indicador da analise de fraude
                                      pr_cdcritic  => vr_cdcritic,
                                      pr_dscritic  => vr_dsdetcri );
              
                IF TRIM(vr_dsdetcri) IS NOT NULL OR 
                   nvl(vr_cdcritic,0) > 0 THEN
                   vr_cdcritic := 996;  
                   RAISE vr_exc_apro;
                END IF;
                
                --> Verificar se deve notificar area de segurança
                IF rw_fraude.flgemail_retorno = 1 THEN
                   pc_notificar_seguranca (pr_idanalis   => pr_idanalis,
                                           pr_tpalerta   => 2, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                           pr_dsalerta   => pr_dscritic,
                                           pr_dscritic   => vr_dscritic); 
                END IF;
                
                
                --> Notificar monitoração 
                
                BEGIN                                
                  AFRA0004.pc_monitora_operacao (pr_cdcooper   => rw_fraude.cdcooper    -- Codigo da cooperativa
                                                ,pr_nrdconta   => rw_fraude.nrdconta    -- Numero da conta
                                                ,pr_idseqttl   => NULL                  -- Sequencial titular
                                                ,pr_vlrtotal   => NULL                  -- Valor total lancamento 
                                                ,pr_flgagend   => rw_fraude.flgagend    -- Flag agendado /* 1-True, 0-False */ 
                                                ,pr_idorigem   => rw_fraude.tptransacao -- Indicador de origem
                                                ,pr_cdoperacao => rw_fraude.cdoperacao  -- Codigo operacao (tbcc_dominio_campo-CDOPERAC_ANALISE_FRAUDE)
                                                ,pr_idanalis   => rw_fraude.idanalise_fraude  -- ID Analise Fraude
                                                ,pr_lgprowid   => NULL                  -- Rowid craplgp
                                                ,pr_cdcritic   => vr_cdcritic           -- Codigo da critica
                                                ,pr_dscritic   => vr_dscritic);         -- Descricao da critica
                                               
                  vr_cdcritic := NULL;                         
                  vr_dscritic := NULL;                         
                EXCEPTION
                  WHEN OTHERS THEN 
                       vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
                       btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                                  pr_ind_tipo_log => 2, --> erro tratado
                                                  pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                     ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                                  pr_nmarqlog     => vr_nmarqlog);
                                                   
                       vr_cdcritic := NULL;                         
                       vr_dscritic := NULL;                         
                END;                                             
               
             ELSIF rw_fraude.cdparecer_analise = 2 THEN /* Reprovar */
               
                    --> Atualizar analise
                    pc_atualizar_analise ( pr_rowid    => rw_fraude.rowid,
                                           pr_dhretorn => SYSDATE,
                                           pr_cdparece => 2,     --> Parecer da análise antifraude 
                                                                               --> 0 - Pendente
                                                                               --> 1 - Aprovada
                                                                               --> 2 - Reprovada
                                           pr_cdcanal  => pr_cdcanal,      --> Canal origem da operação
                                           pr_flganama => pr_flganama,     --> Indicador analise efetuada manualmente
                                           pr_dstransa => vr_dstransa,     --> Descrição da trasaçao para log                                            
                                           pr_dscrilog => NULL,            --> Em caso de status de erro, apresentar critica para log
                                           pr_dscritic => vr_dsdetcri);
                    IF TRIM(vr_dsdetcri) IS NOT NULL THEN
                      vr_cdcritic := 996;
                      RAISE vr_exc_erro;
                    END IF;
                  
                    --> Chamar rotina de reprovacao da analise
                    pc_reprovacao_analise (pr_idanalis  => pr_idanalis,    --> Indicador da analise de fraude
                                          pr_cdcritic  => vr_cdcritic,
                                          pr_dscritic  => vr_dsdetcri );
                  
                    IF TRIM(vr_dsdetcri) IS NOT NULL OR 
                       nvl(vr_cdcritic,0) > 0 THEN
                      vr_cdcritic := 996; 
                      RAISE vr_exc_erro;
                    END IF;
                    
             END IF;
        
         ELSIF (pr_cdparece = 1) THEN /* Atualizar para 1-Aprovado */
           
            --> Excluir analise na fila  
            AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dsdetcri);
            
            IF TRIM(vr_dsdetcri) IS NOT NULL OR
               nvl(vr_cdcritic,0) > 0 THEN
              vr_cdcritic := 996;  
              RAISE vr_exc_erro; 
            END IF;
    
            --> Atualizar analise
            pc_atualizar_analise ( pr_rowid    => rw_fraude.rowid,
                                   pr_dhretorn => SYSDATE,
                                   pr_cdparece => pr_cdparece,     --> Parecer da análise antifraude 
                                                                       --> 0 - Pendente
                                                                       --> 1 - Aprovada
                                                                       --> 2 - Reprovada
                                   pr_cdcanal  => pr_cdcanal,      --> Canal origem da operação
                                   pr_flganama => pr_flganama,     --> Indicador analise efetuada manualmente
                                   pr_dstransa => vr_dstransa,     --> Descrição da trasaçao para log                                            
                                   pr_dscrilog => NULL,            --> Em caso de status de erro, apresentar critica para log
                                   pr_dscritic => vr_dsdetcri);
            IF TRIM(vr_dsdetcri) IS NOT NULL THEN
              vr_cdcritic := 996;
              RAISE vr_exc_erro;
            END IF;
            
            --> Chamar rotina de aprovação da analise
            pc_aprovacao_analise (pr_idanalis  => pr_idanalis,    --> Indicador da analise de fraude
                                  pr_cdcritic  => vr_cdcritic,
                                  pr_dscritic  => vr_dsdetcri );
          
            IF TRIM(vr_dsdetcri) IS NOT NULL OR 
               nvl(vr_cdcritic,0) > 0 THEN
               vr_cdcritic := 996;  
               RAISE vr_exc_apro;
            END IF;
        
        ELSIF (pr_cdparece = 2) THEN /* Atualizar para 2-Reprovado */   
          
              --> Excluir analise na fila  
              AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dsdetcri);
                
              IF TRIM(vr_dsdetcri) IS NOT NULL OR
                 nvl(vr_cdcritic,0) > 0 THEN
                vr_cdcritic := 996;  
                RAISE vr_exc_erro; 
              END IF;

              --> Atualizar analise
              pc_atualizar_analise ( pr_rowid    => rw_fraude.rowid,
                                     pr_dhretorn => SYSDATE,
                                     pr_cdparece => pr_cdparece,     --> Parecer da análise antifraude 
                                                                         --> 0 - Pendente
                                                                         --> 1 - Aprovada
                                                                         --> 2 - Reprovada
                                     pr_cdcanal  => pr_cdcanal,      --> Canal origem da operação
                                     pr_flganama => pr_flganama,     --> Indicador analise efetuada manualmente
                                     pr_dstransa => vr_dstransa,     --> Descrição da trasaçao para log                                            
                                     pr_dscrilog => NULL,            --> Em caso de status de erro, apresentar critica para log
                                     pr_dscritic => vr_dsdetcri);
              IF TRIM(vr_dsdetcri) IS NOT NULL THEN
                vr_cdcritic := 996;
                RAISE vr_exc_erro;
              END IF;
              
              --> Chamar rotina de reprovacao da analise
              pc_reprovacao_analise (pr_idanalis  => pr_idanalis,    --> Indicador da analise de fraude
                                    pr_cdcritic  => vr_cdcritic,
                                    pr_dscritic  => vr_dsdetcri );
              
              IF TRIM(vr_dsdetcri) IS NOT NULL OR 
                 nvl(vr_cdcritic,0) > 0 THEN
                vr_cdcritic := 996; 
                RAISE vr_exc_repro;
              END IF;
        END IF;
      ELSE
         --> Apenas Gerar log de analise de fraude
         pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                               pr_nrdconta => rw_fraude.nrdconta,
                               pr_idorigem => pr_cdcanal,
                               pr_dstransa => vr_dstransa,
                               pr_idanalis => rw_fraude.idanalise_fraude,
                               pr_dscrilog => 'Parecer nao atualizado, registro nao esta pendendte de analise.',
                               pr_campoalt => vr_campoalt);
      
      END IF;
    ELSIF pr_flganama = 0 THEN /* É analise automatica */
      
          IF (rw_fraude.cdparecer_analise = 0) AND  /* Pendente de analise */
             (rw_fraude.flganalise_manual = 0) THEN /* Não foi feita análise manual */
            
              --> Atualizar analise
              pc_atualizar_analise ( pr_rowid    => rw_fraude.rowid,
                                     pr_dhretorn => SYSDATE,
                                     pr_cdparece => pr_cdparece,     --> Parecer da análise antifraude 
                                                                         --> 0 - Pendente
                                                                         --> 1 - Aprovada
                                                                         --> 2 - Reprovada
                                     pr_cdcanal  => pr_cdcanal,      --> Canal origem da operação
                                     pr_flganama => pr_flganama,     --> Indicador analise efetuada manualmente
                                     pr_dstransa => vr_dstransa,     --> Descrição da trasaçao para log                                            
                                     pr_dscrilog => NULL,            --> Em caso de status de erro, apresentar critica para log
                                     pr_dscritic => vr_dsdetcri);
              IF TRIM(vr_dsdetcri) IS NOT NULL THEN
                vr_cdcritic := 996;
                RAISE vr_exc_erro;
              END IF;
              
              IF pr_cdparece = 1 THEN /* Aprovado automaticamente */
                
                  --> Excluir analise na fila  
                  AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                                    pr_cdcritic => vr_cdcritic,
                                                    pr_dscritic => vr_dsdetcri);
                    
                  IF TRIM(vr_dsdetcri) IS NOT NULL OR
                     nvl(vr_cdcritic,0) > 0 THEN
                    vr_cdcritic := 996;  
                    RAISE vr_exc_erro; 
                  END IF;
                  
                  --> Chamar rotina de aprovação da analise
                  pc_aprovacao_analise (pr_idanalis  => pr_idanalis,    --> Indicador da analise de fraude
                                        pr_cdcritic  => vr_cdcritic,
                                        pr_dscritic  => vr_dsdetcri );
                
                  IF TRIM(vr_dsdetcri) IS NOT NULL OR 
                     nvl(vr_cdcritic,0) > 0 THEN
                     vr_cdcritic := 996;  
                     RAISE vr_exc_apro;
                  END IF;
        
              END IF;
              
          ELSE
             --> Apenas Gerar log de analise de fraude
             pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                                   pr_nrdconta => rw_fraude.nrdconta,
                                   pr_idorigem => pr_cdcanal,
                                   pr_dstransa => vr_dstransa,
                                   pr_idanalis => rw_fraude.idanalise_fraude,
                                   pr_dscrilog => 'Parecer nao atualizado, registro nao esta pendendte de analise.',
                                   pr_campoalt => vr_campoalt);
          END IF;
    ELSE
       --> Apenas Gerar log de analise de fraude
       pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                             pr_nrdconta => rw_fraude.nrdconta,
                             pr_idorigem => pr_cdcanal,
                             pr_dstransa => vr_dstransa,
                             pr_idanalis => rw_fraude.idanalise_fraude,
                             pr_dscrilog => 'Parecer nao atualizado, operacao nao reconhecida.',
                             pr_campoalt => vr_campoalt);
          
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
      pr_dsdetcri := vr_dsdetcri;
      
      ROLLBACK;
      
      --> Caso for fila de exception
      IF pr_cdcanal = 1 AND   
         pr_fingerpr = 'NOFINGERPRINT' AND   
         pr_flganama = 1  THEN
         
         pc_tratar_erro_fila_excep(pr_dscritic => vr_dsdetcri);
         
      ELSIF rw_fraude.nrdconta IS NOT NULL THEN
      
         --> Apos rollback, gerar log e commitar
         --> Gerar log de analise de fraude
         pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
         	                     pr_nrdconta => rw_fraude.nrdconta,
         	                     pr_idorigem => pr_cdcanal,
                               pr_dstransa => vr_dstransa,
                               pr_idanalis => pr_idanalis,
                               pr_dscrilog => pr_dsdetcri,
                               pr_campoalt => vr_campoalt);
      
      ELSE
         vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
         btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                    pr_ind_tipo_log => 2, --> erro tratado
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - AFRA0001.pc_reg_reto_analise_antifraude --> idanalis: ' ||pr_idanalis ||
                                                       ', cdparece: '|| pr_cdparece ||
                                                       ' - '||pr_dscritic,
                                    pr_nmarqlog     => vr_nmarqlog);
      
      END IF;
     
      COMMIT;

    WHEN vr_exc_apro THEN
        --> Caso não consiga aprovar, tentará reprovar a analise
        ROLLBACK; 
        pc_tratar_erro_aprovacao;
      
    WHEN vr_exc_repro THEN
        --> Caso não consiga reprovar, tentará aprovar a analise
        ROLLBACK; 
        pc_tratar_erro_reprovacao;
    WHEN OTHERS THEN
      pr_cdcritic := 996;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := 'Não foi possivel registrar retorno da analise: '||SQLERRM;
      ROLLBACK;
      
      
      --> Caso for fila de exception
      IF pr_cdcanal = 1 AND   
         pr_fingerpr = 'NOFINGERPRINT' AND   
         pr_flganama = 1  THEN
         
         pc_tratar_erro_fila_excep(pr_dscritic => vr_dsdetcri);
         
      --> Apos rollback, gerar log e commitar
      --> Gerar log de analise de fraude
      ELSIF rw_fraude.nrdconta IS NOT NULL THEN
          pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                                pr_nrdconta => rw_fraude.nrdconta,
                                pr_idorigem => pr_cdcanal,
                                pr_dstransa => vr_dstransa,
                                pr_idanalis => pr_idanalis,
                                pr_dscrilog => pr_dsdetcri,
                                pr_campoalt => vr_campoalt);
         
      ELSE
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2, --> erro tratado
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - AFRA0001.pc_reg_reto_analise_antifraude --> ' || pr_dscritic,
                                   pr_nmarqlog     => vr_nmarqlog);
      
      END IF;
     
      COMMIT;
     
     END;        
  EXCEPTION
     WHEN vr_exc_apro THEN
        --> Caso não consiga aprovar, tentará reprovar a analise
        ROLLBACK; 
        pc_tratar_erro_aprovacao;
  END pc_reg_reto_analise_antifraude; 
  
  --> Rotina responsavel por registrar a confirmação de entrega da análise ao sistema antifraude
  PROCEDURE pc_reg_conf_entrega_antifraude(pr_idanalis    IN  NUMBER,       --> Id Unico da transação 
                                           pr_cdentreg    IN  NUMBER,       -->  Codigo de confirmação de entrega 
                                                                               --> 3 - Entrega confirmada antifraude
                                                                               --> 4 - Erro na comunicação com antifraude
                                           pr_cdcritic   OUT  NUMBER,       --> Código da Crítica 
                                           pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica 
                                           pr_dsdetcri   OUT VARCHAR2) IS   --> Detalhe da critica    
  /* ..........................................................................
    
      Programa : pc_reg_conf_entrega_antifraude        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por registrar a confirmação de entrega da análise ao sistema antifraude
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.idanalise_fraude,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdcooper,
             fra.nrdconta,
             --fra.cdcanal,
             fra.cdstatus_analise,
             fra.cdproduto,
             fra.cdoperacao,
             fra.tptransacao,
             decode(fra.tptransacao, 1, 0, 1) flgagend, /* 1=True, 0=False (indicador agendamento) */
             prm.flgemail_retorno
        FROM tbgen_analise_fraude fra,
             tbgen_analise_fraude_param prm
       WHERE fra.cdoperacao  = prm.cdoperacao
         AND fra.tptransacao = prm.tpoperacao
         AND fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    CURSOR cr_craptvl IS
      SELECT c.nrcontrole_if
        FROM craptvl a,
             tbspb_msg_enviada c
       WHERE a.idanafrd = pr_idanalis
         and a.idmsgenv = c.nrseq_mensagem;

    rw_craptvl cr_craptvl%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_dscritic_aux VARCHAR2(4000);
    vr_dsdetcri VARCHAR2(4000);
    vr_exc_erro EXCEPTION;  
   
    
    vr_dstransa craplgm.dstransa%TYPE;  
    vr_campoalt typ_tab_campo_alt;
    vr_cdparece tbgen_analise_fraude.cdparecer_analise%TYPE;
    
    vr_nmarqlog VARCHAR2(500)   := NULL;
    vr_dscrilog VARCHAR2(500)   := NULL;
    vr_cdcanal  INTEGER         := NULL;
    
    vr_cdprogra   VARCHAR2(50) := 'pc_reg_conf_entrega_antifraude';

    --everton
    vr_nrseq_mensagem tbspb_msg_enviada_fase.nrseq_mensagem%type;
    vr_nrseq_mensagem_fase tbspb_msg_enviada_fase.nrseq_mensagem_fase%type := null;
    vr_situacao_OFSAA      VARCHAR2(20);

  BEGIN
  
    vr_dstransa := 'Confirmação de entrega da operação para Analise de Fraude';
    
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 996;
      vr_dscritic := NULL;
      vr_dsdetcri := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    
    --> Caso deu erro na comunicação, setar parecer como aprovado, para nao manter a operacao retida
    IF pr_cdentreg = 4 THEN
      vr_cdparece := 1;
      vr_dscrilog := 'Falha na entrega para análise do sistema antifraude.';
      vr_cdcanal  := 1; --> Ayllos 
    ELSE
      vr_cdparece := NULL;
      vr_dscrilog := NULL;
      vr_cdcanal  := NULL;
    END IF;
    
    --> Atualizar status da analise analise
    pc_atualizar_analise ( pr_rowid    => rw_fraude.rowid,
                           pr_cdstatus => pr_cdentreg,     -->  Codigo de confirmação de entrega 
                                                                 --> 3 - Entrega confirmada antifraude
                                                                 --> 4 - Erro na comunicação com antifraude
                           pr_cdparece => vr_cdparece,
                           pr_cdcanal =>  vr_cdcanal,      --> Canal origem do parecer
                           pr_dstransa => vr_dstransa,     --> Descrição da trasaçao para log                                            
                           pr_dscrilog => vr_dscrilog,     --> Em caso de status de erro, apresentar critica para log
                           pr_dscritic => vr_dsdetcri);
    IF TRIM(vr_dsdetcri) IS NOT NULL THEN
      vr_cdcritic := 996;
      RAISE vr_exc_erro;
    END IF;  
      
    --> se retornou como não entregue
    --> e o parecer ainda esta como pendente
    IF pr_cdentreg = 4 AND rw_fraude.cdparecer_analise = 0 THEN
      
      --> Excluir analise na fila  
      AFRA0002.pc_remover_analise_fila (pr_idanalis => rw_fraude.idanalise_fraude, --> Identificador da analise 
                                        pr_cdcritic => vr_dscritic,
                                        pr_dscritic => vr_dscritic);
                    
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        vr_cdcritic := 996;  
        RAISE vr_exc_erro; 
      END IF;
        
      --> Verificar se deve notificar area de segurança
      IF rw_fraude.flgemail_retorno = 1 THEN
        pc_notificar_seguranca (pr_idanalis   => pr_idanalis,
                                pr_tpalerta   => 1, --> Tipo de alerta 1 - Entrega, 2 - Retorno falha
                                pr_dscritic   => vr_dscritic); 
      END IF;
      
      --> Caso não conseguiu enviar para o sistema de analise de fraude, 
      --> deve tratar operacao como aprovada
      pc_aprovacao_analise (pr_idanalis  => pr_idanalis,    --> Indicador da analise de fraude
                            pr_cdcritic  => vr_cdcritic,
                            pr_dscritic  => vr_dsdetcri );
        
      IF TRIM(vr_dsdetcri) IS NOT NULL OR 
         nvl(vr_cdcritic,0) > 0 THEN
         
         ROLLBACK;
         
         --> Atualizar analise e gerar log 
         pc_atualizar_analise ( pr_rowid => rw_fraude.rowid,
                                pr_dhdenvio => NULL,
                                pr_cdstatus => pr_cdentreg,      --> erro comuicação midleware
                                pr_cdparece => 2,                --> Reprovado
                                pr_cdcanal  => 1, -- Ayllos      --> Canal do parecer da analise  
                                pr_dstransa => vr_dstransa,      --> Descrição da trasaçao para log                                            
                                pr_dscrilog => vr_dscritic,      --> Em caso de status de erro, apresentar critica para log
                                pr_dscritic => vr_dscritic_aux);
          
         IF TRIM(vr_dscritic_aux) IS NOT NULL THEN
            vr_dscritic := vr_dscritic_aux;
            RAISE vr_exc_erro;
         END IF; 
          
         --> Excecutar rotinas referentes a reprovação da analise de fraude
         pc_reprovacao_analise (pr_idanalis  => rw_fraude.idanalise_fraude,    --> Indicador da analise de fraude
                                pr_cdcritic  => vr_cdcritic,
                                pr_dscritic  => vr_dscritic );
    
         IF TRIM(vr_dscritic) IS NOT NULL OR 
            nvl(vr_cdcritic,0) > 0 THEN    
           RAISE vr_exc_erro;
         END IF;
         
      ELSE
        
        
        --> Notificar monitoração         

        BEGIN                                
          AFRA0004.pc_monitora_operacao (pr_cdcooper   => rw_fraude.cdcooper    -- Codigo da cooperativa
                                        ,pr_nrdconta   => rw_fraude.nrdconta    -- Numero da conta
                                        ,pr_idseqttl   => NULL                  -- Sequencial titular
                                        ,pr_vlrtotal   => NULL                  -- Valor total lancamento 
                                        ,pr_flgagend   => rw_fraude.flgagend    -- Flag agendado /* 1-True, 0-False */ 
                                        ,pr_idorigem   => rw_fraude.tptransacao -- Indicador de origem
                                        ,pr_cdoperacao => rw_fraude.cdoperacao  -- Codigo operacao (tbcc_dominio_campo-CDOPERAC_ANALISE_FRAUDE)
                                        ,pr_idanalis   => rw_fraude.idanalise_fraude  -- ID Analise Fraude
                                        ,pr_lgprowid   => NULL                  -- Rowid craplgp
                                        ,pr_cdcritic   => vr_cdcritic           -- Codigo da critica
                                        ,pr_dscritic   => vr_dscritic);         -- Descricao da critica
                                         
          vr_cdcritic := NULL;                         
          vr_dscritic := NULL;                         
        EXCEPTION
          WHEN OTHERS THEN 
               vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
               btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                          pr_ind_tipo_log => 2, --> erro tratado
                                          pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                             ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                          pr_nmarqlog     => vr_nmarqlog);
                                             
               vr_cdcritic := NULL;                         
               vr_dscritic := NULL;                         
        END;                                             
      
      END IF;
      
    END IF; 
        
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
      pr_dsdetcri := vr_dsdetcri;
      
      ROLLBACK;
      
      --> Apos rollback, gerar log e commitar
      --> Gerar log de analise de fraude
      IF rw_fraude.nrdconta IS NOT NULL THEN
         pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                               pr_nrdconta => rw_fraude.nrdconta,
                               pr_idorigem => 12, -- OFFSA
                               pr_dstransa => vr_dstransa,
                               pr_idanalis => pr_idanalis,
                               pr_dscrilog => pr_dsdetcri,
                               pr_campoalt => vr_campoalt);
     
      ELSE
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2, --> erro tratado
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - AFRA0001.pc_reg_conf_entrega_antifraude --> ' || pr_dscritic,
                                   pr_nmarqlog     => vr_nmarqlog);
      
      END IF;
     
      COMMIT;
      
    WHEN OTHERS THEN
      pr_cdcritic := 996;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := 'Não foi possivel registrar a confirmaçao de entrega da analise: '||SQLERRM;
      ROLLBACK;
      --> Apos rollback, gerar log e commitar
      --> Gerar log de analise de fraude
      IF rw_fraude.nrdconta IS NOT NULL THEN
      pc_log_analise_fraude(pr_cdcooper => rw_fraude.cdcooper,
                            pr_nrdconta => rw_fraude.nrdconta,
                            pr_idorigem => 12, -- OFFSA
                            pr_dstransa => vr_dstransa,
                            pr_idanalis => pr_idanalis,
                            pr_dscrilog => pr_dsdetcri,
                            pr_campoalt => vr_campoalt);
     
      ELSE
        vr_nmarqlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2, --> erro tratado
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - AFRA0001.pc_reg_conf_entrega_antifraude --> ' || pr_dscritic,
                                   pr_nmarqlog     => vr_nmarqlog);
      
      END IF;
     
      COMMIT;
      
  END pc_reg_conf_entrega_antifraude;
  
  --> Rotina para estornar TED reprovada pela analise de frude
  PROCEDURE pc_estornar_ted_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, -->Id da análise de fraude
                                     pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                     pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                     pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                     pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_estornar_ted_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Janeiro/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por estornar TED reprovada pela analise de fraude
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdcooper,
             fra.nrdconta,
             --fra.cdcanal,
             fra.cdstatus_analise,
             fra.cdlantar,
             fra.tptransacao,
             fra.cdproduto

        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis
         AND fra.cdproduto = 30; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações da TED
    CURSOR cr_craptvl (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tvl.cdcooper,
             tvl.nrdconta,             
             tvl.nrdocmto,
             tvl.cdbccrcb,
             tvl.cdagercb,
             tvl.cpfcgrcb,
             tvl.nmpesrcb,
             tvl.vldocrcb,
             tvl.cdfinrcb,
             tvl.dshistor,
             tvl.dtmvtolt,
             tvl.idseqttl,
             ass.inpessoa              
        FROM craptvl tvl,
             crapass ass
       WHERE tvl.cdcooper = ass.cdcooper
         AND tvl.nrdconta = ass.nrdconta
         AND tvl.idanafrd = pr_idanalis
         AND tvl.cdcooper = pr_cdcooper
         AND tvl.nrdconta = pr_nrdconta;         
    rw_craptvl cr_craptvl%ROWTYPE;
    
    --> Buscar informações do agendamento de TED
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,             
             lau.nrdconta,
             lau.idseqttl,             
             lau.nrdocmto,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.dtmvtolt,
             lau.dsorigem,
             lau.cdagenci,   
             ass.inpessoa
        FROM craplau lau,
             crapass ass
       WHERE lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta
         AND lau.cdtiptra = 4    
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    vr_nrseqdig craplcm.nrseqdig%TYPE;
    vr_dsprotoc crappro.dsprotoc%TYPE;
    vr_dstransa craplgm.dstransa%TYPE;
    vr_vldinami VARCHAR2(4000);
    
    
  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    --> Online
    IF rw_fraude.tptransacao = 1 THEN
      
      --> Buscar dados da TED
      OPEN cr_craptvl( pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craptvl INTO rw_craptvl;
      
      IF cr_craptvl%NOTFOUND THEN
        CLOSE cr_craptvl;
        vr_dscritic := 'Não foi possivel localizar craptvl';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptvl;
      END IF;
      
      --> Estornar lançamento de débito do valor da TED da conta corrente
      BEGIN
      
        vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',rw_craptvl.cdcooper||';'||
                                                        to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                        1     ||';'||
                                                        100   ||';'||
                                                        44000 );      
        INSERT INTO craplcm 
                    (dtmvtolt, 
                     cdagenci, 
                     cdbccxlt, 
                     nrdolote, 
                     nrdconta, 
                     nrdocmto, 
                     cdhistor, 
                     nrseqdig, 
                     vllanmto, 
                     nrdctabb, 
                     cdpesqbb, 
                     dtrefere, 
                     hrtransa, 
                     cdoperad, 
                     cdcooper, 
                     cdorigem )
             VALUES (pr_dtmvtolt,           -- dtmvtolt
                     1,                     -- cdagenci
                     100,                   -- cdbccxlt
                     44000,                 -- nrdolote
                     rw_craptvl.nrdconta,   -- nrdconta
                     rw_craptvl.nrdocmto,   -- nrdocmto
                     2123,                  -- cdhistor
                     vr_nrseqdig,           -- nrseqdig
                     rw_craptvl.vldocrcb,   -- vllanmto
                     rw_craptvl.nrdconta,   -- nrdctabb
                     'EST TED',             -- cdpesqbb
                     TRUNC(SYSDATE),        -- dtrefere
                     gene0002.fn_busca_time,-- hrtransa
                     '1',                   -- cdoperad
                     rw_craptvl.cdcooper,   -- cdcooper
                     12);                   -- cdorigem                             
        
        
      EXCEPTION  
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel gerar lançamento de estorno de TED:'||SQLERRM;
          RAISE vr_exc_erro;
      END;    
          
      --> Estornar lançamento de tarifa de TED da conta corrente do cooperado      
      TARI0001.pc_estorno_baixa_tarifa (pr_cdcooper  => rw_craptvl.cdcooper  --> Codigo Cooperativa
                                       ,pr_cdagenci  => 1                    --> Codigo Agencia
                                       ,pr_nrdcaixa  => 1                    --> Numero do caixa
                                       ,pr_cdoperad  => '1'                  --> Codigo Operador
                                       ,pr_dtmvtolt  => pr_dtmvtolt          --> Data Lancamento
                                       ,pr_nmdatela  => NULL                 --> Nome da tela       
                                       ,pr_idorigem  => 12                   --> Indicador de origem
                                       ,pr_inproces  => pr_inproces          --> Indicador processo
                                       ,pr_nrdconta  => rw_craptvl.nrdconta  --> Numero da Conta
                                       ,pr_cddopcap  => 1                    --> Codigo de opcao --> 1 - Estorno de tarifa
                                                                                     --> 2 - Baixa de tarifa
                                       ,pr_lscdlant  => rw_fraude.cdlantar   --> Lista de lancamentos de tarifa(delimitador ;)
                                       ,pr_lscdmote  => ''                   --> Lista de motivos de estorno (delimitador ;)
                                       ,pr_flgerlog  => 'S'                  --> Indicador se deve gerar log (S-sim N-Nao)
                                       ,pr_cdcritic  => vr_cdcritic          --> Codigo Critica
                                       ,pr_dscritic  => vr_dscritic);        --> Descricao Critica
        
      IF nvl(vr_cdcritic,0) > 0 OR         
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;    
      END IF;   
      
      --> Alterar a situação do comprovante no IB/Mobile para ESTORNADO.  
      GENE0006.pc_estorna_protocolo(pr_cdcooper => rw_craptvl.cdcooper,
                                    pr_dtmvtolt => rw_craptvl.dtmvtolt,
                                    pr_nrdconta => rw_craptvl.nrdconta,
                                    pr_cdtippro => 9, --> TED 
                                    pr_nrdocmto => rw_craptvl.nrdocmto,
                                    pr_dsprotoc => vr_dsprotoc,     --> Descrição do protocolo
                                    pr_retorno  => vr_dscritic);
      IF nvl(vr_dscritic,'OK')<> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      --> Alterar a tabela de valores utilizados na internet para diminuir o valor da TED
      BEGIN
        UPDATE crapmvi 
           SET crapmvi.vlmovted = crapmvi.vlmovted - rw_craptvl.vldocrcb
         WHERE crapmvi.cdcooper = rw_craptvl.cdcooper
           AND crapmvi.nrdconta = rw_craptvl.nrdconta
           AND crapmvi.idseqttl = rw_craptvl.idseqttl
           AND crapmvi.dtmvtolt = rw_craptvl.dtmvtolt;                             
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar movimento internet: '|| SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      vr_vldinami := '#VALOR#='||to_char(rw_craptvl.vldocrcb,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craptvl.dtmvtolt,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno(pr_cdcooper  => rw_craptvl.cdcooper,
                           pr_nrdconta  => rw_craptvl.nrdconta,
                           pr_inpessoa  => rw_craptvl.inpessoa,
                           pr_idseqttl  => rw_craptvl.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                           pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                           pr_cdcritic  => vr_cdcritic,
                           pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
    --> Agendamento
    ELSIF rw_fraude.tptransacao = 2 THEN  
      
      OPEN cr_craplau (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplau INTO rw_craplau;
      
      IF cr_craplau%NOTFOUND THEN
        CLOSE cr_craplau;
        vr_dscritic := 'Não foi possivel localizar agendamento de TED';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplau;
      END IF;
    
      --> cancelar agendamento 
      PAGA0002.pc_cancelar_agendamento
                         ( pr_cdcooper => rw_craplau.cdcooper  --> Codigo da cooperativa
                          ,pr_cdagenci => rw_craplau.cdagenci  --> Codigo da agencia
                          ,pr_nrdcaixa => 900                  --> Numero do caixa
                          ,pr_cdoperad => '1'                  --> Codigo do operador
                          ,pr_nrdconta => rw_craplau.nrdconta  --> Numero da conta do cooperado
                          ,pr_idseqttl => rw_craplau.idseqttl  --> Sequencial do titular
                          ,pr_dtmvtolt => rw_craplau.dtmvtolt  --> Data do movimento
                          ,pr_dsorigem => rw_craplau.dsorigem  --> Descrição de origem do registro
                          ,pr_dtmvtage => rw_craplau.dtmvtolt  --> Data do agendamento
                          ,pr_nrdocmto => rw_craplau.nrdocmto  --> Numero do documento
                          ,pr_nmdatela => NULL                 --> Nome da tela
                          ,pr_idoriest => 12                   --> Origem do cancelamento/estorno            
                          --> parametros de saida
                          ,pr_dstransa => vr_dstransa          --> descrição de transação									                    
                          ,pr_dscritic => vr_dscritic );          --> Descricao critica  
    
    
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF; 
      
      vr_vldinami := '#VALOR#='||to_char(rw_craplau.vllanaut,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno (pr_cdcooper  => rw_craplau.cdcooper,
                           pr_nrdconta  => rw_craplau.nrdconta,
                           pr_inpessoa  => rw_craplau.inpessoa,
                           pr_idseqttl  => rw_craplau.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                    pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                           pr_cdcritic  => vr_cdcritic,
                           pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
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
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar estorno da TED para analise: '||SQLERRM;
  END pc_estornar_ted_analise; 
  

  --> Rotina para estornar Titulo reprovada pela analise de fraude
  PROCEDURE pc_estornar_titulo_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Id da análise de fraude
                                        pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                        pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                        pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                        pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_estornar_titulo_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por estornar Titulo reprovado pela analise de fraude
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdcooper,
             fra.nrdconta,
             --fra.cdcanal,
             fra.cdstatus_analise,
             fra.cdlantar,
             fra.tptransacao,
             fra.cdproduto

        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis
         AND fra.cdproduto = 44; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações do Titulo
    CURSOR cr_craptit (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tit.cdcooper,
             tit.cdagenci,
             tit.nrdconta,             
             tit.dscodbar,
             tit.vldpagto,
             tit.dtmvtolt,
             tit.cdctrbxo,
             tit.nrdident,
             tit.idseqttl,
             ass.inpessoa              
        FROM craptit tit,
             crapass ass
       WHERE tit.cdcooper = ass.cdcooper
         AND tit.nrdconta = ass.nrdconta
         AND tit.idanafrd = pr_idanalis
         AND tit.cdcooper = pr_cdcooper
         AND tit.nrdconta = pr_nrdconta;         
    rw_craptit cr_craptit%ROWTYPE;
    
    --> Buscar informações do agendamento
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,             
             lau.nrdconta,
             lau.idseqttl,             
             lau.nrdocmto,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.dtmvtolt,
             lau.dsorigem,
             lau.cdagenci,   
             ass.inpessoa
        FROM craplau lau,
             crapass ass
       WHERE lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta
         AND lau.cdtiptra = 2   
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    vr_dsprotoc crappro.dsprotoc%TYPE;
    vr_dstransa craplgm.dstransa%TYPE;
    vr_vldinami VARCHAR2(4000);
    
    
  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    --> Online
    IF rw_fraude.tptransacao = 1 THEN
    
      OPEN cr_craptit (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craptit INTO rw_craptit;
      
      IF cr_craptit%NOTFOUND THEN
        CLOSE cr_craptit;
        vr_dscritic := 'Não foi possivel localizar pagamento do titulo.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptit;
      END IF;
      
      --> Procedimento para estornar titulo
      PAGA0004.pc_estorna_titulo (pr_cdcooper  => rw_craptit.cdcooper  --> Codigo da cooperativa
                                 ,pr_cdagenci  => rw_craptit.cdagenci  --> Codigo da agencia
                                 ,pr_dtmvtolt  => rw_craptit.dtmvtolt  --> Data de movimento
                                 ,pr_nrdconta  => rw_craptit.nrdconta  --> Numero da conta
                                 ,pr_idseqttl  => rw_craptit.idseqttl  --> Sequencial titular
                                 ,pr_cdbarras  => rw_craptit.dscodbar  --> Codigo de barras
                                 ,pr_dscedent  => ''                   --> Cedente
                                 ,pr_vlfatura  => rw_craptit.vldpagto  --> Valor da fatura
                                 ,pr_cdoperad  => '1'                  --> Codigo do operador
                                 ,pr_idorigem  => 12 /* Antifraude */  --> Id de origem da operação
                                 ,pr_cdctrbxo  => rw_craptit.cdctrbxo  --> Codigo de controle de baixa
                                 ,pr_nrdident  => rw_craptit.nrdident  --> Identificador do titulo NPC
                                 ,pr_dstransa  => vr_dstransa          --> Retorna Descrição da transação
                                 ,pr_dscritic  => vr_dscritic          --> Retorna critica
                                 ,pr_dsprotoc  => vr_dsprotoc);        --> Retorna protocolo
          
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_vldinami := '#VALOR#='||to_char(rw_craptit.vldpagto,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craptit.dtmvtolt,'DD/MM/RRRR');
      

      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno(pr_cdcooper  => rw_craptit.cdcooper,
                           pr_nrdconta  => rw_craptit.nrdconta,
                           pr_inpessoa  => rw_craptit.inpessoa,
                           pr_idseqttl  => rw_craptit.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                   pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                           pr_cdcritic  => vr_cdcritic,
                           pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
    --> Agendamento
    ELSIF rw_fraude.tptransacao = 2 THEN  
      
      OPEN cr_craplau (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplau INTO rw_craplau;
      
      IF cr_craplau%NOTFOUND THEN
        CLOSE cr_craplau;
        vr_dscritic := 'Não foi possivel localizar agendamento de Tributo';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplau;
      END IF;
    
      --> cancelar agendamento 
      PAGA0002.pc_cancelar_agendamento
                         ( pr_cdcooper => rw_craplau.cdcooper  --> Codigo da cooperativa
                          ,pr_cdagenci => rw_craplau.cdagenci  --> Codigo da agencia
                          ,pr_nrdcaixa => 900                  --> Numero do caixa
                          ,pr_cdoperad => '1'                  --> Codigo do operador
                          ,pr_nrdconta => rw_craplau.nrdconta  --> Numero da conta do cooperado
                          ,pr_idseqttl => rw_craplau.idseqttl  --> Sequencial do titular
                          ,pr_dtmvtolt => rw_craplau.dtmvtolt  --> Data do movimento
                          ,pr_dsorigem => rw_craplau.dsorigem  --> Descrição de origem do registro
                          ,pr_dtmvtage => rw_craplau.dtmvtolt  --> Data do agendamento
                          ,pr_nrdocmto => rw_craplau.nrdocmto  --> Numero do documento
                          ,pr_nmdatela => NULL                 --> Nome da tela                                      
                          ,pr_idoriest => 12                   --> Origem do cancelamento/estorno                                      
                          --> parametros de saida
                          ,pr_dstransa => vr_dstransa          --> descrição de transação                                      
                          ,pr_dscritic => vr_dscritic );       --> Descricao critica  
    
    
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF; 
     
      vr_vldinami := '#VALOR#='||to_char(rw_craplau.vllanaut,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno(pr_cdcooper  => rw_craplau.cdcooper,
                           pr_nrdconta  => rw_craplau.nrdconta,
                           pr_inpessoa  => rw_craplau.inpessoa,
                           pr_idseqttl  => rw_craplau.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                   pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                           pr_cdcritic  => vr_cdcritic,
                           pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
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
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar estorno de titulo para analise: '||SQLERRM;
  END pc_estornar_titulo_analise;  
  
  
  --> Rotina para estornar Tributos reprovada pela analise de fraude
  PROCEDURE pc_estornar_Tributo_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Id da análise de fraude
                                         pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                         pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                         pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                         pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_estornar_Tributo_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2018.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por estornar Tributos reprovada pela analise de fraude
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdcooper,
             fra.nrdconta,
             --fra.cdcanal,
             fra.cdstatus_analise,
             fra.cdlantar,
             fra.tptransacao,
             fra.cdproduto

        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações de tributos
    CURSOR cr_craplft (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lft.cdcooper,
             lft.nrdconta,             
             lft.cdbarras,
             lft.cdseqfat,
             --Icluir valor de multa e fatura para DARF
             decode(lft.tpfatura,2,lft.vllanmto + nvl(lft.vlrmulta,0) + nvl(lft.vlrjuros,0),
                                   lft.vllanmto) vllanmto,
             lft.dtmvtolt,
             lft.idseqttl,
             ass.inpessoa              
        FROM craplft lft,
             crapass ass
       WHERE lft.cdcooper = ass.cdcooper
         AND lft.nrdconta = ass.nrdconta
         AND lft.idanafrd = pr_idanalis
         AND lft.cdcooper = pr_cdcooper
         AND lft.nrdconta = pr_nrdconta;         
    rw_craplft cr_craplft%ROWTYPE;
    
    --> Buscar informações do agendamento
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,             
             lau.nrdconta,
             lau.idseqttl,             
             lau.nrdocmto,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.dtmvtolt,
             lau.dsorigem,
             lau.cdagenci,   
             ass.inpessoa
        FROM craplau lau,
             crapass ass
       WHERE lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    vr_dsprotoc crappro.dsprotoc%TYPE;
    vr_dstransa craplgm.dstransa%TYPE;
    vr_vldinami VARCHAR2(4000);
    
    
  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    --> Online
    IF rw_fraude.tptransacao = 1 THEN
    
      OPEN cr_craplft (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplft INTO rw_craplft;
      
      IF cr_craplft%NOTFOUND THEN
        CLOSE cr_craplft;
        vr_dscritic := 'Não foi possivel localizar pagamento de tributo.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplft;
      END IF;
      
      PAGA0004.pc_estorna_convenio( pr_cdcooper  => rw_craplft.cdcooper  --> Codigo da cooperativa
                                   ,pr_nrdconta  => rw_craplft.nrdconta  --> Numero da conta
                                   ,pr_idseqttl  => rw_craplft.idseqttl  --> Sequencial titular
                                   ,pr_cdbarras  => rw_craplft.cdbarras  --> Codigo de barras
                                   ,pr_dscedent  => ''                   --> Cedente
                                   ,pr_cdseqfat  => rw_craplft.cdseqfat  --> sequencial da fatura
                                   ,pr_vlfatura  => rw_craplft.vllanmto  --> Valor da fatura
                                   ,pr_cdoperad  => '1'                  --> Codigo do operador
                                   ,pr_idorigem  => 12 /* Antifraude */  --> Id de origem da operação
                                   --> OUT <--
                                   ,pr_dstransa  => vr_dstransa   --> Retorna Descrição da transação
                                   ,pr_dscritic  => vr_dscritic   --> Retorna critica
                                   ,pr_dsprotoc  => vr_dsprotoc);   --> Retorna protocolo
      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_vldinami := '#VALOR#='||to_char(rw_craplft.vllanmto,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craplft.dtmvtolt,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno(pr_cdcooper  => rw_craplft.cdcooper,
                           pr_nrdconta  => rw_craplft.nrdconta,
                           pr_inpessoa  => rw_craplft.inpessoa,
                           pr_idseqttl  => rw_craplft.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                   pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                           pr_cdcritic  => vr_cdcritic,
                           pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
    --> Agendamento
    ELSIF rw_fraude.tptransacao = 2 THEN  
      
      OPEN cr_craplau (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplau INTO rw_craplau;
      
      IF cr_craplau%NOTFOUND THEN
        CLOSE cr_craplau;
        vr_dscritic := 'Não foi possivel localizar agendamento de Tributo';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplau;
      END IF;
    
      --> cancelar agendamento 
      PAGA0002.pc_cancelar_agendamento
                         ( pr_cdcooper => rw_craplau.cdcooper  --> Codigo da cooperativa
                          ,pr_cdagenci => rw_craplau.cdagenci  --> Codigo da agencia
                          ,pr_nrdcaixa => 900                  --> Numero do caixa
                          ,pr_cdoperad => '1'                  --> Codigo do operador
                          ,pr_nrdconta => rw_craplau.nrdconta  --> Numero da conta do cooperado
                          ,pr_idseqttl => rw_craplau.idseqttl  --> Sequencial do titular
                          ,pr_dtmvtolt => rw_craplau.dtmvtolt  --> Data do movimento
                          ,pr_dsorigem => rw_craplau.dsorigem  --> Descrição de origem do registro
                          ,pr_dtmvtage => rw_craplau.dtmvtolt  --> Data do agendamento
                          ,pr_nrdocmto => rw_craplau.nrdocmto  --> Numero do documento
                          ,pr_nmdatela => NULL                 --> Nome da tela                                      
                          ,pr_idoriest => 12                   --> Origem do cancelamento/estorno            
                          --> parametros de saida
                          ,pr_dstransa => vr_dstransa          --> descrição de transação                                      
                          ,pr_dscritic => vr_dscritic );       --> Descricao critica  
    
    
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF; 
     
      vr_vldinami := '#VALOR#='||to_char(rw_craplau.vllanaut,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno(pr_cdcooper  => rw_craplau.cdcooper,
                           pr_nrdconta  => rw_craplau.nrdconta,
                           pr_inpessoa  => rw_craplau.inpessoa,
                           pr_idseqttl  => rw_craplau.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                   pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                           pr_cdcritic  => vr_cdcritic,
                           pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
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
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar estorno de tributo para analise: '||SQLERRM;
  END pc_estornar_tributo_analise; 
  
  
  --> Rotina para estornar GPS reprovada pela analise de fraude
  PROCEDURE pc_estornar_gps_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, -->Id da análise de fraude
                                     pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                     pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                     pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_estornar_gps_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Teobaldo Jamunda (AMcom)
      Data     : Abril/2018.                   Ultima atualizacao: 20/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para estornar GPS reprovada pela analise de fraude
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude - GPS
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.cdstatus_analise,
             fra.cdlantar,
             fra.tptransacao,
             fra.cdproduto
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis
         AND fra.cdproduto = 47; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informacoes GPS
    CURSOR cr_craplgp (pr_idanalis  craplgp.idanafrd%TYPE,
                       pr_cdcooper  craplgp.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT lgp.cdcooper,
             ass.nrdconta,
             lgp.cdidenti,
             cop.cdagectl,
             ass.cdagenci,
             pes.nmpessoa, 
             ass.inpessoa,   
             lgp.cdbarras,
             lgp.dslindig,
             lgp.mmaacomp,
             lgp.nrautdoc,
             lgp.vlrtotal,
             lgp.vlrdinss,
             lgp.idseqttl,
             lgp.flgpagto,
             lgp.nrseqdig,
             lgp.nrdcaixa,
             lgp.rowid
        FROM craplgp lgp,
             crapcop cop,
             crapass ass,
             crapban ban,
             tbcadast_pessoa pes
       WHERE lgp.cdcooper = cop.cdcooper
         AND lgp.cdcooper = ass.cdcooper
         AND lgp.nrctapag = ass.nrdconta 
         AND lgp.cdbccxlt = ban.cdbccxlt
         AND ass.nrcpfcgc = pes.nrcpfcgc
         AND lgp.idanafrd = pr_idanalis  
         AND lgp.cdcooper = pr_cdcooper  
         AND lgp.nrctapag = pr_nrdconta;       
    rw_craplgp cr_craplgp%ROWTYPE;
    
    --> Buscar informações do agendamento de GPS
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,             
             lau.nrdconta,
             lau.idseqttl,             
             lau.nrdocmto,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.dtmvtolt,
             lau.dsorigem,
             lau.cdagenci,   
             ass.inpessoa,
             lau.flmobile,
             lau.nrcpfope,
             (SELECT gps.rowid
                FROM tbinss_agendamento_gps  gps
               WHERE gps.cdcooper = lau.cdcooper
                 AND gps.nrdconta = lau.nrdconta
                 AND gps.nrseqagp = lau.nrseqagp) rowid_tbinss
        FROM craplau lau,
             crapass ass
       WHERE lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta
         AND lau.cdtiptra = 2    
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    vr_dsprotoc crappro.dsprotoc%TYPE;    
    vr_vldinami VARCHAR2(4000);
    vr_nrdolote craplgp.nrdolote%TYPE;
    
    rw_craplot lote0001.cr_craplot%ROWTYPE;
    
  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    --> Online
    IF rw_fraude.tptransacao = 1 THEN
      
      --> Buscar dados da GPS
      OPEN cr_craplgp( pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplgp INTO rw_craplgp;
      
      IF cr_craplgp%NOTFOUND THEN
        CLOSE cr_craplgp;
        vr_dscritic := 'Não foi possivel localizar cr_craplgp';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplgp;
      END IF;
      
      IF rw_craplgp.flgpagto = 1 THEN -- TRUE/PAGO
        vr_dscritic := 'Pagamento ja enviado. Estorno não permitido.';
        RAISE vr_exc_erro;      
      END IF;
      
      vr_nrdolote:= 31000 + rw_craplgp.nrdcaixa;

      -- Inserir o lote e não deixar tabela lockada
      lote0001.pc_insere_lote( pr_cdcooper => rw_craplgp.cdcooper                      
                              ,pr_dtmvtolt => pr_dtmvtolt                      
                              ,pr_cdagenci => rw_craplgp.cdagenci                      
                              ,pr_cdbccxlt => 100 /* Fixo */                   
                              ,pr_nrdolote => vr_nrdolote                      
                              ,pr_cdoperad => 1                      
                              ,pr_nrdcaixa => rw_craplgp.nrdcaixa                      
                              ,pr_tplotmov => 30                               
                              ,pr_cdhistor => 1414 /* Historico gps sicredi */ 
                              ,pr_craplot  => rw_craplot 
                              ,pr_dscritic => pr_dscritic);

      -- se encontrou erro ao buscar lote, abortar programa
      IF pr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;      
      
      --> Estornar lançamento de débito do valor da GPS da conta corrente
      BEGIN
      
        INSERT INTO craplcm 
                    (dtmvtolt, 
                     cdagenci, 
                     cdbccxlt, 
                     nrdolote, 
                     nrdconta, 
                     nrdocmto, 
                     cdhistor, 
                     nrseqdig, 
                     vllanmto, 
                     nrdctabb, 
                     cdpesqbb, 
                     dtrefere, 
                     hrtransa, 
                     cdoperad, 
                     cdcooper, 
                     cdorigem )
             VALUES (pr_dtmvtolt,           -- dtmvtolt
                     rw_craplot.cdagenci,   -- cdagenci 
                     rw_craplot.cdbccxlt,   -- cdbccxlt 
                     rw_craplot.nrdolote,   -- nrdolote 
                     rw_craplgp.nrdconta,   -- nrdconta
                     rw_craplgp.nrautdoc,   -- nrdocmto 
                     2280,                  -- cdhistor (Estorno de Arrecadacao)
                     rw_craplot.nrseqdig,   -- nrseqdig
                     rw_craplgp.vlrtotal,   -- vllanmto  
                     rw_craplgp.nrdconta,   -- nrdctabb
                     'EST GPS',             -- cdpesqbb  
                     TRUNC(SYSDATE),        -- dtrefere
                     gene0002.fn_busca_time,-- hrtransa
                     '1',                   -- cdoperad
                     rw_craplgp.cdcooper,   -- cdcooper
                     12);                   -- cdorigem 
        
      EXCEPTION  
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel gerar lançamento de estorno de GPS:'||SQLERRM;
          RAISE vr_exc_erro;
      END;    
      
      --> Alterar a situação do comprovante no IB/Mobile para ESTORNADO.  
      GENE0006.pc_estorna_protocolo(pr_cdcooper => rw_craplgp.cdcooper,
                                    pr_dtmvtolt => pr_dtmvtolt,
                                    pr_nrdconta => rw_craplgp.nrdconta,
                                    pr_cdtippro => 13,              --> GPS
                                    pr_nrdocmto => rw_craplgp.nrseqdig,
                                    pr_dsprotoc => vr_dsprotoc,     --> Descrição do protocolo
                                    pr_retorno  => vr_dscritic);
                                    
      IF nvl(vr_dscritic,'OK')<> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Atualiza o registro de movimento da internet
      paga0001.pc_insere_movimento_internet(pr_cdcooper => rw_craplgp.cdcooper
                                           ,pr_nrdconta => rw_craplgp.nrdconta
                                           ,pr_idseqttl => rw_craplgp.idseqttl
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdoperad => 1
                                           ,pr_inpessoa => rw_craplgp.inpessoa
                                           ,pr_tpoperac => 2 -- Pagamento
                                           ,pr_vllanmto => (rw_craplgp.vlrtotal * -1) -- Diminuir valor
                                           ,pr_dscritic => vr_dscritic);
                                           
      IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
      END IF;
      
      vr_vldinami := '#VALOR#='||to_char(rw_craplgp.vlrtotal,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(pr_dtmvtolt,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno (pr_cdcooper => rw_craplgp.cdcooper,
                                   pr_nrdconta  => rw_craplgp.nrdconta,
                                   pr_inpessoa  => rw_craplgp.inpessoa,
                                   pr_idseqttl  => rw_craplgp.idseqttl,   
                                   pr_cdproduto => rw_fraude.cdproduto,
                                   pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                                   pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                   pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                                   pr_cdcritic  => vr_cdcritic,
                                   pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN
        -- Excluir
        DELETE craplgp lgp
         WHERE lgp.rowid = rw_craplgp.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no Pagamento do Agendamento! (Erro: '|| to_char(SQLCODE) || ')';
          RAISE vr_exc_erro;
      END;        
      
      -- verificar se lote esta lockado
      IF cxon0020.fn_verifica_lote_uso(pr_rowid => rw_craplot.rowid ) = 1 THEN
        vr_dscritic:= 'Registro de lote '||rw_craplot.nrdolote||' em uso. Tente novamente.';  
        RAISE vr_exc_erro;
      END IF;
        
      -- Atualizar lote
      BEGIN
        UPDATE craplot
           SET craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
               craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
               --> CREDITO 
               craplot.vlcompcr = nvl(craplot.vlcompcr,0) + rw_craplgp.vlrtotal,
               craplot.vlinfocr = nvl(craplot.vlinfocr,0) + rw_craplgp.vlrtotal
         WHERE craplot.rowid = rw_craplot.rowid; 
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar lote '||rw_craplot.nrdolote||' :'||SQLERRM;
          RAISE vr_exc_erro;
      END; 
      
    --> Agendamento
    ELSIF rw_fraude.tptransacao = 2 THEN  
      
      OPEN cr_craplau (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplau INTO rw_craplau;
      
      IF cr_craplau%NOTFOUND THEN
        CLOSE cr_craplau;
        vr_dscritic := 'Não foi possivel localizar agendamento de GPS';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplau;
      END IF;
      
      --> cancelar agendamento  GPS
      INSS0002.pc_gps_agmto_desativar(pr_cdcooper => rw_craplau.cdcooper     --> Codigo da cooperativa
                                     ,pr_nrdconta => rw_craplau.nrdconta     --> Numero da conta do cooperado
                                     ,pr_idorigem => 12                      --> Origem Analise de Fraude
                                     ,pr_cdoperad => '1'                     --> Codigo do operador
                                     ,pr_nmdatela => NULL                    --> Nome da tela
                                     ,pr_dsdrowid => rw_craplau.rowid_tbinss --> ROWID da tbinss_agendamento_gps 
                                     ,pr_nrcpfope => rw_craplau.nrcpfope     --> numero do cpf do operador 
                                     ,pr_flmobile => rw_craplau.flmobile     --> indicador de operacao atraves sistema mobile 
                                     ,pr_dscritic => vr_dscritic);           --> Descricao critica 
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF; 
      
      vr_vldinami := '#VALOR#='||to_char(rw_craplau.vllanaut,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno (pr_cdcooper  => rw_craplau.cdcooper,
                                    pr_nrdconta  => rw_craplau.nrdconta,
                                    pr_inpessoa  => rw_craplau.inpessoa,
                                    pr_idseqttl  => rw_craplau.idseqttl,
                                    pr_cdproduto => rw_fraude.cdproduto,
                                    pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                                    pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                    pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                                    pr_cdcritic  => vr_cdcritic,
                                    pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
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
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar estorno da GPS para analise: '||SQLERRM;
  END pc_estornar_gps_analise;
  
  
  --> Rotina para estornar Convenio reprovado pela analise de fraude  
  PROCEDURE pc_estornar_convenio_analise(pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Id da análise de fraude
                                         pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                         pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                         pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                         pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_estornar_convenio_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Teobaldo Jamunda (AMcom)
      Data     : Abril/2018.                    Ultima atualizacao: 17/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por estornar Convenio reprovado pela analise de fraude
                  (PRJ381 - Analide de Fraude, Teobaldo Jamunda - AMcom)             
      
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.rowid,
             fra.dsfingerprint,
             fra.cdparecer_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.cdstatus_analise,
             fra.cdlantar,
             fra.tptransacao,
             fra.cdproduto
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações de convenios
    CURSOR cr_craplft (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lft.cdcooper,
             lft.nrdconta,             
             lft.cdbarras,
             lft.cdseqfat,
             lft.vllanmto,
             lft.dtmvtolt,
             lft.idseqttl,
             ass.inpessoa              
        FROM craplft lft,
             crapass ass
       WHERE lft.cdcooper = ass.cdcooper
         AND lft.nrdconta = ass.nrdconta
         AND lft.idanafrd = pr_idanalis
         AND lft.cdcooper = pr_cdcooper
         AND lft.nrdconta = pr_nrdconta;         
    rw_craplft cr_craplft%ROWTYPE;
    
    --> Buscar informações do agendamento
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT lau.cdcooper,             
             lau.nrdconta,
             lau.idseqttl,             
             lau.nrdocmto,
             lau.vllanaut,
             lau.dtmvtopg,
             lau.dtmvtolt,
             lau.dsorigem,
             lau.cdagenci,   
             ass.inpessoa
        FROM craplau lau,
             crapass ass
       WHERE lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(4000);
    vr_exc_erro  EXCEPTION;    
    vr_dsprotoc  crappro.dsprotoc%TYPE;
    vr_dstransa  craplgm.dstransa%TYPE;
    vr_vldinami  VARCHAR2(4000);

    
  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    --> Online
    IF rw_fraude.tptransacao = 1 THEN
    
      OPEN cr_craplft (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplft INTO rw_craplft;
      
      IF cr_craplft%NOTFOUND THEN
        CLOSE cr_craplft;
        vr_dscritic := 'Não foi possivel localizar pagamento de tributo.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplft;
      END IF;
      
      PAGA0004.pc_estorna_convenio( pr_cdcooper  => rw_craplft.cdcooper  --> Codigo da cooperativa
                                   ,pr_nrdconta  => rw_craplft.nrdconta  --> Numero da conta
                                   ,pr_idseqttl  => rw_craplft.idseqttl  --> Sequencial titular
                                   ,pr_cdbarras  => rw_craplft.cdbarras  --> Codigo de barras
                                   ,pr_dscedent  => ''                   --> Cedente
                                   ,pr_cdseqfat  => rw_craplft.cdseqfat  --> sequencial da fatura
                                   ,pr_vlfatura  => rw_craplft.vllanmto  --> Valor da fatura
                                   ,pr_cdoperad  => '1'                  --> Codigo do operador
                                   ,pr_idorigem  => 12 /* Antifraude */  --> Id de origem da operação
                                   --> OUT <--
                                   ,pr_dstransa  => vr_dstransa          --> Retorna Descrição da transação
                                   ,pr_dscritic  => vr_dscritic          --> Retorna critica
                                   ,pr_dsprotoc  => vr_dsprotoc);        --> Retorna protocolo
      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_vldinami := '#VALOR#='||to_char(rw_craplft.vllanmto,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craplft.dtmvtolt,'DD/MM/RRRR');

      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno(pr_cdcooper  => rw_craplft.cdcooper,
                                   pr_nrdconta  => rw_craplft.nrdconta,
                                   pr_inpessoa  => rw_craplft.inpessoa,
                                   pr_idseqttl  => rw_craplft.idseqttl,
                                   pr_cdproduto => rw_fraude.cdproduto,
                                   pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                                   pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                   pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                                   pr_cdcritic  => vr_cdcritic,
                                   pr_dscritic  => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
    --> Agendamento
    ELSIF rw_fraude.tptransacao = 2 THEN  
      
      OPEN cr_craplau (pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplau INTO rw_craplau;
      
      IF cr_craplau%NOTFOUND THEN
        CLOSE cr_craplau;
        vr_dscritic := 'Não foi possivel localizar agendamento de Convenio';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplau;
      END IF;
    
      --> cancelar agendamento 
      PAGA0002.pc_cancelar_agendamento
                         ( pr_cdcooper => rw_craplau.cdcooper  --> Codigo da cooperativa
                          ,pr_cdagenci => rw_craplau.cdagenci  --> Codigo da agencia
                          ,pr_nrdcaixa => 900                  --> Numero do caixa
                          ,pr_cdoperad => '1'                  --> Codigo do operador
                          ,pr_nrdconta => rw_craplau.nrdconta  --> Numero da conta do cooperado
                          ,pr_idseqttl => rw_craplau.idseqttl  --> Sequencial do titular
                          ,pr_dtmvtolt => rw_craplau.dtmvtolt  --> Data do movimento
                          ,pr_dsorigem => rw_craplau.dsorigem  --> Descrição de origem do registro
                          ,pr_dtmvtage => rw_craplau.dtmvtolt  --> Data do agendamento
                          ,pr_nrdocmto => rw_craplau.nrdocmto  --> Numero do documento
                          ,pr_nmdatela => NULL                 --> Nome da tela                                      
                          ,pr_idoriest => 12                   --> Origem do cancelamento/estorno            
                          --> parametros de saida
                          ,pr_dstransa => vr_dstransa          --> descrição de transação                                      
                          ,pr_dscritic => vr_dscritic );       --> Descricao critica  
    
    
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF; 
     
      vr_vldinami := '#VALOR#='||to_char(rw_craplau.vllanaut,'999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')||';'||
                     '#DTDEBITO#='||to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR');
      
      --> Gerar uma notificação no IB para o cooperado      
      AFRA0004.pc_mensagem_estorno(pr_cdcooper  => rw_craplau.cdcooper,
                                   pr_nrdconta  => rw_craplau.nrdconta,
                                   pr_inpessoa  => rw_craplau.inpessoa,
                                   pr_idseqttl  => rw_craplau.idseqttl,
                                   pr_cdproduto => rw_fraude.cdproduto,
                                   pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                                   pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                   pr_programa  => 'AFRA0001',              --> Nome do programa/package de origem da mensagem
                                   pr_cdcritic  => vr_cdcritic,
                                   pr_dscritic  => vr_dscritic );

      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
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
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar estorno de convenio para analise: '||SQLERRM;
  END pc_estornar_convenio_analise;
  
  
  
  
  PROCEDURE pc_notificar_seguranca (pr_idanalis   IN tbgen_analise_fraude.idanalise_fraude%TYPE,
                                    pr_tpalerta   IN INTEGER, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                    pr_dsalerta   IN VARCHAR2 DEFAULT NULL,
                                    pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_notificar_seguranca        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para notificar area de segurança
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    CURSOR cr_afraprm IS
      SELECT  prm.flgemail_entrega
             ,prm.dsemail_entrega
             ,prm.dsassunto_entrega
             ,prm.dscorpo_entrega
             ,prm.dsemail_retorno
             ,prm.dsassunto_retorno
             ,prm.dscorpo_retorno
             ,fra.cdcooper
             ,fra.cdoperacao
             ,fra.nrdconta
             ,fra.dstransacao
        FROM tbgen_analise_fraude fra,
             tbgen_analise_fraude_param prm
       WHERE fra.cdoperacao  = prm.cdoperacao
         AND fra.tptransacao = prm.tpoperacao
         AND fra.idanalise_fraude  = pr_idanalis;  
    rw_afraprm cr_afraprm%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;  
    
    vr_dsdemail tbgen_analise_fraude_param.dsemail_retorno%TYPE;
    vr_dsassunt tbgen_analise_fraude_param.dsassunto_retorno%TYPE;
    vr_dsdcorpo tbgen_analise_fraude_param.dscorpo_retorno%TYPE;
    
    PRAGMA AUTONOMOUS_TRANSACTION;
    
  BEGIN
    
    --> buscar informações dos parametros   
    OPEN cr_afraprm;
    FETCH cr_afraprm INTO rw_afraprm;
    CLOSE cr_afraprm;
    
    
    -- Falha Entrega Aymaru
    IF pr_tpalerta = 1 THEN
      vr_dsdemail := rw_afraprm.dsemail_entrega;
      vr_dsassunt := rw_afraprm.dsassunto_entrega;
      vr_dsdcorpo := rw_afraprm.dscorpo_entrega;
      
    -- Falha na entrega OFFSA  
    ELSIF pr_tpalerta = 2 THEN
      vr_dsdemail := rw_afraprm.dsemail_retorno;
      vr_dsassunt := rw_afraprm.dsassunto_retorno;
      vr_dsdcorpo := rw_afraprm.dscorpo_retorno;    
    END IF;
    
    vr_dsdcorpo := vr_dsdcorpo||'<br> ID Analise: '||pr_idanalis;
    vr_dsdcorpo := vr_dsdcorpo||'<br> Tipo de Operação: '||fn_dsoperacao_fraude(rw_afraprm.cdoperacao);
    vr_dsdcorpo := vr_dsdcorpo||'<br> Transação: '||rw_afraprm.dstransacao;
    vr_dsdcorpo := vr_dsdcorpo||'<br> Cooperativa: '||rw_afraprm.cdcooper;
    vr_dsdcorpo := vr_dsdcorpo||'<br> Conta: '||gene0002.fn_mask_conta(rw_afraprm.nrdconta);
    
    IF pr_dsalerta IS NOT NULL THEN
      vr_dsdcorpo := vr_dsdcorpo||'<br> Critica: '||pr_dsalerta;
    END IF;
    
    --> Caso conseguiu definir destinatario, deve enviar email
    IF vr_dsdemail IS NOT NULL THEN
    
      gene0003.pc_solicita_email(pr_cdcooper    => rw_afraprm.cdcooper, 
                                 pr_cdprogra    => 'AFRA0001', 
                                 pr_des_destino => vr_dsdemail, 
                                 pr_des_assunto => vr_dsassunt, 
                                 pr_des_corpo   => vr_dsdcorpo, 
                                 pr_des_anexo   => NULL,                                  
                                 pr_flg_enviar  => 'S', 
                                 pr_des_erro    => vr_dscritic);                                                                  
    
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN      
      ROLLBACK;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      ROLLBACK;
      pr_dscritic := 'Não foi possivel enviar notificacao: '||SQLERRM;
  END pc_notificar_seguranca; 
  
  PROCEDURE pc_envia_template (pr_cdcritic  OUT INTEGER,
                                  pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_envia_ted_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pelo envio da TED para analise de fraude
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    
  BEGIN
    NULL;
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
      pr_dscritic := 'Não foi possivel realizar o envio da TED para analise: '||SQLERRM;
  END pc_envia_template; 
  
  -- Rotina para buscar o tempo final da operação online
  FUNCTION fn_limite_fim_operacao( pr_cdcooper IN NUMBER,
                                   pr_tplimite IN NUMBER) 
    RETURN NUMBER IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : fn_limite_fim_operacao
    --  Autor    : Odirlei Busana (AMcom)
    --  Data     : Abril/2018.                   Ultima atualizacao: --/--/----
    --
    -- Objetivo  : Rotina para buscar o tempo final da operação online
    ---------------------------------------------------------------------------------------------------------------
    vr_exc_erro     EXCEPTION;
    vr_dstextab     craptab.dstextab%TYPE;
    vr_dscritic     VARCHAR2(4000);
    vr_hrfimpag     NUMBER := 0;
    
  BEGIN
  
    IF vr_tab_limfimope.exists(pr_tplimite) THEN    
      RETURN vr_tab_limfimope(pr_tplimite);
    END IF;
  
  
    --> Cecred
    IF pr_tplimite = 2 THEN
    
      --> Verifica horario limite para pagamentos via internet
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'HRTRTITULO'
                                              ,pr_tpregist => 90);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        RAISE vr_exc_erro;
      ELSE      
        vr_hrfimpag:= SubStr(vr_dstextab,3,5);
      END IF;
    
    --> Sicredi  
    ELSIF pr_tplimite = 3 THEN
      
      --Selecionar Horarios Limites Internet
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'HRPGSICRED'
                                              ,pr_tpregist => 90);

      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Hora Fim
        vr_hrfimpag:= GENE0002.fn_busca_entrada(2,vr_dstextab,' ');
      END IF;
      
    --> Bancoob   
    ELSIF pr_tplimite = 4 THEN
   
      --Selecionar Horarios Limites Internet
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'HRPGBANCOOB'
                                              ,pr_tpregist => 90);

      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Hora Fim
        vr_hrfimpag:= GENE0002.fn_busca_entrada(2,vr_dstextab,' ');
      END IF;
   
    END IF;
   
    IF nvl(vr_hrfimpag,0) <> 0 THEN
      vr_tab_limfimope(pr_tplimite) := vr_hrfimpag;
    END IF;
   
    RETURN nvl(vr_hrfimpag,0);
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      RETURN 0;  
    WHEN OTHERS THEN
      RETURN 0;  
  END fn_limite_fim_operacao;  
  
  --> Retornar a data limite da analise
  PROCEDURE pc_ret_data_limite_analise ( pr_cdoperac  IN tbcc_operacao.cdoperacao%TYPE  --> Codigo da operação
                                        ,pr_tpoperac  IN INTEGER                        --> Tipo de operacao 1 -online 2-agendamento
                                        ,pr_dhoperac  IN TIMESTAMP                      --> Data hora da operação      
                                        ,pr_dtefeope  IN DATE DEFAULT NULL              --> Data que sera efetivada a operacao agendada
                                        ,pr_cdcooper  IN NUMBER DEFAULT 1               --> Codigo da cooperativa, para uso do limite de operacao
                                        ,pr_tplimite  IN NUMBER DEFAULT 0               --> Tipo de limite de operacao, utilizado para o tipo de retencao 3 - limite operacao
                                        ,pr_dhlimana OUT TIMESTAMP                      --> Retorna data hora limite da operacao
                                        ,pr_qtsegret OUT NUMBER                         --> Retorna tempo em segundo de retenção da analise
                                        ,pr_dscritic  OUT VARCHAR2) IS  
    /* ..........................................................................
    
      Programa : pc_ret_data_limite_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Retornar a data limite da analise
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar parametrização da analise
    CURSOR cr_afraprm IS 
      SELECT w.hrretencao,
             w.tpretencao
        FROM tbgen_analise_fraude_param w 
       WHERE w.cdoperacao = pr_cdoperac
         AND w.tpoperacao = pr_tpoperac;
    rw_afraprm cr_afraprm%ROWTYPE;     
    
    --> Buscar intervalo Online valida hora
     CURSOR cr_afrainter(pr_dhoperac DATE) IS 
      SELECT w.qtdminutos_retencao 
        FROM tbgen_analise_fraude_interv w 
       WHERE w.cdoperacao = pr_cdoperac
         AND w.tpoperacao = pr_tpoperac     
         AND w.hrinicio <= to_char(trunc(pr_dhoperac,'MI'),'SSSSS')
         AND w.hrfim    >= to_char(trunc(pr_dhoperac,'MI'),'SSSSS');
    rw_afrainter cr_afrainter%ROWTYPE;     

    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    vr_hrlimope NUMBER;
    vr_dhoperac TIMESTAMP;
    vr_fldiauti INTEGER;  --Idenrifica se é dia util
    
  BEGIN
  
    OPEN cr_afraprm;
    FETCH cr_afraprm INTO rw_afraprm;
    --> Se nao localizar registro, usar valor padrão
    IF cr_afraprm%NOTFOUND THEN
      CLOSE cr_afraprm;
      rw_afraprm.hrretencao := 30000; -->08:20
    ELSE
      CLOSE cr_afraprm;
    END IF;
  
    vr_fldiauti := 1;
    
    -- Online
    IF pr_tpoperac = 1 THEN
      
      --> Verificar se o dia atual é dia util
      vr_dhoperac := gene0005.fn_valida_dia_util( pr_cdcooper  => pr_cdcooper, 
                                                  pr_dtmvtolt  => trunc(pr_dhoperac), 
                                                  pr_tipo      => 'P');
    
      IF trunc(vr_dhoperac) <> trunc(pr_dhoperac) THEN
        --> Caso nao for, deve setar a data do proximo dia
        vr_fldiauti := 0;
        vr_dhoperac := to_date(
                              to_char(vr_dhoperac,'DD/MM/RRRR')||' '||to_char(pr_dhoperac,'HH24:MI:SS')
                             ,'DD/MM/RRRR HH24:MI:SS');
      ELSE
        vr_fldiauti := 1;
        vr_dhoperac := pr_dhoperac;
      END IF;
            
      --> Intervalo
      IF rw_afraprm.tpretencao = 1 THEN
        
        --> Caso nao for dia util
        IF vr_fldiauti = 0 THEN
          --> deve setar como as 09:00 do proximo dia util
          vr_dhoperac := to_date(
                              to_char(vr_dhoperac,'DD/MM/RRRR')||' 09:00:00'
                             ,'DD/MM/RRRR HH24:MI:SS');
        
        END IF;
      
        OPEN cr_afrainter(pr_dhoperac => vr_dhoperac);
        FETCH cr_afrainter INTO rw_afrainter;
        --> Se nao localizar registro, usar valor padrão
        IF cr_afrainter%NOTFOUND THEN
          CLOSE cr_afrainter;
          rw_afrainter.qtdminutos_retencao := 10;
        ELSE
          CLOSE cr_afrainter;
        END IF;      
    
        --> Calcular tempo limite
        pr_dhlimana := vr_dhoperac + (rw_afrainter.qtdminutos_retencao / 24 / 60);
        pr_qtsegret := rw_afrainter.qtdminutos_retencao * 60;
        
        --> Caso nao for dia util
        IF vr_fldiauti = 0 THEN
          --Calcular a quantidade de segundos do dia da operacao
          -- ate o dia de limite da analise
          pr_qtsegret := (to_date(to_char(pr_dhlimana,'DD/MM/RRRR HH24:MI:SS'),'DD/MM/RRRR HH24:mi:ss') - 
                          to_date(to_char(pr_dhoperac,'DD/MM/RRRR HH24:mi:ss'),'DD/MM/RRRR HH24:mi:ss')
                         ) * 86400;
        
        END IF;
      
      --> Fixo   
      ELSIF rw_afraprm.tpretencao = 2 THEN
        --> Calcular tempo limite
        pr_dhlimana := to_date(to_char(vr_dhoperac,'DD/MM/RRRR') ||' ' ||
                               to_char(to_date(rw_afraprm.hrretencao,'SSSSS'),'HH24:MI:SS')
                               ,'DD/MM/RRRR HH24:MI:SS');
        --Calcular a quantidade de segundos do dia da operacao
        -- ate o dia de limite da analise
        pr_qtsegret := (to_date(to_char(pr_dhlimana,'DD/MM/RRRR HH24:MI:SS'),'DD/MM/RRRR HH24:mi:ss') - 
                        to_date(to_char(pr_dhoperac,'DD/MM/RRRR HH24:mi:ss'),'DD/MM/RRRR HH24:mi:ss')
                       ) * 86400;
      
      --> Limite da operacao    
      ELSIF rw_afraprm.tpretencao = 3 THEN
        
        --> Buscar hora de limite final da operacao
        vr_hrlimope := fn_limite_fim_operacao( pr_cdcooper => pr_cdcooper,
                                               pr_tplimite => pr_tplimite);
        
        
        --> Calcular tempo limite
        IF vr_hrlimope > 0 THEN
          pr_dhlimana := to_date(to_char(vr_dhoperac,'DD/MM/RRRR') ||' ' ||
                                 to_char(to_date(vr_hrlimope,'SSSSS'),'HH24:MI:SS')                                 
                                 ,'DD/MM/RRRR HH24:MI:SS');
                                 
          --> Se a hora de limite analise for maior que a data atual
          --> utilizar a propria data e apenas irá incrementar os minutos
          IF pr_dhlimana <= SYSDATE THEN
            pr_dhlimana := vr_dhoperac;
          END IF;                       
        ELSE
          --> Caso nao tenha encontrado o horario limite, 
          --> irá apenas incrementar a quantidade de minutos
          pr_dhlimana := vr_dhoperac;
        END IF;  
                             
        --> incrementar o tempo de retencao
        pr_dhlimana := pr_dhlimana + (rw_afraprm.hrretencao / 24 / 60);
                               
        --Calcular a quantidade de segundos do dia da operacao
        -- ate o dia de limite da analise
        pr_qtsegret := (to_date(to_char(pr_dhlimana,'DD/MM/RRRR HH24:MI:SS'),'DD/MM/RRRR HH24:mi:ss') - 
                        to_date(to_char(pr_dhoperac,'DD/MM/RRRR HH24:mi:ss'),'DD/MM/RRRR HH24:mi:ss')
                       ) * 86400;
      
      END IF;
    
      
      
    ELSIF pr_tpoperac = 2 THEN
      
      IF pr_dtefeope IS NULL THEN
        vr_dscritic := 'Data de efetivação do agendamento deve ser informada.';
        RAISE vr_exc_erro;
      END IF;
      --> Calcular tempo limite
      pr_dhlimana := to_date(to_char(pr_dtefeope,'DD/MM/RRRR') ||' ' ||
                             to_char(to_date(rw_afraprm.hrretencao,'SSSSS'),'HH24:MI:SS')
                             ,'DD/MM/RRRR HH24:MI:SS');
      --Calcular a quantidade de segundos do dia da operacao
      -- ate o dia de limite da analise
      pr_qtsegret := (to_date(to_char(pr_dhlimana,'DD/MM/RRRR HH24:MI:SS'),'DD/MM/RRRR HH24:mi:ss') - 
                      to_date(to_char(pr_dhoperac,'DD/MM/RRRR HH24:mi:ss'),'DD/MM/RRRR HH24:mi:ss')
                     ) * 86400;
    
    
      IF pr_qtsegret < 0 THEN
        vr_dscritic := 'Nao foi possivel def. tempo limite para analise, tempo limite ja ultrapassado. ';
        RAISE vr_exc_erro; 
      END IF;
    END IF;
  
  
  
    
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      
      pr_dscritic := 'Não foi possivel calcular a data limite da analise: '||SQLERRM;
  END pc_ret_data_limite_analise;   
  

  /* Procedimento para carregar em memoria parametros da analise de fraude */
  PROCEDURE pc_ler_parametros_fraude (pr_atualizar IN INTEGER DEFAULT 0) IS
    /* ..........................................................................
    --
    --  Programa : pc_ler_parametros_fraude       
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Teobaldo Jamunda (AMcom)
    --  Data     : Abril/2018.                   Ultima atualizacao: 03/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada para carregar em memoria parametros 
    --               para analise de fraude.    (PRJ381 - Analise de Fraude)
    --
    --  Alteração  : 
    --
    -- ..........................................................................*/
    
    --> Buscar parametros analise de fraude
    CURSOR cr_param IS
       SELECT afp.cdoperacao, 
              afp.tpoperacao, 
              afp.hrretencao, 
              afp.flgemail_entrega, 
              afp.dsemail_entrega, 
              afp.dsassunto_entrega, 
              afp.dscorpo_entrega, 
              afp.flgemail_retorno, 
              afp.dsemail_retorno, 
              afp.dsassunto_retorno, 
              afp.dscorpo_retorno, 
              afp.flgativo
        FROM tbgen_analise_fraude_param afp;
    
    vr_Index Varchar2(10);
    
  BEGIN
    IF pr_atualizar > 0 THEN 
      vr_tab_AnaliseFraudeParam.Delete;
      
      For rw_param in cr_param Loop
        vr_Index := rw_param.cdoperacao || '|' || rw_param.tpoperacao; 
        
        vr_tab_AnaliseFraudeParam(vr_Index).cdoperacao := rw_param.cdoperacao;
        vr_tab_AnaliseFraudeParam(vr_Index).tpoperacao := rw_param.tpoperacao;
        vr_tab_AnaliseFraudeParam(vr_Index).hrretencao := rw_param.hrretencao;
        vr_tab_AnaliseFraudeParam(vr_Index).flgemail_entrega := rw_param.flgemail_entrega;
        vr_tab_AnaliseFraudeParam(vr_Index).dsemail_entrega := rw_param.dsemail_entrega;
        vr_tab_AnaliseFraudeParam(vr_Index).dsassunto_entrega := rw_param.dsassunto_entrega;
        vr_tab_AnaliseFraudeParam(vr_Index).dscorpo_entrega := rw_param.dscorpo_entrega;
        vr_tab_AnaliseFraudeParam(vr_Index).flgemail_retorno := rw_param.flgemail_retorno;
        vr_tab_AnaliseFraudeParam(vr_Index).dsemail_retorno := rw_param.dsemail_retorno;
        vr_tab_AnaliseFraudeParam(vr_Index).dsassunto_retorno := rw_param.dsassunto_retorno;
        vr_tab_AnaliseFraudeParam(vr_Index).dscorpo_retorno := rw_param.dscorpo_retorno;
        vr_tab_AnaliseFraudeParam(vr_Index).flgativo:= rw_param.flgativo;
      End Loop;              
    END IF;
        
  END pc_ler_parametros_fraude;      
  
END;
/
