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
                           
  PROCEDURE pc_valida_bloqueio_judicial(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                                       ,pr_tpaplica IN INTEGER               --> Tipo da aplicação
                                       ,pr_nraplica IN INTEGER               --> Número da aplicação
                                       ,pr_dtmvtolt IN DATE                  --> Data de movimento
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Retorno de erro   
                           

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
    Data    : Maio/2014                    Ultima Atualizacao: 14/05/2014.
     
    Dados referentes ao programa:
   
    Objetivo  : Validar os dados da tela BLQRGT    
                 
    Alteracoes: 14/05/2014 - Conversão PROGRESS para ORACLE (Adriano).
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
      
      -- Consulta o bloqueio judicial somente no bloqueio como garantia
      IF pr_inoperac = 1 THEN
        
        pc_valida_bloqueio_judicial(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_tpaplica => pr_tpaplica
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdcritic => vr_cdcritic 
                                   ,pr_dscritic => vr_dscritic);
                                   
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          
          -- Gera exceção
          RAISE vr_exc_erro;
          
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
  
  /*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0148.p
    Autor   : Adriano
    Data    : Maio/2014                    Ultima Atualizacao: 07/06/2016.
     
    Dados referentes ao programa:
   
    Objetivo  : Validar bloqueio judicial
                 
    Alteracoes: 14/05/2014 - Conversão PROGRESS para ORACLE (Adriano).

                07/06/2016 - Removido o cursor cr_craptab_ctabloq e utilizado a 
                             TABE0001.pc_carrega_ctablq para buscar as informacoes 
                             das contas bloqueadas (Douglas - Chamado 454248)
  .............................................................................*/
  PROCEDURE pc_valida_bloqueio_judicial(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN INTEGER               --> Número do caixa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta
                                       ,pr_tpaplica IN INTEGER               --> Tipo da aplicação
                                       ,pr_nraplica IN INTEGER               --> Número da aplicação
                                       ,pr_dtmvtolt IN DATE                  --> Data de movimento
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Retorno de erro   
                           
  BEGIN                          
    DECLARE
    
      -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
      SELECT lpp.nrdconta
            ,lpp.nrctrrpp
            ,Count(*) qtlancmto
        FROM craplpp lpp
       WHERE lpp.cdcooper = pr_cdcooper
         AND lpp.cdhistor IN (158,496)
         AND lpp.dtmvtolt > pr_dtmvtolt
         GROUP BY lpp.nrdconta
                 ,lpp.nrctrrpp
                  HAVING Count(*) > 3;
                  
      --Contar a quantidade de resgates das contas
      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE) IS
      SELECT lrg.nrdconta
            ,lrg.nraplica
            ,COUNT(*) qtlancmto
        FROM craplrg lrg
       WHERE lrg.cdcooper = pr_cdcooper
         AND lrg.tpaplica = 4
         AND lrg.inresgat = 0
         GROUP BY lrg.nrdconta
                 ,lrg.nraplica;

      --Selecionar informacoes dos lancamentos de resgate
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
      SELECT lrg.nrdconta
            ,lrg.nraplica
            ,lrg.tpaplica
            ,lrg.tpresgat
            ,NVL(SUM(NVL(lrg.vllanmto,0)),0) vllanmto
        FROM craplrg lrg
       WHERE lrg.cdcooper  = pr_cdcooper
         AND lrg.dtresgat <= pr_dtresgat
         AND lrg.inresgat  = 0
         AND lrg.tpresgat  = 1
         GROUP BY lrg.nrdconta
                 ,lrg.nraplica
                 ,lrg.tpaplica
                 ,lrg.tpresgat;                
               
      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Tabela para armazenar os erros
      vr_tab_erro gene0001.typ_tab_erro;
            
      -- Tabela de retorno da rotina
      vr_saldo_rdca  APLI0001.typ_tab_saldo_rdca;  
      vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;
    
      --Variavel usada para montar o indice da tabela de memoria
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);
     
      --Definicao das tabelas de memoria da apli0001.pc_acumula_aplicacoes
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;
           
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
          
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
      
      -- Variaveis locais
      vr_percenir NUMBER := 0;
      vr_vlblqjud NUMBER := 0;
      vr_vlresblq NUMBER := 0;
      vr_vlsldapl NUMBER := 0;
      vr_vlsbloqu NUMBER := 0;
      vr_vlsldrpp NUMBER := 0;
      vr_vlsldpou NUMBER := 0;
      vr_des_reto VARCHAR(3);
                 
    BEGIN      
      
      -- Limpar tabelas
      vr_tab_erro.DELETE;
      vr_saldo_rdca.DELETE;
          
      IF pr_tpaplica <> 1 THEN
        
        -- Busca Saldo Bloqueado Judicial
        GENE0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper --> Cooperativa
                                        ,pr_nrdconta => pr_nrdconta --> Conta
                                        ,pr_nrcpfcgc => 0           --> Fixo - CPF/CGC
                                        ,pr_cdtipmov => 1           --> Fixo - Tipo do movimento
                                        ,pr_cdmodali => 2           --> Modalidade Cta Corrente
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Data atual
                                        ,pr_vlbloque => vr_vlblqjud --> Valor bloqueado
                                        ,pr_vlresblq => vr_vlresblq --> Valor que falta bloquear
                                        ,pr_dscritic => vr_dscritic); --> Erros encontrados no processo
        
        IF vr_dscritic IS NOT NULL THEN
          
          -- Gera exceção 
          RAISE vr_exc_erro;
        
        END IF;
                                        
        IF vr_vlblqjud > 0 THEN
          
          vr_vlsldapl := 0;
          
          -- Consulta o saldo RDCA
          APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper    --> Cooperativa
                                         ,pr_cdagenci   => pr_cdagenci    --> Codigo da agencia
                                         ,pr_nrdcaixa   => pr_nrdcaixa    --> Numero do caixa
                                         ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                                         ,pr_nraplica   => 0              --> Numero da aplicacao
                                         ,pr_tpaplica   => 1 /*Rdca*/     --> Tipo de aplicacao
                                         ,pr_dtinicio   => pr_dtmvtolt    --> Data de inicio da aplicacao
                                         ,pr_dtfim      => pr_dtmvtolt    --> Data final da aplicacao
                                         ,pr_cdprogra   => 'BLOQ0001'     --> Codigo do programa chamador da rotina
                                         ,pr_nrorigem   => 1              --> Origem da chamada da rotina
                                         ,pr_saldo_rdca => vr_saldo_rdca  --> Tipo de tabela com o saldo RDCA
                                         ,pr_des_reto   => vr_des_reto    --> OK ou NOK
                                         ,pr_tab_erro   => vr_tab_erro);   --> Tabela com erros
        
          -- Verifica se deu erro
          IF vr_des_reto = 'NOK' THEN
            
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := NULL;
              vr_dscritic := 'Retorno "NOK" na BLOQ0001.pc_consulta_aplicacoes e sem informação na pr_vet_erro, Conta: '|| pr_nrdconta;
            END IF;
                  
            -- Gera exceção 
            RAISE vr_exc_erro;
            
          END IF;
          
          -- loop sobre a tabela de retorno
          FOR vr_ind IN 1..vr_saldo_rdca.COUNT LOOP
              
            IF vr_ind = vr_saldo_rdca.LAST THEN
              
              vr_vlsbloqu := vr_saldo_rdca(vr_ind).sldresga;
            
            END IF;
               
            IF vr_saldo_rdca(vr_ind).dssitapl <> 'BLOQUEADA' THEN
                
              vr_vlsldapl := vr_vlsldapl +  vr_saldo_rdca(vr_ind).sldresga;
                
            END IF;

          END LOOP;
          
          -- Limpa tabela temporaria
          vr_saldo_rdca.DELETE;
          
          -- Consulta o saldo RDC
          APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper    --> Cooperativa
                                         ,pr_cdagenci   => pr_cdagenci    --> Codigo da agencia
                                         ,pr_nrdcaixa   => pr_nrdcaixa    --> Numero do caixa
                                         ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                                         ,pr_nraplica   => 0              --> Numero da aplicacao
                                         ,pr_tpaplica   => 2 /*RDC*/      --> Tipo de aplicacao
                                         ,pr_dtinicio   => pr_dtmvtolt    --> Data de inicio da aplicacao
                                         ,pr_dtfim      => pr_dtmvtolt    --> Data final da aplicacao
                                         ,pr_cdprogra   => 'BLOQ0001'     --> Codigo do programa chamador da rotina
                                         ,pr_nrorigem   => 1              --> Origem da chamada da rotina
                                         ,pr_saldo_rdca => vr_saldo_rdca  --> Tipo de tabela com o saldo RDCA
                                         ,pr_des_reto   => vr_des_reto    --> OK ou NOK
                                         ,pr_tab_erro   => vr_tab_erro);   --> Tabela com erros
        
          -- Verifica se deu erro
          IF vr_des_reto = 'NOK' THEN
            
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := NULL;
              vr_dscritic := 'Retorno "NOK" na BLOQ0001.pc_consulta_aplicacoes e sem informação na pr_vet_erro, Conta: '|| pr_nrdconta;
            END IF;
                  
            -- Gera exceção 
            RAISE vr_exc_erro;
            
          END IF;
          
          -- Percorrer tabela memoria saldos
          FOR vr_ind IN 1..vr_saldo_rdca.COUNT LOOP
              
            IF vr_ind = vr_saldo_rdca.LAST THEN
              
              vr_vlsbloqu := vr_saldo_rdca(vr_ind).sldresga;
            
            END IF;
               
            IF vr_saldo_rdca(vr_ind).dssitapl <> 'BLOQUEADA' THEN
                
              vr_vlsldapl := vr_vlsldapl +  vr_saldo_rdca(vr_ind).sldresga;
                
            END IF;
                
          END LOOP;
            
          IF ((vr_vlsldapl - vr_vlblqjud) < vr_vlsbloqu) THEN
            
            -- Monta mensagem de critica
            vr_dscritic := 'Aplicacao ja Bloqueada Judicialmente.';
            
            -- Gera exceção
            RAISE vr_exc_erro;
          
          END IF;
          
        END IF;
        
      ELSIF pr_tpaplica = 1 THEN -- Poupança programada
        
        -- Busca saldo bloqueado judicialmente              
        GENE0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper --> Cooperativa
                                        ,pr_nrdconta => pr_nrdconta --> Conta
                                        ,pr_nrcpfcgc => 0           --> Fixo - CPF/CGC
                                        ,pr_cdtipmov => 1           --> Fixo - Tipo do movimento
                                        ,pr_cdmodali => 3           --> Modalidade Cta Corrente
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Data atual
                                        ,pr_vlbloque => vr_vlblqjud --> Valor bloqueado
                                        ,pr_vlresblq => vr_vlresblq --> Valor que falta bloquear
                                        ,pr_dscritic => vr_dscritic); --> Erros encontrados no processo
        
        IF vr_dscritic IS NOT NULL THEN
          
          -- Gera exceção 
          RAISE vr_exc_erro;
        
        END IF;
        
        IF vr_vlblqjud > 0 THEN
          
          -- Verifica se a cooperativa esta cadastrada
          OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
           
          FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
           
          -- Se não encontrar
          IF BTCH0001.cr_crapdat%NOTFOUND THEN
             
            -- Fechar o cursor pois haverá raise
            CLOSE BTCH0001.cr_crapdat;
             
            -- Montar mensagem de critica
            vr_cdcritic := 1;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             
            -- Gera exceção
            RAISE vr_exc_erro;
            
          ELSE
            -- Apenas fechar o cursor
            CLOSE BTCH0001.cr_crapdat;
             
          END IF;
          
          -- Carregar tabela de memoria de contas bloqueadas
          TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_tab_cta_bloq => vr_tab_conta_bloq);
           
          -- Carregar tabela de memoria de lancamentos na poupanca
          FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180) LOOP
                                       
            -- Montar indice para acessar tabela
            vr_index_craplpp := LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
             
            -- Atribuir quantidade encontrada de cada conta ao vetor
            vr_tab_craplpp(vr_index_craplpp) := rw_craplpp.qtlancmto;
             
          END LOOP;

          -- Carregar tabela de memoria com total de resgates na poupanca
          FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper) LOOP
             
            -- Montar Indice para acesso quantidade lancamentos de resgate
            vr_index_craplrg := LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
             
            -- Popular tabela de memoria
            vr_tab_craplrg(vr_index_craplrg) := rw_craplrg.qtlancmto;
             
          END LOOP;
           
          -- Carregar tabela de memória com total resgatado por conta e aplicacao
          FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                       ,pr_dtresgat => rw_crapdat.dtmvtopr) LOOP
                                        
            -- Montar indice para selecionar total dos resgates na tabela auxiliar
            vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0') ||
                                LPad(rw_craplrg.tpaplica,05,'0') ||
                                LPad(rw_craplrg.nraplica,10,'0');
                                
            -- Popular a tabela de memoria com a soma dos lancamentos de resgate
            vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
            vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
             
          END LOOP;
           
          -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
          vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                               ,pr_nmsistem => 'CRED'
                                                                               ,pr_tptabela => 'CONFIG'
                                                                               ,pr_cdempres => 0
                                                                               ,pr_cdacesso => 'PERCIRAPLI'
                                                                               ,pr_tpregist => 0));
          
          
          
       
          -- Executar rotina consulta poupanca
          APLI0001.pc_consulta_poupanca(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_idorigem => 1
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => 1
                                       ,pr_nrctrrpp => 0
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_dtmvtopr => pr_dtmvtolt
                                       ,pr_inproces => 1
                                       ,pr_cdprogra => 'BLOQ0001'
                                       ,pr_flgerlog => FALSE
                                       ,pr_percenir => vr_percenir
                                       ,pr_tab_craptab => vr_tab_conta_bloq 
                                       ,pr_tab_craplpp => vr_tab_craplpp
                                       ,pr_tab_craplrg => vr_tab_craplrg
                                       ,pr_tab_resgate => vr_tab_resgate
                                       ,pr_vlsldrpp => vr_vlsldrpp
                                       ,pr_retorno  => vr_des_reto
                                       ,pr_tab_dados_rpp => vr_tab_dados_rpp
                                       ,pr_tab_erro      => vr_tab_erro);
                              
          --Se retornou erro
          IF vr_des_reto = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := NVL(vr_tab_erro(vr_tab_erro.FIRST).cdcritic,0);
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
            ELSE
              vr_cdcritic := NULL;
              vr_dscritic := 'Retorno "NOK" na BLOQ0001.pc_consulta_poupanca e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta;
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        
          -- Percorrer tabela memoria dados poupanca
          FOR vr_ind IN 1..vr_tab_dados_rpp.COUNT LOOP
            
            IF vr_ind = vr_tab_dados_rpp.LAST THEN
              
              vr_vlsbloqu := vr_tab_dados_rpp(vr_ind).vlrgtrpp;
            
            END IF;
            
            IF vr_tab_dados_rpp(vr_ind).dsblqrpp <> 'Sim' THEN
              
              vr_vlsldpou := vr_vlsldpou + vr_tab_dados_rpp(vr_ind).vlrgtrpp;
            
            END IF;
            
          END LOOP;
          
          IF ((vr_vlsldpou - vr_vlblqjud) < vr_vlsbloqu) THEN
            
            -- Monta critica
            vr_cdcritic := NULL;
            vr_dscritic := 'Poupanca ja Bloqueada Judicialmente.';
            
            -- Gera exceção
            RAISE vr_exc_erro;
          
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
        pr_dscritic := 'Erro na BLOQ0001.pc_valida_bloqueio_judicial --> '|| SQLERRM;
          
    
    END;
    
  END pc_valida_bloqueio_judicial;    
                           
END BLOQ0001;
/
