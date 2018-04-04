CREATE OR REPLACE PACKAGE CECRED.AFRA0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : AFRA0001
      Sistema  : Rotinas referentes a Analise de Fraude
      Sigla    : AFRA
      Autor    : Odirlei Busana - AMcom
      Data     : Novembro/2016.                   Ultima atualizacao: 03/04/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Analise de Fraude.

      Alteracoes:		02/02/2018 - Ajuste na variável pr_dhoperac para que sejam desconsiderados
								     os segundos, desta forma a cursor se torna compatível com  os 
									 intervalos cadastrados na Tela CADFRA.
									 Chamado 789957 - Gabriel (Mouts).

				        03/04/2018 - Adicionado NOTI0001.pc_cria_notificacao

  ---------------------------------------------------------------------------------------------------------------*/
  
  --- Armazenar os campos alterados
  TYPE typ_rec_campo_alt
       IS RECORD(dsdadant craplgi.dsdadant%TYPE,
                 dsdadatu craplgi.dsdadatu%TYPE);
  TYPE typ_tab_campo_alt IS TABLE OF typ_rec_campo_alt
       INDEX BY VARCHAR2(50); 
         
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
                                        
  --> Rotina responsavel em enviar as analises de fraude pendentes
  PROCEDURE pc_enviar_analise_fraude (pr_idanalis   IN INTEGER DEFAULT 0,
                                      pr_cdcritic  OUT INTEGER,
                                      pr_dscritic  OUT VARCHAR2 ); 
                                      
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
                                           
  --> Rotina para estornar TED reprovada pela analise de frude
  PROCEDURE pc_estornar_ted_analise (pr_idanalis  IN tbgen_analise_fraude.idanalise_fraude%TYPE, -->Id da análise de fraude
                                     pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,                      --> Data do sistema
                                     pr_inproces  IN crapdat.inproces%TYPE,                      --> Indicar de execução do processo batch
                                     pr_cdcritic  OUT INTEGER,                                   --> Retorno de critica
                                     pr_dscritic  OUT VARCHAR2 ); 
                                     
  --> Rotina para geração de mensagem de estorno para o cooperado
  PROCEDURE pc_mensagem_estorno (pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                 pr_nrdconta  IN crapass.nrdconta%TYPE,
                                 pr_inpessoa  IN crapass.inpessoa%TYPE,
                                 pr_idseqttl  IN crapttl.idseqttl%TYPE,
                                 pr_cdproduto IN tbgen_analise_fraude.cdproduto%TYPE,
                                 pr_tptransacao IN tbgen_analise_fraude.tptransacao%TYPE, --> Tipo de transação (1-online/ 2-agendada)                                  
                                 pr_vldinami  IN VARCHAR2, --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                 pr_cdcritic  OUT INTEGER,
                                 pr_dscritic  OUT VARCHAR2 );                                           

  /* Procedimento para realizar monitoração de fraudes nas TEDs */
  PROCEDURE pc_monitora_ted ( pr_idanalis IN INTEGER );

  PROCEDURE pc_notificar_seguranca (pr_idanalis   IN tbgen_analise_fraude.idanalise_fraude%TYPE,
                                    pr_tpalerta   IN INTEGER, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
                                    pr_dsalerta   IN VARCHAR2 DEFAULT NULL,
                                    pr_dscritic  OUT VARCHAR2 );
                                    
  --> Retornar a data limite da analise
  PROCEDURE pc_ret_data_limite_analise ( pr_cdoperac   IN tbcc_operacao.cdoperacao%TYPE  --> Codigo da operação
                                        ,pr_tpoperac   IN INTEGER                        --> Tipo de operacao 1 -online 2-agendamento
                                        ,pr_dhoperac   IN TIMESTAMP                      --> Data hora da operação      
                                        ,pr_dtefeope   IN DATE DEFAULT NULL              --> Data que sera efetivada a operacao agendada
                                        ,pr_dhlimana  OUT TIMESTAMP                      --> Retorna data hora limite da operacao
                                        ,pr_qtsegret  OUT NUMBER                         --> Retorna tempo em segundo de retenção da analise
                                        ,pr_dscritic  OUT VARCHAR2);   
