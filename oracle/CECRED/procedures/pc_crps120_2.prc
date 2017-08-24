CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps120_2(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                     ,pr_cdprogra  IN crapprg.cdprogra%TYPE DEFAULT NULL  --> Codigo do programa chamador
                     ,pr_crapdat   IN BTCH0001.cr_crapdat%ROWTYPE   --> type contendo as informações da crapdat
                     ,pr_nrdconta  IN crapass.nrdconta%TYPE   --> Nr da conta do associado
                     ,pr_nrdolote  IN crapepr.nrdolote%TYPE   --> Nr do lote do emprestimo
                     ,pr_vldaviso  IN NUMBER                  --> Valor de aviso
                     ,pr_vlsalliq  IN NUMBER                  --> Valor de saldo liquido
                     ,pr_dtintegr  IN DATE                    --> Data de integração
                     ,pr_cdhistor  IN craphis.cdhistor%TYPE   --> Cod do historico
                     ,pr_insitavs OUT crapavs.insitavs%TYPE  --> Situação do aviso
                     ,pr_vldebito OUT crapavs.vldebito%TYPE  --> Retorno do valor debito
                     ,pr_vlestdif OUT crapavs.vlestdif%TYPE  --> Valor da diferença
                     ,pr_vldoipmf OUT NUMBER                 -->
                     ,pr_flgproce OUT crapavs.flgproce%TYPE  --> retorno indicativo de processamento
                     ,pr_cdcritic OUT PLS_INTEGER            --> Critica encontrada
                     ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps120_2 (Fontes/crps120_2.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/95.                     Ultima atualizacao: 05/08/2015

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado pelo crps120.
       Objetivo  : Processar os debitos dos planos de capital (Cotas).

       Alteracoes: 16/01/97 - Alterado para tratar CPMF (Edson).

                   13/02/97 - Fazer tratamento para nova rotina do capital (Odair).

                   27/08/97 - Alterado para tratar o campo flgproce (Deborah).

                   30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

                   11/04/03 - Comparar com o total de prestacoes do plano capital.
                              (Ze Eduardo).

                   29/06/2005 - Alimentado campo cdcooper da tabela craplct (Diego).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   20/08/2013 - Quando o salario nao for suficiente para o debito
                                de cotas, seta crappla.indpagto = 0 e atribui o
                                valor da prestacao de cotas ao novo campo
                                crappla.vlpenden. Do contrario, seta indpagto = 1 e
                                atribui valor zero ao campo vlpenden. (Fabricio)

                   16/12/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

                   15/01/2014 - Inclusao de VALIDATE craplct (Carlos)

                   27/01/2014 - Atualizacao do campo crappla.dtdpagto (data do
                                proximo debito). (Fabricio)

                   21/02/2014 - Replicação da manutenção progres (Odirlei-AMcom)

                   28/07/2015 - Separacao da procedure pc_debita_plano_capital 
                                do programa pc_crps120 para pc_crps120_2. (Jaison)

                   05/08/2015 - Alteracao para gravar o valor do lancamento na
                                craplot como debito e nao como credito. (Jaison)
					
                   23/08/2016 - Aplicado atualização na FLGATUPL, flag atualiza Plano,
                                essa melhoria foi aplicado no Progress mãs não foi 
                                replicado para o fonte do Oracle. (Mauro - Mouts).
                                Abaixo melhoria do progress.
                                ####27/03/2014 - Atualizacao do campo crappla.flgatupl 
                                (identificador de necessidade de correcao do valor
                                do plano de capital). (Fabricio)#####

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS120';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Ler Planos de capitalizacao.
      CURSOR cr_crappla IS
        SELECT qtpremax,
               qtprepag,
               nrdconta,
               dtultpag,
               nrctrpla,
               dtdpagto,
			   cdtipcor,
               dtultcor,
               rowid
          FROM crappla
         WHERE crappla.cdcooper = pr_cdcooper
           AND crappla.nrdconta = pr_nrdconta
           AND crappla.tpdplano = 1
           AND crappla.cdsitpla = 1 -- Ativo
         --Ordenar pelo indice CRAPPLA##CRAPPLA1, para buscar o find first
         ORDER BY CDCOOPER,
                  NRDCONTA,
                  TPDPLANO,
                  NRCTRPLA;
      rw_crappla cr_crappla%ROWTYPE;

      -- Ler Cadastro com informacoes referentes a cotas e recursos
      CURSOR cr_crapcot (pr_cdcooper crapcop.cdcooper%type,
                         pr_nrdconta crappla.nrdconta%type)IS
        SELECT
               rowid
          FROM crapcot
         WHERE crapcot.cdcooper = pr_cdcooper
           AND crapcot.nrdconta = pr_nrdconta;
      rw_crapcot cr_crapcot%ROWTYPE;

      -- Busca dos dados de Linhas de Credito
      CURSOR cr_craplot (pr_cdcooper crapcop.cdcooper%type,
                         pr_dtintegr date,
                         pr_cdagenci crapage.cdagenci%type,
                         pr_cdbccxlt crapban.cdbccxlt%type,
                         pr_nrdolote crapepr.nrdolote%type) IS
      SELECT dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrseqdig,
             qtinfoln,
             qtcompln,
             vlinfocr,
             vlcompcr,
             rowid
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtintegr
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      vr_flgsomar INTEGER;
      vr_nrseqdig NUMBER := 0;
      vr_vllanmto crappla.vlpagmes%TYPE;
      vr_indcance INTEGER := 0;
      vr_dtdpagto crappla.dtdpagto%TYPE;
	   -- data de 1 ano atrás
      vr_dtultcor_year DATE := pr_crapdat.dtmvtolt - INTERVAL '1' YEAR;

      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => pr_cdprogra
                                ,pr_action => 'PC_'||vr_cdprogra);

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      pr_vldebito := 0;
      pr_flgproce := 0;--FALSE;

      -- Ler Planos de capitalizacao.
      OPEN cr_crappla;
      FETCH cr_crappla
        INTO rw_crappla;

      IF cr_crappla%NOTFOUND THEN
        -- Se não localizar retornar
        pr_vlestdif := pr_vldaviso;
        pr_insitavs := 1;
        pr_flgproce := 1;--TRUE;
        CLOSE cr_crappla;
        RETURN;
      ELSE
        CLOSE cr_crappla;
        --Se a quantidade de prestações ultrapassar a qtd maxima, retornar
        IF nvl(rw_crappla.qtprepag,0) > nvl(rw_crappla.qtpremax,0)  THEN
          pr_vlestdif := pr_vldaviso;
          pr_insitavs := 1;
          pr_flgproce := 1;--TRUE;
          RETURN;
        END IF;
      END IF;

      -- Ler Cadastro com informacoes referentes a cotas e recursos
      OPEN cr_crapcot (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => rw_crappla.nrdconta);
      FETCH cr_crapcot
        INTO rw_crapcot;

      IF cr_crapcot%NOTFOUND THEN
        vr_dscritic := gene0001.fn_busca_critica(169);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta));
        CLOSE cr_crapcot;
        --retonar para o programa chamador
        RETURN;
      ELSE
        CLOSE cr_crapcot;
      END IF;

      -- definir se deve somar
      IF TO_CHAR(pr_crapdat.dtmvtolt,'MM') = TO_CHAR(rw_crappla.dtultpag,'MM') THEN
        -- Se for o mesmo mes
        vr_flgsomar := 1; --TRUE
      ELSE
        vr_flgsomar := 0; --FALSE
      END IF;

      pr_vldoipmf := 0;

      /* Calcular data de pagamento */
      vr_dtdpagto := GENE0005.fn_calc_data(pr_dtmvtolt => NVL(rw_crappla.dtdpagto,pr_crapdat.dtmvtolt),
                                           pr_qtmesano => 1,
                                           pr_tpmesano => 'M',
                                           pr_des_erro => vr_dscritic);
      IF trim(vr_dscritic) is not null THEN
        RAISE vr_exc_saida;
      END IF;
      /* Verifica se o valor do salario eh suficiente para debitar a parcela do
         plano */
      IF nvl(pr_vldaviso,0) > (nvl(pr_vlsalliq,0) + nvl(pr_vldoipmf,0)) THEN
        pr_vlestdif := pr_vldaviso * -1;
        pr_insitavs := 1;
        pr_flgproce := 1;--TRUE;
        pr_vldoipmf := 0;

        /* Mesmo sem debitar COTAS passaremos o aviso de debito para
        "processado". Com a tentativa diaria de debito da parcela de
        COTAS este valor ficara pendente na LAUTOM atraves do registro
        na crappla */
        BEGIN
          UPDATE crappla
             SET crappla.indpagto = 0, /* A debitar */
                 crappla.vlpenden = pr_vldaviso,
                 crappla.dtdpagto = vr_dtdpagto
           WHERE ROWID = rw_crappla.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel atualizar  Plano de capitalizacao'
                         ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)||':'||SQLERRM;
            RAISE vr_exc_saida;
        END;

        RETURN;

      ELSE
        vr_vllanmto := pr_vldaviso;
        pr_vlestdif := 0;
        pr_insitavs := 1;
        pr_flgproce := 1; -- TRUE;

      END IF;

      -- Buscar lote
      OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                       pr_dtintegr => pr_dtintegr,
                       pr_cdagenci => 1,
                       pr_cdbccxlt => 100,
                       pr_nrdolote => pr_nrdolote);
      FETCH cr_craplot
        INTO rw_craplot;

      --  se não encontrar gravar log
      IF cr_craplot%NOTFOUND THEN
        vr_dscritic := gene0001.fn_busca_critica(60);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '|| vr_dscritic
                                                   ||'AG: 001 BCX: 100 LOTE:'|| gene0002.fn_mask(pr_nrdolote,'999999'));
        CLOSE cr_craplot;
        --retonar para o programa chamador
        RETURN;
      ELSE
        --somente fechar cursor
        CLOSE cr_craplot;
      END IF;

      -- Inserir Lancamentos de cotas/capital
      BEGIN
        INSERT INTO craplct
                    ( dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrdconta
                     ,nrdocmto
                     ,cdhistor
                     ,vllanmto
                     ,nrseqdig
                     ,nrctrpla
                     ,cdcooper)

             VALUES ( rw_craplot.dtmvtolt -- dtmvtolt
                     ,rw_craplot.cdagenci -- cdagenci
                     ,rw_craplot.cdbccxlt -- cdbccxlt
                     ,rw_craplot.nrdolote -- nrdolote
                     ,rw_crappla.nrdconta -- nrdconta
                     ,rw_craplot.nrdolote -- nrdocmto
                     ,pr_cdhistor         -- cdhistor
                     ,vr_vllanmto         -- vllanmto
                     ,(rw_craplot.nrseqdig + 1) -- nrseqdig
                     ,rw_crappla.nrctrpla -- nrctrpla
                     ,pr_cdcooper         -- cdcooper
                     )
          RETURNING nrseqdig INTO vr_nrseqdig;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel inserir lançamento de cotas/capital(craplct)'
                         ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)
                         ||' DOC: '|| rw_craplot.nrdolote||' :'||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Atualizar lote
      BEGIN
        UPDATE craplot
           SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
               craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
               craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(vr_vllanmto,0),
               craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(vr_vllanmto,0),
               craplot.nrseqdig = vr_nrseqdig
         WHERE ROWID = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar lote(CRAPLOT)'
                         ||' cdcooper: '|| pr_cdcooper
                         ||' nrdolote: '|| pr_nrdolote||' :'||SQLERRM;
          RAISE vr_exc_saida;
      END;
        
      -- atualizar cotas 
      BEGIN
        UPDATE  crapcot
        SET     crapcot.vldcotas = nvl(crapcot.vldcotas,0) + nvl(vr_vllanmto,0),
                crapcot.qtprpgpl = nvl(crapcot.qtprpgpl,0) + 1
        WHERE   ROWID = rw_crapcot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar lote(CRAPCOT)'
                         ||' cdcooper: '|| pr_cdcooper
                         ||' nrdolote: '|| pr_nrdolote||' :'||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Atualizar Planos de capitalizacao.
      BEGIN
        IF (rw_crappla.qtprepag+1) = rw_crappla.qtpremax THEN
          vr_indcance := 1;
        END IF;

        UPDATE crappla
           SET crappla.indpagto = 1, /* Debito efetuado */
               crappla.vlpenden = 0,
               crappla.dtultpag = rw_craplot.dtmvtolt,
               crappla.dtdpagto = vr_dtdpagto,
               crappla.qtprepag = crappla.qtprepag + 1,
               crappla.vlprepag = crappla.vlprepag + nvl(vr_vllanmto,0),
               crappla.vlpagmes = (CASE
                                     -- verificar se deve somar com o valor ja existente
                                     WHEN vr_flgsomar = 1 /*true*/ THEN
                                       crappla.vlpagmes + nvl(vr_vllanmto,0)
                                     -- ou apenas inicializar
                                     ELSE nvl(vr_vllanmto,0)
                                   END),
              crappla.dtcancel = (CASE vr_indcance
                                    -- Verificar se deve preencher a data de cancelamento
                                    WHEN 1 THEN pr_crapdat.dtmvtolt
                                    -- ou deixa a existente
                                    ELSE crappla.dtcancel
                                  END),
              crappla.cdsitpla = (CASE vr_indcance
                                    -- Verificar se deve atualizar a situação de cancelamento, para 2-cancelado
                                    WHEN 1 THEN 2
                                    -- ou deixa a mesma situação
                                    ELSE crappla.cdsitpla
                                  END)
         WHERE ROWID = rw_crappla.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar Plano de capitalizacao(crappla)'
                         ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)||' :'||SQLERRM;
          RAISE vr_exc_saida;
      END;

      pr_vldebito := vr_vllanmto;

	        -- Atualiza valor do plano
      BEGIN
        IF(rw_crappla.dtultcor <= vr_dtultcor_year AND rw_crappla.cdtipcor>0)THEN
           UPDATE crappla
           SET crappla.flgatupl = 1
           WHERE ROWID = rw_crappla.rowid;
         END IF; 
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar Plano de capitalizacao(crappla)'
                         ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)||' :'||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
    END;

  END pc_crps120_2;
/

