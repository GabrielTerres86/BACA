CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps530 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    /* .............................................................................

       Programa: pc_crps530 (Fontes/crps530.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Fernando
       Data    : Julho/2009                      Ultima Atualizacao: 20/05/2014
       Dados referente ao programa:

       Frequencia: Diario.

       Objetivo  : Atende a solicitacao 002 - Ordem 48
                   Listar os emprestimos atrelados a emissao de boletos que estao 
                   em atraso.
                   
       Alteracoes :
                12/03/2012 - Declarado variaveis necessarias para utilizacao
                             da include lelem.i (Tiago).
                
                22/08/2013 - Alterado para nao usar mais informaçoes de telefone 
                             da tabela CRAPASS para usar a CRAPTFC. Substituido
                             o termo "PAC" por "PA"(Daniele).
                
                20/05/2014 - Converão Progress para Oracle (Odirlei-AMcom)             
                
    ............................................................................ */   

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS530';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Buscar emprestimos não liquidados
    CURSOR cr_crapepr IS
      SELECT epr.cdcooper,
             epr.cdagenci,
             epr.vlsdeved,
             epr.nrdconta,
             epr.nrctremp,
             epr.vljuracu,
             epr.inliquid,
             epr.qtprecal,
             epr.qtmesdec,
             epr.qtpreemp,
             epr.dtdpagto,
             epr.dtmvtolt,
             epr.vlpreemp                         
        FROM crapepr epr,
             craplcr lcr
       WHERE epr.cdcooper = pr_cdcooper      
         AND epr.inliquid = 0 -- não liquidado     
         AND lcr.cdcooper = pr_cdcooper      
         AND lcr.cdlcremp = epr.cdlcremp  
         AND lcr.cdusolcr = 2 -- Boletos           
       ORDER BY epr.cdagenci,epr.nrdconta;
     
    -- Buscar dados da agencia
    CURSOR cr_crapage (pr_cdcooper crapage.cdcooper%type,
                       pr_cdagenci crapage.cdagenci%type) IS
      SELECT nmresage
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%rowtype;     
    
    -- Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper crapage.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT nrdconta,
             inpessoa,
             nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;         
    rw_crapass cr_crapass%rowtype;
    
    -- Buscar um telefones de cada tipo do cooperado
    CURSOR cr_craptfc (pr_cdcooper craptfc.cdcooper%type,
                       pr_nrdconta craptfc.nrdconta%type) IS
    
    SELECT nrdddtfc
          ,nrtelefo
          ,tptelefo
          ,nrseq
      FROM (SELECT nrdddtfc
                  ,nrtelefo
                  ,tptelefo
                  --simular find-first
                  ,row_number() over(PARTITION BY tptelefo ORDER BY tptelefo) nrseq
              FROM craptfc
             WHERE craptfc.cdcooper = pr_cdcooper
       AND craptfc.nrdconta = pr_nrdconta
               AND craptfc.tptelefo IN (1, -- residencial
                                        2, -- celular
                                        3) -- comercial
             ORDER BY tptelefo) x
     WHERE x.nrseq = 1; -- exibir apenas o primeiro de cada tipo
      
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- armazenar as empresas dos titulares
    type typ_tab_reg_crapttl
                  is record( cdempres crapttl.cdempres%type,
                             cdturnos crapttl.cdturnos%type);

    type typ_tab_crapttl is table of typ_tab_reg_crapttl
                         index by varchar2(10); --nrdconta
    vr_tab_crapttl typ_tab_crapttl;
    
      
    ------------------------------- VARIAVEIS -------------------------------
    vr_sldaregu     NUMBER(25,8);               -- Saldo a regularizar
    vr_vlsdeved     crapepr.vlsdeved%type;      -- valor do saldo devedor do emprestimo. 
    vr_cdagenci     crapepr.cdagenci%type;      -- variavel para controlar quebra da agencia
    vr_regexist     BOOLEAN;                    -- Variavel para controlar emissão do relatorio 
    vr_rel_dsagenci VARCHAR2(100);              -- Nome da agencia para o relatorio
    vr_nrramfon     VARCHAR2(400);              -- Texto com os numeros do telefone
    vr_cdempres     crapttl.cdempres%type;      -- Codigo da empresa do associado
    vr_cdturnos     crapttl.cdturnos%type;      -- Codigo de turnos do associado  
    
    vr_des_xml         CLOB;                -- Variáveis para armazenar as informações em XML      
    vr_texto_completo  VARCHAR2(32600);     -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_nom_direto      VARCHAR2(100);       -- diretorio de geracao do relatorio
    vr_nmarquiv        VARCHAR2(100);       --
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    
    -- Chamar a geração do relatorio
    PROCEDURE pc_solicita_relato(pr_des_xml    IN OUT NOCOPY CLOB,
                                 pr_nmarquiv   IN VARCHAR2,
                                 pr_dscritic  OUT VARCHAR2) is
    BEGIN
            
      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => pr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl516/conta'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl516.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||pr_nmarquiv --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar na hora
                                 ,pr_des_erro  => pr_dscritic);       --> Saída com erro
          
    END pc_solicita_relato;    
    
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in varchar2,
                             pr_fecha_xml in boolean default false) is
    begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    end;
    
    --Buscar codigo da empresa da pessoa fisica ou juridica
    PROCEDURE pc_trata_cdempres (pr_cdcooper IN crapcop.cdcooper%type,
                                 pr_inpessoa IN crapass.inpessoa%type,
                                 pr_nrdconta IN crapass.nrdconta%type,
                                 pr_cdempres IN OUT crapttl.cdempres%type,
                                 pr_cdturnos IN OUT crapttl.cdturnos%type) IS

      -- Ler Cadastro de pessoas juridicas.
      CURSOR cr_crapjur is
        SELECT cdempres
          FROM crapjur
         WHERE crapjur.cdcooper = pr_cdcooper
           AND crapjur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
      
      -- Ler Cadastro de titulares da conta
      CURSOR cr_crapttl is
        SELECT cdempres,
               nrdconta,
               cdturnos
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.idseqttl = 1;

    BEGIN

      -- Se for pessoa fisica
      IF pr_inpessoa = 1 THEN
        -- se estiver vazia, carrega temptable
        IF vr_tab_crapttl.count = 0 THEN  
          --Popular tabela temporaria com dos titulares
          FOR rw_crapttl IN cr_crapttl LOOP
            vr_tab_crapttl(lpad(rw_crapttl.nrdconta,10,0)).cdempres :=  rw_crapttl.cdempres;
            vr_tab_crapttl(lpad(rw_crapttl.nrdconta,10,0)).cdturnos :=  rw_crapttl.cdturnos;
          END LOOP;
        END IF;      
        
        --verificar se o registro do titular existe
        IF vr_tab_crapttl.exists(lpad(pr_nrdconta,10,0)) THEN
          pr_cdempres := vr_tab_crapttl(lpad(pr_nrdconta,10,0)).cdempres;
          pr_cdturnos := vr_tab_crapttl(lpad(pr_nrdconta,10,0)).cdturnos;
        END IF;
      ELSE
        -- Ler Cadastro de pessoas juridicas.
        OPEN cr_crapjur;
        FETCH cr_crapjur
          INTO rw_crapjur;
        IF cr_crapjur%NOTFOUND THEN
          CLOSE cr_crapjur;
        ELSE
          CLOSE cr_crapjur;
          pr_cdempres := rw_crapjur.cdempres;
        END IF;
      END IF;

    END pc_trata_cdempres;  
    
    -- Função para retornar o numero de meses decorridos
    FUNCTION fn_meses_decorridos (pr_cdcooper IN crapepr.cdcooper%type,  --> codigo da cooperativa 
                                   pr_nrdconta IN crapepr.nrdconta%type,  --> Numero de conta
                                   pr_nrctremp IN crapepr.nrctremp%type,  --> Numero do contrato do emprestimo
                                   pr_dtdpagto IN crapepr.dtdpagto%type,  --> Data de pagamento
                                   pr_qtmesdec IN crapepr.qtmesdec%type,  --> Qtd de mes decorridos
                                   pr_dtmvtolt IN crapepr.dtmvtolt%type,  --> Data do movimento do emprestimos                                   
                                   pr_crapdat  IN BTCH0001.cr_crapdat%rowtype, --> registro da crapdat da cooperativa
                                   pr_cdcritic OUT crapcri.cdcritic%type, --> Critica encontrada
                                   pr_dscritic OUT VARCHAR2)              --> Texto de erro/critica encontrada
                                   RETURN NUMBER IS
      
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_exc_erro   EXCEPTION;
      vr_dtinipag   DATE;
      vr_qtmesdec   crapepr.qtmesdec%type;
      
      -- Ler tabela auxiliar de emprestimos
      CURSOR cr_crawepr IS
        SELECT dtdpagto
          FROM crawepr 
         WHERE crawepr.cdcooper = pr_cdcooper       
           AND crawepr.nrdconta = pr_nrdconta   
           AND crawepr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;     
           
    BEGIN
      
      --Buscar emprestimo na tabela auxiliar
      OPEN cr_crawepr;
      FETCH cr_crawepr
        INTO rw_crawepr;
      -- Se registro não existe
      IF cr_crawepr%NOTFOUND THEN
        --usar a data da crapepr
        vr_dtinipag := pr_dtdpagto;
      ELSE
       --senao usar a data da tabela  auxiliar
       vr_dtinipag := rw_crawepr.dtdpagto;  
      END IF;    
      CLOSE cr_crawepr;
      
      -- se for o mes da data de pagamento do emprestimo
      IF TO_CHAR(pr_dtdpagto,'MM/RRRR') = TO_CHAR(pr_crapdat.dtmvtolt,'MM/RRRR') THEN 
        /*  Ainda nao pagou no mes */
        IF pr_dtdpagto <= pr_crapdat.dtmvtolt  THEN
          vr_qtmesdec := nvl(pr_qtmesdec,0) + 1;
        ELSE
          vr_qtmesdec := nvl(pr_qtmesdec,0);
        END IF;
      -- se for o mes da data de movimento do emprestimo  
      ELSIF TO_CHAR(pr_dtmvtolt,'MM/RRRR') = TO_CHAR(pr_crapdat.dtmvtolt,'MM/RRRR') THEN 
        /* Contrato do mes */
        IF TO_CHAR(vr_dtinipag,'MM/RRRR') = TO_CHAR(pr_crapdat.dtmvtolt,'MM/RRRR') THEN
          /* Devia ter pago a primeira no mes do contrato */
          vr_qtmesdec := nvl(pr_qtmesdec,0) + 1;
        ELSE
          /* Paga a primeira somente no mes seguinte */
          vr_qtmesdec := pr_qtmesdec;
        END IF;
      
      ELSE
        -- Se a data de pagamento do emprestimo for menor que a data do mvt atual e 
        -- o  dia de pagamento for menor(passou um mês)
        IF (pr_dtdpagto < pr_crapdat.dtmvtolt  AND 
            to_char(pr_dtdpagto,'DD') <= to_char(pr_crapdat.dtmvtolt,'DD')) OR
            -- ou a data do pagamento é maior que a data do movimento atual
            pr_dtdpagto > pr_crapdat.dtmvtolt  THEN    
          vr_qtmesdec := pr_qtmesdec + 1;
        ELSE
          vr_qtmesdec := pr_qtmesdec;
        END IF;  
      END IF;
      
      -- Se a qtd de mes decorridos calculados for menor que zero deve ser zero
      IF vr_qtmesdec < 0 THEN
        RETURN 0;
      ELSE 
        RETURN vr_qtmesdec;
      END IF;        
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        pr_cdcritic := vr_cdcritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na fn_meses_decorridos: '||SQLerrm;  
    END;    
    
    -- Procedimento para calcular o saldo a regularizar 
    PROCEDURE pc_calculo_a_regularizar(pr_cdcooper IN crapepr.cdcooper%type,  --> codigo da cooperativa 
                                       pr_nrdconta IN crapepr.nrdconta%type,  --> Numero de conta
                                       pr_nrctremp IN crapepr.nrctremp%type,  --> Numero do contrato do emprestimo                                       
                                       pr_vljuracu IN crapepr.vljuracu%type,  --> Valor do juro acumulado
                                       pr_inliquid IN crapepr.inliquid%type,  --> Indicador de liquidado
                                       pr_qtprecal IN crapepr.qtprecal%type,  --> Qtd de prestação calduladas 
                                       pr_qtmesdec IN crapepr.qtmesdec%type,  --> Qtd de mes decorridos
                                       pr_qtpreemp IN crapepr.qtpreemp%type,  --> Quantidade de prestacoes do emprestimo
                                       pr_dtdpagto IN crapepr.dtdpagto%type,  --> Data de pagamento
                                       pr_dtmvtolt IN crapepr.dtmvtolt%type,  --> Data de pagamento
                                       pr_vlpreemp IN crapepr.vlpreemp%type,  --> Valor da prestação do emprestimo
                                       pr_crapdat  IN BTCH0001.cr_crapdat%rowtype, --> registro da crapdat da cooperativa
                                       pr_vlsdeved IN OUT  crapepr.vlsdeved%type, --> Valor do saldo devedor
                                       pr_sldaregu OUT NUMBER,                --> Valor do saldo a regularizar     
                                       pr_cdcritic OUT crapcri.cdcritic%type, --> Critica encontrada
                                       pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
      
    
    
    
      vr_cdcritic       PLS_INTEGER;
      vr_dscritic       VARCHAR2(4000);
      vr_exc_erro       EXCEPTION;
      vr_qtprecal       INTEGER;
      vr_qtmesdec       INTEGER;
      vr_vljuracu       NUMBER(20,8);
      vr_vlsdeved       NUMBER; -- NO PROGRESS INTEGER(ajustado)
      vr_diapagto       INTEGER;
      vr_txdjuros       NUMBER(20,7) := 0 ;
      vr_qtprepag       INTEGER;
      vr_qtprecal_lem   INTEGER;
      vr_vlprepag       NUMBER(25,8);
      vr_vljurmes       NUMBER(25,8);
      vr_dtultpag       DATE;
      
      
    BEGIN
      -- Se o emprestimo ainda não estiver liquidado
      -- usar a quantidade de prestações calculadas
      IF pr_inliquid = 0 THEN
        vr_qtprecal := pr_qtprecal;
      ELSE 
        --senão usar a qtd de prestações do emprestimo
        vr_qtprecal := pr_qtpreemp;
      END IF;  

      vr_vljuracu := pr_vljuracu;
      
      -- Chamar rotina de cálculo externa
      empr0001.pc_leitura_lem(pr_cdcooper    => pr_cdcooper
                             ,pr_cdprogra    => vr_cdprogra
                             ,pr_rw_crapdat  => pr_crapdat
                             ,pr_nrdconta    => pr_nrdconta
                             ,pr_nrctremp    => pr_nrctremp
                             ,pr_dtcalcul    => pr_crapdat.dtmvtolt
                              --OUT
                             ,pr_diapagto    => vr_diapagto
                             ,pr_txdjuros    => vr_txdjuros
                             ,pr_qtprepag    => vr_qtprepag
                             ,pr_qtprecal    => vr_qtprecal_lem
                             ,pr_vlprepag    => vr_vlprepag
                             ,pr_vljuracu    => vr_vljuracu
                             ,pr_vljurmes    => vr_vljurmes
                             ,pr_vlsdeved    => pr_vlsdeved
                             ,pr_dtultpag    => vr_dtultpag
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_des_erro    => vr_dscritic);
      -- Se a rotina retornou com erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_erro;
      END IF;
      
      IF pr_inliquid = 0 THEN
        vr_qtprecal := vr_qtprecal + vr_qtprecal_lem;
      END IF; 
      
      /* Calcula os meses decorridos */
      vr_qtmesdec :=  fn_meses_decorridos (pr_cdcooper => pr_cdcooper,  --> codigo da cooperativa 
                                           pr_nrdconta => pr_nrdconta,  --> Numero de conta
                                           pr_nrctremp => pr_nrctremp,  --> Numero do contrato do emprestimo
                                           pr_dtdpagto => pr_dtdpagto,  --> Data de pagamento
                                           pr_qtmesdec => pr_qtmesdec,  --> Qtd de mes decorridos
                                           pr_dtmvtolt => pr_dtmvtolt,  --> Data do movimento do emprestimos                                   
                                           pr_crapdat  => pr_crapdat,   --> registro da crapdat da cooperativa
                                           pr_cdcritic => vr_cdcritic,  --> Critica encontrada
                                           pr_dscritic => vr_dscritic );--> Texto de erro/critica encontrada
      -- Se retornou erro                                     
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN  
        RAISE vr_exc_erro;
      END IF;
        
      /* Verifica o valor a regularizar */
      IF pr_qtprecal > pr_qtmesdec   AND
         pr_dtdpagto <= pr_crapdat.dtmvtolt THEN

        pr_sldaregu := nvl(pr_vlpreemp,0) - nvl(vr_vlprepag,0);
        -- se saldo a regularizar for menor que negativo, deve ser zero 
        IF pr_sldaregu < 0 THEN
          pr_sldaregu := 0;
        END IF;                            
      ELSE   
        -- se houver diferença entre o mes decorrido e o mes calculado
        IF (nvl(vr_qtmesdec,0) - nvl(vr_qtprecal,0)) > 0 THEN
          pr_sldaregu := (nvl(vr_qtmesdec,0) - nvl(vr_qtprecal,0)) * pr_vlpreemp;
        END IF;        
      END IF;   
      
      -- se qtd de mes decorridos for maior que a qt de prestações do emprestimo
      IF nvl(vr_qtmesdec,0) > nvl(pr_qtpreemp,0)   THEN 
        pr_sldaregu := pr_vlsdeved;
      -- se o valor do saldo a regularizar for maior que o saldo de devedor  
      ELSIF nvl(pr_sldaregu,0) > nvl(pr_vlsdeved,0) THEN         
         pr_sldaregu := pr_vlsdeved;
      ELSE
         pr_sldaregu := nvl(pr_sldaregu,0);
      END IF;
        
      -- Zerar saldo a regularizar caso o mesmo seja negativo
      IF nvl(pr_sldaregu,0) < 0  THEN
        pr_sldaregu := 0;
      END IF;  
               
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        pr_cdcritic := vr_cdcritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na pc_calculo_a_regularizar: '||SQLerrm;
    END;
        
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
            
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    
    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    
    -- iniciar variaveis de controle
    vr_cdagenci := -1;
    vr_regexist := FALSE;
    
    -- Ler emprestimos não liquidados, cujo o uso da linha de credito seja boleto
    FOR rw_crapepr IN cr_crapepr LOOP
     
      /* Verifica se tem Saldo A Regularizar */
      vr_sldaregu := 0;
      vr_vlsdeved := rw_crapepr.vlsdeved;
      
      pc_calculo_a_regularizar(pr_cdcooper => rw_crapepr.cdcooper,  --> codigo da cooperativa 
                               pr_nrdconta => rw_crapepr.nrdconta,  --> Numero de conta
                               pr_nrctremp => rw_crapepr.nrctremp,  --> Numero do contrato do emprestimo
                               pr_vlsdeved => vr_vlsdeved,          --> Valor do saldo devedor
                               pr_vljuracu => rw_crapepr.vljuracu,  --> Valor do juro acumulado
                               pr_inliquid => rw_crapepr.inliquid,  --> Indicador de liquidado
                               pr_qtprecal => rw_crapepr.qtprecal,  --> Qtd de prestação calduladas 
                               pr_qtmesdec => rw_crapepr.qtmesdec,  --> Qtd de mes decorridos
                               pr_qtpreemp => rw_crapepr.qtpreemp,  --> Quantidade de prestacoes do emprestimo
                               pr_dtdpagto => rw_crapepr.dtdpagto,  --> Data de pagamento
                               pr_dtmvtolt => rw_crapepr.dtmvtolt,  --> Data de pagamento
                               pr_vlpreemp => rw_crapepr.vlpreemp,  --> Valor da prestação do emprestimo
                               pr_crapdat  => rw_crapdat,           --> registro da crapdat da cooperativa
                               pr_sldaregu => vr_sldaregu,          --> Valor do saldo a regularizar     
                               pr_cdcritic => vr_cdcritic,          --> Critica encontrada
                               pr_dscritic => vr_dscritic);         --> Texto de erro/critica encontrada      
      
      -- Se retornou erro                                     
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN  
        RAISE vr_exc_saida;
      END IF;  
      
      IF nvl(vr_sldaregu,0) = 0  THEN
        -- se valor a regularizar for zero, deve ir para o proximo registro
        continue;
      END IF;  
      
      -- Controlar quebra por agencia
      IF vr_cdagenci <> rw_crapepr.cdagenci THEN
        vr_cdagenci := rw_crapepr.cdagenci;
        
        -- controla a geração do relatorio
        IF vr_regexist THEN
          --fechar a tag principal e descarregar o buffer
          pc_escreve_xml('</crrl516>',TRUE);
          
          -- Efetuar solicitação de geração de relatório 
          pc_solicita_relato(pr_des_xml   => vr_des_xml,
                             pr_nmarquiv  => vr_nmarquiv,
                             pr_dscritic  => vr_dscritic);
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_saida;
          END IF;

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
        END IF;  
        
        -- Inicializar o CLOB
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := null;        

        
        -- Definir nome do relatorio
        vr_nmarquiv := 'crrl516_'||TO_CHAR(rw_crapepr.cdagenci, 'fm000')||'.lst';
        
        -- Buscar dados da agencia
        OPEN cr_crapage(pr_cdcooper => rw_crapepr.cdcooper,
                        pr_cdagenci => rw_crapepr.cdagenci);
        FETCH cr_crapage
          INTO rw_crapage;
        -- definir nome da agencia  
        IF cr_crapage%NOTFOUND THEN
          vr_rel_dsagenci := gene0002.fn_mask(rw_crapepr.cdagenci,'zz9')||' - PA NAO CADASTRADO';
        ELSE
          vr_rel_dsagenci := gene0002.fn_mask(rw_crapepr.cdagenci,'zz9')||' - '||rw_crapage.nmresage;
        END IF;             
        CLOSE cr_crapage;
                
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl516 dsagenci="'||vr_rel_dsagenci||'">');          

      END IF;
      
      -- Buscar dados do associado
      OPEN cr_crapass (pr_cdcooper => rw_crapepr.cdcooper,
                       pr_nrdconta => rw_crapepr.nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;                 
      IF cr_crapass%NOTFOUND THEN
         CLOSE cr_crapass;
         vr_dscritic := 'Associado não encontrado(nrdconta:'||rw_crapepr.nrdconta||')!';
         raise vr_exc_saida;
      ELSE
         CLOSE cr_crapass;
      END IF;            
      
      vr_nrramfon := NULL;
      -- buscar telefones dos cooperados
      FOR rw_craptfc IN cr_craptfc(pr_cdcooper => rw_crapepr.cdcooper,
                                   pr_nrdconta => rw_crapepr.nrdconta) LOOP
        
        -- Incluir primeiro telefone 1-residencial e 2-celular
        IF rw_craptfc.tptelefo <> 3 THEN 
          IF vr_nrramfon is not null THEN
            vr_nrramfon := vr_nrramfon||'/'||rw_craptfc.nrtelefo;
          ELSE
            vr_nrramfon := rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;
          END IF;       
        ELSE
          /*** se não encontrou nenhum incluir telefone 3-comercial ***/
          IF vr_nrramfon is null THEN
            vr_nrramfon := rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;
          END IF;  
        END IF;     
      END LOOP;  
      -- Buscar codigo da empresa do cooperado
      pc_trata_cdempres (pr_cdcooper => pr_cdcooper,
                         pr_inpessoa => rw_crapass.inpessoa,
                         pr_nrdconta => rw_crapass.nrdconta,
                         pr_cdempres => vr_cdempres,
                         pr_cdturnos => vr_cdturnos);
      
      vr_regexist := TRUE;
      
      -- Escrever dados para o relatorio
      pc_escreve_xml('<conta>
                        <nrdconta>'|| gene0002.fn_mask_conta(rw_crapass.nrdconta) ||'</nrdconta>
                        <nmprimtl>'|| substr(rw_crapass.nmprimtl,1,26)            ||'</nmprimtl>
                        <cdempres>'|| vr_cdempres         ||'</cdempres>
                        <nrramfon>'|| vr_nrramfon         ||'</nrramfon>
                        <cdturnos>'|| vr_cdturnos         ||'</cdturnos>
                        <nrctremp>'|| gene0002.fn_mask_contrato(rw_crapepr.nrctremp) ||'</nrctremp>
                        <diapagto>'|| to_number(to_char(rw_crapepr.dtdpagto,'DD'))   ||'</diapagto>
                        <vlsdeved>'|| nvl(vr_vlsdeved,0)  ||'</vlsdeved>
                        <vlpreemp>'|| rw_crapepr.vlpreemp ||'</vlpreemp>
                        <sldaregu>'|| nvl(vr_sldaregu,0)  ||'</sldaregu>
                       </conta>' );                  
                            
    END LOOP;  
    
    -- controla a geração do ultimo relatorio por agencia
    IF vr_regexist THEN
      --fechar a tag principal e descarregar o buffer
      pc_escreve_xml('</crrl516>',TRUE);
          
      -- Efetuar solicitação de geração de relatório 
      pc_solicita_relato(pr_des_xml   => vr_des_xml,
                         pr_nmarquiv  => vr_nmarquiv,
                         pr_dscritic  => vr_dscritic);
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    -- caso não gerou nenhum relatorio
    ELSE 
      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;        
        
      -- Definir nome do relatorio
      vr_nmarquiv := 'crrl516.lst';              
                
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl516 dsatraso="NAO HA EPR/BOLETOS EM ATRASO.">
                                                               <conta/>
                                                             </crrl516>',true);     
    
      -- Efetuar solicitação de geração de relatório 
      pc_solicita_relato(pr_des_xml   => vr_des_xml,
                         pr_nmarquiv  => vr_nmarquiv,
                         pr_dscritic  => vr_dscritic);
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    END IF;
    
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK; 
  END pc_crps530;
/

