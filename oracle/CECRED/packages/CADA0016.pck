CREATE OR REPLACE PACKAGE CECRED.CADA0016 is
  /*---------------------------------------------------------------------------------------------------------------
   --
  --  Programa : CADA0016
  --  Sistema  : CRM
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Agosto/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para atualizar informações de cadastro da estrutura nova para 
  --             estrutura antiga
  --
  -- Alteracoes:   
  --    
  --  
  ---------------------------------------------------------------------------------------------------------------*/
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------  
  TYPE typ_rec_contas IS RECORD
                      (cdcooper crapass.cdcooper%TYPE, 
                       nrdconta crapass.nrdconta%TYPE,
                       idseqttl crapttl.idseqttl%TYPE,
                       idpessoa tbcadast_pessoa.idpessoa%TYPE);
                       
  TYPE typ_tab_contas IS TABLE OF typ_rec_contas
                      INDEX BY PLS_INTEGER;
                      
  --> Type para armazenar bens da pessoa                    
  TYPE typ_tab_bens IS TABLE OF tbcadast_pessoa_bem%ROWTYPE
       INDEX BY PLS_INTEGER;
                      
  --------->>>> PROCUDURES/FUNCTIONS <<<<----------
  /*****************************************************************************/
  /**         Procedure atualizar modulo de sessao da trigger                 **/
  /*****************************************************************************/
  PROCEDURE pc_sessao_trigger( pr_tpmodule   IN INTEGER,        --> tipo do modulo (1-inicializa,2-finaliza)          
                               pr_dsmodule   IN OUT VARCHAR2);  --> Nome do mudulo                                 
  
  
  --> Funcao para retornar o nome da pessoa de relacao com a pessoa principal
  FUNCTION fn_nome_pes_relacao ( pr_idpessoa   IN tbcadast_pessoa.idpessoa%TYPE,            --> Identificador de pessoa 
                                 pr_tprelacao  IN tbcadast_pessoa_relacao.tprelacao%TYPE    --> Tipo de relacao
                               ) RETURN VARCHAR2; 
                               
  /*****************************************************************************/
  /**            Procedure para atualizar endereço na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_endereco( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE                   --> Identificador de pessoa
                                 ,pr_nrseq_endereco   IN tbcadast_pessoa_endereco.nrseq_endereco%TYPE    --> Sequencial do endereco
                                 ,pr_tpoperacao       IN INTEGER                                         --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_endereco_old     IN tbcadast_pessoa_endereco%ROWTYPE                --> Dados anteriores
                                 ,pr_endereco_new     IN tbcadast_pessoa_endereco%ROWTYPE                --> Dados novos
                                 ,pr_dscritic        OUT VARCHAR2);                                      --> Retornar Critica   
  
  /*****************************************************************************/
  /**            Procedure para atualizar telefone na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_telefone( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE                   --> Identificador de pessoa
                                 ,pr_nrseq_telefone   IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE    --> Sequencial do telefone
                                 ,pr_tpoperacao       IN INTEGER                                         --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_telefone_old     IN tbcadast_pessoa_telefone%ROWTYPE                --> Dados anteriores
                                 ,pr_telefone_new     IN tbcadast_pessoa_telefone%ROWTYPE                --> Dados novos
                                 ,pr_dscritic        OUT VARCHAR2 );                                     --> Retornar Critica 
  
  /*****************************************************************************/
  /**            Procedure para atualizar email na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_email(pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa
                             ,pr_nrseq_email   IN tbcadast_pessoa_email.nrseq_email%TYPE    --> Sequencial do email
                             ,pr_tpoperacao    IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_email_old     IN tbcadast_pessoa_email%ROWTYPE             --> Dados anteriores
                             ,pr_email_new     IN tbcadast_pessoa_email%ROWTYPE             --> Dados novos
                             ,pr_dscritic      OUT VARCHAR2 );                              --> Retornar Critica 
  
  /*****************************************************************************/
  /**   Procedure para atualizar politicamente exposto na estrutura antiga    **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_polexp( pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                               ,pr_tpoperacao    IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_polexp_old    IN tbcadast_pessoa_polexp%ROWTYPE            --> Dados anteriores
                               ,pr_polexp_new    IN tbcadast_pessoa_polexp%ROWTYPE            --> Dados novos
                               ,pr_dscritic      OUT VARCHAR2);                               --> Retornar Critica 

  /*****************************************************************************/
  /**     Procedure para atualizar renda complementar na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_rendacompl( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                   ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                   ,pr_rendacompl_old    IN tbcadast_pessoa_rendacompl%ROWTYPE        --> Dados anteriores
                                   ,pr_rendacompl_new    IN tbcadast_pessoa_rendacompl%ROWTYPE        --> Dados novos
                                   ,pr_dscritic         OUT VARCHAR2);                                --> Retornar Critica                                
                               
  /*****************************************************************************/
  /**     Procedure para atualizar renda na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_renda ( pr_idpessoa     IN tbcadast_pessoa.idpessoa%TYPE        --> Identificador de pessoa                             
                               ,pr_nrseq_renda  IN INTEGER                              --> Sequencial da renda
                               ,pr_tpoperacao   IN INTEGER                              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_renda_old    IN tbcadast_pessoa_renda%ROWTYPE        --> Dados anteriores
                               ,pr_renda_new    IN tbcadast_pessoa_renda%ROWTYPE        --> Dados novos
                               ,pr_dscritic     OUT VARCHAR2);                          --> Retornar Critica 
                                 
  /*****************************************************************************/
  /**     Procedure para atualizar pessoa estrangeira na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_estrangeira ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE        --> Identificador de pessoa                                                                
                                     ,pr_tpoperacao        IN INTEGER                              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_estrangeira_old   IN tbcadast_pessoa_estrangeira%ROWTYPE  --> Dados anteriores
                                     ,pr_estrangeira_new   IN tbcadast_pessoa_estrangeira%ROWTYPE  --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2);                           --> Retornar Critica                                
                                     

  /*****************************************************************************/
  /**     Procedure para atualizar dados de banco de PJ na estrutura antiga   **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_bco( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_bco_old  IN tbcadast_pessoa_juridica_bco%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_bco_new  IN tbcadast_pessoa_juridica_bco%ROWTYPE      --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2);                                --> Retornar Critica 
                                                                          
  /*****************************************************************************/
  /** Procedure para atualizar dados de faturamento de PJ na estrutura antiga **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_fat( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_fat_old  IN tbcadast_pessoa_juridica_fat%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_fat_new  IN tbcadast_pessoa_juridica_fat%ROWTYPE      --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2);                                --> Retornar Critica 

  /*****************************************************************************/
  /** Procedure para atualizar resultados financeiros de PJ na estrutura antiga **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_fnc( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_fnc_old  IN tbcadast_pessoa_juridica_fnc%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_fnc_new  IN tbcadast_pessoa_juridica_fnc%ROWTYPE      --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2);                                --> Retornar Critica                                      

  /*****************************************************************************/
  /** Procedure para atualizar paticipacao societaria na estrutura antiga **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_ptp( pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao         IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_ptp_old   IN tbcadast_pessoa_juridica_ptp%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_ptp_new   IN tbcadast_pessoa_juridica_ptp%ROWTYPE      --> Dados novos
                                     ,pr_dscritic          OUT VARCHAR2 );                               --> Retornar Critica 

  /*****************************************************************************/
  /**    Procedure para atualizar representante do pj na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_rep( pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao         IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_rep_old   IN tbcadast_pessoa_juridica_rep%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_rep_new   IN tbcadast_pessoa_juridica_rep%ROWTYPE      --> Dados novos
                                     ,pr_dscritic          OUT VARCHAR2 );                               --> Retornar Critica                                      
                                     
  /*****************************************************************************/
  /**    Procedure para atualizar representante do pj na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_referencia ( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE           --> Identificador de pessoa                             
                                           ,pr_tpoperacao       IN INTEGER                                 --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_pessoa_ref_old   IN tbcadast_pessoa_referencia%ROWTYPE      --> Dados anteriores
                                           ,pr_pessoa_ref_new   IN tbcadast_pessoa_referencia%ROWTYPE      --> Dados novos
                                           ,pr_dscritic        OUT VARCHAR2);                              --> Retornar Critica 

  /*****************************************************************************/
  /**       Procedure para atualizar dependentes na estrutura antiga          **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_fisica_dep ( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE           --> Identificador de pessoa                             
                                           ,pr_tpoperacao       IN INTEGER                                 --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_pessoa_dep_old   IN tbcadast_pessoa_fisica_dep%ROWTYPE      --> Dados anteriores
                                           ,pr_pessoa_dep_new   IN tbcadast_pessoa_fisica_dep%ROWTYPE      --> Dados novos
                                           ,pr_dscritic        OUT VARCHAR2 );                             --> Retornar Critica 

  /*****************************************************************************/
  /**    Procedure para atualizar responsavel legal na estrutura antiga       **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_fisica_resp ( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                            ,pr_tpoperacao       IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                            ,pr_pessoa_resp_old  IN tbcadast_pessoa_fisica_resp%ROWTYPE       --> Dados anteriores
                                            ,pr_pessoa_resp_new  IN tbcadast_pessoa_fisica_resp%ROWTYPE       --> Dados novos
                                            ,pr_dscritic        OUT VARCHAR2);                                --> Retornar Critica 
                                            
  /********************************************************************************/
  /** Procedure para atualizar as pessoas de relacionamento na estrutura antiga  **/
  /********************************************************************************/
  PROCEDURE pc_atualiza_pessoa_relacao( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa
                                       ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_pessoa_relac_old  IN tbcadast_pessoa_relacao%ROWTYPE           --> Dados anteriores
                                       ,pr_pessoa_relac_new  IN tbcadast_pessoa_relacao%ROWTYPE           --> Dados novos
                                       ,pr_dscritic         OUT VARCHAR2 );                               --> Retornar Critica 

  /*****************************************************************************/
  /**            Procedure para atualizar bens na estrutura antiga            **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_bem ( pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE           --> Identificador de pessoa                            
                             ,pr_tpoperacao    IN INTEGER                                 --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_bem_old       IN tbcadast_pessoa_bem%ROWTYPE             --> Dados anteriores
                             ,pr_bem_new       IN tbcadast_pessoa_bem%ROWTYPE             --> Dados novos
                             ,pr_dscritic      OUT VARCHAR2);                             --> Retornar Critica 

  /*****************************************************************************/
  /**            Procedure para atualizar pessoa na estrutura antiga          **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa( pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE    --> Identificador de pessoa                            
                               ,pr_tpoperacao    IN INTEGER                          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_pessoa_old    IN tbcadast_pessoa%ROWTYPE          --> Dados anteriores
                               ,pr_pessoa_new    IN tbcadast_pessoa%ROWTYPE          --> Dados novos
                               ,pr_dscritic      OUT VARCHAR2);                      --> Retornar Critica 

  /*****************************************************************************/
  /**       Procedure para atualizar pessoa fisica na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_fisica ( pr_idpessoa       IN tbcadast_pessoa.idpessoa%TYPE    --> Identificador de pessoa                            
                                       ,pr_tpoperacao     IN INTEGER                          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_pessoa_fis_old IN tbcadast_pessoa_fisica%ROWTYPE   --> Dados anteriores
                                       ,pr_pessoa_fis_new IN tbcadast_pessoa_fisica%ROWTYPE   --> Dados novos
                                       ,pr_dscritic      OUT VARCHAR2);                       --> Retornar Critica                                

  /*****************************************************************************/
  /**       Procedure para atualizar pessoa juridica na estrutura antiga      **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_juridica ( pr_idpessoa       IN tbcadast_pessoa.idpessoa%TYPE    --> Identificador de pessoa                            
                                         ,pr_tpoperacao     IN INTEGER                          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                         ,pr_pessoa_jur_old IN tbcadast_pessoa_juridica%ROWTYPE --> Dados anteriores
                                         ,pr_pessoa_jur_new IN tbcadast_pessoa_juridica%ROWTYPE --> Dados novos
                                         ,pr_dscritic      OUT VARCHAR2);                       --> Retornar Critica 

END CADA0016;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0016 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0016
  --  Sistema  : CRM
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Agosto/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para atualizar informações de cadastro da estrutura nova para 
  --             estrutura antiga
  --
  -- Alteracoes:  24/11/2017 - Ajustado para gravar espaco qnd nulo no campos de cidada e uf.
  --                           PRJ339-CRM (Odirlei-AMcom) 
  --  
  --              29/01/2017 - Ajustes para atualizar a data de alteração, para posicionar que essa pessoa teve 
  --                           alguma alteração cadastral. PRJ309-CRM(Odirlei-AMcom)
  --
  --              16/03/2018 - colocado NVL nos valores que irão atualizar ou inserir no campo vlsalari tabela crapcje, pois caso o campo vlsalari estiver nulo,
  --                           irá impactar no caluclo do rating. Chamado 830113 (Alcemir Mouts).
  ---------------------------------------------------------------------------------------------------------------*/
  
  vr_dtpadrao DATE := to_date('01/01/1900','DD/MM/RRRR');
  
  /*****************************************************************************/
  /**         Procedure atualizar modulo de sessao da trigger                 **/
  /*****************************************************************************/
  PROCEDURE pc_sessao_trigger( pr_tpmodule   IN INTEGER,        --> tipo do modulo (1-inicializa,2-finaliza)          
                               pr_dsmodule   IN OUT VARCHAR2    --> Nome do mudulo                                 
                              ) IS 
     
  /* ..........................................................................
    --
    --  Programa : pc_modulo_sessao_trigger
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  :  Procedure atualizar modulo de sessao da trigger
    --
    --   Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------     
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
    
    vr_dsmodule   VARCHAR2(100);
    vr_dsaction   VARCHAR2(100);
    
  BEGIN
    
    -- Guarda o nome e acao atual
    DBMS_APPLICATION_INFO.read_module(module_name => vr_dsmodule,
                                      action_name => vr_dsaction);
    
    --> Se for inicializado
    IF pr_tpmodule = 1 THEN    
      -- Inclui na sessão o modulo em execução da trigger
      DBMS_APPLICATION_INFO.SET_MODULE(module_name => 'TRIGGER_PESSOA'
                                      ,action_name => vr_dsaction);
    --> senao é retornar valor anterior 
    ELSE
      -- Inclui na sessão o modulo em execução da trigger
      DBMS_APPLICATION_INFO.SET_MODULE(module_name => pr_dsmodule
                                      ,action_name => vr_dsaction);
    
    END IF;
    
    --> retornar modulo anterior, caso queira retornar o valor
    pr_dsmodule := vr_dsmodule;
      
  END pc_sessao_trigger;  
  

  /*****************************************************************************/
  /**            Procedure para retornar contas com o mesmo CPF/CNPJ          **/
  /*****************************************************************************/
  PROCEDURE pc_retorna_contas( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE    --> indicador de pessoa
                              ,pr_tab_contas      OUT typ_tab_contas                   --> Retornar contas
                              ,pr_dscritic        OUT VARCHAR2                         --> Retornar Critica 
                             ) IS 
     
  /* ..........................................................................
    --
    --  Programa : pc_retorna_contas
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para retornar contas com o mesmo CPF/CNPJ
    --
    --   Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------     
    --> Buscar dados pessoa
    CURSOR cr_pessoa IS
      SELECT tps.tppessoa,
             tps.nrcpfcgc
        FROM tbcadast_pessoa tps
       WHERE tps.idpessoa = pr_idpessoa;
    rw_pessoa cr_pessoa%ROWTYPE;
       
    -- Cursor para buscar as contas da pessoa
    CURSOR cr_crapttl(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT ttl.nrdconta
            ,ttl.cdcooper 
            ,ttl.idseqttl
        FROM crapttl ttl
       WHERE ttl.nrcpfcgc = pr_nrcpfcgc;
         
    -- Cursor para buscar as contas da pessoa
    CURSOR cr_crapjur(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS      
      SELECT jur.nrdconta
            ,jur.cdcooper             
        FROM crapjur jur,
             crapass ass
       WHERE ass.nrcpfcgc = pr_nrcpfcgc
         AND ass.cdcooper = jur.cdcooper
         AND ass.nrdconta = jur.nrdconta;       
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION; 
    
    vr_tab_contas typ_tab_contas;
    vr_idx        INTEGER;
    
  BEGIN
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO rw_pessoa;
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;
      vr_dscritic := 'Pessoa nao encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;  
  
    --> se for pessoa fisica
    IF rw_pessoa.tppessoa = 1 THEN
      --> Buscar pessoa fisica
      FOR rw_crapttl IN cr_crapttl(pr_nrcpfcgc => rw_pessoa.nrcpfcgc) LOOP
        vr_idx := vr_tab_contas.count() + 1;
        vr_tab_contas(vr_idx).idpessoa := pr_idpessoa;    
        vr_tab_contas(vr_idx).nrdconta := rw_crapttl.nrdconta;    
        vr_tab_contas(vr_idx).cdcooper := rw_crapttl.cdcooper;
        vr_tab_contas(vr_idx).idseqttl := rw_crapttl.idseqttl;            
      END LOOP; 
    ELSE
    --> senao pessoa juridica
      FOR rw_crapjur IN cr_crapjur(pr_nrcpfcgc => rw_pessoa.nrcpfcgc) LOOP
        vr_idx := vr_tab_contas.count() + 1;
        vr_tab_contas(vr_idx).idpessoa := pr_idpessoa;    
        vr_tab_contas(vr_idx).nrdconta := rw_crapjur.nrdconta;    
        vr_tab_contas(vr_idx).cdcooper := rw_crapjur.cdcooper;
        vr_tab_contas(vr_idx).idseqttl := 1; 
      END LOOP;
    
    
    END IF;
  
    pr_tab_contas := vr_tab_contas;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_retorna_contas: '||SQLERRM; 
  END pc_retorna_contas;
  
  
  /*****************************************************************************/
  /**         Procedure para retornar numero de conta mais recente            **/
  /*****************************************************************************/
  PROCEDURE pc_ret_conta_recente( pr_nrcpfcgc         IN tbcadast_pessoa.nrcpfcgc%TYPE    --> Numero do CPF/CNPJ
                                 ,pr_cdcooper         IN crapass.cdcooper%TYPE            --> Codigo da cooperativa
                                 ,pr_nrdconta        OUT crapass.nrdconta%TYPE            --> Retornar contas
                                 ,pr_dscritic        OUT VARCHAR2                         --> Retornar Critica 
                                ) IS 
     
  /* ..........................................................................
    --
    --  Programa : pc_ret_conta_recente
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure  para retornar numero de conta mais recente
    --
    --   Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------     
    --> Buscar dados pessoa
    CURSOR cr_crapass IS
      SELECT ass.nrdconta
        FROM crapass ass 
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrcpfcgc = pr_nrcpfcgc
         AND ass.dtdemiss IS NULL
         ORDER BY ass.dtadmiss DESC;
    rw_crapass cr_crapass%ROWTYPE;
         
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
    
  BEGIN
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      pr_nrdconta := 0;
    ELSE
      CLOSE cr_crapass;
      pr_nrdconta := rw_crapass.nrdconta;
    END IF;  
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_ret_conta_recente: '||SQLERRM; 
  END pc_ret_conta_recente;  
  
  /*****************************************************************************/
  /**       Procedure para atualizar data de alteracao da tabela pessoa       **/
  /*****************************************************************************/
  PROCEDURE pc_atlz_dtaltera_pessoa( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE     --> Identificador de pessoa
                                    ,pr_dscritic        OUT VARCHAR2                          --> Retornar Critica 
                                   ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atlz_dtaltera_pessoa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Janeiro/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar data de alteracao da tabela pessoa
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
  
    
    
  BEGIN
  
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve 
    --> alguma alteração cadastral
    UPDATE tbcadast_pessoa pes
       SET pes.dtalteracao = SYSDATE
      WHERE pes.idpessoa = pr_idpessoa;  
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar dtalteracao no cadastro de pessoa: '||SQLERRM; 
  END pc_atlz_dtaltera_pessoa;
  
  
  /*****************************************************************************/
  /**            Procedure para atualizar endereço na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_endereco( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE                   --> Identificador de pessoa
                                 ,pr_nrseq_endereco   IN tbcadast_pessoa_endereco.nrseq_endereco%TYPE    --> Sequencial do endereco
                                 ,pr_tpoperacao       IN INTEGER                                         --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_endereco_old     IN tbcadast_pessoa_endereco%ROWTYPE                --> Dados anteriores
                                 ,pr_endereco_new     IN tbcadast_pessoa_endereco%ROWTYPE                --> Dados novos
                                 ,pr_dscritic        OUT VARCHAR2                                        --> Retornar Critica 
                                 ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_endereco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar endereço na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;   
    --rw_pessoa_rel cr_pessoa%ROWTYPE;
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas  cada0010.typ_tab_conta;
    vr_dscidade    crapmun.dscidade%TYPE;
    vr_cdestado    crapmun.cdestado%TYPE;
    vr_nrseq_end   tbcadast_pessoa_endereco.nrseq_endereco%TYPE;
    
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;
    
    
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    
    IF vr_tab_contas.count() > 0 THEN
      IF pr_endereco_new.idcidade IS NOT NULL THEN
        --> buscar nome da cidade
        cada0014.pc_ret_desc_cidade_uf (pr_idcidade  => pr_endereco_new.idcidade,
                                        pr_dscidade  => vr_dscidade,
                                        pr_cdestado  => vr_cdestado,
                                        pr_dscritic  => vr_dscritic);
                                     
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> 6-Titular (crapttl)
        --> 7-Titular (crapjur)
        IF vr_tab_contas(idx).tprelacao IN (6,7) THEN  
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              DELETE crapenc enc
               WHERE enc.cdcooper = vr_tab_contas(idx).cdcooper
                 AND enc.nrdconta = vr_tab_contas(idx).nrdconta
                 AND enc.idseqttl = vr_tab_contas(idx).idseqttl
                 AND enc.tpendass = pr_endereco_old.tpendereco;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar endereco: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN
              UPDATE crapenc enc 
                 SET --cdseqinc = pr_endereco_new.nrseq_endereco,     
                     dsendere = pr_endereco_new.nmlogradouro,       
                     nrendere = pr_endereco_new.nrlogradouro,       
                     complend = pr_endereco_new.dscomplemento,      
                     nmbairro = pr_endereco_new.nmbairro,           
                     nmcidade = nvl(vr_dscidade,' '),
                     cdufende = nvl(vr_cdestado,' '),      
                     nrcepend = pr_endereco_new.nrcep,              
                     incasprp = pr_endereco_new.tpimovel,                                
                     vlalugue = pr_endereco_new.vldeclarado,                                  
                     dtaltenc = pr_endereco_new.dtalteracao,        
                     dtinires = pr_endereco_new.dtinicio_residencia,
                     idorigem = nvl(pr_endereco_new.tporigem_cadastro,0)
               WHERE enc.cdcooper = vr_tab_contas(idx).cdcooper
                 AND enc.nrdconta = vr_tab_contas(idx).nrdconta
                 AND enc.idseqttl = vr_tab_contas(idx).idseqttl
--                 AND enc.cdseqinc = pr_endereco_new.nrseq_endereco;
                 --Endereço deve validar pelo tipo de endereco, pois deve existir apenas 1 para cada tipo  
                 AND enc.tpendass = nvl(pr_endereco_old.tpendereco,pr_endereco_new.tpendereco);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar endereço:'||SQLERRM;     
                RAISE vr_exc_erro;      
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN
              
              vr_nrseq_end := pr_endereco_new.nrseq_endereco;
              
              LOOP
                --> Inserir registro
                BEGIN
                  INSERT INTO crapenc
                              ( cdcooper, 
                                nrdconta, 
                                idseqttl, 
                                tpendass, 
                                cdseqinc, 
                                dsendere, 
                                nrendere, 
                                complend, 
                                nmbairro, 
                                nmcidade, 
                                cdufende, 
                                nrcepend, 
                                incasprp,                         
                                vlalugue,                         
                                dtaltenc, 
                                dtinires, 
                                idorigem)
                       VALUES ( vr_tab_contas(idx).cdcooper,        --> cdcooper
                                vr_tab_contas(idx).nrdconta,        --> nrdconta
                                vr_tab_contas(idx).idseqttl,        --> idseqttl
                                pr_endereco_new.tpendereco,             --> tpendass
                                vr_nrseq_end,                           --> cdseqinc
                                pr_endereco_new.nmlogradouro,           --> dsendere
                                pr_endereco_new.nrlogradouro,           --> nrendere
                                pr_endereco_new.dscomplemento,          --> complend
                                pr_endereco_new.nmbairro,               --> nmbairro
                                nvl(vr_dscidade,' '),                   --> nmcidade
                                nvl(vr_cdestado,' '),                   --> cdufende
                                pr_endereco_new.nrcep,                  --> nrcepend
                                pr_endereco_new.tpimovel,               --> incasprp                        
                                pr_endereco_new.vldeclarado,            --> vlalugue                        
                                pr_endereco_new.dtalteracao,            --> dtaltenc
                                pr_endereco_new.dtinicio_residencia,    --> dtinires
                                nvl(pr_endereco_new.tporigem_cadastro,0));     --> idorigem
                                    
                EXCEPTION
                  --> Tratamento para garantir gravar o endereco independente do 
                  --> sequencial, pois a o controle é feito pelo tipo de end, que não pode ter mais de 1
                  WHEN dup_val_on_index THEN  
                    vr_nrseq_end := vr_nrseq_end + 1;  
                  
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir endereco: '||SQLERRM; 
                    RAISE vr_exc_erro;
                END;
                
                EXIT;
              END LOOP;
            END IF;
            
          END IF;  
        --> 10-Pessoa de referencia (contato)           
        ELSIF vr_tab_contas(idx).tprelacao IN (10) THEN
            
          --> Se for diferente de exclusao 
          IF pr_tpoperacao <> 3 THEN 
            BEGIN          
              UPDATE crapavt avt
                 SET avt.nrcepend     = pr_endereco_new.nrcep,
                     avt.dsendres##1  = pr_endereco_new.nmlogradouro,
                     avt.nrendere     = pr_endereco_new.nrlogradouro, 
                     avt.complend     = substr(pr_endereco_new.dscomplemento,1,47),
                     avt.nmbairro     = pr_endereco_new.nmbairro,
                     avt.nmcidade     = nvl(vr_dscidade,' '),
                     avt.cdufresd     = nvl(vr_cdestado,' ')
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 5
                 AND nvl(avt.nrdctato ,0) = 0 ;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar endereço do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          ELSE
            --Em caso de exclusao deve ser limpo os campos
            BEGIN          
              UPDATE crapavt avt
                 SET avt.nrcepend     = 0,
                     avt.dsendres##1  = ' ',
                     avt.nrendere     = 0, 
                     avt.complend     = ' ',
                     avt.nmbairro     = ' ',
                     avt.nmcidade     = ' ',
                     avt.cdufresd     = ' '
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 5
                 AND nvl(avt.nrdctato ,0) = 0 ;    
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar endereço do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;  
        --> 20-Representante de uma PJ        
        ELSIF vr_tab_contas(idx).tprelacao IN (20) THEN
            
          --> Se for diferente de exclusao 
          IF pr_tpoperacao <> 3 THEN 
            BEGIN          
              UPDATE crapavt avt
                 SET avt.nrcepend     = pr_endereco_new.nrcep,
                     avt.dsendres##1  = pr_endereco_new.nmlogradouro,
                     avt.nrendere     = pr_endereco_new.nrlogradouro, 
                     avt.complend     = substr(pr_endereco_new.dscomplemento,1,47),
                     avt.nmbairro     = pr_endereco_new.nmbairro,
                     avt.nmcidade     = nvl(vr_dscidade,' '),
                     avt.cdufresd     = nvl(vr_cdestado,' ')
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND nvl(avt.nrcpfcgc,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 6
                 AND nvl(avt.nrdctato ,0) = 0 ;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar endereço do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          ELSE
            --Em caso de exclusao deve ser limpo os campos
            BEGIN          
              UPDATE crapavt avt
                 SET avt.nrcepend     = 0,
                     avt.dsendres##1  = ' ',
                     avt.nrendere     = 0, 
                     avt.complend     = ' ',
                     avt.nmbairro     = ' ',
                     avt.nmcidade     = ' ',
                     avt.cdufresd     = ' '
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND nvl(avt.nrcpfcgc,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 6
                 AND nvl(avt.nrdctato ,0) = 0 ;    
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar endereço do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;  
     
        --> 30-Responsavel Legal
        ELSIF vr_tab_contas(idx).tprelacao = 30 AND 
              (pr_endereco_new.tpendereco = 10  OR 
               pr_endereco_old.tpendereco = 10) THEN
            
          --> Se for diferente de exclusao 
          IF pr_tpoperacao <> 3 THEN 
            BEGIN          
              UPDATE crapcrl crl
                 SET crl.cdcepres =  pr_endereco_new.nrcep,
                     crl.dsendres =  pr_endereco_new.nmlogradouro,
                     crl.nrendres =  pr_endereco_new.nrlogradouro,
                     crl.dscomres =  substr(pr_endereco_new.dscomplemento,1,40),
                     crl.dsbaires =  pr_endereco_new.nmbairro,
                     crl.dscidres =  nvl(vr_dscidade,' '),
                     crl.dsdufres =  nvl(vr_cdestado,' ')
               WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                 AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                 AND crl.nrcpfcgc = rw_pessoa.nrcpfcgc
                 AND crl.nmrespon = rw_pessoa.nmpessoa
                 AND nvl(crl.nrdconta ,0) = 0 ;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar endereço do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          ELSE
            --Em caso de exclusao deve ser limpo os campos
            BEGIN          
              UPDATE crapcrl crl
                 SET crl.cdcepres = 0,
                     crl.dsendres = ' ',
                     crl.nrendres = 0, 
                     crl.dscomres = ' ',
                     crl.dsbaires = ' ',
                     crl.dscidres = ' ',
                     crl.dsdufres = ' '
               WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                 AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                 AND crl.nrcpfcgc = rw_pessoa.nrcpfcgc
                 AND crl.nmrespon = rw_pessoa.nmpessoa
                 AND nvl(crl.nrdconta ,0) = 0;    
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar endereço do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;
        
        END IF; --> fim tprelacao
      
      END LOOP; --> Fim loop vr_tab_contas
    END IF; --> vr_tab_contas.count     
  
    --> atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar endereco: '||SQLERRM; 
  END pc_atualiza_endereco;
  
  /*****************************************************************************/
  /**            Procedure para atualizar telefone na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_telefone( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE                   --> Identificador de pessoa
                                 ,pr_nrseq_telefone   IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE    --> Sequencial do telefone
                                 ,pr_tpoperacao       IN INTEGER                                         --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_telefone_old     IN tbcadast_pessoa_telefone%ROWTYPE                --> Dados anteriores
                                 ,pr_telefone_new     IN tbcadast_pessoa_telefone%ROWTYPE                --> Dados novos
                                 ,pr_dscritic        OUT VARCHAR2                                        --> Retornar Critica 
                                 ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_telefone
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar endereço na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;   
    
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas  cada0010.typ_tab_conta;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> 6-Titular (crapttl)
        --> 7-Titular (crapjur)
        IF vr_tab_contas(idx).tprelacao IN (6,7) THEN
        
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              DELETE craptfc tfc
               WHERE tfc.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND tfc.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND tfc.idseqttl   = vr_tab_contas(idx).idseqttl
                 AND tfc.tptelefo   = pr_telefone_old.tptelefone
                 --> validar pelo numero do telefone
                 AND tfc.nrtelefo = pr_telefone_old.nrtelefone
                 AND nvl(tfc.nrdramal,0) = nvl(pr_telefone_old.nrramal,0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar telefone: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN
              UPDATE craptfc tfc
                 SET --tfc.cdseqtfc = pr_telefone_new.nrseq_telefone,         
                     tfc.cdopetfn = pr_telefone_new.cdoperadora,            
                     tfc.tptelefo = pr_telefone_new.tptelefone,             
                     tfc.nmpescto = pr_telefone_new.nmpessoa_contato,       
                     tfc.secpscto = pr_telefone_new.nmsetor_pessoa_contato, 
                     tfc.nrdddtfc = pr_telefone_new.nrddd,
                     tfc.nrtelefo = pr_telefone_new.nrtelefone,     
                     tfc.nrdramal = nvl(pr_telefone_new.nrramal,0),
                     tfc.idsittfc = pr_telefone_new.insituacao,             
                     tfc.idorigem = nvl(pr_telefone_new.tporigem_cadastro,0),      
                     tfc.flgacsms = nvl(pr_telefone_new.flgaceita_sms,0)                
               WHERE tfc.cdcooper = vr_tab_contas(idx).cdcooper
                 AND tfc.nrdconta = vr_tab_contas(idx).nrdconta
                 AND tfc.idseqttl = vr_tab_contas(idx).idseqttl
                 --> validar pelo numero do telefone, caso for insert, apenas terá o new
                 AND tfc.nrtelefo = nvl(pr_telefone_old.nrtelefone,pr_telefone_new.nrtelefone)
                 AND nvl(tfc.nrdramal,0) = nvl(nvl(pr_telefone_old.nrramal,pr_telefone_new.nrramal),0);
            EXCEPTION
              WHEN dup_val_on_index THEN
                --> Irá atualizar no update abaixo
                NULL; 
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar telefone:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
            
            IF SQL%ROWCOUNT = 0 THEN
              --testar o numero novo, pois ocorre qnd a alteração partiu dessa propria 
              -- tabela e numero da esta atualizado
              BEGIN
                UPDATE craptfc tfc
                   SET --tfc.cdseqtfc = pr_telefone_new.nrseq_telefone,         
                       tfc.cdopetfn = pr_telefone_new.cdoperadora,            
                       tfc.tptelefo = pr_telefone_new.tptelefone,             
                       tfc.nmpescto = pr_telefone_new.nmpessoa_contato,       
                       tfc.secpscto = pr_telefone_new.nmsetor_pessoa_contato, 
                       tfc.nrdddtfc = pr_telefone_new.nrddd,
                       tfc.nrtelefo = pr_telefone_new.nrtelefone,     
                       tfc.nrdramal = nvl(pr_telefone_new.nrramal,0),
                       tfc.idsittfc = pr_telefone_new.insituacao,             
                       tfc.idorigem = nvl(pr_telefone_new.tporigem_cadastro,0),      
                       tfc.flgacsms = nvl(pr_telefone_new.flgaceita_sms,0)                
                 WHERE tfc.cdcooper = vr_tab_contas(idx).cdcooper
                   AND tfc.nrdconta = vr_tab_contas(idx).nrdconta
                   AND tfc.idseqttl = vr_tab_contas(idx).idseqttl
                   --> validar pelo numero do telefone, caso for insert, apenas terá o new
                   AND --testar o numero novo, pois ocorre qnd a alteração partiu dessa propria 
                       -- tabela e numero da esta atualizado
                       tfc.nrtelefo = pr_telefone_new.nrtelefone
                   AND nvl(tfc.nrdramal,0) = nvl(pr_telefone_new.nrramal,0);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar telefone:'||SQLERRM; 
                  RAISE vr_exc_erro;          
              END;
            
            END IF;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN
              --> Inserir registro
              BEGIN
                INSERT INTO craptfc
                            ( cdcooper, 
                              nrdconta, 
                              idseqttl, 
                              cdseqtfc, 
                              cdopetfn, 
                              nrdddtfc, 
                              tptelefo, 
                              nmpescto, 
                              nrtelefo, 
                              nrdramal, 
                              secpscto, 
                              idsittfc, 
                              idorigem, 
                              flgacsms)
                     VALUES ( vr_tab_contas(idx).cdcooper,            --> cdcooper
                              vr_tab_contas(idx).nrdconta,            --> nrdconta
                              vr_tab_contas(idx).idseqttl,            --> idseqttl
                              pr_telefone_new.nrseq_telefone,         --> cdseqtfc
                              pr_telefone_new.cdoperadora,            --> cdopetfn
                              pr_telefone_new.nrddd,                  --> nrdddtfc
                              pr_telefone_new.tptelefone,             --> tptelefo
                              pr_telefone_new.nmpessoa_contato,       --> nmpescto
                              pr_telefone_new.nrtelefone,             --> nrtelefo
                              nvl(pr_telefone_new.nrramal,0),         --> nrdramal
                              pr_telefone_new.nmsetor_pessoa_contato, --> secpscto
                              pr_telefone_new.insituacao,             --> idsittfc                        
                              nvl(pr_telefone_new.tporigem_cadastro,0), --> idorigem                        
                              nvl(pr_telefone_new.flgaceita_sms,0));  --> flgacsms
                                  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir telefone: '||SQLERRM; 
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF; --> fim tpoperacao
        
        --> 1-Conjuge
        ELSIF vr_tab_contas(idx).tprelacao IN (1) AND
             --> Comercial
             (pr_telefone_new.tptelefone = 3 OR pr_telefone_old.tptelefone = 3) THEN
            
          --> Se for diferente de exclusao e é Comercial
          IF pr_tpoperacao <> 3 AND pr_telefone_new.tptelefone = 3 THEN 
            BEGIN          
              UPDATE crapcje cje
                 SET cje.nrfonemp = '('||pr_telefone_new.nrddd||')'||pr_telefone_new.nrtelefone,
                     cje.nrramemp = nvl(pr_telefone_new.nrramal,0)
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                 AND nvl(cje.nrcpfcjg,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND cje.nmconjug = rw_pessoa.nmpessoa
                 AND nvl(cje.nrctacje,0) = 0;
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar telefone do conjuge: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          --> Se for exclusao ou mudou de tipo 3 para outro  
          ELSIF pr_tpoperacao = 3 OR pr_telefone_new.tptelefone <> 3 THEN
            --Em caso de exclusao deve ser limpo os campos
            BEGIN          
              UPDATE crapcje cje
                 SET cje.nrfonemp = ' ',
                     cje.nrramemp = 0
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                 AND nvl(cje.nrcpfcjg,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND cje.nmconjug = rw_pessoa.nmpessoa
                 AND nvl(cje.nrctacje,0) = 0; 
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar telefone do conjuge: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;
        
        --> 10-Pessoa de referencia (contato)
        ELSIF vr_tab_contas(idx).tprelacao = 10 AND
              --> Residencial
              (pr_telefone_new.tptelefone = 10 OR pr_telefone_old.tptelefone = 10) THEN
            
          --> Se for diferente de exclusao e o tipo novo é residencial
          IF pr_tpoperacao <> 3 AND pr_telefone_new.tptelefone = 10 THEN 
            BEGIN          
              UPDATE crapavt avt
                 SET avt.nrtelefo = '('||pr_telefone_new.nrddd||')'||pr_telefone_new.nrtelefone
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 5 -- Pessoa de contato
                 AND nvl(avt.nrdctato ,0) = 0 ;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar telefone do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          --> se for exclusao ou o novo é diferente de 10
          ELSIF pr_tpoperacao = 3 OR pr_telefone_new.tptelefone <> 10 THEN 
            --Em caso de exclusao deve ser limpo os campos
            BEGIN          
              UPDATE crapavt avt
                 SET avt.nrtelefo = ' '
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 5 -- Pessoa de contato
                 AND nvl(avt.nrdctato ,0) = 0;     
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar teelfone do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;                                         
        
        END IF; --> fim tprelacao
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar telefone: '||SQLERRM; 
  END pc_atualiza_telefone;
  
  
  /*****************************************************************************/
  /**            Procedure para atualizar email na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_email(pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa
                             ,pr_nrseq_email   IN tbcadast_pessoa_email.nrseq_email%TYPE    --> Sequencial do email
                             ,pr_tpoperacao    IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_email_old     IN tbcadast_pessoa_email%ROWTYPE             --> Dados anteriores
                             ,pr_email_new     IN tbcadast_pessoa_email%ROWTYPE             --> Dados novos
                             ,pr_dscritic      OUT VARCHAR2                                 --> Retornar Critica 
                             ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_email
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar email na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;   
       
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas  cada0010.typ_tab_conta;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> 6-Titular (crapttl)
        --> 7-Titular (crapjur)
        IF vr_tab_contas(idx).tprelacao IN (6,7) THEN
        
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              DELETE crapcem cem
               WHERE cem.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND cem.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND cem.idseqttl   = vr_tab_contas(idx).idseqttl
                 AND upper(cem.dsdemail)   = UPPER(pr_email_old.dsemail);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar email: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN
              UPDATE crapcem cem
                 SET --cem.cddemail = pr_email_new.nrseq_email,
                     cem.dsdemail = pr_email_new.dsemail,
                     cem.nmpescto = pr_email_new.nmpessoa_contato,
                     cem.secpscto = pr_email_new.nmsetor_pessoa_contato                                          
               WHERE cem.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND cem.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND cem.idseqttl   = vr_tab_contas(idx).idseqttl
                 --> validar pelo email, caso for insert, apenas terá o new
                 AND upper(cem.dsdemail)   = UPPER(nvl(pr_email_old.dsemail,pr_email_new.dsemail));
                 
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar email:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN
              --> Inserir registro
              BEGIN
                INSERT INTO crapcem
                            ( cdoperad, 
                              nrdconta, 
                              dsdemail, 
                              cddemail, 
                              dtmvtolt, 
                              hrtransa, 
                              cdcooper, 
                              idseqttl,                               
                              nmpescto, 
                              secpscto  )
                     VALUES ( pr_email_new.cdoperad_altera,            --> cdoperad
                              vr_tab_contas(idx).nrdconta,            --> nrdconta
                              pr_email_new.dsemail,                   --> dsdemail
                              pr_email_new.nrseq_email,               --> cddemail
                              trunc(SYSDATE),                         --> dtmvtolt
                              gene0002.fn_busca_time,                 --> hrtransa
                              vr_tab_contas(idx).cdcooper,            --> cdcooper
                              vr_tab_contas(idx).idseqttl,            --> idseqttl                              
                              pr_email_new.nmpessoa_contato,          --> nmpescto
                              pr_email_new.nmsetor_pessoa_contato);   --> secpscto
                                  
              EXCEPTION
                WHEN dup_val_on_index THEN
                  NULL;
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir email: '||SQLERRM; 
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF; --> fim tpoperacao
               
        --> 10-Pessoa de referencia (contato)
        ELSIF vr_tab_contas(idx).tprelacao = 10 THEN
            
          --> Se for diferente de exclusao
          IF pr_tpoperacao <> 3 THEN 
            BEGIN          
              UPDATE crapavt avt
                 SET avt.dsdemail = pr_email_new.dsemail
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 5 -- Pessoa de contato
                 AND nvl(avt.nrdctato ,0) = 0 ;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar email do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          --> se for exclusao ou o novo é diferente de 10
          ELSIF pr_tpoperacao = 3 THEN 
            --Em caso de exclusao deve ser limpo os campos
            BEGIN          
              UPDATE crapavt avt
                 SET avt.dsdemail = ' '
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 5 -- Pessoa de contato
                 AND nvl(avt.nrdctato ,0) = 0;     
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar email do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;                                         
        
        END IF; --> fim tprelacao
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar email: '||SQLERRM; 
  END pc_atualiza_email;
  
  /*****************************************************************************/
  /**   Procedure para atualizar politicamente exposto na estrutura antiga    **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_polexp( pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                               ,pr_tpoperacao    IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_polexp_old    IN tbcadast_pessoa_polexp%ROWTYPE            --> Dados anteriores
                               ,pr_polexp_new    IN tbcadast_pessoa_polexp%ROWTYPE            --> Dados novos
                               ,pr_dscritic      OUT VARCHAR2                                 --> Retornar Critica 
                               ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_polexp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar politicamente exposto na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;   
    rw_pessoa_emp cr_pessoa%ROWTYPE;               
    rw_pessoa_pol cr_pessoa%ROWTYPE;               
        
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    IF pr_polexp_new.idpessoa_politico IS NOT NULL THEN
      -- Buscar informações da pessoa politico
      OPEN cr_pessoa (pr_idpessoa => pr_polexp_new.idpessoa_politico );
      FETCH cr_pessoa INTO rw_pessoa_pol; 
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;      
        vr_dscritic := 'Pessoa(politico) não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa;
      END IF;
    END IF;
    
    IF pr_polexp_new.idpessoa_empresa IS NOT NULL THEN    
      -- Buscar informações da pessoa empresa
      OPEN cr_pessoa (pr_idpessoa => pr_polexp_new.idpessoa_empresa );
      FETCH cr_pessoa INTO rw_pessoa_emp; 
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;      
        vr_dscritic := 'Pessoa(empresa) não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa;
      END IF;
    END IF;

    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
  
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
              
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              DELETE tbcadast_politico_exposto pol
               WHERE pol.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND pol.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND pol.idseqttl   = vr_tab_contas(idx).idseqttl;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar politicamente exposto: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN
              UPDATE tbcadast_politico_exposto pol
                 SET pol.tpexposto        = pr_polexp_new.tpexposto,
                     pol.dtinicio         = pr_polexp_new.dtinicio,
                     pol.dttermino        = pr_polexp_new.dttermino,
                     pol.nmempresa        = rw_pessoa_emp.nmpessoa,
                     pol.nrcnpj_empresa   = rw_pessoa_emp.nrcpfcgc,
                     pol.nmpolitico       = rw_pessoa_pol.nmpessoa,
                     pol.cdocupacao       = pr_polexp_new.cdocupacao,
                     pol.cdrelacionamento = pr_polexp_new.tprelacao_polexp,
                     pol.nrcpf_politico   = rw_pessoa_pol.nrcpfcgc
               WHERE pol.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND pol.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND pol.idseqttl   = vr_tab_contas(idx).idseqttl;
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar politicamente exposto:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN
              --> Inserir registro
              BEGIN
                INSERT INTO tbcadast_politico_exposto
                            ( cdcooper, 
                              nrdconta, 
                              idseqttl, 
                              tpexposto, 
                              dtinicio, 
                              dttermino, 
                              nmempresa, 
                              nrcnpj_empresa, 
                              nmpolitico, 
                              cdocupacao, 
                              cdrelacionamento, 
                              nrcpf_politico )
                     VALUES ( vr_tab_contas(idx).cdcooper,      --> cdcooper
                              vr_tab_contas(idx).nrdconta,      --> nrdconta
                              vr_tab_contas(idx).idseqttl,      --> idseqttl
                              pr_polexp_new.tpexposto,          --> tpexposto
                              pr_polexp_new.dtinicio,           --> dtinicio
                              pr_polexp_new.dttermino,          --> dttermino
                              rw_pessoa_emp.nmpessoa,           --> nmempresa
                              nvl(rw_pessoa_emp.nrcpfcgc,0),           --> nrcnpj_empresa                             
                              rw_pessoa_pol.nmpessoa,           --> nmpolitico
                              pr_polexp_new.cdocupacao,         --> cdocupacao
                              pr_polexp_new.tprelacao_polexp,          --> cdrelacionamento
                              nvl(rw_pessoa_pol.nrcpfcgc,0));          --> nrcpf_politico
                                                            
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir politicamente exposto: '||SQLERRM; 
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar politicamente exposto: '||SQLERRM; 
  END pc_atualiza_polexp;
  
  /*****************************************************************************/
  /**     Procedure para atualizar renda complementar na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_rendacompl( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                   ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                   ,pr_rendacompl_old    IN tbcadast_pessoa_rendacompl%ROWTYPE        --> Dados anteriores
                                   ,pr_rendacompl_new    IN tbcadast_pessoa_rendacompl%ROWTYPE        --> Dados novos
                                   ,pr_dscritic         OUT VARCHAR2                                  --> Retornar Critica 
                                   ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_rendacompl
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar renda complementar na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;                        
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
  
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
              
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              UPDATE crapttl ttl
                                        --> caso o sequencial for igual ao index do campo deve limpar
                 SET ttl.vldrendi##1 = decode(pr_rendacompl_old.nrseq_renda,1,0,ttl.vldrendi##1),
                     ttl.vldrendi##2 = decode(pr_rendacompl_old.nrseq_renda,2,0,ttl.vldrendi##2),
                     ttl.vldrendi##3 = decode(pr_rendacompl_old.nrseq_renda,3,0,ttl.vldrendi##3),
                     ttl.vldrendi##4 = decode(pr_rendacompl_old.nrseq_renda,4,0,ttl.vldrendi##4),
                     ttl.vldrendi##5 = decode(pr_rendacompl_old.nrseq_renda,5,0,ttl.vldrendi##5),
                     ttl.vldrendi##6 = decode(pr_rendacompl_old.nrseq_renda,6,0,ttl.vldrendi##6),
                     --> tprenda
                     ttl.tpdrendi##1 = decode(pr_rendacompl_old.nrseq_renda,1,0,ttl.tpdrendi##1),
                     ttl.tpdrendi##2 = decode(pr_rendacompl_old.nrseq_renda,2,0,ttl.tpdrendi##2),
                     ttl.tpdrendi##3 = decode(pr_rendacompl_old.nrseq_renda,3,0,ttl.tpdrendi##3),
                     ttl.tpdrendi##4 = decode(pr_rendacompl_old.nrseq_renda,4,0,ttl.tpdrendi##4),
                     ttl.tpdrendi##5 = decode(pr_rendacompl_old.nrseq_renda,5,0,ttl.tpdrendi##5),
                     ttl.tpdrendi##6 = decode(pr_rendacompl_old.nrseq_renda,6,0,ttl.tpdrendi##6)
               WHERE ttl.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND ttl.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND ttl.idseqttl   = vr_tab_contas(idx).idseqttl;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar renda complementar do titular: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            
            --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
            --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela            
            IF nvl(pr_rendacompl_new.vlrenda,0) <> nvl(pr_rendacompl_old.vlrenda,0) OR 
               nvl(pr_rendacompl_new.tprenda,0) <> nvl(pr_rendacompl_old.tprenda,0) THEN
               
              --> Realizar alteração     
              BEGIN
                UPDATE crapttl ttl
                       --> caso o sequencial for igual ao index do campo deve atualiza-lo
                       --> vlrenda
                   SET ttl.vldrendi##1 = decode(pr_rendacompl_new.nrseq_renda,1,pr_rendacompl_new.vlrenda,ttl.vldrendi##1),
                       ttl.vldrendi##2 = decode(pr_rendacompl_new.nrseq_renda,2,pr_rendacompl_new.vlrenda,ttl.vldrendi##2),
                       ttl.vldrendi##3 = decode(pr_rendacompl_new.nrseq_renda,3,pr_rendacompl_new.vlrenda,ttl.vldrendi##3),
                       ttl.vldrendi##4 = decode(pr_rendacompl_new.nrseq_renda,4,pr_rendacompl_new.vlrenda,ttl.vldrendi##4),
                       ttl.vldrendi##5 = decode(pr_rendacompl_new.nrseq_renda,5,pr_rendacompl_new.vlrenda,ttl.vldrendi##5),
                       ttl.vldrendi##6 = decode(pr_rendacompl_new.nrseq_renda,6,pr_rendacompl_new.vlrenda,ttl.vldrendi##6),
                       --> tprenda
                       ttl.tpdrendi##1 = decode(pr_rendacompl_new.nrseq_renda,1,pr_rendacompl_new.tprenda,ttl.tpdrendi##1),
                       ttl.tpdrendi##2 = decode(pr_rendacompl_new.nrseq_renda,2,pr_rendacompl_new.tprenda,ttl.tpdrendi##2),
                       ttl.tpdrendi##3 = decode(pr_rendacompl_new.nrseq_renda,3,pr_rendacompl_new.tprenda,ttl.tpdrendi##3),
                       ttl.tpdrendi##4 = decode(pr_rendacompl_new.nrseq_renda,4,pr_rendacompl_new.tprenda,ttl.tpdrendi##4),
                       ttl.tpdrendi##5 = decode(pr_rendacompl_new.nrseq_renda,5,pr_rendacompl_new.tprenda,ttl.tpdrendi##5),
                       ttl.tpdrendi##6 = decode(pr_rendacompl_new.nrseq_renda,6,pr_rendacompl_new.tprenda,ttl.tpdrendi##6)
                       
                 WHERE ttl.cdcooper   = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta   = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl   = vr_tab_contas(idx).idseqttl;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar renda complementar do titular:'||SQLERRM; 
                  RAISE vr_exc_erro;          
              END;
              
                
              --> Se nao foi alterado nenhum registro
              IF SQL%ROWCOUNT  = 0 THEN              
                vr_dscritic := 'Titular não encontrado'; 
                RAISE vr_exc_erro;            
              END IF;
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar renda complementar: '||SQLERRM; 
  END pc_atualiza_rendacompl;
  
  /*****************************************************************************/
  /**     Procedure para atualizar renda na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_renda ( pr_idpessoa     IN tbcadast_pessoa.idpessoa%TYPE        --> Identificador de pessoa                             
                               ,pr_nrseq_renda  IN INTEGER                              --> Sequencial da renda
                               ,pr_tpoperacao   IN INTEGER                              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_renda_old    IN tbcadast_pessoa_renda%ROWTYPE        --> Dados anteriores
                               ,pr_renda_new    IN tbcadast_pessoa_renda%ROWTYPE        --> Dados novos
                               ,pr_dscritic     OUT VARCHAR2                            --> Retornar Critica 
                               ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_renda
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar renda na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa       cr_pessoa%ROWTYPE;                        
    rw_pessoa_renda cr_pessoa%ROWTYPE;                        
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   CADA0010.typ_tab_conta;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
        
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;      
    
    IF vr_tab_contas.count() > 0 THEN
    
      IF pr_renda_new.idpessoa_fonte_renda > 0 THEN
        -- Buscar informações da pessoa fonte renda
        OPEN cr_pessoa (pr_idpessoa => pr_renda_new.idpessoa_fonte_renda );
        FETCH cr_pessoa INTO rw_pessoa_renda; 
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;      
          vr_dscritic := 'Pessoa não encontrada fonte de renda.';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_pessoa;
        END IF;  
      END IF;
      
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
        /* Para contas
           TpRelacao ==> 1-Conjuge (crapcje)
                         2-Empresa de trabalho do conjuge (crapcje)
                         3-Pai (crapttl)
                         4-Mae (crapttl)
                         5-Empresa de trabalho (crapttl)
                         6-Titular (crapttl)
                         7-Titular (crapjur)
                         10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                         20-Representante de uma PJ (crapavt onde tpctato = 6)
                         23-Pai do Representante (crapavt onde tpctato = 6)
                         24-Mae do Representante (crapavt onde tpctato = 6)
                         30-Responsavel Legal (crapcrl)
                         33-Pai do Responsavel Legal (crapcrl)
                         34-Mae do Responsavel Legal (crapcrl)
                         40-Dependente (crapdep)
                         50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                         51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                         60-Empresa de Participacao (PJ) (crapepa)
          */  
      
            
        -- 6-TITULAR
        IF vr_tab_contas(idx).tprelacao IN (6) THEN
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              UPDATE crapttl ttl
                 SET ttl.tpcttrab = 0,
                     ttl.cdturnos = 0,
                     ttl.cdnvlcgo = 0,
                     ttl.dtadmemp = NULL,
                     ttl.cdocpttl = 0,
                     ttl.nrcadast = 0,
                     ttl.vlsalari = 0,
                     ttl.nmextemp = ' ',
                     ttl.nrcpfemp = 0
               WHERE ttl.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND ttl.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND ttl.idseqttl   = vr_tab_contas(idx).idseqttl;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar renda complementar do titular: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
          
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
            --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
            IF nvl(pr_renda_new.tpcontrato_trabalho,0)   <> nvl(pr_renda_old.tpcontrato_trabalho,0)   OR 
               nvl(pr_renda_new.cdturno,0)               <> nvl(pr_renda_old.cdturno,0)               OR
               nvl(pr_renda_new.cdnivel_cargo,0)         <> nvl(pr_renda_old.cdnivel_cargo,0)         OR
               nvl(pr_renda_new.dtadmissao,vr_dtpadrao)  <> nvl(pr_renda_old.dtadmissao,vr_dtpadrao)  OR
               nvl(pr_renda_new.cdocupacao,0)            <> nvl(pr_renda_old.cdocupacao,0)            OR
               nvl(pr_renda_new.nrcadastro,0)            <> nvl(pr_renda_old.nrcadastro,0)            OR
               nvl(pr_renda_new.vlrenda,0)               <> nvl(pr_renda_old.vlrenda,0)               OR
               nvl(pr_renda_new.idpessoa_fonte_renda,0)  <> nvl(pr_renda_old.idpessoa_fonte_renda,0)  THEN
          
              --> Realizar alteração  
              BEGIN
                UPDATE crapttl ttl
                   SET ttl.tpcttrab = pr_renda_new.tpcontrato_trabalho,
                       ttl.cdturnos = pr_renda_new.cdturno,
                       ttl.cdnvlcgo = pr_renda_new.cdnivel_cargo,
                       ttl.dtadmemp = pr_renda_new.dtadmissao,
                       ttl.cdocpttl = pr_renda_new.cdocupacao,
                       ttl.nrcadast = pr_renda_new.nrcadastro,
                       ttl.vlsalari = pr_renda_new.vlrenda,
                       ttl.nmextemp = substr(rw_pessoa_renda.nmpessoa,1,40),
                       ttl.nrcpfemp = rw_pessoa_renda.nrcpfcgc
                 WHERE ttl.cdcooper   = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta   = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl   = vr_tab_contas(idx).idseqttl;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar renda do titular:'||SQLERRM; 
                  RAISE vr_exc_erro;          
              END;
                  
              --> Se nao foi alterado nenhum registro
              IF SQL%ROWCOUNT  = 0 THEN              
                vr_dscritic := 'Titular não encontrado'; 
                RAISE vr_exc_erro;            
              END IF;
            END IF;
          END IF; --> fim tpoperacao          
          
        --> 1-Conjuge
        ELSIF vr_tab_contas(idx).tprelacao IN (1) THEN
          --> Se for diferente de exclusao e é Comercial
          IF pr_tpoperacao <> 3 THEN 
            BEGIN          
              UPDATE crapcje cje
                 SET cje.cdocpcje = pr_renda_new.cdocupacao,
                     cje.tpcttrab = pr_renda_new.tpcontrato_trabalho,
                     cje.cdnvlcgo = pr_renda_new.cdnivel_cargo,
                     cje.cdturnos = pr_renda_new.cdturno,       
                     cje.dtadmemp = pr_renda_new.dtadmissao,
                     cje.vlsalari = nvl(pr_renda_new.vlrenda,0),         
                     cje.nmextemp = substr(rw_pessoa_renda.nmpessoa,1,40),
                     cje.nrdocnpj = rw_pessoa_renda.nrcpfcgc                 
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                 AND nvl(cje.nrcpfcjg,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND cje.nmconjug = rw_pessoa.nmpessoa
                 AND nvl(cje.nrctacje,0) = 0;                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar renda do conjuge: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          --> Se for exclusao
          ELSIF pr_tpoperacao = 3  THEN
            --Em caso de exclusao deve ser limpo os campos
            BEGIN          
              UPDATE crapcje cje
                 SET cje.cdocpcje = 0,
                     cje.tpcttrab = 0,
                     cje.cdnvlcgo = 0,
                     cje.cdturnos = 0,       
                     cje.dtadmemp = NULL,
                     cje.vlsalari = 0,         
                     cje.nmextemp = ' ',
                     cje.nrdocnpj = 0       
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                 AND nvl(cje.nrcpfcjg,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND cje.nmconjug = rw_pessoa.nmpessoa
                 AND nvl(cje.nrctacje,0) = 0; 
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar renda do conjuge: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;
        END IF; --> tipo de relacao
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar renda: '||SQLERRM; 
  END pc_atualiza_renda;
  
  /*****************************************************************************/
  /**     Procedure para atualizar pessoa estrangeira na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_estrangeira ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE        --> Identificador de pessoa                                                                
                                     ,pr_tpoperacao        IN INTEGER                              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_estrangeira_old   IN tbcadast_pessoa_estrangeira%ROWTYPE  --> Dados anteriores
                                     ,pr_estrangeira_new   IN tbcadast_pessoa_estrangeira%ROWTYPE  --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2                             --> Retornar Critica 
                                     ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_estrangeira
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar pessoa estrangeira na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa       cr_pessoa%ROWTYPE;                        
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   CADA0010.typ_tab_conta;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
        
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;      
    
    IF vr_tab_contas.count() > 0 THEN
    
      
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
        /* Para contas
           TpRelacao ==> 1-Conjuge (crapcje)
                         2-Empresa de trabalho do conjuge (crapcje)
                         3-Pai (crapttl)
                         4-Mae (crapttl)
                         5-Empresa de trabalho (crapttl)
                         6-Titular (crapttl)
                         7-Titular (crapjur)
                         10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                         20-Representante de uma PJ (crapavt onde tpctato = 6)
                         23-Pai do Representante (crapavt onde tpctato = 6)
                         24-Mae do Representante (crapavt onde tpctato = 6)
                         30-Responsavel Legal (crapcrl)
                         33-Pai do Responsavel Legal (crapcrl)
                         34-Mae do Responsavel Legal (crapcrl)
                         40-Dependente (crapdep)
                         50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                         51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                         60-Empresa de Participacao (PJ) (crapepa)
          */  
      
            
        -- 6-Titular (crapttl)
        IF vr_tab_contas(idx).tprelacao IN (6) THEN
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              UPDATE crapttl ttl
                 SET --   = pr_estrangeira_new.incrs,
                     --  = pr_estrangeira_new.infatca,
                     ttl.cdnacion  = 0,
                     --  = pr_estrangeira_new.nridentificacao,
                     --  = pr_estrangeira_new.dsnatureza_relacao,
                     --  = pr_estrangeira_new.dsestado,
                     --  = pr_estrangeira_new.nrpassaporte,
                     --  = pr_estrangeira_new.tpdeclarado,
                     ttl.dsnatura  = ' '
               WHERE ttl.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND ttl.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND ttl.idseqttl   = vr_tab_contas(idx).idseqttl;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar dados de pessoa estrangeira do titular: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
          
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
          
            --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
            --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
            IF nvl(pr_estrangeira_new.cdpais,0)           <> nvl(pr_estrangeira_old.cdpais,0)           OR
               nvl(pr_estrangeira_new.dsnaturalidade,' ') <> nvl(pr_estrangeira_old.dsnaturalidade,' ') THEN
          
              --> Realizar alteração  
              BEGIN
                UPDATE crapttl ttl
                   SET --  = pr_estrangeira_new.incrs,
                       --  = pr_estrangeira_new.infatca,
                       ttl.cdnacion  = nvl(pr_estrangeira_new.cdpais,0),
                       --  = pr_estrangeira_new.nridentificacao,
                       --  = pr_estrangeira_new.dsnatureza_relacao,
                       --  = pr_estrangeira_new.dsestado,
                       --  = pr_estrangeira_new.nrpassaporte,
                       --  = pr_estrangeira_new.tpdeclarado,
                       ttl.dsnatura  = pr_estrangeira_new.dsnaturalidade
                 WHERE ttl.cdcooper   = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta   = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl   = vr_tab_contas(idx).idseqttl;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar dados de pessoa estrangeira do titular:'||SQLERRM; 
                  RAISE vr_exc_erro;          
              END;
                  
              --> Se nao foi alterado nenhum registro
              IF SQL%ROWCOUNT  = 0 THEN              
                vr_dscritic := 'Titular não encontrado'; 
                RAISE vr_exc_erro;            
              END IF;
            END IF;
          END IF; --> fim tpoperacao          
            
        END IF;
        
        -- 7-Titular (crapjur)       
        -- 6-Titular(crapttl)         
        IF vr_tab_contas(idx).tprelacao IN (7) OR 
          --> Novamente tipo 6 para atualizar tbm a crapass qnd for idseqttl = 1
          (vr_tab_contas(idx).tprelacao = 6 AND 
           vr_tab_contas(idx).idseqttl = 1)THEN
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              UPDATE crapass ass
                 SET --   = pr_estrangeira_new.incrs,
                     --  = pr_estrangeira_new.infatca,
                     ass.cdnacion  = 0
                     --  = pr_estrangeira_new.nridentificacao,
                     --  = pr_estrangeira_new.dsnatureza_relacao,
                     --  = pr_estrangeira_new.dsestado,
                     --  = pr_estrangeira_new.nrpassaporte,
                     --  = pr_estrangeira_new.tpdeclarado,
                     --  = pr_estrangeira_new.dsnaturalidade
               WHERE ass.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND ass.nrdconta   = vr_tab_contas(idx).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar dados de pessoa estrangeira do associado: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
          
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
            --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
            IF nvl(pr_estrangeira_new.cdpais,0) <> nvl(pr_estrangeira_old.cdpais,0) THEN
          
              --> Realizar alteração  
              BEGIN
                UPDATE crapass ass
                   SET --  = pr_estrangeira_new.incrs,
                       --  = pr_estrangeira_new.infatca,
                       ass.cdnacion  = nvl(pr_estrangeira_new.cdpais,0)
                       --  = pr_estrangeira_new.nridentificacao,
                       --  = pr_estrangeira_new.dsnatureza_relacao,
                       --  = pr_estrangeira_new.dsestado,
                       --  = pr_estrangeira_new.nrpassaporte,
                       --  = pr_estrangeira_new.tpdeclarado,
                       --  = pr_estrangeira_new.dsnaturalidade
                 WHERE ass.cdcooper   = vr_tab_contas(idx).cdcooper
                   AND ass.nrdconta   = vr_tab_contas(idx).nrdconta;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar dados de pessoa estrangeira do titular:'||SQLERRM; 
                  RAISE vr_exc_erro;          
              END;
            END IF;
                
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN              
              vr_dscritic := 'Titular não encontrado'; 
              RAISE vr_exc_erro;            
            END IF;
          END IF; --> fim tpoperacao 
        END IF; --> tipo de relacao
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar dados de pessoa estrangeira: '||SQLERRM; 
  END pc_atualiza_estrangeira;
  
  /*****************************************************************************/
  /**     Procedure para atualizar dados de banco de PJ na estrutura antiga   **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_bco( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_bco_old  IN tbcadast_pessoa_juridica_bco%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_bco_new  IN tbcadast_pessoa_juridica_bco%ROWTYPE      --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2                                  --> Retornar Critica 
                                     ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_juridica_bco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar dados de banco de PJ na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;                        
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;
    vr_dsvencto     VARCHAR2(20);
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
  
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
              
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              UPDATE crapjfn jfn
                                        --> caso o sequencial for igual ao index do campo deve limpar
                     --> cdbanco
                 SET jfn.cddbanco##1 = decode(pr_juridica_bco_old.nrseq_banco,1,0   ,jfn.cddbanco##1),                                       
                     jfn.cddbanco##2 = decode(pr_juridica_bco_old.nrseq_banco,2,0   ,jfn.cddbanco##2),
                     jfn.cddbanco##3 = decode(pr_juridica_bco_old.nrseq_banco,3,0   ,jfn.cddbanco##3),
                     jfn.cddbanco##4 = decode(pr_juridica_bco_old.nrseq_banco,4,0   ,jfn.cddbanco##4),
                     jfn.cddbanco##5 = decode(pr_juridica_bco_old.nrseq_banco,5,0   ,jfn.cddbanco##5),
                     
                     --> dsoperacao
                     jfn.dstipope##1 = decode(pr_juridica_bco_old.nrseq_banco,1,' ',jfn.dstipope##1), 
                     jfn.dstipope##2 = decode(pr_juridica_bco_old.nrseq_banco,2,' ',jfn.dstipope##2), 
                     jfn.dstipope##3 = decode(pr_juridica_bco_old.nrseq_banco,3,' ',jfn.dstipope##3), 
                     jfn.dstipope##4 = decode(pr_juridica_bco_old.nrseq_banco,4,' ',jfn.dstipope##4), 
                     jfn.dstipope##5 = decode(pr_juridica_bco_old.nrseq_banco,5,' ',jfn.dstipope##5), 
                     
                     --> vloperacao 
                     jfn.vlropera##1 = decode(pr_juridica_bco_old.nrseq_banco,1,0 ,jfn.vlropera##1),  
                     jfn.vlropera##2 = decode(pr_juridica_bco_old.nrseq_banco,2,0 ,jfn.vlropera##2),  
                     jfn.vlropera##3 = decode(pr_juridica_bco_old.nrseq_banco,3,0 ,jfn.vlropera##3),  
                     jfn.vlropera##4 = decode(pr_juridica_bco_old.nrseq_banco,4,0 ,jfn.vlropera##4),  
                     jfn.vlropera##5 = decode(pr_juridica_bco_old.nrseq_banco,5,0 ,jfn.vlropera##5),  
                     
                     --> dsgarantia
                     jfn.garantia##1 = decode(pr_juridica_bco_old.nrseq_banco,1,' ',jfn.garantia##1),   
                     jfn.garantia##2 = decode(pr_juridica_bco_old.nrseq_banco,2,' ',jfn.garantia##2),  
                     jfn.garantia##3 = decode(pr_juridica_bco_old.nrseq_banco,3,' ',jfn.garantia##3), 
                     jfn.garantia##4 = decode(pr_juridica_bco_old.nrseq_banco,4,' ',jfn.garantia##4),
                     jfn.garantia##5 = decode(pr_juridica_bco_old.nrseq_banco,5,' ',jfn.garantia##5),                
                     
                     --> dtvencimento
                     jfn.dsvencto##1 = decode(pr_juridica_bco_old.nrseq_banco,1,' ',jfn.dsvencto##1),   
                     jfn.dsvencto##2 = decode(pr_juridica_bco_old.nrseq_banco,2,' ',jfn.dsvencto##2),   
                     jfn.dsvencto##3 = decode(pr_juridica_bco_old.nrseq_banco,3,' ',jfn.dsvencto##3),   
                     jfn.dsvencto##4 = decode(pr_juridica_bco_old.nrseq_banco,4,' ',jfn.dsvencto##4),   
                     jfn.dsvencto##5 = decode(pr_juridica_bco_old.nrseq_banco,5,' ',jfn.dsvencto##5)   
                     
               WHERE jfn.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND jfn.nrdconta   = vr_tab_contas(idx).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar dados de banco de PJ: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN
              IF pr_juridica_bco_new.dtvencimento IS NULL THEN
                vr_dsvencto := 'VARIOS';
              ELSE  
                vr_dsvencto := to_char(pr_juridica_bco_new.dtvencimento,'DD/MM/RRRR'); 
              END IF;
            
            
              UPDATE crapjfn jfn
                                        --> caso o sequencial for igual ao index do campo deve atualiza-lo
                     --> cdbanco
                 SET jfn.cddbanco##1 = decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.cdbanco   ,jfn.cddbanco##1),                                       
                     jfn.cddbanco##2 = decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.cdbanco   ,jfn.cddbanco##2),
                     jfn.cddbanco##3 = decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.cdbanco   ,jfn.cddbanco##3),
                     jfn.cddbanco##4 = decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.cdbanco   ,jfn.cddbanco##4),
                     jfn.cddbanco##5 = decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.cdbanco   ,jfn.cddbanco##5),
                     
                     --> dsoperacao
                     jfn.dstipope##1 = decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.dsoperacao,jfn.dstipope##1), 
                     jfn.dstipope##2 = decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.dsoperacao,jfn.dstipope##2), 
                     jfn.dstipope##3 = decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.dsoperacao,jfn.dstipope##3), 
                     jfn.dstipope##4 = decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.dsoperacao,jfn.dstipope##4), 
                     jfn.dstipope##5 = decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.dsoperacao,jfn.dstipope##5), 
                     
                     --> vloperacao
                     jfn.vlropera##1 = decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.vloperacao,jfn.vlropera##1),  
                     jfn.vlropera##2 = decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.vloperacao,jfn.vlropera##2),  
                     jfn.vlropera##3 = decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.vloperacao,jfn.vlropera##3),  
                     jfn.vlropera##4 = decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.vloperacao,jfn.vlropera##4),  
                     jfn.vlropera##5 = decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.vloperacao,jfn.vlropera##5), 
                     
                     --> dsgarantia
                     jfn.garantia##1 = decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.dsgarantia,jfn.garantia##1),                     
                     jfn.garantia##2 = decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.dsgarantia,jfn.garantia##2),
                     jfn.garantia##3 = decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.dsgarantia,jfn.garantia##3),
                     jfn.garantia##4 = decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.dsgarantia,jfn.garantia##4),
                     jfn.garantia##5 = decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.dsgarantia,jfn.garantia##5),
                     
                     --> dtvencimento
                     jfn.dsvencto##1 = decode(pr_juridica_bco_new.nrseq_banco,1,vr_dsvencto,jfn.dsvencto##1),   
                     jfn.dsvencto##2 = decode(pr_juridica_bco_new.nrseq_banco,2,vr_dsvencto,jfn.dsvencto##2),   
                     jfn.dsvencto##3 = decode(pr_juridica_bco_new.nrseq_banco,3,vr_dsvencto,jfn.dsvencto##3),   
                     jfn.dsvencto##4 = decode(pr_juridica_bco_new.nrseq_banco,4,vr_dsvencto,jfn.dsvencto##4),   
                     jfn.dsvencto##5 = decode(pr_juridica_bco_new.nrseq_banco,5,vr_dsvencto,jfn.dsvencto##5)
                     
               WHERE jfn.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND jfn.nrdconta   = vr_tab_contas(idx).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar dados de banco de PJ:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN              
              BEGIN      
                INSERT INTO crapjfn                             
                            (cdcooper,
                             nrdconta,
                             --> cdbanco
                             cddbanco##1, 
                             cddbanco##2, 
                             cddbanco##3, 
                             cddbanco##4, 
                             cddbanco##5,                              
                             --> dsoperacao
                             dstipope##1, 
                             dstipope##2, 
                             dstipope##3, 
                             dstipope##4, 
                             dstipope##5,                              
                             --> vloperacao
                             vlropera##1, 
                             vlropera##2, 
                             vlropera##3, 
                             vlropera##4, 
                             vlropera##5, 
                             --> dsgarantia
                             garantia##1, 
                             garantia##2, 
                             garantia##3, 
                             garantia##4, 
                             garantia##5,                              
                             --> dtvencimento
                             dsvencto##1, 
                             dsvencto##2, 
                             dsvencto##3, 
                             dsvencto##4, 
                             dsvencto##5 
                             
                             )
                     VALUES( vr_tab_contas(idx).cdcooper,
                             vr_tab_contas(idx).nrdconta,
                             --> cdbanco
                             decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.cdbanco   ,0),
                             decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.cdbanco   ,0),
                             decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.cdbanco   ,0),
                             decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.cdbanco   ,0),
                             decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.cdbanco   ,0),
                             --> dsoperacao                             
                             decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.dsoperacao,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.dsoperacao,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.dsoperacao,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.dsoperacao,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.dsoperacao,' '),
                             --> vloperacao                             
                             decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.vloperacao,0),
                             decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.vloperacao,0),
                             decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.vloperacao,0),
                             decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.vloperacao,0),
                             decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.vloperacao,0),
                             --> dsgarantia                             
                             decode(pr_juridica_bco_new.nrseq_banco,1,pr_juridica_bco_new.dsgarantia,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,2,pr_juridica_bco_new.dsgarantia,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,3,pr_juridica_bco_new.dsgarantia,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,4,pr_juridica_bco_new.dsgarantia,' '),
                             decode(pr_juridica_bco_new.nrseq_banco,5,pr_juridica_bco_new.dsgarantia,' '),
                             --> dtvencimento                             
                             decode(pr_juridica_bco_new.nrseq_banco,1,vr_dsvencto,' '),   
                             decode(pr_juridica_bco_new.nrseq_banco,2,vr_dsvencto,' '),   
                             decode(pr_juridica_bco_new.nrseq_banco,3,vr_dsvencto,' '),   
                             decode(pr_juridica_bco_new.nrseq_banco,4,vr_dsvencto,' '),   
                             decode(pr_juridica_bco_new.nrseq_banco,5,vr_dsvencto,' ')
                             );
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir dados de banco de PJ:'||SQLERRM; 
                  RAISE vr_exc_erro;         
              END;            
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar dados de banco de PJ: '||SQLERRM; 
  END pc_atualiza_juridica_bco;
  
  /*****************************************************************************/
  /** Procedure para atualizar dados de faturamento de PJ na estrutura antiga **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_fat( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_fat_old  IN tbcadast_pessoa_juridica_fat%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_fat_new  IN tbcadast_pessoa_juridica_fat%ROWTYPE      --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2                                  --> Retornar Critica 
                                     ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_juridica_fat
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar dados de faturamento de PJ na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;                        
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;
    vr_mesftbru     INTEGER;
    vr_anoftbru     INTEGER;
    
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
  
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
              
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              UPDATE crapjfn jfn
                                        --> caso o sequencial for igual ao index do campo deve limpar
                     --> dtmes_referencia
                 SET jfn.mesftbru##1  = decode(pr_juridica_fat_old.nrseq_faturamento,1 ,0   ,jfn.mesftbru##1 ),
                     jfn.mesftbru##2  = decode(pr_juridica_fat_old.nrseq_faturamento,2 ,0   ,jfn.mesftbru##2 ),
                     jfn.mesftbru##3  = decode(pr_juridica_fat_old.nrseq_faturamento,3 ,0   ,jfn.mesftbru##3 ),
                     jfn.mesftbru##4  = decode(pr_juridica_fat_old.nrseq_faturamento,4 ,0   ,jfn.mesftbru##4 ),
                     jfn.mesftbru##5  = decode(pr_juridica_fat_old.nrseq_faturamento,5 ,0   ,jfn.mesftbru##5 ),
                     jfn.mesftbru##6  = decode(pr_juridica_fat_old.nrseq_faturamento,6 ,0   ,jfn.mesftbru##6 ),
                     jfn.mesftbru##7  = decode(pr_juridica_fat_old.nrseq_faturamento,7 ,0   ,jfn.mesftbru##7 ),
                     jfn.mesftbru##8  = decode(pr_juridica_fat_old.nrseq_faturamento,8 ,0   ,jfn.mesftbru##8 ),
                     jfn.mesftbru##9  = decode(pr_juridica_fat_old.nrseq_faturamento,9 ,0   ,jfn.mesftbru##9 ),
                     jfn.mesftbru##10 = decode(pr_juridica_fat_old.nrseq_faturamento,10,0   ,jfn.mesftbru##10),
                     jfn.mesftbru##11 = decode(pr_juridica_fat_old.nrseq_faturamento,11,0   ,jfn.mesftbru##11),
                     jfn.mesftbru##12 = decode(pr_juridica_fat_old.nrseq_faturamento,12,0   ,jfn.mesftbru##12),
                     
                     --> dtmes_referencia
                     jfn.anoftbru##1  = decode(pr_juridica_fat_old.nrseq_faturamento,1 ,0 ,jfn.anoftbru##1 ), 
                     jfn.anoftbru##2  = decode(pr_juridica_fat_old.nrseq_faturamento,2 ,0 ,jfn.anoftbru##2 ), 
                     jfn.anoftbru##3  = decode(pr_juridica_fat_old.nrseq_faturamento,3 ,0 ,jfn.anoftbru##3 ), 
                     jfn.anoftbru##4  = decode(pr_juridica_fat_old.nrseq_faturamento,4 ,0 ,jfn.anoftbru##4 ), 
                     jfn.anoftbru##5  = decode(pr_juridica_fat_old.nrseq_faturamento,5 ,0 ,jfn.anoftbru##5 ), 
                     jfn.anoftbru##6  = decode(pr_juridica_fat_old.nrseq_faturamento,6 ,0 ,jfn.anoftbru##6 ), 
                     jfn.anoftbru##7  = decode(pr_juridica_fat_old.nrseq_faturamento,7 ,0 ,jfn.anoftbru##7 ), 
                     jfn.anoftbru##8  = decode(pr_juridica_fat_old.nrseq_faturamento,8 ,0 ,jfn.anoftbru##8 ), 
                     jfn.anoftbru##9  = decode(pr_juridica_fat_old.nrseq_faturamento,9 ,0 ,jfn.anoftbru##9 ), 
                     jfn.anoftbru##10 = decode(pr_juridica_fat_old.nrseq_faturamento,10,0 ,jfn.anoftbru##10), 
                     jfn.anoftbru##11 = decode(pr_juridica_fat_old.nrseq_faturamento,11,0 ,jfn.anoftbru##11), 
                     jfn.anoftbru##12 = decode(pr_juridica_fat_old.nrseq_faturamento,12,0 ,jfn.anoftbru##12), 
                                                                                         
                     --> vlfaturamento_bruto                                             
                     jfn.vlrftbru##1  = decode(pr_juridica_fat_old.nrseq_faturamento,1 ,0 ,jfn.vlrftbru##1 ),  
                     jfn.vlrftbru##2  = decode(pr_juridica_fat_old.nrseq_faturamento,2 ,0 ,jfn.vlrftbru##2 ),  
                     jfn.vlrftbru##3  = decode(pr_juridica_fat_old.nrseq_faturamento,3 ,0 ,jfn.vlrftbru##3 ),  
                     jfn.vlrftbru##4  = decode(pr_juridica_fat_old.nrseq_faturamento,4 ,0 ,jfn.vlrftbru##4 ),  
                     jfn.vlrftbru##5  = decode(pr_juridica_fat_old.nrseq_faturamento,5 ,0 ,jfn.vlrftbru##5 ),  
                     jfn.vlrftbru##6  = decode(pr_juridica_fat_old.nrseq_faturamento,6 ,0 ,jfn.vlrftbru##6 ),  
                     jfn.vlrftbru##7  = decode(pr_juridica_fat_old.nrseq_faturamento,7 ,0 ,jfn.vlrftbru##7 ),  
                     jfn.vlrftbru##8  = decode(pr_juridica_fat_old.nrseq_faturamento,8 ,0 ,jfn.vlrftbru##8 ),  
                     jfn.vlrftbru##9  = decode(pr_juridica_fat_old.nrseq_faturamento,9 ,0 ,jfn.vlrftbru##9 ),  
                     jfn.vlrftbru##10 = decode(pr_juridica_fat_old.nrseq_faturamento,10,0 ,jfn.vlrftbru##10),  
                     jfn.vlrftbru##11 = decode(pr_juridica_fat_old.nrseq_faturamento,11,0 ,jfn.vlrftbru##11),  
                     jfn.vlrftbru##12 = decode(pr_juridica_fat_old.nrseq_faturamento,12,0 ,jfn.vlrftbru##12)                       
                     
               WHERE jfn.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND jfn.nrdconta   = vr_tab_contas(idx).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar dados de faturamento de PJ: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN
              IF pr_juridica_fat_new.dtmes_referencia IS NULL THEN
                vr_mesftbru := 0;
                vr_anoftbru := 0;
              ELSE  
                vr_mesftbru := to_char(pr_juridica_fat_new.dtmes_referencia,'MM');
                vr_anoftbru := to_char(pr_juridica_fat_new.dtmes_referencia,'RRRR');
              END IF;
            
            
              UPDATE crapjfn jfn
                                        --> caso o sequencial for igual ao index do campo deve atualiza-lo
                     --> dtmes_referencia
                 SET jfn.mesftbru##1  = decode(pr_juridica_fat_new.nrseq_faturamento,1 ,vr_mesftbru  ,jfn.mesftbru##1 ),
                     jfn.mesftbru##2  = decode(pr_juridica_fat_new.nrseq_faturamento,2 ,vr_mesftbru  ,jfn.mesftbru##2 ),
                     jfn.mesftbru##3  = decode(pr_juridica_fat_new.nrseq_faturamento,3 ,vr_mesftbru  ,jfn.mesftbru##3 ),
                     jfn.mesftbru##4  = decode(pr_juridica_fat_new.nrseq_faturamento,4 ,vr_mesftbru  ,jfn.mesftbru##4 ),
                     jfn.mesftbru##5  = decode(pr_juridica_fat_new.nrseq_faturamento,5 ,vr_mesftbru  ,jfn.mesftbru##5 ),
                     jfn.mesftbru##6  = decode(pr_juridica_fat_new.nrseq_faturamento,6 ,vr_mesftbru  ,jfn.mesftbru##6 ),
                     jfn.mesftbru##7  = decode(pr_juridica_fat_new.nrseq_faturamento,7 ,vr_mesftbru  ,jfn.mesftbru##7 ),
                     jfn.mesftbru##8  = decode(pr_juridica_fat_new.nrseq_faturamento,8 ,vr_mesftbru  ,jfn.mesftbru##8 ),
                     jfn.mesftbru##9  = decode(pr_juridica_fat_new.nrseq_faturamento,9 ,vr_mesftbru  ,jfn.mesftbru##9 ),
                     jfn.mesftbru##10 = decode(pr_juridica_fat_new.nrseq_faturamento,10,vr_mesftbru  ,jfn.mesftbru##10),
                     jfn.mesftbru##11 = decode(pr_juridica_fat_new.nrseq_faturamento,11,vr_mesftbru  ,jfn.mesftbru##11),
                     jfn.mesftbru##12 = decode(pr_juridica_fat_new.nrseq_faturamento,12,vr_mesftbru  ,jfn.mesftbru##12),
                     
                     --> dtmes_referencia
                     jfn.anoftbru##1  = decode(pr_juridica_fat_new.nrseq_faturamento,1 ,vr_anoftbru ,jfn.anoftbru##1 ), 
                     jfn.anoftbru##2  = decode(pr_juridica_fat_new.nrseq_faturamento,2 ,vr_anoftbru ,jfn.anoftbru##2 ), 
                     jfn.anoftbru##3  = decode(pr_juridica_fat_new.nrseq_faturamento,3 ,vr_anoftbru ,jfn.anoftbru##3 ), 
                     jfn.anoftbru##4  = decode(pr_juridica_fat_new.nrseq_faturamento,4 ,vr_anoftbru ,jfn.anoftbru##4 ), 
                     jfn.anoftbru##5  = decode(pr_juridica_fat_new.nrseq_faturamento,5 ,vr_anoftbru ,jfn.anoftbru##5 ), 
                     jfn.anoftbru##6  = decode(pr_juridica_fat_new.nrseq_faturamento,6 ,vr_anoftbru ,jfn.anoftbru##6 ), 
                     jfn.anoftbru##7  = decode(pr_juridica_fat_new.nrseq_faturamento,7 ,vr_anoftbru ,jfn.anoftbru##7 ), 
                     jfn.anoftbru##8  = decode(pr_juridica_fat_new.nrseq_faturamento,8 ,vr_anoftbru ,jfn.anoftbru##8 ), 
                     jfn.anoftbru##9  = decode(pr_juridica_fat_new.nrseq_faturamento,9 ,vr_anoftbru ,jfn.anoftbru##9 ), 
                     jfn.anoftbru##10 = decode(pr_juridica_fat_new.nrseq_faturamento,10,vr_anoftbru ,jfn.anoftbru##10), 
                     jfn.anoftbru##11 = decode(pr_juridica_fat_new.nrseq_faturamento,11,vr_anoftbru ,jfn.anoftbru##11), 
                     jfn.anoftbru##12 = decode(pr_juridica_fat_new.nrseq_faturamento,12,vr_anoftbru ,jfn.anoftbru##12), 
                     
                     --> vlfaturamento_bruto 
                     jfn.vlrftbru##1  = decode(pr_juridica_fat_new.nrseq_faturamento,1 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##1 ),  
                     jfn.vlrftbru##2  = decode(pr_juridica_fat_new.nrseq_faturamento,2 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##2 ),  
                     jfn.vlrftbru##3  = decode(pr_juridica_fat_new.nrseq_faturamento,3 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##3 ),  
                     jfn.vlrftbru##4  = decode(pr_juridica_fat_new.nrseq_faturamento,4 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##4 ),  
                     jfn.vlrftbru##5  = decode(pr_juridica_fat_new.nrseq_faturamento,5 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##5 ),  
                     jfn.vlrftbru##6  = decode(pr_juridica_fat_new.nrseq_faturamento,6 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##6 ),  
                     jfn.vlrftbru##7  = decode(pr_juridica_fat_new.nrseq_faturamento,7 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##7 ),  
                     jfn.vlrftbru##8  = decode(pr_juridica_fat_new.nrseq_faturamento,8 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##8 ),  
                     jfn.vlrftbru##9  = decode(pr_juridica_fat_new.nrseq_faturamento,9 ,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##9 ),  
                     jfn.vlrftbru##10 = decode(pr_juridica_fat_new.nrseq_faturamento,10,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##10),  
                     jfn.vlrftbru##11 = decode(pr_juridica_fat_new.nrseq_faturamento,11,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##11),  
                     jfn.vlrftbru##12 = decode(pr_juridica_fat_new.nrseq_faturamento,12,pr_juridica_fat_new.vlfaturamento_bruto ,jfn.vlrftbru##12)
                     
               WHERE jfn.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND jfn.nrdconta   = vr_tab_contas(idx).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar dados de faturamento de PJ:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN              
              BEGIN      
                INSERT INTO crapjfn                             
                            (cdcooper,
                             nrdconta,
                             --> dtmes_referencia
                             mesftbru##1, 
                             mesftbru##2,
                             mesftbru##3, 
                             mesftbru##4, 
                             mesftbru##5, 
                             mesftbru##6, 
                             mesftbru##7, 
                             mesftbru##8, 
                             mesftbru##9, 
                             mesftbru##10,
                             mesftbru##11,
                             mesftbru##12,
                             --> dtmes_referencia
                             anoftbru##1, 
                             anoftbru##2, 
                             anoftbru##3, 
                             anoftbru##4, 
                             anoftbru##5, 
                             anoftbru##6, 
                             anoftbru##7, 
                             anoftbru##8, 
                             anoftbru##9, 
                             anoftbru##10,
                             anoftbru##11,
                             anoftbru##12,
                             --> vlfaturamento_bruto 
                             vlrftbru##1, 
                             vlrftbru##2, 
                             vlrftbru##3, 
                             vlrftbru##4, 
                             vlrftbru##5, 
                             vlrftbru##6, 
                             vlrftbru##7, 
                             vlrftbru##8, 
                             vlrftbru##9, 
                             vlrftbru##10,
                             vlrftbru##11,
                             vlrftbru##12)
                     VALUES( vr_tab_contas(idx).cdcooper,
                             vr_tab_contas(idx).nrdconta,
                             --> dtmes_referencia
                             decode(pr_juridica_fat_new.nrseq_faturamento,1 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,2 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,3 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,4 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,5 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,6 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,7 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,8 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,9 ,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,10,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,11,vr_mesftbru  ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,12,vr_mesftbru  ,0 ),
                             --> dtmes_referencia
                             decode(pr_juridica_fat_new.nrseq_faturamento,1 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,2 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,3 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,4 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,5 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,6 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,7 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,8 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,9 ,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,10,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,11,vr_anoftbru ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,12,vr_anoftbru ,0 ),
                             --> vlfaturamento_bruto 
                             decode(pr_juridica_fat_new.nrseq_faturamento,1 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,2 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,3 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,4 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,5 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,6 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,7 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,8 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,9 ,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,10,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,11,pr_juridica_fat_new.vlfaturamento_bruto ,0 ),
                             decode(pr_juridica_fat_new.nrseq_faturamento,12,pr_juridica_fat_new.vlfaturamento_bruto ,0 )                                                          
                             );
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir dados de faturamento de PJ:'||SQLERRM; 
                  RAISE vr_exc_erro;         
              END;             
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar dados de faturamento de PJ: '||SQLERRM; 
  END pc_atualiza_juridica_fat;
  
  /*****************************************************************************/
  /** Procedure para atualizar resultados financeiros de PJ na estrutura antiga **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_fnc( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_fnc_old  IN tbcadast_pessoa_juridica_fnc%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_fnc_new  IN tbcadast_pessoa_juridica_fnc%ROWTYPE      --> Dados novos
                                     ,pr_dscritic         OUT VARCHAR2                                  --> Retornar Critica 
                                     ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_juridica_fnc
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar resultados financeiros de PJ na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;                        
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;
    
    
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
  
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
              
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              UPDATE crapjfn jfn                    
                 SET jfn.vlrctbru = 0,
                     jfn.vlctdpad = 0,
                     jfn.vldspfin = 0,
                     jfn.ddprzrec = 0,
                     jfn.ddprzpag = 0,
                     jfn.vlcxbcaf = 0,
                     jfn.vlctarcb = 0,
                     jfn.vlrestoq = 0,
                     jfn.vlrimobi = 0,
                     jfn.vloutatv = 0,
                     jfn.vlfornec = 0,
                     jfn.vldivbco = 0,
                     jfn.vloutpas = 0,
                     jfn.mesdbase = 0,
                     jfn.anodbase = 0                     
               WHERE jfn.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND jfn.nrdconta   = vr_tab_contas(idx).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar resultados financeiros de PJ: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN              
            
              UPDATE crapjfn jfn
                 SET jfn.vlrctbru = pr_juridica_fnc_new.vlreceita_bruta,
                     jfn.vlctdpad = pr_juridica_fnc_new.vlcusto_despesa_adm,
                     jfn.vldspfin = pr_juridica_fnc_new.vldespesa_administrativa,
                     jfn.ddprzrec = pr_juridica_fnc_new.qtdias_recebimento,
                     jfn.ddprzpag = pr_juridica_fnc_new.qtdias_pagamento,
                     jfn.vlcxbcaf = pr_juridica_fnc_new.vlativo_caixa_banco_apl,
                     jfn.vlctarcb = pr_juridica_fnc_new.vlativo_contas_receber,
                     jfn.vlrestoq = pr_juridica_fnc_new.vlativo_estoque,
                     jfn.vlrimobi = pr_juridica_fnc_new.vlativo_imobilizado,
                     jfn.vloutatv = pr_juridica_fnc_new.vlativo_outros,
                     jfn.vlfornec = pr_juridica_fnc_new.vlpassivo_fornecedor,
                     jfn.vldivbco = pr_juridica_fnc_new.vlpassivo_divida_bancaria,
                     jfn.vloutpas = pr_juridica_fnc_new.vlpassivo_outros,
                     jfn.mesdbase = to_char(pr_juridica_fnc_new.dtmes_base,'MM'),
                     jfn.anodbase = to_char(pr_juridica_fnc_new.dtmes_base,'RRRR')
                     
               WHERE jfn.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND jfn.nrdconta   = vr_tab_contas(idx).nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar resultados financeiros de PJ:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN        
              BEGIN      
                INSERT INTO crapjfn
                            (cdcooper,
                             nrdconta,
                             vlrctbru,
                             vlctdpad,
                             vldspfin,
                             ddprzrec,
                             ddprzpag,
                             vlcxbcaf,
                             vlctarcb,
                             vlrestoq,
                             vlrimobi,
                             vloutatv,
                             vlfornec,
                             vldivbco,
                             vloutpas,
                             mesdbase,
                             anodbase)
                     VALUES( vr_tab_contas(idx).cdcooper,
                             vr_tab_contas(idx).nrdconta,
                             pr_juridica_fnc_new.vlreceita_bruta,
                             pr_juridica_fnc_new.vlcusto_despesa_adm,
                             pr_juridica_fnc_new.vldespesa_administrativa,
                             pr_juridica_fnc_new.qtdias_recebimento,
                             pr_juridica_fnc_new.qtdias_pagamento,
                             pr_juridica_fnc_new.vlativo_caixa_banco_apl,
                             pr_juridica_fnc_new.vlativo_contas_receber,
                             pr_juridica_fnc_new.vlativo_estoque,
                             pr_juridica_fnc_new.vlativo_imobilizado,
                             pr_juridica_fnc_new.vlativo_outros,
                             pr_juridica_fnc_new.vlpassivo_fornecedor,
                             pr_juridica_fnc_new.vlpassivo_divida_bancaria,
                             pr_juridica_fnc_new.vlpassivo_outros,
                             to_char(pr_juridica_fnc_new.dtmes_base,'MM'),
                             to_char(pr_juridica_fnc_new.dtmes_base,'RRRR'));
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar resultados financeiros de PJ:'||SQLERRM; 
                  RAISE vr_exc_erro;         
              END;                   
                          
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar resultados financeiros de PJ: '||SQLERRM; 
  END pc_atualiza_juridica_fnc;
  
  /*****************************************************************************/
  /** Procedure para atualizar paticipacao societaria na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_ptp( pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao         IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_ptp_old   IN tbcadast_pessoa_juridica_ptp%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_ptp_new   IN tbcadast_pessoa_juridica_ptp%ROWTYPE      --> Dados novos
                                     ,pr_dscritic          OUT VARCHAR2                                  --> Retornar Critica 
                                     ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_juridica_ptp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar paticipacao societaria na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa       cr_pessoa%ROWTYPE;         
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_jur (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nmfantasia,
             pes.nrinscricao_estadual,
             pes.cdnatureza_juridica, 
             pes.dtinicio_atividade,  
             pes.qtfilial,
             pes.qtfuncionario,
             pes.dssite,
             pes.cdsetor_economico,
             pes.cdramo_atividade,
             pes.nmpessoa,
             pes.nrcnpj
        FROM vwcadast_pessoa_juridica pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa_jur     cr_pessoa_jur%ROWTYPE;  
    rw_pessoa_jur_new cr_pessoa_jur%ROWTYPE;  
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;    
    vr_nrdconta     crapass.nrdconta%TYPE;
    
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    -- Buscar informações da pessoa participante
    OPEN cr_pessoa_jur (pr_idpessoa => nvl(pr_juridica_ptp_old.idpessoa_participacao,
                                           pr_juridica_ptp_new.idpessoa_participacao) );
    FETCH cr_pessoa_jur INTO rw_pessoa_jur; 
    IF cr_pessoa_jur%NOTFOUND THEN
      CLOSE cr_pessoa_jur;      
      vr_dscritic := 'Pessoa juridica não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa_jur;
    END IF;     
    
    rw_pessoa_jur_new := NULL;
    IF pr_juridica_ptp_new.idpessoa_participacao > 0 THEN
      -- Buscar informações da pessoa participante
      OPEN cr_pessoa_jur (pr_idpessoa => pr_juridica_ptp_new.idpessoa_participacao );
      FETCH cr_pessoa_jur INTO rw_pessoa_jur_new; 
      IF cr_pessoa_jur%NOTFOUND THEN
        CLOSE cr_pessoa_jur;      
        vr_dscritic := 'Pessoa juridica não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa_jur;
      END IF;
    END IF;
        
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
      
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP        
                 
          --> Exclusao ou se mudou a pessoa
          IF pr_tpoperacao = 3 OR 
             (nvl(pr_juridica_ptp_old.idpessoa_participacao,
                  pr_juridica_ptp_new.idpessoa_participacao) <> pr_juridica_ptp_new.idpessoa_participacao)          
            THEN
            --> Deletar registro
            BEGIN
              DELETE crapepa epa
               WHERE epa.cdcooper = vr_tab_contas(idx).cdcooper
                 AND epa.nrdconta = vr_tab_contas(idx).nrdconta
                 AND epa.nrdocsoc = rw_pessoa_jur.nrcnpj;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar paticipacao societaria de PJ: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          END IF;
          
          --> Senao é ALTERACAO/INCLUSAO  
          IF pr_tpoperacao <> 3 THEN          
            --> Buscar numero da cona mais recente
            pc_ret_conta_recente( pr_nrcpfcgc   => rw_pessoa_jur_new.nrcnpj     --> Numero do CPF/CNPJ
                                 ,pr_cdcooper   => vr_tab_contas(idx).cdcooper  --> Codigo da cooperativa
                                 ,pr_nrdconta   => vr_nrdconta                  --> Retornar contas
                                 ,pr_dscritic   => vr_dscritic);                --> Retornar Critica       
                      
            --> Realizar alteração  
            BEGIN              
              
              UPDATE crapepa epa
                 SET epa.nrctasoc = vr_nrdconta,
                     epa.nmfansia = decode(vr_nrdconta,0,rw_pessoa_jur_new.nmfantasia          ,' '   ),
                     epa.nrinsest = decode(vr_nrdconta,0,rw_pessoa_jur_new.nrinscricao_estadual,0     ),
                     epa.natjurid = decode(vr_nrdconta,0,rw_pessoa_jur_new.cdnatureza_juridica ,0     ),
                     epa.dtiniatv = decode(vr_nrdconta,0,rw_pessoa_jur_new.dtinicio_atividade  ,NULL  ),
                     epa.qtfilial = decode(vr_nrdconta,0,rw_pessoa_jur_new.qtfilial            ,0     ),
                     epa.qtfuncio = decode(vr_nrdconta,0,rw_pessoa_jur_new.qtfuncionario       ,0     ),
                     epa.dsendweb = decode(vr_nrdconta,0,rw_pessoa_jur_new.dssite              ,' '   ),
                     epa.cdseteco = decode(vr_nrdconta,0,rw_pessoa_jur_new.cdsetor_economico   ,0     ),
                     --> cdmodali = 
                     epa.cdrmativ = decode(vr_nrdconta,0,rw_pessoa_jur_new.cdramo_atividade    ,0     ),
                     --> vledvmto = 
                     epa.dtadmiss = pr_juridica_ptp_new.dtadmissao,
                     --> dtmvtolt = 
                     epa.persocio = pr_juridica_ptp_new.persocio,
                     epa.nmprimtl = decode(vr_nrdconta,0,substr(rw_pessoa_jur_new.nmpessoa,1,40)            ,' '   ),
                     epa.nrdocsoc = rw_pessoa_jur_new.nrcnpj
               WHERE epa.cdcooper = vr_tab_contas(idx).cdcooper
                 AND epa.nrdconta = vr_tab_contas(idx).nrdconta
                 AND epa.nrdocsoc = rw_pessoa_jur.nrcnpj;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar paticipacao societaria de PJ:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN        
              BEGIN      
                INSERT INTO crapepa
                            (cdcooper,
                             nrdconta,
                             nrdocsoc,
                             nrctasoc,
                             nmfansia,
                             nrinsest,
                             natjurid,
                             dtiniatv,
                             qtfilial,
                             qtfuncio,
                             dsendweb,
                             cdseteco,
                             cdrmativ,
                             dtadmiss,
                             persocio,
                             nmprimtl )
                     VALUES( vr_tab_contas(idx).cdcooper,                                       --> cdcooper
                             vr_tab_contas(idx).nrdconta,                                       --> nrdconta
                             rw_pessoa_jur_new.nrcnpj,                                          --> nrdocsoc
                             vr_nrdconta,                                                       --> nrctasoc
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.nmfantasia          ,' '  ),--> nmfansia
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.nrinscricao_estadual,0    ),--> nrinsest
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.cdnatureza_juridica ,0    ),--> natjurid
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.dtinicio_atividade  ,NULL ),--> dtiniatv
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.qtfilial            ,0    ),--> qtfilial
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.qtfuncionario       ,0    ),--> qtfuncio
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.dssite              ,' '  ),--> dsendweb
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.cdsetor_economico   ,0    ),--> cdseteco
                             decode(vr_nrdconta,0,rw_pessoa_jur_new.cdramo_atividade    ,0    ),--> cdrmativ
                             pr_juridica_ptp_new.dtadmissao,                                    --> dtadmiss
                             pr_juridica_ptp_new.persocio,                                      --> persocio
                             decode(vr_nrdconta,0,substr(rw_pessoa_jur_new.nmpessoa,1,40)  ,' ' )  --> nmprimtl
                             );
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar paticipacao societaria de PJ:'||SQLERRM; 
                  RAISE vr_exc_erro;         
              END;                   
                          
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar participacao societaria de PJ: '||SQLERRM; 
  END pc_atualiza_juridica_ptp;
  
  --> Funcao para retornar o nome da pessoa de relacao com a pessoa principal
  FUNCTION fn_nome_pes_relacao ( pr_idpessoa   IN tbcadast_pessoa.idpessoa%TYPE,            --> Identificador de pessoa 
                                 pr_tprelacao  IN tbcadast_pessoa_relacao.tprelacao%TYPE    --> Tipo de relacao
                               ) RETURN VARCHAR2 IS 
  
  
  ---------------> CURSORES <----------------- 
    CURSOR cr_pessoa_relacao IS
      SELECT pes.nmpessoa
        FROM tbcadast_pessoa_relacao rel
            ,tbcadast_pessoa         pes
       WHERE rel.idpessoa_relacao = pes.idpessoa
         AND rel.tprelacao = pr_tprelacao
         AND rel.idpessoa  = pr_idpessoa;
    rw_pessoa_relacao cr_pessoa_relacao%ROWTYPE;
    
  BEGIN
  
    OPEN cr_pessoa_relacao;
    FETCH cr_pessoa_relacao INTO rw_pessoa_relacao;
    CLOSE cr_pessoa_relacao;
    
    RETURN rw_pessoa_relacao.nmpessoa;  
  
  END fn_nome_pes_relacao;      
  
  --> Rotina para retornar os bens da pessoa
  PROCEDURE pc_ret_bens_pessoa ( pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE     --> Identificador de pessoa                                                              
                                ,pr_tab_bens          OUT typ_tab_bens                      --> Retorna Bens
                                ,pr_dscritic          OUT VARCHAR2                          --> Retornar Critica 
                                ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_ret_bens_pessoa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar os bens da pessoa
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_bem (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT bem.*
        FROM tbcadast_pessoa_bem bem
       WHERE bem.idpessoa = pr_idpessoa;    
    rw_pessoa_bem     cr_pessoa_bem%ROWTYPE; 
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;     
    
    
  BEGIN
  
    --> Listar os bens
    FOR rw_pessoa_bem IN cr_pessoa_bem(pr_idpessoa => pr_idpessoa) LOOP
      pr_tab_bens(rw_pessoa_bem.nrseq_bem)   := rw_pessoa_bem;
    END LOOP;      
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar os bens: '||SQLERRM; 
  END pc_ret_bens_pessoa;
     
  
  --> Incluir avalista
  PROCEDURE pc_incluir_avalista ( pr_cdcooper           IN crapass.cdcooper%TYPE                     --> Codifo da cooperativa       
                                 ,pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                 ,pr_nrdconta           IN crapass.nrdconta%TYPE                     --> Numero de conta
                                 ,pr_idseqttl           IN crapttl.idseqttl%TYPE DEFAULT 1           --> sequencial do titular
                                 ,pr_idpessoa_aval      IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa avalista
                                 ,pr_nrdconta_aval      IN crapass.nrdconta%TYPE                     --> Numero de conta avalista
                                 ,pr_tpctrato           IN crapavt.tpctrato%TYPE                     --> Tipo de contrato
                                 ,pr_nrseq              IN INTEGER DEFAULT 0                         --> Sequencial da tabela referencia
                                 ,pr_rowidavt          OUT ROWID                                     --. Retornar rowid da avt criada
                                 ,pr_dscritic          OUT VARCHAR2                                  --> Retornar Critica 
                                ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_incluir_avalista
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar avalista na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tppessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa         cr_pessoa%ROWTYPE;         
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_fis (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT *
        FROM vwcadast_pessoa_fisica pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa_fis     cr_pessoa_fis%ROWTYPE;  
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_jur (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT *
        FROM vwcadast_pessoa_juridica pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa_jur     cr_pessoa_jur%ROWTYPE;
    
    --> Buscar endereço
    CURSOR cr_endereco (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT enc.*,
             mun.dscidade,
             mun.cdestado
        FROM tbcadast_pessoa_endereco enc,
             crapmun mun
       WHERE enc.idcidade = mun.idcidade
         AND enc.idpessoa = pr_idpessoa 
         AND enc.tpendereco = 10; --> residencial
    rw_endereco cr_endereco%ROWTYPE;
    
    --> Buscar email
    CURSOR cr_email (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT eml.*
        FROM tbcadast_pessoa_email eml
       WHERE eml.idpessoa = pr_idpessoa; 
    rw_email cr_email%ROWTYPE;
    
    --> Buscar telefone
    CURSOR cr_telefone (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT tel.*,
             '('||tel.nrddd ||') '||tel.nrtelefone dstelefone
        FROM tbcadast_pessoa_telefone tel
       WHERE tel.idpessoa = pr_idpessoa 
         AND tel.tptelefone = 1; --> residencial
    rw_telefone cr_telefone%ROWTYPE;
    
    --> Identificar tipo de pessoa
    CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE,
                      pr_nrdconta  crapass.nrdconta%TYPE)IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;  
    rw_crapass cr_crapass%ROWTYPE;
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_bens     typ_tab_bens;    
    vr_dsnatura     crapavt.dsnatura%TYPE;
    vr_crapavt      crapavt%rowtype;
    vr_nmpaicto     crapavt.nmpaicto%TYPE;
    vr_nmmaecto     crapavt.nmmaecto%TYPE;
    
    vr_nrctremp     crapavt.nrctremp%TYPE;
    vr_nrcpfcgc     crapavt.nrcpfcgc%TYPE;
    
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa_aval );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    IF rw_pessoa.tppessoa = 1 THEN
      -- Buscar informações da pessoa
      OPEN cr_pessoa_fis (pr_idpessoa => pr_idpessoa_aval );
      FETCH cr_pessoa_fis INTO rw_pessoa_fis; 
      IF cr_pessoa_fis%NOTFOUND THEN
        CLOSE cr_pessoa_fis;      
        vr_dscritic := 'Pessoa Fisica não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa_fis;
      END IF;
    
      vr_crapavt.nrcpfcgc := rw_pessoa_fis.nrcpf;
    
    ELSE
    
      -- Buscar informações da pessoa
      OPEN cr_pessoa_jur (pr_idpessoa => pr_idpessoa_aval );
      FETCH cr_pessoa_jur INTO rw_pessoa_jur; 
      IF cr_pessoa_jur%NOTFOUND THEN
        CLOSE cr_pessoa_jur;      
        vr_dscritic := 'Pessoa Juridica não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa_jur;
      END IF;
    
    END IF;
    
    --> Identificar tipo de pessoa
    rw_crapass := NULL;
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;            
    
    IF pr_tpctrato = 6 THEN
      vr_nrctremp := pr_nrseq;
      vr_nrcpfcgc := vr_crapavt.nrcpfcgc;
    ELSIF pr_tpctrato = 5 THEN
      -- Sera necessario colocar a linha abaixo porque para a pessoa de referencia 
      -- nao eh gravado o CPF / CNPJ quando a mesma nao possui conta
      IF rw_crapass.inpessoa > 1 THEN -- Se for um PJ
        vr_nrctremp := pr_nrseq; 
        vr_nrcpfcgc := 0; 
      ELSE
        vr_nrctremp := pr_idseqttl; 
        vr_nrcpfcgc := pr_nrseq; -- Para PF, o CPF/CGC eh o sequencial
      END IF;    
    
    END IF;
        
    IF pr_nrdconta_aval > 0 THEN
    
      --> Criar avalista com numero de conta
      BEGIN
        INSERT INTO crapavt
                   (cdcooper, 
                    tpctrato, 
                    nrdconta, 
                    nrctremp, 
                    nrcpfcgc,
                    nrdctato)
            VALUES (pr_cdcooper,          --> cdcooper
                    pr_tpctrato,          --> tpctrato
                    pr_nrdconta,          --> nrdconta
                    vr_nrctremp,          --> nrctremp
                    vr_nrcpfcgc,          --> nrcpfcgc
                    pr_nrdconta_aval      --> nrdctato
                    )RETURNING ROWID INTO pr_rowidavt ;
      EXCEPTION
        WHEN dup_val_on_index THEN
          BEGIN
            UPDATE crapavt avt
               SET nrdctato = pr_nrdconta_aval 
             WHERE avt.cdcooper = pr_cdcooper
               AND avt.tpctrato = pr_tpctrato
               AND avt.nrdconta = pr_nrdconta
               AND avt.nrctremp = vr_nrctremp
               AND avt.nrcpfcgc = vr_nrcpfcgc 
             RETURNING ROWID INTO pr_rowidavt ;
          
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel atualizar avalista com conta: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel cria avalista com conta: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      
      --> atualizar por tipo de pessoa
      IF rw_pessoa.tppessoa = 2 THEN
        --> Pessoa representante, nao permite PJ
        IF pr_tpctrato = 6 THEN      
          vr_dscritic := 'Pessoa Juridica não permitida.';
          RAISE vr_exc_erro;
          
        ELSE
          --> Buscar email
          rw_email := NULL;
          OPEN cr_email (pr_idpessoa => pr_idpessoa_aval);
          FETCH cr_email INTO rw_email;
          CLOSE cr_email;
          
          --> Buscar telefone
          rw_telefone := NULL;
          OPEN cr_telefone (pr_idpessoa => pr_idpessoa_aval);
          FETCH cr_telefone INTO rw_telefone;
          CLOSE cr_telefone;
        
          --> Criar avalista Sem numero de conta
          BEGIN
            INSERT INTO crapavt
                       (cdcooper, 
                        tpctrato, 
                        nrdconta, 
                        nrctremp, 
                        nrcpfcgc,
                        nrdctato,
                        --> pessoa_juridica
                        nmdavali,                                             
                        --> email
                        dsdemail,
                        --> Telefone 10 -- Residencial
                        nrtelefo                        
                        )
              VALUES   (pr_cdcooper,                             --> cdcooper
                        pr_tpctrato,                             --> tpctrato
                        pr_nrdconta,                             --> nrdconta                    
                        vr_nrctremp,                             --> nrctremp
                        vr_nrcpfcgc,                             --> nrcpfcgc                   
                        pr_nrdconta_aval,                        --> nrdctato
                        --> pessoa_fisica
                        rw_pessoa_jur.nmpessoa,                  --> nmdavali                                                                 
                        --> email
                        rw_email.dsemail,                        --> dsdemail
                        --> Telefone 10 -- Residencial
                        rw_telefone.dstelefone                   --> nrtelefo
                        ) RETURNING ROWID INTO pr_rowidavt ;
          EXCEPTION
            WHEN dup_val_on_index THEN
              BEGIN
                UPDATE crapavt avt
                   SET nrdctato = pr_nrdconta_aval,                        
                        --> pessoa_fisica
                       nmdavali = rw_pessoa_jur.nmpessoa,   
                        --> email
                       dsdemail = rw_email.dsemail,                        
                        --> Telefone 10 -- Residencial
                       nrtelefo = rw_telefone.dstelefone                   
                 WHERE avt.cdcooper = pr_cdcooper
                   AND avt.tpctrato = pr_tpctrato
                   AND avt.nrdconta = pr_nrdconta
                   AND avt.nrctremp = vr_nrctremp
                   AND avt.nrcpfcgc = vr_nrcpfcgc
                 RETURNING ROWID INTO pr_rowidavt ;
              
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Nao foi possivel atualizar avalista(PJ) com conta: '||SQLERRM;
                  RAISE vr_exc_erro;
              END;
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel cria avalista(PJ) sem conta: '||SQLERRM;
              RAISE vr_exc_erro;
          END;  
        END IF;
      
      ELSE      
    
        --> Buscar naturalidade
        IF rw_pessoa_fis.cdnaturalidade > 0 THEN
          vr_dsnatura := cada0014.fn_desc_naturalidade( pr_cdnatura => rw_pessoa_fis.cdnaturalidade, 
                                                        pr_dscritic => vr_dscritic);
        
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          ELSIF vr_dsnatura IS NULL THEN
            vr_dscritic := 'Naturalidade nao cadastrada.';
            RAISE vr_exc_erro;
          END IF;      
        END IF;
        
        --> Retornar os bens da pessoa
        pc_ret_bens_pessoa ( pr_idpessoa   => pr_idpessoa_aval --> Identificador de pessoa                                                              
                            ,pr_tab_bens   => vr_tab_bens      --> Retorna Bens
                            ,pr_dscritic   => vr_dscritic);    --> Retornar Critica 
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;    
        
        --> Apenas popular as lacunas, para não dar erro ao inserir
        FOR i IN 1..6 LOOP
          IF NOT vr_tab_bens.exists(i) THEN
            vr_tab_bens(i).dsbem := ' ';
          END IF;      
        END LOOP;
        
        
        --> Buscar endereço
        OPEN cr_endereco (pr_idpessoa => pr_idpessoa_aval);
        FETCH cr_endereco INTO rw_endereco;
        CLOSE cr_endereco;
        
        --> Buscar email
        rw_email := NULL;
        OPEN cr_email (pr_idpessoa => pr_idpessoa_aval);
        FETCH cr_email INTO rw_email;
        CLOSE cr_email;
        
        --> Buscar telefone
        rw_telefone := NULL;
        OPEN cr_telefone (pr_idpessoa => pr_idpessoa_aval);
        FETCH cr_telefone INTO rw_telefone;
        CLOSE cr_telefone;
        
        vr_nmpaicto := fn_nome_pes_relacao(pr_idpessoa => pr_idpessoa_aval,
                                           pr_tprelacao=> 3);
        
        vr_nmmaecto := fn_nome_pes_relacao(pr_idpessoa => pr_idpessoa_aval,
                                           pr_tprelacao=> 4);
      
        --> Criar avalista Sem numero de conta
        BEGIN
          INSERT INTO crapavt
                     (cdcooper, 
                      tpctrato, 
                      nrdconta, 
                      nrctremp, 
                      nrcpfcgc,
                      nrdctato,
                      --> pessoa_fisica
                      nmdavali,
                      tpdocava,
                      nrdocava,
                      idorgexp,
                      dtemddoc,
                      cdufddoc,
                      dtnascto,
                      cdsexcto,
                      cdestcvl,
                      inhabmen,
                      dthabmen,
                      cdnacion,
                      dsnatura,
                      --> pessoa_relacao tprelacao=> 3, -- Pai
                      nmpaicto,
                      --> pessoa_relacao tprelacao=> 4 -- Mae
                      nmmaecto,                    
                      --> cadast_pessoa_endereco
                      nrcepend,
                      dsendres##1,
                      nrendere,
                      complend,
                      nmbairro,
                      nmcidade,
                      cdufresd,
                      
                      --> pessoa_bem
                      dsrelbem##1,
                      persemon##1,
                      qtprebem##1,
                      vlrdobem##1,
                      vlprebem##1,
                      
                      dsrelbem##2,
                      persemon##2,
                      qtprebem##2,
                      vlrdobem##2,
                      vlprebem##2,
                      
                      dsrelbem##3,
                      persemon##3,
                      qtprebem##3,
                      vlrdobem##3,
                      vlprebem##3,
                      
                      dsrelbem##4,
                      persemon##4,
                      qtprebem##4,
                      vlrdobem##4,
                      vlprebem##4,
                      
                      dsrelbem##5,
                      persemon##5,
                      qtprebem##5,
                      vlrdobem##5,
                      vlprebem##5,
                      
                      dsrelbem##6,
                      persemon##6,
                      qtprebem##6,
                      vlrdobem##6,
                      vlprebem##6,
                      
                      --> email
                      dsdemail,
                      --> Telefone 10 -- Residencial
                      nrtelefo
                      
                      )
            VALUES   (pr_cdcooper,                             --> cdcooper
                      pr_tpctrato,                             --> tpctrato
                      pr_nrdconta,                             --> nrdconta                    
                      vr_nrctremp,                             --> nrctremp
                      vr_nrcpfcgc,                             --> nrcpfcgc                   
                      pr_nrdconta_aval,                        --> nrdctato
                      --> pessoa_fisica
                      rw_pessoa_fis.nmpessoa,                  --> nmdavali
                      rw_pessoa_fis.tpdocumento,               --> tpdocava
                      rw_pessoa_fis.nrdocumento,               --> nrdocava
                      nvl(rw_pessoa_fis.idorgao_expedidor,0),  --> idorgexp
                      rw_pessoa_fis.dtemissao_documento,       --> dtemddoc
                      nvl(rw_pessoa_fis.cduf_orgao_expedidor,' '), --> cdufddoc
                      rw_pessoa_fis.dtnascimento,              --> dtnascto
                      rw_pessoa_fis.tpsexo,                    --> cdsexcto
                      rw_pessoa_fis.cdestado_civil,            --> cdestcvl
                      rw_pessoa_fis.inhabilitacao_menor,       --> inhabmen
                      rw_pessoa_fis.dthabilitacao_menor,       --> dthabmen
                      nvl(rw_pessoa_fis.cdnacionalidade,0),    --> cdnacion
                      nvl(vr_dsnatura,' '),                    --> dsnatura
                      --> pessoa_relacao tprelacao=> 3, -- Pai      
                      vr_nmpaicto,                                                         
                      --> pessoa_relacao tprelacao=> 4 -- Mae       
                      vr_nmmaecto,
                      --> cadast_pessoa_endereco                    
                      rw_endereco.nrcep,                       --> nrcepend
                      rw_endereco.nmlogradouro,                --> dsendres
                      rw_endereco.nrlogradouro,                --> nrendere
                      rw_endereco.dscomplemento,               --> complend
                      rw_endereco.nmbairro,                    --> nmbairro
                      nvl(rw_endereco.dscidade,' '),           --> nmcidade                    
                      nvl(rw_endereco.cdestado,' '),           --> cdufresd
                      --> pessoa_bem
                      nvl(vr_tab_bens(1).dsbem,' '),           --> dsrelbem##1
                      nvl(vr_tab_bens(1).pebem,0),             --> persemon##1
                      nvl(vr_tab_bens(1).qtparcela_bem,0),     --> qtprebem##1
                      nvl(vr_tab_bens(1).vlbem,0),             --> vlrdobem##1
                      nvl(vr_tab_bens(1).vlparcela_bem,0),     --> vlprebem##1
                                                               
                      nvl(vr_tab_bens(2).dsbem,' '),           --> dsrelbem##2
                      nvl(vr_tab_bens(2).pebem,0),             --> persemon##2
                      nvl(vr_tab_bens(2).qtparcela_bem,0),     --> qtprebem##2
                      nvl(vr_tab_bens(2).vlbem,0),             --> vlrdobem##2
                      nvl(vr_tab_bens(2).vlparcela_bem,0),     --> vlprebem##2
                                                               
                      nvl(vr_tab_bens(3).dsbem,' '),           --> dsrelbem##3
                      nvl(vr_tab_bens(3).pebem,0),             --> persemon##3
                      nvl(vr_tab_bens(3).qtparcela_bem,0),     --> qtprebem##3
                      nvl(vr_tab_bens(3).vlbem,0),             --> vlrdobem##3
                      nvl(vr_tab_bens(3).vlparcela_bem,0),     --> vlprebem##3
                                                               
                      nvl(vr_tab_bens(4).dsbem,' '),           --> dsrelbem##4
                      nvl(vr_tab_bens(4).pebem,0),             --> persemon##4
                      nvl(vr_tab_bens(4).qtparcela_bem,0),     --> qtprebem##4
                      nvl(vr_tab_bens(4).vlbem,0),             --> vlrdobem##4
                      nvl(vr_tab_bens(4).vlparcela_bem,0),     --> vlprebem##4
                                       
                      nvl(vr_tab_bens(5).dsbem,' '),           --> dsrelbem##5
                      nvl(vr_tab_bens(5).pebem,0),             --> persemon##5
                      nvl(vr_tab_bens(5).qtparcela_bem,0),     --> qtprebem##5
                      nvl(vr_tab_bens(5).vlbem,0),             --> vlrdobem##5
                      nvl(vr_tab_bens(5).vlparcela_bem,0),     --> vlprebem##5
                                       
                      nvl(vr_tab_bens(6).dsbem,' '),           --> dsrelbem##6
                      nvl(vr_tab_bens(6).pebem,0),             --> persemon##6
                      nvl(vr_tab_bens(6).qtparcela_bem,0),     --> qtprebem##6
                      nvl(vr_tab_bens(6).vlbem,0),             --> vlrdobem##6
                      nvl(vr_tab_bens(6).vlparcela_bem,0),     --> vlprebem##6
                      --> email
                      rw_email.dsemail,                        --> dsdemail
                      --> Telefone 10 -- Residencial
                      rw_telefone.dstelefone                   --> nrtelefo
                      ) RETURNING ROWID INTO pr_rowidavt ;
        EXCEPTION
          WHEN dup_val_on_index THEN
            BEGIN
              UPDATE crapavt avt
                 SET nrdctato = pr_nrdconta_aval,                        
                      --> pessoa_fisica
                     nmdavali = rw_pessoa_fis.nmpessoa,                  
                     tpdocava = rw_pessoa_fis.tpdocumento,               
                     nrdocava = rw_pessoa_fis.nrdocumento,               
                     idorgexp = nvl(rw_pessoa_fis.idorgao_expedidor,0),         
                     dtemddoc = rw_pessoa_fis.dtemissao_documento,       
                     cdufddoc = nvl(rw_pessoa_fis.cduf_orgao_expedidor,' '), 
                     dtnascto = rw_pessoa_fis.dtnascimento,              
                     cdsexcto = rw_pessoa_fis.tpsexo,                    
                     cdestcvl = rw_pessoa_fis.cdestado_civil,            
                     inhabmen = rw_pessoa_fis.inhabilitacao_menor,       
                     dthabmen = rw_pessoa_fis.dthabilitacao_menor,       
                     cdnacion = nvl(rw_pessoa_fis.cdnacionalidade,0),    
                     dsnatura = nvl(vr_dsnatura,' '),                             
                      --> pessoa_relacao tprelacao=> 3, -- Pai      
                     nmpaicto = vr_nmpaicto,                                                    
                      --> pessoa_relacao tprelacao=> 4 -- Mae       
                     nmmaecto = vr_nmmaecto,
                      --> cadast_pessoa_endereco                    
                     nrcepend = rw_endereco.nrcep,                       
                     dsendres##1 = rw_endereco.nmlogradouro,                
                     nrendere = rw_endereco.nrlogradouro,                
                     complend = rw_endereco.dscomplemento,               
                     nmbairro = rw_endereco.nmbairro,                    
                     nmcidade = nvl(rw_endereco.dscidade,' '),
                     cdufresd = nvl(rw_endereco.cdestado,' '),
                      --> pessoa_bem
                     dsrelbem##1 = nvl(vr_tab_bens(1).dsbem,' '),           
                     persemon##1 = nvl(vr_tab_bens(1).pebem,0),             
                     qtprebem##1 = nvl(vr_tab_bens(1).qtparcela_bem,0),     
                     vlrdobem##1 = nvl(vr_tab_bens(1).vlbem,0),             
                     vlprebem##1 = nvl(vr_tab_bens(1).vlparcela_bem,0),     
                                                               
                     dsrelbem##2 = nvl(vr_tab_bens(2).dsbem,' '),           
                     persemon##2 = nvl(vr_tab_bens(2).pebem,0),             
                     qtprebem##2 = nvl(vr_tab_bens(2).qtparcela_bem,0),     
                     vlrdobem##2 = nvl(vr_tab_bens(2).vlbem,0),             
                     vlprebem##2 = nvl(vr_tab_bens(2).vlparcela_bem,0),     
                                                               
                     dsrelbem##3 = nvl(vr_tab_bens(3).dsbem,' '),           
                     persemon##3 = nvl(vr_tab_bens(3).pebem,0),             
                     qtprebem##3 = nvl(vr_tab_bens(3).qtparcela_bem,0),     
                     vlrdobem##3 = nvl(vr_tab_bens(3).vlbem,0),             
                     vlprebem##3 = nvl(vr_tab_bens(3).vlparcela_bem,0),     
                                                               
                     dsrelbem##4 = nvl(vr_tab_bens(4).dsbem,' '),           
                     persemon##4 = nvl(vr_tab_bens(4).pebem,0),             
                     qtprebem##4 = nvl(vr_tab_bens(4).qtparcela_bem,0),     
                     vlrdobem##4 = nvl(vr_tab_bens(4).vlbem,0),             
                     vlprebem##4 = nvl(vr_tab_bens(4).vlparcela_bem,0),     
                                       
                     dsrelbem##5 = nvl(vr_tab_bens(5).dsbem,' '),           
                     persemon##5 = nvl(vr_tab_bens(5).pebem,0),             
                     qtprebem##5 = nvl(vr_tab_bens(5).qtparcela_bem,0),     
                     vlrdobem##5 = nvl(vr_tab_bens(5).vlbem,0),             
                     vlprebem##5 = nvl(vr_tab_bens(5).vlparcela_bem,0),     
                                       
                     dsrelbem##6 = nvl(vr_tab_bens(6).dsbem,' '),           
                     persemon##6 = nvl(vr_tab_bens(6).pebem,0),             
                     qtprebem##6 = nvl(vr_tab_bens(6).qtparcela_bem,0),     
                     vlrdobem##6 = nvl(vr_tab_bens(6).vlbem,0),             
                     vlprebem##6 = nvl(vr_tab_bens(6).vlparcela_bem,0),     
                      --> email
                     dsdemail = rw_email.dsemail,                        
                      --> Telefone 10 -- Residencial
                     nrtelefo = rw_telefone.dstelefone                   
               WHERE avt.cdcooper = pr_cdcooper
                 AND avt.tpctrato = pr_tpctrato
                 AND avt.nrdconta = pr_nrdconta
                 AND avt.nrctremp = vr_nrctremp
                 AND avt.nrcpfcgc = vr_nrcpfcgc
               RETURNING ROWID INTO pr_rowidavt ;
            
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Nao foi possivel atualizar avalista com conta: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel cria avalista sem conta: '||SQLERRM;
            RAISE vr_exc_erro;
        END;  
      
      END IF;
    
    END IF;
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel criar avalista: '||SQLERRM; 
  END pc_incluir_avalista;
 
  
  /*****************************************************************************/
  /**    Procedure para atualizar representante do pj na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_juridica_rep( pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                     ,pr_tpoperacao         IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_juridica_rep_old   IN tbcadast_pessoa_juridica_rep%ROWTYPE      --> Dados anteriores
                                     ,pr_juridica_rep_new   IN tbcadast_pessoa_juridica_rep%ROWTYPE      --> Dados novos
                                     ,pr_dscritic          OUT VARCHAR2                                  --> Retornar Critica 
                                     ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar representante do pj na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa         cr_pessoa%ROWTYPE;         
    rw_pessoa_rep     cr_pessoa%ROWTYPE;         
    rw_pessoa_rep_new cr_pessoa%ROWTYPE;            
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;    
    vr_nrdconta     crapass.nrdconta%TYPE;
    vr_dsproftl     crapavt.dsproftl%TYPE;
    vr_rowidavt     ROWID;
    
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    -- Buscar informações da pessoa representante
    OPEN cr_pessoa (pr_idpessoa => nvl(pr_juridica_rep_old.idpessoa_representante,
                                       pr_juridica_rep_new.idpessoa_representante) );
    FETCH cr_pessoa INTO rw_pessoa_rep; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa representante não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    rw_pessoa_rep_new := NULL;
    IF pr_juridica_rep_new.idpessoa_representante > 0 THEN
      -- Buscar informações da pessoa participante
      OPEN cr_pessoa (pr_idpessoa => pr_juridica_rep_new.idpessoa_representante );
      FETCH cr_pessoa INTO rw_pessoa_rep_new; 
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;      
        vr_dscritic := 'Pessoa representante não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa;
      END IF;
    END IF;
        
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
      
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP        
                 
          --> Exclusao ou se mudou a pessoa
          IF pr_tpoperacao = 3 OR 
             (nvl(pr_juridica_rep_old.idpessoa_representante,
                  pr_juridica_rep_new.idpessoa_representante) <> pr_juridica_rep_new.idpessoa_representante)          
            THEN
            --> Deletar registro
            BEGIN
              DELETE crapavt avt
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.tpctrato = 6
                 AND avt.dsproftl <> 'PROCURADOR' -- Nao sera levado procuradores
                 AND avt.nrcpfcgc = nvl(rw_pessoa_rep.nrcpfcgc,0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar paticipacao societaria de PJ: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          END IF;
          
          --> Senao é ALTERACAO/INCLUSAO  
          IF pr_tpoperacao <> 3 THEN          
            --> Buscar numero da cona mais recente
            pc_ret_conta_recente( pr_nrcpfcgc   => rw_pessoa_rep_new.nrcpfcgc   --> Numero do CPF/CNPJ
                                 ,pr_cdcooper   => vr_tab_contas(idx).cdcooper  --> Codigo da cooperativa
                                 ,pr_nrdconta   => vr_nrdconta                  --> Retornar contas
                                 ,pr_dscritic   => vr_dscritic);                --> Retornar Critica       
            
            IF pr_juridica_rep_new.tpcargo_representante > 0 THEN
              --> Retornar descrição do cargo            
              vr_dsproftl := cada0014.fn_desc_tpcargo_representante( pr_tpcargo_representante => pr_juridica_rep_new.tpcargo_representante, 
                                                                     pr_dscritic              => vr_dscritic);
            
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              ELSIF vr_dsproftl IS NULL THEN  
                vr_dscritic := 'Tipo de cargo nao cadastrado';
                RAISE vr_exc_erro;
              END IF;
            END IF;          
            --> Realizar alteração  
            BEGIN              
              
              UPDATE crapavt avt
                 SET avt.nrdctato = vr_nrdconta,
                     avt.nrcpfcgc = rw_pessoa_rep_new.nrcpfcgc,
                     avt.persocio = pr_juridica_rep_new.persocio, 
                     avt.dsproftl = vr_dsproftl,
                     avt.dtvalida = pr_juridica_rep_new.dtvigencia ,
                     avt.dtadmsoc = pr_juridica_rep_new.dtadmissao, 
                     avt.flgdepec = pr_juridica_rep_new.flgdependencia_economica
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.tpctrato = 6
                 AND avt.dsproftl <> 'PROCURADOR' -- Nao sera levado procuradores
                 AND avt.nrcpfcgc = nvl(rw_pessoa_rep.nrcpfcgc,0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar representante do PJ:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN        
              --> Incluir avalista
              pc_incluir_avalista ( pr_cdcooper      => vr_tab_contas(idx).cdcooper                --> Codifo da cooperativa       
                                   ,pr_idpessoa      => pr_idpessoa                                --> Identificador de pessoa                             
                                   ,pr_nrdconta      => vr_tab_contas(idx).nrdconta                --> Numero de conta
                                   ,pr_idpessoa_aval => pr_juridica_rep_new.idpessoa_representante --> Identificador de pessoa avalista
                                   ,pr_nrdconta_aval => vr_nrdconta                                --> Numero de conta avalista
                                   ,pr_tpctrato      => 6                                          --> Tipo de contrato
                                   ,pr_rowidavt      => vr_rowidavt                                --> Retornar rowid da avt criada
                                   ,pr_dscritic      => vr_dscritic);                              --> Retornar Critica
                          
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  
              
              --> Apos criar o avalista, atualizar com as informaçoes do representante
              BEGIN              
              
                UPDATE crapavt avt
                   SET avt.nrcpfcgc = rw_pessoa_rep_new.nrcpfcgc,
                       avt.persocio = pr_juridica_rep_new.persocio, 
                       avt.dsproftl = vr_dsproftl,
                       avt.dtvalida = pr_juridica_rep_new.dtvigencia ,
                       avt.dtadmsoc = pr_juridica_rep_new.dtadmissao, 
                       avt.flgdepec = pr_juridica_rep_new.flgdependencia_economica
                 WHERE avt.rowid = vr_rowidavt;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar representante do PJ:'||SQLERRM; 
                  RAISE vr_exc_erro;          
              END;
              
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 


  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar paticipacao societaria de PJ: '||SQLERRM; 
  END pc_atualiza_juridica_rep;
  
  /*****************************************************************************/
  /**    Procedure para atualizar representante do pj na estrutura antiga     **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_referencia ( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                           ,pr_tpoperacao       IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_pessoa_ref_old   IN tbcadast_pessoa_referencia%ROWTYPE      --> Dados anteriores
                                           ,pr_pessoa_ref_new   IN tbcadast_pessoa_referencia%ROWTYPE      --> Dados novos
                                           ,pr_dscritic        OUT VARCHAR2                                  --> Retornar Critica 
                                           ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_pessoa_referencia
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar pessoa referencia na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa         cr_pessoa%ROWTYPE;         
    rw_pessoa_ref     cr_pessoa%ROWTYPE;         
    rw_pessoa_ref_new cr_pessoa%ROWTYPE;           
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;    
    vr_tab_contas_old typ_tab_contas;    
    vr_nrdconta     crapass.nrdconta%TYPE;    
    vr_rowidavt     ROWID;
    
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    -- Buscar informações da pessoa representante
    OPEN cr_pessoa (pr_idpessoa => nvl(pr_pessoa_ref_old.idpessoa_referencia,
                                       pr_pessoa_ref_new.idpessoa_referencia) );
    FETCH cr_pessoa INTO rw_pessoa_ref; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa representante não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    rw_pessoa_ref_new := NULL;
    IF pr_pessoa_ref_new.idpessoa_referencia > 0 THEN
      -- Buscar informações da pessoa participante
      OPEN cr_pessoa (pr_idpessoa => pr_pessoa_ref_new.idpessoa_referencia );
      FETCH cr_pessoa INTO rw_pessoa_ref_new; 
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;      
        vr_dscritic := 'Pessoa representante não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa;
      END IF;
    END IF;
        
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
      
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP        
                 
          --> Exclusao ou se mudou a pessoa
          IF pr_tpoperacao = 3 OR 
             (nvl(pr_pessoa_ref_old.idpessoa_referencia,
                  pr_pessoa_ref_new.idpessoa_referencia) <> pr_pessoa_ref_new.idpessoa_referencia)          
            THEN
            
            --> Deletar registro
            BEGIN
              DELETE crapavt avt
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.tpctrato = 5
                 --> Pessoa anterior
                 AND avt.nrctremp = pr_pessoa_ref_old.nrseq_referencia
                 AND avt.nmdavali = rw_pessoa_ref.nmpessoa;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar pessoa referencia: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;   
            
            -- Eliminar pessoas que estjam atreladas via conta
            -- Buscar contas anteriores
            pc_retorna_contas ( pr_idpessoa   => pr_pessoa_ref_old.idpessoa_referencia,
                                pr_tab_contas => vr_tab_contas_old,
                                pr_dscritic   => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;  
            
            IF vr_tab_contas_old.count > 0 THEN
              FOR  idx_old IN vr_tab_contas_old.first..vr_tab_contas_old.last LOOP
                --> Apenas se for da mesma cooperativa
                IF vr_tab_contas(idx).cdcooper = vr_tab_contas_old(idx_old).cdcooper THEN
                  --> Deletar registro
                  BEGIN
                    DELETE crapavt avt
                     WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                       AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                       AND avt.tpctrato = 5
                       --> Pessoa anterior
                       AND avt.nrdctato = vr_tab_contas_old(idx_old).nrdconta;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao deletar pessoa referencia: '||SQLERRM; 
                      RAISE vr_exc_erro;
                  END; 
                END IF;
              END LOOP;            
            END IF;        
            
          END IF;--> Fim tpoperacao
          
          --> Senao é ALTERACAO/INCLUSAO  
          IF pr_tpoperacao <> 3 THEN          
            --> Buscar numero da cona mais recente
            pc_ret_conta_recente( pr_nrcpfcgc   => rw_pessoa_ref_new.nrcpfcgc   --> Numero do CPF/CNPJ
                                 ,pr_cdcooper   => vr_tab_contas(idx).cdcooper  --> Codigo da cooperativa
                                 ,pr_nrdconta   => vr_nrdconta                  --> Retornar contas
                                 ,pr_dscritic   => vr_dscritic);                --> Retornar Critica       
                              
              
            --> Incluir avalista
            pc_incluir_avalista ( pr_cdcooper      => vr_tab_contas(idx).cdcooper                --> Codifo da cooperativa       
                                 ,pr_idpessoa      => pr_idpessoa                                --> Identificador de pessoa                             
                                 ,pr_nrdconta      => vr_tab_contas(idx).nrdconta                --> Numero de conta
                                 ,pr_idseqttl      => vr_tab_contas(idx).idseqttl                --> Sequencial do titular
                                 ,pr_idpessoa_aval => pr_pessoa_ref_new.idpessoa_referencia --> Identificador de pessoa avalista
                                 ,pr_nrdconta_aval => vr_nrdconta                                --> Numero de conta avalista
                                 ,pr_tpctrato      => 5                                          --> Tipo de contrato
                                 ,pr_nrseq         => pr_pessoa_ref_new.nrseq_referencia         --> Sequencial de pessoa referencia                                 
                                 ,pr_rowidavt      => vr_rowidavt                                --> Retornar rowid da avt criada
                                 ,pr_dscritic      => vr_dscritic);                              --> Retornar Critica
                          
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;                              
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar pessoa referencia: '||SQLERRM; 
  END pc_atualiza_pessoa_referencia;
  
  /*****************************************************************************/
  /**       Procedure para atualizar dependentes na estrutura antiga          **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_fisica_dep ( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                           ,pr_tpoperacao       IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_pessoa_dep_old   IN tbcadast_pessoa_fisica_dep%ROWTYPE        --> Dados anteriores
                                           ,pr_pessoa_dep_new   IN tbcadast_pessoa_fisica_dep%ROWTYPE        --> Dados novos
                                           ,pr_dscritic        OUT VARCHAR2                                  --> Retornar Critica 
                                           ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_pessoa_fisica_dep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar dependentes na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa         cr_pessoa%ROWTYPE;    
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_fis (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpf,
             pes.nmpessoa,
             pes.tpcadastro,
             pes.dtnascimento
        FROM vwcadast_pessoa_fisica pes
       WHERE pes.idpessoa = pr_idpessoa;        
    rw_pessoa_dep     cr_pessoa_fis%ROWTYPE;         
    rw_pessoa_dep_new cr_pessoa_fis%ROWTYPE;       
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas   typ_tab_contas;    
    
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    -- Buscar informações da pessoa representante
    OPEN cr_pessoa_fis (pr_idpessoa => nvl(pr_pessoa_dep_old.idpessoa_dependente,
                                       pr_pessoa_dep_new.idpessoa_dependente) );
    FETCH cr_pessoa_fis INTO rw_pessoa_dep; 
    IF cr_pessoa_fis%NOTFOUND THEN
      CLOSE cr_pessoa_fis;      
      vr_dscritic := 'Pessoa dependente não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa_fis;
    END IF;     
    
    rw_pessoa_dep_new := NULL;
    IF pr_pessoa_dep_new.idpessoa_dependente > 0 THEN
      -- Buscar informações da pessoa participante
      OPEN cr_pessoa_fis (pr_idpessoa => pr_pessoa_dep_new.idpessoa_dependente );
      FETCH cr_pessoa_fis INTO rw_pessoa_dep_new; 
      IF cr_pessoa_fis%NOTFOUND THEN
        CLOSE cr_pessoa_fis;      
        vr_dscritic := 'Pessoa dependente não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa_fis;
      END IF;
    END IF;
        
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
      
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP        
                 
          --> Exclusao ou se mudou a pessoa
          IF pr_tpoperacao = 3 OR 
             (nvl(pr_pessoa_dep_old.idpessoa_dependente,
                  pr_pessoa_dep_new.idpessoa_dependente) <> pr_pessoa_dep_new.idpessoa_dependente)          
            THEN
            
            --> Deletar registro
            BEGIN
              DELETE crapdep dep
               WHERE dep.cdcooper = vr_tab_contas(idx).cdcooper
                 AND dep.nrdconta = vr_tab_contas(idx).nrdconta
                 --> Pessoa anterior
                 AND dep.nmdepend = rw_pessoa_dep.nmpessoa;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar pessoa dependente: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;                
            
          END IF;--> Fim tpoperacao
          
          --> Senao é ALTERACAO/INCLUSAO  
          IF pr_tpoperacao <> 3 THEN          
            --> Realizar alteração  
            BEGIN
              UPDATE crapdep dep
                 SET dep.nmdepend = rw_pessoa_dep_new.nmpessoa,
                     dep.dtnascto = rw_pessoa_dep_new.dtnascimento,
                     dep.tpdepend = pr_pessoa_dep_new.tpdependente                                        
               WHERE dep.cdcooper = vr_tab_contas(idx).cdcooper
                 AND dep.nrdconta = vr_tab_contas(idx).nrdconta
                 --> Pessoa anterior
                 AND dep.nmdepend = rw_pessoa_dep.nmpessoa;
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar dependente:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
         
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN
              --> Inserir registro
              BEGIN
                INSERT INTO crapdep
                            ( cdcooper, 
                              nrdconta, 
                              idseqdep, 
                              nmdepend, 
                              dtnascto, 
                              tpdepend  )
                     VALUES ( vr_tab_contas(idx).cdcooper,            --> cdcooper
                              vr_tab_contas(idx).nrdconta,            --> nrdconta
                              vr_tab_contas(idx).idseqttl,     --> idseqdep
                              rw_pessoa_dep_new.nmpessoa,             --> nmdepend
                              rw_pessoa_dep_new.dtnascimento,         --> dtnascto
                              pr_pessoa_dep_new.tpdependente          --> tpdepend
                              ); 
                                  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir dependente: '||SQLERRM; 
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 


  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar dependentes: '||SQLERRM; 
  END pc_atualiza_pessoa_fisica_dep;
  
  --> Incluir responsavel legal
  PROCEDURE pc_incluir_resp_legal ( pr_cdcooper          IN crapass.cdcooper%TYPE                      --> Codifo da cooperativa       
                                   ,pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                   ,pr_nrdconta          IN crapass.nrdconta%TYPE                     --> Numero de conta
                                   ,pr_idseqttl          IN crapttl.idseqttl%TYPE                     --> Sequencial do titular
                                   ,pr_idpessoa_resp     IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa avalista
                                   ,pr_nrdconta_resp     IN crapass.nrdconta%TYPE                     --> Numero de conta avalista
                                   ,pr_cdrlcrsp          IN crapcrl.cdrlcrsp%TYPE                     --> Codigo do relacionamento
                                   ,pr_rowidcrl         OUT ROWID                                     --. Retornar rowid da avt criada
                                   ,pr_dscritic         OUT VARCHAR2                                  --> Retornar Critica 
                                  ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_incluir_resp_legal
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar responsavel legal na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tppessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa         cr_pessoa%ROWTYPE;             
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_fis (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT *
        FROM vwcadast_pessoa_fisica pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa_fis     cr_pessoa_fis%ROWTYPE;  
    
    --> Buscar endereço
    CURSOR cr_endereco (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT enc.*,
             mun.dscidade,
             mun.cdestado
        FROM tbcadast_pessoa_endereco enc,
             crapmun mun
       WHERE enc.idcidade = mun.idcidade
         AND enc.idpessoa = pr_idpessoa 
         AND enc.tpendereco = 10; --> residencial
    rw_endereco cr_endereco%ROWTYPE;
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_dsnatura     crapavt.dsnatura%TYPE;
    vr_nmpaicto     crapavt.nmpaicto%TYPE;
    vr_nmmaecto     crapavt.nmmaecto%TYPE;
    
    
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa_resp );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    IF rw_pessoa.tppessoa = 1 THEN
      -- Buscar informações da pessoa
      OPEN cr_pessoa_fis (pr_idpessoa => pr_idpessoa_resp );
      FETCH cr_pessoa_fis INTO rw_pessoa_fis; 
      IF cr_pessoa_fis%NOTFOUND THEN
        CLOSE cr_pessoa_fis;      
        vr_dscritic := 'Pessoa Fisica não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa_fis;
      END IF;   
    
    ELSE
      vr_dscritic := 'Pessoa Juridica não permitida.';
      RAISE vr_exc_erro;
      
    END IF;    
    
    IF pr_nrdconta_resp > 0 THEN
  
      --> Criar responsavel com numero de conta
      BEGIN
        INSERT INTO crapcrl
                   (cdcooper, 
                    nrctamen, 
                    nrcpfmen, 
                    idseqmen, 
                    nrdconta,
                    nrcpfcgc,
                    cdrlcrsp )
            VALUES (pr_cdcooper,          --> cdcooper
                    pr_nrdconta,          --> nrctamen
                    0,                    --> nrcpfmen
                    pr_idseqttl,          --> idseqmen
                    pr_nrdconta_resp,     --> nrdconta
                    0,                     --> nrcpfcgc
                    pr_cdrlcrsp            --> cdrlcrsp
                    )RETURNING ROWID INTO pr_rowidcrl ;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel cria responsavel legal com conta: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      --> Buscar naturalidade
      vr_dsnatura := ' ';
      IF rw_pessoa_fis.cdnaturalidade > 0 THEN
        vr_dsnatura := cada0014.fn_desc_naturalidade( pr_cdnatura => rw_pessoa_fis.cdnaturalidade, 
                                                      pr_dscritic => vr_dscritic);
      
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        ELSIF vr_dsnatura IS NULL THEN
          vr_dscritic := 'Naturalidade nao cadastrada.';
          RAISE vr_exc_erro;
        END IF;
      END IF;
            
      --> Buscar endereço
      OPEN cr_endereco (pr_idpessoa => pr_idpessoa_resp);
      FETCH cr_endereco INTO rw_endereco;
      CLOSE cr_endereco;
      
      vr_nmpaicto := fn_nome_pes_relacao(pr_idpessoa => pr_idpessoa_resp,
                                         pr_tprelacao=> 3);
      
      vr_nmmaecto := fn_nome_pes_relacao(pr_idpessoa => pr_idpessoa_resp,
                                         pr_tprelacao=> 4);
    
      --> Criar avalista Sem numero de conta
      BEGIN
        INSERT INTO crapcrl
                   (cdcooper, 
                    nrctamen, 
                    nrcpfmen, 
                    idseqmen, 
                    nrdconta, 
                    nrcpfcgc, 
                    nmrespon, 
                    cdufiden, 
                    dtemiden, 
                    dtnascin, 
                    cddosexo, 
                    cdestciv,  
                    dsnatura, 
                    cdcepres, 
                    dsendres, 
                    nrendres, 
                    dscomres, 
                    dsbaires, 
                    nrcxpost, 
                    dscidres, 
                    dsdufres, 
                    nmpairsp, 
                    nmmaersp, 
                    tpdeiden, 
                    nridenti, 
                    dtmvtolt, 
                    flgimpri, 
                    cdrlcrsp, 
                    cdnacion, 
                    idorgexp)
             VALUES(pr_cdcooper,                        --> cdcooper
                    pr_nrdconta,                        --> nrctamen
                    0,                                  --> nrcpfmen
                    pr_idseqttl,                        --> idseqmen
                    0,                                  --> nrdconta
                    rw_pessoa_fis.nrcpf,                --> nrcpfcgc
                    rw_pessoa_fis.nmpessoa,             --> nmrespon
                    nvl(rw_pessoa_fis.cduf_orgao_expedidor,' '), --> cdufiden
                    rw_pessoa_fis.dtemissao_documento,  --> dtemiden
                    rw_pessoa_fis.dtnascimento,         --> dtnascin
                    rw_pessoa_fis.tpsexo,               --> cddosexo
                    rw_pessoa_fis.cdestado_civil,       --> cdestciv
                    vr_dsnatura,                        --> dsnatura
                    rw_endereco.nrcep,                  --> cdcepres
                    rw_endereco.nmlogradouro,           --> dsendres
                    rw_endereco.nrlogradouro,           --> nrendres
                    rw_endereco.dscomplemento,          --> dscomres
                    rw_endereco.nmbairro,               --> dsbaires
                    0,                                  --> nrcxpost
                    nvl(rw_endereco.dscidade,' '),      --> dscidres
                    nvl(rw_endereco.cdestado,' '),      --> dsdufres
                    vr_nmpaicto,                        --> nmpairsp
                    vr_nmmaecto,                        --> nmmaersp
                    rw_pessoa_fis.tpdocumento,          --> tpdeiden
                    rw_pessoa_fis.nridentificacao,      --> nridenti
                    trunc(SYSDATE),                     --> dtmvtolt
                    0,                                  --> flgimpri
                    pr_cdrlcrsp,                        --> cdrlcrsp
                    nvl(rw_pessoa_fis.cdnacionalidade,0),  --> cdnacion
                    nvl(rw_pessoa_fis.idorgao_expedidor,0) --> idorgexp   
                    ) RETURNING ROWID INTO pr_rowidcrl ;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel cria avalista sem conta: '||SQLERRM;
          RAISE vr_exc_erro;
      END;  
    
    END IF;
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel criar responsavel legal: '||SQLERRM; 
  END pc_incluir_resp_legal;
 
  
  /*****************************************************************************/
  /**    Procedure para atualizar responsavel legal na estrutura antiga       **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_fisica_resp ( pr_idpessoa         IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa                             
                                            ,pr_tpoperacao       IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                            ,pr_pessoa_resp_old  IN tbcadast_pessoa_fisica_resp%ROWTYPE       --> Dados anteriores
                                            ,pr_pessoa_resp_new  IN tbcadast_pessoa_fisica_resp%ROWTYPE       --> Dados novos
                                            ,pr_dscritic        OUT VARCHAR2                                  --> Retornar Critica 
                                           ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_pessoa_fisica_resp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar responsavel legal na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa         cr_pessoa%ROWTYPE;    
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_fis (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpf,
             pes.nmpessoa,
             pes.tpcadastro,
             pes.dtnascimento
        FROM vwcadast_pessoa_fisica pes
       WHERE pes.idpessoa = pr_idpessoa;        
    rw_pessoa_resp     cr_pessoa_fis%ROWTYPE;         
    rw_pessoa_resp_new cr_pessoa_fis%ROWTYPE;       
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas     typ_tab_contas;    
    vr_tab_contas_old typ_tab_contas;   
    vr_tab_contas_new typ_tab_contas;   
    vr_nrdconta       crapass.nrdconta%TYPE;
    vr_nrqtatlz       INTEGER;
    vr_rowidcrl       ROWID;
    
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    -- Buscar informações da pessoa representante
    OPEN cr_pessoa_fis (pr_idpessoa => nvl(pr_pessoa_resp_old.idpessoa_resp_legal,
                                           pr_pessoa_resp_new.idpessoa_resp_legal) );
    FETCH cr_pessoa_fis INTO rw_pessoa_resp; 
    IF cr_pessoa_fis%NOTFOUND THEN
      CLOSE cr_pessoa_fis;      
      vr_dscritic := 'Pessoa responsavel legal não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa_fis;
    END IF;     
    
    rw_pessoa_resp_new := NULL;
    IF pr_pessoa_resp_new.idpessoa_resp_legal > 0 THEN
      -- Buscar informações da pessoa participante
      OPEN cr_pessoa_fis (pr_idpessoa => pr_pessoa_resp_new.idpessoa_resp_legal );
      FETCH cr_pessoa_fis INTO rw_pessoa_resp_new; 
      IF cr_pessoa_fis%NOTFOUND THEN
        CLOSE cr_pessoa_fis;      
        vr_dscritic := 'Pessoa responsavel legal não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa_fis;
      END IF;
    END IF;
        
    -- Buscar contas
    pc_retorna_contas ( pr_idpessoa   => pr_idpessoa,
                        pr_tab_contas => vr_tab_contas,
                        pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
      
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP        
                 
          --> Exclusao ou se mudou a pessoa
          IF pr_tpoperacao = 3 OR 
             (nvl(pr_pessoa_resp_old.idpessoa_resp_legal,
                  pr_pessoa_resp_new.idpessoa_resp_legal) <> pr_pessoa_resp_new.idpessoa_resp_legal)          
            THEN
            
            --> Deletar registro
            BEGIN
              DELETE crapcrl crl
               WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                 AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                 AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                 --> Pessoa anterior
                 AND crl.nrcpfcgc = nvl(rw_pessoa_resp.nrcpf,0)
                 AND crl.nmrespon = rw_pessoa_resp.nmpessoa;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar responsavel legal: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;   
            
            -- Eliminar pessoas que estjam atreladas via conta
            -- Buscar contas anteriores
            pc_retorna_contas ( pr_idpessoa   => pr_pessoa_resp_old.idpessoa_resp_legal,
                                pr_tab_contas => vr_tab_contas_old,
                                pr_dscritic   => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;  
            
            IF vr_tab_contas_old.count > 0 THEN
              FOR  idx_old IN vr_tab_contas_old.first..vr_tab_contas_old.last LOOP
                --> Apenas se for da mesma cooperativa
                IF vr_tab_contas(idx).cdcooper = vr_tab_contas_old(idx_old).cdcooper THEN
                  --> Deletar registro                  
                  BEGIN
                    DELETE crapcrl crl
                     WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                       AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                       AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                       --> Pessoa anterior
                       AND crl.nrdconta = vr_tab_contas_old(idx_old).nrdconta;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao deletar responsavel legal: '||SQLERRM; 
                      RAISE vr_exc_erro;
                  END; 
                END IF;
              END LOOP;            
            END IF;        
            
          END IF;--> Fim tpoperacao
          
          --> Senao é ALTERACAO/INCLUSAO  
          IF pr_tpoperacao <> 3 THEN 
            vr_nrqtatlz := 0;
                   
            --> Buscar numero da cona mais recente
            pc_ret_conta_recente( pr_nrcpfcgc   => rw_pessoa_resp_new.nrcpf   --> Numero do CPF/CNPJ
                                 ,pr_cdcooper   => vr_tab_contas(idx).cdcooper  --> Codigo da cooperativa
                                 ,pr_nrdconta   => vr_nrdconta                  --> Retornar contas
                                 ,pr_dscritic   => vr_dscritic);                --> Retornar Critica                                                   
          
            BEGIN
              UPDATE crapcrl crl
                 SET crl.cdrlcrsp = nvl(pr_pessoa_resp_new.cdrelacionamento,0)
               WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                 AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                 AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                 --> Pessoa anterior
                 AND crl.nrcpfcgc = nvl(rw_pessoa_resp.nrcpf,0)
                 AND crl.nmrespon = rw_pessoa_resp.nmpessoa;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar responsavel legal: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;   
            
            vr_nrqtatlz := vr_nrqtatlz + SQL%ROWCOUNT; 
            
            -- Atualizar pessoas que estejam atreladas via conta
            -- Buscar contas anteriores
            pc_retorna_contas ( pr_idpessoa   => pr_pessoa_resp_new.idpessoa_resp_legal,
                                pr_tab_contas => vr_tab_contas_new,
                                pr_dscritic   => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;  
            
            IF vr_tab_contas_new.count > 0 THEN
              FOR  idx_new IN vr_tab_contas_new.first..vr_tab_contas_new.last LOOP
                --> Apenas se for da mesma cooperativa
                IF vr_tab_contas(idx).cdcooper = vr_tab_contas_new(idx_new).cdcooper THEN
                  --> Atualizar registro                  
                  BEGIN
                    UPDATE crapcrl crl
                       SET crl.cdrlcrsp = nvl(pr_pessoa_resp_new.cdrelacionamento,0)
                     WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                       AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                       AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                       --> Pessoa anterior
                       AND crl.nrdconta = vr_tab_contas_new(idx_new).nrdconta;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atuaalizar responsavel legal: '||SQLERRM; 
                      RAISE vr_exc_erro;
                  END; 
                  
                  vr_nrqtatlz := vr_nrqtatlz + SQL%ROWCOUNT;
                   
                END IF;              
              END LOOP;            
            END IF;   
         
            --> Se nao foi alterado nenhum registro
            IF vr_nrqtatlz  = 0 THEN
              --> Incluir responsavel legal
              pc_incluir_resp_legal ( pr_cdcooper        => vr_tab_contas(idx).cdcooper           --> Codifo da cooperativa       
                                     ,pr_idpessoa        => pr_idpessoa                           --> Identificador de pessoa                             
                                     ,pr_nrdconta        => vr_tab_contas(idx).nrdconta           --> Numero de conta
                                     ,pr_idseqttl        => vr_tab_contas(idx).idseqttl           --> Sequencial do titular
                                     ,pr_idpessoa_resp   => pr_pessoa_resp_new.idpessoa_resp_legal--> Identificador de pessoa avalista
                                     ,pr_nrdconta_resp   => vr_nrdconta                           --> Numero de conta avalista
                                     ,pr_cdrlcrsp        => pr_pessoa_resp_new.cdrelacionamento   --> Codigo do relacionamento
                                     ,pr_rowidcrl        => vr_rowidcrl                           --> Retornar rowid da crl criada
                                     ,pr_dscritic        => vr_dscritic );                        --> Retornar Critica 
            
              IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  
            END IF;
          
            
          END IF; --> fim tpoperacao          
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar responsavel legal: '||SQLERRM; 
  END pc_atualiza_pessoa_fisica_resp;
  
  --> Incluir conjuge
  PROCEDURE pc_incluir_conjuge (pr_cdcooper          IN crapass.cdcooper%TYPE                 --> Codifo da cooperativa       
                               ,pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE         --> Identificador de pessoa                             
                               ,pr_nrdconta          IN crapass.nrdconta%TYPE                 --> Numero de conta
                               ,pr_idseqttl          IN crapttl.idseqttl%TYPE                 --> Sequencial do titular
                               ,pr_idpessoa_cje     IN tbcadast_pessoa.idpessoa%TYPE          --> Identificador de pessoa avalista
                               ,pr_nrdconta_cje     IN crapass.nrdconta%TYPE                  --> Numero de conta avalista
                               ,pr_rowidcje         OUT ROWID                                 --> Retornar rowid da avt criada
                               ,pr_dscritic         OUT VARCHAR2                              --> Retornar Critica 
                              ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_incluir_conjuge
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar conjuge na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tppessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa         cr_pessoa%ROWTYPE;             
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_fis (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT *
        FROM vwcadast_pessoa_fisica pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa_fis     cr_pessoa_fis%ROWTYPE;  
    
    --> Buscar telefone
    CURSOR cr_telefone (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT tel.*,
             '('||tel.nrddd ||') '||tel.nrtelefone dstelefone
        FROM tbcadast_pessoa_telefone tel
       WHERE tel.idpessoa = pr_idpessoa 
         AND tel.tptelefone = 3; --> Comercial
    rw_telefone cr_telefone%ROWTYPE;
    
    --> Buscar renda
    CURSOR cr_renda (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT ren.*,
             pes.nrcpfcgc,
             pes.nmpessoa
        FROM tbcadast_pessoa_renda ren,
             tbcadast_pessoa pes
       WHERE ren.idpessoa             = pr_idpessoa 
         AND ren.idpessoa_fonte_renda = pes.idpessoa ;
    rw_renda cr_renda%ROWTYPE;
    
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
        
  BEGIN
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa_cje );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF; 
    
    IF rw_pessoa.tppessoa = 1 THEN
      -- Buscar informações da pessoa
      OPEN cr_pessoa_fis (pr_idpessoa => pr_idpessoa_cje );
      FETCH cr_pessoa_fis INTO rw_pessoa_fis; 
      IF cr_pessoa_fis%NOTFOUND THEN
        CLOSE cr_pessoa_fis;      
        vr_dscritic := 'Pessoa Fisica não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_pessoa_fis;
      END IF;   
    
    ELSE
      vr_dscritic := 'Pessoa Juridica não permitida.';
      RAISE vr_exc_erro;
      
    END IF;     
    
    --> Buscar renda
    OPEN cr_renda (pr_idpessoa => pr_idpessoa_cje);
    FETCH cr_renda INTO rw_renda;
    CLOSE cr_renda;
       
    --> Buscar telefone
    rw_telefone := NULL;
    OPEN cr_telefone (pr_idpessoa => pr_idpessoa_cje);
    FETCH cr_telefone INTO rw_telefone;
    CLOSE cr_telefone;
          
    IF pr_nrdconta_cje > 0 THEN
  
      --> Criar conjuge com numero de conta
      BEGIN
        INSERT INTO crapcje
                   (cdcooper, 
                    nrdconta, 
                    idseqttl, 
                    nrctacje,
                    -- Renda
                    nrdocnpj,
                    nmextemp,
                    cdocpcje,                   
                    tpcttrab,
                    cdnvlcgo,
                    cdturnos,
                    dtadmemp,
                    vlsalari,
                    -- Telefone -- 3 Comercial
                    nrfonemp,
                    nrramemp )
            VALUES (pr_cdcooper,                 --> cdcooper
                    pr_nrdconta,                 --> nrctamen
                    pr_idseqttl,                 --> nrcpfmen
                    pr_nrdconta_cje,             --> idseqmen
                    -- Renda
                    rw_renda.nrcpfcgc,           --> nrdocnpj
                    substr(rw_renda.nmpessoa,1,40), --> nmextemp
                    rw_renda.cdocupacao,         --> cdocpcje
                    rw_renda.tpcontrato_trabalho,--> tpcttrab
                    rw_renda.cdnivel_cargo,      --> cdnvlcgo
                    rw_renda.cdturno,            --> cdturnos
                    rw_renda.dtadmissao,         --> dtadmemp
                    nvl(rw_renda.vlrenda,0),     --> vlsalari
                    -- Telefone -- 3 Comercial
                    rw_telefone.dstelefone,      --> nrfonemp
                    rw_telefone.nrramal          --> nrramemp                    
                    )RETURNING ROWID INTO pr_rowidcje ;
      EXCEPTION
        WHEN dup_val_on_index THEN 
          BEGIN
            UPDATE crapcje cje
               SET nrctacje = pr_nrdconta_cje,             --> idseqmen
                   -- Renda 
                   nrdocnpj = rw_renda.nrcpfcgc,           --> nrdocnpj
                   nmextemp = substr(rw_renda.nmpessoa,1,40),           --> nmextemp
                   cdocpcje = rw_renda.cdocupacao,         --> cdocpcje
                   tpcttrab = rw_renda.tpcontrato_trabalho,--> tpcttrab
                   cdnvlcgo = rw_renda.cdnivel_cargo,      --> cdnvlcgo
                   cdturnos = rw_renda.cdturno,            --> cdturnos
                   dtadmemp = rw_renda.dtadmissao,         --> dtadmemp
                   vlsalari = nvl(rw_renda.vlrenda,0),            --> vlsalari
                   -- Telefone -- 3 Comercial
                   nrfonemp = rw_telefone.dstelefone,      --> nrfonemp
                   nrramemp = rw_telefone.nrramal          --> nrramemp  
             WHERE cje.cdcooper = pr_cdcooper
               AND cje.nrdconta = pr_nrdconta
               AND cje.idseqttl = pr_idseqttl
               RETURNING ROWID INTO pr_rowidcje ;
             
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel atualizar conjuge com conta: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel cria conjuge com conta: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      
      --> Criar conjuge Sem numero de conta
      BEGIN
        INSERT INTO crapcje
                   (cdcooper, 
                    nrdconta, 
                    idseqttl, 
                    nrctacje,
                    -- Pessoa
                    nrcpfcjg,
                    nmconjug,
                    dtnasccj,
                    tpdoccje,
                    nrdoccje,
                    idorgexp,
                    cdufdcje,
                    dtemdcje,
                    grescola,
                    cdfrmttl,
                    cdnatopc,
                    dsproftl,
                    -- Renda
                    nrdocnpj,
                    nmextemp,
                    cdocpcje,                   
                    tpcttrab,
                    cdnvlcgo,
                    cdturnos,
                    dtadmemp,
                    vlsalari,
                    -- Telefone -- 3 Comercial
                    nrfonemp,
                    nrramemp )
            VALUES (pr_cdcooper,                        --> cdcooper
                    pr_nrdconta,                        --> nrctamen
                    pr_idseqttl,                        --> nrcpfmen
                    0,                                  --> nrctacje
                    --Pessoa
                    rw_pessoa_fis.nrcpf,                --> nrcpfcjg
                    rw_pessoa_fis.nmpessoa,             --> nmconjug
                    rw_pessoa_fis.dtnascimento,         --> dtnasccj
                    rw_pessoa_fis.tpdocumento,          --> tpdoccje
                    rw_pessoa_fis.nrdocumento,          --> nrdoccje
                    nvl(rw_pessoa_fis.idorgao_expedidor,0), --> idorgexp
                    nvl(rw_pessoa_fis.cduf_orgao_expedidor,' '), --> cdufdcje
                    rw_pessoa_fis.dtemissao_documento,  --> dtemdcje
                    rw_pessoa_fis.cdgrau_escolaridade,  --> grescola
                    rw_pessoa_fis.cdcurso_superior,     --> cdfrmttl
                    rw_pessoa_fis.cdnatureza_ocupacao,  --> cdnatopc
                    rw_pessoa_fis.dsprofissao,          --> dsproftl                    
                    -- Renda
                    rw_renda.nrcpfcgc,                  --> nrdocnpj
                    substr(rw_renda.nmpessoa,1,40),     --> nmextemp
                    rw_renda.cdocupacao,                --> cdocpcje
                    rw_renda.tpcontrato_trabalho,       --> tpcttrab
                    rw_renda.cdnivel_cargo,             --> cdnvlcgo
                    rw_renda.cdturno,                   --> cdturnos
                    rw_renda.dtadmissao,                --> dtadmemp
                    nvl(rw_renda.vlrenda,0),            --> vlsalari
                    -- Telefone -- 3 Comercial
                    rw_telefone.dstelefone,             --> nrfonemp
                    rw_telefone.nrramal                 --> nrramemp                    
                    )RETURNING ROWID INTO pr_rowidcje ;
      EXCEPTION
        WHEN dup_val_on_index THEN
        
          BEGIN
            UPDATE crapcje cje
               SET nrctacje = 0,                                  --> nrctacje
                   --Pessoa
                   nrcpfcjg = rw_pessoa_fis.nrcpf,                --> nrcpfcjg
                   nmconjug = rw_pessoa_fis.nmpessoa,             --> nmconjug
                   dtnasccj = rw_pessoa_fis.dtnascimento,         --> dtnasccj
                   tpdoccje = rw_pessoa_fis.tpdocumento,          --> tpdoccje
                   nrdoccje = rw_pessoa_fis.nrdocumento,          --> nrdoccje
                   idorgexp = nvl(rw_pessoa_fis.idorgao_expedidor,0),      --> idorgexp
                   cdufdcje = nvl(rw_pessoa_fis.cduf_orgao_expedidor,' '), --> cdufdcje
                   dtemdcje = rw_pessoa_fis.dtemissao_documento,  --> dtemdcje
                   grescola = rw_pessoa_fis.cdgrau_escolaridade,  --> grescola
                   cdfrmttl = rw_pessoa_fis.cdcurso_superior,     --> cdfrmttl
                   cdnatopc = rw_pessoa_fis.cdnatureza_ocupacao,  --> cdnatopc
                   dsproftl = rw_pessoa_fis.dsprofissao,          --> dsproftl                    
                   -- Renda -- Renda
                   nrdocnpj = rw_renda.nrcpfcgc,                  --> nrdocnpj
                   nmextemp = substr(rw_renda.nmpessoa,1,40),     --> nmextemp
                   cdocpcje = rw_renda.cdocupacao,                --> cdocpcje
                   tpcttrab = rw_renda.tpcontrato_trabalho,       --> tpcttrab
                   cdnvlcgo = rw_renda.cdnivel_cargo,             --> cdnvlcgo
                   cdturnos = rw_renda.cdturno,                   --> cdturnos
                   dtadmemp = rw_renda.dtadmissao,                --> dtadmemp
                   vlsalari = nvl(rw_renda.vlrenda,0),            --> vlsalari
                   -- Telefone -- 3 Comercial
                   nrfonemp = rw_telefone.dstelefone,             --> nrfonemp
                   nrramemp = rw_telefone.nrramal                 --> nrramemp   
             WHERE cje.cdcooper = pr_cdcooper
               AND cje.nrdconta = pr_nrdconta
               AND cje.idseqttl = pr_idseqttl
               RETURNING ROWID INTO pr_rowidcje ;
             
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel atualizar conjuge sem conta: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel cria conjuge sem conta: '||SQLERRM;
          RAISE vr_exc_erro;
      END;      
    END IF;
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel criar conjuge: '||SQLERRM; 
  END pc_incluir_conjuge;

  /*******************************************************************************/
  /** Procedure para atualizar as pessoas de relacionamento na estrutura antiga **/
  /*******************************************************************************/
  PROCEDURE pc_atualiza_pessoa_relacao( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE             --> Identificador de pessoa
                                       ,pr_tpoperacao        IN INTEGER                                   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_pessoa_relac_old  IN tbcadast_pessoa_relacao%ROWTYPE             --> Dados anteriores
                                       ,pr_pessoa_relac_new  IN tbcadast_pessoa_relacao%ROWTYPE             --> Dados novos
                                       ,pr_dscritic         OUT VARCHAR2                                 --> Retornar Critica 
                                       ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_pessoa_relacao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar pessoas de relacionamento na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro,
             fis.cdestado_civil
        FROM tbcadast_pessoa pes,
             tbcadast_pessoa_fisica fis 
       WHERE pes.idpessoa = pr_idpessoa
         AND pes.idpessoa = fis.idpessoa(+);    
    rw_pessoa cr_pessoa%ROWTYPE;   
        
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_fis (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpf,
             pes.nmpessoa,
             pes.tpcadastro,
             pes.dtnascimento
        FROM vwcadast_pessoa_fisica pes
       WHERE pes.idpessoa = pr_idpessoa;        
    rw_pessoa_rel       cr_pessoa_fis%ROWTYPE;         
    rw_pessoa_rel_new   cr_pessoa_fis%ROWTYPE; 
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas     cada0010.typ_tab_conta;
    vr_tab_contas_old typ_tab_contas;
    vr_nrdconta       crapass.nrdconta%TYPE;
    vr_rowidcje       ROWID;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    -- Buscar informações da pessoa representante
    OPEN cr_pessoa_fis (pr_idpessoa => nvl(pr_pessoa_relac_old.idpessoa_relacao,
                                           pr_pessoa_relac_new.idpessoa_relacao) );
    FETCH cr_pessoa_fis INTO rw_pessoa_rel; 
    IF cr_pessoa_fis%NOTFOUND THEN
      CLOSE cr_pessoa_fis;      
      vr_dscritic := 'Pessoa responsavel legal não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa_fis;
    END IF;     
        
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> Exclusao
        IF pr_tpoperacao = 3 OR 
           --> Ou foi alterada a pessoa ou a relacao
           (nvl(pr_pessoa_relac_old.idpessoa_relacao,
                pr_pessoa_relac_new.idpessoa_relacao) <> pr_pessoa_relac_new.idpessoa_relacao) OR         
           (nvl(pr_pessoa_relac_old.tprelacao,
                pr_pessoa_relac_new.tprelacao) <> pr_pessoa_relac_new.tprelacao)
           THEN
           
          --> Se relacao era 3-PAI ou 4 - mae 
          IF pr_pessoa_relac_old.tprelacao IN( 3,4) THEN
          
            --> 6-Titular (crapttl)
            IF vr_tab_contas(idx).tprelacao = 6 THEN
            
              BEGIN
                UPDATE crapttl ttl
                   SET ttl.nmpaittl = decode(pr_pessoa_relac_old.tprelacao,3,' ',ttl.nmpaittl),
                       ttl.nmmaettl = decode(pr_pessoa_relac_old.tprelacao,4,' ',ttl.nmmaettl)
                 WHERE ttl.cdcooper = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl = vr_tab_contas(idx).idseqttl;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir pai do titular: '||SQLERRM; 
                  RAISE vr_exc_erro;
              END;
            
            --> 10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
            ELSIF vr_tab_contas(idx).tprelacao IN(10) THEN
              BEGIN          
                UPDATE crapavt avt
                   SET avt.nmpaicto = decode(pr_pessoa_relac_old.tprelacao,3,' ',avt.nmpaicto),
                       avt.nmmaecto = decode(pr_pessoa_relac_old.tprelacao,4,' ',avt.nmmaecto)
                 WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                   AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                   AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                   AND avt.nmdavali = rw_pessoa.nmpessoa
                   AND avt.tpctrato = 5
                   AND nvl(avt.nrdctato ,0) = 0 ;                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir pai do avalista: '||SQLERRM;
                  RAISE vr_exc_erro;                    
              END;
            --> 20-Representante de uma PJ (crapavt onde tpctato = 6)
            ELSIF vr_tab_contas(idx).tprelacao IN(20) THEN
              BEGIN          
                UPDATE crapavt avt
                   SET avt.nmpaicto = decode(pr_pessoa_relac_old.tprelacao,3,' ',avt.nmpaicto),
                       avt.nmmaecto = decode(pr_pessoa_relac_old.tprelacao,4,' ',avt.nmmaecto)
                 WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                   AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                   AND nvl(avt.nrcpfcgc,0) = nvl(rw_pessoa.nrcpfcgc,0)
                   AND avt.nmdavali = rw_pessoa.nmpessoa
                   AND avt.tpctrato = 6
                   AND nvl(avt.nrdctato ,0) = 0 ;                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir pai do avalista: '||SQLERRM;
                  RAISE vr_exc_erro;                    
              END;  
              
            --> 30-Responsavel Legal (crapcrl)
            ELSIF vr_tab_contas(idx).tprelacao IN(30) THEN
              BEGIN          
                UPDATE crapcrl crl
                   SET crl.nmpairsp = decode(pr_pessoa_relac_old.tprelacao,3,' ',crl.nmpairsp),
                       crl.nmmaersp = decode(pr_pessoa_relac_old.tprelacao,4,' ',crl.nmmaersp)
                 WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                   AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                   AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                   AND nvl(crl.nrcpfcgc, 0) = nvl(rw_pessoa.nrcpfcgc,0);                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir pai do responsavel legal: '||SQLERRM;
                  RAISE vr_exc_erro;                    
              END;
            
            END IF;
                    
          --> Se relacao era 1-Conjuge
          ELSIF pr_pessoa_relac_old.tprelacao IN (1) THEN
          
            BEGIN
              DELETE crapcje cje
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                 AND nvl(cje.nrcpfcjg,0) = nvl(rw_pessoa_rel.nrcpf,0)
                 AND cje.nmconjug = rw_pessoa_rel.nmpessoa
                 AND nvl(cje.nrctacje,0) = 0;  
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao excluir conjuge: '||SQLERRM;
                RAISE vr_exc_erro;            
            END;
            
            --> Necessario incluir conjuge vazio devido o estado civil da pessoa
            IF rw_pessoa.cdestado_civil NOT IN (1,    --> SOLTEIRO
                                                5,    --> VIUVO
                                                6,    --> SEPARADO
                                                7) THEN --> DIVORCIADO
            
              BEGIN
                INSERT INTO crapcje
                            (cdcooper,
                             nrdconta,
                             idseqttl)
                      VALUES(vr_tab_contas(idx).cdcooper,
                             vr_tab_contas(idx).nrdconta,
                             vr_tab_contas(idx).idseqttl);
              EXCEPTION
                WHEN dup_val_on_index THEN
                  NULL;
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao incluir conjuge vazio: '||SQLERRM;
                  RAISE vr_exc_erro;            
              END;
            END IF;
            
            -- Eliminar pessoas que estjam atreladas via conta
            -- Buscar contas anteriores
            pc_retorna_contas ( pr_idpessoa   => pr_pessoa_relac_old.idpessoa_relacao,
                                pr_tab_contas => vr_tab_contas_old,
                                pr_dscritic   => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;  
            
            IF vr_tab_contas_old.count > 0 THEN
              FOR  idx_old IN vr_tab_contas_old.first..vr_tab_contas_old.last LOOP
                --> Apenas se for da mesma cooperativa
                IF vr_tab_contas(idx).cdcooper = vr_tab_contas_old(idx_old).cdcooper THEN
                  --> Deletar registro                  
                  BEGIN
                    DELETE crapcje cje
                     WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                       AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                       AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                       AND nvl(cje.nrctacje,0) = vr_tab_contas_old(idx_old).nrdconta;  
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao excluir conjuge: '||SQLERRM;
                      RAISE vr_exc_erro;            
                  END;
                  
                  --> Necessario incluir conjuge vazio devido o estado civil da pessoa
                  IF rw_pessoa.cdestado_civil NOT IN (1,    --> SOLTEIRO
                                                      5,    --> VIUVO
                                                      6,    --> SEPARADO
                                                      7) THEN --> DIVORCIADO
                  
                    BEGIN
                      INSERT INTO crapcje
                                  (cdcooper,
                                   nrdconta,
                                   idseqttl)
                            VALUES(vr_tab_contas(idx).cdcooper,
                                   vr_tab_contas(idx).nrdconta,
                                   vr_tab_contas(idx).idseqttl);
                    EXCEPTION
                      WHEN dup_val_on_index THEN
                        NULL;
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao incluir conjuge vazio: '||SQLERRM;
                        RAISE vr_exc_erro;            
                    END;
                  END IF;
                                                       
                END IF; --Coops diferentes
              END LOOP; 
            END IF;   
            
          END IF;  --> Fim tprelacao           
        END IF; --> Tipo de operacao
        
        --> Alteração/inlcusao
        IF pr_tpoperacao <> 3 THEN
        
          --> buscar dados da nova pessoa de relacionamento
          rw_pessoa_rel_new := NULL;
          IF pr_pessoa_relac_new.idpessoa_relacao > 0 THEN
            -- Buscar informações da pessoa participante
            OPEN cr_pessoa_fis (pr_idpessoa => pr_pessoa_relac_new.idpessoa_relacao );
            FETCH cr_pessoa_fis INTO rw_pessoa_rel_new; 
            IF cr_pessoa_fis%NOTFOUND THEN
              CLOSE cr_pessoa_fis;      
              vr_dscritic := 'Pessoa de relacionamento não encontrada.';
              RAISE vr_exc_erro;
            ELSE
              CLOSE cr_pessoa_fis;
            END IF;
          END IF;
        
        
          --> Se relacao era 3-PAI ou 4 - mae 
          IF pr_pessoa_relac_new.tprelacao IN( 3,4) THEN
          
            --> 6-Titular (crapttl)
            IF vr_tab_contas(idx).tprelacao = 6 THEN
              BEGIN
                UPDATE crapttl ttl
                   SET ttl.nmpaittl = decode(pr_pessoa_relac_new.tprelacao,3,rw_pessoa_rel_new.nmpessoa,ttl.nmpaittl),
                       ttl.nmmaettl = decode(pr_pessoa_relac_new.tprelacao,4,rw_pessoa_rel_new.nmpessoa,ttl.nmmaettl)
                 WHERE ttl.cdcooper = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl = vr_tab_contas(idx).idseqttl;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar pai do titular: '||SQLERRM; 
                  RAISE vr_exc_erro;
              END;
            
            --> 10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
            ELSIF vr_tab_contas(idx).tprelacao IN(10) THEN
              BEGIN          
                UPDATE crapavt avt
                   SET avt.nmpaicto = decode(pr_pessoa_relac_new.tprelacao,3,rw_pessoa_rel_new.nmpessoa,avt.nmpaicto),
                       avt.nmmaecto = decode(pr_pessoa_relac_new.tprelacao,4,rw_pessoa_rel_new.nmpessoa,avt.nmmaecto)
                 WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                   AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                   AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                   AND avt.nmdavali = rw_pessoa.nmpessoa
                   AND avt.tpctrato = 5
                   AND nvl(avt.nrdctato ,0) = 0 ;                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar pai do avalista: '||SQLERRM;
                  RAISE vr_exc_erro;                    
              END;
            
            --> 20-Representante de uma PJ (crapavt onde tpctato = 6)
            ELSIF vr_tab_contas(idx).tprelacao IN(20) THEN
              BEGIN          
                UPDATE crapavt avt
                   SET avt.nmpaicto = decode(pr_pessoa_relac_new.tprelacao,3,rw_pessoa_rel_new.nmpessoa,avt.nmpaicto),
                       avt.nmmaecto = decode(pr_pessoa_relac_new.tprelacao,4,rw_pessoa_rel_new.nmpessoa,avt.nmmaecto)
                 WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                   AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                   AND nvl(avt.nrcpfcgc,0) = nvl(rw_pessoa.nrcpfcgc,0)
                   AND avt.nmdavali = rw_pessoa.nmpessoa
                   AND avt.tpctrato = 6
                   AND nvl(avt.nrdctato ,0) = 0 ;                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar pai do avalista: '||SQLERRM;
                  RAISE vr_exc_erro;                    
              END;  
            --> 30-Responsavel Legal (crapcrl)
            ELSIF vr_tab_contas(idx).tprelacao IN(30) THEN
              BEGIN          
                UPDATE crapcrl crl
                   SET crl.nmpairsp = decode(pr_pessoa_relac_new.tprelacao,3,rw_pessoa_rel_new.nmpessoa,crl.nmpairsp),
                       crl.nmmaersp = decode(pr_pessoa_relac_new.tprelacao,4,rw_pessoa_rel_new.nmpessoa,crl.nmmaersp)
                 WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                   AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                   AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                   AND nvl(crl.nrcpfcgc, 0) = nvl(rw_pessoa.nrcpfcgc,0);                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar pai do responsavel legal: '||SQLERRM;
                  RAISE vr_exc_erro;                    
              END;
            
            END IF;
                    
          --> Se relacao era 1-Conjuge
          ELSIF pr_pessoa_relac_new.tprelacao IN (1) THEN
          
            --> 6-Titular (crapttl)
            IF vr_tab_contas(idx).tprelacao = 6 THEN
              --> Buscar numero da cona mais recente
              pc_ret_conta_recente( pr_nrcpfcgc   => rw_pessoa_rel_new.nrcpf   --> Numero do CPF/CNPJ
                                   ,pr_cdcooper   => vr_tab_contas(idx).cdcooper  --> Codigo da cooperativa
                                   ,pr_nrdconta   => vr_nrdconta                  --> Retornar contas
                                   ,pr_dscritic   => vr_dscritic);                --> Retornar Critica                                                   
            
              IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  
                 
              --> Incluir conjuge
              pc_incluir_conjuge (pr_cdcooper        => vr_tab_contas(idx).cdcooper          --> Codifo da cooperativa       
                                 ,pr_idpessoa        => pr_idpessoa                          --> Identificador de pessoa                             
                                 ,pr_nrdconta        => vr_tab_contas(idx).nrdconta          --> Numero de conta
                                 ,pr_idseqttl        => vr_tab_contas(idx).idseqttl          --> Sequencial do titular
                                 ,pr_idpessoa_cje    => pr_pessoa_relac_new.idpessoa_relacao --> Identificador de pessoa avalista
                                 ,pr_nrdconta_cje    => vr_nrdconta                          --> Numero de conta avalista
                                 ,pr_rowidcje        => vr_rowidcje                          --> Retornar rowid da avt criada
                                 ,pr_dscritic        => vr_dscritic);                        --> Retornar Critica   
              
              IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  
            END IF;
          END IF;  --> Fim tprelacao  
        
        END IF; --> Tipo de operacao
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar pessoas de relacionamento: '||SQLERRM; 
  END pc_atualiza_pessoa_relacao;
  
  
  /*****************************************************************************/
  /**            Procedure para atualizar bens na estrutura antiga            **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_bem ( pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE           --> Identificador de pessoa                            
                             ,pr_tpoperacao    IN INTEGER                                 --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_bem_old       IN tbcadast_pessoa_bem%ROWTYPE             --> Dados anteriores
                             ,pr_bem_new       IN tbcadast_pessoa_bem%ROWTYPE             --> Dados novos
                             ,pr_dscritic      OUT VARCHAR2                               --> Retornar Critica 
                             ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_bem
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar bens na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro,
             pes.tppessoa
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE;   
       
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas  cada0010.typ_tab_conta;
    
  BEGIN
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;     
    
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> Caso for pj porém o tipo de conta é fisica, ir para o proximo
        --> pois é a relacao onde determinada conta tem vinculo
        IF vr_tab_contas(idx).tprelacao = 7 AND 
           rw_pessoa.tppessoa = 1 THEN           
           continue;
        END IF;   
        
        --> 6-Titular (crapttl)
        --> 7-Titular (crapjur)
        IF vr_tab_contas(idx).tprelacao IN (6,7) THEN
        
          --> Exclusao
          IF pr_tpoperacao = 3 THEN
            --> Deletar registro
            BEGIN
              DELETE crapbem bem
               WHERE bem.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND bem.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND bem.idseqttl   = vr_tab_contas(idx).idseqttl
                 AND bem.idseqbem   = pr_bem_old.nrseq_bem;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao excluir bem: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;    
        
          --> Senao é ALTERACAO/INCLUSAO  
          ELSE
            --> Realizar alteração  
            BEGIN
              UPDATE crapbem bem
                 SET cdoperad = pr_bem_new.cdoperad_altera, 
                     dtaltbem = pr_bem_new.dtalteracao, 
                     --idseqbem := pr_bem_new.nrseq_bem, 
                     dsrelbem = pr_bem_new.dsbem, 
                     persemon = pr_bem_new.pebem, 
                     qtprebem = pr_bem_new.qtparcela_bem, 
                     vlrdobem = pr_bem_new.vlbem, 
                     vlprebem = pr_bem_new.vlparcela_bem    
               WHERE bem.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND bem.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND bem.idseqttl   = vr_tab_contas(idx).idseqttl
                 AND bem.idseqbem   = pr_bem_new.nrseq_bem;
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar bem:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
            
              
            --> Se nao foi alterado nenhum registro
            IF SQL%ROWCOUNT  = 0 THEN
              --> Inserir registro
              BEGIN
                INSERT INTO crapbem
                            ( cdcooper, 
                              nrdconta, 
                              idseqttl, 
                              dtmvtolt, 
                              cdoperad, 
                              dtaltbem, 
                              idseqbem, 
                              dsrelbem, 
                              persemon, 
                              qtprebem, 
                              vlrdobem, 
                              vlprebem )
                     VALUES (vr_tab_contas(idx).cdcooper,  --> cdcooper
                             vr_tab_contas(idx).nrdconta,  --> nrdconta
                             vr_tab_contas(idx).idseqttl,  --> idseqttl
                             pr_bem_new.dtalteracao,       --> dtmvtolt
                             pr_bem_new.cdoperad_altera,   --> cdoperad
                             pr_bem_new.dtalteracao,       --> dtaltbem
                             pr_bem_new.nrseq_bem,         --> idseqbem
                             pr_bem_new.dsbem,             --> dsrelbem
                             pr_bem_new.pebem,             --> persemon
                             pr_bem_new.qtparcela_bem,     --> qtprebem
                             pr_bem_new.vlbem,             --> vlrdobem
                             pr_bem_new.vlparcela_bem);    --> vlprebem
                                  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir bem: '||SQLERRM; 
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF; --> fim tpoperacao
               
        --> 20-Representante de uma PJ (crapavt onde tpctato = 6)
        ELSIF vr_tab_contas(idx).tprelacao = 20 THEN
            
          --> Se for exclusao
          IF pr_tpoperacao = 3 THEN 
            BEGIN          
              UPDATE crapavt avt
                 SET dsrelbem##1 = decode(pr_bem_old.nrseq_bem,1,' ',dsrelbem##1),
                     persemon##1 = decode(pr_bem_old.nrseq_bem,1,0  ,persemon##1),
                     qtprebem##1 = decode(pr_bem_old.nrseq_bem,1,0  ,qtprebem##1),
                     vlrdobem##1 = decode(pr_bem_old.nrseq_bem,1,0  ,vlrdobem##1),
                     vlprebem##1 = decode(pr_bem_old.nrseq_bem,1,0  ,vlprebem##1),
                 
                     dsrelbem##2 = decode(pr_bem_old.nrseq_bem,2,' ',dsrelbem##2),
                     persemon##2 = decode(pr_bem_old.nrseq_bem,2,0  ,persemon##2),
                     qtprebem##2 = decode(pr_bem_old.nrseq_bem,2,0  ,qtprebem##2),
                     vlrdobem##2 = decode(pr_bem_old.nrseq_bem,2,0  ,vlrdobem##2),
                     vlprebem##2 = decode(pr_bem_old.nrseq_bem,2,0  ,vlprebem##2),
                     
                     dsrelbem##3 = decode(pr_bem_old.nrseq_bem,3,' ',dsrelbem##3),
                     persemon##3 = decode(pr_bem_old.nrseq_bem,3,0  ,persemon##3),
                     qtprebem##3 = decode(pr_bem_old.nrseq_bem,3,0  ,qtprebem##3),
                     vlrdobem##3 = decode(pr_bem_old.nrseq_bem,3,0  ,vlrdobem##3),
                     vlprebem##3 = decode(pr_bem_old.nrseq_bem,3,0  ,vlprebem##3),
                                                                               
                     dsrelbem##4 = decode(pr_bem_old.nrseq_bem,4,' ',dsrelbem##4),
                     persemon##4 = decode(pr_bem_old.nrseq_bem,4,0  ,persemon##4),
                     qtprebem##4 = decode(pr_bem_old.nrseq_bem,4,0  ,qtprebem##4),
                     vlrdobem##4 = decode(pr_bem_old.nrseq_bem,4,0  ,vlrdobem##4),
                     vlprebem##4 = decode(pr_bem_old.nrseq_bem,4,0  ,vlprebem##4),
                                                                               
                     dsrelbem##5 = decode(pr_bem_old.nrseq_bem,5,' ',dsrelbem##5),
                     persemon##5 = decode(pr_bem_old.nrseq_bem,5,0  ,persemon##5),
                     qtprebem##5 = decode(pr_bem_old.nrseq_bem,5,0  ,qtprebem##5),
                     vlrdobem##5 = decode(pr_bem_old.nrseq_bem,5,0  ,vlrdobem##5),
                     vlprebem##5 = decode(pr_bem_old.nrseq_bem,5,0  ,vlprebem##5),
                                                                               
                     dsrelbem##6 = decode(pr_bem_old.nrseq_bem,6,' ',dsrelbem##6),
                     persemon##6 = decode(pr_bem_old.nrseq_bem,6,0  ,persemon##6),
                     qtprebem##6 = decode(pr_bem_old.nrseq_bem,6,0  ,qtprebem##6),
                     vlrdobem##6 = decode(pr_bem_old.nrseq_bem,6,0  ,vlrdobem##6),
                     vlprebem##6 = decode(pr_bem_old.nrseq_bem,6,0  ,vlprebem##6) 
                 
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND nvl(avt.nrcpfcgc,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 6 -- Pessoa de referencia
                 AND nvl(avt.nrdctato ,0) = 0 ;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao limpar bem do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          --> se for exclusao
          ELSE 
            -- Atualizar campos
            BEGIN          
              UPDATE crapavt avt
                 SET dsrelbem##1 = decode(pr_bem_new.nrseq_bem,1,pr_bem_new.dsbem         ,dsrelbem##1),
                     persemon##1 = decode(pr_bem_new.nrseq_bem,1,pr_bem_new.pebem         ,persemon##1),
                     qtprebem##1 = decode(pr_bem_new.nrseq_bem,1,pr_bem_new.qtparcela_bem ,qtprebem##1),
                     vlrdobem##1 = decode(pr_bem_new.nrseq_bem,1,pr_bem_new.vlbem         ,vlrdobem##1),
                     vlprebem##1 = decode(pr_bem_new.nrseq_bem,1,pr_bem_new.vlparcela_bem ,vlprebem##1),
                 
                     dsrelbem##2 = decode(pr_bem_new.nrseq_bem,2,pr_bem_new.dsbem         ,dsrelbem##2),
                     persemon##2 = decode(pr_bem_new.nrseq_bem,2,pr_bem_new.pebem         ,persemon##2),
                     qtprebem##2 = decode(pr_bem_new.nrseq_bem,2,pr_bem_new.qtparcela_bem ,qtprebem##2),
                     vlrdobem##2 = decode(pr_bem_new.nrseq_bem,2,pr_bem_new.vlbem         ,vlrdobem##2),
                     vlprebem##2 = decode(pr_bem_new.nrseq_bem,2,pr_bem_new.vlparcela_bem ,vlprebem##2),
                     
                     dsrelbem##3 = decode(pr_bem_new.nrseq_bem,3,pr_bem_new.dsbem         ,dsrelbem##3),
                     persemon##3 = decode(pr_bem_new.nrseq_bem,3,pr_bem_new.pebem         ,persemon##3),
                     qtprebem##3 = decode(pr_bem_new.nrseq_bem,3,pr_bem_new.qtparcela_bem ,qtprebem##3),
                     vlrdobem##3 = decode(pr_bem_new.nrseq_bem,3,pr_bem_new.vlbem         ,vlrdobem##3),
                     vlprebem##3 = decode(pr_bem_new.nrseq_bem,3,pr_bem_new.vlparcela_bem ,vlprebem##3),
                                                                               
                     dsrelbem##4 = decode(pr_bem_new.nrseq_bem,4,pr_bem_new.dsbem         ,dsrelbem##4),
                     persemon##4 = decode(pr_bem_new.nrseq_bem,4,pr_bem_new.pebem         ,persemon##4),
                     qtprebem##4 = decode(pr_bem_new.nrseq_bem,4,pr_bem_new.qtparcela_bem ,qtprebem##4),
                     vlrdobem##4 = decode(pr_bem_new.nrseq_bem,4,pr_bem_new.vlbem         ,vlrdobem##4),
                     vlprebem##4 = decode(pr_bem_new.nrseq_bem,4,pr_bem_new.vlparcela_bem ,vlprebem##4),
                                                                               
                     dsrelbem##5 = decode(pr_bem_new.nrseq_bem,5,pr_bem_new.dsbem         ,dsrelbem##5),
                     persemon##5 = decode(pr_bem_new.nrseq_bem,5,pr_bem_new.pebem         ,persemon##5),
                     qtprebem##5 = decode(pr_bem_new.nrseq_bem,5,pr_bem_new.qtparcela_bem ,qtprebem##5),
                     vlrdobem##5 = decode(pr_bem_new.nrseq_bem,5,pr_bem_new.vlbem         ,vlrdobem##5),
                     vlprebem##5 = decode(pr_bem_new.nrseq_bem,5,pr_bem_new.vlparcela_bem ,vlprebem##5),
                                                                               
                     dsrelbem##6 = decode(pr_bem_new.nrseq_bem,6,pr_bem_new.dsbem         ,dsrelbem##6),
                     persemon##6 = decode(pr_bem_new.nrseq_bem,6,pr_bem_new.pebem         ,persemon##6),
                     qtprebem##6 = decode(pr_bem_new.nrseq_bem,6,pr_bem_new.qtparcela_bem ,qtprebem##6),
                     vlrdobem##6 = decode(pr_bem_new.nrseq_bem,6,pr_bem_new.vlbem         ,vlrdobem##6),
                     vlprebem##6 = decode(pr_bem_new.nrseq_bem,6,pr_bem_new.vlparcela_bem ,vlprebem##6) 
                 
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND nvl(avt.nrcpfcgc,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato = 6 -- Pessoa de referencia
                 AND nvl(avt.nrdctato ,0) = 0 ;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar bens do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
              
          END IF;                                         
        
        END IF; --> fim tprelacao
      
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar bem: '||SQLERRM; 
  END pc_atualiza_bem;
  
  /*****************************************************************************/
  /**            Procedure para atualizar pessoa na estrutura antiga          **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa( pr_idpessoa      IN tbcadast_pessoa.idpessoa%TYPE    --> Identificador de pessoa                            
                               ,pr_tpoperacao    IN INTEGER                          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_pessoa_old    IN tbcadast_pessoa%ROWTYPE          --> Dados anteriores
                               ,pr_pessoa_new    IN tbcadast_pessoa%ROWTYPE          --> Dados novos
                               ,pr_dscritic      OUT VARCHAR2                        --> Retornar Critica 
                               ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_pessoa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar pessoa na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
   
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas  cada0010.typ_tab_conta;
    
  BEGIN    
    
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> Exclusao
        IF pr_tpoperacao = 3 THEN 
          --> Tabela não permitirá exclusão
          RETURN;
        ELSE
        
          --> 1-Conjuge (crapcje)
          IF vr_tab_contas(idx).tprelacao IN (1) THEN
            BEGIN          
              UPDATE crapcje cje
                 SET cje.nmconjug = pr_pessoa_new.nmpessoa,
                     cje.nrcpfcjg = pr_pessoa_new.nrcpfcgc                 
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                 AND nvl(cje.nrctacje,0) = 0;                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar renda do conjuge: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          
          --> 2-Empresa de trabalho do conjuge (crapcje)
          ELSIF vr_tab_contas(idx).tprelacao IN (2) THEN
            BEGIN
              UPDATE crapcje cje
                 SET cje.nmextemp = substr(pr_pessoa_new.nmpessoa,1,40),
                     cje.nrdocnpj = pr_pessoa_new.nrcpfcgc
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl;
                
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar empresa onde titular trabalha:'||SQLERRM;
                RAISE vr_exc_erro;
            END;
          
          --> 3-Pai (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (3) THEN
            --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
            --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
            IF nvl(pr_pessoa_new.nmpessoa,' ') <> nvl(pr_pessoa_old.nmpessoa,' ') THEN
              BEGIN
                UPDATE crapttl ttl
                   SET ttl.nmpaittl = pr_pessoa_new.nmpessoa
                 WHERE ttl.cdcooper = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl = vr_tab_contas(idx).idseqttl;
                  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel atualizar pai do titular:'||SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF;
          
          --> 4-Mae (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (4) THEN
            --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
            --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
            IF nvl(pr_pessoa_new.nmpessoa,' ') <> nvl(pr_pessoa_old.nmpessoa,' ') THEN
              BEGIN
                UPDATE crapttl ttl
                   SET ttl.nmmaettl = pr_pessoa_new.nmpessoa
                 WHERE ttl.cdcooper = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl = vr_tab_contas(idx).idseqttl;
                  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel atualizar pai do titular:'||SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF;
          --> 6-Titular (crapttl)  
          --> 7-Titular (crapjur)        
          ELSIF vr_tab_contas(idx).tprelacao IN (6,7) THEN
            
            IF vr_tab_contas(idx).idseqttl = 1 THEN
              --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
              --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
              IF nvl(pr_pessoa_new.nmpessoa,' ')                  <> nvl(pr_pessoa_old.nmpessoa,' ')                OR
                 nvl(pr_pessoa_new.nmpessoa_receita,' ')          <> nvl(pr_pessoa_old.nmpessoa_receita,' ')        OR
                 nvl(pr_pessoa_new.tppessoa,0)                    <> nvl(pr_pessoa_old.tppessoa,0)                  OR
                 nvl(pr_pessoa_new.dtconsulta_spc,vr_dtpadrao)    <> nvl(pr_pessoa_old.dtconsulta_spc,vr_dtpadrao)  OR
                 nvl(pr_pessoa_new.dtconsulta_rfb,vr_dtpadrao)    <> nvl(pr_pessoa_old.dtconsulta_rfb,vr_dtpadrao)  OR
                 nvl(pr_pessoa_new.cdsituacao_rfb,0)              <> nvl(pr_pessoa_old.cdsituacao_rfb,0)            OR
                 nvl(pr_pessoa_new.tpconsulta_rfb,0)              <> nvl(pr_pessoa_old.tpconsulta_rfb,0)            OR
                 nvl(pr_pessoa_new.dtconsulta_scr,vr_dtpadrao)    <> nvl(pr_pessoa_old.dtconsulta_scr,vr_dtpadrao) THEN 
                 
                BEGIN
                  UPDATE crapass ass
                     SET ass.nmprimtl = pr_pessoa_new.nmpessoa,
                         ass.nmttlrfb = nvl(pr_pessoa_new.nmpessoa_receita,' '),
                         --> tratar para manter inpessoa 3
                         ass.inpessoa = decode(ass.inpessoa,3,3,pr_pessoa_new.tppessoa),
                         ass.dtcnsspc = pr_pessoa_new.dtconsulta_spc,
                         ass.dtcnscpf = pr_pessoa_new.dtconsulta_rfb,
                         ass.cdsitcpf = pr_pessoa_new.cdsituacao_rfb,
                         ass.inconrfb = decode(pr_pessoa_new.tpconsulta_rfb,2,0,1),                     
                         ass.dtcnsscr = pr_pessoa_new.dtconsulta_scr
                   WHERE ass.cdcooper = vr_tab_contas(idx).cdcooper
                     AND ass.nrdconta = vr_tab_contas(idx).nrdconta;
                    
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar associado:'||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;     
            END IF;       
            
            --> 6-Titular (crapttl)          
            IF vr_tab_contas(idx).tprelacao IN (6) THEN
            
              --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
              --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
              IF nvl(pr_pessoa_new.nmpessoa,' ')                     <>  nvl(pr_pessoa_old.nmpessoa,' ')                    OR
                 nvl(pr_pessoa_new.dtconsulta_rfb,vr_dtpadrao)       <>  nvl(pr_pessoa_old.dtconsulta_rfb,vr_dtpadrao)      OR
                 nvl(pr_pessoa_new.cdsituacao_rfb,0)                 <>  nvl(pr_pessoa_old.cdsituacao_rfb,0)                OR
                 nvl(pr_pessoa_new.dtatualiza_telefone,vr_dtpadrao)  <>  nvl(pr_pessoa_old.dtatualiza_telefone,vr_dtpadrao) THEN
   
                BEGIN
                  UPDATE crapttl ttl
                     SET nmextttl = pr_pessoa_new.nmpessoa,
                         dtcnscpf = pr_pessoa_new.dtconsulta_rfb,
                         cdsitcpf = pr_pessoa_new.cdsituacao_rfb,
                         dtatutel = pr_pessoa_new.dtatualiza_telefone
                   WHERE ttl.cdcooper = vr_tab_contas(idx).cdcooper
                     AND ttl.nrdconta = vr_tab_contas(idx).nrdconta
                     AND ttl.idseqttl = vr_tab_contas(idx).idseqttl;
                  
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar titular:'||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;
            --> 7-Titular (crapjur)
            ELSIF vr_tab_contas(idx).tprelacao IN (7) THEN
              --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
              --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
              IF nvl(pr_pessoa_new.nmpessoa,' ')                     <>  nvl(pr_pessoa_old.nmpessoa,' ')                    OR
                 nvl(pr_pessoa_new.dtatualiza_telefone,vr_dtpadrao)  <>  nvl(pr_pessoa_old.dtatualiza_telefone,vr_dtpadrao) THEN
   
                BEGIN
                  UPDATE crapjur jur
                     SET nmextttl = pr_pessoa_new.nmpessoa,
                         dtatutel = pr_pessoa_new.dtatualiza_telefone
                   WHERE jur.cdcooper = vr_tab_contas(idx).cdcooper
                     AND jur.nrdconta = vr_tab_contas(idx).nrdconta;
                  
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar pessoa juridica:'||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;  
            END IF;
            
          --> 5-Empresa de trabalho (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (5) THEN
            --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
            --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
            IF nvl(pr_pessoa_new.nmpessoa,' ')   <>  nvl(pr_pessoa_old.nmpessoa,' ')  OR
               nvl(pr_pessoa_new.nrcpfcgc,0)     <>  nvl(pr_pessoa_old.nrcpfcgc,0)    THEN
              BEGIN
                UPDATE crapttl ttl
                   SET ttl.nmextemp = substr(pr_pessoa_new.nmpessoa,1,40),
                       ttl.nrcpfemp = pr_pessoa_new.nrcpfcgc
                 WHERE ttl.cdcooper = vr_tab_contas(idx).cdcooper
                   AND ttl.nrdconta = vr_tab_contas(idx).nrdconta
                   AND ttl.idseqttl = vr_tab_contas(idx).idseqttl;
                  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel atualizar empresa onde titular trabalha:'||SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF;
            
          --> 10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
          ELSIF vr_tab_contas(idx).tprelacao IN (10) THEN

            BEGIN          
              UPDATE crapavt avt
                 SET avt.nmdavali = pr_pessoa_new.nmpessoa
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND avt.nrcpfcgc = vr_tab_contas(idx).idseqttl
                 AND avt.nmdavali = nvl(pr_pessoa_old.nmpessoa,
                                        pr_pessoa_new.nmpessoa)
                 AND avt.tpctrato = 5
                 AND nvl(avt.nrdctato ,0) = 0;    
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          --> 20-Representante de uma PJ (crapavt onde tpctato = 6)
          ELSIF vr_tab_contas(idx).tprelacao IN (20) THEN

            BEGIN          
              UPDATE crapavt avt
                 SET avt.nmdavali = pr_pessoa_new.nmpessoa,
                     avt.nrcpfcgc = pr_pessoa_new.nrcpfcgc
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND (nvl(avt.nrcpfcgc,0) = nvl(nvl(pr_pessoa_old.nrcpfcgc,
                                                   pr_pessoa_new.nrcpfcgc),0)
                     OR --> CPF/CPNJ devem estar iguais ou o nome
                     avt.nmdavali = nvl(pr_pessoa_old.nmpessoa,
                                        pr_pessoa_new.nmpessoa))
                 AND avt.tpctrato = 6
                 AND nvl(avt.nrdctato ,0) = 0;    
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;  
          --> 23-Pai do Representante (crapavt onde tpctato = 6)
          --> 24-Mae do Representante (crapavt onde tpctato = 6)
          ELSIF vr_tab_contas(idx).tprelacao IN (23,24) THEN

            BEGIN          
              UPDATE crapavt avt
                 SET avt.nmpaicto = decode(vr_tab_contas(idx).tprelacao,23,
                                                                        pr_pessoa_new.nmpessoa,
                                                                        avt.nmpaicto),
                     avt.nmmaecto = decode(vr_tab_contas(idx).tprelacao,24,
                                                                        pr_pessoa_new.nmpessoa,
                                                                        avt.nmmaecto)
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND nvl(avt.nrcpfcgc,0) = nvl(nvl(pr_pessoa_old.nrcpfcgc,
                                                   pr_pessoa_new.nrcpfcgc),0)
                 AND avt.nmdavali = nvl(pr_pessoa_old.nmpessoa,
                                        pr_pessoa_new.nmpessoa)
                 AND avt.tpctrato IN (5,6)
                 AND nvl(avt.nrdctato ,0) = 0;    
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar pai/mae do avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;             
          --> 30-Responsavel Legal (crapcrl)
          ELSIF vr_tab_contas(idx).tprelacao IN (30) THEN
            BEGIN
              UPDATE crapcrl crl
                 SET crl.nmrespon = pr_pessoa_new.nmpessoa,
                     crl.nrcpfcgc = pr_pessoa_new.nrcpfcgc
               WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                 AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                 AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                 --> Pessoa anterior
                 AND crl.nrcpfcgc = nvl(nvl(pr_pessoa_old.nrcpfcgc,
                                            pr_pessoa_new.nrcpfcgc),0)
                 AND crl.nmrespon = nvl(pr_pessoa_old.nmpessoa,
                                        pr_pessoa_new.nmpessoa);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar responsavel legal: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;   
          --> 33-Pai do Responsavel Legal (crapcrl)
          --> 34-Mae do Responsavel Legal (crapcrl)
          ELSIF vr_tab_contas(idx).tprelacao IN (33,34) THEN
            BEGIN
              UPDATE crapcrl crl
                 SET crl.nmpairsp = decode(vr_tab_contas(idx).tprelacao,33,
                                                                       pr_pessoa_new.nmpessoa,
                                                                       crl.nmpairsp),
                     crl.nmmaersp = decode(vr_tab_contas(idx).tprelacao,34,
                                                                       pr_pessoa_new.nmpessoa,
                                                                       crl.nmmaersp)
               WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                 AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                 AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                 --> Pessoa anterior
                 AND crl.nrcpfcgc = nvl(nvl(pr_pessoa_old.nrcpfcgc,
                                            pr_pessoa_new.nrcpfcgc),0)
                 AND crl.nmrespon = nvl(pr_pessoa_old.nmpessoa,
                                        pr_pessoa_new.nmpessoa);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar pai/mae do responsavel legal: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;
                     
          --> 40-Dependente (crapdep)
          ELSIF vr_tab_contas(idx).tprelacao IN (40) THEN
            --> Realizar alteração  
            BEGIN
              UPDATE crapdep dep
                 SET dep.nmdepend = pr_pessoa_new.nmpessoa               
               WHERE dep.cdcooper = vr_tab_contas(idx).cdcooper
                 AND dep.nrdconta = vr_tab_contas(idx).nrdconta
                 --> Pessoa anterior
                 AND dep.nmdepend = nvl(pr_pessoa_old.nmpessoa,
                                        pr_pessoa_new.nmpessoa);
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar dependente: '||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
          
          --> 50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
          --> 51-Empresa do Politico Exposto (tbcadast_politico_exposto)
          ELSIF vr_tab_contas(idx).tprelacao IN (50,51) THEN
            --> Realizar alteração  
            BEGIN
              UPDATE tbcadast_politico_exposto pol
                 SET pol.nmempresa        = decode(pr_pessoa_new.tppessoa,2 ,pr_pessoa_new.nmpessoa,pol.nmempresa     ),
                     pol.nrcnpj_empresa   = decode(pr_pessoa_new.tppessoa,2 ,pr_pessoa_new.nrcpfcgc,pol.nrcnpj_empresa),
                     pol.nmpolitico       = decode(pr_pessoa_new.tppessoa,1 ,pr_pessoa_new.nmpessoa,pol.nmpolitico    ),
                     pol.nrcpf_politico   = decode(pr_pessoa_new.tppessoa,1 ,pr_pessoa_new.nrcpfcgc,pol.nrcpf_politico)
               WHERE pol.cdcooper   = vr_tab_contas(idx).cdcooper
                 AND pol.nrdconta   = vr_tab_contas(idx).nrdconta
                 AND pol.idseqttl   = vr_tab_contas(idx).idseqttl;
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar politicamente exposto:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
          
          --> 60-Empresa de Participacao (PJ) (crapepa)
          ELSIF vr_tab_contas(idx).tprelacao IN (60) THEN
            --> Realizar alteração  
            BEGIN              
              
              UPDATE crapepa epa
                 SET epa.nmprimtl = substr(pr_pessoa_new.nmpessoa,1,40),
                     epa.nrdocsoc = pr_pessoa_new.nrcpfcgc
               WHERE epa.cdcooper = vr_tab_contas(idx).cdcooper
                 AND epa.nrdconta = vr_tab_contas(idx).nrdconta
                 AND epa.nrdocsoc = nvl(pr_pessoa_old.nrcpfcgc,
                                        pr_pessoa_new.nrcpfcgc);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar paticipacao societaria de PJ:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
          
          END IF; --> Fim IF tprelacao
        END IF; --> Fim IF tpoperacao
    
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar pessoa: '||SQLERRM; 
  END pc_atualiza_pessoa;
  
  /*****************************************************************************/
  /**       Procedure para atualizar pessoa fisica na estrutura antiga        **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_fisica ( pr_idpessoa       IN tbcadast_pessoa.idpessoa%TYPE    --> Identificador de pessoa                            
                                       ,pr_tpoperacao     IN INTEGER                          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_pessoa_fis_old IN tbcadast_pessoa_fisica%ROWTYPE   --> Dados anteriores
                                       ,pr_pessoa_fis_new IN tbcadast_pessoa_fisica%ROWTYPE   --> Dados novos
                                       ,pr_dscritic      OUT VARCHAR2                         --> Retornar Critica 
                                       ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_pessoa_fisica
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar pessoa fisica na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro,
             est.cdpais
        FROM tbcadast_pessoa pes,
             tbcadast_pessoa_estrangeira est
       WHERE pes.idpessoa = pr_idpessoa
         AND pes.idpessoa = est.idpessoa(+);    
    rw_pessoa cr_pessoa%ROWTYPE; 
    
    -- Buscar informações da pessoa
    CURSOR cr_pessoa_estrang (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT est.cdpais,
             est.dsnaturalidade
        FROM tbcadast_pessoa_estrangeira est
       WHERE est.idpessoa = pr_idpessoa;    
    rw_pessoa_estrang cr_pessoa_estrang%ROWTYPE; 
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas  cada0010.typ_tab_conta;
    vr_dsnatura    crapttl.dsnatura%TYPE;
    vr_cdufnatu    crapttl.cdufnatu%TYPE;
    
  BEGIN    
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;  
  
  
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> Exclusao
        IF pr_tpoperacao = 3 THEN 
          --> Tabela não permitirá exclusão
          RETURN;
        ELSE
        
          --> 1-Conjuge (crapcje)
          IF vr_tab_contas(idx).tprelacao IN (1) THEN
            BEGIN          
              UPDATE crapcje cje
                 SET cje.dtnasccj = pr_pessoa_fis_new.dtnascimento,
                     cje.tpdoccje = pr_pessoa_fis_new.tpdocumento, 
                     cje.nrdoccje = pr_pessoa_fis_new.nrdocumento, 
                     cje.idorgexp = nvl(pr_pessoa_fis_new.idorgao_expedidor,0),
                     cje.cdufdcje = nvl(pr_pessoa_fis_new.cduf_orgao_expedidor,' '),
                     cje.dtemdcje = pr_pessoa_fis_new.dtemissao_documento,
                     cje.grescola = pr_pessoa_fis_new.cdgrau_escolaridade,
                     cje.cdfrmttl = pr_pessoa_fis_new.cdcurso_superior,
                     cje.cdnatopc = pr_pessoa_fis_new.cdnatureza_ocupacao,
                     cje.dsproftl = pr_pessoa_fis_new.dsprofissao                    
               WHERE cje.cdcooper = vr_tab_contas(idx).cdcooper
                 AND cje.nrdconta = vr_tab_contas(idx).nrdconta
                 AND cje.idseqttl = vr_tab_contas(idx).idseqttl
                 AND nvl(cje.nrctacje,0) = 0;                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar renda do conjuge: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          
          --> 2-Empresa de trabalho do conjuge (crapcje)
          ELSIF vr_tab_contas(idx).tprelacao IN (2) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          
          --> 3-Pai (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (3) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          
          --> 4-Mae (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (4) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          
          --> 6-Titular (crapttl)  
          --> 7-Titular (crapjur)        
          ELSIF vr_tab_contas(idx).tprelacao IN (6,7) THEN                     
            
            --> 6-Titular (crapttl)          
            IF vr_tab_contas(idx).tprelacao IN (6) THEN
            
              
              IF vr_tab_contas(idx).idseqttl = 1 THEN
                --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
                --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
                IF nvl(pr_pessoa_fis_new.dtnascimento,vr_dtpadrao) <> nvl(pr_pessoa_fis_old.dtnascimento,vr_dtpadrao) OR
                   nvl(pr_pessoa_fis_new.nrdocumento,' ') <> nvl(pr_pessoa_fis_old.nrdocumento,' ') OR
                   nvl(pr_pessoa_fis_new.dtemissao_documento,trunc(SYSDATE)) <> nvl(pr_pessoa_fis_old.dtemissao_documento,trunc(SYSDATE))
                   THEN
                  BEGIN
                    UPDATE crapass ass
                       SET ass.dtnasctl = pr_pessoa_fis_new.dtnascimento,
                           ass.nrdocptl = pr_pessoa_fis_new.nrdocumento,
                           ass.dtemdptl = pr_pessoa_fis_new.dtemissao_documento
                     WHERE ass.cdcooper = vr_tab_contas(idx).cdcooper
                       AND ass.nrdconta = vr_tab_contas(idx).nrdconta;
                      
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Não foi possivel atualizar associado pessoa fisica:'||SQLERRM;
                      RAISE vr_exc_erro;
                  END;    
                END IF; 
              END IF; 
              
              IF  nvl(pr_pessoa_fis_new.cdnaturalidade,0)          <>      nvl(pr_pessoa_fis_old.cdnaturalidade,0)           OR         
                  nvl(pr_pessoa_fis_new.tpsexo,0)                  <>      nvl(pr_pessoa_fis_old.tpsexo,0)                   OR
                  nvl(pr_pessoa_fis_new.cdestado_civil,0)          <>      nvl(pr_pessoa_fis_old.cdestado_civil,0)           OR
                  nvl(pr_pessoa_fis_new.dtnascimento,vr_dtpadrao)  <>      nvl(pr_pessoa_fis_old.dtnascimento,vr_dtpadrao)   OR
                  nvl(pr_pessoa_fis_new.cdnacionalidade,0)         <>      nvl(pr_pessoa_fis_old.cdnacionalidade,0)          OR
                  nvl(pr_pessoa_fis_new.tpnacionalidade,0)         <>      nvl(pr_pessoa_fis_old.tpnacionalidade,0)          OR
                  nvl(pr_pessoa_fis_new.tpdocumento,'')            <>      nvl(pr_pessoa_fis_old.tpdocumento,'')             OR
                  nvl(pr_pessoa_fis_new.nrdocumento,'')            <>      nvl(pr_pessoa_fis_old.nrdocumento,'')             OR
                  nvl(pr_pessoa_fis_new.dtemissao_documento,vr_dtpadrao) <> nvl(pr_pessoa_fis_old.dtemissao_documento,vr_dtpadrao)  OR
                  nvl(pr_pessoa_fis_new.idorgao_expedidor,0)       <>      nvl(pr_pessoa_fis_old.idorgao_expedidor,0)        OR
                  nvl(pr_pessoa_fis_new.cduf_orgao_expedidor, ' ') <>      nvl(pr_pessoa_fis_old.cduf_orgao_expedidor, ' ')  OR
                  nvl(pr_pessoa_fis_new.inhabilitacao_menor,0)     <>      nvl(pr_pessoa_fis_old.inhabilitacao_menor,0)      OR 
                  nvl(pr_pessoa_fis_new.dthabilitacao_menor,vr_dtpadrao) <> nvl(pr_pessoa_fis_old.dthabilitacao_menor,vr_dtpadrao)  OR
                  nvl(pr_pessoa_fis_new.cdgrau_escolaridade,0)     <>      nvl(pr_pessoa_fis_old.cdgrau_escolaridade,0)      OR
                  nvl(pr_pessoa_fis_new.cdcurso_superior,0)        <>      nvl(pr_pessoa_fis_old.cdcurso_superior,0)         OR
                  nvl(pr_pessoa_fis_new.cdnatureza_ocupacao,0)     <>      nvl(pr_pessoa_fis_old.cdnatureza_ocupacao,0)      OR
                  nvl(pr_pessoa_fis_new.dsprofissao,'')            <>      nvl(pr_pessoa_fis_old.dsprofissao,'')             OR
                  nvl(pr_pessoa_fis_new.dsjustific_outros_rend,'') <>      nvl(pr_pessoa_fis_old.dsjustific_outros_rend,'') THEN     
                  
              
                --> buscar descrição da naturalidade
                IF  nvl(pr_pessoa_fis_new.cdnaturalidade,0) > 0 THEN
                  vr_dsnatura := NULL;
                  vr_cdufnatu := NULL;
                
                  CADA0014.pc_ret_desc_cidade_uf ( pr_idcidade => pr_pessoa_fis_new.cdnaturalidade,
                                                   pr_dscidade => vr_dsnatura,
                                                   pr_cdestado => vr_cdufnatu,
                                                   pr_dscritic => vr_dscritic);             
                ELSE
                  --> caso for pessoa estrangeira, deve atribuir valor da tabela de pessoa estrangeira  
                  OPEN cr_pessoa_estrang(pr_idpessoa => pr_pessoa_fis_new.idpessoa);
                  FETCH cr_pessoa_estrang INTO rw_pessoa_estrang;
                  CLOSE cr_pessoa_estrang;
              
                  IF nvl(rw_pessoa_estrang.cdpais,0) <> 0 THEN
                    vr_dsnatura := rw_pessoa_estrang.dsnaturalidade;
                    vr_cdufnatu := 'EX';
                  END IF;
                END IF;            
                
                BEGIN
                  UPDATE crapttl ttl
                     SET ttl.dsnatura = nvl(nvl(vr_dsnatura,ttl.dsnatura),' '),
                         ttl.cdufnatu = nvl(nvl(vr_cdufnatu,ttl.cdufnatu),' '),
                         ttl.cdsexotl = pr_pessoa_fis_new.tpsexo,
                         ttl.cdestcvl = nvl(pr_pessoa_fis_new.cdestado_civil,0),
                         ttl.dtnasttl = pr_pessoa_fis_new.dtnascimento,
                         ttl.cdnacion = nvl(pr_pessoa_fis_new.cdnacionalidade,0), 
                         ttl.tpnacion = pr_pessoa_fis_new.tpnacionalidade,    
                         ttl.tpdocttl = pr_pessoa_fis_new.tpdocumento,        
                         ttl.nrdocttl = pr_pessoa_fis_new.nrdocumento,        
                         ttl.dtemdttl = pr_pessoa_fis_new.dtemissao_documento,
                         ttl.idorgexp = nvl(pr_pessoa_fis_new.idorgao_expedidor,0),
                         ttl.cdufdttl = nvl(pr_pessoa_fis_new.cduf_orgao_expedidor, ' '),
                         ttl.inhabmen = pr_pessoa_fis_new.inhabilitacao_menor,
                         ttl.dthabmen = pr_pessoa_fis_new.dthabilitacao_menor,
                         ttl.grescola = nvl(pr_pessoa_fis_new.cdgrau_escolaridade,0),
                         ttl.cdfrmttl = pr_pessoa_fis_new.cdcurso_superior,
                         ttl.cdnatopc = nvl(pr_pessoa_fis_new.cdnatureza_ocupacao,0),
                         ttl.dsproftl = pr_pessoa_fis_new.dsprofissao,
                         ttl.dsjusren = pr_pessoa_fis_new.dsjustific_outros_rend                   
                   WHERE ttl.cdcooper = vr_tab_contas(idx).cdcooper
                     AND ttl.nrdconta = vr_tab_contas(idx).nrdconta
                     AND ttl.idseqttl = vr_tab_contas(idx).idseqttl;
                  
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar titular:'||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF; 
            --> 7-Titular (crapjur)
            ELSIF vr_tab_contas(idx).tprelacao IN (7) THEN
              --> Nao possui nenhuma informação a ser atualizada desta estrutura
              NULL;
            END IF;
            
          --> 5-Empresa de trabalho (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (5) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
            
          --> 10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
          --> 20-Representante de uma PJ (crapavt onde tpctato = 6)
          ELSIF vr_tab_contas(idx).tprelacao IN (10,20) THEN

            --> buscar descrição da naturalidade
            IF  nvl(pr_pessoa_fis_new.cdnaturalidade,0) > 0 THEN
              vr_dsnatura := NULL;
              vr_cdufnatu := NULL;
              
              CADA0014.pc_ret_desc_cidade_uf ( pr_idcidade => pr_pessoa_fis_new.cdnaturalidade,
                                               pr_dscidade => vr_dsnatura,
                                               pr_cdestado => vr_cdufnatu,
                                               pr_dscritic => vr_dscritic);
            END IF;
              
            BEGIN          
              UPDATE crapavt avt
                 SET avt.tpdocava = pr_pessoa_fis_new.tpdocumento,
                     avt.nrdocava = pr_pessoa_fis_new.nrdocumento,
                     avt.idorgexp = nvl(pr_pessoa_fis_new.idorgao_expedidor,0),
                     avt.dtemddoc = pr_pessoa_fis_new.dtemissao_documento,
                     avt.cdufddoc = nvl(pr_pessoa_fis_new.cduf_orgao_expedidor,' '),
                     avt.dtnascto = pr_pessoa_fis_new.dtnascimento,        
                     avt.cdsexcto = pr_pessoa_fis_new.tpsexo,              
                     avt.cdestcvl = pr_pessoa_fis_new.cdestado_civil,
                     avt.inhabmen = pr_pessoa_fis_new.inhabilitacao_menor,
                     avt.dthabmen = pr_pessoa_fis_new.dthabilitacao_menor,
                     avt.cdnacion = nvl(pr_pessoa_fis_new.cdnacionalidade,0),
                     avt.dsnatura = nvl(nvl(vr_dsnatura,avt.dsnatura),' ')
               WHERE avt.cdcooper = vr_tab_contas(idx).cdcooper
                 AND avt.nrdconta = vr_tab_contas(idx).nrdconta
                 AND nvl(avt.nrcpfcgc,0) = nvl(rw_pessoa.nrcpfcgc,0)
                 AND avt.nmdavali = rw_pessoa.nmpessoa
                 AND avt.tpctrato IN (5,6)
                 AND nvl(avt.nrdctato ,0) = 0;    
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar avalista: '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          --> 23-Pai do Representante (crapavt onde tpctato = 6)
          --> 24-Mae do Representante (crapavt onde tpctato = 6)
          ELSIF vr_tab_contas(idx).tprelacao IN (23,24) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;            
          --> 30-Responsavel Legal (crapcrl)
          ELSIF vr_tab_contas(idx).tprelacao IN (30) THEN
            
            --> buscar descrição da naturalidade
            IF  nvl(pr_pessoa_fis_new.cdnaturalidade,0) > 0 THEN
              vr_dsnatura := NULL;
              vr_cdufnatu := NULL;
              
              CADA0014.pc_ret_desc_cidade_uf ( pr_idcidade => pr_pessoa_fis_new.cdnaturalidade,
                                               pr_dscidade => vr_dsnatura,
                                               pr_cdestado => vr_cdufnatu,
                                               pr_dscritic => vr_dscritic);
            END IF;
            
            BEGIN
              UPDATE crapcrl crl
                 SET crl.idorgexp = nvl(pr_pessoa_fis_new.idorgao_expedidor,0),
                     crl.cdufiden = nvl(pr_pessoa_fis_new.cduf_orgao_expedidor,' '),
                     crl.dtemiden = pr_pessoa_fis_new.dtemissao_documento,
                     crl.dtnascin = pr_pessoa_fis_new.dtnascimento,       
                     crl.cddosexo = pr_pessoa_fis_new.tpsexo,             
                     crl.cdestciv = pr_pessoa_fis_new.cdestado_civil,
                     crl.nridenti = pr_pessoa_fis_new.nrdocumento,
                     crl.tpdeiden = pr_pessoa_fis_new.tpdocumento,
                     crl.cdnacion = nvl(pr_pessoa_fis_new.cdnacionalidade,0),
                     crl.dsnatura = nvl(nvl(vr_dsnatura,crl.dsnatura),' ')
               WHERE crl.cdcooper = vr_tab_contas(idx).cdcooper
                 AND crl.nrctamen = vr_tab_contas(idx).nrdconta
                 AND crl.idseqmen = vr_tab_contas(idx).idseqttl
                 AND crl.nrcpfcgc = nvl(rw_pessoa.nrcpfcgc,0)
                 AND crl.nmrespon = rw_pessoa.nmpessoa;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar responsavel legal: '||SQLERRM; 
                RAISE vr_exc_erro;
            END;   
            
          --> 33-Pai do Responsavel Legal (crapcrl)
          --> 34-Mae do Responsavel Legal (crapcrl)
          ELSIF vr_tab_contas(idx).tprelacao IN (33,34) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL; 
                     
          --> 40-Dependente (crapdep)
          ELSIF vr_tab_contas(idx).tprelacao IN (40) THEN
            --> Realizar alteração  
            BEGIN
              UPDATE crapdep dep
                 SET dep.dtnascto = pr_pessoa_fis_new.dtnascimento
               WHERE dep.cdcooper = vr_tab_contas(idx).cdcooper
                 AND dep.nrdconta = vr_tab_contas(idx).nrdconta
                 AND dep.nmdepend = rw_pessoa.nmpessoa;
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar dependente: '||SQLERRM; 
                RAISE vr_exc_erro;          
            END;
          
          --> 50-Pessoa politicamente Exposta (tbcadast_politico_exposto)          
          ELSIF vr_tab_contas(idx).tprelacao IN (50) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          --> 51-Empresa do Politico Exposto (tbcadast_politico_exposto)
          ELSIF vr_tab_contas(idx).tprelacao IN (51) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          --> 60-Empresa de Participacao (PJ) (crapepa)
          ELSIF vr_tab_contas(idx).tprelacao IN (60) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;          
          END IF; --> Fim IF tprelacao
        END IF; --> Fim IF tpoperacao
    
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar pessoa fisica: '||SQLERRM; 
  END pc_atualiza_pessoa_fisica;
  
  /*****************************************************************************/
  /**       Procedure para atualizar pessoa juridica na estrutura antiga      **/
  /*****************************************************************************/
  PROCEDURE pc_atualiza_pessoa_juridica ( pr_idpessoa       IN tbcadast_pessoa.idpessoa%TYPE    --> Identificador de pessoa                            
                                         ,pr_tpoperacao     IN INTEGER                          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                         ,pr_pessoa_jur_old IN tbcadast_pessoa_juridica%ROWTYPE --> Dados anteriores
                                         ,pr_pessoa_jur_new IN tbcadast_pessoa_juridica%ROWTYPE --> Dados novos
                                         ,pr_dscritic      OUT VARCHAR2                         --> Retornar Critica 
                                        ) IS   
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_pessoa_juridica
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar pessoa juridica na estrutura antiga
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar informações da pessoa
    CURSOR cr_pessoa (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE)IS
      SELECT pes.nrcpfcgc,
             pes.nmpessoa,
             pes.tpcadastro
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;    
    rw_pessoa cr_pessoa%ROWTYPE; 
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION; 
    
    vr_tab_contas  cada0010.typ_tab_conta;
    
    
  BEGIN    
  
    -- Buscar informações da pessoa
    OPEN cr_pessoa (pr_idpessoa => pr_idpessoa );
    FETCH cr_pessoa INTO rw_pessoa; 
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;      
      vr_dscritic := 'Pessoa não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_pessoa;
    END IF;  
  
  
    -- Buscar a relacao da pessoa com demais pessoas
    CADA0010.pc_busca_relacao_conta( pr_idpessoa  => pr_idpessoa,
                                     pr_conta     => vr_tab_contas,
                                     pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
    */
    
    IF vr_tab_contas.count() > 0 THEN
      FOR idx IN vr_tab_contas.first..vr_tab_contas.last LOOP
      
        --> Exclusao
        IF pr_tpoperacao = 3 THEN 
          --> Tabela não permitirá exclusão
          RETURN;
        ELSE
        
          --> 1-Conjuge (crapcje)
          IF vr_tab_contas(idx).tprelacao IN (1) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;                                
          --> 2-Empresa de trabalho do conjuge (crapcje)
          ELSIF vr_tab_contas(idx).tprelacao IN (2) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;                                          
          --> 3-Pai (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (3) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;          
          --> 4-Mae (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (4) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;          
          --> 6-Titular (crapttl)  
          --> 7-Titular (crapjur)        
          ELSIF vr_tab_contas(idx).tprelacao IN (6,7) THEN                     
           
            --> 6-Titular (crapttl)          
            IF vr_tab_contas(idx).tprelacao IN (6) THEN
              --> Nao possui nenhuma informação a ser atualizada desta estrutura
              NULL;                                
              
            --> 7-Titular (crapjur)
            ELSIF vr_tab_contas(idx).tprelacao IN (7) THEN  
              --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
              --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
              IF nvl(pr_pessoa_jur_new.cdcnae,0)                       <> nvl(pr_pessoa_jur_old.cdcnae,0) OR
                 nvl(pr_pessoa_jur_new.dtinicio_atividade,vr_dtpadrao) <> nvl(pr_pessoa_jur_old.dtinicio_atividade,vr_dtpadrao) THEN
                --> Atualizar dados associado
                BEGIN
                  UPDATE crapass ass
                     SET ass.cdclcnae = nvl(pr_pessoa_jur_new.cdcnae,0),
                         ass.dtnasctl = pr_pessoa_jur_new.dtinicio_atividade
                   WHERE ass.cdcooper = vr_tab_contas(idx).cdcooper
                     AND ass.nrdconta = vr_tab_contas(idx).nrdconta;
                    
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar associado:'||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;
              
              --> Validar se foi alterado alguma informação desta tabela, para garantir que nao seja sobreposto
              --> alguma informação que ainda nao foi processada, devido a ordem de execução da tabela
              IF nvl(pr_pessoa_jur_new.nmfantasia,' ')                      <> nvl(pr_pessoa_jur_old.nmfantasia,' ')                     OR               
                 nvl(pr_pessoa_jur_new.nrinscricao_estadual,0)              <> nvl(pr_pessoa_jur_old.nrinscricao_estadual,0)             OR
                 nvl(pr_pessoa_jur_new.cdnatureza_juridica,0)               <> nvl(pr_pessoa_jur_old.cdnatureza_juridica,0)              OR
                 nvl(pr_pessoa_jur_new.dtinicio_atividade,vr_dtpadrao)      <> nvl(pr_pessoa_jur_old.dtinicio_atividade,vr_dtpadrao)     OR
                 nvl(pr_pessoa_jur_new.qtfilial,0)                          <> nvl(pr_pessoa_jur_old.qtfilial,0)                         OR
                 nvl(pr_pessoa_jur_new.qtfuncionario,0)                     <> nvl(pr_pessoa_jur_old.qtfuncionario,0)                    OR
                 nvl(pr_pessoa_jur_new.vlcapital,0)                         <> nvl(pr_pessoa_jur_old.vlcapital,0)                        OR
                 nvl(pr_pessoa_jur_new.dtregistro,vr_dtpadrao)              <> nvl(pr_pessoa_jur_old.dtregistro,vr_dtpadrao)             OR
                 nvl(pr_pessoa_jur_new.nrregistro,0)                        <> nvl(pr_pessoa_jur_old.nrregistro,0)                       OR
                 nvl(pr_pessoa_jur_new.dtinscricao_municipal,vr_dtpadrao)   <> nvl(pr_pessoa_jur_old.dtinscricao_municipal,vr_dtpadrao)  OR
                 nvl(pr_pessoa_jur_new.nrnire,0)                            <> nvl(pr_pessoa_jur_old.nrnire,0)                           OR
                 nvl(pr_pessoa_jur_new.inrefis,0)                           <> nvl(pr_pessoa_jur_old.inrefis,0)                          OR          
                 nvl(pr_pessoa_jur_new.dssite,' ')                          <> nvl(pr_pessoa_jur_old.dssite,' ')                         OR
                 nvl(pr_pessoa_jur_new.nrinscricao_municipal,0)             <> nvl(pr_pessoa_jur_old.nrinscricao_municipal,0)            OR          
                 nvl(pr_pessoa_jur_new.cdsetor_economico,0)                 <> nvl(pr_pessoa_jur_old.cdsetor_economico,0)                OR
                 nvl(pr_pessoa_jur_new.vlfaturamento_anual,0)               <> nvl(pr_pessoa_jur_old.vlfaturamento_anual,0)              OR
                 nvl(pr_pessoa_jur_new.cdramo_atividade,0)                  <> nvl(pr_pessoa_jur_old.cdramo_atividade,0)                 OR
                 nvl(pr_pessoa_jur_new.nrlicenca_ambiental,0)               <> nvl(pr_pessoa_jur_old.nrlicenca_ambiental,0)              OR
                 nvl(pr_pessoa_jur_new.dtvalidade_licenca_amb,vr_dtpadrao)  <> nvl(pr_pessoa_jur_old.dtvalidade_licenca_amb,vr_dtpadrao) OR
                 nvl(pr_pessoa_jur_new.dsorgao_registro,' ')                <> nvl(pr_pessoa_jur_old.dsorgao_registro,' ')               OR
                 nvl(pr_pessoa_jur_new.tpregime_tributacao,0)               <> nvl(pr_pessoa_jur_old.tpregime_tributacao,0)              THEN
              
  
                --> Atualizar dados pessoa juridica
                BEGIN
                  UPDATE crapjur jur
                     SET jur.nmfansia = pr_pessoa_jur_new.nmfantasia
                        ,jur.nrinsest = pr_pessoa_jur_new.nrinscricao_estadual
                        ,jur.natjurid = pr_pessoa_jur_new.cdnatureza_juridica
                        ,jur.dtiniatv = pr_pessoa_jur_new.dtinicio_atividade
                        ,jur.qtfilial = pr_pessoa_jur_new.qtfilial          
                        ,jur.qtfuncio = pr_pessoa_jur_new.qtfuncionario     
                        ,jur.vlcaprea = pr_pessoa_jur_new.vlcapital         
                        ,jur.dtregemp = pr_pessoa_jur_new.dtregistro        
                        ,jur.nrregemp = pr_pessoa_jur_new.nrregistro   
                        ,jur.dtinsnum = pr_pessoa_jur_new.dtinscricao_municipal
                        ,jur.nrcdnire = pr_pessoa_jur_new.nrnire               
                        ,jur.flgrefis = pr_pessoa_jur_new.inrefis              
                        ,jur.dsendweb = pr_pessoa_jur_new.dssite               
                        ,jur.nrinsmun = pr_pessoa_jur_new.nrinscricao_municipal
                        ,jur.cdseteco = pr_pessoa_jur_new.cdsetor_economico    
                        ,jur.vlfatano = pr_pessoa_jur_new.vlfaturamento_anual  
                        ,jur.cdrmativ = pr_pessoa_jur_new.cdramo_atividade         
                        ,jur.nrlicamb = pr_pessoa_jur_new.nrlicenca_ambiental  
                        ,jur.dtvallic = pr_pessoa_jur_new.dtvalidade_licenca_amb       
                        ,jur.orregemp = pr_pessoa_jur_new.dsorgao_registro                 
                        ,jur.tpregtrb = nvl(pr_pessoa_jur_new.tpregime_tributacao,0)
                   WHERE jur.cdcooper = vr_tab_contas(idx).cdcooper
                     AND jur.nrdconta = vr_tab_contas(idx).nrdconta;
                  
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar pessoa juridica:'||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;
              
              --> Realizar alteração dados financeiros  
              BEGIN                            
                UPDATE crapjfn jfn
                   SET jfn.perfatcl = pr_pessoa_jur_new.peunico_cliente                       
                 WHERE jfn.cdcooper   = vr_tab_contas(idx).cdcooper
                   AND jfn.nrdconta   = vr_tab_contas(idx).nrdconta;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar resultados financeiros de PJ:'||SQLERRM; 
                  RAISE vr_exc_erro;          
              END;
              
            END IF;
            
          --> 5-Empresa de trabalho (crapttl)
          ELSIF vr_tab_contas(idx).tprelacao IN (5) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
            
          --> 10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
          --> 20-Representante de uma PJ (crapavt onde tpctato = 6)
          ELSIF vr_tab_contas(idx).tprelacao IN (10,20) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL; 
            
          --> 23-Pai do Representante (crapavt onde tpctato = 6)
          --> 24-Mae do Representante (crapavt onde tpctato = 6)
          ELSIF vr_tab_contas(idx).tprelacao IN (23,24) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;            
            
          --> 30-Responsavel Legal (crapcrl)
          ELSIF vr_tab_contas(idx).tprelacao IN (30) THEN            
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL; 
            
          --> 33-Pai do Responsavel Legal (crapcrl)
          --> 34-Mae do Responsavel Legal (crapcrl)
          ELSIF vr_tab_contas(idx).tprelacao IN (33,34) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL; 
                     
          --> 40-Dependente (crapdep)
          ELSIF vr_tab_contas(idx).tprelacao IN (40) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          
          --> 50-Pessoa politicamente Exposta (tbcadast_politico_exposto)          
          ELSIF vr_tab_contas(idx).tprelacao IN (50) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          --> 51-Empresa do Politico Exposto (tbcadast_politico_exposto)
          ELSIF vr_tab_contas(idx).tprelacao IN (51) THEN
            --> Nao possui nenhuma informação a ser atualizada desta estrutura
            NULL;
          --> 60-Empresa de Participacao (PJ) (crapepa)
          ELSIF vr_tab_contas(idx).tprelacao IN (60) THEN
            --> Realizar alteração  
            BEGIN              
              
              UPDATE crapepa epa
                 SET epa.nmfansia = pr_pessoa_jur_new.nmfantasia,
                     epa.nrinsest = pr_pessoa_jur_new.nrinscricao_estadual,
                     epa.natjurid = nvl(pr_pessoa_jur_new.cdnatureza_juridica,0),
                     epa.dtiniatv = pr_pessoa_jur_new.dtinicio_atividade,
                     epa.qtfilial = pr_pessoa_jur_new.qtfilial,
                     epa.qtfuncio = pr_pessoa_jur_new.qtfuncionario,
                     epa.dsendweb = pr_pessoa_jur_new.dssite,
                     epa.cdseteco = pr_pessoa_jur_new.cdsetor_economico,
                     epa.cdrmativ = pr_pessoa_jur_new.cdramo_atividade  
               WHERE epa.cdcooper = vr_tab_contas(idx).cdcooper
                 AND epa.nrdconta = vr_tab_contas(idx).nrdconta
                 AND epa.nrdocsoc = nvl(rw_pessoa.nrcpfcgc,0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar paticipacao societaria de PJ:'||SQLERRM; 
                RAISE vr_exc_erro;          
            END;          
          END IF; --> Fim IF tprelacao
        END IF; --> Fim IF tpoperacao
    
      END LOOP; --> Fim Looop vr_tab_contas
    END IF; --> Fim IF  vr_tab_contas.count
    
    --> Atualizar a data de alteração, para posicionar que essa pessoa teve alguma alteração cadastral
    pc_atlz_dtaltera_pessoa( pr_idpessoa => pr_idpessoa   --> Identificador de pessoa
                            ,pr_dscritic => pr_dscritic); --> Retornar Critica 

    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar pessoa juridica: '||SQLERRM; 
  END pc_atualiza_pessoa_juridica;
  
END CADA0016;
/
