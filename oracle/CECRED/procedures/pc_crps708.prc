CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS708 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
BEGIN
   /* .............................................................................

   Programa: PC_CRPS708
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonata - RKAM
   Data    : Setembro/2016                        Ultima atualizacao: 24/11/2016

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Efetuar a contabilização do repasse dos recursos de TED entre as cooperativas

   Alteracoes: 01/11/2016 - Ajustes realizados para corrigir os problemas encontrados
                            durante a homologação da área de negócio
                            (Adriano - M211).

               24/11/2016 - Ajuste para alimentar correta o lote utilizado no
                            lançamento de créditos na conta do cooperado
                            (Adriano - SD 563707).

               20/03/2018 - Correção para quando rodar na quarta por motivo de feriados fazer
                      corretamente intervalo de terça a quarta. (Alexandre Borgmann-Mouts chamado 851502)

   ............................................................................. */
   DECLARE

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
     SELECT cop.nrctactl
       FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     -- Busca do valor de tarifa
     CURSOR cr_tarifa IS
     SELECT vltedtec
       FROM gncdtrf;
     vr_vltedtec gncdtrf.vltedtec%TYPE;

     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     -- Busca dos lancamentos de TED Sicredi do dia
     CURSOR cr_craplcm(pr_ini DATE
                      ,pr_fim DATE) IS
     SELECT cop.cdcooper
           ,cop.nrctactl
           ,COUNT(1) qtlanmto
       FROM craplcm lcm
           ,crapcop cop
      WHERE cop.cdcooper = lcm.cdcooper
        AND NOT cop.cdcooper IN (3,16)
        AND cop.flgativo = 1
        AND lcm.cdhistor = 1787
        AND lcm.nrdolote = 8482
        AND lcm.cdagenci = 1
        AND lcm.cdbccxlt = 100
        AND lcm.dtmvtolt BETWEEN pr_ini AND pr_fim
        GROUP BY cop.cdcooper
                ,cop.nrctactl;
     -- Quantidade acumulado total
     vr_qtlanmto NUMBER;

     -- Buscar Lote
     CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_nrdolote IN craptab.dstextab%TYPE) IS
     SELECT nrseqdig,
            qtinfoln,
            qtcompln,
            vlinfodb,
            vlcompdb,
            ROWID
       FROM craplot
      WHERE craplot.cdcooper = pr_cdcooper
        AND craplot.dtmvtolt = pr_dtmvtolt
        AND craplot.cdagenci = 1
        AND craplot.cdbccxlt = 100
        AND craplot.nrdolote = pr_nrdolote;
     rw_craplot cr_craplot%ROWTYPE;
     vr_hasfound BOOLEAN := FALSE;

     --Variaveis Locais
     vr_cdcritic INTEGER;
     vr_cdprogra VARCHAR2(10);
     vr_dscritic VARCHAR2(4000);
     vr_nmarqlog VARCHAR2(400) := 'prcctl_' || to_char(SYSDATE, 'RRRR') || to_char(SYSDATE,'MM') || to_char(SYSDATE,'DD') || '.log';

     --Variaveis de Excecao
     vr_exc_saida   EXCEPTION;
     vr_exc_fimprg  EXCEPTION;

     -- Busca das datas para processar
     vr_inicio DATE;
     vr_final  DATE;
     vr_date   DATE;

   ---------------------------------------
   -- Inicio Bloco Principal pc_crps707
   ---------------------------------------
   BEGIN

     --Atribuir o nome do programa que está executando
     vr_cdprogra:= 'CRPS708';

     -- Incluir nome do módulo logado
     GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                               ,pr_action => NULL);

     -- Validações iniciais do programa
     BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

     --Se retornou critica aborta programa
     IF vr_cdcritic <> 0 THEN

       --Descricao do erro recebe mensagam da critica
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );

       --Sair do programa
       RAISE vr_exc_saida;

     END IF;

     -- Verificação do calendário
     OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

     IF BTCH0001.cr_crapdat%NOTFOUND THEN
       CLOSE BTCH0001.cr_crapdat;

      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;

     ELSE
       -- Apenas fechar o cursor
       CLOSE BTCH0001.cr_crapdat;
     END IF;

     --> Gerar log
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                pr_ind_tipo_log => 2, --> erro tratado
                                pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' - '|| vr_cdprogra ||' --> Iniciando repasse de TEDs Sicredi',
                                pr_nmarqlog     => vr_nmarqlog);

     -- Busca do valor de tarifa
     OPEN cr_tarifa;

     FETCH cr_tarifa INTO vr_vltedtec;

     CLOSE cr_tarifa;

     vr_qtlanmto := 0;

     -- Somente se achou tarifa
     IF nvl(vr_vltedtec,0) > 0 THEN

       -- Busca datas para processamento
       vr_date := next_day(rw_crapdat.dtmvtolt-8,'QUARTA-FEIRA');

       vr_inicio := vr_date - 6;
       vr_final  := vr_date;

       -- Buscaremos todos os lançamentos de TEDs efetuadas no período para cada Cooperativa
       FOR rw_lcm IN cr_craplcm(vr_inicio,vr_final) LOOP

         -- Busca Lote
         OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_nrdolote => 8485);

         FETCH cr_craplot INTO rw_craplot;

         vr_hasfound := cr_craplot%FOUND;

         CLOSE cr_craplot;

         -- Se não existir
         IF NOT vr_hasfound THEN
           BEGIN
             -- Cria Lote
             INSERT INTO craplot (cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,qtcompln
                                 ,qtinfoln
                                 ,vlinfocr
                                 ,vlcompcr
                                 ,nrseqdig)
                           VALUES(pr_cdcooper
                                 ,rw_crapdat.dtmvtolt
                                 ,1           -- cdagenci
                                 ,100         -- cdbccxlt
                                 ,8485
                                 ,1
                                 ,1
                                 ,1
                                 ,rw_lcm.qtlanmto*vr_vltedtec
                                 ,rw_lcm.qtlanmto*vr_vltedtec
                                 ,1)
                        RETURNING nrseqdig
                             INTO rw_craplot.nrseqdig;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao gravar LOTE:'||sqlerrm;
               RAISE vr_exc_saida;
           END;
         ELSE -- Se Existir
           BEGIN
             -- Atualiza Lote
             UPDATE craplot
                SET qtcompln = nvl(craplot.qtcompln,0) + 1
                  , qtinfoln = nvl(craplot.qtinfoln,0) + 1
                  , vlinfocr = nvl(craplot.vlinfocr,0) + (rw_lcm.qtlanmto*vr_vltedtec)
                  , vlcompcr = nvl(craplot.vlcompcr,0) + (rw_lcm.qtlanmto*vr_vltedtec)
                  , nrseqdig = nvl(craplot.nrseqdig,0) + 1
              WHERE craplot.cdcooper = pr_cdcooper
                AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplot.cdagenci = 1
                AND craplot.cdbccxlt = 100
                AND craplot.nrdolote = 8485
          RETURNING nrseqdig
               INTO rw_craplot.nrseqdig;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar LOTE:' || sqlerrm;
               RAISE vr_exc_saida;
           END;
         END IF;

         -- Cria o lancamento em C/C
         BEGIN
           INSERT INTO craplcm (dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrdocmto
                               ,cdhistor
                               ,vllanmto
                               ,nrseqdig
                               ,cdcooper
                               ,hrtransa)
                        VALUES(rw_crapdat.dtmvtolt
                              ,1
                              ,100
                              ,8485
                              ,rw_lcm.nrctactl
                              ,rw_lcm.nrctactl
                              ,gene0002.fn_mask(rw_lcm.nrctactl,'99999999') -- nrdctitg
                              ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                              ,1810
                              ,rw_lcm.qtlanmto*vr_vltedtec
                              ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                              ,pr_cdcooper
                              ,to_char(SYSDATE,'sssss'));
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao criar repasse: '||SQLERRM;
             RAISE vr_exc_saida;
         END;

         -- Acumular ao total
         vr_qtlanmto := vr_qtlanmto + rw_lcm.qtlanmto;

       END LOOP;

       -- Se houve valor acumulado
       IF vr_qtlanmto > 0 THEN
         -- Busca Lote
         OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_nrdolote => 8486);

         FETCH cr_craplot INTO rw_craplot;

         vr_hasfound := cr_craplot%FOUND;

         CLOSE cr_craplot;

         -- Se não existir
         IF NOT vr_hasfound THEN
           BEGIN
             -- Cria Lote
             INSERT INTO craplot (cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,qtcompln
                                 ,qtinfoln
                                 ,vlinfocr
                                 ,vlcompcr
                                 ,nrseqdig)
                           VALUES(pr_cdcooper
                                 ,rw_crapdat.dtmvtolt
                                 ,1           -- cdagenci
                                 ,100         -- cdbccxlt
                                 ,8486
                                 ,1
                                 ,1
                                 ,1
                                 ,vr_qtlanmto*vr_vltedtec
                                 ,vr_qtlanmto*vr_vltedtec
                                 ,1)
                        RETURNING nrseqdig
                             INTO rw_craplot.nrseqdig;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao gravar LOTE destino:'||sqlerrm;
               RAISE vr_exc_saida;
           END;
         ELSE -- Se Existir
           BEGIN
             -- Atualiza Lote
             UPDATE craplot
                SET qtcompln = nvl(craplot.qtcompln,0) + 1
                  , qtinfoln = nvl(craplot.qtinfoln,0) + 1
                  , vlinfocr = nvl(craplot.vlinfocr,0) + (vr_qtlanmto*vr_vltedtec)
                  , vlcompcr = nvl(craplot.vlcompcr,0) + (vr_qtlanmto*vr_vltedtec)
                  , nrseqdig = nvl(craplot.nrseqdig,0) + 1
              WHERE craplot.cdcooper = pr_cdcooper
                AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplot.cdagenci = 1
                AND craplot.cdbccxlt = 100
                AND craplot.nrdolote = 8486
          RETURNING nrseqdig
               INTO rw_craplot.nrseqdig;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar LOTE destino:' || sqlerrm;
               RAISE vr_exc_saida;
           END;
         END IF;

         -- Buscar conta da AV na Central
         OPEN cr_crapcop (pr_cdcooper => 16);

         FETCH cr_crapcop INTO rw_crapcop;

         CLOSE cr_crapcop;

         -- Cria o lancamento em C/C
         BEGIN
           INSERT INTO craplcm (dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrdocmto
                               ,cdhistor
                               ,vllanmto
                               ,nrseqdig
                               ,cdcooper
                               ,hrtransa)
                        VALUES(rw_crapdat.dtmvtolt
                              ,1
                              ,100
                              ,8486
                              ,rw_crapcop.nrctactl
                              ,rw_crapcop.nrctactl
                              ,gene0002.fn_mask(rw_crapcop.nrctactl,'99999999') -- nrdctitg
                              ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                              ,1811
                              ,vr_qtlanmto*vr_vltedtec
                              ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                              ,pr_cdcooper
                              ,to_char(SYSDATE,'sssss'));
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao criar repasse no destino: '||SQLERRM;
             RAISE vr_exc_saida;
         END;
       END IF;
     END IF;

     -- Processo OK, devemos chamar a fimprg
     btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);

     --> Gerar log
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                pr_ind_tipo_log => 2, --> erro tratado
                                pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' - '|| vr_cdprogra ||' --> Encerramento do Repasse de TEDs Sicredi',
                                pr_nmarqlog     => vr_nmarqlog);

     --Salvar informacoes no banco de dados
     COMMIT;

   EXCEPTION
     WHEN vr_exc_fimprg THEN
       -- Se foi retornado apenas codigo
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;

       -- Se foi gerada critica para envio ao log
       IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic );
       END IF;

       --Limpar variaveis retorno
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       -- Efetuar commit pois gravaremos o que foi processo até então
       COMMIT;

     WHEN vr_exc_saida THEN
       -- Se foi retornado apenas código
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;

       -- Devolvemos código e critica encontradas
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;

       -- Efetuar rollback
       ROLLBACK;

     WHEN OTHERS THEN
       -- Efetuar retorno do erro não tratado
       pr_cdcritic := 0;
       pr_dscritic := 'Erro na procedure pc_crps707. '||sqlerrm;

       -- Efetuar rollback
       ROLLBACK;

   END;


END;
/
