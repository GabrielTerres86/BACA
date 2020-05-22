CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS279_carlos (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps279 (Fontes/crps279.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah
       Data    : Janeiro/2000                      Ultima atualizacao: 17/04/2018

       Dados referentes ao programa:

       Frequencia: Mensal (Batch - Background).
       Objetivo  : Atende a solicitacao 004.
                   Emite: Controle de seguros prestamistas (226).

       Alteracoes: 05/05/2000 - Classificar por inmatric descending para que na
                                leitura as contas originais fiquem sempre depois
                                das contas duplicadas (Deborah).

                   21/09/2000 - Campos da tabela:
                                valor minimo para emissao de proposta
                                valor maximo de cobertura
                                valor minimo de cobertura
                                data de inicio da cobertura
                                Ajustes para esses campos (Deborah).

                   06/02/2001 - Alterado para enviar o arquivo por e-mail (Edson).

                   02/05/2001 - Alterado para tirar os parenteses da mensagem
                                (Deborah).

                   03/12/2001 - Incluir valor total (Margarete).

                   04/02/2002 - Padronizar o indice gravado na tabela (Ze Eduardo).

                   07/05/2002 - Calcular e mostrar o percentual de pagto para a
                                seguradora (Edson).

                   19/09/2002 - Alterado para enviar arquivo de seguro de vida
                                automaticamente          (Junior).

                   22/11/2002 - Colocar "&" no final do comando MTSEND (Junior).

                   04/04/2003 - Imprimir o relatorio somente para as cooperativas
                                que possuir seguros (Ze Eduardo).

                   31/03/2004 - Enviar email para ADD-MAKLER somente quando a
                                cooperativa for VIACREDI ou CREDITEXTIL (Edson).

                   31/03/2004 - Corrigir valor PAGTO SEGURADORA se estiver zerado
                                (Julio)

                   04/10/2004 - Alterado destino do email para
                                janeide.bnu@addmakler.com.br (Edson).

                   03/11/2004 - Enviar, tambem, email para a VIACREDI (Edson).

                   23/03/2005 - Incluir o campo craptsg.cdsegura na leitura da
                                tabela craptsg (Edson).

                   01/09/2005 - Alterado destino do email para
                                elisangela.bnu@addmakler.com.br (Edson).

                   21/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   23/01/2006 - Efetuado acerto - Data seguro(Mirtes)

                   26/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).

                   12/04/2007 - Retirar rotina de email em comentario (David).

                   01/06/2007 - Aumentado de 6 para 7 digitos o 'nrctremp'
                                (Guilherme).

                   13/08/2007 - Incluido envio do relatorio 226 para os emails:
                                fernandabrizola.bnu@addmakler.com.br
                                rene.bnu@addmakler.com.br
                                susan.bnu@addmakler.com.br
                              - Incluido "Vct ctrato" crrl226  (Guilherme).

                   12/09/2007 - Incluido envio e-mail para graziele@viacredi.coop.br
                                (Guilherme).

                   05/11/2007 - Layout do arquivo modificado para que as 145
                                colunas sejam impressas (Gabriel).

                   07/12/2007 - Cooperativa Creditextil, enviar  o e-mail para
                                ivanildo@sorellaseguros.com.br (Gabriel)

                   18/09/2008 - Enviar e-mail para patrimonio@viacredi.coop.br
                                (Gabriel).

                   4/11/2008  - Enviar rel226 para ariana@viacredi.coop.br(Gabriel).

                   14/11/2008 - Listar seguros prestamistas a partir da data
                                de contratacao deste servico pela cooperativa
                               (Diego).

                   28/01/2009 - Enviar email somente para aylloscecred@addmakler
                                .com.br (Gabriel)

                   10/06/2009 - Incluido resumo por PAC do saldo devedor e
                                encaminhado e_mail para as cooperativas(Fernando).

                   01/12/2010 - Alteracao de Format (Kbase/Willian).
                                001 - Alterado para 50 posições, valor anterior 40.

                   04/01/2011 - Alterado o envio de e-mail do rel226 de
                                ivanildo@sorellaseguros.com.br para
                                aylloscecred@addmakler.com.br (Adriano).

                   05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)

                   13/02/2012 - Substituído o email ariana@viacredi.coop.br
                                por fernanda.devitz@viacredi.coop.br (Lucas)

                   07/01/2013 - Desprezada as linhas de credito 800 e 900 da
                                leitura da tabela de emprestimos (crapepr).
                                (Daniele)

                   01/02/2013 - Incluir parametros de programa pararelo (David).

                   05/03/2013 - Alterado posicao de  NOME, NASCIMENTO e PAC para
                                aparecer ao lado da conta no frame f_emprestimos
                                Tarefa - 47606 (Lucas R).

                   08/03/2013 - Substituido e-mail jeicy@cecred.coop.br por
                                cecredseguros@cecred.coop.br (Diego).

                   27/07/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   17/10/2013 - Alterado para não gerar os relatorios e enviar os email na hora
                                apenas realizar a solicitação e deixar par o job gerar e enviar.
                                (Marcos-Supero)

                   18/11/2013 - Ajuste de formato na data dtsgprst para ano com
                                04 digitos (Gabriel).

                   22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                                ser acionada em caso de saída para continuação da cadeia,
                                e não em caso de problemas na execução (Marcos-Supero)

                   28/11/2013 - Ajustes nas variaveis tratadas durante a iniprg (Marcos-Supero)

                   09/01/2014 - Remoção de chamada duplicada a geração de relatorio
                                ja que agora é possivel passar qual a extensão da
                                copia ou e-mail, e ainda não, o que gerava a necessidade
                                de duas chamadas (Marcos-Supero)
                                
                   06/05/2014 - Ajustes para utilizar o vr_vlsdeved no totalizador por PA,
                               pois neste é validado o valor maximo e minimo (Odirlei-Amcom)

                   01/07/2014 - Ajustar os totalizadores do PA que estavam apresentando 
                                divergencia com relação ao total geral (Douglas - Chamado 153718)
                                
                   21/01/2015 - Alterado o formato do campo nrctremp para 8 
                                caracters (Kelvin - 233714)                                

                   27/04/2015 - Adicionar no cr_crapepr as linhas de crédito 
                                6901,6902,6903,6904,6905 para que elas não sejam listadas.
                                (Chamado 276392 - Douglas)
                                
                   27/05/2015 - Ajuste para verificar se o emprestimo lista no relatorio (James)

                   04/01/2017 - P342 - Incorporação Transulcred -> Transpocred (Ricardo Linhares)

                   20/02/2017 - Ajuste na query do cursor cr_crapepr, este está retornando registros
                                desordenado e duplicado. (Chamado 615774 - Rafael Monteiro)

                   17/04/2018 - Retirar o <= da validacao de idade do seguro prestamista
                                (Lucas Ranghetti #INC0012820)

                   17/10/2018 - Liberacao primeiro pacote Projeto 421 - Melhorias nas
                                ferramentas contabeis e fiscais.
                                Heitor / Alcemir (Mouts)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS279';

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

      -- Selecionar informacoes da solicitação
      CURSOR cr_crapsol IS
        SELECT sol.nrdevias
          FROM crapsol sol
              ,crapprg prg
         WHERE prg.cdcooper = sol.cdcooper
           AND prg.nrsolici = sol.nrsolici
           AND prg.cdcooper = pr_cdcooper
           AND prg.cdprogra = vr_cdprogra
           AND sol.insitsol = 1; -- Ativa
      vr_nrdevias crapsol.nrdevias%TYPE;

      -- Busca da idade limite
      CURSOR cr_craptsg IS
        SELECT nrtabela
          FROM craptsg
         WHERE cdcooper = pr_cdcooper
           AND tpseguro = 4
           AND tpplaseg = 1
           AND cdsegura = 5011; -- SEGURADORA CHUBB

      -- Buscar todos os seguros prestamista ativos
      CURSOR cr_crapseg IS
        SELECT nrdconta
              ,dtmvtolt
          FROM crapseg
         WHERE cdcooper = pr_cdcooper
           AND tpseguro = 4  --> Prestamista
           AND cdsitseg = 1; --> Ativa

      -- Busca das informações de proposta de empréstimos
      CURSOR cr_crawepr(pr_nrdconta crawepr.nrdconta%TYPE,
                        pr_nrctremp crawepr.nrctremp%TYPE) IS
        SELECT dtdpagto
              ,qtpreemp
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Leitura dos associados e seus empréstimos em aberto
      CURSOR cr_crapepr(pr_tab_dtiniseg DATE) IS
          select a.nrcpfcgc
                ,a.inmatric
                ,a.nrdconta
                ,a.nmprimtl
                ,a.cdagenci
                ,a.dtnasctl
                ,a.nrctremp
                ,a.vlsdeved
                ,a.dtmvtolt
                ,ROW_NUMBER () OVER (PARTITION BY a.nrcpfcgc
                                         ORDER BY a.nrcpfcgc
                                                 ,a.inmatric DESC
                                                 ,a.nrdconta) sqregcpf
                ,COUNT (*) OVER (PARTITION BY a.nrcpfcgc)     qtregcpf
            from ( SELECT ass.nrcpfcgc
                          ,ass.inmatric
              ,ass.nrdconta
              ,ass.nmprimtl
              ,ass.cdagenci
              ,ass.dtnasctl
              ,epr.nrctremp
              ,epr.vlsdeved
              ,epr.dtmvtolt
          FROM crapepr epr
              ,crapass ass
              ,craplcr lcr
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.inpessoa = 1 --> Somente fisica
           AND ass.cdcooper = epr.cdcooper
           AND ass.nrdconta = epr.nrdconta
           AND epr.dtmvtolt >= pr_tab_dtiniseg --to_date('31/01/2000','dd/mm/rrrr') 
                                                                  AND epr.dtmvtolt <= to_date('28/02/2020','dd/mm/rrrr') -- regra para faturar até o final de fev/2020
           AND epr.inliquid  = 0     --> Em aberto
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp
           AND lcr.flgsegpr = 1
                    UNION
                    SELECT ass.nrcpfcgc 
                          ,ass.inmatric
                          ,ass.nrdconta
                          ,ass.nmprimtl
                          ,ass.cdagenci
                          ,ass.dtnasctl
                          ,epr.nrctremp
                          ,epr.vlsdeved
                          ,epr.dtmvtolt
                           FROM crapepr epr
                              ,crapass ass
                              ,craplcr lcr
                          WHERE ass.cdcooper = 9 -->cooperativa 9
                            AND ass.inpessoa = 1 --> Somente fisica
                            AND ass.cdcooper = epr.cdcooper
                            AND ass.nrdconta = epr.nrdconta
                            AND epr.dtmvtolt < '01/01/2017' --> todos os registros antes do dia primeiro
                            AND epr.inliquid = 0 --> Em aberto
                            AND lcr.cdcooper = epr.cdcooper
                            AND lcr.cdlcremp = epr.cdlcremp
                            AND lcr.flgsegpr = 1
                            AND ass.nrdconta BETWEEN 900001 and 912654 --> somente as contas que foram incorporadas (Incorporação Transulcred -> Transpocred)
                            AND pr_cdcooper = 9 -- Apenas para Cooperativa 9, (Incorporação Transulcred -> Transpocred)
                            ) a
        ORDER BY a.nrcpfcgc
                ,a.inmatric DESC
                ,a.nrdconta
                ,sqregcpf;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Estrutura e tabela para manter as informações durante a quebra de CPF
      TYPE typ_reg_cratepr IS
        RECORD(nrdconta crapass.nrdconta%TYPE
              ,dtmvtolt crapepr.dtmvtolt%TYPE
              ,dtvctctr DATE
              ,nrctremp crapepr.nrctremp%TYPE
              ,vlsdeved crapepr.vlsdeved%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,dtnasctl crapass.dtnasctl%TYPE);
      TYPE typ_tab_cratepr IS
        TABLE OF typ_reg_cratepr
          INDEX BY VARCHAR2(24); -- Conta(8) + Data(8) + Contrato(8)
      vr_tab_cratepr typ_tab_cratepr;
      vr_chv_cratepr VARCHAR2(24); -- Var para montagem da chave

      -- Tabela para armazenar os saldo devedores por PAC:
      TYPE typ_tab_sldevpac IS
        TABLE OF NUMBER(30,10)
          INDEX BY PLS_INTEGER; --> Número do PAC sera a chave
      vr_tab_sldevpac typ_tab_sldevpac;
      vr_tab_sldevpac_temp typ_tab_sldevpac; --> Auxiliar para somar CPF a CPF

      -- Armazenar os seguros prestamista
      TYPE typ_tab_crapseg IS
        TABLE OF DATE
          INDEX BY PLS_INTEGER; -- Indice pela conta
      vr_tab_crapseg typ_tab_crapseg;

      -- tabela para armazenar valores de lancamento no arquivo contabil por agencia PRJ421
      TYPE typ_tab_lancarq IS 
        TABLE OF NUMBER(30,10) INDEX BY PLS_INTEGER;
      
      vr_tab_lancarq typ_tab_lancarq;
      ------------------------------- VARIAVEIS -------------------------------

      -- Variaveis para retorno da parametrização do relatório
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
      vr_tab_vlmaximo NUMBER;
      vr_tab_vlminimo NUMBER;
      vr_tab_vltabela NUMBER(6,5);
      vr_tab_nrdeanos PLS_INTEGER;
      vr_tab_dtiniseg DATE;
      vr_idx_lancarq PLS_INTEGER;
      
      -- variavei geracao arquivo contbil Prj421      
      vr_arquivo_txt         utl_file.file_type;
      vr_nom_diretorio       varchar2(200);
      vr_dsdircop            varchar2(200);
      vr_typ_said VARCHAR2(4);
      vr_linhadet VARCHAR(4000);
      

      -- Nome do arquivo que será gerado
      vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
      vr_nmarqdat            varchar2(50);
      vr_dtmvtolt_yymmdd     VARCHAR2(8);

      -- Variaveis para cópia das informações quando no primeiro registro do CPF
      vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
      vr_nrdconta crapass.nrdconta%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      vr_cdagenci crapass.cdagenci%TYPE;
      vr_dtnasctl crapass.dtnasctl%TYPE;
      -- Saldo e controle por CPF
      vr_vlsdeved NUMBER(24,10); --> Total saldo devedor
      vr_flganter BOOLEAN;       --> Indicador de epr anterior a data
      vr_dtsgprst DATE;          --> Data de movimento do seguro prestamista
      vr_dtvencto DATE;          --> Data de vencimento do epr
      vr_vltotarq NUMBER(30,10);  --> total do lancamento geração arquivo prj421
      -- Idade do cooperado
      vr_nrdeanos PLS_INTEGER;
      vr_nrdmeses PLS_INTEGER;
      vr_dsdidade VARCHAR2(50);
      vr_percpagt NUMBER(20,15);

      -- Totalizadores
      vr_vltotdiv NUMBER(30,10):= 0;-- Total da divida
      vr_qttotdiv PLS_INTEGER := 0; -- Quantidade de associados
      vr_vlttpgto NUMBER;           -- Valor pago de seguro
      vr_vlpagseg NUMBER(18,10);    -- % pagto seguradora

      -- Variaveis para os XMLs e relatórios
      vr_flgachou BOOLEAN := FALSE;      -- Encontrou registro Sim/Não
      vr_clobxml  CLOB;                  -- Clob para conter o XML de dados
      vr_nmdireto VARCHAR2(200);         -- Diretório para gravação do arquivo

      -- Variaveis para retornar os emails que recebem o relatório
      vr_dsmail_generi crapprm.dsvlrprm%TYPE;
      vr_dsmail_cooper crapprm.dsvlrprm%TYPE;

      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

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
       

rw_crapdat.dtmvtolt := to_date('28/02/2020','dd/mm/rrrr');
rw_crapdat.dtmvtocd := to_date('28/02/2020','dd/mm/rrrr');
rw_crapdat.dtmvtoan := to_date('27/02/2020','dd/mm/rrrr');
rw_crapdat.dtmvtopr := to_date('02/03/2020','dd/mm/rrrr');


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

      -- Selecionar número de cópias da solicitação
      OPEN cr_crapsol;
      FETCH cr_crapsol
       INTO vr_nrdevias;
      -- Usar 1 caso não tenha encontrado
      IF cr_crapsol%NOTFOUND THEN
        vr_nrdevias := 1;
      END IF;
      CLOSE cr_crapsol;

      -- Leitura dos valores de mínimo e máximo
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'SEGPRESTAM'
                                               ,pr_tpregist => 0);
      -- Se não encontrar
      IF vr_dstextab IS NULL THEN
        -- Usar valores padrão
        vr_tab_vlminimo := 0;
        vr_tab_vlmaximo := 999999999.99;
      ELSE
        -- Usar informações conforme o posicionamento
        -- Valor mínimo da posição 27 a 39
        vr_tab_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,27,12));
        -- Valor máximo da posição 14 a 26
        vr_tab_vlmaximo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
        -- Data de inicio dos seguros da posição 40 a 50
        vr_tab_dtiniseg := to_date(SUBSTR(vr_dstextab,40,10),'dd/mm/yyyy');
        -- Valor de tabela da posição 51 a 58
        vr_tab_vltabela := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
      END IF;

      -- Buscar idade limite
      OPEN cr_craptsg;
      FETCH cr_craptsg
       INTO vr_tab_nrdeanos;
      -- Se não tiver encontrado
      IF cr_craptsg%NOTFOUND THEN
        -- Usar 0
        vr_tab_nrdeanos := 0;
      END IF;
      CLOSE cr_craptsg;

      -- Buscar os seguros prestamista
      FOR rw_crapseg IN cr_crapseg LOOP
        -- Copiar ao vetor
        vr_tab_crapseg(rw_crapseg.nrdconta) := rw_crapseg.dtmvtolt;
      END LOOP;

      -- Inicializar o XML de dados
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Leitura dos associados e seus empréstimos em aberto
      FOR rw_crapepr IN cr_crapepr(pr_tab_dtiniseg => vr_tab_dtiniseg) LOOP

        -- Indica que achou registro
        vr_flgachou := TRUE;

        -- Somente no primeiro registro do CPF
        IF rw_crapepr.sqregcpf = 1 THEN
          -- Copiar as informações para variavel auxiliar e inicializar contadores e controles
          vr_nrcpfcgc := rw_crapepr.nrcpfcgc;
          vr_nrdconta := rw_crapepr.nrdconta;
          vr_nmprimtl := rw_crapepr.nmprimtl;
          vr_cdagenci := rw_crapepr.cdagenci;
          vr_dtnasctl := rw_crapepr.dtnasctl;
          vr_vlsdeved := 0;
          vr_flganter := FALSE;
          vr_dtsgprst := NULL;
          -- Rotina responsavel por calcular a quantidade de anos e meses entre as datas
          CADA0001.pc_busca_idade(pr_dtnasctl => rw_crapepr.dtnasctl -- Data de Nascimento
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data da utilizacao atual
                                 ,pr_nrdeanos => vr_nrdeanos         -- Numero de Anos
                                 ,pr_nrdmeses => vr_nrdmeses         -- Numero de meses
                                 ,pr_dsdidade => vr_dsdidade         -- Descricao da idade
                                 ,pr_des_erro => vr_dscritic);       -- Mensagem de Erro
          -- Limpar as tabelas internas
          vr_tab_cratepr.DELETE;
          vr_tab_sldevpac_temp.DELETE;
        END IF;

        -- Se não existe o registro para o PAC atual
        IF NOT vr_tab_sldevpac_temp.EXISTS(rw_crapepr.cdagenci) THEN
          vr_tab_sldevpac_temp(rw_crapepr.cdagenci) := 0;
        END IF;
        -- Acumular o saldo devedor por PAC deste CPF
        vr_tab_sldevpac_temp(rw_crapepr.cdagenci) := vr_tab_sldevpac_temp(rw_crapepr.cdagenci) + rw_crapepr.vlsdeved;

        -- Acumular o saldo devedor total
        vr_vlsdeved := vr_vlsdeved + rw_crapepr.vlsdeved;

        -- Se existir a proposta do empréstimo
        OPEN cr_crawepr(rw_crapepr.nrdconta, rw_crapepr.nrctremp);
        FETCH cr_crawepr INTO rw_crawepr;
        IF cr_crawepr%FOUND THEN
          -- Copiar data do vencimento com base na proposta porém usando o primeiro dia do mes
          vr_dtvencto := TRUNC(rw_crawepr.dtdpagto,'mm');

          -- Adicionar "n" meses com base na quantidade de parcelas -1
          vr_dtvencto := ADD_MONTHS(vr_dtvencto,rw_crawepr.qtpreemp - 1);

          -- Para Fevereiro com vencimento superior a 28
          IF to_char(vr_dtvencto,'mm') = 2 AND to_char(rw_crawepr.dtdpagto,'dd') > 28 THEN
            -- Usar dia 28 e mes e ano encontrado
            vr_dtvencto := to_date('28'||to_char(vr_dtvencto,'mm')||to_char(vr_dtvencto,'yyyy'),'ddmmyyyy');
          -- Para meses de 30 dias com dia superior a 30
          ELSIF to_char(vr_dtvencto,'mm') IN(4,6,9,11) AND to_char(rw_crawepr.dtdpagto,'dd') > 30 THEN
            -- Usar dia 30 e mes e ano encontrado
            vr_dtvencto := to_date('30'||to_char(vr_dtvencto,'mm')||to_char(vr_dtvencto,'yyyy'),'ddmmyyyy');
          ELSE
            -- Usar o dia da parcela normalmente e mes e ano encontrados
            vr_dtvencto := to_date(to_char(rw_crawepr.dtdpagto,'dd')||to_char(vr_dtvencto,'mm')||to_char(vr_dtvencto,'yyyy'),'ddmmyyyy');
          END IF;
        END IF;
        CLOSE cr_crawepr;

        -- Se há saldo devedor
        IF rw_crapepr.vlsdeved > 0 THEN
           -- Montar a chave para incluir as informações na tabela interna
           -- Lembrando a regra da chave: Conta(8) + Data(8) + Contrato(8)
           vr_chv_cratepr := to_char(rw_crapepr.nrdconta,'fm00000000')
                          || to_char(rw_crapepr.dtmvtolt,'yyyymmdd')
                          || to_char(rw_crapepr.nrctremp,'fm00000000');
          -- Incluir na tabela
          vr_tab_cratepr(vr_chv_cratepr).nrdconta := rw_crapepr.nrdconta;
          vr_tab_cratepr(vr_chv_cratepr).dtmvtolt := rw_crapepr.dtmvtolt;
          vr_tab_cratepr(vr_chv_cratepr).dtvctctr := vr_dtvencto;
          vr_tab_cratepr(vr_chv_cratepr).nrctremp := rw_crapepr.nrctremp;
          vr_tab_cratepr(vr_chv_cratepr).vlsdeved := rw_crapepr.vlsdeved;
          vr_tab_cratepr(vr_chv_cratepr).nmprimtl := rw_crapepr.nmprimtl;
          vr_tab_cratepr(vr_chv_cratepr).cdagenci := rw_crapepr.cdagenci;
          vr_tab_cratepr(vr_chv_cratepr).dtnasctl := rw_crapepr.dtnasctl;
          -- Se a data do empréstimo for inferior a parametriza
          IF rw_crapepr.dtmvtolt <= vr_tab_dtiniseg THEN
            -- Ativar flag de registro anterior
            vr_flganter := TRUE;
          END IF;
        END IF;

        -- No último registro da conta
        IF rw_crapepr.sqregcpf = rw_crapepr.qtregcpf THEN
          -- Somente se o saldo devedor for superior ao mínimo
          -- e a idade(anos) menor que a quantida máxima parametrizada
          IF vr_vlsdeved > vr_tab_vlminimo AND vr_nrdeanos < vr_tab_nrdeanos THEN
            -- Considerar somente o valor maximo parametrizado
            vr_vlsdeved := LEAST(vr_tab_vlmaximo,vr_vlsdeved);

            -- Se existir
            IF vr_tab_sldevpac_temp.EXISTS(rw_crapepr.cdagenci) THEN
              -- Se não existe o registro na pltable final para o PAC atual
              IF NOT vr_tab_sldevpac.EXISTS(rw_crapepr.cdagenci) THEN
                vr_tab_sldevpac(rw_crapepr.cdagenci) := 0;
              END IF;
              -- Acumular o saldo devedor atual
              vr_tab_sldevpac(rw_crapepr.cdagenci) := vr_tab_sldevpac(rw_crapepr.cdagenci) + nvl(vr_vlsdeved,0);
            END IF;
            -- Acumular o total de divida e de associados
            vr_vltotdiv := vr_vlsdeved + vr_vltotdiv;
            vr_qttotdiv := vr_qttotdiv + 1;

            -- Abrir a tag do CPF
            pc_escreve_clob(vr_clobxml,'<nrcpfass id="'||gene0002.fn_mask(vr_nrcpfcgc,'999.999.999.99')||'" vlsdeved="'||to_char(vr_vlsdeved,'fm999g999g990d00')||'">');

            -- Varrer os registros da PL Table
            vr_chv_cratepr := vr_tab_cratepr.FIRST;
            LOOP
              -- Sair quando não encontrar mais registros
              EXIT WHEN vr_chv_cratepr IS NULL;
              -- Quando for o primeiro registro OU mudou a conta
              -- (Isso ajuda na performance para não buscar "N" vezes na vr_tab_crapseg)
              IF vr_chv_cratepr = vr_tab_cratepr.FIRST
              OR vr_tab_cratepr(vr_chv_cratepr).nrdconta <> vr_tab_cratepr(vr_tab_cratepr.PRIOR(vr_chv_cratepr)).nrdconta THEN
                -- Buscar se existe seguro prestamista para a conta
                IF vr_tab_crapseg.EXISTS(vr_tab_cratepr(vr_chv_cratepr).nrdconta) THEN
                  -- Usar a data
                  vr_dtsgprst := vr_tab_crapseg(vr_tab_cratepr(vr_chv_cratepr).nrdconta);
                ELSE
                  -- Limpar o campo
                  vr_dtsgprst := NULL;
                END IF;
                -- Se não achou e existe registro anterior
                IF vr_dtsgprst IS NULL AND vr_flganter THEN
                  -- Usar o parâmetro
                  vr_dtsgprst := vr_tab_dtiniseg;
                END IF;
              END IF;

              -- Enviar a tag deste empréstimo
              pc_escreve_clob(vr_clobxml,'<empresti>'
                                       ||  '<nmprimtl>'||SUBSTR(vr_tab_cratepr(vr_chv_cratepr).nmprimtl,1,42)||'</nmprimtl>'
                                       ||  '<dtnasctl>'||to_char(vr_tab_cratepr(vr_chv_cratepr).dtnasctl,'dd/mm/yyyy')||'</dtnasctl>'
                                       ||  '<cdagenci>'||vr_tab_cratepr(vr_chv_cratepr).cdagenci||'</cdagenci>'
                                       ||  '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_cratepr(vr_chv_cratepr).nrdconta)||'</nrdconta>'
                                       ||  '<dtmvtolt>'||to_char(vr_tab_cratepr(vr_chv_cratepr).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'
                                       ||  '<dtvctctr>'||to_char(vr_tab_cratepr(vr_chv_cratepr).dtvctctr,'dd/mm/yyyy')||'</dtvctctr>'
                                       ||  '<nrctremp>'||gene0002.fn_mask(vr_tab_cratepr(vr_chv_cratepr).nrctremp,'zz.zzz.zz9')||'</nrctremp>'
                                       ||  '<vlsdeved>'||to_char(vr_tab_cratepr(vr_chv_cratepr).vlsdeved,'fm999g999g990d00')||'</vlsdeved>'
                                       ||  '<dtsgprst>'||to_char(vr_dtsgprst,'dd/mm/yyyy')||'</dtsgprst>'
                                       ||'</empresti>');
              -- Buscar o próximo
              vr_chv_cratepr := vr_tab_cratepr.NEXT(vr_chv_cratepr);
            END LOOP;
            -- Fechar a tag deste CPF
            pc_escreve_clob(vr_clobxml,'</nrcpfass>');
          END IF;
        END IF;
      END LOOP;

      -- Se achou algum registro
      IF vr_flgachou THEN
        -- Ver % pago
        vr_vlttpgto := (vr_vltotdiv * vr_tab_vltabela) / 100;
        -- Se valor da divida é dif que zero
        IF vr_vltotdiv <> 0 THEN
          -- Ver valor pago em seguro com base no % pago sob a divida
          vr_vlpagseg := TRUNC(vr_vlttpgto / vr_vltotdiv,10);
        ELSE
          -- Considera zero
          vr_vlpagseg := 0;
        END IF;
        -- Se divida ou total pago zerados
        IF vr_vlttpgto = 0 OR vr_vltotdiv = 0 THEN
          -- Considerar % pagamento segurado zerado também
          vr_vlpagseg := 0;
        END IF;
        
        vr_tab_lancarq.delete;
        vr_vltotarq := 0;
        -- Gerar tag de totais
        pc_escreve_clob(vr_clobxml,'<totais qttotdiv="'||to_char(vr_qttotdiv,'fm999g999g990')||'"'
                                 ||       ' vlttpgto="'||to_char(vr_vlttpgto,'fm999g999g990d00')||'"'
                                 ||       ' vltotdiv="'||to_char(vr_vltotdiv,'fm999g999g990d00')||'"'
                                 ||       ' vlpagseg="'||to_char(vr_vlpagseg,'fm990d0000000000')||'">');
                                       
        vr_percpagt  := round(vr_tab_vltabela/100,10);
        -- Gerar totais por PAC se existir
       
        IF vr_tab_sldevpac.COUNT > 0 THEN
          FOR vr_cdagenci IN vr_tab_sldevpac.FIRST..vr_tab_sldevpac.LAST LOOP
            -- Se existir registro no contador atual
            IF vr_tab_sldevpac.EXISTS(vr_cdagenci) THEN

              -- Gerar registro
              pc_escreve_clob(vr_clobxml,'<totpac>'
                                       ||  '<cdagenci>'||LPAD(vr_cdagenci,3,' ')||'</cdagenci>'
                                       ||  '<sldevpac>'||to_char(vr_tab_sldevpac(vr_cdagenci),'fm999g999g990d00')||'</sldevpac>'
                                       ||'</totpac>');
                                       
              vr_tab_lancarq(vr_cdagenci) := vr_tab_sldevpac(vr_cdagenci) * vr_percpagt; -- deve ser arredondado
              vr_vltotarq := vr_vltotarq + round(vr_tab_lancarq(vr_cdagenci),2);
                                      
            END IF;
          END LOOP;
          -- para evitar diferença o ultimo PA recebe a diferença do rateio (pode ser negativo ou posito)
          vr_tab_lancarq(vr_tab_lancarq.last) := vr_tab_lancarq(vr_tab_lancarq.last) + round((vr_vlttpgto - vr_vltotarq),2); 
        END IF;
        -- Fechar tag
        pc_escreve_clob(vr_clobxml,'</totais>');
      END IF;

      -- Fechar a tag raiz
      pc_escreve_clob(vr_clobxml,'</raiz>');

      -- gerar arquivo contabil
      vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nmsubdir => 'contab');

     -- Busca o diretório final para copiar arquivos
     vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
     -- Nome do arquivo a ser gerado
     vr_dtmvtolt_yymmdd := to_char(rw_crapdat.dtmvtolt, 'yyyymmdd');
     vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_PRESTAMISTA.txt';


     
     -- Abre o arquivo para escrita
     gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                 pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                 pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                 pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                 pr_des_erro => vr_dscritic);

     if vr_dscritic is not null then
       vr_cdcritic := 0;
       RAISE vr_exc_saida;
     end if;
     
      -- gerar arquivo aqui -- varrer pl table
      IF vr_tab_lancarq.count > 0 THEN
         vr_idx_lancarq := vr_tab_lancarq.first;
         
         /* Escrita arquivo o total*/
         vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(rw_crapdat.dtmvtolt,'ddmmyy'))||','||
                             '8304,'||
                             '4963,'||
                             trim(to_char(round(vr_vlttpgto,2),'999999999999.99'))||','|| --valor deve ir positivo para o arquivo
                             '5210,'||
                             '"VLR. REF. PROVISAO P/ PAGAMENTO DE SEGURO PRESTAMISTA - CHUBB DO BRASIL CIA DE SEGUROS - REF. ' 
                             || to_CHAR(rw_crapdat.dtmvtolt,'MM/YYYY') ||'"';
         

         gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
         
         --escreve no arquivo rateio por PA                    
         WHILE  vr_idx_lancarq IS NOT NULL LOOP
                      
            vr_linhadet := lpad(vr_idx_lancarq,3,0) || ',' || TRIM(to_char(round(vr_tab_lancarq(vr_idx_lancarq),2),'999999999999.99')); 
            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
                        
            vr_idx_lancarq :=  vr_tab_lancarq.next(vr_idx_lancarq);  
           
         END LOOP;
       
      END IF;
      
      gene0001.pc_fecha_arquivo(vr_arquivo_txt);
      
      vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_PRESTAMISTA.txt';
              
      -- Copia o arquivo gerado para o diretório final convertendo para DOS
      gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
                
      -- Testar erro
      if vr_typ_said = 'ERR' then
         vr_cdcritic := 1040;
         gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
      end if;
     
    

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper);

      -- Retornar os emails que vão receber o relatório conforme a cooperativa conectada
      vr_dsmail_cooper := GENE0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL226_MAIL_COOP');

      -- Retornar os emails que vão receber o relatório independente de cooperativa conectada
      vr_dsmail_generi := GENE0001.fn_param_sistema('CRED',0,'CRRL226_MAIL_GENER');

      --Verificar se os dois grupos de email tem informação para concatenar com o separador
      IF vr_dsmail_generi IS NOT NULL AND
         vr_dsmail_cooper IS NOT NULL THEN
         vr_dsmail_generi := vr_dsmail_cooper||';'||vr_dsmail_generi;
      ELSE
         --do contratrio somente concatenar, pois um grupo estará vazio e não precisará do separador
         vr_dsmail_generi := vr_dsmail_cooper||vr_dsmail_generi;
      END IF;            

      -- Submeter geração de relatório para ser enviado por email
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                       --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                       --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                        --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                           --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl226.jasper'                  --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                              --> Parametros para montagem do arquivo
                                 ,pr_dsarqsaid => vr_nmdireto||'/rl/crrl226.lst'    --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                               --> 132 colunas
                                 ,pr_flg_gerar => 'N'                               --> Geraçao na hora
                                 ,pr_sqcabrel  => 1                                 --> Qual a seq do cabrel
                                 ,pr_flg_impri => 'S'                               --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132dm'                           --> Nome do formulário para impressão
                                 ,pr_nrcopias  => vr_nrdevias                       --> Número de cópias
                                 ,pr_dsmailcop => vr_dsmail_generi                  --> Lista sep. por ';' de emails para envio do relatório
                                 ,pr_fldosmail => 'S'                               --> Converter anexo para DOS antes de enviar
                                 ,pr_dscmaxmail => ' | tr -d "\032"'                --> Complemento do comando converte-arquivo
                                 ,pr_dsextmail => 'txt'                             --> Enviar o e-mail como txt
                                 ,pr_dsassmail => 'RELACAO DE CONTROLE SEGURO PRESTAMISTA ' || rw_crapcop.nmrescop  --> Assunto do e-mail que enviará o relatório
                                 ,pr_dscormail => 'SEGUE ARQUIVO EM ANEXO.'         --> HTML corpo do email que enviará o relatório
                                 ,pr_flgremarq => 'N'                               --> Flag para remover o arquivo após cópia/email(Manter na converte)
                                 ,pr_des_erro  => vr_dscritic);                     --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizada
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
        -- Devolvemos código e critica encontradas
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

  END pc_crps279_carlos;
/
