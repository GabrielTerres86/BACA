CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS442(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic out crapcri.cdcritic%type  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
 /* ..........................................................................

   Programa: PC_CRPS442 (Antigo Fontes/crps442.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2007                     Ultima atualizacao: 26/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 82.
               Efetuar os lancamentos dos creditos do INSS - BANCOOB

   Alteracoes: 04/03/2008 - Ajuste para creditar com glb_dtmvtopr (Evandro).

               05/03/2008 - Alterado o lote de 10111 para 10114 (Evandro).

               06/03/2008 - Colocar o credito como enviado pois o BANCOOB baixa
                            automaticamente os creditos em C/C (Evandro).

               02/02/2012 - O processo de geracao do lote e do lancamento
                            foi passado para a procedure gera_credito_em_conta
                            criado na b1wgen0091 (Adriano).

               07/12/2012 - Incluido procedure transfere_beneficio para
                            transferencia dos beneficios para altovale
                            (Tiago).

               26/08/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)
			   
			   30/09/2013 - Incluido linha "IF glb_cdcooper = 1 OR
                            glb_cdcooper = 2 THEN" e "craptco.tpctatrf <> 3"
                            (no FIND da craptco) e incluido linha:
                            "RUN transfere_beneficioIN h-b1wgen0091
                            craptco.cdcooper" (Daniele).
                            
               14/01/2014 - Retirado a condicao craptco.tpctatrf <> 3 da 
                            leitura da craptco (Tiago). 

............................................................................. */
  declare
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS442';
    -- Tratamento de erros
    vr_exc_erro   exception;
    vr_exc_fimprg exception;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);
    
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;

    /* Cursor generico de calendario */
    rw_crapdat btch0001.cr_crapdat%rowtype;

    --Buscar agencias
    cursor cr_crapage (pr_cdcooper in craptab.cdcooper%type) is
      select cdagenci,
             nmresage
        from crapage
        where cdcooper = pr_cdcooper;

    -- -- Buscar Lancamento de credito de beneficios do INSS
    CURSOR cr_craplbi (pr_cdcooper in craptab.cdcooper%type,
                       pr_cdagenci in crapage.cdagenci%type,
                       pr_dtmvtopr in date) is
      SELECT l.rowid,
             l.cdagenci,
             l.progress_recid,
             l.nrdconta,
             L.vlliqcre
        FROM craplbi l
       WHERE cdcooper  = pr_cdcooper
         AND cdagenci  = pr_cdagenci
         AND dtinipag <= pr_dtmvtopr
         AND dtfimpag >= pr_dtmvtopr
         AND tpmepgto  = 2 /* Credito em conta */
         AND cdsitcre  = 1 /* Nao bloqueado */
         AND dtdpagto  is null /* Nao pago */
    ORDER BY CDCOOPER, 
             CDAGENCI, 
             DTDPAGTO, 
             DTINIPAG, 
             DTFIMPAG,             
             DTMVTOLT,
             DTDENVIO,
             PROGRESS_RECID;

    -- Buscar contas transferidas entre cooperativas
    CURSOR cr_craptco (pr_cdcooper in craptab.cdcooper%type,
                       pr_nrdconta in craplbi.nrdconta%type) IS
      SELECT cdcooper,
             nrctaant,
             nrdconta
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.flgativo = 1; /*TRUE*/
    rw_craptco cr_craptco%rowtype;  

  begin

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    end if;

    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se n?o encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    end if;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 --true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Buscar descric?o da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      raise vr_exc_erro;
    END IF;    
    
    FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP 
      FOR rw_craplbi IN cr_craplbi(pr_cdcooper => pr_cdcooper,
                                   pr_cdagenci => rw_crapage.cdagenci,
                                   pr_dtmvtopr => rw_crapdat.dtmvtopr
                                  ) LOOP

        -- executar rotina para geracao do lote e lancamentos
        BEGIN
          INSS0001.pc_gera_credito_em_conta(pr_cdcooper => pr_cdcooper,
                                            pr_cdoperad => 0,
                                            pr_cdprogra => vr_cdprogra,
                                            pr_dtmvtolt => rw_crapdat.dtmvtopr,
                                            pr_dtdehoje => rw_crapdat.dtmvtolt,
                                            pr_nrdrowid => rw_craplbi.rowid,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);

          -- Verificar se retornou critica, caso retornou grava log e vai para o proximo
          IF vr_dscritic is not null THEN
            IF vr_cdcritic IS NULL THEN
              -- Utilizaremos codigo zero, pois foi erro n?o cadastrado
              vr_cdcritic := 0;
            END IF;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Erro na INSS0001.pc_gera_credito_em_conta RECID: '||rw_craplbi.progress_recid
                                                        || ' Erro: '|| vr_dscritic );
            continue;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 3 -- Erro nao tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Erro na INSS0001.pc_gera_credito_em_conta RECID: '||rw_craplbi.progress_recid
                                                        || ' Erro: '|| SQLerrm );
            continue;
        END;

        IF pr_cdcooper = 1 OR pr_cdcooper = 2 THEN /* VIACREDI e CREDITEXTIL*/ 
          -- Buscar conta transferida entre cooperativas
          OPEN cr_craptco(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_craplbi.nrdconta);
          FETCH cr_craptco
           INTO rw_craptco;
          -- Se nao encontrar
          IF cr_craptco%NOTFOUND THEN
            -- Apenas fechar o cursor
            CLOSE cr_craptco;
          ELSE
            BEGIN
              -- Gerar lote de transferencia na cooperativa 1(Debito) /* VIACREDI */
              INSS0001.pc_transfere_beneficio(pr_cdcooper => pr_cdcooper,
                                              pr_cdoperad => '0',
                                              pr_cdprogra => vr_cdprogra,
                                              pr_nrdconta => rw_craptco.nrctaant,
                                              pr_cdhistor => 1117, /*TRANSF. INSS*/
                                              pr_nrdolote => 10114,
                                              pr_dtmvtolt => rw_crapdat.dtmvtopr,
                                              pr_dtdehoje => rw_crapdat.dtmvtolt,
                                              pr_nrdrowid => rw_craplbi.rowid,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);


              -- Verificar se retornou critica, caso retornou grava log
              IF vr_dscritic is not null THEN
                IF vr_cdcritic IS NULL THEN
                  -- Utilizaremos codigo zero, pois foi erro n?o cadastrado
                  vr_cdcritic := 0;
                END IF;
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || 'Erro na INSS0001.pc_transfere_beneficio(Debito) RECID: '||rw_craplbi.progress_recid
                                                            || ' Erro: '|| vr_dscritic );
              END IF;

              -- Gerar lote de transferencia 
              INSS0001.pc_transfere_beneficio(pr_cdcooper => rw_craptco.cdcooper,
                                              pr_cdoperad => '0',
                                              pr_cdprogra => vr_cdprogra,
                                              pr_nrdconta => rw_craptco.nrdconta,
                                              pr_cdhistor => 1118, /*CREDITO INSS*/
                                              pr_nrdolote => 10114,
                                              pr_dtmvtolt => rw_crapdat.dtmvtopr,
                                              pr_dtdehoje => rw_crapdat.dtmvtolt,
                                              pr_nrdrowid => rw_craplbi.rowid,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);


              -- Verificar se retornou critica, caso retornou grava log
              IF vr_dscritic is not null THEN
                IF vr_cdcritic IS NULL THEN
                  -- Utilizaremos codigo zero, pois foi erro nao cadastrado
                  vr_cdcritic := 0;
                END IF;
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || 'Erro na INSS0001.pc_transfere_beneficio(Credito) RECID: '||rw_craplbi.progress_recid
                                                            || ' Erro: '|| vr_dscritic );
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 3 -- Erro nao tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || 'Erro na INSS0001.pc_transfere_beneficio RECID: '||rw_craplbi.progress_recid
                                                            || ' Erro: '|| SQLerrm );
            END;
            CLOSE cr_craptco;
          END IF;
        END IF;  /* pr_cdcooper = 1  VIACREDI */
      
      END LOOP;
    END LOOP;
   
     -- Processo OK, devemos chamar a fimprg
     btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra); 
    COMMIT;

  exception
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
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
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;

    WHEN vr_exc_erro THEN
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;      
      
      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS442;
/

