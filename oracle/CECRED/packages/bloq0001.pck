CREATE OR REPLACE PACKAGE CECRED.BLOQ0001 AS

  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0148.p
    Autor   : Lucas Lunelli
    Data    : Janeiro/2013                Ultima Atualizacao: 14/05/2014.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela BLQRGT
                 
    Alteracoes: 02/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
    
                06/03/2014 - Incluso VALIDATE (Daniel).
                
                14/05/2014 - Conversão PROGRESS para ORACLE (Adriano).

                20/10/2014 - Implementado novo parametro pr_inprodut na procedure
                             pc_busca_blqrgt (Jean Michel)
  .............................................................................*/
  
  FUNCTION fn_valor_bloqueio_garantia (pr_idcobert IN NUMBER) RETURN NUMBER;
  
  PROCEDURE pc_busca_blqrgt(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                           ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                           ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                           ,pr_tpaplica IN craprda.tpaplica%TYPE --> Tipo da aplicação
                           ,pr_nraplica IN craprda.nraplica%TYPE --> Número da aplicação
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_inprodut IN VARCHAR2              --> Identificador de produto (A= Antigo / N=Novo)
                           ,pr_flgstapl OUT INTEGER              --> Status da aplicação
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                           ,pr_dscritic OUT crapcri.dscritic%TYPE);
                           
  PROCEDURE pc_valida_blqrgt(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                            ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                            ,pr_tpaplica IN craprda.tpaplica%TYPE --> Tipo da aplicação
                            ,pr_nraplica IN craprda.nraplica%TYPE --> Número da aplicação
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                            ,pr_inoperac IN INTEGER              -->  1=Bloqueio/2=Lib
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                            ,pr_dscritic OUT crapcri.dscritic%TYPE);                           
                           
  PROCEDURE pc_valida_conta(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                           ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                           ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                           ,pr_dsdconta OUT VARCHAR2             --> Nome do titular
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                           ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Retorno de erro                              
                           
                           
  PROCEDURE pc_valida_bloqueio_garantia (pr_vlropera          IN NUMBER
                                        ,pr_permingar         IN NUMBER
                                        ,pr_resgate_libera    IN NUMBER
                                        ,pr_tpctrato          IN NUMBER
                                        ,pr_inaplica_propria  IN NUMBER
                                        ,pr_vlaplica_propria  IN NUMBER
                                        ,pr_inpoupa_propria   IN NUMBER
                                        ,pr_vlpoupa_propria   IN NUMBER
                                        ,pr_resgate_automa    IN NUMBER
                                        ,pr_inaplica_terceiro IN NUMBER
                                        ,pr_vlaplica_terceiro IN NUMBER
                                        ,pr_inpoupa_terceiro  IN NUMBER
                                        ,pr_vlpoupa_terceiro  IN NUMBER
                                        ,pr_dscritic         OUT crapcri.dscritic%TYPE); --> Retorno de erro
                                        
  PROCEDURE pc_revalida_bloqueio_garantia (pr_idcobert  IN NUMBER
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Retorno de erro
                                          
  PROCEDURE pc_retorna_bloqueio_garantia (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                                         ,pr_tpctrato IN NUMBER
                                         ,pr_nrctaliq IN VARCHAR2 -- Conta em que o contrato está em liquidação
                                         ,pr_dsctrliq IN VARCHAR2 -- Lista separada em “;”
                                         ,pr_vlbloque_aplica OUT NUMBER
                                         ,pr_vlbloque_poupa OUT NUMBER
                                         ,pr_vlbloque_ambos OUT NUMBER
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Retorno de erro
  
  PROCEDURE pc_retorna_saldos_conta (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_tpctrato IN NUMBER
                                    ,pr_nrctaliq IN VARCHAR2 -- Conta em que o contrato está em liquidação
                                    ,pr_dsctrliq IN VARCHAR2 -- Lista de contratos separados por “;” a liquidar com a contratação deste;
                                    ,pr_vlsaldo_aplica OUT NUMBER 
                                    ,pr_vlsaldo_poupa  OUT NUMBER
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Retorno de erro
                                         
  PROCEDURE pc_bloq_desbloq_cob_operacao (pr_idcobertura           IN NUMBER
                                         ,pr_inbloq_desbloq        IN VARCHAR2 --> B - Bloquear / D - Desbloquear;
                                         ,pr_cdoperador            IN VARCHAR2 DEFAULT ''
                                         ,pr_cdcoordenador_desbloq IN VARCHAR2 DEFAULT ''
                                         ,pr_vldesbloq             IN NUMBER DEFAULT 0
                                         ,pr_flgerar_log           IN VARCHAR2
                                         ,pr_dscritic             OUT crapcri.dscritic%TYPE); --> Retorno de erro   
                                         
  PROCEDURE pc_bloqueio_garantia_atualizad (pr_idcobert             IN NUMBER
                                           ,pr_vlroriginal         OUT NUMBER
                                           ,pr_vlratualizado       OUT NUMBER
                                           ,pr_nrcpfcnpj_cobertura OUT NUMBER
                                           ,pr_dscritic            OUT crapcri.dscritic%TYPE);
  
  PROCEDURE pc_calc_bloqueio_garantia (pr_cdcooper        IN  NUMBER
                                      ,pr_nrdconta        IN  NUMBER
                                      ,pr_tpctrato        IN  NUMBER DEFAULT 0
                                      ,pr_nrctaliq        IN  VARCHAR2 DEFAULT 0 -- Conta em que o contrato está em liquidação;
                                      ,pr_dsctrliq        IN  VARCHAR2 DEFAULT 0 -- Lista de contratos separados por ";" a liquidar com a contratação deste;
                                      ,pr_vlsldapl        IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                                      ,pr_vlblqapl        IN  NUMBER DEFAULT 0
                                      ,pr_vlsldpou        IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                                      ,pr_vlblqpou        IN  NUMBER DEFAULT 0
                                      ,pr_vlbloque_aplica OUT NUMBER
                                      ,pr_vlbloque_poupa  OUT NUMBER
                                      ,pr_dscritic        OUT VARCHAR2);
  
  --> Chamada ayllosweb da rotina pc_calc_bloqueio_garantia
  PROCEDURE pc_calc_bloq_garantia_web 
                            ( pr_nrdconta IN  NUMBER
                             ,pr_tpctrato IN  NUMBER DEFAULT 0
                             ,pr_nrctaliq IN  VARCHAR2 DEFAULT 0 -- Conta em que o contrato está em liquidação;
                             ,pr_dsctrliq IN  VARCHAR2 DEFAULT 0 -- Lista de contratos separados por ";" a liquidar com a contratação deste;
                             ,pr_vlsldapl IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                             ,pr_vlblqapl IN  NUMBER DEFAULT 0
                             ,pr_vlsldpou IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                             ,pr_vlblqpou IN  NUMBER DEFAULT 0
                             ,pr_xmllog   IN  VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);        --> Erros do processo                                      
  
  PROCEDURE pc_vincula_cobertura_operacao(pr_idcobertura_anterior IN NUMBER DEFAULT 0
                                         ,pr_idcobertura_nova     IN NUMBER
                                         ,pr_nrcontrato           IN NUMBER
                                         ,pr_dscritic            OUT VARCHAR2);
END BLOQ0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.BLOQ0001 AS

  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0148.p
    Autor   : Lucas Lunelli
    Data    : Janeiro/2013                Ultima Atualizacao: 20/10/2014.
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela BLQRGT
                 
    Alteracoes: 02/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
    
                06/03/2014 - Incluso VALIDATE (Daniel).
                
                14/05/2014 - Conversão PROGRESS para ORACLE (Adriano).

                20/10/2014 - Implementado novo parametro pr_inprodut na procedure
                             pc_busca_blqrgt (Jean Michel)
  .............................................................................*/
  
  /* Retornar valor do bloqueio para a cobertura da operação repassada. */
  FUNCTION fn_valor_bloqueio_garantia (pr_idcobert IN NUMBER) RETURN NUMBER IS
  /* ..........................................................................

   Programa: fn_valor_bloqueio_garantia
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lombardi
   Data    : Novembro/2017                            Ultima alteracao:

   Dados referentes ao programa:

   Frequencia: Quando for Chamado
   Objetivo  : Retornar o valor total do bloqueio para a cobertura da operação repassada.

   Alteracoes: 

  ............................................................................. */
  BEGIN
    DECLARE
      vr_cdcooper NUMBER := 0;
      vr_nrdconta NUMBER := 0;
      vr_tpcontrato NUMBER := 0;
      vr_nrcontrato NUMBER := 0;
      vr_perminimo NUMBER := 0;
      vr_vldesbloq NUMBER := 0;
      vr_inaplicacao_propria NUMBER := 0;
      vr_inpoupanca_propria NUMBER := 0;
      vr_inaplicacao_terceiro NUMBER := 0;
      vr_inpoupanca_terceiro NUMBER := 0;
      vr_valopera NUMBER := 0;
      vr_vlcobert NUMBER := 0;
      
      CURSOR cr_cobertura IS
        SELECT cdcooper
              ,nrdconta
              ,tpcontrato
              ,nrcontrato
              ,perminimo
              ,inaplicacao_propria
              ,inpoupanca_propria
              ,inaplicacao_terceiro
              ,inpoupanca_terceiro
              ,vldesbloq
          FROM tbgar_cobertura_operacao
         WHERE idcobertura = pr_idcobert
           AND insituacao = 1; -- Bloqueado
       rw_cobertura cr_cobertura%ROWTYPE;
       
       CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                        ,pr_nrdconta IN crapepr.nrdconta%TYPE
                        ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT wpr.vlemprst
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;
      
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT lim.vllimite
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrctrlim
           AND lim.tpctrlim = pr_tpctrlim;
      rw_craplim cr_craplim%ROWTYPE;
      
       
    BEGIN
      
      OPEN cr_cobertura;
      FETCH cr_cobertura INTO rw_cobertura;
      IF cr_cobertura%FOUND THEN
        vr_cdcooper             := rw_cobertura.cdcooper;
        vr_nrdconta             := rw_cobertura.nrdconta;
        vr_tpcontrato           := rw_cobertura.tpcontrato;
        vr_nrcontrato           := rw_cobertura.nrcontrato;
        vr_perminimo            := rw_cobertura.perminimo;
        vr_inaplicacao_propria  := rw_cobertura.inaplicacao_propria;
        vr_inpoupanca_propria   := rw_cobertura.inpoupanca_propria;
        vr_inaplicacao_terceiro := rw_cobertura.inaplicacao_terceiro;
        vr_inpoupanca_terceiro  := rw_cobertura.inpoupanca_terceiro;
        vr_vldesbloq            := rw_cobertura.vldesbloq;
      END IF;
      
      IF vr_inaplicacao_propria + vr_inpoupanca_propria + vr_inaplicacao_terceiro + vr_inpoupanca_terceiro > 0 THEN
        -- Buscar as informações da operação conforme o tipo do contrato
        IF vr_tpcontrato = 90 THEN
          -- Buscar empréstimo
          OPEN cr_crawepr(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => vr_nrdconta
                         ,pr_nrctremp => vr_nrcontrato);
          FETCH cr_crawepr INTO rw_crawepr;
          
          vr_valopera := rw_crawepr.vlemprst;
          
        ELSE
          -- Buscar limite
          OPEN cr_craplim(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => vr_nrdconta
                         ,pr_nrctrlim => vr_nrcontrato
                         ,pr_tpctrlim => vr_tpcontrato);
          FETCH cr_craplim INTO rw_craplim;
          
          vr_valopera := rw_craplim.vllimite;
        END IF;
        -- Calcular o valor necessário para cobertura do empréstimo ou do limite
        vr_vlcobert := vr_valopera * (vr_perminimo / 100);

        -- Descontar possíveis valores de Desbloqueio
        vr_vlcobert := vr_vlcobert - NVL(vr_vldesbloq,0);
      END IF;
      
      IF vr_vlcobert > 0 THEN
        RETURN(vr_vlcobert);
      ELSE
        RETURN(vr_vlcobert);
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END;
  
  
  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0148.p
    Autor   : Adriano
    Data    : Maio/2014                    Ultima Atualizacao: 07/06/2016.
     
    Dados referentes ao programa:
   
    Objetivo  : Buscar os dados da tela BLQRGT   
                 
    Alteracoes: 14/05/2014 - Conversão PROGRESS para ORACLE (Adriano).

                20/10/2014 - Implementado novo parametro pr_inprodut na procedure
                             pc_busca_blqrgt (Jean Michel)

                07/06/2016 - Ajustado o cursor que verifica se a aplicacao esta bloqueada 
                             para resgate utilizando o indice da tabela craptab
                             (Douglas - Chamado 454248)
  .............................................................................*/
  PROCEDURE pc_busca_blqrgt(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                           ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                           ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                           ,pr_tpaplica IN craprda.tpaplica%TYPE --> Tipo da aplicação
                           ,pr_nraplica IN craprda.nraplica%TYPE --> Número da aplicação
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_inprodut IN VARCHAR2              --> Identificador de produto (A= Antigo / N=Novo)
                           ,pr_flgstapl OUT INTEGER              --> Status da aplicação
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                           ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro   
                           
  BEGIN                          
    DECLARE
    
      -- Cursor para veririca se a aplicação está bloqueada para resgate
      CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN VARCHAR
                       ,pr_nraplica IN INTEGER) IS
      SELECT tab.cdcooper
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND UPPER(tab.nmsistem) = 'CRED'
         AND UPPER(tab.tptabela) = 'BLQRGT'
         AND tab.cdempres = 00
         AND UPPER(tab.cdacesso) = pr_nrdconta
         AND TO_NUMBER(substr(tab.dstextab,1,7)) = pr_nraplica;
      rw_craptab cr_craptab%ROWTYPE;
      
      -- Cursor para veririca se a aplicação nova está bloqueada para resgate
      CURSOR cr_craprac(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN craprac.nrdconta%TYPE
                       ,pr_nraplica IN craprac.nraplica%TYPE) IS
      SELECT rac.cdcooper
        FROM craprac rac
       WHERE rac.cdcooper = pr_cdcooper
         AND rac.nrdconta = pr_nrdconta
         AND rac.nraplica = pr_nraplica
         AND rac.idblqrgt = 0;
      rw_craprac cr_craprac%ROWTYPE;
      
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
          
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
                 
    BEGIN      
    
      pc_valida_blqrgt(pr_cdcooper => pr_cdcooper
                      ,pr_cdagenci => pr_cdagenci
                      ,pr_nrdcaixa => pr_nrdcaixa
                      ,pr_cdoperad => pr_cdoperad
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpaplica => pr_tpaplica
                      ,pr_nraplica => pr_nraplica
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_inoperac => 0
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
                            
      IF vr_cdcritic IS NOT NULL OR
         vr_dscritic IS NOT NULL THEN
      
        -- Gera exceção
        RAISE vr_exc_erro;
         
      END IF;                               
      
      -- Verifica tipo de produto (A = Antigo / N = Novo)
      IF pr_inprodut = 'A' THEN
        -- Verifica se a aplicação está bloqueada para resgate
        OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => GENE0002.fn_mask(pr_nrdconta,'9999999999')
                       ,pr_nraplica => pr_nraplica);
                       
        FETCH cr_craptab INTO rw_craptab;

        IF cr_craptab%FOUND THEN
          -- Fecha o cursor
          CLOSE cr_craptab;
          
          -- Aplicação não liberada para resgate
          pr_flgstapl := 0;
          
        ELSE
          -- Fecha o cursor
          CLOSE cr_craptab;
          
          -- Aplicação liberada para resgate
          pr_flgstapl := 1; 
        
        END IF;
      ELSIF pr_inprodut = 'N' THEN
        -- Verifica se a aplicação está bloqueada para resgate
        OPEN cr_craprac(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => GENE0002.fn_mask(pr_nrdconta,'9999999999')
                       ,pr_nraplica => pr_nraplica);
                       
        FETCH cr_craprac INTO rw_craprac;

        IF cr_craprac%FOUND THEN
          -- Fecha o cursor
          CLOSE cr_craprac;
          
          -- Aplicação não liberada para resgate
          pr_flgstapl := 0;
          
        ELSE
          -- Fecha o cursor
          CLOSE cr_craprac;
          
          -- Aplicação liberada para resgate
          pr_flgstapl := 1; 
        
        END IF;      
      END IF;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_cdcritic :=  NULL;
        pr_dscritic := 'Erro na BLOQ0001.pc_busca_blqrgt --> '|| SQLERRM;
          
    
    END;
    
  END pc_busca_blqrgt;
    
  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0148.p
    Autor   : Adriano
    Data    : Maio/2014                    Ultima Atualizacao: 30/11/2017.
     
    Dados referentes ao programa:
   
    Objetivo  : Validar os dados da tela BLQRGT    
                 
    Alteracoes: 14/05/2014 - Conversão PROGRESS para ORACLE (Adriano).
    
                30/11/2017 - Removido chamada da pc_valida_bloqueio_judicial
                             pois não existe mais o acionamento desta rotina 
                             para criação de Bloqueio.
                             PRJ404-Garantia(Odirlei-AMcom)
  .............................................................................*/
  PROCEDURE pc_valida_blqrgt(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                            ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                            ,pr_tpaplica IN craprda.tpaplica%TYPE --> Tipo da aplicação
                            ,pr_nraplica IN craprda.nraplica%TYPE --> Número da aplicação
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                            ,pr_inoperac IN INTEGER              -->  1=Bloqueio/2=Lib
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                            ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro   
                           
  BEGIN                          
    DECLARE
    
      -- Cursor para encontrar o registro de poupanca programada
      CURSOR cr_craprpp(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE) IS
      SELECT rpp.cdcooper
        FROM craprpp rpp
       WHERE rpp.cdcooper = pr_cdcooper
         AND rpp.nrdconta = pr_nrdconta
         AND rpp.nrctrrpp = pr_nraplica;
      rw_craprpp cr_craprpp%ROWTYPE;
       
      -- Cursor para bucar o tipo da aplicacao
      CURSOR cr_crapdtc(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_tpaplica IN crapdtc.tpaplica%TYPE) IS
      SELECT dtc.tpaplrdc
            ,dtc.vlmaxapl
            ,dtc.vlminapl
        FROM crapdtc dtc
       WHERE dtc.cdcooper = pr_cdcooper 
         AND dtc.flgstrdc = 1    -- Captacao liberada
         AND (dtc.tpaplrdc = 1   --Pre 
          OR  dtc.tpaplrdc = 2 ) -- Pos
         AND dtc.tpaplica = pr_tpaplica;
      rw_crapdtc cr_crapdtc%ROWTYPE;
      
      -- Cursor para encontrar o registro da aplicação
      CURSOR cr_craprda(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nraplica IN craprda.nraplica%TYPE
                       ,pr_tpaplica IN craprda.tpaplica%TYPE) IS
      SELECT rda.cdcooper
        FROM craprda rda
       WHERE rda.cdcooper = pr_cdcooper
         AND rda.nrdconta = pr_nrdconta
         AND rda.nraplica = pr_nraplica
         AND rda.tpaplica = pr_tpaplica;
      rw_craprda cr_craprda%ROWTYPE;
      
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
          
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Armazena o nome do titular
      vr_dsdconta VARCHAR2(60);
                 
    BEGIN      
    
      pc_valida_conta(pr_cdcooper => pr_cdcooper
                     ,pr_cdagenci => pr_cdagenci
                     ,pr_nrdcaixa => pr_nrdcaixa
                     ,pr_cdoperad => pr_cdoperad
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dsdconta => vr_dsdconta
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);
                      
      IF vr_cdcritic IS NOT NULL OR
         vr_dscritic IS NOT NULL THEN
      
        -- Gera exceção
        RAISE vr_exc_erro;
         
      END IF;                   
      
      IF pr_tpaplica = 1 THEN
        
        -- Busca o registro de poupanca programada
        OPEN cr_craprpp(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrrpp => pr_nraplica);
                       
        FETCH cr_craprpp INTO rw_craprpp;
        
        IF cr_craprpp%NOTFOUND THEN
          
          -- Fecha o cursor
          CLOSE cr_craprpp;
          
          -- Monta a mensagem de critica
          vr_cdcritic := 426;
          vr_dscritic := NULL;
          
          -- Gera exceção
          RAISE vr_exc_erro;
          
        ELSE
          
          -- Fecha cursor
          CLOSE cr_craprpp;
          
        END IF;               
      
      ELSE
        
        IF pr_tpaplica <> 3 AND
           pr_tpaplica <> 5 THEN
           
          -- Busca o registro da aplicação
          OPEN cr_crapdtc(pr_cdcooper => pr_cdcooper
                         ,pr_tpaplica => pr_tpaplica);  
                         
          FETCH cr_crapdtc INTO rw_crapdtc;
          
          IF cr_crapdtc%NOTFOUND THEN
            
            -- Fecha o cursor
            CLOSE cr_crapdtc;
            
            -- Monta a mensagem de critica
            vr_cdcritic := 346;
            vr_dscritic := NULL;
            
            -- Gera exceção
            RAISE vr_exc_erro;
          ELSE
            
            -- Fecha o cursor
            CLOSE cr_crapdtc;
            
          END IF;  
          
          -- Encontra o registro  da aplicação
          OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta 
                         ,pr_nraplica => pr_nraplica
                         ,pr_tpaplica => pr_tpaplica);
                         
          FETCH cr_craprda INTO rw_craprda;
          
          IF cr_craprda%NOTFOUND THEN
            
            -- Fecha o cursor
            CLOSE cr_craprda;
            
            -- Monta mensagem de erro
            vr_cdcritic := 426;
            vr_dscritic := NULL;
            
            -- Gera exceção
            RAISE vr_exc_erro;
            
          ELSE
            -- Fecha o cursor
            CLOSE cr_craprda;
          END IF;               
          
        END IF;
        
      END IF;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_cdcritic :=  NULL;
        pr_dscritic := 'Erro na BLOQ0001.pc_valida_blqrgt --> '|| SQLERRM;
          
    
    END;
    
  END pc_valida_blqrgt;    

  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0148.p
    Autor   : Adriano
    Data    : Maio/2014                    Ultima Atualizacao: 14/05/2014.
     
    Dados referentes ao programa:
   
    Objetivo  : Validar existencia da Conta/dv     
                 
    Alteracoes: 14/05/2014 - Conversão PROGRESS para ORACLE (Adriano).
  .............................................................................*/    
  PROCEDURE pc_valida_conta(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                           ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                           ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                           ,pr_dsdconta OUT VARCHAR2             --> Nome do titular
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                           ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro   
                           
  BEGIN                          
    DECLARE
    
      -- Encontra registro do associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE 
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Encontra registro do titular
      CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE 
                       ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT ttl.nmextTtl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1; --Primeiro titular
         
      -- Encontra registro da conta juridica
      CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE 
                       ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT jur.nrdconta
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
       
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
          
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
                 
    BEGIN      
    
      -- Busca o registro da conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
                     
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        
        -- Fecha o cursor
        CLOSE cr_crapass;
        
        -- Monta a critica
        vr_cdcritic := 9;
        vr_dscritic := NULL;
        
        -- Gera exceção
        RAISE vr_exc_erro;
        
      ELSE
        
        -- Fecha o cursor
        CLOSE cr_crapass; 
      
      END IF;
      
      -- Pessoa fisica
      IF rw_crapass.inpessoa = 1 THEN
       
        -- Encontra o registro do titular 
        OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta); 
                       
        FETCH cr_crapttl INTO pr_dsdconta;
        
        IF cr_crapttl%NOTFOUND THEN

          -- Fecha o cursor
          CLOSE cr_crapttl;
          
          -- Monta mensagem de critica
          vr_cdcritic := 9;
          vr_dscritic := NULL;
          
          -- Gera exceção
          RAISE vr_exc_erro;
                    
        ELSE
          
          -- Fecha o cursor
          CLOSE cr_crapttl;
        
        END IF;               
      
      ELSE -- Pessoa juridica
               
        -- Busca o registro de conta juridica
        OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);        
                       
        FETCH cr_crapass INTO pr_dsdconta;
        
        IF cr_crapjur%NOTFOUND THEN
          
          -- Fecha o cursor
          CLOSE cr_crapjur;
          
          -- Monta mensagem de critica
          vr_cdcritic := 9;
          vr_dscritic := NULL;
          
          -- Gera exceção 
          RAISE vr_exc_erro;
        ELSE
          
          -- Fecha o cursor
          CLOSE cr_crapjur;
        
        END IF;
      
      END IF;
      
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_cdcritic :=  NULL;
        pr_dscritic := 'Erro na BLOQ0001.pc_valida_conta --> '|| SQLERRM;
          
    
    END;
    
  END pc_valida_conta;    
  
  PROCEDURE pc_valida_bloqueio_garantia (pr_vlropera          IN NUMBER
                                        ,pr_permingar         IN NUMBER
                                        ,pr_resgate_libera    IN NUMBER
                                        ,pr_tpctrato          IN NUMBER
                                        ,pr_inaplica_propria  IN NUMBER
                                        ,pr_vlaplica_propria  IN NUMBER
                                        ,pr_inpoupa_propria   IN NUMBER
                                        ,pr_vlpoupa_propria   IN NUMBER
                                        ,pr_resgate_automa    IN NUMBER
                                        ,pr_inaplica_terceiro IN NUMBER
                                        ,pr_vlaplica_terceiro IN NUMBER
                                        ,pr_inpoupa_terceiro  IN NUMBER
                                        ,pr_vlpoupa_terceiro  IN NUMBER
                                        ,pr_dscritic         OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro
  /*.............................................................................

    Programa: PC_BLOQ_DESBLOQ_COB_OPERACAO
    Autor   : Lombardi
    Data    : Outubro/2017                    Ultima Atualizacao: --/--/----.
     
    Dados referentes ao programa:
   
    Objetivo  :  Verificar se o bloqueio configurado possui saldo suficiente para 
                 a cobertura da operação.
                 
    Alteracoes: 30/11/2017 - Removido rotina pc_valida_bloqueio_judicial,
                             pois não é mais utilizada.
                             PRJ404-Garantia aplic.(Odirlei-AMcom)
  .............................................................................*/
  
  BEGIN                          
    DECLARE
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_vlgarnec NUMBER := 0;
      vr_valor_selecionado NUMBER := 0;
      vr_inresgate_liberado NUMBER := 0; /* Buscar se a coop tem */
                 
    BEGIN      
          
      vr_vlgarnec := pr_vlropera * (pr_permingar / 100);
      
      IF pr_inaplica_propria = 1 THEN
        vr_valor_selecionado := vr_valor_selecionado + pr_vlaplica_propria;
      END IF;
      
      IF pr_inpoupa_propria = 1 THEN
        vr_valor_selecionado := vr_valor_selecionado + pr_vlpoupa_propria;
      END IF;
      
      IF pr_inaplica_terceiro = 1 THEN
        vr_valor_selecionado := vr_valor_selecionado + pr_vlaplica_terceiro;
      END IF;
      
      IF pr_inpoupa_terceiro = 1 THEN
        vr_valor_selecionado := vr_valor_selecionado + pr_vlpoupa_terceiro;
      END IF;
      
      IF pr_inaplica_propria = 0 AND pr_inpoupa_propria = 0 AND pr_resgate_automa = 1 THEN
          vr_dscritic := 'Resgate Automático só pode ser selecionado para Aplicação ou Poup. Programada Própria!';
          RAISE vr_exc_erro;
      END IF;
      
      -- Validar se a Cooperativa não possue mais Resgate Automático:
      IF pr_resgate_libera = 0 AND pr_resgate_automa = 1 THEN 
        vr_dscritic := 'Resgate Automático não está mais liberado na Cooperativa, favor rever a cobertura da operação!';
        RAISE vr_exc_erro;
      END IF;
      
      -- Somente caso a linha de crédito seja específica de aplicação
      IF pr_tpctrato = 4 AND vr_vlgarnec > vr_valor_selecionado THEN 
        vr_dscritic := 'Valor da garantia não é suficiente!';
        RAISE vr_exc_erro;
      END IF;
      
      -- Para linha de crédito que não seja específica de aplicação, 
      -- se foi selecionado pelo menos uma opção, deve haver cobertura da operação também:
      IF pr_tpctrato <> 4 AND (pr_inaplica_propria + pr_inpoupa_propria+ pr_inaplica_terceiro + pr_inpoupa_terceiro) > 0 AND
         vr_vlgarnec  > vr_valor_selecionado THEN
        vr_dscritic := 'Valor da garantia sugerida não é suficiente!';
        RAISE vr_exc_erro;
      END IF;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_dscritic := 'Erro na BLOQ0001.pc_valida_bloqueio_garantia --> '|| SQLERRM;
        
    END;
    
  END pc_valida_bloqueio_garantia;
  
  PROCEDURE pc_revalida_bloqueio_garantia (pr_idcobert  IN NUMBER
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro
  /*.............................................................................

    Programa: PC_BLOQ_DESBLOQ_COB_OPERACAO
    Autor   : Lombardi
    Data    : Outubro/2017                    Ultima Atualizacao: --/--/----.
     
    Dados referentes ao programa:
   
    Objetivo  :  Re-Verificar se o bloqueio configurado possui saldo suficiente para a cobertura da operação. 
                 Esta rotina irá buscar as informações da cobertura cadastrada e delegar a validação para a r
                 otina pc_valida_bloqueio_garantia.
                 
    Alteracoes: 
  .............................................................................*/
  
  BEGIN                          
    DECLARE
      
      CURSOR cr_cobertura (pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT cdcooper
              ,nrdconta
              ,tpcontrato
              ,nrcontrato
              ,inresgate_automatico
              ,perminimo
              ,inaplicacao_propria
              ,inpoupanca_propria
              ,nrconta_terceiro
              ,inaplicacao_terceiro
              ,inpoupanca_terceiro
          FROM tbgar_cobertura_operacao
         WHERE idcobertura = pr_idcobert;
      rw_cobertura cr_cobertura%ROWTYPE;
      
      CURSOR cr_parame (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT inresgate_automatico
          FROM tbgar_parame_geral
         WHERE cdcooper = pr_cdcooper;
      rw_parame cr_parame%ROWTYPE;
      
      CURSOR cr_crawepr (pr_cdcooper   IN crawepr.cdcooper%TYPE
                        ,pr_nrdconta   IN crawepr.nrdconta%TYPE
                        ,pr_nrcontrato IN crawepr.nrctremp%TYPE) IS
        SELECT wpr.vlemprst
              ,lcr.tpctrato
              ,TO_CHAR(wpr.nrctrliq##1) || ',' || TO_CHAR(wpr.nrctrliq##2) || ',' ||
               TO_CHAR(wpr.nrctrliq##3) || ',' || TO_CHAR(wpr.nrctrliq##4) || ',' ||
               TO_CHAR(wpr.nrctrliq##5) || ',' || TO_CHAR(wpr.nrctrliq##6) || ',' ||
               TO_CHAR(wpr.nrctrliq##7) || ',' || TO_CHAR(wpr.nrctrliq##8) || ',' ||
               TO_CHAR(wpr.nrctrliq##9) || ',' || TO_CHAR(wpr.nrctrliq##10) dsliquid
          FROM crawepr wpr
              ,craplcr lcr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrcontrato
           AND wpr.cdcooper = lcr.cdcooper
           AND wpr.cdlcremp = lcr.cdlcremp;
      rw_crawepr cr_crawepr%ROWTYPE;
      
      CURSOR cr_craplim (pr_cdcooper   IN craplim.cdcooper%TYPE
                        ,pr_nrdconta   IN craplim.nrdconta%TYPE
                        ,pr_nrcontrato IN craplim.nrctrlim%TYPE
                        ,pr_tpcontrato IN craplim.tpctrlim%TYPE) IS
        SELECT lim.vllimite
              ,lim.cddlinha
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrcontrato
           AND lim.tpctrlim = pr_tpcontrato;
      rw_craplim cr_craplim%ROWTYPE;
      
      
      CURSOR cr_craplim2 (pr_cdcooper   IN craplim.cdcooper%TYPE
                         ,pr_nrdconta   IN craplim.nrdconta%TYPE
                         ,pr_tpcontrato IN craplim.tpctrlim%TYPE) IS
        SELECT nrctrlim
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = pr_tpcontrato
           AND craplim.insitlim = 2; /* Somente ativo*/
      rw_craplim2 cr_craplim2%ROWTYPE;
      
      CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE
                        ,pr_codlinha IN craplrt.cddlinha%TYPE) IS
        SELECT lrt.tpctrato
          FROM craplrt lrt
         WHERE lrt.cdcooper = pr_cdcooper
           AND lrt.cddlinha = pr_codlinha;
      rw_craplrt cr_craplrt%ROWTYPE;
      
      CURSOR cr_crapldc (pr_cdcooper IN craplrt.cdcooper%TYPE
                        ,pr_codlinha IN craplrt.cddlinha%TYPE) IS 
        SELECT ldc.tpctrato
          FROM crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_codlinha;
      rw_crapldc cr_crapldc%ROWTYPE;
      
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_cdcooper                NUMBER := 0;
      vr_nrdconta                NUMBER := 0;
      vr_tpcontrato              NUMBER := 0;
      vr_nrcontrato              NUMBER := 0;
      vr_perminimo               NUMBER := 0;
      vr_inresgate_automatico    NUMBER := 0;
      vr_inaplicacao_propria     NUMBER := 0;
      vr_inpoupanca_propria      NUMBER := 0;
      vr_nrconta_terceiro        NUMBER := null;
      vr_inaplicacao_terceiro    NUMBER := 0;
      vr_inpoupanca_terceiro     NUMBER := 0;
      vr_inresgat_permitido      NUMBER := 0;
      vr_valopera                NUMBER := 0;
      vr_codlinha                NUMBER := 0;
      vr_tpctrato                NUMBER := 0;
      vr_dsctrliq                VARCHAR2(1000);
      vr_vlsaldo_aplica          NUMBER := 0;
      vr_vlsaldo_poup            NUMBER := 0;
      vr_vlsaldo_aplica_terceiro NUMBER := 0;
      vr_vlsaldo_poup_terceiro   NUMBER := 0;
      
      
    BEGIN
      
      OPEN cr_cobertura(pr_idcobert);
      FETCH cr_cobertura INTO rw_cobertura;
      
      IF cr_cobertura%FOUND THEN
        vr_cdcooper             := rw_cobertura.cdcooper;
        vr_nrdconta             := rw_cobertura.nrdconta;
        vr_tpcontrato           := rw_cobertura.tpcontrato;
        vr_nrcontrato           := rw_cobertura.nrcontrato;
        vr_inresgate_automatico := rw_cobertura.inresgate_automatico;
        vr_perminimo            := rw_cobertura.perminimo;
        vr_inaplicacao_propria  := rw_cobertura.inaplicacao_propria;
        vr_inpoupanca_propria   := rw_cobertura.inpoupanca_propria;
        vr_nrconta_terceiro     := rw_cobertura.nrconta_terceiro;
        vr_inaplicacao_terceiro := rw_cobertura.inaplicacao_terceiro;
        vr_inpoupanca_terceiro  := rw_cobertura.inpoupanca_terceiro;
      ELSE
        CLOSE cr_cobertura;
        vr_dscritic := 'Cobertura não encontrada';
        RAISE vr_exc_erro;
      END IF;
      
      CLOSE cr_cobertura;
      
      -- Buscar parametros de configuracao
      OPEN cr_parame(pr_cdcooper => vr_cdcooper);
      FETCH cr_parame INTO rw_parame;
      -- Se encontrar
      IF cr_parame%FOUND THEN
        vr_inresgate_automatico := rw_parame.inresgate_automatico;
      ELSE
        CLOSE cr_parame;
        vr_dscritic := 'Parametros de configuracao das operacoes de credito com garantia não encontrados';
        RAISE vr_exc_erro;
      END IF;
      
      CLOSE cr_parame;
      
      IF vr_tpcontrato = 90 THEN
        -- Buscar da tabela de empréstimos     
        OPEN cr_crawepr (pr_cdcooper   => vr_cdcooper
                        ,pr_nrdconta   => vr_nrdconta
                        ,pr_nrcontrato => vr_nrcontrato);
        FETCH cr_crawepr INTO rw_crawepr;
        IF cr_crawepr%FOUND THEN
          vr_valopera := rw_crawepr.vlemprst;
          vr_tpctrato := rw_crawepr.tpctrato;
          vr_dsctrliq := rw_crawepr.dsliquid;
        END IF;
        CLOSE cr_crawepr;
      ELSE
        -- Buscar da tabela de limite
        OPEN cr_craplim (pr_cdcooper   => vr_cdcooper  
                        ,pr_nrdconta   => vr_nrdconta  
                        ,pr_nrcontrato => vr_nrcontrato
                        ,pr_tpcontrato => vr_tpcontrato);
        FETCH cr_craplim INTO rw_craplim;
        IF cr_craplim%FOUND THEN
          vr_valopera := rw_craplim.vllimite;
          vr_codlinha := rw_craplim.cddlinha;
        END IF;
        CLOSE cr_craplim;
        
        -- Buscar o contrato de limite atual
        OPEN cr_craplim2 (pr_cdcooper   => vr_cdcooper  
                         ,pr_nrdconta   => vr_nrdconta  
                         ,pr_tpcontrato => vr_tpcontrato);
        FETCH cr_craplim2 INTO rw_craplim2;
        IF cr_craplim2%FOUND THEN
          vr_dsctrliq := rw_craplim2.nrctrlim;
        END IF;
        CLOSE cr_craplim2;
        
        -- Buscaremos dados da linha conforme tipo de contrato:
        IF vr_tpcontrato = 1 THEN
          -- Buscar dados da linha de crédito rotativo
          OPEN cr_craplrt (pr_cdcooper   => vr_cdcooper  
                          ,pr_codlinha   => vr_codlinha);
          FETCH cr_craplrt INTO rw_craplrt;
          IF cr_craplrt%FOUND THEN
            vr_tpctrato := rw_craplrt.tpctrato;
          END IF;
          CLOSE cr_craplrt;
        ELSE
          -- Buscar dados da linha de desconto
          OPEN cr_crapldc (pr_cdcooper   => vr_cdcooper  
                          ,pr_codlinha   => vr_codlinha);
          FETCH cr_crapldc INTO rw_crapldc;
          IF cr_crapldc%FOUND THEN
            vr_tpctrato := rw_crapldc.tpctrato;
          END IF;
          CLOSE cr_crapldc;
        END IF;
        
      END IF;

      -- Buscar o saldo da conta da contratação e terceira (se houver)
      PC_RETORNA_SALDOS_CONTA(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => vr_nrdconta -- Conta Contratação
                             ,pr_tpctrato => vr_tpctrato
                             ,pr_nrctaliq => vr_nrdconta -- Conta Contratação
                             ,pr_dsctrliq => vr_dsctrliq
                             ,pr_vlsaldo_aplica => vr_vlsaldo_aplica
                             ,pr_vlsaldo_poupa  => vr_vlsaldo_poup
                             ,pr_dscritic       => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_nrconta_terceiro > 0 THEN 
        -- sub-rotina para buscar saldo disponível:
        PC_RETORNA_SALDOS_CONTA(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => vr_nrconta_terceiro -- Conta Terceiro
                               ,pr_tpctrato => vr_tpctrato
                               ,pr_nrctaliq => vr_nrdconta -- Conta Contratação
                               ,pr_dsctrliq => vr_dsctrliq
                               ,pr_vlsaldo_aplica => vr_vlsaldo_aplica_terceiro
                               ,pr_vlsaldo_poupa  => vr_vlsaldo_poup_terceiro
                               ,pr_dscritic       => vr_dscritic);
      
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
      END IF;
      END IF;      

      BLOQ0001.pc_valida_bloqueio_garantia (pr_vlropera          => vr_valopera
                                           ,pr_permingar         => vr_perminimo
                                           ,pr_resgate_libera    => vr_inresgat_permitido
                                           ,pr_tpctrato          => vr_tpctrato
                                           ,pr_inaplica_propria  => vr_inaplicacao_propria
                                           ,pr_vlaplica_propria  => vr_vlsaldo_aplica
                                           ,pr_inpoupa_propria   => vr_inpoupanca_propria
                                           ,pr_vlpoupa_propria   => vr_vlsaldo_poup
                                           ,pr_resgate_automa    => vr_inresgate_automatico
                                           ,pr_inaplica_terceiro => vr_inaplicacao_terceiro
                                           ,pr_vlaplica_terceiro => vr_vlsaldo_aplica_terceiro
                                           ,pr_inpoupa_terceiro  => vr_inpoupanca_terceiro
                                           ,pr_vlpoupa_terceiro  => vr_vlsaldo_poup_terceiro
                                           ,pr_dsCritic          => pr_dscritic);
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_dscritic := 'Erro na BLOQ0001.pc_revalida_bloqueio_garantia --> '|| SQLERRM;
        
    END;
    
  END pc_revalida_bloqueio_garantia;
  
  PROCEDURE pc_retorna_bloqueio_garantia (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                                         ,pr_tpctrato IN NUMBER
                                         ,pr_nrctaliq IN VARCHAR2 -- Conta em que o contrato está em liquidação
                                         ,pr_dsctrliq IN VARCHAR2 -- Lista separada em “;”
                                         ,pr_vlbloque_aplica OUT NUMBER
                                         ,pr_vlbloque_poupa OUT NUMBER
                                         ,pr_vlbloque_ambos OUT NUMBER
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Retorno de erro
  /*.............................................................................

    Programa: pc_retorna_bloqueio_garantia
    Autor   : Lombardi
    Data    : Outubro/2017                    Ultima Atualizacao: --/--/----.
     
    Dados referentes ao programa:
   
    Objetivo  :  Verificar se a conta repassada possui algum bloqueio de cobertura de garantia, e existindo
                 trazer o valor total a bloquear além de dizer quais modalidades devem ser bloqueadas
                 
    Alteracoes: 
  .............................................................................*/
  
  BEGIN
    DECLARE
    
      CURSOR cr_gar (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT nrdconta
              ,tpcontrato
              ,nrcontrato
              ,perminimo
              ,inaplicacao_propria
              ,inpoupanca_propria
              ,inaplicacao_terceiro
              ,inpoupanca_terceiro
              ,nrconta_terceiro
              ,vldesbloq
          FROM tbgar_cobertura_operacao
         WHERE cdcooper = pr_cdcooper /* Da conta dele ou onde estiver como terceiro */
           AND pr_nrdconta IN(nrdconta,nrconta_terceiro)
           AND insituacao = 1 /*Ativa*/;
      
      CURSOR cr_craplim (pr_nrdconta IN craplim.nrdconta%TYPE
                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                        ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
        SELECT vllimite
            FROM craplim
            WHERE craplim.cdcooper = pr_cdcooper
            AND craplim.nrdconta = pr_nrdconta -- Usada da cobertura pois a passada por ser de terceiro
            AND craplim.tpctrlim = pr_tpctrlim
            AND craplim.nrctrlim = pr_nrctrlim
            AND craplim.insitlim = 2; -- Somente ativo
      rw_craplim cr_craplim%ROWTYPE;
      
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
      vr_des_reto VARCHAR2(100);
      vr_tab_erro gene0001.typ_tab_erro;
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_split gene0002.typ_split;
      vr_vlbloque_aplica NUMBER := 0;
      vr_vlbloque_poupa NUMBER := 0;
      vr_vlbloque_ambos NUMBER := 0;
      vr_dstextab craptab.dstextab%TYPE;
      vr_inusatab BOOLEAN;
      vr_vlendivi NUMBER := 0;
      vr_vltotpre NUMBER(25,2) := 0;
      vr_qtprecal NUMBER(10) := 0;
      
      TYPE typ_vet_liquida IS TABLE OF NUMBER
           INDEX BY PLS_INTEGER;     
      vr_vet_liquida typ_vet_liquida;
      
    BEGIN
      
      vr_vet_liquida.delete;
      vr_split := gene0002.fn_quebra_string(pr_string => pr_dsctrliq
                                                 ,pr_delimit => ';');
      
      --> Carregar temptable como os numeros de contrato
      IF vr_split.count > 0 THEN
        FOR i IN vr_split.first..vr_split.last LOOP
          vr_vet_liquida(vr_split(i)) := vr_split(i);        
        END LOOP;        
      END IF;
      
      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      -- Se a primeira posição do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
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
      
      FOR rw_gar IN cr_gar(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta) LOOP
        
        IF rw_gar.tpcontrato = pr_tpctrato          AND
           rw_gar.nrdconta = pr_nrctaliq            AND 
           vr_vet_liquida.exists(rw_gar.nrcontrato) THEN
          -- Continuar ao próximo registro, pois este será liquidade e não deve compor o saldo devedor.
          continue;
        END IF;
        
        IF rw_gar.tpcontrato = 90 THEN
          -- Buscar saldo devedor
          EMPR0001.pc_saldo_devedor_epr (pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_cdagenci => 1 --> Codigo da agencia
                                        ,pr_nrdcaixa => 0 --> Numero do caixa
                                        ,pr_cdoperad => '1' --> Codigo do operador
                                        ,pr_nmdatela => 'ATENDA' --> Nome datela conectada
                                        ,pr_idorigem => 1 /*Ayllos*/ --> Indicador da origem da chamada
                                        ,pr_nrdconta => rw_gar.nrdconta --> Conta do associado
                                        ,pr_idseqttl => 1 --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat --> Vetor com dados de parametro (CRAPDAT)
                                        ,pr_nrctremp => rw_gar.nrcontrato --> Numero contrato emprestimo
                                        ,pr_cdprogra => 'B1WGEN0001' --> Programa conectado
                                        ,pr_inusatab => vr_inusatab --> Indicador de utilizacão da tabela
                                        ,pr_flgerlog => 'N' --> Gerar log S/N
                                        ,pr_vlsdeved => vr_vlendivi --> Saldo devedor calculado
                                        ,pr_vltotpre => vr_vltotpre --> Valor total das prestacães
                                        ,pr_qtprecal => vr_qtprecal --> Parcelas calculadas
                                        ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
          IF vr_des_reto = 'NOK' THEN
            -- Extrair o codigo e critica de erro da tabela de erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;-- Limpar tabela de erros
            vr_tab_erro.DELETE;
            RAISE vr_exc_erro;
          END IF;
        ELSE
          -- Buscar o valor do limite:
          OPEN cr_craplim (pr_nrdconta => rw_gar.nrdconta
                          ,pr_tpctrlim => rw_gar.tpcontrato
                          ,pr_nrctrlim => rw_gar.nrcontrato);
          FETCH cr_craplim INTO rw_craplim;
          
          IF cr_craplim%FOUND THEN
            vr_vlendivi := rw_craplim.vllimite;
          END IF;
          CLOSE cr_craplim;
        END IF;
        
        -- Aplicar o percentual mínimo de garantia
        vr_vlendivi := vr_vlendivi * (rw_gar.perminimo / 100);
        
        -- Remover possíveis valores de Desbloqueio
        vr_vlendivi := nvl(vr_vlendivi,0) - nvl(rw_gar.vldesbloq,0);
        
        -- Acumular aos valores a bloquear conforme configuração de seleção:
        IF rw_gar.nrdconta = pr_nrdconta THEN
          -- Observar os campos de seleção de aplicação própria
          IF rw_gar.inaplicacao_propria = 1 AND rw_gar.inpoupanca_propria = 1 THEN 
            -- Acumular campo ambos
            vr_vlbloque_ambos := vr_vlbloque_ambos + vr_vlendivi ;
          ELSIF rw_gar.inaplicacao_propria = 1 THEN 
            -- Acumular campo aplica
            vr_vlbloque_aplica := vr_vlbloque_aplica + vr_vlendivi ;
          ELSIF rw_gar.inpoupanca_propria = 1 THEN 
            -- Acumular campo Poupança
            vr_vlbloque_poupa := vr_vlbloque_poupa + vr_vlendivi ;
          END IF;
        END IF;
        
        IF rw_gar.nrconta_terceiro = pr_nrdconta THEN
          -- Observar os campos de seleção de aplicação terceiro
          IF rw_gar.inaplicacao_terceiro = 1 AND rw_gar.inpoupanca_terceiro = 1 THEN 
            -- Acumular campo ambos
            vr_vlbloque_ambos := vr_vlbloque_ambos + vr_vlendivi ;
          ELSIF rw_gar.inaplicacao_terceiro = 1 THEN 
            -- Acumular campo aplica
            vr_vlbloque_aplica := vr_vlbloque_aplica + vr_vlendivi;
          ELSIF rw_gar.inpoupanca_terceiro = 1 THEN 
            -- Acumular campo Poupança
            vr_vlbloque_poupa := vr_vlbloque_poupa + vr_vlendivi;
          END IF;
        END IF;
        
      END LOOP;
      
      pr_vlbloque_aplica := vr_vlbloque_aplica;
      pr_vlbloque_poupa  := vr_vlbloque_poupa;
      pr_vlbloque_ambos  := vr_vlbloque_ambos;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        IF vr_cdcritic > 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_dscritic := 'Erro ao verificar valores de Bloqueio para Poupança e Aplicação da conta, detalhes --> '|| SQLERRM;
    END;
    
  END pc_retorna_bloqueio_garantia;
  
  PROCEDURE pc_retorna_saldos_conta (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_tpctrato IN NUMBER
                                    ,pr_nrctaliq IN VARCHAR2 -- Conta em que o contrato está em liquidação
                                    ,pr_dsctrliq IN VARCHAR2 -- Lista de contratos separados por “;” a liquidar com a contratação deste;
                                    ,pr_vlsaldo_aplica OUT NUMBER 
                                    ,pr_vlsaldo_poupa  OUT NUMBER
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Retorno de erro
  /*.............................................................................

    Programa: pc_retorna_saldos_conta
    Autor   : Lombardi
    Data    : Outubro/2017                    Ultima Atualizacao: --/--/----.
     
    Dados referentes ao programa:
   
    Objetivo  :  Calcular saldos disponíveis para bloqueio na conta repassada.
                 
    Alteracoes: 
  .............................................................................*/
  
  BEGIN                          
    DECLARE
      
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_nrdconta IN craprac.cdcooper%TYPE) IS
        SELECT rac.cdoperad
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.cdprodut
              ,rac.idblqrgt
          FROM craprac rac
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.idsaqtot = 0;
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_tab_conta_bloq  APLI0001.typ_tab_ctablq;
      vr_tab_craplpp     APLI0001.typ_tab_craplpp;
      vr_tab_craplrg     APLI0001.typ_tab_craplpp;
      vr_tab_resgate     APLI0001.typ_tab_resgate;
      vr_tab_dados_rpp   APLI0001.typ_tab_dados_rpp;
      vr_saldo_rdca      APLI0001.typ_tab_saldo_rdca;
      vr_index_dados_rpp PLS_INTEGER;
      vr_vlblqjud_apli   NUMBER := 0;
      vr_vlresblq_apli   NUMBER := 0;
      vr_vlblqjud_poup   NUMBER := 0;
      vr_vlresblq_poup   NUMBER := 0;
      vr_vlbloque_aplica NUMBER := 0;
      vr_vlbloque_poupa  NUMBER := 0;
      vr_vlbloque_ambos  NUMBER := 0;
      vr_vlsaldo_aplica  NUMBER := 0;
      vr_vlsaldo_poup    NUMBER := 0;
      vr_vlsldtot        NUMBER := 0;
      vr_vlsldrgt        NUMBER := 0;
      vr_percenir        NUMBER := 0;
      
    BEGIN
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
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
      
      -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
      vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                           ,pr_nmsistem => 'CRED'
                                                                           ,pr_tptabela => 'CONFIG'
                                                                           ,pr_cdempres => 0
                                                                           ,pr_cdacesso => 'PERCIRAPLI'
                                                                           ,pr_tpregist => 0));
      
      -- Consulta o saldo RDCA
      APLI0001.pc_consulta_aplicacoes (pr_cdcooper => pr_cdcooper --> Cooperativa
                                      ,pr_cdagenci => 1 --> Codigo da agencia
                                      ,pr_nrdcaixa => 1 --> Numero do caixa
                                      ,pr_nrdconta => pr_nrdconta --> Conta do associado
                                      ,pr_nraplica => 0 --> Numero da aplicacao
                                      ,pr_tpaplica => 0 --> Tipo de aplicacao (Todas)
                                      ,pr_dtinicio => rw_crapdat.dtmvtolt --> Data de inicio da aplicacao
                                      ,pr_dtfim => rw_crapdat.dtmvtolt --> Data final da aplicacao
                                      ,pr_cdprogra => 'GAROPC' --> Codigo do programa chamador da rotina
                                      ,pr_nrorigem => 1 --> Origem da chamada da rotina
                                      ,pr_saldo_rdca => vr_saldo_rdca --> Tipo de tabela com o saldo RDCA
                                      ,pr_des_reto => vr_des_reto --> OK ou NOK
                                      ,pr_tab_erro => vr_tab_erro); --> Tabela com erros
      -- Verifica se deu erro
      IF vr_des_reto = 'NOK' THEN
        -- Tenta buscar o erro no vetor de erro
        IF vr_tab_erro.COUNT > 0 THEN
          pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          pr_dscritic := 'Retorno "NOK" na BLOQ0001.pc_consulta_aplicacoes e sem '
          || 'informação na pr_vet_erro, Conta:'|| pr_nrdconta;
        END IF;
      END IF;
      
      -- Iterar sob cada um dos registros retornados para remover bloqueadas BLQRGT
      FOR vr_ind IN 1..vr_saldo_rdca.COUNT LOOP
        IF vr_saldo_rdca(vr_ind).dssitapl <> 'BLOQUEADA' THEN
          vr_vlsaldo_aplica := vr_vlsaldo_aplica + vr_saldo_rdca(vr_ind).sldresga;
        END IF;
      END LOOP;
      
      FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP
        -- Chama procedure para buscar o saldo total de resgate
        apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper
                                          ,pr_cdoperad => '1'
                                          ,pr_nmdatela => 'crps128'
                                          ,pr_idorigem => 1,pr_nrdconta => rw_craprac.nrdconta
                                          ,pr_idseqttl => 1
                                          ,pr_nraplica => rw_craprac.nraplica
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdprodut => rw_craprac.cdprodut
                                          ,pr_idblqrgt => 1
                                          ,pr_idgerlog => 0
                                          ,pr_vlsldtot => vr_vlsldtot
                                          ,pr_vlsldrgt => vr_vlsldrgt
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        -- Se retornou algum erro
        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levanta exceção
          RAISE vr_exc_erro;
        END IF;
        -- Soma valor do saldo de resgate retornado
        vr_vlsaldo_aplica := vr_vlsaldo_aplica + vr_vlsldrgt;
      END LOOP;
      
      -- Carregar tabela de memoria de contas bloqueadas
      TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_tab_cta_bloq => vr_tab_conta_bloq);
      
      -- Buscar informações e Saldos das Poupanças Programadas:
      apli0001.pc_consulta_poupanca(pr_cdcooper => pr_cdcooper --> Cooperativa
                                   ,pr_cdagenci => 1 --> Codigo da Agencia
                                   ,pr_nrdcaixa => 1 --> Numero do caixa
                                   ,pr_cdoperad => 1 --> Codigo do Operador
                                   ,pr_idorigem => 5 --> Identificador da Origem
                                   ,pr_nrdconta => pr_nrdconta --> Nro da conta associado
                                   ,pr_idseqttl => 1 --> Identificador Sequencial
                                   ,pr_nrctrrpp => 0 --> Contrato Poupanca Programada
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Data do proximo movimento
                                   ,pr_inproces => rw_crapdat.inproces --> Indicador de processo
                                   ,pr_cdprogra => 'GAROPC' --> Nome do programa chamador
                                   ,pr_flgerlog => FALSE --> Flag erro log
                                   ,pr_percenir => vr_percenir --> % IR para Calculo Poupanca
                                   ,pr_tab_craptab => vr_tab_conta_bloq --> Tipo de tabela de Conta Bloqu
                                   ,pr_tab_craplpp => vr_tab_craplpp --> Tipo de tabela com lcto poup
                                   ,pr_tab_craplrg => vr_tab_craplrg --> Tipo de tabela com resgates
                                   ,pr_tab_resgate => vr_tab_resgate --> Tabela com valores dos resgates
                                   ,pr_vlsldrpp => vr_vlsaldo_poup --> Valor saldo poup progr
                                   ,pr_retorno => vr_des_reto --> Descricao erro/sucesso OK/NOK
                                   ,pr_tab_dados_rpp => vr_tab_dados_rpp --> Poupancas Programadas
                                   ,pr_tab_erro => vr_tab_erro); --> Saida com erros;
      
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT() > 0 THEN
          -- Retornar a descrição da Critica
          pr_dscritic := 'Erro ao verificar saldo de Poupança da Conta Terceira: '
          || vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          pr_dscritic := 'Erro ao verificar saldo de Poupança da Conta Terceira: '
          || vr_dscritic;
        END IF;
      END IF;
      
      vr_index_dados_rpp:= vr_tab_dados_rpp.FIRST;
      WHILE vr_index_dados_rpp IS NOT NULL LOOP
        -- Se aplicação bloqueada
        IF vr_tab_dados_rpp(vr_index_dados_rpp).dsblqrpp = 'Sim' THEN
          -- Decrementar do saldo
          vr_vlsaldo_poup := vr_vlsaldo_poup - vr_tab_dados_rpp(vr_index_dados_rpp).vlsdrdpp;
        END IF;
        -- Proximo Registro
        vr_index_dados_rpp:= vr_tab_dados_rpp.NEXT(vr_index_dados_rpp);
      END LOOP; --dados_rpp
      
      BLOQ0001.pc_retorna_bloqueio_garantia(pr_cdcooper        => pr_cdcooper
                                           ,pr_nrdconta        => pr_nrdconta
                                           ,pr_tpctrato        => pr_tpctrato
                                           ,pr_nrctaliq        => pr_nrctaliq /* Conta da liquidação */
                                           ,pr_dsctrliq        => pr_dsctrliq /* Contratos em liquidação */
                                           ,pr_vlbloque_aplica => vr_vlbloque_aplica
                                           ,pr_vlbloque_poupa  => vr_vlbloque_poupa 
                                           ,pr_vlbloque_ambos  => vr_vlbloque_ambos 
                                           ,pr_dscritic        => vr_dscritic);
      -- Se retornou critica
      IF vr_dscritic IS NOT NULL THEN
        -- Retornar com a critica
        pr_dscritic := 'Erro ao verificar bloqueios de garantia Conta ' || pr_nrdconta || '-->' || vr_dscritic;
      END IF;
      
      -- Verificar se há bloqueio judicial de Aplicações na conta
      gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper -- Cooperativa
                                      ,pr_nrdconta => pr_nrdconta -- Conta Corrente
                                      ,pr_nrcpfcgc => 0 /*fixo*/ -- Cpf/cnpj
                                      ,pr_cdtipmov => 1 /*bloqueio*/ -- Tipo Movimento
                                      ,pr_cdmodali => 2 /*Aplicacao*/ -- Modalidade
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Atual
                                      ,pr_vlbloque => vr_vlblqjud_apli -- Valor Bloqueado
                                      ,pr_vlresblq => vr_vlresblq_apli -- Valor Residual
                                      ,pr_dscritic => vr_dscritic); -- Critica
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        -- Retornar a critica
        pr_dscritic := 'Erro ao verificar bloqueio judicial – Retornando.';
      END IF;
      
      -- Verificar se há bloqueio judicial de Aplicações na conta
      gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper -- Cooperativa
                                      ,pr_nrdconta => pr_nrdconta -- Conta Corrente
                                      ,pr_nrcpfcgc => 0 /*fixo*/ -- Cpf/cnpj
                                      ,pr_cdtipmov => 1 /*bloqueio*/ -- Tipo Movimento
                                      ,pr_cdmodali => 2 /*Aplicacao*/ -- Modalidade
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Atual
                                      ,pr_vlbloque => vr_vlblqjud_apli -- Valor Bloqueado
                                      ,pr_vlresblq => vr_vlresblq_apli -- Valor Residual
                                      ,pr_dscritic => vr_dscritic); -- Critica
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        -- Retornar a critica
        pr_dscritic := 'Erro ao verificar bloqueio judicial – Retornando.';
      END IF;
      
      -- Verificar se há bloqueio judicial de Poupança na conta
      gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper -- Cooperativa
                                      ,pr_nrdconta => pr_nrdconta -- Conta Corrente
                                      ,pr_nrcpfcgc => 0 /*fixo*/ -- Cpf/cnpj
                                      ,pr_cdtipmov => 1 /*bloqueio*/ -- Tipo Movimento
                                      ,pr_cdmodali => 3 /*Poupança*/ -- Modalidade
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Atual
                                      ,pr_vlbloque => vr_vlblqjud_poup -- Valor Bloqueado
                                      ,pr_vlresblq => vr_vlresblq_poup -- Valor Residual
                                      ,pr_dscritic => vr_dscritic); -- Critica
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        -- Retornar a critica
        pr_dscritic := 'Erro ao verificar bloqueio judicial – Retornando.';
      END IF;
      
      -- Atualizar o saldo de Poupança Programada removendo bloqueio judicial
      vr_vlsaldo_poup := greatest(0,vr_vlsaldo_poup - vr_vlblqjud_poup);
      
      -- Atualizar o saldo de Aplicações removendo bloqueio judicial
      IF vr_vlblqjud_apli > 0 THEN
        -- Caso bloqueio superior ao saldo Aplicação
        IF vr_vlblqjud_apli > vr_vlsaldo_aplica THEN
          -- Descontar o bloqueio desta e zerar pois o bloqueio é maior que o saldo
          vr_vlblqjud_apli := vr_vlblqjud_apli - vr_vlsaldo_aplica;
          vr_vlsaldo_aplica := 0;
        ELSE
          -- Descontar do saldo o bloqueio desta e zerar o bloqueio pois o saldo é suficiente
          vr_vlsaldo_aplica := vr_vlsaldo_aplica - vr_vlblqjud_apli;
          vr_vlblqjud_apli := 0;
        END IF;
      END IF;
      
      --Verificar se há bloqueio de garantia
      
      -- Se ha valor a bloquear
      IF vr_vlbloque_aplica + vr_vlbloque_poupa + vr_vlbloque_ambos > 0 THEN
        
        -- Se deve o ocorrer bloqueio apenas de aplicação
        IF vr_vlbloque_aplica + vr_vlbloque_ambos > 0 THEN
          
          -- Se Bloqueio superior a saldo aplicações
          IF (vr_vlbloque_aplica + vr_vlbloque_ambos) >= vr_vlsaldo_aplica THEN
            
            -- Primeiro descontar o bloqueio exclusivo
            IF vr_vlbloque_aplica >= vr_vlsaldo_aplica THEN
              vr_vlbloque_aplica := vr_vlbloque_aplica - vr_vlsaldo_aplica;
            ELSE
              -- Bloqueio exclusivo totalmente atendido e saldo aplicação descontando o mesmo
              vr_vlsaldo_aplica := vr_vlsaldo_aplica - vr_vlbloque_aplica;
              vr_vlbloque_aplica := 0;
              
              -- Descontar agora do bloqueio genérico (Aplica + Poupa)
              IF vr_vlbloque_ambos >= vr_vlsaldo_aplica THEN
                vr_vlbloque_ambos := vr_vlbloque_ambos - vr_vlsaldo_aplica;
              ELSE
                -- Bloqueio genérico totalmente atendido e saldo aplicação descontando o mesmo
                vr_vlbloque_ambos := 0;
              END IF;
            END IF;
            
            -- Zerar saldo Aplica
            vr_vlsaldo_aplica := 0;
            
          ELSE
            -- Descontar do saldo o bloqueio desta e zerar o bloqueio pois o saldo é suficiente
            vr_vlsaldo_aplica := vr_vlsaldo_aplica - (vr_vlbloque_aplica + vr_vlbloque_ambos);
            vr_vlbloque_aplica := 0;
            vr_vlbloque_ambos := 0;
          END IF;
        END IF;
        
        -- Se deve ocorrer bloqueio de Poupança e ainda houver valor a bloquear
        IF vr_vlbloque_poupa + vr_vlbloque_ambos > 0 THEN
          
          -- Bloquear então a Poupança Programada
          IF vr_vlbloque_poupa + vr_vlbloque_ambos > vr_vlsaldo_poup THEN
            
            -- Primeiro descontar o bloqueio exclusivo
            IF vr_vlbloque_poupa >= vr_vlsaldo_poup THEN
              vr_vlbloque_poupa := vr_vlbloque_poupa - vr_vlsaldo_poup;
            ELSE
              -- Bloqueio exclusivo totalmente atendido e saldo aplicação descontando o mesmo
              vr_vlsaldo_poup := vr_vlsaldo_poup - vr_vlbloque_poupa;
              vr_vlbloque_poupa := 0;-- Descontar agora do bloqueio genérico (Aplica + Poupa)
              
              IF vr_vlbloque_ambos >= vr_vlsaldo_poup THEN
                vr_vlbloque_ambos := vr_vlbloque_ambos - vr_vlsaldo_poup;
              ELSE
                -- Bloqueio genérico totalmente atendido e saldo aplicação descontando o mesmo
                vr_vlbloque_ambos := 0;
              END IF;
            END IF;
            
            -- Zerar saldo Poupa
            vr_vlsaldo_poup := 0;
            
          ELSE
            -- Descontar do saldo o bloqueio desta e zerar o bloqueio pois o saldo é suficiente
            vr_vlsaldo_poup := vr_vlsaldo_poup - (vr_vlbloque_poupa + vr_vlbloque_ambos);
            vr_vlbloque_poupa := 0;
            vr_vlbloque_ambos := 0;
          END IF;
        END IF;
      END IF;
      
      -- Retornar valores calculados
      pr_vlsaldo_aplica := vr_vlsaldo_aplica;
      pr_vlsaldo_poupa  := vr_vlsaldo_poup;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_dscritic := 'Erro na BLOQ0001.pc_retorna_saldos_conta --> '|| SQLERRM;
        
    END;
    
  END pc_retorna_saldos_conta;
  
  PROCEDURE pc_bloq_desbloq_cob_operacao (pr_idcobertura           IN NUMBER
                                         ,pr_inbloq_desbloq        IN VARCHAR2 --> B - Bloquear / D - Desbloquear;
                                         ,pr_cdoperador            IN VARCHAR2 DEFAULT ''
                                         ,pr_cdcoordenador_desbloq IN VARCHAR2 DEFAULT ''
                                         ,pr_vldesbloq             IN NUMBER DEFAULT 0
                                         ,pr_flgerar_log           IN VARCHAR2
                                         ,pr_dscritic             OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro   
  /*.............................................................................

    Programa: PC_BLOQ_DESBLOQ_COB_OPERACAO
    Autor   : Lombardi
    Data    : Outubro/2017                    Ultima Atualizacao: --/--/----.
     
    Dados referentes ao programa:
   
    Objetivo  : Tratar o bloqueio e desbloqueio da garantia nas operações sendo contratadas
                 
    Alteracoes: 
  .............................................................................*/
  
  BEGIN                          
    DECLARE
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic crapcri.dscritic%TYPE := NULL;
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_cdcooper NUMBER;
      vr_nrdconta NUMBER;
      vr_nrcontrato NUMBER;
      vr_tpcontrato NUMBER;
      vr_perminimo NUMBER;
      vr_inaplicacao_propria NUMBER;
      vr_inpoupanca_propria NUMBER;
      vr_nrconta_terceiro NUMBER;
      vr_inaplicacao_terceiro NUMBER;
      vr_inpoupanca_terceiro NUMBER;
      vr_inresgate_automatico NUMBER;
      vr_des_log VARCHAR2(1000);
      vr_des_log_tipos VARCHAR2(1000);
                 
    BEGIN      
          
      IF pr_idcobertura > 0 THEN
        
        -- Somente se foi solicitado o Bloqueio
        IF pr_inbloq_desbloq = 'B' THEN
         -- Valida se há saldo suficiente para garantir o valor mínimo de cobertura da operação
         -- (se bloqueio configurado é suficiente)
         BLOQ0001.pc_revalida_bloqueio_garantia (pr_idcobert => pr_idcobertura
                                                ,pr_dscritic => vr_dscritic);
                                                 
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          BEGIN
            UPDATE tbgar_cobertura_operacao
               SET insituacao = 1
             WHERE idcobertura = pr_idcobertura
         RETURNING cdcooper
                  ,nrdconta             
                  ,nrcontrato           
                  ,tpcontrato           
                  ,perminimo         
                  ,inaplicacao_propria  
                  ,inpoupanca_propria   
                  ,nrconta_terceiro     
                  ,inaplicacao_terceiro 
                  ,inpoupanca_terceiro  
                  ,inresgate_automatico 
              INTO vr_cdcooper
                  ,vr_nrdconta
                  ,vr_nrcontrato
                  ,vr_tpcontrato
                  ,vr_perminimo
                  ,vr_inaplicacao_propria
                  ,vr_inpoupanca_propria
                  ,vr_nrconta_terceiro
                  ,vr_inaplicacao_terceiro
                  ,vr_inpoupanca_terceiro
                  ,vr_inresgate_automatico;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao Bloquear cobertura de operacao. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          
        ELSIF pr_inbloq_desbloq = 'L' THEN
          IF pr_vldesbloq = 0 THEN
            pr_dscritic := 'Valor informado para Liberação Inválido! Favor enviar valor maior que zero';
            RAISE vr_exc_erro;
          END IF;
          
          BEGIN
            UPDATE tbgar_cobertura_operacao
               SET cdoperador_desbloq = pr_cdoperador
                  ,vldesbloq = pr_vldesbloq
                  ,dtdesbloq = SYSDATE
             WHERE idcobertura = pr_idcobertura
         RETURNING cdcooper
                  ,nrdconta
                  ,nrcontrato
                  ,tpcontrato
                  ,perminimo
                  ,inaplicacao_propria
                  ,inpoupanca_propria
                  ,nrconta_terceiro
                  ,inaplicacao_terceiro
                  ,inpoupanca_terceiro
                  ,inresgate_automatico
              INTO vr_cdcooper
                  ,vr_nrdconta
                  ,vr_nrcontrato
                  ,vr_tpcontrato
                  ,vr_perminimo
                  ,vr_inaplicacao_propria
                  ,vr_inpoupanca_propria
                  ,vr_nrconta_terceiro
                  ,vr_inaplicacao_terceiro
                  ,vr_inpoupanca_terceiro
                  ,vr_inresgate_automatico;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao Liberar valor de cobertura de operacao. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        ELSE
          BEGIN
            UPDATE tbgar_cobertura_operacao
               SET insituacao = 2
                  ,cdoperador_desbloq = pr_cdoperador
                  ,vldesbloq = 0
                  ,dtdesbloq = SYSDATE
             WHERE idcobertura = pr_idcobertura
         RETURNING cdcooper
                  ,nrdconta             
                  ,nrcontrato           
                  ,tpcontrato           
                  ,perminimo
                  ,inaplicacao_propria  
                  ,inpoupanca_propria   
                  ,nrconta_terceiro     
                  ,inaplicacao_terceiro 
                  ,inpoupanca_terceiro  
                  ,inresgate_automatico 
              INTO vr_cdcooper
                  ,vr_nrdconta
                  ,vr_nrcontrato
                  ,vr_tpcontrato
                  ,vr_perminimo
                  ,vr_inaplicacao_propria
                  ,vr_inpoupanca_propria
                  ,vr_nrconta_terceiro
                  ,vr_inaplicacao_terceiro
                  ,vr_inpoupanca_terceiro
                  ,vr_inresgate_automatico;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao Desbloquear cobertura de operacao ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          
        END IF;
        
        -- Se foi solicitado a geração de LOG
        IF pr_flgerar_log = 'S' AND -- Caso foi solicitado o Bloqueio porém nenhuma opção foi selecionada
          (vr_inaplicacao_propria + vr_inaplicacao_terceiro + vr_inpoupanca_propria + vr_inpoupanca_terceiro) > 0 THEN
          
          vr_des_log := to_char(sysdate,'dd/mm/rrrr - hh24:mi:ss') ||
                        ' Operador: ' || pr_cdoperador;
          
          IF pr_inbloq_desbloq = 'B' THEN
            vr_des_log := vr_des_log || ' bloqueou: ';
            -- Se selecionado Aplica Própria
            IF vr_inaplicacao_propria = 1 THEN
              vr_des_log_tipos := vr_des_log_tipos || ' Aplicações Próprias,';
            END IF;
            -- Se selecionado Poup Própria
            IF vr_inpoupanca_propria = 1 THEN
              vr_des_log_tipos := vr_des_log_tipos || ' Poupanças Próprias,';
            END IF;
            --Se selecionado Aplicação Terc
            IF vr_inaplicacao_terceiro = 1 THEN
              vr_des_log_tipos := vr_des_log_tipos || ' Aplicações Terceiro Conta ' || vr_nrconta_terceiro || ',';
            END IF;
            -- Se selecionado Poup. Terc
            IF vr_inpoupanca_terceiro = 1 THEN
              vr_des_log_tipos := vr_des_log_tipos || ' Poupanças Terceiro Conta ' || vr_nrconta_terceiro || ',';
            END IF;
            
            vr_des_log := vr_des_log || rtrim(vr_des_log_tipos,',');
            
            -- Se há resgate automático
            IF vr_inresgate_automatico = 1 THEN
              vr_des_log := vr_des_log || ' com Resgate Automático ';
            END IF;
            
            -- Finalizar:
            vr_des_log := vr_des_log || ' para ';
          ELSE
            vr_des_log := vr_des_log || ' liberou: ';
            -- Se foi passado valor
            IF pr_vldesbloq > 0 THEN
              vr_des_log := vr_des_log || ' R$ ' || 
                            to_char(pr_vldesbloq,'fm999g999g990d00') || 
                            ' com aprovação do Coordenador ' || 
                            pr_cdcoordenador_desbloq;
            END IF;
            vr_des_log := vr_des_log || ' de ';
          END IF;
          
          -- Montar tipo da operação
          vr_des_log := vr_des_log || ' Cobertura da Operação de ' || 
                        CASE vr_tpcontrato
                          WHEN 1 THEN 'Lim. Crédito '
                          WHEN 2 THEN 'Lim. Dsct. Cheques '
                          WHEN 3 THEN 'Lim. Dsct. Títulos '
                          ELSE 'Empr.Financiamento '
                        END;
          -- Montar contrato e seus detalhes
          vr_des_log := vr_des_log || ' Na Conta ' || vr_nrdconta ||
                        ' Contrato ' || vr_nrcontrato ||
                        ' no valor de ' || vr_perminimo || '%' ||
                        ' do Saldo Devedor ou Limite Contratocase vr_tpcontrato' ||
                        CASE vr_tpcontrato
                          WHEN 1 THEN 'Lim. Crédito '
                          WHEN 2 THEN 'Lim. Dsct. Cheques '
                          WHEN 3 THEN 'Lim. Dsct. Títulos '
                          ELSE 'Empr.Financiamento '
                        END;
          -- Gerar LOG
          btch0001.pc_gera_log_batch (pr_cdcooper => vr_cdcooper
                                     ,pr_ind_tipo_log => 1
                                     ,pr_des_log => vr_des_log
                                     ,pr_flfinmsg => 'N'
                                     ,pr_nmarqlog => 'blqrgt');
        END IF;
        
      END IF;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_dscritic := 'Erro na BLOQ0001.PC_BLOQ_DESBLOQ_COB_OPERACAO --> '|| SQLERRM;
        
    END;
    
  END pc_bloq_desbloq_cob_operacao;
  
  PROCEDURE pc_bloqueio_garantia_atualizad (pr_idcobert             IN NUMBER
                                           ,pr_vlroriginal         OUT NUMBER
                                           ,pr_vlratualizado       OUT NUMBER
                                           ,pr_nrcpfcnpj_cobertura OUT NUMBER
                                           ,pr_dscritic            OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro   
  /*.............................................................................

    Programa: pc_bloqueio_garantia_atualizad
    Autor   : Lombardi
    Data    : Outubro/2017                    Ultima Atualizacao: --/--/----.
     
    Dados referentes ao programa:
   
    Objetivo  : Retornar o valor do bloqueio original, o valor atualizado, e qual é o CPF do Garantidor
                (Contratante da Operação ou Terceiro) para a cobertura da operação repassada.
                 
    Alteracoes: 
  .............................................................................*/
  
  BEGIN                          
    DECLARE
      CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT cdcooper
              ,nrdconta
              ,tpcontrato
              ,nrcontrato
              ,perminimo
              ,inaplicacao_propria
              ,inpoupanca_propria
              ,nrconta_terceiro
              ,inaplicacao_terceiro
              ,inpoupanca_terceiro
              ,vldesbloq
          FROM tbgar_cobertura_operacao
         WHERE idcobertura = pr_idcobert
           AND insituacao = 1 /*Bloqueado*/;
      rw_cobertura cr_cobertura%ROWTYPE;
      
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrcontrato IN crawepr.nrctremp%TYPE) IS
        SELECT wpr.vlemprst
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrcontrato;
      
      CURSOR cr_craplim(pr_cdcooper   IN craplim.cdcooper%TYPE
                       ,pr_nrdconta   IN craplim.nrdconta%TYPE
                       ,pr_nrcontrato IN craplim.nrctrlim%TYPE
                       ,pr_tpcontrato IN craplim.tpctrlim%TYPE) IS
        SELECT lim.vllimite
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrcontrato
           AND lim.tpctrlim = pr_tpcontrato;
      rw_craplim cr_craplim%ROWTYPE;
      
      CURSOR cr_crapass (pr_cdcooper         IN crapass.cdcooper%TYPE
                        ,pr_nrdconta         IN crapass.nrdconta%TYPE
                        ,pr_nrconta_terceiro IN crapass.nrdconta%TYPE) IS
        SELECT nrcpfcgc
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND ((pr_nrconta_terceiro > 0 AND 
                 nrdconta = pr_nrconta_terceiro)
            OR (pr_nrconta_terceiro = 0 AND  
                nrdconta = pr_nrdconta));
      rw_crapass cr_crapass%ROWTYPE;
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic crapcri.dscritic%TYPE := NULL;
      vr_des_reto VARCHAR2(3)           := '';
      vr_tab_erro GENE0001.typ_tab_erro;
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_cdcooper                        NUMBER := 0;
      vr_nrdconta                        NUMBER := 0;
      vr_tpcontrato                      NUMBER := 0;
      vr_nrcontrato                      NUMBER := 0;
      vr_perminimo                       NUMBER := 0;
      vr_inaplicacao_propria             NUMBER := 0;
      vr_inpoupanca_propria              NUMBER := 0;
      vr_nrconta_terceiro                NUMBER := 0;
      vr_inaplicacao_terceiro            NUMBER := 0;
      vr_inpoupanca_terceiro             NUMBER := 0;
      vr_vldesbloq                       NUMBER := 0;
      vr_valopera_original               NUMBER := 0;
      vr_valopera_atualizada             NUMBER := 0;
      vr_vlcobert_original               NUMBER := 0;
      vr_vlcobert_atualizada             NUMBER := 0;
      vr_nrcpfcnpj_cobertura             NUMBER := 0;
      vr_dstextab                        craptab.dstextab%TYPE;
      vr_inusatab                        BOOLEAN;
      vr_vltotpre                        NUMBER(25,2) := 0;
      vr_qtprecal                        NUMBER(10) := 0;
                 
    BEGIN      
      
      OPEN cr_cobertura(pr_idcobert);
      FETCH cr_cobertura INTO rw_cobertura;
      IF cr_cobertura%NOTFOUND THEN
        vr_dscritic := 'Erro ao buscar cobertura. ' || SQLERRM;
        RAISE vr_exc_erro;
      END IF;
      
      vr_cdcooper             := rw_cobertura.cdcooper;
      vr_nrdconta             := rw_cobertura.nrdconta;
      vr_tpcontrato           := rw_cobertura.tpcontrato;
      vr_nrcontrato           := rw_cobertura.nrcontrato;
      vr_perminimo            := rw_cobertura.perminimo;
      vr_nrconta_terceiro     := rw_cobertura.nrconta_terceiro;
      vr_inaplicacao_propria  := rw_cobertura.inaplicacao_propria;
      vr_inpoupanca_propria   := rw_cobertura.inpoupanca_propria;
      vr_inaplicacao_terceiro := rw_cobertura.inaplicacao_terceiro;
      vr_inpoupanca_terceiro  := rw_cobertura.inpoupanca_terceiro;
      vr_vldesbloq            := rw_cobertura.vldesbloq;
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
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
      
      IF (vr_inaplicacao_propria + vr_inpoupanca_propria + vr_inaplicacao_terceiro + vr_inpoupanca_terceiro) > 0 THEN
        -- Buscaremos as informações da operação conforme o tipo do contrato
        IF vr_tpcontrato = 90 THEN
          -- Buscar configurações necessárias para busca de saldo de empréstimo
          -- Verificar se usa tabela juros
          vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'USUARI'
                                                  ,pr_cdempres => 11
                                                  ,pr_cdacesso => 'TAXATABELA'
                                                  ,pr_tpregist => 0);
          -- Se a primeira posição do campo dstextab for diferente de zero
          vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';
          -- Buscar valor do contrato de empréstimo
          OPEN cr_crawepr (pr_cdcooper   => vr_cdcooper
                          ,pr_nrdconta   => vr_nrdconta
                          ,pr_nrcontrato => vr_nrcontrato);
          FETCH cr_crawepr INTO vr_valopera_original;
          IF cr_crawepr%NOTFOUND THEN
            vr_dscritic := 'Erro ao buscar valor do contrato de empréstimo. ' || SQLERRM;
            RAISE vr_exc_erro;
          END IF;
          
          -- Buscar o saldo devedor atualizado do contrato
          EMPR0001.pc_saldo_devedor_epr (pr_cdcooper => vr_cdcooper            --> Cooperativa conectada
                                        ,pr_cdagenci => 1                      --> Codigo da agencia
                                        ,pr_nrdcaixa => 0                      --> Numero do caixa
                                        ,pr_cdoperad => '1'                    --> Codigo do operador
                                        ,pr_nmdatela => 'ATENDA'               --> Nome datela conectada
                                        ,pr_idorigem => 1 /*Ayllos*/           --> Indicador da origem da chamada
                                        ,pr_nrdconta => vr_nrdconta            --> Conta do associado
                                        ,pr_idseqttl => 1                      --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => rw_crapdat           --> Vetor com dados de parametro (CRAPDAT)
                                        ,pr_nrctremp => vr_nrcontrato          --> Numero contrato emprestimo
                                        ,pr_cdprogra => 'B1WGEN0001'           --> Programa conectado
                                        ,pr_inusatab => vr_inusatab            --> Indicador de utilizacão da tabela
                                        ,pr_flgerlog => 'N'                    --> Gerar log S/N
                                        ,pr_vlsdeved => vr_valopera_atualizada --> Saldo devedor calculado
                                        ,pr_vltotpre => vr_vltotpre            --> Valor total das prestacães
                                        ,pr_qtprecal => vr_qtprecal            --> Parcelas calculadas
                                        ,pr_des_reto => vr_des_reto            --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);          --> Tabela com possives erros
          -- Se houve retorno de erro
          IF vr_des_reto = 'NOK' THEN
            -- Extrair o codigo e critica de erro da tabela de erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            -- Limpar tabela de erros
            vr_tab_erro.DELETE;
            RAISE vr_exc_erro;
          END IF;

        ELSE
          -- Buscar limite
          OPEN cr_craplim(pr_cdcooper   => vr_cdcooper
                         ,pr_nrdconta   => vr_nrdconta
                         ,pr_nrcontrato => vr_nrcontrato
                         ,pr_tpcontrato => vr_tpcontrato);
          FETCH cr_craplim INTO rw_craplim;
          IF cr_craplim%NOTFOUND THEN
            vr_dscritic := 'Erro ao buscar valor do contrato de empréstimo. ' || SQLERRM;
            RAISE vr_exc_erro;
          END IF;
          vr_valopera_original := rw_craplim.vllimite;
          vr_valopera_atualizada := rw_craplim.vllimite;
        END IF;
        
        -- Calcular o valor necessário para cobertura do empréstimo ou do limite
        vr_vlcobert_original   := vr_valopera_original  * (vr_perminimo / 100);
        vr_vlcobert_atualizada := (vr_valopera_atualizada  * (vr_perminimo / 100)) - nvl(vr_vldesbloq,0);
        
        -- Buscar no cadastro de associados o CPF/CNPJ do garantidor
        OPEN cr_crapass (pr_cdcooper         => vr_cdcooper
                        ,pr_nrdconta         => vr_nrdconta
                        ,pr_nrconta_terceiro => vr_nrconta_terceiro);
        FETCH cr_crapass INTO rw_crapass;
        
        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic := 9;
          RAISE vr_exc_erro;
        END IF;
        
        vr_nrcpfcnpj_cobertura := rw_crapass.nrcpfcgc;
        
      END IF;
      
      -- Retornar as variaveis calculadas/retornadas:
      pr_vlroriginal := vr_vlcobert_original;
      pr_vlratualizado := vr_vlcobert_atualizada;
      pr_nrcpfcnpj_cobertura := vr_nrcpfcnpj_cobertura;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        IF vr_cdcritic > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_dscritic := 'Erro na BLOQ0001.PC_BLOQ_DESBLOQ_COB_OPERACAO --> '|| SQLERRM;
        
    END;
    
  END pc_bloqueio_garantia_atualizad;
  
  PROCEDURE pc_calc_bloqueio_garantia (pr_cdcooper        IN  NUMBER
                                      ,pr_nrdconta        IN  NUMBER
                                      ,pr_tpctrato        IN  NUMBER DEFAULT 0
                                      ,pr_nrctaliq        IN  VARCHAR2 DEFAULT 0 -- Conta em que o contrato está em liquidação;
                                      ,pr_dsctrliq        IN  VARCHAR2 DEFAULT 0 -- Lista de contratos separados por ";" a liquidar com a contratação deste;
                                      ,pr_vlsldapl        IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                                      ,pr_vlblqapl        IN  NUMBER DEFAULT 0
                                      ,pr_vlsldpou        IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                                      ,pr_vlblqpou        IN  NUMBER DEFAULT 0
                                      ,pr_vlbloque_aplica OUT NUMBER
                                      ,pr_vlbloque_poupa  OUT NUMBER
                                      ,pr_dscritic        OUT VARCHAR2) IS    --> Retorno de erro   
  /*.............................................................................

    Programa: pc_calc_bloqueio_garantia
    Autor   : Lombardi
    Data    : Outubro/2017                    Ultima Atualizacao: --/--/----.
     
    Dados referentes ao programa:
   
    Objetivo  : Verificar se a conta repassada possui algum bloqueio de cobertura de garantia, e existindo
                trazer o valor total a bloquear em aplicações e em poupanças. Pode ser repassado para esta rotina o
                Saldo de Aplicações ou de Poupanças, caso a rotina chamada já tenha calculado, se não houve o cálculo
                ao passar zero a rotina irá buscar os saldos.
                 
    Alteracoes: 
  .............................................................................*/
  
  BEGIN                          
    DECLARE
      CURSOR cr_craprac(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE) IS
        SELECT rac.cdoperad
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.cdprodut
              ,rac.idblqrgt
          FROM craprac rac
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.idsaqtot = 0;
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic crapcri.dscritic%TYPE := NULL;
      vr_des_reto VARCHAR2(3)           := '';
      vr_tab_erro GENE0001.typ_tab_erro;
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_tab_conta_bloq     APLI0001.typ_tab_ctablq;
      vr_tab_craplpp        APLI0001.typ_tab_craplpp;
      vr_tab_craplrg        APLI0001.typ_tab_craplpp;
      vr_tab_resgate        APLI0001.typ_tab_resgate;
      vr_tab_dados_rpp      APLI0001.typ_tab_dados_rpp;
      vr_saldo_rdca         APLI0001.typ_tab_saldo_rdca;
      vr_index_dados_rpp    PLS_INTEGER;
      vr_vlblqjud_apli      NUMBER := 0;
      vr_vlresblq_apli      NUMBER := 0;
      vr_vlblqjud_poup      NUMBER := 0;
      vr_vlresblq_poup      NUMBER := 0;
      vr_vlbloque_aplica    NUMBER := 0;
      vr_vlbloque_poupa     NUMBER := 0;
      vr_vlbloque_ambos     NUMBER := 0;
      vr_vlsaldo_aplica     NUMBER := 0;
      vr_vlsaldo_poup       NUMBER := 0;
      vr_vlsaldo_aplica_aux NUMBER := 0;
      vr_vlsaldo_poup_aux   NUMBER := 0;
      vr_vlsldtot           NUMBER := 0;
      vr_vlsldrgt           NUMBER := 0;
      vr_percenir           NUMBER := 0;
      
    BEGIN      
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
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
      
      -- Se já recebemos o Saldo das Aplicações
      IF pr_vlsldapl > 0 THEN
        vr_vlsaldo_aplica := pr_vlsldapl;
      ELSE
        -- Consulta o saldo RDCA
        APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper         --> Cooperativa
                                       ,pr_cdagenci   => 1                   --> Codigo da agencia
                                       ,pr_nrdcaixa   => 1                   --> Numero do caixa
                                       ,pr_nrdconta   => pr_nrdconta         --> Conta do associado
                                       ,pr_nraplica   => 0                   --> Numero da aplicacao
                                       ,pr_tpaplica   => 0                   --> Tipo de aplicacao (Todas)
                                       ,pr_dtinicio   => rw_crapdat.dtmvtolt --> Data de inicio da aplicacao
                                       ,pr_dtfim      => rw_crapdat.dtmvtolt --> Data final da aplicacao
                                       ,pr_cdprogra   => 'GAROPC'            --> Codigo do programa chamador da rotina
                                       ,pr_nrorigem   => 1                   --> Origem da chamada da rotina
                                       ,pr_saldo_rdca => vr_saldo_rdca       --> Tipo de tabela com o saldo RDCA
                                       ,pr_des_reto   => vr_des_reto         --> OK ou NOK
                                       ,pr_tab_erro   => vr_tab_erro);       --> Tabela com erros
        
        -- Verifica se deu erro
        IF vr_des_reto = 'NOK' THEN
          -- Tenta buscar o erro no vetor de erro
          IF vr_tab_erro.COUNT > 0 THEN
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_dscritic := 'Retorno "NOK" na BLOQ0001.pc_consulta_aplicacoes e sem ' ||
                           'informação na pr_vet_erro, Conta:' || pr_nrdconta;
          END IF;
        END IF;
        
        -- Iterar sob cada um dos registros retornados para remover bloqueadas BLQRGT
        FOR vr_index IN 1..vr_saldo_rdca.COUNT LOOP
          IF vr_saldo_rdca(vr_index).dssitapl <> 'BLOQUEADA' THEN
            vr_vlsaldo_aplica := vr_vlsaldo_aplica + vr_saldo_rdca(vr_index).sldresga;
          END IF;
        END LOOP;
        
        -- Buscar cadastro de aplicações de captação
        FOR rw_craprac IN cr_craprac (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          
          -- Chama procedure para buscar o saldo total de resgate
          apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper
                                            ,pr_cdoperad => '1'
                                            ,pr_nmdatela => 'crps128'
                                            ,pr_idorigem => 1
                                            ,pr_nrdconta => rw_craprac.nrdconta
                                            ,pr_idseqttl => 1
                                            ,pr_nraplica => rw_craprac.nraplica
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_cdprodut => rw_craprac.cdprodut
                                            ,pr_idblqrgt => 1
                                            ,pr_idgerlog => 0
                                            ,pr_vlsldtot => vr_vlsldtot
                                            ,pr_vlsldrgt => vr_vlsldrgt
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          -- Se retornou algum erro
          IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_erro;
          END IF;
          
          -- Soma valor do saldo de resgate retornado
          vr_vlsaldo_aplica := vr_vlsaldo_aplica + vr_vlsldrgt;
          
        END LOOP;
        
      END IF;
      
      -- Se recebemos o saldo de Poupança Programada
      IF pr_vlsldpou > 0 THEN
        vr_vlsaldo_poup := pr_vlsldpou;
      ELSE
        -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
        vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                             ,pr_nmsistem => 'CRED'
                                                                             ,pr_tptabela => 'CONFIG'
                                                                             ,pr_cdempres => 0
                                                                             ,pr_cdacesso => 'PERCIRAPLI'
                                                                             ,pr_tpregist => 0));
        
        -- Carregar tabela de memoria de contas bloqueadas
        TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tab_cta_bloq => vr_tab_conta_bloq);
        
        -- Buscar informações e Saldos das Poupanças Programadas:
        apli0001.pc_consulta_poupanca(pr_cdcooper      => pr_cdcooper         --> Cooperativa
                                     ,pr_cdagenci      => 1                   --> Codigo da Agencia
                                     ,pr_nrdcaixa      => 1                   --> Numero do caixa
                                     ,pr_cdoperad      => 1                   --> Codigo do Operador
                                     ,pr_idorigem      => 5                   --> Identificador da Origem
                                     ,pr_nrdconta      => pr_nrdconta         --> Nro da conta associado
                                     ,pr_idseqttl      => 1                   --> Identificador Sequencial
                                     ,pr_nrctrrpp      => 0                   --> Contrato Poupanca Programada
                                     ,pr_dtmvtolt      => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dtmvtopr      => rw_crapdat.dtmvtopr --> Data do proximo movimento
                                     ,pr_inproces      => rw_crapdat.inproces --> Indicador de processo
                                     ,pr_cdprogra      => 'GAROPC'            --> Nome do programa chamador
                                     ,pr_flgerlog      => FALSE               --> Flag erro log
                                     ,pr_percenir      => vr_percenir         --> % IR para Calculo Poupanca
                                     ,pr_tab_craptab   => vr_tab_conta_bloq   --> Tipo de tabela de Conta Bloqu
                                     ,pr_tab_craplpp   => vr_tab_craplpp      --> Tipo de tabela com lcto poup
                                     ,pr_tab_craplrg   => vr_tab_craplrg      --> Tipo de tabela com resgates
                                     ,pr_tab_resgate   => vr_tab_resgate      --> Tabela com valores dos resgates
                                     ,pr_vlsldrpp      => vr_vlsaldo_poup     --> Valor saldo poup progr
                                     ,pr_retorno       => vr_des_reto         --> Descricao erro/sucesso OK/NOK
                                     ,pr_tab_dados_rpp => vr_tab_dados_rpp    --> Poupancas Programadas
                                     ,pr_tab_erro      => vr_tab_erro);       --> Saida com erros;
        --Se retornou erro
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.COUNT() > 0 THEN
            -- Retornar a descrição da Critica
            vr_dscritic := 'Erro ao verificar saldo de Poupança da Conta Terceira: ' || vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_dscritic := 'Erro ao verificar saldo de Poupança da Conta Terceira: ' || vr_dscritic;
          END IF;
        END IF;
        
        -- Desconsiderar aqueles que já estão bloqueados na BLQRGT
        vr_index_dados_rpp:= vr_tab_dados_rpp.FIRST;
        WHILE vr_index_dados_rpp IS NOT NULL LOOP
          -- Se aplicação bloqueada
          IF vr_tab_dados_rpp(vr_index_dados_rpp).dsblqrpp = 'Sim' THEN
            -- Decrementar do saldo
            vr_vlsaldo_poup := vr_vlsaldo_poup - vr_tab_dados_rpp(vr_index_dados_rpp).vlsdrdpp;
          END IF;
          
          -- Proximo Registro
          vr_index_dados_rpp := vr_tab_dados_rpp.NEXT(vr_index_dados_rpp);
        END LOOP; --dados_rpp
      END IF;
      
      -- Verificar se já não existe bloqueio de garantia Poupança ou Aplicações desconsiderando
      -- o bloqueio atual caso tenhamos recebido via parâmetro:
      BLOQ0001.pc_retorna_bloqueio_garantia (pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_tpctrato => pr_tpctrato
                                            ,pr_nrctaliq => pr_nrctaliq /* Conta da liquidação */
                                            ,pr_dsctrliq => pr_dsctrliq /* Contratos em liquidação */
                                            ,pr_vlbloque_aplica => vr_vlbloque_aplica
                                            ,pr_vlbloque_poupa => vr_vlbloque_poupa
                                            ,pr_vlbloque_ambos => vr_vlbloque_ambos
                                            ,pr_dscritic => vr_dscritic);
      -- Se retornou critica
      IF vr_dscritic IS NOT NULL THEN
        -- Retornar com a critica
        vr_dscritic := 'Erro ao verificar bloqueios de garantia Conta ' || pr_nrdconta || '-->'||vr_dscritic;
      END IF;
      
      -- Se já recebemos o valor de bloqueio judicial de aplicação
      IF pr_vlblqapl > 0 THEN
         vr_vlblqjud_apli := pr_vlblqapl;
      ELSE
        -- Verificar se há bloqueio judicial de Aplicações na conta
        gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper -- Cooperativa
                                        ,pr_nrdconta => pr_nrdconta -- Conta Corrente
                                        ,pr_nrcpfcgc => 0 /*fixo*/ -- Cpf/cnpj
                                        ,pr_cdtipmov => 1 /*bloqueio*/ -- Tipo Movimento
                                        ,pr_cdmodali => 2 /*Aplicacao*/ -- Modalidade
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Atual
                                        ,pr_vlbloque => vr_vlblqjud_apli -- Valor Bloqueado
                                        ,pr_vlresblq => vr_vlresblq_apli -- Valor Residual
                                        ,pr_dscritic => vr_dscritic); -- Critica
        -- Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          -- Retornar a critica
          vr_dscritic := 'Erro ao verificar bloqueio judicial – Retornando.';
        END IF;
      END IF;
      
      -- Se já recebemos o bloqueio judicial de Poupança
      IF pr_vlblqpou > 0 THEN
        vr_vlblqjud_poup := pr_vlblqpou;
      ELSE
        -- Verificar se há bloqueio judicial de Poupança na conta
        gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper -- Cooperativa
                                        ,pr_nrdconta => pr_nrdconta -- Conta Corrente
                                        ,pr_nrcpfcgc => 0 /*fixo*/ -- Cpf/cnpj
                                        ,pr_cdtipmov => 1 /*bloqueio*/ -- Tipo Movimento
                                        ,pr_cdmodali => 3 /*Poupança*/ -- Modalidade
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Atual
                                        ,pr_vlbloque => vr_vlblqjud_poup -- Valor Bloqueado
                                        ,pr_vlresblq => vr_vlresblq_poup -- Valor Residual
                                        ,pr_dscritic => vr_dscritic); -- Critica
        -- Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          -- Retornar a critica
          vr_dscritic := 'Erro ao verificar bloqueio judicial – Retornando.';
        END IF;
      END IF;
      
      -- Atualizar o saldo de Poupança Programada removendo bloqueio judicial
      vr_vlsaldo_poup := GREATEST(0, vr_vlsaldo_poup - vr_vlblqjud_poup);
      
      -- Atualizar o saldo de Aplicações removendo bloqueio judicial
      IF vr_vlblqjud_apli > 0 THEN
        -- Caso bloqueio superior ao saldo Aplicação
        IF vr_vlblqjud_apli > vr_vlsaldo_aplica THEN
          -- Descontar o bloqueio desta e zerar pois o bloqueio é maior que o saldo
          vr_vlblqjud_apli := vr_vlblqjud_apli - vr_vlsaldo_aplica;
          vr_vlsaldo_aplica := 0;
        ELSE
          -- Descontar do saldo o bloqueio desta e zerar o bloqueio pois o saldo é suficiente
          vr_vlsaldo_aplica := vr_vlsaldo_aplica - vr_vlblqjud_apli;
          vr_vlblqjud_apli := 0;
        END IF;
      END IF;
      
      -- Armazenar valores originais antes do calculo do bloqueio
      vr_vlsaldo_aplica_aux := vr_vlsaldo_aplica;
      vr_vlsaldo_poup_aux := vr_vlsaldo_poup;
      
      --**** Verificar se há bloqueio de garantia ***--
      
      -- Se ha valor a bloquear
      IF vr_vlbloque_aplica + vr_vlbloque_poupa + vr_vlbloque_ambos > 0 THEN
        
        -- Se deve o ocorrer bloqueio apenas de aplicação
        IF vr_vlbloque_aplica + vr_vlbloque_ambos > 0 THEN
          -- Se Bloqueio superior a saldo aplicações
          IF (vr_vlbloque_aplica + vr_vlbloque_ambos) >= vr_vlsaldo_aplica THEN
            -- Primeiro descontar o bloqueio exclusivo
            IF vr_vlbloque_aplica >= vr_vlsaldo_aplica THEN
              vr_vlbloque_aplica := vr_vlbloque_aplica - vr_vlsaldo_aplica;
            ELSE
              -- Bloqueio exclusivo totalmente atendido e saldo aplicação descontando o mesmo
              vr_vlsaldo_aplica := vr_vlsaldo_aplica - vr_vlbloque_aplica;
              vr_vlbloque_aplica := 0;
              -- Descontar agora do bloqueio genérico (Aplica + Poupa)
              IF vr_vlbloque_ambos >= vr_vlsaldo_aplica THEN
                vr_vlbloque_ambos := vr_vlbloque_ambos - vr_vlsaldo_aplica;
              ELSE
                -- Bloqueio genérico totalmente atendido e saldo aplicação descontando o mesmo
                vr_vlbloque_ambos := 0;
              END IF;
            END IF;
            -- Zerar saldo Aplica
            vr_vlsaldo_aplica := 0;
          ELSE
            -- Descontar do saldo o bloqueio desta e zerar o bloqueio pois o saldo é suficiente
            vr_vlsaldo_aplica := vr_vlsaldo_aplica - (vr_vlbloque_aplica + vr_vlbloque_ambos);
            vr_vlbloque_aplica := 0;
            vr_vlbloque_ambos := 0;
          END IF;
        END IF;
        
        -- Se deve ocorrer bloqueio de Poupança e ainda houver valor a bloquear
        IF vr_vlbloque_poupa + vr_vlbloque_ambos > 0 THEN
          
          -- Bloquear então a Poupança Programada
          IF vr_vlbloque_poupa + vr_vlbloque_ambos > vr_vlsaldo_poup THEN
            -- Primeiro descontar o bloqueio exclusivo
            IF vr_vlbloque_poupa >= vr_vlsaldo_poup THEN
              vr_vlbloque_poupa := vr_vlbloque_poupa - vr_vlsaldo_poup;
            ELSE
              -- Bloqueio exclusivo totalmente atendido e saldo aplicação descontando o mesmo
              vr_vlsaldo_poup := vr_vlsaldo_poup - vr_vlbloque_poupa;
              vr_vlbloque_poupa := 0;
              -- Descontar agora do bloqueio genérico (Aplica + Poupa)
              IF vr_vlbloque_ambos >= vr_vlsaldo_poup THEN
                vr_vlbloque_ambos := vr_vlbloque_ambos - vr_vlsaldo_poup;
              ELSE
                -- Bloqueio genérico totalmente atendido e saldo aplicação descontando o mesmo
                vr_vlbloque_ambos := 0;
              END IF;
            END IF;
            -- Zerar saldo Poupa
            vr_vlsaldo_poup := 0;
          ELSE
            -- Descontar do saldo o bloqueio desta e zerar o bloqueio pois o saldo é suficiente
            vr_vlsaldo_poup := vr_vlsaldo_poup - (vr_vlbloque_poupa + vr_vlbloque_ambos);
            vr_vlbloque_poupa := 0;
            vr_vlbloque_ambos := 0;
          END IF;
          
        END IF;
        
      END IF;
      
      -- Retornar a diferença entre o saldo antes e depois do bloqueio de Garantia,
      -- desta forma temos exatamente os valores a Bloquear apenas de Garantia:
      pr_vlbloque_aplica := vr_vlsaldo_aplica_aux - vr_vlsaldo_aplica;
      pr_vlbloque_poupa := vr_vlsaldo_poup_aux - vr_vlsaldo_poup;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro       
        pr_dscritic := 'Erro na BLOQ0001.PC_BLOQ_DESBLOQ_COB_OPERACAO --> '|| SQLERRM;
        
    END;
    
  END pc_calc_bloqueio_garantia;
  
    
  --> Chamada ayllosweb da rotina pc_calc_bloqueio_garantia
  PROCEDURE pc_calc_bloq_garantia_web 
                            ( pr_nrdconta IN  NUMBER
                             ,pr_tpctrato IN  NUMBER DEFAULT 0
                             ,pr_nrctaliq IN  VARCHAR2 DEFAULT 0 -- Conta em que o contrato está em liquidação;
                             ,pr_dsctrliq IN  VARCHAR2 DEFAULT 0 -- Lista de contratos separados por ";" a liquidar com a contratação deste;
                             ,pr_vlsldapl IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                             ,pr_vlblqapl IN  NUMBER DEFAULT 0
                             ,pr_vlsldpou IN  NUMBER DEFAULT 0   -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                             ,pr_vlblqpou IN  NUMBER DEFAULT 0
                             ,pr_xmllog   IN  VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................
    
        Programa: pc_calc_bloq_garantia_web
        Sistema : CECRED
        Sigla   : BLOQ
        Autor   : Odirlei Busana
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Chamada ayllosweb da rotina pc_calc_bloqueio_garantia
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
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
      
      
      --> variaveis auxiliares
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_vlblqapl        NUMBER;
      vr_vlblqpou        NUMBER;
      
      ---------->> CURSORES <<--------      
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
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
      
      
      pc_calc_bloqueio_garantia (pr_cdcooper        => vr_cdcooper
                                ,pr_nrdconta        => pr_nrdconta
                                ,pr_tpctrato        => nvl(pr_tpctrato,0)
                                ,pr_nrctaliq        => nvl(pr_nrctaliq,0) -- Conta em que o contrato está em liquidação;
                                ,pr_dsctrliq        => nvl(pr_dsctrliq,0) -- Lista de contratos separados por ";" a liquidar com a contratação deste;
                                ,pr_vlsldapl        => nvl(pr_vlsldapl,0) -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                                ,pr_vlblqapl        => nvl(pr_vlblqapl,0)
                                ,pr_vlsldpou        => nvl(pr_vlsldpou,0) -- Somente repassar saldo de aplicação se já foi descontado bloqueios antigos (BLQRGT);
                                ,pr_vlblqpou        => nvl(pr_vlblqpou,0)
                                ,pr_vlbloque_aplica => vr_vlblqapl
                                ,pr_vlbloque_poupa  => vr_vlblqpou 
                                ,pr_dscritic        => vr_dscritic  );    --> Retorno de erro   
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
            
      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;        
      
      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<root><Dados>');
      
      BEGIN
        pc_escreve_xml( '<vlblqapl>'|| vr_vlblqapl ||'</vlblqapl>'||
                        '<vlblqpou>'|| vr_vlblqpou ||'</vlblqpou>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao montar tabela de retorno'||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
      
      
      pc_escreve_xml('</Dados></root>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);        
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);                             
    
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
  END pc_calc_bloq_garantia_web;
  
  
  PROCEDURE pc_vincula_cobertura_operacao(pr_idcobertura_anterior IN NUMBER DEFAULT 0
                                         ,pr_idcobertura_nova     IN NUMBER
                                         ,pr_nrcontrato           IN NUMBER
                                         ,pr_dscritic            OUT VARCHAR2) IS
  /*.............................................................................

    Programa: pc_vincula_cobertura_operacao
    Autor   : Jaison Fernando
    Data    : Novembro/2017                    Ultima Atualizacao: 
     
    Dados referentes ao programa:
   
    Objetivo  : Tratar a vinculacao da garantia nas operacoes sendo contratadas.
                 
    Alteracoes: 

  .............................................................................*/
  
  BEGIN                          
    DECLARE
      -- Variavel de critica
      vr_dscritic crapcri.dscritic%TYPE := NULL;

      -- Variavel excecao
      vr_exc_erro EXCEPTION;

    BEGIN      
      
      -- Se foi informado cobertura anterior
      IF pr_idcobertura_anterior > 0 THEN
        BEGIN
          DELETE
            FROM tbgar_cobertura_operacao
           WHERE idcobertura = pr_idcobertura_anterior;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao remover cobertura de operacao anterior: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;

      -- Se foi informado nova cobertura
      IF pr_idcobertura_nova > 0 THEN
        BEGIN
          UPDATE tbgar_cobertura_operacao
             SET nrcontrato  = pr_nrcontrato
           WHERE idcobertura = pr_idcobertura_nova;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar cobertura de operacao: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;

    EXCEPTION 
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na BLOQ0001.PC_VINCULA_COBERTURA_OPERACAO --> '|| SQLERRM;
        
    END;
    
  END pc_vincula_cobertura_operacao;
                
END BLOQ0001;
/
