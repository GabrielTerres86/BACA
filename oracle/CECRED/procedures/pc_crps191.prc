CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps191 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps191 (Fontes/crps191.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Abril/97.                      Ultima atualizacao: 06/08/2018

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atende a solicitacao 005.
                   Gerar avisos de debito em conta

       Alteracoes: 28/05/97 - Alterado para nao imprimir etiquetas para a Credito
                          (Deborah).

                   27/08/97 - Alterado para incluir o campo flgproce na criacao
                              do crapavs (Deborah).

                   04/12/97 - Tirar IF para imprimir etiquetas para Credito (Odair)

                   09/09/98 - Tratar novas administradoras (Odair)

                   18/09/98 - Gerar etiquetas somente para lancamentos de fatura
                              (Deborah).

                   09/08/1999 - Colocar mensagem de impressao no log (Deborah).

                   05/01/2000 - Padronizar as mensagens (Deborah).

                   22/12/2000 - Imprimir etiquetas nas impressoras a laser
                                (Eduardo).

                   05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo)

                   09/02/2004 - Alterada forma de impressao, todas as etiquetas
                                deverao ir para a fila da cecred, inclusao
                                do nome da cooperativa na etiqueta (Julio).

                   27/04/2004 - Tratamento para cooperativa 3, nao procurar
                                crapcrd (Julio).

                   18/05/2004 - Inclusao da impressao no log impressao.log (Julio)

                   28/07/2004 - Referencia da STREAM no comando DOWN (Julio)

                   07/04/2005 - Pular uma linha na primeira pagina do crrl149.lst
                                (Evandro).

                   29/06/2005 - Alimentado campo cdcooper das tabelas craprej e
                                crapavs (Diego).

                   20/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   02/03/2006 - Nao imprimir as etiquetas Cecred Visa (Ze).

                   18/04/2006 - Imprimir somente se ha etiquetas geradas (Edson).

                   26/04/2006 - Desprezar administradoras 83/84/85/86/87/88(BB)
                                (Mirtes)

                   04/06/2008 - Campo dsorigem nas leituras da craplau (David)

                   31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   14/07/2009 - incluido no for each a condição -
                                craplau.dsorigem <> "PG555" - Precise - paulo

                   02/06/2011 - incluido no for each a condição -
                                craplau.dsorigem <> "TAA" (Evandro).

                   03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                                craplau. (Fabricio)

                   25/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

                   03/06/2013 - incluido no FOR EACH craplau a condicao -
                                craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)

                   31/10/2013 - Remover geracao do crrl149 - Sofdesk 103182
                                (Lucas R.)

                   02/01/2014 - Retirado variavel aux_dscomand e os lugares onde
                                era utilizada (Tiago).

                   16/01/2014 - Inclusao de VALIDATE crapavs (Carlos)

                   23/01/2014 - Conversão Progress >> Oracle PL/SQL (Tiago Castro - RKAM)

                   18/02/2014 - Removido do programa codigo nao usado mais
                                Softdesk - 128250 (Gabriel)

                   01/04/2014 - incluido nas consultas da craplau
                                craplau.dsorigem <> "DAUT BANCOOB" (Lucas).

                   28/09/2015 - incluido nas consultas da craplau
                                craplau.dsorigem <> "CAIXA" (Lombardi).

                   20/05/2016 - Incluido nas consultas da craplau
                                craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)

                   02/03/2017 - Incluido nas consultas da craplau 
                                craplau.dsorigem <> "ADIOFJUROS" (Lucas Ranghetti M338.1)

                   06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
                                após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
                                Alteração específica neste programa acrescentando o tratamento para a origem
                                BLQPREJU. (Renato Cordeiro - AMcom)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS191';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
      vr_inrestar   NUMBER(1);
      vr_nrctares   NUMBER(12);
      vr_dsrestar   VARCHAR2(4000);             --> String genérica com informações para restart

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
      -- busca capas de lote do tipo 17
      CURSOR cr_craplot IS
        SELECT  dtmvtolt,
                cdagenci,
                cdbccxlt,
                nrdolote
        FROM    craplot
        WHERE   craplot.cdcooper  = pr_cdcooper
        AND     craplot.dtmvtolt  = vr_dtmvtolt
        AND     craplot.tplotmov  = 17
        AND     craplot.nrdolote >= vr_nrctares;

      -- busca lancamentos automáticos
      CURSOR cr_craplau(pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE ) IS
