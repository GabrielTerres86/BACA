CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps389 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

   Programa: pc_crps389 (Fontes/crps389.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2004                      Ultima atualizacao: 10/07/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Efetuar os debitos do parcelamento da subscricao de capital.
               Emite relatrio 345.

   Alteracoes: 09/06/2004 - Cancelar o debito de subscricao para demitidos no
                            final do mes (Edson).
               
               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)
               
               01/07/2005 - Alimentado campo cdcooper das tabelas craprej,
                            craplot, craplcm e craplct (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).

               11/10/2005 - Alterado para gerar arquivos separados por PAC
                            (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               17/05/2006 - Alterado numero de vias do relatorio para
                            Viacredi (Diego).
                            
               11/09/2006 - Efetuado acerto para enviar relatorio de todos os
                            PACS a Intranet (Diego).
                            
               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).         
                            
               02/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).
               
               01/10/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                           (Reinert)  
                           
               22/01/2014 - Incluir VALIDATE craprej, craplot, craplcm,
                            craplct (Lucas R.)

               17/05/2014 - Conversao Progress => Oracle (Andrino-RKAM).

               02/03/2016 - Iniciado variavel vr_rel_telefone como null 
                            (Lucas Ranghetti #411661 )
							
               10/07/2018 - PRJ450 - Regulatorios de Credito - Centralizacao do lancamento em conta corrente (Fabiano B. Dias - AMcom).
							
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS389';

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

      -- Cursor sobre os registros para subscricao do capital dos associados admitidos.
      CURSOR cr_crapsdc IS
        SELECT nrdconta, 
               indebito,
               dtdebito,
               vldebito,
               vllanmto,
               tplanmto,
               nrseqdig,
               dtrefere,
               ROWID
          FROM crapsdc
         WHERE cdcooper  = pr_cdcooper
           AND crapsdc.dtrefere <= rw_crapdat.dtmvtolt 
           AND crapsdc.dtdebito IS NULL             
           AND crapsdc.indebito = 0;
      rw_crapsdc cr_crapsdc%ROWTYPE;

      -- Cursor sobre a capa do lote
      CURSOR cr_craplot(pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT cdagenci,
               cdbccxlt,
               nrdolote,
               nrseqdig,
               qtcompln,
               vlcompdb,
               vlcompcr,
               ROWID
          FROM craplot 
         WHERE craplot.cdcooper = pr_cdcooper   
           AND craplot.dtmvtolt = rw_crapdat.dtmvtolt   
           AND craplot.cdagenci = 1              
           AND craplot.cdbccxlt = 100            
           AND craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      -- Busca o saldo das contas
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT vllimcre,
               dtdemiss
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor sobre as cotas e recursos
      CURSOR cr_crapcot(pr_nrdconta crapcot.nrdconta%TYPE) IS
        SELECT vldcotas,
               ROWID
          FROM crapcot
         WHERE crapcot.cdcooper = pr_cdcooper
           AND crapcot.nrdconta = pr_nrdconta;
      rw_crapcot cr_crapcot%ROWTYPE;

      -- Cursor com a soma dos debitos dos registros para subscricao do capital dos associados admitidos.
      CURSOR cr_crapsdc_2 IS
        SELECT nvl(SUM(vldebito),0)
          FROM crapsdc
         WHERE cdcooper = pr_cdcooper      
           AND nrdconta = rw_crapsdc.nrdconta
           AND dtdebito IS NOT NULL;

      -- Busca as contas que tiveram lancamentos rejeitados
      CURSOR cr_craprej IS
        SELECT craprej.nrdconta,
               crapass.cdagenci,
               craprej.vllanmto,
               crapass.dtdemiss,
               craprej.tpintegr,
               craprej.nrseqdig,
               crapass.nmprimtl,
               crapass.dtadmiss,
               craprej.dtdaviso,
               count(1) over (partition by crapass.cdagenci) totreg,
               row_number() over (partition by crapass.cdagenci order by crapass.cdagenci) nrseq_agencia
          FROM crapass,
               craprej
         WHERE craprej.cdcooper = pr_cdcooper
           AND craprej.cdpesqbb = 'CRPS389'
           AND crapass.cdcooper = craprej.cdcooper
           AND crapass.nrdconta = craprej.nrdconta
         ORDER BY crapass.cdagenci,
                  craprej.nrdconta,
                  craprej.tpintegr,
                  craprej.dtdaviso;

      -- Busca os dados da agencia
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE crapage.cdcooper = pr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;

      -- Cursor com o cadastro dos numeros de telefone de cada titular da conta.
      CURSOR cr_craptfc(pr_nrdconta craptfc.nrdconta%TYPE) IS
        SELECT nrdddtfc,
               nrtelefo,
               nrdramal
          FROM craptfc 
         WHERE craptfc.cdcooper = pr_cdcooper    
           AND craptfc.nrdconta = pr_nrdconta
           AND craptfc.idseqttl = 1; 
      rw_craptfc cr_craptfc%ROWTYPE;

      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      -- Variaveis do IOF
      vr_tab_dtiniiof DATE;                            --> Data de inicio da IOF
      vr_tab_dtfimiof DATE;                            --> Data final da IOF
      vr_tab_txiofrda NUMBER(17,10);                   --> Taxa de IOF
      
      -- Variaveis do CPMF
      vr_tab_dtinipmf DATE;                            --> Data de inicio da CPMF
      vr_tab_dtfimpmf DATE;                            --> Data final da CPMF
      vr_tab_txcpmfcc NUMBER(17,10);                   --> Taxa do fundo de correcao
      vr_tab_txrdcpmf NUMBER(17,10);                   --> Taxa de CPMF
      vr_tab_indabono NUMBER(01);                      --> Indicador de abono de CPMF      
      vr_tab_dtiniabo DATE;                            --> Data de inicio do abono da CPMF

      -- Variaveis do relatorio
      vr_nmarqimp     VARCHAR2(50);                    --> Nome do arquivo que sera gerado
      vr_nom_direto   VARCHAR2(100);                   --> Nome do diretorio para a geracao do arquivo de saida      
      vr_rel_telefone VARCHAR2(50);                    --> Numero do telefone
      vr_rel_qtassoci PLS_INTEGER;                     --> Quantidade de associados
      vr_rel_vltotcap NUMBER(17,2);                    --> Valor total
      vr_rel_dsobserv VARCHAR2(40);                    --> Observacao da rejeicao
      
      -- Variaveis gerais
      vr_texto_completo VARCHAR2(32600);               --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml      CLOB;                            --> XML do relatorio
      vr_dstextab     craptab.dstextab%TYPE;           --> Variavel auxiliar para busca dos parametros da CRAPTAB
      vr_vlsddisp     NUMBER(17,2);                    --> Valor de saldo disponivel      
      vr_sdc_vldebito NUMBER(17,2);                    --> Valor total dos debitos
      
      -- Tabela de retorno LANC0001 (PRJ450 10/07/2018).
      vr_tab_retorno   lanc0001.typ_reg_retorno;
      vr_incrineg      NUMBER;
      vr_cdpesqbb      VARCHAR2(200);	

      --------------------------- SUBROTINAS INTERNAS --------------------------

      PROCEDURE pc_calcula_saldo IS
        
        -- Busca o saldo das contas
        CURSOR cr_crapsld IS
          SELECT vlsddisp,
                 vlipmfap,
                 vlipmfpg
            FROM crapsld
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_crapsdc.nrdconta;
        rw_crapsld cr_crapsld%ROWTYPE;
      
        -- Busca informacoes de lancmento de deposito a vista
        CURSOR cr_craplcm IS
          SELECT cdhistor,
                 dtrefere,
                 vllanmto
            FROM craplcm
           WHERE craplcm.cdcooper = pr_cdcooper
             AND craplcm.nrdconta = rw_crapsdc.nrdconta
             AND craplcm.dtmvtolt = rw_crapdat.dtmvtolt
             AND craplcm.cdhistor <> 289 -- BASE CPMF CSD            
           ORDER BY cdcooper, nrdconta, dtmvtolt, cdhistor, nrdocmto;

        -- Historico dos lancamentos
        CURSOR cr_craphis(pr_cdhistor craphis.cdhistor%TYPE) IS
          SELECT inhistor,
                 indoipmf
            FROM craphis
           WHERE craphis.cdcooper = pr_cdcooper
             AND craphis.cdhistor = pr_cdhistor;
        rw_craphis cr_craphis%ROWTYPE;

        vr_cdhistor craphis.cdhistor%TYPE;    --> Codigo do historico
        vr_inhistor craphis.inhistor%TYPE;    --> Indicador da funcao do historico
        vr_indoipmf craphis.indoipmf%TYPE;    --> Indicador de incidencia do IPMF (1-Nao incide, 2-Incide).
        vr_txdoipmf NUMBER(17,10);            --> Taxa do IPMF
      BEGIN
        
        -- Busca o saldo da conta
        OPEN cr_crapsld;
        FETCH cr_crapsld INTO rw_crapsld;
        
        -- Verifica se nao foi encontrado saldo na conta
        IF cr_crapsld%NOTFOUND THEN
          vr_cdcritic := 10; -- Associado sem registro de saldo!!! - ERRO DO SISTEMA!!!
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapsld;

        -- Busca as informacoes do associado
        OPEN cr_crapass(rw_crapsdc.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        
        -- Verifica se nao foi encontrado o associado
        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic := 251; -- 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;

        -- Calcula o valor de saldo disponivel
        vr_vlsddisp := rw_crapsld.vlsddisp + rw_crapass.vllimcre - 
                       rw_crapsld.vlipmfap - rw_crapsld.vlipmfpg;

        -- Efetua loop sobre os lancamentos de deposito a vista
        FOR rw_craplcm IN cr_craplcm LOOP

          IF nvl(vr_cdhistor,0) <> rw_craplcm.cdhistor THEN
            
            -- Busca as informacoes de historico
            OPEN cr_craphis(rw_craplcm.cdhistor);
            FETCH cr_craphis INTO rw_craphis;
            
            -- Verifica se nao foi encontrado historico
            IF cr_craphis%NOTFOUND THEN
              vr_cdcritic := 83; -- 083 - Historico desconhecido no lancamento.
              RAISE vr_exc_saida;
            END IF;
            CLOSE cr_craphis;
            
            -- Atualiza as informacoes do historico
            vr_cdhistor := rw_craplcm.cdhistor;
            vr_inhistor := rw_craphis.inhistor;
            vr_indoipmf := rw_craphis.indoipmf;
            vr_txdoipmf := vr_tab_txcpmfcc;

            -- Se nao tiver abono e nao possuir os debitos a seguir, nao faz a deducao de ipmf
            IF vr_tab_indabono = 0 AND rw_craplcm.cdhistor IN (114,  -- DB.APLIC.RDCA
                                                               127,  -- DB. COTAS
                                                               160,  -- DB.POUP.PROGR
                                                               177) THEN -- DB.APL.RDCA60
              vr_indoipmf := 1; -- Nao incide IPMF
              vr_txdoipmf := 0; -- Taxa zerada
            END IF;
          
          END IF;

          IF vr_tab_indabono     = 0 AND
             vr_tab_dtiniabo    <= rw_craplcm.dtrefere  AND
            (rw_craplcm.cdhistor = 186   OR  -- CR.ANTEC.RDCA
             rw_craplcm.cdhistor = 498   OR  -- CR.ANTEC.RDCA
             rw_craplcm.cdhistor = 187   OR  -- CR.ANT.RDCA60
             rw_craplcm.cdhistor = 500) THEN -- CR.ANT.RDCA60
            vr_vlsddisp := vr_vlsddisp - trunc((rw_craplcm.vllanmto * vr_tab_txcpmfcc),2);
          END IF;

          -- credito no vlsddisp
          IF vr_inhistor = 1 THEN
            -- Se incide IPMF
            IF vr_indoipmf = 2 THEN
              vr_vlsddisp := vr_vlsddisp + trunc(rw_craplcm.vllanmto * 
                                                   (1 + vr_txdoipmf),2);
            ELSE -- nao incide IPMF
              vr_vlsddisp := vr_vlsddisp + rw_craplcm.vllanmto;
            END IF;
          END IF;

          -- debito no vlsddisp
          IF vr_inhistor = 11   THEN
            -- Se incide IPMF
            IF vr_indoipmf = 2 THEN
              vr_vlsddisp := vr_vlsddisp - trunc(rw_craplcm.vllanmto *
                                                    (1 + vr_txdoipmf),2);
            ELSE -- Nao incide IPMF
              vr_vlsddisp := vr_vlsddisp - rw_craplcm.vllanmto;
            END IF;
          END IF;
        END LOOP; 

      END pc_calcula_saldo;


      PROCEDURE pc_sem_capital IS
        vr_nrdocmto craplcm.nrdocmto%TYPE;
      BEGIN

        -- busca o saldo da conta
        pc_calcula_saldo;
      
        -- Se o saldo disponivel for inferior ao lancamento, insere nos rejeitados
        IF vr_vlsddisp < rw_crapsdc.vllanmto THEN
          
          -- Insere na tabela de rejeitados
          BEGIN
            INSERT INTO craprej
              (cdpesqbb,
               nrdconta,
               dtdaviso,
               tpintegr,
               vllanmto,
               nrseqdig,
               cdcooper)
             VALUES
              ('CRPS389',
               rw_crapsdc.nrdconta,
               rw_crapsdc.dtrefere,
               rw_crapsdc.tplanmto,
               rw_crapsdc.vllanmto,
               decode(rw_crapsdc.tplanmto, 1, rw_crapsdc.nrseqdig, rw_crapsdc.nrseqdig - 1),
               pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na CRAPREJ: ' ||SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          -- Volta para a rotina que chamadora
          RETURN; 
        END IF;
      
        /*  Cria lancamento de debito no conta-corrente ......................... */
        -- Abre a capa de lote
        OPEN cr_craplot(10101);
        FETCH cr_craplot INTO rw_craplot;
        
        -- Se não existir a capa de lote, entao insere
        IF cr_craplot%NOTFOUND THEN
          BEGIN
            INSERT INTO craplot
              (dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               cdcooper)
             VALUES
              (rw_crapdat.dtmvtolt,
               1,
               100,
               10101,
               1,
               pr_cdcooper)
             RETURNING cdagenci,
                       cdbccxlt,
                       nrdolote,
                       nrseqdig,
                       qtcompln,
                       vlcompdb,
                       vlcompcr,
                       ROWID
                  INTO rw_craplot.cdagenci,
                       rw_craplot.cdbccxlt,
                       rw_craplot.nrdolote,
                       rw_craplot.nrseqdig,
                       rw_craplot.qtcompln,
                       rw_craplot.vlcompdb,
                       rw_craplot.vlcompcr,
                       rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := '1-Erro ao inserir CRAPLOT: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        CLOSE cr_craplot; -- Fecha a capa de lote

        -- PRJ450 - 10/07/2018 - inicio:
        IF rw_crapsdc.tplanmto = 1 THEN
          vr_cdpesqbb := 'SUBSCRICAO DE CAPITAL INICIAL';
        ELSE
          vr_cdpesqbb := 'PLANO DE SUBSCRICAO DE CAPITAL - PARCELA REF. ' || to_char(rw_crapsdc.dtrefere,'dd/mm/yyyy');		
        END IF;
		
        lanc0001.pc_gerar_lancamento_conta (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          , pr_cdagenci => rw_craplot.cdagenci
                                          , pr_cdbccxlt => rw_craplot.cdbccxlt
                                          , pr_nrdolote => rw_craplot.nrdolote
                                          , pr_nrdconta => rw_crapsdc.nrdconta
                                          , pr_nrdocmto => rw_craplot.nrseqdig + 1 
                                          , pr_cdhistor => 127   
                                          , pr_nrseqdig => rw_craplot.nrseqdig + 1
                                          , pr_vllanmto => rw_crapsdc.vllanmto
                                          , pr_nrdctabb => rw_crapsdc.nrdconta
                                          , pr_cdpesqbb => vr_cdpesqbb
                                          --, pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                          --, pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                          --, pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                          --, pr_cdbanchq => lt_d_nrbanori
                                          --, pr_cdcmpchq => lt_d_cdcmpori
                                          --, pr_cdagechq => lt_d_nrageori
                                          --, pr_nrctachq => lt_d_nrctarem
                                          --, pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                          --, pr_sqlotchq => lt_d_nrsequen
                                          --, pr_dtrefere => rw_craprda.dtmvtolt
                                          --, pr_hrtransa => vr_hrtransa
                                          --, pr_cdoperad IN  craplcm.cdoperad%TYPE default ' '
                                          --, pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                          , pr_cdcooper => pr_cdcooper
                                          , pr_nrdctitg => to_char(rw_crapsdc.nrdconta,'00000000')
                                          --, pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                          --, pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                          --, pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                          --, pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                          --, pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                          --, pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                          --, pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                          --, pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                          --, pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                          -------------------------------------------------
                                          -- Dados do lote (Opcional)
                                          -------------------------------------------------
                                          --, pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                          --, pr_tplotmov  => 1
                                          , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                          , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                          , pr_cdcritic  => vr_cdcritic      -- OUT
                                          , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)

        vr_nrdocmto := rw_craplot.nrseqdig + 1;

        IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;		  
		
        -- PRJ450 - 10/07/2018 - fim.

        -- Atualiza a capa de lote
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
        rw_craplot.vlcompdb := rw_craplot.vlcompdb + rw_crapsdc.vllanmto;
        BEGIN
          UPDATE craplot
            SET craplot.nrseqdig = rw_craplot.nrseqdig,
                craplot.qtcompln = rw_craplot.qtcompln,
                craplot.qtinfoln = rw_craplot.qtcompln,
                craplot.vlcompdb = rw_craplot.vlcompdb,
                craplot.vlinfodb = rw_craplot.vlcompdb
          WHERE ROWID = rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '1-Erro ao atualizar CRAPLOT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        /*  Cria lancamento de credito no capital ...............................*/
        -- Abre a capa de lote
        OPEN cr_craplot(10102);
        FETCH cr_craplot INTO rw_craplot;
        
        -- Se não existir a capa de lote, entao insere
        IF cr_craplot%NOTFOUND THEN
          BEGIN
            INSERT INTO craplot
              (dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               cdcooper)
             VALUES
              (rw_crapdat.dtmvtolt,
               1,
               100,
               10102,
               2,
               pr_cdcooper)
             RETURNING cdagenci,
                       cdbccxlt,
                       nrdolote,
                       nrseqdig,
                       qtcompln,
                       vlcompdb,
                       vlcompcr,
                       ROWID
                  INTO rw_craplot.cdagenci,
                       rw_craplot.cdbccxlt,
                       rw_craplot.nrdolote,
                       rw_craplot.nrseqdig,
                       rw_craplot.qtcompln,
                       rw_craplot.vlcompdb,
                       rw_craplot.vlcompcr,
                       rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := '2-Erro ao inserir CRAPLOT: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        CLOSE cr_craplot; -- Fecha a capa de lote

        -- Insere o lancamento de cotas / capital   
        BEGIN
          INSERT INTO craplct
            (dtmvtolt, 
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdocmto,
             cdhistor,
             nrseqdig,
             vllanmto,
             cdcooper)
           VALUES
            (rw_crapdat.dtmvtolt,
             rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             rw_craplot.nrdolote,
             rw_crapsdc.nrdconta,
             vr_nrdocmto,
             decode(rw_crapsdc.tplanmto,1,60,401),
             rw_craplot.nrseqdig + 1,
             rw_crapsdc.vllanmto,
             pr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '1-Erro ao inserir na CRAPLCT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza a capa de lote
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
        rw_craplot.vlcompcr := rw_craplot.vlcompcr + rw_crapsdc.vllanmto;
        BEGIN
          UPDATE craplot
            SET craplot.nrseqdig = rw_craplot.nrseqdig,
                craplot.qtcompln = rw_craplot.qtcompln,
                craplot.qtinfoln = rw_craplot.qtcompln,
                craplot.vlcompcr = rw_craplot.vlcompcr,
                craplot.vlinfocr = rw_craplot.vlcompcr
          WHERE ROWID = rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '2-Erro ao atualizar CRAPLOT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        /*  Atualiza o registro de parcelamento de capital ......................*/
        rw_crapsdc.indebito := 1;
        rw_crapsdc.dtdebito := rw_crapdat.dtmvtolt;
        rw_crapsdc.vldebito := rw_crapsdc.vllanmto;
        BEGIN
          UPDATE crapsdc
             SET indebito = 1,
                 dtdebito = rw_crapdat.dtmvtolt,
                 vldebito = rw_crapsdc.vllanmto
           WHERE ROWID = rw_crapsdc.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '1-Erro ao atualizar CRAPSDC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza o valor das cotas
        rw_crapcot.vldcotas := rw_crapcot.vldcotas + rw_crapsdc.vllanmto;
        BEGIN
          UPDATE crapcot
             SET vldcotas = rw_crapcot.vldcotas
           WHERE ROWID = rw_crapcot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela CRAPCOT: ' ||SQLERRM;
        END;
             
      END pc_sem_capital;


      /*  Cria lancamento de debito no capital ................................ */
      PROCEDURE pc_com_capital IS
        
      BEGIN

        -- Abre a capa de lote
        OPEN cr_craplot(10102);
        FETCH cr_craplot INTO rw_craplot;
        
        -- Se não existir a capa de lote, entao insere
        IF cr_craplot%NOTFOUND THEN
          BEGIN
            INSERT INTO craplot
              (dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               cdcooper)
             VALUES
              (rw_crapdat.dtmvtolt,
               1,
               100,
               10102,
               2,
               pr_cdcooper)
             RETURNING cdagenci,
                       cdbccxlt,
                       nrdolote,
                       nrseqdig,
                       qtcompln,
                       vlcompdb,
                       vlcompcr,
                       ROWID
                  INTO rw_craplot.cdagenci,
                       rw_craplot.cdbccxlt,
                       rw_craplot.nrdolote,
                       rw_craplot.nrseqdig,
                       rw_craplot.qtcompln,
                       rw_craplot.vlcompdb,
                       rw_craplot.vlcompcr,
                       rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := '3-Erro ao inserir CRAPLOT: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        CLOSE cr_craplot; -- Fecha a capa de lote
           
        -- Insere o lancamento de cotas / capital   
        BEGIN
          INSERT INTO craplct
            (dtmvtolt, 
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdocmto,
             cdhistor,
             nrseqdig,
             vllanmto,
             cdcooper)
           VALUES
            (rw_crapdat.dtmvtolt,
             rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             rw_craplot.nrdolote,
             rw_crapsdc.nrdconta,
             rw_craplot.nrseqdig + 1,  --Em conversa com o Guilherme, foi colocado este valor ao inves do DECIMAL(RECID(craplcm)) 
             402,
             rw_craplot.nrseqdig + 1,
             rw_crapsdc.vllanmto,
             pr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '1-Erro ao inserir na CRAPLCT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Atualiza a capa de lote
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
        rw_craplot.vlcompdb := rw_craplot.vlcompdb + rw_crapsdc.vllanmto;
        BEGIN
          UPDATE craplot
            SET craplot.nrseqdig = rw_craplot.nrseqdig,
                craplot.qtcompln = rw_craplot.qtcompln,
                craplot.qtinfoln = rw_craplot.qtcompln,
                craplot.vlcompdb = rw_craplot.vlcompdb,
                craplot.vlinfodb = rw_craplot.vlcompdb
          WHERE ROWID = rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '3-Erro ao atualizar CRAPLOT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;


        /*  Cria lancamento de credito no capital ...............................*/
        BEGIN
          INSERT INTO craplct
            (dtmvtolt, 
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdocmto,
             cdhistor,
             nrseqdig,
             vllanmto,
             cdcooper)
           VALUES
            (rw_crapdat.dtmvtolt,
             rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             rw_craplot.nrdolote,
             rw_crapsdc.nrdconta,
             rw_craplot.nrseqdig + 1, --Em conversa com o Guilherme, foi colocado este valor ao inves do DECIMAL(RECID(craplcm)) 
             decode(rw_crapsdc.tplanmto,1,60,401),
             rw_craplot.nrseqdig + 1,
             rw_crapsdc.vllanmto,
             pr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '2-Erro ao inserir na CRAPLCT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza a capa de lote
        rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
        rw_craplot.vlcompcr := rw_craplot.vlcompcr + rw_crapsdc.vllanmto;
        BEGIN
          UPDATE craplot
            SET craplot.nrseqdig = rw_craplot.nrseqdig,
                craplot.qtcompln = rw_craplot.qtcompln,
                craplot.qtinfoln = rw_craplot.qtcompln,
                craplot.vlcompcr = rw_craplot.vlcompcr,
                craplot.vlinfocr = rw_craplot.vlcompcr
          WHERE ROWID = rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '4-Erro ao atualizar CRAPLOT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        /*  Atualiza o registro de parcelamento de capital ......................*/
        rw_crapsdc.indebito := 3;
        rw_crapsdc.dtdebito := rw_crapdat.dtmvtolt;
        rw_crapsdc.vldebito := rw_crapsdc.vllanmto;
        BEGIN
          UPDATE crapsdc
             SET indebito = 3,
                 dtdebito = rw_crapdat.dtmvtolt,
                 vldebito = rw_crapsdc.vllanmto
           WHERE ROWID = rw_crapsdc.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '2-Erro ao atualizar CRAPSDC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      END pc_com_capital;



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

      /*  Tabela com a taxa do IOF */
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'CTRIOFRDCA'
                                               ,pr_tpregist => 1);
      -- Se nao encontrar taxa de IOF cancela o programa
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 626; --Falta tabela da aliquota do IOF sobre emprestimos
        RAISE vr_exc_saida;
      END IF;
 
      -- Data inicial e final da IOF
      vr_tab_dtiniiof := to_date(substr(vr_dstextab,1,10),'dd/mm/yyyy');
      vr_tab_dtfimiof := to_date(substr(vr_dstextab,12,10),'dd/mm/yyyy');
      
      -- Se o IOF estiver vigente, atualiza a taxa do mesmo
      IF rw_crapdat.dtmvtolt >= vr_tab_dtiniiof AND rw_crapdat.dtmvtolt <= vr_tab_dtfimiof THEN
        vr_tab_txiofrda := substr(vr_dstextab,23,16);
      ELSE
        vr_tab_txiofrda := 0;
      END IF;

      /*  Tabela com a taxa do CPMF */
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'CTRCPMFCCR'
                                               ,pr_tpregist => 1);

      -- Se nao encontrar taxa de CPMF cancela o programa
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 641; --Falta tabela de controle da CPMF.
        RAISE vr_exc_saida;
      END IF;

      -- Data inicial e final da CPMF
      vr_tab_dtinipmf := to_date(substr(vr_dstextab,1,10),'dd/mm/yyyy');
      vr_tab_dtfimpmf := to_date(substr(vr_dstextab,12,10),'dd/mm/yyyy');

      -- Se o CPMF estiver vigente, atualiza a taxa do mesmo
      IF rw_crapdat.dtmvtolt >= vr_tab_dtinipmf AND rw_crapdat.dtmvtolt <= vr_tab_dtfimpmf THEN
        vr_tab_txcpmfcc := SUBSTR(vr_dstextab,23,13);
        vr_tab_txrdcpmf := SUBSTR(vr_dstextab,38,13);
      ELSE 
        vr_tab_txcpmfcc := 0;
        vr_tab_txrdcpmf := 1;
      END IF;
      
      vr_tab_indabono := SUBSTR(vr_dstextab,51,1);  /* 0 = abona
                                                       1 = nao abona */
      vr_tab_dtiniabo := to_date(substr(vr_dstextab,53,10),'dd/mm/yyyy'); /* data de inicio do abono */

      -- Busca os registros para subscricao do capital dos associados admitidos.
      OPEN cr_crapsdc;
      LOOP
        FETCH cr_crapsdc INTO rw_crapsdc;
        EXIT WHEN cr_crapsdc%NOTFOUND;
        
        -- Busca as informacoes do associado
        OPEN cr_crapass(rw_crapsdc.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        
        -- Verifica se nao foi encontrado o associado
        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic := 251; -- 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
        
        /*  Cancela subscricao p/ demitidos */
        IF rw_crapass.dtdemiss IS NOT NULL THEN    
          IF to_char(rw_crapdat.dtmvtolt,'MM') <> to_char(rw_crapdat.dtmvtopr,'MM') THEN
            -- Atualiza a data de debito e a situacao de debito como cancelado
            BEGIN
              UPDATE crapsdc
                 SET dtdebito = rw_crapdat.dtmvtolt,
                     indebito = 2 -- Cancelado
               WHERE ROWID = rw_crapsdc.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := '3-Erro ao atualizar CRAPSDC: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            continue; -- Vai para o proximo registro
          END IF;
        END IF;
         
        -- Busca as informacoes de cotas
        OPEN cr_crapcot(rw_crapsdc.nrdconta);
        FETCH cr_crapcot INTO rw_crapcot;
        
        -- Cancela o programa se nao existir registro de cota
        IF cr_crapcot%NOTFOUND THEN
          vr_cdcritic := 169; -- 169 - Associado sem registro de cotas!!! - Erro do sistema!!!!
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcot;
        
        vr_sdc_vldebito := 0;
    
        OPEN cr_crapsdc_2;
        FETCH cr_crapsdc_2 INTO vr_sdc_vldebito;
        CLOSE cr_crapsdc_2;
        -- Se o valor das cotas menos o valor dos debitos for superior ao lancamento
        IF (rw_crapcot.vldcotas - vr_sdc_vldebito) >= rw_crapsdc.vllanmto   THEN
          pc_com_capital;  -- Efetua o lancamento de debito no capital
        ELSE
          pc_sem_capital;
        END IF;
   
        IF vr_cdcritic > 0 THEN
          RAISE vr_exc_saida;
        END IF;
      END LOOP; /*  Fim do LOOP -- crapsdc  */


      /*  Imprime relatorio com rejeitados ........................................ */
      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');


      FOR rw_craprej IN cr_craprej LOOP
 
    
        /* abre um arquivo para cada PA */
        IF rw_craprej.nrseq_agencia = 1 THEN
          -- Inicializa as variaveis
          vr_rel_qtassoci := 0;
          vr_rel_vltotcap := 0;
          vr_nmarqimp := '/crrl345_' || to_char(rw_craprej.cdagenci,'fm000')||'.lst';

          -- Inicializar o CLOB
          vr_des_xml := NULL;
          vr_texto_completo := NULL;
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
            
          -- Busca o nome da agencia
          OPEN cr_crapage(rw_craprej.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          CLOSE cr_crapage;

          -- Inicializa o XML
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                      '<?xml version="1.0" encoding="utf-8"?><crrl345>'||
                       '<dsagenci>'||to_char(rw_craprej.cdagenci,'990') || ' - '|| rw_crapage.nmresage||'</dsagenci>');
            
        END IF;
        
        -- busca o telefone do titular da conta
        OPEN cr_craptfc(rw_craprej.nrdconta);
        FETCH cr_craptfc INTO rw_craptfc;
        
        -- Se o titular possui telefone
        IF cr_craptfc%FOUND THEN
          IF rw_craptfc.nrtelefo <> 9999 AND rw_craptfc.nrtelefo <> 0 THEN
            vr_rel_telefone := NULL;
            IF rw_craptfc.nrdddtfc <> 0 THEN
              vr_rel_telefone := '(' || rw_craptfc.nrdddtfc || ') ';
            END IF;
                      
            vr_rel_telefone := vr_rel_telefone || rw_craptfc.nrtelefo;
          ELSE
            vr_rel_telefone := to_char(rw_craptfc.nrdramal,'0,000');
          END IF;
        ELSE
          vr_rel_telefone := NULL;
        END IF;
        CLOSE cr_craptfc;

        vr_rel_qtassoci := vr_rel_qtassoci + 1;
        vr_rel_vltotcap := vr_rel_vltotcap + rw_craprej.vllanmto;
        IF rw_craprej.dtdemiss IS NULL THEN
          IF rw_craprej.tpintegr = 1 THEN
            vr_rel_dsobserv := 'CAPITAL INICIAL';
          ELSE
            vr_rel_dsobserv := 'PARCELA ' || to_char(rw_craprej.nrseqdig,'fm90');
          END IF;
        ELSE
          vr_rel_dsobserv := 'DEMITIDO';
        END IF;
        
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
           '<conta>'||
             '<cdagenci>'||rw_craprej.cdagenci                          ||'</cdagenci>'||
             '<nrdconta>'||gene0002.fn_mask_conta(rw_craprej.nrdconta)  ||'</nrdconta>'||
             '<nmprimtl>'||substr(rw_craprej.nmprimtl,1,40)             ||'</nmprimtl>'||
             '<telefone>'||substr(vr_rel_telefone,1,20)                 ||'</telefone>'||
             '<dtadmiss>'||to_char(rw_craprej.dtadmiss,'dd/mm/yyyy')    ||'</dtadmiss>'||             
             '<dtdaviso>'||to_char(rw_craprej.dtdaviso,'dd/mm/yyyy')    ||'</dtdaviso>'||
             '<vllanmto>'||to_char(rw_craprej.vllanmto,'fm999G990D00')  ||'</vllanmto>'||
             '<dsobserv>'||vr_rel_dsobserv                              ||'</dsobserv>'||
           '</conta>');
         
        /* fecha o arquivo de cada PA */
        IF rw_craprej.totreg = rw_craprej.nrseq_agencia THEN
          -- Escreve a linha de total
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
               '<qtassoci>'||to_char(vr_rel_qtassoci,'fm999G990')||'</qtassoci>'||
               '<vltotcap>'||to_char(vr_rel_vltotcap,'fm9999G990D00')    ||'</vltotcap>'||
             '</crrl345>',TRUE);
            
          -- Chamada do iReport para gerar o arquivo de saida
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                      pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                      pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                      pr_dsxmlnode => '/crrl345/conta',               --> No base do XML para leitura dos dados
                                      pr_dsjasper  => 'crrl345.jasper',               --> Arquivo de layout do iReport
                                      pr_dsparams  => null,                           --> Nao enviar parametro
                                      pr_dsarqsaid => vr_nom_direto||vr_nmarqimp,     --> Arquivo final
                                      pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                      pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                      pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                      pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                      pr_nrcopias  => 1,                              --> Numero de copias
                                      pr_des_erro  => vr_dscritic);                   --> Saida com erro

          -- Verifica se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
                    
        END IF;              
      END LOOP; /* Fim do FOR da craprej */

      -- Exclui os registros de rejeitados inseridos pelo programa
      BEGIN
        DELETE craprej
         WHERE craprej.cdcooper = pr_cdcooper
           AND craprej.cdpesqbb = 'CRPS389';
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir CRAPREJ: ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;

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

  END pc_crps389;
/