END;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AFRA0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : AFRA0001
      Sistema  : Rotinas referentes a Analise de Fraude
      Sigla    : AFRA
      Autor    : Odirlei Busana - AMcom
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Analise de Fraude.  - PRJ335 - Analise de Fraude

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  ---> Formatos utilizados para montagem do Json
  vr_dsformat_data   VARCHAR2(30) := 'DD/MM/RRRR';
  vr_dsformat_dthora VARCHAR2(30) := 'DD/MM/RRRR HH24:MI:SS';
  
  
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

  -- Rotina para buscar conteúdo das mensagens do iBank/SMS
  FUNCTION fn_buscar_valor(pr_campo             IN VARCHAR2
                          ,pr_valores_dinamicos IN VARCHAR2 DEFAULT NULL) -- Máscara #Cooperativa#=1;#Convenio#=123
   RETURN VARCHAR2 IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : fn_buscar_valor
    --  Autor    : Everton
    --  Data     : Abril/2018.                   Ultima atualizacao: --/--/----
    --
    -- Objetivo  : Buscar campo de variavéis dinâmicas
    ---------------------------------------------------------------------------------------------------------------
  
 
    /*Quebra os valores da string recebida por parâmetro*/
    CURSOR cr_parametro IS
      SELECT regexp_substr(parametro, '[^=]+', 1, 1) parametro
            ,regexp_substr(parametro, '[^=]+', 1, 2) valor
        FROM (SELECT regexp_substr(pr_valores_dinamicos, '[^;]+', 1, ROWNUM) parametro
                FROM dual
              CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_valores_dinamicos ,'[^;]+','')) + 1);
  
  BEGIN
  
    -- Sobrescreve os parâmetros
    FOR rw_parametro IN cr_parametro LOOP
      --
      IF UPPER(rw_parametro.parametro) = (pr_campo) THEN
         RETURN rw_parametro.valor;
      END IF;                              
      --                       
    END LOOP;
  
  END fn_buscar_valor;  

  
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
             fra.tptransacao
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
             crapban ban
       WHERE tvl.cdcooper = cop.cdcooper
         AND tvl.cdcooper = ass.cdcooper
         AND tvl.nrdconta = ass.nrdconta 
         AND tvl.cdbccrcb = ban.cdbccxlt
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
    
    vr_basecnpj   VARCHAR2(20);
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
    
    ----> ACCOUNT DEBIT
    vr_basecnpj := fn_base_cnpj_central(rw_craptvl.cdcooper);
    vr_ted.put('DBT_Acct_Bank'       , to_char(vr_basecnpj));     
    vr_ted.put('DBT_Acct_Branch'     , to_char(rw_craptvl.cdagectl));    
    --Tipo da conta de debito        
    vr_ted.put('DBT_Acct_Type'       , rw_craptvl.dstpctdb);        
    vr_ted.put('DBT_Acct_Number'     , to_char(rw_craptvl.nrdconta));        
    vr_ted.put('DBT_Acct_CreditUnion', to_char(rw_craptvl.cdcooper));
    vr_ted.put('DBT_Acct_PA'         , to_char(rw_craptvl.cdagenci));
    
    ----> HOLDER
    vr_ted.put('DBT_Hldr_Type'       , rw_craptvl.dspesemi);
    vr_ted.put('DBT_Hldr_Document'   , rw_craptvl.ds_cpfcgemi);        
    vr_ted.put('DBT_Hldr_Name'       , rw_craptvl.nmpesemi);
    
    --> carregar os telefones do cooperado  
    pc_carregar_fone_json ( pr_cdcooper     => rw_craptvl.cdcooper, --> Codigo da cooperativa
                           pr_nrdconta     => rw_craptvl.nrdconta, --> Numero da conta do cooperaro
                           pr_dsprefix     => 'DBT_Hldr',          --> Prefixo do campo dos telefones no json
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
    vr_ted.put('CDT_Acct_Type'       , rw_craptvl.dstpctcr);
    vr_ted.put('CDT_Acct_Number'     , rw_craptvl.nrcctrcb);
    vr_ted.put('CDT_Acct_CreditUnion', '');
    vr_ted.put('CDT_Hldr_Type'       , rw_craptvl.dspescrd);
    vr_ted.put('CDT_Hldr_Document'   , rw_craptvl.ds_cpfcgrcb);
    vr_ted.put('CDT_Hldr_Name'       , rw_craptvl.nmpesrcb);
    
    ----> TRANSACTION
    vr_ted.put('Trxn_Id'             , to_char(pr_idanalis));
    vr_ted.put('Trxn_Channel'        , rw_craptvl.dsdcanal);
    vr_ted.put('Trxn_MessageCode'    , rw_craptvl.dscodmsg);
    vr_ted.put('Trxn_ControlNumber'  , rw_craptvl.idopetrf);
    vr_ted.put('Trxn_Date'           , to_char(SYSDATE,vr_dsformat_dthora));
    vr_ted.put('Trxn_Value'          , fn_format_number('Trxn_Value',rw_craptvl.vldocrcb));
    vr_ted.put('Trxn_Purpose'        , to_char(rw_craptvl.cdfinrcb) );
    vr_ted.put('Trxn_TransferIdentifier', '');
    vr_ted.put('Trxn_History'        , rw_craptvl.dshistor);
    vr_ted.put('Trxn_ScheduledDate'  , '');
    vr_ted.put('Trxn_ScheduledTime'  , '');
    vr_ted.put('Trxn_PreferenceLevel', '');
    vr_ted.put('Trxn_MovementDate'   , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_ted.put('Trxn_Scheduled'      , '0');
    vr_ted.put('Tracking_IP'         , rw_fraude.iptransacao);
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
             fra.tptransacao
      
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
             crapcti cti
       WHERE lau.cdcooper = cop.cdcooper
         AND lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta 
         AND lau.cddbanco = ban.cdbccxlt         
         AND lau.cdcooper = cti.cdcooper
         AND lau.nrdconta = cti.nrdconta
         AND lau.cddbanco = cti.cddbanco
         AND lau.cdageban = cti.cdageban
         AND lau.nrctadst = cti.nrctatrf 
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
    
    vr_basecnpj      VARCHAR2(20);
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
    
    
    ----> ACCOUNT DEBIT
    vr_basecnpj := fn_base_cnpj_central(rw_craplau.cdcooper);
    vr_ted.put('DBT_Acct_Bank'       , to_char(vr_basecnpj));     
    vr_ted.put('DBT_Acct_Branch'     , to_char(rw_craplau.cdagectl));    
    --Tipo da conta de debito        
    vr_ted.put('DBT_Acct_Type'       , rw_craplau.dstpctdb);        
    vr_ted.put('DBT_Acct_Number'     , to_char(rw_craplau.nrdconta));        
    vr_ted.put('DBT_Acct_CreditUnion', to_char(rw_craplau.cdcooper));
    vr_ted.put('DBT_Acct_PA'         , to_char(rw_craplau.cdagenci));
        
    ----> HOLDER
    vr_ted.put('DBT_Hldr_Type'       , rw_craplau.dspesemi);
    vr_ted.put('DBT_Hldr_Document'   , vr_ds_nrcpfcgc);        
    vr_ted.put('DBT_Hldr_Name'       , vr_nmextttl);
    
    --> carregar os telefones do cooperado  
    pc_carregar_fone_json ( pr_cdcooper     => rw_craplau.cdcooper, --> Codigo da cooperativa
                           pr_nrdconta     => rw_craplau.nrdconta, --> Numero da conta do cooperaro
                           pr_dsprefix     => 'DBT_Hldr',          --> Prefixo do campo dos telefones no json
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
    vr_ted.put('CDT_Acct_Type'       , rw_craplau.dstpctcr);
    vr_ted.put('CDT_Acct_Number'     , rw_craplau.nrcctrcb);
    vr_ted.put('CDT_Acct_CreditUnion', '');
    vr_ted.put('CDT_Hldr_Type'       , rw_craplau.dspescrd);
    vr_ted.put('CDT_Hldr_Document'   , rw_craplau.ds_cpfcgrcb);
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
    vr_ted.put('Trxn_TransferIdentifier', '');
    vr_ted.put('Trxn_History'        , '');
    vr_ted.put('Trxn_ScheduledDate'  , to_char(rw_craplau.dtmvtopg,vr_dsformat_data));
    vr_ted.put('Trxn_ScheduledTime'  , '');
    vr_ted.put('Trxn_PreferenceLevel', '');
    vr_ted.put('Trxn_MovementDate'   , to_char(rw_crapdat.dtmvtocd,vr_dsformat_data));
    vr_ted.put('Trxn_Scheduled'      , '1');
    vr_ted.put('Tracking_IP'         , rw_fraude.iptransacao);  
    vr_ted.put('Trxn_NLS_Start_Date' , to_char(pr_dhdenvio,vr_dsformat_dthora));
    vr_ted.put('Trxn_NLS_End_Date'   , to_char(pr_dhlimana,vr_dsformat_dthora));      
    vr_ted.print();
              
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
  
  --> Rotina responsavel em enviar as analises de fraude pendentes
  PROCEDURE pc_enviar_analise_fraude (pr_idanalis   IN INTEGER DEFAULT 0,
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
             fra.idanalise_fraude,
             fra.tptransacao,
             fra.cdproduto,
             prm.flgemail_entrega
        FROM tbgen_analise_fraude fra,
             tbgen_analise_fraude_param prm
       WHERE fra.cdoperacao  = prm.cdoperacao
         AND fra.tptransacao = prm.tpoperacao
         AND fra.cdstatus_analise  = 0  --> Aguardando envio
         AND fra.cdparecer_analise = 0 --> Pendente 
         AND fra.idanalise_fraude  = decode(pr_idanalis,0,fra.idanalise_fraude,pr_idanalis);
    rw_fraude cr_fraude%ROWTYPE;
    
    CURSOR cr_fraude_lock (pr_rowid ROWID) IS
      SELECT 1
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
        
        vr_dscritic := 'Falha na entrega ao Middleware: '||vr_dscritic_aux;

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
          IF rw_fraude.cdproduto = 30 THEN
            --> Notificar monitoração 
            pc_monitora_ted ( pr_idanalis => rw_fraude.idanalise_fraude); 
          END IF;
        END IF; 
        
        
      END IF;
      
      --> Commit a cada registro, visto que apos enviar dados
      --> para o AYmaru não pode ser dado Rollback
      COMMIT;
      
    END LOOP;
    
    
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
      
  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => 1
                        ,pr_dscritic => substr(pr_dscrilog,1,245)
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => pr_dstransa
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
           nvl(pr_campoalt(vr_idx).dsdadatu,' ') THEN
          --> Gravar log 
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => vr_idx,
                              pr_dsdadant => pr_campoalt(vr_idx).dsdadant,
                              pr_dsdadatu => pr_campoalt(vr_idx).dsdadatu);
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
                 flganalise_manual    
            INTO vr_tab_campo_alt('dhenvio_analise'  ).dsdadatu,
                 vr_tab_campo_alt('dhlimite_analise' ).dsdadatu,
                 vr_tab_campo_alt('dhretorno_analise').dsdadatu,
                 vr_tab_campo_alt('cdstatus_analise' ).dsdadatu,
                 vr_tab_campo_alt('cdparecer_analise').dsdadatu,
                 vr_tab_campo_alt('dsfingerprint'    ).dsdadatu,
                 vr_tab_campo_alt('cdcanal_analise'  ).dsdadatu,
                 vr_tab_campo_alt('flganalise_manual').dsdadatu;  
     
     IF SQL%ROWCOUNT = 0 THEN
       vr_dscritic := 'Registro de analise de fraude não encontrado.';
       RAISE vr_exc_erro;
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
  
  --> Excecutar rotinas referentes a aprovação da analise de fraude
  PROCEDURE pc_aprovacao_analise (pr_idanalis   IN INTEGER,    --> Indicador da analise de fraude
                                  pr_cdcritic  OUT INTEGER,
                                  pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_aprovacao_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Excecutar rotinas referentes a aprovação da analise de fraude
      Alteração : 
        
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
             fra.nrdconta
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
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    
    vr_tab_protocolo gene0006.typ_tab_protocolo;  
    vr_ind           PLS_INTEGER;
    vr_dsinform      crappro.dsinform##3%TYPE;
    vr_cdidtran      crappro.dsinform##3%TYPE;
    
    
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
                              --------- SAIDA  --------
                              ,pr_cdcritic =>  vr_cdcritic               --> Codigo do erro
                              ,pr_dscritic =>  vr_dscritic );	           --> Descricao do erro
                              
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
        
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
      Data     : Novembro/2016.                   Ultima atualizacao: 06/06/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Excecutar rotinas referentes a reprovação da analise de fraude
      Alteração : 
        
      Alteração : 06/06/2017 - Ajustado para usar a data dtmvtocd para estornar a TED.
                               PRJ335- Analise de fraude(Odirlei-AMcom)
        
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
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    
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
    
      --> Rotina para estornar TED reprovada pela analise de frude
      pc_estornar_ted_analise (pr_idanalis  => rw_fraude.idanalise_fraude, -->Id da análise de fraude
                               pr_dtmvtolt  => rw_crapdat.dtmvtocd,  --> Data do sistema
                               pr_inproces  => rw_crapdat.inproces,  --> Indicar de execução do processo batch
                               pr_cdcritic  => vr_cdcritic,  --> Retorno de critica
                               pr_dscritic  => vr_dscritic);          
        
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
                                        pr_idanalise_fraude OUT tbgen_analise_fraude.idanalise_fraude%TYPE, --> identificador único da transação  
                                        pr_dscritic   OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_Criar_Analise_Antifraude        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Novembro/2016.                   Ultima atualizacao: 10/11/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para Inclusao do registro de analise de fraude
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
  BEGIN
     
  
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
                ,cdoperacao) 
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
                
                )RETURNING idanalise_fraude INTO pr_idanalise_fraude ;
       
     
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
             fra.dhenvio_analise,
             fra.dhlimite_analise,
             fra.dhretorno_analise,
             fra.cdstatus_analise,
             fra.cdcanal_analise,
             fra.cdproduto,
             fra.flganalise_manual,
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
    
    vr_dstransa craplgm.dstransa%TYPE;  
    vr_campoalt typ_tab_campo_alt;
    vr_nmarqlog VARCHAR2(200);
    
    ----------> SUB-ROTINAS <----------
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
                              pr_dscrilog => 'Falha ao enviar TED para o SPB na procedure AFRA0001.pc_reg_reto_analise_antifraude: '||vr_dsdetcri,
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
    
    --> Tratar erro na aprovação
    
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
           
           IF rw_fraude.cdproduto = 30 THEN                
              --> Notificar monitoração 
              pc_monitora_ted ( pr_idanalis => pr_idanalis);
           END IF;   

         END IF; 
      
      END IF;    
    
    END pc_tratar_erro_fila_excep;
    
    
  BEGIN
    BEGIN
    
    vr_campoalt.delete;
    vr_dstransa := 'Retorno paracer da Analise de Fraude';
    
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
                
                IF rw_fraude.cdproduto = 30 THEN                
                   --> Notificar monitoração 
                   pc_monitora_ted ( pr_idanalis => pr_idanalis);
                END IF; 
               
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
                RAISE vr_exc_erro;
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
                                                       ' - AFRA0001.pc_reg_reto_analise_antifraude --> ' || pr_dscritic,
                                    pr_nmarqlog     => vr_nmarqlog);
      
      END IF;
     
      COMMIT;

    WHEN vr_exc_apro THEN
        --> Caso não consiga aprovar, tentará reprovar a analise
        ROLLBACK; 
        pc_tratar_erro_aprovacao;
      
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
             fra.tptransacao,
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
   
    
    vr_dstransa craplgm.dstransa%TYPE;  
    vr_campoalt typ_tab_campo_alt;
    vr_cdparece tbgen_analise_fraude.cdparecer_analise%TYPE;
    
    vr_nmarqlog VARCHAR2(500)   := NULL;
    vr_dscrilog VARCHAR2(500)   := NULL;
    vr_cdcanal  INTEGER         := NULL;
  BEGIN
  
    vr_dstransa := 'Confirmação de entrega parecer da Analise de Fraude';
    
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
                                pr_tpalerta   => 2, --> Tipo de alerta 1 - Entrega midware, 2 - Retorno falha  Entrega OFFSA
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
        --> TED 
        IF rw_fraude.cdproduto = 30 THEN
           --> Notificar monitoração 
           pc_monitora_ted ( pr_idanalis => pr_idanalis);

        END IF;   
      
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
      pc_mensagem_estorno (pr_cdcooper  => rw_craptvl.cdcooper,
                           pr_nrdconta  => rw_craptvl.nrdconta,
                           pr_inpessoa  => rw_craptvl.inpessoa,
                           pr_idseqttl  => rw_craptvl.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
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
      pc_mensagem_estorno (pr_cdcooper  => rw_craplau.cdcooper,
                           pr_nrdconta  => rw_craplau.nrdconta,
                           pr_inpessoa  => rw_craplau.inpessoa,
                           pr_idseqttl  => rw_craplau.idseqttl,
                           pr_cdproduto => rw_fraude.cdproduto,
                           pr_tptransacao => rw_fraude.tptransacao, --> Tipo de transação (1-online/ 2-agendada)                                  
                           pr_vldinami  => vr_vldinami,             --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
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
  
  --> Rotina para geração de mensagem de estorno para o cooperado
  PROCEDURE pc_mensagem_estorno (pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                 pr_nrdconta  IN crapass.nrdconta%TYPE,
                                 pr_inpessoa  IN crapass.inpessoa%TYPE,
                                 pr_idseqttl  IN crapttl.idseqttl%TYPE,
                                 pr_cdproduto IN tbgen_analise_fraude.cdproduto%TYPE,
                                 pr_tptransacao IN tbgen_analise_fraude.tptransacao%TYPE, --> Tipo de transação (1-online/ 2-agendada)                                  
                                 pr_vldinami  IN VARCHAR2, --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                 pr_cdcritic  OUT INTEGER,
                                 pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_mensagem_estorno        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Janeiro/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pela geração de mensagem de estorno para o cooperado
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> buscar dados da cooper
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; 
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --> Buscar nome do associado
    CURSOR cr_crapass IS 
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
         
    --> Buscar nome do titular
    CURSOR cr_crapttl( pr_cdcooper crapttl.cdcooper%TYPE,
                       pr_nrdconta crapttl.nrdconta%TYPE,
                       pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT ttl.nmextttl
        FROM crapttl ttl 
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;    
    
    --Selecionar titulares com senhas ativas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.cdsitsnh = 1
         AND crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    vr_dsdassun crapmsg.dsdassun%TYPE;
    vr_dsdplchv crapmsg.dsdplchv%TYPE;
    vr_dsdmensg crapmsg.dsdmensg%TYPE;
    vr_cdtipmsg tbgen_tipo_mensagem.cdtipo_mensagem%TYPE;
    vr_vldinami VARCHAR2(1000);
    vr_nmprimtl crapass.nmprimtl%TYPE;

    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE;
    
    
  BEGIN
  
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
    
    IF pr_cdproduto = 30 THEN
      --> Online
      IF pr_tptransacao = 1 THEN
        vr_dsdassun := 'TED Estornada';
      ELSE
        vr_dsdassun := 'Agendamento de TED Estornado';
      END IF;
      vr_dsdplchv := 'TED';
    END IF;
    
    --> Online
    IF pr_tptransacao = 1 THEN
      IF pr_inpessoa = 1 THEN
        vr_cdtipmsg := 21;
        vr_notif_origem   := 5;
        vr_notif_motivo   := 1; 
        vr_variaveis_notif('#valor')    := fn_buscar_valor('#VALOR#',pr_vldinami);
      ELSE
        vr_cdtipmsg := 18;
        vr_notif_origem   := 5;
        vr_notif_motivo   := 2;  
        vr_variaveis_notif('#valor')    := fn_buscar_valor('#VALOR#',pr_vldinami);
      END IF;
    --> Agendada
    ELSIF pr_tptransacao = 2 THEN
      IF pr_inpessoa = 1 THEN
        vr_cdtipmsg := 19;
        vr_notif_origem   := 3;
        vr_notif_motivo   := 10; 
        vr_variaveis_notif('#valor')    := fn_buscar_valor('#VALOR#',pr_vldinami);
        vr_variaveis_notif('#dtdebito') := fn_buscar_valor('#DTDEBITO#',pr_vldinami);                   
      ELSE
        vr_cdtipmsg := 20;
        vr_notif_origem   := 3;
        vr_notif_motivo   := 11;  
        vr_variaveis_notif('#valor')    := fn_buscar_valor('#VALOR#',pr_vldinami);
        vr_variaveis_notif('#dtdebito') := fn_buscar_valor('#DTDEBITO#',pr_vldinami);                   

      END IF;
    END IF; 
    
    --> Buscar pessoas que possuem acesso a conta
    FOR rw_crapsnh IN cr_crapsnh (pr_cdcooper  => pr_cdcooper
                                 ,pr_nrdconta  => pr_nrdconta) LOOP
                                   
      IF pr_inpessoa = 1 AND rw_crapsnh.idseqttl > 0 THEN
        OPEN cr_crapttl(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => rw_crapsnh.idseqttl);
        FETCH cr_crapttl INTO vr_nmprimtl;
        CLOSE cr_crapttl;
      ELSE
        OPEN cr_crapass;
        FETCH cr_crapass INTO vr_nmprimtl;
        CLOSE cr_crapass;    
      END IF;
    
      vr_vldinami := '#NOME#='||vr_nmprimtl||';'||
                     pr_vldinami;
    
      --> buscar mensagem 
      vr_dsdmensg := gene0003.fn_buscar_mensagem(pr_cdcooper          => pr_cdcooper
                                                ,pr_cdproduto         => pr_cdproduto
                                                ,pr_cdtipo_mensagem   => vr_cdtipmsg
                                                ,pr_sms               => 0             -- Indicador se mensagem é SMS (pois deve cortar em 160 caracteres)
                                                ,pr_valores_dinamicos => vr_vldinami); -- Máscara #Cooperativa#=1;#Convenio#=123    
    
      --> Criar mensagem
      GENE0003.pc_gerar_mensagem ( pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => rw_crapsnh.idseqttl
                                  ,pr_cdprogra => 'AFRA0001'
                                  ,pr_inpriori => 1
                                  ,pr_dsdmensg => vr_dsdmensg
                                  ,pr_dsdassun => vr_dsdassun
                                  ,pr_dsdremet => rw_crapcop.nmrescop
                                  ,pr_dsdplchv => vr_dsdplchv
                                  ,pr_cdoperad => ''
                                  ,pr_cdcadmsg => 0
                                  ,pr_dscritic => vr_dscritic);
     
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      --
      -- Cria uma notificação
      noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                  ,pr_cdmotivo_mensagem => vr_notif_motivo
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => rw_crapsnh.idseqttl
                                  ,pr_variaveis => vr_variaveis_notif);      
      --
    END LOOP;
  
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
      pr_dscritic := 'Não foi gerar mensagem de estorno ao cooperado: '||SQLERRM;
  END pc_mensagem_estorno; 
  
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
  
  --> Retornar a data limite da analise
  PROCEDURE pc_ret_data_limite_analise ( pr_cdoperac  IN tbcc_operacao.cdoperacao%TYPE  --> Codigo da operação
                                        ,pr_tpoperac  IN INTEGER                        --> Tipo de operacao 1 -online 2-agendamento
                                        ,pr_dhoperac  IN TIMESTAMP                      --> Data hora da operação      
                                        ,pr_dtefeope  IN DATE DEFAULT NULL              --> Data que sera efetivada a operacao agendada
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
      SELECT w.hrretencao
        FROM tbgen_analise_fraude_param w 
       WHERE w.cdoperacao = pr_cdoperac
         AND w.tpoperacao = pr_tpoperac;
    rw_afraprm cr_afraprm%ROWTYPE;     
    
    --> Buscar intervalo Online valida hora
     CURSOR cr_afrainter IS 
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
  
    -- Online
    IF pr_tpoperac = 1 THEN
    
      OPEN cr_afrainter;
      FETCH cr_afrainter INTO rw_afrainter;
      --> Se nao localizar registro, usar valor padrão
      IF cr_afrainter%NOTFOUND THEN
        CLOSE cr_afrainter;
        rw_afrainter.qtdminutos_retencao := 10;
      ELSE
        CLOSE cr_afrainter;
      END IF;      
    
      --> Calcular tempo limite
      pr_dhlimana := pr_dhoperac + (rw_afrainter.qtdminutos_retencao / 24 / 60);
      pr_qtsegret := rw_afrainter.qtdminutos_retencao * 60;
      
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
    
    END IF;
  
    
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      
      pr_dscritic := 'Não foi possivel calcular a data limite da analise: '||SQLERRM;
  END pc_ret_data_limite_analise;   
  
  /* Procedimento para realizar monitoração de fraudes nas TEDs */
  PROCEDURE pc_monitora_ted ( pr_idanalis IN INTEGER ) IS
                            
     
    /* ..........................................................................
    --
    --  Programa : pc_monitora_ted       
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2016.                   Ultima atualizacao: 02/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada para realizar monitoração de fraudes nas TEDs
    --
    --  Alteração  : 07/04/2016 - Criacao dos parametros PR_INPESSOA e PR_INTIPCTA. 
    --                            Buscar informacoes que vinham da CRAPPRM e agora
    --                            vem da CRAPCOP. (Jaison/Marcos - SUPERO)
    --
    --               02/05/2016 - Se valor da TED ou do Limite ficarem abaixo dos
    --                            monitoraveis, buscar PRM e se existir, mandar email
    --                            para o email encontrado, senao nao havera envio.
    --                            (Jaison/Marcos - SUPERO)
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    
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
             fra.tptransacao
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações da TED
    CURSOR cr_craptvl (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tvl.cdcooper,
             tvl.nrdconta,
             cop.nmrescop,
             tvl.idseqttl,
             tvl.cdbccrcb,
             tvl.cdagercb,
             tvl.nrcctrcb,
             tvl.nmpesrcb,
             tvl.cpfcgrcb,
             tvl.vldocrcb,
             decode(substr(tvl.idopetrf, length(tvl.idopetrf), 1), 'M',1,0) flmobile,
             tvl.flgpescr,
             tvl.tpdctacr
     
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
    
    --> Buscar informações do agendamento de TED
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS                      
               
      SELECT lau.cdcooper,
             lau.nrdconta,
             cop.nmrescop,
             lau.idseqttl,
             lau.cddbanco,
             lau.cdageban,
             lau.nrctadst,
             cti.nmtitula,
             cti.nrcpfcgc,
             lau.vllanaut,
             lau.flmobile,
             cti.inpessoa,
             cti.intipcta
              
        FROM craplau lau,
             crapcop cop,
             crapass ass,
             crapban ban,
             crapcti cti
       WHERE lau.cdcooper = cop.cdcooper
         AND lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta 
         AND lau.cddbanco = ban.cdbccxlt         
         AND lau.cdcooper = cti.cdcooper
         AND lau.nrdconta = cti.nrdconta
         AND lau.cddbanco = cti.cddbanco
         AND lau.cdageban = cti.cdageban
         AND lau.nrctadst = cti.nrctatrf 
         AND lau.cdtiptra = 4    
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
    
    --> Selecionar informacoes de senhas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%type
                      ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.vllimted
      FROM crapsnh
      WHERE crapsnh.cdcooper = pr_cdcooper
      AND   crapsnh.nrdconta = pr_nrdconta
      AND   crapsnh.idseqttl = pr_idseqttl
      AND   crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;
    
    --> Buscar dados a agencia destino
    CURSOR cr_crapagb(pr_cddbanco crapagb.cddbanco%TYPE,
                      pr_cdageban crapagb.cdageban%TYPE) IS
      SELECT ban.nmresbcc
            ,agb.nmageban
            ,caf.cdufresd
        FROM crapban ban,
             crapagb agb,
             crapcaf caf
       WHERE agb.cddbanco = pr_cddbanco
         AND agb.cdageban = pr_cdageban
         AND agb.cddbanco = ban.cdbccxlt
         AND agb.cdcidade = caf.cdcidade;         
    rw_crapagb cr_crapagb%ROWTYPE;
    
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa,
             ass.nmprimtl,
             ass.nrcpfcgc,
             ass.cdagenci,
             age.nmresage
        FROM crapass ass
            ,crapage age
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;
    
    vr_crabass BOOLEAN;
    
    --Selecionar informacoes dos titulares da conta
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
                      ,pr_nrdconta IN crapttl.nrdconta%TYPE
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT crapttl.cdcooper
            ,crapttl.nrdconta
            ,crapttl.cdempres
            ,crapttl.cdturnos
            ,crapttl.nmextttl
            ,crapttl.idseqttl
      FROM crapttl crapttl
      WHERE crapttl.cdcooper = pr_cdcooper
      AND   crapttl.nrdconta = pr_nrdconta
      AND   (
            (trim(pr_idseqttl) IS NOT NULL AND crapttl.idseqttl = pr_idseqttl) OR
            (trim(pr_idseqttl) IS NULL)
            );
    rw_crapttl cr_crapttl%ROWTYPE;
    
    --Selecionar dados Pessoa Juridica
    CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                      ,pr_nrdconta IN crapjur.nrdconta%type) IS
      SELECT crapjur.nmextttl
      FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
      AND   crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    --Selecionar Avalistas
    CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                      ,pr_nrdconta IN crapavt.nrdconta%type
                      ,pr_tpctrato IN crapavt.tpctrato%type) IS
      SELECT crapavt.nrdctato
            ,crapavt.nmdavali
            ,crapavt.cdcooper
      FROM crapavt
      WHERE crapavt.cdcooper = pr_cdcooper
      AND   crapavt.nrdconta = pr_nrdconta
      AND   crapavt.tpctrato = pr_tpctrato;
    
    --Selecionar os telefones do titular
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                      ,pr_nrdconta IN craptfc.nrdconta%type) IS
      SELECT craptfc.nrdddtfc
            ,craptfc.nrtelefo
            ,craptfc.nmpescto
      FROM craptfc
      WHERE craptfc.cdcooper = pr_cdcooper
      AND   craptfc.nrdconta = pr_nrdconta;
    rw_craptfc cr_craptfc%ROWTYPE;
    
    --Selecionar os dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.dsestted
            ,crapcop.vlinited
            ,crapcop.vlmnlmtd
            ,crapcop.flmobted
            ,crapcop.flmstted
            ,crapcop.flnvfted
            ,crapcop.flmntage
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Buscar se o favorecido esta cadastrado na CRAPCTI ha mais de um dia
    CURSOR cr_crapcti (pr_cdcooper IN crapcti.cdcooper%TYPE
                      ,pr_nrdconta IN crapcti.nrdconta%TYPE
                      ,pr_cddbanco IN crapcti.cddbanco%TYPE
                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE
                      ,pr_cdageban IN crapcti.cdageban%TYPE
                      ,pr_inpessoa IN crapcti.inpessoa%TYPE
                      ,pr_intipcta IN crapcti.intipcta%TYPE
                      ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE) IS
      SELECT COUNT(1)
        FROM crapcti cti
       WHERE cti.cdcooper = pr_cdcooper
         AND cti.nrdconta = pr_nrdconta
         AND cti.cddbanco = pr_cddbanco
         AND cti.nrctatrf = pr_nrctatrf
         AND cti.cdageban = pr_cdageban
         AND cti.inpessoa = pr_inpessoa
         AND cti.intipcta = pr_intipcta
         AND cti.nrcpfcgc = pr_nrcpfcgc
         AND TRUNC(cti.dttransa) < TRUNC(SYSDATE); -- Cadastrados ha mais de um dia
    
    ---------------> VARIAVEIS <-----------------
    vr_exc_naomonit EXCEPTION;
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    
    vr_vlr_minmonted    NUMBER := 0;
    vr_vlr_minported    NUMBER := 0;
    vr_flmonmob         NUMBER := 0;
    vr_dsufsmon         VARCHAR2(4000)  := NULL;
    vr_dsassunt         VARCHAR2(500)   := NULL;
    vr_conteudo         VARCHAR2(32000) := NULL;
    vr_email_dest       VARCHAR2(500)   := NULL;
    vr_qtregistro       NUMBER;
    
    vr_cdcooper crapcop.cdcooper%TYPE;   --> Codigo da cooperativa                            
    vr_nmrescop crapcop.nmrescop%TYPE;   --> Nome da cooperativa 
    vr_nrdconta crapttl.nrdconta%TYPE;   --> Numero da conta
    vr_idseqttl crapttl.idseqttl%TYPE;   --> Sequencial titular                             
    vr_cddbanco crapcti.cddbanco%TYPE;   --> Codigo do banco                             
    vr_cdageban crapcti.cdageban%TYPE;   --> codigo da agencia bancaria. 
    vr_nrctatrf crapcti.nrctatrf%TYPE;   --> conta que recebe a transferencia. 
    vr_nmtitula crapcti.nmtitula%TYPE;   --> nome do titular da conta. 
    vr_nrcpfcgc crapcti.nrcpfcgc%TYPE;   --> cpf/cnpj do titular da conta.  
    vr_vllanmto craplcm.vllanmto%TYPE;   --> Valor do lançamento
    vr_flmobile INTEGER;                 --> Indicador se origem é do Mobile
    vr_iptransa VARCHAR2(100);           --> IP da transacao no IBank/mobile
    vr_inpessoa crapcti.inpessoa%TYPE;   --> Tipo de pessoa da conta
    vr_intipcta crapcti.intipcta%TYPE;   --> Tipo da conta
    vr_idagenda INTEGER;                 --> Tipo de agendamento
    
    PRAGMA AUTONOMOUS_TRANSACTION;
      
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
    
    -- Se for TED Online
    IF rw_fraude.tptransacao = 1 THEN
  
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
      
      vr_cdcooper := rw_fraude.cdcooper;   --> Codigo da cooperativa                            
      vr_nmrescop := rw_craptvl.nmrescop;  --> Nome da cooperativa 
      vr_nrdconta := rw_craptvl.nrdconta;  --> Numero da conta
      vr_idseqttl := rw_craptvl.idseqttl;  --> Sequencial titular                             
      vr_cddbanco := rw_craptvl.cdbccrcb;  --> Codigo do banco                             
      vr_cdageban := rw_craptvl.cdagercb;  --> codigo da agencia bancaria. 
      vr_nrctatrf := rw_craptvl.nrcctrcb;  --> conta que recebe a transferencia. 
      vr_nmtitula := rw_craptvl.nmpesrcb;  --> nome do titular da conta. 
      vr_nrcpfcgc := rw_craptvl.cpfcgrcb;  --> cpf/cnpj do titular da conta.  
      vr_vllanmto := rw_craptvl.vldocrcb;  --> Valor do lançamento
      vr_flmobile := rw_craptvl.flmobile;  --> Indicador se origem é do Mobile
      vr_iptransa := rw_fraude.iptransacao;   --> IP da transacao no IBank/mobile
      vr_inpessoa := rw_craptvl.flgpescr;  --> Tipo de pessoa da conta
      vr_intipcta := rw_craptvl.tpdctacr;  --> Tipo da conta
      vr_idagenda := 1;                    --> Tipo de agendamento      
      
    ELSE
      
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
      
      vr_cdcooper := rw_fraude.cdcooper;   --> Codigo da cooperativa                            
      vr_nmrescop := rw_craplau.nmrescop;  --> Nome da cooperativa 
      vr_nrdconta := rw_craplau.nrdconta;  --> Numero da conta
      vr_idseqttl := rw_craplau.idseqttl;  --> Sequencial titular                             
      vr_cddbanco := rw_craplau.cddbanco;  --> Codigo do banco                             
      vr_cdageban := rw_craplau.cdageban;  --> codigo da agencia bancaria. 
      vr_nrctatrf := rw_craplau.nrctadst;  --> conta que recebe a transferencia. 
      vr_nmtitula := rw_craplau.nmtitula;  --> nome do titular da conta. 
      vr_nrcpfcgc := rw_craplau.nrcpfcgc;  --> cpf/cnpj do titular da conta.  
      vr_vllanmto := rw_craplau.vllanaut;  --> Valor do lançamento
      vr_flmobile := rw_craplau.flmobile;  --> Indicador se origem é do Mobile
      vr_iptransa := rw_fraude.iptransacao;   --> IP da transacao no IBank/mobile
      vr_inpessoa := rw_craplau.inpessoa;  --> Tipo de pessoa da conta
      vr_intipcta := rw_craplau.intipcta;  --> Tipo da conta
      vr_idagenda := 1;                   --> Tipo de agendamento
    
    END IF;
  
  
    vr_dsassunt := (CASE 
                      WHEN vr_idagenda = 1 THEN 'TED/'
                      ELSE                      'Agendamento de TED/'
                    END) ||
                    vr_nmrescop||'/'|| 
                   ltrim(gene0002.fn_mask_conta(vr_nrdconta))||
                   '/R$ '||TRIM(to_char(vr_vllanmto,'fm999g999g990d00'));
  
    --> Busca dados da cooperativa
    OPEN  cr_crapcop(pr_cdcooper => vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
  
    --> Buscar valor de limite minimo de monitoramento da TED
    vr_vlr_minmonted := rw_crapcop.vlmnlmtd;
  
    --> Buscar valor minimo de monitoramento por TED
    vr_vlr_minported := rw_crapcop.vlinited;
    
    --> Verificar se deve monitorar TEDs mobile
    vr_flmonmob := rw_crapcop.flmobted;
    
    --> Buscar lista de UFs a serem monitoradas
    vr_dsufsmon := rw_crapcop.dsestted;        
                                              
    ------------> INICIAR VALIDAÇÔES DO TED <------------
    
    --> Verificar se precisa monitorar TEDs oriundas do mobile
    IF vr_flmobile = 1 AND vr_flmonmob = 0 THEN
      --> sair sem monitorar
      RAISE vr_exc_naomonit;
    END IF;
    
    --> Buscar informacoes da agencia destino
    OPEN cr_crapagb (pr_cddbanco => vr_cddbanco,
                     pr_cdageban => vr_cdageban);
    FETCH cr_crapagb INTO rw_crapagb;    
    IF cr_crapagb%NOTFOUND THEN
      CLOSE cr_crapagb;
      vr_dscritic := 'Nao foi possivel localizar dados da agencia destino.';     
      RAISE vr_exc_erro;      
    END IF;
    CLOSE cr_crapagb;
    
    --> caso esteja nulo deve considerar todos os UFs
    IF TRIM(vr_dsufsmon) IS NOT NULL THEN
      -- Verificar se estado da agencia destino consta a lista de monitoracao
      IF gene0002.fn_existe_valor(pr_base     => upper(vr_dsufsmon), 
                                  pr_busca    => upper(rw_crapagb.cdufresd),
                                  pr_delimite => ';') = 'N' THEN
        --> sair sem monitorar
        RAISE vr_exc_naomonit;
      END IF;
    END IF;
    
    --> Se eh para trazer somente novos favorecidos
    IF rw_crapcop.flnvfted = 1 THEN
      -- Buscar se o favorecido esta cadastrado na CRAPCTI ha mais de um dia
      OPEN cr_crapcti(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => vr_nrdconta
                     ,pr_cddbanco => vr_cddbanco
                     ,pr_nrctatrf => vr_nrctatrf
                     ,pr_cdageban => vr_cdageban
                     ,pr_inpessoa => vr_inpessoa
                     ,pr_intipcta => vr_intipcta
                     ,pr_nrcpfcgc => vr_nrcpfcgc);
      FETCH cr_crapcti INTO vr_qtregistro;
      -- Fecha cursor
      CLOSE cr_crapcti;
      -- Esta cadastrado na CRAPCTI ha mais de um dia
      IF vr_qtregistro > 0 THEN
        --> sair sem monitorar
        RAISE vr_exc_naomonit;
      END IF;
    END IF;
                   
    -- buscar dados do cooperado
    OPEN cr_crapass (pr_cdcooper => vr_cdcooper,
                     pr_nrdconta => vr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      vr_dscritic:= 'Associado nao cadastrado.';
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
     
    --> Se nao houver monitoracao para TEDs da mesma titularidade
    IF rw_crapcop.flmstted = 0 AND rw_crapass.nrcpfcgc = vr_nrcpfcgc THEN
      --> sair sem monitorar
      RAISE vr_exc_naomonit;
    END IF;
    
    --> Se nao é para monitorar agendamento de TED
    IF vr_idagenda > 1 AND rw_crapcop.flmntage = 0 THEN
      --> sair sem monitorar
      RAISE vr_exc_naomonit;
    END IF;    
    
    --> Buscar limite de TED do cooperado
    OPEN cr_crapsnh (pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => vr_nrdconta
                    ,pr_idseqttl => vr_idseqttl);
    FETCH cr_crapsnh INTO rw_crapsnh;
    --> caso nao encontrar o limite de TED
    IF cr_crapsnh%NOTFOUND THEN
      CLOSE cr_crapsnh;
      vr_dscritic := 'Nao foi possivel localizar limite de TED do cooperado.';
      RAISE vr_exc_erro;      
    END IF;
    CLOSE cr_crapsnh;
 
    --> Se o valor da TED é menor que o valor minimo para monitoracao
    IF vr_vllanmto < vr_vlr_minported
      OR
      --> Se o valor de limite de ted é menor que o valor de limite minimo para monitoracao
      rw_crapsnh.vllimted < vr_vlr_minmonted
    THEN
      --Buscar destinatario email
      vr_email_dest:= gene0001.fn_param_sistema('CRED',vr_cdcooper,'MONITORA_TED_ABAIXO');
           
      --Se nao encontrou destinatario
      IF vr_email_dest IS NULL THEN
        --> sair sem monitorar
        RAISE vr_exc_naomonit;
      END IF;
    ELSE
      --Buscar destinatario email
      vr_email_dest:= gene0001.fn_param_sistema('CRED',vr_cdcooper,'MONITORAMENTO_TED');

      --Se nao encontrou destinatario
      IF vr_email_dest IS NULL THEN
        --Montar mensagem de erro
        vr_dscritic:= 'Nao foi encontrado destinatario para os e-mails de monitoramento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    ------------> MONTAR CORPO E-MAIL <------------
    
    vr_conteudo := 'Dados do Favorecido: '|| vr_nmtitula ||'<br>'||
                   'Banco: '       || vr_cddbanco ||'-'|| rw_crapagb.nmresbcc ||'<br>'||
                   'Agencia: '     || vr_cdageban||'-'|| rw_crapagb.nmageban ||'<br>'||
                   'Estado: '      || rw_crapagb.cdufresd ||'<br>'||
                   'Conta: '       || gene0002.fn_mask_conta(vr_nrctatrf)||'<br>'||
                   'IP Transacao: '|| vr_iptransa ||'<br>'||
                   'Limite diário TED: R$'|| to_char(rw_crapsnh.vllimted,'fm999g999g999g990d00')||'<br>'||
                   'Dados cooperado: '|| gene0002.fn_mask_conta(vr_nrdconta)||'<br>'||
                   'PA: '|| rw_crapass.cdagenci ||' - '||rw_crapass.nmresage|| '<br>';
     
    -- Se for pessoa fisica
    IF rw_crapass.inpessoa = 1 THEN
      --> Lista todos os titulares
      FOR rw_crapttl IN cr_crapttl (pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_idseqttl => NULL) LOOP
        --Concatenar Conteudo
        vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                   ': '||rw_crapttl.nmextttl|| '<BR>';
      END LOOP;
    
    -- Se for pessoa juridica
    ELSIF rw_crapass.inpessoa = 2 THEN
      --> Lista o nome da empresa 
      OPEN cr_crapjur (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      --Se Encontrou
      IF cr_crapjur%FOUND THEN
        --Concatenar o nome da empresa
        vr_conteudo:= vr_conteudo||'Empresa: '|| rw_crapjur.nmextttl;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapjur;
      --Concatenar Procuradores/Representantes
      vr_conteudo:= vr_conteudo||'<BR><BR>'||
                    'Procuradores/Representantes: <BR>';
    
      --> Lista os procuradores/representantes 
      FOR rw_crapavt IN cr_crapavt (pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_tpctrato => 6) LOOP
        vr_crabass:= FALSE;
        --Se tem Contato
        IF rw_crapavt.nrdctato <> 0 THEN
          OPEN cr_crapass (pr_cdcooper => rw_crapavt.cdcooper
                          ,pr_nrdconta => rw_crapavt.nrdctato);
          --Posicionar Proximo Registro
          FETCH cr_crapass INTO rw_crabass;
          --Se Encontrou
          vr_crabass:= cr_crapass%FOUND;
          --Fechar Cursor
          CLOSE cr_crapass;
        END IF;
        IF rw_crapavt.nrdctato <> 0 AND vr_crabass THEN
          --Concatenar nome avalista
          vr_conteudo:= vr_conteudo||rw_crabass.nmprimtl|| '<BR>';
        ELSE
          --Concatenar nome avalista
          vr_conteudo:= vr_conteudo||rw_crapavt.nmdavali|| '<BR>';
        END IF;
      END LOOP;    
    END IF; --> Fim IF inpessoa
    
    --> Fones 
    vr_conteudo:= vr_conteudo|| '<BR>Fones:<BR>';
    --Encontrar numeros de telefone
    FOR rw_craptfc IN cr_craptfc (pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => vr_nrdconta) LOOP
      --Montar Conteudo
      vr_conteudo:= vr_conteudo||'(' ||rw_craptfc.nrdddtfc|| ') '
                                     ||rw_craptfc.nrtelefo|| ' - '
                                     ||rw_craptfc.nmpescto|| '<BR>';
    END LOOP;
    
    vr_conteudo := vr_conteudo ||'<BR>'||'Valor TED: R$ '|| to_char(vr_vllanmto,'fm999g999g999g990d00')||'<br>';
    
    --Enviar Email
    GENE0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper    --> Cooperativa conectada
                              ,pr_cdprogra        => 'PAGA0002'     --> Programa conectado
                              ,pr_des_destino     => vr_email_dest  --> Um ou mais detinatários separados por ';' ou ','
                              ,pr_des_assunto     => vr_dsassunt    --> Assunto do e-mail
                              ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                              ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                              ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                              ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                              ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                              ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                              ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                              ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    
  EXCEPTION
    -- sair sem gerar monitoracao
    WHEN vr_exc_naomonit THEN
      NULL;
      COMMIT;
    WHEN vr_exc_erro THEN
      ROLLBACK;
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - AFRA0001.pc_monitora_ted --> '|| vr_dsassunt ||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));  
      
      COMMIT;
    WHEN OTHERS THEN
      ROLLBACK;
      vr_dscritic := SQLerrm;  
    
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - AFRA0001.pc_monitora_ted --> '|| vr_dsassunt ||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));  
      COMMIT;
  END pc_monitora_ted;        
  
END;
/
