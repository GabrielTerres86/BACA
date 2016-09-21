CREATE OR REPLACE PROCEDURE CECRED.pc_crps214 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps214                                     (Fontes/crps214.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Maio/97                           Ultima atualizacao: 22/06/2016

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 001.
                   Emitir relatorio referente aos convenios de debito em conta.
                   Emite relatorio 153.

       Observação : A partir da conversão de Progress >>> PLSQL deixamos de tratar o convênio
                    8 como uma lógica de gravação e geração do relatório única, e passamos a
                    tratá-lo como todos os outros. Esta foi uma decisão do Elton pois o convênio
                    8 não era mais recebido desde 2008 e se um dia houver novo recebimento, então
                    ele será tratado como os outros convênios.

       Alteracoes: 10/12/97 - Alterado para emitir 3 vias (Deborah).

                   09/01/98 - Acerto no acesso a tabela de tarifa (Deborah).

                   12/03/98 - Alterado para listar o PAC (Deborah).

                   24/05/1999 - Criada tabela de tarifas generica para nao
                                calcular mais com 0 (Deborah).

                   09/12/2003 - Buscar nome da cidade no crapcop (Junior).

                   14/10/2004 - Imprimir somente uma via do relatorio (Ze).

                   11/11/2004 - Enviar e-mail, se existir o e-mail, com o relatorio
                                gerado em anexo (Evandro).

                   30/06/2005 - Alimentado campo cdcooper da tabela crapctc (Diego).

                   20/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).

                   12/04/2007 - Retirar rotina de email em comentario (David).

                   09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                                glb_cdcooper) no "find" da tabela CRAPHIS.
                              - Kbase IT Solutions - Paulo Ricardo Maciel.

                   28/08/2008 - Erro de array no lookup. Espaco em branco (Magui).
                   01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   13/10/2008 - Erro de array no lookup. Espaco em branco (Magui).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   15/08/2013 - Nova forma de chamar as agências, de PAC agora
                                a escrita será PA (André Euzébio - Supero).

                   16/01/2014 - Inclusao de VALIDATE crapctc (Carlos)

                   07/04/2014 - Conversão Progress >> Oracle PL/SQL (Marcos-Supero)

                   22/06/2016 - Correcao para o uso correto do indice da CRAPTAB 
                                nesta rotina.(Carlos Rafael Tanholi).            
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS214';

      -- Tratamento de erros
      vr_exc_saida       EXCEPTION;
      vr_exc_fimprg      EXCEPTION;
      vr_exc_ignora_conv EXCEPTION;
      vr_cdcritic        PLS_INTEGER;
      vr_dscritic        VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nmcidade
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar dados dos associados
      CURSOR cr_crapass IS   --> Código da cooperativa
        SELECT ass.nrdconta
              ,SUBSTR(ass.nmprimtl,1,28) nmprimtl
              ,age.cdagenci
              ,SUBSTR(age.nmresage,1,15) nmresage
          FROM crapage age
              ,crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci;

      -- Carga das tarifas dos históricos
      -- Já montando a chave da vr_tab_txhistor
      CURSOR cr_craptab_vltarif IS
        SELECT to_char(cdempres,'fm00000')||cdacesso cdchvtxh
              ,gene0002.fn_char_para_number(dstextab) vltarifa
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper -- Codigo da cooperativa
           AND UPPER(tab.nmsistem) = 'CRED'
           AND UPPER(tab.tptabela) = 'USUARI'
           AND REGEXP_LIKE(UPPER(tab.cdacesso),'VLTARIF[[:digit:]]')
           AND tab.tpregist = 1;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Consulta de convenios integrados por empresa
      CURSOR cr_crapepc IS
        SELECT epc.dtrefere
              ,epc.incvfol1
              ,epc.incvfol2
              ,epc.dtcvfol2
              ,epc.dtcvcta1
              ,epc.dtcvcta2
              ,epc.incvcta1
              ,epc.incvcta2
              ,epc.cdempres
              ,epc.nrconven
          FROM crapepc epc
         WHERE epc.cdcooper = pr_cdcooper;  -- Codigo da cooperativa

       -- Consulta de empresas
      CURSOR cr_crapemp IS
        SELECT emp.cdempres
              ,emp.nmresemp
              ,emp.dtavsemp
          FROM crapemp emp
         WHERE emp.cdcooper = pr_cdcooper; -- Codigo da cooperativa

      -- Consulta de convenios integrados por empresa
      CURSOR cr_crapcnv IS
        SELECT cnv.nrconven
              ,cnv.dsconven
              ,cnv.dsdemail
              ,cnv.indebcre
              ,cnv.lshistor
          FROM crapcnv cnv
         WHERE cnv.cdcooper = pr_cdcooper; -- Codigo da cooperativa

      -- Consulta de historicos
      CURSOR cr_craphis (pr_cdhistor IN craphis.cdhistor%TYPE)IS
        SELECT his.dshistor
          FROM craphis his
         WHERE his.cdcooper = pr_cdcooper  -- Codigo da coop conectada
           AND his.cdhistor = pr_cdhistor; -- Codigo do historico
      vr_dshistor craphis.dshistor%TYPE;

      -- Consulta dos avisos de debito em conta corrente
      CURSOR cr_crapavs (pr_nrconven IN crapavs.nrconven%TYPE
                        ,pr_cdempcnv IN crapavs.cdempcnv%TYPE
                        ,pr_dtrefere IN crapavs.dtrefere%TYPE
                        ,pr_intipdeb IN pls_integer)IS
        SELECT avs.nrdconta
              ,avs.tpdaviso
              ,avs.cdhistor
              ,avs.vllanmto
              ,avs.insitavs
              ,avs.vlestdif
              ,avs.vldebito
              ,avs.nrdocmto
              ,avs.dtintegr
          FROM crapavs avs
         WHERE avs.cdcooper = pr_cdcooper -- Codigo da cooperativa
           AND avs.nrconven = pr_nrconven -- Numero do convenio
           AND avs.cdempcnv = pr_cdempcnv -- Codigo da empresa conveniada
           AND avs.dtrefere = pr_dtrefere -- Data de referencia
           AND ( -- Somente tipo de aviso 1 para Folhe
                 ( pr_intipdeb = 0 AND avs.tpdaviso = 1 )
                OR
                 -- Ou tipo de aviso 3 para Débitos em conta
                 ( avs.tpdaviso = 3)
               )
         ORDER BY avs.nrdconta;
      rw_crapavs cr_crapavs%ROWTYPE;

      -- Busca do convênio
      CURSOR cr_crapctc(pr_nrconven IN crapepc.nrconven%TYPE
                       ,pr_dtrefere IN crapepc.dtrefere%TYPE
                       ,pr_cdempres IN crapepc.cdempres%TYPE
                       ,pr_cdhistor IN crapctc.cdhistor%TYPE) IS
        SELECT ctc.vltarifa
              ,ctc.qtefetua
              ,ctc.vlefetua
              ,ctc.qtlanmto
              ,ctc.vllanmto
              ,ctc.qtempres
          FROM crapctc ctc
         WHERE ctc.cdcooper = pr_cdcooper
           AND ctc.nrconven = pr_nrconven
           AND ctc.dtrefere = pr_dtrefere
           AND ctc.cdempres = pr_cdempres
           AND ctc.cdhistor = pr_cdhistor;
      rw_crapctc cr_crapctc%rowtype;

      -- Lista do convênio processados
      CURSOR cr_crapctc_resumo(pr_dtresumo IN crapctc.dtresumo%TYPE) IS
        SELECT ctc.nrconven
              ,ctc.dtrefere
              ,ctc.vllanmto
              ,ctc.qtlanmto
              ,ctc.vlrejeit
              ,ctc.qtrejeit
          FROM crapctc ctc
         WHERE ctc.cdcooper = pr_cdcooper
           AND ctc.dtresumo = pr_dtresumo;

      -- Busca do convênio contidos no resumo passado
      CURSOR cr_crapctc_contido(pr_nrconven IN crapepc.nrconven%TYPE
                               ,pr_dtrefere IN crapepc.dtrefere%TYPE) IS
        SELECT ctc.vltarifa                   vltarifa
              ,SUM(ctc.vlrejeit)              vlrejeit
              ,SUM(ctc.qtrejeit)              qtrejeit
              ,SUM(ctc.qtefetua*ctc.vltarifa) vltarifa_efetua
              ,SUM(ctc.qtefetua)              qtefetua
          FROM crapctc ctc
         WHERE ctc.cdcooper = pr_cdcooper
           AND ctc.nrconven = pr_nrconven
           AND ctc.dtrefere = pr_dtrefere
           AND ctc.cdempres > 0
         GROUP BY ctc.vltarifa;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Tipo para armazenar as informações dos associados
      TYPE typ_reg_crapass IS
        RECORD(nmprimtl crapass.nmprimtl%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,nmresage crapage.nmresage%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
        INDEX BY PLS_INTEGER; --> Numero da conta como chave
      vr_tab_crapass typ_tab_crapass;

      -- Tabela para armazenar as taxas cfme histórico
      TYPE typ_tab_txhistor IS
        TABLE OF NUMBER
        INDEX BY VARCHAR2(16); --> Empresa(5)+VLTARIF(7)+histor(4)
      vr_tab_txhistor typ_tab_txhistor;

      -- Tipo para armazenar a estrutura do cadastro de empresas
      TYPE typ_reg_crapemp IS
        RECORD(nmresemp crapemp.nmresemp%TYPE
              ,dtavsemp crapemp.dtavsemp%TYPE);
      -- Estrutura do cadastro de empresas
      TYPE typ_tab_crapemp IS
        TABLE OF typ_reg_crapemp
          INDEX BY PLS_INTEGER; --> Código da empresa
      -- Tabela temporaria para armazenar os dados da empresa
      vr_tab_crapemp typ_tab_crapemp;

      -- Tipo para armazenar a estrutura do cadastro de convênios
      TYPE typ_reg_crapcnv IS
        RECORD(indebcre crapcnv.indebcre%TYPE
              ,dsconven crapcnv.dsconven%TYPE
              ,dsdemail crapcnv.dsdemail%TYPE
              ,tbhistor gene0002.typ_split);
      -- Estrutura do cadastro de convenios
      TYPE typ_tab_crapcnv IS
        TABLE OF typ_reg_crapcnv
          INDEX BY PLS_INTEGER; --> Código do convênio
      -- Tabela temporaria para armazenar os convenios
      vr_tab_crapcnv typ_tab_crapcnv;

      -- Tipo para armazenar os históricos do relatório
      TYPE typ_reg_tthistor IS
        RECORD(dshistor craphis.dshistor%TYPE
              ,vlhistor NUMBER
              ,qthistor PLS_INTEGER
              ,vlestsau NUMBER
              ,qtestsau PLS_INTEGER
              ,vldebsau NUMBER
              ,qtdebsau PLS_INTEGER);
      -- Estrutura do cadastro de empresas
      TYPE typ_tab_tthistor IS
        TABLE OF typ_reg_tthistor
          INDEX BY PLS_INTEGER; --> Código do histórico
      -- Tabela temporaria para armazenar os registros da tabela
      vr_tab_tthistor typ_tab_tthistor;



      ------------------------------- VARIAVEIS -------------------------------

      vr_intipdeb  pls_integer;     --> Tipo do débito
      vr_flgestou  boolean;         --> Flag de estouro no débito
      vr_flggerar  boolean;         --> Flag para gerar
      vr_dsempres  varchar2(40);    --> Nome da empresa
      vr_contaarq  pls_integer := 0;--> Contagem dos relatórios

      vr_nom_direto varchar2(100);   --> Raiz da Coop
      vr_nmarqimp   VARCHAR2(200);   --> Descrição do relatório
      vr_xml        CLOB;            --> CLOB com conteudo do XML do relatório
      vr_xmlbuffer  VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
      vr_strbuffer  VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
      vr_dtrefere   DATE;            --> Auxiliar para data referência
      vr_dsproces   VARCHAR2(5);     --> Descrição do processo
      vr_flglista   boolean;         --> Flag para controle de fluxo da listagem
      vr_flgpular   boolean;         --> Flag para controle de fluxo da listagem
      vr_contador   number;          --> Contador de registros da AVS
      vr_nrdconta   number;          --> Controle da ultima conta listada
      vr_vltarifa   number;          --> Valor da tarifa por histórico

      vr_res_vldebint number;       --> Valor debitado integrado
      vr_res_qtdebint pls_integer;  --> Quantidade de conv integrados debitados
      vr_res_vlreceit number;       --> Valor da receita integrada
      vr_res_vltarifa number;       --> Valor da tarifa aplicada
      vr_res_qttarifa pls_integer;  --> Quantida de conv tarifados
      vr_res_vlrepass number;       --> Valor do repasse
      vr_res_dstarifa varchar2(100);--> Descrição genérica tarifa
      vr_res_vldebenv number;       --> Valor debitado
      vr_res_qtdebenv pls_integer;  --> Quantidade de lançãmentos
      vr_res_vldebrej number;       --> Valor rejeitado
      vr_res_qtdebrej pls_integer;  --> Quantidade de rejeitos

      --------------------------- SUBROTINAS INTERNAS --------------------------

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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Carregar a tabela de associados
      FOR rw_crapass IN cr_crapass LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).nmresage := rw_crapass.nmresage;
      END LOOP;

      -- Carregar a tabela de taxas por histórico
      FOR rw_craptab IN cr_craptab_vltarif LOOP
        vr_tab_txhistor(rw_craptab.cdchvtxh) := rw_craptab.vltarifa;
      END LOOP;

      -- Carrega a tabela de empresas
      FOR rw_crapemp IN cr_crapemp LOOP
        vr_tab_crapemp(rw_crapemp.cdempres).nmresemp := rw_crapemp.nmresemp;
        vr_tab_crapemp(rw_crapemp.cdempres).dtavsemp := rw_crapemp.dtavsemp;
      END LOOP;

      -- Carrega a tabela de convenios
      FOR rw_crapcnv IN cr_crapcnv LOOP
        vr_tab_crapcnv(rw_crapcnv.nrconven).indebcre := rw_crapcnv.indebcre;
        vr_tab_crapcnv(rw_crapcnv.nrconven).dsconven := rw_crapcnv.dsconven;
        vr_tab_crapcnv(rw_crapcnv.nrconven).dsdemail := rw_crapcnv.dsdemail;
        -- Já separar os históricos e montar na coluna com tipagem de registro
        vr_tab_crapcnv(rw_crapcnv.nrconven).tbhistor := gene0002.fn_quebra_string(pr_string  => rw_crapcnv.lshistor
                                                                                 ,pr_delimit => ',');
      END LOOP;

      -- Montar o caminho raiz da coop
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper);

      -- Leitura dos convênios integrados pela empresa
      FOR rw_crapepc IN cr_crapepc LOOP
        BEGIN
          -- Reiniciar controles
          vr_flgestou := true;
          vr_flggerar := false;
          vr_dtrefere := rw_crapepc.dtrefere;

          -- Para primeiro e segundo débito em folha e
          -- quando alcançarmos o dia seguinto ao débito em folha
          IF rw_crapepc.incvfol1 = 2 AND rw_crapepc.incvfol2 = 2 AND rw_crapepc.dtcvfol2 = rw_crapdat.dtmvtolt THEN
            -- Debito em folha e pode gerar
            vr_intipdeb := 0;
            vr_flggerar := true;
          -- Ou para débito em conta na primeira tentativa
          ELSIF rw_crapepc.incvcta1 = 2 AND rw_crapepc.dtcvcta1 = rw_crapdat.dtmvtolt THEN
            -- Débito em Conta 1ª tentativa
            vr_intipdeb := 1;
            -- Se não houve o segundo débito em conta
            IF rw_crapepc.incvcta2 = 1 THEN
              -- Não há estouro
              vr_flgestou := false;
            END IF;
            -- Em caso de estouro, irá gerar
            IF vr_flgestou THEN
              vr_flggerar := true;
            END IF;
          -- Ou para débito em conta na segunda tentativa
          ELSIF rw_crapepc.incvcta1 = 2 AND rw_crapepc.dtcvcta2 = rw_crapdat.dtmvtolt THEN
            -- Débito em Conta 2ª tentativa e pode gerar
            vr_intipdeb := 2;
            vr_flggerar := true;
          ELSE --> Qualquer outra opção, pula o registro
            CONTINUE;
          END IF;

          -- Buscar descrição da empresa
          IF vr_tab_crapemp.exists(rw_crapepc.cdempres) THEN
            vr_dsempres := to_char(rw_crapepc.cdempres,'fm00000')||' - '||vr_tab_crapemp(rw_crapepc.cdempres).nmresemp;
          ELSE
            vr_dsempres := to_char(rw_crapepc.cdempres,'fm00000')||' - Nao encontrada';
          END IF;

          -- Buscar cadastro do convênio
          IF NOT vr_tab_crapcnv.exists(rw_crapepc.nrconven) THEN
            -- Gerar critica 563 e parar o processo
            vr_cdcritic := 563;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Escrever no log e parar o processo
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || to_char(rw_crapepc.nrconven,'fm00'));
            -- Zerar a critica
            vr_cdcritic := 0;
            -- Sair
            RAISE vr_exc_saida;
          END IF;

          -- Ignorar o registro em caso de convênio de crédito
          IF vr_tab_crapcnv(rw_crapepc.nrconven).indebcre = 'C' THEN
            CONTINUE;
          END IF;

          -- Limpar a pltable totalizadora dos históricos
          vr_tab_tthistor.DELETE;
          -- Se retornou informacoes na lista de histórios
          IF vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor.count() > 0 THEN
            -- Carregar a tabela de histórios do convênio
            FOR vr_ind IN 1..vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor.count LOOP
              -- Se existir esta posição
              IF vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor.EXISTS(vr_ind) THEN
                -- Buscar a descrição
                OPEN cr_craphis(pr_cdhistor => vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind));
                FETCH cr_craphis
                 INTO vr_dshistor;
                -- Se não tiver encontrado
                IF cr_craphis%NOTFOUND THEN
                  -- Usar descrição genérica
                  vr_dshistor := 'Nao encontrado';
                END IF;
                -- Fechar cursor
                CLOSE cr_craphis;
                -- Carregar a informação na pltable de históricos
                vr_tab_tthistor(vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind)).dshistor := ' '||vr_dshistor;
                vr_tab_tthistor(vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind)).vlhistor := 0;
                vr_tab_tthistor(vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind)).qthistor := 0;
                vr_tab_tthistor(vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind)).vlestsau := 0;
                vr_tab_tthistor(vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind)).qtestsau := 0;
                vr_tab_tthistor(vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind)).vldebsau := 0;
                vr_tab_tthistor(vr_tab_crapcnv(rw_crapepc.nrconven).tbhistor(vr_ind)).qtdebsau := 0;
              END IF;
            END LOOP;
          END IF;

          -- Incrementar contador e gerar nome do relatório
          vr_contaarq := vr_contaarq + 1;
          vr_nmarqimp := '/rl/crrl153_'||to_char(vr_contaarq,'fm00')||'.lst';
          vr_dsproces := CASE vr_intipdeb
                           WHEN 0 THEN 'FOLHA'
                           ELSE 'CONTA'
                         END;

          -- Inicializar XML do relatório
          dbms_lob.createtemporary(vr_xml, TRUE);
          dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
          vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><crrl153_root>';

          -- Inicializar tag empresa
          vr_strbuffer := vr_strbuffer
                       || '<empresa>'
                       ||   '<dsempres>'||vr_dsempres||'</dsempres>'
                       ||   '<dtrefere>'||to_char(vr_dtrefere,'dd/mm/yyyy')||'</dtrefere>'
                       ||   '<dsconven>'||to_char(rw_crapepc.nrconven,'fm000')||' - '||vr_tab_crapcnv(rw_crapepc.nrconven).dsconven||'</dsconven>'
                       ||   '<dsproces>'||vr_dsproces||'</dsproces>'
                       ;
          -- Enviar ao CLOB
          gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                 ,pr_texto_completo => vr_xmlbuffer
                                 ,pr_texto_novo     => vr_strbuffer);
          -- Limpar a auxiliar
          vr_strbuffer := null;

          -- Inicializar variaveis controladoras da listagem da AVS
          vr_contador := 0;
          vr_nrdconta := 0;
          vr_flglista := FALSE;
          vr_flgpular := FALSE;

          -- Buscar os avisos em conta
          FOR rw_crapavs IN cr_crapavs (pr_nrconven => rw_crapepc.nrconven
                                       ,pr_cdempcnv => rw_crapepc.cdempres
                                       ,pr_dtrefere => rw_crapepc.dtrefere
                                       ,pr_intipdeb => vr_intipdeb) LOOP
            -- Acumular valores por histórico
            vr_tab_tthistor(rw_crapavs.cdhistor).vlhistor := vr_tab_tthistor(rw_crapavs.cdhistor).vlhistor + NVL(rw_crapavs.vllanmto,0);
            vr_tab_tthistor(rw_crapavs.cdhistor).qthistor := vr_tab_tthistor(rw_crapavs.cdhistor).qthistor + 1;
            -- Se ainda não foi avisado
            IF rw_crapavs.insitavs = 0 THEN
              vr_tab_tthistor(rw_crapavs.cdhistor).vlestsau := vr_tab_tthistor(rw_crapavs.cdhistor).vlestsau + NVL(rw_crapavs.vlestdif,0)*-1;
              vr_tab_tthistor(rw_crapavs.cdhistor).qtestsau := vr_tab_tthistor(rw_crapavs.cdhistor).qtestsau + 1;
            END IF;
            -- Se há debito
            IF rw_crapavs.vldebito > 0 THEN
              vr_tab_tthistor(rw_crapavs.cdhistor).vldebsau := vr_tab_tthistor(rw_crapavs.cdhistor).vldebsau + NVL(rw_crapavs.vldebito,0);
              vr_tab_tthistor(rw_crapavs.cdhistor).qtdebsau := vr_tab_tthistor(rw_crapavs.cdhistor).qtdebsau + 1;
            END IF;
            -- Se o aviso está pago, deverá pular e não mostrar o associado no relatório
            IF rw_crapavs.insitavs = 1 THEN
              CONTINUE;
            END IF;

            -- Se não existir CRAPASS para a conta do aviso
            IF NOT vr_tab_crapass.EXISTS(rw_crapavs.nrdconta) THEN
              -- Gerar critica 9 e parar o processo
              vr_cdcritic := 9;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              -- Escrever no log e parar o processo
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic || gene0002.fn_mask_conta(rw_crapavs.nrdconta));
              -- Zerar a critica
              vr_cdcritic := 0;
              -- Sair
              RAISE vr_exc_saida;
            END IF;

            -- Somente em caso de estouro
            IF vr_flgestou THEN
              -- Gerar a tag do associado
              vr_strbuffer := vr_strbuffer
                           || '<associ>'
                           ||   '<nrdconta>'||gene0002.fn_mask_conta(rw_crapavs.nrdconta)||'</nrdconta>'
                           ||   '<nmprimtl>'||vr_tab_crapass(rw_crapavs.nrdconta).nmprimtl||'</nmprimtl>'
                           ||   '<nmresage>'||vr_tab_crapass(rw_crapavs.nrdconta).nmresage||'</nmresage>'
                           ||   '<dshistor>'||rw_crapavs.cdhistor||vr_tab_tthistor(rw_crapavs.cdhistor).dshistor||'</dshistor>'
                           ||   '<nrdocmto>'||rw_crapavs.nrdocmto||'</nrdocmto>'
                           ||   '<dtintegr>'||to_char(rw_crapavs.dtintegr,'dd/mm/rr')||'</dtintegr>'
                           ||   '<vlhstass>'||to_char(rw_crapavs.vllanmto,'fm999g999g990d00')||'</vlhstass>';
              -- Somente enviar estouro e debito, se maiores que zero
              IF rw_crapavs.vlestdif*-1 > 0 THEN
                vr_strbuffer := vr_strbuffer
                             ||   '<vlestass>'||to_char((rw_crapavs.vlestdif*-1),'fm999g999g990d00')||'</vlestass>';
              END IF;
              IF rw_crapavs.vldebito > 0 THEN
                vr_strbuffer := vr_strbuffer
                             ||   '<vldebass>'||to_char(rw_crapavs.vldebito,'fm999g999g990d00')||'</vldebass>';
              END IF;
              -- Fechar nó histórico
              vr_strbuffer := vr_strbuffer
                           || '</associ>';
              -- Enviar ao CLOB
              gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                     ,pr_texto_completo => vr_xmlbuffer
                                     ,pr_texto_novo     => vr_strbuffer);
              -- Limpar a auxiliar
              vr_strbuffer := null;
            END IF;
          END LOOP;

          -- Efetuar varredura dos históricos
          IF vr_tab_tthistor.COUNT > 0 THEN
            FOR vr_cdhistor IN 1..vr_tab_tthistor.LAST LOOP
              -- Se a posição atual existir e existiu pelo menos um lançamento
              IF vr_tab_tthistor.EXISTS(vr_cdhistor) AND vr_tab_tthistor(vr_cdhistor).vlhistor > 0 THEN
                -- Primeiro buscar a taxa para a empresa do convênio
                IF vr_tab_txhistor.EXISTS(to_char(rw_crapepc.cdempres,'fm00000')||'VLTARIF'||to_char(vr_cdhistor,'fm9000')) THEN
                  -- Usá-la,
                  vr_vltarifa := vr_tab_txhistor(to_char(rw_crapepc.cdempres,'fm00000')||'VLTARIF'||to_char(vr_cdhistor,'fm9000'));
                -- Se não procurar com empresa 00
                ELSIF vr_tab_txhistor.EXISTS('00000VLTARIF'||to_char(vr_cdhistor,'fm9000')) THEN
                  -- Usá-la,
                  vr_vltarifa := vr_tab_txhistor('00000VLTARIF'||to_char(vr_cdhistor,'fm9000'));
                ELSE --> Não há
                  vr_vltarifa := 0;
                END IF;
                -- Montar o registro para o relatório
                vr_strbuffer := vr_strbuffer
                             || '<histor>'
                             ||   '<dshistor>'||vr_cdhistor||vr_tab_tthistor(vr_cdhistor).dshistor||'</dshistor>'
                             ||   '<vlhistor>'||to_char(vr_tab_tthistor(vr_cdhistor).vlhistor,'fm999g999g990d00')||'</vlhistor>'
                             ||   '<qthistor>'||to_char(vr_tab_tthistor(vr_cdhistor).qthistor,'fm999g999g990')||'</qthistor>'
                             ||   '<qtestsau>'||to_char(vr_tab_tthistor(vr_cdhistor).qtestsau,'fm999g999g990')||'</qtestsau>'
                             ||   '<qtdebsau>'||to_char(vr_tab_tthistor(vr_cdhistor).qtdebsau,'fm999g999g990')||'</qtdebsau>'
                             ||   '<vltarifa>'||to_char(vr_vltarifa,'fm999g999g990d00')||'</vltarifa>'
                             ||   '<vlcobrar>'||to_char(vr_tab_tthistor(vr_cdhistor).qtdebsau*vr_vltarifa,'fm999g999g990d00')||'</vlcobrar>'
                             ||   '<vlestsau>'||to_char(vr_tab_tthistor(vr_cdhistor).vlestsau,'fm999g999g990d00')||'</vlestsau>'
                             ||   '<vldebsau>'||to_char(vr_tab_tthistor(vr_cdhistor).vldebsau,'fm999g999g990d00')||'</vldebsau>'
                             || '</histor>';
                -- Enviar ao CLOB
                gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                       ,pr_texto_completo => vr_xmlbuffer
                                       ,pr_texto_novo     => vr_strbuffer);
                -- Limpar a auxiliar
                vr_strbuffer := null;

                -- Verificar controle de convênios
                IF vr_flggerar THEN
                  -- Efetuar busca no controle de convênios
                  OPEN cr_crapctc(pr_nrconven => rw_crapepc.nrconven
                                 ,pr_dtrefere => rw_crapepc.dtrefere
                                 ,pr_cdempres => rw_crapepc.cdempres
                                 ,pr_cdhistor => vr_cdhistor);
                  FETCH cr_crapctc
                   INTO rw_crapctc;
                  -- Se encontrou
                  IF cr_crapctc%FOUND THEN
                    -- Fechar o cursor
                    CLOSE cr_crapctc;
                    -- Comparar os valores
                    IF rw_crapctc.vltarifa <> vr_vltarifa OR rw_crapctc.qtefetua <> vr_tab_tthistor(vr_cdhistor).qtdebsau
                    OR rw_crapctc.vlefetua <> vr_tab_tthistor(vr_cdhistor).vldebsau OR rw_crapctc.qtlanmto <> vr_tab_tthistor(vr_cdhistor).qthistor
                    OR rw_crapctc.vllanmto <> vr_tab_tthistor(vr_cdhistor).vlhistor THEN
                      -- Gerar critica 301
                      vr_cdcritic := 301;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                      -- Escrever no log
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                 || vr_cdprogra || ' --> '
                                                                 || vr_dscritic || ' Convenio ' || to_char(rw_crapepc.nrconven,'fm000')
                                                                 || ' Empresa ' || to_char(rw_crapepc.cdempres,'fm00000'));
                      -- Zerar a critica
                      vr_cdcritic := 0;
                      -- Sair
                      RAISE vr_exc_ignora_conv;
                    END IF;
                  ELSE
                    -- Fechar o cursor
                    CLOSE cr_crapctc;
                    -- Deverá criar o registro
                    BEGIN
                      INSERT INTO crapctc (nrconven
                                          ,dtrefere
                                          ,cdempres
                                          ,cdcooper
                                          ,cdhistor
                                          ,dtresumo
                                          ,qtempres
                                          ,vltarifa
                                          ,qtefetua
                                          ,vlefetua
                                          ,qtlanmto
                                          ,vllanmto
                                          ,qtrejeit
                                          ,vlrejeit)
                                    VALUES(rw_crapepc.nrconven                                                            --nrconven
                                          ,rw_crapepc.dtrefere                                                            --dtrefere
                                          ,rw_crapepc.cdempres                                                            --cdempres
                                          ,pr_cdcooper                                                                    --cdcooper
                                          ,vr_cdhistor                                                                    --cdhistor
                                          ,null                                                                           --dtresumo
                                          ,0                                                                              --qtempres
                                          ,vr_vltarifa                                                                    --vltarifa
                                          ,vr_tab_tthistor(vr_cdhistor).qtdebsau                                          --qtefetua
                                          ,vr_tab_tthistor(vr_cdhistor).vldebsau                                          --vlefetua
                                          ,vr_tab_tthistor(vr_cdhistor).qthistor                                          --qtlanmto
                                          ,vr_tab_tthistor(vr_cdhistor).vlhistor                                          --vllanmto
                                          ,vr_tab_tthistor(vr_cdhistor).qthistor - vr_tab_tthistor(vr_cdhistor).qtdebsau  --qtrejeit
                                          ,vr_tab_tthistor(vr_cdhistor).vlhistor - vr_tab_tthistor(vr_cdhistor).vldebsau);--vlrejeit;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao gerar CRAPCTC, Convenio ' || to_char(rw_crapepc.nrconven,'fm000')
                                    || ' Empresa ' || to_char(rw_crapepc.cdempres,'fm00000')||'. Detalhes: '||sqlerrm;
                        RAISE vr_exc_saida;
                    END;
                  END IF;
                END IF;
              END IF;
            END LOOP;
          END IF;

          -- Ao final da leitura dos avisos, fechar a tag empresa
          vr_strbuffer := '</empresa></crrl153_root>';
          -- Enviar ao CLOB
          gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                 ,pr_texto_completo => vr_xmlbuffer
                                 ,pr_texto_novo     => vr_strbuffer
                                 ,pr_fecha_xml      => true); --> Ultima chamada
          -- Limpar a auxiliar
          vr_strbuffer := null;

          -- Somente se o CLOB contiver informações
          IF dbms_lob.getlength(vr_xml) > 0 THEN
            -- Solicitar o relatório, com chamada a imprim.p e envio por e-mail
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                       ,pr_dsxml     => vr_xml                               --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl153_root/empresa'              --> Nó base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl153.jasper'                     --> Arquivo de layout do iReport
                                       ,pr_dsparams  => null                                 --> Sem parâmetros
                                       ,pr_dsarqsaid => vr_nom_direto||vr_nmarqimp           --> Arquivo final com o path
                                       ,pr_qtcoluna  => 132                                  --> 132 colunas
                                       ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                       ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                       ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                       ,pr_nrcopias  => 1                                    --> Número de cópias
                                       ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                       ,pr_dsmailcop => trim(vr_tab_crapcnv(rw_crapepc.nrconven).dsdemail) --> Email de destino
                                       ,pr_dsassmail => 'FECHAMENTO DOS CONVENIOS'           --> Assunto do e-mail
                                       ,pr_fldosmail => 'S'                                  --> Chama a conversão para DOS antes do envio
                                       ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

          END IF;

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_xml);
          dbms_lob.freetemporary(vr_xml);
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_saida;
          END IF;
        EXCEPTION
          WHEN vr_exc_ignora_conv THEN
            -- Liberando a memória alocada pro CLOB
            -- e continuar ao próximo convênio
            dbms_lob.close(vr_xml);
            dbms_lob.freetemporary(vr_xml);
          WHEN vr_exc_saida THEN
            -- Apenas propaga o erro
            RAISE vr_exc_saida;
        END;
      END LOOP;

      -- Varrer controle dos convênios
      FOR rw_ctc_res IN cr_crapctc_resumo(pr_dtresumo => rw_crapdat.dtmvtolt) LOOP
        -- Inicializar variaveis
        vr_res_vldebint := 0;
        vr_res_qtdebint := 0;
        vr_res_vlreceit := 0;
        vr_res_vltarifa := 0;
        vr_res_qttarifa := 0;
        vr_res_vlrepass := 0;
        vr_res_dstarifa := '';
        -- Inicializar valores integrados
        vr_res_vldebenv := rw_ctc_res.vllanmto;
        vr_res_qtdebenv := rw_ctc_res.qtlanmto;
        vr_res_vldebrej := rw_ctc_res.vlrejeit * -1;
        vr_res_qtdebrej := rw_ctc_res.qtrejeit;
        -- Buscar cadastro do convênio
        IF NOT vr_tab_crapcnv.exists(rw_ctc_res.nrconven) THEN
          -- Gerar critica 563 e parar o processo
          vr_cdcritic := 563;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Escrever no log e parar o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic || to_char(rw_ctc_res.nrconven,'fm00'));
          -- Zerar a critica
          vr_cdcritic := 0;
          -- Sair
          RAISE vr_exc_saida;
        END IF;
        -- Incrementar contador de arquivos
        vr_contaarq := vr_contaarq + 1;
        -- Gerar o nome do relatório
        vr_nmarqimp := '/rl/crrl153_'||to_char(vr_contaarq,'fm00')||'.lst';

        -- Busca do controle dos convênios contidos neste resumo
        FOR rw_ctc_cont IN  cr_crapctc_contido(pr_nrconven => rw_ctc_res.nrconven
                                              ,pr_dtrefere => rw_ctc_res.dtrefere) LOOP
          -- Acumular valores
          vr_res_vldebint := vr_res_vldebint + rw_ctc_cont.vlrejeit;
          vr_res_qtdebint := vr_res_qtdebint + rw_ctc_cont.qtrejeit;
          vr_res_vltarifa := vr_res_vltarifa + rw_ctc_cont.vltarifa_efetua;
          vr_res_qttarifa := vr_res_qttarifa + rw_ctc_cont.qtefetua;
          -- Se não for a primeira passagem
          IF vr_res_dstarifa IS NOT NULL THEN
            -- Adiciona um espaçamento
            vr_res_dstarifa := vr_res_dstarifa || '   +   ';
          END IF;
          -- Adicionar a tarifa aplicada
          vr_res_dstarifa := vr_res_dstarifa || to_char(vr_res_qttarifa,'fm999g990')
                                             || ' X '
                                             || to_char(rw_ctc_cont.vltarifa,'fm90d00');
        END LOOP;

        -- Gerar valores absolutos
        vr_res_vldebint := vr_res_vldebint * -1;
        vr_res_vltarifa := vr_res_vltarifa * -1;
        vr_res_vlreceit := vr_res_vldebenv + vr_res_vldebrej + vr_res_vldebint;
        vr_res_vlrepass := vr_res_vlreceit + vr_res_vltarifa;

        -- Abrir o CLOB do relatório
        dbms_lob.createtemporary(vr_xml, TRUE);
        dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
        vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><crrl153_root>';
        -- Enviar as informações
        vr_strbuffer := vr_strbuffer
                     || '<resumo>'
                     ||   '<nrconven>'||to_char(rw_ctc_res.nrconven,'fm000')||'</nrconven>'
                     ||   '<dsconven>'||vr_tab_crapcnv(rw_ctc_res.nrconven).dsconven||'</dsconven>'
                     ||   '<res_vldebenv>'||to_char(vr_res_vldebenv,'fm999g999g990d00')||'</res_vldebenv>'
                     ||   '<res_qtdebenv>'||to_char(vr_res_qtdebenv,'fm999g999g990')||'</res_qtdebenv>'
                     ||   '<res_vldebrej>'||to_char(vr_res_vldebrej,'fm999g999g990d00')||'</res_vldebrej>'
                     ||   '<res_qtdebrej>'||to_char(vr_res_qtdebrej,'fm999g999g990')||'</res_qtdebrej>'
                     ||   '<res_vldebint>'||to_char(vr_res_vldebint,'fm999g999g990d00')||'</res_vldebint>'
                     ||   '<res_qtdebint>'||to_char(vr_res_qtdebint,'fm999g999g990')||'</res_qtdebint>'
                     ||   '<res_vlreceit>'||to_char(vr_res_vlreceit,'fm999g999g990d00')||'</res_vlreceit>'
                     ||   '<res_vltarifa>'||to_char(vr_res_vltarifa,'fm999g999g990d00')||'</res_vltarifa>'
                     ||   '<res_vlrepass>'||to_char(vr_res_vlrepass,'fm999g999g990d00')||'</res_vlrepass>'
                     ||   '<res_dstarifa>'||vr_res_dstarifa||'</res_dstarifa>'
                     || '</resumo>';
        -- Encerrar o XML
        vr_strbuffer := vr_strbuffer || '</crrl153_root>';
        -- Enviar ao CLOB
        gene0002.pc_escreve_xml(pr_xml            => vr_xml
                               ,pr_texto_completo => vr_xmlbuffer
                               ,pr_texto_novo     => vr_strbuffer
                               ,pr_fecha_xml      => true);
        -- Limpar a auxiliar
        vr_strbuffer := null;

        -- Somente se o CLOB contiver informações
        IF dbms_lob.getlength(vr_xml) > 0 THEN
          -- Solicitar o relatório, com chamada a imprim.p e envio por e-mail
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_xml                               --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl153_root/resumo'               --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl153_resumo.jasper'              --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||vr_nmarqimp           --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_dsmailcop => trim(vr_tab_crapcnv(rw_ctc_res.nrconven).dsdemail) --> Email de destino
                                     ,pr_dsassmail => 'FECHAMENTO DOS CONVENIOS'           --> Assunto do e-mail
                                     ,pr_fldosmail => 'S'                                  --> Chama a conversão para DOS antes do envio
                                     ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_xml);
        dbms_lob.freetemporary(vr_xml);
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;
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

  END pc_crps214;
/