SELECT nrdconta
      ,nrcrcard
      ,cdhistor
      ,vllanaut
      ,nrseqdig
      ,nrdocmto
      ,dtmvtolt
      ,dtmvtopg
      ,nrseqlan
      ,nrdolote
  FROM craplau
 WHERE craplau.cdcooper = pr_cdcooper
   AND craplau.dtmvtolt = pr_dtmvtolt
   AND craplau.cdagenci = pr_cdagenci
   AND craplau.cdbccxlt = pr_cdbccxlt
   AND craplau.nrdolote = pr_nrdolote
   AND craplau.nrseqlan > NVL(TRIM(vr_dsrestar), '0')
        -- sistemas que foi originada a operaçao
   AND craplau.dsorigem NOT IN ('CAIXA'
                               ,'INTERNET'
                               ,'TAA'
                               ,'PG555'
                               ,'CARTAOBB'
                               ,'BLOQJUD'
                               ,'DAUT BANCOOB'
                               ,'TRMULTAJUROS'
                               ,'BLQPREJU'
                               ,'ADIOFJUROS');

      -- busca cadastro de associados
      CURSOR cr_crapass(pr_nrdconta IN craplau.nrdconta%TYPE)  IS
        SELECT  inpessoa,
                nrdconta,
                nmprimtl,
                cdsecext,
                cdagenci
        FROM    crapass
        WHERE   crapass.cdcooper = pr_cdcooper
        AND     crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
        FROM crapres res
        WHERE res.cdcooper = pr_cdcooper
        AND res.cdprogra   = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

       -- Definição de tipo para armazenar o nome da administradora


      ------------------------------- VARIAVEIS -------------------------------

      --------------------------- SUBROTINAS INTERNAS --------------------------


      --------------- VALIDACOES INICIAIS -----------------

    BEGIN

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

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;

      END IF;
      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      vr_dtmvtolt := rw_crapdat.dtmvtolt;

      -- busca capas de lotes tipo 17
      FOR rw_craplot IN cr_craplot LOOP
        -- busca lancamentos automáticos
        FOR rw_craplau IN cr_craplau( rw_craplot.dtmvtolt
                                     ,rw_craplot.cdagenci
                                     ,rw_craplot.cdbccxlt
                                     ,rw_craplot.nrdolote) LOOP
           -- busca cadastro do associado
          OPEN cr_crapass(rw_craplau.nrdconta );
          FETCH cr_crapass INTO rw_crapass;
          -- verifica se a conta foi encontrada
          IF cr_crapass%NOTFOUND THEN 
            CLOSE cr_crapass;
            pr_cdcritic := 251;-- gera critica 251
            RAISE vr_exc_saida;
          END IF;
          CLOSE cr_crapass;

          BEGIN
            -- insere dados de cadastro de débito em conta corrente
            INSERT INTO crapavs 
              ( cdagenci
               ,cdempres
               ,cdhistor
               ,cdsecext
               ,dtdebito
               ,dtmvtolt
               ,dtrefere
               ,insitavs
               ,nrdconta
               ,nrdocmto
               ,nrseqdig
               ,tpdaviso
               ,vldebito
               ,vlestdif
               ,vlestour
               ,vllanmto
               ,dtintegr
               ,flgproce
               ,cdcooper
              )
              VALUES
              ( rw_crapass.cdagenci
               ,0
               ,rw_craplau.cdhistor
               ,rw_crapass.cdsecext
               ,rw_craplau.dtmvtopg
               ,rw_craplau.dtmvtolt
               ,rw_craplau.dtmvtolt
               ,0
               ,rw_craplau.nrdconta
               ,rw_craplau.nrdocmto
               ,rw_craplau.nrseqdig
               ,2
               ,0
               ,0
               ,0
               ,rw_craplau.vllanaut
               ,NULL
               ,0
               ,pr_cdcooper
              );
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir dados na tabela crapavs. '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          -- atualizar tabela de controde de restart a cada 1000 registros
          IF Mod(cr_craplau%ROWCOUNT,1000) = 0 THEN          
            -- Atualizar a tabela de restart
            BEGIN
              UPDATE crapres res
                 SET res.nrdconta = rw_craplau.nrdolote
                    ,res.dsrestar = rw_craplau.nrseqlan
               WHERE res.rowid    = rw_crapres.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Lote:'||rw_craplau.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_saida;
            END;
            -- Finalmente efetua commit
            COMMIT;
          END IF;
        END LOOP;
      END LOOP;

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

  END pc_crps191;
