CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS538(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                       ,pr_nmtelant IN VARCHAR2                --> Nome tela anterior
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS538                      Antigo: Fontes/CRPS538.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Novembro/2009.                   Ultima atualizacao: 26/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos de TITULOS da Nossa Remessa - Conciliacao.

   Alteracoes: 27/05/2010 - Alterar a data utilizada no FIND para a data que
                            esta no HEADER do arquivo e incluir um resumo ao
                            fim do relatorio de Rejeitados, Integrados e
                            Recebidos (Guilherme/Supero)

               28/05/2010 - Quando encontrar o registro Trailer dar LEAVE
                            e sair do laco de importacao do arquivo(Guilherme).

               04/06/2010 - Acertos Gerais (Ze).

               16/06/2010 - Inclusao do campo gncptit.dtliquid (Ze).

               28/06/2010 - Alteracao na Busca (FIND LAST) ate verificacao na
                            BO (Ze).

               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               26/08/2010 - Incluida importacao diferenciada quando CECRED,
                            gerando relatorio 574 do que nao foi importado nas
                            cooperativas (Guilherme/Supero)

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                            (Vitor)

               12/05/2011 - Tratamento para liquidaçao da cobrança registrada
                          - Definido explicitamente cada bloco de transacao para
                            conseguir efetuar o comando DDA para JD (Guilherme).

               22/06/2011 - Validar a data do arquivo pelo dtmvtolt e nao pelo
                            dtmvtoan (Guilherme).

               24/06/2011 - Gravar banco/agencia origem do pagamento (Rafael).

               11/07/2011 - Quando nao encontrar titulo nas cooperativas singulares
                            gerar registros no relatorio(Guilherme).

               13/07/2011 - Incluir baixa automatica por decurso de prazo
                            (Guilherme).

               02/08/2011 - Criacao da procedure gera_relatorio_605, que gera
                            o crrl605, para conciliacao dos dados da
                            Sua Remessa(085). Fabricio

               16/09/2011 - Ajustes gera_relatorio_605. Separar liquidacoes
                            pela COOP e COMPE. (Rafael).

               03/10/2011 - Criticar titulos baixados p/ protesto e
                            pagos a menor (941 e 940). (Rafael).

               03/11/2011 - Ajuste calculo de titulos pagos em atraso (Rafael)

               17/11/2011 - Executar liquidacao intrabancaria DDA dos titulos
                            pagos na compe 085. (Rafael)
                          - Mostrar no relatorio 605 qdo ocorrer liquidacao
                            de um boleto baixado (943). (Rafael)
                          - Alterado prazo de envio para protesto de titulos
                            vencidos. (Rafael)

               08/12/2011 - Utilizado data de pagto do arquivo para realizar
                            calculo de juros/multa. (Rafael)

               23/12/2011 - Alteraçoes para substiuir o campo 'TARIFAS' por
                            'TARIFAS COOP'. (Lucas)

               18/01/2012 - Utilizar vlr de abatimento no calculo do título
                            mesmo vencido. (Rafael)

               13/03/2012 - Alterado prazos de decurso de prazo de titulos
                            em virtude do novo catalogo da CIP 3.05. (Rafael)
                          - Valor de abatimento deve ser aplicado antes do
                            calculo de juros/multa. (Rafael)

               22/03/2012 - Procedure para gerar rel. 618 (CAC). (Lucas)

               23/03/2012 - Importar todos arqs 2*.REM - ref CAF (Guilherme)

               10/04/2012 - Aumento de posicoes na variavel com o no. de
                            arquivos, para 9999 arquivos (Guilherme).

               18/04/2012 - Identificar pagamento DDA ao processar COB615,
                            cdtipdoc = 140 e 144 (DDA INF e DDA VLB). (Rafael)

               14/05/2012 - Tratamento liq de titulos apos baixa.
                          - Criado critica 947 - Liq de boleto pago. (Rafael)

               10/08/2012 - Ajuste na rotina de liquidacao de titulos
                            descontados da cob. registrada. (Rafael)

               21/08/2012 - Incluido nrseqdig no campo gncptit.hrtransa para
                            evitar chave duplicada de titulo pago. (Rafael)

               29/08/2012 - Removido inclusao na gncptit ref. a liq de boleto
                            pago. Estava mostrando valor duplicado no
                            relatorio 533 na central. (Rafael)

               23/11/2012 - Ajustes para títulos migrados da Viacredi para
                            Alto Vale (Gabriel).

               04/12/2012 - Nao processar arquivos 2*.REM que nao sejam
                            COB605. (Rafael)

               12/03/2013 - Conforme circular INFO-CIP 009/2013, foi extinto
                            TD 44 e 144 do pagto de titulos. (Rafael)

               14/03/2013 - Substituir nmrescop por dsdircop ao gerar
                            relatorio 618. (Rafael)

               07/05/2013 - Projeto Melhorias da Cobranca - processar titulos
                            da cobranca 085 - sem registro. (Rafael)
                          - Utilizado ROUND nas rotinas de cálculo de juros
                            e multa. (Rafael)

               31/07/2013 - Incluso processo para geracao log com base tabela
                            crapcol. (Daniel)

               26/09/2013 - Incluso parametro tt-lat-consolidada nas chamadas
                            de instrucoes da b1wgen0088. Incluso processo de
                            cobranca tarifa consolidadas (Daniel).

               11/11/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (Guilherme Gielow)

               15/11/2013 - Novos ajustes no processamento "COMPEFORA" (Rafael).

               25/11/2013 - Conversao Progress -> Oracle - Alisson (AMcom)

               17/12/2013 - Ajustado leituras crapcob e incluso format no
                            display do campo crapret.nrdocmto (Daniel).

               20/12/2013 - Ajuste no processo de convenios migrados para
                            outras cooperativas. (Rafael)
                          - Removido tratamento de convenios ativos, pois
                            todo convenio deve ser tratado. (Rafael)
                          - Ajuste na data de geracao do arquivo de retorno
                            ao cooperado. (Rafael)

               07/05/2014 - Ajustado processo tratamento critica, evitando
                            que leitura seja abortada (Daniel)

               21/05/2014 - Ajustado chamadas dos relatorios para que
                            gerem com o cdrelato correto (Odirlei-AMcom)

               27/05/2014 - Ajustado para baixar por decurso de prazo os titulos DDA de
                            22 para 59 dias (Tiago SD138818).

               06/06/2014 - Ajuste para remoção da mensagem (592 - Bloqueto nao
                            encontrado, 009 - Associado nao cadastrado).
                            Solicitado através do chamado 146138 (Carlos Rafael Tanholi)

               10/06/2014 - Ajuste para remoção da mensagem: "Instrucao de protesto nao
                            efetuada, conforme chamado: 144932 02/04/2014 - Jéssica (DB1).

               25/06/2014 - #171395 Reincluídos os cdcritic 592 e 009, comentados no ajuste
                            de 6/6/14, pois eles são utilizados no relatório (Carlos)

               27/06/2014 - Ajuste no tratamento de erro na rotina de protesto automatico
                            e baixa por decurso de prazo. (Rafael)

               21/07/2014 - #171395 Reincluída a mensagem de crítica de associado não
                            encontrado (9) (Carlos)

               30/07/2014 - Ajuste na montagem do nome do sacado para usar a gene0007.fn_caract_controle
                            já que estava permitindo caracteres de controle o que invalidava o XML
                            (Marcos-Supero)

               09/09/2014 - Ajustes ref. ao Projeto 03-Float (Liberacao em Out/2014) (Rafael)

               25/09/2014 - Incluso TRIM nos to_number feitos nas leituras de valores do arquivo,
                            para evitar erro quando a informação for nula, preenchida no arquivo
                            com espaços em branco (Renato - Supero)

               23/10/2014 - Ajustes na geração do xml do relatorio para fechar corretamente a tag <float>
                            (Odirlei/Amcom)

               05/11/2014 - Ajuste na rotina pc_verifica_vencto. Tratamento para banco/agencias
                            nao localizadas no CAF. (SD 217445 - Rafael).

               07/11/2014 - Ajustes identificanos na validação para incorporação da concredi/credimilsul
                            (Odirlei/Amcom)

               04/12/2014 - Ajuste de Performance. Retirada a função interna para uso da
                            gene0002.pc_escreve_xml. Retirado o cursor cr_craptab para usar a função
                            tabe0001.fn_busca_dstextab (Alisson-AMcom)

               11/12/2014 - Retirado tratamento de verificação se existe crapcob de contas migradas,
                            pois já existe uma validação de que se não existe a cobrança o crapcob é gerado
                            para convenios impressos pelo software(Odirlei/AMcom)

               12/12/2014 - Se o convenio for incorporacao/migracao e o cooperado nao for encontrado na
                            cooperativa, entao processar o proximo registro. (Rafael - SD 233200)

               30/12/2014 - Alterado procedimento pc_gera_relatorio_686, para incluir no relatorio
                            o bloco de saldo pendente SD214269(Odirlei-AMcom)

               23/01/2015 - Correção em cursores com ORDER BY progress_recid para forçar o
                            índice utilizado pelo Progress (Dionathan)

               13/02/2015 - Alterado para não mostrar as criticas de protesto e
                            baixa por decurso no log, e sim salvar no log de cobrança
                            que apresentará na tela COBRAN SD250588.
                            E Ajustes para enviar por email as criticas de Tarifa para a
                            area responsavel SD242639 (Odirlei-AMcom)

               19/02/2015 - Alterar os comites do fonte, para que sejam executados apenas ao final do processamento
                            dos arquivos, pois houveram problemas no processamento do batch neste dia. (Renato - Supero)

               26/02/2015 - Ajustes para tratar o envio de e-mail de erros de tarifas para a cobrança.
                            Alinha com o Rafael Cechet, que caso não sejam encontrados os cadastros dos
                            e-mails, o mesmo seria enviado para cobrança@cecred.coop.br.
                            Também foi feito a tratativa para que em caso de erro no envio, o programa
                            gere um aviso no log com a mensagem de erro e continue o programa sem abortar (Renato - Supero)

               08/05/2015 - Adicionado campo data de emissao no relatorio 605. SD 257997 (Kelvin)

               11/06/2015 - Incluido ocorrencias 76 e 77 no processo de liquidaçao ref. ao
                            projeto 219 - Cooperativa/EE (Daniel)
                          - Ajustes no relatorio 686 referente ao movimento do Float (Rafael)

               31/08/2015 - Projeto para tratamento dos programas que geram
                            criticas que necessitam de lancamentos manuais
                            pela contabilidade. (Jaison/Marcos-Supero)

               10/09/2015 - Ajuste para corrigir o tratamento de erro, apos a chamada das rotinas
                            pc_proc_liquid_apos_baixa/pc_processa_liquidacao, para retornar o
                            erro corretamente no proc_batch.log
                            (Adriano)

               06/10/2015 - Ajustes referente ao Projeto 210 - Pagto de emprestimo c/ boleto (Rafael)

               23/11/2015 - Ajustes no posicionamento do processamento das liquidacoes dos boletos
                            de emprestimo ref ao projeto 210. (Rafael)

               26/11/2015 - Ajuste no posicionamento do processamento das liquidacoes
                            intrabancarias DDA para nao ocorrer erros no processamento das liquidacoes
                            de emprestimo. (Rafael)

               01/12/2015 - Ajuste para definir a data corretamente antes de chamar a rotina
                            PAGA0001.pc_gera_arq_cooperado SD364513 (Odirlei-AMcom)

               08/12/2015 - Ajuste nas mensagens de log do sistema (proc_message.log). (Rafael)

               28/12/2015 - Ajuste no pagamento de emprestimo, pela COMPEFORA. (James)

               12/01/2016 - Enviar e-mail para a area processual de credito
                            quando ocorrer COMPEFORA. (Rafael)

         20/01/2016 - Ajustar a chamada da procedure migrada da package PAGA0001
                            para COBR0007 (Douglas - Importacao de Arquivo CNAB)

               03/02/2016 - Ajustar gravacao do relatorio 523 para o utilizar o indice
                            ao inves do contador, pois esta sobrescrevendo o relatorio
                          - Ajustar limite de data de protesto quando a tela for COMPEFORA
                           (Douglas - Chamado 391061)

               23/02/2016 - Alterados os 59 dias fixos para Decurso de Prazofoi para
                            buscar esta informação do Convênio Contratado.
                            Projeto 213 - Reciprocidade (Lombardi)

               26/02/2015 - Campo Float retirado do cabecalho do relatório e passado para a
                            tabela de detalhes de contas. Projeto 213 - Reciprocidade (Lombardi)


         29/02/2016 - Inicializar as variaveis totalizadoras para cada contador
                            (Douglas - Chamado 394368)

               12/04/2016 - Ajustado a data de movimento para a baixa de titulo
                            (Douglas - Chamado 424571)

               09/05/2016 - Tratamento para não liquidar boletos de convenios bloqueados
                            PRJ318 - Nova Plataforma de cobrança (Odirlei-AMcom)

               22/09/2016 - Ajuste nos cursores e alteração da lógica para obtenção de títulos (Rodrigo)

               30/09/2016 - Alterações referentes ao projeto 302 - Sistema de acordos
                            (Renato Darosci - Supero)
												 
			   10/10/2016 - Alteração do diretório para geração de arquivo contábil.
                            P308 (Ricardo Linhares).

               11/10/2016 - Ajustes referente ao processo de REPROC do arquivo COB615 (Renato Darosci)
               
               18/11/2016 - Realizado ajuste para tratar os emprestimos e acordos ao rodar    
                            arquivos de REPROC (Renato Darosci)		

               15/12/2016 - Ajustes projeto 340 - Nova plataforma de cobrança.
                            (Odirlei - AMcom)             

               10/02/2017 - P340 - Ajustes emergenciais antes da liberação programada de 21/02/17
			              - Ajustado pasta micros/<cooperativa>/abbc;
						  - Ajustado cláusula where dos cursores cr_devolucao; (Rafael)

               15/02/2017 - Ajustes referente ao Prj.307 Automatização Arquivos Contábeis Ayllos (Jean Michel)

               22/02/2017 - Incluido novamente relatório 618 - CAC (Renato);
			                    - Ajustado valor do pagto na rotina de devolução (Rafael);
						              - Ajustado data de movimento no arquivo de devolução (Rafael);
                          
               24/02/2017 - Ajustado relatório 618 em função do novo layout COB615 (Rafael);

               15/03/2017 - Removido a inicialição da variavel de multa e juros após inclusão do boleto na
                            PL Table do relatório 618. Estava sendo zerado de forma incorreta, fazendo com 
                            que o boleto tivesse o valor de multa/juros pago zerado (Douglas - Chamado 624683)

               17/03/2017 - Ajustes devolução. PRJ340 - NPC (Odirlei-AMcom)

               22/03/2017 - Alteração SILOC - Gerar registro na gncpdvc após inserir 
                            o registro na tabela tbcobran_devolucao (Renato Darosci)
                            
               07/04/2017 - #642531 Tratamento do tail para pegar/validar os dados da última linha
                            do arquivo corretamente (Carlos)

               12/04/2017 - Cooperado importou o boleto corretamente e imprimiu atraves do software proprio
                            porém na impressão ele utilizou o numero da conta sem o digito verificador e todos 
                            os pagamentos estao sendo rejeitados (Douglas - Chamado 650122)

               12/04/2017 - Ajuste para incluir a diferença entre o valor pago e o valor do boleto atualizado
                            com multa e juros, no campo de juros pago. Boleto foi pago com valor maior
                            que o calculado pelo sistema, porem grava apenas a diferença dos valores no campo
                            de juros pago, dessa forma vai gravar o valor correto de juros pago.
                            (Douglas - Chamado 635796)
                            
               17/04/2017 - Adicionar NVL no campo cddbanco para o armazanamento do nome do relatorio 
                            crrl618 (Lucas Ranghetti #620567)
                            
               02/05/2017 - Entrega 02 - Prj.307 Automatização Arquivos Contábeis Ayllos (Jonatas-Supero)                            
               
               21/06/2017 - Alterado mensagens de LOG da crapcol #696421 (Tiago/Rodrigo).

               12/07/2017 - #712635 Inclusão tabela crapcco nos cursores cr_cde e cr_boletos_pagos_acordos 
                            para otimização (Carlos)
                            
               28/07/2017 - Ajustes para Comandar baixa efetiva de boletos pagos no dia fora da cooperativo.
                            PRJ340 - NPC (Odirlei-AMcom) 
            
               01/08/2017 - Ajuste para incluir a diferença entre o valor pago e o valor do boleto
                            atualizado com multa e juros no campo de juros pago.
                            Esse ajuste foi feito no change set 11141 e liberado em 05/2017, porém
                            o change set 11744 que foi liberado em 06/2017 matou a alteração.
                            Implementação da procedure pc_grava_log para gerar log dos registros
                            que apresentaram critica no loop de processamento das linhas
                            do arquivo. (SD#726081-AJFink)


               01/09/2017 - SD737676 - Para evitar duplicidade devido o Matera mudar
                            o nome do arquivo apos processamento, iremos gerar o arquivo
                            _Criticas com o sufixo do crrl gerado por este (Marcos-Supero)

               26/09/2017 - Ajuste para validar o valor e a data de vencimento do título
                            somente quando estiver fora do período de convivência da NPC.
                            Títulos estavam sendo devolvidos com a crítica 63.
                            (SD#764044-AJFink)
   .............................................................................*/

     DECLARE

    --variaveis para controle de arquivos
    vr_dircon VARCHAR2(200);
    vr_arqcon VARCHAR2(200);
    vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos';
    vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
    vc_cdtodascooperativas INTEGER := 0;

       /* Tipos e registros da pc_CRPS538 */

       TYPE typ_reg_crapcco IS
         RECORD (cdcooper crapcco.cdcooper%TYPE
                ,cdagenci crapcco.cdagenci%TYPE
                ,cdbccxlt crapcco.cdbccxlt%TYPE
                ,nrdolote crapcco.nrdolote%TYPE
                ,nrconven crapcco.nrconven%TYPE
                ,flgativo crapcco.flgativo%TYPE
                ,cddbanco crapcco.cddbanco%TYPE
                ,nrdctabb crapcco.nrdctabb%TYPE
                ,dsorgarq crapcco.dsorgarq%TYPE
                ,flgregis crapcco.flgregis%TYPE
                ,cdcopant crapcco.cdcooper%TYPE
                ,dsorgant crapcco.dsorgarq%TYPE);

       TYPE typ_reg_relat_cecred IS
           RECORD (cdbandst INTEGER
                  ,cdmotdev INTEGER
                  ,cdbcoaco INTEGER
                  ,cdageaco INTEGER
                  ,dtmvtolt DATE
                  ,dscodbar VARCHAR2(100)
                  ,vlddocmt NUMBER
                  ,vlliquid NUMBER);

       TYPE typ_reg_rel618 IS RECORD
         (cddbanco INTEGER
         ,bancoage VARCHAR2(100)
         ,nrcpfcnj crapcob.nrinssac%type
         ,nmsacado crapsab.nmdsacad%type
         ,dscodbar VARCHAR2(100)
         ,nrdocmto crapcob.dsdoccop%type
         ,dtvencto crapcob.dtvencto%type
         ,vldocmto crapcob.vltitulo%type
         ,vldesaba crapcob.vlabatim%type
         ,vljurmul NUMBER
         ,vldescar NUMBER
         ,vlrpagto NUMBER
         ,vlrdifer NUMBER
         ,inpessoa INTEGER);

       TYPE typ_reg_rel706 IS RECORD
         (cdagenci crapass.cdagenci%TYPE
         ,nrdconta crapass.nrdconta%TYPE
         ,nrcnvcob crapcob.nrcnvcob%TYPE
         ,nrdocmto crapcob.nrdocmto%TYPE
         ,nrctremp crapcob.nrctremp%TYPE
         ,dsdoccop crapcob.dsdoccop%TYPE
         ,tpparcel INTEGER
         ,dtvencto crapcob.dtvencto%TYPE
         ,vltitulo crapcob.vltitulo%TYPE
         ,vldpagto crapcob.vldpagto%TYPE
         ,flamenor BOOLEAN
         ,flvencid BOOLEAN
         ,dscritic VARCHAR2(100));

       TYPE typ_reg_conv_arq IS RECORD
         (cdcooper crapcop.cdcooper%type
         ,dtmvtolt crapdat.dtmvtolt%type
         ,cdagenci crapage.cdagenci%type
         ,cdbccxlt craplot.cdbccxlt%type
         ,nrdolote craplot.nrdolote%type
         ,nrconven crapcco.nrconven%type);

       TYPE typ_reg_craptco IS RECORD
         (cdcooper craptco.cdcooper%TYPE
         ,nrdconta craptco.nrdconta%TYPE
         ,cdcopant craptco.cdcopant%TYPE
         ,nrctaant craptco.nrctaant%TYPE);

       --Definicao dos tipos de tabelas
       TYPE typ_tab_craptco IS TABLE OF typ_reg_craptco INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapcco IS TABLE OF typ_reg_crapcco INDEX BY VARCHAR2(20);
       TYPE typ_tab_relat_cecred IS TABLE OF typ_reg_relat_cecred INDEX BY VARCHAR2(50);
       TYPE typ_tab_rel618 IS TABLE OF typ_reg_rel618 INDEX BY VARCHAR2(100);
       TYPE typ_tab_conv_arq IS TABLE OF typ_reg_conv_arq INDEX BY VARCHAR2(20);
       --TYPE typ_tab_crapsab IS TABLE OF crapsab.nmdsacad%type INDEX BY VARCHAR2(45);
       TYPE typ_tab_crapmot IS TABLE OF crapmot.dsmotivo%type INDEX BY VARCHAR2(17);
       TYPE typ_tab_cratrej IS TABLE OF craprej%ROWTYPE INDEX BY VARCHAR2(20);
       TYPE typ_tab_comando IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
       TYPE typ_tab_rel706 IS TABLE OF typ_reg_rel706 INDEX BY VARCHAR2(50);

       --Definicao das tabelas de memoria
       vr_tab_crapcco      typ_tab_crapcco;
       vr_tab_craptco      typ_tab_craptco;
--       vr_tab_relat_cecred typ_tab_relat_cecred;
       vr_tab_rel618       typ_tab_rel618;
       vr_tab_rel706       typ_tab_rel706;
       vr_tab_conv_arq     typ_tab_conv_arq;
       vr_tab_crapmot      typ_tab_crapmot;
       vr_tab_cratrej      typ_tab_cratrej;
       vr_tab_comando      typ_tab_comando;
       --Tabela para receber arquivos lidos no unix
       vr_tab_nmarqtel GENE0002.typ_split;
       --Tabela de lancamentos para consolidar
       vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
       vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
       vr_tab_arq_cobranca    PAGA0001.typ_tab_arq_cobranca;
       --Tabela de Titulos
       vr_tab_titulos   PAGA0001.typ_tab_titulos;
       vr_tab_descontar PAGA0001.typ_tab_titulos;
       --Tabela de Memoria de erro
       vr_tab_erro      GENE0001.typ_tab_erro;
       vr_tab_erro2     GENE0001.typ_tab_erro;
       /* Cursores da rotina CRPS538 */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
               ,cop.cdagedbb
               ,cop.cdageitg
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;

       --Selecionar associados
       CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT crapass.nrdctitg
               ,crapass.nrdconta
               ,crapass.cdsitdtl
               ,crapass.dtelimin
               ,crapass.cdagenci
               ,crapass.inpessoa
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%ROWTYPE;

       --Selecionar informacoes log cobranca
       CURSOR cr_crapcol (pr_cdcooper IN crapcol.cdcooper%type
                         ,pr_cdoperad IN crapcol.cdoperad%type
                         ,pr_datailog IN crapcol.dtaltera%type
                         ,pr_dataflog IN crapcol.dtaltera%type
                         ,pr_horailog IN crapcol.hrtransa%type
                         ,pr_horaflog IN crapcol.hrtransa%type) IS
         SELECT crapcol.dslogtit
         FROM crapcol
         WHERE crapcol.cdcooper = pr_cdcooper
         AND   crapcol.cdoperad = pr_cdoperad
         AND   crapcol.dtaltera BETWEEN pr_datailog AND pr_dataflog
         AND   crapcol.hrtransa BETWEEN pr_horailog AND pr_horaflog;

       --Verificar compensacao titulos central
       CURSOR cr_gncptit (pr_cdcooper IN gncptit.cdcooper%type
                         ,pr_dtmvtolt IN gncptit.dtmvtolt%type
                         ,pr_cdbandst IN gncptit.cdbandst%type
                         ,pr_nrdvcdbr IN gncptit.nrdvcdbr%type
                         ,pr_cdfatven IN gncptit.cdfatven%type
                         ,pr_dscodbar IN gncptit.dscodbar%type) IS
         SELECT /*+ INDEX_DESC(gncptit GNCPTIT##GNCPTIT1) */
                gncptit.cdtipreg
               ,gncptit.flgconci
               ,gncptit.dtliquid
               ,gncptit.rowid
         FROM gncptit
         WHERE gncptit.cdcooper = pr_cdcooper
           AND gncptit.dtmvtolt = pr_dtmvtolt
           AND gncptit.cdbandst = pr_cdbandst
           AND gncptit.nrdvcdbr = pr_nrdvcdbr
           AND gncptit.cdfatven = pr_cdfatven
           AND upper(gncptit.dscodbar) = pr_dscodbar
           AND ROWNUM = 1;
       rw_gncptit cr_gncptit%ROWTYPE;

       --Selecionar todas as cooperativas
       CURSOR cr_crapcop_lista IS
         SELECT crapcop.cdcooper
         FROM crapcop;

       --Selecionar todos os convenios
       CURSOR cr_crapcco IS
         SELECT crapcco.nrconven
               ,crapcco.flgativo
               ,crapcco.dsorgarq
               ,crapcco.cdcooper
               ,crapcco.cddbanco
               ,crapcco.nrdctabb
               ,crapcco.cdagenci
               ,crapcco.cdbccxlt
               ,crapcco.nrdolote
               ,crapcco.flgregis
         FROM crapcco;

       --Selecionar as contas migradas
       CURSOR cr_craptco (pr_cdcooper IN craptco.cdcooper%type) IS
         SELECT craptco.nrctaant
               ,craptco.cdcopant
               ,craptco.cdcooper
               ,craptco.nrdconta
         FROM craptco
         WHERE craptco.cdcopant = pr_cdcooper
         AND   craptco.tpctatrf = 1
         AND   craptco.flgativo = 1; /*TRUE*/

       --Selecionar Borderos Cobranca
       CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_cdbandoc IN crapcco.cddbanco%TYPE
                         ,pr_nrdctabb IN crapcco.nrdctabb%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                         ,pr_nrdconta IN crapcob.nrdconta%type
                         ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
         SELECT crapcob.cdcooper
               ,crapcob.flgregis
               ,crapcob.incobran
               ,crapcob.insitcrt
               ,crapcob.cdtitprt
               ,crapcob.nrdconta
               ,crapcob.nrinssac
               ,crapcob.dsdoccop
               ,crapcob.dtvencto
               ,crapcob.vltitulo
               ,crapcob.vldescto
               ,crapcob.vlabatim
               ,crapcob.cdmensag
               ,crapcob.tpdmulta
               ,crapcob.tpjurmor
               ,crapcob.nrcnvcob
               ,crapcob.nrdocmto
               ,crapcob.vlrmulta
               ,crapcob.vljurdia
               ,crapcob.indpagto
               ,crapcob.dtmvtolt
               ,crapcob.rowid
               ,crapcob.inemiten
               ,crapcob.nrctremp
               ,crapcob.vldpagto
               ,crapcob.inserasa
               ,crapcob.dtvctori
         FROM crapcob
         WHERE crapcob.cdcooper = pr_cdcooper
         AND   crapcob.cdbandoc = pr_cdbandoc
         AND   crapcob.nrdctabb = pr_nrdctabb
         AND   crapcob.nrcnvcob = pr_nrcnvcob
         AND   crapcob.nrdconta = pr_nrdconta
         AND   crapcob.nrdocmto = pr_nrdocmto;
       rw_crapcob cr_crapcob%ROWTYPE;
       rw_crabcob cr_crapcob%ROWTYPE;

       --Selecionar informacoes Retorno
       CURSOR cr_crapret (pr_cdcooper IN crapret.cdcooper%type
                         ,pr_nrdconta IN crapret.nrdconta%type
                         ,pr_nrcnvcob IN crapret.nrcnvcob%type
                         ,pr_nrdocmto IN crapret.nrdocmto%type) IS
         SELECT nvl(SUM(nvl(crapret.vloutdes,0) + nvl(crapret.vltarcus,0)),0) vltotal
         FROM crapret
         WHERE crapret.cdcooper = pr_cdcooper
         AND   crapret.nrdconta = pr_nrdconta
         AND   crapret.nrcnvcob = pr_nrcnvcob
         AND   crapret.nrdocmto = pr_nrdocmto;

       --Selecionar Informacoes do Sacado
       CURSOR cr_crapsab (pr_cdcooper IN crapsab.cdcooper%TYPE
                         ,pr_nrdconta IN crapsab.nrdconta%TYPE
                         ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
         SELECT crapsab.cdcooper
               ,crapsab.nrdconta
               ,crapsab.nrinssac
               ,crapsab.nmdsacad
         FROM crapsab
         WHERE crapsab.cdcooper = pr_cdcooper
         AND   crapsab.nrdconta = pr_nrdconta
         AND   crapsab.nrinssac = pr_nrinssac;
       rw_crapsab cr_crapsab%ROWTYPE;

       -- RETIRADO O PROCESSAMENTO DE LIQUIDAÇÃO INTRABANCÁRIA (Renato Darosci - 11/10/2016)
       --Selecionar informacoes para liquidacao
       /*CURSOR cr_crapcco_liquida (pr_cdcooper IN crapcop.cdcooper%type
                                 ,pr_cdbcoctl IN crapcop.cdbcoctl%type
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%type) IS
         SELECT crapcob.rowid
         FROM crapcob
             ,crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
         AND   crapcco.cddbanco = pr_cdbcoctl
         AND   crapcco.flgregis = 1
         AND   crapcob.cdcooper = crapcco.cdcooper
         AND   crapcob.nrcnvcob = crapcco.nrconven
         AND   crapcob.incobran = 5 -- pagos 
         AND   crapcob.dtdpagto = pr_dtmvtolt
         AND   crapcob.cdbanpag = pr_cdbcoctl
         AND   crapcob.flgcbdda = 1;*/

       --Selecionar informacoes convenios ativos
       CURSOR cr_crapcco_ativo (pr_cdcooper IN crapcco.cdcooper%type
                               ,pr_cddbanco IN crapcco.cddbanco%type) IS
         SELECT crapcco.cdcooper
               ,crapcco.nrconven
               ,crapcco.nrdctabb
               ,crapcco.cddbanco
               ,crapcco.cdagenci
               ,crapcco.cdbccxlt
               ,crapcco.nrdolote
               ,crapcco.dsorgarq
         FROM crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
         AND   crapcco.cddbanco = pr_cddbanco
         AND   crapcco.flgregis = 1;

       --Selecionar titulos baixa decurso prazo
       CURSOR cr_crapcob_aberto (pr_cdcooper IN crapcco.cdcooper%type
                                ,pr_nrconven IN crapcco.nrconven%TYPE
                                ,pr_dtvencto IN crapcob.dtvencto%type
                                ,pr_incobran IN crapcob.incobran%type) IS
         SELECT crapcob.dtvencto
               ,crapcob.qtdiaprt
               ,crapcob.nrdconta
               ,crapcob.nrcnvcob
               ,crapcob.nrdocmto
               ,crapcob.cdtpinsc
               ,crapcob.flgdprot
               ,crapcob.flgregis
               ,crapcob.dtmvtolt
               ,crapcob.flgcbdda
               ,crapcob.cdcooper
               ,crapcob.inserasa
               ,crapceb.qtdecprz
               ,crapcob.rowid
         FROM crapcob
             ,crapceb
         WHERE crapceb.cdcooper = pr_cdcooper
         AND   crapceb.nrconven = pr_nrconven
         AND   crapcob.cdcooper = crapceb.cdcooper
         AND   crapcob.nrdconta = crapceb.nrdconta
         AND   crapcob.nrcnvcob = crapceb.nrconven
         AND   crapcob.dtvencto = TRUNC(pr_dtvencto) - crapceb.qtdecprz
         AND   crapcob.incobran = pr_incobran;

       --Selecionar titulos para protesto
         CURSOR cr_crapcob_prot (pr_cdcooper IN crapcco.cdcooper%type
                                ,pr_nrconven IN crapcco.nrconven%TYPE
                                ,pr_dtvencto IN crapcob.dtvencto%type
                                ,pr_incobran IN crapcob.incobran%type
                                ,pr_qtdiaprt IN crapcob.qtdiaprt%TYPE) IS
         SELECT crapcob.dtvencto
               ,crapcob.qtdiaprt
               ,crapcob.nrdconta
               ,crapcob.nrcnvcob
               ,crapcob.nrdocmto
               ,crapcob.cdtpinsc
               ,crapcob.flgdprot
               ,crapcob.flgregis
               ,crapcob.dtmvtolt
               ,crapcob.flgcbdda
               ,crapcob.cdcooper
               ,crapcob.inserasa
               ,crapceb.qtdecprz
               ,crapcob.rowid
           FROM crapcob
               ,crapceb
          WHERE crapceb.cdcooper = pr_cdcooper
          AND   crapceb.nrconven = pr_nrconven
          AND   crapcob.cdcooper = crapceb.cdcooper
          AND   crapcob.nrdconta = crapceb.nrdconta
          AND   crapcob.nrcnvcob = crapceb.nrconven
          AND   crapcob.dtvencto = pr_dtvencto
          AND   crapcob.qtdiaprt = pr_qtdiaprt
          AND   crapcob.incobran = 0;

       --Selecionar Informacoes Bancos
       CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
         SELECT crapban.nmextbcc
         FROM crapban
         WHERE crapban.cdbccxlt = pr_cdbccxlt;

       --Selecionar Motivos
       CURSOR cr_crapmot (pr_cdcooper IN crapmot.cdcooper%type) IS
             SELECT  crapmot.cddbanco
                    ,crapmot.cdocorre
                    ,crapmot.tpocorre
                    ,crapmot.cdmotivo
                    ,crapmot.dsmotivo
             FROM crapmot
             WHERE crapmot.cdcooper = pr_cdcooper;

       --Selecionar informacoes convenio 'IMPRESSO PELO SOFTWARE'
       CURSOR cr_cco_impresso (pr_nrconven IN crapcco.nrconven%TYPE) IS
         SELECT crapcco.cdcooper
               ,crapcco.dsorgarq
         FROM crapcco
         WHERE crapcco.cdcooper > 0
           AND crapcco.nrconven = pr_nrconven
           AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE';
       rw_cco_impresso cr_cco_impresso%ROWTYPE;

       -- buscar dados do convenio de cobranca cadastrado
       CURSOR cr_crapceb( pr_cdcooper IN crapceb.cdcooper%TYPE
                         ,pr_nrdconta IN crapceb.nrdconta%TYPE
                         ,pr_nrconven IN crapceb.nrconven%TYPE) IS
         SELECT ceb.flgcebhm,
                ceb.insitceb
           FROM crapceb ceb
          WHERE ceb.cdcooper = pr_cdcooper
            AND ceb.nrdconta = pr_nrdconta
            AND ceb.nrconven = pr_nrconven;
       rw_crapceb cr_crapceb%ROWTYPE;

       -- buscar boletos de contrato pagos na cobranca para serem regularizados
       CURSOR cr_cde (pr_cdcooper IN crapret.cdcooper%TYPE
                     ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                     ,pr_dtocorre IN crapret.dtocorre%TYPE) IS
         SELECT ass.cdagenci,
                cde.cdcooper,
                cde.nrdconta,
                cde.nrctremp,
                cde.nrcnvcob,
                cde.nrboleto,
                cde.tpparcela,
                cob.dsdoccop,
                cob.dtvencto,
                cob.vltitulo,
                ret.vlrpagto,
                ret.flcredit,
                cob.rowid cob_rowid
           FROM crapret ret,
                crapcob cob,
                tbepr_cobranca cde,
                crapass ass,
                crapcco cco
          WHERE ret.cdcooper = pr_cdcooper
            AND ret.nrcnvcob = pr_nrcnvcob
            AND ret.dtocorre = pr_dtocorre
            AND ret.cdocorre IN (6,76) -- liquidacao normal COO/CEE
            AND cob.cdcooper = ret.cdcooper
            AND cob.nrcnvcob = ret.nrcnvcob
            AND cob.nrdconta = ret.nrdconta
            AND cob.nrdocmto = ret.nrdocmto
            AND cco.cdcooper = cde.cdcooper
            AND cco.nrconven = cde.nrcnvcob
            AND cob.nrctremp > 0
            AND cde.cdcooper = cob.cdcooper
            AND cde.nrdconta_cob = cob.nrdconta
            AND cde.nrcnvcob = cob.nrcnvcob
            AND cde.nrboleto = cob.nrdocmto
            AND cob.cdbandoc = cco.cddbanco
            AND cob.nrdctabb = cco.nrdctabb
            AND ass.cdcooper = cde.cdcooper
            AND ass.nrdconta = cde.nrdconta
            ORDER BY cde.nrdconta, cde.nrctremp;
       rw_cde cr_cde%ROWTYPE;

       -- Buscar boletos dos acordos pagos na cobranca para serem regularizados
       CURSOR cr_boletos_pagos_acordos (pr_cdcooper IN crapret.cdcooper%TYPE
                                       ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                                       ,pr_dtocorre IN crapret.dtocorre%TYPE) IS
         SELECT aco.cdcooper
              , aco.nrdconta
              , acp.nracordo
              , acp.nrparcela
              , acp.nrconvenio
              , acp.nrboleto
              , cob.dsdoccop
              , cob.dtvencto
              , cob.vltitulo
              , ret.vlrpagto
              , ret.flcredit
              , cob.rowid     cob_rowid
           FROM crapret   ret
              , crapcob   cob
              , tbrecup_acordo_parcela  acp
              , tbrecup_acordo          aco
              , crapcco                 cco
         WHERE ret.cdcooper = pr_cdcooper
           AND ret.nrcnvcob = pr_nrcnvcob
           AND ret.dtocorre = pr_dtocorre
           AND ret.cdocorre IN (6,76) -- liquidacao normal COO/CEE
           
           AND cob.cdcooper = ret.cdcooper
           AND cob.nrcnvcob = ret.nrcnvcob
           AND cob.nrdconta = ret.nrdconta
           AND cob.nrdocmto = ret.nrdocmto
           
           AND aco.cdcooper     = cob.cdcooper
           AND acp.nrdconta_cob = cob.nrdconta
           AND acp.nrconvenio   = cob.nrcnvcob
           AND acp.nrboleto     = cob.nrdocmto

           AND cco.cdcooper = ret.cdcooper  
           AND cco.nrconven = ret.nrcnvcob 
           AND cob.cdbandoc = cco.cddbanco
           AND cob.nrdctabb = cco.nrdctabb         

           AND aco.nracordo     = acp.nracordo;
       
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
       rw_craprej  craprej%ROWTYPE;

       --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS538';
       --Variaveis Locais
       vr_comando         VARCHAR2(1000);
       vr_typ_saida       VARCHAR2(1000);
       vr_flgbatch        INTEGER;
       vr_contador        INTEGER;
       vr_flpdfcopi       VARCHAR2(1);
       vr_nmarqret        VARCHAR2(100);
       vr_nmorigem        VARCHAR2(100);
       vr_nmarqrem        VARCHAR2(100);
       vr_cdbanctl        VARCHAR2(100);
       vr_dtleiarq        VARCHAR2(10);
       vr_dtarquiv        VARCHAR2(10);
       vr_dstipcob        VARCHAR2(6);
       vr_dtleiaux        VARCHAR2(8);
       vr_setlinha        VARCHAR2(1000);
       vr_caminho_puro    VARCHAR2(1000);
       vr_caminho_rl      VARCHAR2(1000);
       vr_caminho_integra VARCHAR2(1000);
       vr_caminho_salvar  VARCHAR2(1000);
       vr_caminho_rlnsv   VARCHAR2(1000);
       vr_caminho_rl_3    VARCHAR2(1000);
       vr_nom_dirmic      VARCHAR2(200);
       vr_flgpgdda        INTEGER;
       vr_tot_qtregrec    INTEGER;
       vr_tot_qtregint    INTEGER;
       vr_tot_qtregrej    INTEGER;
       vr_tot_vlregrec    NUMBER;
       vr_tot_vlregint    NUMBER;
       vr_tot_vlregrej    NUMBER;

       vr_nrcnvcob     INTEGER;
       vr_nrdconta     INTEGER;
       vr_nrdocmto     INTEGER;
       vr_cdmotdev     INTEGER;
       vr_dtmvtolt     DATE;
       vr_dtmvtaux     DATE;
       vr_dtmvtpro     DATE;
       vr_dtdpagto     DATE;
       vr_dscodbar     VARCHAR2(100);
       vr_vlliquid     NUMBER;
       vr_vldescar     NUMBER;
       vr_cdoperad     VARCHAR2(100);
       vr_dstextab     VARCHAR2(1000);
       vr_nmarqimp     VARCHAR2(100);
       vr_rel_dspesqbb VARCHAR2(100);
       vr_rejeitad     BOOLEAN;
       vr_temlancto    BOOLEAN;
       vr_qtdregis     INTEGER:= 0;
       vr_vlregist     NUMBER:= 0;
       vr_vldescon     NUMBER:= 0;
       vr_valjuros     NUMBER:= 0;
       vr_vloutdeb     NUMBER:= 0;
       vr_vloutcre     NUMBER:= 0;
       vr_valorpgo     NUMBER:= 0;
       vr_vltarifa     NUMBER:= 0;
       vr_qttotreg     INTEGER:= 0;
       vr_vltotreg     NUMBER:= 0;
       vr_vltotdes     NUMBER:= 0;
       vr_vltotjur     NUMBER:= 0;
       vr_vltotpag     NUMBER:= 0;
       vr_vltottar     NUMBER:= 0;
       vr_bancoage     VARCHAR2(100);
       vr_dsmotrel     VARCHAR2(100);
       vr_tplotmov     INTEGER:= 1;
       vr_nmarquiv     VARCHAR2(100);
       vr_dsocorre     VARCHAR2(100);
       vr_nmdestin     VARCHAR2(100);
       vr_cdtipdoc     VARCHAR2(100);
       vr_listadir     VARCHAR2(4000);
       vr_qtregrec     INTEGER:= 0;
       vr_qtregicd     INTEGER:= 0;
       vr_qtregisd     INTEGER:= 0;
       vr_qtregrej     INTEGER:= 0;
       vr_vlregrec     NUMBER:= 0;
       vr_vlregicd     NUMBER:= 0;
       vr_vlregisd     NUMBER:= 0;
       vr_vlregrej     NUMBER:= 0;
       vr_dstitdsc     VARCHAR2(100);
       vr_datailog     DATE;
       vr_dataflog     DATE;
       vr_horailog     INTEGER;
       vr_horaflog     INTEGER;
       vr_vlrmincac    NUMBER;
       vr_dtrefere     DATE;
       vr_dtcredit     DATE;
       vr_email_tarif  VARCHAR2(1000);
       vr_descorpo     VARCHAR2(3900);
       vr_flamenor     BOOLEAN := FALSE;
       vr_cdtipreg     NUMBER; 
       vr_dscodbar_ori VARCHAR2(60);
       vr_vltitulo     crapcob.vltitulo%TYPE;
       vr_nrispbif_rec crapban.nrispbif%TYPE;
       vr_nrispbif_fav crapban.nrispbif%TYPE;
       vr_flgdnpcb     INTEGER;
       vr_fcrapcob     BOOLEAN;
       vr_nrseqarq     INTEGER;
       vr_tpcaptur     INTEGER;
       vr_tpdocmto     INTEGER;
       vr_dtvencto     DATE;

       -- Variáveis relacionadas ao processo de REPROC
       vr_inreproc     BOOLEAN;
       vr_dsarqrep     VARCHAR2(100);
       
       --Variaveis para retorno de erro
       vr_des_erro     VARCHAR2(3);
       vr_cdcritic     INTEGER:= 0;
       vr_dscritic     VARCHAR2(4000);
       vr_cdcritic2    INTEGER:= 0;
       vr_dscritic2    VARCHAR2(4000);
       vr_des_erro2    VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_final    EXCEPTION;
       vr_exc_saida    EXCEPTION;
       vr_exc_fimprg   EXCEPTION;
       vr_exc_saida_2  EXCEPTION;

       --Variaveis utilizadas nos indices
       vr_index_desc          VARCHAR2(20);
       vr_index_titulo        VARCHAR2(20);
       vr_index_rel618        VARCHAR2(100);
       vr_index_rel706        VARCHAR2(50);
       vr_index_erro          PLS_INTEGER;
       vr_index_crapcco       VARCHAR2(20);
       vr_index_conv_arq      VARCHAR2(20);
       vr_index_relat_cecred  VARCHAR2(50);
       vr_index_crapmot       VARCHAR2(17);
       vr_index_cratrej       VARCHAR2(20);
       -- Variavel para armazenar as informacoes em XML
       vr_des_xml      CLOB;
       vr_clobcri      CLOB;
       vr_dstexto      VARCHAR2(32700);
       vr_desdados     VARCHAR2(4000);
       --Variaveis de Arquivo
       vr_input_file  utl_file.file_type;

       vr_aux_cdocorre NUMBER;

       procedure pc_grava_log(pr_cdcooper crapcop.cdcooper%type
                             ,pr_cdcritic integer
                             ,pr_dscritic varchar2) is
         --
         vr_idprglog pls_integer    := 0;
         vr_dscritic varchar2(4000) := null;
         --
       begin
         --
         --se possui código de critica e a descricao da critica está vazia então carrega a descricao
         if nvl(pr_cdcritic,0) <> 0 and trim(pr_dscritic) is null then
           --
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
           --
         --se o parametro da descricao da crítica possui conteudo então inicializa a variavael interna
         elsif trim(pr_dscritic) is not null then
           --
           vr_dscritic := trim(pr_dscritic);
           --
         end if;
         --
         --se possui descricao de crítica então grava log
         if trim(vr_dscritic) is not null then
           --
           cecred.pc_log_programa(pr_dstiplog      => 'O'
                                 ,pr_cdprograma    => 'CRPS538'
                                 ,pr_cdcooper      => nvl(pr_cdcooper,3)
                                 ,pr_tpexecucao    => 1 --batch
                                 ,pr_tpocorrencia  => 4 --mensagem
                                 ,pr_cdcriticidade => 2 --alta
                                 ,pr_dsmensagem    => trim(substr(trim(to_char(sysdate,'hh24:mi:ss')||' - PC_CRPS538.GRAVA_LOG --> '||pr_dscritic),1,4000))
                                 ,pr_idprglog      => vr_idprglog);
           --
         end if;
         --
       end pc_grava_log;

       --Procedimento para validar vencimento titulo
       PROCEDURE pc_verifica_vencto_titulo (pr_cdcooper   IN INTEGER
                                           ,pr_dtvencto   IN DATE
                                           ,pr_nmtelant   IN VARCHAR2
                                           ,pr_rw_crapdat IN BTCH0001.rw_crapdat%type
                                           ,pr_critdata   OUT BOOLEAN
                                           ,pr_cdcritic   OUT INTEGER
                                           ,pr_dscritic   OUT VARCHAR2) IS
       BEGIN
         DECLARE
           --Variaveis Locais
           vr_dtdiautil DATE;
           vr_dtferiado DATE;
           vr_dtrefere  DATE;
           vr_nranoant  VARCHAR2(4);
         BEGIN
           --Inicialiar variaveis erro
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;
           --Marcar Critica
           pr_critdata:= FALSE;
           --Verificar proximo dia util
           IF pr_dtvencto IS NOT NULL THEN
             vr_dtferiado:= gene0005.fn_valida_dia_util (pr_cdcooper => pr_cdcooper
                                                        ,pr_dtmvtolt => pr_dtvencto
                                                        ,pr_tipo => 'P');
           END IF;
           --Determinar Data Referencia
           IF pr_nmtelant = 'COMPEFORA' THEN
             vr_dtrefere:= pr_rw_crapdat.dtmvtoan;
           ELSE
             vr_dtrefere:= pr_rw_crapdat.dtmvtolt;
           END IF;
           --Proximo dia util Maior data atual
           IF vr_dtferiado >= vr_dtrefere THEN
             RETURN;
           END IF;

           --Marcar para criticar data
           pr_critdata:= TRUE;
           /** Tratamento para permitir pagamento no primeiro dia util do **/
           /** ano de titulos vencidos no ultimo dia util do ano anterior **/

           --Montar ano da dtmvtoan
           vr_nranoant:= to_char(pr_rw_crapdat.dtmvtoan,'YYYY');
           --Ano anterior diferente Ano Pagamento
           IF vr_nranoant != to_char(pr_rw_crapdat.dtmvtocd,'YYYY') THEN
             --Montar ultimo dia ano anterior
             vr_dtdiautil:= to_date('3112'||vr_nranoant,'DDMMYYYY');
             /** Se dia 31/12 for segunda-feira obtem data do sabado **/
             /** para aceitar vencidos do ultimo final de semana     **/
             CASE to_number(to_char(vr_dtdiautil,'D'))
               WHEN 1 THEN vr_dtdiautil:= to_date('2912'||vr_nranoant,'DDMMYYYY');
               WHEN 2 THEN vr_dtdiautil:= to_date('2912'||vr_nranoant,'DDMMYYYY');
               WHEN 7 THEN vr_dtdiautil:= to_date('3012'||vr_nranoant,'DDMMYYYY');
               ELSE NULL;
             END CASE;
             /** Verifica se pode aceitar o titulo vencido **/
             IF pr_dtvencto >= vr_dtdiautil THEN
               --Retorna FALSE
               pr_critdata:= FALSE;
             END IF;
           END IF;
         EXCEPTION
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             pr_cdcritic:= 0;
             pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_verifica_vencto_titulo. '||sqlerrm;
             --Sair do programa
             RAISE vr_exc_saida;
         END;
       END pc_verifica_vencto_titulo;

       PROCEDURE pc_verifica_vencto  (pr_cdcooper IN INTEGER  --Codigo da cooperativa
                              ,pr_dtmvtolt IN DATE     --Data para verificacao
                              ,pr_cddbanco IN INTEGER  --Codigo do Banco
                              ,pr_cdagenci IN INTEGER  --Codigo da Agencia
                              ,pr_dtboleto IN DATE     --Data do Titulo
                              ,pr_flgvenci OUT BOOLEAN --Indicador titulo vencido
                              ,pr_cdcritic OUT INTEGER --Codigo do erro
                              ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
        ---------------------------------------------------------------------------------------------------------------
        -- Objetivo  : Procedure para verificar se a data de pagto do titulo eh feriado
        --             em funcao do banco/agencia do local de pagamento
        ---------------------------------------------------------------------------------------------------------------
        BEGIN
          DECLARE
            --Cursores Locais

        /* Busca dos dados da cooperativa */
        CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
          SELECT crapcop.cdcooper
                ,crapcop.nmrescop
                ,crapcop.nmextcop
                ,crapcop.nrtelura
                ,crapcop.dsdircop
                ,crapcop.cdbcoctl
                ,crapcop.cdagectl
                ,crapcop.flgoppag
                ,crapcop.flgopstr
                ,crapcop.inioppag
                ,crapcop.fimoppag
                ,crapcop.iniopstr
                ,crapcop.fimopstr
            FROM crapcop
           WHERE crapcop.cdcooper = pr_cdcooper;
        rw_crapcop cr_crapcop%ROWTYPE;

        --Selecionar informacoes dos bancos
        CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
          SELECT crapban.nmresbcc
                ,crapban.nmextbcc
                ,crapban.cdbccxlt
          FROM crapban
          WHERE crapban.cdbccxlt = pr_cdbccxlt;
        rw_crapban cr_crapban%ROWTYPE;

        --Selecionar Informacoes das Agencias
        CURSOR cr_crapagb (pr_cddbanco IN crapagb.cddbanco%TYPE
                          ,pr_cdageban IN crapage.cdagepac%TYPE) IS
          SELECT crapagb.cddbanco
                ,crapagb.cdcidade
                ,crapagb.cdsitagb
          FROM crapagb
          WHERE crapagb.cddbanco = pr_cddbanco
          AND   crapagb.cdageban = pr_cdageban;
        rw_crapagb cr_crapagb%ROWTYPE;

            /* Verifica a cidade da agencia */
            CURSOR cr_crapcaf (pr_cdcidade IN crapagb.cdcidade%TYPE) IS
              SELECT crapcaf.cdcidade
              FROM  crapcaf
              WHERE crapcaf.cdcidade = pr_cdcidade;
            rw_crapcaf cr_crapcaf%ROWTYPE;

            --Selecionar feriados sistema financeiro
            CURSOR cr_crapfsf (pr_cdcidade IN crapfsf.cdcidade%TYPE
                              ,pr_dtferiad IN crapfsf.dtferiad%TYPE) IS
              SELECT crapfsf.dtferiad
              FROM crapfsf
              WHERE crapfsf.cdcidade = pr_cdcidade
              AND   crapfsf.dtferiad = pr_dtferiad;
            rw_crapfsf cr_crapfsf%ROWTYPE;

            --Variaveis Locais
            vr_proxutil  DATE;
            vr_dtferiado DATE;
            vr_erro_caf  BOOLEAN := FALSE;

            --Variaveis de Erro
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(4000);
            --Variaveis Excecao
            vr_exc_erro EXCEPTION;
            --Tipo de Dados para cursor cooperativa
          BEGIN
            --Inicializar variaveis retorno
            pr_cdcritic:= NULL;
            pr_dscritic:= NULL;

            IF pr_dtboleto IS NULL THEN
                --Mensagem erro
                vr_dscritic:= 'Data de vencimento nao pode ser nulo.';
                --Levantar Excecao
                RAISE vr_exc_erro;
            END IF;

            -- vencto
            vr_proxutil:= pr_dtboleto;
            --Flag vencida
            pr_flgvenci:= FALSE;

            /* Verifica a cooperativa */
            OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
            FETCH cr_crapcop INTO rw_crapcop;
            --Se nao encontrou
            IF cr_crapcop%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapcop;
              vr_erro_caf := TRUE;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapcop;

            /* Busca o registro do banco */
            OPEN cr_crapban (pr_cdbccxlt => pr_cddbanco);
            --Posicionar no proximo registro
            FETCH cr_crapban INTO rw_crapban;

            IF cr_crapban%NOTFOUND THEN
               vr_erro_caf := TRUE;
            END IF;

            --Fechar Cursor
            CLOSE cr_crapban;

            IF NOT vr_erro_caf THEN
              --Selecionar Agencias
              OPEN cr_crapagb (pr_cddbanco => rw_crapban.cdbccxlt
                              ,pr_cdageban => pr_cdagenci);
              --Posicionar no primeiro registro
              FETCH cr_crapagb INTO rw_crapagb;

              IF cr_crapagb%NOTFOUND THEN
                 --Fechar Cursor
                 vr_erro_caf := TRUE;
              END IF;

              --Fechar Cursor
              CLOSE cr_crapagb;
            END IF;

            IF NOT vr_erro_caf THEN
              /* Verifica a cidade da agencia */
              OPEN cr_crapcaf (pr_cdcidade => rw_crapagb.cdcidade);
              --Posicionar no proximo registro
              FETCH cr_crapcaf INTO rw_crapcaf;

              --Se nao encontrar
              IF cr_crapcaf%NOTFOUND THEN
                vr_erro_caf := TRUE;
              END IF;

              --Fechar Cursor
              CLOSE cr_crapcaf;
            END IF;

            --Loop procurando por feriados
            WHILE TRUE LOOP
              --Verificar se o dia eh feriado
              vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                        ,pr_dtmvtolt => vr_proxutil
                                                        ,pr_tipo     => 'P');

              IF NOT vr_erro_caf THEN
                --Selecionar feriados sistema financeiro
                OPEN cr_crapfsf (pr_cdcidade => rw_crapcaf.cdcidade
                                ,pr_dtferiad => vr_dtferiado);
                --Posicionar no proximo registro
                FETCH cr_crapfsf INTO rw_crapfsf;
                --Se nao encontrar
                IF cr_crapfsf%FOUND THEN
                  --Vencida recebe false
                  vr_proxutil:= vr_proxutil+1;
                ELSE
                  EXIT;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapfsf;
              ELSE
                EXIT;
              END IF;
            END LOOP;

            --Se a data do vencimento maior ou igual a data de movimento
            IF vr_dtferiado >= pr_dtmvtolt THEN
              pr_flgvenci:= FALSE;
            ELSE
              --Vencida recebe true
              pr_flgvenci:= TRUE;
            END IF;

          EXCEPTION
             WHEN vr_exc_erro THEN
               pr_cdcritic:= vr_cdcritic;
               pr_dscritic:= vr_dscritic;
             WHEN OTHERS THEN
               pr_cdcritic:= 0;
               pr_dscritic:= 'Erro na rotina pc_crps538.pc_verifica_vencto. '||SQLERRM;
          END;
        END pc_verifica_vencto;

       --Funcao para listar motivos
       FUNCTION fn_lista_motivos (pr_dsmotivo IN VARCHAR2
                                 ,pr_cddbanco IN INTEGER
                                 ,pr_cdocorre IN INTEGER) RETURN VARCHAR2 IS
       BEGIN
         DECLARE
           --Variaveis Locais
           vr_dsmotrel     crapmot.dsmotivo%type;
           vr_pos           INTEGER:= 1;
         BEGIN
           --Percorrer string dos motivos
           WHILE vr_pos <= LENGTH(TRIM(pr_dsmotivo)) LOOP
             --Monta mensagem
             vr_dsmotrel:= TRIM(SUBSTR(pr_dsmotivo, vr_pos, 2));
             --Montar Indice para acesso ao cadastro motivos
             vr_index_crapmot:= lpad(pr_cddbanco,5,'0')||
                                lpad(pr_cdocorre,5,'0')||
                                lpad(2,5,'0')||
                                vr_dsmotrel;
             --Verificar se existe motivo
             IF vr_tab_crapmot.EXISTS(vr_index_crapmot) THEN
               vr_dsmotrel:= vr_dsmotrel ||' - ' ||vr_tab_crapmot(vr_index_crapmot);
             END IF;
             --Incrementar posicao
             vr_pos:= vr_pos + 2;
           END LOOP;
           --Retornar descricao motivo
           RETURN(vr_dsmotrel);
         EXCEPTION
           WHEN OTHERS THEN
           RETURN NULL;
         END;
       END fn_lista_motivos;

       -- Gera Relatorio 686
       PROCEDURE pc_gera_relatorio_686 (pr_nmtelant IN VARCHAR2
                                       ,pr_cdcritic OUT INTEGER
                                       ,pr_dscritic OUT VARCHAR2) IS

         CURSOR cr_crapret_relat (pr_cdcooper IN crapret.cdcooper%TYPE
                                 ,pr_dtdpagto IN crapret.dtocorre%TYPE) IS
           SELECT ret.nrcnvcob
                  ,cco.dsorgarq
                  ,ceb.qtdfloat
                  ,COUNT(*) qtdregis
                  ,SUM(ret.vlrpagto) vltotpag
                  ,ret.dtcredit
            FROM crapret ret, crapceb ceb, crapcco cco
           WHERE ret.cdcooper = pr_cdcooper
             AND ret.dtocorre = pr_dtdpagto
             AND ceb.cdcooper = ret.cdcooper
             AND ceb.nrconven = ret.nrcnvcob
             AND ceb.nrdconta = ret.nrdconta
             AND ret.dtcredit IS NOT NULL
             AND ret.cdocorre IN (6,17,76,77)
             AND ret.vlrpagto < 250000
             AND cco.cdcooper = ret.cdcooper
             AND cco.nrconven = ret.nrcnvcob
             AND cco.cddbanco = 85
             GROUP BY ceb.qtdfloat, cco.qtdfloat, cco.dsorgarq, ret.nrcnvcob, ret.dtcredit
             ORDER BY ceb.qtdfloat, cco.qtdfloat, ret.nrcnvcob;

         /* Buscar saldo pendentes do float */
         CURSOR cr_crapret_sld (pr_cdcooper IN crapret.cdcooper%TYPE
                               ,pr_dtdpagto IN crapret.dtocorre%TYPE
                               ,pr_dtmvtopr IN crapret.dtocorre%TYPE) IS
           SELECT ret.dtocorre
                 ,ret.dtcredit 
                 ,ret.nrcnvcob
                 ,ceb.qtdfloat
                 ,COUNT(*) qtdregis
                 ,SUM(ret.vlrpagto) vltotpag
             FROM crapret ret
                 ,crapceb ceb
                 ,crapcco cco
            WHERE ret.cdcooper = pr_cdcooper
              AND ret.dtocorre < pr_dtdpagto -- Eliminar os registros mostrados acima
              AND ret.dtcredit BETWEEN pr_dtmvtopr AND (pr_dtmvtopr + 10)
              AND ret.cdocorre IN (6,17,76,77)
              AND ret.vlrpagto < 250000
              AND cco.cdcooper = ret.cdcooper
              AND cco.nrconven = ret.nrcnvcob
              AND ceb.cdcooper = ret.cdcooper
              AND ceb.nrconven = ret.nrcnvcob
              AND ceb.nrdconta = ret.nrdconta
              AND cco.cddbanco = 85
           --   AND ret.flcredit = 0
            GROUP BY ret.dtocorre
                    ,ret.dtcredit
                    ,ret.nrcnvcob
                    ,ceb.qtdfloat
            ORDER BY ceb.qtdfloat
                    ,ret.dtocorre
                    ,ret.dtcredit
                    ,ret.nrcnvcob;

          vr_dtdpagto_rel  DATE;
          vr_aux_float     INTEGER;
          vr_aux_float_sld INTEGER;
          vr_vlsldpen      crapret.vlrpagto%TYPE := 0;
          vr_aux_contador  NUMBER := 0;

       BEGIN

         IF pr_nmtelant = 'COMPEFORA' THEN
           --Dia Anterior
           vr_dtdpagto_rel:= rw_crapdat.dtmvtoan;
         ELSE
           --Data Atual
           vr_dtdpagto_rel:= rw_crapdat.dtmvtolt;
         END IF;

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         vr_dstexto:= NULL;

         -- Inicilizar as informacoes do XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl686><lancamentos'||
                        ' dtmvtolt="'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||
                        '">');

         vr_aux_float := NULL;

         --Selecionar Convenios
         FOR rw_crapret IN cr_crapret_relat (pr_cdcooper => pr_cdcooper
                                            ,pr_dtdpagto => vr_dtdpagto_rel) LOOP

               IF (vr_aux_float IS NOT NULL) AND (rw_crapret.qtdfloat <> vr_aux_float) THEN
                  gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</float>');
               END IF;

               IF (rw_crapret.qtdfloat <> vr_aux_float) OR ( vr_aux_float IS NULL) THEN
                 gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                 '<float qtdddias="' || to_char(rw_crapret.qtdfloat) || '"
                         flsldpen="N" >');
                 vr_aux_float := rw_crapret.qtdfloat;
               END IF;

               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
               '<convenio>
                  <nrcnvcob>'||to_char(rw_crapret.nrcnvcob)||'</nrcnvcob>
                  <qtdfloat>'||to_char(rw_crapret.qtdfloat)||'</qtdfloat>
                  <qtdregis>'||to_char(rw_crapret.qtdregis)||'</qtdregis>
                  <vltotpag>'||to_char(rw_crapret.vltotpag,'fm999g999g990d00')||'</vltotpag>
                  <dtcredit>'||to_char(rw_crapret.dtcredit,'DD/MM/RRRR')||'</dtcredit>
                  <dtocorre>'||to_char(vr_dtdpagto_rel,'DD/MM/RRRR')||'</dtocorre>
                </convenio>');

               if rw_crapret.qtdfloat > 0 then
                 vr_vlsldpen := vr_vlsldpen + rw_crapret.vltotpag;
               end if;

         END LOOP;

         vr_aux_float_sld := NULL;

         --Buscar saldo pendente dopfloat para o relatorio
         FOR rw_crapret IN cr_crapret_sld (pr_cdcooper => pr_cdcooper
                                          ,pr_dtdpagto => vr_dtdpagto_rel            
                                          ,pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP

           vr_aux_contador := vr_aux_contador +1;
           
           IF vr_aux_contador = 1 THEN
         -- Finalizar tag XML
         IF (vr_aux_float IS NOT NULL) THEN
           -- finalizar apenas se a variavel recebeu valor dentro do cursor
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</float>');
         END IF;
           END IF;

           IF (vr_aux_float_sld IS NOT NULL) AND (rw_crapret.qtdfloat <> vr_aux_float_sld) THEN
              gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</float>');
           END IF;

           IF (rw_crapret.qtdfloat <> vr_aux_float_sld) OR ( vr_aux_float_sld IS NULL) THEN
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
             '<float qtdddias="' || to_char(rw_crapret.qtdfloat) ||
             '" flsldpen="S" >');
             vr_aux_float_sld := rw_crapret.qtdfloat;
           END IF;

           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
           '<convenio>
              <nrcnvcob>'||to_char(rw_crapret.nrcnvcob)||'</nrcnvcob>
              <qtdfloat>'||to_char(rw_crapret.qtdfloat)||'</qtdfloat>
              <qtdregis>'||to_char(rw_crapret.qtdregis)||'</qtdregis>
              <vltotpag>'||to_char(rw_crapret.vltotpag,'fm999g999g990d00')||'</vltotpag>
              <dtcredit>'||to_char(rw_crapret.dtcredit,'DD/MM/RRRR')||'</dtcredit>
              <dtocorre>'||to_char(rw_crapret.dtocorre,'DD/MM/RRRR')||'</dtocorre>
            </convenio>');

           IF rw_crapret.qtdfloat > 0 THEN
              vr_vlsldpen := vr_vlsldpen + rw_crapret.vltotpag;
           END IF;            

         END LOOP;

         IF (vr_aux_contador = 0 and (vr_aux_float IS NOT NULL)) or (vr_aux_float_sld IS NOT NULL) THEN
         -- Finalizar tag XML
         IF (vr_aux_float IS NOT NULL) THEN
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
             '<convenio>
                <tot_vlsldpen>'||to_char(vr_vlsldpen,'fm999g999g990d00')||'</tot_vlsldpen>
              </convenio>');              
           -- finalizar apenas se a variavel recebeu valor dentro do cursor
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</float>');
         END IF;
         END IF;

         -- Finalizar tag XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</lancamentos>');

         -- Finalizar tag XML do relatorio
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl686>',true);

         -- Busca o diretorio da cooperativa conectada
         vr_caminho_rl := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => 'rl');

         -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
         -- para evitar sobrepor arquivos de outras execuções
         IF vr_inreproc THEN
           vr_nmarqimp:= 'crrl686_REP_'||GENE0002.fn_busca_time()||'.lst';
         ELSE   
         vr_nmarqimp:= 'crrl686.lst';
         END IF;


         -- Efetuar solicitacao de geracao de relatorio crrl686 --
         gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper                  --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                  --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt          --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml                   --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl686/lancamentos/float/convenio' --> Na base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl686.jasper'             --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                         --> Titulo do relatorio
                                     ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                     ,pr_qtcoluna  => 234                          --> 234 colunas
                                     ,pr_cdrelato  => 686                          --> Codigo fixo do relatorio
                                     ,pr_sqcabrel  => 1                            --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_flg_impri => 'S'                          --> Chamar a impressao (Imprim.p)
                                     ,pr_nmformul  => '234dh'                      --> Nome do formulario para impress?o
                                     ,pr_nrcopias  => 1                            --> Número de cópias
                                     ,pr_flg_gerar => 'S'                          --> gerar PDF
                                     ,pr_des_erro  => vr_dscritic);                --> Sa?da com erro
         -- Testar se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar excecao
           RAISE vr_exc_saida;
         END IF;

         -- Liberando a memoria alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
         vr_dstexto:= NULL;

       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_gera_relatorio_686. '||sqlerrm;
           --Sair do programa
           --RAISE vr_exc_saida;
       END;


       --Gerar Relatorio 574
       PROCEDURE pc_gera_relatorio_574 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                       ,pr_cdcritic OUT INTEGER
                                       ,pr_dscritic OUT VARCHAR2) IS
       
         ---------> CURSORES <---------
         --> Listar devoluoes da coop
         CURSOR cr_devolucao (pr_cdcooper crapcop.cdcooper%TYPE,
                              pr_dtmvtolt crapdat.dtmvtolt%TYPE )IS
           SELECT dev.dtocorre,
                  dev.nrispbif,
                  ban.cdbccxlt,
                  dev.cdagerem,
                  dev.dscodbar,
                  dev.vlliquid,
                  dev.cdmotdev
             FROM tbcobran_devolucao dev,
                  crapban ban
            WHERE dev.cdcooper = pr_cdcooper
              AND dev.dtmvtolt = pr_dtmvtolt
              AND ban.nrispbif (+) = dev.nrispbif
              AND ban.cdbccxlt (+) = decode(ban.nrispbif(+),0,1,ban.cdbccxlt(+));
              
         ---------> VARIAVEIS <----------
         vr_dsmotdev VARCHAR2(4000);     
       
       BEGIN
       
         vr_nmarqimp:= 'crrl574.lst';

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         vr_dstexto:= NULL;
         -- Inicilizar as informacoes do XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl574><dados dtmvtolt="'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'">');
           
           
         --> Listar devoluoes da coop
         FOR rw_devolucao IN cr_devolucao (pr_cdcooper => pr_cdcooper,
                                           pr_dtmvtolt => pr_dtmvtolt) LOOP
           
           CASE rw_devolucao.cdmotdev
             WHEN 53 THEN
               vr_dsmotdev := 'Apresentação indevida';
             WHEN 63 THEN               
					     vr_dsmotdev := 'Código de barras em desacordo com as especificações';
             WHEN 72 THEN
					     vr_dsmotdev := 'Devolução de Pagamento Fraudado';
             WHEN 73 THEN
					     vr_dsmotdev := 'Beneficiário sem contrato de cobrança';
             WHEN 74 THEN
					     vr_dsmotdev := 'Beneficiário inválido ou boleto não encontrado';
             WHEN 77 THEN
					     vr_dsmotdev := 'Boleto em cartório ou protestado';
             ELSE
               vr_dsmotdev := 'Descrição de motivo não encontrada';
           END CASE;    
         
           --Escrever no Arquivo XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
             '<dado>
                   <dtocorre>'|| to_char(rw_devolucao.dtocorre,'DD/MM/RRRR')   ||'</dtocorre>'||
                  '<nrispbif>'|| rw_devolucao.nrispbif   ||'</nrispbif>'||
                  '<cdbccxlt>'|| rw_devolucao.cdbccxlt   ||'</cdbccxlt>'||
                  '<cdagerem>'|| rw_devolucao.cdagerem   ||'</cdagerem>'||
                  '<dscodbar>'|| rw_devolucao.dscodbar   ||'</dscodbar>'||
                  '<vlliquid>'|| to_char(rw_devolucao.vlliquid,'fm999g999g999g990d00')  ||'</vlliquid>'||
                  '<cdmotdev>'|| rw_devolucao.cdmotdev   ||'</cdmotdev>'||
                  '<dsmotdev>'|| gene0007.fn_caract_acento(vr_dsmotdev) ||'</dsmotdev>
              </dado>');           
         END LOOP;

         -- Finalizar tag XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</dados></crrl574>',true);

         /*  Salvar copia relatorio para "/rlnsv"  */
         IF pr_nmtelant = 'COMPEFORA' THEN
           vr_flpdfcopi:= 'S';
         ELSE
           vr_flpdfcopi:= 'N';
         END IF;

         -- Efetuar solicitacao de geracao de relatorio crrl574 --
         gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl574/dados/dado'  --> N? base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl574.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Titulo do relat?rio
                                     ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                     ,pr_nmformul  => NULL                --> Nome do formul?rio para impress?o
                                     ,pr_nrcopias  => 1                   --> N?mero de c?pias
                                     ,pr_flg_gerar => 'S'                 --> gerar PDF
                                     ,pr_dspathcop => vr_caminho_rlnsv    --> Lista sep. por ';' de diretórios a copiar o relatório
                                     ,pr_des_erro  => vr_dscritic);       --> Sa?da com erro
         -- Testar se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar excecao
           RAISE vr_exc_saida;
         END IF;

         -- Liberando a memoria alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
         vr_dstexto:= NULL;
       
       EXCEPTION
         --> apenas repassar as criticas
         WHEN vr_exc_saida THEN
           pr_dscritic := vr_dscritic;
           pr_cdcritic := vr_cdcritic;
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_gera_relatorio_574. '||sqlerrm;
       
       END;

       --Gerar Relatorio 605
       PROCEDURE pc_gera_relatorio_605 (pr_cdcritic OUT INTEGER
                                       ,pr_dscritic OUT VARCHAR2) IS
         --Cursores Locais
         CURSOR cr_crapcco_relat (pr_cdcooper IN crapcco.cdcooper%type
                                 ,pr_cddbanco IN crapcco.cddbanco%type) IS
           SELECT crapcco.dsorgarq
                 ,crapcco.nrconven
                 ,crapcco.nrdolote
                 ,crapcco.cdagenci
                 ,crapcco.cdbccxlt
           FROM crapcco
           WHERE crapcco.cdcooper = pr_cdcooper
           AND   crapcco.cddbanco = pr_cddbanco;
         --Selecionar controle remessas titulos bancarios
         CURSOR cr_crapcre_relat (pr_cdcooper IN crapcop.cdcooper%type
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                                 ,pr_nrconven IN crapcco.nrconven%type
                                 ,pr_intipmvt IN crapcre.intipmvt%type
                                 ,pr_cddbanco IN crapcco.cddbanco%type) IS
           SELECT crapcre.cdcooper
                 ,crapcre.nrcnvcob
                 ,crapcre.dtmvtolt
                 ,crapcre.nrremret
                 ,crapcco.nrdctabb
                 ,crapcco.cddbanco
           FROM crapcre
               ,crapcco
           WHERE crapcre.cdcooper = pr_cdcooper
           AND   crapcre.dtmvtolt = pr_dtmvtolt
           AND   crapcre.nrcnvcob = pr_nrconven
           AND   crapcre.intipmvt = pr_intipmvt
           AND   crapcco.cddbanco = pr_cddbanco
           AND   crapcco.cdcooper = crapcre.cdcooper
           AND   crapcco.nrconven = crapcre.nrcnvcob;

         --Selecionar Retorno
         CURSOR cr_crapret (pr_cdcooper IN crapcre.cdcooper%type
                           ,pr_nrcnvcob IN crapcre.nrcnvcob%type
                           ,pr_dtocorre IN crapcre.dtmvtolt%type
                           ,pr_nrremret IN crapcre.nrremret%type
                           ,pr_nrdctabb IN crapcco.nrdctabb%type
                           ,pr_cdbandoc IN crapcco.cddbanco%type) IS
           SELECT crapret.cdcooper
                 ,crapret.nrcnvcob
                 ,crapret.nrdconta
                 ,crapret.nrdocmto
                 ,crapret.cdocorre
                 ,crapret.vltitulo
                 ,crapret.vldescto
                 ,crapret.vlabatim
                 ,crapret.vljurmul
                 ,crapret.vloutdes
                 ,crapret.vloutcre
                 ,crapret.vlrpagto
                 ,crapret.vltarass
                 ,crapcob.cdbandoc
                 ,crapcob.nrdctabb
                 ,crapcob.indpagto
                 ,Count(1) OVER (PARTITION BY crapret.cdocorre) nrtotoco
                 ,Row_Number() OVER (PARTITION BY crapret.cdocorre
                                     ORDER BY crapret.cdocorre
                                             ,crapcob.indpagto
                                             ,crapret.nrdconta
                                             ,crapret.nrdocmto  ) nrseqoco
                 ,Count(1) OVER (PARTITION BY crapret.cdocorre,crapcob.indpagto) nrtotind
                 ,Row_Number() OVER (PARTITION BY crapret.cdocorre,crapcob.indpagto
                                     ORDER BY crapret.cdocorre
                                             ,crapcob.indpagto
                                             ,crapret.nrdconta
                                             ,crapret.nrdocmto) nrseqind
           FROM crapret
               ,crapcob
           WHERE crapret.cdcooper = pr_cdcooper
           AND   crapret.nrcnvcob = pr_nrcnvcob
           AND   crapret.dtocorre = pr_dtocorre
           AND   crapret.nrremret = pr_nrremret
           AND   crapcob.cdcooper = crapret.cdcooper
           AND   crapcob.nrcnvcob = crapret.nrcnvcob
           AND   crapcob.nrdconta = crapret.nrdconta
           AND   crapcob.nrdctabb = pr_nrdctabb
           AND   crapcob.cdbandoc = pr_cdbandoc
           AND   crapcob.nrdocmto = crapret.nrdocmto
           ORDER BY crapret.cdocorre
                   ,crapcob.indpagto
                   ,crapret.nrdconta
                   ,crapret.nrdocmto;

         --Selecionar Retorno
         CURSOR cr_crapret_2 (pr_cdcooper IN crapret.cdcooper%type
                             ,pr_nrcnvcob IN crapret.nrcnvcob%type
                             ,pr_dtocorre IN crapdat.dtmvtolt%type
                             ,pr_nrremret IN crapret.nrremret%type
                             ,pr_nrdctabb IN crapcob.nrdctabb%type
                             ,pr_cddbanco IN crapcob.cdbandoc%type) IS
           SELECT crapret.cdcooper
                 ,crapret.nrcnvcob
                 ,crapret.nrdconta
                 ,crapret.nrdocmto
                 ,decode(crapret.cdocorre,6,DECODE(crapcob.indpagto,0,crapret.cdocorre,6.5),crapret.cdocorre) cdocorre
                 ,crapret.vltitulo
                 ,crapret.vldescto
                 ,crapret.vlabatim
                 ,crapret.vljurmul
                 ,crapret.vloutdes
                 ,crapret.vloutcre
                 ,crapret.vlrpagto
                 ,crapret.vltarass
                 ,crapret.cdmotivo
                 ,crapret.dtcredit
                 ,crapcob.dsdoccop
                 ,crapcob.dtvencto
                 ,crapcob.cdbandoc
                 ,crapcob.nrdctabb
                 ,crapcob.indpagto
                 ,crapcob.cdbanpag
                 ,crapcob.cdagepag
                 ,crapcob.dtdocmto
                 ,crapass.cdagenci
                 ,crapceb.qtdfloat
                 ,Count(1) OVER (PARTITION BY decode(crapret.cdocorre,6,DECODE(crapcob.indpagto,0,crapret.cdocorre,6.5),crapret.cdocorre)) nrtotoco
                 ,Row_Number() OVER (PARTITION BY decode(crapret.cdocorre,6,DECODE(crapcob.indpagto,0,crapret.cdocorre,6.5),crapret.cdocorre)
                                     ORDER BY decode(crapret.cdocorre,6,DECODE(crapcob.indpagto,0,crapret.cdocorre,6.5),crapret.cdocorre)
                                             ,crapcob.indpagto
                                             ,crapret.nrdconta
                                             ,crapret.nrdocmto  ) nrseqoco
           FROM crapret
               ,crapceb
               ,crapcob
               ,crapass
           WHERE crapret.cdcooper = pr_cdcooper
           AND   crapret.nrcnvcob = pr_nrcnvcob
           AND   crapret.dtocorre = pr_dtocorre
           AND   crapret.nrremret = pr_nrremret
           AND   crapceb.cdcooper = crapret.cdcooper
           AND   crapceb.nrdconta = crapret.nrdconta
           AND   crapceb.nrconven = crapret.nrcnvcob
           AND   crapcob.cdcooper = crapret.cdcooper
           AND   crapcob.nrcnvcob = crapret.nrcnvcob
           AND   crapcob.nrdconta = crapret.nrdconta
           AND   crapcob.nrdctabb = pr_nrdctabb
           AND   crapcob.cdbandoc = pr_cddbanco
           AND   crapcob.nrdocmto = crapret.nrdocmto
           AND   crapass.cdcooper = crapcob.cdcooper
           AND   crapass.nrdconta = crapcob.nrdconta
           ORDER BY decode(crapret.cdocorre,6,DECODE(crapcob.indpagto,0,crapret.cdocorre,6.5),crapret.cdocorre)
                   ,crapcob.indpagto
                   ,crapret.nrdconta
                   ,crapret.nrdocmto
                   ,nrseqoco;

         --Selecionar Titulos Bordero
         CURSOR cr_craptdb (pr_cdcooper IN crapcob.cdcooper%type
                           ,pr_nrdconta IN crapcob.nrdconta%type
                           ,pr_cdbandoc IN crapcob.cdbandoc%type
                           ,pr_nrdctabb IN crapcob.nrdctabb%type
                           ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                           ,pr_nrdocmto IN crapcob.nrdocmto%type
                           ,pr_insittit IN craptdb.insittit%type) IS
           SELECT craptdb.cdcooper
                 ,craptdb.rowid
                 ,count(*) over (partition BY craptdb.cdcooper) qtdreg
           FROM craptdb
           WHERE craptdb.cdcooper = pr_cdcooper
           AND   craptdb.nrdconta = pr_nrdconta
           AND   craptdb.cdbandoc = pr_cdbandoc
           AND   craptdb.nrdctabb = pr_nrdctabb
           AND   craptdb.nrcnvcob = pr_nrcnvcob
           AND   craptdb.nrdocmto = pr_nrdocmto
           AND   craptdb.insittit = pr_insittit;
         rw_craptdb cr_craptdb%ROWTYPE;

         --Selecionar Ocorrencia
         CURSOR cr_crapoco (pr_cdcooper IN crapoco.cdcooper%type
                           ,pr_cddbanco IN crapoco.cddbanco%type
                           ,pr_cdocorre IN crapoco.cdocorre%type
                           ,pr_tpocorre IN crapoco.tpocorre%type) IS
           SELECT crapoco.dsocorre
           FROM crapoco
           WHERE crapoco.cdcooper = pr_cdcooper
           AND   crapoco.cddbanco = pr_cddbanco
           AND   crapoco.cdocorre = pr_cdocorre
           AND   crapoco.tpocorre = pr_tpocorre;
         rw_crapoco cr_crapoco%ROWTYPE;

         --Variaveis Locais
         vr_dsparam     VARCHAR2(100);
         vr_cdocorre    crapoco.cdocorre%TYPE;
         vr_flgquebra   BOOLEAN:= FALSE;
       BEGIN
         --Inicializar variaveis erro
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;
         --Inicializar variavel erro
         vr_cdcritic:= 0;
         vr_contador:= 1;
         --Selecionar Convenios
         FOR rw_crapcco IN cr_crapcco_relat (pr_cdcooper => pr_cdcooper
                                            ,pr_cddbanco => 85) LOOP

           --Zerar variaveis
           vr_qttotreg:= 0;
           vr_vltotreg:= 0;
           vr_vltotdes:= 0;
           vr_vltotjur:= 0;
           vr_vloutdeb:= 0;
           vr_vloutcre:= 0;
           vr_vltotpag:= 0;
           vr_vltottar:= 0;
           vr_qtdregis:= 0;
           vr_vlregist:= 0;
           vr_vldescon:= 0;
           vr_valjuros:= 0;
           vr_vloutdeb:= 0;
           vr_vloutcre:= 0;
           vr_valorpgo:= 0;
           vr_vltarifa:= 0;
           vr_qtregrec:= 0;
           vr_qtregicd:= 0;
           vr_vlregicd:= 0;
           
           -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
           -- para evitar sobrepor arquivos de outras execuções
           IF vr_inreproc THEN
             -- Nome arquivo impressao
           vr_nmarqimp:= 'crrl605_'|| gene0002.fn_mask(rw_crapcco.nrconven,'9999999') ||
                         '_'|| gene0002.fn_mask(vr_contador,'99')|| 
                         '_REP_'||GENE0002.fn_busca_time||'.lst';
           ELSE   
             -- Nome arquivo impressao
             vr_nmarqimp:= 'crrl605_'|| gene0002.fn_mask(rw_crapcco.nrconven,'9999999') ||
                         '_'|| gene0002.fn_mask(vr_contador,'99')|| '.lst';
           END IF;
           
           --Incrementar contador
           vr_contador:= vr_contador + 1;
           --Marcar como nao rejeitado
           vr_rejeitad:= FALSE;
           --Nome arquivo
           vr_nmarquiv:= vr_tab_nmarqtel(1);

           -- Preparar o CLOB para armazenar as infos do arquivo
           dbms_lob.createtemporary(vr_clobcri, TRUE, dbms_lob.CALL);
           dbms_lob.open(vr_clobcri, dbms_lob.lob_readwrite);

           -- Inicializar o CLOB
           dbms_lob.createtemporary(vr_des_xml, TRUE);
           dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
           vr_dstexto:= NULL;
           -- Inicilizar as informacoes do XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl605><lancamentos nmarquiv="'||
                          vr_nmarquiv||'" dtmvtolt="'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||
                          '" cdagenci="'||rw_crapcco.cdagenci||'" cdbccxlt="'||rw_crapcco.cdbccxlt||
                          '" nrdolote="'||to_char(rw_crapcco.nrdolote,'fm999g990')||'" tplotmov="'||to_char(vr_tplotmov,'fm09')||
                          '" nrconven="'||to_char(rw_crapcco.nrconven,'fm00000000')||' - '||rw_crapcco.dsorgarq||
                          '">');
           --Marcar que nao teve lancamentos
           vr_temlancto:= FALSE;
           vr_index_cratrej:= vr_tab_cratrej.FIRST;
           --Selecionar os rejeitados
           WHILE vr_index_cratrej IS NOT NULL LOOP
             --Verificar convenio
             IF SUBSTR(vr_tab_cratrej(vr_index_cratrej).cdpesqbb,20,6) = gene0002.fn_mask(rw_crapcco.nrconven,'999999') THEN
               --Marcar rejeitado
               vr_rejeitad:= TRUE;
               vr_cdcritic:= vr_tab_cratrej(vr_index_cratrej).cdcritic;
               --Se possui erro
               IF vr_cdcritic = 0 THEN
                 --Descricao Critica
                 vr_dscritic:= vr_tab_cratrej(vr_index_cratrej).dshistor;
               ELSE
                 --Buscar Descricao Critica
                 vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               END IF;

               -- Caso esteja dentro da lista abaixo
               IF vr_cdcritic IN (9,592,595,965,966,980) THEN
                 -- Monta a mensagem
                 vr_desdados := '50' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') || ',' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMRR') ||
                                ',1455,4894,' || TO_CHAR(vr_tab_cratrej(vr_index_cratrej).vllanmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                ',5210,"' || GENE0007.fn_caract_acento(UPPER(LTRIM(vr_dscritic,lpad(vr_cdcritic,3,0) || ' - '))) ||
                                ' COOPERADO C/C ' || GENE0002.fn_mask_conta(vr_tab_cratrej(vr_index_cratrej).nrdconta) ||
                                ' (CONFORME CRITICA RELATORIO 605_' || GENE0002.fn_mask(vr_contador - 1,'99') || ')"' || chr(10);
                 -- Adiciona a linha ao arquivo de criticas
                 dbms_lob.writeappend(vr_clobcri, length(vr_desdados),vr_desdados);
               END IF;

               --Determinar se o historico será ou nao mostrado
               IF vr_tab_cratrej(vr_index_cratrej).cdcritic = 922  AND /** Boleto pago c/ cheque **/
                  trim(vr_tab_cratrej(vr_index_cratrej).dshistor) IS NOT NULL THEN
                 NULL;
               ELSE
                 vr_tab_cratrej(vr_index_cratrej).dshistor:= NULL;
               END IF;
               --Marcar que tem lancamento
               vr_temlancto:= TRUE;
               --Montar tag saldo contabil para arquivo XML
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
               '<lancto>
                  <nrseqdig>'||to_char(vr_tab_cratrej(vr_index_cratrej).nrseqdig,'fm999g990')||'</nrseqdig>
                  <nrdconta>'||to_char(vr_tab_cratrej(vr_index_cratrej).nrdconta,'fm9g999g999g9')||'</nrdconta>
                  <nrdocmto>'||to_char(vr_tab_cratrej(vr_index_cratrej).nrdocmto,'fm999g999g990')||'</nrdocmto>
                  <cdpesqbb>'||substr(vr_tab_cratrej(vr_index_cratrej).cdpesqbb,1,44)||'</cdpesqbb>
                  <vllanmto>'||to_char(vr_tab_cratrej(vr_index_cratrej).vllanmto,'fm999g999g990d00')||'</vllanmto>
                  <cdbccxlt>'||gene0002.fn_mask(vr_tab_cratrej(vr_index_cratrej).cdbccxlt,'zz9')||'</cdbccxlt>
                  <cdagenci>'||gene0002.fn_mask(vr_tab_cratrej(vr_index_cratrej).cdagenci,'zzz9')||'</cdagenci>
                  <dscritic>'||substr(vr_dscritic,1,54)||'</dscritic>
                  <dshistor>'||vr_tab_cratrej(vr_index_cratrej).dshistor||'</dshistor>
                </lancto>');
             END IF;
             --Proximo registro
             vr_index_cratrej:= vr_tab_cratrej.NEXT(vr_index_cratrej);
           END LOOP;

           -- Se possuir conteudo de critica no CLOB
           IF LENGTH(vr_clobcri) > 0 THEN
             -- Busca o diretório para contabilidade
             vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
             vr_dircon := vr_dircon || vc_dircon;
             vr_arqcon := TO_CHAR(vr_dtmvtolt,'RRMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CRITICAS_605.txt';

             -- Chama a geracao do TXT
             GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper              --> Cooperativa conectada
                                                ,pr_cdprogra  => vr_cdprogra              --> Programa chamador
                                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt      --> Data do movimento atual
                                                ,pr_dsxml     => vr_clobcri               --> Arquivo XML de dados
                                                ,pr_dsarqsaid => vr_caminho_puro || '/contab/' || vr_arqcon    --> Arquivo final com o path
                                                ,pr_cdrelato  => NULL                     --> Código fixo para o relatório
                                                ,pr_flg_gerar => 'N'                      --> Apenas submeter
                                                ,pr_dspathcop => vr_dircon
                                                ,pr_fldoscop  => 'S'                     --> Indica que a solicitação irá incrementar o arquivo
                                                ,pr_des_erro  => vr_des_erro2);            --> Saída com erro

           END IF;

           -- Liberando a memória alocada pro CLOB
           dbms_lob.close(vr_clobcri);
           dbms_lob.freetemporary(vr_clobcri);

           -- Verifica se ocorreram erros na geracao do TXT
           IF vr_des_erro2 IS NOT NULL THEN
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> ERRO NA GERACAO DO ' || vr_arqcon || ': '
                                                        || vr_des_erro2 );
           END IF;

           --Inserir tag em branco caso nao tenha lancamentos para permitir a impressao
           --dos atributos da tag lancamentos
           IF NOT vr_temlancto THEN
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<lancto></lancto>');
             --Nao imprimir cabecalho
             vr_dsparam:= 'PR_IMPRIME##N';
           ELSE
             vr_dsparam:= 'PR_IMPRIME##S';
           END IF;

           -- Finalizar tag XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</lancamentos>');

           --Determinar a data para sustar
           IF pr_nmtelant = 'COMPEFORA' THEN
             vr_dtmvtaux:= rw_crapdat.dtmvtoan;
           ELSE
             vr_dtmvtaux:= rw_crapdat.dtmvtolt;
           END IF;

           --Selecionar as Ocorrencias
           FOR rw_crapcre IN cr_crapcre_relat (pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtmvtaux
                                              ,pr_nrconven => rw_crapcco.nrconven
                                              ,pr_intipmvt => 2
                                              ,pr_cddbanco => 85) LOOP

             -- log relatorio 605
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||
                                                         'Gerando relatorio 605 : convenio ' || to_char(rw_crapcco.nrconven));

             --Criar tag XML Grupos
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<grupos>');

             --Percorrer todas as ocorrencias
             FOR rw_crapret IN cr_crapret (pr_cdcooper => rw_crapcre.cdcooper
                                          ,pr_nrcnvcob => rw_crapcre.nrcnvcob
                                          ,pr_dtocorre => rw_crapcre.dtmvtolt
                                          ,pr_nrremret => rw_crapcre.nrremret
                                          ,pr_nrdctabb => rw_crapcre.nrdctabb
                                          ,pr_cdbandoc => rw_crapcre.cddbanco) LOOP

               --Incrementar qdade registros
               vr_qtdregis:= nvl(vr_qtdregis,0) + 1;
               vr_vlregist:= nvl(vr_vlregist,0) + nvl(rw_crapret.vltitulo,0);
               vr_vldescon:= nvl(vr_vldescon,0) + nvl(rw_crapret.vldescto,0) + nvl(rw_crapret.vlabatim,0);
               vr_valjuros:= nvl(vr_valjuros,0) + nvl(rw_crapret.vljurmul,0);
               vr_vloutdeb:= nvl(vr_vloutdeb,0) + nvl(rw_crapret.vloutdes,0);
               vr_vloutcre:= nvl(vr_vloutcre,0) + nvl(rw_crapret.vloutcre,0);
               vr_valorpgo:= nvl(vr_valorpgo,0) + nvl(rw_crapret.vlrpagto,0);
               vr_vltarifa:= nvl(vr_vltarifa,0) + nvl(rw_crapret.vltarass,0);

               /* liquidacao e liquidacao apos baixa */
               IF rw_crapret.cdocorre IN (6,17,76,77) THEN
                 --Incrementar quantidade recebida
                 vr_qtregrec:= nvl(vr_qtregrec,0) + 1;
                 --Incrementar valor recebido
                 vr_vlregrec:= nvl(vr_vlregrec,0) + nvl(rw_crapret.vlrpagto,0);
                 /* busca por titulo descontado pago */
                 OPEN cr_craptdb (pr_cdcooper => rw_crapret.cdcooper
                                 ,pr_nrdconta => rw_crapret.nrdconta
                                 ,pr_cdbandoc => rw_crapret.cdbandoc
                                 ,pr_nrdctabb => rw_crapret.nrdctabb
                                 ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                 ,pr_nrdocmto => rw_crapret.nrdocmto
                                 ,pr_insittit => 2); /* pago */
                 FETCH cr_craptdb INTO rw_craptdb;
                 --Se encontrou e achou somente 1
                 IF cr_craptdb%FOUND THEN
                   --IF rw_craptdb.qtdreg = 1 THEN
                     /* totais de registros integrados */
                     vr_qtregicd:= nvl(vr_qtregicd,0) + 1;
                     vr_vlregicd:= nvl(vr_vlregicd,0) + nvl(rw_crapret.vlrpagto,0);
                   --END IF;
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_craptdb;
               END IF;
               --Se for Ultimo crapcob.indpagto
               IF rw_crapret.nrseqind = rw_crapret.nrtotind THEN
                 IF rw_crapret.cdocorre IN(6,76) AND rw_crapret.indpagto = 0 THEN
                   vr_flgquebra:= TRUE;
                 END IF;
               END IF;
               --Se for o Ultimo crapret.cdocorre ou quebrou
               IF rw_crapret.nrseqoco = rw_crapret.nrtotoco OR vr_flgquebra THEN
                 --Selecionar Ocorrencias
                 OPEN cr_crapoco (pr_cdcooper => rw_crapret.cdcooper
                                 ,pr_cddbanco => rw_crapret.cdbandoc
                                 ,pr_cdocorre => rw_crapret.cdocorre
                                 ,pr_tpocorre => 2); /* Retorno */
                 FETCH cr_crapoco INTO rw_crapoco;
                 --Se Encontrou
                 IF cr_crapoco%FOUND THEN
                   IF (rw_crapret.indpagto > 0 AND rw_crapret.cdocorre IN (6,76)) THEN
                     vr_dsocorre:= rw_crapoco.dsocorre || ' (COOP)';
                   ELSE
                     vr_dsocorre:= rw_crapoco.dsocorre;
                   END IF;
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_crapoco;

                 --Montar tag saldo contabil para arquivo XML
                 gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                   '<grupo>
                     <cdocorre>'||gene0002.fn_mask(rw_crapret.cdocorre,'z9')||'</cdocorre>
                     <dsocorre>'||substr(vr_dsocorre,1,60)||'</dsocorre>
                     <qtdregis>'||vr_qtdregis||'</qtdregis>
                     <vlregist>'||to_char(vr_vlregist,'fm999g999g9990d00')||'</vlregist>
                     <vldescon>'||to_char(vr_vldescon,'fm999g999g9990d00')||'</vldescon>
                     <valjuros>'||to_char(vr_valjuros,'fm999g999g9990d00')||'</valjuros>
                     <vloutdeb>'||to_char(vr_vloutdeb,'fm999g999g9990d00')||'</vloutdeb>
                     <vloutcre>'||to_char(vr_vloutcre,'fm999g999g9990d00')||'</vloutcre>
                     <valorpgo>'||to_char(vr_valorpgo,'fm999g999g9990d00')||'</valorpgo>
                     <vltarifa>'||to_char(vr_vltarifa,'fm999g999g9990d00')||'</vltarifa>
                   </grupo>');

                 --Acumular Totais
                 vr_qttotreg:= nvl(vr_qttotreg,0) + nvl(vr_qtdregis,0);
                 vr_vltotreg:= nvl(vr_vltotreg,0) + nvl(vr_vlregist,0);
                 vr_vltotdes:= nvl(vr_vltotdes,0) + nvl(vr_vldescon,0);
                 vr_vltotjur:= nvl(vr_vltotjur,0) + nvl(vr_valjuros,0);
                 vr_vloutdeb:= nvl(vr_vloutdeb,0) + nvl(vr_vloutdeb,0);
                 vr_vloutcre:= nvl(vr_vloutcre,0) + nvl(vr_vloutcre,0);
                 vr_vltotpag:= nvl(vr_vltotpag,0) + nvl(vr_valorpgo,0);
                 vr_vltottar:= nvl(vr_vltottar,0) + nvl(vr_vltarifa,0);
                 --Zerar Variaveis
                 vr_qtdregis:= 0;
                 vr_vlregist:= 0;
                 vr_vldescon:= 0;
                 vr_valjuros:= 0;
                 vr_vloutdeb:= 0;
                 vr_vloutcre:= 0;
                 vr_valorpgo:= 0;
                 vr_vltarifa:= 0;
                 vr_flgquebra:= FALSE;
               END IF;
             END LOOP; --rw_crapret

             -- Finalizar tag XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</grupos><analitico>');

             --Quantidade total registros
             vr_qttotreg:= 0;
             vr_vltotreg:= 0;
             vr_vltotdes:= 0;
             vr_vltotjur:= 0;
             vr_vloutdeb:= 0;
             vr_vloutcre:= 0;
             vr_vltotpag:= 0;
             vr_vltottar:= 0;
             vr_flgquebra:= FALSE;

             --Selecionar retornos
             FOR rw_crapret IN cr_crapret_2 (pr_cdcooper => rw_crapcre.cdcooper
                                            ,pr_nrcnvcob => rw_crapcre.nrcnvcob
                                            ,pr_dtocorre => rw_crapcre.dtmvtolt
                                            ,pr_nrremret => rw_crapcre.nrremret
                                            ,pr_nrdctabb => rw_crapcre.nrdctabb
                                            ,pr_cddbanco => rw_crapcre.cddbanco) LOOP

               --Se for primeira ocorrencia
               IF rw_crapret.nrseqoco = 1 THEN
                 --Se for liquidacao coop
                 IF rw_crapret.cdocorre = 6.5 THEN
                   vr_cdocorre:= 6;
                 ELSE
                   vr_cdocorre:= rw_crapret.cdocorre;
                 END IF;
                 --Selecionar Ocorrencias
                 OPEN cr_crapoco (pr_cdcooper => rw_crapret.cdcooper
                                 ,pr_cddbanco => rw_crapret.cdbandoc
                                 ,pr_cdocorre => vr_cdocorre
                                 ,pr_tpocorre => 2); /* Retorno */
                 FETCH cr_crapoco INTO rw_crapoco;
                 --Montar Descricao da Ocorrencia
                 IF rw_crapret.cdocorre = 6.5 THEN
                   vr_dsocorre:= rw_crapoco.dsocorre || ' (COOP)';
                 ELSE
                   vr_dsocorre:= rw_crapoco.dsocorre;
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_crapoco;
                 --Abrir tag ocorrencias
                 gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<ocorrencias cdocorre="'||vr_cdocorre||'" dsocorre="'||vr_dsocorre||'">');
               END IF;

              --Titulo nao descontado
               vr_dstitdsc:= NULL;
               /* busca por titulo descontado pago */
               OPEN cr_craptdb (pr_cdcooper => rw_crapret.cdcooper
                               ,pr_nrdconta => rw_crapret.nrdconta
                               ,pr_cdbandoc => rw_crapret.cdbandoc
                               ,pr_nrdctabb => rw_crapret.nrdctabb
                               ,pr_nrcnvcob => rw_crapret.nrcnvcob
                               ,pr_nrdocmto => rw_crapret.nrdocmto
                               ,pr_insittit => 2); /* pago */
               FETCH cr_craptdb INTO rw_craptdb;
               --Se encontrou
               IF cr_craptdb%FOUND AND rw_craptdb.qtdreg = 1 THEN
               --IF cr_craptdb%FOUND THEN
                 --Marcar como titulo descontado
                 vr_dstitdsc:= 'TD';
               END IF;
               --Fechar Cursor
               CLOSE cr_craptdb;
               --Acumuladores
               vr_qttotreg:= nvl(vr_qttotreg,0) + 1;
               vr_vltotreg:= nvl(vr_vltotreg,0) + nvl(rw_crapret.vltitulo,0);
               vr_vldescon:= nvl(rw_crapret.vldescto,0) + nvl(rw_crapret.vlabatim,0);
               vr_vltotdes:= nvl(vr_vltotdes,0) + vr_vldescon;
               vr_vltotjur:= nvl(vr_vltotjur,0) + nvl(rw_crapret.vljurmul,0);
               vr_vloutdeb:= nvl(vr_vloutdeb,0) + nvl(rw_crapret.vloutdes,0);
               vr_vloutcre:= nvl(vr_vloutcre,0) + nvl(rw_crapret.vloutcre,0);
               vr_vltotpag:= nvl(vr_vltotpag,0) + nvl(rw_crapret.vlrpagto,0);
               vr_vltottar:= nvl(vr_vltottar,0) + nvl(rw_crapret.vltarass,0);
               --Pagamento ocorreu na cooperativa
               IF (rw_crapret.cdbanpag = 11 AND rw_crapret.cdagepag = 0) THEN
                 vr_bancoage:= 'COOP.';
               ELSE
                 vr_bancoage:= rw_crapret.cdbanpag||'/'||rw_crapret.cdagepag;
               END IF;
               /** Dados **/
               --Listar Motivos
               vr_dsmotrel:= fn_lista_motivos (pr_dsmotivo => rw_crapret.cdmotivo
                                              ,pr_cddbanco => rw_crapcre.cddbanco
                                              ,pr_cdocorre => vr_cdocorre);

               --Montar tag saldo contabil para arquivo XML
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
               '<oco>
                   <cdagenci>'||gene0002.fn_mask(rw_crapret.cdagenci,'zz9')||'</cdagenci>
                   <nrdconta>'||to_char(rw_crapret.nrdconta,'fm9g999g999g9')||'</nrdconta>
                   <nrdocmto>'||to_char(rw_crapret.nrdocmto,'fm999g999g990')||'</nrdocmto>
                   <dstitdsc>'||vr_dstitdsc||'</dstitdsc>
                   <dsdoccop>'||rw_crapret.dsdoccop||'</dsdoccop>
                   <dtvencto>'||to_char(rw_crapret.dtvencto,'DD/MM/YY')||'</dtvencto>
                   <vltitulo>'||to_char(rw_crapret.vltitulo,'fm999g999g990d00')||'</vltitulo>
                   <vldescon>'||to_char(vr_vldescon,'fm999g999g990d00')||'</vldescon>
                   <vljurmul>'||to_char(rw_crapret.vljurmul,'fm999g999g990d00')||'</vljurmul>
                   <vloutdes>'||to_char(rw_crapret.vloutdes,'fm999g999g990d00')||'</vloutdes>
                   <vloutcre>'||to_char(rw_crapret.vloutcre,'fm999g999g990d00')||'</vloutcre>
                   <vlrpagto>'||to_char(rw_crapret.vlrpagto,'fm999g999g990d00')||'</vlrpagto>
                   <dtcredit>'||to_char(rw_crapret.dtcredit,'DD/MM/YY')||'</dtcredit>
                   <bancoage>'||vr_bancoage||'</bancoage>
                   <vltarass>'||to_char(rw_crapret.vltarass,'fm999g999g990d00')||'</vltarass>
                   <dsmotrel>'||SUBSTR(vr_dsmotrel,1,45)||'</dsmotrel>
                   <dtdocmto>'||to_char(rw_crapret.dtdocmto,'DD/MM/YY')||'</dtdocmto>
                   <qtdfloat>'||to_char(rw_crapret.qtdfloat,'fm99')||'</qtdfloat>
                 </oco>');

               /* Totais */
               --Se for a ultima ocorrencia
               IF rw_crapret.nrseqoco = rw_crapret.nrtotoco THEN
                 --Abrir tag ocorrencias
                 gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</ocorrencias>');
                 --Zerar Variaveis
                 vr_qttotreg:= 0;
                 vr_vltotreg:= 0;
                 vr_vltotdes:= 0;
                 vr_vltotjur:= 0;
                 vr_vloutdeb:= 0;
                 vr_vloutcre:= 0;
                 vr_vltotpag:= 0;
                 vr_vltottar:= 0;
               END IF;
             END LOOP;

             --Totalizador final do relatorio
             vr_qtregisd:= nvl(vr_qtregrec,0) - nvl(vr_qtregicd,0);
             vr_vlregisd:= nvl(vr_vlregrec,0) - nvl(vr_vlregicd,0);

             -- Finalizar tag XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
             '<total>
                 <qtregrec>'||to_char(nvl(vr_qtregrec,0),'fm999g999g990')||'</qtregrec>
                 <qtregicd>'||to_char(nvl(vr_qtregicd,0),'fm999g999g990')||'</qtregicd>
                 <qtregisd>'||to_char(nvl(vr_qtregisd,0),'fm999g999g990')||'</qtregisd>
                 <qtregrej>'||to_char(nvl(vr_qtregrej,0),'fm999g999g990')||'</qtregrej>
                 <vlregrec>'||to_char(nvl(vr_vlregrec,0),'fm999g999g990d00')||'</vlregrec>
                 <vlregicd>'||to_char(nvl(vr_vlregicd,0),'fm999g999g990d00')||'</vlregicd>
                 <vlregisd>'||to_char(nvl(vr_vlregisd,0),'fm999g999g990d00')||'</vlregisd>
                 <vlregrej>'||to_char(nvl(vr_vlregrej,0),'fm999g999g990d00')||'</vlregrej>
               </total></analitico>');

           END LOOP; --rw_crapcre

           -- Finalizar tag XML do relatorio
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl605>',true);

           -- Efetuar solicitacao de geracao de relatorio crrl605 --
           gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper                  --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                  --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt          --> Data do movimento atual
                                       ,pr_dsxml     => vr_des_xml                   --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl605'                   --> N? base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl605.jasper'             --> Arquivo de layout do iReport
                                       ,pr_dsparams  => vr_dsparam                   --> Titulo do relat?rio
                                       ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                       ,pr_qtcoluna  => 234                          --> 234 colunas
                                       ,pr_cdrelato  => 605                          --> Codigo fixo do relatorio
                                       ,pr_sqcabrel  => 1                            --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                       ,pr_flg_impri => 'S'                          --> Chamar a impress?o (Imprim.p)
                                       ,pr_nmformul  => '234dh'                      --> Nome do formul?rio para impress?o
                                       ,pr_nrcopias  => 1                            --> N?mero de c?pias
                                       ,pr_flg_gerar => 'N'                          --> gerar PDF
                                       ,pr_des_erro  => vr_dscritic);                --> Sa?da com erro
           -- Testar se houve erro
           IF vr_dscritic IS NOT NULL THEN
             -- Gerar excecao
             RAISE vr_exc_saida;
           END IF;

           -- Liberando a mem?ria alocada pro CLOB
           dbms_lob.close(vr_des_xml);
           dbms_lob.freetemporary(vr_des_xml);
           vr_dstexto:= NULL;
         END LOOP; --rw_crapcco

         --Escrever mensagem no Log
         IF vr_rejeitad THEN
           vr_cdcritic:= 191;
         ELSE
           vr_cdcritic:= 190;
         END IF;
         --Montar Mensagem Critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ' || vr_dscritic
                                                     || ' --> ' || vr_nmarquiv);

       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_gera_relatorio_605. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END;

       --Gerar Relatorio 618
       PROCEDURE pc_gera_relatorio_618 (pr_cdcritic OUT INTEGER
                                       ,pr_dscritic OUT VARCHAR2) IS
       BEGIN
         --Inicializar variaveis erro
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;

         --Percorrer toda a tabela de memória
         vr_index_rel618:= vr_tab_rel618.FIRST;
         WHILE vr_index_rel618 IS NOT NULL LOOP

           --Primeiro registro do banco
           IF vr_index_rel618 = vr_tab_rel618.FIRST  OR
            vr_tab_rel618(vr_index_rel618).cddbanco <> vr_tab_rel618(vr_tab_rel618.PRIOR(vr_index_rel618)).cddbanco THEN

             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_des_xml, TRUE);
             dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
             vr_dstexto:= NULL;
             
             -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
             -- para evitar sobrepor arquivos de outras execuções
             IF vr_inreproc THEN
               -- Nome arquivo impressao
               vr_nmarqimp:= 'crrl618_'|| rw_crapcop.dsdircop ||'_'||
                             gene0002.fn_mask(nvl(vr_tab_rel618(vr_index_rel618).cddbanco,0),'999') || 
                           '_REP_'||GENE0002.fn_busca_time||'.lst';
             ELSE   
             --Nome arquivo Impressao
             vr_nmarqimp:= 'crrl618_'|| rw_crapcop.dsdircop ||'_'||
                           gene0002.fn_mask(nvl(vr_tab_rel618(vr_index_rel618).cddbanco,0),'999') || '.lst';
             END IF;

             --Descricao da Origem
             vr_nmorigem:= gene0002.fn_mask(rw_crapcop.cdbcoctl,'999')||' - ' ||
                           rw_crapcop.nmrescop ||' - AGENCIA: '||
                           gene0002.fn_mask(rw_crapcop.cdagectl,'9999');

             --Descricao do Destino
             vr_nmdestin:= 'COBRANCA';

             --Selecionar Bancos
             OPEN cr_crapban (pr_cdbccxlt => vr_tab_rel618(vr_index_rel618).cddbanco);
             FETCH cr_crapban INTO vr_nmdestin;
             CLOSE cr_crapban;

             -- Inicilizar as informacoes do XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl618><dados>');
           END IF;

           --Montar tag saldo contabil para arquivo XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
             '<dado>
                  <bancoage>'||vr_tab_rel618(vr_index_rel618).bancoage||'</bancoage>
                  <nrcpfcnj>'||gene0002.fn_mask(vr_tab_rel618(vr_index_rel618).nrcpfcnj,'zzzzzzzzzzzzzz9')||'</nrcpfcnj>
                  <nmsacado>'||gene0007.fn_caract_controle(substr(vr_tab_rel618(vr_index_rel618).nmsacado,1,30))||'</nmsacado>
                  <dscodbar>'||substr(vr_tab_rel618(vr_index_rel618).dscodbar,1,43)||'</dscodbar>
                  <nrdocmto>'||substr(vr_tab_rel618(vr_index_rel618).nrdocmto,1,15)||'</nrdocmto>
                  <dtvencto>'||to_char(vr_tab_rel618(vr_index_rel618).dtvencto,'DD/MM/YY')||'</dtvencto>
                  <vldocmto>'||to_char(vr_tab_rel618(vr_index_rel618).vldocmto,'fm999g999g999g990d00')||'</vldocmto>
                  <vldesaba>'||to_char(vr_tab_rel618(vr_index_rel618).vldesaba,'fm999g999g990d00')||'</vldesaba>
                  <vljurmul>'||to_char(vr_tab_rel618(vr_index_rel618).vljurmul,'fm999g999g990d00')||'</vljurmul>
                  <vlrpagto>'||to_char(vr_tab_rel618(vr_index_rel618).vlrpagto,'fm999g999g990d00')||'</vlrpagto>
                  <vlrdifer>'||to_char(vr_tab_rel618(vr_index_rel618).vlrdifer,'fm999g999g990d00')||'</vlrdifer>
                  <vldescar>'||to_char(vr_tab_rel618(vr_index_rel618).vldescar,'fm999g999g990d00')||'</vldescar>
               </dado>');
           --Ultimo registro do banco
           IF vr_index_rel618 = vr_tab_rel618.LAST OR
              vr_tab_rel618(vr_index_rel618).cddbanco <> vr_tab_rel618(vr_tab_rel618.NEXT(vr_index_rel618)).cddbanco THEN

             --Buscar relatorio RL da Cecred
             vr_caminho_rl_3:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                    ,pr_cdcooper => 3
                                                    ,pr_nmsubdir => 'rl');

             -- Finalizar tag XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</dados></crrl618>',true);

             -- Efetuar solicitacao de geracao de relatorio crrl618 --
             gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper                  --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra                  --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt          --> Data do movimento atual
                                         ,pr_dsxml     => vr_des_xml                   --> Arquivo XML de dados
                                         ,pr_dsxmlnode => '/crrl618/dados/dado'        --> No base do XML para leitura dos dados
                                         ,pr_dsjasper  => 'crrl618.jasper'             --> Arquivo de layout do iReport
                                         ,pr_dsparams  => 'PR_NMORIGEM##'||vr_nmorigem||'@@PR_NMDESTIN##'||vr_nmdestin||'@@PR_DTRELATO##'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')  --> Campo Origem e Destino no Cabecalho
                                         ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                         ,pr_qtcoluna  => 234                          --> 234 colunas
                                         ,pr_sqcabrel  => 1                            --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                         ,pr_cdrelato  => 618                          --> Codigo do Relatorio
                                         ,pr_flg_impri => 'S'                          --> Chamar a impress?o (Imprim.p)
                                         ,pr_nmformul  => '234dh'                      --> Nome do formul?rio para impress?o
                                         ,pr_nrcopias  => 1                            --> N?mero de c?pias
                                         ,pr_flg_gerar => 'N'                          --> gerar PDF
                                         ,pr_dspathcop => vr_caminho_rl_3              --> Lista sep. por ';' de diretórios a copiar o relatório
                                         ,pr_des_erro  => vr_dscritic);                --> Sa?da com erro
             -- Testar se houve erro
             IF vr_dscritic IS NOT NULL THEN
               -- Gerar excecao
               RAISE vr_exc_saida;
             END IF;

             -- Liberando a mem?ria alocada pro CLOB
             dbms_lob.close(vr_des_xml);
             dbms_lob.freetemporary(vr_des_xml);
             vr_dstexto:= NULL;
           END IF;
           --Proximo registro da tabela de memeria
           vr_index_rel618:= vr_tab_rel618.NEXT(vr_index_rel618);
         END LOOP;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_gera_relatorio_618. '||sqlerrm;
       END;

       -- Gerar Relatorio 706 - Pagto de Contrato com Boleto
       PROCEDURE pc_gera_relatorio_706 (pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT INTEGER
                                       ,pr_dscritic OUT VARCHAR2) IS
       BEGIN
         --Inicializar variaveis erro
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;

         --Percorrer toda a tabela de memória
         vr_index_rel706:= vr_tab_rel706.FIRST;
         WHILE vr_index_rel706 IS NOT NULL LOOP

           --Primeiro registro do banco
           IF vr_index_rel706 = vr_tab_rel706.FIRST THEN

             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_des_xml, TRUE);
             dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
             vr_dstexto:= NULL;
             
             -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
             -- para evitar sobrepor arquivos de outras execuções
             IF vr_inreproc THEN
               -- Nome arquivo impressao
               vr_nmarqimp:= 'crrl706_REP_'||GENE0002.fn_busca_time||'.lst';
             ELSE   
               -- Nome arquivo Impressao
             vr_nmarqimp:= 'crrl706.lst';
             END IF;
           

             --Descricao da Origem
             vr_nmorigem:= '';

             --Descricao do Destino
             vr_nmdestin:= 'CREDITO';

             -- Inicilizar as informacoes do XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl706>');
           END IF;

           --Montar tag saldo contabil para arquivo XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
             '<dados>
                  <cdagenci>'||vr_tab_rel706(vr_index_rel706).cdagenci||'</cdagenci>
                  <nrdconta>'||vr_tab_rel706(vr_index_rel706).nrdconta||'</nrdconta>
                  <nrcnvcob>'||vr_tab_rel706(vr_index_rel706).nrcnvcob||'</nrcnvcob>
                  <nrdocmto>'||vr_tab_rel706(vr_index_rel706).nrdocmto||'</nrdocmto>
                  <nrctremp>'||vr_tab_rel706(vr_index_rel706).nrctremp||'</nrctremp>
                  <tpparepr>'||CASE vr_tab_rel706(vr_index_rel706).tpparcel
                                WHEN 1 THEN 'NORMAL'
                                WHEN 2 THEN 'ATRASO'
                                WHEN 3 THEN 'PARCIAL'
                                WHEN 4 THEN 'QUITACAO' END ||'</tpparepr>
                  <dtvencto>'||to_char(vr_tab_rel706(vr_index_rel706).dtvencto,'DD/MM/YY')||'</dtvencto>
                  <vltitulo>'||to_char(vr_tab_rel706(vr_index_rel706).vltitulo,'fm999g999g999g990d00')||'</vltitulo>
                  <vldpagto>'||to_char(vr_tab_rel706(vr_index_rel706).vldpagto,'fm999g999g990d00')||'</vldpagto>
                  <dscritic>'||vr_tab_rel706(vr_index_rel706).dscritic || '</dscritic>
               </dados>');

           --Ultimo registro
           IF vr_index_rel706 = vr_tab_rel706.LAST THEN

             -- Finalizar tag XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl706>',true);

             -- Efetuar solicitacao de geracao de relatorio crrl706 --
             gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper                  --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra                  --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt          --> Data do movimento atual
                                         ,pr_dsxml     => vr_des_xml                   --> Arquivo XML de dados
                                         ,pr_dsxmlnode => '/crrl706/dados'        --> No base do XML para leitura dos dados
                                         ,pr_dsjasper  => 'crrl706.jasper'             --> Arquivo de layout do iReport
                                         ,pr_dsparams  => NULL -- 'PR_NMORIGEM##'||vr_nmorigem||'@@PR_NMDESTIN##'||vr_nmdestin||'@@PR_DTRELATO##'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')  --> Campo Origem e Destino no Cabecalho
                                         ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                         ,pr_qtcoluna  => 132                          --> 234 colunas
                                         ,pr_sqcabrel  => 1                            --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                         ,pr_cdrelato  => 706                          --> Codigo do Relatorio
                                         ,pr_flg_impri => 'S'                          --> Chamar a impress?o (Imprim.p)
                                         ,pr_nmformul  => '132col'                     --> Nome do formul?rio para impress?o
                                         ,pr_nrcopias  => 1                            --> N?mero de c?pias
                                         ,pr_flg_gerar => 'N'                          --> gerar PDF
                                         ,pr_des_erro  => vr_dscritic);                --> Saida com erro
             -- Testar se houve erro
             IF vr_dscritic IS NOT NULL THEN
               -- Gerar excecao
               RAISE vr_exc_saida;
             END IF;

             -- Liberando a mem?ria alocada pro CLOB
             dbms_lob.close(vr_des_xml);
             dbms_lob.freetemporary(vr_des_xml);
             vr_dstexto:= NULL;
           END IF;
           --Proximo registro da tabela de memeria
           vr_index_rel706:= vr_tab_rel706.NEXT(vr_index_rel706);
         END LOOP;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_gera_relatorio_706. '||sqlerrm;
       END;

       --> Procedimento para grava registro de devolucao
       PROCEDURE pc_grava_devolucao ( pr_cdcooper   IN tbcobran_devolucao.cdcooper%TYPE  --> codigo da cooperativa
                                     ,pr_dtmvtolt   IN tbcobran_devolucao.dtmvtolt%TYPE  --> data do movimento
                                     ,pr_dtmvtopr   IN tbcobran_devolucao.dtmvtolt%TYPE  --> data do próximo movimento 
                                     ,pr_nrseqarq   IN tbcobran_devolucao.nrseqarq%TYPE  --> numero sequencial do arquivo da devolucao (cob615)
                                     ,pr_dscodbar   IN tbcobran_devolucao.dscodbar%TYPE  --> codigo de barras
                                     ,pr_nrispbif   IN tbcobran_devolucao.nrispbif%TYPE  --> numero do ispb recebedora
                                     ,pr_vlliquid   IN tbcobran_devolucao.vlliquid%TYPE  --> valor de liquidacao do titulo
                                     ,pr_dtocorre   IN tbcobran_devolucao.dtocorre%TYPE  --> data da ocorrencia da devolucao
                                     ,pr_nrdconta   IN tbcobran_devolucao.nrdconta%TYPE  --> numero da conta do cooperado
                                     ,pr_nrcnvcob   IN tbcobran_devolucao.nrcnvcob%TYPE  --> numero do convenio de cobranca do cooperado
                                     ,pr_nrdocmto   IN tbcobran_devolucao.nrdocmto%TYPE  --> numero do boleto de cobranca
                                     ,pr_cdmotdev   IN tbcobran_devolucao.cdmotdev%TYPE  --> codigo do motivo da devolucao
                                     ,pr_tpcaptur   IN tbcobran_devolucao.tpcaptura%TYPE  --> tipo de captura (cob615)
                                     ,pr_tpdocmto   IN tbcobran_devolucao.tpdocmto%TYPE  --> codigo do tipo de documento (cob615)
                                     ,pr_cdagerem   IN tbcobran_devolucao.cdagerem%TYPE  --> codigo da agencia do remetente (cob615)
                                     ,pr_dslinarq   IN tbcobran_devolucao.dslinarq%TYPE  --> 
                                     ,pr_dscritic  OUT VARCHAR2 
                                     )IS
       BEGIN
         
       
         INSERT INTO tbcobran_devolucao
                     (cdcooper, 
                      dtmvtolt, 
                      nrseqarq, 
                      dscodbar, 
                      nrispbif, 
                      vlliquid, 
                      dtocorre, 
                      nrdconta, 
                      nrcnvcob, 
                      nrdocmto, 
                      cdmotdev, 
                      tpcaptura, 
                      tpdocmto, 
                      cdagerem, 
                      dslinarq,
                      flgenvia) 
               VALUES(pr_cdcooper,      --> cdcooper
                      pr_dtmvtolt,      --> dtmvtolt
                      pr_nrseqarq,      --> nrseqarq
                      pr_dscodbar,      --> dscodbar
                      pr_nrispbif,      --> nrispbif
                      pr_vlliquid,      --> vlliquid
                      pr_dtocorre,      --> dtocorre
                      pr_nrdconta,      --> nrdconta
                      pr_nrcnvcob,      --> nrcnvcob
                      pr_nrdocmto,      --> nrdocmto
                      pr_cdmotdev,      --> cdmotdev
                      pr_tpcaptur,      --> tpcaptur
                      pr_tpdocmto,      --> tpdocmto
                      pr_cdagerem,      --> cdagerem
                      pr_dslinarq,      --> dslinarq
                      0);               --> flgenvia 
       
         INSERT INTO gncpdvc(cdcooper
                            ,dtmvtolt
                            ,nmarquiv
                            ,nrseqarq
                            ,dscodbar
                            ,nrispbif
                            ,vlliquid
                            ,dtocorre
                            ,nrdconta
                            ,nrcnvcob
                            ,nrdocmto
                            ,cdmotdev
                            ,tpcaptura
                            ,tpdocmto
                            ,cdagerem
                            ,flgconci
                            ,flgpcctl
                            ,dslinarq)
                     VALUES (pr_cdcooper -- cdcooper
                            ,pr_dtmvtopr -- dtmvtolt  -> PRÓXIMO MOVIMENTO <-
                            ,' '         -- nmarquiv
                            ,pr_nrseqarq -- nrseqarq
                            ,pr_dscodbar -- dscodbar
                            ,pr_nrispbif -- nrispbif
                            ,pr_vlliquid -- vlliquid
                            ,pr_dtocorre -- dtocorre
                            ,pr_nrdconta -- nrdconta
                            ,pr_nrcnvcob -- nrcnvcob
                            ,pr_nrdocmto -- nrdocmto
                            ,pr_cdmotdev -- cdmotdev
                            ,pr_tpcaptur -- tpcaptura
                            ,pr_tpdocmto -- tpdocmto
                            ,pr_cdagerem -- cdagerem
                            ,0           -- flgconci
                            ,0           -- flgpcctl
                            ,NULL);      -- dslinarq
         
       EXCEPTION
         WHEN OTHERS THEN
           pr_dscritic := 'Nao foi possivel inserir devolucao: '||SQLERRM;
       END pc_grava_devolucao;
       
       --> Procedimento para geração do arquivo de devolução DVC605
       PROCEDURE pc_gerar_arq_devolucao( pr_cdcooper  IN crapcop.cdcooper%TYPE
                                        ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                        ,pr_cdcritic OUT INTEGER
                                        ,pr_dscritic OUT VARCHAR2) IS
       
         ---------> CURSORES <---------
         --> Listar devoluoes da coop
         CURSOR cr_devolucao (pr_dtmvtolt crapdat.dtmvtolt%TYPE )IS
           SELECT ban2.nrispbif nrispbif_cop,
                  cop.cdagectl,
                  dev.dtocorre,
                  dev.nrispbif,
                  ban.cdbccxlt,
                  dev.cdagerem,
                  dev.dscodbar,
                  dev.vlliquid,
                  dev.cdmotdev,
                  dev.tpcaptura,
                  dev.tpdocmto,
                  dev.nrseqarq,
                  dev.dslinarq,
                  row_number()        over (PARTITION BY cop.cdagectl 
                                            ORDER BY cop.cdagectl) nrseqrec,
                  COUNT(dev.cdcooper) over (PARTITION BY cop.cdagectl) nrqtdrec
             FROM tbcobran_devolucao dev,
                  crapban ban,
                  crapban ban2,
                  crapcop cop
            WHERE dev.cdcooper     = pr_cdcooper
              AND dev.dtmvtolt     = pr_dtmvtolt
              AND cop.cdcooper     = dev.cdcooper
              AND ban2.cdbccxlt    = cop.cdbcoctl 
              AND ban.nrispbif (+) = dev.nrispbif 
              AND ban.cdbccxlt (+) = decode(dev.nrispbif,0,1,ban.cdbccxlt(+))
            ORDER BY cop.cdagectl ASC;
              
         ---------> VARIAVEIS <----------
         vr_dsmotdev VARCHAR2(4000);  
         vr_cddomes  VARCHAR2(10); 
         vr_dsdlinha VARCHAR2(200);   
         vr_dschave_troca VARCHAR2(160);
         vr_nrseqlin INTEGER;
         vr_vltotarq NUMBER;
         vr_dsdircop_arq VARCHAR2(100);
         vr_dsdirmic_arq VARCHAR2(100);
         
         vr_dslobdev      CLOB;
         vr_dsbufdev      VARCHAR2(32700);
         
       
       BEGIN
       
         --> Definir sigra do mes
         vr_cddomes := replace(to_char(rw_crapdat.dtmvtopr,'MM'),'0','');
         IF vr_cddomes >= 10 THEN
           CASE vr_cddomes
             WHEN 10 THEN            
               vr_cddomes := 'O';
             WHEN 11 THEN 
               vr_cddomes := 'N';
             WHEN 12 THEN 
               vr_cddomes := 'D';    
             ELSE
               NULL;
           END CASE;     
         END IF; 
       
         --> Listar devoluoes da coop
         FOR rw_devolucao IN cr_devolucao (pr_dtmvtolt => pr_dtmvtolt ) LOOP
         
           IF rw_devolucao.nrseqrec = 1 THEN
             
             vr_nrseqlin := 1;
             vr_vltotarq := 0;
             
             --> Definir nome do arquivo
             vr_nmarquiv:= '2' ||                                    --> arquivo de cobrança
                           to_char(rw_devolucao.cdagectl,'fm0000')|| --> Agencia
                           vr_cddomes ||                             --> código do mês
                           to_char(rw_crapdat.dtmvtopr,'DD') ||                 --> número do dia do movimento
                           '.DVS';

             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_dslobdev, TRUE);
             dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
             vr_dsbufdev := NULL;
             
             BEGIN 
               --MONTAR HEADER
               vr_dsdlinha := lpad('0',47,'0')                || -->  1 001-047   X(047)  Controle do header 
                              'DVC605'                        || -->  2 048-053   X(006)  Nome do arquivo 
                              '0000001'                       || -->  3 054-060   9(007)  Versão do arquivo
                              lpad(' ',4,' ')                 || -->  4 061-064   X(004)  Filler - Preencher com brancos 
                              '7'                             || -->  5 065-065   9(001)  Indicador de remessa
                              to_char(rw_crapdat.dtmvtopr,'RRRRMMDD') || -->  6 066-073   9(008)  Data do movimento 
                              lpad(' ',58,' ')                || -->  7 074-131   X(058)  Filler -Preencher com brancos 
                              to_char(rw_devolucao.nrispbif_cop,
                                        'fm00000000')         || -->  8 132-139   9(008)  ISPB IF remetente  
                              lpad(' ',11,' ')                || -->  9 140-150   X(011)  Filler - Preencher com brancos 
                              to_char(vr_nrseqlin,               --> 10 151-160   9(010)  Sequencial de arquivo Número sequencial do registro no arquivo, iniciando em 1 no 
                                        'fm0000000000') || chr(10);                                  --> Header, com evolução de +1 a cada novo registro, inclusive o Trailer ;
               
               -- Inicilizar as informacoes do XML
               gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,vr_dsdlinha);
             EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao montar Header do arquivo de devolucao: '||SQLERRM;
                 RAISE vr_exc_saida; 
             END;  
           END IF;
           
           --> Incrementar seq
           vr_nrseqlin := vr_nrseqlin + 1;
           vr_vltotarq := vr_vltotarq + rw_devolucao.vlliquid;
           
           BEGIN 
           
             vr_dschave_troca := substr(rw_devolucao.dslinarq,57,57);
           
             --MONTAR LINHA DETALHE
             vr_dsdlinha := rw_devolucao.dscodbar           || -->  1  001-044  X(044)  Código de barras do documento 
                            lpad(' ', 2,' ')                || -->  2  045-046  X(002) Filler - Preencher com brancos 
                            '   '                           || -->  3  047-049  X(003) Filler Preenchimento livre 
                            rw_devolucao.tpcaptura          || -->  4  050-050  9(001) Tipo de captura informado na troca: 
                                                                                      --> 1 (para Guichê de Caixa) 
                                                                                      --> 2 (para Terminal de Auto Atendimento) 
                                                                                      --> 3 (para Internet – home/office banking) 
                                                                                      --> 5 (para Correspondente) 
                                                                                      --> 6 (para Telefone) 
                                                                                      --> 7 (para Arquivo Eletrônico) 
                            to_char(rw_devolucao.cdmotdev,'fm00')  || -->  5  051-052  9(002) Motivo de devolução
                            lpad(' ', 4,' ')                       || -->  6  053-056  X(004) Filler Preencher com branco 
                            
                            vr_dschave_troca  || --> chave para troca extraida da linha original, contem campos abaixo
                                    -->  7  057-060  9(004)  Número da agência remetentedo documento na troca 
                                    -->  8  061-067  9(007) Número atribuído ao lote que contémo documento na troca 
                                    -->  9  068-070  9(003) Número sequencial do documento no lote da troca 
                                    --> 10  071-078  9(008)  Data do movimento de troca no formato “AAAAMMDD” 
                                    --> 11  079-084  X(006) Centro processador Informação para controle do remetente 
                                    --> 12  085-096  9(012) Valor líquido do título
                                    --> 13  097-103  9(007) Número da versão do arquivodo remetente da troca 
                                    --> 14  104-113  9(010) Número sequencial do registro no arquivo do remetente da troca
                            lpad(' ',18,' ')                                || --> 15  114-131  X(018) Filler - Preencher com brancos 
                            to_char(rw_devolucao.nrispbif,'fm00000000')     || --> 16  132-139  9(008)  Código ISPB do participante recebedor 
                            to_char(rw_devolucao.nrispbif_cop,'fm00000000') || --> 17  140-147  9(008)  Código ISPB do participante favorecido 
                            to_char(41,'fm000')                             || --> 18  148-150  9(003) Tipo de documento 
                            to_char(vr_nrseqlin,'fm0000000000')             || --> 19  151-160  9(010) Sequencial de arquivo
                            chr(10);
                                                   
             
             -- incluir linha detalhe
             gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,vr_dsdlinha);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao montar linha detalhe do arquivo de devolucao: '||SQLERRM;
               RAISE vr_exc_saida; 
           END; 
           
           --> Verificar se é o ultimo registro
           IF rw_devolucao.nrseqrec = rw_devolucao.nrqtdrec THEN
             BEGIN 
               vr_nrseqlin := vr_nrseqlin + 1;
             
               --MONTAR TRAILER
               vr_dsdlinha := lpad('9',47,'9')                || -->  1 001-047   X(047)  Controle do header 
                              'DVC605'                        || -->  2 048-053   X(006)  Nome do arquivo 
                              '0000001'                       || -->  3 054-060   9(007)  Versão do arquivo
                              lpad(' ',4,' ')                 || -->  4 061-064   X(004)  Filler - Preencher com brancos 
                              '7'                             || -->  5 065-065   9(001)  Indicador de remessa
                              to_char(rw_crapdat.dtmvtopr,'RRRRMMDD') || -->  6 066-073   9(008)  Data do movimento 
                              to_char(vr_vltotarq * 100,
                                       'fm00000000000000000') || --> 7 074-090 9(017) Somatório do valor dos detalhes do arquivo (*) 
                              lpad(' ',41,' ')                || --> 8  091-131  X(041) Filler - Preencher com brancos
                              to_char(rw_devolucao.nrispbif_cop,
                                        'fm00000000')         || -->  9  132-139  9(008)  ISPB IF remetente
                              lpad(' ',11,' ')                || --> 10 140-150   X(011)  Filler - Preencher com brancos 
                              to_char(vr_nrseqlin,                
                                        'fm0000000000')       || --> 11 151-160   9(010)  Sequencial de arquivo 
                              chr(10);
                                                                                         
                                                                                         
               -- Incluir linha trailer e descarregar buffer
               gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,vr_dsdlinha,TRUE);
             EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao montar Trailer do arquivo de devolucao: '||SQLERRM;
                 RAISE vr_exc_saida; 
             END;
             
             vr_dsdircop_arq := gene0001.fn_diretorio( pr_tpdireto => 'C', 
                                                       pr_cdcooper => pr_cdcooper, 
                                                       pr_nmsubdir => '/arq');
             
             vr_dsdirmic_arq := gene0001.fn_diretorio( pr_tpdireto => 'M', 
                                                       pr_cdcooper => pr_cdcooper, 
                                                       pr_nmsubdir => '/abbc');
                                                       
             -- Geracao do arquivo
             GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper              --> Cooperativa conectada
                                                ,pr_cdprogra  => vr_cdprogra              --> Programa chamador
                                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt      --> Data do movimento atual
                                                ,pr_dsxml     => vr_dslobdev               --> Arquivo XML de dados
                                                ,pr_dsarqsaid => vr_dsdircop_arq || '/' || vr_nmarquiv    --> Arquivo final com o path
                                                ,pr_cdrelato  => NULL                     --> Código fixo para o relatório
                                                ,pr_flg_gerar => 'S'                      --> Apenas submeter
                                                ,pr_dspathcop => vr_dsdirmic_arq
                                                ,pr_fldoscop  => 'S'
                                                ,pr_flappend  => 'N'                      --> Indica que a solicitação irá incrementar o arquivo
                                                ,pr_des_erro  => vr_dscritic);            --> Saída com erro



             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_dslobdev);
             dbms_lob.freetemporary(vr_dslobdev);
           
           END IF;
           
         END LOOP;
              
       EXCEPTION
         WHEN vr_exc_saida THEN
           pr_dscritic := vr_dscritic;
           pr_cdcritic := vr_cdcritic;
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro ao gerar arquivo de devolucao: '||sqlerrm;  
           
       END pc_gerar_arq_devolucao;

       --Procedimento para gravar dados na tabela memoria cratrej
       PROCEDURE pc_gera_cratrej (pr_craprej IN craprej%ROWTYPE) IS
       BEGIN
         DECLARE
           vr_index_cratrej VARCHAR2(20);
         BEGIN
           --Montar Indice
           vr_index_cratrej:= lpad(pr_craprej.nrseqdig,10,'0')||
                              lpad(vr_tab_cratrej.count+1,10,'0') ;
           --Gravar dados na tabela memoria
           vr_tab_cratrej(vr_index_cratrej).dtmvtolt:= pr_craprej.dtmvtolt;
           vr_tab_cratrej(vr_index_cratrej).cdagenci:= pr_craprej.cdagenci;
           vr_tab_cratrej(vr_index_cratrej).vllanmto:= pr_craprej.vllanmto;
           vr_tab_cratrej(vr_index_cratrej).nrseqdig:= pr_craprej.nrseqdig;
           vr_tab_cratrej(vr_index_cratrej).cdpesqbb:= pr_craprej.cdpesqbb;
           vr_tab_cratrej(vr_index_cratrej).cdcritic:= pr_craprej.cdcritic;
           vr_tab_cratrej(vr_index_cratrej).cdcooper:= pr_craprej.cdcooper;
           vr_tab_cratrej(vr_index_cratrej).nrdconta:= pr_craprej.nrdconta;
           vr_tab_cratrej(vr_index_cratrej).cdbccxlt:= pr_craprej.cdbccxlt;
           vr_tab_cratrej(vr_index_cratrej).nrdocmto:= pr_craprej.nrdocmto;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao inserir na tabela de memoria cratrej. '||SQLERRM;
             RAISE vr_exc_saida;
         END;
       END pc_gera_cratrej;


       --Procedimento para Integrar Cecred
       PROCEDURE pc_integra_cecred (pr_cdcritic OUT INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
         --Cursores Locais
         CURSOR cr_crabcco (pr_cdcooper IN crapcop.cdcooper%type
                           ,pr_nrconven IN crapcco.nrconven%type) IS
           SELECT crapcco.cdcooper
                 ,crapcco.nrconven
                 ,crapcco.nrdctabb
                 ,crapcco.cddbanco
                 ,Count(*) OVER (PARTITION BY crapcco.nrconven) qtdreg
           FROM crapcco
           WHERE crapcco.cdcooper <> pr_cdcooper
           AND   crapcco.nrconven = pr_nrconven;
         rw_crabcco cr_crabcco%ROWTYPE;

         --Selecionar Convenio
         CURSOR cr_crabcco2 (pr_cdcooper IN crapcop.cdcooper%type
                            ,pr_nrconven IN crapcco.nrconven%type) IS
           SELECT crapcco.cdcooper
                 ,crapcco.nrconven
                 ,crapcco.nrdctabb
                 ,crapcco.cddbanco
                 ,Count(*) OVER (PARTITION BY crapcco.nrconven) qtdreg
           FROM crapcco
           WHERE crapcco.cdcooper = pr_cdcooper
           AND   crapcco.nrconven = pr_nrconven;

         --Selecionar Transferencias de Contas
         CURSOR cr_craptco_ant (pr_cdcooper IN craptco.cdcooper%type
                               ,pr_cdcopant IN craptco.cdcopant%type
                               ,pr_nrctaant IN craptco.nrctaant%type
                               ,pr_tpctatrf IN craptco.tpctatrf%type
                               ,pr_flgativo IN craptco.flgativo%type) IS
           SELECT craptco.nrdconta
           FROM craptco
           WHERE craptco.cdcooper = pr_cdcooper
           AND   craptco.cdcopant = pr_cdcopant
           AND   craptco.nrctaant = pr_nrctaant
           AND   craptco.tpctatrf = pr_tpctatrf
           AND   craptco.flgativo = pr_flgativo;
         rw_craptco cr_craptco_ant%ROWTYPE;

         -- verificar se o boleto foi processado na singular
         CURSOR cr_ret_sing (pr_cdcooper IN crapret.cdcooper%TYPE
                            ,pr_nrdconta IN crapret.nrdconta%TYPE
                            ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                            ,pr_nrdocmto IN crapret.nrdocmto%TYPE
                            ,pr_dtocorre IN crapret.dtocorre%TYPE) IS
           SELECT 1
             FROM crapret ret
            WHERE ret.cdcooper = pr_cdcooper
              AND ret.nrdconta = pr_nrdconta
              AND ret.nrcnvcob = pr_nrcnvcob
              AND ret.nrdocmto = pr_nrdocmto
              AND ret.dtocorre = pr_dtocorre
              AND ret.cdocorre IN (6,17,76,77);
         
         --> Buscar codigo do banco
         CURSOR cr_crapban (pr_nrispbif crapban.nrispbif%TYPE)IS
           SELECT ban.cdbccxlt
             FROM crapban ban
            WHERE ban.nrispbif = pr_nrispbif; 
         
         vr_flgproc_sing INTEGER;

         --Variaveis Locais
         vr_flgtitcp BOOLEAN;
         vr_dsmotivo VARCHAR2(100);
         vr_vldescto NUMBER;
         vr_vlabatim NUMBER;
         vr_vlrjuros NUMBER;
         vr_vlrmulta NUMBER;
         vr_vlfatura NUMBER;
         vr_nrretcoo VARCHAR2(100);
         vr_flgrejei BOOLEAN;
         vr_flgvenci BOOLEAN;
         vr_lgdetail BOOLEAN;
         vr_flgerro  BOOLEAN;
         vr_cdbanpag INTEGER;
         vr_cdagepag INTEGER;
         vr_liqaposb BOOLEAN;
         vr_crapass  BOOLEAN;
         vr_crapsab  BOOLEAN;
         vr_crapceb  BOOLEAN;
         vr_email_compefora BOOLEAN := FALSE;
         vr_email_proc_cred VARCHAR2(1000);
         vr_dstextab craptab.dstextab%type;
         --Excecoes
         vr_exc_proximo EXCEPTION;
         vr_exc_sair    EXCEPTION;
       BEGIN
         --Inicializar variaveis erro
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;
         --Limpar tabela memoria relatorio
--         vr_tab_relat_cecred.DELETE;
         --Inicializar contador
         vr_contador:= 0;

         /* Remove os arquivos ".q" caso existam */
         vr_comando:= 'rm '||vr_caminho_integra||'/'||replace(vr_nmarqret,'%','*')||'.q 2> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
         --Se ocorreu erro dar RAISE
         /*IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
         END IF;*/ -- Nao dar erro se os arquivos nao existem

         --Listar arquivos no diretorio
         gene0001.pc_lista_arquivos (pr_path     => vr_caminho_integra
                                    ,pr_pesq     => vr_nmarqret
                                    ,pr_listarq  => vr_listadir
                                    ,pr_des_erro => vr_dscritic);
         --Se ocorreu erro
         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;

         --Montar vetor com nomes dos arquivos
         vr_tab_nmarqtel:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

         --Se nao encontrou arquivos
         IF vr_tab_nmarqtel.COUNT <= 0 THEN
           -- Montar mensagem de critica
           vr_cdcritic:= 182;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||vr_dscritic
                                                       || ' - Arquivo: integra/'||vr_nmarqret );
           --Levantar Excecao pois nao tem arquivo para processar
           RAISE vr_exc_final;
         END IF;
         /*  Fim da verificacao se deve executar  */

         -- Se for execução pela COMPEFORA, deve criticar caso seja encontrado 
         -- mais de um arquivo para processamento, de forma a evitar que um arquivo 
         -- normal e um REPROC sejam reprocessados juntos  ( Renato Darosci - Supero)
         IF pr_nmtelant = 'COMPEFORA' THEN
           -- Se encontrou mais de um arquivos
           IF vr_tab_nmarqtel.COUNT > 1 THEN
             -- Montar mensagem de critica
             vr_cdcritic := 0;
             vr_dscritic := 'Mais de um arquivo encontrado para processamento.';
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_nmarqret );
             --Levantar excecao pois nesse caso deveria ter apenas um arquivo para processar
             RAISE vr_exc_final;
           END IF;
         END IF;
         
         -- Buscar parametro de valor mínimo
         vr_dstextab := TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper,
                         pr_nmsistem => 'CRED',
                         pr_tptabela => 'GENERI',
                         pr_cdempres => 0,
                         pr_cdacesso => 'VLRMINCAC',
                         pr_tpregist => 0);
         --Se nao encontrou
         IF vr_dstextab IS NULL THEN
           vr_vlrmincac := 0;
         ELSE
           vr_vlrmincac := to_number(vr_dstextab) / 100 ;
         END IF;

         --Percorrer todos os arquivos
         FOR idx IN 1..vr_tab_nmarqtel.COUNT LOOP

           --Inicializar variaveis
           vr_lgdetail:= FALSE;
           vr_cdcritic:= 0;
           vr_inreproc:= FALSE;
           
           /*  REMOVIDO PORQUE NÃO ESTAVA VALIDANDO DA FORMA CORRETA, POIS O "TAIL -2" CONSIDERAVA A LINHA ERRADA */
           /* Verificar se o arquivo esta completo. A ultima linha do arquivo deve conter o chr(26) */
           /*vr_comando:= 'tail -2 '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx);

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_setlinha);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
             RAISE vr_exc_saida_2;
           END IF;
           --Verificar linha controle
           IF SUBSTR(vr_setlinha,01,10) <> '9999999999' THEN
             --Codigo erro
             vr_cdcritic:= 258;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
             --Zerar variavel critica
             vr_cdcritic:= 0;
           END IF;*/

           /* Verificar o Header */
           -- Comando para listar a primeira linha do arquivo
           vr_comando:= 'head -1 ' ||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx);

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_setlinha);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
             RAISE vr_exc_saida_2;
           END IF;

           --Montar Tipo Cobranca
           vr_dstipcob:= SUBSTR(vr_setlinha,48,6);
           --Montar Data Arquivo
           vr_dtleiaux:= SUBSTR(vr_setlinha,66,8);

           /* Verifica a primeira linha do arquivo importado */
           IF SUBSTR(vr_setlinha,1,10) <> '0000000000'  THEN
             vr_cdcritic:= 468;
           ELSIF vr_dstipcob <> 'COB615' THEN
             vr_cdcritic:= 181;
           ELSIF vr_dtleiaux <> vr_dtleiarq THEN
             vr_cdcritic:= 789;
           END IF;

           --Se ocorreu algum erro na validacao
           IF vr_cdcritic <> 0 THEN
             --Buscar descricao da critica
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
             --Zerar variavel critica
             vr_cdcritic:= 0;
             --Ir para proximo arquivo
             CONTINUE;
           END IF;

           -- Verificar se o arquivo é um REPROC  (Renato Darosci - 11/10/2016)
           IF TRIM(SUBSTR(vr_setlinha,99,3)) = 'REP' THEN
             -- Indica que o arquivo é de reprocessamento
             vr_inreproc := TRUE;
           END IF;

           --Escrever mensagem de integracao no log
           vr_cdcritic:= 219;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
           --Zerar variavel critica
           vr_cdcritic:= 0;

           /* Nao ocorreu erro nas validacoes, abrir o arquivo e processar as linhas */

           --Abrir o arquivo de dados
           gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_integra  --> Diretorio do arquivo
                                   ,pr_nmarquiv => vr_tab_nmarqtel(idx) --> Nome do arquivo
                                   ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                   ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                   ,pr_des_erro => vr_dscritic);  --> Erro
           IF vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida_2;
           ELSE
             BEGIN
               -- Ler a primeira linha. A mesma deve ser ignorada
               gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto lido
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 --Chegou ao final arquivo, sair do loop
                 EXIT;
               WHEN OTHERS THEN
                 vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
                 RAISE vr_exc_saida_2;
             END;
           END IF;

           vr_tab_lcm_consolidada.delete;

           --Criar savepoint para rollback
           -- SAVEPOINT save_trans;
           --Percorrer todas as linhas do arquivo
           LOOP
             BEGIN
               BEGIN
                 -- Le os dados do arquivo e coloca na variavel vr_setlinha
                 gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto lido
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   --Chegou ao final arquivo, sair do loop
                   EXIT;
                 WHEN OTHERS THEN
                   vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
                   RAISE vr_exc_sair;
               END;

               /* Trailer do lote do arquivo - Quanto encontrar a sequencia 
                  especifica, deve ignorar a linha ( Renato Darosci - 11/10/2016) */
               IF SUBSTR(vr_setlinha,1,31) = '      9999999999999999999999999' THEN
                 CONTINUE; -- Passa para o processamento da Próxima linha do arquivo
               END IF;
               
               /* Trailer - Se encontrar essa seq., terminou o arquivo */
               IF SUBSTR(vr_setlinha,1,10) = '9999999999' THEN
                 EXIT;
               END IF;

               --Atribuir variaveis do registro lido
               BEGIN
                 vr_flgerro:= FALSE;
                 vr_lgdetail:= TRUE;
                 vr_dscodbar_ori := SUBSTR(vr_setlinha,1,44);

                 vr_dtmvtolt:= TO_DATE(TRIM(SUBSTR(vr_setlinha,71,8)),'YYYYMMDD');
                 vr_vlliquid:= TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100;
                 vr_nrcnvcob:= TO_NUMBER(TRIM(SUBSTR(vr_setlinha,20,6)));
                 vr_nrdconta:= TO_NUMBER(TRIM(SUBSTR(vr_setlinha,26,8)));
                 vr_nrdocmto:= TO_NUMBER(TRIM(SUBSTR(vr_setlinha,34,9)));
                 vr_liqaposb:= FALSE;
                 vr_vltitulo:= to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100;
                 
                 -- Cooperado importou o boleto corretamente e imprimiu atraves do software proprio
                 -- porém na impressão ele utilizou o numero da conta sem o digito verificador
                 -- e todos os pagamentos estao sendo rejeitados
                 -- Chamado 650122
                 IF pr_cdcooper = 10     AND   -- Credicomin
                    vr_nrdconta = 5814   AND   -- Numero da Conta sem o digito (utilizado pelo cooperado na impressao)
                    vr_nrcnvcob = 109061 THEN  -- Convenio Impresso pelo Software
                   -- Ajustar numero da conta para o cooperado
                   vr_nrdconta := 58149;
                 END IF;
                 
                 --ISPB da recebedora
                 vr_nrispbif_rec := SUBSTR(vr_setlinha,132,8);
                 
                 --ISPB da favorecida
                 vr_nrispbif_fav := SUBSTR(vr_setlinha,140,8);
                 
                 vr_nrseqarq  := TO_NUMBER(trim(SUBSTR(vr_setlinha,151,10)));
                 vr_tpcaptur  := to_number(trim(SUBSTR(vr_setlinha, 50, 1)));
                 vr_tpdocmto  := to_number(trim(SUBSTR(vr_setlinha,148, 3)));
                 vr_cdagepag  := to_number(trim(SUBSTR(vr_setlinha, 57, 4))); 
                 
                 
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_flgerro:= TRUE;
               END;

               --> Buscar codigo do banco recebedor
               vr_cdbanpag := NULL;
               OPEN cr_crapban(pr_nrispbif => vr_nrispbif_rec);
               FETCH cr_crapban INTO vr_cdbanpag;
               CLOSE cr_crapban;
                              
               /* Quando cecred validar se o título e de uma singular
                caso contrario cria temp-table do relatorio de titulos rejeitados */
               IF pr_cdcooper = 3 THEN
                 --Se ocorreu erro
                 IF vr_flgerro THEN
                   --Marcar como rejeitado
                   vr_flgrejei:= TRUE;
                   --Escrever mensagem de integracao no log
                   vr_cdcritic:= 843;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   -- Envio centralizado de log de erro
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                             ,pr_ind_tipo_log => 2 -- Erro tratato
                                             ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                             ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '||vr_dscritic
                                                           || ' - Linha: '|| SUBSTR(vr_setlinha,151,10)
                                                           || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx));

                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,3              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,1              /* processou na central */
                      ,vr_cdcritic    /* integrado c/ erro */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                   --Proxima Linha Arquivo
                   RAISE vr_exc_proximo;
                 END IF; --vr_flgerro
                 /* verifica se é de um convenio na cooperativa singular */
                 vr_flgtitcp:= FALSE;
                 FOR rw_crapcop_lista IN cr_crapcop_lista LOOP
                   --Montar Indice para acesso tabela memoria convenio
                   vr_index_crapcco:= lpad(rw_crapcop_lista.cdcooper,10,'0')||
                                      lpad(vr_nrcnvcob,10,'0');
                   vr_flgtitcp:= vr_tab_crapcco.EXISTS(vr_index_crapcco);
                   --Sair do loop quando encontrar
                   IF vr_flgtitcp THEN
                     EXIT;
                   END IF;
                 END LOOP;
                 --Se nao encontrou
                 IF NOT vr_flgtitcp THEN
                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,3              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,1              /* processou na central */
                      ,796            /* integrado c/ erro */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                                        
                   --> Gerar Devolucao
                   vr_cdmotdev := 53; --> 53 - Apresentação indevida
                     
                   --> Procedimento para grava registro de devolucao
                   pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                       ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                       ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                       ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                       ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                       ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                       ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                       ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                       ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                       ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                       ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                       ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                       ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                       ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                       ,pr_dslinarq   => vr_setlinha
                                       ,pr_dscritic   => vr_dscritic);
                                         
                   IF TRIM(vr_dscritic) IS NOT NULL THEN
                         RAISE vr_exc_sair;
                 END IF;

                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                   
                   --Marcar como rejeitado
                   vr_flgrejei:= TRUE;

                 END IF;
               END IF; --pr_cdcooper = 3
               --Se ocorreu erro na conversao de alguma informacao
               IF vr_flgerro THEN
                 --Proxima linha
                 RAISE vr_exc_proximo;
               END IF;

               /**************************************************************/
               /*************TRATAMENTO P/ COBRANCA REGISTRADA****************/
               vr_index_crapcco:= lpad(rw_crapcop.cdcooper,10,'0')||
                                  lpad(vr_nrcnvcob,10,'0');
               --Se nao existir convenio ignora linha
               IF NOT vr_tab_crapcco.EXISTS(vr_index_crapcco) THEN
                 --Proxima linha
                 RAISE vr_exc_proximo;
               END IF;

               --Verificar se foi migrado
               IF vr_tab_crapcco(vr_index_crapcco).cddbanco = rw_crapcop.cdbcoctl  THEN
                 /* Se for Viacredi, verificar se eh cooperado migrado */
                 --Verificar se eh uma conta migrada
                 IF vr_tab_craptco.EXISTS(vr_nrdconta) THEN
                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                   
                   -- verificar se o convenio do cooperado migrado possui convenio de cobranca
                   -- na cooperativa destino
                   OPEN cr_crapceb(pr_cdcooper => vr_tab_craptco(vr_nrdconta).cdcooper
                                  ,pr_nrdconta => vr_tab_craptco(vr_nrdconta).nrdconta
                                  ,pr_nrconven => vr_nrcnvcob);
                   FETCH cr_crapceb INTO rw_crapceb;
                   --Indicar se encontrou ou nao
                   vr_crapceb := cr_crapceb%FOUND;
                   --Fechar Cursor
                   CLOSE cr_crapceb;
                   
                   IF vr_crapceb = TRUE THEN                                                          
                   --Proxima linha
                   RAISE vr_exc_proximo;
                   ELSE

                     vr_flgrejei:= TRUE;

                     --Escrever crítica no relatório
                     vr_cdcritic:= 966;

                     /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                     BEGIN
                       INSERT INTO gncptit
                        (gncptit.cdcooper
                        ,gncptit.cdagenci
                        ,gncptit.dtmvtolt
                        ,gncptit.dtliquid
                        ,gncptit.cdbandst
                        ,gncptit.cddmoeda
                        ,gncptit.nrdvcdbr
                        ,gncptit.dscodbar
                        ,gncptit.tpcaptur
                        ,gncptit.cdagectl
                        ,gncptit.nrdolote
                        ,gncptit.nrseqdig
                        ,gncptit.vldpagto
                        ,gncptit.tpdocmto
                        ,gncptit.nrseqarq
                        ,gncptit.nmarquiv
                        ,gncptit.cdoperad
                        ,gncptit.hrtransa
                        ,gncptit.vltitulo
                        ,gncptit.cdtipreg
                        ,gncptit.flgconci
                        ,gncptit.flgpcctl
                        ,gncptit.cdcritic
                        ,gncptit.cdmotdev
                        ,gncptit.cdfatven
                        ,gncptit.nrispbds)
                       VALUES
                        (pr_cdcooper
                        ,0
                        ,vr_dtmvtolt
                        ,rw_crapdat.dtmvtolt
                        ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                        ,SUBSTR(vr_setlinha,01,44)
                        ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                        ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                        ,vr_tab_nmarqtel(idx)
                        ,vr_cdoperad
                        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                        ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                        ,3              /* Sua Remessa - Erro */
                        ,1              /* registro conciliado */
                        ,0              /* processou na central */
                        ,vr_cdcritic    /* integrado c/ erro */
                        ,0
                        ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                        ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_cdcritic:= 0;
                         vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                         --Levantar Excecao
                         RAISE vr_exc_sair;
                     END;
                     /* create craprej */
                     BEGIN
                       INSERT INTO craprej
                         (craprej.dtmvtolt
                         ,craprej.cdagenci
                         ,craprej.vllanmto
                         ,craprej.nrseqdig
                         ,craprej.cdpesqbb
                         ,craprej.cdcritic
                         ,craprej.cdcooper
                         ,craprej.nrdconta
                         ,craprej.cdbccxlt
                         ,craprej.nrdocmto)
                       VALUES
                         (rw_crapdat.dtmvtolt
                         ,vr_cdagepag
                         ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                         ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                         ,vr_setlinha
                         ,vr_cdcritic
                         ,pr_cdcooper
                         ,vr_nrdconta
                         ,vr_cdbanpag
                         ,vr_nrdocmto)
                       RETURNING
                          craprej.dtmvtolt
                         ,craprej.cdagenci
                         ,craprej.vllanmto
                         ,craprej.nrseqdig
                         ,craprej.cdpesqbb
                         ,craprej.cdcritic
                         ,craprej.cdcooper
                         ,craprej.nrdconta
                         ,craprej.cdbccxlt
                         ,craprej.nrdocmto
                       INTO
                         rw_craprej.dtmvtolt
                         ,rw_craprej.cdagenci
                         ,rw_craprej.vllanmto
                         ,rw_craprej.nrseqdig
                         ,rw_craprej.cdpesqbb
                         ,rw_craprej.cdcritic
                         ,rw_craprej.cdcooper
                         ,rw_craprej.nrdconta
                         ,rw_craprej.cdbccxlt
                         ,rw_craprej.nrdocmto;
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_cdcritic:= 0;
                         vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                         --Levantar Excecao
                         RAISE vr_exc_sair;
                     END;

                     --Atualizar tabela memoria cratrej
                     pc_gera_cratrej (rw_craprej);

                     --> Gerar Devolucao
                     vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária
                     
                     --> Procedimento para grava registro de devolucao
                     pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                         ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                         ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                         ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                         ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                         ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                         ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                         ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                         ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                         ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                         ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                         ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                         ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                         ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                         ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                         ,pr_dslinarq   => vr_setlinha
                                         ,pr_dscritic   => vr_dscritic);
                                           
                     IF TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_sair;                       
                     END IF;

                     --Inicializar variavel erro
                     vr_cdcritic:= 0;

                     --Proxima linha
                     RAISE vr_exc_proximo;

                   END IF;
                   
                 END IF;
                 --Se for Migracao
                 IF upper(trim(vr_tab_crapcco(vr_index_crapcco).dsorgarq)) IN ('MIGRACAO','INCORPORACAO') THEN
                   --Selecionar Convenio
                   OPEN cr_crabcco (pr_cdcooper => pr_cdcooper
                                   ,pr_nrconven => vr_nrcnvcob);
                   FETCH cr_crabcco INTO rw_crabcco;
                   --Se Encontrou
                   IF cr_crabcco%FOUND AND rw_crabcco.qtdreg = 1 THEN
                     CLOSE cr_crabcco;
                     --Selecionar Transferencias de Contas
                     OPEN cr_craptco_ant (pr_cdcooper => pr_cdcooper
                                         ,pr_cdcopant => rw_crabcco.cdcooper
                                         ,pr_nrctaant => vr_nrdconta
                                         ,pr_tpctatrf => 1
                                         ,pr_flgativo => 1);
                     FETCH cr_craptco_ant INTO rw_craptco;
                     --Se encontrou
                     IF cr_craptco_ant%FOUND THEN
                       vr_nrdconta:= rw_craptco.nrdconta;
                     ELSE
                       --Fechar Cursor
                       IF cr_craptco_ant%ISOPEN THEN
                          CLOSE cr_craptco_ant;
                       END IF;
                       -- o convenio for incorporacao/migracao e o
                       -- cooperado nao for encontrado na cooperativa, pular
                       -- para o proximo registro
                       RAISE vr_exc_proximo;
                     END IF;
                     --Fechar Cursor
                     IF cr_craptco_ant%ISOPEN THEN
                       CLOSE cr_craptco_ant;
                     END IF;
                   END IF;
                   --Fechar Cursor
                   IF cr_crabcco%ISOPEN THEN
                      CLOSE cr_crabcco;
                   END IF;
                 END IF;

                 --Selecionar Associado
                 OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_nrdconta => vr_nrdconta);
                 FETCH cr_crapass INTO rw_crapass;
                 --Indicar se encontrou ou nao
                 vr_crapass:= cr_crapass%FOUND;
                 --Fechar Cursor
                 CLOSE cr_crapass;

                 --Se nao encontrou associado
                 IF NOT vr_crapass THEN
                   vr_flgrejei:= TRUE;

                   --Escrever crítica no relatório
                   vr_cdcritic:= 9;

                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,3              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,0              /* processou na central */
                      ,vr_cdcritic    /* integrado c/ erro */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   /* create craprej */
                   BEGIN
                     INSERT INTO craprej
                       (craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto)
                     VALUES
                       (rw_crapdat.dtmvtolt
                       ,vr_cdagepag
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                       ,vr_setlinha
                       ,vr_cdcritic
                       ,pr_cdcooper
                       ,vr_nrdconta
                       ,vr_cdbanpag
                       ,vr_nrdocmto)
                     RETURNING
                        craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto
                     INTO
                       rw_craprej.dtmvtolt
                       ,rw_craprej.cdagenci
                       ,rw_craprej.vllanmto
                       ,rw_craprej.nrseqdig
                       ,rw_craprej.cdpesqbb
                       ,rw_craprej.cdcritic
                       ,rw_craprej.cdcooper
                       ,rw_craprej.nrdconta
                       ,rw_craprej.cdbccxlt
                       ,rw_craprej.nrdocmto;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;

                   --Atualizar tabela memoria cratrej
                   pc_gera_cratrej (rw_craprej);

                   --> Gerar Devolucao
                   vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária
                   
                   --> Procedimento para grava registro de devolucao
                   pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                       ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                       ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                       ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                       ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                       ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                       ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                       ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                       ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                       ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                       ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                       ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                       ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                       ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                       ,pr_dslinarq   => vr_setlinha
                                       ,pr_dscritic   => vr_dscritic);
                                         
                   IF TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_sair;                       
                   END IF;

                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                   --Pular proxima linha arquivo
                   RAISE vr_exc_proximo;
                 END IF; --vr_tab_crapass

                 -- verificar se o convenio do cooperado está cadastrado
                 OPEN cr_crapceb(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_nrdconta => vr_nrdconta
                                ,pr_nrconven => vr_nrcnvcob);
                 FETCH cr_crapceb INTO rw_crapceb;
                 --Indicar se encontrou ou nao
                 vr_crapceb := cr_crapceb%FOUND;
                 --Fechar Cursor
                 CLOSE cr_crapceb;

                 IF NOT vr_crapceb THEN
                    -- cooperado sem convenio cadastrado
                    vr_cdcritic := 966;
                 ELSE
                    IF rw_crapceb.flgcebhm = 0 AND
                       (vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'IMPRESSO PELO SOFTWARE' OR
                        vr_tab_crapcco(vr_index_crapcco).dsorgant = 'IMPRESSO PELO SOFTWARE') THEN
                       -- Convenio do cooperado nao homologado
                       vr_cdcritic := 965;
                    END IF;
                   
                   -- Verificar se o Convenio do cooperado está bloqueado
                   IF rw_crapceb.insitceb = 4 THEN -- bloqueado
                     vr_cdcritic := 980; --> 980 - Convenio do cooperado bloqueado
                 END IF;
                 END IF;

                 -- verificar se ocorreu alguma das criticas acima (965 ou 966)
                 IF vr_cdcritic > 0 THEN

                   vr_flgrejei:= TRUE;

                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(trim(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(trim(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(trim(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(trim(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(trim(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(trim(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(trim(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(trim(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(trim(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(trim(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(trim(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(trim(SUBSTR(vr_setlinha,10,10))) / 100
                      ,3              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,0              /* processou na central */
                      ,vr_cdcritic    /* integrado c/ erro */
                      ,0
                      ,to_number(trim(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   /* create craprej */
                   BEGIN
                     INSERT INTO craprej
                       (craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto)
                     VALUES
                       (rw_crapdat.dtmvtolt
                       ,vr_cdagepag
                       ,TO_NUMBER(trim(SUBSTR(vr_setlinha,85,12))) / 100
                       ,TO_NUMBER(trim(SUBSTR(vr_setlinha,151,10)))
                       ,vr_setlinha
                       ,vr_cdcritic
                       ,pr_cdcooper
                       ,vr_nrdconta
                       ,vr_cdbanpag
                       ,vr_nrdocmto)
                     RETURNING
                        craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto
                     INTO
                       rw_craprej.dtmvtolt
                       ,rw_craprej.cdagenci
                       ,rw_craprej.vllanmto
                       ,rw_craprej.nrseqdig
                       ,rw_craprej.cdpesqbb
                       ,rw_craprej.cdcritic
                       ,rw_craprej.cdcooper
                       ,rw_craprej.nrdconta
                       ,rw_craprej.cdbccxlt
                       ,rw_craprej.nrdocmto;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;

                   --Atualizar tabela memoria cratrej
                   pc_gera_cratrej (rw_craprej);
                   
                   IF vr_cdcritic IN (965,966,980) THEN
                     CASE vr_cdcritic
                       WHEN 965 THEN
                         vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária
                       WHEN 966 THEN
                         vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária
                       WHEN 980 THEN
                         vr_cdmotdev := 72; --> 72 - Devolução de Pagamento Fraudado                         
                     END CASE;                       
                     
                     --> Procedimento para grava registro de devolucao
                     pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                         ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                         ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                         ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                         ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                         ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                         ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                         ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                         ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                         ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                         ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                         ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                         ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                         ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                         ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                         ,pr_dslinarq   => vr_setlinha
                                         ,pr_dscritic   => vr_dscritic);
                                         
                     IF TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_sair;                       
                     END IF;
                   
                   END IF;                  

                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                   --Pular proxima linha arquivo
                   RAISE vr_exc_proximo;
                 END IF; --vr_crapaceb

                 --> Veificar se cobrança ja entra na regra de rollout da nova plataforma de cobrança
                 vr_flgdnpcb := NPCB0001.fn_verifica_rollout ( pr_cdcooper   => rw_crapcop.cdcooper, --> Codigo da cooperativa
                                                               pr_dtmvtolt   => rw_crapdat.dtmvtolt, --> Data do movimento
                                                               pr_vltitulo   => vr_vltitulo,         --> Valor do titulo
                                                               pr_tpdregra   => 2 );                 --> Tipo de regra de rollout(1-registro,2-pagamento)
                 
                 --limpar registro
                 rw_crapcob := null;

                 /* Validar se registro esta disponivel para pagto */
                 OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_cdbandoc => vr_tab_crapcco(vr_index_crapcco).cddbanco
                                 ,pr_nrdctabb => vr_tab_crapcco(vr_index_crapcco).nrdctabb
                                       ,pr_nrcnvcob => vr_nrcnvcob
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_nrdocmto => vr_nrdocmto);
                 FETCH cr_crapcob INTO rw_crapcob;
                 vr_fcrapcob := cr_crapcob%FOUND;
                    CLOSE cr_crapcob;

                 --Se nao encontrou
                 IF vr_fcrapcob = FALSE AND
                    nvl(vr_tab_crapcco(vr_index_crapcco).dsorgarq,' ') <> 'IMPRESSO PELO SOFTWARE' AND
                    nvl(vr_tab_crapcco(vr_index_crapcco).dsorgant,' ') <> 'IMPRESSO PELO SOFTWARE' THEN

                   --Escrever mensagem de integracao no log
                   vr_flgrejei:= TRUE;

                   vr_cdcritic:= 592;

                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,3              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,0              /* processou na central */
                      ,vr_cdcritic    /* integrado c/ erro */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   /* create craprej */
                   BEGIN
                     INSERT INTO craprej
                       (craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto)
                     VALUES
                       (rw_crapdat.dtmvtolt
                       ,vr_cdagepag
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                       ,vr_setlinha
                       ,vr_cdcritic
                       ,pr_cdcooper
                       ,vr_nrdconta
                       ,vr_cdbanpag
                       ,vr_nrdocmto)
                     RETURNING
                        craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto
                     INTO
                       rw_craprej.dtmvtolt
                       ,rw_craprej.cdagenci
                       ,rw_craprej.vllanmto
                       ,rw_craprej.nrseqdig
                       ,rw_craprej.cdpesqbb
                       ,rw_craprej.cdcritic
                       ,rw_craprej.cdcooper
                       ,rw_craprej.nrdconta
                       ,rw_craprej.cdbccxlt
                       ,rw_craprej.nrdocmto;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;

                   --Atualizar tabela memoria cratrej
                   pc_gera_cratrej (rw_craprej);
                   
                   vr_cdmotdev := 74; --> 74 - CPF/CNPJ do beneficiário inválido ou não confere com registro de boleto na base da IF Destinatária
                     
                   --> Procedimento para grava registro de devolucao
                   pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                       ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                       ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                       ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                       ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                       ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                       ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                       ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                       ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                       ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                       ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                       ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                       ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                       ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                       ,pr_dslinarq   => vr_setlinha
                                       ,pr_dscritic   => vr_dscritic);
                                         
                   IF TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_sair;                       
                   END IF;

                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                   --Pular proxima linha arquivo
                   RAISE vr_exc_proximo;
                 END IF;

                 --Se nao encontrou titulo do convenio 'IMPRESSO PELO SOFTWARE', então criar um título novo
                 IF vr_fcrapcob = FALSE AND
                    (nvl(vr_tab_crapcco(vr_index_crapcco).dsorgarq,' ') = 'IMPRESSO PELO SOFTWARE'  OR
                     nvl(vr_tab_crapcco(vr_index_crapcco).dsorgant,' ') = 'IMPRESSO PELO SOFTWARE') THEN

                    INSERT INTO crapcob (cdcooper
                                        ,nrdconta
                                        ,nrcnvcob
                                        ,nrdocmto
                                        ,nrdctabb
                                        ,cdbandoc
                                        ,dtmvtolt
                                        ,dtvencto
                                        ,vltitulo
                                        ,incobran
                                        ,flgregis
                                        ,vlabatim
                                        ,vldescto
                                        ,tpdmulta
                                        ,tpjurmor
                                        ,dsdoccop
                                        ,flgdprot
                                        ,dsinform
                                        ,nrnosnum)
                                 VALUES (rw_crapcop.cdcooper
                                        ,vr_nrdconta
                                        ,vr_nrcnvcob
                                        ,vr_nrdocmto
                                        ,vr_tab_crapcco(vr_index_crapcco).nrdctabb
                                        ,vr_tab_crapcco(vr_index_crapcco).cddbanco
                                        ,rw_crapdat.dtmvtolt
                                        ,rw_crapdat.dtmvtolt
                                        ,TO_NUMBER(SUBSTR(vr_setlinha,85,12)) / 100
                                        ,0 -- incobran
                                        ,vr_tab_crapcco(vr_index_crapcco).flgregis
                                        ,0 -- vlabatim
                                        ,0 -- vldescto
                                        ,3 -- tpdmulta
                                        ,3 -- tpjurmor
                                        ,to_char(vr_nrdocmto) -- dscodcop
                                        ,0
                                        ,'LIQAPOSBX' || substr(vr_setlinha,1,44)
                                        ,TRIM(SUBSTR(vr_setlinha,26,17)) );

                    IF cr_crapcob%ISOPEN THEN
                       CLOSE cr_crapcob;
                    END IF;

                    /* Validar se registro esta disponivel para pagto */
                    OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_cdbandoc => vr_tab_crapcco(vr_index_crapcco).cddbanco
                                    ,pr_nrdctabb => vr_tab_crapcco(vr_index_crapcco).nrdctabb
                                          ,pr_nrcnvcob => vr_nrcnvcob
                                          ,pr_nrdconta => vr_nrdconta
                                          ,pr_nrdocmto => vr_nrdocmto);
                    FETCH cr_crapcob INTO rw_crapcob;
                   -- liquidacao após baixa ou liquidação de título não registrado
                   vr_liqaposb:= TRUE;
                 END IF;

                 --Fechar Cursor
                 IF cr_crapcob%ISOPEN THEN
                   CLOSE cr_crapcob;
                 END IF;

                 --> Se cobrança ja esta na regra de rollout da nova plataforma de cobrança, 
                 IF vr_flgdnpcb = 1
                 --> e esta fora do periodo de convivencia /*SD#764044*/
                 AND npcb0001.fn_valid_periodo_conviv (rw_crapdat.dtmvtolt) = 0 THEN

                   cxon0014.pc_calcula_data_vencimento(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                       pr_de_campo => substr(vr_dscodbar_ori,6,4),
                                                       pr_dtvencto => vr_dtvencto,
                                                       pr_cdcritic => vr_cdcritic,
                                                       pr_dscritic => vr_dscritic);
                   
                   
                   --> Verificar se valor e data de vencimento do codigo de barra estão corretos
                   IF TO_NUMBER(trim(SUBSTR(vr_dscodbar_ori,10,10))) / 100 <> rw_crapcob.vltitulo OR 
                      vr_dtvencto <> NVL(rw_crapcob.dtvctori,rw_crapcob.dtvencto) OR
                      --> ou se na validacao da do vencto retornou critica
                      nvl(vr_cdcritic,0) > 0 OR 
                      TRIM(vr_dscritic) IS NOT NULL THEN
                      
                      
                     /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                     BEGIN
                       INSERT INTO gncptit
                        (gncptit.cdcooper
                        ,gncptit.cdagenci
                        ,gncptit.dtmvtolt
                        ,gncptit.dtliquid
                        ,gncptit.cdbandst
                        ,gncptit.cddmoeda
                        ,gncptit.nrdvcdbr
                        ,gncptit.dscodbar
                        ,gncptit.tpcaptur
                        ,gncptit.cdagectl
                        ,gncptit.nrdolote
                        ,gncptit.nrseqdig
                        ,gncptit.vldpagto
                        ,gncptit.tpdocmto
                        ,gncptit.nrseqarq
                        ,gncptit.nmarquiv
                        ,gncptit.cdoperad
                        ,gncptit.hrtransa
                        ,gncptit.vltitulo
                        ,gncptit.cdtipreg
                        ,gncptit.flgconci
                        ,gncptit.flgpcctl
                        ,gncptit.cdcritic
                        ,gncptit.cdmotdev
                        ,gncptit.cdfatven
                        ,gncptit.nrispbds)
                       VALUES
                        (pr_cdcooper
                        ,0
                        ,vr_dtmvtolt
                        ,rw_crapdat.dtmvtolt
                        ,to_number(trim(SUBSTR(vr_setlinha,1,3)))
                        ,to_number(trim(SUBSTR(vr_setlinha,4,1)))
                        ,to_number(trim(SUBSTR(vr_setlinha,5,1)))
                        ,SUBSTR(vr_setlinha,01,44)
                        ,to_number(trim(SUBSTR(vr_setlinha,50,1)))
                        ,to_number(trim(SUBSTR(vr_setlinha,57,4)))
                        ,to_number(trim(SUBSTR(vr_setlinha,61,6)))
                        ,to_number(trim(SUBSTR(vr_setlinha,68,3)))
                        ,to_number(trim(SUBSTR(vr_setlinha,85,12))) / 100
                        ,to_number(trim(SUBSTR(vr_setlinha,45,2)))
                        ,to_number(trim(SUBSTR(vr_setlinha,151,10)))
                        ,vr_tab_nmarqtel(idx)
                        ,vr_cdoperad
                        ,TO_NUMBER(trim(SUBSTR(vr_setlinha,151,10)))
                        ,to_number(trim(SUBSTR(vr_setlinha,10,10))) / 100
                        ,3              /* Sua Remessa - Erro */
                        ,1              /* registro conciliado */
                        ,0              /* processou na central */
                        ,998            /* Apresentacao indevida */
                        ,0
                        ,to_number(trim(SUBSTR(vr_setlinha,6,4)))
                        ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_cdcritic:= 0;
                         vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                         --Levantar Excecao
                         RAISE vr_exc_sair;
                     END; 
                      
                     vr_cdmotdev := 63; --> 63 - Código de barras em desacordo com as especificações
                     
                     --> Procedimento para grava registro de devolucao
                     pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                         ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                         ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                         ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                         ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                         ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                         ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                         ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                         ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                         ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                         ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                         ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                         ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                         ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                         ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                         ,pr_dslinarq   => vr_setlinha
                                         ,pr_dscritic   => vr_dscritic);
                                         
                     IF TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_sair;                       
                     END IF;
                     --> processar proximo registro
                     RAISE vr_exc_proximo;
                      
                   END IF;
                 
                 END IF;  --> Fim regra rollout    
                 
                 --> Devolução de Pagamento Fraudado
                 IF rw_crapcob.incobran = 2 THEN               
                   
                 
                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(trim(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(trim(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(trim(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(trim(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(trim(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(trim(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(trim(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(trim(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(trim(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(trim(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(trim(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(trim(SUBSTR(vr_setlinha,10,10))) / 100
                      ,3              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,0              /* processou na central */
                      ,980            /* Boleto bloqueado */
                      ,0
                      ,to_number(trim(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                 
                   vr_cdmotdev := 72; --> 72 - Devolução de Pagamento Fraudado
                     
                   --> Procedimento para grava registro de devolucao
                   pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                       ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                       ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                       ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                       ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                       ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                       ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                       ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                       ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                       ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                       ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                       ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                       ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                       ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                       ,pr_dslinarq   => vr_setlinha
                                       ,pr_dscritic   => vr_dscritic);
                                         
                   IF TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_sair;                       
                   END IF;
                   --> processar proximo registro
                   RAISE vr_exc_proximo;
                   
                 END IF;
                 

                 -- se o boleto de emprestimo ja foi pago ou baixado, será devolvido no crrl574
                 IF rw_crapcob.incobran IN (3,5) AND
                    vr_tab_crapcco(vr_index_crapcco).dsorgarq IN ('EMPRESTIMO','ACORDO') THEN
                    
                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,5              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,0              /* processou na central */
                      ,969            /* integrado c/ erro - boleto de emprestimo nao processado */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   
                   --> Gerar Devolucao
                   vr_cdmotdev := 53; --> 53 - Apresentação indevida
                     
                   --> Procedimento para grava registro de devolucao
                   pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                       ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                       ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                       ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                       ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                       ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                       ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                       ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                       ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                       ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                       ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                       ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                       ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                       ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                       ,pr_dslinarq   => vr_setlinha
                                       ,pr_dscritic   => vr_dscritic);
                                         
                   IF TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_sair;                       
                   END IF;
                    
                    RAISE vr_exc_proximo;
                 END IF;

                 /* aceita titulos em aberto, baixados e ja pagos */
                 IF rw_crapcob.incobran = 5  THEN
                   --Rejeitado
                   vr_flgrejei:= TRUE;
                   /* flg para realizar liquidacao apos baixa */
                   vr_liqaposb:= TRUE;
                   /* liquidacao de boleto pago */
                   vr_cdcritic:= 947;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   /* Gerar LOG 085 */
                   IF nvl(rw_crapcob.flgregis,0) = 1 THEN
                     --Criar log Cobranca
                     PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid               --ROWID da Cobranca
                                                  ,pr_cdoperad => vr_cdoperad                    --Operador
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt            --Data movimento
                                                  ,pr_dsmensag => 'Liquidacao de boleto pago'    --Descricao Mensagem
                                                  ,pr_des_erro => vr_des_erro                    --Indicador erro
                                                  ,pr_dscritic => vr_dscritic);                  --Descricao erro
                     --Se ocorreu erro
                     IF vr_des_erro = 'NOK' THEN
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                     END IF;
                   END IF;
                   /* create craprej */
                   BEGIN
                     INSERT INTO craprej
                       (craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto)
                     VALUES
                       (rw_crapdat.dtmvtolt
                       ,vr_cdagepag
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                       ,vr_setlinha
                       ,vr_cdcritic
                       ,pr_cdcooper
                       ,vr_nrdconta
                       ,vr_cdbanpag
                       ,vr_nrdocmto)
                     RETURNING
                        craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto
                     INTO
                       rw_craprej.dtmvtolt
                       ,rw_craprej.cdagenci
                       ,rw_craprej.vllanmto
                       ,rw_craprej.nrseqdig
                       ,rw_craprej.cdpesqbb
                       ,rw_craprej.cdcritic
                       ,rw_craprej.cdcooper
                       ,rw_craprej.nrdconta
                       ,rw_craprej.cdbccxlt
                       ,rw_craprej.nrdocmto;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   --Atualizar tabela memoria cratrej
                   pc_gera_cratrej (rw_craprej);

                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                 END IF;
                 /* se titulo baixado p/ protesto (941) ou baixado (943), criticar... */
                 IF  nvl(rw_crapcob.flgregis,0) = 1 AND rw_crapcob.incobran = 3 AND
                     rw_crapcob.insitcrt IN (0,1) THEN
                   /* flg para realizar liquidacao apos baixa */
                   vr_liqaposb:= TRUE;
                   IF rw_crapcob.insitcrt = 1 THEN
                   
                     vr_cdcritic:= 941;
                     /* se existir informacao do titulo enviado p/ protesto */
                     IF TRIM(rw_crapcob.cdtitprt) IS NOT NULL THEN
                       --Inicializar Valor Despesas

                       --Selecionar Convenio
                       OPEN cr_crabcco2 (pr_cdcooper => gene0002.fn_busca_entrada(1,rw_crapcob.cdtitprt,';')
                                        ,pr_nrconven => gene0002.fn_busca_entrada(3,rw_crapcob.cdtitprt,';'));
                       FETCH cr_crabcco2 INTO rw_crabcco;
                       --Se Encontrou Convenio
                       IF cr_crabcco2%FOUND AND rw_crabcco.qtdreg = 1 THEN
                         --Fechar Cursor
                         CLOSE cr_crabcco2;
                         --Encontrar Cobrancas
                         OPEN cr_crapcob (pr_cdcooper => gene0002.fn_busca_entrada(1,rw_crapcob.cdtitprt,';')
                                         ,pr_nrdconta => gene0002.fn_busca_entrada(2,rw_crapcob.cdtitprt,';')
                                         ,pr_nrcnvcob => gene0002.fn_busca_entrada(3,rw_crapcob.cdtitprt,';')
                                         ,pr_nrdocmto => gene0002.fn_busca_entrada(4,rw_crapcob.cdtitprt,';')
                                         ,pr_nrdctabb => rw_crabcco.nrdctabb
                                         ,pr_cdbandoc => rw_crabcco.cddbanco);
                         FETCH cr_crapcob INTO rw_crabcob;
                         --Se encontrou
                         IF cr_crapcob%FOUND THEN
                           --Fechar Cursor
                           CLOSE cr_crapcob;
                           --Determinar a data para sustar
                           IF pr_nmtelant = 'COMPEFORA' THEN
                             vr_dtmvtaux:= rw_crapdat.dtmvtolt;
                           ELSE
                             vr_dtmvtaux:= rw_crapdat.dtmvtopr;
                           END IF;
                           /* Sustar a baixa */
                           COBR0007.pc_inst_sustar_baixar (pr_cdcooper => rw_crabcob.cdcooper    --Codigo Cooperativa
                                                          ,pr_nrdconta => rw_crabcob.nrdconta    --Numero da Conta
                                                          ,pr_nrcnvcob => rw_crabcob.nrcnvcob    --Numero Convenio
                                                          ,pr_nrdocmto => rw_crabcob.nrdocmto    --Numero Documento
                                                          ,pr_dtmvtolt => vr_dtmvtaux            --Data pagamento
                                                          ,pr_cdoperad => vr_cdoperad            --Operador
                                                          ,pr_nrremass => 0                      --Numero Remessa
                                                          ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                                          ,pr_cdcritic => vr_cdcritic2
                                                          ,pr_dscritic => vr_dscritic2);

                           --Se ocorreu erro
                           IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
                           --  vr_cdcritic:= vr_cdcritic2;
                           --  vr_dscritic:= vr_dscritic2;
                             --Levantar Excecao
                           --  RAISE vr_exc_sair;
                               NULL;
                           END IF;
                           /* Gerar LOG 085*/
                           PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid       --ROWID da Cobranca
                                                        ,pr_cdoperad => vr_cdoperad            --Operador
                                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt        --Data movimento
                                                        ,pr_dsmensag => 'Liquidacao apos baixa'    --Descricao Mensagem
                                                        ,pr_des_erro => vr_des_erro            --Indicador erro
                                                        ,pr_dscritic => vr_dscritic2);          --Descricao erro
                           --Se ocorreu erro
                           IF vr_des_erro = 'NOK' THEN
                             vr_cdcritic:= 0;
                             vr_dscritic:= vr_dscritic2;
                             --Levantar Excecao
                             RAISE vr_exc_sair;
                           END IF;
                           /* Gerar LOG 001 [BB]*/
                           PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crabcob.rowid           --ROWID da Cobranca
                                                        ,pr_cdoperad => vr_cdoperad                --Operador
                                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt        --Data movimento
                                                        ,pr_dsmensag => 'Liquidacao do boleto no convenio 085'    --Descricao Mensagem
                                                        ,pr_des_erro => vr_des_erro                --Indicador erro
                                                        ,pr_dscritic => vr_dscritic2);             --Descricao erro
                           --Se ocorreu erro
                           IF vr_des_erro = 'NOK' THEN
                             vr_cdcritic:= 0;
                             vr_dscritic:= vr_dscritic2;
                             --Levantar Excecao
                             RAISE vr_exc_sair;
                           END IF;
                           
                         END IF; --cr_crapcob%FOUND
                         --Fechar Cursor
                         IF cr_crapcob%ISOPEN THEN
                           CLOSE cr_crapcob;
                         END IF;
                       END IF; --cr_crabcco%FOUND
                       --Fechar Cursor
                       IF cr_crabcco2%ISOPEN THEN
                         CLOSE cr_crabcco2;
                       END IF;

                       --Se valor despesa > 0 e
                       --se valor despeza > que Valor Minimo CAC
                       IF nvl(vr_vldescar,0) > 0 AND
                          nvl(vr_vldescar,0) >= vr_vlrmincac THEN
                         --Selecionar nome sacado
                         OPEN cr_crapsab (pr_cdcooper => rw_crapcob.cdcooper
                                         ,pr_nrdconta => rw_crapcob.nrdconta
                                         ,pr_nrinssac => rw_crapcob.nrinssac);
                         FETCH cr_crapsab INTO rw_crapsab;
                         --Indicar se encontrou ou nao
                         vr_crapsab:= cr_crapsab%FOUND;
                         --Fechar Cursor
                         CLOSE cr_crapsab;
                         --Se nao encontrou
                         IF NOT vr_crapsab THEN
                           rw_crapsab.nmdsacad:= NULL;
                         END IF;
                         --Montar Indice para relatorio 618
                         vr_index_rel618:= lpad(to_char(vr_cdbanpag,'fm000'),10,'0')||
                                           rpad(TRIM(rw_crapsab.nmdsacad),50,'#')||
                                           lpad(to_char(rw_crabcob.vltitulo*100),25,'0')||
                                           lpad(vr_tab_rel618.COUNT+1,10,'0');
                         /* Alimenta a temp-table do rel. 618 */
                         vr_tab_rel618(vr_index_rel618).cddbanco:= vr_cdbanpag;
                         vr_tab_rel618(vr_index_rel618).bancoage:= to_char(vr_cdbanpag,'fm000') ||'/'||to_char(vr_cdagepag,'fm0000');
                         vr_tab_rel618(vr_index_rel618).nrcpfcnj:= rw_crabcob.nrinssac;
                         vr_tab_rel618(vr_index_rel618).nmsacado:= rw_crapsab.nmdsacad;
                         vr_tab_rel618(vr_index_rel618).dscodbar:= SUBSTR(vr_setlinha,01,44);
                         vr_tab_rel618(vr_index_rel618).nrdocmto:= rw_crabcob.dsdoccop;
                         vr_tab_rel618(vr_index_rel618).dtvencto:= rw_crabcob.dtvencto;
                         vr_tab_rel618(vr_index_rel618).vldocmto:= rw_crabcob.vltitulo;
                         vr_tab_rel618(vr_index_rel618).vldesaba:= TRUNC((nvl(rw_crabcob.vldescto,0) + nvl(rw_crabcob.vlabatim,0)),2);
                         vr_tab_rel618(vr_index_rel618).vljurmul:= TRUNC(nvl(vr_vlrjuros,0) + nvl(vr_vlrmulta,0),2);
                         vr_tab_rel618(vr_index_rel618).vlrpagto:= TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100;
                         vr_tab_rel618(vr_index_rel618).vlrdifer:= 0;
                         vr_tab_rel618(vr_index_rel618).vldescar:= vr_vldescar;
                         vr_tab_rel618(vr_index_rel618).inpessoa:= rw_crapass.inpessoa;
                       END IF; -- vr_vldescar > 0
                     END IF; --rw_crapcob.cdtitprt IS NOT NULL
                   ELSIF rw_crapcob.insitcrt = 0 THEN
                     vr_cdcritic:= 943;
                     /* Gerar LOG 085 */
                     IF nvl(rw_crapcob.flgregis,0) = 1 THEN
                       --Criar log Cobranca
                       PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid       --ROWID da Cobranca
                                                    ,pr_cdoperad => vr_cdoperad            --Operador
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt        --Data movimento
                                                    ,pr_dsmensag => 'Liquidacao apos baixa'    --Descricao Mensagem
                                                    ,pr_des_erro => vr_des_erro            --Indicador erro
                                                    ,pr_dscritic => vr_dscritic2);          --Descricao erro
                       --Se ocorreu erro
                       IF vr_des_erro = 'NOK' THEN
                         vr_cdcritic:= 0;
                         vr_dscritic:= vr_dscritic2;
                         --Levantar Excecao
                         RAISE vr_exc_sair;
                       END IF;
                     END IF;
                   END IF; --rw_crapcob.insitcrt = 1
                   --Buscar descricao critica
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   /* create craprej */
                   BEGIN
                     INSERT INTO craprej
                       (craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto)
                     VALUES
                       (rw_crapdat.dtmvtolt
                       ,vr_cdagepag
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                       ,vr_setlinha
                       ,vr_cdcritic
                       ,pr_cdcooper
                       ,vr_nrdconta
                       ,vr_cdbanpag
                       ,vr_nrdocmto)
                     RETURNING
                        craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto
                     INTO
                       rw_craprej.dtmvtolt
                       ,rw_craprej.cdagenci
                       ,rw_craprej.vllanmto
                       ,rw_craprej.nrseqdig
                       ,rw_craprej.cdpesqbb
                       ,rw_craprej.cdcritic
                       ,rw_craprej.cdcooper
                       ,rw_craprej.nrdconta
                       ,rw_craprej.cdbccxlt
                       ,rw_craprej.nrdocmto;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   --Atualizar tabela memoria cratrej
                   pc_gera_cratrej (rw_craprej);
                   --Inicializar variaveis erro
                   vr_cdcritic:= 0;
                   vr_dscritic:= NULL;
                 END IF; --protesto (941 e 943)
                 /* Este mesmo calculo eh usado na b2crap14, caso alterar aqui
                    nao esquecer de alterar la tambem */
                 /* variaveis de calculo cobranca registrada */
                 vr_vlrjuros:= 0;
                 vr_vlrmulta:= 0;
                 vr_vldescto:= 0;
                 vr_vlabatim:= rw_crapcob.vlabatim;
                 vr_vlfatura:= rw_crapcob.vltitulo;
                 /*
                 --Verificar Vencimento Titulo
                 pc_verifica_vencto_titulo (pr_cdcooper   => rw_crapcop.cdcooper --Cooperativa
                                           ,pr_dtvencto   => rw_crapcob.dtvencto --Vencimento
                                           ,pr_nmtelant   => pr_nmtelant         --Tela Anterior
                                           ,pr_rw_crapdat => rw_crapdat          --Registro Tipo Data
                                           ,pr_critdata   => vr_flgvenci         --Retorno/Vencido
                                           ,pr_cdcritic   => vr_cdcritic         --Codigo Erro
                                           ,pr_dscritic   => vr_dscritic);       --Descricao Erro
                 */
                 IF pr_nmtelant = 'COMPEFORA' THEN
                    vr_dtrefere:= rw_crapdat.dtmvtoan;
                 ELSE
                    vr_dtrefere:= rw_crapdat.dtmvtolt;
                 END IF;

                 --Verificar Vencimento Titulo
                 pc_verifica_vencto (pr_cdcooper => rw_crapcop.cdcooper                  --Codigo da cooperativa
                                    ,pr_dtmvtolt => vr_dtrefere                          --Data para verificacao
                                    ,pr_cddbanco => vr_cdbanpag                          --Codigo do Banco
                                    ,pr_cdagenci => vr_cdagepag                          --Codigo da Agencia
                                    ,pr_dtboleto => rw_crapcob.dtvencto                  --Data do Titulo
                                    ,pr_flgvenci => vr_flgvenci                          --Indicador titulo vencido
                                    ,pr_cdcritic => vr_cdcritic                          --Codigo do erro
                                    ,pr_dscritic => vr_dscritic );                          --Descricao do erro

                 --Se ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   /* nao criticar possiveis problemas do calculo de vencimento */
                   vr_cdcritic := NULL;
                   vr_dscritic := NULL;
                 END IF;

                 /* calculo de abatimento deve ser antes da aplicacao de juros e multa */
                 IF nvl(vr_vlabatim,0) > 0 THEN
                   --Diminuir valor do abatimento na fatura
                   vr_vlfatura:= nvl(vr_vlfatura,0) - nvl(vr_vlabatim,0);
                 END IF;
                 /* trata o desconto se concede apos o vencimento */
                 IF rw_crapcob.cdmensag = 2 THEN
                   --Valor desconto recebe valor bordero cobranca
                   vr_vldescto:= rw_crapcob.vldescto;
                   --Diminuir valor dodesconto na fatura
                   vr_vlfatura:= nvl(vr_vlfatura,0) - nvl(vr_vldescto,0);
                 END IF;
                 /* verifica se o titulo esta vencido */
                 IF vr_flgvenci THEN
                   --
				   /*calculo do juro, multa e valor do título com juros e multa*/
                   cxon0014.pc_calcula_vlr_titulo_vencido(pr_vltitulo => vr_vlfatura
                                                         ,pr_tpdmulta => rw_crapcob.tpdmulta
                                                         ,pr_vlrmulta => rw_crapcob.vlrmulta
                                                         ,pr_tpjurmor => rw_crapcob.tpjurmor
                                                         ,pr_vljurdia => rw_crapcob.vljurdia
                                                         ,pr_qtdiavenc => (vr_dtmvtolt - rw_crapcob.dtvencto)
                                                         ,pr_vlfatura => vr_vlfatura
                                                         ,pr_vlrmulta_calc => vr_vlrmulta
                                                         ,pr_vlrjuros_calc => vr_vlrjuros
                                                         ,pr_dscritic => vr_dscritic);
                   --
                   if trim(vr_dscritic) is not null then
                     --Levantar Excecao
                     raise vr_exc_sair;
                   end if;
                   --
                 ELSE
                   /* se concede apos vencto, ja calculou */
                   IF rw_crapcob.cdmensag <> 2  THEN
                     --Valor desconto
                     vr_vldescto:= nvl(rw_crapcob.vldescto,0);
                     --Diminuir o desconto da fatura
                     vr_vlfatura:= nvl(vr_vlfatura,0) - nvl(vr_vldescto,0);
                   END IF;
                 END IF; --vr_flgvenci

                 /* se pagou valor menor ou vencido e é do convenio EMPRESTIMO */
                 IF (TRUNC(vr_vlliquid,2) < TRUNC(vr_vlfatura,2) OR vr_flgvenci) AND
                    vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'EMPRESTIMO' THEN
                    
                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,5              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,0              /* processou na central */
                      ,969            /* integrado c/ erro - boleto de emprestimo nao processado */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   
                   --> Gerar Devolucao
                   vr_cdmotdev := 53; --> 53 - Apresentação indevida
                     
                   --> Procedimento para grava registro de devolucao
                   pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                       ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                       ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                       ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                       ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                       ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                       ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                       ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                       ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                       ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                       ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                       ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                       ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                       ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                       ,pr_dslinarq   => vr_setlinha
                                       ,pr_dscritic   => vr_dscritic);
                                         
                   IF TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_sair;                       
                   END IF;
                    
                   -- pular para o proximo registro - devolvido em arquivo
                    RAISE vr_exc_proximo;
                 -- Se pagou valor a menor e é ACORDO
                 ELSIF TRUNC(vr_vlliquid,2) < TRUNC(vr_vlfatura,2) AND 
                    vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'ACORDO' THEN
                    
                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,5              /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,0              /* processou na central */
                      ,969            /* integrado c/ erro - boleto de emprestimo nao processado */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   
                   --> Gerar Devolucao
                   vr_cdmotdev := 53; --> 53 - Apresentação indevida
                     
                   --> Procedimento para grava registro de devolucao
                   pc_grava_devolucao ( pr_cdcooper   => rw_crapcop.cdcooper  --> codigo da cooperativa
                                       ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> data do movimento
                                       ,pr_dtmvtopr   => rw_crapdat.dtmvtopr  --> data do próximo movimento
                                       ,pr_nrseqarq   => vr_nrseqarq          --> numero sequencial do arquivo da devolucao (cob615)
                                       ,pr_dscodbar   => vr_dscodbar_ori      --> codigo de barras
                                       ,pr_nrispbif   => vr_nrispbif_rec      --> numero do ispb recebedora
                                       ,pr_vlliquid   => vr_vlliquid          --> valor de liquidacao do titulo
                                       ,pr_dtocorre   => vr_dtmvtolt          --> data da ocorrencia da devolucao
                                       ,pr_nrdconta   => vr_nrdconta          --> numero da conta do cooperado
                                       ,pr_nrcnvcob   => vr_nrcnvcob          --> numero do convenio de cobranca do cooperado
                                       ,pr_nrdocmto   => vr_nrdocmto          --> numero do boleto de cobranca
                                       ,pr_cdmotdev   => vr_cdmotdev          --> codigo do motivo da devolucao
                                       ,pr_tpcaptur   => vr_tpcaptur          --> tipo de captura (cob615)
                                       ,pr_tpdocmto   => vr_tpdocmto          --> codigo do tipo de documento (cob615)
                                       ,pr_cdagerem   => vr_cdagepag          --> codigo da agencia do remetente (cob615)
                                       ,pr_dslinarq   => vr_setlinha
                                       ,pr_dscritic   => vr_dscritic);
                                         
                   IF TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_sair;                       
                   END IF;
                    
                   -- pular para o proximo registro - devolvido em arquivo
                    RAISE vr_exc_proximo;
                 END IF;

                 /* se pagou valor menor do que deveria, joga critica no log */
                 IF TRUNC(vr_vlliquid,2) < TRUNC(vr_vlfatura,2) AND NOT vr_liqaposb THEN
                   vr_cdcritic:= 940;
                   --Buscar descricao critica
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   /* create craprej */
                   BEGIN
                     INSERT INTO craprej
                       (craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto)
                     VALUES
                       (rw_crapdat.dtmvtolt
                       ,vr_cdagepag
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                       ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                       ,vr_setlinha
                       ,vr_cdcritic
                       ,pr_cdcooper
                       ,vr_nrdconta
                       ,vr_cdbanpag
                       ,vr_nrdocmto)
                     RETURNING
                        craprej.dtmvtolt
                       ,craprej.cdagenci
                       ,craprej.vllanmto
                       ,craprej.nrseqdig
                       ,craprej.cdpesqbb
                       ,craprej.cdcritic
                       ,craprej.cdcooper
                       ,craprej.nrdconta
                       ,craprej.cdbccxlt
                       ,craprej.nrdocmto
                     INTO
                       rw_craprej.dtmvtolt
                       ,rw_craprej.cdagenci
                       ,rw_craprej.vllanmto
                       ,rw_craprej.nrseqdig
                       ,rw_craprej.cdpesqbb
                       ,rw_craprej.cdcritic
                       ,rw_craprej.cdcooper
                       ,rw_craprej.nrdconta
                       ,rw_craprej.cdbccxlt
                       ,rw_craprej.nrdocmto;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;

                   --Atualizar tabela memoria cratrej
                   pc_gera_cratrej (rw_craprej);
                   --Selecionar nome sacado
                   OPEN cr_crapsab (pr_cdcooper => rw_crapcob.cdcooper
                                   ,pr_nrdconta => rw_crapcob.nrdconta
                                   ,pr_nrinssac => rw_crapcob.nrinssac);
                   FETCH cr_crapsab INTO rw_crapsab;
                   --Indicar se encontrou ou nao
                   vr_crapsab:= cr_crapsab%FOUND;
                   --Fechar Cursor
                   CLOSE cr_crapsab;
                   --Se nao encontrou
                   IF NOT vr_crapsab THEN
                     rw_crapsab.nmdsacad:= NULL;
                   END IF;

                   IF ( TRUNC(vr_vlfatura,2) - TRUNC(vr_vlliquid,2) ) >= vr_vlrmincac THEN

                     --Montar Indice para relatorio 618
                     vr_index_rel618:= lpad(to_char(vr_cdbanpag,'fm000'),10,'0')||
                                       rpad(TRIM(rw_crapsab.nmdsacad),50,'#')||
                                       lpad(to_char(rw_crapcob.vltitulo*100),25,'0')||
                                       lpad(vr_tab_rel618.COUNT+1,10,'0');
                     /* Alimenta a temp-table do rel. 618 */
                     vr_tab_rel618(vr_index_rel618).cddbanco:= vr_cdbanpag;
                     vr_tab_rel618(vr_index_rel618).bancoage:= to_char(vr_cdbanpag,'fm000')||'/'||to_char(vr_cdagepag,'fm0000');
                     vr_tab_rel618(vr_index_rel618).nrcpfcnj:= rw_crapcob.nrinssac;
                     vr_tab_rel618(vr_index_rel618).nmsacado:= rw_crapsab.nmdsacad;
                     vr_tab_rel618(vr_index_rel618).dscodbar:= SUBSTR(vr_setlinha,01,44);
                     vr_tab_rel618(vr_index_rel618).nrdocmto:= rw_crapcob.dsdoccop;
                     vr_tab_rel618(vr_index_rel618).dtvencto:= rw_crapcob.dtvencto;
                     vr_tab_rel618(vr_index_rel618).vldocmto:= rw_crapcob.vltitulo;
                     vr_tab_rel618(vr_index_rel618).vldesaba:= TRUNC((nvl(rw_crapcob.vldescto,0) + nvl(rw_crapcob.vlabatim,0)),2);
                     vr_tab_rel618(vr_index_rel618).vljurmul:= TRUNC(nvl(vr_vlrjuros,0) + nvl(vr_vlrmulta,0),2);
                     vr_tab_rel618(vr_index_rel618).vlrpagto:= TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100;
                     vr_tab_rel618(vr_index_rel618).vlrdifer:= TRUNC(nvl(vr_tab_rel618(vr_index_rel618).vldocmto,0) -
                                                                   nvl(vr_tab_rel618(vr_index_rel618).vldesaba,0) +
                                                                   nvl(vr_tab_rel618(vr_index_rel618).vljurmul,0) -
                                                                   nvl(vr_tab_rel618(vr_index_rel618).vlrpagto,0),2);
                     vr_tab_rel618(vr_index_rel618).vldescar:= 0;

                   END IF;

                 ELSIF TRUNC(vr_vlliquid,2) > TRUNC(vr_vlfatura,2) THEN
                   --Juros recebe valor liquidacao menos o valor fatura
                   vr_vlrjuros:= nvl(vr_vlrjuros,0) + (nvl(vr_vlliquid,0) - nvl(vr_vlfatura,0));
                 END IF;
                 --Determinar o tipo de liquidacao
                 CASE SUBSTR(vr_setlinha,50,1)
                   WHEN '1' THEN vr_dsmotivo:= '03'; /*Liquidaçao no Guiche de Caixa*/
                   WHEN '2' THEN vr_dsmotivo:= '32'; /*Liquidaçao Terminal de Auto-Atendimento*/
                   WHEN '3' THEN vr_dsmotivo:= '33'; /*Liquidaçao na Internet (Home banking)*/
                   WHEN '5' THEN vr_dsmotivo:= '31'; /*Liquidaçao Banco Correspondente*/
                   WHEN '6' THEN vr_dsmotivo:= '37'; /*Liquidaçao por Telefone*/
                   WHEN '7' THEN vr_dsmotivo:= '06'; /*Liquidaçao Arquivo Eletronico*/
                   ELSE NULL;
                 END CASE;
                 /* buscar banco/agencia origem do pagamento (Rafael) */
                 BEGIN
                   vr_cdagepag:= TO_NUMBER(TRIM(SUBSTR(vr_setlinha,57,4)));
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_cdbanpag:= rw_crapcop.cdbcoctl;
                     vr_cdagepag:= rw_crapcop.cdagectl;
                 END;
                 --Verificar nome da tela
                 IF pr_nmtelant = 'COMPEFORA' THEN
                   vr_dtmvtaux:= rw_crapdat.dtmvtoan;
                 ELSE
                   vr_dtmvtaux:= rw_crapdat.dtmvtolt;
                 END IF;

                 -- Flag para verificar pagamento a menor
                 vr_flamenor := (TRUNC(vr_vlliquid,2) < TRUNC(vr_vlfatura,2) AND NOT vr_liqaposb);

                 /* se nao for liquidacao de titulo já pago, entao liq normal */
                 IF NOT vr_liqaposb THEN

                   IF rw_crapcob.inemiten = 3 THEN
                     vr_aux_cdocorre := 76;
                   ELSE
                     vr_aux_cdocorre := 6;
                   END IF;

                   --Processar liquidacao
                   PAGA0001.pc_processa_liquidacao (pr_idtabcob     => rw_crapcob.rowid       --Rowid da Cobranca
                                                   ,pr_nrnosnum     => 0                      --Nosso Numero
                                                   ,pr_nrispbpg     => vr_nrispbif_rec        --Numero ISPB do pagador
                                                   ,pr_cdbanpag     => vr_cdbanpag            --Codigo banco pagamento
                                                   ,pr_cdagepag     => vr_cdagepag            --Codigo Agencia pagamento
                                                   ,pr_vltitulo     => nvl(rw_crapcob.vltitulo,0)    --Valor do titulo
                                                   ,pr_vlliquid     => 0                      --Valor Liquidacao
                                                   ,pr_vlrpagto     => nvl(vr_vlliquid,0)            --Valor pagamento
                                                   ,pr_vlabatim     => 0                      --Valor abatimento
                                                   ,pr_vldescto     => nvl(vr_vldescto,0) + nvl(vr_vlabatim,0)   --Valor desconto
                                                   ,pr_vlrjuros     => nvl(vr_vlrjuros,0) + nvl(vr_vlrmulta,0)   --Valor juros
                                                   ,pr_vloutdeb     => 0                      --Valor saida debito
                                                   ,pr_vloutcre     => 0                      --Valor saida credito
                                                   ,pr_dtocorre     => vr_dtmvtolt            --Data Ocorrencia
                                                   ,pr_dtcredit     => rw_crapdat.dtmvtolt    --Data Credito
                                                   ,pr_cdocorre     => vr_aux_cdocorre        --Codigo Ocorrencia
                                                   ,pr_dsmotivo     => vr_dsmotivo            --Descricao Motivo
                                                   ,pr_dtmvtolt     => vr_dtmvtaux            --Data movimento
                                                   ,pr_cdoperad     => '1'                    --Codigo Operador
                                                   ,pr_indpagto     => rw_crapcob.indpagto    --Indicador pagamento /* 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA */
                                                   ,pr_ret_nrremret => vr_nrretcoo            --Numero remetente
                                                   ,pr_nmtelant     => pr_nmtelant            --Verificar COMPEFORA
                                                   ,pr_cdcritic     => vr_cdcritic            --Codigo Critica
                                                   ,pr_dscritic     => vr_dscritic            --Descricao Critica
                                                   ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                                   ,pr_tab_descontar       => vr_tab_descontar);     --Tabela de titulos
                 ELSE

                   IF rw_crapcob.inemiten = 3 THEN
                     vr_aux_cdocorre := 77;
                   ELSE
                     vr_aux_cdocorre := 17;
                   END IF;

                   --Processar Liquidacao apos baixa
                   PAGA0001.pc_proc_liquid_apos_baixa (pr_idtabcob     => rw_crapcob.rowid       --Rowid da Cobranca
                                                      ,pr_nrnosnum     => 0                      --Nosso Numero
                                                      ,pr_nrispbpg     => vr_nrispbif_rec        --Numero ISPB do pagador
                                                      ,pr_cdbanpag     => vr_cdbanpag            --Codigo banco pagamento
                                                      ,pr_cdagepag     => vr_cdagepag            --Codigo Agencia pagamento
                                                      ,pr_vltitulo     => nvl(rw_crapcob.vltitulo,0)    --Valor do titulo
                                                      ,pr_vlliquid     => 0                      --Valor Liquidacao
                                                      ,pr_vlrpagto     => nvl(vr_vlliquid,0)            --Valor pagamento
                                                      ,pr_vlabatim     => 0                      --Valor abatimento
                                                      ,pr_vldescto     => nvl(vr_vldescto,0) + nvl(vr_vlabatim,0) --Valor desconto
                                                      ,pr_vlrjuros     => 0                      --Valor juros
                                                      ,pr_vloutdeb     => 0                      --Valor saida debito
                                                      ,pr_vloutcre     => 0                      --Valor saida credito
                                                      ,pr_dtocorre     => vr_dtmvtolt            --Data Ocorrencia
                                                      ,pr_dtcredit     => rw_crapdat.dtmvtolt    --Data Credito
                                                      ,pr_cdocorre     => vr_aux_cdocorre        --Codigo Ocorrencia
                                                      ,pr_dsmotivo     => vr_dsmotivo            --Descricao Motivo
                                                      ,pr_dtmvtolt     => vr_dtmvtaux            --Data movimento
                                                      ,pr_cdoperad     => '1'                    --Codigo Operador
                                                      ,pr_indpagto     => rw_crapcob.indpagto    --Indicador pagamento /* 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA */
                                                      ,pr_ret_nrremret => vr_nrretcoo            --Numero remetente
                                                      ,pr_cdcritic     => vr_cdcritic            --Codigo Critica
                                                      ,pr_dscritic     => vr_dscritic            --Descricao Critica
                                                      ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada); --Tabela lancamentos consolidada
                 END IF;

                 --Se ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR
                    vr_dscritic IS NOT NULL THEN

                   --Marcar como rejeitado
                   vr_flgrejei:= TRUE;

                   IF vr_dscritic IS NULL     AND
                      vr_cdcritic IS NOT NULL THEN
                     --monta mensagem de erro
                     vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

                   END IF;

                   -- Envio centralizado de log de erro
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                             ,pr_ind_tipo_log => 2 -- Erro tratato
                                             ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                             ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                 || vr_cdprogra || ' --> '||vr_dscritic
                                                                 || ' - Linha: '|| SUBSTR(vr_setlinha,151,10)
                                                                 || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx));

                   -- Incluir a regra para processamento do acordo - Renato Darosci - 30/09/2016
                   IF nvl(rw_crapcob.nrctremp,0) > 0 THEN 
                     vr_cdtipreg := 5; 
                   ELSIF vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'ACORDO' THEN
                     vr_cdtipreg := 5;
                   ELSE
                     vr_cdtipreg := 3;
                   END IF;
                   
                   
                   /* Criacao da tabela generica gncptit - utilizada na conciliacao */
                   BEGIN
                     INSERT INTO gncptit
                      (gncptit.cdcooper
                      ,gncptit.cdagenci
                      ,gncptit.dtmvtolt
                      ,gncptit.dtliquid
                      ,gncptit.cdbandst
                      ,gncptit.cddmoeda
                      ,gncptit.nrdvcdbr
                      ,gncptit.dscodbar
                      ,gncptit.tpcaptur
                      ,gncptit.cdagectl
                      ,gncptit.nrdolote
                      ,gncptit.nrseqdig
                      ,gncptit.vldpagto
                      ,gncptit.tpdocmto
                      ,gncptit.nrseqarq
                      ,gncptit.nmarquiv
                      ,gncptit.cdoperad
                      ,gncptit.hrtransa
                      ,gncptit.vltitulo
                      ,gncptit.cdtipreg
                      ,gncptit.flgconci
                      ,gncptit.flgpcctl
                      ,gncptit.cdcritic
                      ,gncptit.cdmotdev
                      ,gncptit.cdfatven
                      ,gncptit.nrispbds)
                     VALUES
                      (pr_cdcooper
                      ,0
                      ,vr_dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                      ,SUBSTR(vr_setlinha,01,44)
                      ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_tab_nmarqtel(idx)
                      ,vr_cdoperad
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                      ,vr_cdtipreg    /* Sua Remessa - Erro */
                      ,1              /* registro conciliado */
                      ,1              /* processou na central */
                      ,vr_cdcritic    /* integrado c/ erro */
                      ,0
                      ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                      ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   --Inicializar variavel erro
                   vr_cdcritic:= 0;
                   --Proxima Linha Arquivo
                   RAISE vr_exc_proximo;
                 END IF;

                 /* controle para lancamento consolidado na conta corrente */
                 vr_index_conv_arq:= lpad(rw_crapcop.cdcooper,10,'0')||
                                     lpad(vr_nrcnvcob,10,'0');
                 --Se nao existir na tabela memória
                 IF NOT vr_tab_conv_arq.EXISTS(vr_index_conv_arq) THEN
                   vr_tab_conv_arq(vr_index_conv_arq).cdcooper:= vr_tab_crapcco(vr_index_conv_arq).cdcooper;
                   vr_tab_conv_arq(vr_index_conv_arq).dtmvtolt:= rw_crapdat.dtmvtolt;
                   vr_tab_conv_arq(vr_index_conv_arq).cdagenci:= vr_tab_crapcco(vr_index_conv_arq).cdagenci;
                   vr_tab_conv_arq(vr_index_conv_arq).cdbccxlt:= vr_tab_crapcco(vr_index_conv_arq).cdbccxlt;
                   vr_tab_conv_arq(vr_index_conv_arq).nrdolote:= vr_tab_crapcco(vr_index_conv_arq).nrdolote;
                   vr_tab_conv_arq(vr_index_conv_arq).nrconven:= vr_tab_crapcco(vr_index_conv_arq).nrconven;
                 END IF;

                 --Atribuir tipo documento
                 vr_cdtipdoc:= SUBSTR(vr_setlinha, 148, 3);

                 -- Incluir a regra para processamento do acordo - Renato Darosci - 30/09/2016
                 IF nvl(rw_crapcob.nrctremp,0) > 0 THEN 
                   vr_cdtipreg := 5; 
                 ELSIF vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'ACORDO' THEN
                   vr_cdtipreg := 5;
                 ELSE
                   vr_cdtipreg := 4;
                 END IF;
                 
                 --Tipo documento
                 IF vr_cdtipdoc IN (140,144) THEN
                   vr_flgpgdda:= 1;
                 ELSE
                   vr_flgpgdda:= 0;
                 END IF;

                 BEGIN
                   INSERT INTO gncptit
                    (gncptit.cdcooper
                    ,gncptit.cdagenci
                    ,gncptit.dtmvtolt
                    ,gncptit.dtliquid
                    ,gncptit.cdbandst
                    ,gncptit.cddmoeda
                    ,gncptit.nrdvcdbr
                    ,gncptit.dscodbar
                    ,gncptit.tpcaptur
                    ,gncptit.cdagectl
                    ,gncptit.nrdolote
                    ,gncptit.nrseqdig
                    ,gncptit.vldpagto
                    ,gncptit.tpdocmto
                    ,gncptit.nrseqarq
                    ,gncptit.nmarquiv
                    ,gncptit.cdoperad
                    ,gncptit.hrtransa
                    ,gncptit.vltitulo
                    ,gncptit.cdtipreg
                    ,gncptit.flgconci
                    ,gncptit.flgpcctl
                    ,gncptit.cdcritic
                    ,gncptit.cdmotdev
                    ,gncptit.cdfatven
                    ,gncptit.flgpgdda
                    ,gncptit.nrispbds)
                  VALUES
                    (pr_cdcooper
                    ,0
                    ,vr_dtmvtolt
                    ,rw_crapdat.dtmvtolt
                    ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                    ,SUBSTR(vr_setlinha,01,44)
                    ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                    ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                    ,vr_tab_nmarqtel(idx)
                    ,vr_cdoperad
                    ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                    ,vr_cdtipreg    /* Sua Remessa */
                    ,1              /* registro conciliado */
                    ,0              /* processou na central */
                    ,0              /* integrado coop */
                    ,0
                    ,to_number(TRIM(SUBSTR(vr_setlinha,6,4)))
                    ,vr_flgpgdda
                    ,vr_nrispbif_rec);                           --> gncptit.nrispbds
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_cdcritic:= 0;
                     vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                     --Levantar Excecao
                     RAISE vr_exc_sair;
                 END;
               END IF; /* final tratamento para cobranca registrada */
             EXCEPTION
               WHEN vr_exc_proximo THEN
                 NULL;
               WHEN vr_exc_sair THEN
                 pc_grava_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                 --Desfazer transacao
                 --ROLLBACK TO save_trans;
                 --Sair Loop
                 --EXIT;
                 NULL;
               WHEN vr_exc_saida_2 THEN
                 --Desfazer transacao
                 ROLLBACK;
                 --Sair Loop
                 EXIT;
             END;
           END LOOP; --Fim Linhas Arquivo

           /* realiza liquidacao dos titulos descontados (se houver) */
           --Limpar tabela titulos
           vr_tab_titulos.DELETE;
           --Montar indice para acesso a tabela descontar
           vr_index_desc:= vr_tab_descontar.FIRST;
           WHILE vr_index_desc IS NOT NULL LOOP

             --Adicionar na tabela de titulo os descontados
             vr_index_titulo:= lpad(vr_tab_descontar(vr_index_desc).nrdconta,10,'0')||
                               lpad(vr_tab_titulos.count+1,10,'0');
             vr_tab_titulos(vr_index_titulo):= vr_tab_descontar(vr_index_desc);

             --Se for ultimo registro da conta
             IF vr_index_desc = vr_tab_descontar.LAST OR
               (vr_tab_descontar(vr_index_desc).nrdconta <>
                vr_tab_descontar(vr_tab_descontar.NEXT(vr_index_desc)).nrdconta) THEN
               --Limpar tabela erro
               vr_tab_erro2.DELETE;
               --Verificar nome da tela
               IF pr_nmtelant = 'COMPEFORA' THEN
                 vr_dtmvtaux:= rw_crapdat.dtmvtoan;
               ELSE
                 vr_dtmvtaux:= rw_crapdat.dtmvtolt;
               END IF;

               --Efetuar a baixa do titulo
               DSCT0001.pc_efetua_baixa_titulo (pr_cdcooper    => pr_cdcooper         --Codigo Cooperativa
                                               ,pr_cdagenci    => 0                   --Codigo Agencia
                                               ,pr_nrdcaixa    => 0                   --Numero Caixa
                                               ,pr_cdoperad    => 0                   --Codigo operador
                                               ,pr_dtmvtolt    => rw_crapdat.dtmvtolt --Data Movimento
                                               ,pr_idorigem    => 1  /*AYLLOS*/       --Identificador Origem pagamento
                                               ,pr_nrdconta    => vr_tab_descontar(vr_index_desc).nrdconta         --Numero da conta
                                               ,pr_indbaixa    => 1                   --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                               ,pr_tab_titulos => vr_tab_titulos      --Titulos a serem baixados
                                               ,pr_cdcritic    => vr_cdcritic         --Codigo Critica
                                               ,pr_dscritic    => vr_dscritic         --Descricao Critica
                                               ,pr_tab_erro    => vr_tab_erro2);      --Tabela erros
               --Se ocorreu erro
               IF vr_tab_erro2.Count > 0 THEN
                 FOR idx IN vr_tab_erro2.FIRST..vr_tab_erro2.LAST LOOP
                   --Buscar proxima sequencia de erro
                   vr_index_erro:= vr_tab_erro.COUNT+1;
                   vr_tab_erro(vr_index_erro):= vr_tab_erro2(idx);

                   -- Gera o log de erro
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> Erro retorno na DSTC0001: '||vr_tab_erro2(idx).dscritic);

                 END LOOP;
               END IF;
               --Limpar tabela titulos
               vr_tab_titulos.DELETE;
             END IF;
             --Proximo registro da tabela descontados
             vr_index_desc:= vr_tab_descontar.NEXT(vr_index_desc);
           END LOOP; --vr_tab_descontar

           --Se processou
           IF vr_lgdetail THEN
             -- Verifica se é um arquivo REPROC, e neste caso renomeia o arquivo que vai ser gravado 
             -- na pasta salvar, evitando dessa forma que o arquivo anterior seja sobrescrito
             IF vr_inreproc THEN
               -- Montar o nome do arquivo de REPROC
               vr_dsarqrep := SUBSTR(vr_tab_nmarqtel(idx),0,(INSTR(vr_tab_nmarqtel(idx),'.',-1)-1)) -- Nome do arquivo
                              ||'_REP_'||GENE0002.fn_busca_time                                 -- Sufixo: REP + Time
                              ||SUBSTR(vr_tab_nmarqtel(idx),INSTR(vr_tab_nmarqtel(idx),'.',-1));    -- Extensão do arquivo
               /*  Move arquivo integrado para o diretorio salvar  */
               vr_comando:= 'mv '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx)||' '||vr_caminho_salvar||'/'||vr_dsarqrep;
             ELSE
             --Move Arquivo diretorio salvar
             vr_comando:= 'mv '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx)||' '||vr_caminho_salvar||' 2> /dev/null';

             END IF;
             
             /* Não deve mais executar o comando neste momento!!!
             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
               RAISE vr_exc_saida;
             END IF;*/
           ELSE
             --Excluir arquivo do integra
             vr_comando:= 'rm '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx)||' 2> /dev/null';

             /* Não deve mais executar o comando neste momento!!!
             --Executar o comando no unix
             GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
               RAISE vr_exc_saida;
             END IF;*/
           END IF;

           -- Guardar o comando para ser executado ao término da execução
           vr_tab_comando(vr_tab_comando.count() + 1) := vr_comando;

           -- Como o arquivo ja foi processado, efetua o commit
           -- ***** COMMIT; *** Não deve efetuar o comite neste ponto, pois o mesmo deve
           -- ser executado apenas ao término de todo processamento

           --Se houve rejeitado
           IF vr_flgrejei THEN
             vr_cdcritic:= 191;
           ELSE
             vr_cdcritic:= 190;
           END IF;
           --Buscar descricao da critica
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx));
         END LOOP; --Contador arquivos

         /**************************************************************/
         /*************TRATAMENTO P/ COBRANCA REGISTRADA****************/

         --Verificar nome da tela
         IF pr_nmtelant = 'COMPEFORA' THEN
           vr_dtmvtaux:= rw_crapdat.dtmvtoan;
           --Data Pagamento
           vr_dtdpagto:= rw_crapdat.dtmvtoan;
         ELSE
           vr_dtmvtaux:= rw_crapdat.dtmvtolt;
           --Data Pagamento
           vr_dtdpagto:= rw_crapdat.dtmvtolt;
         END IF;

         -- 1o processamento
         /* Busca todos os convenios da IF CECRED que foram gerados pela internet */
         FOR rw_crapcco IN cr_crapcco_ativo (pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cddbanco => rw_crapcop.cdbcoctl) LOOP


           /************************************************************
            Realizar lançamentos dos creditos do movimento D-0
           *************************************************************/
           -- Determinar a data do pagamento
           IF pr_nmtelant = 'COMPEFORA' THEN
             --Dia Anterior
             vr_dtcredit:= rw_crapdat.dtmvtoan;
           ELSE
             --Data Atual
             vr_dtcredit:= rw_crapdat.dtmvtolt;
           END IF;

           /************************************************************************
           *****      ###############  TRATAMENTO REPROC  ###############      *****
           ** ESTE TRATAMENTO FOI INCLUSO NO PROGRAMA, PARA EVITAR PROCESSAMENTO  **
           ** INDEVIDO DE PAGAMENTOS DE EMPRESTIMOS E ACORDO, QUANDO OCORRER O    ** 
           ** PROCESSAMENTO DE ARQUIVOS DE REPROC. ESTE TIPO DE PROCESSAMENTO É   ** 
           ** ATIPICO E OCORRERÁ APENAS EM SITUAÇÕES MUITO PONTUAIS.              **
           ************************************************************************/
           -- Se for emprestimo ou acordo e estiver processando em modo de REPROC
           IF rw_crapcco.dsorgarq IN ('EMPRESTIMO','ACORDO') AND vr_inreproc THEN
             -- Atualizar os registros da CRAPRET para não processar em duplicidade
             BEGIN
               UPDATE crapret 
                  SET flcredit = 2
                WHERE cdcooper = rw_crapcco.cdcooper
                  AND nrcnvcob = rw_crapcco.nrconven
                  AND dtcredit = vr_dtcredit 
                  AND flcredit = 1;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao alterar CRAPRET: '||SQLERRM;
                 RAISE vr_exc_saida;
             END;
           END IF;
           /*************************************/
           
           PAGA0001.pc_valores_a_creditar( pr_cdcooper => rw_crapcco.cdcooper
                                          ,pr_nrcnvcob => rw_crapcco.nrconven
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_dtcredit => vr_dtcredit
                                          ,pr_idtabcob => NULL
                                          ,pr_nmtelant => pr_nmtelant
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                          ,pr_cdprogra => vr_cdprogra           --Nome Programa
                                          ,pr_cdcritic => vr_cdcritic           --Codigo da Critica
                                          ,pr_dscritic => vr_dscritic);         --Descricao da critica

           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

           /* Altera tabela craprtc */
           --Determinar a data do protesto
           IF pr_nmtelant = 'COMPEFORA' THEN
             --Dia Anterior
             vr_dtmvtaux:= rw_crapdat.dtmvtoan;
           ELSE
             --Data Atual
             vr_dtmvtaux:= rw_crapdat.dtmvtolt;
           END IF;

           PAGA0001.pc_realiza_lancto_cooperado (pr_cdcooper => rw_crapcco.cdcooper --Codigo Cooperativa
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                                ,pr_cdagenci => rw_crapcco.cdagenci --Codigo Agencia
                                                ,pr_cdbccxlt => rw_crapcco.cdbccxlt --Codigo banco caixa
                                                ,pr_nrdolote => rw_crapcco.nrdolote --Numero do Lote
                                                ,pr_cdpesqbb => rw_crapcco.nrconven --Codigo Convenio
                                                ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                                ,pr_dscritic => vr_dscritic         --Descricao Critica
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada);        --Tabela Lancamentos
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
           /*************************************************************/

           IF rw_crapcco.dsorgarq = 'EMPRESTIMO' THEN

              FOR rw_cde IN cr_cde (pr_cdcooper => rw_crapcco.cdcooper
                                 ,pr_nrcnvcob => rw_crapcco.nrconven
                                 ,pr_dtocorre => vr_dtcredit) LOOP

                  IF pr_nmtelant = 'COMPEFORA' AND NOT vr_email_compefora THEN

                     vr_email_proc_cred := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                     pr_cdcooper => pr_cdcooper,
                                                                     pr_cdacesso => 'EMAIL_PROCESSUAL_CREDITO');

                     -- Se não encontrar e-mail cadastrado no parametro, deve mandar
                     -- para o e-mail do processual de credito
                     IF vr_email_proc_cred IS NULL THEN
                       vr_email_proc_cred := 'processualdecredito@cecred.coop.br';
                     END IF;

                     /* Envio do arquivo detalhado via e-mail */
                     gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                               ,pr_cdprogra        => vr_cdprogra
                                               ,pr_des_destino     => vr_email_proc_cred
                                               ,pr_des_assunto     => 'Pagtos de emprestimos com boleto (COMPEFORA) - ' || rw_crapcop.nmrescop
                                               ,pr_des_corpo       => 'Favor verificar pagtos de emprestimos com boleto atraves dos relatorios do BI.'
                                               ,pr_des_anexo       => NULL
                                               ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                               ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                               ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                               ,pr_des_erro        => vr_dscritic);

                     vr_email_compefora := TRUE;
                  END IF;

                    -- se o pagto do boleto foi creditado, entao pagar o contrato
                  IF rw_cde.flcredit = 1 THEN
                    BEGIN
                      EMPR0007.pc_pagar_epr_cobranca (pr_cdcooper => rw_cde.cdcooper
                                                     ,pr_nrdconta => rw_cde.nrdconta
                                                     ,pr_nrctremp => rw_cde.nrctremp
                                                     ,pr_nrcnvcob => rw_cde.nrcnvcob
                                                     ,pr_nrdocmto => rw_cde.nrboleto
                                                     ,pr_vldpagto => rw_cde.vlrpagto
                                                     ,pr_idorigem => 7 -- 7) Batch
                                                     ,pr_nmtelant => pr_nmtelant
                                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                     ,pr_cdoperad => '1'
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Erro
                        vr_cdcritic:= 0;
                        vr_dscritic:= 'Erro nao tratado - '||sqlerrm;
                    END;
                  ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Boleto nao creditado';
                  END IF;

                  -- se ocorreu alguma critica de pagto de emprestimo, registrar no boleto
                  IF vr_dscritic IS NOT NULL THEN
                     PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_cde.cob_rowid               --ROWID da Cobranca
                                                  ,pr_cdoperad => 'PAGAEPR'                      --Operador
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt            --Data movimento
                                                  ,pr_dsmensag => 'Erro: ' || substr(vr_dscritic,1,100) --Descricao Mensagem
                                                  ,pr_des_erro => vr_des_erro                    --Indicador erro
                                                  ,pr_dscritic => vr_dscritic2);                  --Descricao erro
                  ELSE
                     PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_cde.cob_rowid               --ROWID da Cobranca
                                                  ,pr_cdoperad => vr_cdoperad                    --Operador
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt            --Data movimento
                                                  ,pr_dsmensag => 'Pagto realizado ref ao contrato ' ||
                                                                  to_char(rw_cde.nrctremp) || (CASE WHEN TRIM(pr_nmtelant) IS NULL THEN ' ' ELSE ' - COMPEFORA' END) --Descricao Mensagem
                                                  ,pr_des_erro => vr_des_erro                    --Indicador erro
                                                  ,pr_dscritic => vr_dscritic2);                  --Descricao erro
                  END IF;

                     vr_index_rel706 := to_char(rw_cde.cdcooper,'fm000') ||
                                     to_char(rw_cde.cdagenci,'fm00000') ||
                                        to_char(rw_cde.nrdconta,'fm00000000') ||
                                        to_char(rw_cde.nrcnvcob,'fm0000000') ||
                                        to_char(rw_cde.nrboleto,'fm000000000') ||
                                        to_char(vr_tab_rel706.count() + 1, 'fm000000');

                     vr_tab_rel706(vr_index_rel706).cdagenci := rw_cde.cdagenci;
                     vr_tab_rel706(vr_index_rel706).nrdconta := nvl(rw_cde.nrdconta,0);
                     vr_tab_rel706(vr_index_rel706).nrcnvcob := rw_cde.nrcnvcob;
                     vr_tab_rel706(vr_index_rel706).nrdocmto := rw_cde.nrboleto;
                     vr_tab_rel706(vr_index_rel706).nrctremp := rw_cde.nrctremp;
                     vr_tab_rel706(vr_index_rel706).dsdoccop := rw_cde.dsdoccop;
                     vr_tab_rel706(vr_index_rel706).tpparcel := nvl(rw_cde.tpparcela,0);
                  vr_tab_rel706(vr_index_rel706).dtvencto := rw_cde.dtvencto;
                  vr_tab_rel706(vr_index_rel706).vltitulo := rw_cde.vltitulo;
                     vr_tab_rel706(vr_index_rel706).vldpagto := rw_cde.vlrpagto;

                  IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                     vr_tab_rel706(vr_index_rel706).dscritic := 'Erro: ' || substr(nvl(vr_dscritic,' '),1,90);
                  ELSE
                     vr_tab_rel706(vr_index_rel706).dscritic := 'OK';
                  END IF;

                  vr_cdcritic := NULL;
                  vr_dscritic := NULL;

              END LOOP;

           ELSIF rw_crapcco.dsorgarq = 'ACORDO' THEN
             -- Percorrer boletos dos acordos pagos na cobranca para serem regularizados
             FOR rw_boletos_pagos_acordos IN cr_boletos_pagos_acordos (pr_cdcooper => rw_crapcco.cdcooper
                                                                      ,pr_nrcnvcob => rw_crapcco.nrconven
                                                                      ,pr_dtocorre => vr_dtcredit)   LOOP
                                        					 
               BEGIN
                 -- Efetuar o pagamento do acordo
                 RECP0001.pc_pagar_contrato_acordo(pr_nracordo => rw_boletos_pagos_acordos.nracordo
                                                  ,pr_nrparcel => rw_boletos_pagos_acordos.nrparcela
                                                  ,pr_vlparcel => rw_boletos_pagos_acordos.vlrpagto
                                                  ,pr_cdoperad => 1 -- usuário master
                                                  ,pr_idorigem => 1 -- Ayllos
                                                  ,pr_nmtelant => pr_nmtelant
                                                  ,pr_vltotpag => vr_vltotpag
                                                  ,pr_cdcritic => vr_cdcritic
                                                  ,pr_dscritic => vr_dscritic);
                                                  
                 -- Se retornar erro
                 IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                 END IF;

               EXCEPTION
                 WHEN OTHERS THEN
                   -- Erro
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro nao tratado - '||sqlerrm;
               END;					
                                        	
               -- se ocorreu alguma critica de pagto de emprestimo, registrar no boleto
               IF vr_dscritic IS NOT NULL THEN
                 PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_boletos_pagos_acordos.cob_rowid    --ROWID da Cobranca
                                              ,pr_cdoperad => 'PAGAACORDO'                   		    --Operador
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt            		    --Data movimento
                                              ,pr_dsmensag => 'Erro: ' || substr(vr_dscritic,1,100) --Descricao Mensagem
                                              ,pr_des_erro => vr_des_erro                    		    --Indicador erro
                                              ,pr_dscritic => vr_dscritic2);                  	    --Descricao erro
               ELSE
                 PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_boletos_pagos_acordos.cob_rowid    --ROWID da Cobranca
                                              ,pr_cdoperad => vr_cdoperad                    		  --Operador
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt           	 	  --Data movimento
                                              ,pr_dsmensag => 'Pagto realizado ref ao acordo ' || to_char(rw_boletos_pagos_acordos.nracordo) ||
                                                              (CASE WHEN TRIM(pr_nmtelant) IS NULL THEN ' ' ELSE ' - COMPEFORA' END) --Descricao Mensagem
                                              ,pr_des_erro => vr_des_erro                    		  --Indicador erro
                                              ,pr_dscritic => vr_dscritic2);                 		  --Descricao erro
               END IF;			  
             END LOOP;  
           END IF;
           /************************************************************************
           *****      ###############  TRATAMENTO REPROC  ###############      *****
           ** ESTE TRATAMENTO FOI INCLUSO NO PROGRAMA, PARA EVITAR PROCESSAMENTO  **
           ** INDEVIDO DE PAGAMENTOS DE EMPRESTIMOS E ACORDO, QUANDO OCORRER O    ** 
           ** PROCESSAMENTO DE ARQUIVOS DE REPROC. ESTE TIPO DE PROCESSAMENTO É   ** 
           ** ATIPICO E OCORRERÁ APENAS EM SITUAÇÕES MUITO PONTUAIS.              **
           ************************************************************************/
           -- Se for emprestimo ou acordo e estiver processando em modo de REPROC
           IF rw_crapcco.dsorgarq IN ('EMPRESTIMO','ACORDO') AND vr_inreproc THEN
             -- Atualizar os registros da CRAPRET para não processar em duplicidade
             BEGIN
               UPDATE crapret 
                  SET flcredit = 1
                WHERE cdcooper = rw_crapcco.cdcooper
                  AND nrcnvcob = rw_crapcco.nrconven
                  AND dtcredit = vr_dtcredit  
                  AND flcredit = 2;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao alterar CRAPRET: '||SQLERRM;
                 RAISE vr_exc_saida;
             END;
           END IF;

         END LOOP;

         -- Não deve executar o 2o processamento quando for execução de arquivo REPROC (Renato Darosci - 11/10/2016)
         IF NOT vr_inreproc THEN
         -- 2o processamento
         /* Busca todos os convenios da IF CECRED que foram gerados pela internet */
         FOR rw_crapcco IN cr_crapcco_ativo (pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cddbanco => rw_crapcop.cdbcoctl) LOOP

           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Processando baixas e protestos  : convenio ' || to_char(rw_crapcco.nrconven) );

               IF pr_nmtelant = 'COMPEFORA' THEN
                 --Data Atual
                 vr_dtmvtaux:= rw_crapdat.dtmvtoan;
             vr_dtmvtpro:= rw_crapdat.dtmvtolt;
               ELSE
                 --Proximo Dia Util
                 vr_dtmvtaux:= rw_crapdat.dtmvtolt;
             vr_dtmvtpro:= rw_crapdat.dtmvtopr;
               END IF;

           FOR idx IN 0..7 LOOP

             FOR idxprt IN 5..15 LOOP
               FOR rw_crapcob IN cr_crapcob_prot (pr_cdcooper => rw_crapcco.cdcooper
                                                 ,pr_nrconven => rw_crapcco.nrconven
                                                 ,pr_dtvencto => TRUNC(vr_dtmvtaux) - (idxprt + idx)
                                                 ,pr_incobran => 0 /*aberto*/
                                                 ,pr_qtdiaprt => idxprt) LOOP
                 /* que devem ser protestados */
                 IF nvl(rw_crapcob.flgdprot,0) = 1 AND nvl(rw_crapcob.flgregis,0) = 1 THEN
               /* Validar se chegou no limite de protesto
                   Data de vencimento conta como data pro protesto */
               IF (rw_crapcob.dtvencto + rw_crapcob.qtdiaprt) <= vr_dtmvtaux THEN
                 /* Gerar Protesto */
                 COBR0007.pc_inst_protestar (pr_cdcooper => pr_cdcooper           --Codigo Cooperativa
                                            ,pr_nrdconta => rw_crapcob.nrdconta   --Numero da Conta
                                            ,pr_nrcnvcob => rw_crapcob.nrcnvcob   --Numero Convenio
                                            ,pr_nrdocmto => rw_crapcob.nrdocmto   --Numero Documento
                                            ,pr_cdocorre => 9 /* cdocorre */      --Codigo da ocorrencia
                                            ,pr_cdtpinsc => rw_crapcob.cdtpinsc   --Tipo Inscricao
                                                ,pr_dtmvtolt => vr_dtmvtpro           --Data pagamento
                                            ,pr_cdoperad => vr_cdoperad           --Operador
                                            ,pr_nrremass => 0                     --Numero da Remessa
                                            ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --Tabela
                                            ,pr_cdcritic => vr_cdcritic           --Codigo da Critica
                                            ,pr_dscritic => vr_dscritic);         --Descricao da critica

                 --Se ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   /* Alterado para não apresentar a critica no log, e sim salvar no log de cobrança */
                   PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid            --ROWID da Cobranca
                                                  ,pr_cdoperad => vr_cdoperad               --Operador
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt       --Data movimento
                                                  ,pr_dsmensag => 'Protesto nao efetuado: '||
                                                                  vr_dscritic               --Descricao Mensagem
                                                  ,pr_des_erro => vr_des_erro               --Indicador erro
                                                  ,pr_dscritic => vr_dscritic);

                   --Inicializar variavel erro
                   vr_cdcritic:= NULL;
                   vr_dscritic:= NULL;
                 END IF;
               END IF;
               END IF;
               END LOOP;
             END LOOP;

             FOR rw_crapcob IN cr_crapcob_aberto (pr_cdcooper => rw_crapcco.cdcooper
                                                 ,pr_nrconven => rw_crapcco.nrconven
                                                 ,pr_dtvencto => TRUNC(rw_crapdat.dtmvtolt) -idx
                                                 ,pr_incobran => 0 /*aberto*/) LOOP
               -- se o titulo for DDA e emissao apos 17/03/2012 e vencido
               -- a 59 dias,  baixar por decurso de prazo */
               IF ( (nvl(rw_crapcob.flgregis,0) = 1 AND
                  rw_crapcob.dtmvtolt < TO_DATE('03/17/2012','MM/DD/YYYY')  AND nvl(rw_crapcob.flgcbdda,0) = 1 AND
                 (rw_crapcob.dtvencto + rw_crapcob.qtdecprz + 6) <= vr_dtmvtaux) OR

                 -- se o titulo estiver vencido a 59 dias e nao for DDA ou
                 (nvl(rw_crapcob.flgregis,0) = 1 AND nvl(rw_crapcob.flgcbdda,-1) = 0 AND
                 (rw_crapcob.dtvencto + rw_crapcob.qtdecprz) <= vr_dtmvtaux) OR

                 -- se o titulo for DDA e emissao apos 17/03/2012 e vencido
                 -- a 59 dias,  baixar por decurso de prazo
                 (nvl(rw_crapcob.flgregis,0) = 1 AND
                  rw_crapcob.dtmvtolt >= TO_DATE('03/17/2012','MM/DD/YYYY') AND nvl(rw_crapcob.flgcbdda,0) = 1 AND
                 (rw_crapcob.dtvencto + rw_crapcob.qtdecprz) <= vr_dtmvtaux) OR

                 -- se o boleto eh de emprestimo, venceu no dia e nao foi pago, baixar por decurso de prazo
                 (rw_crapcco.dsorgarq = 'EMPRESTIMO' AND rw_crapcob.dtvencto <= rw_crapdat.dtmvtolt) ) AND

                 -- Se o boleto é de acordo, não será baixado por decurso de prazo, pois a baixa 
                 -- acontece apenas no momento de quebra do acordo
                 (rw_crapcco.dsorgarq <> 'ACORDO' ) AND
                 
                 -- não pode-se baixar caso o crapcob.inserasa for 1 (Pendente automática) ou
                 -- 2 (Pendente manual) ou 3 (Solicitação enviada) ou 4 (Sol. Cancel. Enviadas)
                 -- 5 (Negativada) ou 7 (Ação Judicial)
                 rw_crapcob.inserasa NOT IN (1,2,3,4,5,7) THEN


                 IF rw_crapcco.dsorgarq = 'EMPRESTIMO' THEN
                   IF pr_nmtelant = 'COMPEFORA' THEN
                     vr_dtmvtpro:= rw_crapdat.dtmvtoan;
                   ELSE
                     vr_dtmvtpro:= rw_crapdat.dtmvtolt;
                   END IF;
                 ELSE
                 --Determinar a data do protesto
                 IF pr_nmtelant = 'COMPEFORA' THEN
                   vr_dtmvtpro:= rw_crapdat.dtmvtolt;
                 ELSE
                   vr_dtmvtpro:= rw_crapdat.dtmvtopr;
                   END IF;
                 END IF;

                 --Baixar titulo por decurso de prazo
                 COBR0007.pc_inst_pedido_baixa_decurso (pr_cdcooper => rw_crapcob.cdcooper   --Codigo Cooperativa
                                                       ,pr_nrdconta => rw_crapcob.nrdconta   --Numero da Conta
                                                       ,pr_nrcnvcob => rw_crapcob.nrcnvcob   --Numero Convenio
                                                       ,pr_nrdocmto => rw_crapcob.nrdocmto   --Numero Documento
                                                       ,pr_cdocorre => 2                     --Codigo da ocorrencia
                                                       ,pr_dtmvtolt => vr_dtmvtpro           --Data pagamento
                                                       ,pr_cdoperad => vr_cdoperad           --Operador
                                                       ,pr_nrremass => 0                     --Numero da Remessa
                                                       ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --Tabela
                                                       ,pr_cdcritic => vr_cdcritic           --Codigo da Critica
                                                       ,pr_dscritic => vr_dscritic);         --Descricao da critica

                 --Se ocorreu erro
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   /* Alterado para não apresentar a critica no log, e sim salvar no log de cobrança */
                   PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid            --ROWID da Cobranca
                                                  ,pr_cdoperad => vr_cdoperad               --Operador
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt       --Data movimento
                                                  ,pr_dsmensag => 'Baixa por por decurso de prazo nao efetuada: '||
                                                                  vr_dscritic               --Descricao Mensagem
                                                  ,pr_des_erro => vr_des_erro               --Indicador erro
                                                  ,pr_dscritic => vr_dscritic);

                   --Inicializar variavel erro
                   vr_cdcritic:= NULL;
                   vr_dscritic:= NULL;
                 END IF;
               END IF;
             END LOOP;

           END LOOP;

           --Determinar a data para arquivo de retorno
           IF pr_nmtelant = 'COMPEFORA' THEN
             --Data Atual
             vr_dtmvtaux:= rw_crapdat.dtmvtoan;
           ELSE
             --Proximo Dia Util
             vr_dtmvtaux:= rw_crapdat.dtmvtolt;
           END IF;

           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Gerando arq retorno ao cooperado: convenio ' || to_char(rw_crapcco.nrconven) );

           /* Gerar e enviar arquivo de retorno para o cooperado */
           PAGA0001.pc_gera_arq_cooperado (pr_cdcooper => rw_crapcco.cdcooper   --Codigo Cooperativa
                                          ,pr_nrcnvcob => rw_crapcco.nrconven   --Numero Convenio
                                          ,pr_nrdconta => 0                     --Numero da Conta
                                          ,pr_dtmvtolt => vr_dtmvtaux           --Data pagamento
                                          ,pr_idorigem => 1  /* AYLLOS */       --Identificador Origem
                                          ,pr_flgproce => 0  /* false */         --Flag Processo
                                          ,pr_cdprogra => vr_cdprogra           --Nome Programa
                                          ,pr_tab_arq_cobranca => vr_tab_arq_cobranca --Tabela Cobranca
                                          ,pr_cdcritic => vr_cdcritic           --Codigo da Critica
                                          ,pr_dscritic => vr_dscritic);         --Descricao da critica
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

         END LOOP;

         -- Limpar lancamentos de debitos e creditos
         -- para efetuar os creditos do movimento D+1
         vr_tab_lcm_consolidada.delete;

         /* Busca todos os convenios da IF CECRED que foram gerados pela internet */
         FOR rw_crapcco IN cr_crapcco_ativo (pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cddbanco => rw_crapcop.cdbcoctl) LOOP

           /************************************************************
            Realizar lançamentos dos creditos do movimento D+1
           *************************************************************/
           -- Determinar a data do pagamento
           IF pr_nmtelant = 'COMPEFORA' THEN
             --Dia Atual
             vr_dtcredit:= rw_crapdat.dtmvtolt;
           ELSE
             --Data do dia
             vr_dtcredit:= rw_crapdat.dtmvtopr;
           END IF;

           PAGA0001.pc_valores_a_creditar( pr_cdcooper => rw_crapcco.cdcooper
                                          ,pr_nrcnvcob => rw_crapcco.nrconven
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_dtcredit => vr_dtcredit
                                          ,pr_idtabcob => NULL
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                          ,pr_nmtelant => pr_nmtelant
                                          ,pr_cdprogra => vr_cdprogra           --Nome Programa
                                          ,pr_cdcritic => vr_cdcritic           --Codigo da Critica
                                          ,pr_dscritic => vr_dscritic);         --Descricao da critica

           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

           PAGA0001.pc_realiza_lancto_cooperado (pr_cdcooper => rw_crapcco.cdcooper --Codigo Cooperativa
                                                ,pr_dtmvtolt => vr_dtcredit         --Data Movimento
                                                ,pr_cdagenci => rw_crapcco.cdagenci --Codigo Agencia
                                                ,pr_cdbccxlt => rw_crapcco.cdbccxlt --Codigo banco caixa
                                                ,pr_nrdolote => rw_crapcco.nrdolote --Numero do Lote
                                                ,pr_cdpesqbb => rw_crapcco.nrconven --Codigo Convenio
                                                ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                                ,pr_dscritic => vr_dscritic         --Descricao Critica
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada);        --Tabela Lancamentos
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
         END LOOP;

           
           --> Comandar baixa efetiva de boletos pagos no dia fora da cooperativo(interbancaria)
           COBR0010.pc_gera_baixa_eft_interbca (pr_cdcooper => pr_cdcooper,   --> Cooperativa
                                                pr_dtmvtolt => vr_dtmvtaux,   --> Data
                                                pr_cdcritic => vr_cdcritic,   --> Codigo da Critica
                                                pr_dscritic => vr_dscritic);  --> Descricao Critica
         
           --> Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --> Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

         END IF; -- Fim REPROC
         
         /*  RETIRADO O PROCESSAMENTO DE LIQUIDAÇÃO INTRABANCÁRIA (Renato Darosci - 11/10/2016)
         --Verificar nome da tela
         IF pr_nmtelant = 'COMPEFORA' THEN
           vr_dtmvtaux:= rw_crapdat.dtmvtoan;
           --Data Pagamento
           vr_dtdpagto:= rw_crapdat.dtmvtoan;
         ELSE
           vr_dtmvtaux:= rw_crapdat.dtmvtolt;
           --Data Pagamento
           vr_dtdpagto:= rw_crapdat.dtmvtolt;
         END IF; */

         /*************TRATAMENTO P/ COBRANCA REGISTRADA****************/
         /**************************************************************/

         --Inicializar Variaveis
         vr_cdcritic:= 0;
         vr_contador:= 1;

         --Gerar relatorio 574
         pc_gera_relatorio_574 (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
         --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

           --Gerar relatorio 605
           pc_gera_relatorio_605 (pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

           pc_gera_relatorio_686 (pr_nmtelant => pr_nmtelant
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

           --Se existem dados no relatorio 618
           IF vr_tab_rel618.count > 0 THEN
             --Gerar relatorio 618
             pc_gera_relatorio_618 (pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
           END IF;

           --Se existem dados no relatorio 706
           IF vr_tab_rel706.count > 0 THEN
             --Gerar relatorio 706
             pc_gera_relatorio_706 (pr_cdcooper => pr_cdcooper
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
           END IF;

           pc_gerar_arq_devolucao(pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

         --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
       EXCEPTION
         WHEN vr_exc_final THEN
           -- Nao tem arquivo para processar ou foi encontrado mais de um arquivo
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;
         WHEN vr_exc_saida THEN
           pr_cdcritic:= vr_cdcritic;
           pr_dscritic:= vr_dscritic;
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_crps538.pc_integra_cecred. '||sqlerrm;
       END pc_integra_cecred;

       --Integrar Todas as cooperativas
       PROCEDURE pc_integra_todas_coop (pr_cdcritic OUT INTEGER
                                       ,pr_dscritic OUT VARCHAR2) IS
         --Cursores Locais
         CURSOR cr_craprej_523 (pr_cdcooper IN craprej.cdcooper%type
                               ,pr_dtmvtolt IN craprej.dtmvtolt%type
                               ,pr_cdagenci IN craprej.cdagenci%type) IS
           SELECT craprej.vllanmto
                 ,craprej.cdpesqbb
                 ,craprej.nrseqdig
                 ,craprej.dshistor
                 ,craprej.cdcritic
                 ,craprej.rowid
           FROM craprej
           WHERE craprej.cdcooper = pr_cdcooper
           AND   craprej.dtmvtolt = pr_dtmvtolt
           AND   craprej.cdagenci = pr_cdagenci
           ORDER BY craprej.nrseqdig;
         --Variaveis Locais
         vr_flpdfcopi  VARCHAR2(1);
         vr_flgimprime VARCHAR2(1);
         vr_dsparam    VARCHAR2(1000);
         --Variaveis Excecao
         vr_exc_proximo EXCEPTION;
         vr_exc_sair    EXCEPTION;
       BEGIN
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;

         --Inicializar contador
         vr_contador:= 0;

         /* Remove os arquivos ".q" caso existam */
         vr_comando:= 'rm '||vr_caminho_integra||'/'||replace(vr_nmarqrem,'%','*')||'.q 2> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
         --Se ocorreu erro dar RAISE
         /*IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
         END IF;*/ -- Nao dar erro se os arquivos nao existem

         --Listar arquivos no diretorio
         gene0001.pc_lista_arquivos (pr_path     => vr_caminho_integra
                                    ,pr_pesq     => vr_nmarqrem
                                    ,pr_listarq  => vr_listadir
                                    ,pr_des_erro => vr_dscritic );
         --Se ocorreu erro
         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         
         --Montar vetor com nomes dos arquivos
         vr_tab_nmarqtel:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

         vr_contador:= vr_tab_nmarqtel.COUNT;
         --Se nao encontrou arquivos
         IF vr_contador <= 0 THEN
           -- Montar mensagem de critica
           vr_cdcritic:= 182;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||vr_dscritic
                                                       || ' - Arquivo: integra/'||vr_nmarqrem );
           --Sair Normal, nao tem nada para processar
           RAISE vr_exc_final;
         END IF;
         /*  Fim da verificacao se deve executar  */

         --Percorrer todos os arquivos
         FOR idx IN 1..vr_contador LOOP

           --Zerar Critica
           vr_cdcritic:= 0;
           --Zerar totalizadores
           vr_tot_qtregrec:= 0;
           vr_tot_vlregrec:= 0;
           vr_tot_qtregint:= 0;
           vr_tot_vlregint:= 0;
           vr_tot_qtregrej:= 0;
           vr_tot_vlregrej:= 0;

           /* Verificar se o arquivo esta completo */
           vr_comando:= 'tail -2 '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx);

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_setlinha);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             RAISE vr_exc_saida;
           END IF;
           --Verificar linha controle
           IF SUBSTR(vr_setlinha,01,10) <> '9999999999' AND
              SUBSTR(vr_setlinha,162,10) <> '9999999999' THEN
             --Codigo erro
             vr_cdcritic:= 258;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
             --Zerar variavel critica
             vr_cdcritic:= 0;
           END IF;

           /* Verificar o Header */

           -- Comando para listar a primeira linha do arquivo
           vr_comando:= 'head -1 ' ||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx);

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_setlinha);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             RAISE vr_exc_saida;
           END IF;
           --Montar Tipo Cobranca
           vr_dstipcob:= SUBSTR(vr_setlinha,48,6);
           --Montar Data Arquivo
           vr_dtleiaux:= SUBSTR(vr_setlinha,66,8);

           /* Verifica cada linha do arquivo importado */
           IF vr_dstipcob <> 'COB605' THEN
             vr_cdcritic:= 181;
           ELSIF SUBSTR(vr_setlinha,61,3) <> vr_cdbanctl THEN
             vr_cdcritic:= 57;
           ELSIF vr_dtleiaux <> vr_dtleiarq THEN
             vr_cdcritic:= 13;
           END IF;
           --Converter a data do arquivo lido
           BEGIN
             vr_dtarquiv:= TO_DATE(SUBSTR(vr_setlinha,66,8),'YYYYMMDD');
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 173;
           END;
           
           --Se ocorreu algum erro na validacao
           IF vr_cdcritic <> 0 THEN
             --Buscar descricao da critica
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
             --Zerar variavel critica
             vr_cdcritic:= 0;
             --Ir para proximo arquivo
             CONTINUE;
           END IF;

           /* Nao ocorreu erro nas validacoes, abrir o arquivo e processar as linhas */

           --Abrir o arquivo de dados e pular a primeira linha
           gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_integra  --> Diretorio do arquivo
                                   ,pr_nmarquiv => vr_tab_nmarqtel(idx) --> Nome do arquivo
                                   ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                   ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                   ,pr_des_erro => vr_dscritic);  --> Erro
           IF vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           ELSE
             --Ler a primeira linha... ela deve ser ignorada no loop.
             BEGIN
               -- Le os dados do arquivo e coloca na variavel vr_setlinha
               gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto lido
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 --Chegou ao final arquivo, sair do loop
                 EXIT;
               WHEN OTHERS THEN
                 vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
                 RAISE vr_exc_saida;
             END;
           END IF;

           --Percorrer todas as linhas do arquivo
           LOOP
             --Criar savepoint para rollback
             SAVEPOINT save_trans;
             BEGIN
               BEGIN
                 -- Le os dados do arquivo e coloca na variavel vr_setlinha
                 gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto lido
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   --Chegou ao final arquivo, sair do loop
                   EXIT;
                 WHEN OTHERS THEN
                   vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
                   RAISE vr_exc_sair;
               END;
               /* Trailer - Se encontrar essa seq., terminou o arquivo */
               IF SUBSTR(vr_setlinha,1,15) = '999999999999999' THEN
                 EXIT;
               END IF;
               --Verificar compensacao titulos central
               OPEN cr_gncptit (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => vr_dtarquiv
                               ,pr_cdbandst => TO_NUMBER(TRIM(SUBSTR(vr_setlinha,1,3)))
                               ,pr_nrdvcdbr => TO_NUMBER(TRIM(SUBSTR(vr_setlinha,5,1)))
                               ,pr_cdfatven => TO_NUMBER(TRIM(SUBSTR(vr_setlinha,6,4)))
                               ,pr_dscodbar => SUBSTR(vr_setlinha,01,44));
               --Posicionar no primeiro registro
               FETCH cr_gncptit INTO rw_gncptit;
               --Se nao encontrou
               IF cr_gncptit%NOTFOUND THEN
                 --Fechar Cursor
                 CLOSE cr_gncptit;
                 --Inserir tabela
                 BEGIN
                   INSERT INTO gncptit
                    (gncptit.cdcooper
                    ,gncptit.cdagenci
                    ,gncptit.dtmvtolt
                    ,gncptit.dtliquid
                    ,gncptit.cdbandst
                    ,gncptit.cddmoeda
                    ,gncptit.nrdvcdbr
                    ,gncptit.dscodbar
                    ,gncptit.tpcaptur
                    ,gncptit.cdagectl
                    ,gncptit.nrdolote
                    ,gncptit.nrseqdig
                    ,gncptit.vldpagto
                    ,gncptit.tpdocmto
                    ,gncptit.nrseqarq
                    ,gncptit.nmarquiv
                    ,gncptit.cdoperad
                    ,gncptit.hrtransa
                    ,gncptit.vltitulo
                    ,gncptit.cdtipreg
                    ,gncptit.flgconci
                    ,gncptit.flgpcctl
                    ,gncptit.cdcritic
                    ,gncptit.cdmotdev
                    ,gncptit.cdfatven)
                   VALUES
                    (pr_cdcooper
                    ,0
                    ,vr_dtarquiv
                    ,rw_crapdat.dtmvtolt
                    ,to_number(TRIM(SUBSTR(vr_setlinha,1,3)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,4,1)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,5,1)))
                    ,SUBSTR(vr_setlinha,01,44)
                    ,to_number(TRIM(SUBSTR(vr_setlinha,50,1)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,57,4)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,61,6)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,68,3)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                    ,to_number(TRIM(SUBSTR(vr_setlinha,45,2)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,151,10)))
                    ,vr_tab_nmarqtel(idx)
                    ,vr_cdoperad
                    ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                    ,to_number(TRIM(SUBSTR(vr_setlinha,10,10))) / 100
                    ,2
                    ,1
                    ,0
                    ,927
                    ,0
                    ,to_number(TRIM(SUBSTR(vr_setlinha,6,4))));
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_cdcritic:= 0;
                     vr_dscritic:= 'Erro ao inserir na tabela gncptit. '||sqlerrm;
                     --Levantar Excecao
                     RAISE vr_exc_sair;
                 END;
                 --Inserir tabela rejeicao
                 BEGIN
                   INSERT INTO craprej
                    (craprej.dtmvtolt
                    ,craprej.cdagenci
                    ,craprej.dshistor
                    ,craprej.vllanmto
                    ,craprej.nrseqdig
                    ,craprej.cdpesqbb
                    ,craprej.cdcritic
                    ,craprej.cdcooper)
                   VALUES
                    (rw_crapdat.dtmvtolt
                    ,538
                    ,SUBSTR(vr_setlinha,20,25)
                    ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                    ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                    ,vr_setlinha
                    ,927
                    ,pr_cdcooper);
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_cdcritic:= 0;
                     vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                     --Levantar Excecao
                     RAISE vr_exc_sair;
                 END;
               ELSE
                 --Registro Conciliado
                 IF rw_gncptit.cdtipreg = 2 THEN
                   --Inserir tabela rejeicao
                   BEGIN
                     INSERT INTO craprej
                      (craprej.dtmvtolt
                      ,craprej.cdagenci
                      ,craprej.dshistor
                      ,craprej.vllanmto
                      ,craprej.nrseqdig
                      ,craprej.cdpesqbb
                      ,craprej.cdcritic
                      ,craprej.cdcooper)
                     VALUES
                      (rw_crapdat.dtmvtolt
                      ,538
                      ,SUBSTR(vr_setlinha,20,25)
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,85,12))) / 100
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha,151,10)))
                      ,vr_setlinha
                      ,670
                      ,pr_cdcooper);
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao inserir na tabela craprej. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                 ELSE
                   /*  Se encontrou um registro do tipo 1(Nossa Remessa) é pq conseguiu conciliar   */
                   BEGIN
                     UPDATE gncptit set gncptit.cdtipreg = 2
                                       ,gncptit.flgconci = 1
                                       ,gncptit.dtliquid = rw_crapdat.dtmvtolt
                     WHERE gncptit.rowid = rw_gncptit.rowid;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao atualizar tabela gncptit. '||sqlerrm;
                       --Levantar Excecao
                       RAISE vr_exc_sair;
                   END;
                   --Incrementar total integrado
                   vr_tot_qtregint:= nvl(vr_tot_qtregint,0) + 1;
                   vr_tot_vlregint:= nvl(vr_tot_vlregint,0) + to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100;
                 END IF;
               END IF;
               --Fechar Cursor
               IF cr_gncptit%ISOPEN THEN
                 CLOSE cr_gncptit;
               END IF;
               --Incrementar quantidade registros
               vr_tot_qtregrec:= nvl(vr_tot_qtregrec,0) + 1;
               vr_tot_vlregrec:= nvl(vr_tot_vlregrec,0) + to_number(TRIM(SUBSTR(vr_setlinha,85,12))) / 100;
             EXCEPTION
               WHEN vr_exc_proximo THEN
                 NULL;
               WHEN vr_exc_sair THEN
                 pc_grava_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                 --Desfazer transacoes
                 ROLLBACK TO save_trans;
                 --Sair Loop
                 EXIT;
             END;
           END LOOP; --Linhas do arquivo

           --Fechar arquivo dados
           BEGIN
             gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao fechar arquivo dados: '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx);
               --Levantar Excecao
               RAISE vr_exc_saida;
           END;

           -- Monta o comando para mover o arquivo para diretorio Salvar

           /*  Move arquivo integrado para o diretorio salvar  */
           vr_comando:= 'mv '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx)||' '||vr_caminho_salvar;

           /* Não deve mais executar o comando neste momento!!!
           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             RAISE vr_exc_saida;
           END IF;*/

           -- Guardar o comando para ser executado ao término da execução
           vr_tab_comando(vr_tab_comando.count() + 1) := vr_comando;

           --Efetua a gravacao, pois o arquivo ja foi processado
           -- ***** COMMIT; *** Não deve efetuar o comite neste ponto, pois o mesmo deve
           -- ser executado apenas ao término de todo processamento

           --Escrever mensagem log
           vr_cdcritic:= 190;
           --Buscar descricao da critica
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '||vr_dscritic
                                                         || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx));
           --Zerar variavel critica
           vr_cdcritic:= 0;
           --Nome arquivo impressao
           vr_nmarqimp:= 'crrl523_'||gene0002.fn_mask(idx,'9999')||'.lst';

           -- Inicializar o CLOB
           dbms_lob.createtemporary(vr_des_xml, TRUE);
           dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
           vr_dstexto:= NULL;
           -- Inicilizar as informacoes do XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl523><rejeitados>');

           --Percorrer registros rejeitados
           FOR rw_craprej IN cr_craprej_523 (pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_cdagenci => 538) LOOP
             --Codigo da critica
             vr_cdcritic:= rw_craprej.cdcritic;
             --Buscar descricao da critica
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Incrementar qdade e valor rejeitado
             vr_tot_qtregrej:= nvl(vr_tot_qtregrej,0) + 1;
             vr_tot_vlregrej:= nvl(vr_tot_vlregrej,0) + rw_craprej.vllanmto;
             --Montar Linha Pesquisa
             vr_rel_dspesqbb:= SUBSTR(rw_craprej.cdpesqbb,01,3)|| ' '||
                               SUBSTR(rw_craprej.cdpesqbb,61,7)|| ' '||
                               SUBSTR(rw_craprej.cdpesqbb,71,8)|| ' '||
                               SUBSTR(rw_craprej.cdpesqbb,45,2);
             --Escrever no Arquivo XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
               '<rej>
                    <nrseqdig>'||rw_craprej.nrseqdig||'</nrseqdig>
                    <dshistor>'||rw_craprej.dshistor||'</dshistor>
                    <vllanmto>'||to_char(rw_craprej.vllanmto,'fm999g999g999g990d00')||'</vllanmto>
                    <dspesqbb>'||vr_rel_dspesqbb||'</dspesqbb>
                    <dscritic>'||vr_dscritic||'</dscritic>
                 </rej>');
             --Deletar Linha rejeitado
             BEGIN
               DELETE craprej WHERE rowid = rw_craprej.rowid;
             EXCEPTION
               WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao excluir registro na craprej. '||sqlerrm;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END;
           END LOOP;
           -- Finalizar tag XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</rejeitados>');

           -- Finalizar tag XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl523>',true);

           /*  Salvar copia relatorio para "/rlnsv"  */
           IF pr_nmtelant = 'COMPEFORA' THEN
             vr_flpdfcopi:= 'S';
           ELSE
             vr_flpdfcopi:= 'N';
           END IF;

           --Tem Rejeitados
           IF nvl(vr_tot_qtregrej,0) > 0 THEN
             vr_flgimprime:= 'S';
           ELSE
             vr_flgimprime:= 'N';
           END IF;

           -- Montar Parametros
           vr_dsparam:= 'PR_NMARQUIV##'||'integra/'||vr_tab_nmarqtel(idx)||'@@'||
                        'PR_DTARQUIV##'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'@@'||
                        'PR_QTREGREJ##'||to_char(vr_tot_qtregrej,'fm999g990')||'@@'||
                        'PR_VLREGREJ##'||to_char(vr_tot_vlregrej,'fm999g999g999g990d00')||'@@'||
                        'PR_QTREGINT##'||to_char(vr_tot_qtregint,'fm999g990')||'@@'||
                        'PR_VLREGINT##'||to_char(vr_tot_vlregint,'fm999g999g999g990d00')||'@@'||
                        'PR_QTREGREC##'||to_char(vr_tot_qtregrec,'fm999g990')||'@@'||
                        'PR_VLREGREC##'||to_char(vr_tot_vlregrec,'fm999g999g999g990d00')||'@@'||
                        'PR_IMPRIME##'||vr_flgimprime;


           -- Efetuar solicitacao de geracao de relatorio crrl523 --
           gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper                --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt        --> Data do movimento atual
                                       ,pr_dsxml     => vr_des_xml                 --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl523/rejeitados/rej'  --> No base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl523.jasper'           --> Arquivo de layout do iReport
                                       ,pr_dsparams  => vr_dsparam                 --> Parametros
                                       ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                       ,pr_qtcoluna  => 132                        --> 132 colunas
                                       ,pr_sqcabrel  => 1                          --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                       ,pr_flg_impri => 'S'                        --> Chamar a impress?o (Imprim.p)
                                       ,pr_nmformul  => NULL                       --> Nome do formul?rio para impress?o
                                       ,pr_nrcopias  => 1                          --> N?mero de c?pias
                                       ,pr_flg_gerar => 'N'                        --> gerar PDF
                                       ,pr_dspathcop => vr_caminho_rlnsv           --> Lista sep. por ';' de diretórios a copiar o relatório
                                       ,pr_des_erro  => vr_dscritic);              --> Sa?da com erro
           -- Testar se houve erro
           IF vr_dscritic IS NOT NULL THEN
             -- Gerar excecao
             RAISE vr_exc_saida;
           END IF;

           -- Liberando a mem?ria alocada pro CLOB
           dbms_lob.close(vr_des_xml);
           dbms_lob.freetemporary(vr_des_xml);
           vr_dstexto:= NULL;
           --Zerar codigo critica
           vr_cdcritic:= 0;
         END LOOP; --Contador arquivos

       EXCEPTION
         WHEN vr_exc_final THEN
           --nao tem arquivo para processar
           pr_cdcritic:= NULL;
           pr_dscritic:= NULL;
         WHEN vr_exc_saida THEN
           pr_cdcritic:= vr_cdcritic;
           pr_dscritic:= vr_dscritic;
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_integra_todas_coop. '||sqlerrm;
       END pc_integra_todas_coop;

     ---------------------------------------
     -- Inicio Bloco Principal pc_CRPS538
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       --Determinar batch = false
       vr_flgbatch:= 0;
       vr_cdoperad:= '1';
       vr_datailog:= SYSDATE;
       vr_horailog:= GENE0002.fn_busca_time;

       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => vr_flgbatch
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       --Carregar tabela memoria convenios
       FOR rw_crapcco IN cr_crapcco LOOP
         vr_index_crapcco:= lpad(rw_crapcco.cdcooper,10,'0')||
                            lpad(rw_crapcco.nrconven,10,'0');
         vr_tab_crapcco(vr_index_crapcco).nrconven:= rw_crapcco.nrconven;
         vr_tab_crapcco(vr_index_crapcco).cdcooper:= rw_crapcco.cdcooper;
         vr_tab_crapcco(vr_index_crapcco).cdagenci:= rw_crapcco.cdagenci;
         vr_tab_crapcco(vr_index_crapcco).cdbccxlt:= rw_crapcco.cdbccxlt;
         vr_tab_crapcco(vr_index_crapcco).nrdolote:= rw_crapcco.nrdolote;
         vr_tab_crapcco(vr_index_crapcco).flgativo:= rw_crapcco.flgativo;
         vr_tab_crapcco(vr_index_crapcco).cddbanco:= rw_crapcco.cddbanco;
         vr_tab_crapcco(vr_index_crapcco).nrdctabb:= rw_crapcco.nrdctabb;
         vr_tab_crapcco(vr_index_crapcco).dsorgarq:= rw_crapcco.dsorgarq;
         vr_tab_crapcco(vr_index_crapcco).flgregis:= rw_crapcco.flgregis;
         vr_tab_crapcco(vr_index_crapcco).cdcopant:= NULL;
         vr_tab_crapcco(vr_index_crapcco).dsorgant:= NULL;

         IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
            -- verificar se o convenio migrado é 'IMPRESSO PELO SOFTWARE'
            OPEN cr_cco_impresso(pr_nrconven => rw_crapcco.nrconven);
            FETCH cr_cco_impresso INTO rw_cco_impresso;
            IF cr_cco_impresso%FOUND THEN
               vr_tab_crapcco(vr_index_crapcco).cdcopant := rw_cco_impresso.cdcooper;
               vr_tab_crapcco(vr_index_crapcco).dsorgant := rw_cco_impresso.dsorgarq;
            END IF;
            IF cr_cco_impresso%ISOPEN THEN
               CLOSE cr_cco_impresso;
            END IF;

         END IF;

       END LOOP;

       --Carregar tabela memoria contas migradas
       FOR rw_craptco IN cr_craptco (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craptco(rw_craptco.nrctaant).cdcooper := rw_craptco.cdcooper;
         vr_tab_craptco(rw_craptco.nrctaant).nrdconta := rw_craptco.nrdconta;
         vr_tab_craptco(rw_craptco.nrctaant).cdcopant := rw_craptco.cdcopant;
         vr_tab_craptco(rw_craptco.nrctaant).nrctaant := rw_craptco.nrctaant;
       END LOOP;

       --Carregar tabela memoria de motivos
       FOR rw_crapmot IN cr_crapmot (pr_cdcooper => pr_cdcooper) LOOP
         --Montar Indice para tabela
         vr_index_crapmot:= lpad(rw_crapmot.cddbanco,5,'0')||
                            lpad(rw_crapmot.cdocorre,5,'0')||
                            lpad(rw_crapmot.tpocorre,5,'0')||
                            lpad(rw_crapmot.cdmotivo,2,'0');
         vr_tab_crapmot(vr_index_crapmot):= rw_crapmot.dsmotivo;
       END LOOP;

       /* Le tabela Parametros */
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'EXECUTAABBC'
                                               ,pr_tpregist => 0);

       --Se encontrou
       IF TRIM(vr_dstextab) IS NOT NULL THEN
         IF upper(vr_dstextab) != 'SIM' THEN
           --Levantar Excecao Fimprg
           RAISE vr_exc_fimprg;
         END IF;
       ELSE
         --Levantar Excecao Fimprg
         RAISE vr_exc_fimprg;
       END IF;

       --Zerar Contador
       vr_contador:= 0;
       --Filtro arquivo retorno
       vr_nmarqret:= '29999%.RET'; /* Sua REMESSA e erros enviados */
       --Filtro arquivo remessa
       vr_nmarqrem:= '2%.REM';

       --Zerar totalizadores
       vr_tot_qtregrec:= 0;
       vr_tot_vlregrec:= 0;
       vr_tot_qtregint:= 0;
       vr_tot_vlregint:= 0;
       vr_tot_qtregrej:= 0;
       vr_tot_vlregrej:= 0;

       --Banco Centralizador
       vr_cdbanctl:= gene0002.fn_mask(rw_crapcop.cdbcoctl,'999');

       --Buscar Diretorio Integracao da Cooperativa
       vr_caminho_puro:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => NULL);
       vr_caminho_integra:= vr_caminho_puro||'/integra';

       -- Buscar o diretorio padrao da cooperativa conectada
       vr_caminho_salvar:=vr_caminho_puro||'/salvar';

       -- Buscar o diretorio padrao da cooperativa conectada
       vr_caminho_rl:= vr_caminho_puro||'/rl';

       IF pr_nmtelant = 'COMPEFORA' THEN
         --Data leitura arquivo
         vr_dtleiarq:= to_char(rw_crapdat.dtmvtoan,'YYYYMMDD');
       ELSE
         --Data leitura arquivo
         vr_dtleiarq:= to_char(rw_crapdat.dtmvtolt,'YYYYMMDD');
       END IF;

       --Se nao for Cecred
       IF pr_cdcooper <> 3 THEN
         --Executar integracao todas cooperativas
         pc_integra_todas_coop (pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
         --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
       END IF;

       --Executar Integracao Cecred
       pc_integra_cecred (pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
       --Se ocorreu erro
       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'Inicio Processo Lancamento Tarifas' );


       -- Lancamento Tarifas
       PAGA0001.pc_efetua_lancto_tarifas_lat (pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                             ,pr_tab_lat_consolidada  => vr_tab_lat_consolidada --Tabela Lancamentos
                                             ,pr_cdcritic => vr_cdcritic         --Codigo Erro
                                             ,pr_dscritic => vr_dscritic);       --Descricao Erro

       --Se Ocorreu erro
       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'Fim Processo Lancamento Tarifas' );

       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || 'Inicio Geracao Log CRAPCOL' );

       --Montar data e hora para log
       vr_dataflog:= SYSDATE;
       vr_horaflog:= GENE0002.fn_busca_time;
       vr_descorpo:= NULL;

       --Escrever Criticas no LOG
       FOR rw_crapcol IN cr_crapcol (pr_cdcooper => pr_cdcooper
                                    ,pr_cdoperad => 'TARIFA'
                                    ,pr_datailog => vr_datailog
                                    ,pr_dataflog => vr_dataflog
                                    ,pr_horailog => vr_horailog
                                    ,pr_horaflog => vr_horaflog) LOOP

         -- Tratamento para que se estourar o tamanho da mensagem não aborte o processo
         -- e envia as informações montadas até o momento, visto que muitas das informações se repetem
         BEGIN
             vr_descorpo := vr_descorpo || to_char(sysdate,'hh24:mi:ss')||' - '||
                            vr_cdprogra || ' --> '|| rw_crapcol.dslogtit || '<br>' ;
         EXCEPTION
         WHEN OTHERS THEN
           NULL;
         END;
       END LOOP;

       -- se encontrou alguma critica envia por email para a area responsavel
       IF vr_descorpo IS NOT NULL THEN
         vr_email_tarif := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                      pr_cdcooper => pr_cdcooper,
                                                      pr_cdacesso => 'EMAIL_TARIF');

         -- Se não encontrar e-mail cadastrado no parametro, deve mandar
         -- para o e-mail da cobrança da CECRED ( Renato - Supero )
         IF vr_email_tarif IS NULL THEN
           vr_email_tarif := 'cobranca@cecred.coop.br';
         END IF;

         /* Envio do arquivo detalhado via e-mail */
         gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                   ,pr_cdprogra        => vr_cdprogra
                                   ,pr_des_destino     => vr_email_tarif
                                   ,pr_des_assunto     => 'Erros log de tarifas ('||rw_crapcop.nmrescop ||')'
                                   ,pr_des_corpo       => 'Segue a lista de criticas de Tarifa ('||vr_cdprogra||'): <br><br>'||
                                                           vr_descorpo
                                   ,pr_des_anexo       => NULL
                                   ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                   ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                   ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                   ,pr_des_erro        => vr_dscritic);

         -- Se ocorrer erro
         IF vr_dscritic IS NOT NULL THEN
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Erro ao enviar email de erros de log de tarifas: '||vr_dscritic );

           -- Limpar a mensagem de erro
           vr_dscritic := NULL;
         END IF;

       END IF;

       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'Fim Geracao Log CRAPCOL' );

       -- Se há comandos a serem processados
       IF vr_tab_comando.COUNT() > 0 THEN
         -- Percorrer o registro de comando e executá-los
         FOR ind IN vr_tab_comando.FIRST..vr_tab_comando.LAST LOOP

           -- Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_tab_comando(ind)
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);

           -- Se ocorreu erro
           IF vr_typ_saida = 'ERR' THEN
             -- montar mensagem de erro
             vr_dscritic:= 'Erro no comando unix, executar manualmente: '||vr_comando;
             -- Gerar um log
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );

             -- Limpar variável de erro
             vr_dscritic := NULL;
           END IF;

         END LOOP;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);


       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao da critica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Se foi gerada critica para envio ao log
         IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
         END IF;
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
         -- Efetuar commit pois gravaremos o que foi processado ate entao
         COMMIT;

       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos codigo e critica encontradas
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
   END PC_CRPS538;
/
