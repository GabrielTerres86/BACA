CREATE OR REPLACE PROCEDURE cecred.PC_CRPS709 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
BEGIN
   /* .............................................................................

   Programa: pc_crps709
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro Guaranha - RKAM
   Data    : Setembro/2016                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Realizar o repasse dos recursos de TED entre as cooperativas

   Alteracoes:
   ............................................................................. */
   DECLARE

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
       SELECT cop.nrctactl
       FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     -- Busca dos lancamentos de TED Sicredi do dia
     CURSOR cr_craplcm IS
       SELECT cop.cdcooper
             ,cop.nrctactl
             ,SUM(lcm.vllanmto) vllanmto
         FROM craplcm lcm
             ,crapcop cop 
        WHERE cop.cdcooper = lcm.cdcooper
          AND cop.cdcooper <> 3
          AND cop.flgativo = 1
          AND lcm.cdhistor = 1787
          AND lcm.nrdolote = 8482
          AND lcm.cdagenci = 1
          AND lcm.cdbccxlt = 100
          AND lcm.dtmvtolt = rw_crapdat.dtmvtolt
        GROUP BY cop.cdcooper
                ,cop.nrctactl;
    -- Valor acumulado total 
    vr_vllanmto craplcm.vllanmto%TYPE;
   
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
     vr_cdcritic     INTEGER;
     vr_cdprogra     VARCHAR2(10);
     vr_dscritic     VARCHAR2(4000);
     vr_nmarqlog     VARCHAR2(400) := 'prcctl_' || to_char(SYSDATE, 'RRRR') || to_char(SYSDATE,'MM') || to_char(SYSDATE,'DD') || '.log';
      

     --Variaveis de Excecao
     vr_exc_saida   EXCEPTION;
     vr_exc_email   EXCEPTION;
     vr_exc_fimprg  EXCEPTION;



   ---------------------------------------
   -- Inicio Bloco Principal pc_crps707
   ---------------------------------------
   BEGIN

     --Atribuir o nome do programa que está executando
     vr_cdprogra:= 'CRPS709';

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
      RAISE vr_exc_email;
        
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
     
     vr_vllanmto := 0;
     -- Buscaremos todos os lançamentos de TEDs efetuadas no dia para cada Cooperativa
     FOR rw_lcm IN cr_craplcm LOOP
       -- Busca Lote
       OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_nrdolote => 8483);
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
                               ,vlinfocr
                               ,vlcompcr
                               ,nrseqdig)
                         VALUES(pr_cdcooper
                               ,rw_crapdat.dtmvtolt
                               ,1           -- cdagenci
                               ,100         -- cdbccxlt
                               ,8483
                               ,1
                               ,1
                               ,rw_lcm.vllanmto
                               ,rw_lcm.vllanmto
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
              SET qtcompln = qtcompln + 1
                , vlinfocr = vlinfocr + rw_lcm.vllanmto
                , vlcompcr = vlcompcr + rw_lcm.vllanmto
                , nrseqdig = nrseqdig + 1
            WHERE craplot.cdcooper = pr_cdcooper
              AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
              AND craplot.cdagenci = 1
              AND craplot.cdbccxlt = 100
              AND craplot.nrdolote = 8483
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
                            ,8483
                            ,rw_lcm.nrctactl
                            ,rw_lcm.nrctactl
                            ,gene0002.fn_mask(rw_lcm.nrctactl,'99999999') -- nrdctitg
                            ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                            ,1789
                            ,rw_lcm.vllanmto
                            ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                            ,pr_cdcooper
                            ,to_char(SYSDATE,'sssss'));
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao criar repasse: '||SQLERRM;
           RAISE vr_exc_saida;
       END;
       
       -- Acumular ao total
       vr_vllanmto := vr_vllanmto + rw_lcm.vllanmto;
     
     END LOOP;
     
     -- Se houve valor acumulado
     IF vr_vllanmto > 0 THEN 
       -- Busca Lote
       OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_nrdolote => 8484);
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
                               ,vlinfocr
                               ,vlcompcr
                               ,nrseqdig)
                         VALUES(pr_cdcooper
                               ,rw_crapdat.dtmvtolt
                               ,1           -- cdagenci
                               ,100         -- cdbccxlt
                               ,8484
                               ,1
                               ,1
                               ,vr_vllanmto
                               ,vr_vllanmto
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
              SET qtcompln = qtcompln + 1
                , vlinfocr = vlinfocr + vr_vllanmto
                , vlcompcr = vlcompcr + vr_vllanmto
                , nrseqdig = nrseqdig + 1
            WHERE craplot.cdcooper = pr_cdcooper
              AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
              AND craplot.cdagenci = 1
              AND craplot.cdbccxlt = 100
              AND craplot.nrdolote = 8484
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
       FETCH cr_crapcop
        INTO rw_crapcop;
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
                            ,8484
                            ,rw_crapcop.nrctactl
                            ,rw_crapcop.nrctactl
                            ,gene0002.fn_mask(rw_crapcop.nrctactl,'99999999') -- nrdctitg
                            ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                            ,1788
                            ,vr_vllanmto
                            ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                            ,pr_cdcooper
                            ,to_char(SYSDATE,'sssss'));
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao criar repasse no destino: '||SQLERRM;
           RAISE vr_exc_saida;
       END;              
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
