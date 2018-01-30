CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS110" (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                                ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                                ,pr_cdagenci  IN PLS_INTEGER DEFAULT 0  --> Código da agência, utilizado no paralelismo
                                                ,pr_idparale  IN PLS_INTEGER DEFAULT 0  --> Identificador do job executando em paralelo.
                                                ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                                ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                                ,pr_dscritic OUT VARCHAR2) IS
BEGIN

/* .............................................................................

 Programa: pc_crps110                      Antigo: Fontes/crps110.p
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Odair
 Data    : Janeiro/95                      Ultima Alteracao: 05/01/2018

 Dados referentes ao programa:

 Frequencia: Mensal (Batch - Background).
 Objetivo  : Atende a solicitacao 058.
             Emite o resumo dos saldos das aplicacoes RDCA por dia de aniver-
             sario e por agencia.

 Alteracoes: 06/12/95 - Alterado para modificar a logica do programa,ele dei-
                        xou de trabalhar com workfile e trabalha com arquivo
                        convencional classificado pelo sort (Odair).

             25/11/96 - Tratar RDCAII (Odair).

             29/12/1999 - Nao gerar relatorio se nao ha aplicacoes
                          (Deborah).

             12/01/2000 - Nao gerar pedido de impressao (Deborah).

             11/02/2000 - Gerar pedido de impressao (Deborah).

             20/01/2003 - Quebra de pagina por Pac e 2 vias (Deborah).

             06/09/2004 - Criar um relatorio por Agencia (Ze Eduardo).

             13/10/2004 - NAO marcar a solicitacao como atendida (Evandro).

             18/01/2005 - Incluida coluna "ORDEM" no relatorio (Evandro).

             01/08/2005 - Colocar numero da agencia no resumo
                          geral (Margarete).

             06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                          "fontes/iniprg.p" por causa da "glb_cdcooper"
                          (Evandro).

             15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

             22/05/2006 - Alterado numero de vias do relatorio para
                          Viacredi (Diego).

             22/06/2007 - Somente lista aplicacoes RDCA30 e RDCA60 (Elton).

             30/07/2007 - Tratamento para aplicacoes RDC (David).

             14/08/2007 - Acerto na dtiniper e dtfimper (Magui).

             26/11/2007 - Substituir chamada da include aplicacao.i pela
                          BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                          (Sidnei - Precise).

             01/06/2011 - Estanciado a b1wgen0004 no inicio do programa
                          e deletado ao final para ganho de performance
                          (Adriano).

             16/04/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

             16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

             11/11/2013 - Remover geração do pdf dos relatório 090 por PA
                          (Marcos-Supero)

             29/11/2013 - Alterado totalizador de 99 para 999. (Marcos-Supero)
             
             21/08/2014 - Adicionado resumo das aplicações com vencimento nos
                          próximos 30 dias para craprac no relatório crrl090.
                          (Reinert)
                          
             05/01/2018 - Rotina atualizada para permitir execução por paralelismo 
                          quando necessário - Projeto Ligeirinho (Roberto Nunhes - AMCOM).

   ............................................................................. */

   DECLARE

     /* Tipos e registros da pc_crps110 */

     --Definicao do tipo de registro para aplicacoes rdca
     TYPE typ_reg_ordem IS
       RECORD (cdagenci crapage.cdagenci%TYPE
              ,nmresage crapage.nmresage%TYPE
              ,vlpercen NUMBER
              ,ordem    INTEGER);
     --Definicao do tipo de registro para relatorio geral
     TYPE typ_reg_detalhe IS
       RECORD (dtrefere craprda.dtfimper%TYPE
              ,qtaplica INTEGER
              ,vlaplica craprda.vlaplica%TYPE
              ,vlsdrdca craprda.vlsdrdca%TYPE);
              
       --Definicao do tipo de registro para relatorio por data
     TYPE typ_reg_detalhe_data IS
       RECORD (dtrefere craprda.dtfimper%TYPE
              ,qtaplica INTEGER
              ,vlaplica craprda.vlaplica%TYPE
              ,vlsdrdca craprda.vlsdrdca%TYPE);
     -- Definição da tabela que conterá registros das aplicações por data
     TYPE typ_tab_detalhe_data IS TABLE OF typ_reg_detalhe_data INDEX BY VARCHAR2(15);
              
       --Definicao do tipo de registro para relatorio por PA     
     TYPE typ_reg_detalhe_pa IS
       RECORD (vr_tab_detalhe_data typ_tab_detalhe_data);
     -- Definição da tabela que conterá registros das aplicações por PA
     TYPE typ_tab_detalhe_pa IS TABLE OF typ_reg_detalhe_pa INDEX BY PLS_INTEGER;

     --Definicao dos tipos de tabelas de memoria
     TYPE typ_tab_tot     IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
     TYPE typ_tab_ordem   IS TABLE OF typ_reg_ordem INDEX BY PLS_INTEGER;
     TYPE typ_tab_detalhe IS TABLE OF typ_reg_detalhe INDEX BY VARCHAR2(8);
     TYPE typ_tab_agencia IS TABLE OF NUMBER INDEX BY VARCHAR2(15);

     --Definicao das tabelas de memoria
     vr_tab_crapdtc      typ_tab_tot;
     vr_tab_tot_qtaplica typ_tab_tot;
     vr_tab_tot_vlaplica typ_tab_tot;
     vr_tab_tot_vlsdrdca typ_tab_tot;
     vr_tab_ordem        typ_tab_ordem;
     vr_tab_detalhe      typ_tab_detalhe;
     vr_tab_agencia      typ_tab_agencia;
     vr_tab_detalhe_pa   typ_tab_detalhe_pa;
     vr_tab_erro         GENE0001.typ_tab_erro;
     
     -- Qtde parametrizada de Jobs
     vr_qtdjobs       number;
     -- Job name dos processos criados
     vr_jobname       varchar2(30);
     -- Bloco PLSQL para chamar a execução paralela do pc_crps750
     vr_dsplsql       varchar2(4000); 
     -- crapdat inproces
     vr_inproces      crapdat.inproces%type;     
     -- ID para o paralelismo
     vr_idparale      integer;
     vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE; 
     vr_idlog_ini_ger tbgen_prglog.idprglog%type;
     vr_idlog_ini_par tbgen_prglog.idprglog%type;
     vr_qterro        number := 0;
     vr_dscritic      varchar2(4000);
     vr_tpexecucao    tbgen_prglog.tpexecucao%type;

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
       SELECT cop.cdcooper
             ,cop.nmrescop
             ,cop.nrtelura
             ,cop.cdbcoctl
             ,cop.cdagectl
             ,cop.dsdircop
             ,cop.nrctactl
       FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;
     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     --Selecionar todas as agencias
     CURSOR cr_crapage (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ) IS
       SELECT  crapage.cdagenci
              ,crapage.nmresage
       FROM crapage crapage
       WHERE  crapage.cdcooper = pr_cdcooper
         --Inclusão de filtro por agência para tratar o paralelismo
         AND  crapage.cdagenci = decode(pr_cdagenci,0,crapage.cdagenci,pr_cdagenci);    
         
     --Selecionar todas as agencias
     CURSOR cr_crapage_par (pr_cdcooper IN crapass.cdcooper%TYPE
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                           ,pr_cdprogra IN tbgen_batch_controle.cdprogra%TYPE
                           ,pr_qterro   IN number
                           ) IS
       SELECT  crapage.cdagenci
              ,crapage.nmresage
       FROM crapage crapage
       WHERE  crapage.cdcooper = pr_cdcooper
         AND (pr_qterro = 0 OR 
             (pr_qterro > 0 AND EXISTS (SELECT 1
                                         FROM tbgen_batch_controle
                                        WHERE tbgen_batch_controle.cdcooper    = pr_cdcooper
                                          AND tbgen_batch_controle.cdprogra    = pr_cdprogra
                                          AND tbgen_batch_controle.tpagrupador = 1
                                          AND tbgen_batch_controle.cdagrupador = crapage.cdagenci
                                          AND tbgen_batch_controle.insituacao  = 1
                                          AND tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)));  

     --Selecionar informacoes das aplicacoes rdca ordenadas por data final do periodo
     --de rendimento
     CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE
                       ,pr_insaqtot IN craprda.insaqtot%TYPE
                       ,pr_dtiniper IN craprda.dtfimper%TYPE
                       ,pr_dtfimper IN craprda.dtfimper%TYPE
                       ,pr_cdagenci IN craprda.cdageass%TYPE) IS
       SELECT craprda.insaqtot
             ,craprda.nrdconta
             ,craprda.nraplica
             ,craprda.vlaplica
             ,craprda.dtmvtolt
             ,craprda.cdageass
             ,craprda.tpaplica
             ,craprda.dtfimper
             ,craprda.dtvencto
             ,craprda.vlsdrdca
             ,Count(*) OVER (PARTITION BY craprda.cdageass) qtregtot
             ,ROW_NUMBER () OVER (PARTITION BY craprda.cdageass
                                  ORDER BY craprda.cdageass,craprda.dtfimper ASC, craprda.nrdconta) nrseqtot
             ,Count(*) OVER (PARTITION BY craprda.cdageass,craprda.dtfimper) qtregdata
             ,ROW_NUMBER () OVER (PARTITION BY craprda.cdageass,craprda.dtfimper
                                  ORDER BY craprda.cdageass,craprda.dtfimper ASC, craprda.nrdconta) nrseqreg
       FROM craprda craprda
       WHERE craprda.cdcooper = pr_cdcooper
       AND   craprda.insaqtot = pr_insaqtot
       AND   craprda.cdageass = pr_cdagenci
       AND   craprda.dtfimper BETWEEN pr_dtiniper AND pr_dtfimper;

     --Selecionar as formas de captacao de recursos
     CURSOR cr_crapdtc (pr_cdcooper IN crapdtc.cdcooper%TYPE) IS
       SELECT crapdtc.tpaplica
             ,crapdtc.tpaplrdc
       FROM crapdtc crapdtc
       WHERE crapdtc.cdcooper = pr_cdcooper;
       
     -- Selecionar informações de aplicações de captação  
     CURSOR cr_craprac (pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_dtiniper IN craprac.dtmvtolt%TYPE
                       ,pr_dtfimper IN craprac.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapass.cdagenci%TYPE) IS 
       SELECT rac.cdprodut
             ,rac.qtdiacar
             ,rac.nrdconta
             ,rac.nraplica
             ,rac.dtmvtolt
             ,rac.txaplica
             ,rac.dtvencto
             ,rac.vlaplica
             ,ass.cdagenci
             ,COUNT(*) OVER (PARTITION BY ass.cdagenci, 
                                          rac.dtvencto) qtregdata
             ,ROW_NUMBER () OVER (PARTITION BY ass.cdagenci,rac.dtvencto
                                  ORDER BY ass.cdagenci,rac.dtvencto ASC, rac.nrdconta) nrseqreg
         FROM craprac rac,
              crapass ass
        WHERE rac.cdcooper = pr_cdcooper
          AND rac.idsaqtot = 0
          AND rac.dtvencto BETWEEN pr_dtiniper AND pr_dtfimper
          AND ass.cdagenci = pr_cdagenci
          AND rac.cdcooper = ass.cdcooper
          AND rac.nrdconta = ass.nrdconta;
     rw_craprac cr_craprac%ROWTYPE;
     
     -- Selecionar informações de produtos de captação
     CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
       SELECT cpc.idtippro
             ,cpc.cddindex
             ,cpc.idtxfixa
         FROM crapcpc cpc
        WHERE cpc.cdprodut = pr_cdprodut;
     rw_crapcpc cr_crapcpc%ROWTYPE;

     --Constantes Locais
     vr_cdagenci_par CONSTANT INTEGER:= 0;
     vr_nrdcaixa_par CONSTANT INTEGER:= 0;

     --Variaveis Locais
     vr_rel_qtaplica INTEGER;
     vr_rel_vlaplica NUMBER;
     vr_rel_vlsdrdca NUMBER;     
     vr_rel_nmresage VARCHAR2(100);
     vr_vlaplica     NUMBER;
     vr_vldperda     NUMBER;
     vr_vlpercen     NUMBER;
     vr_ger_vlsdrdca NUMBER;
     vr_txaplica     NUMBER;
     vr_cdprogra     VARCHAR2(10);
     vr_cdcritic     INTEGER;
     vr_contador     INTEGER;
     vr_cdagenci     INTEGER;
     vr_dtmvtolt     DATE;
     vr_dtmvtopr     DATE;
     vr_dtiniper     DATE;
     vr_dtfimper     DATE;
     vr_dtinitax     DATE;
     vr_dtfimtax     DATE;
     vr_vlsldapl     NUMBER(25,8);
     vr_sldpresg_tmp craplap.vllanmto%TYPE; --> Valor saldo de resgate
     vr_dup_vlsdrdca craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA

     --Variaveis usadas no retorno da procedure pc_saldo_rgt_rdc_pos
     vr_sldpresg     NUMBER(18,8); --> Saldo para resgate
     vr_vlrenrgt     NUMBER(18,8);          --> Rendimento resgatado periodo
     vr_vlrdirrf     craplap.vllanmto%TYPE; --> Valor do irrf sobre o rendimento
     vr_perirrgt     NUMBER(18,2);          --> % de IR Resgatado
     vr_vlrrgtot     craplap.vllanmto%TYPE; --> Resgate para zerar a aplicação
     vr_vlirftot     craplap.vllanmto%TYPE; --> IRRF para finalizar a aplicacao
     vr_vlrendmm     craplap.vlrendmm%TYPE; --> Rendimento da ultima provisao até a data do resgate
     vr_vlrvtfim     craplap.vllanmto%TYPE; --> Quantia provisao reverter para zerar a aplicação
     
     -- Variaveis usadas no retorno da procedure pc_posicao_saldo_aplicacao_pre
     vr_vlsldtot NUMBER;      --> Saldo Total da Aplicação
     vr_vlultren NUMBER;      --> Valor Último Rendimento
     vr_vlsldrgt NUMBER;      --> Saldo Total para Resgate
     vr_vlrentot NUMBER;      --> Valor Rendimento Total
     vr_vlrevers NUMBER;      --> Valor de Reversão
     vr_percirrf NUMBER;      --> Percentual do IRRF
     vr_vlbascal NUMBER := 0; --> Valor Base Cálculo


     --Variavel usada para montar o indice da tabela de memoria
     vr_index_detalhe VARCHAR2(8);
     vr_index_agencia INTEGER;
     vr_index_ordem   INTEGER;

     -- Variável para armazenar as informações em XML
     vr_des_xml     CLOB;

     --Variaveis para retorno de erro
     vr_des_erro    VARCHAR2(4000);
     vr_des_compl   VARCHAR2(4000);
     vr_dstextab    VARCHAR2(1000);

     --Variavel para arquivo de dados e xml
     vr_nom_direto  VARCHAR2(100);
     vr_nom_arquivo VARCHAR2(100);

     --Variaveis de Excecao
     vr_exc_saida  EXCEPTION;
     vr_exc_fimprg EXCEPTION;
     vr_exc_pula   EXCEPTION;

     --Procedure para limpar os dados das tabelas de memoria
     PROCEDURE pc_limpa_tabela IS
     BEGIN
       vr_tab_crapdtc.DELETE;
       vr_tab_ordem.DELETE;
       vr_tab_detalhe.DELETE;
       vr_tab_agencia.DELETE;
       vr_tab_tot_qtaplica.DELETE;
       vr_tab_tot_vlaplica.DELETE;
       vr_tab_tot_vlsdrdca.DELETE;
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_des_erro:= 'Erro ao limpar tabelas de memória. Rotina pc_crps110.pc_limpa_tabela. '||sqlerrm;
         vr_dscritic := vr_des_erro;
         --Sair do programa
         RAISE vr_exc_saida;
     END;

     --Inicializar a tabela de memoria
     PROCEDURE pc_inicializa_tabela IS
     BEGIN
       --Inicializar todas as posicoes do varray com 0.
       FOR idx IN 1..999 LOOP
         vr_tab_tot_qtaplica(idx):= 0;
         vr_tab_tot_vlaplica(idx):= 0;
         vr_tab_tot_vlsdrdca(idx):= 0;
       END LOOP;
     END;

     --Escrever no arquivo CLOB
     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
     BEGIN
       --Escrever no arquivo XML
       dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
     END;

     --Geração do relatório crrl090 totalizador
     PROCEDURE pc_imprime_crrl090_total (pr_des_erro OUT VARCHAR2) IS

       --Variaveis Locais
       vr_nrcopias     INTEGER;
       vr_qtaplica     INTEGER;
       vr_vlaplica     NUMBER;
       vr_vlsdrdca     NUMBER;
       vr_tot_vlsdrdca NUMBER;

       --Variavel de Exceção
       vr_exc_erro EXCEPTION;

     BEGIN
       --Inicializar variavel de erro
       pr_des_erro:= NULL;
       -- Busca do diretório base da cooperativa
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
       --Determinar o nome do arquivo que será gerado
       vr_nom_arquivo := 'crrl090_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');
       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl090_total><detalhes>');

       --Zerar o totalizador do saldo
       vr_tot_vlsdrdca:= 0;

       --Acessar primeiro registro da tabela de memoria de detalhe
       vr_index_detalhe:= vr_tab_detalhe.FIRST;
       WHILE vr_index_detalhe IS NOT NULL  LOOP
         --Montar tag da conta para arquivo XML
         pc_escreve_xml
           ('<detalhe>
              <dtfimper>'||To_Char(vr_tab_detalhe(vr_index_detalhe).dtrefere,'DD/MM/YYYY')||'</dtfimper>
              <qtaplica>'||To_Char(vr_tab_detalhe(vr_index_detalhe).qtaplica,'999g999g990')||'</qtaplica>
              <vlaplica>'||To_Char(vr_tab_detalhe(vr_index_detalhe).vlaplica,'fm999g999g999g990d00')||'</vlaplica>
              <vlsdrdca>'||To_Char(vr_tab_detalhe(vr_index_detalhe).vlsdrdca,'fm999g999g999g990d00')||'</vlsdrdca>
           </detalhe>');
         --Acumular o total geral para o calculo do percentual
         vr_tot_vlsdrdca:= Nvl(vr_tot_vlsdrdca,0) + Nvl(vr_tab_detalhe(vr_index_detalhe).vlsdrdca,0);
         --Encontrar o proximo registro da tabela de memoria
         vr_index_detalhe:= vr_tab_detalhe.NEXT(vr_index_detalhe);
       END LOOP;

       --Finalizar tag detalhe
       pc_escreve_xml('</detalhes><agencias>');

       /* pegar os percentuais em relacao ao total dos saldos */
       FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper
                                    --Incluido parametro de agencia para aplicar paralelismo
                                    ,pr_cdagenci => 0 --Utiliza o parâmetro fixo para que o cursor retorne todas as agências.
                                     ) LOOP
         --Se a quantidade aplicada e o saldo forem > 0
         IF vr_tab_tot_qtaplica.EXISTS(rw_crapage.cdagenci) AND
            vr_tab_tot_vlsdrdca.EXISTS(rw_crapage.cdagenci) AND
            (vr_tab_tot_qtaplica(rw_crapage.cdagenci) != 0 OR
            vr_tab_tot_vlsdrdca(rw_crapage.cdagenci) != 0) THEN

           --Valor do percentual recebe saldo total da agencia * 100 / saldo agencia
           vr_vlpercen:= vr_tab_tot_vlsdrdca(rw_crapage.cdagenci) * 100 / vr_tot_vlsdrdca;
           --Gravar informacoes na tabela de memoria
           vr_tab_ordem(rw_crapage.cdagenci).cdagenci:= rw_crapage.cdagenci;
           vr_tab_ordem(rw_crapage.cdagenci).nmresage:= rw_crapage.nmresage;
           vr_tab_ordem(rw_crapage.cdagenci).vlpercen:= vr_vlpercen;
           vr_tab_ordem(rw_crapage.cdagenci).ordem:= 0;
           --Criar registro na tabela de ordenacao
           -- (Multiplico o vr_vlpercen por 1000, pois sem isso os numeros ficam muito
           --  próximos o que gera problema na ordenação)
           vr_index_agencia:= LPad(9999999999 - (vr_vlpercen*1000),10,'0')||LPad(rw_crapage.cdagenci,5,'0');
           vr_tab_agencia(vr_index_agencia):= rw_crapage.cdagenci;

         END IF;
       END LOOP;

       /* ordenar os PA'S de acordo com o percentual */

       --Inicializar contador
       vr_contador:= 1;
       --Posicionar no primeiro registro (maior percentual de participacao)
       vr_index_agencia:= vr_tab_agencia.FIRST;
       WHILE vr_index_agencia IS NOT NULL LOOP

         vr_tab_ordem(vr_tab_agencia(vr_index_agencia)).ordem:= vr_contador;
         --Encontrar o proximo registro da tabela de memoria
         vr_index_agencia:= vr_tab_agencia.NEXT(vr_index_agencia);

         --Incrementar contador da ordem
         vr_contador:= vr_contador+1;
       END LOOP;

       -- Processar todos os registros ordenados por agencia para gravar XML
       vr_index_ordem:= vr_tab_ordem.FIRST;
       --Enquanto o registro nao for nulo
       WHILE vr_index_ordem IS NOT NULL LOOP
         --Determinar o codigo da agencia
         vr_cdagenci:= vr_tab_ordem(vr_index_ordem).cdagenci;
         --Montar a descricao da agencia
         vr_rel_nmresage:= To_Char(vr_tab_ordem(vr_index_ordem).cdagenci,'fm009') ||'-'||
                           vr_tab_ordem(vr_index_ordem).nmresage;
         --Zerar variaveis
         vr_qtaplica:= 0;
         vr_vlaplica:= 0;
         vr_vlsdrdca:= 0;
         --Encontrar a quantidade aplicada
         IF vr_tab_tot_qtaplica.EXISTS(vr_cdagenci) THEN
           vr_qtaplica:= vr_tab_tot_qtaplica(vr_cdagenci);
         END IF;
         --Encontrar o valor aplicado
         IF vr_tab_tot_vlaplica.EXISTS(vr_cdagenci) THEN
           vr_vlaplica:= vr_tab_tot_vlaplica(vr_cdagenci);
         END IF;
         --Encontrar o valor do saldo
         IF vr_tab_tot_vlsdrdca.EXISTS(vr_cdagenci) THEN
           vr_vlsdrdca:= vr_tab_tot_vlsdrdca(vr_cdagenci);
         END IF;
         --Montar tag da agencia para arquivo XML
         pc_escreve_xml
             ('<agencia>
                <nmresage>'||substr(vr_rel_nmresage,1,18)||'</nmresage>
                <qtaplica>'||To_Char(vr_qtaplica,'999g990')||'</qtaplica>
                <vlaplica>'||To_Char(vr_vlaplica,'fm999g999g990d00')||'</vlaplica>
                <vlsdrdca>'||To_Char(vr_vlsdrdca,'fm999g999g990d00')||'</vlsdrdca>
                <ordem>'||To_Char(vr_tab_ordem(vr_index_ordem).ordem,'999g990')||'</ordem>
             </agencia>');
         -- Buscar o próximo registro da tabela
         vr_index_ordem:= vr_tab_ordem.NEXT(vr_index_ordem);
       END LOOP;

       --Finalizar agrupador agencia e do relatorio
       pc_escreve_xml('</agencias></crrl090_total>');

       --Se for Viacredi imprime 1 copia
       IF pr_cdcooper = 1 THEN
         --Somente uma copia
         vr_nrcopias:= 1;
       ELSE
         --Demais cooperativas imprime 3 copias
         vr_nrcopias:= 3;
       END IF;

       -- Efetuar solicitação de geração de relatório --
       gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper            --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra            --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt    --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml             --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl090_total'       --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl090_total.jasper' --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                   --> Titulo do relatório
                                  ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                  ,pr_qtcoluna  => 132                    --> 132 colunas
                                  ,pr_sqcabrel  => 1                      --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                  ,pr_flg_impri => 'S'                    --> Chamar a impressão (Imprim.p)
                                  ,pr_nmformul  => '132col'              --> Nome do formulário para impressão
                                  ,pr_nrcopias  => vr_nrcopias           --> Número de cópias
                                  ,pr_flg_gerar => 'N'                   --> gerar PDF
                                  ,pr_des_erro  => vr_des_erro);         --> Saída com erro
       -- Liberando a memória alocada pro CLOB
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);

       -- Testar se houve erro
       IF vr_des_erro IS NOT NULL THEN
         vr_dscritic := vr_des_erro;
         -- Gerar exceção
         RAISE vr_exc_saida;
       END IF;

     EXCEPTION
       WHEN vr_exc_erro THEN
         pr_des_erro:= vr_des_erro;
         vr_dscritic:= vr_des_erro;
       WHEN OTHERS THEN
         pr_des_erro:= 'Erro ao imprimir relatório crrl090_99. '||sqlerrm;
     END;
     
   ---------------------------------------
   -- Inicio Bloco Principal pc_crps110
   ---------------------------------------
   BEGIN

     --Atribuir o nome do programa que está executando
     vr_cdprogra:= 'CRPS110';

     -- Incluir nome do módulo logado
     GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS110'
                               ,pr_action => NULL);

     -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
       CLOSE cr_crapcop;
       vr_cdcritic:= 651;
       -- Montar mensagem de critica
       vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       if vr_des_erro is not null then 
         vr_dscritic:= vr_des_erro;
       end if; 
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE cr_crapcop;
     END IF;

     -- Verifica se a cooperativa esta cadastrada
     OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     -- Se não encontrar
     IF BTCH0001.cr_crapdat%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
       CLOSE BTCH0001.cr_crapdat;
       vr_cdcritic:= 1;
       -- Montar mensagem de critica
       vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       if vr_des_erro is not null then 
         vr_dscritic := vr_des_erro;
       end if; 
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE BTCH0001.cr_crapdat;
       --Atribui o inproces
       vr_inproces:= rw_crapdat.inproces;    
       --Atribuir a data do movimento
       vr_dtmvtolt:= rw_crapdat.dtmvtolt;
       --Atribuir a proxima data do movimento
       vr_dtmvtopr:= rw_crapdat.dtmvtopr;
     END IF;

     -- Validações iniciais do programa
     BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

     --Se retornou critica aborta programa
     IF vr_cdcritic <> 0 THEN
       --Sair do programa
       RAISE vr_exc_saida;
     END IF;

     --Zerar tabelas de memoria auxiliar
     pc_limpa_tabela;
     --Inicializar tabelas de memoria de totalizadores
     pc_inicializa_tabela;
     --Carregar tabela de memoria de tipos de captacao
     FOR rw_crapdtc IN cr_crapdtc (pr_cdcooper => pr_cdcooper) LOOP
       vr_tab_crapdtc(rw_crapdtc.tpaplica):= rw_crapdtc.tpaplrdc;
     END LOOP;
     --Atribuir a data de inicio como a data do movimento
     vr_dtiniper:= vr_dtmvtolt;
     --Buscar a data final do periodo
     vr_dtfimper:= GENE0005.fn_calc_data(pr_dtmvtolt => vr_dtiniper
                                        ,pr_qtmesano => 1
                                        ,pr_tpmesano => 'M'
                                        ,pr_des_erro => vr_des_erro);
     --Se ocorreu erro
     IF vr_des_erro IS NOT NULL THEN
       vr_dscritic := vr_des_erro;
       --Levantar Exceção
       RAISE vr_exc_saida;
     END IF;

     /* Data de fim e inicio da utilizacao da taxa de poupanca.
     Utiliza-se essa data quando o rendimento da aplicacao for menor que
     a poupanca, a cooperativa opta por usar ou nao.
     Essa informacao é necessária para a rotina pc_saldo_rgt_rdc_pos */
     vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'MXRENDIPOS'
                                             ,pr_tpregist => 1);
     --Determinar as data de inicio e fim das taxas para rotina pc_saldo_rgt_rdc_pos
     vr_dtinitax := To_Date(gene0002.fn_busca_entrada(1, vr_dstextab, ';'),'DD/MM/YYYY');
     vr_dtfimtax := To_Date(gene0002.fn_busca_entrada(2, vr_dstextab, ';'),'DD/MM/YYYY');

     -- Busca do diretório base da cooperativa
     vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
     
     -- Buscar quantidade parametrizada de Jobs
     vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                                  ,pr_cdprogra => vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                                  ); 
     
     /* Paralelismo visando performance Rodar Somente no processo Noturno */
     if vr_inproces  > 2 and
        vr_qtdjobs   > 0 and 
        pr_cdagenci  = 0 then  
        
        -- Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_id_paralelo;
        
        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
           -- Levantar exceção
           vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
           RAISE vr_exc_saida;
        END IF;
        
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I',    
                        pr_cdprograma => vr_cdprogra,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger);
                        
        
        -- Verifica se algum job paralelo executou com erro
        vr_qterro := 0;
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => vr_cdprogra,
                                                      pr_dtmvtolt    => vr_dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);   
                                                                              
        --Retorna todas as agencias utilizando o cursor principal original
        FOR rw_crapage_par IN cr_crapage_par (pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => vr_dtmvtolt
                                             ,pr_cdprogra => vr_cdprogra
                                             ,pr_qterro   => vr_qterro
                                              ) LOOP
          
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := vr_cdprogra ||'_'|| rw_crapage_par.cdagenci || '$'; 
          
          -- Cadastra o programa paralelo
          gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(rw_crapage_par.cdagenci,3,'0') --> Utiliza a agência como id programa
                                    ,pr_des_erro => vr_dscritic);
                                    
          -- Testar saida com erro
          if vr_dscritic is not null then
            -- Levantar exceçao
            raise vr_exc_saida;
          end if; 
          
          -- Montar o bloco PLSQL que será executado
          -- Ou seja, executaremos a geração dos dados
          -- para a agência atual atraves de Job no banco
          vr_dsplsql := 'DECLARE' || chr(13) || --
                        '  wpr_stprogra NUMBER;' || chr(13) || --
                        '  wpr_infimsol NUMBER;' || chr(13) || --
                        '  wpr_cdcritic NUMBER;' || chr(13) || --
                        '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                        'BEGIN' || chr(13) || --         
                        '  pc_crps110( '|| pr_cdcooper             || ',' ||
                                           '0'                     || ',' ||
                                           rw_crapage_par.cdagenci     || ',' ||
                                           vr_idparale             || ',' ||
                                           ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' || chr(13) ||
                        'END;';
                        
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => vr_dscritic);    
                                 
          -- Testar saida com erro
          if vr_dscritic is not null then 
             -- Levantar exceçao
             raise vr_exc_saida;
          end if;
          
          -- Chama rotina que irá pausar este processo controlador
          -- caso tenhamos excedido a quantidade de JOBS em execuçao
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                      ,pr_des_erro => vr_dscritic);
          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;           
        END LOOP;

        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- até que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => vr_dscritic);
                                    

        -- Verifica se algum job paralelo executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => vr_cdprogra,
                                                      pr_dtmvtolt    => vr_dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);
        if vr_qterro > 0 then 
          vr_cdcritic := 0;
          vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
          raise vr_exc_saida;
        end if; 
     else 
       if pr_cdagenci <> 0 then
         vr_tpexecucao := 2;
       else
         vr_tpexecucao := 1;
       end if; 
       
       -- Grava controle de batch por agência
       gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                       ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                       ,pr_dtmvtolt    => vr_dtmvtolt               -- Data de Movimento
                                       ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                       ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                       ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                       ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                       ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                       ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                       ,pr_dscritic    => vr_dscritic );      
      
       --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
       pc_log_programa(pr_dstiplog   => 'I',    
                       pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                       pr_cdcooper   => pr_cdcooper, 
                       pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       pr_idprglog   => vr_idlog_ini_par); 
                           
       -- Grava LOG de ocorrência inicial do cursor cr_craprpp
       pc_log_programa(PR_DSTIPLOG           => 'O',
                       PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                       pr_cdcooper           => pr_cdcooper,
                       pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       pr_tpocorrencia       => 4,
                       pr_dsmensagem         => 'Início - cursor cr_crapage. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                       PR_IDPRGLOG           => vr_idlog_ini_par);      
     
       FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper
                                     --Incluido parametro de agencia para aplicar paralelismo
                                    ,pr_cdagenci => pr_cdagenci
                                     ) LOOP
                                     
                  
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl090_'||To_Char(rw_crapage.cdagenci,'fm009');                  
                                            
         --Pesquisar todas as aplicacoes
         FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper
                                      ,pr_insaqtot => 0
                                      ,pr_dtiniper => vr_dtiniper
                                      ,pr_dtfimper => vr_dtfimper
                                      ,pr_cdagenci => rw_crapage.cdagenci) LOOP

           --Zerar o saldo geral
           vr_ger_vlsdrdca:= 0;
                             
           /* Calcular o Saldo da aplicacao ate a data do movimento */
           IF rw_craprda.tpaplica = 3 THEN

             -- Consulta saldo aplicação RDCA30 (Antiga includes/b1wgen0004.i)
             APLI0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                  ,pr_dtmvtolt => vr_dtmvtolt         --> Data do processo
                                                  ,pr_inproces => rw_crapdat.inproces --> Indicador do processo
                                                  ,pr_dtmvtopr => vr_dtmvtopr         --> Próximo dia util
                                                  ,pr_cdprogra => vr_cdprogra         --> Programa em execução
                                                  ,pr_cdagenci => vr_cdagenci_par     --> Código da agência
                                                  ,pr_nrdcaixa => vr_nrdcaixa_par     --> Número do caixa
                                                  ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicação RDCA
                                                  ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicação RDCA
                                                  ,pr_vlsdrdca => vr_ger_vlsdrdca     --> Saldo da aplicação
                                                  ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplicação RDCA
                                                  ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                  ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                  ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                                  ,pr_txaplica => vr_txaplica         --> Taxa aplicada sob o empréstimo
                                                  ,pr_des_reto => vr_des_erro         --> OK ou NOK
                                                  ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
             --Se retornou erro
             IF vr_des_erro = 'NOK' THEN
               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                 vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                 vr_des_erro:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta;
               ELSE
                 vr_cdcritic:= 0;
                 vr_des_erro:= 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca30 e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta;
               END IF;
               vr_dscritic := vr_des_erro;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
           ELSIF rw_craprda.tpaplica = 5 THEN

             -- Consulta saldo aplicação RDCA60 (Antiga includes/b1wgen0004a.i)
             APLI0001.pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                  ,pr_dtmvtolt => vr_dtmvtolt         --> Data do movto atual
                                                  ,pr_dtmvtopr => vr_dtmvtopr         --> Data do próximo movimento
                                                  ,pr_cdprogra => vr_cdprogra         --> Programa em execução
                                                  ,pr_cdagenci => vr_cdagenci_par     --> Código da agência
                                                  ,pr_nrdcaixa => vr_nrdcaixa_par     --> Número do caixa
                                                  ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicação RDCA
                                                  ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicação RDCA
                                                  ,pr_vlsdrdca => vr_ger_vlsdrdca     --> Saldo da aplicação
                                                  ,pr_sldpresg => vr_sldpresg         --> Saldo para resgate
                                                  ,pr_des_reto => vr_des_erro         --> OK ou NOK
                                                  ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros

             --Se retornou erro
             IF vr_des_erro = 'NOK' THEN
               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                 vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                 vr_des_erro:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta;
               ELSE
                 vr_cdcritic:= 0;
                 vr_des_erro:= 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca60 e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta;
               END IF;
               vr_dscritic := vr_des_erro;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
           ELSE
             --Selecionar os tipos de captação
             IF NOT vr_tab_crapdtc.EXISTS(rw_craprda.tpaplica) THEN
               vr_cdcritic:= 346;
               --Descricao do erro recebe mensagam da critica
               vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               --Complementar a msg erro
               vr_des_compl:= ' Conta/dv: '||gene0002.fn_mask_conta(rw_craprda.nrdconta)||
                              ' Nr.Aplicacao: '||rw_craprda.nraplica;
               -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || vr_des_erro || vr_des_compl);
               --volta para o inicio do for
               vr_cdcritic := 0;
               vr_des_erro := NULL;
               continue;
             ELSE
               --Deletar todos os erros
               vr_tab_erro.DELETE;
               --Se for uma aplicacao rdcpre
               IF vr_tab_crapdtc(rw_craprda.tpaplica) = 1 THEN /* RDCPRE */

                 --Consultar saldo rdc pre
                 APLI0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper          --> Cooperativa
                                          ,pr_nrdconta => rw_craprda.nrdconta  --> Nro da conta da aplicação RDCA
                                          ,pr_nraplica => rw_craprda.nraplica  --> Nro da aplicação RDCA
                                          ,pr_dtmvtolt => rw_craprda.dtvencto  --> Data do processo (Não necessariamente da CRAPDAT)
                                          ,pr_dtiniper => NULL                 --> Data de início da aplicação
                                          ,pr_dtfimper => NULL                 --> Data de término da aplicação
                                          ,pr_txaplica => 0                    --> Taxa aplicada
                                          ,pr_flggrvir => FALSE                --> Identificador se deve gravar valor insento
                                          ,pr_tab_crapdat => rw_crapdat        --> Controle de Datas
                                          ,pr_vlsdrdca => vr_ger_vlsdrdca      --> Saldo da aplicação pós cálculo
                                          ,pr_vlrdirrf => vr_vlrdirrf          --> Valor de IR
                                          ,pr_perirrgt => vr_perirrgt          --> Percentual de IR resgatado
                                          ,pr_des_reto => vr_des_erro          --> OK ou NOK
                                          ,pr_tab_erro => vr_tab_erro);        --> Tabela com erros

                 --Se retornou erro
                 IF vr_des_erro = 'NOK' THEN
                   -- Tenta buscar o erro no vetor de erro
                   IF vr_tab_erro.COUNT > 0 THEN
                     vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                     vr_des_erro:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta ||' Nr.Aplicacao: '||rw_craprda.nraplica;
                   ELSE
                     vr_cdcritic:= 0;
                     vr_des_erro:= 'Retorno "NOK" na apli0001.pc_saldo_rdc_pre e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta;
                   END IF;
                   vr_dscritic := vr_des_erro;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                 END IF;
               --Se for uma aplicacao rdcpos
               ELSIF vr_tab_crapdtc(rw_craprda.tpaplica) = 2 THEN /* RDCPOS*/

                 -- Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF.
                 APLI0001.pc_saldo_rgt_rdc_pos(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                              ,pr_cdagenci => vr_cdagenci_par     --> Código da agência
                                              ,pr_nrdcaixa => vr_nrdcaixa_par     --> Número do caixa
                                              ,pr_nrctaapl => rw_craprda.nrdconta --> Nro da conta da aplicação RDC
                                              ,pr_nraplres => rw_craprda.nraplica --> Nro da aplicação RDC
                                              ,pr_dtmvtolt => vr_dtmvtolt         --> Data do movimento atual passado
                                              ,pr_dtaplrgt => vr_dtmvtolt         --> Data do movimento atual passado
                                              ,pr_vlsdorgt => 0                   --> Valor RDC
                                              ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                              ,pr_dtinitax => vr_dtinitax         --> Data Inicial da Utilizacao da taxa da poupanca
                                              ,pr_dtfimtax => vr_dtfimtax         --> Data Final da Utilizacao da taxa da poupanca
                                              ,pr_vlsddrgt => vr_sldpresg         --> Valor do resgate total sem irrf ou o solicitado
                                              ,pr_vlrenrgt => vr_vlrenrgt         --> Rendimento total a ser pago quando resgate total
                                              ,pr_vlrdirrf => vr_vlrdirrf         --> IRRF do que foi solicitado
                                              ,pr_perirrgt => vr_perirrgt         --> Percentual de aliquota para calculo do IRRF
                                              ,pr_vlrgttot => vr_vlrrgtot         --> Resgate para zerar a aplicação
                                              ,pr_vlirftot => vr_vlirftot         --> IRRF para finalizar a aplicacao
                                              ,pr_vlrendmm => vr_vlrendmm         --> Rendimento da ultima provisao até a data do resgate
                                              ,pr_vlrvtfim => vr_vlrvtfim         --> Quantia provisao reverter para zerar a aplicação
                                              ,pr_des_reto => vr_des_erro         --> OK ou NOK
                                              ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros

                 --Se retornou erro
                 IF vr_des_erro = 'NOK' THEN
                   -- Tenta buscar o erro no vetor de erro
                   IF vr_tab_erro.COUNT > 0 THEN
                     vr_cdcritic:=  vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                     vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta ||' Nr.Aplicacao: '||rw_craprda.nraplica;
                   ELSE
                     vr_cdcritic:= 0;
                     vr_des_erro := 'Retorno "NOK" na apli0001.pc_saldo_rgt_rdc_pos e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta;
                   END IF;
                   vr_dscritic := vr_des_erro;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                 END IF;
                 --Se o valor do resgate > 0
                 IF Nvl(vr_vlrrgtot,0) > 0 THEN
                   --Valor saldo rdca recebe valor resgate
                   vr_ger_vlsdrdca:= vr_vlrrgtot;
                 ELSE
                   --Valor saldo rdca recebe valor saldo rdca
                   vr_ger_vlsdrdca:= Nvl(rw_craprda.vlsdrdca,0);
                 END IF;
               END IF; --vr_tab_crapdtc(rw_craprda.tpaplica) = 1
             END IF; --vr_tab_crapdtc.EXISTS
           END IF; --rw_craprda.tpaplica = 3


           --Se o valor do saldo rdca
           IF vr_ger_vlsdrdca > 0 THEN
             IF NOT vr_tab_detalhe_pa.EXISTS(rw_crapage.cdagenci) OR
						  NOT vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data.EXISTS(to_char(rw_craprda.dtfimper, 'ddmmyyyy'))	THEN
                
               --Incrementar quantidade aplicada
               vr_rel_qtaplica:= Nvl(vr_rel_qtaplica,0) + 1;           
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).qtaplica := 1;
               
               --Acumular valor aplicado
               vr_rel_vlaplica:= Nvl(vr_rel_vlaplica,0) + Nvl(rw_craprda.vlaplica,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).vlaplica := Nvl(rw_craprda.vlaplica,0);
               
               --Acumular total saldo rdca
               vr_rel_vlsdrdca:= Nvl(vr_rel_vlsdrdca,0) + Nvl(vr_ger_vlsdrdca,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).vlsdrdca := Nvl(vr_ger_vlsdrdca,0);
               
               -- Data de referencia
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).dtrefere := rw_craprda.dtfimper;   
             ELSE
               
               --Incrementar quantidade aplicada
               vr_rel_qtaplica:= Nvl(vr_rel_qtaplica,0) + 1;           
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).qtaplica := 
               NVL(vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).qtaplica,0) + 1;
               
               --Acumular valor aplicado
               vr_rel_vlaplica:= Nvl(vr_rel_vlaplica,0) + Nvl(rw_craprda.vlaplica,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).vlaplica :=
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).vlaplica + Nvl(rw_craprda.vlaplica,0);
                 
               --Acumular total saldo rdca
               vr_rel_vlsdrdca:= Nvl(vr_rel_vlsdrdca,0) + Nvl(vr_ger_vlsdrdca,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).vlsdrdca :=
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).vlsdrdca + Nvl(vr_ger_vlsdrdca,0);
               
               -- Data de referencia   
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprda.dtfimper, 'ddmmyyyy')).dtrefere := rw_craprda.dtfimper;               
                                                                                                                  
             END IF;
             --Montar Indice para tabela de detalhes pela data
             vr_index_detalhe:= To_Char(rw_craprda.dtfimper,'YYYYMMDD');
             --Inserir os detalhes na tabela de aniversarios
             IF vr_tab_detalhe.EXISTS(vr_index_detalhe) THEN
               vr_tab_detalhe(vr_index_detalhe).qtaplica:= vr_tab_detalhe(vr_index_detalhe).qtaplica + 1;
               vr_tab_detalhe(vr_index_detalhe).vlaplica:= vr_tab_detalhe(vr_index_detalhe).vlaplica + Nvl(rw_craprda.vlaplica,0);
               vr_tab_detalhe(vr_index_detalhe).vlsdrdca:= vr_tab_detalhe(vr_index_detalhe).vlsdrdca + Nvl(vr_ger_vlsdrdca,0);
             ELSE
               vr_tab_detalhe(vr_index_detalhe).dtrefere:= rw_craprda.dtfimper;
               vr_tab_detalhe(vr_index_detalhe).qtaplica:= 1;
               vr_tab_detalhe(vr_index_detalhe).vlaplica:= Nvl(rw_craprda.vlaplica,0);
               vr_tab_detalhe(vr_index_detalhe).vlsdrdca:= Nvl(vr_ger_vlsdrdca,0);
             END IF;
           END IF;

           --Se for o ultimo registro da mesma data
           IF rw_craprda.qtregdata = rw_craprda.nrseqreg THEN

             --Acumular totais da quantidade aplicada para relatório geral
             vr_tab_tot_qtaplica(rw_craprda.cdageass):= vr_tab_tot_qtaplica(rw_craprda.cdageass) +
                                                        Nvl(vr_rel_qtaplica,0);
             --Acumular totais de valor aplicado para relatório geral
             vr_tab_tot_vlaplica(rw_craprda.cdageass):= vr_tab_tot_vlaplica(rw_craprda.cdageass) +
                                                        Nvl(vr_rel_vlaplica,0);
             --Acumular totais de valor saldo para relatório geral
             vr_tab_tot_vlsdrdca(rw_craprda.cdageass):= vr_tab_tot_vlsdrdca(rw_craprda.cdageass) +
                                                        Nvl(vr_rel_vlsdrdca,0);
             --Zerar variaveis de acumulo por data
             vr_rel_qtaplica:= 0;
             vr_rel_vlaplica:= 0;
             vr_rel_vlsdrdca:= 0;
           END IF;

         END LOOP; --rw_craprda
         
         -- Busca todos os produtos de captação
         FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
                                     ,pr_dtiniper => vr_dtiniper
                                     ,pr_dtfimper => vr_dtfimper
                                     ,pr_cdagenci => rw_crapage.cdagenci)LOOP
                                     
           -- Abre cursor de cadastro de produtos
           OPEN cr_crapcpc(rw_craprac.cdprodut);
           FETCH cr_crapcpc INTO rw_crapcpc;
           
           -- Se não encontrar levantar exceção
           IF cr_crapcpc%NOTFOUND THEN
             vr_cdcritic := 0;
             vr_des_erro :=  'Produto de captacao nao encontrado';
             vr_dscritic := vr_des_erro;
             -- Fecha cursor
             CLOSE cr_crapcpc;
             RAISE vr_exc_saida;       
           END IF;
           -- Fecha cursor         
           CLOSE cr_crapcpc;
           
           IF rw_crapcpc.idtippro = 1 THEN -- Pré-fixada
             -- Calculo para obter saldo atualizado de aplicacao pre
             APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                                    ,pr_nrdconta => rw_craprac.nrdconta   --> Número da Conta
                                                    ,pr_nraplica => rw_craprac.nraplica   --> Número da Aplicação
                                                    ,pr_dtiniapl => rw_craprac.dtmvtolt   --> Data de Início da Aplicação
                                                    ,pr_txaplica => rw_craprac.txaplica   --> Taxa da Aplicação
                                                    ,pr_idtxfixa => rw_crapcpc.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
                                                    ,pr_cddindex => rw_crapcpc.cddindex   --> Código do Indexador
                                                    ,pr_qtdiacar => rw_craprac.qtdiacar   --> Dias de Carência
                                                    ,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                    ,pr_dtinical => rw_craprac.dtmvtolt   --> Data Inicial Cálculo
                                                    ,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
                                                    ,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                    ,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                    ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
                                                    ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
                                                    ,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
                                                    ,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
                                                    ,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
                                                    ,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
                                                    ,pr_percirrf => vr_percirrf           --> Percentual do IRRF
                                                    ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                                    ,pr_dscritic => vr_des_erro);         --> Descrição da crítica
             -- Se procedure retornou erro                                        
             IF vr_cdcritic <> 0 OR TRIM(vr_des_erro) IS NOT NULL THEN
               vr_des_erro := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pre -> ' || vr_des_erro;
               vr_dscritic := vr_des_erro;
               -- Levanta exceção
               RAISE vr_exc_saida;
             END IF;
           ELSIF rw_crapcpc.idtippro = 2 THEN -- Pós-fixada
             
             APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                                    ,pr_nrdconta => rw_craprac.nrdconta   --> Número da Conta
                                                    ,pr_nraplica => rw_craprac.nraplica   --> Número da Aplicação
                                                    ,pr_dtiniapl => rw_craprac.dtmvtolt   --> Data de Início da Aplicação
                                                    ,pr_txaplica => rw_craprac.txaplica   --> Taxa da Aplicação
                                                    ,pr_idtxfixa => rw_crapcpc.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
                                                    ,pr_cddindex => rw_crapcpc.cddindex   --> Código do Indexador
                                                    ,pr_qtdiacar => rw_craprac.qtdiacar   --> Dias de Carência
                                                    ,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                    ,pr_dtinical => rw_craprac.dtmvtolt   --> Data Inicial Cálculo
                                                    ,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
                                                    ,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                    ,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                    ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
                                                    ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
                                                    ,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
                                                    ,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
                                                    ,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
                                                    ,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
                                                    ,pr_percirrf => vr_percirrf           --> Percentual do IRRF
                                                    ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                                    ,pr_dscritic => vr_des_erro);         --> Descrição da crítica
                                                    
             -- Se procedure retornou erro                                        
             IF vr_cdcritic <> 0 OR TRIM(vr_des_erro) IS NOT NULL THEN
               vr_des_erro := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pos -> ' || vr_des_erro;
               vr_dscritic := vr_des_erro;
               -- Levanta exceção
               RAISE vr_exc_saida;
             END IF;
           
           END IF;
           
           --Se o valor do saldo total para resgate
           IF vr_vlsldrgt > 0 THEN
             IF NOT vr_tab_detalhe_pa.EXISTS(rw_crapage.cdagenci) OR
						  NOT vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data.EXISTS(to_char(rw_craprac.dtvencto, 'ddmmyyyy'))	THEN
                
               --Incrementar quantidade aplicada
               vr_rel_qtaplica:= Nvl(vr_rel_qtaplica,0) + 1;           
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).qtaplica := 1;
               
               --Acumular valor aplicado
               vr_rel_vlaplica:= Nvl(vr_rel_vlaplica,0) + Nvl(rw_craprac.vlaplica,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).vlaplica := Nvl(rw_craprac.vlaplica,0);
               
               --Acumular total saldo rdca
               vr_rel_vlsdrdca:= Nvl(vr_rel_vlsdrdca,0) + Nvl(vr_vlsldrgt,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).vlsdrdca := Nvl(vr_vlsldrgt,0);
               
               -- Data de referencia
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).dtrefere := rw_craprac.dtvencto;   
             ELSE
               
               --Incrementar quantidade aplicada
               vr_rel_qtaplica:= Nvl(vr_rel_qtaplica,0) + 1;           
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).qtaplica := 
               NVL(vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).qtaplica,0) + 1;
               
               --Acumular valor aplicado
               vr_rel_vlaplica:= Nvl(vr_rel_vlaplica,0) + Nvl(rw_craprac.vlaplica,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).vlaplica :=
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).vlaplica + Nvl(rw_craprac.vlaplica,0);
                 
               --Acumular total saldo
               vr_rel_vlsdrdca:= Nvl(vr_rel_vlsdrdca,0) + Nvl(vr_vlsldrgt,0);
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).vlsdrdca :=
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).vlsdrdca + Nvl(vr_vlsldrgt,0);
               
               -- Data de referencia   
               vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(rw_craprac.dtvencto, 'ddmmyyyy')).dtrefere := rw_craprac.dtvencto;               
                                                                                                                  
             END IF;
             
             --Montar Indice para tabela de detalhes pela data
             vr_index_detalhe:= To_Char(rw_craprac.dtvencto,'YYYYMMDD');
             --Inserir os detalhes na tabela de aniversarios
             IF vr_tab_detalhe.EXISTS(vr_index_detalhe) THEN
               vr_tab_detalhe(vr_index_detalhe).qtaplica:= vr_tab_detalhe(vr_index_detalhe).qtaplica + 1;
               vr_tab_detalhe(vr_index_detalhe).vlaplica:= vr_tab_detalhe(vr_index_detalhe).vlaplica + Nvl(rw_craprac.vlaplica,0);
               vr_tab_detalhe(vr_index_detalhe).vlsdrdca:= vr_tab_detalhe(vr_index_detalhe).vlsdrdca + Nvl(vr_vlsldrgt,0);
             ELSE
               vr_tab_detalhe(vr_index_detalhe).dtrefere:= rw_craprac.dtvencto;
               vr_tab_detalhe(vr_index_detalhe).qtaplica:= 1;
               vr_tab_detalhe(vr_index_detalhe).vlaplica:= Nvl(rw_craprac.vlaplica,0);
               vr_tab_detalhe(vr_index_detalhe).vlsdrdca:= Nvl(vr_vlsldrgt,0);
             END IF;
             
           END IF;

           --Se for o ultimo registro da mesma data
           IF rw_craprac.qtregdata = rw_craprac.nrseqreg THEN

             --Acumular totais da quantidade aplicada para relatório geral
             vr_tab_tot_qtaplica(rw_craprac.cdagenci):= vr_tab_tot_qtaplica(rw_craprac.cdagenci) +
                                                        Nvl(vr_rel_qtaplica,0);
             --Acumular totais de valor aplicado para relatório geral
             vr_tab_tot_vlaplica(rw_craprac.cdagenci):= vr_tab_tot_vlaplica(rw_craprac.cdagenci) +
                                                        Nvl(vr_rel_vlaplica,0);
             --Acumular totais de valor saldo para relatório geral
             vr_tab_tot_vlsdrdca(rw_craprac.cdagenci):= vr_tab_tot_vlsdrdca(rw_craprac.cdagenci) +
                                                        Nvl(vr_rel_vlsdrdca,0);
             --Zerar variaveis de acumulo por data
             vr_rel_qtaplica:= 0;
             vr_rel_vlaplica:= 0;
             vr_rel_vlsdrdca:= 0;
           END IF;
                    
         END LOOP;

         IF NOT vr_tab_detalhe_pa.EXISTS(rw_crapage.cdagenci) THEN
           CONTINUE;
         END IF;
         
         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);       
         
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl090>'||
                        '<agencia cdagenci="'||To_Char(rw_crapage.cdagenci,'fm009')||
                        ' - '||rw_crapage.nmresage||'">');
         
         -- For para percorrer data de inicio até data final
         FOR rw_dtrefere IN to_number(to_char(vr_dtiniper, 'j'))..to_number(to_char(vr_dtfimper,'j')) LOOP
           
           IF vr_tab_detalhe_pa.EXISTS(rw_crapage.cdagenci) AND
						vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data.EXISTS(to_char(to_date(rw_dtrefere,'j'), 'ddmmyyyy'))	THEN
         
             IF Nvl(vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(to_date(rw_dtrefere,'j'), 'ddmmyyyy')).qtaplica,0) > 0 THEN
               --Escrever informacoes da linha de credito no arquivo XML                          
               pc_escreve_xml('<aplica>
                                 <dtfimper>'||To_Char(vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(to_date(rw_dtrefere,'j'), 'ddmmyyyy')).dtrefere,'DD/MM/YYYY')||'</dtfimper>
                                 <qtaplica>'||To_Char(vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(to_date(rw_dtrefere,'j'), 'ddmmyyyy')).qtaplica,'999g990')||'</qtaplica>
                                 <vlaplica>'||To_Char(vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(to_date(rw_dtrefere,'j'), 'ddmmyyyy')).vlaplica,'fm999g999g999g990d00')||'</vlaplica>
                                 <vlsdrdca>'||To_Char(vr_tab_detalhe_pa(rw_crapage.cdagenci).vr_tab_detalhe_data(to_char(to_date(rw_dtrefere,'j'), 'ddmmyyyy')).vlsdrdca,'fm999g999g999g990d00')||'</vlsdrdca>
                               </aplica>');             
                               
             END IF;
           END IF;
             
         END LOOP;
                
         --Finaliza o arquivo xml
         pc_escreve_xml('</agencia></crrl090>');  
         
         -- Grava LOG de ocorrência inicial geração relatório
         pc_log_programa(PR_DSTIPLOG           => 'O',
                         PR_CDPROGRAMA         => vr_cdprogra ||'_'|| rw_crapage.cdagenci || '$',
                         pr_cdcooper           => pr_cdcooper,
                         pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia       => 4,
                         pr_dsmensagem         => 'Início - gene0002.pc_solicita_relato. AGENCIA: '||rw_crapage.cdagenci,
                         PR_IDPRGLOG           => vr_idlog_ini_par);  
                                      
         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl090/agencia/aplica' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl090.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Sem parametros
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro
         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           vr_dscritic := vr_des_erro;
           -- Gerar exceção
           RAISE vr_exc_saida;
         END IF;
         
         -- Grava LOG de ocorrência inicial geração relatório
         pc_log_programa(PR_DSTIPLOG           => 'O',
                         PR_CDPROGRAMA         => vr_cdprogra ||'_'|| rw_crapage.cdagenci || '$',
                         pr_cdcooper           => pr_cdcooper,
                         pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia       => 4,
                         pr_dsmensagem         => 'Fim - gene0002.pc_solicita_relato. AGENCIA: '||rw_crapage.cdagenci,
                         PR_IDPRGLOG           => vr_idlog_ini_par); 
       END LOOP; --rw_crapage
     
       -- Grava LOG de ocorrência final do cursor cr_craprpp
       pc_log_programa(PR_DSTIPLOG           => 'O',
                       PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                       pr_cdcooper           => pr_cdcooper,
                       pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       pr_tpocorrencia       => 4,
                       pr_dsmensagem         => 'Fim - cursor cr_crapage. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                       PR_IDPRGLOG           => vr_idlog_ini_par);
     
     
       --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 1); 
     
     end if;

     
     --Se for o programa principal - executado no batch
     if pr_idparale = 0 then
       --Executar procedure geração relatorio crrl090 totalizador
       pc_imprime_crrl090_total (pr_des_erro => vr_des_erro);
       --Se retornou erro
       IF vr_des_erro IS NOT NULL THEN
         vr_dscritic := vr_des_erro;
         --Levantar Exceção
         RAISE vr_exc_saida;
       END IF;
       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       
        if vr_idcontrole <> 0 then
          -- Atualiza finalização do batch na tabela de controle 
          gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                             ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                             ,pr_dscritic   => vr_dscritic);
                                             
          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if; 
                                                          
        end if;    
        
        if vr_inproces > 2 and vr_qtdjobs > 0 then 
          --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_ger,
                          pr_flgsucesso => 1);                 
        end if;

        --Salvar informacoes no banco de dados
        commit;
     
     --Se for job chamado pelo programa do batch   
     else
       -- Atualiza finalização do batch na tabela de controle 
       gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);  
                                               
       -- Encerrar o job do processamento paralelo dessa agência
       gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);  
      
       --Salvar informacoes no banco de dados
       commit;
     end if;   
   EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_des_erro );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      
      if pr_idparale <> 0 then 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'vr_exc_fimprg - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||vr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);  

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if;                  
      
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
      
      if pr_idparale <> 0 then 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'vr_exc_saida - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);  

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
                          
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if;
      
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
      
      if pr_idparale <> 0 then 
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'WHEN OTHERS - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);   

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
      
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if;
   END;
 END pc_crps110;
/
