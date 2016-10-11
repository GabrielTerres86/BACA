CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS480(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utiliza��o de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                             ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
  /*..............................................................................

     Programa: pc_crps480 (Antigo fontes/crps480.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : David
     Data    : Maio/2007                       Ultima atualizacao: 28/09/2016

     Dados referentes ao programa:

     Frequencia: Mensal.

     Objetivo  : Solicitacao: 003.
                 Calcular o rendimento mensal e liquido das aplicacoes RDCA e lis-
                 tar o resumo mensal.
                 Ordem da solicitacao: 9
                 Relatorio 454 e 455.

     Observacoes: No campo craprda.vlsdrdca esta sempre o valor real da aplicacao
                  sem provisao e sem rendimentos, todos os resgates foram
                  retirados desse campo
                  Deve constar no relatorio os seguintes dados:
                  - quantidade de titulos ativos = craprda.insaqtot = 0;
                  - quantidade de titulos aplicados no mes = craplap.cdhistor = 473 do mes;
                  - saldo total dos titulos ativos = craprda.vlsdrdca;
                  - valor total aplicado no mes = craprda.vlsdrdca;
                    com month(craprda.dtmvtolt) igual ao mes que roda o mensal;
                  - valor total dos resgates no mes =  craplap.cdhistor = 475
                    do mes onde craprda.dtvencto <= craplap.dtmvtolt;
                  - rendimento creditado no mes = craplap.cdhistor = 476 do mes;
                  - imposto de renda retido na fonte = craplap.cdhistor = 477 do mes;
                  - valor total da provisao do mes = 474 do mes;
                  - ajuste da provisao = 463 do mes;
                  - saques sem rendimento = craplap.cdhistor = 475 do mes
                    onde craprda.dtvencto e  maior que a data do resgate;
                  - Historico = 474 provisao rdcpre
                                463 estorno provisao rdcpre
                                529 provisao rdcpos
                                531 estorno provisao rdcpos

     Alteracoes: 22/08/2007 - Corrigido tplotmov para 9 (Magui).

                 01/10/2007 - Trabalhar com 4 casas na provisao RDCPOS e
                              RDCPRE (Magui).

                 09/11/2007 - Incluida coluna Saldo ajustado que contem
                              as provisoes e reversoes passadas para auxiliar
                              no fechamento contabil (Magui).

                 26/12/2007 - Ajustar relatorios p/fechamento contabil
                              do RDCPRE (Magui).

                 26/02/2008 - Incluir parametros no restart (David).

                 11/03/2008 - Melhorar leitura do craplap para taxas e
                              incluir novos campos no crrl455, rdcpos (Magui).

                 25/03/2008 - Incluir crrl477 e crrl478 (David).

                 04/01/2008 - Alterar posicao das includes de cabecalho (David).

                 07/05/2008 - Corrigir atualizacao do lote (Magui).

                 24/07/2008 - Incluido no relatorio crrl455 relacao de Prazo
                              Medio das Aplicacoes, e listagem detalhada
                              por conta das aplicacoes (somente para Cecred)
                              (Diego).

                 01/09/2010 - Armazenar informacoes de aplicacoes na crapbnd.
                              Incluir quadro de prazos no relatorio crrl454.
                              Tarefa 34654 (Henrique).

                 14/09/2010 - Incluido prazos entre 1080 e 5400 dias. (Henrique)

                 26/11/2010 - Retirar da sol 3 ordem 9 e colocar na sol 83
                              ordem 6.E na CECRED sol 83 e ordem 7 (Magui).

                 17/01/2011 - Alterada a coluna Total da Provis�o para
                              imprimir corretamente a quantidade de caracteres
                              (Isara - RKAM).

                 26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                             (Guilherme)

                 08/02/2011 - Incluir totalizador por conta somente para CECRED
                              (Isara - RKAM).

                 10/01/2012 - Melhoria de desempenho (Gabriel)

                 01/11/2012 - Nova coluna "Situacao" da aplicacao frame f_detalhe
                              Novo totalizador por Situacao no total por conta
                              (Guilherme/Supero)

                 20/02/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)

                 09/08/2013 - Inclus�o de teste na pr_flgresta antes de controlar
                              o restart (Marcos-Supero)

                 09/08/2013 - Troca da busca do mes por extenso com to_char para
                              utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

                 25/11/2013 - Ajustes na passagem dos par�metros para restart (Marcos-Supero)

                 03/02/2014 - criado temptable para armazenar associados, a fim de melhorar performace (Odirlei-AMcom)

                 24/07/2014 - Atualizacao dos campos dtsdfmea e vlslfmea da craprda (Andrino-RKAM)

                 11/11/2014 - Nova coluna de car�ncia e convertido o relat�rio para paisagem. (Kelvin - Chamado 218644)

                 19/11/2014 - Adicionar valida��o para n�o gerar registro na CRAPLAP
                              com valor zerado ou negativo (Douglas - Chamado 191418)

                 22/04/2015 - Altera��o para realizar a gera��o do relat�rio separado por PF e PJ, al�m de
                              alterar o fonte para utilizar o mesmo jaspaer para os relat�rios CRRL454 e CRRL455.
                              Projeto 186  ( Renato - Supero )

                 16/09/2015 - SD334531 - Ajuste pois ap�s gera��o do arquivo _RDC a vari�vel vr_nom_direto persistia
                              com o diret�rio contab, e n�o do rl que era o correto. (Marcos-Supero)

                 19/10/2015 - Ajuste nos relatorios para nao contabilizar informacoes nos PAs migrados
                              e gerar os dados corretamente no PA atual (SD326975 Tiago/Rodrigo)

                 03/12/2015 - Adicionado novo campo com a m�dia dos saldos das aplica��es rdcpos,
                              conforme solicitado no chamado 357115 (Kelvin)

                 25/05/2016 - Ajuste no saldo medio pois estava trazendo os valores incorretos, conforme
                              solicitado no chamado 446559. (Kelvin)

                 10/06/2016 - Ajustado a leitura da craptab para utilizar a procedure padrao TABE0001.fn_busca_dstextab
                              e carregar as contas bloqueadas com a TABE0001.pc_carrega_ctablq
                              (Douglas - Chamado 454248)
                              

                  28/09/2016 - Altera��o do diret�rio para gera��o de arquivo cont�bil.
                                     P308 (Ricardo Linhares).                                    
  ..............................................................................*/

    DECLARE
      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_erro exception;
      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      -- Controle para rollback to savepoint
      vr_exc_undo EXCEPTION;
      -- Ignorar o restante do processo
      vr_exc_next EXCEPTION;

      ---------------- Cursores gen�ricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.nrctactl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Descricao da craptab
      vr_dstextab     craptab.dstextab%TYPE;

      -- Data de fim e inicio da utilizacao da taxa de poupanca.
      -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
      --  a poupanca, a cooperativa opta por usar ou nao.
      -- Buscar a descri��o das faixas contido na craptab
      vr_dtinitax     DATE;                  --> Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax     DATE;                  --> Data de fim da utilizacao da taxa de poupanca.

      -- Vari�veis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;--> N�mero da conta de restart
      vr_dsrestar VARCHAR2(4000);       --> String gen�rica com informa��es para restart
      vr_inrestar INTEGER;              --> Indicador de Restart
      vr_nraplica INTEGER;              --> N�mero da aplica��o do Restart
      vr_tpaplica INTEGER;              --> Tipo da aplica��o do Restart
      vr_qtaplati INTEGER;              --> Qtdade de aplica��es ativas no Restart
      vr_vlsdapat NUMBER;               --> Valores de saldo de aplica��es ativas no Restart
      vr_qtregres NUMBER := 0;          --> Quantidade de registros ignorados por terem sido processados antes do restart

      ---------------- Defini��o de temp-tables da rotina  --------------

      -- Definicao do tipo de registro para a tabela de rejeitados (CRAPREJ)
      TYPE typ_reg_craprej IS
        RECORD(cdempres craprej.cdempres%TYPE
              ,tplotmov craprej.tplotmov%TYPE
              ,vllanmto craprej.vllanmto%TYPE
              ,nrseqdig craprej.nrseqdig%TYPE);
      -- Definicao do tipo de tabela de rejeitados
      TYPE typ_tab_craprej IS
        TABLE OF typ_reg_craprej
          INDEX BY BINARY_INTEGER;
      -- Vetor para armazenar os dados de resumo
      vr_tab_craprej typ_tab_craprej;
      -- Chave para a tabela de resumo
      vr_num_chave_craprej PLS_INTEGER; -- Ser� contatenado o cdempres e o tplotmov

      -- Defini��o do tipo de registro para o resumo (antiga w_resumo)
      TYPE typ_reg_resumo IS
        RECORD(tpaplica INTEGER
              ,tpaplrdc INTEGER
              ,dsaplica VARCHAR2(6)
              ,qtaplati NUMBER(6)    DEFAULT 0  -- "zzz,zz9"              "Qtde de titulos ativos"
              ,qtaplmes NUMBER(6)    DEFAULT 0  -- "zzz,zz9"              "Qtde de titulos aplicados no mes"
              ,vlsdapat NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Saldo total dos titulos ativos"
              ,vlaplmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Valor total aplicado no m�s"
              ,vlresmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Resgates dos titulos vencidos no m�s"
              ,vlrenmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Rendimento creditado no m�s"
              ,vlprvmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Valor total da provis�o do m�s"
              ,vlprvlan NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Valor provis�o lan�amento"
              ,vlajuprv NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Ajuste de provis�o no m�s"
              ,vlsqsren NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Saques sem rendimento"
              ,vlsqcren NUMBER(14,2) DEFAULT 0   -- "zzz,zzz,zzz,zz9.99-"  "Saques com rendimento"
              ,vlrtirrf NUMBER(14,2) DEFAULT 0); -- "zzz,zzz,zzz,zz9.99-"  "Imposto de Renda Retido na Fonte"
      -- Definicao do tipo de tabela de resumo
      TYPE typ_tab_resumo IS
        TABLE OF typ_reg_resumo
          INDEX BY BINARY_INTEGER;
      -- Definicao do tipo de tabela de resumo para pessoa Fisica/Juridica
      TYPE typ_tab_fisjur IS
        TABLE OF typ_tab_resumo
          INDEX BY BINARY_INTEGER;
      -- Defini��o do tipo de tabela dos valores de titulos ativos por pessoa
      TYPE typ_tab_vlsdapat IS
        TABLE OF NUMBER
          INDEX BY BINARY_INTEGER;
      -- Defini��o do tipo de tabela para resumo por agencia
      TYPE typ_tab_resage IS
        TABLE OF typ_tab_vlsdapat
          INDEX BY BINARY_INTEGER;
      -- Defini��o pelo tipo de aplicacao
      TYPE typ_tab_resapl IS
        TABLE OF typ_tab_resage
          INDEX BY BINARY_INTEGER;
      -- Defini��o do total pelo tipo de aplicacao
      TYPE typ_tab_totapl IS
        TABLE OF typ_tab_vlsdapat
          INDEX BY BINARY_INTEGER;

      -- Vetor para armazenar os dados de resumo
      vr_tab_resumo typ_tab_resumo;
      vr_tab_fisjur typ_tab_fisjur;  -- Dados de resumo para pessoa Fisica/Jur�dica

      vr_tab_resage typ_tab_resapl;  -- Dados de resumo por agencia
      vr_tab_proage typ_tab_resapl;  -- Dados de provis�o por agencia

      vr_tab_totpes typ_tab_totapl;  -- Totais Ativos
      vr_tab_totpro typ_tab_totapl;  -- Totais Provis�es

      -- Chave para a tabela de resumo
      vr_num_chave_resumo BINARY_INTEGER;

      -- Defini��o do tipo de registro para o detalhe (antiga w_detalhe)
      TYPE typ_reg_detalhe IS
        RECORD(tpaplica NUMBER(1)    -- "9"
              ,tpaplrdc INTEGER      --
              ,dsaplica VARCHAR2(6)  --
              ,cdagenci NUMBER(3)    -- "zz9"
              ,nmresage VARCHAR2(15) --
              ,indvecto NUMBER(1)    -- "9"
              ,nrdconta NUMBER(8)    -- "zzzz,zzz,9"
              ,nmprimtl VARCHAR2(60) --
              ,nraplica NUMBER(6)    -- "zzz,zz9"
              ,dtaplica DATE         -- "99/99/99"
              ,dtvencto DATE         -- "99/99/99"
              ,vlaplica NUMBER(11,2) -- "zzz,zzz,zz9.99"
              ,vlrgtmes NUMBER(11,2) -- "zzz,zzz,zz9.99"
              ,vlsldrdc NUMBER(11,2) -- "zzz,zzz,zz9.99-"
              ,txaplica NUMBER(9,6)  -- "zz9.999999"
              ,dssitapl VARCHAR2(1)-- "X(1)" /* Sit Aplicacao: (B)loqueado - (L)iberada */
              ,qtdiauti NUMBER(5));
      -- Definicao do tipo de tabela de detalhe
      TYPE typ_tab_detalhe IS
        TABLE OF typ_reg_detalhe
          INDEX BY VARCHAR2(19); --> Chave composta TipoAplica + Agencia + Vcto + Conta + Aplica
      -- Vetor para armazenar os dados de detalhe
      vr_tab_detalhe typ_tab_detalhe;
      -- Chave para a tabela detalhe(Conta+aplica��o)
      vr_des_chave_det VARCHAR2(19);
      -- Auxiliar para indicador de vencimento
      vr_indvecto NUMBER(1);

      -- Defini��o de tipo de registro para o BNDES (antiga tt-cta-bndes)
      TYPE typ_reg_cta_bndes IS
        RECORD(nrdconta NUMBER
              ,tpaplica NUMBER
              ,vlaplica NUMBER);
      -- Definicao do tipo de tabela de ctas BNDES
      TYPE typ_tab_cta_bndes IS
        TABLE OF typ_reg_cta_bndes
          INDEX BY VARCHAR2(9); --> Chave composta Conta(8) + TpAplica(1)
      -- Vetor para armazenar os dados de cta BNDES
      vr_tab_cta_bndes typ_tab_cta_bndes;
      -- Chave para a tabela BNDES(Conta+TipAplica)
      vr_des_chave_bndes VARCHAR2(9);

      -- Defini��o de tipo de registro para o resumo Cecred (antiga w_resumo_cecred)
      TYPE typ_reg_resumo_cecred IS
        RECORD(nrdconta NUMBER         -- "zzzz,zzz,9"           -- CONTA/DV
              ,nmrescop VARCHAR2(20)   -- "x(15)"                -- TITULAR
              ,qtaplati NUMBER(6)      -- "zzz,zz9"              -- QT.TITULOS
              ,vlprvmes NUMBER(17,2)   -- "z,zzz,zzz,zz9.99-"    -- RENDIMENTO
              ,vlrenmes NUMBER(17,2)   -- "zzz,zzz,zzz,zz9.99-"  -- AJUSTE PROVISAO
              ,vlajuprv NUMBER(17,2)   -- "zzz,zzz,zzz,zz9.99-"  -- TOTAL PROVISAO
              ,vlsldmed NUMBER(17,2)); -- "zzz,zzz,zzz,zz9.99-"  -- SALDO M�DIO DAS APLICA��ES RDCPOS
      -- Definicao do tipo de tabela de resumo Cecred
      TYPE typ_tab_resumo_cecred IS
        TABLE OF typ_reg_resumo_cecred
          INDEX BY BINARY_INTEGER; --> usaremos a conta como chave
      -- Vetor para armazenar os dados de resumo Cecred
      vr_tab_resumo_cecred typ_tab_resumo_cecred;
      -- Auxiliar para chaveamento
      vr_num_chave_resumo_cecred BINARY_INTEGER;

      -- Vetor com a quantidade de dias para cada per�odo de 1 a 19
      TYPE typ_reg_periodo IS VARRAY(19) OF NUMBER(4);
      vr_vet_periodo typ_reg_periodo := typ_reg_periodo(90,180,270,360,720,1080,1440
                                                       ,1800,2160,2520,2880,3240,3600
                                                       ,3960,4320,4680,5040,5400,5401);

      -- Vetor para armazenar os dados de detalhe
      vr_tab_blqrgt APLI0001.typ_tab_ctablq;

      --Type para armazenar as os associados
      type typ_reg_crapass is record (cdagenci crapass.cdagenci%TYPE,
                                      nrdconta crapass.nrdconta%TYPE,
                                      nmprimtl crapass.nmprimtl%TYPE,
                                      inpessoa crapass.inpessoa%TYPE,
                                      nmrescop crapass.nmprimtl%TYPE,
                                      nmresage crapage.nmresage%TYPE);

      type typ_tab_reg_crapass is table of typ_reg_crapass
                             index by Binary_Integer; --cta(10)
      vr_tab_crapass typ_tab_reg_crapass;

      ---------------- Cursores espec�ficos ----------------

      -- Busca das aplica��es RDC pr� e p�s
      CURSOR cr_craprda IS
        SELECT /*+ Index (rda CRAPRDA##CRAPRDA6) */
               dtc.tpaplrdc
              ,dtc.dsaplica
              ,rda.tpaplica
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.cdageass
              ,age.nmresage
              ,rda.inaniver
              ,rda.vlaplica
              ,rda.dtmvtolt
              ,rda.dtvencto
              ,rda.dtiniper
              ,rda.dtfimper
              ,rda.vlsdrdca
              ,rda.dtatslmm
              ,rda.vlsltxmm
              ,rda.dtatslmx
              ,rda.vlsltxmx
              ,rda.vlslfmes
              ,rda.vlsdextr
              ,rda.dtsdfmes
              ,rda.dtcalcul
              ,rda.insaqtot
              ,rda.qtdiauti
              ,rownum
          FROM craprda rda
              ,crapdtc dtc
              ,crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND dtc.cdcooper = pr_cdcooper
           AND rda.cdcooper = age.cdcooper
           AND rda.cdageass = age.cdagenci
           AND rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND rda.cdcooper = pr_cdcooper  --> Coop passada
           AND rda.insaqtot = 0            --> N�o sacado totalmente
           AND dtc.tpaplrdc IN(1,2)        --> RDC pr� e p�s
         ORDER BY rda.cdcooper, rda.tpaplica, rda.insaqtot, rda.cdageass, rda.nrdconta, rda.nraplica;

      -- Buscar o primeiro registro na CRAPREJ - Cadastro de rejeitos na integra��o
      CURSOR cr_craprej(pr_nrdconta IN craprej.nrdconta%TYPE) IS
        SELECT rej.rowid
          FROM craprej rej
         WHERE rej.cdcooper = pr_cdcooper  --> Cooperativa conectada
           AND rej.cdpesqbb = vr_cdprogra  --> Programa atual
           AND rej.tpintegr = 2            --> Provisoes - RDCPOS
           AND nrdconta     = pr_nrdconta
         ORDER BY rej.progress_recid;
      vr_craprej_rowid ROWID;

      -- Leitura dos lancamentos de resgate da aplicacao passada
      CURSOR cr_craplap(pr_nrdconta IN craprda.nrdconta%TYPE
                       ,pr_nraplica IN craplap.nraplica%TYPE
                       ,pr_dtmvtolt IN craplap.dtmvtolt%TYPE) IS
        SELECT lap.txaplica
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta --> Conta enviada
           AND lap.nraplica = pr_nraplica --> Aplica��o enviada
           AND lap.dtmvtolt = pr_dtmvtolt --> Data enviada
         ORDER BY lap.progress_recid;     --> Primeiro resgate
      rw_craplap cr_craplap%ROWTYPE;

      -- Buscar as capas de lote para a cooperativa e data atual
      CURSOR cr_craplot(pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = rw_crapdat.dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote
         ORDER BY cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      -- Buscar as informa��es para restart e Rowid para atualiza��o posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -- Busca das cooperativas associadas a cecred e com registro na craprej
      CURSOR cr_craprej_cecred IS
        SELECT rej.nrdconta
              ,SUBSTR(ass.nmprimtl,1,INSTR(ass.nmprimtl,'-',-1)-1) nmrescop
              ,rej.nrseqdig
          FROM crapass ass
              ,craprej rej
         WHERE rej.cdcooper = ass.cdcooper
           AND ass.cdcooper = pr_cdcooper
           AND rej.nrdconta = ass.nrdconta
           AND rej.cdcooper = pr_cdcooper
           AND rej.cdpesqbb = vr_cdprogra
           AND rej.tpintegr = 2 -- Provis�es RDC Pos
         ORDER BY rej.nrdconta;

      -- Busca descria��o do Associado (Cooperativa associada a Cecred)
      CURSOR cr_crapass_cecred IS
        SELECT SUBSTR(ass.nmprimtl,1,INSTR(ass.nmprimtl,'-',-1)-1) nmrescop,
               ass.nmprimtl,
               ass.nrdconta,
               DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa, -- Tratar pessoa 3 como juridica
               ass.cdagenci,
               age.nmresage
          FROM crapass ass,
               crapage age
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci;

      -- Buscar todas as aplica��es para inicializar a tabela de mem�ria
      CURSOR cr_crapdtc_ini IS
        SELECT dtc.tpaplica
          FROM crapdtc dtc
         WHERE dtc.cdcooper  = pr_cdcooper
           AND dtc.tpaplrdc IN (1,2); -- RDP pr� e p�s

      --Tipo do Cursor de associados para Bulk Collect
      TYPE typ_crapass_bulk IS TABLE of cr_crapass_cecred%ROWTYPE;
      vr_tab_crapass_bulk typ_crapass_bulk;

      -- Busca dos lan�amentos do m�s com aplica�ao do tipo RDC Pr� e P�s
      CURSOR cr_craplap_mes IS
        SELECT rda.insaqtot
              ,rda.nrdconta
              ,rda.nraplica
              ,dtc.tpaplrdc
              ,dtc.dsaplica
              ,rda.tpaplica
              ,rda.dtvencto
              ,rda.cdageass
              ,age.nmresage
              ,lap.dtmvtolt
              ,rda.dtmvtolt rda_dtmvtolt
              ,rda.vlaplica
              ,rda.vlslfmes
              ,rda.inaniver
              ,rda.dtfimper
              ,lap.txaplica
              ,lap.cdhistor
              ,lap.vllanmto
              ,lap.nrdolote
              ,rda.qtdiauti
          FROM craplap lap
              ,crapage age
              ,craprda rda
              ,crapdtc dtc
         WHERE rda.cdcooper = pr_cdcooper
           AND age.cdcooper = pr_cdcooper
           AND dtc.cdcooper = pr_cdcooper
           AND rda.cdcooper = age.cdcooper
           AND rda.cdageass = age.cdagenci
           AND lap.cdcooper = rda.cdcooper
           AND lap.nrdconta = rda.nrdconta
           AND lap.nraplica = rda.nraplica
           AND rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND lap.cdcooper = pr_cdcooper
           AND lap.dtmvtolt > rw_crapdat.dtultdma     -- Ult dia m�s anterior
           AND lap.dtmvtolt < rw_crapdat.dtultdia + 1 -- Ult dia m�s corrente + 1
           -- Hist�ricos abaixo
           -- 463 REVERSAO PRV, 473 APLIC.RDCPRE, 474 PROV. RDCPRE
           -- 475 RENDIMENTO  , 476 IRRF        , 477 RESG.RDC
           -- 528 APLIC.RDCPOS, 529 PROV. RDCPOS, 531 REVERSAO PRV
           -- 532 RENDIMENTO  , 533 IRRF        , 534 RESG.RDC
           AND lap.cdhistor IN(474,529,473,528,477,534,532,475,531,463,476,533)
           AND dtc.tpaplrdc IN(1,2); --RDC Pr� e P�s

      -- Buscar exist�ncia de lan�amento espec�fico
      CURSOR cr_craplap_histor(pr_nrdconta IN craplap.nrdconta%TYPE
                              ,pr_nraplica IN craplap.nraplica%TYPE
                              ,pr_cdhistor IN craplap.cdhistor%TYPE
                              ,pr_dtmvtolt IN craplap.dtmvtolt%TYPE)IS
        SELECT COUNT(1)
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.dtmvtolt = pr_dtmvtolt
           AND lap.cdhistor = pr_cdhistor;
      vr_num_exis NUMBER;

      -- Busca do tipo da aplica��o RDC passada
      CURSOR cr_crapdtc(pr_tpaplica IN crapdtc.tpaplica%TYPE) IS
        SELECT dtc.tpaplrdc
              ,dtc.dsaplica
          FROM crapdtc dtc
         WHERE dtc.cdcooper = pr_cdcooper
           AND dtc.tpaplica = pr_tpaplica;

      --Busca o saldo m�dio das aplica��es RDCPOS
      CURSOR cr_crapsda(pr_cdcooper crapsda.cdcooper%TYPE
                       ,pr_nrdconta crapsda.nrdconta%TYPE
                       ,pr_dtmvtoan crapdat.dtmvtoan%TYPE
                       ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT (vlsldmed / (SELECT dat.qtdiaute
                              FROM crapdat dat
                             WHERE cdcooper = pr_cdcooper))
          FROM (SELECT SUM(vlsldmed) vlsldmed
                  FROM (SELECT SUM(vlsrdcpo) vlsldmed
                          FROM crapsda
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND dtmvtolt BETWEEN last_day(add_months(pr_dtmvtoan, -1)) + 1 AND pr_dtmvtoan --Do dia primeiro at� ultimo dia util
                         UNION ALL
                        SELECT SUM(vlslfmea) --Select abaixo para buscar valores do ultimo dia do m�s, pois n�o contem dados na sda
                          FROM craprda
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND dtsdfmea = pr_dtmvtolt)); --Busca do �ltimo dia do m�s

      vr_tpaplrdc crapdtc.tpaplrdc%TYPE;
      vr_dsaplica crapdtc.dsaplica%TYPE;

      -- Vari�veis para o calculo de aplica��o
      vr_dtiniper           DATE;                  --> Data inicial para calculo
      vr_dtfimper           DATE;                  --> Data final para calculo
      vr_vlsldrdc           craprda.vlsdrdca%TYPE; --> Saldo da aplica��o
      vr_vllanmto           NUMBER(18,4);          --> Acumular valor dos rendimentos
      vr_vllctprv           craplap.vllanmto%TYPE; --> Valor dos lan�amentos
      vr_vlrendmm           craplap.vlrendmm%TYPE; --> Valor rendimento tx m�nima

      -- Vari�veis para gera��o de lotes
      vr_nrdocmto           craplap.nrdocmto%TYPE; --> Nrdocmto
      vr_cdhistor           INTEGER;               --> Hist�rico
      vr_rowid_craplap      ROWID;            --> Rowid gravado na craplap

      -- Controle dos prazos
      vr_prazodia           NUMBER; -- Quantidade de dias entre dt vcto e data aplica��o
      vr_tipprazo           NUMBER; -- Tipo do prazo para chamada a pc_controla_prazo

      -- Vari�veis para cria��o do XML e gera��o dos relat�rios
      vr_cdempres           NUMBER;         -- Leitura na craprej
      vr_tot_vlacumul       NUMBER;         -- Acumulador para os valores por per�odo
      vr_des_periodo        VARCHAR2(20);   -- Descri��o para per�odo
      vr_des_xml            CLOB;           -- Dados do XML
      vr_dsjasper           VARCHAR2(30);   -- Nome do arquivo Jasper
      vr_sqcabrel           NUMBER;         -- Indice do CabRel
      vr_dsxmlnod           VARCHAR2(100);  -- N� base do XML de dados
      vr_nmformul           VARCHAR2(10);   -- Nome do formul�rio
      vr_qtcoluna           NUMBER;         -- Quantidade de colunas do relat�rio
      --
      vr_dsxmldad_arq       CLOB;           -- Arquivo de informa��o de tarifas
      vr_nom_direto         VARCHAR2(100);  -- Diretorio /coop/rl
      vr_nom_arquivo        VARCHAR2(100);  -- Nome do arquivo de relat�rio
      vr_nmarqrdc           VARCHAR2(100);  -- Nome do arquivo RDC
      vr_dscomand           VARCHAR2(500);  -- comando Unix
      vr_cdagenci           crapass.cdagenci%TYPE; -- C�digo da agencia
      vr_nrctaaux           NUMBER;         -- N�mero da conta - vari�vel auxiliar
      vr_nrctaori           NUMBER;         -- N�mero da conta de origem para o arquivo
      vr_nrctades           NUMBER;         -- N�mero da conta de destino para o arquivo
      vr_dsmensag           VARCHAR2(100);  -- Mensagem de cabe�alho do arquivo
      vr_dsmsgarq           VARCHAR2(120);  -- Mensagem de cabe�alho do arquivo completa
      vr_dsprefix  CONSTANT VARCHAR2(15) := 'REVERSAO '; -- Prefixo para cabe�alho do arquivo
      vr_dtmvtolt           DATE;           -- Auxiliar para tratamento de datas
      vr_dslinarq           VARCHAR2(200);  -- Linha que ser� escrita no arquivo
      vr_dscritic           VARCHAR2(2000); -- controle de erros
      vr_typ_saida          VARCHAR2(2000); -- controle de erros de scripts unix
      vr_vllinarq           NUMBER;

      vr_Bufdes_xml varchar2(32000);
      
     vr_dircon VARCHAR2(200);
     vr_arqcon VARCHAR2(200);
     vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos'; 
     vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
     vc_cdtodascooperativas INTEGER := 0;  
      

      -------- SubRotinas para reaproveitamento de c�digo --------------

      -- Subrotina para escrever texto na vari�vel CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fimarq    IN BOOLEAN default false) IS
      BEGIN
        --Verificar se ja atingiu o tamanho do buffer, ou se � o final do xml
        IF length(vr_Bufdes_xml) + length(pr_des_dados) > 31000 OR pr_fimarq THEN
          --Escrever no arquivo XML
          --vr_des_xml := vr_des_xml||vr_Bufdes_xml||pr_des_dados;
          dbms_lob.writeappend(vr_des_xml,length(vr_Bufdes_xml||pr_des_dados),vr_Bufdes_xml||pr_des_dados);
          vr_Bufdes_xml := null;
        ELSE
          --armazena no buffer
          vr_Bufdes_xml := vr_Bufdes_xml||pr_des_dados;
        END IF;
      END;

      -- SobRotina que cria registros de totais no XML
      PROCEDURE pc_cria_node_total(pr_des_total IN VARCHAR2
                                  ,pr_des_valor IN VARCHAR2
                                  ,pr_des_vlfis IN VARCHAR2
                                  ,pr_des_vljur IN VARCHAR2) IS
      BEGIN

        -- Escreve no XML abrindo e fechando a tag de total
        pc_escreve_xml('<total>'
                     ||'  <dstotal>'||pr_des_total||'</dstotal>'
                     ||'  <vltotal>'||pr_des_valor||'</vltotal>'
                     ||'  <vlfisic>'||pr_des_vlfis||'</vlfisic>'
                     ||'  <vljurid>'||pr_des_vljur||'</vljurid>'
                     ||'</total>');
      END;

      -- Subprocedure para cria��o do registro de detalhe
      PROCEDURE pc_cria_reg_detalhe(pr_nrdconta IN craprda.nrdconta%TYPE
                                   ,pr_nmprimtl IN crapass.nmprimtl%TYPE
                                   ,pr_nraplica IN craprda.nraplica%TYPE
                                   ,pr_tpaplrdc IN crapdtc.tpaplrdc%TYPE
                                   ,pr_dsaplica IN crapdtc.dsaplica%TYPE
                                   ,pr_dtvencto IN craprda.dtvencto%TYPE
                                   ,pr_tpaplica IN craprda.tpaplica%TYPE
                                   ,pr_cdageass IN craprda.cdageass%TYPE
                                   ,pr_nmresage IN crapage.nmresage%TYPE
                                   ,pr_dtmvtolt IN craprda.dtmvtolt%TYPE
                                   ,pr_vlaplica IN craprda.vlaplica%TYPE
                                   ,pr_vlslfmes IN craprda.vlslfmes%TYPE
                                   ,pr_inaniver IN craprda.inaniver%TYPE
                                   ,pr_dtfimper IN craprda.dtfimper%TYPE
                                   ,pr_qtdiauti IN craprda.qtdiauti%TYPE
                                   ,pr_txaplica IN craplap.txaplica%TYPE) IS
      BEGIN
        /*** ---------------------------------------------------------- ***/
        /*** Se for uma aplicacao RDCPOS deve-se verificar quantos dias ***/
        /*** faltam para o vencimento da aplicacao, pois no relatorio   ***/
        /*** analitico serao listadas primeiro as aplicacoes com vencto ***/
        /*** ate 360 dias e depois listadas as aplicacoes com vencto    ***/
        /*** maior que 360 dias                                         ***/
        /*** ---------------------------------------------------------- ***/
        IF pr_tpaplrdc = 1 -- RDCPRE
        OR (pr_tpaplrdc = 2 AND pr_dtvencto - rw_crapdat.dtmvtolt <= 360) THEN -- RDC Pos com menos de 1 ano
          vr_indvecto := 1; -- N�o venceu ainda
        ELSE
          vr_indvecto := 2; -- J� venceu
        END IF;
        -- Montar a chave TpAplica | Agencia | IndVcto | Conta | Aplica
        vr_des_chave_det := pr_tpaplica || LPAD(pr_cdageass,3,'0') || vr_indvecto || LPAD(pr_nrdconta,8,'0') || LPAD(pr_nraplica,6,'0');
        -- Continua somente se n�o existe o registro na tabela de detalhe
        IF NOT vr_tab_detalhe.EXISTS(vr_des_chave_det) THEN
          -- Copiar o restante das informa��es de detalhe
          vr_tab_detalhe(vr_des_chave_det).tpaplica := pr_tpaplica;
          vr_tab_detalhe(vr_des_chave_det).tpaplrdc := pr_tpaplrdc;
          vr_tab_detalhe(vr_des_chave_det).dsaplica := pr_dsaplica;
          vr_tab_detalhe(vr_des_chave_det).cdagenci := pr_cdageass;
          vr_tab_detalhe(vr_des_chave_det).nmresage := pr_nmresage;
          vr_tab_detalhe(vr_des_chave_det).indvecto := vr_indvecto;
          vr_tab_detalhe(vr_des_chave_det).nrdconta := pr_nrdconta;
          vr_tab_detalhe(vr_des_chave_det).nmprimtl := pr_nmprimtl;
          vr_tab_detalhe(vr_des_chave_det).nraplica := pr_nraplica;
          vr_tab_detalhe(vr_des_chave_det).dtaplica := pr_dtmvtolt;
          vr_tab_detalhe(vr_des_chave_det).dtvencto := pr_dtvencto;
          vr_tab_detalhe(vr_des_chave_det).vlaplica := pr_vlaplica;
          vr_tab_detalhe(vr_des_chave_det).vlrgtmes := 0;
          vr_tab_detalhe(vr_des_chave_det).vlsldrdc := pr_vlslfmes ;
          vr_tab_detalhe(vr_des_chave_det).txaplica := pr_txaplica;
          vr_tab_detalhe(vr_des_chave_det).qtdiauti := pr_qtdiauti;

          -- Verificar se a aplica��o possui bloqueio de resgate
          IF vr_tab_blqrgt.EXISTS(LPAD(pr_nrdconta,12,'0')||LPAD(pr_nraplica,8,'0')) THEN
            -- Situa��o bloqueada
            vr_tab_detalhe(vr_des_chave_det).dssitapl := 'B';
          ELSE
            -- Para aplica��o RDCA
            IF pr_tpaplica = 3 THEN
              -- Se J� completou anivers�rio
              -- OU per�odo final � anterior ou igual a data atual
              IF pr_inaniver = 1 OR pr_dtfimper <= rw_crapdat.dtmvtolt  THEN
                -- Atribuir D
                vr_tab_detalhe(vr_des_chave_det).dssitapl := 'D';
              ELSE
                -- Atribuir branco
                vr_tab_detalhe(vr_des_chave_det).dssitapl := ' ';
              END IF;
            -- Para aplica��o RDCAII
            ELSIF pr_tpaplica = 5 THEN
              -- Se J� completou anivers�rio
              -- OU per�odo final � anterior ou igual a data atual
              --  E per�odo final - data contrata��o aplica��o > 50 dias
              IF pr_inaniver = 1
              OR (pr_dtfimper <= rw_crapdat.dtmvtolt AND pr_dtfimper - pr_dtmvtolt > 60) THEN
                -- Atribuir D
                vr_tab_detalhe(vr_des_chave_det).dssitapl := 'D';
              ELSE
                -- Atribuir branco
                vr_tab_detalhe(vr_des_chave_det).dssitapl := ' ';
              END IF;
            -- Para todas as outras
            ELSE
              -- Atribuir branco
              vr_tab_detalhe(vr_des_chave_det).dssitapl := ' ';
            END IF;
          END IF;
        END IF;
      END;

    BEGIN

      -- C�digo do programa
      vr_cdprogra := 'CRPS480';

      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480'
                                ,pr_action => null);

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF pr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> C�digo do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> N�mero da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String gen�rica com informa��es para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => pr_cdcritic   --> C�digo de erro
                                ,pr_des_erro  => pr_dscritic); --> Sa�da de erro
      -- Se encontrou erro, gerar exce��o
      IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Se houver indicador de restart, mas n�o veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;
      -- Se houver indica��o de restart
      IF vr_inrestar > 0 THEN
        BEGIN

          -- Buscar informa��es na string de restart
          vr_nraplica := SUBSTR(vr_dsrestar,1,6);
          vr_tpaplica := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,8,2));
          vr_qtaplati := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,11,6));
          vr_vlsdapat := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,18,16));
          -- Se foi enviado aplica��o
          IF vr_tpaplica > 0 THEN
            -- Buscar descri��o do tipo
            OPEN cr_crapdtc(pr_tpaplica => vr_tpaplica);
            FETCH cr_crapdtc
             INTO vr_tpaplrdc
                 ,vr_dsaplica;
            CLOSE cr_crapdtc;
            -- Criar o registro de resumo
            vr_tab_resumo(vr_tpaplica).tpaplica := vr_tpaplica;
            vr_tab_resumo(vr_tpaplica).dsaplica := vr_dsaplica;
            vr_tab_resumo(vr_tpaplica).tpaplrdc := vr_tpaplrdc;
            vr_tab_resumo(vr_tpaplica).qtaplati := vr_qtaplati;
            vr_tab_resumo(vr_tpaplica).vlsdapat := vr_vlsdapat;
          END IF;
          -- Buscar informa��es complementares na string de restart
          vr_tpaplica := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,35,2));
          vr_qtaplati := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,38,6));
          vr_vlsdapat := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,45,16));
          -- Se foi enviado aplica��o
          IF vr_tpaplica > 0 THEN
            -- Buscar descri��o do tipo
            OPEN cr_crapdtc(pr_tpaplica => vr_tpaplica);
            FETCH cr_crapdtc
             INTO vr_tpaplrdc
                 ,vr_dsaplica;
            CLOSE cr_crapdtc;
            -- Criar o registro de resumo
            vr_tab_resumo(vr_tpaplica).tpaplica := vr_tpaplica;
            vr_tab_resumo(vr_tpaplica).dsaplica := vr_dsaplica;
            vr_tab_resumo(vr_tpaplica).tpaplrdc := vr_tpaplrdc;
            vr_tab_resumo(vr_tpaplica).qtaplati := vr_qtaplati;
            vr_tab_resumo(vr_tpaplica).vlsdapat := vr_vlsdapat;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao converter informa��es de restart para number. Conte�do vr_dsrestar: '||vr_dsrestar||'.';
            RAISE vr_exc_erro;
        END;

      END IF;

      -- Data de fim e inicio da utilizacao da taxa de poupanca.
      -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
      --  a poupanca, a cooperativa opta por usar ou nao.
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'MXRENDIPOS'
                     ,pr_tpregist => 1);

      -- Se n�o encontrar
      IF TRIM(vr_dstextab) IS NOT NULL THEN
        -- Utilizar datas padr�o
        vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
        vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
      ELSE
        -- Utilizar datas da tabela
        vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/YYYY');
        vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/YYYY');
      END IF;

      -- Buscar todas as contas que possuem bloqueio de resgate
      TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                ,pr_tab_cta_bloq => vr_tab_blqrgt);

      --Carregar tabela memoria associados
      OPEN cr_crapass_cecred;
      --Carregar Bulk Collect
      FETCH cr_crapass_cecred BULK COLLECT INTO vr_tab_crapass_bulk;
      --Fechar Cursor
      CLOSE cr_crapass_cecred;

      --Montar o indice por conta a partir do bulk collect
      IF vr_tab_crapass_bulk.COUNT > 0 THEN
        FOR idx IN vr_tab_crapass_bulk.FIRST..vr_tab_crapass_bulk.LAST LOOP
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nrdconta := vr_tab_crapass_bulk(idx).nrdconta;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).cdagenci := vr_tab_crapass_bulk(idx).cdagenci;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nmrescop := vr_tab_crapass_bulk(idx).nmrescop;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nmprimtl := vr_tab_crapass_bulk(idx).nmprimtl;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).inpessoa := vr_tab_crapass_bulk(idx).inpessoa;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nmresage := vr_tab_crapass_bulk(idx).nmresage;
        END LOOP;
      END IF;

      -- Buscar as capas de lote para a cooperativa e data atual
      OPEN cr_craplot(pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 8480);
      FETCH cr_craplot
       INTO rw_craplot;
      -- Se n�o tiver encontrado
      IF cr_craplot%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplot;
        -- Efetuar a inser��o de um novo registro
        BEGIN
          INSERT INTO craplot(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,vlinfodb
                             ,vlcompdb
                             ,qtinfoln
                             ,qtcompln
                             ,vlinfocr
                             ,vlcompcr)
                       VALUES(pr_cdcooper
                             ,rw_crapdat.dtmvtolt
                             ,1
                             ,100
                             ,8480
                             ,9
                             ,0
                             ,0
                             ,0
                             ,0
                             ,0
                             ,0)
                     RETURNING cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,tplotmov
                              ,nrseqdig
                              ,rowid
                          INTO rw_craplot.cdagenci
                              ,rw_craplot.cdbccxlt
                              ,rw_craplot.nrdolote
                              ,rw_craplot.tplotmov
                              ,rw_craplot.nrseqdig
                              ,rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            pr_dscritic := 'Erro ao inserir capas de lotes (craplot). Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        -- apenas fechar o cursor
        CLOSE cr_craplot;
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informa��es para restart e Rowid para atualiza��o posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se n�o tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          pr_cdcritic := 151;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 151);
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;

      -- Percorrer o registro de tipo de aplica��o para inicializar a tab
      FOR rw_crapdtc IN cr_crapdtc_ini LOOP
        -- Inicializa para pessoa fisica e jur�dica
        vr_tab_fisjur(1)(rw_crapdtc.tpaplica).qtaplati := 0;
        vr_tab_fisjur(2)(rw_crapdtc.tpaplica).qtaplati := 0;
      END LOOP;

      -- Busca das aplica��es RDC pr� e p�s
      FOR rw_craprda IN cr_craprda LOOP

        BEGIN
          -- Leitura dos lancamentos de resgate da aplicacao passada
          OPEN cr_craplap(pr_nrdconta => rw_craprda.nrdconta
                         ,pr_nraplica => rw_craprda.nraplica
                         ,pr_dtmvtolt => rw_craprda.dtmvtolt);
          FETCH cr_craplap
           INTO rw_craplap;
          -- Se n�o encontrar nada
          IF cr_craplap%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craplap;
            -- Gerar log 90 e concatenar conta e aplica��o
            pr_cdcritic := 90;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 90)
                        || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                        || gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
            -- Gerar roolback para desfazer altera��es desse registro
            RAISE vr_exc_undo;
          ELSE
            -- Apenas fechar para continuar o processo
            CLOSE cr_craplap;
          END IF;

          -- Se h� controle de restart
          IF vr_inrestar > 0  AND (  -- Se for uma conta anterior a de restart
                                     (rw_craprda.nrdconta < vr_nrctares)
                                   OR
                                     -- Ou se � a mesma conta, mas de uma aplica��o anterior
                                     (rw_craprda.nrdconta = vr_nrctares AND rw_craprda.nraplica <= vr_nraplica) ) THEN
            -- Criar o registro de detalhe para esta aplica��o
            pc_cria_reg_detalhe(pr_nrdconta => rw_craprda.nrdconta
                               ,pr_nmprimtl => vr_tab_crapass(rw_craprda.nrdconta).nmprimtl
                               ,pr_nraplica => rw_craprda.nraplica
                               ,pr_tpaplrdc => rw_craprda.tpaplrdc
                               ,pr_dsaplica => rw_craprda.dsaplica
                               ,pr_dtvencto => rw_craprda.dtvencto
                               ,pr_tpaplica => rw_craprda.tpaplica
                               ,pr_cdageass => vr_tab_crapass(rw_craprda.nrdconta).cdagenci
                               ,pr_nmresage => vr_tab_crapass(rw_craprda.nrdconta).nmresage
                               ,pr_dtmvtolt => rw_craprda.dtmvtolt
                               ,pr_vlaplica => rw_craprda.vlaplica
                               ,pr_vlslfmes => rw_craprda.vlslfmes
                               ,pr_inaniver => rw_craprda.inaniver
                               ,pr_dtfimper => rw_craprda.dtfimper
                               ,pr_qtdiauti => rw_craprda.qtdiauti
                               ,pr_txaplica => rw_craplap.txaplica);
            -- Ignorar o restante do processo
            RAISE vr_exc_next;
          END IF;
          -- Calculando data inicial do per�odo (default 1� dia do m�s)
          vr_dtiniper := rw_crapdat.dtinimes;
          -- Se a data for inferior ao in�cio da aplica��o
          IF vr_dtiniper < rw_craprda.dtiniper THEN
            -- Subsituir a data com a data da aplica��o
            vr_dtiniper := rw_craprda.dtiniper;
          END IF;
          -- Calculando data final do per�odo (default dia corrente + 1)
          vr_dtfimper := rw_crapdat.dtmvtolt + 1;
          -- Se a data for superior ao fim da aplica��o
          IF vr_dtfimper > rw_craprda.dtfimper THEN
            -- Substituir a data com o termino da aplica��o
            vr_dtfimper := rw_craprda.dtfimper;
          END IF;
          -- Efetuar atualiza��o dos campos Saldo emiss�o de Extrato
          -- e Data execu��o mensal na aplica��o
          rw_craprda.vlsdextr := rw_craprda.vlsdrdca;
          rw_craprda.dtsdfmes := rw_crapdat.dtmvtolt;
          -- Zerar vari�veis de processo
          vr_vlsdapat := 0;
          vr_vlrendmm := 0;
          -- Para RDC Pr�
          IF rw_craprda.tpaplrdc = 1 THEN
            -- Chamar Rotina de calculo da provisao no final do mes e no vencimento.
            APLI0001.pc_provisao_rdc_pre(pr_cdcooper  => pr_cdcooper         --> Cooperativa
                                        ,pr_nrdconta  => rw_craprda.nrdconta --> Numero da Conta
                                        ,pr_nraplica  => rw_craprda.nraplica --> Numero da Aplica�ao
                                        ,pr_dtiniper  => vr_dtiniper         --> Data base inicial
                                        ,pr_dtfimper  => vr_dtfimper         --> Data base final
                                        ,pr_vlsdrdca  => vr_vlsldrdc         --> Valor do saldo RDCA
                                        ,pr_vlrentot  => vr_vllanmto         --> Valor do rendimento total
                                        ,pr_vllctprv  => vr_vllctprv         --> Valor dos ajustes RDC
                                        ,pr_des_reto => vr_des_reto          --> Indicador de sa�da com erro (OK/NOK)
                                        ,pr_tab_erro => vr_tab_erro);        --> Tabela com erros
            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Se veio erro na tabela
              IF vr_tab_erro.COUNT > 0 then
                -- Montar erro
                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                -- Por algum motivo retornou erro mais a tabela veio vazia
                pr_dscritic := 'Tab.Erro vazia - n�o � poss�vel retornar o erro da chamada APLI0001.pc_provisao_rdc_pre';
              END IF;
              -- Incluir na mensagem de erro a conta e aplica��o
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            ELSE
              -- Atualizar data de calculo do saldo com a taxa m�xima
              rw_craprda.dtatslmx := rw_crapdat.dtmvtopr; --> Pr�ximo dia util
              -- Atualizar valor saldo aplica��es ativas
              vr_vlsdapat := APLI0001.fn_round(vr_vlsldrdc,2);
              -- Utilizar hist�rico 474 - PROV. RDCPRE
              vr_cdhistor := 474;
            END IF;
          -- Para RDC P�s
          ELSIF rw_craprda.tpaplrdc = 2  THEN
            -- Mantem o saldo atual a taxa minima para o caso de resgates antes do vencimento
            APLI0001.pc_provisao_rdc_pos(pr_cdcooper  => pr_cdcooper         --> C�digo cooperativa
                                        ,pr_cdagenci  => 1                   --> C�digo da ag�ncia
                                        ,pr_nrdcaixa  => 999                 --> N�mero do caixa
                                        ,pr_nrctaapl  => rw_craprda.nrdconta --> N�mero da conta
                                        ,pr_nraplres  => rw_craprda.nraplica --> N�mero da aplica��o
                                        ,pr_dtiniper  => rw_craprda.dtatslmm --> Data in�cio do per�odo (dt calculo taxa minima)
                                        ,pr_dtfimper  => vr_dtfimper         --> Data fim do per�odo
                                        ,pr_dtinitax => vr_dtinitax         --> Data de inicio da utilizacao da taxa de poupanca.
                                        ,pr_dtfimtax => vr_dtfimtax         --> Data de fim da utilizacao da taxa de poupanca.
                                        ,pr_flantven  => TRUE                --> Indicador de taxa m�nima
                                        ,pr_vlsdrdca  => vr_vlsldrdc         --> Valor RDCA
                                        ,pr_vlrentot  => vr_vllanmto         --> Valor total
                                        ,pr_des_reto  => vr_des_reto         --> Indicador de sa�da com erro (OK/NOK)
                                        ,pr_tab_erro  => vr_tab_erro);       --> Tabela com erros
            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Se veio erro na tabela
              IF vr_tab_erro.COUNT > 0 then
                -- Montar erro
                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                -- Por algum motivo retornou erro mais a tabela veio vazia
                pr_dscritic := 'Tab.Erro vazia - n�o � poss�vel retornar o erro da chamada APLI0001.pc_provisao_rdc_pos[1]';
              END IF;
              -- Incluir na mensagem de erro a conta e aplica��o
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            ELSE
              -- Atualizar data de calculo do saldo da taxa
              -- e o valor da taxa m�nima
              rw_craprda.vlsltxmm := NVL(rw_craprda.vlsltxmm,0) + NVL(vr_vllanmto,0); -- Acumular o j� existente
              rw_craprda.dtatslmm := rw_crapdat.dtmvtopr;                             -- Pr�ximo dia util
              -- Acumular o valor do rendimento
              vr_vlrendmm := vr_vllanmto;
            END IF;
            -- Mantem o saldo atual agora para a taxa m�xima
            APLI0001.pc_provisao_rdc_pos(pr_cdcooper  => pr_cdcooper         --> C�digo cooperativa
                                        ,pr_cdagenci  => 1                   --> C�digo da ag�ncia
                                        ,pr_nrdcaixa  => 999                 --> N�mero do caixa
                                        ,pr_nrctaapl  => rw_craprda.nrdconta --> N�mero da conta
                                        ,pr_nraplres  => rw_craprda.nraplica --> N�mero da aplica��o
                                        ,pr_dtiniper  => rw_craprda.dtatslmx --> Data in�cio do per�odo (dt calculo taxa maxima)
                                        ,pr_dtfimper  => vr_dtfimper         --> Data fim do per�odo
                                        ,pr_dtinitax => vr_dtinitax         --> Data de inicio da utilizacao da taxa de poupanca.
                                        ,pr_dtfimtax => vr_dtfimtax         --> Data de fim da utilizacao da taxa de poupanca.
                                        ,pr_flantven  => FALSE               --> Indicador de taxa m�nima
                                        ,pr_vlsdrdca  => vr_vlsldrdc         --> Valor RDCA
                                        ,pr_vlrentot  => vr_vllanmto         --> Valor total
                                        ,pr_des_reto  => vr_des_reto         --> Indicador de sa�da com erro (OK/NOK)
                                        ,pr_tab_erro  => vr_tab_erro);       --> Tabela com erros
            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Se veio erro na tabela
              IF vr_tab_erro.COUNT > 0 then
                -- Montar erro
                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                -- Por algum motivo retornou erro mais a tabela veio vazia
                pr_dscritic := 'Tab.Erro vazia - n�o � poss�vel retornar o erro da chamada APLI0001.pc_provisao_rdc_pos[2]';
              END IF;
              -- Incluir na mensagem de erro a conta e aplica��o
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            ELSE
              -- Atualizar data de calculo do saldo da taxa
              -- e o valor da taxa M�xima agora
              rw_craprda.vlsltxmx := NVL(rw_craprda.vlsltxmx,0) + NVL(vr_vllanmto,0); -- Acumular o j� existente
              rw_craprda.dtatslmx := rw_crapdat.dtmvtopr;                             -- Pr�ximo dia util
              -- Acumular o saldo provisionado na taxa m�xima para RDCPOS
              vr_vlsdapat := APLI0001.FN_ROUND(vr_vlsldrdc,2);
              -- Utilizar hist�rico 529 - PROV. RDCPOS
              vr_cdhistor := 529;
              -- Apenas para execu��o a partir da Cecred
              IF pr_cdcooper = 3 THEN
                -- Gravar a tabela craprej - Cadastro de rejeitos na integra��o
                DECLARE
                  vr_dsopera VARCHAR2(30);
                BEGIN
                  -- Buscar o primeiro registro na CRAPREJ - Cadastro de rejeitos na integra��o
                  vr_craprej_rowid := null;
                  OPEN cr_craprej(pr_nrdconta => rw_craprda.nrdconta);
                  FETCH cr_craprej
                   INTO vr_craprej_rowid;
                  -- Se tiver encontrado
                  IF cr_craprej%FOUND THEN
                    -- Fechar o cursor
                    CLOSE cr_craprej;
                    -- Tenta atualizar as informa��es
                    vr_dsopera := 'Atualizar';
                    UPDATE craprej
                       SET nrseqdig = NVL(nrseqdig,0) + 1
                     WHERE rowid = vr_craprej_rowid;
                  ELSE
                    -- Fechar o cursor
                    CLOSE cr_craprej;
                    -- N�o encontrou nada para atualizar, ent�o inserimos
                    vr_dsopera := 'Inserir';
                    INSERT INTO craprej
                               (cdcooper
                               ,cdpesqbb
                               ,tpintegr
                               ,nrdconta
                               ,nrseqdig)
                         VALUES(pr_cdcooper   --> Cooperativa conectada
                               ,vr_cdprogra   --> Programa atual
                               ,2             --> Provisoes - RDCPOS
                               ,rw_craprda.nrdconta
                               ,1);
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    pr_dscritic := 'Erro ao '||vr_dsopera||' as informa��es na tabela CRAPREJ - Conta:'
                                || rw_craprda.nrdconta ||' Aplic:'||rw_craprda.nraplica||'. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
                END;
              END IF;
            END IF;
          END IF; --> tipos de aplica��o
          -- Atribuir a sequencia encontrada + 1 ao nro.docmto
          vr_nrdocmto := NVL(rw_craplot.nrseqdig,0) + 1;

          -- Validar se o valor de lan�amento � maior que zero
          -- N�o deve gerar registro na CRAPLAP com valor zerado ou negativo
          IF vr_vllanmto > 0 THEN
            -- Chamar a grava��o de craplap de cr�dito
            apli0001.pc_gera_craplap_rdc(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_nrdcaixa => 999
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                        ,pr_nrdconta => rw_craprda.nrdconta
                                        ,pr_nraplica => rw_craprda.nraplica
                                        ,pr_nrdocmto => vr_nrdocmto
                                        ,pr_txapllap => rw_craplap.txaplica
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_nrseqdig => rw_craplot.nrseqdig
                                        ,pr_vllanmto => vr_vllanmto
                                        ,pr_dtrefere => rw_craprda.dtfimper
                                        ,pr_vlrendmm => vr_vlrendmm
                                        ,pr_tipodrdb => 'C'
                                        ,pr_rowidlot => rw_craplot.ROWID
                                        ,pr_rowidlap => vr_rowid_craplap
                                        ,pr_vlinfodb => rw_craplot.vlinfodb
                                        ,pr_vlcompdb => rw_craplot.vlcompdb
                                        ,pr_qtinfoln => rw_craplot.qtinfoln
                                        ,pr_qtcompln => rw_craplot.qtcompln
                                        ,pr_vlinfocr => rw_craplot.vlinfocr
                                        ,pr_vlcompcr => rw_craplot.vlcompcr
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro );
            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Se veio erro na tabela
              IF vr_tab_erro.COUNT > 0 then
                -- Montar erro
                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                -- Por algum motivo retornou erro mais a tabela veio vazia
                pr_dscritic := 'Tab.Erro vazia - n�o � poss�vel retornar o erro da chamada APLI0001.pc_gera_craplap_rdc';
              END IF;
              -- Incluir na mensagem de erro a conta e aplica��o
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            END IF;
          END IF;
          -- Inserir / atualizar o resumo do tipo de aplica��o atual
          vr_tab_resumo(rw_craprda.tpaplica).tpaplica := rw_craprda.tpaplica;
          vr_tab_resumo(rw_craprda.tpaplica).tpaplrdc := rw_craprda.tpaplrdc;
          vr_tab_resumo(rw_craprda.tpaplica).qtaplati := nvl(vr_tab_resumo(rw_craprda.tpaplica).qtaplati,0) + 1;
          vr_tab_resumo(rw_craprda.tpaplica).vlsdapat := nvl(vr_tab_resumo(rw_craprda.tpaplica).vlsdapat,0) + vr_vlsdapat;

          BEGIN
            -- gravar as informa��es por tipo de pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).qtaplati :=
                      nvl(vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).qtaplati,0) + 1;
            vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).vlsdapat :=
                      nvl(vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).vlsdapat,0) + vr_vlsdapat;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).qtaplati := 1;
              vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).vlsdapat := vr_vlsdapat;
          END;

          -- Gravar as informa��es por agencia
          BEGIN
            vr_tab_resage(rw_craprda.tpaplrdc)(vr_tab_crapass(rw_craprda.nrdconta).cdagenci)(vr_tab_crapass(rw_craprda.nrdconta).inpessoa) :=
                vr_tab_resage(rw_craprda.tpaplrdc)(vr_tab_crapass(rw_craprda.nrdconta).cdagenci)(vr_tab_crapass(rw_craprda.nrdconta).inpessoa) + vr_vlsdapat;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_resage(rw_craprda.tpaplrdc)(vr_tab_crapass(rw_craprda.nrdconta).cdagenci)(vr_tab_crapass(rw_craprda.nrdconta).inpessoa) := vr_vlsdapat;
          END;

          BEGIN
            -- Somar os totalizadores
            vr_tab_totpes(rw_craprda.tpaplrdc)(vr_tab_crapass(rw_craprda.nrdconta).inpessoa) :=
                vr_tab_totpes(rw_craprda.tpaplrdc)(vr_tab_crapass(rw_craprda.nrdconta).inpessoa) + vr_vlsdapat;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_totpes(rw_craprda.tpaplrdc)(vr_tab_crapass(rw_craprda.nrdconta).inpessoa) := vr_vlsdapat;
          END;

          -- Atualizar todos os campos atualizados ate o momento no Rowtype
          -- e tambem a data calculada e saldo fim do m�s na aplica��o
          BEGIN
            UPDATE craprda rda
               SET rda.vlslfmea = ROUND(vr_vlsldrdc,2) -- Saldo calculado acima
                  ,rda.dtsdfmea = rw_craprda.dtsdfmes
                  ,rda.vlsdextr = rw_craprda.vlsdextr
                  ,rda.dtsdfmes = rw_craprda.dtsdfmes
                  ,rda.dtatslmx = rw_craprda.dtatslmx
                  ,rda.vlsltxmx = rw_craprda.vlsltxmx
                  ,rda.dtatslmm = rw_craprda.dtatslmm
                  ,rda.vlsltxmm = rw_craprda.vlsltxmm
                  ,rda.vlslfmes = ROUND(vr_vlsldrdc,2) -- Saldo calculado acima
                  ,rda.dtcalcul = rw_crapdat.dtmvtopr  -- Pr�ximo dia util
             WHERE rda.cdcooper = pr_cdcooper
               AND rda.nrdconta = rw_craprda.nrdconta
               AND rda.nraplica = rw_craprda.nraplica
             RETURNING rda.vlslfmes
                      ,rda.dtcalcul
                  INTO rw_craprda.vlslfmes
                      ,rw_craprda.dtcalcul;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              pr_dscritic := 'Erro ao atualizar a aplica��o RDCA - Conta:'||rw_craprda.nrdconta
                          ||' Aplic:'||rw_craprda.nraplica||'. Detalhes: '||sqlerrm;
              RAISE vr_exc_undo;
          END;
          -- Somente quando a execu��o partir da Cecred
          IF pr_cdcooper = 3 THEN
            -- Inserir Informacoes para o BNDES das aplicacoes de nossas filiadas na CECRED
            DECLARE
              vr_dsopera VARCHAR2(30);
            BEGIN
              -- Tenta atualizar as informa��es
              vr_dsopera := 'Atualizar';
              UPDATE crapbnd
                 SET vlaplprv = NVL(vlaplprv,0) + ROUND(vr_vlsldrdc,2) -- Saldo final do m�s

               WHERE cdcooper = pr_cdcooper         --> Cooperativa conectada
                 AND dtmvtolt = rw_crapdat.dtmvtolt --> Data atual
                 AND nrdconta = rw_craprda.nrdconta;
              -- Se n�o conseguiu atualizar nenhum registro
              IF SQL%ROWCOUNT = 0 THEN
                -- N�o encontrou nada para atualizar, ent�o inserimos
                vr_dsopera := 'Inserir';
                INSERT INTO crapbnd
                           (cdcooper
                           ,dtmvtolt
                           ,nrdconta
                           ,vlaplprv)
                     VALUES(pr_cdcooper            --> Cooperativa conectada
                           ,rw_crapdat.dtmvtolt    --> Data atual
                           ,rw_craprda.nrdconta    --> Conta da aplica��o
                           ,ROUND(vr_vlsldrdc,2)); --> Saldo final do m�s
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao '||vr_dsopera||' as informa��es na tabela CRAPBDN - Conta:'
                            || rw_craprda.nrdconta ||' Aplic:'||rw_craprda.nraplica||'. Detalhes: '||sqlerrm;
              RAISE vr_exc_undo;
            END;
          END IF;
          -- Prazo em dias � a diferen�a entre a data de vencimento - data atual da aplica��o
          vr_prazodia := rw_craprda.dtvencto - rw_craprda.dtmvtolt;
          -- Guardar o tipo de prazo cfme a diferen�a de dias
          FOR vr_ind IN vr_vet_periodo.FIRST..vr_vet_periodo.LAST LOOP
            -- Se a quantidade � inferior ou igual
            -- a quantidade da posi��o atual do vetor de per�odo
            IF vr_prazodia <= vr_vet_periodo(vr_ind) THEN
              -- Utilizaremos esta posi��o
              vr_tipprazo := vr_ind;
              -- Sair do LOOP
              EXIT;
            END IF;
            -- Se for o ultimo e ainda estamos neste ponto, � pq a quantidade
            -- � maior que o ultimo, ent�o utilizamos a ultima posi��o
            IF vr_ind = vr_vet_periodo.LAST THEN
              vr_tipprazo := vr_vet_periodo.LAST;
            END IF;
          END LOOP;
          /* -- Gravar a tabela craprej - Cadastro de rejeitos na integra��o --
          craprej.tpintegr - Tipo de relatorio (1-Prazo Medio)
          craprej.vllanmto - Totaliza valores por periodo de vencimento
          craprej.nrseqdig - Totaliza quantidade de aplicacoes por periodo
          craprej.tplotmov - Tipo de prazo (90, 180, 270 ...5400)
          creprej.cdempres = 7(RDPRE) e 8(RDCPOS)
          --------------------------------------------------------------------- */

          -- Atualiza a tabela temporario de rejeitados (antiga CRAPREJ fisica)
          vr_num_chave_craprej := LPad(rw_craprda.tpaplica,10,'0')||LPad(vr_tipprazo,5,'0');
          IF vr_tab_craprej.EXISTS(vr_num_chave_craprej) THEN
            vr_tab_craprej(vr_num_chave_craprej).vllanmto := vr_tab_craprej(vr_num_chave_craprej).vllanmto + vr_vlsdapat; --> Acumular valores calculados
            vr_tab_craprej(vr_num_chave_craprej).nrseqdig := vr_tab_craprej(vr_num_chave_craprej).nrseqdig + 1; --> Incrementar sequencial
          ELSE
            vr_tab_craprej(vr_num_chave_craprej).vllanmto := vr_vlsdapat; --> Acumular valores calculados
            vr_tab_craprej(vr_num_chave_craprej).nrseqdig := 1; --> Incrementar sequencial
          END IF;

          -- Montar chave para grava��o na tt BNDES(Conta+TipAplica)
          vr_des_chave_bndes := LPAD(rw_craprda.nrdconta,8,'0')||rw_craprda.tpaplica;
          -- Atualizar o registro na tabela(se n�o existir o pr�prio ASSIGN j� cria)
          vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta := rw_craprda.nrdconta;
          vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica := rw_craprda.tpaplica;
          vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica := NVL(vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica,0) + vr_vlsdapat;
          vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta := rw_craprda.nrdconta;
          -- Criar novo registro de detalhe
          pc_cria_reg_detalhe(pr_nrdconta => rw_craprda.nrdconta
                             ,pr_nmprimtl => vr_tab_crapass(rw_craprda.nrdconta).nmprimtl
                             ,pr_nraplica => rw_craprda.nraplica
                             ,pr_tpaplrdc => rw_craprda.tpaplrdc
                             ,pr_dsaplica => rw_craprda.dsaplica
                             ,pr_dtvencto => rw_craprda.dtvencto
                             ,pr_tpaplica => rw_craprda.tpaplica
                             ,pr_cdageass => vr_tab_crapass(rw_craprda.nrdconta).cdagenci
                             ,pr_nmresage => vr_tab_crapass(rw_craprda.nrdconta).nmresage
                             ,pr_dtmvtolt => rw_craprda.dtmvtolt
                             ,pr_vlaplica => rw_craprda.vlaplica
                             ,pr_vlslfmes => rw_craprda.vlslfmes
                             ,pr_inaniver => rw_craprda.inaniver
                             ,pr_dtfimper => rw_craprda.dtfimper
                             ,pr_qtdiauti => rw_craprda.qtdiauti
                             ,pr_txaplica => rw_craplap.txaplica);
          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informacoes no banco de dados a cada
            -- 10.000 registros processados, gravar tbm o controle
            -- de restart, pois qualquer rollback que ser� efetuado
            -- vai retornar a situa��o at� o ultimo commit
            -- Obs. Descontamos da quantidade atual, a quantidade
            --      que n�o foi processada devido a estes registros
            --      terem sido processados anteriormente ao restart
            IF Mod(cr_craprda%ROWCOUNT-vr_qtregres,10000) = 0 THEN

              -- Armazenar o conteudo de restart anterior
              -- Obs: quando n�o existe ainda, incluir espa�os para
              --      garantir pelo menos as 34 primeiras posi��es da string
              vr_dsrestar := NVL(rw_crapres.dsrestar,RPad(' ',34,' '));
              -- Buscar todos os tipos de aplica��o da tabela de resumo
              vr_num_chave_resumo := vr_tab_resumo.FIRST;
              LOOP
                -- Sair quando a chave estiver vezia (final da tabela)
                EXIT WHEN vr_num_chave_resumo IS NULL;
                -- Para RDC Pr�
                IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 1  THEN
                  -- Manter as primeiras 7 posi��es
                  -- E incluir o tipo, quantidade e saldo da aplica��o atual a partir da 8 posi��o
                  vr_dsrestar := SUBSTR(vr_dsrestar,1,7) || to_char(vr_tab_resumo(vr_num_chave_resumo).tpaplica,'fm00')||' '
                                                         || to_char(vr_tab_resumo(vr_num_chave_resumo).qtaplati,'fm000000')||' '
                                                         || to_char(vr_tab_resumo(vr_num_chave_resumo).vlsdapat,'000000000000D00')||' '
                                                         || SUBSTR(vr_dsrestar,35);
                -- Para RDC P�s
                ELSIF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
                  -- Manter as primeiras 34 posi��es
                  -- E incluir o tipo, quantidade e saldo da aplica��o atual a partir da 35 posi��o
                  vr_dsrestar := SUBSTR(vr_dsrestar,1,34) || to_char(vr_tab_resumo(vr_num_chave_resumo).tpaplica,'fm00')||' '
                                                          || to_char(vr_tab_resumo(vr_num_chave_resumo).qtaplati,'fm000000')||' '
                                                          || to_char(vr_tab_resumo(vr_num_chave_resumo).vlsdapat,'000000000000D00')||' ';
                END IF;
                -- Buscar o pr�ximo registro da tab resumo
                vr_num_chave_resumo := vr_tab_resumo.NEXT(vr_num_chave_resumo);
              END LOOP;
              -- Incluir nas 7 primeiras posi��es o n�mero da aplica��o e um espa�o e o restante permanece igual
              vr_dsrestar := LPAD(rw_craprda.nraplica,6,'0')||' '||SUBSTR(vr_dsrestar,8);
              -- Atualizar a tabela de restart
              BEGIN
                UPDATE crapres res
                   SET res.nrdconta = rw_craprda.nrdconta  -- conta da aplica��o atual
                      ,res.dsrestar = vr_dsrestar          -- descri��o gen�rica com dados das aplica��es para restart
                 WHERE res.rowid = rw_crapres.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  pr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta:'||rw_craprda.nrdconta
                              ||' Aplic:'||rw_craprda.nraplica||'. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
              END;
              -- Finalmente efetua commit
              COMMIT;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_next THEN
            -- Exception criada para desviar o fluxo para c� e
            -- n�o processar o restante das instru��es ap�s o RAISE
            -- pois o registro atual j� havia sido processado antes do restart
            -- Obs. Apenas acumulamos a quantidade de registros j� processado
            vr_qtregres := vr_qtregres + 1;
          WHEN vr_exc_undo THEN
            -- Desfazer transacoes desde o ultimo commit
            ROLLBACK;
            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_erro;
        END;
      END LOOP; --> Fim loop cr_craprda

      -- Efetuar Commit de informa��es pendentes de grava��o
      COMMIT;
      -- Chamar rotina para elimina��o do restart para evitarmos
      -- reprocessamento das aplica��es indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> C�digo do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => pr_dscritic); --> Sa�da de erro
      -- Testar sa�da de erro
      IF pr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_erro;
      END IF;

      -- Varrer o vetor de aplica��es para o BNDES
      vr_des_chave_bndes := vr_tab_cta_bndes.FIRST;
      LOOP
        -- Sair quando encontrar uma chave nulla
        EXIT WHEN vr_des_chave_bndes IS NULL;
        -- Para cada registro, ir� atualizar a tabela crapprb - Prazos de retornos
        -- de produtor para levamento de informa��es do BNDES
        DECLARE
          vr_dsopera VARCHAR2(30);
        BEGIN
          -- Tenta atualizar as informa��es
          vr_dsopera := 'Atualizar';
          UPDATE crapprb
             SET vlretorn = NVL(vlretorn,0) + vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica
           WHERE cdcooper = pr_cdcooper         --> Cooperativa conectada
             AND dtmvtolt = rw_crapdat.dtmvtolt --> Data atual
             AND cddprazo = 0                   --> Somente no prazo 0
             AND nrdconta = vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta
             AND cdorigem = vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica;
          -- Se n�o conseguiu atualizar nenhum registro
          IF SQL%ROWCOUNT = 0 THEN
            -- N�o encontrou nada para atualizar, ent�o inserimos
            vr_dsopera := 'Inserir';
            INSERT INTO crapprb
                       (cdcooper
                       ,dtmvtolt
                       ,nrdconta
                       ,cdorigem
                       ,cddprazo
                       ,vlretorn)
                 VALUES(pr_cdcooper            --> Cooperativa conectada
                       ,rw_crapdat.dtmvtolt    --> Data atual
                       ,vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta
                       ,vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica
                       ,0
                       ,vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao '||vr_dsopera||' as informa��es na tabela CRAPPRB. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        -- Buscar o pr�ximo registro
        vr_des_chave_bndes := vr_tab_cta_bndes.NEXT(vr_des_chave_bndes);
      END LOOP;

      -- Para execu��o somente quando Coop = 3 - Cecred
      IF pr_cdcooper = 3 THEN
        -- Buscar todos os associados (Cooperativas) da Cecred
        -- com registro na craprej de 2 - Provis�o RDC Pos
        FOR rw_craprej IN cr_craprej_cecred LOOP
          -- Para cada registro, criaremos o resumo Cecred
          vr_tab_resumo_cecred(rw_craprej.nrdconta).nrdconta := rw_craprej.nrdconta;
          vr_tab_resumo_cecred(rw_craprej.nrdconta).nmrescop := rw_craprej.nmrescop;
          vr_tab_resumo_cecred(rw_craprej.nrdconta).qtaplati := NVL(rw_craprej.nrseqdig,0);
          vr_tab_resumo_cecred(rw_craprej.nrdconta).vlprvmes := 0;
          vr_tab_resumo_cecred(rw_craprej.nrdconta).vlrenmes := 0;
          vr_tab_resumo_cecred(rw_craprej.nrdconta).vlajuprv := 0;
        END LOOP;
      END IF;
      -- Busca dos lan�amentos do m�s com aplica�ao do tipo RDC Pr� e P�s
      -- para cria��o dos registros de resumo
      FOR rw_craplap IN cr_craplap_mes LOOP
        -- Verificar se j� existe o registro para relat�rio detalhado
        IF rw_craplap.insaqtot = 0 THEN
          -- Chamar a cria��o de registro de detalhe
          pc_cria_reg_detalhe(pr_nrdconta => rw_craplap.nrdconta
                             ,pr_nmprimtl => vr_tab_crapass(rw_craplap.nrdconta).nmprimtl
                             ,pr_nraplica => rw_craplap.nraplica
                             ,pr_tpaplrdc => rw_craplap.tpaplrdc
                             ,pr_dsaplica => rw_craplap.dsaplica
                             ,pr_dtvencto => rw_craplap.dtvencto
                             ,pr_tpaplica => rw_craplap.tpaplica
                             ,pr_cdageass => vr_tab_crapass(rw_craplap.nrdconta).cdagenci
                             ,pr_nmresage => vr_tab_crapass(rw_craplap.nrdconta).nmresage
                             ,pr_dtmvtolt => rw_craplap.rda_dtmvtolt
                             ,pr_vlaplica => rw_craplap.vlaplica
                             ,pr_vlslfmes => rw_craplap.vlslfmes
                             ,pr_inaniver => rw_craplap.inaniver
                             ,pr_dtfimper => rw_craplap.dtfimper
                             ,pr_qtdiauti => rw_craplap.qtdiauti
                             ,pr_txaplica => rw_craplap.txaplica);
        END IF;
        /*** ---------------------------------------------------------- ***/
        /*** Se for uma aplicacao RDCPOS deve-se verificar quantos dias ***/
        /*** faltam para o vencimento da aplicacao, pois no relatorio   ***/
        /*** analitico serao listadas primeiro as aplicacoes com vencto ***/
        /*** ate 360 dias e depois listadas as aplicacoes com vencto    ***/
        /*** maior que 360 dias                                         ***/
        /*** ---------------------------------------------------------- ***/
        IF rw_craplap.tpaplrdc = 1 -- RDCPRE
        OR (rw_craplap.tpaplrdc = 2 AND rw_craplap.dtvencto - rw_crapdat.dtmvtolt <= 360) THEN -- RDC Pos com menos de 1 ano
          vr_indvecto := 1; -- N�o venceu ainda
        ELSE
          vr_indvecto := 2; -- J� venceu
        END IF;
        -- Montar a chave TpAplica | Agencia | IndVcto | Conta | Aplica
        vr_des_chave_det := rw_craplap.tpaplica || LPAD(rw_craplap.cdageass,3,'0') || vr_indvecto || LPAD(rw_craplap.nrdconta,8,'0') || LPAD(rw_craplap.nraplica,6,'0');
        -- Criar ou apenas atualiza o registro de resumo
        vr_tab_resumo(rw_craplap.tpaplica).tpaplica := rw_craplap.tpaplica;
        vr_tab_resumo(rw_craplap.tpaplica).dsaplica := rw_craplap.dsaplica;
        vr_tab_resumo(rw_craplap.tpaplica).tpaplrdc := rw_craplap.tpaplrdc;

        -- Criar o registro caso o mesmo n�o exista
        IF NOT vr_tab_fisjur(1).exists(rw_craplap.tpaplica) THEN
          -- Criar o registro para pessoa f�sica e juridica
          vr_tab_fisjur(1)(rw_craplap.tpaplica) := vr_tab_resumo(rw_craplap.tpaplica);
          vr_tab_fisjur(2)(rw_craplap.tpaplica) := vr_tab_resumo(rw_craplap.tpaplica);
        END IF;

        -- Para execu��o somente quando Coop = 3 - Cecred com aplica��o RDC Pos
        IF pr_cdcooper = 3 AND rw_craplap.tpaplrdc = 2 THEN
          -- Se ainda n�o existir registro para essa conta
          IF NOT vr_tab_resumo_cecred.EXISTS(rw_craplap.nrdconta) THEN

            -- Criaremos o resumo Cecred ou atualizar� em caso de j� existir
            vr_tab_resumo_cecred(rw_craplap.nrdconta).nrdconta := rw_craplap.nrdconta;
            vr_tab_resumo_cecred(rw_craplap.nrdconta).nmrescop := vr_tab_crapass(rw_craplap.nrdconta).nmrescop;
            vr_tab_resumo_cecred(rw_craplap.nrdconta).qtaplati := 0;
            vr_tab_resumo_cecred(rw_craplap.nrdconta).vlprvmes := 0;
            vr_tab_resumo_cecred(rw_craplap.nrdconta).vlrenmes := 0;
            vr_tab_resumo_cecred(rw_craplap.nrdconta).vlajuprv := 0;
          END IF;

          OPEN cr_crapsda(pr_cdcooper
                         ,rw_craplap.nrdconta
                         ,rw_crapdat.dtmvtoan
                         ,rw_crapdat.dtmvtolt);
         FETCH cr_crapsda
          INTO vr_tab_resumo_cecred(rw_craplap.nrdconta).vlsldmed;
         CLOSE cr_crapsda;

        END IF;
        -- Para lan�amentos 473 APLIC.RDCPRE e 528 APLIC.RDCPOS
        IF rw_craplap.cdhistor IN(473,528) THEN
          -- Atualizar campos espec�ficos
          vr_tab_resumo(rw_craplap.tpaplica).qtaplmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).qtaplmes,0) + 1;
          vr_tab_resumo(rw_craplap.tpaplica).vlaplmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlaplmes,0) + rw_craplap.vlaplica;

          BEGIN
            -- gravar as informa��es por tipo de pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).qtaplmes :=
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).qtaplmes,0) + 1;
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlaplmes :=
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlaplmes,0) + rw_craplap.vlaplica;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).qtaplmes := 1;
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlaplmes := rw_craplap.vlaplica;
          END;

        -- Para aplica��es ainda n�o vencidas e
        -- lan�amentos 477 RESG.RDC e 534 RESG.RDC
        ELSIF rw_craplap.dtvencto <= rw_craplap.dtmvtolt AND rw_craplap.cdhistor IN(477,534) THEN
          -- Atualizar campos espec�ficos
          vr_tab_resumo(rw_craplap.tpaplica).vlresmes := vr_tab_resumo(rw_craplap.tpaplica).vlresmes + rw_craplap.vllanmto;
          -- Se ainda n�o foi sacado totalmente
          IF rw_craplap.insaqtot = 0 THEN
            -- Acumular resgate no registro de detalhe
            vr_tab_detalhe(vr_des_chave_det).vlrgtmes := NVL(vr_tab_detalhe(vr_des_chave_det).vlrgtmes,0) + rw_craplap.vllanmto;
          END IF;

          BEGIN
            -- gravar as informa��es por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlresmes :=
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlresmes,0) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlresmes := rw_craplap.vllanmto;
          END;

        -- Para aplica��es vencidas e
        -- lan�amentos 477 RESG.RDC e 534 RESG.RDC
        ELSIF rw_craplap.dtvencto > rw_craplap.dtmvtolt AND rw_craplap.cdhistor IN(477,534) THEN
          -- Se ainda n�o foi sacado totalmente
          IF rw_craplap.insaqtot = 0 THEN
            -- Acumular resgate no registro de detalhe
            vr_tab_detalhe(vr_des_chave_det).vlrgtmes := NVL(vr_tab_detalhe(vr_des_chave_det).vlrgtmes,0) + rw_craplap.vllanmto;
          END IF;
          -- Somente para o 477
          IF rw_craplap.cdhistor = 477 THEN
            -- Acumular sqsren
            vr_tab_resumo(rw_craplap.tpaplica).vlsqsren := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlsqsren,0) + rw_craplap.vllanmto;

            BEGIN
              -- gravar as informa��es por tipo pessoa
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren :=
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren,0) + rw_craplap.vllanmto;
            EXCEPTION
              WHEN no_data_found THEN
                vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren := rw_craplap.vllanmto;
            END;
          ELSE --> para o 534
            -- Verificar se existe lan�amento com hist�rico 532
            vr_num_exis := 0;
            OPEN cr_craplap_histor(pr_nrdconta => rw_craplap.nrdconta
                                  ,pr_nraplica => rw_craplap.nraplica
                                  ,pr_cdhistor => 532
                                  ,pr_dtmvtolt => rw_craplap.dtmvtolt);
            FETCH cr_craplap_histor
             INTO vr_num_exis;
            CLOSE cr_craplap_histor;
            -- Se tiver encontrado somente 1
            IF vr_num_exis = 1 THEN
              -- Acumular no sq com rendimento
              vr_tab_resumo(rw_craplap.tpaplica).vlsqcren := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlsqcren,0) + rw_craplap.vllanmto;

              BEGIN
                -- gravar as informa��es por tipo pessoa
                vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqcren :=
                    nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqcren,0) + rw_craplap.vllanmto;
              EXCEPTION
                WHEN no_data_found THEN
                  vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqcren := rw_craplap.vllanmto;
              END;
            ELSE
              -- Acumular no sq sem rendimento
              vr_tab_resumo(rw_craplap.tpaplica).vlsqsren := nvl(vr_tab_resumo(rw_craplap.tpaplica).vlsqsren,0) + rw_craplap.vllanmto;

              BEGIN
                -- gravar as informa��es por tipo pessoa
                vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren :=
                    nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren,0) + rw_craplap.vllanmto;
              EXCEPTION
                WHEN no_data_found THEN
                  vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren := rw_craplap.vllanmto;
              END;
            END IF;
          END IF;
        -- Para lan�amentos 475 RENDIMENTO e 532 RENDIMENTO
        ELSIF rw_craplap.cdhistor IN(475,532) THEN
          -- Acumular no valor rendimento m�s
          vr_tab_resumo(rw_craplap.tpaplica).vlrenmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlrenmes,0) + rw_craplap.vllanmto;

          BEGIN
            -- gravar as informa��es por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrenmes :=
                nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrenmes,0) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrenmes := rw_craplap.vllanmto;
          END;

          -- Se existir registro na resumo_cecred
          IF vr_tab_resumo_cecred.EXISTS(rw_craplap.nrdconta) THEN
            -- Acumular tbm
            vr_tab_resumo_cecred(rw_craplap.nrdconta).vlrenmes := NVL(vr_tab_resumo_cecred(rw_craplap.nrdconta).vlrenmes,0) + rw_craplap.vllanmto;
          END IF;
        -- Para lan�amentos 474 PROV. RDCPRE e 529 PROV. RDCPOS
        ELSIF rw_craplap.cdhistor IN(474,529) THEN
          -- Acumular valor de provis�o m�s
          vr_tab_resumo(rw_craplap.tpaplica).vlprvmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlprvmes,0) + rw_craplap.vllanmto;

          BEGIN
            -- gravar as informa��es por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvmes :=
                nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvmes,0) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvmes := rw_craplap.vllanmto;
          END;

          -- Gravar as informa��es por agencia
          BEGIN
            vr_tab_proage(rw_craplap.tpaplrdc)(vr_tab_crapass(rw_craplap.nrdconta).cdagenci)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) :=
                vr_tab_proage(rw_craplap.tpaplrdc)(vr_tab_crapass(rw_craplap.nrdconta).cdagenci)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_proage(rw_craplap.tpaplrdc)(vr_tab_crapass(rw_craplap.nrdconta).cdagenci)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) := rw_craplap.vllanmto;
          END;

          BEGIN
            -- Somar os totalizadores
            vr_tab_totpro(rw_craplap.tpaplrdc)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) :=
                vr_tab_totpro(rw_craplap.tpaplrdc)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_totpro(rw_craplap.tpaplrdc)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) := rw_craplap.vllanmto;
          END;

          -- Somente para o lote 8480
          IF rw_craplap.nrdolote = 8480 THEN
            -- Acumular provis�o lan�ado
            vr_tab_resumo(rw_craplap.tpaplica).vlprvlan := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlprvlan,0) + rw_craplap.vllanmto;

            BEGIN
              -- gravar as informa��es por tipo pessoa
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvlan :=
                  nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvlan,0) + rw_craplap.vllanmto;
            EXCEPTION
              WHEN no_data_found THEN
                vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvlan := rw_craplap.vllanmto;
            END;
          END IF;
          -- Se existir registro na resumo_cecred
          IF vr_tab_resumo_cecred.EXISTS(rw_craplap.nrdconta) THEN
            -- Acumular tbm
            vr_tab_resumo_cecred(rw_craplap.nrdconta).vlprvmes := NVL(vr_tab_resumo_cecred(rw_craplap.nrdconta).vlprvmes,0) + rw_craplap.vllanmto;
          END IF;
        -- Para lan�amentos 531 REVERSAO PRV e 463 REVERSAO PRV
        ELSIF rw_craplap.cdhistor IN(531,463) THEN
          -- Decrementar ajuste de previd�ncia
          vr_tab_resumo(rw_craplap.tpaplica).vlajuprv := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlajuprv,0) - rw_craplap.vllanmto;

          BEGIN
            -- gravar as informa��es por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlajuprv :=
                nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlajuprv,0) - rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlajuprv := (0 - rw_craplap.vllanmto);
          END;
          -- Se existir registro na resumo_cecred
          IF vr_tab_resumo_cecred.EXISTS(rw_craplap.nrdconta) THEN
            -- Decrementar tbm
            vr_tab_resumo_cecred(rw_craplap.nrdconta).vlajuprv := NVL(vr_tab_resumo_cecred(rw_craplap.nrdconta).vlajuprv,0) - rw_craplap.vllanmto;
          END IF;
        -- Para lan�amentos 476 IRRF e 533 IRRF
        ELSIF rw_craplap.cdhistor IN(476,533) THEN
          -- Acumular IRRF
          vr_tab_resumo(rw_craplap.tpaplica).vlrtirrf := vr_tab_resumo(rw_craplap.tpaplica).vlrtirrf + rw_craplap.vllanmto;

          BEGIN
            -- gravar as informa��es por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrtirrf :=
                nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrtirrf,0) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrtirrf := rw_craplap.vllanmto;
          END;
        END IF;
      END LOOP;

      -- Busca do diret�rio base da cooperativa para a gera��o de relat�rios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl
      -- Iniciar extra��o dos dados para gera��o dos relat�rios de resumo
      vr_num_chave_resumo := vr_tab_resumo.FIRST;
      LOOP
        -- Sair quando a chave estiver vezia (final da tabela)
        EXIT WHEN vr_num_chave_resumo IS NULL;
        -- Inicializar o CLOB (XML)
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        vr_Bufdes_xml := null;
        -- Inicilizar as informa��es do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
        -- Montar a tag do tipo de aplica��o atual
        pc_escreve_xml('<tipoAplica id="'||vr_num_chave_resumo||'" desTpApli="'||vr_tab_resumo(vr_num_chave_resumo).dsaplica||'">');
        -- Para RDC pr�
        IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 1 THEN
          -- Efetuar busca na craprej com vr_cdempres = 7 /* RDCPRE */
          vr_cdempres := 7;
          -- Relat�rio CRRL454
          vr_nom_arquivo := 'crrl454.lst';
          vr_sqcabrel    := 1;
        -- Para RDC P�s
        ELSIF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
          -- Efetuar busca na craprej com vr_cdempres = 8 /* RDCPOS */
          vr_cdempres := 8;
          -- Relat�rio crrl455
          vr_nom_arquivo := 'crrl455.lst';
          vr_sqcabrel    := 2;
        END IF;
        -- Dever� utilizar o mesmo JASPER para ambos os relat�rio
        vr_dsjasper    := 'crrl455.jasper';
        vr_nmformul    := '132col';
        vr_qtcoluna    := 132;

        -- Criar tags agrupadora de totais
        pc_escreve_xml('<totais>');
        -- Enviar cada informa��es de totais como um n�
        -- para que o relat�rio possa se din�mico
        pc_cria_node_total(pr_des_total => 'QUANTIDADE DE TITULOS ATIVOS:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).qtaplati,0)   ,'fm999g990')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).qtaplati,0),'fm999g990')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).qtaplati,0),'fm999g990'));
        pc_cria_node_total(pr_des_total => 'QUANTIDADE DE TITULOS APLICADOS NO MES:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).qtaplmes,0)   ,'fm999g990')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).qtaplmes,0),'fm999g990')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).qtaplmes,0),'fm999g990'));
        pc_cria_node_total(pr_des_total => 'SALDO TOTAL DOS TITULOS ATIVOS:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlsdapat,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlsdapat,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlsdapat,0),'fm999g999g999g990d00mi'));
        pc_cria_node_total(pr_des_total => 'VALOR TOTAL APLICADO NO MES:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlaplmes,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlaplmes,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlaplmes,0),'fm999g999g999g990d00mi'));
        pc_cria_node_total(pr_des_total => 'RENDIMENTO CREDITADO NO MES:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlrenmes,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlrenmes,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlrenmes,0),'fm999g999g999g990d00mi'));
        pc_cria_node_total(pr_des_total => 'VALOR TOTAL DA PROVISAO DO MES:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlprvmes,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlprvmes,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlprvmes,0),'fm999g999g999g990d00mi'));
        pc_cria_node_total(pr_des_total => 'AJUSTE DE PROVISAO NO MES:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlajuprv,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlajuprv,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlajuprv,0),'fm999g999g999g990d00mi'));
        pc_cria_node_total(pr_des_total => 'RESGATES DOS TITULOS VENCIDOS NO MES:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlresmes,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlresmes,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlresmes,0),'fm999g999g999g990d00mi'));
        pc_cria_node_total(pr_des_total => 'SAQUES SEM RENDIMENTO:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlsqsren,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlsqsren,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlsqsren,0),'fm999g999g999g990d00mi'));


        FOR ind IN vr_tab_fisjur.first..vr_tab_fisjur.last LOOP
          dbms_output.put_line(TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlsdapat,0),'fm999g999g999g990d00mi'));
        END LOOP;


        -- Somente para P�s
        IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
          pc_cria_node_total(pr_des_total => 'SAQUES COM RENDIMENTO:'
                            ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlsqcren,0)   ,'fm999g999g999g990d00mi')
                            ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlsqcren,0),'fm999g999g999g990d00mi')
                            ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlsqcren,0),'fm999g999g999g990d00mi'));
        END IF;
        pc_cria_node_total(pr_des_total => 'IMPOSTO DE RENDA RETIDO NA FONTE:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlrtirrf,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlrtirrf,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlrtirrf,0),'fm999g999g999g990d00mi'));
        -- Fechar tags de totais
        pc_escreve_xml('</totais>');
        -- Iniciar Tag de per�odos
        pc_escreve_xml('<periodos>');
        -- Reinicializar totalizadores
        vr_tot_vlacumul := 0;
        -- Buscar todos os per�odos do vetor de per�odos
        FOR vr_per IN vr_vet_periodo.FIRST..vr_vet_periodo.LAST LOOP
          -- Somente no per�odo 19 (Ultimo)
          IF vr_per = 19 THEN
            -- Utilizar "MAIS de"
            vr_des_periodo := 'MAIS de '||(vr_vet_periodo(vr_per)-1);
          ELSE
            -- Utilizar "ATE"
            vr_des_periodo := 'ATE '||vr_vet_periodo(vr_per);
          END IF;

          -- Buscar dados na tabela temporario de rejeitados (antiga craprej), caso tenha sido gravado algo para este per�odo
          vr_num_chave_craprej := LPad(vr_cdempres,10,'0')||LPad(vr_per,5,'0');

          -- Ao encontrar
          IF vr_tab_craprej.EXISTS(vr_num_chave_craprej) THEN
            -- Acumular total
            vr_tot_vlacumul := vr_tot_vlacumul + NVL(vr_tab_craprej(vr_num_chave_craprej).vllanmto,0);
            -- Enviar ao XML os dados encontrados
            pc_escreve_xml('<periodo>'
                         ||'  <dsper>'||vr_des_periodo||'</dsper>'                         --> PERIODO VCTO/DIAS
                         ||'  <vllcto>'||to_char(NVL(vr_tab_craprej(vr_num_chave_craprej).vllanmto,0),'fm999g999g999g990d00')||'</vllcto>' --> VALOR
                         ||'  <vllctoac>'||to_char(NVL(vr_tot_vlacumul,0),'fm999g999g999g990d00')||'</vllctoac>'        --> VALOR ACUMULADO
                         ||'  <qtaplica>'||to_char(NVL(vr_tab_craprej(vr_num_chave_craprej).nrseqdig,0),'fm999g990')||'</qtaplica>'        --> QTD.RDC
                         ||'</periodo>');
          ELSE
            -- Enviar ao XML um registro em branco
            pc_escreve_xml('<periodo>'
                         ||'  <dsper>'||vr_des_periodo||'</dsper>' --> PERIODO VCTO/DIAS
                         ||'  <vllcto>'||to_char(0,'fm0d00')||'</vllcto>'                       --> VALOR
                         ||'  <vllctoac>'||to_char(0,'fm0d00')||'</vllctoac>'                   --> VALOR ACUMULADO
                         ||'  <qtaplica>'||to_char(0,'fm0')||'</qtaplica>'                      --> QTD.RDC
                         ||'</periodo>');
          END IF;
          -- Para cooperativas <> Cecred com valor de lan�amento
          IF vr_tab_craprej.EXISTS(vr_num_chave_craprej) AND pr_cdcooper <> 3 AND NVL(vr_tab_craprej(vr_num_chave_craprej).vllanmto,0) > 0 THEN
            -- Criar os registro na tabela de prazos de retornos do BNDES
            DECLARE
              vr_cddprazo NUMBER; -- Quantidade de dias cfme per�odo encontrado
            BEGIN
              -- Buscar a quantidade de dias cfme o prazo passado
              vr_cddprazo := vr_vet_periodo(vr_per);
              -- Finalmente insere na tabela
              INSERT INTO crapprb
                         (cdcooper
                         ,dtmvtolt
                         ,nrdconta
                         ,cdorigem
                         ,cddprazo
                         ,vlretorn)
                   VALUES(3                            --> Sempre gravar na Cecred
                         ,rw_crapdat.dtmvtolt          --> Programa atual
                         ,rw_crapcop.nrctactl          --> Conta da cooperativa conectda
                         ,vr_cdempres                  --> DCPRE = 7 e RDCPOS = 8
                         ,vr_cddprazo                  --> Dias do prazo passado
                         ,vr_tab_craprej(vr_num_chave_craprej).vllanmto); --> Valor enviado
            EXCEPTION
              WHEN dup_val_on_index THEN
                -- enviar log ao batch e n�o parar o processo, pois segundo o Guilherme Strube
                -- no Progress n�o estava sendo tratado provavelmente pq nunca gerava erro, j�
                -- que � feita apenas uma execu��o por dia
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> Chave duplicada ao inserir na CRAPPRB '
                                                           || '(Cdcooper = 3, Dtmvtolt = '||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||', Nrdconta = '||gene0002.fn_mask_conta(rw_crapcop.nrctactl)
                                                           || ', Cdorigem = '||vr_cdempres||', Cddprazo = '||vr_cddprazo||', Vlretorn = '||vr_tab_craprej(vr_num_chave_craprej).vllanmto||').');
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao inserir as informa��es na tabela CRAPPRB. Detalhes: '||sqlerrm;
                RAISE vr_exc_erro;
            END;
          END IF;
        END LOOP;
        -- Fechar a tag de per�odos
        pc_escreve_xml('</periodos>');
        -- Somente para P�s
        IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
          -- Abrir tag resumos
          pc_escreve_xml('<resumo_cecred>');
          -- Buscar o primeiro indice da tabela resumo-cecred
          vr_num_chave_resumo_cecred := vr_tab_resumo_cecred.FIRST;
          -- Buscar as informa��es do Resumo-Cecred
          LOOP
            -- Sair quando o indice estiver null
            EXIT WHEN vr_num_chave_resumo_cecred IS NULL;
            -- Enviar o registro de resumo
            pc_escreve_xml('<resumo>'
                         ||'  <nrdconta>'||gene0002.fn_mask_conta(vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).nrdconta)||'</nrdconta>'         --> CONTA/DV
                         ||'  <nmrescop>'||vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).nmrescop||'</nmrescop>'                                 --> TITULAR
                         ||'  <qtaplati>'||to_char(NVL(vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).qtaplati,0),'fm999g990')||'</qtaplati>'            --> QT.TITULOS
                         ||'  <vlrenmes>'||to_char(NVL(vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).vlrenmes,0),'fm999g999g999g990d00')||'</vlrenmes>'   --> RENDIMENTO
                         ||'  <vlprvmes>'||to_char(NVL(vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).vlprvmes,0),'fm999g999g999g990d00')||'</vlprvmes>' --> AJUSTE PROVISAO
                         ||'  <vlajuprv>'||to_char(NVL(vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).vlajuprv,0),'fm999g999g999g990d00')||'</vlajuprv>' --> TOTAL PROVISAO
                         ||'  <vlsldmed>'||to_char(NVL(vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).vlsldmed,0),'fm999g999g999g990d00')||'</vlsldmed>' --> SALDO M�DIO RDCPOS
                         ||'</resumo>');
            -- Buscar o pr�ximo indice
            vr_num_chave_resumo_cecred := vr_tab_resumo_cecred.NEXT(vr_num_chave_resumo_cecred);
          END LOOP;
          -- Fechar tag de resumos
          pc_escreve_xml('</resumo_cecred>');
        END IF;
        -- Fechar as tags abertas
        pc_escreve_xml('</tipoAplica></raiz>',true);

        -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz/tipoAplica' --> N� base do XML para leitura dos dados
                                   ,pr_dsjasper  => vr_dsjasper         --> Arquivo de layout do iReport
                                   ,pr_dsparams  => 'PR_CDCOOPER##'||pr_cdcooper||'@@PR_MESREF##'||gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'||to_char(rw_crapdat.dtmvtolt,'rrrr') --> Coop e M�s de referencia
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo --> Arquivo final co
                                   ,pr_qtcoluna  => vr_qtcoluna         --> 80 08 234 colunas
                                   ,pr_flg_gerar => 'N'                 --> Gera�ao na hora
                                   ,pr_flg_impri => 'S'                 --> Chamar a impress�o (Imprim.p)
                                   ,pr_nmformul  => vr_nmformul         --> Nome do formul�rio para impress�o
                                   ,pr_nrcopias  => 1                   --> N�mero de c�pias
                                   ,pr_sqcabrel  => vr_sqcabrel         --> Qual a seq do cabrel
                                   ,pr_des_erro  => pr_dscritic);       --> Sa�da com erro

        -- Liberando a mem�ria alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        -- Testar se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exce��o
          RAISE vr_exc_erro;
        END IF;
        -- Buscar o pr�ximo registro da tab resumo
        vr_num_chave_resumo := vr_tab_resumo.NEXT(vr_num_chave_resumo);
      END LOOP;

      -- Se for uma virada de m�s, emitir o arquivo para contabilidade
      IF trunc(rw_crapdat.dtmvtopr,'MM') <> trunc(rw_crapdat.dtmvtolt,'MM') AND
         (vr_tab_totpes.COUNT() > 0 OR vr_tab_totpro.COUNT() > 0)          AND
         pr_cdcooper <> 3  THEN

        -- Inicializar o CLOB (XML) para o arquivo com informa��o das tarifas
        dbms_lob.createtemporary(vr_dsxmldad_arq, TRUE);
        dbms_lob.open(vr_dsxmldad_arq,dbms_lob.lob_readwrite);

        --------------------------------------------
        /***** SALDO TOTAL DOS TITULOS ATIVOS *****/
        --------------------------------------------

        -- Para cada tipo de aplica��o
        FOR indapl IN vr_tab_totpes.FIRST..vr_tab_totpes.LAST LOOP

          -- Para cada tipo de pessoa que constara no arquivo
          FOR indpes IN 1..2 LOOP

            -- Setar as vari�veis conforme tipo de aplica��o
            IF indapl = 1 THEN
              -- Setar as vari�veis conforme indice
              if indpes = 1 THEN
                -- pessoa fisica
                vr_nrctaori := 4253;
                vr_nrctades := 4273;
                vr_dsmensag := 'SALDO TOTAL DE TITULOS ATIVOS RDC PRE - COOPERADOS PESSOA FISICA';
              elsif indpes = 2 then
                -- pessoa juridica
                vr_nrctaori := 4253;
                vr_nrctades := 4274;
                vr_dsmensag := 'SALDO TOTAL DE TITULOS ATIVOS RDC PRE - COOPERADOS PESSOA JURIDICA';
              end if;
            ELSE
              -- Setar as vari�veis conforme indice
              if indpes = 1 then
                -- pessoa fisica
                vr_nrctaori := 4254;
                vr_nrctades := 4275;
                vr_dsmensag := 'SALDO TOTAL DE TITULOS ATIVOS RDC POS - COOPERADOS PESSOA FISICA';
              elsif indpes = 2 then
                -- pessoa juridica
                vr_nrctaori := 4254;
                vr_nrctades := 4276;
                vr_dsmensag := 'SALDO TOTAL DE TITULOS ATIVOS RDC POS - COOPERADOS PESSOA JURIDICA';
              end if;
            END IF;

            -- Para cada cada modalidade 1=Normal e 2=Revers�o
            FOR indmod IN 1..2 LOOP

              -- Se modo normal
              IF indmod = 1 THEN
                vr_dtmvtolt := rw_crapdat.dtmvtolt;
                vr_dsmsgarq := vr_dsmensag;
              ELSE
                -- Invers�o das contas
                vr_nrctaaux := vr_nrctaori;
                vr_nrctaori := vr_nrctades;
                vr_nrctades := vr_nrctaaux;

                vr_dtmvtolt := rw_crapdat.dtmvtopr;

                -- Incluir a palavra REVERSAO
                vr_dsmsgarq := vr_dsprefix||vr_dsmensag;
              END IF;

              -- Verifica se o valor existe
              IF vr_tab_totpes.EXISTS(indapl) THEN
                IF vr_tab_totpes(indapl).EXISTS(indpes) THEN
                  vr_vllinarq := vr_tab_totpes(indapl)(indpes);
                ELSE
                  vr_vllinarq := 0; -- Quando n�o existir atribui zero
                END IF;
              ELSE
                vr_vllinarq := 0; -- Quando n�o existir atribui zero
              END IF;

              -- Se o valor for maior que zero
              IF vr_vllinarq > 0 THEN

                /* Imprimir dados de pessoa FISICA */
                vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                            || ',' ||to_char(vr_dtmvtolt,'DDMMYY') || ','||vr_nrctaori||','||vr_nrctades||','
                            || to_char(vr_vllinarq,'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,')
                            || ',1434,"'|| vr_dsmsgarq ||'"'
                            || CHR(10);

                -- Escrever CLOB
                dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);

                -- Repetir as informa��es da agencia
                FOR repete IN 1..2 LOOP
                  -- Agencia
                  vr_cdagenci := vr_tab_resage(indapl).FIRST;

                  -- Percorrer para todas as agencias todos os dados de pessoa fisica e juridica
                  LOOP

                    -- Verifica se o valor existe
                    IF vr_tab_resage.EXISTS(indapl) THEN
                      IF vr_tab_resage(indapl).EXISTS(vr_cdagenci) THEN
                        IF vr_tab_resage(indapl)(vr_cdagenci).EXISTS(indpes) THEN

                          -- Monta a linha para o arquivo
                          vr_dslinarq := to_char(vr_cdagenci,'FM000')||','||
                                         to_char(vr_tab_resage(indapl)(vr_cdagenci)(indpes),'fm99999999990D00','NLS_NUMERIC_CHARACTERS=.,')||
                                         CHR(10);

                          -- Escrever a linha no CLOB
                          dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);
                        END IF; -- Testa tipo pessoa
                      END IF; -- Testa agencia
                    END IF; -- Testa aplica��o

                    EXIT WHEN vr_cdagenci = vr_tab_resage(indapl).LAST;
                    vr_cdagenci := vr_tab_resage(indapl).NEXT(vr_cdagenci);
                  END LOOP;
                END LOOP; -- Fim repete
              END IF; -- Se o total for maior que zero
            END LOOP; -- Normal e revers�o
          END LOOP; -- Pessoas 1 e 2
        END LOOP; -- Tipo de aplica��o


        --------------------------------------------
        /***** VALOR TOTAL DA PROVISAO DO MES *****/
        --------------------------------------------

        -- Para cada tipo de aplica��o
        FOR indapl IN vr_tab_totpro.FIRST..vr_tab_totpro.LAST LOOP

          -- Para cada tipo de pessoa que constara no arquivo
          FOR indpes IN 1..2 LOOP

            -- Setar as vari�veis conforme tipo de aplica��o
            IF indapl = 1 THEN
              -- Setar as vari�veis conforme indice
              if indpes = 1 THEN
                -- pessoa fisica
                vr_nrctaori := 8057;
                vr_nrctades := 8114;
                vr_dsmensag := 'PROVISAO DO MES - RDC PRE COOPERADOS PESSOA FISICA';
              elsif indpes = 2 then
                -- pessoa juridica
                vr_nrctaori := 8058;
                vr_nrctades := 8114;
                vr_dsmensag := 'PROVISAO DO MES - RDC PRE COOPERADOS PESSOA JURIDICA';
              end if;
            ELSE
              -- Setar as vari�veis conforme indice
              if indpes = 1 then
                -- pessoa fisica
                vr_nrctaori := 8060;
                vr_nrctades := 8118;
                vr_dsmensag := 'PROVISAO DO MES - RDC POS COOPERADOS PESSOA FISICA';
              elsif indpes = 2 then
                -- pessoa juridica
                vr_nrctaori := 8061;
                vr_nrctades := 8118;
                vr_dsmensag := 'PROVISAO DO MES - RDC POS COOPERADOS PESSOA JURIDICA';
              end if;
            END IF;

            -- Para cada cada modalidade 1=Normal e 2=Revers�o
            FOR indmod IN 1..2 LOOP

              -- Se modo normal
              IF indmod = 1 THEN
                vr_dtmvtolt := rw_crapdat.dtmvtolt;
                --
                vr_dsmsgarq := vr_dsmensag;
              ELSE
                -- Invers�o das contas
                vr_nrctaaux := vr_nrctaori;
                vr_nrctaori := vr_nrctades;
                vr_nrctades := vr_nrctaaux;

                vr_dtmvtolt := rw_crapdat.dtmvtopr;

                -- Incluir a palavra REVERSAO
                vr_dsmsgarq := vr_dsprefix||vr_dsmensag;
              END IF;

              -- Verifica se o valor existe
              IF vr_tab_totpro.EXISTS(indapl) THEN
                IF vr_tab_totpro(indapl).EXISTS(indpes) THEN
                  vr_vllinarq := vr_tab_totpro(indapl)(indpes);
                ELSE
                  vr_vllinarq := 0; -- Quando n�o existir atribui zero
                END IF;
              ELSE
                vr_vllinarq := 0; -- Quando n�o existir atribui zero
              END IF;

              -- Se o valor for maior que zero
              IF vr_vllinarq > 0 THEN

                /* Imprimir dados de pessoa FISICA */
                vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                            || ',' ||to_char(vr_dtmvtolt,'DDMMYY') || ','||vr_nrctaori||','||vr_nrctades||','
                            || to_char(vr_vllinarq,'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,')
                            || ',1434,"'|| vr_dsmsgarq ||'"'
                            || CHR(10);

                -- Escrever CLOB
                dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);

                -- Repetir as informa��es da agencia
                FOR repete IN 1..2 LOOP

                  -- Agencia
                  vr_cdagenci := vr_tab_proage(indapl).FIRST;

                  -- Percorrer para todas as agencias todos os dados de pessoa fisica e juridica
                  LOOP

                    -- Verifica se o valor existe
                    IF vr_tab_proage.EXISTS(indapl) THEN
                      IF vr_tab_proage(indapl).EXISTS(vr_cdagenci) THEN
                        IF vr_tab_proage(indapl)(vr_cdagenci).EXISTS(indpes) THEN

                          -- Monta a linha para o arquivo
                          vr_dslinarq := to_char(vr_cdagenci,'FM000')||','||
                                         to_char(vr_tab_proage(indapl)(vr_cdagenci)(indpes),'fm99999999990D00','NLS_NUMERIC_CHARACTERS=.,')||
                                         CHR(10);

                          -- Escrever a linha no CLOB
                          dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);
                        END IF; -- Testa tipo pessoa
                      END IF; -- Testa agencia
                    END IF; -- Testa aplica��o

                    EXIT WHEN vr_cdagenci = vr_tab_proage(indapl).LAST;
                    vr_cdagenci := vr_tab_proage(indapl).NEXT(vr_cdagenci);
                  END LOOP;
                END LOOP; -- fim repete
              END IF; -- Se valor total maior que zero
            END LOOP; -- Normal e revers�o
          END LOOP; -- Pessoas 1 e 2
        END LOOP; -- Tipo de aplica��o

        -- Buscar os diret�rios
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/contab');

        -- Define o nome do arquivo
        vr_nmarqrdc := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'_RDC.txt';

        -- Criar o arquivo de dados
        GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsxmldad_arq
                                     ,pr_caminho  => vr_nom_direto
                                     ,pr_arquivo  => vr_nmarqrdc
                                     ,pr_des_erro => vr_dscritic);

        --Liberando a mem�ria alocada pro CLOB
        dbms_lob.close(vr_dsxmldad_arq);
        dbms_lob.freetemporary(vr_dsxmldad_arq);

        -- Testa
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exce��o
          RAISE vr_exc_erro;
        END IF;
        
         -- Busca o diret�rio para contabilidade
        vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
        vr_dircon := vr_dircon || vc_dircon;
        vr_arqcon := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_RDC.txt';

        -- Executa comando UNIX para converter arq para Dos
        vr_dscomand := 'ux2dos ' || vr_nom_direto ||'/'||vr_nmarqrdc||' > '
                                 || vr_dircon ||'/'||vr_arqcon || ' 2>/dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomand
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

      -- Buscar novamente o diret�rio rl
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl');

      -- Iniciar extra��o dos dados para gera��o dos relat�rios detalhados
      vr_des_chave_det := vr_tab_detalhe.FIRST;
      LOOP
        -- Sair quando a chave n�o possuir mais nenhum informa��o
        EXIT WHEN vr_des_chave_det IS NULL;
        -- Se for o primeiro registro, ou se mudou o tipo de aplica��o
        IF vr_des_chave_det = vr_tab_detalhe.FIRST OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).tpaplica THEN
          -- Inicializar o CLOB (XML)
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          vr_Bufdes_xml := null;
          -- Inicilizar as informa��es do XML
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
          -- Para RDC pr�
          IF vr_tab_detalhe(vr_des_chave_det).tpaplrdc = 1 THEN
            -- Efetuar busca na craprej com vr_cdempres = 7 /* RDCPRE */
            vr_cdempres := 7;
            -- Utilizar crrl454
            vr_nom_arquivo := 'crrl477.lst';
            vr_dsjasper    := 'crrl477.jasper';
            vr_sqcabrel    := 3;
            vr_dsxmlnod    := '/raiz/tipoAplica/aplicacoes/agencia/aplica'; -- N� base do XML de dados
          -- Para RDC P�s
          ELSIF vr_tab_detalhe(vr_des_chave_det).tpaplrdc = 2 THEN
            -- Efetuar busca na craprej com vr_cdempres = 8 /* RDCPOS */
            vr_cdempres := 8;
            -- Utilizar crrl455
            vr_nom_arquivo := 'crrl478.lst';
            vr_dsjasper    := 'crrl478.jasper';
            vr_sqcabrel    := 4;
            vr_dsxmlnod    := '/raiz'; -- N� base do XML de dados
          END IF;
          -- Montar a tag do tipo de aplica��o atual
          pc_escreve_xml('<tipoAplica id="'||vr_tab_detalhe(vr_des_chave_det).tpaplica||'" desTpApli="'||vr_tab_detalhe(vr_des_chave_det).dsaplica||'"><aplicacoes>');
        END IF;
        -- Se for o primeiro ou mudou a ag�ncia ou tipo de vencimento
        IF vr_des_chave_det = vr_tab_detalhe.FIRST
        OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).tpaplica
        OR vr_tab_detalhe(vr_des_chave_det).cdagenci <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).cdagenci
        OR vr_tab_detalhe(vr_des_chave_det).indvecto <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).indvecto THEN
          -- Criar novo n� de ag�ncia / tipo vcto
          pc_escreve_xml('<agencia cdageass="'||vr_tab_detalhe(vr_des_chave_det).cdagenci||'" '
                       ||         'nmresage="'||vr_tab_detalhe(vr_des_chave_det).nmresage||'" '
                       ||         'indvecto="'||vr_tab_detalhe(vr_des_chave_det).indvecto||'">');
        END IF;
        -- Enviar o registro de detalhe ao XML
        pc_escreve_xml('<aplica>'
                     ||'  <nrdconta>'||ltrim(gene0002.fn_mask_conta(vr_tab_detalhe(vr_des_chave_det).nrdconta))||'</nrdconta>'
                     ||'  <nmprimtl>'||SUBSTR(vr_tab_detalhe(vr_des_chave_det).nmprimtl,1,32)||'</nmprimtl>'
                     ||'  <nraplica>'||ltrim(gene0002.fn_mask(vr_tab_detalhe(vr_des_chave_det).nraplica,'zzz.zz9'))||'</nraplica>'
                     ||'  <dtaplica>'||to_char(vr_tab_detalhe(vr_des_chave_det).dtaplica,'dd/mm/rr')||'</dtaplica>'
                     ||'  <dtvencto>'||to_char(vr_tab_detalhe(vr_des_chave_det).dtvencto,'dd/mm/rr')||'</dtvencto>'
                     ||'  <vlaplica>'||to_char(vr_tab_detalhe(vr_des_chave_det).vlaplica,'fm999g999g990d00')||'</vlaplica>'
                     ||'  <vlrgtmes>'||to_char(vr_tab_detalhe(vr_des_chave_det).vlrgtmes,'fm999g999g990d00')||'</vlrgtmes>'
                     ||'  <vlsldrdc>'||to_char(vr_tab_detalhe(vr_des_chave_det).vlsldrdc,'fm999g999g990d00')||'</vlsldrdc>'
                     ||'  <txaplica>'||to_char(vr_tab_detalhe(vr_des_chave_det).txaplica,'fm990d000000')||'</txaplica>'
                     ||'  <dssitapl>'||vr_tab_detalhe(vr_des_chave_det).dssitapl||'</dssitapl>'
                     ||'  <qtdiauti>'||vr_tab_detalhe(vr_des_chave_det).qtdiauti||'</qtdiauti>'
                     ||'</aplica>');
        -- Se for o ultimo ou ir� mudar a ag�ncia ou tipo de vencimento no pr�ximo
        IF vr_des_chave_det = vr_tab_detalhe.LAST
        OR vr_tab_detalhe(vr_des_chave_det).cdagenci <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).cdagenci
        OR vr_tab_detalhe(vr_des_chave_det).indvecto <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).indvecto
        OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).tpaplica THEN
          -- fechar n� de ag�ncia / tipo vcto
          pc_escreve_xml('</agencia>');
        END IF;
        -- Se for o ultimo registro do vetor ou do tipo de aplica��o
        IF vr_des_chave_det = vr_tab_detalhe.LAST OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).tpaplica THEN
          -- Fechar as tags abertas
          pc_escreve_xml('</aplicacoes></tipoAplica></raiz>',TRUE);
          -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--

          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                                     ,pr_dsxmlnode => vr_dsxmlnod                          --> N� base do XML para leitura dos dados
                                     ,pr_dsjasper  => vr_dsjasper                          --> Arquivo de layout do iReport
                                     ,pr_dsparams  => 'PR_CDCOOPER##'||pr_cdcooper         --> Somente Coop Conectada
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo   --> Arquivo final com o path
                                     ,pr_qtcoluna  => 234                                  --> 234 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Gera�ao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impress�o (Imprim.p)
                                     ,pr_nmformul  => '234col'                             --> Nome do formul�rio para impress�o
                                     ,pr_nrcopias  => 1                                    --> N�mero de c�pias
                                     ,pr_sqcabrel  => vr_sqcabrel                          --> Qual a seq do cabrel
                                     ,pr_des_erro  => pr_dscritic);                        --> Sa�da com erro
          -- Testar se houve erro
          IF pr_dscritic IS NOT NULL THEN
            -- Gerar exce��o
            RAISE vr_exc_erro;
          END IF;
          -- Liberando a mem�ria alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
        END IF;
        -- Buscar o pr�ximo registro
        vr_des_chave_det := vr_tab_detalhe.NEXT(vr_des_chave_det);
      END LOOP;

      -- Quando programa terminar de executar limpa tabela de controle
      BEGIN
        DELETE craprej rej
         WHERE rej.cdcooper = pr_cdcooper
           AND rej.cdpesqbb = vr_cdprogra;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro e fazer rollback
          pr_dscritic := 'Erro ao eliminar as informa��es de controle (CRAPREJ). Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps480;
/
