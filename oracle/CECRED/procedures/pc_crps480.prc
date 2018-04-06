CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS480(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
  /*..............................................................................

     Programa: pc_crps480 (Antigo fontes/crps480.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : David
     Data    : Maio/2007                       Ultima atualizacao: 16/01/2018

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

                 17/01/2011 - Alterada a coluna Total da Provisão para
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

                 20/02/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                 09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                              o restart (Marcos-Supero)

                 09/08/2013 - Troca da busca do mes por extenso com to_char para
                              utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

                 25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

                 03/02/2014 - criado temptable para armazenar associados, a fim de melhorar performace (Odirlei-AMcom)
                 
                 24/07/2014 - Atualizacao dos campos dtsdfmea e vlslfmea da craprda (Andrino-RKAM)
                            
                 11/11/2014 - Nova coluna de carência e convertido o relatório para paisagem. (Kelvin - Chamado 218644)

                 19/11/2014 - Adicionar validação para não gerar registro na CRAPLAP 
                              com valor zerado ou negativo (Douglas - Chamado 191418)
                              
                 22/04/2015 - Alteração para realizar a geração do relatório separado por PF e PJ, além de 
                              alterar o fonte para utilizar o mesmo jaspaer para os relatórios CRRL454 e CRRL455.
                              Projeto 186  ( Renato - Supero )
                              
                 16/09/2015 - SD334531 - Ajuste pois após geração do arquivo _RDC a variável vr_nom_direto persistia 
                              com o diretório contab, e não do rl que era o correto. (Marcos-Supero)

                 19/10/2015 - Ajuste nos relatorios para nao contabilizar informacoes nos PAs migrados
                              e gerar os dados corretamente no PA atual (SD326975 Tiago/Rodrigo)   
                              
                 03/12/2015 - Adicionado novo campo com a média dos saldos das aplicações rdcpos,
                              conforme solicitado no chamado 357115 (Kelvin)
                 
                 25/05/2016 - Ajuste no saldo medio pois estava trazendo os valores incorretos, conforme
                              solicitado no chamado 446559. (Kelvin)

                 10/06/2016 - Ajustado a leitura da craptab para utilizar a procedure padrao TABE0001.fn_busca_dstextab
                              e carregar as contas bloqueadas com a TABE0001.pc_carrega_ctablq
                              (Douglas - Chamado 454248)
                              

                 28/09/2016 - Alteração do diretório para geração de arquivo contábil.
                              P308 (Ricardo Linhares).                                    

                 11/10/2016 - Limpeza e inclusao de valor acumulado, na tabela
                              TBFIN_FLUXO_CONTAS_SYSPHERA. (Jaison/Marcos SUPERO)
                            
                 20/03/2017 - Remover linhas de reversão das contas de resultado e incluir
                              lançamentos de novos históricos para o arquivo Radar ou Matera (Jonatas - Supero)                            

                 13/11/2017 - Ao buscar na tabela craptab o acesso MXRENDIPOS, a validacao correta deveria ser
                              is null ao inves de is not null como estava antes. Como estava, nao considerava o parametro
                              de data de inicio da aplicacao da regra de poupanca, ocasionando provisoes incorretas.
                              Heitor (Mouts) - Chamado 781104

                 16/01/2018 - Alteração procedimento INSERT/UPDATE na tabela CRAPBND
                              Melhorias sustentação
                              As chamadas das rotinas GENE0002.pc_clob_para_arquivo e GENE0001.pc_OScommand
                              estavam retornando erros na variável vr_dscritic e desviando para a exception
                              vr_exc_erro, porém, esta exception só trata o parâmetro pr_dscritic -> Ajuste
                              (Ana - Envolti - Chamado 822997)

  ..............................................................................*/

    DECLARE
      -- Código do programa
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

      ---------------- Cursores genéricos ----------------

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

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Descricao da craptab
      vr_dstextab     craptab.dstextab%TYPE;

      -- Data de fim e inicio da utilizacao da taxa de poupanca.
      -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
      --  a poupanca, a cooperativa opta por usar ou nao.
      -- Buscar a descrição das faixas contido na craptab
      vr_dtinitax     DATE;                  --> Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax     DATE;                  --> Data de fim da utilizacao da taxa de poupanca.

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;--> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);       --> String genérica com informações para restart
      vr_inrestar INTEGER;              --> Indicador de Restart
      vr_nraplica INTEGER;              --> Número da aplicação do Restart
      vr_tpaplica INTEGER;              --> Tipo da aplicação do Restart
      vr_qtaplati INTEGER;              --> Qtdade de aplicações ativas no Restart
      vr_vlsdapat NUMBER;               --> Valores de saldo de aplicações ativas no Restart
      vr_qtregres NUMBER := 0;          --> Quantidade de registros ignorados por terem sido processados antes do restart

      ---------------- Definição de temp-tables da rotina  --------------

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
      vr_num_chave_craprej PLS_INTEGER; -- Será contatenado o cdempres e o tplotmov

      -- Definição do tipo de registro para o resumo (antiga w_resumo)
      TYPE typ_reg_resumo IS
        RECORD(tpaplica INTEGER
              ,tpaplrdc INTEGER
              ,dsaplica VARCHAR2(6)
              ,qtaplati NUMBER(6)    DEFAULT 0  -- "zzz,zz9"              "Qtde de titulos ativos"
              ,qtaplmes NUMBER(6)    DEFAULT 0  -- "zzz,zz9"              "Qtde de titulos aplicados no mes"
              ,vlsdapat NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Saldo total dos titulos ativos"
              ,vlaplmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Valor total aplicado no mês"
              ,vlresmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Resgates dos titulos vencidos no mês"
              ,vlrenmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Rendimento creditado no mês"
              ,vlprvmes NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Valor total da provisão do mês"
              ,vlprvlan NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Valor provisão lançamento"
              ,vlajuprv NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  "Ajuste de provisão no mês"
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
      -- Definição do tipo de tabela dos valores de titulos ativos por pessoa
      TYPE typ_tab_vlsdapat IS 
        TABLE OF NUMBER
          INDEX BY BINARY_INTEGER; 
      -- Definição do tipo de tabela para resumo por agencia 
      TYPE typ_tab_resage IS
        TABLE OF typ_tab_vlsdapat
          INDEX BY BINARY_INTEGER;
      -- Definição pelo tipo de aplicacao
      TYPE typ_tab_resapl IS
        TABLE OF typ_tab_resage
          INDEX BY BINARY_INTEGER;
      -- Definição do total pelo tipo de aplicacao
      TYPE typ_tab_totapl IS
        TABLE OF typ_tab_vlsdapat
          INDEX BY BINARY_INTEGER;
      
      -- Vetor para armazenar os dados de resumo
      vr_tab_resumo typ_tab_resumo;
      vr_tab_fisjur typ_tab_fisjur;  -- Dados de resumo para pessoa Fisica/Jurídica

      vr_tab_resage typ_tab_resapl;  -- Dados de resumo por agencia
      vr_tab_proage typ_tab_resapl;  -- Dados de provisão por agencia

      vr_tab_totpes typ_tab_totapl;  -- Totais Ativos
      vr_tab_totpro typ_tab_totapl;  -- Totais Provisões
      
      -- Chave para a tabela de resumo
      vr_num_chave_resumo BINARY_INTEGER;

      -- Definição do tipo de registro para o detalhe (antiga w_detalhe)
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
      -- Chave para a tabela detalhe(Conta+aplicação)
      vr_des_chave_det VARCHAR2(19);
      -- Auxiliar para indicador de vencimento
      vr_indvecto NUMBER(1);

      -- Definição de tipo de registro para o BNDES (antiga tt-cta-bndes)
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

      -- Definição de tipo de registro para o resumo Cecred (antiga w_resumo_cecred)
      TYPE typ_reg_resumo_cecred IS
        RECORD(nrdconta NUMBER         -- "zzzz,zzz,9"           -- CONTA/DV
              ,nmrescop VARCHAR2(20)   -- "x(15)"                -- TITULAR
              ,qtaplati NUMBER(6)      -- "zzz,zz9"              -- QT.TITULOS
              ,vlprvmes NUMBER(17,2)   -- "z,zzz,zzz,zz9.99-"    -- RENDIMENTO
              ,vlrenmes NUMBER(17,2)   -- "zzz,zzz,zzz,zz9.99-"  -- AJUSTE PROVISAO
              ,vlajuprv NUMBER(17,2)   -- "zzz,zzz,zzz,zz9.99-"  -- TOTAL PROVISAO
              ,vlsldmed NUMBER(17,2)); -- "zzz,zzz,zzz,zz9.99-"  -- SALDO MÉDIO DAS APLICAÇÕES RDCPOS
      -- Definicao do tipo de tabela de resumo Cecred
      TYPE typ_tab_resumo_cecred IS
        TABLE OF typ_reg_resumo_cecred
          INDEX BY BINARY_INTEGER; --> usaremos a conta como chave
      -- Vetor para armazenar os dados de resumo Cecred
      vr_tab_resumo_cecred typ_tab_resumo_cecred;
      -- Auxiliar para chaveamento
      vr_num_chave_resumo_cecred BINARY_INTEGER;

      -- Vetor com a quantidade de dias para cada período de 1 a 19
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
      
      -- PL/Table contendo informações por pessoa fisica e juridica
      TYPE typ_pf_pj_rdc IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      
      -- PL/Table contendo informações por histórico, aplicação e pessoa fisica e juridica      
      TYPE typ_val_his_tipo_pessoa is table of typ_pf_pj_rdc index by PLS_INTEGER; 
      
      vr_val_his_tipo_pessoa typ_val_his_tipo_pessoa;     
           
      -- PL/Table contendo informações por agencia e pessoa fisica e juridica
      TYPE typ_agencia_rdc is table of typ_pf_pj_rdc INDEX BY PLS_INTEGER;
      
      -- PL/Table principal para gravar valores por histórico , ageência e PF e PJ por agência
      TYPE typ_val_pf_pj_rdc is table of typ_agencia_rdc INDEX BY PLS_INTEGER;    
      
      vr_tab_val_pf_pj_rdc typ_val_pf_pj_rdc;                                  

      ---------------- Cursores específicos ----------------

      -- Busca das aplicações RDC pré e pós
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
           AND rda.insaqtot = 0            --> Não sacado totalmente
           AND dtc.tpaplrdc IN(1,2)        --> RDC pré e pós
         ORDER BY rda.cdcooper, rda.tpaplica, rda.insaqtot, rda.cdageass, rda.nrdconta, rda.nraplica;

      -- Buscar o primeiro registro na CRAPREJ - Cadastro de rejeitos na integração
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
           AND lap.nraplica = pr_nraplica --> Aplicação enviada
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

      -- Buscar as informações para restart e Rowid para atualização posterior
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
           AND rej.tpintegr = 2 -- Provisões RDC Pos
         ORDER BY rej.nrdconta;

      -- Busca descriação do Associado (Cooperativa associada a Cecred)
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
      
      -- Buscar todas as aplicações para inicializar a tabela de memória
      CURSOR cr_crapdtc_ini IS
        SELECT dtc.tpaplica
          FROM crapdtc dtc
         WHERE dtc.cdcooper  = pr_cdcooper
           AND dtc.tpaplrdc IN (1,2); -- RDP pré e pós
      
      --Tipo do Cursor de associados para Bulk Collect
      TYPE typ_crapass_bulk IS TABLE of cr_crapass_cecred%ROWTYPE;
      vr_tab_crapass_bulk typ_crapass_bulk;

      -- Busca dos lançamentos do mês com aplicaçao do tipo RDC Pré e Pós
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
           AND lap.dtmvtolt > rw_crapdat.dtultdma     -- Ult dia mês anterior
           AND lap.dtmvtolt < rw_crapdat.dtultdia + 1 -- Ult dia mês corrente + 1
           -- Históricos abaixo
           -- 463 REVERSAO PRV, 473 APLIC.RDCPRE, 474 PROV. RDCPRE
           -- 475 RENDIMENTO  , 476 IRRF        , 477 RESG.RDC
           -- 528 APLIC.RDCPOS, 529 PROV. RDCPOS, 531 REVERSAO PRV
           -- 532 RENDIMENTO  , 533 IRRF        , 534 RESG.RDC
           AND lap.cdhistor IN(474,529,473,528,477,534,532,475,531,463,476,533)
           AND dtc.tpaplrdc IN(1,2); --RDC Pré e Pós

      -- Buscar existência de lançamento específico
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

      -- Busca do tipo da aplicação RDC passada
      CURSOR cr_crapdtc(pr_tpaplica IN crapdtc.tpaplica%TYPE) IS
        SELECT dtc.tpaplrdc
              ,dtc.dsaplica
          FROM crapdtc dtc
         WHERE dtc.cdcooper = pr_cdcooper
           AND dtc.tpaplica = pr_tpaplica;
           
      --Busca o saldo médio das aplicações RDCPOS
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
                           AND dtmvtolt BETWEEN last_day(add_months(pr_dtmvtoan, -1)) + 1 AND pr_dtmvtoan --Do dia primeiro até ultimo dia util
                         UNION ALL
                        SELECT SUM(vlslfmea) --Select abaixo para buscar valores do ultimo dia do mês, pois não contem dados na sda
                          FROM craprda
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND dtsdfmea = pr_dtmvtolt)); --Busca do último dia do mês
     
      vr_tpaplrdc crapdtc.tpaplrdc%TYPE;
      vr_dsaplica crapdtc.dsaplica%TYPE;

      -- Variáveis para o calculo de aplicação
      vr_dtiniper           DATE;                  --> Data inicial para calculo
      vr_dtfimper           DATE;                  --> Data final para calculo
      vr_vlsldrdc           craprda.vlsdrdca%TYPE; --> Saldo da aplicação
      vr_vllanmto           NUMBER(18,4);          --> Acumular valor dos rendimentos
      vr_vllctprv           craplap.vllanmto%TYPE; --> Valor dos lançamentos
      vr_vlrendmm           craplap.vlrendmm%TYPE; --> Valor rendimento tx mínima

      -- Variáveis para geração de lotes
      vr_nrdocmto           craplap.nrdocmto%TYPE; --> Nrdocmto
      vr_cdhistor           INTEGER;               --> Histórico
      vr_rowid_craplap      ROWID;            --> Rowid gravado na craplap

      -- Controle dos prazos
      vr_prazodia           NUMBER; -- Quantidade de dias entre dt vcto e data aplicação
      vr_tipprazo           NUMBER; -- Tipo do prazo para chamada a pc_controla_prazo

      -- Variáveis para criação do XML e geração dos relatórios
      vr_cdempres           NUMBER;         -- Leitura na craprej
      vr_tot_vlacumul       NUMBER;         -- Acumulador para os valores por período
      vr_des_periodo        VARCHAR2(20);   -- Descrição para período
      vr_des_xml            CLOB;           -- Dados do XML
      vr_dsjasper           VARCHAR2(30);   -- Nome do arquivo Jasper
      vr_sqcabrel           NUMBER;         -- Indice do CabRel
      vr_dsxmlnod           VARCHAR2(100);  -- Nó base do XML de dados
      vr_nmformul           VARCHAR2(10);   -- Nome do formulário
      vr_qtcoluna           NUMBER;         -- Quantidade de colunas do relatório
      --
      vr_dsxmldad_arq       CLOB;           -- Arquivo de informação de tarifas
      vr_nom_direto         VARCHAR2(100);  -- Diretorio /coop/rl
      vr_nom_arquivo        VARCHAR2(100);  -- Nome do arquivo de relatório
      vr_nmarqrdc           VARCHAR2(100);  -- Nome do arquivo RDC
      vr_dscomand           VARCHAR2(500);  -- comando Unix
      vr_cdagenci           crapass.cdagenci%TYPE; -- Código da agencia
      vr_nrctaaux           NUMBER;         -- Número da conta - variável auxiliar
      vr_nrctaori           NUMBER;         -- Número da conta de origem para o arquivo
      vr_nrctades           NUMBER;         -- Número da conta de destino para o arquivo
      vr_dsmensag           VARCHAR2(100);  -- Mensagem de cabeçalho do arquivo  
      vr_dsmsgarq           VARCHAR2(120);  -- Mensagem de cabeçalho do arquivo completa
      vr_dsprefix           CONSTANT VARCHAR2(15) := 'REVERSAO '; -- Prefixo para cabeçalho do arquivo
      vr_dtmvtolt           DATE;           -- Auxiliar para tratamento de datas
      vr_dslinarq           VARCHAR2(200);  -- Linha que será escrita no arquivo
      vr_cdcritic           NUMBER;
      vr_dscritic           VARCHAR2(2000); -- controle de erros
      vr_typ_saida          VARCHAR2(2000); -- controle de erros de scripts unix
      vr_vllinarq           NUMBER;
  
      vr_Bufdes_xml varchar2(32000);
      
      vr_dircon VARCHAR2(200);
      vr_arqcon VARCHAR2(200);

      -------- SubRotinas para reaproveitamento de código --------------
        --> Controla log proc_batch, atualizando parâmetros conforme tipo de ocorrência
        PROCEDURE pc_gera_log(pr_cdcooper      IN crapcop.cdcooper%TYPE,
                            pr_dstiplog      IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                            pr_dscritic      IN VARCHAR2 DEFAULT NULL,
                            pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0,
                            pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0,
                            pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2) IS

        -----------------------------------------------------------------------------------------------------------
        --
        --  Programa : pc_gera_log
        --  Sistema  : Rotina para gravar logs em tabelas
        --  Sigla    : CRED
        --  Autor    : Ana Lúcia E. Volles - Envolti
        --  Data     : Janeiro/2018          Ultima atualizacao: 16/01/2018
        --  Chamado  : 822997
        --
        -- Dados referentes ao programa:
        -- Frequencia: Rotina executada em qualquer frequencia.
        -- Objetivo  : Controla gravação de log em tabelas.
        --
        -- Alteracoes:  
        --             
        ------------------------------------------------------------------------------------------------------------   
      BEGIN     
        --> Controlar geração de log de execução dos jobs
        --Como executa na cadeira, utiliza pc_gera_log_batch
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                      
                                  ,pr_ind_tipo_log  => pr_ind_tipo_log
                                  ,pr_nmarqlog      => 'proc_batch.log'                 
                                  ,pr_dstiplog      => NVL(pr_dstiplog,'E')             
                                  ,pr_cdprograma    => vr_cdprogra                      
                                  ,pr_tpexecucao    => 1 -- batch                       
                                  ,pr_cdcriticidade => pr_cdcriticidade                      
                                  ,pr_cdmensagem    => pr_cdmensagem                      
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                      || vr_cdprogra || ' --> '|| pr_dscritic);
      EXCEPTION  
        WHEN OTHERS THEN  
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
      END pc_gera_log;
      --

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fimarq    IN BOOLEAN default false) IS
      BEGIN
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS480.pc_escreve_xml' ,pr_action => NULL);

        --Verificar se ja atingiu o tamanho do buffer, ou se é o final do xml
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

      -- Subprocedure para criação do registro de detalhe
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
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS480.pc_cria_reg_detalhe' ,pr_action => NULL);

        IF pr_tpaplrdc = 1 -- RDCPRE
        OR (pr_tpaplrdc = 2 AND pr_dtvencto - rw_crapdat.dtmvtolt <= 360) THEN -- RDC Pos com menos de 1 ano
          vr_indvecto := 1; -- Não venceu ainda
        ELSE
          vr_indvecto := 2; -- Já venceu
        END IF;
        -- Montar a chave TpAplica | Agencia | IndVcto | Conta | Aplica
        vr_des_chave_det := pr_tpaplica || LPAD(pr_cdageass,3,'0') || vr_indvecto || LPAD(pr_nrdconta,8,'0') || LPAD(pr_nraplica,6,'0');
        -- Continua somente se não existe o registro na tabela de detalhe
        IF NOT vr_tab_detalhe.EXISTS(vr_des_chave_det) THEN
          -- Copiar o restante das informações de detalhe
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
          
          -- Verificar se a aplicação possui bloqueio de resgate
          IF vr_tab_blqrgt.EXISTS(LPAD(pr_nrdconta,12,'0')||LPAD(pr_nraplica,8,'0')) THEN
            -- Situação bloqueada
            vr_tab_detalhe(vr_des_chave_det).dssitapl := 'B';
          ELSE
            -- Para aplicação RDCA
            IF pr_tpaplica = 3 THEN
              -- Se Já completou aniversário
              -- OU período final é anterior ou igual a data atual
              IF pr_inaniver = 1 OR pr_dtfimper <= rw_crapdat.dtmvtolt  THEN
                -- Atribuir D
                vr_tab_detalhe(vr_des_chave_det).dssitapl := 'D';
              ELSE
                -- Atribuir branco
                vr_tab_detalhe(vr_des_chave_det).dssitapl := ' ';
              END IF;
            -- Para aplicação RDCAII
            ELSIF pr_tpaplica = 5 THEN
              -- Se Já completou aniversário
              -- OU período final é anterior ou igual a data atual
              --  E período final - data contratação aplicação > 50 dias
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
      
      --Inicia vetores de totalização por histório e tipo de pessoa e agência.
      PROCEDURE pc_inicia_totalizadores(pr_cdhistor in number,
                                        pr_cdagenci in number) IS
        
      BEGIN
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS480.pc_inicia_totalizadores' ,pr_action => NULL);
        
        IF NOT vr_val_his_tipo_pessoa.exists(pr_cdhistor) THEN
          vr_val_his_tipo_pessoa(pr_cdhistor)(1) := 0; -- Pessoa Fisica
          vr_val_his_tipo_pessoa(pr_cdhistor)(2) := 0; -- Pessoa Fisica
        END IF;
        
        
        IF NOT vr_tab_val_pf_pj_rdc.EXISTS(pr_cdhistor) THEN
          vr_tab_val_pf_pj_rdc(pr_cdhistor)(pr_cdagenci)(1) := 0; -- Pessoa Fisica
          vr_tab_val_pf_pj_rdc(pr_cdhistor)(pr_cdagenci)(2) := 0; -- Pessoa Juridica
        END IF;
       
        IF NOT vr_tab_val_pf_pj_rdc(pr_cdhistor).EXISTS(pr_cdagenci) THEN
          vr_tab_val_pf_pj_rdc(pr_cdhistor)(pr_cdagenci)(1) := 0; -- Pessoa Fisica
          vr_tab_val_pf_pj_rdc(pr_cdhistor)(pr_cdagenci)(2) := 0; -- Pessoa Juridica
        END IF;
                                                       
      END pc_inicia_totalizadores;

    ---------------------------------------
    -- Inicio Bloco Principal pc_crps480
    ---------------------------------------
    BEGIN

      -- Código do programa
      vr_cdprogra := 'CRPS480';

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480'
                                ,pr_action => null);

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
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
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF pr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Limpa historico passado da tabela de alimentacao ao BI, ja que eh necessario o mes atual
      BEGIN
        DELETE tbfin_fluxo_contas_sysphera 
         WHERE cdcooper = pr_cdcooper
           AND cdconta  = 25;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 1037;
          pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic)||' tbfin_fluxo_contas_sysphera '||
                        'com cdcooper:'||pr_cdcooper||
                        ', cdconta: 25'||
                        '. '||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        RAISE vr_exc_erro;
      END;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => pr_cdcritic   --> Código de erro
                                ,pr_des_erro  => pr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;
      -- Se houver indicação de restart
      IF vr_inrestar > 0 THEN
        BEGIN

          -- Buscar informações na string de restart
          vr_nraplica := SUBSTR(vr_dsrestar,1,6);
          vr_tpaplica := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,8,2));
          vr_qtaplati := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,11,6));
          vr_vlsdapat := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,18,16));
          -- Se foi enviado aplicação
          IF vr_tpaplica > 0 THEN
            -- Buscar descrição do tipo
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
          -- Buscar informações complementares na string de restart
          vr_tpaplica := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,35,2));
          vr_qtaplati := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,38,6));
          vr_vlsdapat := GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,45,16));
          -- Se foi enviado aplicação
          IF vr_tpaplica > 0 THEN
            -- Buscar descrição do tipo
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
            pr_cdcritic := 1120;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' vr_dsrestar: '||vr_dsrestar||'. '||sqlerrm;
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
                                               
      -- Se não encontrar
      IF TRIM(vr_dstextab) IS NULL THEN
        -- Utilizar datas padrão
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
      -- Se não tiver encontrado
      IF cr_craplot%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplot;
        -- Efetuar a inserção de um novo registro
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
            pr_cdcritic := 1034;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' craplot: '||
                          'cdcooper:'  ||pr_cdcooper||
                          ', dtmvtolt:'||rw_crapdat.dtmvtolt||
                          ', cdagenci:1, cdbccxlt:100, nrdolote:8480'||
                          ', tplotmov:9, vlinfodb:0, vlcompdb:0'||
                          ', qtinfoln:0, qtcompln:0, vlinfocr:0, vlcompcr:0'||
                          '. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        -- apenas fechar o cursor
        CLOSE cr_craplot;
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se não tiver encontrador
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
      
      -- Percorrer o registro de tipo de aplicação para inicializar a tab
      FOR rw_crapdtc IN cr_crapdtc_ini LOOP
        -- Inicializa para pessoa fisica e jurídica
        vr_tab_fisjur(1)(rw_crapdtc.tpaplica).qtaplati := 0;
        vr_tab_fisjur(2)(rw_crapdtc.tpaplica).qtaplati := 0;
      END LOOP;
      
      -- Busca das aplicações RDC pré e pós
      FOR rw_craprda IN cr_craprda LOOP
     
        BEGIN
          -- Leitura dos lancamentos de resgate da aplicacao passada
          OPEN cr_craplap(pr_nrdconta => rw_craprda.nrdconta
                         ,pr_nraplica => rw_craprda.nraplica
                         ,pr_dtmvtolt => rw_craprda.dtmvtolt);
          FETCH cr_craplap
           INTO rw_craplap;
          -- Se não encontrar nada
          IF cr_craplap%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craplap;
            -- Gerar log 90 e concatenar conta e aplicação
            pr_cdcritic := 90;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 90)
                        || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                        || gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
            -- Gerar roolback para desfazer alterações desse registro
            RAISE vr_exc_undo;
          ELSE 
            -- Apenas fechar para continuar o processo
            CLOSE cr_craplap;
          END IF;
          
          -- Se há controle de restart
          IF vr_inrestar > 0  AND (  -- Se for uma conta anterior a de restart
                                     (rw_craprda.nrdconta < vr_nrctares)
                                   OR
                                     -- Ou se é a mesma conta, mas de uma aplicação anterior
                                     (rw_craprda.nrdconta = vr_nrctares AND rw_craprda.nraplica <= vr_nraplica) ) THEN
            -- Criar o registro de detalhe para esta aplicação
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

            -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
            GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
            -- Ignorar o restante do processo
            RAISE vr_exc_next;
          END IF;
          -- Calculando data inicial do período (default 1º dia do mês)
          vr_dtiniper := rw_crapdat.dtinimes;
          -- Se a data for inferior ao início da aplicação
          IF vr_dtiniper < rw_craprda.dtiniper THEN
            -- Subsituir a data com a data da aplicação
            vr_dtiniper := rw_craprda.dtiniper;
          END IF;
          -- Calculando data final do período (default dia corrente + 1)
          vr_dtfimper := rw_crapdat.dtmvtolt + 1;
          -- Se a data for superior ao fim da aplicação
          IF vr_dtfimper > rw_craprda.dtfimper THEN
            -- Substituir a data com o termino da aplicação
            vr_dtfimper := rw_craprda.dtfimper;
          END IF;
          -- Efetuar atualização dos campos Saldo emissão de Extrato
          -- e Data execução mensal na aplicação
          rw_craprda.vlsdextr := rw_craprda.vlsdrdca;
          rw_craprda.dtsdfmes := rw_crapdat.dtmvtolt;
          -- Zerar variáveis de processo
          vr_vlsdapat := 0;
          vr_vlrendmm := 0;
          -- Para RDC Pré
          IF rw_craprda.tpaplrdc = 1 THEN
            -- Chamar Rotina de calculo da provisao no final do mes e no vencimento.
            APLI0001.pc_provisao_rdc_pre(pr_cdcooper  => pr_cdcooper         --> Cooperativa
                                        ,pr_nrdconta  => rw_craprda.nrdconta --> Numero da Conta
                                        ,pr_nraplica  => rw_craprda.nraplica --> Numero da Aplicaçao
                                        ,pr_dtiniper  => vr_dtiniper         --> Data base inicial
                                        ,pr_dtfimper  => vr_dtfimper         --> Data base final
                                        ,pr_vlsdrdca  => vr_vlsldrdc         --> Valor do saldo RDCA
                                        ,pr_vlrentot  => vr_vllanmto         --> Valor do rendimento total
                                        ,pr_vllctprv  => vr_vllctprv         --> Valor dos ajustes RDC
                                        ,pr_des_reto => vr_des_reto          --> Indicador de saída com erro (OK/NOK)
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
                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_provisao_rdc_pre.';
              END IF;
              -- Incluir na mensagem de erro a conta e aplicação
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            ELSE
              -- Atualizar data de calculo do saldo com a taxa máxima
              rw_craprda.dtatslmx := rw_crapdat.dtmvtopr; --> Próximo dia util
              -- Atualizar valor saldo aplicações ativas
              vr_vlsdapat := APLI0001.fn_round(vr_vlsldrdc,2);
              -- Utilizar histórico 474 - PROV. RDCPRE
              vr_cdhistor := 474;
            END IF;
          -- Para RDC Pós
          ELSIF rw_craprda.tpaplrdc = 2  THEN
            -- Mantem o saldo atual a taxa minima para o caso de resgates antes do vencimento
            APLI0001.pc_provisao_rdc_pos(pr_cdcooper  => pr_cdcooper         --> Código cooperativa
                                        ,pr_cdagenci  => 1                   --> Código da agência
                                        ,pr_nrdcaixa  => 999                 --> Número do caixa
                                        ,pr_nrctaapl  => rw_craprda.nrdconta --> Número da conta
                                        ,pr_nraplres  => rw_craprda.nraplica --> Número da aplicação
                                        ,pr_dtiniper  => rw_craprda.dtatslmm --> Data início do período (dt calculo taxa minima)
                                        ,pr_dtfimper  => vr_dtfimper         --> Data fim do período
                                        ,pr_dtinitax => vr_dtinitax         --> Data de inicio da utilizacao da taxa de poupanca.
                                        ,pr_dtfimtax => vr_dtfimtax         --> Data de fim da utilizacao da taxa de poupanca.
                                        ,pr_flantven  => TRUE                --> Indicador de taxa mínima
                                        ,pr_vlsdrdca  => vr_vlsldrdc         --> Valor RDCA
                                        ,pr_vlrentot  => vr_vllanmto         --> Valor total
                                        ,pr_des_reto  => vr_des_reto         --> Indicador de saída com erro (OK/NOK)
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
                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_provisao_rdc_pos[1].';
              END IF;
              -- Incluir na mensagem de erro a conta e aplicação
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            ELSE
              -- Atualizar data de calculo do saldo da taxa
              -- e o valor da taxa mínima
              rw_craprda.vlsltxmm := NVL(rw_craprda.vlsltxmm,0) + NVL(vr_vllanmto,0); -- Acumular o já existente
              rw_craprda.dtatslmm := rw_crapdat.dtmvtopr;                             -- Próximo dia util
              -- Acumular o valor do rendimento
              vr_vlrendmm := vr_vllanmto;
            END IF;
            -- Mantem o saldo atual agora para a taxa máxima
            APLI0001.pc_provisao_rdc_pos(pr_cdcooper  => pr_cdcooper         --> Código cooperativa
                                        ,pr_cdagenci  => 1                   --> Código da agência
                                        ,pr_nrdcaixa  => 999                 --> Número do caixa
                                        ,pr_nrctaapl  => rw_craprda.nrdconta --> Número da conta
                                        ,pr_nraplres  => rw_craprda.nraplica --> Número da aplicação
                                        ,pr_dtiniper  => rw_craprda.dtatslmx --> Data início do período (dt calculo taxa maxima)
                                        ,pr_dtfimper  => vr_dtfimper         --> Data fim do período
                                        ,pr_dtinitax => vr_dtinitax         --> Data de inicio da utilizacao da taxa de poupanca.
                                        ,pr_dtfimtax => vr_dtfimtax         --> Data de fim da utilizacao da taxa de poupanca.
                                        ,pr_flantven  => FALSE               --> Indicador de taxa mínima
                                        ,pr_vlsdrdca  => vr_vlsldrdc         --> Valor RDCA
                                        ,pr_vlrentot  => vr_vllanmto         --> Valor total
                                        ,pr_des_reto  => vr_des_reto         --> Indicador de saída com erro (OK/NOK)
                                        ,pr_tab_erro  => vr_tab_erro);       --> Tabela com erros
            -- Se retornar erro
            IF vr_des_reto = 'NOK' THEN
              -- Se veio erro na tabela
              IF vr_tab_erro.COUNT > 0 then
                -- Montar erro
                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_provisao_rdc_pos[2].';
              END IF;
              -- Incluir na mensagem de erro a conta e aplicação
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            ELSE
              -- Atualizar data de calculo do saldo da taxa
              -- e o valor da taxa Máxima agora
              rw_craprda.vlsltxmx := NVL(rw_craprda.vlsltxmx,0) + NVL(vr_vllanmto,0); -- Acumular o já existente
              rw_craprda.dtatslmx := rw_crapdat.dtmvtopr;                             -- Próximo dia util
              -- Acumular o saldo provisionado na taxa máxima para RDCPOS
              vr_vlsdapat := APLI0001.FN_ROUND(vr_vlsldrdc,2);
              -- Utilizar histórico 529 - PROV. RDCPOS
              vr_cdhistor := 529;
              -- Apenas para execução a partir da Cecred
              IF pr_cdcooper = 3 THEN
                -- Gravar a tabela craprej - Cadastro de rejeitos na integração
                DECLARE
                  vr_dsopera VARCHAR2(30);
                BEGIN
                  -- Buscar o primeiro registro na CRAPREJ - Cadastro de rejeitos na integração
                  vr_craprej_rowid := null;
                  OPEN cr_craprej(pr_nrdconta => rw_craprda.nrdconta);
                  FETCH cr_craprej
                   INTO vr_craprej_rowid;
                  -- Se tiver encontrado
                  IF cr_craprej%FOUND THEN
                    -- Fechar o cursor
                    CLOSE cr_craprej;
                    -- Tenta atualizar as informações
                    BEGIN
                    UPDATE craprej
                       SET nrseqdig = NVL(nrseqdig,0) + 1
                     WHERE rowid = vr_craprej_rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        pr_cdcritic := 1035;
                        pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic)||' craprej: '||
                                      'nrseqdig + 1'||
                                      ' com rowid:'||vr_craprej_rowid||
                                      '. '||sqlerrm;

                         --Inclusão na tabela de erros Oracle - Chamado 822997
                         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                         RAISE vr_exc_undo;
                    END;
                  ELSE
                    -- Fechar o cursor
                    CLOSE cr_craprej;
                    BEGIN
                    -- Não encontrou nada para atualizar, então inserimos
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
                EXCEPTION
                  WHEN OTHERS THEN
                        pr_cdcritic := 1034;
                        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' craprej: '||
                                      'cdcooper:'||pr_cdcooper||
                                      ', cdpesqbb:'||vr_cdprogra||
                                      ', tpintegr:2, nrdconta:'||rw_craprda.nrdconta||
                                      ', nrseqdig:1, nraplica:'||rw_craprda.nraplica||
                                      '. '||sqlerrm;
                       --Inclusão na tabela de erros Oracle - Chamado 822997
                       CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                  RAISE vr_exc_undo;
                END;
              END IF;
                END;
              END IF;
            END IF;
          END IF; --> tipos de aplicação
          -- Atribuir a sequencia encontrada + 1 ao nro.docmto
          vr_nrdocmto := NVL(rw_craplot.nrseqdig,0) + 1;

          -- Validar se o valor de lançamento é maior que zero
          -- Não deve gerar registro na CRAPLAP com valor zerado ou negativo
          IF vr_vllanmto > 0 THEN
            -- Chamar a gravação de craplap de crédito
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
                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_gera_craplap_rdc.';
              END IF;
              -- Incluir na mensagem de erro a conta e aplicação
              pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(rw_craprda.nrdconta)
                                         || ' - Nr.Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9');
              -- Gerar erro pra fazer rollback
              RAISE vr_exc_undo;
            END IF;
          END IF;
          -- Inserir / atualizar o resumo do tipo de aplicação atual
          vr_tab_resumo(rw_craprda.tpaplica).tpaplica := rw_craprda.tpaplica;
          vr_tab_resumo(rw_craprda.tpaplica).tpaplrdc := rw_craprda.tpaplrdc;
          vr_tab_resumo(rw_craprda.tpaplica).qtaplati := nvl(vr_tab_resumo(rw_craprda.tpaplica).qtaplati,0) + 1;
          vr_tab_resumo(rw_craprda.tpaplica).vlsdapat := nvl(vr_tab_resumo(rw_craprda.tpaplica).vlsdapat,0) + vr_vlsdapat;
          
          BEGIN
            -- gravar as informações por tipo de pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).qtaplati := 
                      nvl(vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).qtaplati,0) + 1;
            vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).vlsdapat := 
                      nvl(vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).vlsdapat,0) + vr_vlsdapat;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).qtaplati := 1;
              vr_tab_fisjur(vr_tab_crapass(rw_craprda.nrdconta).inpessoa)(rw_craprda.tpaplica).vlsdapat := vr_vlsdapat;
          END;

          -- Gravar as informações por agencia
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
          -- e tambem a data calculada e saldo fim do mês na aplicação
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
                  ,rda.dtcalcul = rw_crapdat.dtmvtopr  -- Próximo dia util
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
              pr_cdcritic := 1035;
              pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic)||' craprda: '||
                            'vlslfmea:'||ROUND(vr_vlsldrdc,2)  ||', dtsdfmea:'||rw_craprda.dtsdfmes||
                            ', vlsdextr:'||rw_craprda.vlsdextr ||', dtsdfmes:'||rw_craprda.dtsdfmes||
                            ', dtatslmx:'||rw_craprda.dtatslmx ||', vlsltxmx:'||rw_craprda.vlsltxmx||
                            ', dtatslmm:'||rw_craprda.dtatslmm ||', vlsltxmm:'||rw_craprda.vlsltxmm||
                            ', vlslfmes:'||ROUND(vr_vlsldrdc,2)||', dtcalcul:'||rw_crapdat.dtmvtopr||
                            ' com cdcooper:'||pr_cdcooper      ||', nrdconta:'||rw_craprda.nrdconta||
                            ', nraplica:'||rw_craprda.nraplica ||
                            '. '||sqlerrm;

              --Inclusão na tabela de erros Oracle - Chamado 822997
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

              RAISE vr_exc_undo;
          END;
          -- Somente quando a execução partir da Cecred
          IF pr_cdcooper = 3 THEN
            -- Inserir Informacoes para o BNDES das aplicacoes de nossas filiadas na CECRED
            BEGIN
              --Chamado 822997 - inversão ordem comandos INSERT/UPDATE
              --Atualizar informacoes tabela bndes
                INSERT INTO crapbnd
                           (cdcooper
                           ,dtmvtolt
                           ,nrdconta
                           ,vlaplprv)
                     VALUES(pr_cdcooper            --> Cooperativa conectada
                           ,rw_crapdat.dtmvtolt    --> Data atual
                           ,rw_craprda.nrdconta    --> Conta da aplicação
                           ,ROUND(vr_vlsldrdc,2)); --> Saldo final do mês
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                BEGIN
                  UPDATE crapbnd
                     SET vlaplprv = NVL(vlaplprv,0) + ROUND(vr_vlsldrdc,2) -- Saldo final do mês
                   WHERE cdcooper = pr_cdcooper         --> Cooperativa conectada
                     AND dtmvtolt = rw_crapdat.dtmvtolt --> Data atual
                     AND nrdconta = rw_craprda.nrdconta;
            EXCEPTION
              WHEN OTHERS THEN
                    --Montar mensagem de erro
                    pr_cdcritic := 1035;
                    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapbnd: '||
                                  'vlaplprv: vlaplprv + '||ROUND(vr_vlsldrdc,2)||
                                  ' com cdcooper: '      ||pr_cdcooper||
                                  ', dtmvtolt:'          ||rw_crapdat.dtmvtolt||
                                  ', nrdconta:'          ||rw_craprda.nrdconta||
                                  '. '||sqlerrm;
                     --Inclusão na tabela de erros Oracle - Chamado 822997
                     CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                    --Levantar Excecao
                    RAISE vr_exc_undo;
                END;
              WHEN OTHERS THEN
                --Montar mensagem de erro
                pr_cdcritic := 1034;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapbnd: '||
                              'cdcooper:'||pr_cdcooper||
                              ', dtmvtolt:'||rw_crapdat.dtmvtolt||
                              ', nrdconta:'||rw_craprda.nrdconta||
                              ', vlaplprv:'||ROUND(vr_vlsldrdc,2)||
                              '. '||sqlerrm;
               --Inclusão na tabela de erros Oracle - Chamado 822997
               CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
               --Levantar Excecao
              RAISE vr_exc_undo;
            END;
          END IF;

          -- Prazo em dias é a diferença entre a data de vencimento - data atual da aplicação
          vr_prazodia := rw_craprda.dtvencto - rw_craprda.dtmvtolt;
          -- Guardar o tipo de prazo cfme a diferença de dias
          FOR vr_ind IN vr_vet_periodo.FIRST..vr_vet_periodo.LAST LOOP
            -- Se a quantidade é inferior ou igual
            -- a quantidade da posição atual do vetor de período
            IF vr_prazodia <= vr_vet_periodo(vr_ind) THEN
              -- Utilizaremos esta posição
              vr_tipprazo := vr_ind;
              -- Sair do LOOP
              EXIT;
            END IF;
            -- Se for o ultimo e ainda estamos neste ponto, é pq a quantidade
            -- é maior que o ultimo, então utilizamos a ultima posição
            IF vr_ind = vr_vet_periodo.LAST THEN
              vr_tipprazo := vr_vet_periodo.LAST;
            END IF;
          END LOOP;
          /* -- Gravar a tabela craprej - Cadastro de rejeitos na integração --
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

          -- Montar chave para gravação na tt BNDES(Conta+TipAplica)
          vr_des_chave_bndes := LPAD(rw_craprda.nrdconta,8,'0')||rw_craprda.tpaplica;
          -- Atualizar o registro na tabela(se não existir o próprio ASSIGN já cria)
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
            -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
            GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informacoes no banco de dados a cada
            -- 10.000 registros processados, gravar tbm o controle
            -- de restart, pois qualquer rollback que será efetuado
            -- vai retornar a situação até o ultimo commit
            -- Obs. Descontamos da quantidade atual, a quantidade
            --      que não foi processada devido a estes registros
            --      terem sido processados anteriormente ao restart
            IF Mod(cr_craprda%ROWCOUNT-vr_qtregres,10000) = 0 THEN

              -- Armazenar o conteudo de restart anterior
              -- Obs: quando não existe ainda, incluir espaços para
              --      garantir pelo menos as 34 primeiras posições da string
              vr_dsrestar := NVL(rw_crapres.dsrestar,RPad(' ',34,' '));
              -- Buscar todos os tipos de aplicação da tabela de resumo
              vr_num_chave_resumo := vr_tab_resumo.FIRST;
              LOOP
                -- Sair quando a chave estiver vezia (final da tabela)
                EXIT WHEN vr_num_chave_resumo IS NULL;
                -- Para RDC Pré
                IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 1  THEN
                  -- Manter as primeiras 7 posições
                  -- E incluir o tipo, quantidade e saldo da aplicação atual a partir da 8 posição
                  vr_dsrestar := SUBSTR(vr_dsrestar,1,7) || to_char(vr_tab_resumo(vr_num_chave_resumo).tpaplica,'fm00')||' '
                                                         || to_char(vr_tab_resumo(vr_num_chave_resumo).qtaplati,'fm000000')||' '
                                                         || to_char(vr_tab_resumo(vr_num_chave_resumo).vlsdapat,'000000000000D00')||' '
                                                         || SUBSTR(vr_dsrestar,35);
                -- Para RDC Pós
                ELSIF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
                  -- Manter as primeiras 34 posições
                  -- E incluir o tipo, quantidade e saldo da aplicação atual a partir da 35 posição
                  vr_dsrestar := SUBSTR(vr_dsrestar,1,34) || to_char(vr_tab_resumo(vr_num_chave_resumo).tpaplica,'fm00')||' '
                                                          || to_char(vr_tab_resumo(vr_num_chave_resumo).qtaplati,'fm000000')||' '
                                                          || to_char(vr_tab_resumo(vr_num_chave_resumo).vlsdapat,'000000000000D00')||' ';
                END IF;
                -- Buscar o próximo registro da tab resumo
                vr_num_chave_resumo := vr_tab_resumo.NEXT(vr_num_chave_resumo);
              END LOOP;
              -- Incluir nas 7 primeiras posições o número da aplicação e um espaço e o restante permanece igual
              vr_dsrestar := LPAD(rw_craprda.nraplica,6,'0')||' '||SUBSTR(vr_dsrestar,8);
              -- Atualizar a tabela de restart
              BEGIN
                UPDATE crapres res
                   SET res.nrdconta = rw_craprda.nrdconta  -- conta da aplicação atual
                      ,res.dsrestar = vr_dsrestar          -- descrição genérica com dados das aplicações para restart
                 WHERE res.rowid = rw_crapres.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  pr_cdcritic := 1035;
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapres: '||
                                'nrdconta:'  ||rw_craprda.nrdconta||
                                ', dsrestar:'||vr_dsrestar||
                                ' com rowid:'||rw_crapres.rowid||
                                '. '||sqlerrm;
                  --Inclusão na tabela de erros Oracle - Chamado 822997
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                  RAISE vr_exc_undo;
              END;
              -- Finalmente efetua commit
              COMMIT;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_next THEN
            -- Exception criada para desviar o fluxo para cá e
            -- não processar o restante das instruções após o RAISE
            -- pois o registro atual já havia sido processado antes do restart
            -- Obs. Apenas acumulamos a quantidade de registros já processado
            vr_qtregres := vr_qtregres + 1;
          WHEN vr_exc_undo THEN
            -- Desfazer transacoes desde o ultimo commit
            ROLLBACK;

            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_erro;
        END;
      END LOOP; --> Fim loop cr_craprda

      -- Efetuar Commit de informações pendentes de gravação
      COMMIT;
      -- Chamar rotina para eliminação do restart para evitarmos
      -- reprocessamento das aplicações indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => pr_dscritic); --> Saída de erro
      -- Testar saída de erro
      IF pr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_erro;
      END IF;

      -- Varrer o vetor de aplicações para o BNDES
      vr_des_chave_bndes := vr_tab_cta_bndes.FIRST;
      LOOP
        -- Sair quando encontrar uma chave nulla
        EXIT WHEN vr_des_chave_bndes IS NULL;
        -- Para cada registro, irá atualizar a tabela crapprb - Prazos de retornos
        -- de produtor para levamento de informações do BNDES
        BEGIN
          -- Tenta atualizar as informações
          UPDATE crapprb
             SET vlretorn = NVL(vlretorn,0) + vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica
           WHERE cdcooper = pr_cdcooper         --> Cooperativa conectada
             AND dtmvtolt = rw_crapdat.dtmvtolt --> Data atual
             AND cddprazo = 0                   --> Somente no prazo 0
             AND nrdconta = vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta
             AND cdorigem = vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica;
          -- Se não conseguiu atualizar nenhum registro
          IF SQL%ROWCOUNT = 0 THEN
            BEGIN
            -- Não encontrou nada para atualizar, então inserimos
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
            EXCEPTION
              WHEN OTHERS THEN
                pr_cdcritic := 1034;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapprb: '||
                              'cdcooper:'||pr_cdcooper||
                              ', dtmvtolt:'||rw_crapdat.dtmvtolt||
                              ', nrdconta:'||vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta||
                              ', cdorigem:'||vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica||
                              ', cddprazo:0'||
                              ', vlretorn:'||vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica||
                              '. '||sqlerrm;
                --Inclusão na tabela de erros Oracle - Chamado 822997
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                RAISE vr_exc_erro;
            END;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 1035;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapprb: '||
                          'vlretorn: vlretorn + '||vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica||
                          ' com cdcooper:'       ||pr_cdcooper||
                          ', dtmvtolt:'          ||rw_crapdat.dtmvtolt||
                          ', cddprazo:0'         ||
                          ', nrdconta:'          ||vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta||
                          ', cdorigem:'          ||vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica||
                          '. '||sqlerrm;
            --Inclusão na tabela de erros Oracle - Chamado 822997
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            RAISE vr_exc_erro;
        END;
        -- Buscar o próximo registro
        vr_des_chave_bndes := vr_tab_cta_bndes.NEXT(vr_des_chave_bndes);
      END LOOP;

      -- Para execução somente quando Coop = 3 - Cecred
      IF pr_cdcooper = 3 THEN
        -- Buscar todos os associados (Cooperativas) da Cecred
        -- com registro na craprej de 2 - Provisão RDC Pos
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
      -- Busca dos lançamentos do mês com aplicaçao do tipo RDC Pré e Pós
      -- para criação dos registros de resumo
      
      FOR rw_craplap IN cr_craplap_mes LOOP
        -- Verificar se já existe o registro para relatório detalhado
        IF rw_craplap.insaqtot = 0 THEN
          -- Chamar a criação de registro de detalhe 
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
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
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
          vr_indvecto := 1; -- Não venceu ainda
        ELSE
          vr_indvecto := 2; -- Já venceu
        END IF;
        -- Montar a chave TpAplica | Agencia | IndVcto | Conta | Aplica
        vr_des_chave_det := rw_craplap.tpaplica || LPAD(rw_craplap.cdageass,3,'0') || vr_indvecto || LPAD(rw_craplap.nrdconta,8,'0') || LPAD(rw_craplap.nraplica,6,'0');
        -- Criar ou apenas atualiza o registro de resumo
        vr_tab_resumo(rw_craplap.tpaplica).tpaplica := rw_craplap.tpaplica;
        vr_tab_resumo(rw_craplap.tpaplica).dsaplica := rw_craplap.dsaplica;
        vr_tab_resumo(rw_craplap.tpaplica).tpaplrdc := rw_craplap.tpaplrdc;
        
        -- Criar o registro caso o mesmo não exista
        IF NOT vr_tab_fisjur(1).exists(rw_craplap.tpaplica) THEN
          -- Criar o registro para pessoa física e juridica
          vr_tab_fisjur(1)(rw_craplap.tpaplica) := vr_tab_resumo(rw_craplap.tpaplica);
          vr_tab_fisjur(2)(rw_craplap.tpaplica) := vr_tab_resumo(rw_craplap.tpaplica);
        END IF;
        
        -- Para execução somente quando Coop = 3 - Cecred com aplicação RDC Pos
        IF pr_cdcooper = 3 AND rw_craplap.tpaplrdc = 2 THEN
          -- Se ainda não existir registro para essa conta
          IF NOT vr_tab_resumo_cecred.EXISTS(rw_craplap.nrdconta) THEN

            -- Criaremos o resumo Cecred ou atualizará em caso de já existir
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
        -- Para lançamentos 473 APLIC.RDCPRE e 528 APLIC.RDCPOS
        IF rw_craplap.cdhistor IN(473,528) THEN
          -- Atualizar campos específicos
          vr_tab_resumo(rw_craplap.tpaplica).qtaplmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).qtaplmes,0) + 1;
          vr_tab_resumo(rw_craplap.tpaplica).vlaplmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlaplmes,0) + rw_craplap.vlaplica;

          BEGIN
            -- gravar as informações por tipo de pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).qtaplmes := 
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).qtaplmes,0) + 1;
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlaplmes := 
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlaplmes,0) + rw_craplap.vlaplica;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).qtaplmes := 1;
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlaplmes := rw_craplap.vlaplica;
          END;
                 
        -- Para aplicações ainda não vencidas e
        -- lançamentos 477 RESG.RDC e 534 RESG.RDC
        ELSIF rw_craplap.dtvencto <= rw_craplap.dtmvtolt AND rw_craplap.cdhistor IN(477,534) THEN
          -- Atualizar campos específicos
          vr_tab_resumo(rw_craplap.tpaplica).vlresmes := vr_tab_resumo(rw_craplap.tpaplica).vlresmes + rw_craplap.vllanmto;
          -- Se ainda não foi sacado totalmente
          IF rw_craplap.insaqtot = 0 THEN
            -- Acumular resgate no registro de detalhe
            vr_tab_detalhe(vr_des_chave_det).vlrgtmes := NVL(vr_tab_detalhe(vr_des_chave_det).vlrgtmes,0) + rw_craplap.vllanmto;
          END IF;
          
          BEGIN
            -- gravar as informações por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlresmes := 
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlresmes,0) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlresmes := rw_craplap.vllanmto;
          END;
          
        -- Para aplicações vencidas e
        -- lançamentos 477 RESG.RDC e 534 RESG.RDC
        ELSIF rw_craplap.dtvencto > rw_craplap.dtmvtolt AND rw_craplap.cdhistor IN(477,534) THEN
          -- Se ainda não foi sacado totalmente
          IF rw_craplap.insaqtot = 0 THEN
            -- Acumular resgate no registro de detalhe
            vr_tab_detalhe(vr_des_chave_det).vlrgtmes := NVL(vr_tab_detalhe(vr_des_chave_det).vlrgtmes,0) + rw_craplap.vllanmto;
          END IF;
          -- Somente para o 477
          IF rw_craplap.cdhistor = 477 THEN
            -- Acumular sqsren
            vr_tab_resumo(rw_craplap.tpaplica).vlsqsren := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlsqsren,0) + rw_craplap.vllanmto;
            
            BEGIN 
              -- gravar as informações por tipo pessoa
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren := 
                 nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren,0) + rw_craplap.vllanmto;
            EXCEPTION
              WHEN no_data_found THEN
                vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren := rw_craplap.vllanmto;
            END;
          ELSE --> para o 534
            -- Verificar se existe lançamento com histórico 532
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
                -- gravar as informações por tipo pessoa
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
                -- gravar as informações por tipo pessoa
                vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren := 
                    nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren,0) + rw_craplap.vllanmto;
              EXCEPTION
                WHEN no_data_found THEN
                  vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlsqsren := rw_craplap.vllanmto;
              END;
            END IF;
          END IF;
        -- Para lançamentos 475 RENDIMENTO e 532 RENDIMENTO
        ELSIF rw_craplap.cdhistor IN(475,532) THEN
          -- Acumular no valor rendimento mês
          vr_tab_resumo(rw_craplap.tpaplica).vlrenmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlrenmes,0) + rw_craplap.vllanmto;
          
          BEGIN
            -- gravar as informações por tipo pessoa
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
        -- Para lançamentos 474 PROV. RDCPRE e 529 PROV. RDCPOS
        ELSIF rw_craplap.cdhistor IN(474,529) THEN
          -- Acumular valor de provisão mês
          vr_tab_resumo(rw_craplap.tpaplica).vlprvmes := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlprvmes,0) + rw_craplap.vllanmto;
          
          BEGIN
            -- gravar as informações por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvmes := 
                nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvmes,0) + rw_craplap.vllanmto;
          EXCEPTION
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlprvmes := rw_craplap.vllanmto;
          END;
          
          -- Gravar as informações por agencia
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
            -- Acumular provisão lançado
            vr_tab_resumo(rw_craplap.tpaplica).vlprvlan := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlprvlan,0) + rw_craplap.vllanmto;
            
            BEGIN 
              -- gravar as informações por tipo pessoa
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
        -- Para lançamentos 531 REVERSAO PRV e 463 REVERSAO PRV
        ELSIF rw_craplap.cdhistor IN(531,463) THEN
          -- Decrementar ajuste de previdência
          vr_tab_resumo(rw_craplap.tpaplica).vlajuprv := NVL(vr_tab_resumo(rw_craplap.tpaplica).vlajuprv,0) - rw_craplap.vllanmto;
          
          BEGIN
            -- gravar as informações por tipo pessoa
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
        -- Para lançamentos 476 IRRF e 533 IRRF
        ELSIF rw_craplap.cdhistor IN(476,533) THEN
          -- Acumular IRRF
          vr_tab_resumo(rw_craplap.tpaplica).vlrtirrf := vr_tab_resumo(rw_craplap.tpaplica).vlrtirrf + rw_craplap.vllanmto;
          
          BEGIN
            -- gravar as informações por tipo pessoa
            vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrtirrf := 
                nvl(vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrtirrf,0) + rw_craplap.vllanmto;
          EXCEPTION 
            WHEN no_data_found THEN
              vr_tab_fisjur(vr_tab_crapass(rw_craplap.nrdconta).inpessoa)(rw_craplap.tpaplica).vlrtirrf := rw_craplap.vllanmto;
          END;
        END IF;
        
        --Agrupamento de valores para Lançamentos para o arquivo AAMMDD_RCD.txt - P307 
        IF rw_craplap.cdhistor IN (463,475,531,532) THEN
          
          --Inicia PL Tables
          pc_inicia_totalizadores(pr_cdhistor => rw_craplap.cdhistor,
                                  pr_cdagenci => vr_tab_crapass(rw_craplap.nrdconta).cdagenci);
        
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);

          vr_val_his_tipo_pessoa(rw_craplap.cdhistor)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) := 
            vr_val_his_tipo_pessoa(rw_craplap.cdhistor)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) + rw_craplap.vllanmto; 
          
          --Totaliza valores dos históricos por agencia e tipo de pessoa                        
          vr_tab_val_pf_pj_rdc(rw_craplap.cdhistor)(vr_tab_crapass(rw_craplap.nrdconta).cdagenci)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) := 
            vr_tab_val_pf_pj_rdc(rw_craplap.cdhistor)(vr_tab_crapass(rw_craplap.nrdconta).cdagenci)(vr_tab_crapass(rw_craplap.nrdconta).inpessoa) + rw_craplap.vllanmto;
          
        
        END IF;
      END LOOP;

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl
      -- Iniciar extração dos dados para geração dos relatórios de resumo
      vr_num_chave_resumo := vr_tab_resumo.FIRST;
      LOOP
        -- Sair quando a chave estiver vezia (final da tabela)
        EXIT WHEN vr_num_chave_resumo IS NULL;
        -- Inicializar o CLOB (XML)
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        vr_Bufdes_xml := null;
        -- Inicilizar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
        -- Montar a tag do tipo de aplicação atual
        pc_escreve_xml('<tipoAplica id="'||vr_num_chave_resumo||'" desTpApli="'||vr_tab_resumo(vr_num_chave_resumo).dsaplica||'">');
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        -- Para RDC pré
        IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 1 THEN
          -- Efetuar busca na craprej com vr_cdempres = 7 /* RDCPRE */
          vr_cdempres := 7;
          -- Relatório CRRL454
          vr_nom_arquivo := 'crrl454.lst';
          vr_sqcabrel    := 1;
        -- Para RDC Pós
        ELSIF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
          -- Efetuar busca na craprej com vr_cdempres = 8 /* RDCPOS */
          vr_cdempres := 8;
          -- Relatório crrl455
          vr_nom_arquivo := 'crrl455.lst';
          vr_sqcabrel    := 2;
        END IF;
        -- Deverá utilizar o mesmo JASPER para ambos os relatório
        vr_dsjasper    := 'crrl455.jasper';
        vr_nmformul    := '132col';
        vr_qtcoluna    := 132;
        
        -- Criar tags agrupadora de totais
        pc_escreve_xml('<totais>');
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        -- Enviar cada informações de totais como um nó
        -- para que o relatório possa se dinâmico
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
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        
        
        FOR ind IN vr_tab_fisjur.first..vr_tab_fisjur.last LOOP
          dbms_output.put_line(TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlsdapat,0),'fm999g999g999g990d00mi'));
        END LOOP;
        
        
        -- Somente para Pós
        IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
          pc_cria_node_total(pr_des_total => 'SAQUES COM RENDIMENTO:'
                            ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlsqcren,0)   ,'fm999g999g999g990d00mi')
                            ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlsqcren,0),'fm999g999g999g990d00mi')
                            ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlsqcren,0),'fm999g999g999g990d00mi'));
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        END IF;
        pc_cria_node_total(pr_des_total => 'IMPOSTO DE RENDA RETIDO NA FONTE:'
                          ,pr_des_valor => TO_CHAR(NVL(vr_tab_resumo(vr_num_chave_resumo).vlrtirrf,0)   ,'fm999g999g999g990d00mi')
                          ,pr_des_vlfis => TO_CHAR(NVL(vr_tab_fisjur(1)(vr_num_chave_resumo).vlrtirrf,0),'fm999g999g999g990d00mi')
                          ,pr_des_vljur => TO_CHAR(NVL(vr_tab_fisjur(2)(vr_num_chave_resumo).vlrtirrf,0),'fm999g999g999g990d00mi'));
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        -- Fechar tags de totais
        pc_escreve_xml('</totais>');
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        -- Iniciar Tag de períodos
        pc_escreve_xml('<periodos>');
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        -- Reinicializar totalizadores
        vr_tot_vlacumul := 0;
        -- Buscar todos os períodos do vetor de períodos
        FOR vr_per IN vr_vet_periodo.FIRST..vr_vet_periodo.LAST LOOP
          -- Somente no período 19 (Ultimo)
          IF vr_per = 19 THEN
            -- Utilizar "MAIS de"
            vr_des_periodo := 'MAIS de '||(vr_vet_periodo(vr_per)-1);
          ELSE
            -- Utilizar "ATE"
            vr_des_periodo := 'ATE '||vr_vet_periodo(vr_per);
          END IF;

          -- Buscar dados na tabela temporario de rejeitados (antiga craprej), caso tenha sido gravado algo para este período
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
            -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
            GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);

            -- Somente RDC Pos
            IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
              -- Incluir registro para cada valor acumulado
              BEGIN
                INSERT INTO tbfin_fluxo_contas_sysphera
                             (cdcooper
                             ,dtmvtolt
                             ,cdconta
                             ,nrseqconta
                             ,cdprazo
                             ,vlacumulado
                             ,cdoperador
                             ,datalteracao)
                       VALUES(pr_cdcooper
                             ,rw_crapdat.dtmvtolt
                             ,25
                             ,0
                             ,vr_vet_periodo(vr_per)
                             ,vr_tab_craprej(vr_num_chave_craprej).vllanmto
                             ,'1'
                             ,SYSDATE);
              EXCEPTION
                WHEN OTHERS THEN
                  pr_cdcritic := 1034;
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' tbfin_fluxo_contas_sysphera: '||
                                'cdcooper:'     ||pr_cdcooper||
                                ', dtmvtolt:'   ||rw_crapdat.dtmvtolt||
                                ', cdconta:25, nrseqconta:0'||
                                ', cdprazo:'    ||vr_vet_periodo(vr_per)||
                                ', vlacumulado:'||vr_tab_craprej(vr_num_chave_craprej).vllanmto||
                                ', cdoperador:1, datalteracao:'||SYSDATE||
                                '. '||sqlerrm;
                RAISE vr_exc_erro;
              END;
            END IF;

          ELSE
            -- Enviar ao XML um registro em branco
            pc_escreve_xml('<periodo>'
                         ||'  <dsper>'||vr_des_periodo||'</dsper>' --> PERIODO VCTO/DIAS
                         ||'  <vllcto>'||to_char(0,'fm0d00')||'</vllcto>'                       --> VALOR
                         ||'  <vllctoac>'||to_char(0,'fm0d00')||'</vllctoac>'                   --> VALOR ACUMULADO
                         ||'  <qtaplica>'||to_char(0,'fm0')||'</qtaplica>'                      --> QTD.RDC
                         ||'</periodo>');
            -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
            GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
          END IF;
          -- Para cooperativas <> Cecred com valor de lançamento
          IF vr_tab_craprej.EXISTS(vr_num_chave_craprej) AND pr_cdcooper <> 3 AND NVL(vr_tab_craprej(vr_num_chave_craprej).vllanmto,0) > 0 THEN
            -- Criar os registro na tabela de prazos de retornos do BNDES
            DECLARE
              vr_cddprazo NUMBER; -- Quantidade de dias cfme período encontrado
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
                -- enviar log ao batch e não parar o processo, pois segundo o Guilherme Strube
                -- no Progress não estava sendo tratado provavelmente pq nunca gerava erro, já
                -- que é feita apenas uma execução por dia
                vr_cdcritic := 1034;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapprb[1]: '||
                              'cdcooper: 3, dtmvtolt:'||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||
                              ', nrdconta:'||rw_crapcop.nrctactl||
                              ', cdorigem:'||vr_cdempres||
                              ', cddprazo:'||vr_cddprazo||
                              ', vlretorn:'||vr_tab_craprej(vr_num_chave_craprej).vllanmto||
                              '. '||sqlerrm;

                --Grava tabela de log - Ch 822997
                pc_gera_log(pr_cdcooper      => pr_cdcooper,
                            pr_dstiplog      => 'E',
                            pr_dscritic      => vr_dscritic,
                            pr_cdcriticidade => 0,
                            pr_cdmensagem    => nvl(vr_cdcritic,0),
                            pr_ind_tipo_log  => 1);

              WHEN OTHERS THEN
                pr_cdcritic := 1034;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapprb[2]: '||
                              'cdcooper: 3, dtmvtolt:'||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||
                              ', nrdconta:'||rw_crapcop.nrctactl||
                              ', cdorigem:'||vr_cdempres||
                              ', cddprazo:'||vr_cddprazo||
                              ', vlretorn:'||vr_tab_craprej(vr_num_chave_craprej).vllanmto||
                              '. '||sqlerrm;

                RAISE vr_exc_erro;
            END;
          END IF;
        END LOOP;
        -- Fechar a tag de períodos
        pc_escreve_xml('</periodos>');
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        -- Somente para Pós
        IF vr_tab_resumo(vr_num_chave_resumo).tpaplrdc = 2 THEN
          -- Abrir tag resumos
          pc_escreve_xml('<resumo_cecred>');
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
          -- Buscar o primeiro indice da tabela resumo-cecred
          vr_num_chave_resumo_cecred := vr_tab_resumo_cecred.FIRST;
          -- Buscar as informações do Resumo-Cecred
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
                         ||'  <vlsldmed>'||to_char(NVL(vr_tab_resumo_cecred(vr_num_chave_resumo_cecred).vlsldmed,0),'fm999g999g999g990d00')||'</vlsldmed>' --> SALDO MÉDIO RDCPOS
                         ||'</resumo>');
            -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
            GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
            -- Buscar o próximo indice
            vr_num_chave_resumo_cecred := vr_tab_resumo_cecred.NEXT(vr_num_chave_resumo_cecred);
          END LOOP;
          -- Fechar tag de resumos
          pc_escreve_xml('</resumo_cecred>');
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        END IF;
        -- Fechar as tags abertas
        pc_escreve_xml('</tipoAplica></raiz>',true);
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);

        -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz/tipoAplica' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => vr_dsjasper         --> Arquivo de layout do iReport
                                   ,pr_dsparams  => 'PR_CDCOOPER##'||pr_cdcooper||'@@PR_MESREF##'||gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'||to_char(rw_crapdat.dtmvtolt,'rrrr') --> Coop e Mês de referencia
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo --> Arquivo final co
                                   ,pr_qtcoluna  => vr_qtcoluna         --> 80 08 234 colunas
                                   ,pr_flg_gerar => 'N'                 --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => vr_nmformul         --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                   --> Número de cópias
                                   ,pr_sqcabrel  => vr_sqcabrel         --> Qual a seq do cabrel
                                   ,pr_des_erro  => pr_dscritic);       --> Saída com erro

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        -- Testar se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
        -- Buscar o próximo registro da tab resumo
        vr_num_chave_resumo := vr_tab_resumo.NEXT(vr_num_chave_resumo);
      END LOOP;
      
      -- Se for uma virada de mês, emitir o arquivo para contabilidade
      IF trunc(rw_crapdat.dtmvtopr,'MM') <> trunc(rw_crapdat.dtmvtolt,'MM') AND 
         (vr_tab_totpes.COUNT() > 0 OR vr_tab_totpro.COUNT() > 0)          AND
         pr_cdcooper <> 3  THEN 
 
        -- Inicializar o CLOB (XML) para o arquivo com informação das tarifas
        dbms_lob.createtemporary(vr_dsxmldad_arq, TRUE);
        dbms_lob.open(vr_dsxmldad_arq,dbms_lob.lob_readwrite);   
        
        --------------------------------------------
        /***** SALDO TOTAL DOS TITULOS ATIVOS *****/
        --------------------------------------------
        
        -- Para cada tipo de aplicação 
        FOR indapl IN vr_tab_totpes.FIRST..vr_tab_totpes.LAST LOOP
        
          -- Para cada tipo de pessoa que constara no arquivo
          FOR indpes IN 1..2 LOOP
            
            -- Setar as variáveis conforme tipo de aplicação
            IF indapl = 1 THEN
              -- Setar as variáveis conforme indice
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
              -- Setar as variáveis conforme indice
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
          
            -- Para cada cada modalidade 1=Normal e 2=Reversão
            FOR indmod IN 1..2 LOOP
              
              -- Se modo normal
              IF indmod = 1 THEN
                vr_dtmvtolt := rw_crapdat.dtmvtolt;
                vr_dsmsgarq := vr_dsmensag;
              ELSE
                -- Inversão das contas
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
                  vr_vllinarq := 0; -- Quando não existir atribui zero
                END IF;
              ELSE
                vr_vllinarq := 0; -- Quando não existir atribui zero
              END IF;
              
              -- Se o valor for maior que zero
              IF vr_vllinarq > 0 THEN
              
                /* Imprimir dados de pessoa FISICA */
                vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                            || ',' ||to_char(vr_dtmvtolt,'DDMMYY') || ','||vr_nrctaori||','||vr_nrctades||',' 
                            || to_char(vr_vllinarq,'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,') 
                            || ',5210,"'|| vr_dsmsgarq ||'"'
                            || CHR(10);
        
                -- Escrever CLOB
                dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);   
        
                -- Repetir as informações da agencia 
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
                    END IF; -- Testa aplicação
                    
                    EXIT WHEN vr_cdagenci = vr_tab_resage(indapl).LAST;
                    vr_cdagenci := vr_tab_resage(indapl).NEXT(vr_cdagenci);
                  END LOOP;
                END LOOP; -- Fim repete
              END IF; -- Se o total for maior que zero
            END LOOP; -- Normal e reversão
          END LOOP; -- Pessoas 1 e 2
        END LOOP; -- Tipo de aplicação
     
    
        --------------------------------------------
        /***** VALOR TOTAL DA PROVISAO DO MES *****/
        --------------------------------------------
        
        -- Para cada tipo de aplicação 
        FOR indapl IN vr_tab_totpro.FIRST..vr_tab_totpro.LAST LOOP
        
          -- Para cada tipo de pessoa que constara no arquivo
          FOR indpes IN 1..2 LOOP
            
            -- Setar as variáveis conforme tipo de aplicação
            IF indapl = 1 THEN
              -- Setar as variáveis conforme indice
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
              -- Setar as variáveis conforme indice
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
          
            vr_dtmvtolt := rw_crapdat.dtmvtolt;
            -- 
            vr_dsmsgarq := vr_dsmensag;
              
            -- Verifica se o valor existe
            IF vr_tab_totpro.EXISTS(indapl) THEN
              IF vr_tab_totpro(indapl).EXISTS(indpes) THEN
                vr_vllinarq := vr_tab_totpro(indapl)(indpes);
              ELSE
                vr_vllinarq := 0; -- Quando não existir atribui zero
              END IF;
            ELSE
              vr_vllinarq := 0; -- Quando não existir atribui zero
            END IF;
              
            -- Se o valor for maior que zero
            IF vr_vllinarq > 0 THEN
                  
              /* Imprimir dados de pessoa FISICA */
              vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                          || ',' ||to_char(vr_dtmvtolt,'DDMMYY') || ','||vr_nrctaori||','||vr_nrctades||',' 
                          || to_char(vr_vllinarq,'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,') 
                          || ',5210,"'|| vr_dsmsgarq ||'"'
                          || CHR(10);
        
              -- Escrever CLOB
              dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);   
        
              -- Repetir as informações da agencia 
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
                  END IF; -- Testa aplicação
                    
                  EXIT WHEN vr_cdagenci = vr_tab_proage(indapl).LAST;
                  vr_cdagenci := vr_tab_proage(indapl).NEXT(vr_cdagenci);
                END LOOP;
              END LOOP; -- fim repete
            END IF; -- Se valor total maior que zero
          END LOOP; -- Pessoas 1 e 2
        END LOOP; -- Tipo de aplicação
        
        -------------------------------------------------
        /***** VALOR ESTORNOS E RENDIMENTOS DO MÊS *****/
        ------------------------------------------------- 
        FOR indpes IN 1..2 LOOP
          IF vr_val_his_tipo_pessoa.EXISTS(463) THEN
            IF vr_val_his_tipo_pessoa(463).exists(indpes) THEN      
              IF vr_val_his_tipo_pessoa(463)(indpes) > 0 THEN
                IF indpes = 1 THEN
                  -- pessoa fisica
                  vr_nrctaori := 8114;
                  vr_nrctades := 8057;
                  vr_dsmensag := '"ESTORNO DA PROVISAO RDC PRE - PESSOA FISICA"';
                ELSIF indpes = 2 THEN
                  -- pessoa juridica
                  vr_nrctaori := 8114;
                  vr_nrctades := 8058;
                  vr_dsmensag := '"ESTORNO DA PROVISAO RDC PRE - PESSOA JURIDICA"';
                END IF;      
                
                /* Imprimir dados de pessoa FISICA */
                vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                            || ',' ||to_char(vr_dtmvtolt,'DDMMYY') 
                            || ',' ||vr_nrctaori   --Débito
                            || ',' ||vr_nrctades   --Crédito
                            || ',' ||to_char(vr_val_his_tipo_pessoa(463)(indpes),'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,') 
                            || ',5210,'
                            || vr_dsmensag
                            || CHR(10);
                  
                -- Escrever CLOB
                dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);
                
                -- Repetir as informações da agencia 
                FOR repete IN 1..2 LOOP
                  -- Agencia 
                  vr_cdagenci := vr_tab_val_pf_pj_rdc(463).FIRST;
                    
                  -- Percorrer para todas as agencias todos os dados de pessoa fisica e juridica
                  LOOP
                        
                    -- Verifica se o valor existe
                    IF vr_tab_val_pf_pj_rdc.EXISTS(463) THEN
                      IF vr_tab_val_pf_pj_rdc(463).EXISTS(vr_cdagenci) THEN
                        IF vr_tab_val_pf_pj_rdc(463)(vr_cdagenci).EXISTS(indpes) THEN
                          IF vr_tab_val_pf_pj_rdc(463)(vr_cdagenci)(indpes) > 0 THEN                          
                            -- Monta a linha para o arquivo
                            vr_dslinarq := to_char(vr_cdagenci,'FM000')||','||
                                           to_char(vr_tab_val_pf_pj_rdc(463)(vr_cdagenci)(indpes),'fm99999999990D00','NLS_NUMERIC_CHARACTERS=.,')||
                                           CHR(10);
                          
                            -- Escrever a linha no CLOB 
                            dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq); 
                          END IF;  
                        END IF; -- Testa tipo pessoa
                      END IF; -- Testa agencia
                    END IF; -- Testa aplicação
                        
                    EXIT WHEN vr_cdagenci = vr_tab_val_pf_pj_rdc(463).LAST;
                    vr_cdagenci := vr_tab_val_pf_pj_rdc(463).NEXT(vr_cdagenci);
                  END LOOP;
                END LOOP; -- fim repete
              END IF;
            END IF;
          END IF;
          
          
          --Histórico 475
          IF vr_val_his_tipo_pessoa.EXISTS(475) THEN          
            IF vr_val_his_tipo_pessoa(475).exists(indpes) THEN 
              IF vr_val_his_tipo_pessoa(475)(indpes) > 0 THEN
                IF indpes = 1 THEN
                  -- pessoa fisica
                  vr_nrctaori := 8057;
                  vr_nrctades := 8114;
                  vr_dsmensag := '"RENDIMENTO RDC PRE - PESSOA FISICA"';
                ELSIF indpes = 2 THEN
                  -- pessoa juridica
                  vr_nrctaori := 8058;
                  vr_nrctades := 8114;
                  vr_dsmensag := '"RENDIMENTO RDC PRE - PESSOA JURIDICA"';
                END IF;      
                
                /* Imprimir dados de pessoa FISICA */
                vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                            || ',' ||to_char(vr_dtmvtolt,'DDMMYY') 
                            || ',' ||vr_nrctaori   --Débito
                            || ',' ||vr_nrctades   --Crédito
                            || ',' ||to_char(vr_val_his_tipo_pessoa(475)(indpes),'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,') 
                            || ',5210,'
                            || vr_dsmensag
                            || CHR(10);
                  
                -- Escrever CLOB
                dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);
                
                -- Repetir as informações da agencia 
                FOR repete IN 1..2 LOOP
                  -- Agencia 
                  vr_cdagenci := vr_tab_val_pf_pj_rdc(475).FIRST;
                    
                  -- Percorrer para todas as agencias todos os dados de pessoa fisica e juridica
                  LOOP
                        
                    -- Verifica se o valor existe
                    IF vr_tab_val_pf_pj_rdc.EXISTS(475) THEN
                      IF vr_tab_val_pf_pj_rdc(475).EXISTS(vr_cdagenci) THEN
                        IF vr_tab_val_pf_pj_rdc(475)(vr_cdagenci).EXISTS(indpes) THEN
                          IF vr_tab_val_pf_pj_rdc(475)(vr_cdagenci)(indpes) > 0 THEN                          
                            -- Monta a linha para o arquivo
                            vr_dslinarq := to_char(vr_cdagenci,'FM000')||','||
                                           to_char(vr_tab_val_pf_pj_rdc(475)(vr_cdagenci)(indpes),'fm99999999990D00','NLS_NUMERIC_CHARACTERS=.,')||
                                           CHR(10);
                          
                            -- Escrever a linha no CLOB 
                            dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq); 
                          END IF;  
                        END IF; -- Testa tipo pessoa
                      END IF; -- Testa agencia
                    END IF; -- Testa aplicação
                        
                    EXIT WHEN vr_cdagenci = vr_tab_val_pf_pj_rdc(475).LAST;
                    vr_cdagenci := vr_tab_val_pf_pj_rdc(475).NEXT(vr_cdagenci);
                  END LOOP;
                END LOOP; -- fim repete
              END IF;
            END IF;
          END IF; 
          
          --Histórico 531
          IF vr_val_his_tipo_pessoa.EXISTS(531) THEN          
            IF vr_val_his_tipo_pessoa(531).exists(indpes) THEN 
              IF vr_val_his_tipo_pessoa(531)(indpes) > 0 THEN
                IF indpes = 1 THEN
                  -- pessoa fisica
                  vr_nrctaori := 8118;
                  vr_nrctades := 8060;
                  vr_dsmensag := '"ESTORNO DA PROVISAO RDC POS - PESSOA FISICA"';
                ELSIF indpes = 2 THEN
                  -- pessoa juridica
                  vr_nrctaori := 8118;
                  vr_nrctades := 8061;
                  vr_dsmensag := '"ESTORNO DA PROVISAO RDC POS - PESSOA JURIDICA"';
                END IF;      
                
                /* Imprimir dados de pessoa FISICA */
                vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                            || ',' ||to_char(vr_dtmvtolt,'DDMMYY') 
                            || ',' ||vr_nrctaori   --Débito
                            || ',' ||vr_nrctades   --Crédito
                            || ',' ||to_char(vr_val_his_tipo_pessoa(531)(indpes),'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,') 
                            || ',5210,'
                            || vr_dsmensag
                            || CHR(10);
                  
                -- Escrever CLOB
                dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);
                
                -- Repetir as informações da agencia 
                FOR repete IN 1..2 LOOP
                  -- Agencia 
                  vr_cdagenci := vr_tab_val_pf_pj_rdc(531).FIRST;
                    
                  -- Percorrer para todas as agencias todos os dados de pessoa fisica e juridica
                  LOOP
                        
                    -- Verifica se o valor existe
                    IF vr_tab_val_pf_pj_rdc.EXISTS(531) THEN
                      IF vr_tab_val_pf_pj_rdc(531).EXISTS(vr_cdagenci) THEN
                        IF vr_tab_val_pf_pj_rdc(531)(vr_cdagenci).EXISTS(indpes) THEN
                          IF vr_tab_val_pf_pj_rdc(531)(vr_cdagenci)(indpes) > 0 THEN                          
                            -- Monta a linha para o arquivo
                            vr_dslinarq := to_char(vr_cdagenci,'FM000')||','||
                                           to_char(vr_tab_val_pf_pj_rdc(531)(vr_cdagenci)(indpes),'fm99999999990D00','NLS_NUMERIC_CHARACTERS=.,')||
                                           CHR(10);
                          
                            -- Escrever a linha no CLOB 
                            dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);  
                          END IF; 
                        END IF; -- Testa tipo pessoa
                      END IF; -- Testa agencia
                    END IF; -- Testa aplicação
                        
                    EXIT WHEN vr_cdagenci = vr_tab_val_pf_pj_rdc(531).LAST;
                    vr_cdagenci := vr_tab_val_pf_pj_rdc(531).NEXT(vr_cdagenci);
                  END LOOP;
                END LOOP; -- fim repete
              END IF; 
            END IF; 
          END IF;
          
          --Histórico 532
          IF vr_val_his_tipo_pessoa.EXISTS(532) THEN          
            IF vr_val_his_tipo_pessoa(532).exists(indpes) THEN           
              IF vr_val_his_tipo_pessoa(532)(indpes) > 0 THEN
                IF indpes = 1 THEN
                  -- pessoa fisica
                  vr_nrctaori := 8060;
                  vr_nrctades := 8118;
                  vr_dsmensag := '"RENDIMENTO RDC POS - PESSOA FISICA"';
                ELSIF indpes = 2 THEN
                  -- pessoa juridica
                  vr_nrctaori := 8061;
                  vr_nrctades := 8118;
                  vr_dsmensag := '"RENDIMENTO RDC POS - PESSOA JURIDICA"';
                END IF;      
                
                /* Imprimir dados de pessoa FISICA */
                vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                            || ',' ||to_char(vr_dtmvtolt,'DDMMYY') 
                            || ',' ||vr_nrctaori   --Débito
                            || ',' ||vr_nrctades   --Crédito
                            || ',' ||to_char(vr_val_his_tipo_pessoa(532)(indpes),'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,') 
                            || ',5210,'
                            || vr_dsmensag
                            || CHR(10);
                  
                -- Escrever CLOB
                dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);
                
                -- Repetir as informações da agencia 
                FOR repete IN 1..2 LOOP
                  -- Agencia 
                  vr_cdagenci := vr_tab_val_pf_pj_rdc(532).FIRST;
                    
                  -- Percorrer para todas as agencias todos os dados de pessoa fisica e juridica
                  LOOP
                        
                    -- Verifica se o valor existe
                    IF vr_tab_val_pf_pj_rdc.EXISTS(532) THEN
                      IF vr_tab_val_pf_pj_rdc(532).EXISTS(vr_cdagenci) THEN
                        IF vr_tab_val_pf_pj_rdc(532)(vr_cdagenci).EXISTS(indpes) THEN
                          IF vr_tab_val_pf_pj_rdc(532)(vr_cdagenci)(indpes) > 0 THEN
                            -- Monta a linha para o arquivo
                            vr_dslinarq := to_char(vr_cdagenci,'FM000')||','||
                                           to_char(vr_tab_val_pf_pj_rdc(532)(vr_cdagenci)(indpes),'fm99999999990D00','NLS_NUMERIC_CHARACTERS=.,')||
                                           CHR(10);
                        
                            -- Escrever a linha no CLOB 
                            dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);   
                          END IF;
                        END IF; -- Testa tipo pessoa
                      END IF; -- Testa agencia
                    END IF; -- Testa aplicação
                        
                    EXIT WHEN vr_cdagenci = vr_tab_val_pf_pj_rdc(532).LAST;
                    vr_cdagenci := vr_tab_val_pf_pj_rdc(532).NEXT(vr_cdagenci);
                  END LOOP;
                END LOOP; -- fim repete
              END IF; 
            END IF; 
          END IF;                
        END LOOP;
        
        -- Buscar os diretórios
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'   
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'contab'); 

        -- Define o nome do arquivo
        vr_nmarqrdc := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'_RDC.txt';
            
        -- Criar o arquivo de dados
        GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsxmldad_arq
                                     ,pr_caminho  => vr_nom_direto
                                     ,pr_arquivo  => vr_nmarqrdc
                                     ,pr_des_erro => pr_dscritic);
    
        --Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_dsxmldad_arq);
        dbms_lob.freetemporary(vr_dsxmldad_arq); 
    
        -- Testa
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF; 
        
        -- Busca o diretório para contabilidade
        vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
                                              
        vr_arqcon := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_RDC.txt';

        -- Executa comando UNIX para converter arq para Dos
        vr_dscomand := 'ux2dos ' || vr_nom_direto ||'/'||vr_nmarqrdc||' > '
                                 || vr_dircon ||'/'||vr_arqcon || ' 2>/dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomand
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => pr_dscritic);
        IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_erro;
        END IF;
        
      END IF;
      
      -- Buscar novamente o diretório rl
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'   
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); 
      
      -- Iniciar extração dos dados para geração dos relatórios detalhados
      vr_des_chave_det := vr_tab_detalhe.FIRST;
      LOOP
        -- Sair quando a chave não possuir mais nenhum informação
        EXIT WHEN vr_des_chave_det IS NULL;
        -- Se for o primeiro registro, ou se mudou o tipo de aplicação
        IF vr_des_chave_det = vr_tab_detalhe.FIRST OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).tpaplica THEN
          -- Inicializar o CLOB (XML)
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          vr_Bufdes_xml := null;
          -- Inicilizar as informações do XML
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
          -- Para RDC pré
          IF vr_tab_detalhe(vr_des_chave_det).tpaplrdc = 1 THEN
            -- Efetuar busca na craprej com vr_cdempres = 7 /* RDCPRE */
            vr_cdempres := 7;
            -- Utilizar crrl454
            vr_nom_arquivo := 'crrl477.lst';
            vr_dsjasper    := 'crrl477.jasper';
            vr_sqcabrel    := 3;
            vr_dsxmlnod    := '/raiz/tipoAplica/aplicacoes/agencia/aplica'; -- Nó base do XML de dados
          -- Para RDC Pós
          ELSIF vr_tab_detalhe(vr_des_chave_det).tpaplrdc = 2 THEN
            -- Efetuar busca na craprej com vr_cdempres = 8 /* RDCPOS */
            vr_cdempres := 8;
            -- Utilizar crrl455
            vr_nom_arquivo := 'crrl478.lst';
            vr_dsjasper    := 'crrl478.jasper';
            vr_sqcabrel    := 4;
            vr_dsxmlnod    := '/raiz'; -- Nó base do XML de dados
          END IF;
          -- Montar a tag do tipo de aplicação atual
          pc_escreve_xml('<tipoAplica id="'||vr_tab_detalhe(vr_des_chave_det).tpaplica||'" desTpApli="'||vr_tab_detalhe(vr_des_chave_det).dsaplica||'"><aplicacoes>');
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        END IF;
        -- Se for o primeiro ou mudou a agência ou tipo de vencimento
        IF vr_des_chave_det = vr_tab_detalhe.FIRST
		    OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).tpaplica
        OR vr_tab_detalhe(vr_des_chave_det).cdagenci <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).cdagenci
        OR vr_tab_detalhe(vr_des_chave_det).indvecto <> vr_tab_detalhe(vr_tab_detalhe.PRIOR(vr_des_chave_det)).indvecto THEN
          -- Criar novo nó de agência / tipo vcto
          pc_escreve_xml('<agencia cdageass="'||vr_tab_detalhe(vr_des_chave_det).cdagenci||'" '
                       ||         'nmresage="'||vr_tab_detalhe(vr_des_chave_det).nmresage||'" '
                       ||         'indvecto="'||vr_tab_detalhe(vr_des_chave_det).indvecto||'">');
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
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
        -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        -- Se for o ultimo ou irá mudar a agência ou tipo de vencimento no próximo
        IF vr_des_chave_det = vr_tab_detalhe.LAST
        OR vr_tab_detalhe(vr_des_chave_det).cdagenci <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).cdagenci
        OR vr_tab_detalhe(vr_des_chave_det).indvecto <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).indvecto
		    OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).tpaplica THEN
          -- fechar nó de agência / tipo vcto
          pc_escreve_xml('</agencia>');
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
        END IF;
        -- Se for o ultimo registro do vetor ou do tipo de aplicação
        IF vr_des_chave_det = vr_tab_detalhe.LAST OR vr_tab_detalhe(vr_des_chave_det).tpaplica <> vr_tab_detalhe(vr_tab_detalhe.NEXT(vr_des_chave_det)).tpaplica THEN
          -- Fechar as tags abertas
          pc_escreve_xml('</aplicacoes></tipoAplica></raiz>',TRUE);
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS480' ,pr_action => null);
          -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                                     ,pr_dsxmlnode => vr_dsxmlnod                          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => vr_dsjasper                          --> Arquivo de layout do iReport
                                     ,pr_dsparams  => 'PR_CDCOOPER##'||pr_cdcooper         --> Somente Coop Conectada
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo   --> Arquivo final com o path
                                     ,pr_qtcoluna  => 234                                  --> 234 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '234col'                             --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                                    --> Número de cópias
                                     ,pr_sqcabrel  => vr_sqcabrel                          --> Qual a seq do cabrel
                                     ,pr_des_erro  => pr_dscritic);                        --> Saída com erro
          -- Testar se houve erro
          IF pr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
          END IF;
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
        END IF;
        -- Buscar o próximo registro
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
          pr_cdcritic := 1037;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' craprej '||
                        'com cdcooper:'||pr_cdcooper||
                        ', cdpesqbb:'||vr_cdprogra||
                        '. '||sqlerrm;

          --Inclusão na tabela de erros Oracle - Chamado 822997
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

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
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;

        --Grava tabela de log - Ch 822997
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        --Inclusão na tabela de erros Oracle - Chamado 822997
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

        --Grava tabela de log - Ch 822997
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 3);

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps480;
/
