CREATE OR REPLACE PACKAGE CECRED.geco0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GECO0001
  --  Sistema  : Rotinas genericas focando nas funcionalidades de grupos econômicos
  --  Sigla    : GECO
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Setembro/2012.                   Ultima atualizacao: 26/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas referentes as funcionalidades e administração dos grupos economicos.
  --
  -- Alteracões: 26/03/2018 - Alteração nos cursores da pc_forma_grupo_economico para considerar contas 
  --                          em prejuízo mesmo que elas tenham a data de eliminação (DTELIMIN) preenchida.
  --                          Reginaldo (AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------

  /* PL Table para os grupos economicos */
  TYPE typ_reg_crapgrp IS
    RECORD(cdcooper crapgrp.cdcooper%TYPE
          ,nrdgrupo crapgrp.nrdgrupo%TYPE
          ,nrctasoc crapgrp.nrctasoc%TYPE
          ,nrdconta crapgrp.nrdconta%TYPE
          ,idseqttl crapgrp.idseqttl%TYPE
          ,nrcpfcgc crapgrp.nrcpfcgc%TYPE
          ,dsdrisco crapgrp.dsdrisco%TYPE
          ,innivris crapgrp.innivris%TYPE
          ,dsdrisgp crapgrp.dsdrisgp%TYPE
          ,inpessoa crapgrp.inpessoa%TYPE
          ,cdagenci crapgrp.cdagenci%TYPE
          ,innivrge crapgrp.innivrge%TYPE
          ,dtrefere crapgrp.dtrefere%TYPE
          ,dtmvtolt crapgrp.dtmvtolt%TYPE
          ,vlendivi NUMBER
          ,vlendigp NUMBER);
  -- Definição para PL Table de grupos econômicos
  TYPE typ_tab_crapgrp IS TABLE OF typ_reg_crapgrp INDEX BY VARCHAR2(100);

  /* Procedure para controlar a formação de grupos econômicos */
  PROCEDURE pc_forma_grupo_economico(pr_cdcooper    IN PLS_INTEGER                       --> Código da cooperativa
                                    ,pr_cdagenci    IN PLS_INTEGER DEFAULT 0             --> Código da agência
                                    ,pr_nrdcaixa    IN PLS_INTEGER                       --> Número do caixa
                                    ,pr_cdoperad    IN VARCHAR2                          --> Cooperado
                                    ,pr_cdprogra    IN VARCHAR2                          --> Programa em execução
                                    ,pr_idorigem    IN PLS_INTEGER                       --> Identificação de origem
                                    ,pr_persocio    IN NUMBER                            --> Sócio
                                    ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE          --> Pool de consulta de datas do sistema
                                    ,pr_tab_grupo   IN OUT NOCOPY typ_tab_crapgrp        --> PL Table para armazenar grupos econômicos
                                    ,pr_cdcritic    OUT PLS_INTEGER                      --> Código da crítica
                                    ,pr_dscritic    OUT VARCHAR2);                       --> Descrição da crítica

  /* Procedure responsavel por calcular e gravar o risco e o endividamento do grupo */
  PROCEDURE pc_calc_endivid_risco_grupo(pr_cdcooper    IN PLS_INTEGER                    --> Código da cooperativa
                                       ,pr_cdagenci    IN PLS_INTEGER                    --> Agência
                                       ,pr_nrdcaixa    IN PLS_INTEGER                    --> Número de caixa
                                       ,pr_cdoperad    IN VARCHAR2                       --> Código cooperativa adicional
                                       ,pr_cdprogra    IN VARCHAR2                       --> Código programa
                                       ,pr_idorigem    IN PLS_INTEGER                    --> Origem
                                       ,pr_nrdgrupo    IN PLS_INTEGER                    --> Número do grupo
                                       ,pr_tpdecons    IN BOOLEAN                        --> Tipo de consulta
                                       ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE       --> Informações de data do sistema
                                       ,pr_tab_grupo   IN OUT NOCOPY typ_tab_crapgrp     --> Tabela de grupos
                                       ,pr_dstextab    IN craptab.dstextab%TYPE          --> Valor de descrição e taxas
                                       ,pr_dsdrisco    OUT VARCHAR2                      --> Descrição do risco
                                       ,pr_vlendivi    OUT NUMBER                        --> Valor dívida
                                       ,pr_des_erro    OUT VARCHAR2);                    --> Descrição de erros

  /* Procedure para gravar log de simulação */
  PROCEDURE pc_log_simula_perc(pr_cdcooper IN PLS_INTEGER --> Código da cooperativa
                              ,pr_dtmvtolt IN DATE        --> Data de movimento
                              ,pr_cdoperad IN VARCHAR2    --> Código de operação
                              ,pr_persocio IN NUMBER      --> sócio
                              ,pr_cdprogra IN VARCHAR2);  --> Programa

  /* Procedure que calcula o risco de um cooperado */
  PROCEDURE pc_calc_risco_individual(pr_cdcooper  IN PLS_INTEGER            --> Código do cooperado
                                    ,pr_nrctasoc  IN PLS_INTEGER            --> Número da conta do associado
                                    ,pr_dtrefere  IN DATE                   --> Data de referencia
                                    ,pr_dstextab  IN craptab.dstextab%TYPE  --> Execução de parâmetros
                                    ,pr_innivris  OUT PLS_INTEGER           --> Indicador do risco
                                    ,pr_dsdrisco  OUT VARCHAR2              --> Descrição do risco
                                    ,pr_des_erro  OUT VARCHAR2);            --> Descrição do erro

  /* Procedure que calcula o endividamento de um cooperado */
  PROCEDURE pc_calc_endividamento_individu(pr_cdcooper    IN PLS_INTEGER                     --> Código da cooperativa
                                          ,pr_cdagenci    IN PLS_INTEGER                   --> Código da agencia
                                          ,pr_nrdcaixa    IN PLS_INTEGER                   --> Número do caixa
                                          ,pr_cdoperad    IN VARCHAR2                      --> Código do cooperado
                                          ,pr_nmdatela    IN VARCHAR2                      --> Nome da tela
                                          ,pr_idorigem    IN PLS_INTEGER                   --> Identificador de origem
                                          ,pr_nrctasoc    IN PLS_INTEGER                   --> Conta associado
                                          ,pr_idseqttl    IN PLS_INTEGER                   --> Sequencia de títulos
                                          ,pr_tpdecons    IN BOOLEAN                       --> Tipo de consulta
                                          ,pr_vlutiliz    OUT NUMBER                       --> Valor utilizado
                                          ,pr_cdcritic    OUT PLS_INTEGER                  --> PL Table para armazenar erros
                                          ,pr_des_erro    OUT VARCHAR2                     --> Descrição do erro
                                          ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE);    --> Tabela de datas
                                          
  /*******************************************************************************/
  /**   Procedure retorna se a conta em questao pertence a algum grupo e qual e,**/
  /**   se o grupo economico esta sendo gerado.                                 **/
  /*******************************************************************************/
  PROCEDURE pc_busca_grupo_associado
                            (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa                            
                            ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                            ------ OUT ------
                            ,pr_flggrupo  OUT INTEGER              --> Retorna se conta pertence a um grupo
                            ,pr_nrdgrupo  OUT crapgrp.nrdgrupo%TYPE--> retorna numero do grupo
                            ,pr_gergrupo  OUT VARCHAR2             --> Retorna grupo economico
                            ,pr_dsdrisgp  OUT crapgrp.dsdrisgp%TYPE); --> retona descrição do grupo                                          

  /* Procedure responsavel por calcular o endividamento do grupo  */
  PROCEDURE pc_calc_endivid_grupo(pr_cdcooper  IN INTEGER                    --> Codigo da cooperativa
                                 ,pr_cdagenci  IN INTEGER                    --> Codigo da agencia
                                 ,pr_nrdcaixa  IN INTEGER                    --> Numero do caixa
                                 ,pr_cdoperad  IN VARCHAR2                   --> Codigo do operador
                                 ,pr_nmdatela  IN VARCHAR2                   --> Nome da tela
                                 ,pr_idorigem  IN INTEGER                    --> Identificação de origem
                                 ,pr_nrdgrupo  IN INTEGER                    --> Número do grupo
                                 ,pr_tpdecons  IN BOOLEAN                    --> Tipo de consulta
                                 ,pr_dsdrisco OUT VARCHAR2                   --> Descrição do risco
                                 ,pr_vlendivi OUT NUMBER                     --> Valor dívida
                                 ,pr_tab_grupo IN OUT NOCOPY typ_tab_crapgrp --> PL Table para armazenar grupos econômicos
                                 ,pr_cdcritic OUT INTEGER                    --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2);                 --> Descricao da critica
  
END geco0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.geco0001 IS
  /* PL Table para dados dos associados */
  TYPE typ_reg_crapass IS
    RECORD(inpessoa crapass.inpessoa%TYPE
          ,dtelimin crapass.dtelimin%TYPE
          ,cdagenci crapass.cdagenci%TYPE
          ,cdcooper crapass.cdcooper%TYPE
          ,nrdconta crapass.nrdconta%TYPE
          ,nrcpfcgc crapass.nrcpfcgc%TYPE);
  -- Definição para PL Table de associados
  TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(50);
  vr_tab_crapass  typ_tab_crapass;

  /* PL Table para dados de pessoas jurídicas */
  TYPE typ_reg_crapjur IS
    RECORD(natjurid crapjur.natjurid%TYPE
          ,nrdconta crapjur.nrdconta%TYPE);
  -- Definição para PL Table de associados
  TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY VARCHAR2(50);
  vr_tab_crapjur typ_tab_crapjur;

  /* PL Table para manter os dados da tabela gncdntj */
  TYPE typ_reg_gncdntj IS
    RECORD(cdnatjur gncdntj.cdnatjur%TYPE);
  -- Definição da PL Table
  TYPE typ_tab_gncdntj IS TABLE OF typ_reg_gncdntj INDEX BY VARCHAR2(20);

  -- Variável global com os tipos de risco
  vr_dsdrisco  VARCHAR2(150) := 'AA,A,B,C,D,E,F,G,H,HH';

  --> Grava informações para log
  -- Inclusao do log padrão - Chamado 883190
  PROCEDURE pc_gera_log(pr_cdcooper      IN NUMBER
                       ,pr_dstiplog      IN VARCHAR2       -- Tipo Log
                       ,pr_cdprogra      IN VARCHAR2
                       ,pr_dscritic      IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                       ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                       ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0
                       ,pr_tpocorrencia  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2) IS
    BEGIN         
    --> Controlar geração de log de execução dos jobs
    --Como executa na cadeira, utiliza pc_gera_log_batch
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper   
                              ,pr_ind_tipo_log  => pr_tpocorrencia 
                              ,pr_nmarqlog      => 'proc_batch.log'  
                              ,pr_dstiplog      => NVL(pr_dstiplog,'E')
                              ,pr_cdprograma    => NVL(pr_cdprogra,'GECO0001')
                              ,pr_tpexecucao    => 1 -- batch      
                              ,pr_cdcriticidade => pr_cdcriticidade
                              ,pr_cdmensagem    => pr_cdmensagem    
                              ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                  ||NVL(pr_cdprogra,'GECO0001')||'-->'||pr_dscritic);
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_gera_log;

  /* Procedure para montar a 'arvore' de ligações do grupo economico SIMULANDO */
  PROCEDURE pc_monta_arvore(pr_cdcooper    IN PLS_INTEGER                 --> Código da cooperativa
                           ,pr_dtmvtolt    IN DATE                        --> Data do movimento
                           ,pr_nrdgrupo    IN PLS_INTEGER                 --> Número do grupo
                           ,pr_nrdconta    IN PLS_INTEGER                 --> Número da conta
                           ,pr_nrcpfcgc    IN NUMBER                      --> CNPJ/CPF
                           ,pr_des_erro    OUT VARCHAR2) IS               --> Erros do processo
  /* .............................................................................

   Programa: pc_monta_arvore       (Antigo: b1wgen0138.p --> monta_arvore)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter
   Data    : Setembro/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Procedure para montar a 'arvore' de ligacoes do grupo economico SIMULANDO.

   Alteracoes: 19/09/2013 - Conversão Progress >> Oracle (PLSQL) (Petter - Supero)

               29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                          - Padronização erros comandos DDL
                          - Pc_set_modulo, cecred.pc_internal_exception
                          - Tratamento erros others
                          - O parâmetro pr_des_erro estava sendo setado = 'OK' no final da rotina, 
                            ou seja, caso ocorresse erro durante a rotina, o mesmo não seria registrado
                            Alterado para setar no início do programa, e retornar corretamente as 
                            possíveis alterações nesse parâmetro
                           (Ana - Envolti - Chamado 813390 / 813391)
  ............................................................................. */
  BEGIN
    DECLARE
      /* PL Table para armazenar naturezas de operação */
      TYPE typ_reg_gncdntj IS
        RECORD(cdnatjur gncdntj.cdnatjur%TYPE);
      TYPE typ_tab_gncdntj IS TABLE OF typ_reg_gncdntj INDEX BY PLS_INTEGER;

      vr_index       PLS_INTEGER := 0;      --> Contador de índice para a PL Table
      vr_vindex      VARCHAR2(400);         --> Índice composto genérico para PL Table
      vr_erro        EXCEPTION;             --> Controle de erros
      vr_tab_gncdntj typ_tab_gncdntj;       --> PL Table para armazenar dados da tabela GNCDNTJ
      vr_cdcritic     PLS_INTEGER;          --> Código da crítica

      /* Busca dados de associados */
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS  --> Código do associado
        SELECT cs.inpessoa
              ,cs.dtelimin
              ,cs.cdagenci
              ,cs.cdcooper
              ,LAG(cs.cdcooper) OVER(ORDER BY cs.cdcooper) cdcooperAnt
              ,cs.nrdconta
              ,cs.nrcpfcgc
              ,LAG(cs.nrcpfcgc) OVER(ORDER BY cs.nrcpfcgc) nrcpfcgcAnt
        FROM crapass cs
        WHERE cs.cdcooper = pr_cdcooper
        ORDER BY cs.cdcooper
                ,cs.nrcpfcgc
                ,cs.progress_recid;

      /* Buscar dados dos formadores de grupos controlando o titular dos grupos */
      CURSOR cr_crapgrp(pr_cdcooper IN crapgrp.cdcooper%TYPE      --> Código do associado
                       ,pr_nrdgrupo IN crapgrp.nrdgrupo%TYPE      --> Número do grupo
                       ,pr_nrcpfcgc IN crapgrp.nrcpfcgc%TYPE      --> CNPJ/CPF
                       ,pr_nrdconta IN crapgrp.nrdconta%TYPE      --> Número da conta
                       ,pr_idseqttl IN crapgrp.idseqttl%TYPE) IS  --> ID da sequencia
        SELECT cg.progress_recid
        FROM crapgrp cg
        WHERE cg.cdcooper = pr_cdcooper
          AND cg.nrdgrupo = pr_nrdgrupo
          AND cg.nrcpfcgc = pr_nrcpfcgc
          AND cg.nrdconta = pr_nrdconta
          AND (cg.idseqttl = pr_idseqttl
           OR (cg.idseqttl = decode(pr_idseqttl, NULL, 1)
               OR cg.idseqttl = decode(pr_idseqttl, NULL, 999)
               OR cg.idseqttl = decode(pr_idseqttl, NULL, 997)));
      rw_crapgrp cr_crapgrp%ROWTYPE;

      /* Buscar grupos de formação para novas inclusões "filhas" */
      CURSOR cr_crapgrp10(pr_cdcooper IN crapgrp.cdcooper%TYPE      --> Código do associado
                         ,pr_nrdgrupo IN crapgrp.nrdgrupo%TYPE      --> Número do grupo
                         ,pr_nrcpfcgc IN crapgrp.nrcpfcgc%TYPE      --> CNPJ/CPF
                         ,pr_nrdconta IN crapgrp.nrdconta%TYPE      --> Número da conta
                         ,pr_idseqttl IN crapgrp.idseqttl%TYPE) IS  --> ID da sequencia
        SELECT cg.progress_recid
             ,cg.cdcooper
             ,cg.nrdgrupo
             ,cg.nrdconta
             ,cg.nrctasoc
             ,cg.nrcpfcgc
             ,cg.inpessoa
             ,cg.idseqttl
             ,cg.cdagenci
             ,cg.dtmvtolt
        FROM crapgrp cg
        WHERE cg.cdcooper = pr_cdcooper
          AND cg.nrdgrupo = pr_nrdgrupo
          AND cg.nrcpfcgc = pr_nrcpfcgc
          AND cg.nrdconta = pr_nrdconta
          AND cg.idseqttl = pr_idseqttl;
      rw_crapgrp10 cr_crapgrp10%ROWTYPE;

      /* Buscar dados de pessoas jurídicas */
      CURSOR cr_crapjur(pr_cdcooper IN crapass.cdcooper%TYPE) IS  --> Código do associado
        SELECT cj.natjurid
              ,cj.nrdconta
              ,lag(cj.nrdconta) over(ORDER BY cj.nrdconta) nrdcontaAnt
        FROM crapjur cj
        WHERE cj.cdcooper = pr_cdcooper
        ORDER BY cj.progress_recid;

      /* Join das tabelas CRAPASS e CRAPTTL para grupos de pessoa física pelo titular do grupo e que não foram eliminados */
      CURSOR cr_ttlass(pr_cdcooper IN crapttl.cdcooper%TYPE       --> Código da cooperativa
                      ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS   --> Númedor do CNPJ/CPF
        SELECT cl.cdcooper
              ,cl.nrcpfcgc
              ,cl.nrdconta
              ,cl.idseqttl
              ,ca.cdagenci
        FROM crapttl cl, crapass ca
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.nrcpfcgc = pr_nrcpfcgc
          AND cl.idseqttl = 1
          AND cl.cdcooper = ca.cdcooper
          AND cl.nrdconta = ca.nrdconta
          AND ca.dtelimin IS NULL
        ORDER BY ca.nrdconta;

      /* Join das tabelas CRAPASS, CRAPJUR e GNCDNTJ para grupos de associados */
      CURSOR cr_crajurgnc(pr_cdcooper IN crapass.cdcooper%TYPE       --> Código da cooperativa
                         ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS   --> Númedor do CNPJ/CPF
        SELECT cp.cdcooper
              ,cp.nrcpfcgc
              ,cp.nrdconta
              ,cp.cdagenci
              ,cp.inpessoa
              ,cj.natjurid
        FROM crapass cp, crapjur cj
        WHERE cp.cdcooper = pr_cdcooper
          AND cp.nrcpfcgc = pr_nrcpfcgc
          AND cp.dtelimin IS NULL
          AND cj.cdcooper = cp.cdcooper
          AND cj.nrdconta = cp.nrdconta
        ORDER BY cj.nrdconta;

      /* Buscar informações sobre a natureza de operação pela posição societária */
      CURSOR cr_gncdntj IS
        SELECT gn.cdnatjur
        FROM gncdntj gn
        WHERE gn.flgprsoc = 1;

    BEGIN

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_monta_arvore');

  	  -- Indicador de sucesso
      pr_des_erro := 'OK';

      -- Verifica se é necessário carregar PL Table
      IF vr_tab_gncdntj.count = 0 THEN
        FOR registro IN cr_gncdntj LOOP
          vr_tab_gncdntj(registro.cdnatjur).cdnatjur := registro.cdnatjur;
        END LOOP;
      END IF;

      -- Verifica se é necessário carregar PL Table
      IF vr_tab_crapass.count = 0 THEN
        -- Gerar PL Table
        FOR registro IN cr_crapass(pr_cdcooper) LOOP
          -- Cria registro para posicionar índice
          IF (lpad(registro.cdcooper, 3, '0') || lpad(registro.nrcpfcgc, 20, '0')) <>
             (lpad(nvl(registro.cdcooperAnt, 0), 3, '0') || lpad(nvl(registro.nrcpfcgcAnt, 0), 20, '0')) THEN
            vr_index := 1;
          ELSE
            vr_index := vr_index + 1;
          END IF;

          -- Criar índice para PL Table
          vr_vindex := lpad(registro.cdcooper, 3, '0') || lpad(registro.nrcpfcgc, 20, '0') || lpad(vr_index, 10, '0');

          vr_tab_crapass(vr_vindex).inpessoa := registro.inpessoa;
          vr_tab_crapass(vr_vindex).dtelimin := registro.dtelimin;
          vr_tab_crapass(vr_vindex).cdagenci := registro.cdagenci;
          vr_tab_crapass(vr_vindex).cdcooper := registro.cdcooper;
          vr_tab_crapass(vr_vindex).nrdconta := registro.nrdconta;
          vr_tab_crapass(vr_vindex).nrcpfcgc := registro.nrcpfcgc;
        END LOOP;
      END IF;

      -- Verifica se é necessário carregar PL Table
      IF vr_tab_crapjur.count = 0 THEN
        -- Gerar PL Table
        FOR registro IN cr_crapjur(pr_cdcooper) LOOP
          -- Cria registro para posicionar índice
          IF lpad(registro.nrdconta, 20, '0') <> lpad(nvl(registro.nrdcontaAnt, 0), 20, '0') THEN
            vr_index := 1;
          ELSE
            vr_index := vr_index + 1;
          END IF;

          -- Criar índice para PL Table
          vr_vindex := lpad(registro.nrdconta, 20, '0') || lpad(vr_index, 10, '0');

          vr_tab_crapjur(vr_vindex).natjurid := registro.natjurid;
          vr_tab_crapjur(vr_vindex).nrdconta := registro.nrdconta;
        END LOOP;
      END IF;

      -- Verifica se existe registro de associado
      IF vr_tab_crapass.exists(lpad(pr_cdcooper, 3, '0') || lpad(pr_nrcpfcgc, 20, '0') || lpad('1', 10, '0')) THEN
        -- Monta vínculos de pessoa física
        IF vr_tab_crapass(lpad(pr_cdcooper, 3, '0') || lpad(pr_nrcpfcgc, 20, '0') || lpad('1', 10, '0')).inpessoa = 1 THEN
          FOR rw_ttlass IN cr_ttlass(pr_cdcooper, pr_nrcpfcgc) LOOP
            -- Se não encontrar este relacionamento no grupo
            OPEN cr_crapgrp10(rw_ttlass.cdcooper, pr_nrdgrupo, rw_ttlass.nrcpfcgc, rw_ttlass.nrdconta, rw_ttlass.idseqttl);
            FETCH cr_crapgrp10 INTO rw_crapgrp10;

            -- Verifica se existe relacionamento no grupo
            IF cr_crapgrp10%NOTFOUND THEN
              CLOSE cr_crapgrp10;

              -- Criar registros de grupo
              BEGIN
                INSERT INTO crapgrp(cdcooper
                                   ,nrdgrupo
                                   ,nrdconta
                                   ,nrctasoc
                                   ,nrcpfcgc
                                   ,inpessoa
                                   ,idseqttl
                                   ,cdagenci
                                   ,dtmvtolt)
                  VALUES(rw_ttlass.cdcooper
                        ,pr_nrdgrupo
                        ,pr_nrdconta
                        ,rw_ttlass.nrdconta
                        ,rw_ttlass.nrcpfcgc
                        ,1
                        ,rw_ttlass.idseqttl
                        ,rw_ttlass.cdagenci
                        ,pr_dtmvtolt);
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                  vr_cdcritic := 1034;
                  pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'CRAPGRP:' 
                                 ||' cdcooper:'||rw_ttlass.cdcooper
                                 ||', nrdgrupo:'||pr_nrdgrupo
                                 ||', nrdconta:'||pr_nrdconta
                                 ||', nrctasoc:'||rw_ttlass.nrdconta
                                 ||', nrcpfcgc:'||rw_ttlass.nrcpfcgc
                                 ||', inpessoa:1, idseqttl:'||rw_ttlass.idseqttl
                                 ||', cdagenci:'||rw_ttlass.cdagenci
                                 ||', dtmvtolt:'||pr_dtmvtolt
                                 ||'. '||SQLERRM;
                  RAISE vr_erro;
              END;
            ELSE
              CLOSE cr_crapgrp10;
            END IF;
          END LOOP;
        ELSE
          -- Consulta se localiza registros de grupos com o mesmo CNPJ/CPF
          FOR rw_crajurgnc IN cr_crajurgnc(pr_cdcooper, pr_nrcpfcgc) LOOP
            --- Verifica se a natureza de operação existe
            IF vr_tab_gncdntj.exists(rw_crajurgnc.natjurid) THEN
              -- Busca dados de grupos com o mesmo número de conta
              OPEN cr_crapgrp(rw_crajurgnc.cdcooper, pr_nrdgrupo, rw_crajurgnc.nrcpfcgc, rw_crajurgnc.nrdconta, NULL);
              FETCH cr_crapgrp INTO rw_crapgrp;

              -- Verifica se foi localizado grupo
              IF cr_crapgrp%NOTFOUND THEN
                CLOSE cr_crapgrp;

				-- Se não encontrar vai criar grupo
                BEGIN
                  INSERT INTO crapgrp(cdcooper
                                     ,nrdgrupo
                                     ,nrdconta
                                     ,nrctasoc
                                     ,nrcpfcgc
                                     ,inpessoa
                                     ,idseqttl
                                     ,cdagenci
                                     ,dtmvtolt)
                    VALUES(rw_crajurgnc.cdcooper
                          ,pr_nrdgrupo
                          ,rw_crajurgnc.nrdconta
                          ,rw_crajurgnc.nrdconta
                          ,rw_crajurgnc.nrcpfcgc
                          ,rw_crajurgnc.inpessoa
                          ,1
                          ,rw_crajurgnc.cdagenci
                          ,pr_dtmvtolt);
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                    vr_cdcritic := 1034;
                    pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'CRAPGRP:' 
                                   ||' cdcooper:'||rw_crajurgnc.cdcooper
                                   ||', nrdgrupo:'||pr_nrdgrupo
                                   ||', nrdconta:'||rw_crajurgnc.nrdconta
                                   ||', nrctasoc:'||rw_crajurgnc.nrdconta
                                   ||', nrcpfcgc:'||rw_crajurgnc.nrcpfcgc
                                   ||', inpessoa:'||rw_crajurgnc.inpessoa||', idseqttl:1'
                                   ||', cdagenci:'||rw_crajurgnc.cdagenci
                                   ||', dtmvtolt:'||pr_dtmvtolt
                                   ||'. '||SQLERRM;
                    RAISE vr_erro;
                END;
              ELSE
                CLOSE cr_crapgrp;
              END IF;
            END IF;
          END LOOP;
        END IF;
      END IF;

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);

    EXCEPTION
      WHEN vr_erro THEN
        pr_des_erro := pr_des_erro;

        --Log - Chamado 883190
        --Grava aqui porque na rotina chamadora não tem o campo cdcritic 
        --para atualizar na tbgen_porglog_ocorrencia
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => NULL
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_des_erro
                   ,pr_cdcriticidade => 1
                   ,pr_cdmensagem    => vr_cdcritic
                   ,pr_tpocorrencia  => 2);  --grava 1

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'geco0001.pc_monta_arvore. '|| SQLERRM;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => NULL
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_des_erro
                   ,pr_cdcriticidade => 2
                   ,pr_cdmensagem    => vr_cdcritic
                   ,pr_tpocorrencia  => 3);  --grava 2

    END;
  END pc_monta_arvore;

  /* Procedure para mesclar os grupos economicos */
  PROCEDURE pc_mesclar_grupos(pr_cdcooper IN PLS_INTEGER                --> Código da cooperativa
                             ,pr_nrdgrupo IN PLS_INTEGER                --> Número do grupo
                             ,pr_cdcritic OUT NUMBER
                             ,pr_des_erro OUT VARCHAR2) IS              --> Descrição de erros
  /* .............................................................................

   Programa: pc_mesclar_grupos       (Antigo: b1wgen0138.p --> mesclar-grupos)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter
   Data    : Setembro/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Mescla a formação dos grupos economicos, por cooperativa e grupo.

   Alteracoes: 19/09/2013 - Conversão Progress >> Oracle (PLSQL) (Petter - Supero)
    
               17/11/2014 - Melhorias de Performance. Foram retirados os selects internos
                            dos updates e criado o cursor cr_outro para selecionar os dados
                            necessários uma única vez. 
               
               29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                          - Padronização erros comandos DDL
                          - Pc_set_modulo, cecred.pc_internal_exception
                          - Tratamento erros others
                          - Retirada a exception vr_exc_erro, não é utilizada
                           (Ana - Envolti - Chamado 813390 / 813391)
  ............................................................................. */
  BEGIN
    DECLARE
      vr_continue   BOOLEAN:= TRUE;             --> COntrole Loop
      vr_achou      BOOLEAN:= TRUE;             --> Controle cpf outro grupo
      vr_cdcritic   PLS_INTEGER;
      
      /* Buscar dados primários na formação de grupos */
    	CURSOR cr_crapgrp(pr_cdcooper  IN crapgrp.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nrdgrupo  IN crapgrp.nrdgrupo%TYPE) IS  --> Número do grupo
        SELECT cg.cdcooper
              ,cg.nrcpfcgc
              ,cg.nrdgrupo
              ,count(distinct cg.nrdgrupo) over (partition by cg.cdcooper,cg.nrcpfcgc) qtd 
        FROM crapgrp cg
        WHERE cg.cdcooper = pr_cdcooper
          AND cg.nrdgrupo = nvl(pr_nrdgrupo, cg.nrdgrupo);

      /* Buscar Cpfs que possuem mais de 1 grupo */
    	CURSOR cr_outro (pr_cdcooper  IN crapgrp.cdcooper%TYPE      --> Código da cooperativa
                      ,pr_nrcpfcgc  IN crapgrp.nrcpfcgc%TYPE      --> Numero CPF
                      ,pr_nrdgrupo  IN crapgrp.nrdgrupo%TYPE) IS  --> Número do grupo
        SELECT cp.nrdgrupo
        FROM crapgrp cp
        WHERE cp.cdcooper = pr_cdcooper
        AND   cp.nrcpfcgc = pr_nrcpfcgc
        AND   cp.nrdgrupo <> pr_nrdgrupo
        ORDER BY cp.progress_recid;
      rw_outro cr_outro%rowtype;
      
    BEGIN
        
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_mesclar_grupos');

      WHILE vr_continue LOOP

        --Marcar para nao continuar
        vr_continue:= FALSE;

        -- Verifica se o número do grupo é zero para agregar grupos por CPF/CNPJ
        IF pr_nrdgrupo = 0 THEN   
          FOR rw_crapgrp IN cr_crapgrp(pr_cdcooper, NULL) LOOP
            --Se possuir mais de um grupo para o cpf/cnpj
            IF rw_crapgrp.qtd > 1 THEN 
              --verificar se o cpf esta em outro grupo
              OPEN cr_outro (rw_crapgrp.cdcooper
                            ,rw_crapgrp.nrcpfcgc
                            ,rw_crapgrp.nrdgrupo);
              FETCH cr_outro INTO rw_outro;

              --verificar se achou outro grupo no mesmo cpf
              vr_achou:= cr_outro%FOUND;
              CLOSE cr_outro;
              
              IF vr_achou THEN
                BEGIN
                -- Atualiza agregamento dos participantes nos grupos
                UPDATE crapgrp gp
                  SET    gp.nrdgrupo = rw_outro.nrdgrupo
                  WHERE  gp.cdcooper = pr_cdcooper
                  AND    gp.nrdgrupo = rw_crapgrp.nrdgrupo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                    pr_cdcritic := 1035;
                    pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                   ||' nrdgrupo:'||rw_outro.nrdgrupo
                                   ||' com cdcooper:'||pr_cdcooper
                                   ||', nrdgrupo:'||rw_crapgrp.nrdgrupo
                                   ||'. '||SQLERRM;

                END;
                -- Condição para interromper o loop
                vr_continue:= TRUE;
                EXIT;
              END IF; --vr_achou
            END IF;
          END LOOP;
        ELSE
        -- Busca registros de grupos
          FOR rw_crapgrp IN cr_crapgrp(pr_cdcooper, pr_nrdgrupo) LOOP
            --Se possuir mais de um grupo para o cpf/cnpj
            IF rw_crapgrp.qtd > 1 THEN 
              --verificar se o cpf esta em outro grupo
              OPEN cr_outro (rw_crapgrp.cdcooper
                            ,rw_crapgrp.nrcpfcgc
                            ,rw_crapgrp.nrdgrupo);
              FETCH cr_outro INTO rw_outro;

              --verificar se achou outro grupo no mesmo cpf
              vr_achou:= cr_outro%FOUND;
              CLOSE cr_outro;
              --se encontrou o cpf em outro grupo
              IF vr_achou THEN
                BEGIN
                -- Atualiza agregamento dos participantes nos grupos
                UPDATE crapgrp gp
                  SET    gp.nrdgrupo = rw_outro.nrdgrupo
                  WHERE  gp.cdcooper = pr_cdcooper
                  AND    gp.nrdgrupo = pr_nrdgrupo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                    pr_cdcritic := 1035;
                    pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                   ||' nrdgrupo:'||rw_outro.nrdgrupo
                                   ||' com cdcooper:'||pr_cdcooper
                                   ||', nrdgrupo:'||pr_nrdgrupo
                                   ||'. '||SQLERRM;
                END;

                -- Condição para interromper o loop
                vr_continue:= TRUE;
                EXIT;
              END IF; --vr_achou  
            END IF;  
          END LOOP; --cr_crapgrp
        END IF;
      END LOOP; --vr_continue
      
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);

    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        pr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic)||'geco0001.pc_mesclar_grupos. '|| SQLERRM;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => NULL
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_des_erro
                   ,pr_cdcriticidade => 2
                   ,pr_cdmensagem    => pr_cdcritic
                   ,pr_tpocorrencia  => 3);  --grava 2

    END;
  END pc_mesclar_grupos;

  /* Procedure para controlar a formação de grupos econômicos */
  PROCEDURE pc_forma_grupo_economico(pr_cdcooper    IN PLS_INTEGER                       --> Código da cooperativa
                                    ,pr_cdagenci    IN PLS_INTEGER DEFAULT 0             --> Código da agência
                                    ,pr_nrdcaixa    IN PLS_INTEGER                       --> Número do caixa
                                    ,pr_cdoperad    IN VARCHAR2                          --> Cooperado
                                    ,pr_cdprogra    IN VARCHAR2                          --> Programa em execução
                                    ,pr_idorigem    IN PLS_INTEGER                       --> Identificação de origem
                                    ,pr_persocio    IN NUMBER                            --> Sócio
                                    ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE          --> Pool de consulta de datas do sistema
                                    ,pr_tab_grupo   IN OUT NOCOPY typ_tab_crapgrp        --> PL Table para armazenar grupos econômicos
                                    ,pr_cdcritic    OUT PLS_INTEGER                      --> Código da crítica
                                    ,pr_dscritic    OUT VARCHAR2) IS                     --> Descrição da crítica
  /* .............................................................................

   Programa: pc_forma_grupo_economico       (Antigo: b1wgen0138.p --> forma-grupo-economico)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter
   Data    : Setembro/2013.                        Ultima atualizacao: 28/03/2018

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Controla formação de grupo economico

   Alteracoes: 13/09/2013 - Conversão Progress >> Oracle (PLSQL) (Petter - Supero)

               18/12/2017 - Melhorias performance 
                          - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                          - Padronização erros comandos DDL
                          - Pc_set_modulo, cecred.pc_internal_exception
                          - Tratamento erros others
                          - Incluída validação para restringir a query: cp.dtdemiss IS NULL
                           (Ana - Envolti - Chamado 813390 / 813391)

	           14/03/2018 - Ajuste para considear contas em prejuízo com data de 
                            eliminação preenchida. (Reginaldo - AMcom)

               28/03/2018 - Ajuste nos cursores para manter o DTELIMIN e o prejuízo.
                            (Reginaldo - AMcom)
  ............................................................................. */
  BEGIN
    DECLARE
      /* PL Table para manter os dados da tabela CRAPASS */
      TYPE typ_reg_crapass IS
        RECORD(cdcooper crapass.cdcooper%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,dtelimin crapass.dtelimin%TYPE
              ,inpessoa crapass.inpessoa%TYPE);
      TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(40);

      /* PL Table para manter os dados da tabela CRAPJUR */
      TYPE typ_reg_crapjur IS
        RECORD(natjurid crapjur.natjurid%TYPE);
      TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY VARCHAR2(15);

      /* PL Table para manter os dados da tabela CRAPTTL */
      TYPE typ_reg_crapttl IS
        RECORD(cdcooper crapttl.cdcooper%TYPE
              ,nrdconta crapttl.nrdconta%TYPE
              ,inhabmen crapttl.inhabmen%TYPE
              ,dtnasttl crapttl.dtnasttl%TYPE);
      TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY VARCHAR2(20);

      /* PL table para manter os dados da tabela CRAPCRL */
      TYPE typ_reg_crapcrl IS
        RECORD(nrdconta  crapcrl.nrdconta%TYPE
              ,nrctamen  crapcrl.nrctamen%TYPE
              ,nrcpfmen  crapcrl.nrcpfmen%TYPE
              ,nrctamena crapcrl.nrctamen%TYPE);
      TYPE typ_tab_crapcrl IS TABLE OF typ_reg_crapcrl INDEX BY VARCHAR2(30);

      vr_nrdgrupo     PLS_INTEGER := 0;  --> Número do grupo
      vr_nrultgrp     PLS_INTEGER := 0;  --> Número do último grupo
      vr_nrdeanos     PLS_INTEGER;       --> Número de anos
      vr_nrdmeses     PLS_INTEGER;       --> Número de meses
      vr_dsdidade     VARCHAR2(100);     --> Descrição idade
      vr_nrdconta     PLS_INTEGER;       --> Número da conta
      vr_nrctasoc     PLS_INTEGER;       --> Número conta de associado
      vr_nrcpfcgc     NUMBER;            --> Número de CPF/CNPJ
      vr_inpessoa     PLS_INTEGER;       --> Pessoa
      vr_cdagenci     PLS_INTEGER;       --> Código agência
      opt_vlendivi    NUMBER;            --> Opção para valor de dívida
      opt_dsdrisco    VARCHAR2(400);     --> Opção para descrição de risco
      vr_dstextab     craptab.dstextab%type; --> Descriçao do texto do parametro
      vr_tab_crapass  typ_tab_crapass;   --> PL Table para tabela CRAPASS
      vr_tab_brapass  typ_tab_crapass;   --> PL Table para tabela CRAPASS em buffer
      vr_tab_crapjur  typ_tab_crapjur;   --> PL Table para tabela CRAPJUR
      vr_tab_gncdntj  typ_tab_gncdntj;   --> PL Table para tabela gncdntj
      vr_tab_crapttl  typ_tab_crapttl;   --> PL Table para tabela CRAPTTL
      vr_tab_crapcrl  typ_tab_crapcrl;   --> PL Table para tabela CRAPCRL
      vr_tab_crapcrf  typ_tab_crapcrl;   --> PL Table para tabela CRAPCRL
      vr_index        PLS_INTEGER := 0;  --> Contador genérico para índice
      vr_indexf       PLS_INTEGER := 0;  --> Contador genérico para índice
      vr_vindex       VARCHAR2(100);     --> Indice para PL Table
      vr_erro         EXCEPTION;         --> Controle de erros - não grava log
      vr_exc_erro     EXCEPTION;         --> grava log
      vr_cdcritic     PLS_INTEGER;

      /* Buscar dados de empresas com ações societárias em outras empresas */
      CURSOR cr_crapepa(pr_cdcooper IN crapepa.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_persocio IN crapepa.persocio%TYPE) IS  --> Percentual do socio
        SELECT ca.cdcooper
              ,ca.nrdconta
              ,ca.nrctasoc
              ,ca.nrdocsoc
              ,cp.nrcpfcgc
              ,cp.cdagenci
							,DECODE(NVL((SELECT max(inprejuz)
                             FROM crapepr epr
                            WHERE epr.cdcooper = cp.cdcooper
                              AND epr.nrdconta = cp.nrdconta
                              AND epr.inprejuz = 1
                              AND epr.vlsdprej > 0
                       ),0),1,NULL,cp.dtelimin) dtelimin

        FROM crapepa ca, crapass cp
        WHERE ca.cdcooper = pr_cdcooper
          AND ca.persocio >= pr_persocio
          AND ca.cdcooper = cp.cdcooper
          AND ca.nrdconta = cp.nrdconta
          AND ((SELECT max(inprejuz)
                      FROM crapepr epr
                     WHERE epr.cdcooper = cp.cdcooper
                       AND epr.nrdconta = cp.nrdconta
                       AND epr.inprejuz = 1
                       AND epr.vlsdprej > 0
                   ) = 1 OR cp.dtelimin IS NULL);

      /* Buscar dados de associados */
      CURSOR cr_crapass(pr_cdcooper IN crapepa.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT cs.cdcooper
              ,cs.nrdconta
              ,cs.nrcpfcgc
              ,cs.cdagenci
              ,cs.inpessoa
							,DECODE(NVL((SELECT max(inprejuz)
                             FROM crapepr epr
                            WHERE epr.cdcooper = cs.cdcooper
                              AND epr.nrdconta = cs.nrdconta
                              AND epr.inprejuz = 1
                              AND epr.vlsdprej > 0
                       ),0),1,NULL,cs.dtelimin) dtelimin

        FROM crapass cs
        WHERE cs.cdcooper = pr_cdcooper;

      /* Buscar dados de pessoas jurídicas */
      CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT cr.natjurid
              ,cr.nrdconta
        FROM crapjur cr
        WHERE cr.cdcooper = pr_cdcooper;

      /* Buscar dados de tipos de natureza de operação */
      CURSOR cr_gncdntj IS
        SELECT gn.cdnatjur
              ,gn.flgprsoc
        FROM gncdntj gn;

      /* Buscar dados da formação de grupos */
      CURSOR cr_crapgrp(pr_cdcooper IN crapgrp.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nrcpfcgc IN crapgrp.nrcpfcgc%TYPE) IS  --> CNPJ/CPF
        SELECT cg.nrdgrupo
        FROM crapgrp cg
        WHERE cg.cdcooper = pr_cdcooper
          AND cg.nrcpfcgc = pr_nrcpfcgc
          AND rownum = 1
        ORDER BY cg.cdcooper
                ,cg.nrdgrupo
                ,cg.nrcpfcgc
                ,cg.nrctasoc
                ,cg.progress_recid;
      rw_crapgrp cr_crapgrp%ROWTYPE;
      rw_crapgrb cr_crapgrp%ROWTYPE;

      /* Buscar dados de titulares da conta */
      CURSOR cr_crapttl(pr_cdcooper IN crapavt.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT cl.cdcooper
              ,cl.nrdconta
              ,LAG(cl.nrdconta) OVER(ORDER BY cl.nrdconta) nrdcontaLag
              ,inhabmen
              ,dtnasttl
        FROM crapttl cl
        WHERE cl.cdcooper = pr_cdcooper
        ORDER BY cl.nrdconta
                ,cl.progress_recid;

      /* Buscar dados do cadastro do representante legal */
      CURSOR cr_crapcrl(pr_cdcooper IN crapavt.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT cl.nrdconta
              ,LAG(cl.nrctamen) OVER(ORDER BY cl.nrctamen,cl.nrcpfmen) nrctamenAnt
              ,cl.nrctamen
        FROM crapcrl cl
        WHERE cl.cdcooper = pr_cdcooper
        ORDER BY cl.nrctamen;

      /* Buscar dados do cadastro do representante legal com nova ordenação */
      CURSOR cr_crapcrlb(pr_cdcooper IN crapavt.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT cl.nrdconta
              ,LAG(cl.nrctamen) OVER(ORDER BY cl.nrctamen,cl.nrcpfmen) nrctamenAnt
              ,cl.nrctamen
              ,LAG(cl.nrcpfmen) OVER(ORDER BY cl.nrctamen,cl.nrcpfmen) nrcpfmenAnt
              ,TRUNC(cl.nrcpfmen) nrcpfmen
        FROM crapcrl cl
        WHERE cl.cdcooper = pr_cdcooper
        ORDER BY cl.nrctamen
                ,cl.nrcpfmen;

      /* Buscar dados da formação de grupos */
      CURSOR cr_crapgrpb(pr_cdcooper IN crapgrp.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT cg.nrdgrupo
              ,NVL((LAG(cg.nrdgrupo) OVER(ORDER BY cg.nrdgrupo)), 0) nrdgrupoa
        FROM crapgrp cg
        WHERE cg.cdcooper = pr_cdcooper
        ORDER BY cg.nrdgrupo;

      /* Join das tabelas CRAPASS e CRAPAVT para buscar dados os proprietários por juros e condição economica */
      CURSOR cr_vtass(pr_cdcooper IN crapavt.cdcooper%TYPE      --> Código da cooperativa
                     ,pr_persocio IN crapavt.persocio%TYPE) IS  --> Percentual do sócio
        SELECT cp.nrdconta
              ,ct.cdcooper
              ,ct.inhabmen
              ,ct.nrdctato
              ,ct.nrcpfcgc
              ,cp.nrcpfcgc nrcpfcgccp
              ,cp.inpessoa
              ,cp.cdagenci
              ,ct.dtnascto
							,DECODE(NVL((SELECT max(inprejuz)
                             FROM crapepr epr
                            WHERE epr.cdcooper = cp.cdcooper
                              AND epr.nrdconta = cp.nrdconta
                              AND epr.inprejuz = 1
                              AND epr.vlsdprej > 0
                      ),0),1,NULL,cp.dtelimin) dtelimin

        FROM crapavt ct, crapass cp
        WHERE ct.cdcooper = pr_cdcooper
          AND ct.tpctrato = 6
          AND ct.persocio >= pr_persocio
          AND ct.flgdepec = 1
          AND cp.cdcooper = ct.cdcooper
          AND cp.nrdconta = ct.nrdconta
          AND ((SELECT max(inprejuz)
                      FROM crapepr epr
                     WHERE epr.cdcooper = cp.cdcooper
                       AND epr.nrdconta = cp.nrdconta
                       AND epr.inprejuz = 1
                       AND epr.vlsdprej > 0
                   ) = 1 OR (cp.dtelimin IS NULL AND cp.dtdemiss IS NULL));

    BEGIN

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

      -- Limpar variáveis
      pr_cdcritic := 0;
      pr_dscritic := '';

      -- Buscar valores de parâmetros
      vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 0);

      -- Verifica se foram retornados parametros
      IF vr_dstextab IS NULL THEN
        pr_cdcritic := 1069;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' CRAPTAB.';
        RAISE vr_exc_erro;
      END IF;-- Executar LOG da simulação

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

      pc_log_simula_perc(pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => SYSDATE
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_persocio => pr_persocio
                        ,pr_cdprogra => pr_cdprogra);


      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

      -- Eliminar todos os grupos da cooperativa
      DELETE FROM crapgrp cp WHERE cp.cdcooper = pr_cdcooper;

      -- Carregar PL Table da tabela CRAPASS
      IF vr_tab_crapass.count = 0 THEN
        FOR registro IN cr_crapass(pr_cdcooper) LOOP
          IF registro.dtelimin IS NULL THEN
            vr_tab_crapass(lpad(registro.nrdconta, 40, '0')).cdcooper := registro.cdcooper;
            vr_tab_crapass(lpad(registro.nrdconta, 40, '0')).nrdconta := registro.nrdconta;
            vr_tab_crapass(lpad(registro.nrdconta, 40, '0')).nrcpfcgc := registro.nrcpfcgc;
            vr_tab_crapass(lpad(registro.nrdconta, 40, '0')).cdagenci := registro.cdagenci;
            vr_tab_crapass(lpad(registro.nrdconta, 40, '0')).dtelimin := registro.dtelimin;
            vr_tab_crapass(lpad(registro.nrdconta, 40, '0')).inpessoa := registro.inpessoa;

            -- Criar registro duplicado por CNPJ/CPF para atender tabela de buffer
            vr_tab_crapass(lpad(registro.nrdconta, 20, '0') || lpad(registro.nrcpfcgc, 20, '0')).nrcpfcgc := registro.nrcpfcgc;
          END IF;

          vr_tab_brapass(lpad(registro.nrdconta, 40, '0')).cdcooper := registro.cdcooper;
          vr_tab_brapass(lpad(registro.nrdconta, 40, '0')).nrdconta := registro.nrdconta;
          vr_tab_brapass(lpad(registro.nrdconta, 40, '0')).nrcpfcgc := registro.nrcpfcgc;
          vr_tab_brapass(lpad(registro.nrdconta, 40, '0')).cdagenci := registro.cdagenci;
          vr_tab_brapass(lpad(registro.nrdconta, 40, '0')).dtelimin := registro.dtelimin;
          vr_tab_brapass(lpad(registro.nrdconta, 40, '0')).inpessoa := registro.inpessoa;
        END LOOP;
      END IF;

      -- Caregar PL Table da tabela CRAPJUR
      IF vr_tab_crapjur.count = 0 THEN
        FOR registro IN cr_crapjur(pr_cdcooper) LOOP
          vr_tab_crapjur(lpad(registro.nrdconta, 15, '0')).natjurid := registro.natjurid;
        END LOOP;
      END IF;

      -- Carregar PL Table da tabela GNCDNTJ
      IF vr_tab_gncdntj.count = 0 THEN
        FOR registro IN cr_gncdntj LOOP
          vr_tab_gncdntj(lpad(registro.cdnatjur, 19, '0') || lpad(registro.flgprsoc, 1, '0')).cdnatjur := registro.cdnatjur;
        END LOOP;
      END IF;

      -- Carregar PL Tabl da tabela CRAPTTL
      IF vr_tab_crapttl.count = 0 THEN
        FOR registro IN cr_crapttl(pr_cdcooper) LOOP
          IF registro.nrdconta <> nvl(registro.nrdcontalag, 0) THEN
            vr_tab_crapttl(lpad(registro.nrdconta, 20, '0')).nrdconta := registro.nrdconta;
            vr_tab_crapttl(lpad(registro.nrdconta, 20, '0')).cdcooper := registro.cdcooper;
            vr_tab_crapttl(lpad(registro.nrdconta, 20, '0')).inhabmen := registro.inhabmen;
            vr_tab_crapttl(lpad(registro.nrdconta, 20, '0')).dtnasttl := registro.dtnasttl;
          END IF;
        END LOOP;
      END IF;

      -- Carregar PL Table da tabela CRAPCRL
      IF vr_tab_crapcrl.count = 0 THEN
        FOR registro IN cr_crapcrl(pr_cdcooper) LOOP
          IF registro.nrctamen <> nvl(registro.nrctamenant, 0) THEN
            vr_index := 1;
          ELSE
            vr_index := vr_index + 1;
          END IF;

          vr_tab_crapcrl(lpad(registro.nrctamen, 20 ,'0') || lpad(vr_index, 10, '0')).nrdconta := registro.nrdconta;
          vr_tab_crapcrl(lpad(registro.nrctamen, 20 ,'0') || lpad(vr_index, 10, '0')).nrctamen := registro.nrctamen;
          vr_tab_crapcrl(lpad(registro.nrctamen, 20 ,'0') || lpad(vr_index, 10, '0')).nrctamena := registro.nrctamenAnt;
        END LOOP;
      END IF;

      -- Carregar PL Table da tabela CRAPCRL com outros campos e ordenação
      IF vr_tab_crapcrf.count = 0 THEN
        FOR registro IN cr_crapcrlb(pr_cdcooper) LOOP
          IF registro.nrcpfmen <> nvl(registro.nrcpfmenAnt, 0) THEN
            vr_indexf := 1;
          ELSE
            vr_indexf := vr_indexf + 1;
          END IF;

          vr_tab_crapcrf(lpad(registro.nrcpfmen, 20 ,'0') || lpad(vr_indexf, 10, '0')).nrdconta := registro.nrdconta;
          vr_tab_crapcrf(lpad(registro.nrcpfmen, 20 ,'0') || lpad(vr_indexf, 10, '0')).nrctamen := registro.nrctamen;
          vr_tab_crapcrf(lpad(registro.nrcpfmen, 20 ,'0') || lpad(vr_indexf, 10, '0')).nrcpfmen := registro.nrcpfmen;
        END LOOP;
      END IF;

      -- Empresas sociais de outras empresas
      FOR rw_crapepa IN cr_crapepa(pr_cdcooper => pr_cdcooper, pr_persocio => pr_persocio) LOOP
        -- Verifica se existe registro como pessoa jurídica
        IF vr_tab_crapjur.EXISTS(lpad(rw_crapepa.nrdconta, 15, '0')) THEN
          -- Verifica se existe registro de natureza de operações
          IF vr_tab_gncdntj.EXISTS(lpad(vr_tab_crapjur(lpad(rw_crapepa.nrdconta, 15, '0')).natjurid, 19, '0') || '1') THEN
            -- Não é formado grupo se a empresa sócia proprietaria nao possuir c/c na cooperativa
            IF rw_crapepa.nrctasoc = 0 AND NOT vr_tab_crapass.exists(lpad(rw_crapepa.nrctasoc, 40, '0')) THEN
              CONTINUE;
            END IF;

            -- Não é formado o grupo se a empresa socia proprietaria não tiver percentual de soc. obrigatoria
            IF vr_tab_crapjur.exists(lpad(rw_crapepa.nrctasoc, 15, '0')) THEN
              IF vr_tab_gncdntj.exists(lpad(vr_tab_crapjur(lpad(rw_crapepa.nrctasoc, 15, '0')).natjurid, 19, '0') || '0') THEN
                CONTINUE;
              END IF;
            END IF;

            -- Não é formado grupo se a empresa socia proprietaria não possuir c/c na cooperativa
            IF NOT vr_tab_crapass.exists(lpad(rw_crapepa.nrctasoc, 40, '0')) THEN
              CONTINUE;
            ELSE
			  -- Verifica se a data de eliminação do associado é nula
              IF vr_tab_crapass(LPad(rw_crapepa.nrctasoc, 40, '0')).dtelimin IS NOT NULL THEN
                 CONTINUE;
              END IF;
            END IF;

            -- Verifica se o CNPJ da empresa ja pertence a outro grupo
            OPEN cr_crapgrp(rw_crapepa.cdcooper,rw_crapepa.nrcpfcgc);
            FETCH cr_crapgrp INTO rw_crapgrp;

            -- Verifica se o CNPJ já está em outro grupo
            IF cr_crapgrp%FOUND THEN
              CLOSE cr_crapgrp;
              vr_nrdgrupo := rw_crapgrp.nrdgrupo;
            ELSE
              CLOSE cr_crapgrp;

              -- Verifica se o CNPJ da empresa participanteja pertence a outro grupo
              OPEN cr_crapgrp(rw_crapepa.cdcooper, rw_crapepa.nrdocsoc);
              FETCH cr_crapgrp INTO rw_crapgrb;

              -- Verifica se a empresa pertence para outro grupo
              IF cr_crapgrp%FOUND THEN
                CLOSE cr_crapgrp;

                vr_nrdgrupo := rw_crapgrb.nrdgrupo;
              ELSE
                CLOSE cr_crapgrp;

				-- Assimila valores para as variáveis
                vr_nrultgrp := vr_nrultgrp + 1;
                vr_nrdgrupo := vr_nrultgrp;
                vr_nrultgrp := vr_nrdgrupo;
                vr_nrdconta := rw_crapepa.nrdconta;
                vr_nrctasoc := rw_crapepa.nrdconta;
                vr_nrcpfcgc := rw_crapepa.nrcpfcgc;
                vr_inpessoa := 2;
                vr_cdagenci := rw_crapepa.cdagenci;
              END IF;
            END IF;

            -- Cria a formadora de grupo
            BEGIN
              INSERT INTO crapgrp(cdcooper
                                 ,nrdgrupo
                                 ,nrdconta
                                 ,nrctasoc
                                 ,nrcpfcgc
                                 ,inpessoa
                                 ,idseqttl
                                 ,cdagenci
                                 ,dtmvtolt)
                 VALUES(rw_crapepa.cdcooper
                       ,vr_nrdgrupo
                       ,rw_crapepa.nrdconta
                       ,rw_crapepa.nrdconta
                       ,rw_crapepa.nrcpfcgc
                       ,2
                       ,999
                       ,rw_crapepa.cdagenci
                       ,pr_tab_crapdat.dtmvtolt);
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                pr_cdcritic := 1034;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                               ||' cdcooper:'||rw_crapepa.cdcooper
                               ||', nrdgrupo:'||vr_nrdgrupo
                               ||', nrdconta:'||rw_crapepa.nrdconta
                               ||', nrctasoc:'||rw_crapepa.nrdconta
                               ||', nrcpfcgc:'||rw_crapepa.nrcpfcgc
                               ||', inpessoa:2, idseqttl:999'
                               ||', cdagenci:'||rw_crapepa.cdagenci
                               ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                               ||'. '||SQLERRM;
                RAISE vr_exc_erro;
            END;

            -- Monta a ligação de contas desta empresa no grupo
            pc_monta_arvore(pr_cdcooper    => rw_crapepa.cdcooper
                           ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                           ,pr_nrdgrupo    => vr_nrdgrupo
                           ,pr_nrdconta    => rw_crapepa.nrdconta
                           ,pr_nrcpfcgc    => rw_crapepa.nrcpfcgc
                           ,pr_des_erro    => pr_dscritic);

            -- Verifica se ocorreram erros na formação dos grupos
            IF pr_dscritic <> 'OK' THEN
              RAISE vr_erro;
            END IF;

            -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

            -- Cria registro do grupo
            BEGIN
              INSERT INTO crapgrp(cdcooper
                                 ,nrdgrupo
                                 ,nrdconta
                                 ,nrctasoc
                                 ,nrcpfcgc
                                 ,inpessoa
                                 ,idseqttl
                                 ,cdagenci
                                 ,dtmvtolt)
                 VALUES(rw_crapepa.cdcooper
                       ,vr_nrdgrupo
                       ,rw_crapepa.nrdconta
                       ,rw_crapepa.nrctasoc
                       ,rw_crapepa.nrdocsoc
                       ,2
                       ,997
                       ,vr_tab_brapass(lpad(rw_crapepa.nrctasoc, 40, '0')).cdagenci
                       ,pr_tab_crapdat.dtmvtolt);
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                pr_cdcritic := 1034;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                               ||' cdcooper:'||rw_crapepa.cdcooper
                               ||', nrdgrupo:'||vr_nrdgrupo
                               ||', nrdconta:'||rw_crapepa.nrdconta
                               ||', nrctasoc:'||rw_crapepa.nrdconta
                               ||', nrcpfcgc:'||rw_crapepa.nrdocsoc
                               ||', inpessoa:2, idseqttl:997'
                               ||', cdagenci:'||vr_tab_brapass(lpad(rw_crapepa.nrctasoc, 40, '0')).cdagenci
                               ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                               ||'. '||SQLERRM;
                RAISE vr_exc_erro;
            END;

            -- Monta a ligação de contas desta empresa no grupo
            pc_monta_arvore(pr_cdcooper    => rw_crapepa.cdcooper
                           ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                           ,pr_nrdgrupo    => vr_nrdgrupo
                           ,pr_nrdconta    => rw_crapepa.nrctasoc
                           ,pr_nrcpfcgc    => rw_crapepa.nrdocsoc
                           ,pr_des_erro    => pr_dscritic);

            -- Verifica se ocorreram erros na formação dos grupos
            IF pr_dscritic <> 'OK' THEN
              RAISE vr_erro;
            END IF;

            -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

          END IF;
        END IF;
      END LOOP;

      -- Procuradores/socio proprietario da empresa
      FOR rw_vtass IN cr_vtass(pr_cdcooper,pr_persocio) LOOP
          -- Verifica se existe registro de pessoa jurídica
          IF vr_tab_crapjur.exists(lpad(rw_vtass.nrdconta, 15, '0')) THEN
            -- Verifica se existe registro de natureza de operação
            IF vr_tab_gncdntj.exists(lpad(vr_tab_crapjur(lpad(rw_vtass.nrdconta, 15, '0')).natjurid, 19, '0') || '1') THEN
              -- Verifica se o CNPJ ja pertence a outro grupo
              OPEN cr_crapgrp(rw_vtass.cdcooper,rw_vtass.nrcpfcgccp);
              FETCH cr_crapgrp INTO rw_crapgrp;

              -- Verifica se encontrou o CNPJ em outros grupos
              IF cr_crapgrp%FOUND THEN
                CLOSE cr_crapgrp;

                -- Assimilar código do grupo
                vr_nrdgrupo := rw_crapgrp.nrdgrupo;
                vr_nrdconta := rw_vtass.nrdconta;
                vr_nrctasoc := rw_vtass.nrdconta;
                vr_nrcpfcgc := rw_vtass.nrcpfcgccp;
                vr_inpessoa := rw_vtass.inpessoa;
                vr_cdagenci := rw_vtass.cdagenci;
              ELSE
                CLOSE cr_crapgrp;

				-- Assimilar código do novo grupo
                vr_nrdgrupo := vr_nrultgrp + 1;
                vr_nrultgrp := vr_nrdgrupo;
                vr_nrdconta := rw_vtass.nrdconta;
                vr_nrctasoc := rw_vtass.nrdconta;
                vr_nrcpfcgc := rw_vtass.nrcpfcgccp;
                vr_inpessoa := 2;
                vr_cdagenci := rw_vtass.cdagenci;
              END IF;

              -- Buscar dados do socio/proprietário para validar responsável legal
              IF vr_tab_crapttl.exists(lpad(rw_vtass.nrdctato, 20, '0')) THEN
                -- Não é formado grupo se o rep.procurador não possuir c/c na cooperativa
                IF NOT vr_tab_brapass.exists(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')) THEN
                  CONTINUE;
                ELSE
                  IF vr_tab_brapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).dtelimin IS NOT NULL THEN
                    CONTINUE;
                  END IF;
                END IF;

                -- Buscar idade
                IF vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).inhabmen = 0  OR vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).inhabmen = 2 THEN
                  -- Verifica a idade
                  cada0001.pc_busca_idade(pr_dtnasctl => vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).dtnasttl
                                         ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt
                                         ,pr_nrdeanos => vr_nrdeanos
                                         ,pr_nrdmeses => vr_nrdmeses
                                         ,pr_dsdidade => vr_dsdidade
                                         ,pr_des_erro => pr_dscritic);
                  -- Verficia se ocorreram erros
                  IF pr_dscritic IS NOT NULL THEN
                    CONTINUE;
                  END IF;

                  -- Se for menor de idade o integrante do grupo é o representante/responsavel do menor
                  IF vr_nrdeanos < 18 OR vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).inhabmen = 2 THEN
                    vr_vindex := lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 20, '0') || lpad('1', 10, '0');

                    -- Iterar sobre registros para a conta
                    LOOP
                      EXIT WHEN vr_vindex IS NULL;

                      -- Renato - verificar esta situação para ver se deve ser tratado desta forma mesmo
                      IF vr_tab_crapcrl.EXISTS(vr_vindex) THEN
                      -- Consulta o registro da conta do associado
                      IF vr_tab_crapass.exists(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')) THEN
                        IF vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).dtelimin IS NULL THEN
                          -- Detecta primeiro registro para conta formadora
                          IF vr_tab_crapcrl(vr_vindex).nrctamen <> NVL(vr_tab_crapcrl(vr_vindex).nrctamena, 9999999) THEN
                            -- Inserir novo grupo
                            BEGIN
                              INSERT INTO crapgrp(cdcooper
                                                 ,nrdgrupo
                                                 ,nrdconta
                                                 ,nrctasoc
                                                 ,nrcpfcgc
                                                 ,inpessoa
                                                 ,idseqttl
                                                 ,cdagenci
                                                 ,dtmvtolt)
                                VALUES(rw_vtass.cdcooper
                                      ,vr_nrdgrupo
                                      ,vr_nrdconta
                                      ,vr_nrctasoc
                                      ,vr_nrcpfcgc
                                      ,vr_inpessoa
                                      ,999
                                      ,vr_cdagenci
                                      ,pr_tab_crapdat.dtmvtolt);
                            EXCEPTION
                              WHEN OTHERS THEN
                                  -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                                  pr_cdcritic := 1034;
                                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                                 ||' cdcooper:'||rw_vtass.cdcooper
                                                 ||', nrdgrupo:'||vr_nrdgrupo
                                                 ||', nrdconta:'||vr_nrdconta
                                                 ||', nrctasoc:'||vr_nrctasoc
                                                 ||', nrcpfcgc:'||vr_nrcpfcgc
                                                 ||', inpessoa:'||vr_inpessoa||', idseqttl:999'
                                                 ||', cdagenci:'||vr_cdagenci
                                                 ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                                                 ||'. '||SQLERRM;
                                  RAISE vr_exc_erro;
                            END;

                            -- Monta a ligação de contas desta empresa no grupo
                            pc_monta_arvore(pr_cdcooper    => rw_vtass.cdcooper
                                           ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                                           ,pr_nrdgrupo    => vr_nrdgrupo
                                           ,pr_nrdconta    => vr_nrdconta
                                           ,pr_nrcpfcgc    => vr_nrcpfcgc
                                           ,pr_des_erro    => pr_dscritic);

                            -- Verifica se ocorreram erros
                            IF pr_dscritic <> 'OK' THEN
                              RAISE vr_erro;
                            END IF;

                              -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
                              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

                          END IF;

                          -- Cria novo grupo "filho"
                          BEGIN
                            INSERT INTO crapgrp(cdcooper
                                               ,nrdgrupo
                                               ,nrdconta
                                               ,nrctasoc
                                               ,nrcpfcgc
                                               ,inpessoa
                                               ,idseqttl
                                               ,cdagenci
                                               ,dtmvtolt)
                              VALUES(rw_vtass.cdcooper
                                    ,vr_nrdgrupo
                                    ,rw_vtass.nrdconta
                                    ,vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).nrdconta
                                    ,vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).nrcpfcgc
                                    ,1
                                    ,996
                                    ,vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).cdagenci
                                    ,pr_tab_crapdat.dtmvtolt);
                          EXCEPTION
                            WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                                pr_cdcritic := 1034;
                                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                               ||' cdcooper:'||rw_vtass.cdcooper
                                               ||', nrdgrupo:'||vr_nrdgrupo
                                               ||', nrdconta:'||rw_vtass.nrdconta
                                               ||', nrctasoc:'||vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).nrdconta
                                               ||', nrcpfcgc:'||vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).nrcpfcgc
                                               ||', inpessoa:1, idseqttl:996'
                                               ||', cdagenci:'||vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).cdagenci
                                               ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_erro;
                          END;

                          -- Monta a ligação de titulares deste responsável no grupo,
                          -- Utiliza metodo de recursão para varrer todos os titulares
                          pc_monta_arvore(pr_cdcooper    => pr_cdcooper
                                         ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                                         ,pr_nrdgrupo    => vr_nrdgrupo
                                         ,pr_nrdconta    => vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).nrdconta
                                         ,pr_nrcpfcgc    => vr_tab_crapass(lpad(vr_tab_crapcrl(vr_vindex).nrdconta, 40, '0')).nrcpfcgc
                                         ,pr_des_erro    => pr_dscritic);

                          -- Verifica se ocorreram erros
                          IF pr_dscritic <> 'OK' THEN
                            RAISE vr_erro;
                          END IF;

                            -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
                            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

                        END IF;
                      END IF;
                      END IF;
                      -- Gerar novo índice para iteração
                      IF vr_tab_crapcrl.next(vr_vindex) IS NOT NULL AND vr_tab_crapcrl(vr_tab_crapcrl.next(vr_vindex)).nrctamen = vr_tab_crapcrl(vr_vindex).nrctamen THEN
                        vr_vindex := vr_tab_crapcrl.next(vr_vindex);
                      ELSE
                        vr_vindex := NULL;
                      END IF;
                    END LOOP;

                    -- Vai para o próximo pois termina o processo no responsável
                    CONTINUE;
                  END IF;
                  END IF;
                ELSE
                  -- Buscar idade
                  IF rw_vtass.inhabmen = 0 OR rw_vtass.inhabmen = 2 THEN
                    -- Verifica se é menor de idade
                    cada0001.pc_busca_idade(pr_dtnasctl => rw_vtass.dtnascto
                                           ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt
                                           ,pr_nrdeanos => vr_nrdeanos
                                           ,pr_nrdmeses => vr_nrdmeses
                                           ,pr_dsdidade => vr_dsdidade
                                           ,pr_des_erro => pr_dscritic);

                    -- Verficia se ocorreram erros
                    IF pr_dscritic IS NOT NULL THEN
                      CONTINUE;
                    END IF;

                    -- Se for menor de idade
                    IF vr_nrdeanos < 18 OR rw_vtass.inhabmen = 2 THEN
                      -- Busca as contas/CPFs que sao responsável pelo menor
                      vr_vindex := lpad(rw_vtass.nrcpfcgc, 20, '0') || lpad('1', 10, '0');

                      -- Itera sobre os registros
                      LOOP
                        EXIT WHEN vr_vindex IS NULL;
                        
                        -- Renato Darosci - verifficar tratamento - Erro indice: nrctamen = 00000000009550354903
                        IF vr_tab_crapcrf.EXISTS(vr_vindex) THEN
                        -- Consulta o registro da conta do associado
                        IF vr_tab_crapass.exists(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')) THEN
                          IF vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).dtelimin IS NULL THEN
                            -- Detecta primeiro registro para conta formadora
                            IF vr_vindex = lpad(rw_vtass.nrcpfcgc, 20, '0') || lpad('1', 10, '0') THEN
                              -- Inserir novo grupo formador
                              BEGIN
                                INSERT INTO crapgrp(cdcooper
                                                   ,nrdgrupo
                                                   ,nrdconta
                                                   ,nrctasoc
                                                   ,nrcpfcgc
                                                   ,inpessoa
                                                   ,idseqttl
                                                   ,cdagenci
                                                   ,dtmvtolt)
                                  VALUES(rw_vtass.cdcooper
                                        ,vr_nrdgrupo
                                        ,vr_nrdconta
                                        ,vr_nrctasoc
                                        ,vr_nrcpfcgc
                                        ,vr_inpessoa
                                        ,999
                                        ,vr_cdagenci
                                        ,pr_tab_crapdat.dtmvtolt);
                              EXCEPTION
                                WHEN OTHERS THEN
                                  -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                                  pr_cdcritic := 1034;
                                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                                 ||' cdcooper:'||rw_vtass.cdcooper
                                                 ||', nrdgrupo:'||vr_nrdgrupo
                                                 ||', nrdconta:'||vr_nrdconta
                                                 ||', nrctasoc:'||vr_nrctasoc
                                                 ||', nrcpfcgc:'||vr_nrcpfcgc
                                                 ||', inpessoa:'||vr_inpessoa||', idseqttl:999'
                                                 ||', cdagenci:'||vr_cdagenci
                                                 ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                                                 ||'. '||SQLERRM;
                                  RAISE vr_exc_erro;
                              END;

                              -- Monta a ligação de contas desta empresa no grupo
                              pc_monta_arvore(pr_cdcooper    => rw_vtass.cdcooper
                                             ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                                             ,pr_nrdgrupo    => vr_nrdgrupo
                                             ,pr_nrdconta    => vr_nrdconta
                                             ,pr_nrcpfcgc    => vr_nrcpfcgc
                                             ,pr_des_erro    => pr_dscritic);

                              -- Verifica se ocorreram erros
                              IF pr_dscritic <> 'OK' THEN
                                RAISE vr_erro;
                              END IF;

                              -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
                              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

                            END IF;

                            -- Inserir novo membro no grupo
                            BEGIN
                              INSERT INTO crapgrp(cdcooper
                                                 ,nrdgrupo
                                                 ,nrdconta
                                                 ,nrctasoc
                                                 ,nrcpfcgc
                                                 ,inpessoa
                                                 ,idseqttl
                                                 ,cdagenci
                                                 ,dtmvtolt)
                                VALUES(rw_vtass.cdcooper
                                      ,vr_nrdgrupo
                                      ,rw_vtass.nrdconta
                                      ,vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).nrdconta
                                      ,vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).nrcpfcgc
                                      ,1
                                      ,996
                                      ,vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).cdagenci
                                      ,pr_tab_crapdat.dtmvtolt);
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                                pr_cdcritic := 1034;
                                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                               ||' cdcooper:'||rw_vtass.cdcooper
                                               ||', nrdgrupo:'||vr_nrdgrupo
                                               ||', nrdconta:'||rw_vtass.nrdconta
                                               ||', nrctasoc:'||vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).nrdconta
                                               ||', nrcpfcgc:'||vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).nrcpfcgc
                                               ||', inpessoa:1, idseqttl:996'
                                               ||', cdagenci:'||vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).cdagenci
                                               ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_erro;
                            END;

                            -- Monta a ligação de titulares deste responsável no grupo,
                            -- Utiliza metodo de recursão para varrer todos os titulares
                            pc_monta_arvore(pr_cdcooper    => pr_cdcooper
                                           ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                                           ,pr_nrdgrupo    => vr_nrdgrupo
                                           ,pr_nrdconta    => vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).nrdconta
                                           ,pr_nrcpfcgc    => vr_tab_crapass(lpad(vr_tab_crapcrf(vr_vindex).nrdconta, 40, '0')).nrcpfcgc
                                           ,pr_des_erro    => pr_dscritic);

                            -- Verifica se ocorreram erros
                            IF pr_dscritic <> 'OK' THEN
                              RAISE vr_erro;
                            END IF;

                            -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
                            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

                          END IF;
                        END IF;
                        END IF;
                        
                        -- Gera o índice do próximo registro
                        IF vr_tab_crapcrf.EXISTS(vr_vindex) THEN
                          IF vr_tab_crapcrf.next(vr_vindex) IS NOT NULL AND vr_tab_crapcrf(vr_tab_crapcrf.next(vr_vindex)).nrcpfmen = vr_tab_crapcrf(vr_vindex).nrcpfmen THEN
                            vr_vindex := vr_tab_crapcrf.next(vr_vindex);
                          ELSE
                            vr_vindex := NULL;
                          END IF;
                        ELSE
                          vr_vindex := NULL;
                        END IF;
                      END LOOP;

                      -- Parte para o próximo pois termina o processo no responsável
                      CONTINUE;
                    ELSE
                      -- Parte para o próximo pois sócio/proc sem conta não entra no grupo
                      CONTINUE;
                    END IF;
                  ELSE
                    -- Parte para o próximo pois sócio/proc sem conta não entra no grupo
                    CONTINUE;
                  END IF;
                END IF;

                -- Inserir conta formadora
                BEGIN
                  INSERT INTO crapgrp(cdcooper
                                     ,nrdgrupo
                                     ,nrdconta
                                     ,nrctasoc
                                     ,nrcpfcgc
                                     ,inpessoa
                                     ,idseqttl
                                     ,cdagenci
                                     ,dtmvtolt)
                    VALUES(rw_vtass.cdcooper
                          ,vr_nrdgrupo
                          ,vr_nrdconta
                          ,vr_nrctasoc
                          ,vr_nrcpfcgc
                          ,vr_inpessoa
                          ,999
                          ,vr_cdagenci
                          ,pr_tab_crapdat.dtmvtolt);
                EXCEPTION
                  WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                  pr_cdcritic := 1034;
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                 ||' cdcooper:'||rw_vtass.cdcooper
                                 ||', nrdgrupo:'||vr_nrdgrupo
                                 ||', nrdconta:'||vr_nrdconta
                                 ||', nrctasoc:'||vr_nrctasoc
                                 ||', nrcpfcgc:'||vr_nrcpfcgc
                                 ||', inpessoa:'||vr_inpessoa||', idseqttl:999'
                                 ||', cdagenci:'||vr_cdagenci
                                 ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                                 ||'. '||SQLERRM;
                  RAISE vr_exc_erro;
                END;

                -- Monta a ligação de contas desta empresa no grupo
                pc_monta_arvore(pr_cdcooper    => rw_vtass.cdcooper
                               ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                               ,pr_nrdgrupo    => vr_nrdgrupo
                               ,pr_nrdconta    => vr_nrdconta
                               ,pr_nrcpfcgc    => vr_nrcpfcgc
                               ,pr_des_erro    => pr_dscritic);

                -- Verifica se ocasionou erro
                IF pr_dscritic <> 'OK' THEN
                  RAISE vr_erro;
                END IF;

              -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

                -- Cria o relacionamento no grupo
                BEGIN
                  INSERT INTO crapgrp(cdcooper
                                     ,nrdgrupo
                                     ,nrdconta
                                     ,nrctasoc
                                     ,nrcpfcgc
                                     ,inpessoa
                                     ,idseqttl
                                     ,cdagenci
                                     ,dtmvtolt)
                    VALUES(rw_vtass.cdcooper
                          ,vr_nrdgrupo
                          ,rw_vtass.nrdconta
                          ,vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).nrdconta
                          ,vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).nrcpfcgc
                          ,vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).inpessoa
                          ,998
                          ,vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).cdagenci
                          ,pr_tab_crapdat.dtmvtolt);
                EXCEPTION
                  WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

                  pr_cdcritic := 1034;
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'CRAPGRP:' 
                                 ||' cdcooper:'||rw_vtass.cdcooper
                                 ||', nrdgrupo:'||vr_nrdgrupo
                                 ||', nrdconta:'||rw_vtass.nrdconta
                                 ||', nrctasoc:'||vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).nrdconta
                                 ||', nrcpfcgc:'||vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).nrcpfcgc
                                 ||', inpessoa:'||vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).inpessoa
                                 ||', idseqttl:998'
                                 ||', cdagenci:'||vr_tab_crapass(lpad(vr_tab_crapttl(lpad(rw_vtass.nrdctato, 20, '0')).nrdconta, 40, '0')).cdagenci
                                 ||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                                 ||'. '||SQLERRM;
                  RAISE vr_exc_erro;
                END;

                -- Monta a ligação de titulares no grupo, Utiliza método de recursão para varrer todos os titulares
                pc_monta_arvore(pr_cdcooper    => pr_cdcooper
                               ,pr_dtmvtolt    => pr_tab_crapdat.dtmvtolt
                               ,pr_nrdgrupo    => vr_nrdgrupo
                               ,pr_nrdconta    => rw_vtass.nrdctato
                               ,pr_nrcpfcgc    => rw_vtass.nrcpfcgc
                               ,pr_des_erro    => pr_dscritic);

                -- Verifica se ocorreram erros e passa para a próximo iteração
                IF pr_dscritic <> 'OK' THEN
                  CONTINUE;
                END IF;

              -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

            END IF;
          END IF;
      END LOOP;

      -- Mesclar grupos
      pc_mesclar_grupos(pr_cdcooper => pr_cdcooper
                       ,pr_nrdgrupo => 0
                       ,pr_cdcritic => pr_cdcritic
                       ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

      -- Processar grupos para cálculo de risco
      FOR rw_crapgrpb IN cr_crapgrpb(pr_cdcooper) LOOP
        -- Verifica se é o primeiro registro do grupo
        IF rw_crapgrpb.nrdgrupo <> rw_crapgrpb.nrdgrupoa THEN

		  -- Calcular endividamento do grupo
          pc_calc_endivid_risco_grupo(pr_cdcooper    => pr_cdcooper
                                     ,pr_cdagenci    => pr_cdagenci
                                     ,pr_nrdcaixa    => pr_nrdcaixa
                                     ,pr_cdoperad    => pr_cdoperad
                                     ,pr_cdprogra    => pr_cdprogra
                                     ,pr_idorigem    => pr_idorigem
                                     ,pr_nrdgrupo    => rw_crapgrpb.nrdgrupo
                                     ,pr_tpdecons    => TRUE
                                     ,pr_tab_crapdat => pr_tab_crapdat
                                     ,pr_tab_grupo   => pr_tab_grupo
                                     ,pr_dstextab    => vr_dstextab
                                     ,pr_dsdrisco    => opt_dsdrisco
                                     ,pr_vlendivi    => opt_vlendivi
                                     ,pr_des_erro    => pr_dscritic);

          -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_forma_grupo_economico');

        END IF;
      END LOOP;

      -- Finalização com sucesso
      pr_dscritic := 'OK';

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);

    EXCEPTION
      WHEN vr_erro THEN
        --Não grava log porque é gravado na rotina chamada
        pr_dscritic := pr_dscritic;

      WHEN vr_exc_erro THEN
        pr_dscritic := pr_dscritic;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => pr_cdprogra
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_dscritic
                   ,pr_cdcriticidade => 1
                   ,pr_cdmensagem    => pr_cdcritic
                   ,pr_tpocorrencia  => 2);  --grava 1

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'geco0001.pc_forma_grupo_economico. '|| SQLERRM;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => pr_cdprogra
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_dscritic
                   ,pr_cdcriticidade => 2
                   ,pr_cdmensagem    => vr_cdcritic
                   ,pr_tpocorrencia  => 3);  --grava 2
    END;
  END pc_forma_grupo_economico;

  /* Procedure responsavel por calcular e gravar o risco e o endividamento do grupo */
  PROCEDURE pc_calc_endivid_risco_grupo(pr_cdcooper    IN PLS_INTEGER                    --> Código da cooperativa
                                       ,pr_cdagenci    IN PLS_INTEGER                    --> Agência
                                       ,pr_nrdcaixa    IN PLS_INTEGER                    --> Número de caixa
                                       ,pr_cdoperad    IN VARCHAR2                       --> Código cooperativa adicional
                                       ,pr_cdprogra    IN VARCHAR2                       --> Código programa
                                       ,pr_idorigem    IN PLS_INTEGER                    --> Origem
                                       ,pr_nrdgrupo    IN PLS_INTEGER                    --> Número do grupo
                                       ,pr_tpdecons    IN BOOLEAN                        --> Tipo de consulta
                                       ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE       --> Informações de data do sistema
                                       ,pr_tab_grupo   IN OUT NOCOPY typ_tab_crapgrp     --> Tabela de grupos
                                       ,pr_dstextab    IN craptab.dstextab%TYPE          --> Valor da execução de descrição
                                       ,pr_dsdrisco    OUT VARCHAR2                      --> Descrição do risco
                                       ,pr_vlendivi    OUT NUMBER                        --> Valor dívida
                                       ,pr_des_erro    OUT VARCHAR2) IS                  --> Descrição de erros
  /* .............................................................................

   Programa: pc_calc_endivid_risco_grupo       (Antigo: b1wgen0138.p --> pc_calc_endivid_risco_grupo)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter
   Data    : Setembro/2013.                        Ultima atualizacao: 28/03/2018

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Calcular e gravar o risco e o endividamento do grupo.

   Alteracoes: 19/09/2013 - Conversão Progress >> Oracle (PLSQL) (Petter - Supero)

               29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                          - Padronização erros comandos DDL
                          - Pc_set_modulo, cecred.pc_internal_exception
                          - Tratamento erros others
                          - Substituída a query dinâmica por 2 queries normais, pois
                            a dinâmica estava impactando na parformance - cancelado
                          - Retirada a query por nrcpfcgc pois não é utilizada. 
                            As rotinas que chamam sempre informam pr_tpdecons = 'TRUE', 
                            sendo assim sempre cai na consulta por nrctasoc
                          - Retirada a leitura dos campos "Quebra" e "ContraQuebra", que não são utilizados
                           (Ana - Envolti - Chamado 813390 / 813391)

			   28/03/2018 - Ajuste para considerar o risco HH para as contas com prejuízo.
							(Reginaldo - AMcom)
  ............................................................................. */
  BEGIN
    DECLARE
      /* Variáveis do processo */
      vr_innivris     PLS_INTEGER;        --> Inicial do processo
      vr_opt_vlendivi NUMBER;             --> Sumarização do valor do endividamento
      vr_opt_innivris PLS_INTEGER;        --> Sumarização do inicial do processo
      vr_tpdordem     VARCHAR2(20);       --> Tipo de ordem
      vr_query        VARCHAR2(4000);     --> Query dinâmica
      vr_regisant     VARCHAR2(100);      --> Registro anterior
      vr_cursor       PLS_INTEGER;        --> Armazenar ID do SQL dinâmico
      vr_exec         PLS_INTEGER;        --> Armazenar ID de execução do SQL dinâmico
      vr_retorno      PLS_INTEGER;        --> Controle da existencia de registros
      vr_dctrl        DATE;               --> Armazenar o formato de data pelo programa chamador

      vr_datarefere   DATE;               --> Armazenar data de acordo com o programa
      vr_cdcritic     PLS_INTEGER;        --> Código da crítica
      vr_exc_erro     EXCEPTION;          --> Controle de erros
      vr_index        VARCHAR2(100);      --> Índice para a PL Table de grupos
      vr_contador     PLS_INTEGER;        --> Contagem de iterações do grupo

      --Busca grupo por nrctasoc
      CURSOR cr_crapgrp_2(pr_cdcooper IN crapgrp.cdcooper%TYPE
                         ,pr_nrdgrupo IN crapgrp.nrdgrupo%TYPE) IS  
        select cg.nrctasoc
              ,cg.nrcpfcgc
              ,cg.cdcooper
              ,cg.nrdgrupo
              ,cg.nrdconta
              ,cg.inpessoa
              ,cg.innivris
              ,cg.idseqttl
              ,cg.cdagenci
              ,cg.dtmvtolt
              ,cg.dtrefere
          from crapgrp cg
         where cg.cdcooper = pr_cdcooper
           and cg.nrdgrupo = pr_nrdgrupo
         order by cg.nrctasoc
                 ,cg.cdcooper
                 ,cg.nrdgrupo
                 ,cg.nrctasoc
                 ,cg.nrcpfcgc
                 ,cg.nrdconta
                 ,cg.inpessoa
                 ,cg.innivris
                 ,cg.idseqttl
                 ,cg.cdagenci
                 ,cg.dtmvtolt
                 ,cg.dtrefere;
      rw_crapgrp2  cr_crapgrp_2%rowtype;

    BEGIN

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_calc_endivid_risco_grupo');
  
      -- Inicializa variáveis
      vr_innivris := 0;
      vr_tpdordem := '';
      vr_regisant := '';

      --Busca grupos por nrctasoc
      FOR rw_crapgrp2 in cr_crapgrp_2(pr_cdcooper,pr_nrdgrupo) LOOP
        -- Zerar valores da iteração anterior
        vr_opt_vlendivi := 0;
        vr_opt_innivris := 0;
        pr_dsdrisco := '';

        -- Validar se valor existe
        IF pr_tpdecons = TRUE THEN
          -- Verifica a conta do associado
          IF rw_crapgrp2.nrctasoc <> nvl(vr_regisant, '0') THEN
            vr_regisant := rw_crapgrp2.nrctasoc;
          ELSE
            CONTINUE;
          END IF;
        ELSE
          -- Verifica o CPF/CNPJ
          IF rw_crapgrp2.nrcpfcgc <> nvl(vr_regisant, '0') THEN
            vr_regisant := rw_crapgrp2.nrcpfcgc;
          ELSE
            CONTINUE;
          END IF;
        END IF;

        -- Verificar se o número da conta é maior que zero
        IF rw_crapgrp2.nrctasoc > 0 THEN
          -- Buscar a data de acordo com o programa chamador
          IF UPPER(pr_cdprogra) = 'CRPS634' THEN
            vr_dctrl := pr_tab_crapdat.dtmvtolt;
          ELSIF UPPER(pr_cdprogra) = 'CRPS641' THEN
            vr_dctrl := pr_tab_crapdat.dtultdma;
          ELSE
            vr_dctrl := pr_tab_crapdat.dtultdia;
          END IF;

          -- Buscar risco individual
          pc_calc_risco_individual(pr_cdcooper  => rw_crapgrp2.cdcooper
                                  ,pr_nrctasoc  => rw_crapgrp2.nrctasoc
                                  ,pr_dtrefere  => vr_dctrl
                                  ,pr_dstextab  => pr_dstextab
                                  ,pr_innivris  => vr_opt_innivris
                                  ,pr_dsdrisco  => pr_dsdrisco
                                  ,pr_des_erro  => pr_des_erro);

          -- Verifica se existe erro
          IF pr_des_erro <> 'OK' THEN
            CONTINUE;
          END IF;

          -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_calc_endivid_risco_grupo');

          -- Buscar parâmetro de data
          IF UPPER(pr_cdprogra) = 'CRPS634' THEN
            vr_datarefere := pr_tab_crapdat.dtmvtolt;
          ELSIF UPPER(pr_cdprogra) = 'CRPS641' THEN
            vr_datarefere := pr_tab_crapdat.dtultdma;
          ELSE
            vr_datarefere := pr_tab_crapdat.dtultdia;
          END IF;

          -- Atualizar registros localizados para qualificar risco do grupo
          BEGIN
          UPDATE crapgrp cr
          SET cr.innivris = vr_opt_innivris
             ,cr.dsdrisco = pr_dsdrisco
             ,cr.dtrefere = vr_datarefere
            WHERE cr.cdcooper = rw_crapgrp2.cdcooper
              AND cr.nrdgrupo = rw_crapgrp2.nrdgrupo
              AND cr.nrcpfcgc = rw_crapgrp2.nrcpfcgc
              AND cr.nrctasoc = rw_crapgrp2.nrctasoc;
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - Ch 813390 / 813391
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

              vr_cdcritic := 1035;
              pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'CRAPGRP:' 
                             ||' innivris:'||vr_opt_innivris
                             ||', dsdrisco:'||pr_dsdrisco
                             ||', dtrefere:'||vr_datarefere
                             ||' com cdcooper:'||rw_crapgrp2.cdcooper
                             ||', nrdgrupo:'||rw_crapgrp2.nrdgrupo
                             ||', nrcpfcgc:'||rw_crapgrp2.nrcpfcgc
                             ||', nrctasoc:'||rw_crapgrp2.nrctasoc
                             ||'. '||SQLERRM;
              RAISE vr_exc_erro;
          END;

          -- Calcular endividamento individual
          pc_calc_endividamento_individu(pr_cdcooper    => rw_crapgrp2.cdcooper
                                        ,pr_cdagenci    => pr_cdagenci
                                        ,pr_nrdcaixa    => pr_nrdcaixa
                                        ,pr_cdoperad    => pr_cdoperad
                                        ,pr_nmdatela    => 'b1wgen0138'
                                        ,pr_idorigem    => pr_idorigem
                                        ,pr_nrctasoc    => rw_crapgrp2.nrctasoc
                                        ,pr_idseqttl    => 1
                                        ,pr_tpdecons    => pr_tpdecons
                                        ,pr_vlutiliz    => vr_opt_vlendivi
                                        ,pr_cdcritic    => vr_cdcritic
                                        ,pr_des_erro    => pr_des_erro
                                        ,pr_tab_crapdat => pr_tab_crapdat);

          -- Verifica se ocorreram erros
          IF pr_des_erro <> 'OK' OR nvl(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_calc_endivid_risco_grupo');

          -- Sumarizar valores
          pr_vlendivi := nvl(pr_vlendivi, 0) + nvl(vr_opt_vlendivi, 0);

          -- Retornar as contas individuais do grupo com seu endividamento e risco
          -- Verifica se existe registro, senão gera registro
          vr_index := lpad(rw_crapgrp2.cdcooper, 3, '0') || lpad(rw_crapgrp2.nrdgrupo, 10, '0') || lpad(rw_crapgrp2.nrctasoc, 20, '0');

          IF NOT pr_tab_grupo.exists(vr_index) THEN
            -- Criar registro de demarcação
            pr_tab_grupo(lpad(rw_crapgrp2.cdcooper, 3, '0') || lpad(rw_crapgrp2.nrdgrupo, 10, '0') || lpad('0', 20, '0')).cdcooper := rw_crapgrp2.cdcooper;

            pr_tab_grupo(vr_index).cdcooper := rw_crapgrp2.cdcooper;
            pr_tab_grupo(vr_index).nrdgrupo := rw_crapgrp2.nrdgrupo;
            pr_tab_grupo(vr_index).nrdconta := rw_crapgrp2.nrdconta;
            pr_tab_grupo(vr_index).nrctasoc := rw_crapgrp2.nrctasoc;
            pr_tab_grupo(vr_index).nrcpfcgc := rw_crapgrp2.nrcpfcgc;
            pr_tab_grupo(vr_index).inpessoa := rw_crapgrp2.inpessoa;
            pr_tab_grupo(vr_index).vlendivi := vr_opt_vlendivi;
            pr_tab_grupo(vr_index).dsdrisco := pr_dsdrisco;
            pr_tab_grupo(vr_index).innivris := rw_crapgrp2.innivris;
            pr_tab_grupo(vr_index).idseqttl := rw_crapgrp2.idseqttl;
            pr_tab_grupo(vr_index).cdagenci := rw_crapgrp2.cdagenci;
            pr_tab_grupo(vr_index).dtmvtolt := rw_crapgrp2.dtmvtolt;
            pr_tab_grupo(vr_index).dtrefere := rw_crapgrp2.dtrefere;
          END IF;
        END IF;

        -- Sumarizar valores
        IF vr_opt_innivris > 0 AND vr_opt_innivris <= 10 AND vr_innivris < vr_opt_innivris THEN
          vr_innivris := vr_opt_innivris;
        END IF;

      END LOOP;

      -- Grupo nao pode estar em prejuizo, sendo assim é trocado para ir em risco H
      IF vr_innivris = 0 OR vr_innivris = 10 THEN
        pr_dsdrisco := 'H';
        vr_innivris := 9;
      ELSE
	    -- Retorno do risco
        pr_dsdrisco := gene0002.fn_busca_entrada(pr_postext     => vr_innivris
                                                ,pr_dstext      => vr_dsdrisco
                                                ,pr_delimitador => ',');
      END IF;

      -- Leitura de todos do grupo para atualizar o risco do grupo
      BEGIN
      UPDATE crapgrp cp
      SET cp.dsdrisgp = pr_dsdrisco
         ,cp.innivrge = vr_innivris
      WHERE cp.cdcooper = pr_cdcooper
        AND cp.nrdgrupo = pr_nrdgrupo;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;
          pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'CRAPGRP:' 
                         ||' dsdrisgp:'||pr_dsdrisco
                         ||', innivrge:'||vr_innivris
                         ||' com cdcooper:'||pr_cdcooper
                         ||', nrdgrupo:'||pr_nrdgrupo
                         ||'. '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Le todos os registros do grupo e atualiza o valor do risco e do endividamento do grupo
      vr_index := lpad(pr_cdcooper, 3, '0') || lpad(pr_nrdgrupo, 10, '0') || lpad('0', 20, '0');
      vr_contador := 0;

      IF pr_tab_grupo.exists(vr_index) THEN
        -- Buscar próximo registro
        vr_index := pr_tab_grupo.next(vr_index);
        LOOP
          -- Buscar próximo índice
          IF SUBSTR(vr_index, LENGTH(vr_index) - 15, LENGTH(vr_index)) = LPAD('0', 15, '0') THEN
            vr_index := NULL;
          ELSE
            IF vr_contador > 0 THEN
              vr_index := pr_tab_grupo.NEXT(vr_index);
            END IF;
          END IF;

          EXIT WHEN vr_index IS NULL;

		  -- Incrementar contador
          vr_contador := vr_contador + 1;

		  -- Gravar valores na PL Table de grupos
          pr_tab_grupo(vr_index).vlendigp := pr_vlendivi;
          pr_tab_grupo(vr_index).dsdrisgp := pr_dsdrisco;
          pr_tab_grupo(vr_index).innivrge := vr_innivris;
        END LOOP;
      END IF;

      -- Mensagem em caso de sucesso
      pr_des_erro := 'OK';

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => pr_cdprogra
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_des_erro
                   ,pr_cdcriticidade => 1
                   ,pr_cdmensagem    => vr_cdcritic
                   ,pr_tpocorrencia  => 2);  --grava 1

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'geco0001.pc_calc_endivid_risco_grupo. ' || SQLERRM;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => pr_cdprogra
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_des_erro
                   ,pr_cdcriticidade => 2
                   ,pr_cdmensagem    => vr_cdcritic
                   ,pr_tpocorrencia  => 3);  --grava 2

    END;
  END pc_calc_endivid_risco_grupo;

  /* Procedure para gravar log de simulação */
  PROCEDURE pc_log_simula_perc(pr_cdcooper IN PLS_INTEGER   --> Código da cooperativa
                              ,pr_dtmvtolt IN DATE          --> Data de movimento
                              ,pr_cdoperad IN VARCHAR2      --> Código de operação
                              ,pr_persocio IN NUMBER        --> Sócio
                              ,pr_cdprogra IN VARCHAR2) IS  --> Programa
  /* .............................................................................

   Programa: pc_log_simula_perc       (Antigo: b1wgen0138.p --> log_simula_perc)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter
   Data    : Setembro/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Executar gravação de dados no log.

   Alteracoes: 13/09/2013 - Conversão Progress >> Oracle (PLSQL) (Petter - Supero)

               29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                          - Padronização erros comandos DDL
                          - Pc_set_modulo, cecred.pc_internal_exception
                          - Tratamento erros others
                           (Ana - Envolti - Chamado 813390 / 813391)
  ............................................................................. */
  BEGIN
    BEGIN
      --> Controlar geração de log de execução dos jobs
      --Como executa na cadeira, utiliza pc_gera_log_batch
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                      
                                ,pr_ind_tipo_log  => 1
                                ,pr_nmarqlog      => 'SIMULA'
                                ,pr_dstiplog      => 'E'   
                                ,pr_cdprograma    => pr_cdprogra
                                ,pr_tpexecucao    => 1 -- batch                       
                                ,pr_cdcriticidade => 0                      
                                ,pr_cdmensagem    => 0  
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                     || pr_cdprogra ||  ' --> Operador: ' 
                                                     || pr_cdoperad || ' Percentual: ' || pr_persocio);

    END;
  END pc_log_simula_perc;

  /* Procedure que calcula o risco de um cooperado */
  PROCEDURE pc_calc_risco_individual(pr_cdcooper  IN PLS_INTEGER            --> Código do cooperado
                                    ,pr_nrctasoc  IN PLS_INTEGER            --> Número da conta do associado
                                    ,pr_dtrefere  IN DATE                   --> Data de referencia
                                    ,pr_dstextab  IN craptab.dstextab%TYPE  --> Execução de parâmetros
                                    ,pr_innivris  OUT PLS_INTEGER           --> Indicador do risco
                                    ,pr_dsdrisco  OUT VARCHAR2              --> Descrição do risco
                                    ,pr_des_erro  OUT VARCHAR2) IS          --> Descrição do erro
  /* .............................................................................

   Programa: pc_calc_risco_individual       (Antigo: b1wgen0138.p --> calc_risco_individual)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter
   Data    : Outubro/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Procedure que calcula o risco de um cooperado.

   Alteracoes: 18/10/2013 - Conversão Progress >> Oracle (PLSQL) (Petter - Supero)

               29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                          - Padronização erros comandos DDL
                          - Pc_set_modulo, cecred.pc_internal_exception
                          - Tratamento erros others
                           (Ana - Envolti - Chamado 813390 / 813391)
  ............................................................................. */
  BEGIN
    DECLARE
      vr_exc_erro   EXCEPTION;       ---> Controle de exceção
      vr_cdcritic   PLS_INTEGER;

      /* Buscar dados da central de risco */
      CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_dtrefere IN crapris.dtrefere%TYPE      --> Data de referencia
                       ,pr_nrctasoc IN crapris.nrdconta%TYPE      --> Numero da conta
                       ,pr_dstextab IN VARCHAR2) IS                --> Descrição de taxas
        SELECT /*+ INDEX (ci crapris##crapris2) */
               ci.innivris
              ,ci.inindris
        FROM crapris ci
        WHERE ci.cdcooper = pr_cdcooper
          AND ci.dtrefere = pr_dtrefere
          AND ci.inddocto = 1
          AND ci.nrdconta = pr_nrctasoc
          AND ci.vldivida > SUBSTR(pr_dstextab, 3, 9)
        ORDER BY ci.progress_recid DESC;
      rw_crapris  cr_crapris%ROWTYPE;

	  /* Cursor para buscar o risco pelo tipo de documento e valor da dívida */
      CURSOR cr_craprisb(pr_cdcooper IN crapris.cdcooper%TYPE      --> Código da cooperativa
                        ,pr_dtrefere IN crapris.dtrefere%TYPE      --> Data de referencia
                        ,pr_nrctasoc IN crapris.nrdconta%TYPE      --> Numero da conta
                        ,pr_dstextab IN VARCHAR2                   --> Descrição de taxas
                        ,pr_innivris IN crapris.innivris%TYPE) IS  --> Nível de risco
        SELECT /*+ INDEX (ci crapris##crapris2) */
               ci.innivris
              ,ci.inindris
        FROM crapris ci
        WHERE ci.cdcooper = pr_cdcooper
          AND ci.dtrefere = pr_dtrefere
          AND ci.inddocto = 1
          AND ci.nrdconta = pr_nrctasoc
          AND ci.vldivida > SUBSTR(pr_dstextab, 3, 9)
          AND ci.innivris <> NVL(pr_innivris, ci.innivris);
      rw_craprisb cr_crapris%ROWTYPE;

    BEGIN
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_calc_risco_individual');

      -- Buscar dados da central de risco
      OPEN cr_crapris(pr_cdcooper, pr_dtrefere, pr_nrctasoc, pr_dstextab/*, NULL*/);
      FETCH cr_crapris INTO rw_crapris;

      -- Verifica se existe risco
      IF cr_crapris%FOUND THEN
        CLOSE cr_crapris;

        -- Verifica se o nível de risco é igual a 10
        IF rw_crapris.innivris = 10 THEN
          -- Buscar risco diferente de 10
          OPEN cr_craprisb(pr_cdcooper, pr_dtrefere, pr_nrctasoc, pr_dstextab, 10);
          FETCH cr_craprisb INTO rw_craprisb;

          -- Verifica se existe risco diferente de 10
          IF cr_craprisb%FOUND THEN
            CLOSE cr_craprisb;

            -- Verifica se o risco é zero
            IF rw_craprisb.inindris = 0 THEN
              pr_innivris := rw_craprisb.innivris;
            ELSE
              pr_innivris := rw_craprisb.inindris;
            END IF;

            -- Retorno risco calculado
            pr_dsdrisco := gene0002.fn_busca_entrada(pr_postext     => pr_innivris
                                                    ,pr_dstext      => vr_dsdrisco
                                                    ,pr_delimitador => ',');
          ELSE
            CLOSE cr_craprisb;

            -- Verifica se o risco é zero
            IF rw_crapris.inindris = 0 THEN
              pr_innivris := rw_crapris.innivris;
            ELSE
              pr_innivris := rw_crapris.inindris;
            END IF;

            -- Retorno risco calculado
            pr_dsdrisco := gene0002.fn_busca_entrada(pr_postext     => pr_innivris
                                                    ,pr_dstext      => vr_dsdrisco
                                                    ,pr_delimitador => ',');

          END IF;
        ELSE
          -- Verifica se o risco é zero
          IF rw_crapris.inindris = 0 THEN
            pr_innivris := rw_crapris.innivris;
          ELSE
            pr_innivris := rw_crapris.inindris;
          END IF;

          -- Retorno risco calculado
          pr_dsdrisco := gene0002.fn_busca_entrada(pr_postext     => pr_innivris
                                                  ,pr_dstext      => vr_dsdrisco
                                                  ,pr_delimitador => ',');
        END IF;
      ELSE
        CLOSE cr_crapris;

		-- Definir risco e finalizar execução
        pr_innivris := 2;
        pr_dsdrisco := 'A';
      END IF;

	  -- Mensagem para execução sem erros
      pr_des_erro := 'OK';

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'geco0001.pc_calc_risco_individu. '||'NOK --> '||SQLERRM;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => NULl
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_des_erro
                   ,pr_cdcriticidade => 2
                   ,pr_cdmensagem    => vr_cdcritic
                   ,pr_tpocorrencia  => 3);  --grava 2
    END;
  END pc_calc_risco_individual;

  /* Procedure que calcula o endividamento de um cooperado */
  PROCEDURE pc_calc_endividamento_individu(pr_cdcooper    IN PLS_INTEGER                     --> Código da cooperativa
                                          ,pr_cdagenci    IN PLS_INTEGER                   --> Código da agencia
                                          ,pr_nrdcaixa    IN PLS_INTEGER                   --> Número do caixa
                                          ,pr_cdoperad    IN VARCHAR2                      --> Código do cooperado
                                          ,pr_nmdatela    IN VARCHAR2                      --> Nome da tela
                                          ,pr_idorigem    IN PLS_INTEGER                   --> Identificador de origem
                                          ,pr_nrctasoc    IN PLS_INTEGER                   --> Conta associado
                                          ,pr_idseqttl    IN PLS_INTEGER                   --> Sequencia de títulos
                                          ,pr_tpdecons    IN BOOLEAN                       --> Tipo de consulta
                                          ,pr_vlutiliz    OUT NUMBER                       --> Valor utilizado
                                          ,pr_cdcritic    OUT PLS_INTEGER                  --> PL Table para armazenar erros
                                          ,pr_des_erro    OUT VARCHAR2                     --> Descrição do erro
                                          ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE) IS  --> Tabela de datas
  /* .............................................................................

   Programa: pc_calc_endividamento_individual       (Antigo: b1wgen0138.p --> calc_endividamento_individual)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Petter
   Data    : Outubro/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Quando solicitado
   Objetivo  : Procedure que calcula o endividamento de um cooperado.

   Alteracoes: 21/10/2013 - Conversão Progress >> Oracle (PLSQL) (Petter - Supero)

               29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                          - Padronização erros comandos DDL
                          - Pc_set_modulo, cecred.pc_internal_exception
                          - Tratamento erros others
                          - O parâmetro pr_des_erro estava sendo setado = 'OK' no final da rotina,
                            ou seja, caso ocorresse erro durante a rotina, o mesmo não seria registrado
                            Alterado para setar no início do programa, e retornar corretamente as
                            possíveis alterações nesse parâmetro
                           (Ana - Envolti - Chamado 813390 / 813391)
               28/03/2018 - Ajuste para considerar o risco HH para as contas com prejuízo.
                            (Reginaldo - AMcom)
  ............................................................................. */
  BEGIN
    DECLARE

      /* Buscar dados de emprestimos. (D-05) para casos de prejuízo */
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_nrctasoc IN crapepr.nrdconta%TYPE) IS --> Conta associado
        SELECT ce.vlsdprej
        FROM crapepr ce
        WHERE ce.cdcooper = pr_cdcooper
          AND ce.nrdconta = pr_nrctasoc
          AND ce.inprejuz = 1 /*prejuizo*/
          AND ce.vlprejuz > 0
          AND ce.vlsdprej > 0;

      /* Buscar dados de emprestimo BNDES para prejuízo */
      CURSOR cr_crapebn(pr_cdcooper IN crapebn.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_nrctasoc IN crapebn.nrdconta%TYPE) IS --> Conta associado
        SELECT cn.vlsdeved
        FROM crapebn cn
        WHERE cn.cdcooper = pr_cdcooper
          AND cn.nrdconta = pr_nrctasoc
          AND cn.insitctr = 'P';

    BEGIN
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_calc_endividamento_individu');

      -- Indicador de sucesso
      pr_des_erro := 'OK';

      -- Verifica conta de associado
      IF pr_nrctasoc <> 0 THEN
        -- Consultar saldo utilizado
        gene0005.pc_saldo_utiliza(pr_cdcooper    => pr_cdcooper
                                 ,pr_tpdecons    => 2
                                 ,pr_cdagenci    => pr_cdagenci
                                 ,pr_nrdcaixa    => pr_nrdcaixa
                                 ,pr_cdoperad    => pr_cdoperad
                                 ,pr_nrdconta    => pr_nrctasoc
                                 ,pr_idseqttl    => pr_idseqttl
                                 ,pr_idorigem    => pr_idorigem
                                 ,pr_dsctrliq    => ''
                                 ,pr_cdprogra    => pr_nmdatela
                                 ,pr_tab_crapdat => pr_tab_crapdat
                                 ,pr_inusatab    => pr_tpdecons
                                 ,pr_vlutiliz    => pr_vlutiliz
                                 ,pr_cdcritic    => pr_cdcritic
                                 ,pr_dscritic    => pr_des_erro);

        -- Verifica se ocorreram erros
        IF NVL(pr_cdcritic, 0) > 0 THEN
          pr_des_erro := 'NOK --> ' || pr_des_erro;
        END IF;

        /* Buscar o saldo devedor de prejuizo e somar ao utilizado.
           Nao foi utilizado a bo27 pois ela le registro extras e gera registro de log sem necessidade */
        FOR rw_crapepr IN cr_crapepr(pr_cdcooper, pr_nrctasoc) LOOP
          pr_vlutiliz := NVL(pr_vlutiliz, 0) + NVL(rw_crapepr.vlsdprej, 0);
        END LOOP;

        /* BNDES - Emprestimos em Prejuizo */
        FOR rw_crapebn IN cr_crapebn(pr_cdcooper, pr_nrctasoc) LOOP
          pr_vlutiliz := NVL(pr_vlutiliz, 0) + NVL(rw_crapebn.vlsdeved, 0);
        END LOOP;
      END IF;

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        pr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic)||'geco0001.pc_calc_endividamento_individu. '||'NOK --> '||SQLERRM;

        --Log efetuado na rotina chamadora - Chamado 883190
    END;
  END pc_calc_endividamento_individu;
  
  /*******************************************************************************/
  /**   Procedure retorna se a conta em questao pertence a algum grupo e qual e,**/
  /**   se o grupo economico esta sendo gerado.                                 **/
  /*******************************************************************************/
  PROCEDURE pc_busca_grupo_associado
                            (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa                            
                            ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                            ------ OUT ------
                            ,pr_flggrupo  OUT INTEGER              --> Retorna se conta pertence a um grupo
                            ,pr_nrdgrupo  OUT crapgrp.nrdgrupo%TYPE--> retorna numero do grupo
                            ,pr_gergrupo  OUT VARCHAR2             --> Retorna grupo economico
                            ,pr_dsdrisgp  OUT crapgrp.dsdrisgp%TYPE) IS --> retona descrição do grupo
     
  /* ..........................................................................
    --
    --  Programa : pc_busca_grupo_associado        Antiga: b1wgen0138.p/busca_grupo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Setembro/2015.                   Ultima atualizacao: 14/09/2015
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Procedure retorna se a conta em questao pertence a algum grupo e qual e,
    --              se o grupo economico esta sendo gerado
    --
    --  Alteração : 14/09/2015 - Conversão Progress -> Oracle (Odirlei)
    --
    --              29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
    --                         - Padronização erros comandos DDL
    --                         - Pc_set_modulo, cecred.pc_internal_exception
    --                         - Tratamento erros others
    --                          (Ana - Envolti - Chamado 813390 / 813391)
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    --> buscar grupo economico do cooperado
    CURSOR cr_crapgrp IS
      SELECT crapgrp.nrdgrupo
            ,crapgrp.dsdrisgp
        FROM crapgrp
       WHERE crapgrp.cdcooper = pr_cdcooper
         AND crapgrp.nrctasoc = pr_nrdconta;
    rw_crapgrp cr_crapgrp%ROWTYPE;  
    
    vr_dstextab craptab.dstextab%TYPE;   
    
  BEGIN

    -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_busca_grupo_associado');

    -- Verificar se grupo economico esta em formacao
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'CTRGRPECON'
                                             ,pr_tpregist => 99);
    
    pr_gergrupo := NULL; 
    IF TRIM(vr_dstextab) IS NOT NULL THEN
      pr_gergrupo := 'Grupo Economico esta sendo gerado. Resultados podem variar.';  
    END IF;
    
    --> buscar grupo economico do cooperado
    OPEN cr_crapgrp;
    FETCH cr_crapgrp INTO rw_crapgrp;

    IF cr_crapgrp%FOUND THEN
      pr_nrdgrupo := rw_crapgrp.nrdgrupo;
      pr_dsdrisgp := rw_crapgrp.dsdrisgp;
      pr_flggrupo := 1; --TRUE
    ELSE
      pr_flggrupo := 0; --FALSE
    END IF;
    CLOSE cr_crapgrp;
    
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
    
  END pc_busca_grupo_associado; 
  
  /* Procedure responsavel por calcular o endividamento do grupo  */
  PROCEDURE pc_calc_endivid_grupo(pr_cdcooper  IN INTEGER                    --> Codigo da cooperativa
                                 ,pr_cdagenci  IN INTEGER                    --> Codigo da agencia
                                 ,pr_nrdcaixa  IN INTEGER                    --> Numero do caixa
                                 ,pr_cdoperad  IN VARCHAR2                   --> Codigo do operador
                                 ,pr_nmdatela  IN VARCHAR2                   --> Nome da tela
                                 ,pr_idorigem  IN INTEGER                    --> Identificação de origem
                                 ,pr_nrdgrupo  IN INTEGER                    --> Número do grupo
                                 ,pr_tpdecons  IN BOOLEAN                    --> Tipo de consulta
                                 ,pr_dsdrisco OUT VARCHAR2                   --> Descrição do risco
                                 ,pr_vlendivi OUT NUMBER                     --> Valor dívida
                                 ,pr_tab_grupo IN OUT NOCOPY typ_tab_crapgrp --> PL Table para armazenar grupos econômicos
                                 ,pr_cdcritic OUT INTEGER                    --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2) IS               --> Descricao da critica
  BEGIN
  /* ..........................................................................
    --
    --  Programa : calc_endivid_grupo              Antiga: b1wgen0138.p/calc_endivid_grupo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lombardi
    --  Data     : Setembro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Calcula o endividamento do grupo
    --
    --   Alteração : 29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
    --                          - Padronização erros comandos DDL
    --                          - Pc_set_modulo, cecred.pc_internal_exception
    --                          - Tratamento erros others
    --                            (Ana - Envolti - Chamado 813390 / 813391)
    -- ..........................................................................*/
    
    DECLARE
      
      ---------------> CURSORES <-----------------
      CURSOR cr_crapgrp (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdgrupo IN crapgrp.nrdgrupo%TYPE
                        ,pr_tpdecons IN INTEGER) IS
        SELECT *
          FROM (SELECT grp.nrcpfcgc
                      ,grp.nrctasoc
                      ,grp.nrdgrupo
                      ,grp.cdcooper
                      ,grp.nrdconta
                      ,grp.inpessoa
                      ,grp.innivris
                      ,grp.dsdrisco
                      ,grp.dsdrisgp
                      ,grp.idseqttl
                      ,grp.cdagenci
                      ,grp.dtmvtolt
                      ,grp.dtrefere
                      ,row_number() OVER(PARTITION BY grp.nrcpfcgc ORDER BY grp.nrcpfcgc, grp.progress_recid) indice_cpf -- Ordena os registros por cpf
                      ,row_number() OVER(PARTITION BY grp.nrctasoc ORDER BY grp.nrctasoc, grp.progress_recid) indice_conta -- Ordena os registros por conta
                  FROM crapgrp grp
                 WHERE grp.cdcooper = pr_cdcooper
                   AND grp.nrdgrupo = pr_nrdgrupo)
         WHERE DECODE(pr_tpdecons,0, indice_cpf --Se for por CPF, obtém o primeiro registro de cada cpf (ignora os repetidos)
                                 ,1, indice_conta) = 1 --Se for por Conta, obtém o primeiro registro de cada conta (ignora os repetidos)
        ORDER BY DECODE(pr_tpdecons,0, nrcpfcgc --Se for por CPF
                                   ,1, nrctasoc); --Se for por Conta
      
      -- Informações de data do sistema
      rw_crapdat  btch0001.rw_crapdat%TYPE; 
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      --Variaveis auxiliares
      vr_opt_vlendivi NUMBER; --> Sumarização do valor do endividamento
      vr_des_erro     VARCHAR2(100);
      vr_index        INTEGER;
      
    BEGIN
    
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_calc_endivid_grupo');

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      pr_vlendivi := 0;
      
      -- Percorre os grupos economicos
      FOR rw_crapgrp IN cr_crapgrp(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdgrupo => pr_nrdgrupo
                                  ,pr_tpdecons => CASE pr_tpdecons 
                                                      WHEN TRUE THEN 1
                                                      ELSE 0
                                                  END) LOOP
        IF rw_crapgrp.nrctasoc > 0  THEN
          pc_calc_endividamento_individu(pr_cdcooper    => rw_crapgrp.cdcooper
                                        ,pr_cdagenci    => pr_cdagenci
                                        ,pr_nrdcaixa    => pr_nrdcaixa
                                        ,pr_cdoperad    => pr_cdoperad
                                        ,pr_nmdatela    => pr_nmdatela
                                        ,pr_idorigem    => pr_idorigem
                                        ,pr_nrctasoc    => rw_crapgrp.nrctasoc
                                        ,pr_idseqttl    => 1
                                        ,pr_tpdecons    => pr_tpdecons
                                        ,pr_vlutiliz    => vr_opt_vlendivi
                                        ,pr_cdcritic    => vr_cdcritic
                                        ,pr_des_erro    => vr_des_erro
                                        ,pr_tab_crapdat => rw_crapdat);

          -- Verifica se ocorreram erros
          IF vr_des_erro <> 'OK' OR nvl(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exc_saida;
          END IF;
          
          -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'GECO0001.pc_calc_endivid_grupo');
          
          -- Acumula valor do endividamento
          pr_vlendivi := pr_vlendivi + vr_opt_vlendivi;
          
          -- Cria o Index
          IF pr_tpdecons THEN
            vr_index := lpad(pr_cdcooper, 3, '0') || lpad(pr_nrdgrupo, 10, '0') || lpad(rw_crapgrp.nrctasoc, 20, '0');
          ELSE
            vr_index := lpad(pr_cdcooper, 3, '0') || lpad(pr_nrdgrupo, 10, '0') || lpad(rw_crapgrp.nrcpfcgc, 20, '0');
          END IF;
          
          -- cria registro de grupo
          IF NOT pr_tab_grupo.exists(vr_index) THEN
            pr_tab_grupo(vr_index).cdcooper := rw_crapgrp.cdcooper;
            pr_tab_grupo(vr_index).nrdgrupo := rw_crapgrp.nrdgrupo;
            pr_tab_grupo(vr_index).nrdconta := rw_crapgrp.nrdconta;
            pr_tab_grupo(vr_index).nrctasoc := rw_crapgrp.nrctasoc;
            pr_tab_grupo(vr_index).nrcpfcgc := rw_crapgrp.nrcpfcgc;
            pr_tab_grupo(vr_index).inpessoa := rw_crapgrp.inpessoa;
            pr_tab_grupo(vr_index).vlendivi := vr_opt_vlendivi;
            pr_tab_grupo(vr_index).innivris := (CASE rw_crapgrp.innivris 
                                                  WHEN 10 THEN 9
                                                  ELSE rw_crapgrp.innivris
                                                END);
            pr_tab_grupo(vr_index).dsdrisco := (CASE rw_crapgrp.innivris 
                                                  WHEN 10 THEN 'H'
                                                  ELSE rw_crapgrp.dsdrisco
                                                END);
            pr_tab_grupo(vr_index).dsdrisgp := rw_crapgrp.dsdrisgp;
            pr_tab_grupo(vr_index).idseqttl := rw_crapgrp.idseqttl;
            pr_tab_grupo(vr_index).cdagenci := rw_crapgrp.cdagenci;
            pr_tab_grupo(vr_index).dtmvtolt := rw_crapgrp.dtmvtolt;
            pr_tab_grupo(vr_index).dtrefere := rw_crapgrp.dtrefere;
            pr_dsdrisco := rw_crapgrp.dsdrisgp;
            
          END IF;
          
        END IF;
      END LOOP;
      
      vr_index := pr_tab_grupo.first;
      WHILE vr_index IS NOT NULL LOOP
        pr_tab_grupo(vr_index).vlendigp := pr_vlendivi;
        vr_index := pr_tab_grupo.next(vr_index);
      END LOOP;
      
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 813390 / 813391
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
      
    EXCEPTION
      WHEN vr_exc_saida THEN     
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => null
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_dscritic
                   ,pr_cdcriticidade => 1
                   ,pr_cdmensagem    => pr_cdcritic
                   ,pr_tpocorrencia  => 2);  --grava 1

        ROLLBACK;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 18/12/2017 - Ch 813390 / 813391
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'geco0001.pc_calc_endivid_grupo - tela '|| pr_nmdatela || '. ' || SQLERRM;

        --Log - Chamado 883190
        pc_gera_log(pr_cdcooper      => pr_cdcooper
                   ,pr_cdprogra      => NULL
                   ,pr_dstiplog      => 'E'
                   ,pr_dscritic      => pr_dscritic
                   ,pr_cdcriticidade => 2
                   ,pr_cdmensagem    => pr_cdcritic
                   ,pr_tpocorrencia  => 3);  --grava 2

        ROLLBACK;
      END;
    
  END pc_calc_endivid_grupo; 
  
END geco0001;
/
