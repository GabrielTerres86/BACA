CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps367 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps367 (Fontes/crps367.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Margarete
       Data    : Outubro/2003.                   Ultima atualizacao: 26/05/2014

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 2. Ordem 42.
                   Criar base de desconto de cheques para o calculo do VAR.

       Alteracoes: 30/06/2005 - Alimentado campo cdcooper da tabela crapvar (Diego).

                   17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                   
                   02/08/2007 - Passar origem de 7 para 10 (Magui).
                   
                   02/09/2010 - Acumular o valor dos cheques separados por prazo
                                Tarefa 34548 (Henrique).
                   
                   13/09/2010 - Inserir novos prazos. (Henrique)    
                   
                   21/01/2014 - Incluir VALIDATE crapprb, crapvar (Lucas R.)         
                   
                   03/04/2014 - Conversão Progress >> PLSQL (Edison-AMcom).
                   
                   26/05/2014 - Nao utilizar mais a tabela CRAPVAR (desativacao da VAR). 
                                (Andrino-RKAM)

    ............................................................................. */

    /******** Decisoes sobre o VAR **********************************************
    Todos os lancamentos a CREDITO 
    Varres os cheques que faltam entrar e colocar no dia dos seus vencimentos
    sem juros
    *****************************************************************************/

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS367';

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
              ,cop.nrctactl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      --Cheques contidos do Bordero de desconto de cheques
      --com situacao 2-processado e nao devolvidos
      CURSOR cr_crapcdb( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN DATE) IS
        SELECT crapcdb.dtlibera
              ,crapcdb.vlcheque
              ,row_number() over (partition by crapcdb.dtlibera order by crapcdb.dtlibera) idreg
              ,count(*) over (partition by crapcdb.dtlibera order by crapcdb.dtlibera) qtdereg
        FROM   crapcdb 
        WHERE  crapcdb.cdcooper  = pr_cdcooper     
        AND    crapcdb.dtlibera >= pr_dtmvtolt     
        AND    crapcdb.dtdevolu  IS NULL                
        AND    crapcdb.insitchq  = 2 
        ORDER BY crapcdb.dtlibera;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_vet_chqacuml IS VARRAY(19) OF NUMBER;

      ------------------------------- VARIAVEIS -------------------------------
      vr_vllanmto NUMBER(25,2);
      vr_dtdpagto DATE;
      vr_chqacuml typ_vet_chqacuml := typ_vet_chqacuml(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
      vr_cddprazo INTEGER;

      --------------------------- SUBROTINAS INTERNAS --------------------------

      --insere informacoes na tabela crapprb
      PROCEDURE pc_proc_cria_crapprb( pr_dtmvtolt IN DATE
                                     ,pr_cddprazo IN INTEGER
                                     ,pr_vlretorn IN crapprb.vlretorn%TYPE) IS

      BEGIN
        DECLARE
          vr_cddprazo crapprb.cddprazo%TYPE;
        BEGIN    
            CASE pr_cddprazo
                WHEN 1  THEN vr_cddprazo := 90;
                WHEN 2  THEN vr_cddprazo := 180;
                WHEN 3  THEN vr_cddprazo := 270;
                WHEN 4  THEN vr_cddprazo := 360;
                WHEN 5  THEN vr_cddprazo := 720;
                WHEN 6  THEN vr_cddprazo := 1080;
                WHEN 7  THEN vr_cddprazo := 1440;
                WHEN 8  THEN vr_cddprazo := 1800;
                WHEN 9  THEN vr_cddprazo := 2160;
                WHEN 10 THEN vr_cddprazo := 2520;
                WHEN 11 THEN vr_cddprazo := 2880;
                WHEN 12 THEN vr_cddprazo := 3240;
                WHEN 13 THEN vr_cddprazo := 3600;
                WHEN 14 THEN vr_cddprazo := 3960;
                WHEN 15 THEN vr_cddprazo := 4320;
                WHEN 16 THEN vr_cddprazo := 4680;
                WHEN 17 THEN vr_cddprazo := 5040;
                WHEN 19 THEN vr_cddprazo := 5401;
                ELSE NULL;
            END CASE;
            
            --grava tabela de prazos de retorno dos nossos produtos para  
            --levantamento de informacoes solicitadas pelo BNDES.
            BEGIN
              INSERT INTO crapprb( cdcooper
                                  ,dtmvtolt
                                  ,cdorigem
                                  ,nrdconta
                                  ,cddprazo
                                  ,vlretorn
              ) VALUES ( 3                   --crapprb.cdcooper  
                        ,pr_dtmvtolt         --crapprb.dtmvtolt 
                        ,2                   --crapprb.cdorigem  /* Cheque */
                        ,rw_crapcop.nrctactl --crapprb.nrdconta
                        ,vr_cddprazo         --crapprb.cddprazo
                        ,pr_vlretorn         --crapprb.vlretorn 
              );          
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tabela crapprb. '||SQLERRM;
                RAISE vr_exc_saida;
            END;
        END;    
      END pc_proc_cria_crapprb;  /* End proc_cria_crapprb */

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
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
      --Cheques contidos do Bordero de desconto de cheques
      --com situacao 2-processado e nao devolvidos
      FOR rw_crapcdb IN cr_crapcdb( pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt) 
      LOOP
        --verifica se eh first-of
        IF rw_crapcdb.idreg = 1 THEN
          --inicializa o valor do lancamento
          vr_vllanmto := 0;
        END IF;  
         
        --acumula o valor dos cheques
        vr_vllanmto := nvl(vr_vllanmto,0) + rw_crapcdb.vlcheque;
        
        --verifica se eh last-of
        IF rw_crapcdb.idreg = rw_crapcdb.qtdereg THEN
          
          --armazenando a data de pagamento
          vr_dtdpagto := rw_crapcdb.dtlibera;
          
          -- se a data de pagamento menor que a proxima data de movimento
          IF vr_dtdpagto < rw_crapdat.dtmvtopr THEN
            --data de pagamento recebe o proximo dia de movimento
            vr_dtdpagto := rw_crapdat.dtmvtopr;
          END IF;    

          /** Alteracao tarefa 34548 (Henrique) **/
          /* Se o mes e' diferente */
          IF TO_CHAR(rw_crapdat.dtmvtolt,'MM') <> TO_CHAR(rw_crapdat.dtmvtopr,'MM') THEN 
            /* Verifica prazo do cheque */
            IF vr_dtdpagto < (rw_crapdat.dtmvtolt + 90)  THEN
               vr_chqacuml(1) := vr_chqacuml(1) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 180)  THEN
               vr_chqacuml(2) := vr_chqacuml(2) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 270)  THEN
               vr_chqacuml(3) := vr_chqacuml(3) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 360)  THEN
               vr_chqacuml(4) := vr_chqacuml(4) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 720)  THEN
               vr_chqacuml(5) := vr_chqacuml(5) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 1080)  THEN
               vr_chqacuml(6) := vr_chqacuml(6) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 1440)  THEN
               vr_chqacuml(7) := vr_chqacuml(7) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 1800)  THEN
               vr_chqacuml(8) := vr_chqacuml(8) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 2160)  THEN
               vr_chqacuml(9) := vr_chqacuml(9) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 2520)  THEN
               vr_chqacuml(10) := vr_chqacuml(10) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 2880)  THEN
               vr_chqacuml(11) := vr_chqacuml(11) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 3240)  THEN
               vr_chqacuml(12) := vr_chqacuml(12) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 3600)  THEN
               vr_chqacuml(13) := vr_chqacuml(13) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 3960)  THEN
               vr_chqacuml(14) := vr_chqacuml(14) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 4320)  THEN
               vr_chqacuml(15) := vr_chqacuml(15) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 4680)  THEN
               vr_chqacuml(16) := vr_chqacuml(16) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 5040)  THEN
               vr_chqacuml(17) := vr_chqacuml(17) + vr_vllanmto;
            ELSIF vr_dtdpagto < (rw_crapdat.dtmvtolt + 5400)  THEN
               vr_chqacuml(18) := vr_chqacuml(18) + vr_vllanmto;
            ELSIF vr_dtdpagto >= (rw_crapdat.dtmvtolt + 5400)  THEN
               vr_chqacuml(19) := vr_chqacuml(19) + vr_vllanmto;
            END IF;   
          END IF; /* End IF  verifica mes*/
        END IF;  
      END LOOP;  

      /** Verifica se o valor total e' maior que 0 para **/
      /** cada prazo. Se maior que 0, alimenta crapprb. **/
      FOR vr_indice IN 1 .. 19 LOOP
        -- se o valor acumulado eh maior que zero
        IF vr_chqacuml(vr_indice) > 0 THEN
          --efetua o lancamento na crapprb
          pc_proc_cria_crapprb( pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cddprazo => vr_indice
                               ,pr_vlretorn => vr_chqacuml(vr_indice));
        END IF;                                 
      END LOOP; /* End repeat */
                                   
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
    END;

  END pc_crps367;
/

