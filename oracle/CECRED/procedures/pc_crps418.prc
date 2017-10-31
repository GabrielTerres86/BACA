CREATE OR REPLACE PROCEDURE CECRED.pc_crps418(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crpsMod (Fontes/crps418.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Mirtes
       Data    : Novembro/2004                     Ultima atualizacao: 31/10/2017

       Frequencia: Semanal.
       Objetivo  : Gerar relatorio 378 - Restricoes Analise Borderos
                   Sol.70.

       Alteracoes: 02/12/2004 - Alterado para imprimir 3 vias para a VIACREDI
                                (Edson).

                   02/02/2005 - Alterado para imprimir frente e verso marginado
                                conforme solicitacao do Adelino (Edson).

                   19/07/2005 - Aumentado campo numero cpf/cgc(Mirtes).

                   02/08/2005 - Critica de CPF no SPC(Mirtes)

                   17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   30/05/2006 - Alterado numero de vias do relatorio crrl378
                                para Viacredi (Elton).

                   26/01/2007 - Alterado formato dos campos do tipo DATE de
                                "99/99/99" para "99/99/9999" (Elton).

                   16/08/2013 - Nova forma de chamar as agencias, de PAC agora
                                a escrita será PA (André Euzébio - Supero).

                   13/12/2013 - Alterado valor da variavel aux_linha1 de "CPF/CGC"
                                para "CPF/CNPJ" e ajustado posicionamento do form
                                f_cab. (Reinert).

                   21/05/2014 - Conversão Progress >> Oracle (Petter - Supero).

                   02/12/2014 - Ajustes referente a correção de validação de
                                mensagens de limites de valores dos cheques (Dionathan)

                   05/12/2014 - Correção na lógica de busca da data quando maior que terça
                                conforme solicitação do Daniel Z. (Marcos-Supero)
                                
                   21/08/2017 - #723707 Troca de cláusula "dsrestri like" por "cdocorre in"
                                no cursor cr_crapabc (Carlos)

                   31/10/2017 - Incluso tratativa para verificar se existe valor antes de
				                assumir registro. Erro apresentado no processo batch (Daniel)

    ............................................................................ */

    DECLARE

      ----------------------------- PL TABLES ----------------------------------
      -- PL Table para armazenar registros do relatório
      TYPE typ_reg_movtos IS
        RECORD(nrdconta  crapass.nrdconta%TYPE
              ,nmprimtl  crapass.nmprimtl%TYPE
              ,nrborder  crapbdc.nrborder%TYPE
              ,vllimite  craplim.vllimite%TYPE
              ,percentu  NUMBER(10, 2)
              ,cdagenci  crapass.cdagenci%TYPE
              ,dtlibbdc  crapbdc.dtlibbdc%TYPE
              ,insitbdc  crapbdc.insitbdc%TYPE
              ,vltotcdb  NUMBER(20, 2)
              ,nrcpfcgc  crapabc.nrcpfcgc%TYPE
              ,nrcpfcgca crapabc.nrcpfcgc%TYPE
              ,qtdevchq  PLS_INTEGER
              ,dsrestri  VARCHAR2(400)
              ,dsrestria VARCHAR2(400)
              ,vlutlcpf  NUMBER(20, 2));
      TYPE typ_tab_movtos IS
        TABLE OF typ_reg_movtos
          INDEX BY VARCHAR2(800);

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS418';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variáveis da rotina
      vr_dtmvtaux     DATE;
      vr_percentu     NUMBER(20,2);
      vr_vlutlcpf     NUMBER(20,2);
      vr_dscpfcgc     VARCHAR2(400);
      vr_tab_movtos   typ_tab_movtos;
      vr_idxmovto     VARCHAR2(800);
      vr_xml          CLOB;
      vr_xmlbuffer    VARCHAR2(32767);
      vr_strbuffer    VARCHAR2(32767);
      vr_stsnrcal     BOOLEAN;
      vr_inpessoa     PLS_INTEGER;
      vr_textodesc    VARCHAR2(4000);
      vr_nom_dir      VARCHAR2(4000);
      vr_nmarqimp     VARCHAR2(400);

      ------------------------------- CURSORES ---------------------------------
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS   --> Código da cooperativa
        SELECT cop.nmrescop
              ,cop.nmextcop
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      /* Procedure para gerar movimentos */
      PROCEDURE pc_gera_movtos_pesquisa(pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código da cooperativa
                                       ,pr_dtmvtaux IN crapdat.dtmvtolt%TYPE       --> Data do movimento realinhada
                                       ,pr_crapdat  IN btch0001.cr_crapdat%ROWTYPE --> Cursor com parametros da cooperativa
                                       ,pr_movtos   OUT NOCOPY typ_tab_movtos      --> PL Table de movimentos
                                       ,pr_des_erro OUT VARCHAR2) IS               --> Descrição do erro
      BEGIN
        DECLARE

          -- Estrutura para armazenar valores de contrato excedido por conta
          TYPE typ_tab_ctatoex IS
            TABLE OF crapcdb.vlcheque%TYPE
              INDEX BY VARCHAR2(10); --> Conta
          vr_tab_ctatoex typ_tab_ctatoex;

          -- Estrutura para armazenar quantidade de cheques
          TYPE typ_tab_qtchqdev IS
            TABLE OF crapcec.qtchqdev%TYPE
              INDEX BY VARCHAR2(25); --> CPF/CNPJ
          vr_tab_qtchqdev typ_tab_qtchqdev;

          -- Estrutura dos valores de cheque por bordero, conta e cpf/cnpj
          TYPE typ_tab_vlcheque IS
            TABLE OF crapcdb.vlcheque%TYPE
              INDEX BY VARCHAR2(100); --> Bordero + Conta + CPF/CNPJ
          vr_tab_vlcheque typ_tab_vlcheque;


          -- Busca dados valores maximos por contrato excedido
          CURSOR cr_ctatoex IS --> Código da cooperativa
            SELECT cdb.nrdconta
                  ,SUM(cdb.vlcheque) vlcheque
            FROM crapcdb cdb
            WHERE cdb.cdcooper = pr_cdcooper
              AND cdb.insitchq = 2
              and cdb.dtlibera > pr_dtmvtaux
            GROUP BY cdb.nrdconta;

          -- Busca das quantidades de cheque por cpf/cnpj
          CURSOR cr_qtchqdev IS --> Código da cooperativa
            SELECT cec.nrcpfcgc
                  ,SUM(cec.qtchqdev) qtchqdev
              FROM crapcec cec
             WHERE cec.cdcooper = pr_cdcooper
             GROUP BY cec.nrcpfcgc
             ORDER BY cec.nrcpfcgc;

          -- Busca dados dos cheques contidos no bordero de cheques sem data de devolução
          CURSOR cr_vlcheque IS --> Código da cooperativa
            SELECT cdb.nrborder
                  ,cdb.nrdconta
                  ,cdb.nrcpfcgc
                  ,SUM(cdb.vlcheque) vlcheque
            FROM crapcdb cdb
            WHERE cdb.cdcooper = pr_cdcooper
              AND cdb.dtdevolu IS NULL
            GROUP BY cdb.nrborder
                    ,cdb.nrdconta
                    ,cdb.nrcpfcgc;

          -- Busca dados da analise de restrições do bordero de cheques
          CURSOR cr_crapabc(pr_nrborder IN crapabc.nrborder%TYPE       --> Número do borderô
                           ,pr_nrdconta IN crapabc.nrdconta%TYPE) IS   --> Número da conta
            SELECT abc.nrborder
                  ,abc.nrdconta
                  ,abc.nrcpfcgc
                  ,NVL(LAG(abc.nrcpfcgc) OVER(ORDER BY abc.nrcpfcgc), 0) nrcpfcgca
                  ,NVL(LAG(abc.dsrestri) OVER (ORDER BY abc.dsrestri), ' ') dsrestria
                  ,abc.dsrestri
            FROM crapabc abc
            WHERE abc.cdcooper = pr_cdcooper
              AND abc.nrborder = pr_nrborder
              AND abc.nrdconta = pr_nrdconta
              AND abc.nrcpfcgc > 0
              AND abc.cdocorre IN (1,2,3,6,7)
            ORDER BY abc.nrcpfcgc;
          -- Busca dados dos borderos de descontos de cheque por associado e limite de crédito
          CURSOR cr_crapbdclim IS
            SELECT bdc.nrdconta
                  ,bdc.dtlibbdc
                  ,bdc.nrborder
                  ,bdc.insitbdc
                  ,ass.cdagenci
                  ,ass.nmprimtl
                  ,lim.vllimite
            FROM crapbdc bdc, crapass ass, craplim lim
            WHERE bdc.cdcooper  = pr_cdcooper
              AND bdc.dtlibbdc IS NOT NULL
              AND bdc.dtlibbdc >= pr_dtmvtaux
              AND bdc.dtlibbdc <  pr_crapdat.dtmvtolt
              AND ass.cdcooper  = bdc.cdcooper
              AND ass.nrdconta  = bdc.nrdconta
              AND lim.cdcooper  = bdc.cdcooper
              AND lim.nrdconta  = ass.nrdconta
              AND lim.nrctrlim  = bdc.nrctrlim
              AND lim.tpctrlim  = 2  --> Desconto Cheque
              AND lim.insitlim  = 2; --> Ativo

          -- Variáveis para índices e controles das PL Table
          vr_idxcdb     VARCHAR2(100);
          vr_index      VARCHAR2(800);

          -- Variáveis da regra de negócio
          vr_qtdevchq   PLS_INTEGER := 0;

        BEGIN

          -- Armazenar valores de contrato excedido por conta
          FOR rw_ctatoex IN cr_ctatoex LOOP
            vr_tab_ctatoex(rw_ctatoex.nrdconta) := rw_ctatoex.vlcheque;
          END LOOP;

          -- Armazenar quantidade de cheques por CPF/CNPJ
          FOR rw_qtchqdev IN cr_qtchqdev LOOP
            vr_tab_qtchqdev(rw_qtchqdev.nrcpfcgc) := rw_qtchqdev.qtchqdev;
          END LOOP;

          -- Carregar PL Table da tabela CRAPCDB sem devolução
          FOR rw_vlcheque IN cr_vlcheque LOOP
            vr_tab_vlcheque(LPAD(rw_vlcheque.nrborder,10,'0')||LPAD(rw_vlcheque.nrdconta,25,'0')||LPAD(rw_vlcheque.nrcpfcgc, 25,'0')) := rw_vlcheque.vlcheque;
          END LOOP;

          -- Buscar borderos de descontos de cheque por associado limitado por crédito
          FOR rw_bordero IN cr_crapbdclim LOOP
            -- Buscar a análise de restrição por borderô de cheques
            FOR rw_restri IN cr_crapabc(rw_bordero.nrborder, rw_bordero.nrdconta) LOOP
              -- Verifica se é a primeira ocorrência do CNPJ/CPF
              IF rw_restri.nrcpfcgc <> rw_restri.nrcpfcgca THEN
                -- Limpar variável para nova sumarização
                vr_vlutlcpf := 0;
                -- Montar índice da PL Table para borderos sem devolução de cheques
                vr_idxcdb := LPAD(rw_bordero.nrborder, 10, '0') || LPAD(rw_bordero.nrdconta, 25, '0') || LPAD(rw_restri.nrcpfcgc, 25, '0');
                -- Verifica se existe registro
                IF vr_tab_vlcheque.exists(vr_idxcdb) THEN
                  -- Buscar valor
                  vr_vlutlcpf := vr_tab_vlcheque(vr_idxcdb);
                END IF;

				-- Sumarizar quantidade de cheques
				IF vr_tab_qtchqdev.exists(rw_restri.nrcpfcgc) THEN
                  -- Buscar valor
                  vr_qtdevchq := vr_tab_qtchqdev(rw_restri.nrcpfcgc);
                ELSE
				  vr_qtdevchq := 0;  
                END IF;

              END IF;

              -- Gravar registro de movimento
              vr_index := LPAD(rw_bordero.cdagenci, 3, '0')
                       || TO_CHAR(rw_bordero.dtlibbdc, 'RRRRMMDD')
                       || LPAD(rw_bordero.nrdconta, 20, '0')
                       || LPAD(rw_bordero.nrborder, 10, '0')
                       || LPAD(rw_restri.nrcpfcgc, 30, '0')
                       || rw_restri.dsrestri;

                -- Calcular percentual
                vr_percentu := ((NVL(vr_vlutlcpf, 0) / rw_bordero.vllimite) * 100);

                -- Criar o registro
                pr_movtos(vr_index).nrdconta  := rw_bordero.nrdconta;
                pr_movtos(vr_index).nmprimtl  := rw_bordero.nmprimtl;
                pr_movtos(vr_index).nrborder  := rw_bordero.nrborder;
                pr_movtos(vr_index).vllimite  := rw_bordero.vllimite;
                pr_movtos(vr_index).cdagenci  := rw_bordero.cdagenci;
                pr_movtos(vr_index).dtlibbdc  := rw_bordero.dtlibbdc;
                pr_movtos(vr_index).insitbdc  := rw_bordero.insitbdc;
                pr_movtos(vr_index).nrcpfcgc  := rw_restri.nrcpfcgc;
                pr_movtos(vr_index).nrcpfcgca := rw_restri.nrcpfcgca;
                pr_movtos(vr_index).dsrestri  := rw_restri.dsrestri;
                pr_movtos(vr_index).dsrestria := rw_restri.dsrestria;

                pr_movtos(vr_index).qtdevchq  := vr_qtdevchq;
                pr_movtos(vr_index).percentu  := vr_percentu;
                pr_movtos(vr_index).vlutlcpf  := vr_vlutlcpf;
                pr_movtos(vr_index).vltotcdb  := CASE
                                                   WHEN vr_tab_ctatoex.exists(rw_bordero.nrdconta) THEN
                                                       vr_tab_ctatoex(rw_bordero.nrdconta)
                                                   ELSE
                                                       0
                                                 END;
            END LOOP;
          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            pr_des_erro := 'Erro em PC_GERA_MOVTOS_PESQUISA: ' || SQLERRM;
        END;
      END pc_gera_movtos_pesquisa;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

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
      -- Nome do arquivo
      vr_nmarqimp := 'crrl378.lst';

      -- Capturar o path do arquivo
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');

      -- Realianhar a data de movimento
      vr_dtmvtaux := rw_crapdat.dtmvtolt - 7;

      -- Diminuir ainda mais um dia caso terça a sábado
      WHILE TO_CHAR(vr_dtmvtaux, 'd') > 2 LOOP
        vr_dtmvtaux := vr_dtmvtaux - 1;
      END LOOP;

      -- Gerar movimentos
      pc_gera_movtos_pesquisa(pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtaux => vr_dtmvtaux
                             ,pr_crapdat  => rw_crapdat
                             ,pr_movtos   => vr_tab_movtos
                             ,pr_des_erro => vr_cdcritic);

      -- Verifica se ocorreram erros
      IF vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_fimprg;
      END IF;

      -- Gerar dados para relatório
      vr_idxmovto := vr_tab_movtos.first;

      -- Inicializar CLOB
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
      vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><base>';

      -- Enviar ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xmlbuffer
                             ,pr_texto_novo     => vr_strbuffer);
      -- Limpar a auxiliar
      vr_strbuffer := null;

      -- Iterar sobre os resultados
      LOOP
        EXIT WHEN vr_idxmovto IS NULL;

        -- Verifica se é o primeiro lote dos registros
        IF vr_tab_movtos.prior(vr_idxmovto) IS NULL OR
           vr_tab_movtos(vr_idxmovto).cdagenci <> vr_tab_movtos(vr_tab_movtos.prior(vr_idxmovto)).cdagenci OR
           vr_tab_movtos(vr_idxmovto).dtlibbdc <> vr_tab_movtos(vr_tab_movtos.prior(vr_idxmovto)).dtlibbdc OR
           vr_tab_movtos(vr_idxmovto).nrdconta <> vr_tab_movtos(vr_tab_movtos.prior(vr_idxmovto)).nrdconta OR
           vr_tab_movtos(vr_idxmovto).nrborder <> vr_tab_movtos(vr_tab_movtos.prior(vr_idxmovto)).nrborder THEN
          -- Fechar TAG do aninhamento do registro
          IF vr_tab_movtos.prior(vr_idxmovto) IS NOT NULL THEN
            vr_strbuffer := vr_strbuffer || '</dividas>';
            vr_strbuffer := vr_strbuffer || '</reg>';
          END IF;

          -- Abrir TAG para aninhamento do registro
          vr_strbuffer := vr_strbuffer || '<reg>';

          -- Gerar dados para o relatório
          vr_strbuffer := vr_strbuffer || '<cab><cdagenci>' || vr_tab_movtos(vr_idxmovto).cdagenci || '</cdagenci>';
          vr_strbuffer := vr_strbuffer || '<dtlibbdc>' || TO_CHAR(vr_tab_movtos(vr_idxmovto).dtlibbdc, 'DD/MM/RRRR') || '</dtlibbdc>';
          vr_strbuffer := vr_strbuffer || '<nrdconta>' || TO_CHAR(vr_tab_movtos(vr_idxmovto).nrdconta, 'FM9999G999G9') || '</nrdconta>';
          vr_strbuffer := vr_strbuffer || '<nmprimtl>' || vr_tab_movtos(vr_idxmovto).nmprimtl || '</nmprimtl>';
          vr_strbuffer := vr_strbuffer || '<nrborder>' || vr_tab_movtos(vr_idxmovto).nrborder || '</nrborder>';
          vr_strbuffer := vr_strbuffer || '<vllimite>' || TO_CHAR(vr_tab_movtos(vr_idxmovto).vllimite, 'FM999G999G999G990D00') || '</vllimite></cab>';
          -- Abrir TAG para nodo filho
          vr_strbuffer := vr_strbuffer || '<dividas>';
          -- Enviar ao XML
          gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                 ,pr_texto_completo => vr_xmlbuffer
                                 ,pr_texto_novo     => vr_strbuffer);

          -- Limpar a auxiliar
          vr_strbuffer := null;
        END IF;

        -- Verifica se é o primeiro do lote de registros
        IF (vr_tab_movtos.prior(vr_idxmovto) IS NULL OR
            vr_tab_movtos(vr_idxmovto).nrcpfcgc <> vr_tab_movtos(vr_tab_movtos.prior(vr_idxmovto)).nrcpfcgc OR
            vr_tab_movtos(vr_idxmovto).dsrestri <> vr_tab_movtos(vr_tab_movtos.prior(vr_idxmovto)).dsrestri)  OR
           vr_tab_movtos(vr_idxmovto).nrcpfcgc <> vr_tab_movtos(vr_idxmovto).nrcpfcgca OR
           vr_tab_movtos(vr_idxmovto).dsrestri <> vr_tab_movtos(vr_idxmovto).dsrestria THEN
          -- Validar o tipo de descritivo da restrição
          IF vr_tab_movtos(vr_idxmovto).dsrestri LIKE 'Perc%' THEN
            vr_textodesc := 'Percentual de cheques do emitente excedido Vlr. ' ||
                                                   TO_CHAR(vr_tab_movtos(vr_idxmovto).vlutlcpf, 'FM999G999G999G990D00') ||
                                                   ' Perc. ' || TO_CHAR(vr_tab_movtos(vr_idxmovto).percentu, 'FM990D00');
          ELSIF vr_tab_movtos(vr_idxmovto).dsrestri LIKE 'Quan%' THEN
            vr_textodesc := 'Quantidade cheques devol. excedido Vlr. ' ||
                                                   TO_CHAR(vr_tab_movtos(vr_idxmovto).vlutlcpf, 'FM999G999G999G990D00') ||
                                                   ' Qtd. ' || TO_CHAR(vr_tab_movtos(vr_idxmovto).qtdevchq, 'FM9990');
          ELSIF vr_tab_movtos(vr_idxmovto).dsrestri LIKE 'Valor maximo por contrato excedido.%' THEN
            vr_textodesc := vr_tab_movtos(vr_idxmovto).dsrestri || ' Vlr. ' ||
                                                   TO_CHAR(vr_tab_movtos(vr_idxmovto).vltotcdb, 'FM999G999G999G990D00');
          ELSIF vr_tab_movtos(vr_idxmovto).dsrestri LIKE 'Valor maximo por emitente excedido%' THEN
            vr_textodesc := vr_tab_movtos(vr_idxmovto).dsrestri || ' Vlr. ' ||
                                                   TO_CHAR(vr_tab_movtos(vr_idxmovto).vlutlcpf, 'FM999G999G999G990D00');
          ELSE
            vr_textodesc := vr_tab_movtos(vr_idxmovto).dsrestri;
          END IF;

           -- Validar formato do CPF/CNPJ
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_tab_movtos(vr_idxmovto).nrcpfcgc
                                     ,pr_stsnrcal => vr_stsnrcal
                                     ,pr_inpessoa => vr_inpessoa);

          -- Formatar numero conformetipo da pessoa
          vr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_movtos(vr_idxmovto).nrcpfcgc
                                                  ,pr_inpessoa => vr_inpessoa);

          -- Gerar nodos filhos
          vr_strbuffer := vr_strbuffer || '<divida><cpfcnpj>' || vr_dscpfcgc || '</cpfcnpj>';
          vr_strbuffer := vr_strbuffer || '<ordem>' || SUBSTR(vr_textodesc, 0, 5) || '</ordem>';
          vr_strbuffer := vr_strbuffer || '<dsrestri>' || vr_textodesc || '</dsrestri></divida>';

          -- Enviar ao XML
          gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                 ,pr_texto_completo => vr_xmlbuffer
                                 ,pr_texto_novo     => vr_strbuffer);

          -- Limpar a auxiliar
          vr_strbuffer := null;

        END IF;

        -- Em caso do ultimo registro
        IF vr_idxmovto = vr_tab_movtos.last THEN
          vr_strbuffer := vr_strbuffer || '</dividas>';
          vr_strbuffer := vr_strbuffer || '</reg>';

          -- Enviar ao XML
          gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                 ,pr_texto_completo => vr_xmlbuffer
                                 ,pr_texto_novo     => vr_strbuffer);

          -- Limpar a auxiliar
          vr_strbuffer := null;

        END IF;

        -- Buscar próximo índice
        vr_idxmovto := vr_tab_movtos.next(vr_idxmovto);
      END LOOP;

      -- Finalizar XML
      vr_strbuffer := '</base>';
      -- Enviar ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xmlbuffer
                             ,pr_texto_novo     => vr_strbuffer
                             ,pr_fecha_xml      => true);

      -- Gerar relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_xml
                                 ,pr_dsxmlnode => '/base/reg'
                                 ,pr_dsjasper  => 'crrl378.jasper'
                                 ,pr_dsparams  => NULL
                                 ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarqimp
                                 ,pr_flg_gerar => 'N'
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_cdrelato  => NULL
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => '132dm'
                                 ,pr_nrcopias  => 1
                                 ,pr_dspathcop => NULL
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_flsemqueb => 'N'
                                 ,pr_des_erro  => pr_dscritic);

      -- Remover CLOB da memória
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);

      -- Verifica se ocorreram erros ao gerar o relatório
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

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
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );

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
        pr_dscritic := SQLERRM;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps418;
/
