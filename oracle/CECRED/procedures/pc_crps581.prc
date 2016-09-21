CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps581 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

   Programa: PC_CRPS581                      Antigo: Fontes/crps581.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Outubro/2010.                   Ultima atualizacao: 07/05/2014
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : TAA - Gerar lancamentos de tarifas das filiadas na Central
               
   Alteracoes: 03/12/2010 - Criar LCM apenas se tarifa > 0 (Guilherme/Supero)
   
               01/02/2011 - Colocar relatorio da intranet (Henrique).
               
               04/02/2011 - Gerar o relatorio separado com as informacoes 
                            para cada cooperativa (Henrique).

               23/03/2011 - Alterado para mostrar os creditos na conta da 
                            cooperativa (Henrique).
                            
               31/03/2011 - Ajuste devido agendamentos no TAA (Henrique).
               
               07/04/2011 - Ajustes para nao gerar relatorio caso a coop
                            nao possua movimentacao (Henrique).
                            
               18/08/2011 - Considerar tarifa de impressao de comprovantes 
                            (Gabriel)   
                            
               19/10/2012 - Incluido include b1wgen0025tt.i (Oscar).   
               
               14/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 

               07/05/2014 - Conversao Progress => Oracle (Andrino-RKAM).

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS581';

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

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop_2 IS
        SELECT cdcooper,
               nrctactl,
               '_'||nmrescop nmrescop
          FROM crapcop
         WHERE cdcooper <> 3;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      /* Tipos de registros para tabela de memoria de relatorio pai */
      TYPE typ_reg_relat_pai
        IS RECORD (indebcre craphis.indebcre%TYPE,
                   cdhistor craphis.cdhistor%TYPE,
                   nrctadeb craphis.nrctadeb%TYPE,
                   nrctacre craphis.nrctacrd%TYPE,
                   dshistor craphis.dshistor%TYPE,
                   vlrtotal NUMBER(17,2));
                   
      /* Tipos de tabela de memoria do relatorio pai */
      TYPE typ_tab_relat_pai
        IS TABLE OF typ_reg_relat_pai INDEX BY VARCHAR2(16); --nrctadeb(05) cdhistor(05) nrctacre(05) indebcre(01)

      /* Tipos de registros para tabela de memoria de relatorio filho */
      TYPE typ_reg_relat_filho
        IS RECORD (indebcre craphis.indebcre%TYPE,
                   cdhistor craphis.cdhistor%TYPE,
                   nrctadeb craphis.nrctadeb%TYPE,
                   nrctacre craphis.nrctacrd%TYPE,
                   cdagenci crapass.cdagenci%TYPE,
                   vlrtotal NUMBER(17,2));
                   
      /* Tipos de tabela de memoria do relatorio filho */
      TYPE typ_tab_relat_filho
        IS TABLE OF typ_reg_relat_filho INDEX BY VARCHAR2(21);  --indebcre(01) cdhistor(05) nrctadeb(05) nrctacre(05) cdagenci(05)

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtmvtini    DATE;                             --> Data de inicio do movimento (primeiro dia do mes do processo)
      vr_tab_lancamentos cada0001.typ_tab_lancamentos; --> Temp-table com os lancamentos que serao processados
      vr_ind         VARCHAR2(38);                     --> Indice da Pl_table vr_tab_lancamentos
      vr_tab_relat_pai   typ_tab_relat_pai;            --> Temp-table com os dados do relatorio pai
      vr_ind_pai     VARCHAR2(16);                     --> Indice da Pl_table vr_tab_relat_pai
      vr_tab_relat_filho typ_tab_relat_filho;          --> Temp-table com os dados do relatorio filho
      vr_ind_filho   VARCHAR2(21);                     --> Indice da Pl_table vr_tab_relat_filho
      vr_texto_completo VARCHAR2(32600);               --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml     CLOB;                             --> XML do relatorio
      vr_nom_direto  VARCHAR2(500);                    --> Diretorio onde sera gerado os relatorios
      
      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- Rotina responsavel em popular a temp-table VR_TAB_RELAT_FILHO
      PROCEDURE pc_cria_relat_filho(pr_cdhisdeb crapthi.cdhistor%TYPE,
                                    pr_indebcre craphis.indebcre%TYPE,
                                    pr_nrctadeb crapcop.nrctactl%TYPE,
                                    pr_nrctacre crapcop.nrctactl%TYPE,
                                    pr_cdagenci crapass.cdagenci%TYPE,
                                    pr_vltarifa NUMBER) IS

      BEGIN
        -- Cria o indice para a pl_table vr_tab_relat_filho
        vr_ind_filho := pr_indebcre || lpad(pr_cdhisdeb,5,'0') || lpad(pr_nrctadeb,5,'0') ||
                        lpad(pr_nrctacre,5,'0') || lpad(pr_cdagenci,5,'0');
          
        -- Insere na pl_table de relat_filho
        vr_tab_relat_filho(vr_ind_filho).indebcre := pr_indebcre;
        vr_tab_relat_filho(vr_ind_filho).cdhistor := pr_cdhisdeb;
        vr_tab_relat_filho(vr_ind_filho).nrctadeb := pr_nrctadeb;
        vr_tab_relat_filho(vr_ind_filho).nrctacre := pr_nrctacre;
        vr_tab_relat_filho(vr_ind_filho).cdagenci := pr_cdagenci;
        vr_tab_relat_filho(vr_ind_filho).vlrtotal := nvl(vr_tab_relat_filho(vr_ind_filho).vlrtotal,0) + pr_vltarifa;
      END pc_cria_relat_filho;


      -- Rotina responsavel em popular a temp-table VR_TAB_RELAT_PAI
      PROCEDURE pc_cria_relat_pai(pr_cdhisdeb crapthi.cdhistor%TYPE,
                                  pr_nrctadeb crapcop.nrctactl%TYPE,
                                  pr_nrctacre crapcop.nrctactl%TYPE,
                                  pr_vltarifa NUMBER) IS

        -- busca a descricao do historico
        CURSOR cr_craphis IS
          SELECT dshistor
            FROM craphis
           WHERE craphis.cdcooper = pr_cdcooper
             AND craphis.cdhistor = pr_cdhisdeb;
        rw_craphis cr_craphis%ROWTYPE;

      BEGIN

        -- busca a descricao do historico
        OPEN cr_craphis;
        FETCH cr_craphis INTO rw_craphis;
        CLOSE cr_craphis;

        -- Cria o indice para a pl_table vr_tab_relat_pai
        vr_ind_pai := lpad(pr_nrctadeb,5,'0') || lpad(pr_cdhisdeb,5,'0') || lpad(pr_nrctacre,5,'0') || 'D';

        -- Insere na pl_table de relat_pai
        vr_tab_relat_pai(vr_ind_pai).indebcre := 'D';
        vr_tab_relat_pai(vr_ind_pai).cdhistor := pr_cdhisdeb;
        vr_tab_relat_pai(vr_ind_pai).nrctadeb := pr_nrctadeb;
        vr_tab_relat_pai(vr_ind_pai).nrctacre := pr_nrctacre;
        vr_tab_relat_pai(vr_ind_pai).dshistor := nvl(rw_craphis.dshistor,'000-NAO ENCONTRADO');
        vr_tab_relat_pai(vr_ind_pai).vlrtotal := nvl(vr_tab_relat_pai(vr_ind_pai).vlrtotal,0) + pr_vltarifa;

      END pc_cria_relat_pai;

      -- Rotina responsavel em popular a tabela CRAPLCM (lancamentos de depositos a vista)
      PROCEDURE pc_cria_craplcm(pr_nrdconta crapass.nrdconta%TYPE,
                                pr_vlrlamto NUMBER,
                                pr_cdhistor crapthi.cdhistor%TYPE,
                                pr_nrdocmto crapcop.nrctactl%TYPE) IS

        -- Busca as capas de lote
        CURSOR cr_craplot(pr_nrdolote craplot.nrdolote%TYPE,
                          pr_cdagenci craplot.cdagenci%TYPE,
                          pr_cdbccxlt craplot.cdbccxlt%TYPE) IS
          SELECT nrseqdig,
                 ROWID
            FROM craplot 
           WHERE craplot.cdcooper = pr_cdcooper
             AND craplot.dtmvtolt = rw_crapdat.dtmvtolt 
             AND craplot.cdagenci = pr_cdagenci
             AND craplot.cdbccxlt = pr_cdbccxlt
             AND craplot.nrdolote = pr_nrdolote
           ORDER BY cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote;
        rw_craplot cr_craplot%ROWTYPE;

        -- Busca os lancamentos de deposito a vista
        CURSOR cr_craplcm(pr_nrdolote craplot.nrdolote%TYPE,
                          pr_cdagenci craplot.cdagenci%TYPE,
                          pr_cdbccxlt craplot.cdbccxlt%TYPE,
                          pr_nrdocmto craplcm.nrdocmto%TYPE) IS
          SELECT 1
            FROM craplcm
           WHERE craplcm.cdcooper = pr_cdcooper      
             AND craplcm.dtmvtolt = rw_crapdat.dtmvtolt  
             AND craplcm.cdagenci = pr_cdagenci  
             AND craplcm.cdbccxlt = pr_cdbccxlt  
             AND craplcm.nrdolote = pr_nrdolote  
             AND craplcm.nrdctabb = pr_nrdconta       
             AND craplcm.nrdocmto = pr_nrdocmto
           ORDER BY cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdctabb, nrdocmto;
        rw_craplcm cr_craplcm%ROWTYPE;

        -- busca o tipo de lancamento (debito / credito) do historico
        CURSOR cr_craphis IS
          SELECT indebcre
            FROM craphis
           WHERE craphis.cdcooper = pr_cdcooper
             AND craphis.cdhistor = pr_cdhistor;
        rw_craphis cr_craphis%ROWTYPE;

        
        -- Variaveis gerais
        vr_nrdolote craplot.nrdolote%TYPE;      --> Numero do lote
        vr_cdagenci craplot.cdagenci%TYPE;      --> Numero do PA
        vr_cdbccxlt craplot.cdbccxlt%TYPE;      --> Codigo do banco/caixa. 
        vr_tplotmov craplot.tplotmov%TYPE := 1; --> Tipo do lote
        vr_nrdocmto craplcm.nrdocmto%TYPE;      --> Numero do documento

      BEGIN

        -- Constantes utilizadas para a geracao do lote
        vr_nrdolote := 7103; -- Lote unico utilizado no lote
        vr_cdagenci := 1; -- Agencia central
        vr_cdbccxlt := 85; 
        vr_nrdocmto := to_char(pr_nrdocmto) || '001';

        -- busca os dados da capa de lote
        OPEN cr_craplot(vr_nrdolote, vr_cdagenci, vr_cdbccxlt);
        FETCH cr_craplot INTO rw_craplot;
           
        -- Se nao existir capa de lote, efetua a insercao
        IF cr_craplot%NOTFOUND THEN
          BEGIN
            INSERT INTO craplot
              (cdcooper,
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov)
             VALUES
              (pr_cdcooper,
               rw_crapdat.dtmvtolt,
               vr_cdagenci,
               vr_cdbccxlt,
               vr_nrdolote,
               vr_tplotmov)
             RETURNING
               nrseqdig,
               ROWID
             INTO
               rw_craplot.nrseqdig,
               rw_craplot.rowid;
          EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir craplot: ' ||SQLERRM;
               RAISE vr_exc_saida;
          END;
        END IF;
        CLOSE cr_craplot;

        -- Efetua busca para descobrir o primeiro numero de documento livre
        LOOP
          -- busca os lancamentos de deposito a vista
          OPEN cr_craplcm(vr_nrdolote, vr_cdagenci, vr_cdbccxlt, vr_nrdocmto);
          FETCH cr_craplcm INTO rw_craplcm;
          
          -- Se encontrar, adiciona 1 para o numero do documento
          IF cr_craplcm%FOUND THEN
            CLOSE cr_craplcm;
            vr_nrdocmto := vr_nrdocmto + 1;
          ELSE
            EXIT;
          END IF;
        END LOOP;
        CLOSE cr_craplcm;

        -- incrementa 1 no valor sequencial
        rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;

        -- Insere lancamento de deposito a vista
        BEGIN
          INSERT INTO craplcm
            (cdcooper,
             nrdconta,
             nrdctabb,
             dtmvtolt,
             dtrefere,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdocmto,
             cdhistor,
             vllanmto,
             nrseqdig)
           VALUES
            (pr_cdcooper,
             pr_nrdconta,
             pr_nrdconta,
             rw_crapdat.dtmvtolt,
             rw_crapdat.dtmvtolt,
             vr_cdagenci,
             vr_cdbccxlt,
             vr_nrdolote,
             vr_nrdocmto,
             pr_cdhistor,
             pr_vlrlamto,
             rw_craplot.nrseqdig);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- busca o tipo de lancamento (debito / credito) do historico
        OPEN cr_craphis;
        FETCH cr_craphis INTO rw_craphis;
        CLOSE cr_craphis;

        -- Atualza a capa de lote
        BEGIN
          UPDATE craplot
             SET qtinfoln = qtinfoln + 1,
                 qtcompln = qtcompln + 1,
                 nrseqdig = rw_craplot.nrseqdig,
                 vlinfocr = vlinfocr + decode(rw_craphis.indebcre,'C',pr_vlrlamto,0),
                 vlcompcr = vlcompcr + decode(rw_craphis.indebcre,'C',pr_vlrlamto,0),
                 vlinfodb = vlinfodb + decode(rw_craphis.indebcre,'C',0,pr_vlrlamto),
                 vlcompdb = vlcompdb + decode(rw_craphis.indebcre,'C',0,pr_vlrlamto)
           WHERE ROWID = rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPLOT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END pc_cria_craplcm;


      -- Rotina responsavel pela criacao dos lancamentos de debito e credito
      PROCEDURE pc_cria_lancamentos(pr_cdhisdeb crapthi.cdhistor%TYPE,
                                    pr_cdhiscre crapthi.cdhistor%TYPE) IS

        -- Busca as contas de debito e credito da cooperativa
        CURSOR cr_crapcop_3(pr_cdcooper crapcop.cdcooper%TYPE) IS
          SELECT nrctactl
            FROM crapcop
           WHERE cdcooper = pr_cdcooper;

        -- Busca as tarifas do historico de debito
        CURSOR cr_crapthi IS
          SELECT vltarifa
            FROM crapthi
           WHERE crapthi.cdcooper = 3 /* Sempre pela cooper 3 */
             AND crapthi.cdhistor = pr_cdhisdeb
             AND crapthi.dsorigem = 'CASH';
        rw_crapthi cr_crapthi%ROWTYPE;

        -- Busca os dados dos associados
        CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                          pr_nrdconta crapass.nrdconta%TYPE) IS
          SELECT cdagenci
            FROM crapass
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;

        vr_tot_vltarifa NUMBER(17,2) := 0;      --> Valor total da tarifa
        vr_nrctacre     crapcop.nrctactl%TYPE;  --> Numero da conta de credito da cooperativa
        vr_nrctadeb     crapcop.nrctactl%TYPE;  --> Numero da conta de debito da cooperativa
      BEGIN

        /**** CALCULO DO VALOR DA TARIFA *****/
        OPEN cr_crapthi;
        FETCH cr_crapthi INTO rw_crapthi;
        CLOSE cr_crapthi;

        -- Busca o primeiro registro da temp-table de lancamentos
        vr_ind := vr_tab_lancamentos.first;
        
        -- Loop sobre a temp-table de lancamentos
        LOOP
          EXIT WHEN vr_ind IS NULL;
           
          -- Se a cooperativa atual eh diferente da cooperativa anterior
          IF vr_ind = vr_tab_lancamentos.first OR
             vr_tab_lancamentos(vr_tab_lancamentos.prior(vr_ind)).cdcooper <> vr_tab_lancamentos(vr_ind).cdcooper THEN

            -- Inicializa as variaveis
            vr_tot_vltarifa := 0;
            vr_nrctacre     := NULL;
            vr_nrctadeb     := NULL;
            
            /* Busca o nr de conta CREDITO */
            OPEN cr_crapcop_3(vr_tab_lancamentos(vr_ind).cdcoptfn);
            FETCH cr_crapcop_3 INTO vr_nrctacre;
            CLOSE cr_crapcop_3;
    
            /* Busca o nr de conta DEBITO */
            OPEN cr_crapcop_3(vr_tab_lancamentos(vr_ind).cdcooper);
            FETCH cr_crapcop_3 INTO vr_nrctadeb;
            CLOSE cr_crapcop_3;

          END IF;

          vr_tot_vltarifa := vr_tot_vltarifa + 
                                  (vr_tab_lancamentos(vr_ind).qtdmovto * rw_crapthi.vltarifa);
          /**** FIM CALCULO DO VALOR DA TARIFA *****/


          /******* DADOS PARA RELATORIO ***********/
          OPEN cr_crapass(vr_tab_lancamentos(vr_ind).cdcooper,
                          vr_tab_lancamentos(vr_ind).nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          CLOSE cr_crapass;

          IF vr_tab_lancamentos(vr_ind).qtdmovto * rw_crapthi.vltarifa > 0 THEN

            -- Cria registro de filho no relatorio para debito
            pc_cria_relat_filho(pr_cdhisdeb,
                                'D',
                                vr_nrctadeb,
                                vr_nrctacre,
                                rw_crapass.cdagenci,
                                vr_tab_lancamentos(vr_ind).qtdmovto * rw_crapthi.vltarifa);
      
            -- Cria registro de filho no relatorio para credito
            pc_cria_relat_filho(pr_cdhisdeb,
                                'C',
                                vr_nrctacre,
                                vr_nrctadeb,
                                vr_tab_lancamentos(vr_ind).cdagetfn,
                                vr_tab_lancamentos(vr_ind).qtdmovto * rw_crapthi.vltarifa);
          END IF;
          /******* FIM - DADOS PARA RELATORIO ***********/

      
          -- Se a proxima cooperativa for diferente da atual (last-of) 
          IF vr_ind = vr_tab_lancamentos.last OR
             vr_tab_lancamentos(vr_tab_lancamentos.next(vr_ind)).cdcooper <> vr_tab_lancamentos(vr_ind).cdcooper THEN

            /**** Cria LCM ****/
            IF vr_tot_vltarifa > 0 THEN
                
              /*** Lancamento de Debito ***/
              pc_cria_craplcm (vr_nrctadeb,
                               vr_tot_vltarifa,
                               pr_cdhisdeb,
                               vr_nrctacre /* p/ nrdocmto */);
    
              /*** Lancamento de Credito ***/
              pc_cria_craplcm (vr_nrctacre,
                               vr_tot_vltarifa,
                               pr_cdhiscre,
                               vr_nrctadeb /* p/ nrdocmto */);

              -- Cria registro de pai no relatorio
              pc_cria_relat_pai(pr_cdhisdeb,
                                vr_nrctadeb,
                                vr_nrctacre,
                                vr_tot_vltarifa);
            END IF;
          END IF;
          
          -- Vai para o proximo registro da temp-table
          vr_ind := vr_tab_lancamentos.next(vr_ind);
        END LOOP;

      END pc_cria_lancamentos;


      -- Gera o relatorio com base nas temp-tables de pai e filho
      PROCEDURE pc_emite_relatorio(pr_cdcooper crapcop.cdcooper%TYPE,
                                   pr_nrctactl crapcop.nrctactl%TYPE,
                                   pr_nmrescop crapcop.nmrescop%TYPE) IS
        vr_flggera BOOLEAN := FALSE;
      BEGIN

        -- Inicializar o CLOB
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicializa o XML
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<?xml version="1.0" encoding="utf-8"?><crrl582>');
        -- Se i for igual a 1, sera processado o debito. Se for igual a 2, sera processado o credito
        FOR i IN 1..2 LOOP

          -- busca o indice do primeiro registro da pl_table VR_IND_PAI
          vr_ind_pai := vr_tab_relat_pai.first;
          
          -- Efetua loop sobre a pl_table VR_IND_PAI
          LOOP
            EXIT WHEN vr_ind_pai IS NULL;
            
            -- Se for para quebrar por cooperativa
            IF pr_cdcooper IS NOT NULL THEN
              -- Se for para processar o debito e a conta de debito for diferente da cooperativa 
              -- vai para o proximo registro
              IF i = 1 AND vr_tab_relat_pai(vr_ind_pai).nrctadeb <> pr_nrctactl THEN
                vr_ind_pai := vr_tab_relat_pai.next(vr_ind_pai);
                continue;
              END IF;

              -- Se for para processar o credito e a conta de credito for diferente da cooperativa 
              -- vai para o proximo registro
              IF i = 2 AND vr_tab_relat_pai(vr_ind_pai).nrctacre <> pr_nrctactl THEN
                vr_ind_pai := vr_tab_relat_pai.next(vr_ind_pai);
                continue;
              END IF;
            END IF;

            -- Seta a flag informando que deve gerar o relatorio
            vr_flggera := TRUE;
            
            /*** Exibe os filhos de DEBITO ***/
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                          '<pai>'||
                            '<nrctadeb>'||gene0002.fn_mask(vr_tab_relat_pai(vr_ind_pai).nrctadeb,'zzzz.zzz.9')||'</nrctadeb>'||
                            '<dshistor>'||vr_tab_relat_pai(vr_ind_pai).dshistor||'</dshistor>'||
                            '<nrctacre>'||gene0002.fn_mask(vr_tab_relat_pai(vr_ind_pai).nrctacre,'zzzz.zzz.9')||'</nrctacre>'||
                            '<vlrtotal>'||to_char(vr_tab_relat_pai(vr_ind_pai).vlrtotal,'fm999G999G990D00')||'</vlrtotal>');
            
            -- busca o indice do filho relacionado ao pai
            vr_ind_filho := 'D'|| lpad(vr_tab_relat_pai(vr_ind_pai).cdhistor,5,'0')||
                                  lpad(vr_tab_relat_pai(vr_ind_pai).nrctadeb,5,'0')||
                                  lpad(vr_tab_relat_pai(vr_ind_pai).nrctacre,5,'0')||
                                  '00000';
                                  
           
            -- Efetua loop sobre a pl_table VR_IND_FILHO
            LOOP
              -- Vai para o proximo registro
              vr_ind_filho := vr_tab_relat_filho.next(vr_ind_filho);
             
              -- Se nao possuir registro, sai do loop
              EXIT WHEN vr_ind_filho IS NULL;
              
              -- Se o registro atual nao pertencer ao pai
              IF vr_tab_relat_filho(vr_ind_filho).indebcre <> 'D' OR
                 vr_tab_relat_filho(vr_ind_filho).cdhistor <> vr_tab_relat_pai(vr_ind_pai).cdhistor OR
                 vr_tab_relat_filho(vr_ind_filho).nrctadeb <> vr_tab_relat_pai(vr_ind_pai).nrctadeb OR
                 vr_tab_relat_filho(vr_ind_filho).nrctacre <> vr_tab_relat_pai(vr_ind_pai).nrctacre THEN
                EXIT; -- Sai do loop
              END IF;
              
              -- Imprimir os dados da pl_table vr_tab_relat_filho
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                            '<filho>'||
                              '<indebcre>'||vr_tab_relat_filho(vr_ind_filho).indebcre||'</indebcre>'||
                              '<cdagenci>'||vr_tab_relat_filho(vr_ind_filho).cdagenci||'</cdagenci>'||
                              '<vlrtotal_filho>'||to_char(vr_tab_relat_filho(vr_ind_filho).vlrtotal,'fm999G999G990D00')||'</vlrtotal_filho>'||
                            '</filho>');
            END LOOP;  
                         
            -- busca o indice do filho relacionado ao pai
            vr_ind_filho := 'C'|| lpad(vr_tab_relat_pai(vr_ind_pai).cdhistor,5,'0')||
                                  lpad(vr_tab_relat_pai(vr_ind_pai).nrctacre,5,'0')||
                                  lpad(vr_tab_relat_pai(vr_ind_pai).nrctadeb,5,'0')||
                                  '00000';
                                  
           
            -- Efetua loop sobre a pl_table VR_IND_FILHO
            LOOP
              -- Vai para o proximo registro
              vr_ind_filho := vr_tab_relat_filho.next(vr_ind_filho);
             
              -- Se nao possuir registro, sai do loop
              EXIT WHEN vr_ind_filho IS NULL;
              
              -- Se o registro atual nao pertencer ao pai
              IF vr_tab_relat_filho(vr_ind_filho).indebcre <> 'C' OR
                 vr_tab_relat_filho(vr_ind_filho).cdhistor <> vr_tab_relat_pai(vr_ind_pai).cdhistor OR
                 vr_tab_relat_filho(vr_ind_filho).nrctadeb <> vr_tab_relat_pai(vr_ind_pai).nrctacre OR
                 vr_tab_relat_filho(vr_ind_filho).nrctacre <> vr_tab_relat_pai(vr_ind_pai).nrctadeb THEN
                EXIT; -- Sai do loop
              END IF;

              -- Imprimir os dados da pl_table vr_tab_relat_filho
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                            '<filho>'||
                              '<indebcre>'||vr_tab_relat_filho(vr_ind_filho).indebcre||'</indebcre>'||
                              '<cdagenci>'||vr_tab_relat_filho(vr_ind_filho).cdagenci||'</cdagenci>'||
                              '<vlrtotal_filho>'||to_char(vr_tab_relat_filho(vr_ind_filho).vlrtotal,'fm999G999G990D00')||'</vlrtotal_filho>'||
                            '</filho>');
              
                         
            END LOOP;
            
            -- Fecha o nó de pai
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</pai>');

            -- Vai para o proximo registro
            vr_ind_pai := vr_tab_relat_pai.next(vr_ind_pai);
            
          END LOOP; -- Loop sobre o pai

          -- Se nao possui cooperativa, entao o debito e credito ja foram processados. Deve sair do loop
          IF pr_cdcooper IS NULL THEN
            EXIT;
          END IF;

        END LOOP; -- Loop sobre contador ate 2

        -- Fecha o nó principal
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</crrl582>',TRUE);

        -- Se nao tiver cooperativa, gera o arquivo no diretorio da CECRED
        IF pr_cdcooper IS NULL THEN
          -- Busca do diretorio base da cooperativa
          vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => 3
                                                ,pr_nmsubdir => 'rl'); 
        ELSE
          -- Busca do diretorio base da cooperativa
          vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'rl'); 
        END IF;
        
        -- Se a flag de geracao de relatorio estiver ativa
        IF vr_flggera THEN
          
          -- Chamada do iReport para gerar o arquivo de saida
          -- Observacao IMPORTANTE: A cooperativa que ira gerar sera sempre 3, porem o arquivo sera gerado na pasta
          --                        de cada cooperativa
          gene0002.pc_solicita_relato(pr_cdcooper  => 3,                              --> Cooperativa conectada
                                      pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                      pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                      pr_dsxmlnode => '/crrl582/pai/filho',           --> No base do XML para leitura dos dados
                                      pr_dsjasper  => 'crrl582.jasper',               --> Arquivo de layout do iReport
                                      pr_dsparams  => null,                           --> Nao enviar parametro
                                      pr_dsarqsaid => vr_nom_direto||'/crrl582'|| replace(nvl(pr_nmrescop,''),' ','_') ||'.lst',  --> Arquivo final
                                      pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                      pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                      pr_nmformul  => '132col',                       --> Nome do formulario
                                      pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                      pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                      pr_nrcopias  => 1,                              --> Numero de copias
                                      pr_des_erro  => vr_dscritic);                   --> Saida com erro
          -- Verifica se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;             
        END IF;
                 
      END pc_emite_relatorio;



    BEGIN  -- INICIO DA ROTINA PRINCIPAL

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
      -- busca o primeiro dia da data de movimento
      vr_dtmvtini := trunc(rw_crapdat.dtmvtolt,'MM');

      -- Efetua loop sobre as cooperativas (exceto cooperativa 3-Cecred)
      FOR rw_crapcop_2 IN cr_crapcop_2 LOOP
        /*********** Tarifas para Consulta de Saldo (tpextrat = 10) ***********/
        tari0001.pc_taa_lancamento_tarifas_ext(0,                     /* Saques de meus Ass. outros TAAs */
                                               rw_crapcop_2.cdcooper, /* Saques no meu TAA */
                                               10,                    /* tipo de extrato */
                                               NULL,                  /* situacao do extrato */
                                               vr_dtmvtini,           /* data de movimento inicial */
                                               rw_crapdat.dtmvtolt,   /* data de movimento final */
                                               5,                     /* cdtplanc */
                                               vr_dscritic,              /* retorno de erro */
                                               vr_tab_lancamentos);   /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos(905,  /* Historico de DEB */
                            906); /* Historico de CRE */

        /*********** Tarifas para Impressao de Saldo (tpextrat = 11) **********/
        tari0001.pc_taa_lancamento_tarifas_ext(0,                     /* Saques de meus Ass. outros TAAs */
                                               rw_crapcop_2.cdcooper, /* Saques no meu TAA */
                                               11,                    /* tipo de extrato */
                                               NULL,                  /* situacao do extrato */
                                               vr_dtmvtini,           /* data de movimento inicial */
                                               rw_crapdat.dtmvtolt,   /* data de movimento final */
                                               7,                     /* cdtplanc */
                                               vr_dscritic,           /* retorno de erro */
                                               vr_tab_lancamentos);   /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
    
        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (907,  /* Historico de DEB */
                             908); /* Historico de CRE */


       /* Tarifas para Impressao Extrato de C/C(tpextrat = 1 e insitext = 5) */
        tari0001.pc_taa_lancamento_tarifas_ext(0,                     /* Saques de meus Ass. outros TAAs */
                                               rw_crapcop_2.cdcooper, /* Saques no meu TAA */
                                               1,                     /* tipo de extrato */
                                               5,                     /* situacao do extrato */
                                               vr_dtmvtini,           /* data de movimento inicial */
                                               rw_crapdat.dtmvtolt,   /* data de movimento final */
                                               9,                     /* cdtplanc */
                                               vr_dscritic,           /* retorno de erro */
                                               vr_tab_lancamentos);   /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
    
        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (909,  /* Historico de DEB */
                             910); /* Historico de CRE */


        /**** Tarifas para Impressao Extrato Aplicacao (tpextrat = 12) ****/
        tari0001.pc_taa_lancamento_tarifas_ext(0,                     /* Saques de meus Ass. outros TAAs */
                                               rw_crapcop_2.cdcooper, /* Saques no meu TAA */
                                               12,                    /* tipo de extrato */
                                               NULL,                  /* situacao do extrato */
                                               vr_dtmvtini,           /* data de movimento inicial */
                                               rw_crapdat.dtmvtolt,   /* data de movimento final */
                                               11,                    /* cdtplanc */
                                               vr_dscritic,           /* retorno de erro */
                                               vr_tab_lancamentos);   /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
    
        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (911,  /* Historico de DEB */
                             912); /* Historico de CRE */


        /************* Tarifas para Pagto de Titulos e Convenios *************/
        cobr0001.pc_taa_lancto_titulos_conv(0,                        /* Saques de meus Ass. outros TAAs */
                                            rw_crapcop_2.cdcooper,    /* Saques no meu TAA */
                                            vr_dtmvtini,              /* data de movimento inicial */
                                            rw_crapdat.dtmvtolt,      /* data de movimento final */
                                            3,                        /* cdtplanc */
                                            vr_dscritic,              /* retorno de erro */
                                            vr_tab_lancamentos);      /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (915,  /* Historico de DEB */
                             916); /* Historico de CRE */


        /*************** Tarifas para Saques de Numerarios ***************/
        cada0001.pc_busca_movto_saque_cooper(0,                        /* Saques de meus Ass. outros TAAs */
                                             rw_crapcop_2.cdcooper,    /* Saques no meu TAA */
                                             vr_dtmvtini,              /* data de movimento inicial */
                                             rw_crapdat.dtmvtolt,      /* data de movimento final */
                                             1,                        /* cdtplanc */
                                             vr_dscritic,              /* retorno de erro */
                                             vr_tab_lancamentos);      /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (913,  /* Historico de DEB */
                             914); /* Historico de CRE */

        
        /*************** Tarifas para Agendamento de Pagamentos ***************/
        cobr0001.pc_taa_agenda_titulos_conv(0,                        /* Saques de meus Ass. outros TAAs */
                                            rw_crapcop_2.cdcooper,    /* Saques no meu TAA */
                                            vr_dtmvtini,              /* data de movimento inicial */
                                            rw_crapdat.dtmvtolt,      /* data de movimento final */
                                            13,                       /* cdtplanc */
                                            vr_dscritic,              /* retorno de erro */
                                            vr_tab_lancamentos);      /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (943,  /* Historico de DEB */
                             944); /* Historico de CRE */


        /*************** Tarifas para Transferencias (propria coop) ***************/
        trnf0001.pc_taa_transferencias(0,                        /* Saques de meus Ass. outros TAAs */
                                       rw_crapcop_2.cdcooper,    /* Saques no meu TAA */
                                       vr_dtmvtini,              /* data de movimento inicial */
                                       rw_crapdat.dtmvtolt,      /* data de movimento final */
                                       15,                       /* cdtplanc */
                                       vr_dscritic,              /* retorno de erro */
                                       vr_tab_lancamentos);      /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (945,  /* Historico de DEB */
                             946); /* Historico de CRE */


        /********* Tarifas para Agendamento de Transferencias (propria coop) *********/
        trnf0001.pc_taa_agenda_transferencias(0,                        /* Saques de meus Ass. outros TAAs */
                                              rw_crapcop_2.cdcooper,    /* Saques no meu TAA */
                                              vr_dtmvtini,              /* data de movimento inicial */
                                              rw_crapdat.dtmvtolt,      /* data de movimento final */
                                              17,                       /* cdtplanc */
                                              vr_dscritic,              /* retorno de erro */
                                              vr_tab_lancamentos);      /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
                                       
        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (947,  /* Historico de DEB */
                             948); /* Historico de CRE */


        /*********Tarifas para Consulta de Agendamentos (tpextrat = 13)**********/
        tari0001.pc_taa_lancamento_tarifas_ext(0,                     /* Saques de meus Ass. outros TAAs */
                                               rw_crapcop_2.cdcooper, /* Saques no meu TAA */
                                               13,                    /* tipo de extrato */
                                               NULL,                  /* situacao do extrato */
                                               vr_dtmvtini,           /* data de movimento inicial */
                                               rw_crapdat.dtmvtolt,   /* data de movimento final */
                                               13,                    /* cdtplanc */
                                               vr_dscritic,           /* retorno de erro */
                                               vr_tab_lancamentos);   /* tabela de retorno */

        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (949,  /* Historico de DEB */
                             950); /* Historico de CRE */


        /********** Tarifas para Exclusao de Agendamentos (tpextrat = 14)**********/
        tari0001.pc_taa_lancamento_tarifas_ext(0,                     /* Saques de meus Ass. outros TAAs */
                                               rw_crapcop_2.cdcooper, /* Saques no meu TAA */
                                               14,                    /* tipo de extrato */
                                               NULL,                  /* situacao do extrato */
                                               vr_dtmvtini,           /* data de movimento inicial */
                                               rw_crapdat.dtmvtolt,   /* data de movimento final */
                                               15,                    /* cdtplanc */
                                               vr_dscritic,           /* retorno de erro */
                                               vr_tab_lancamentos);   /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;


        /** Cria LCM para a cooperativa processada **/
        pc_cria_lancamentos (951,  /* Historico de DEB */
                             952); /* Historico de CRE */


        /********** Tarifas para Impressao Comprovantes (tpextrat = 15)**********/
        tari0001.pc_taa_lancamento_tarifas_ext(0,                     /* Saques de meus Ass. outros TAAs */
                                               rw_crapcop_2.cdcooper, /* Saques no meu TAA */
                                               15,                    /* tipo de extrato */
                                               NULL,                  /* situacao do extrato */
                                               vr_dtmvtini,           /* data de movimento inicial */
                                               rw_crapdat.dtmvtolt,   /* data de movimento final */
                                               23,                    /* cdtplanc */
                                               vr_dscritic,           /* retorno de erro */
                                               vr_tab_lancamentos);   /* tabela de retorno */
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        /** Cria LCM para a cooperativa processada **/   
        pc_cria_lancamentos (1001,  /* Historico de DEB */
                             1002); /* Historico de CRE */


      END LOOP;

      -- Loop para geracao do relatorio por cooperativa
      FOR rw_crapcop_2 IN cr_crapcop_2 LOOP
        pc_emite_relatorio(rw_crapcop_2.cdcooper, rw_crapcop_2.nrctactl, rw_crapcop_2.nmrescop);
      END LOOP;

      -- Emite o relatorio geral (agrupado de todas as cooperativas)
      pc_emite_relatorio(NULL, NULL, NULL);

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

  END pc_crps581;
/

