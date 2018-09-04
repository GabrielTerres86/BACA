CREATE OR REPLACE PACKAGE CECRED.PREJ0005 AS
/*..............................................................................

   Programa: PREJ0005
   Sistema : Cred
   Sigla   : CRED
   Autor   : Luis Fernando (GFT)
   Data    : 27/08/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Rotinas de controle de prejuizo para borderos

   Alteracoes:
..............................................................................*/

  PROCEDURE pc_bloqueio_conta_corrente (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Cooperativa
                                            ,pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                            --------> OUT <--------
                                            ,pr_cdcritic   OUT PLS_INTEGER             --> código da crítica
                                            ,pr_dscritic   OUT VARCHAR2                --> descrição da crítica
                                           );
                                           
  PROCEDURE pc_transferir_prejuizo (pr_cdcooper IN crapcop.cdcooper%TYPE         --> Coop conectada
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE    --> Numero do bordero 
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2 );
                                    
  PROCEDURE pc_executa_job_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                    -- OUT --
                    ,pr_cdcritic OUT PLS_INTEGER
                    ,pr_dscritic OUT VARCHAR2
                    );

END PREJ0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0005 AS
/*..............................................................................

   Programa: PREJ0005
   Sistema : Cred
   Sigla   : CRED
   Autor   : Luis Fernando
   Data    : 27/08/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Rotinas de controle de prejuizo para borderos

   Alteracoes:
..............................................................................*/
  PROCEDURE pc_bloqueio_conta_corrente (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Cooperativa
                                            ,pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                            --------> OUT <--------
                                            ,pr_cdcritic   OUT PLS_INTEGER             --> código da crítica
                                            ,pr_dscritic   OUT VARCHAR2                --> descrição da crítica
                                           ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_bloqueio_conta_corrente
        Sistema  : 
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 27/08/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Bloquear produtos da conta corrente do cooperado 
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
      vr_dscritic varchar2(1000);        --> desc. erro
          
      -- Declara cursor de data
      rw_crapdat   btch0001.cr_crapdat%rowtype;
      
      BEGIN
        -- Buscar data do sistema
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        IF (btch0001.cr_crapdat%NOTFOUND) THEN
          CLOSE btch0001.cr_crapdat;
          vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
          RAISE vr_exc_erro;
        END IF;
        CLOSE btch0001.cr_crapdat;
        
        -- Bloqueio cartao magnetico
        BEGIN
          UPDATE
            crapcrm
          SET
            crapcrm.cdsitcar = 4 -- Bloqueado
            ,crapcrm.dtcancel = rw_crapdat.dtmvtolt
            ,crapcrm.dttransa = trunc(sysdate)
          WHERE
            crapcrm.cdcooper = pr_cdcooper
            AND crapcrm.nrdconta = pr_nrdconta
            AND crapcrm.cdsitcar NOT IN (3,4)
          ;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao cancelar cartao magnetico: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Bloqueio senha internet
        BEGIN
          UPDATE
            crapsnh
          SET
            crapsnh.cdsitsnh = 2 -- Bloqueado
            ,crapsnh.dtblutsh = rw_crapdat.dtmvtolt
            ,crapsnh.dtaltsit = rw_crapdat.dtmvtolt
        WHERE
          crapsnh.cdcooper = pr_cdcooper
          AND crapsnh.nrdconta = pr_nrdconta
          AND crapsnh.cdsitsnh = 1 -- Ativa
          AND crapsnh.tpdsenha = 1 -- Internet
          AND crapsnh.idseqttl = 1; -- primeiro titular
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao cancelar senha internet: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      BEGIN
        UPDATE 
          crapmcr
        SET
          crapmcr.dtcancel = rw_crapdat.dtmvtolt
        WHERE
          crapmcr.cdcooper = pr_cdcooper
          AND crapmcr.nrdconta = pr_nrdconta
          AND crapmcr.tpctrmif = 3
        ;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao cancelar LIMITE: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Cancelamento Limite de Desconto de Título
      BEGIN
        UPDATE 
          craplim
        SET
          craplim.insitlim = 3 -- Cancelado
          ,craplim.dtfimvig = rw_crapdat.dtmvtolt
        WHERE
          craplim.cdcooper = pr_cdcooper
          AND craplim.nrdconta = pr_nrdconta
          AND craplim.insitlim = 2
          AND craplim.tpctrlim = 3
        ;

      EXCEPTION
        when others then
          vr_dscritic := 'Erro ao cancelar LIMITE: ' || sqlerrm;
          raise vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao nao tratado na rotina pc_bloqueio_conta_corrente: ' ||SQLERRM;
  END pc_bloqueio_conta_corrente;

  PROCEDURE pc_transferir_prejuizo (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Coop conectada
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE    --> Numero do bordero 
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2) IS
    /* .............................................................................

    Programa: pc_transferir_prejuizo
    Sistema :
    Sigla   : CRED
    Autor   : Luis Fernando
    Data    : 27/08/2018                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Transferir o bordero para prejuizo e bloquear os respectivos acessos do cooperado

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----
    CURSOR cr_crapbdt IS
      SELECT 
        bdt.rowid AS id,
        bdt.nrborder,
        bdt.nrdconta,
        bdt.cdcooper,
        bdt.inprejuz,
        bdt.dtlibbdt,
        bdt.insitbdt,
        bdt.qtdirisc,
        bdt.nrinrisc
      FROM 
        crapbdt bdt
      WHERE
        bdt.nrborder = pr_nrborder
        AND bdt.cdcooper = pr_cdcooper
    ;
    rw_crapbdt cr_crapbdt%ROWTYPE;
    
    rw_crapdat   btch0001.cr_crapdat%rowtype;
    ---->> VARIAVEIS <<-----

    ---->> TRATAMENTO DE ERROS <<-----
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    BEGIN
      -- Buscar data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
      
      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_cdcritic := 1166; -- bordero nao encontrado
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;
      
      IF (rw_crapbdt.inprejuz=1) THEN
        vr_dscritic := 'Bordero ja esta em prejuizo';
        RAISE vr_exc_erro;
      END IF;
      
      IF (rw_crapbdt.insitbdt<>3) THEN
        vr_cdcritic := 1175; -- bordero diferente de liberado
        RAISE vr_exc_erro;
      END IF;
      
      IF (rw_crapbdt.nrinrisc<>9 OR rw_crapbdt.qtdirisc<180) THEN
        vr_dscritic := 'Bordero deve estar no risco H ha mais de 180 dias';
        RAISE vr_exc_erro;
      END IF;
      
      /*Verifica se nao esta em ACORDO na cyber*/
      /* Verificar se possui acordo na CRAPCYC com motivo igual a 2 e VIP */
      /*
      OPEN c_crapcyc(pr_cdcooper,
                     pr_nrdconta,
                     pr_nrctremp);
      FETCH c_crapcyc INTO vr_flgativo;
      CLOSE c_crapcyc;

      IF nvl(vr_flgativo,0) = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Transferencia para prejuizo nao permitida, acordo possui motivo 2 -Determinação Judicial – Prejuízo Não';
        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      END IF;
      */
      -- Atualiza bordero para prejuizo
      UPDATE 
        crapbdt
      SET 
        inprejuz = 1,
        dtprejuz = rw_crapdat.dtmvtolt
      WHERE 
        ROWID = rw_crapbdt.id
      ;
      
      -- Atualiza os saldos de prejuizo
      UPDATE
        craptdb
      SET
        vlprejuz = vltitulo,
        vlsdprej = vlsldtit,
        vlttmupr = vlmtatit,
        vlttjmpr = vlmratit,
        vlpgjmpr = vlpagmra,
        vlpgmupr = vlpagmta,
        vlsprjat = 0,
        vljraprj = 0
      WHERE 
        nrborder = rw_crapbdt.nrborder
        AND nrdconta = rw_crapbdt.nrdconta
        AND insittit = 4 -- apenas titulos liberados
        AND cdcooper = rw_crapbdt.cdcooper
      ;
      
      pc_bloqueio_conta_corrente(pr_cdcooper => rw_crapbdt.cdcooper
                                 ,pr_nrdconta => rw_crapbdt.nrdconta
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao nao tratado na rotina pc_transferir_prejuizo: ' ||SQLERRM;
  END pc_transferir_prejuizo;
  
  PROCEDURE pc_executa_job_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                    -- OUT --
                    ,pr_cdcritic OUT PLS_INTEGER
                    ,pr_dscritic OUT VARCHAR2
                    ) IS
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_executa_job_prejuizo
        Sistema  : 
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 29/08/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Executa rotina que verifica os borderos que devem ser enviados para prejuizo e os transfere
      ---------------------------------------------------------------------------------------------------------------------*/
      
      ---->> CURSORES <<-----
      CURSOR cr_crapbdt IS
        SELECT 
          bdt.rowid AS id,
          bdt.nrborder,
          bdt.nrdconta,
          bdt.cdcooper,
          bdt.inprejuz,
          bdt.dtlibbdt,
          bdt.insitbdt,
          bdt.qtdirisc,
          bdt.nrinrisc
        FROM 
          crapbdt bdt
        WHERE
          bdt.nrinrisc = 9 
          AND bdt.qtdirisc>=180
          AND bdt.inprejuz=0
      ;
      rw_crapbdt cr_crapbdt%ROWTYPE;
      
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
        
      -- Variável de Data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      BEGIN
        -- Leitura do calendário da cooperativa
        OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        
        OPEN cr_crapbdt;
        LOOP FETCH cr_crapbdt INTO rw_crapbdt;
          EXIT WHEN cr_crapbdt%NOTFOUND;
          pc_transferir_prejuizo(pr_cdcooper  => rw_crapbdt.cdcooper
                                 ,pr_nrborder => rw_crapbdt.nrborder
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          IF (NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL) THEN
            RAISE vr_exc_erro;
          END IF;
        END LOOP;
        
      EXCEPTION
        WHEN vr_exc_erro THEN 
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina PREJ0005.pc_executa_job_prejuizo: ' || SQLERRM;
      
  END pc_executa_job_prejuizo;

END PREJ0005;
/
