CREATE OR REPLACE PROCEDURE CECRED.pc_crps604(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER           --> Flag padrão para utilização de restart
                                             ,pr_cdoperad IN VARCHAR2                --> Codigo Operador
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps604 (Fontes/crps604.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Gati - Oliver
       Data    : Agosto/2011                     Ultima atualizacao: 24/07/2016

       Dados referentes ao programa:

       Frequencia : Diario. Solicitacao 1 / Ordem 36 / Cadeia Exclusiva.
       Objetivo   : Realizar a renovacao dos seguros residenciais.
       
       Alteracoes: 08/12/2011 - Incluida validacao chave tabela crawseg (Diego).
       
                   19/12/2011 - Incluido a passagem do parametro crawseg.dtnascsg
                                na procedure cria_seguro (Adriano).
       
                   27/02/2013 - Incluir parametro aux_flgsegur na procedure 
                                cria_seguro (Lucas R.).
                                
                   25/07/2013 - Incluido o parametro "crawseg.complend" na
                                chamada da procedure "cria_seguro()". (James)
                                
                   29/04/2014 - Considerar o valor do plano no novo seguro e 
                                nao mais o valor do antigo seguro (Jonata-RKAM).
                                
                   10/11/2014 - Por enquanto, foi retirado o tratamento 
                                de renovacao automatica dos seguros de vida
                                (Jonata-RKAM). 
                                
                   13/02/2015 - Ajuste para incluir a renovacao automatica do 
                                seguro de vida.(James)
                                
                   16/06/2015 - Incluir a renovacao do seguro de vida no Oracle.
                                (James)

                   22/07/2016 - Conversao Progress >> Oracle (Jonata-Rkam)
                   
    ............................................................................ */

    DECLARE 

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS604';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.cdagectl
              ,cop.cdbcoctl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Seguros residenciais vencidos
      CURSOR cr_crapseg IS
        SELECT seg.nrdconta
              ,wseg.dtfimvig
              ,tsg.flgunica
              ,wseg.qtparcel
              ,wseg.dtdebito
              ,wseg.tpseguro
              ,wseg.cdsegura
              ,seg.flgclabe
              ,seg.tpendcor
              ,wseg.tpplaseg
              ,tsg.vlplaseg
              ,wseg.nrcpfcgc
              ,wseg.nmdsegur
              ,wseg.vlpremio
              ,wseg.cdcalcul
              ,wseg.vlseguro
              ,wseg.dsendres
              ,wseg.nrendres
              ,wseg.nmbairro
              ,wseg.nmcidade
              ,wseg.cdufresd
              ,wseg.nrcepend
              ,wseg.dtnascsg
              ,wseg.complend
              ,seg.nmbenvid##1
              ,seg.nmbenvid##2
              ,seg.nmbenvid##3
              ,seg.nmbenvid##4
              ,seg.nmbenvid##5
              ,seg.dsgraupr##1
              ,seg.dsgraupr##2
              ,seg.dsgraupr##3
              ,seg.dsgraupr##4
              ,seg.dsgraupr##5 
              ,seg.txpartic##1                                                       
              ,seg.txpartic##2
              ,seg.txpartic##3
              ,seg.txpartic##4
              ,seg.txpartic##5
          FROM crapseg  seg
              ,crawseg wseg
              ,craptsg  tsg
         WHERE seg.cdcooper = wseg.cdcooper 
           AND seg.nrdconta = wseg.nrdconta 
           AND seg.tpseguro = wseg.tpseguro 
           AND seg.nrctrseg = wseg.nrctrseg 
           AND seg.cdcooper = tsg.cdcooper 
           AND seg.tpplaseg = tsg.tpplaseg 
           AND seg.cdsegura = tsg.cdsegura 
           AND seg.tpseguro = tsg.tpseguro  
           AND seg.cdcooper = pr_cdcooper
           AND seg.tpseguro = 11    /* Residencia */
           AND seg.cdsitseg IN(1,3) /* Novo, Renovado  */
           AND seg.dtfimvig  > rw_crapdat.dtmvtolt
           AND seg.dtfimvig <= rw_crapdat.dtmvtopr;
      
      -- Busca ultimo contrato de seguro CASA cadastrado
      CURSOR cr_prox_wseg(pr_nrdconta crawseg.nrdconta%TYPE) IS
        SELECT nvl(MAX(nrctrseg),0) + 1
          FROM crawseg
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpseguro IN(11,1); /* Residencia */
      
      -- Garantir que o próximo contrato não esteja cadastrado em outro tipo de seguro
      CURSOR cr_prox_wseg_unico(pr_nrdconta crawseg.nrdconta%TYPE
                               ,pr_nrctrseg crawseg.nrctrseg%TYPE) IS
        SELECT 1
          FROM crawseg
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrseg = pr_nrctrseg;
      vr_flgexist NUMBER;
       
      -- Variaveis auxiliares
      vr_dtprideb crawseg.dtmvtolt%TYPE;
      vr_nrctrseg crawseg.nrctrseg%TYPE;
      vr_dtdebito crawseg.dtmvtolt%TYPE;
      vr_tab_dsgraupr segu0001.typ_tab_dsgraupr;
      vr_tab_nmbenvid segu0001.typ_tab_nmbenvid;
      vr_tab_txpartic segu0001.typ_tab_txpartic;
      vr_flgsegur BOOLEAN;
      vr_crawseg  ROWID;
      vr_tab_erro gene0001.typ_tab_erro;
      
    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

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

      -- Busca Seguros residenciais vencidos
      FOR rw_seg IN cr_crapseg LOOP
        -- Se data de fim da vigência for dia util
        IF gene0005.fn_valida_dia_util(pr_cdcooper,rw_seg.dtfimvig) = rw_seg.dtfimvig THEN
          -- Efetua primeiro debito na data de inicio de vigencia do sego renovado
          vr_dtprideb := rw_seg.dtfimvig;
        ELSE
          -- Se a data do vencimento esta no proximo mes, devera efetuar o primeiro
          -- debito no mes do vencimento, e devera aparecer no relatorio 416 no mes 
          -- do vencimento. Caso contrario o primeiro debito eh antecipado  
          IF to_char(rw_crapdat.dtmvtolt,'mm') <> to_char(rw_seg.dtfimvig,'mm')  THEN
            vr_dtprideb := rw_crapdat.dtmvtopr;
          ELSE
            vr_dtprideb := rw_crapdat.dtmvtolt;
          END IF;
        END IF;
        
        -- Gera novo numero de contrato
        OPEN cr_prox_wseg(pr_nrdconta => rw_seg.nrdconta);
        FETCH cr_prox_wseg
         INTO vr_nrctrseg;
        CLOSE cr_prox_wseg; 
      
        -- Garantir que o próximo contrato não esteja cadastrado em outro tipo de seguro
        LOOP
          OPEN cr_prox_wseg_unico(pr_nrdconta => rw_seg.nrdconta
                                 ,pr_nrctrseg => vr_nrctrseg);
          FETCH cr_prox_wseg_unico
           INTO vr_flgexist;
          -- Se existir
          IF cr_prox_wseg_unico%FOUND THEN 
            -- Buscar novamente incrementando o número de contrado
            CLOSE cr_prox_wseg_unico;
            vr_nrctrseg := vr_nrctrseg + 1;
          ELSE
            -- Sair.
            CLOSE cr_prox_wseg_unico;
            EXIT; 
          END IF; 
        END LOOP;
        
        -- Calculo da data do debito
        -- Caso não seja parcela unica
        IF rw_seg.flgunica = 0 AND rw_seg.qtparcel <> 1 THEN
          -- Calcula a data para o proximo mes
          vr_dtdebito := gene0005.fn_calc_data(pr_dtmvtolt => to_date(to_char(rw_seg.dtdebito,'dd')||to_char(rw_seg.dtfimvig,'mmrrrr'),'ddmmrrrr') --> Data atual
                                              ,pr_qtmesano => 1   --> Quantidade a acumular
                                              ,pr_tpmesano => 'M' --> Tipo Mes ou Ano
                                              ,pr_des_erro => vr_dscritic);
          -- Havendo erro
          IF vr_dscritic IS NOT NULL THEN
            -- Incrementar a critica
            vr_dscritic := 'Nao foi possivel calcular da data da proxima parcela. '
                        || ' Tipo seguro: ' || rw_seg.tpseguro || '.'
                        || ' Conta: ' || rw_seg.nrdconta ||'. Critica: '||vr_dscritic;
            -- Gerar  LOG          
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );          
            -- Ir ao próximo registro
            continue;            
          END IF;
        ELSE 
          -- Parcela unica
          vr_dtdebito := vr_dtprideb;
        END IF; 
        -- Converter valores da tabela para pltables de beneficiarios
        vr_tab_dsgraupr := segu0001.typ_tab_dsgraupr(rw_seg.dsgraupr##1,rw_seg.dsgraupr##2,rw_seg.dsgraupr##3,rw_seg.dsgraupr##4,rw_seg.dsgraupr##5  );
        vr_tab_nmbenvid := segu0001.typ_tab_nmbenvid(rw_seg.nmbenvid##1,rw_seg.nmbenvid##2,rw_seg.nmbenvid##3,rw_seg.nmbenvid##4,rw_seg.nmbenvid##5);
        vr_tab_txpartic := segu0001.typ_tab_txpartic(rw_seg.txpartic##1,rw_seg.txpartic##2,rw_seg.txpartic##3,rw_seg.txpartic##4,rw_seg.txpartic##5);
        -- Finalmente, cria o registro de seguro
        segu0001.pc_cria_seguro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 0
                               ,pr_nrdcaixa => 0
                               ,pr_cdoperad => pr_cdoperad 
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_nrdconta => rw_seg.nrdconta
                               ,pr_idseqttl => 1
                               ,pr_idorigem => 1
                               ,pr_nmdatela => vr_cdprogra
                               ,pr_flgerlog => FALSE
                               ,pr_cdmotcan => 0
                               ,pr_cdsegura => rw_seg.cdsegura
                               ,pr_cdsitseg => 3
                               ,pr_tab_dsgraupr => vr_tab_dsgraupr
                               ,pr_dtaltseg => NULL
                               ,pr_dtcancel => NULL
                               ,pr_dtdebito => vr_dtdebito
                               ,pr_dtfimvig => rw_seg.dtfimvig + 365
                               ,pr_dtiniseg => rw_seg.dtfimvig
                               ,pr_dtinivig => rw_seg.dtfimvig
                               ,pr_dtprideb => vr_dtprideb
                               ,pr_dtultalt => NULL
                               ,pr_dtultpag => NULL
                               ,pr_flgclabe => rw_seg.flgclabe
                               ,pr_flgconve => 0
                               ,pr_flgunica => rw_seg.flgunica
                               ,pr_indebito => 0
                               ,pr_lsctrant => NULL
                               ,pr_tab_nmbenvid => vr_tab_nmbenvid
                               ,pr_nrctratu => 0
                               ,pr_nrctrseg => vr_nrctrseg
                               ,pr_nrdolote => 4151
                               ,pr_qtparcel => rw_seg.qtparcel
                               ,pr_qtprepag => 0
                               ,pr_qtprevig => 0
                               ,pr_tpdpagto => 0
                               ,pr_tpendcor => rw_seg.tpendcor
                               ,pr_tpplaseg => rw_seg.tpplaseg
                               ,pr_tpseguro => rw_seg.tpseguro
                               ,pr_tab_txpartic => vr_tab_txpartic
                               ,pr_vldifseg => 0
                               ,pr_vlpremio => rw_seg.vlpremio
                               ,pr_vlprepag => 0
                               ,pr_vlpreseg => rw_seg.vlplaseg
                               ,pr_vlcapseg => 0
                               ,pr_cdbccxlt => 200
                               ,pr_nrcpfcgc => rw_seg.nrcpfcgc
                               ,pr_nmdsegur => rw_seg.nmdsegur
                               ,pr_vltotpre => rw_seg.vlpremio
                               ,pr_cdcalcul => rw_seg.cdcalcul
                               ,pr_vlseguro => rw_seg.vlseguro
                               ,pr_dsendres => rw_seg.dsendres
                               ,pr_nrendres => rw_seg.nrendres
                               ,pr_nmbairro => rw_seg.nmbairro
                               ,pr_nmcidade => rw_seg.nmcidade
                               ,pr_cdufresd => rw_seg.cdufresd
                               ,pr_nrcepend => rw_seg.nrcepend
                               ,pr_cdsexosg => 0
                               ,pr_cdempres => 0
                               ,pr_dtnascsg => rw_seg.dtnascsg
                               ,pr_complend => rw_seg.complend
                               ,pr_flgsegur => vr_flgsegur
                               ,pr_crawseg =>  vr_crawseg 
                               ,pr_des_erro => vr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
        -- Testar saida da rotina
        IF vr_dscritic <> 'OK' THEN
          -- Se houver tab_erro
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_dscritic := 'Erro nao tratado.';
          END IF;
          -- Incrementar a critica
          vr_dscritic := 'Nao foi possivel criar o registro da CRAPSEG. '
                      || ' Tipo seguro: ' || rw_seg.tpseguro || '.'
                      || ' Conta: ' || rw_seg.nrdconta ||'. Critica: '||vr_dscritic;
          -- Gerar  LOG          
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );          
          -- Ir ao próximo registro
          continue;        
        END IF;
      END LOOP; 
     
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

  END pc_crps604;
/
