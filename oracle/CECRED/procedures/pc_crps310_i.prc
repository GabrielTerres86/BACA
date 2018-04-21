CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS310_I(pr_cdcooper   IN crapcop.cdcooper%TYPE       --> Coop. conectada
                                               ,pr_cdagenci   IN crapage.cdagenci%TYPE       --> Codigo Agencia 
                                               ,pr_idparale   IN crappar.idparale%TYPE       --> Indicador de processoparalelo
                                               ,pr_rw_crapdat IN OUT btch0001.cr_crapdat%ROWTYPE --> Dados da crapdat
                                               ,pr_cdprogra   IN crapprg.cdprogra%TYPE       --> Codigo programa conectado
                                               ,pr_vlarrasto  IN NUMBER                      --> Valor parametrizado para arrasto
                                               ,pr_flgresta   IN PLS_INTEGER                 --> Flag 0/1 para utiliza��o de restart
                                               ,pr_nrctares   IN crapass.nrdconta%TYPE       --> N�mero da conta de restart
                                               ,pr_dsrestar   IN VARCHAR2                    --> String gen�rica com informa��es para restart
                                               ,pr_inrestar   IN INTEGER                     --> Indicador de Restart
                                               ,pr_cdcritic  OUT crapcri.cdcritic%TYPE       --> Critica encontrada
                                               ,pr_dscritic  OUT VARCHAR2) IS                --> Texto de erro/critica encontrada
  BEGIN         
  /* ............................................................................

     Programa: pc_crps310_i (Antiga Includes/crps310.i)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Margarete
     Data    : Maio/2001                       Ultima atualizacao: 06/04/2018
     
     Dados referentes ao programa:

     Objetivo  : Gerar arquivo com saldo devedor dos emprestimos - Risco.

     Alteracoes: 06/10/2008 - Adaptacao para Desconto de Titulos (David).

                 20/10/2008 - Incluir prejuizo de +48M ate 60M (Magui).

                 27/10/2008 - Novo comunicado controlando preju +48M (Magui).

                 26/01/2009 - Atualizar valores de saldo devedor de emprestimo e
                              quantidade de parcelas pagas quando rodar na
                              semanal (Diego).

                 16/02/2009 - Atualizacao risco crapass(somente mensal)(Mirtes)

                 10/03/2009 - Considerar titulos que vencem na data atual tambem
                              para risco de desconto de titulos(Guilherme).

                 15/04/2009 - Nao considerar titulos que foram pagos pela COMPE na
                              data atual no RISCO pois somente serao lancados na
                              contabilidade com D+1(Guilherme/Evandro).

                 21/05/2009 - Considerar em risco titulos que vencem em
                              glb_dtmvtolt (Guilherme);
                              Alimentar as variaveis de contrato e data de inicio
                              para o desconto de titulos (Evandro).

                 24/06/2009 - Considerar o vlrestit do mes de titulos que foram
                              pagos antecipados para risco de desconto de
                              titulos(Guilherme).

                 31/07/2009 - Quando aux_vldivida > 0 e crapsld.dtrisclq <> ?,
                              atribuir ao crapris.qtdiaatr 21 - dias de atraso
                              (Fernando).

                 20/08/2009 - Atribuir a matricula no contrato ao inves da c/c
                              em modalidado 0299 e origem = 1 (Evandro).

                 09/09/2009 - Nao considerar a data de vencimento nos titulos em
                              aberto porque a liquidacao esta rodando antes no
                              processo batch (Evandro).

                 03/12/2009 - Retirar campos da crapass relacionados ao
                              rating/risco, passados para a crapnrc (Gabriel).

                 10/06/2010 - Tratamento para pagamento feito atraves de TAA
                              "crapcob.indpagto = 4" (Elton).

                 19/08/2010 - Verifica a data em que o cooperado entrou no risco,
                              crapris.dtdrisco (Elton).

                 23/08/2010 - Feito tratamento de Emprestimos (0299),
                              Financiamento (0499) (Adriano).

                 06/09/2010 - Novo modo de calculo do crapris.vldiv (Guilherme).

                 05/10/2010 - Atualiza campo crapris.dtdrisco na procedure
                              efetua_arrasto (Elton).

                 09/11/2010 - Alterado campo qtdade parcela para dec(Mirtes)

                 02/02/2011 - Voltado qtdade(aux_qtprecal_retorno)
                              parcela para inte. Impacto na
                              provisao das coopes e muito grande. (Magui).

                 23/03/2011 - Modalide 0201 sempre risco Rating(Dentro do limite
                              contratado). Apenas sera considerado em CL
                              utilizacao superior ao contratado - risco H
                              Tarefa 38937(Mirtes)

                 11/11/2011 - Ajuste na procedure calcula_codigo_vencimento,
                              tratar exce��o: emprestimos com valor total
                              das parcelas menor que valor do emprestimo
                              contratado (Irlan).

                 05/03/2012 - Corre��o para nao considerar os contratos em
                              preju�zo no calculo dos vencimentos. Calculo
                              j� � feito em outra parte do c�digo.(Irlan)

                 03/04/2012 - Atualiza a data do risco sem considerar o valor do
                              arrasto (Elton).

                 04/04/2012 - Alimentar o campo crapris.qtdriclq quando
                              modalidade for 0101 Adiant.Depos. (Irlan)

                 19/04/2012 - Utilizar glb_dtmvtolt ao inves de usar aux_dtrefere
                              na leitura dos cheques descontados. (Rafael)

                 30/05/2012 - Alimentar campo crapris.vljura60 (Gabriel).

                 18/06/2012 - Quando conta for lancada pra prejuizo (innivris = 10)
                              nao alterar data do risco (Elton).

                 21/08/2012 - Tratar emprestimo pre-fixados (Gabriel).

                 10/10/2012 - Criar novo crapris.cdorigem = 5 referente ao
                              desc. t�tulos - cob. registrada (Rafael).

                 05/12/2012 - Ajuste na grava��o dos juros para que nao
                              ultrapasse o valor da divida (Tiago).

                 20/12/2012 - Onde eh realizado a gravacao/atualizacao do campo
                              crapris.innivris sera tambem feito para o campo
                              crapris.inindris - Projeto GE (Adriano).

                             21/01/2013 - Incluida procedure cria_saida_operacao. (Tiago)

                 22/01/2013 - Incluir novo parametro cdorigem na procedure
                              verifica_motivo_saida (Lucas R.).

                 06/02/2013 - Ajustado processo cria_saida_operacao, incluso tratamento
                              para situacoes onde modalidade e alterada de 0299 para 0499
                              e de 0499 para 0299. (Daniel).

                 27/02/2013 - Ajuste no campo de valores de vencimentos (Gabriel).

                 04/04/2013 - Convers�o Progress >> Oracle PL-Sql (Marcos-Supero).

                 24/05/2013 - Ajuste na gravacao do vljura60 (Marcos-Supero).

                 04/06/2013 - Inclu�da a ordena��o por nrdconta e nrctremp na PROCEDURE
                              cria_saida_operacao (Marcos-Supero).

                 09/08/2013 - Inclus�o de teste na pr_flgresta antes de controlar
                              o restart (Marcos-Supero)
                              
                 29/08/2013 - Leitura das operacoes de emprestimos com o
                              BNDES (crapebn). (Gabriel).
                              
                 29/08/2013 - Para emprestimos com o BNDES, alimentado variavel
                              'aux_nivel' de acordo com a presenca de valores
                              nos campos de creditos em prejuizo ou vencidos.
                              (Gabriel).
                              
                 30/09/2013 - Altera��o na grava��o do valor da divida para 
                              emprestimos pre-fixados.
                              (ris.vldivida e vri.vldivida) (Gabriel).
                                                               
                 30/09/2013 - Nao considerar titulos descontados 085 pagos 
                              via compe no calculo do risco (Gabriel).    
                               
                 07/11/2013 - Alteracoes:
                            - Retirada a chamada e as variaveis 
                              referente a procedure cria_saida_operacao
                              para que a mesma seja tratada no fonte crps660.p
                            - Retirada a procedure verifica_motivo_saida para
                              ser tratada no fonte crps660.p   
                              (Gabriel).
                            
                 07/11/2013 - Inicializada variavel aux_dias em lista_tipo_1.
                             (Gabriel).  

                 12/12/2013 - Alteracao referente a integracao Progress X 
                              Dataserver Oracle 
                              Inclusao do VALIDATE ( Andr� Euz�bio / SUPERO)
                              
                 03/02/2014 - Remover a chamada da procedure "saldo_epr.p".
                              (James)
                                         
                 25/02/2014 - Manutencoes 201402 (Edison-AMcom)
                 
                 28/02/2014 - Ajuste procedure lista_tipo_1 (Daniel).
                 
                 07/05/2014 - Se a situacao do emprestimo nao estiver em
                              atraso ou prejuizo, seta o risco da operacao
                              como 'A'. Caso o risco do cooperado for maior
                              que o da operacao, entao, o risco a ser considerado
                              passa a ser o do cooperado. (Fabricio)
                              
                 08/05/2014 - Incluido mais uma ordenacao no cursor 
                              "cr_crapris_last". (James)             
                              
                 27/05/2014 - Ajuste na procedure "pc_calcula_juros_emp_60dias"
                              para calcular para o novo tipo de emprestimo. (James)
				 
                 25/06/2014 - Altera��o leitura crapris e crapvri. SoftDesk 137892 (Daniel) 
                                       
                 09/07/2014 - Melhorias para enviar as informa��es do Fluxo Financeiro
                              para o documento 3040 - Circular 3.649 (Marcos-Supero)
                              
                            - Remo��o de cria��o da base de risco para o Docto 3010
                              InDocto = 0, pois segundo o Irlan n�o enviamos mais esta 
                              informa��o (Marcos-Supero)
                              
                 05/09/2014 - Re-inclus�o da manuten��o de 28/02/2014 que foi perdida
                              na revis�o 4168 (Marcos-Supero)
                              
                 11/09/2014 - Nova regra quanto ao Saldo Bloqueado liberado ao Cooperado,
                              pois a partir de agora esta informa��o ser� incorporada ao 
                              mesmo risco do Adiantamento a Depositante (AD).
                              O valor somente de Saldo Bloqueado ser� gravado no campo 
                              DSINFAUX para separa��o destes valores nos relat�rios 
                              cont�beis (Marcos-Supero)
                             
                 12/11/2014 - Atendimento de solicita��o do BACEN quanto ao Desconto de 
                              Cheques e Titulos que n�o pode ser rotativo, ent�o alteramos 
                              para que cada border� ou titulo gere um risco e n�o mais o 
                              contrato de limite agregue todos (Marcos-Supero) 
                              
                 04/12/2014 - Ajuste no calculo de dias de atraso. (James)      
                 
				         02/01/2014 - Ajuste para nao gravar nulo no campo vljura60 para
                              o emprestimo tipo novo. (James)
				 
                 19/01/2015 - Ajuste quanto a data de fim da vigencia de contratos, onde 
                              hoje a procedure est� pegando os dias de vig�ncia da tabela 
                              craplrt.qtdiavig, o correto � buscar da tabela craplim.qdiavig
                              (Marcos-Supero, cfme solicita��o James)
                 
                 27/01/2015 - Tratamento para o emprestimo em prejuizo. (James/Oscar)
                 
                 02/02/2015 - Inclus�o do envio do Limite Contratado e N�o Utilizado (Marcos-Supero)
                 
                 29/05/2015 - Ajuste na forma de calculo de provisao. (James)
                 
                 30/10/2015 - Ajuste no cr_crapris_last pois pegava contratos em prejuizo
                              indevidamente (Tiago/Gielow #342525).
                              
                 08/12/2015 - Ajuste para alimentar o campo crapris.dtvencop. (James)
                 
                 30/12/2015 - Ajuste para gravar a data de vencimento das operacoes de
                              emprestimos/financiamentos. (James)
                              
                 25/01/2016 - Realizado diversos ajustes para melhorar performace do programa 
                              crps515.
                              - Alterado Insert crapris
                              - Alterado merge crapvri
                              - Ajustado leituras                                                                                          
                               SD385161 (Odirlei-AMcom)  
                 
                 03/03/2016 - Ajustes para evitar estouro de memoria do oracle
                              retirado leitura da tabela crapepr para temptable e 
                              ajustado outras leituras que populavam temptable a fim de
                              diminuir dados desnecessarios SD385161 (Odirlei-AMcom)
                 
                 27/07/2016 - Incluido a possibilidade da operacao possuir risco soberano. (James)

                 11/05/2016 - Leitura do risco soberano da tbrisco_cadastro_conta
                              e nao mais da crapprm. (Jaison/James)

                 25/08/2016 - Ajustar calculo de prazo de vencido/vencimento dos borderos de cheque/titulo
                              SD488220 (Odirlei-AMcom)

                 15/03/2017 - Ajuste na regra da classifica��o de qual nivel de risco do produto de Adiantamento a 
                              Depositante (AD) se encontra, onde para o n�vel "A" o 15 dia de atraso estava sendo considerado, 
                              sendo que o correto para este n�vel � at� o 14 dia de atraso. (Rafael Monteiro).

                 23/03/2017 - Ajustes PRJ343 - Cess�o Cart�o de Credito.
                              (Odirlei-AMcom)                

                 16/05/2017 - Acionamento da cria��o do Risco para Cart�es Credito BB (Andrei-Mouts)

                 21/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

                 26/12/2017 - Auditoria BACEN ajustar a quantidade de dias em atraso da central de risco produto PP e TR ap�s a transfer�ncia para prejuizo. (Oscar/Odirlei-AMcom)
                 
                 05/02/2018 - Alterado o cursor cr_cessao_carga para considerar contratos transferidos para prejuizo, 
                              n�o estava considerando a sessa�o de credito no calculo de dias em atraso. (Oscar)
                 04/02/2018 - Ajuste para calcular o valor dos juros60 para o produto pos-fixado. (James)            

                 01/02/2018 - Utilizar a data do movimento para atualiza��o da data do risco - Daniel(AMcom)

                 15/02/2018 - Nova rotina para Arrasto por CPF/CNPJ (Guilherme/AMcom)

                 03/04/2018 - Inclus�o de controle de paralelismo por Agencia (PA) quando solicitado.
                            - Visando performance, Roda somente no processo Noturno (Mario-AMcom)
                 - Funcinalidade:
                   - 1. Sem paralelismo: - a quantidade de JOBS para a cdcooper deve ser 0;
                                         - Ativar o programa normalmente.
                   - 2. Com Paralelismo: - a quantidade de JOBS para o cdcooper deve ser > 0;
                                         - ativar o programa normalmente. Roda com PA = 0;
                                         - Cria 1 JOB para cada PA e Ativa/executa os JOBS dos PA's;
                                         - Aguarda todos os JOB's concluirem;
                                         - Consolida todos os PA's lendo os movimentos gerados na tabe�a _WRK.
                   - JOB Paralelismo: - � ativado pelo programa em CRPS310 em execu��o.
                                      - processa os registros do arquivo somente do PA passado pelo par�metro.
                                      - gera os movimentos para consolida��o em tabela _WRK.          

  ............................................................................ */

    DECLARE

      -- Tratamento de erros
      vr_exc_erro exception;
      vr_des_erro varchar2(4000);
      -- Controle para rollback to savepoint
      vr_exc_undo EXCEPTION;

      -- Buscar as informa��es para restart e Rowid para atualiza��o posterior
      CURSOR cr_crapres IS
        SELECT res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = pr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -- Busca dos associados unindo com seu saldo na conta
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.dtadmiss
              ,ass.vllimcre
              ,ass.nrcpfcgc
              ,ass.inpessoa
              ,ass.cdagenci
              ,ass.nrmatric
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
           AND ass.nrdconta > pr_nrctares; --> Conta do restart, se n�o houve, teremos 0 neste valor

      -- Busca informa��es do saldo da conta
      CURSOR cr_crapsld IS
        SELECT sld.nrdconta
              ,sld.vlsddisp
              ,sld.vlsdchsl              
              ,sld.vlsdbloq
              ,sld.vlsdblfp
              ,sld.vlsdblpr
              ,sld.dtrisclq
              ,sld.qtdriclq
          FROM crapsld sld
         WHERE sld.cdcooper = pr_cdcooper;
      rw_crapsld cr_crapsld%ROWTYPE;

      -- Buscar notas de rating do contrado da conta
      CURSOR cr_crapnrc IS
        SELECT nrc.nrdconta
              ,NVL(nrc.indrisco,' ') indrisco
              ,nrc.dtmvtolt
          FROM crapnrc nrc
         WHERE nrc.cdcooper = pr_cdcooper
           AND nrc.insitrat = 2; --> efetivo

      -- Busca de linha de cr�dito em contratos de limite de cr�dito
      CURSOR cr_craplim(pr_nrdconta IN craplim.nrdconta%TYPE) IS
        SELECT /*+ index_desc (lim CRAPLIM##CRAPLIM2)*/ --> Ordenar pelo ultimo vigente
               lim.dtinivig
              ,lim.cddlinha
              ,lim.nrctrlim 
              ,lim.qtdiavig
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.tpctrlim = 1 --> Cheque especial
           AND lim.insitlim = 2; --> Ativo
      rw_craplim cr_craplim%ROWTYPE;

      -- Busca o cadastro de linhas de cr�dito
      CURSOR cr_craplcr IS
        SELECT lcr.cdlcremp
              ,lcr.dsoperac
              ,lcr.perjurmo
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper;

      -- Buscar contas com cadastro de borderos de descontos de titulos
      -- Garantir que a busca abaixo no cursor cr_crapbdt tenha as mesmas
      -- cl�usulas deste
      CURSOR cr_crapbdt_ini(pr_dtrefere IN DATE) IS
        SELECT /*+PARALLEL*/
               bdt.nrdconta
          FROM craptdb tdb
              ,crapcob cob
              ,crapbdt bdt
         WHERE bdt.cdcooper = pr_cdcooper
           AND tdb.cdcooper = bdt.cdcooper
           AND tdb.nrdconta = bdt.nrdconta
           AND tdb.nrborder = bdt.nrborder
           AND cob.cdcooper = bdt.cdcooper
           AND cob.cdbandoc = tdb.cdbandoc
           AND cob.nrdctabb = tdb.nrdctabb
           AND cob.nrcnvcob = tdb.nrcnvcob
           AND cob.nrdconta = tdb.nrdconta
           AND cob.nrdocmto = tdb.nrdocmto           
           -- Borderos Situa��o 4-Liquidado OU  3-Liberado com data inferior ou igual a de referencia
           AND (  bdt.insitbdt = 4 OR (bdt.insitbdt = 3 AND bdt.dtlibbdt <= pr_dtrefere) )
           -- Titulos Situa��o 4-Liberado OU 2-Processado com data igual a de processo
           AND (  tdb.insittit = 4 OR (tdb.insittit = 2 AND tdb.dtdpagto = pr_rw_crapdat.dtmvtolt) )
         GROUP BY bdt.nrdconta;

      -- Busca de todos os empr�stimos em aberto com prejuizo      
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                        pr_nrdconta IN crapepr.nrdconta%TYPE) IS
        SELECT crapepr.nrdconta
              ,crapepr.nrctremp
              ,crapepr.cdlcremp
              ,crapepr.tpemprst
              ,crapepr.dtmvtolt
              ,crapepr.vlsdeved
              ,crapepr.qtprecal
              ,crapepr.qtmesdec
              ,crapepr.qtpreemp
              ,crapepr.dtinipag
              ,crapepr.dtdpagto
              ,crapepr.vlprejuz
              ,crapepr.vlsdprej
              ,crapepr.vlpreemp
              ,crapepr.qtprepag
              ,crapepr.dtprejuz
              ,crapepr.inprejuz
              ,crapepr.qtlcalat
              ,crapepr.vlsdevat
              ,crawepr.dtdpagto dtdpripg
              ,crapepr.dtultpag
              ,crawepr.dsnivris
              ,crapepr.diarefju
              ,crapepr.mesrefju
              ,crapepr.anorefju
              ,crapepr.txjuremp                                       
              ,crawepr.dtlibera
              ,crapepr.txmensal
              ,crapepr.qttolatr
              ,crapepr.vlemprst
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp 
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           -- OU Ativo OU Com prejuizo
           AND (crapepr.inliquid = 0 OR crapepr.inprejuz = 1)
         ORDER BY crapepr.nrctremp;                           
     
      -- Buscar todos os cadastro de borderos dos cheques por conta
      CURSOR cr_crapbdc(pr_dtrefere IN DATE) IS
        SELECT /*+ PARALLEL (bdc,4)*/
               bdc.nrdconta
              ,bdc.nrctrlim
              ,bdc.dtlibbdc
              ,bdc.dtmvtolt
              ,bdc.nrborder
              ,ROW_NUMBER () OVER (PARTITION BY bdc.nrdconta
                                       ORDER BY bdc.nrdconta,bdc.dtmvtolt,bdc.progress_recid) sqatureg
          FROM crapbdc bdc
         WHERE bdc.cdcooper = pr_cdcooper
           AND bdc.insitbdc = 3            -- Liberado
           AND bdc.dtlibbdc <= pr_dtrefere -- Data inferior ou igual a do processo
           --> Buscar apenas os borderos que possuem cheque com data liberacao maior
           -- que a data do sistema           
           AND EXISTS ( SELECT 1 
                          FROM crapcdb cdb
                         WHERE cdb.cdcooper = bdc.cdcooper
                           AND cdb.nrborder = bdc.nrborder
                           AND dtlibera > pr_rw_crapdat.dtmvtolt);      
                           
      -- Buscar todos os cheques contidos no bordero passado
      CURSOR cr_crapcdb IS
        SELECT nrborder
              ,nrdconta
              ,vlliquid
              ,dtlibera
              ,dtlibbdc
              ,cdcmpchq
              ,cdbanchq
              ,cdagechq
              ,nrctachq
              ,nrcheque
              ,dtdevolu
              ,progress_recid
          FROM crapcdb
         WHERE cdcooper = pr_cdcooper
           AND dtlibera > pr_rw_crapdat.dtmvtolt;

      -- Sumarizar os juros no desconto do cheque
      CURSOR cr_crapljd(pr_nrdconta IN crapljd.nrdconta%TYPE
                       ,pr_nrborder IN crapljd.nrborder%TYPE
                       ,pr_dtmvtolt IN crapljd.dtmvtolt%TYPE
                       ,pr_dtrefere IN crapljd.dtrefere%TYPE
                       ,pr_cdcmpchq IN crapljd.cdcmpchq%TYPE
                       ,pr_cdbanchq IN crapljd.cdbanchq%TYPE
                       ,pr_cdagechq IN crapljd.cdagechq%TYPE
                       ,pr_nrctachq IN crapljd.nrctachq%TYPE
                       ,pr_nrcheque IN crapljd.nrcheque%TYPE) IS
        SELECT NVL(SUM(vldjuros),0)
          FROM crapljd
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrborder = pr_nrborder
           AND dtmvtolt = pr_dtmvtolt
           AND dtrefere < pr_dtrefere
           AND cdcmpchq = pr_cdcmpchq
           AND cdbanchq = pr_cdbanchq
           AND cdagechq = pr_cdagechq
           AND nrctachq = pr_nrctachq
           AND nrcheque = pr_nrcheque;
      vr_vldjuros crapljd.vldjuros%TYPE;

      -- Sumarizar a restitui��o no desconto de titulo
      CURSOR cr_crapljt_rest(pr_nrdconta IN crapljt.nrdconta%TYPE
                            ,pr_nrborder IN crapljt.nrborder%TYPE
                            ,pr_dtmvtolt IN crapljt.dtmvtolt%TYPE
                            ,pr_dtrefere IN crapljt.dtrefere%TYPE
                            ,pr_cdbandoc IN crapljt.cdbandoc%TYPE
                            ,pr_nrdctabb IN crapljt.nrdctabb%TYPE
                            ,pr_nrcnvcob IN crapljt.nrcnvcob%TYPE
                            ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
        SELECT NVL(SUM(vlrestit),0)
          FROM crapljt
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrborder = pr_nrborder
           AND dtmvtolt = pr_dtmvtolt
           AND dtrefere > pr_dtrefere -- Posterior a passada
           AND cdbandoc = pr_cdbandoc
           AND nrdctabb = pr_nrdctabb
           AND nrcnvcob = pr_nrcnvcob
           AND nrdocmto = pr_nrdocmto;
      vr_vlrestit crapljt.vlrestit%TYPE;

      -- Sumarizar os juros e a restitui��o no desconto de titulo
      CURSOR cr_crapljt_soma(pr_nrdconta IN crapljt.nrdconta%TYPE
                            ,pr_nrborder IN crapljt.nrborder%TYPE
                            ,pr_dtmvtolt IN crapljt.dtmvtolt%TYPE
                            ,pr_dtrefere IN crapljt.dtrefere%TYPE
                            ,pr_cdbandoc IN crapljt.cdbandoc%TYPE
                            ,pr_nrdctabb IN crapljt.nrdctabb%TYPE
                            ,pr_nrcnvcob IN crapljt.nrcnvcob%TYPE
                            ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
        SELECT NVL(SUM(vldjuros),0) + NVL(SUM(vlrestit),0)
          FROM crapljt
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrborder = pr_nrborder
           AND dtmvtolt = pr_dtmvtolt
           AND dtrefere < pr_dtrefere -- Inferior a passada
           AND cdbandoc = pr_cdbandoc
           AND nrdctabb = pr_nrdctabb
           AND nrcnvcob = pr_nrcnvcob
           AND nrdocmto = pr_nrdocmto;

      -- Buscar cadastro de borderos de descontos de titulos
      -- Esta busca deve obrigatoriamente ser igual ao relatorio
      -- 494 e 495 que sao gerados pelo fontes/crps518.p
      -- os comentarios sobre a busca estao la
      -- Considerar em risco titulos que vencem em glb_dtmvtolt
      -- Garantir que a busca acima no cursor cr_crapbdt_ini tenha as mesmas cl�usulas deste
      CURSOR cr_crapbdt(pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtrefere IN DATE) IS
        SELECT bdt.nrborder
              ,cob.flgregis
              ,bdt.dtlibbdt
              ,tdb.nrdconta
              ,tdb.dtvencto
              ,tdb.vlliquid
              ,tdb.insittit
              ,tdb.dtdpagto
              ,tdb.cdbandoc
              ,tdb.nrdctabb
              ,tdb.nrcnvcob
              ,tdb.nrdocmto
              ,cob.indpagto
              ,COUNT(1)      OVER (PARTITION BY bdt.nrborder,cob.flgregis) qtd_max
              ,ROW_NUMBER () OVER (PARTITION BY bdt.nrborder,cob.flgregis
                                       ORDER BY bdt.nrborder,cob.flgregis) seq_atu
          FROM crapcob cob               
              ,craptdb tdb
              ,crapbdt bdt
         WHERE bdt.cdcooper = tdb.cdcooper
           AND bdt.nrdconta = tdb.nrdconta
           AND bdt.nrborder = tdb.nrborder
           AND cob.cdcooper = bdt.cdcooper
           AND cob.cdbandoc = tdb.cdbandoc
           AND cob.nrdctabb = tdb.nrdctabb
           AND cob.nrcnvcob = tdb.nrcnvcob
           AND cob.nrdconta = tdb.nrdconta
           AND cob.nrdocmto = tdb.nrdocmto
           -- Restri��es
           AND bdt.cdcooper = pr_cdcooper
           AND bdt.nrdconta = pr_nrdconta
           -- Borderos Situa��o 4-Liquidado OU  3-Liberado com data inferior ou igual a de referencia
           AND (  bdt.insitbdt = 4 OR (bdt.insitbdt = 3 AND bdt.dtlibbdt <= pr_dtrefere) )
           -- Titulos Situa��o 4-Liberado OU 2-Processado com data igual a de processo
           AND (  tdb.insittit = 4 OR (tdb.insittit = 2 AND tdb.dtdpagto = pr_rw_crapdat.dtmvtolt) )
         ORDER BY bdt.nrborder
                 ,cob.flgregis
                 ,bdt.progress_recid;

      -- Contrato de emprestimos com o BNDES
      CURSOR cr_crapebn (pr_nrdconta crapebn.nrdconta%TYPE) IS
        SELECT ebn.nrctremp
              ,ebn.dtinictr              
              ,ebn.vlsdeved
              ,ebn.dtvctpro
              ,ebn.dtfimctr
              ,ebn.dtppvenc
              ,ebn.vlparepr
              ,ebn.insitctr
              ,ebn.qtparctr
              ,ebn.vlprac48
              ,ebn.vlprej48
              ,ebn.vlprej12
              ,ebn.vlvac540
              ,ebn.vlven540              
              ,ebn.vlven360
              ,ebn.vlven300
              ,ebn.vlven240
              ,ebn.vlven180
              ,ebn.vlven150
              ,ebn.vlven120
              ,ebn.vlvenc90
              ,ebn.vlvenc60
              ,ebn.vlvenc30
              ,ebn.vlav5400
              ,ebn.vlaa5400
              ,ebn.vlav1800
              ,ebn.vlav1440
              ,ebn.vlav1080
              ,ebn.vlave720
              ,ebn.vlave360
              ,ebn.vlave180
              ,ebn.vlaven90
              ,ebn.vlaven60
              ,ebn.vlaven30              
              ,ebn.vlvenc14
              ,ebn.vlaat180
              ,ebn.vlasu360
              ,ebn.vlveat60
              ,ebn.vlvenc61
              ,ebn.vlven181
              ,ebn.vlvsu360
          FROM crapebn ebn
         WHERE ebn.cdcooper = pr_cdcooper
           AND ebn.nrdconta = pr_nrdconta
           -- Somente (N)ormal, (A)trasado e (P)rejuizo
           AND ebn.insitctr IN('N','A','P');
      /* M324 - Historicos de pagamento de prejuizo
        --
        382 PAGAMENTO DE PREJUIZO ORIGINAL TRANSFERIDO
        383 ABONO DE PREJUIZO
        2388  PAGAMENTO DE PREJUIZO VALOR PRINCIPAL
        2389  PAGAMENTO JUROS PREJUIZO
        2390  PAGAMENTO MULTA ATRASO PREJUIZO
        2392  ESTORNO PAGAMENTO DE PREJUIZO VALOR PRINCIPAL
        2393  ESTORNO PAGAMENTO DE JUROS PREJUIZO
        2394  ESTORNO PAGAMENTO MULTA ATRASO PREJUIZO
        2473  PAGAMENTO JUROS +60 PREJUIZO
        2474  ESTORNO PAGAMENTO JUROS +60 PREJUIZO
        2475  PAGAMENTO JUROS MORA PREJUIZO
        2476  ESTORNO PAGAMENTO JUROS MORA PREJUIZO
        --
      */      
      -- Buscar somatorio prejuizo historico      
      -- Busca dos pagamentos de preju�zo
      CURSOR cr_craplem_prejuz (pr_dtrefere IN craplem.dtmvtolt%type) IS
        SELECT  craplem.nrdconta
               ,craplem.nrctremp
           --,NVL(SUM(NVL(craplem.vllanmto,0)),0) vllanmto
          ,sum(case when craplem.cdhistor in (382,383,2388,2473,2389,2390,2475) then craplem.vllanmto else 0 end) - 
               sum(case when craplem.cdhistor in (2392,2474,2393,2394,2476) then craplem.vllanmto else 0 end) vllanmto
          FROM craplem craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.dtmvtolt <= pr_dtrefere
           -- 382-PAG.PREJ.ORIG E 383-ABONO PREJUIZO
           AND craplem.cdhistor IN (382,383,2388,2473,2389,2390,2475,2392,2474,2393,2394,2476)
         GROUP BY craplem.nrdconta,craplem.nrctremp;
      TYPE typ_craplem IS TABLE OF cr_craplem_prejuz%ROWTYPE INDEX BY PLS_INTEGER;
      r_craplem typ_craplem;  
      
      --> Buscar menor data de vencimento em aberto da parcela de emprestimo
      CURSOR cr_crappep_maior_carga IS 
        SELECT nrdconta
              ,nrctremp
              ,MIN(dtvencto) dtvencto
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND (inliquid = 0 OR inprejuz = 1)
           AND dtvencto <= pr_rw_crapdat.dtmvtoan
         GROUP BY nrdconta
                 ,nrctremp;
                                                 
      --> Buscar vencimentos daos emprestimos de cessao de cartao
      CURSOR cr_cessao_carga IS
        SELECT ces.nrdconta
              ,ces.nrctremp
              ,ces.dtvencto
          FROM tbcrd_cessao_credito ces
          JOIN crapepr epr
            ON epr.cdcooper = ces.cdcooper
           AND epr.nrdconta = ces.nrdconta
           AND epr.nrctremp = ces.nrctremp
         WHERE ces.cdcooper = pr_cdcooper
           AND (epr.inliquid = 0 OR epr.inprejuz = 1);                                                 
                                                 
      --> Buscar ultimo nivel de risco
      CURSOR cr_crapris_9 (pr_cdcooper IN crapris.cdcooper%TYPE,
                           pr_nrdconta IN crapris.nrdconta%TYPE,
                           pr_nrctremp IN crapris.nrctremp%TYPE) IS
        SELECT max(ris.dtrefere) dtrefere, 
               max(ris.qtdiaatr) qtdiaatr
          FROM crapris ris 
         WHERE ris.cdcooper = pr_cdcooper 
           AND ris.innivris = 9 
           AND ris.nrdconta = pr_nrdconta 
           AND ris.nrctremp = pr_nrctremp;
      rw_crapris_9 cr_crapris_9%ROWTYPE;
      
      
      --> Buscar ultimo nivel de risco 9 da linha 100
      CURSOR cr_crapris_9_100 (pr_cdcooper IN crapris.cdcooper%TYPE,
                               pr_nrdconta IN crapris.nrdconta%TYPE,
                               pr_nrctremp IN crapris.nrctremp%TYPE) IS
        SELECT ris.dtrefere dtrefere, 
               ris.qtdiaatr qtdiaatr
          FROM crapris ris,
               crapepr epr 
         WHERE ris.cdcooper = epr.cdcooper
           AND ris.nrdconta = epr.nrdconta
           --> filtrar emp baseado no filtro
           AND epr.nrctremp = pr_nrctremp
           --> buscar o risco referente ao ultimo m�s antes de ser transferido para prejuizo
           AND ris.dtrefere = last_day(add_months( epr.dtmvtolt,-1))
           AND ris.cdcooper = pr_cdcooper 
           AND ris.innivris = 9 
           AND ris.cdorigem = 1
           --> buscar risco baseado na conta(estouro de conta)
           AND ris.nrdconta = pr_nrdconta 
           AND ris.nrctremp = pr_nrdconta;
      rw_crapris_9_100 cr_crapris_9_100%ROWTYPE;
     
                     
      -------- Tipos e registros gen�ricos ------------

      -- Vetor para armazenar os dados de riscos, dessa forma temos o valor
      -- char do risco (AA, A, B...HH) como chave e o valor � seu indice
      TYPE typ_tab_risco IS
        TABLE OF PLS_INTEGER
          INDEX BY VARCHAR2(2);
      vr_tab_risco typ_tab_risco;

      -- Outro vetor para armazenar os dados do risco, por�m chaveado
      -- pelo n�vel em n�mero e nao em texto
      TYPE typ_tab_risco_num IS
        TABLE OF VARCHAR2(2)
          INDEX BY PLS_INTEGER;
      vr_tab_risco_num typ_tab_risco_num;

      -- Cria��o de tipo de registro para armazenar o n�vel de risco para cada conta
      -- Sendo a chave da tabela a conta com zeros a esquerda(10)
      TYPE typ_tab_crapass_nivel IS
        TABLE OF VARCHAR2(2)
          INDEX BY PLS_INTEGER;
      vr_tab_assnivel typ_tab_crapass_nivel;

      TYPE typ_tab_crapass_cpfcnpj IS
        TABLE OF VARCHAR2(2)
          INDEX BY VARCHAR2(14);
      vr_tab_ass_cpfcnpj typ_tab_crapass_cpfcnpj;

      -- Defini��o de tipo para armazenar os dados de linhas de credito
      -- sendo a chave o c�digo da linha de cr�dito e armazenaremos apenas a
      -- sua descri��o
      TYPE typ_reg_craplcr IS
        RECORD(perjurmo craplcr.perjurmo%TYPE
              ,dsoperac craplcr.dsoperac%TYPE);
      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY PLS_INTEGER;
      vr_tab_craplcr typ_tab_craplcr;

      -- Defini��o de tipo e tabela para armazenar as informa��es da tabela
      -- crapnrc(notas de rating do contrado da conta), e assim efetuar menos
      -- leituras na mesma
      TYPE typ_reg_crapnrc IS
        RECORD(indrisco VARCHAR2(2)
              ,dtmvtolt DATE);
      TYPE typ_tab_crapnrc IS
        TABLE OF typ_reg_crapnrc
          INDEX BY BINARY_INTEGER; --> A conta ser� a chave
      -- Vetor para armazenar os dados de cta BNDES
      vr_tab_crapnrc typ_tab_crapnrc;

      -- Tipo para armazenar as informa��es da cr_crapbdc
      TYPE typ_reg_crapbdc IS
        RECORD(nrctrlim crapbdc.nrctrlim%TYPE
              ,dtlibbdc crapbdc.dtlibbdc%TYPE
              ,nrborder crapbdc.nrborder%TYPE);
      -- Tabela para armazenar registros do tipo acima
      TYPE typ_tab_crapbdc IS
        TABLE OF typ_reg_crapbdc
          INDEX BY VARCHAR2(20); --> DataMvto(8) + Sequencia(12) do registro pra evitar sobreposi�ao
      -- Chave para a tabela acima
      vr_dschave_bdc VARCHAR2(20);

      -- Defini��o de tipo e tabela para armazenar
      -- as informa��es da crapbdc por conta
      TYPE typ_reg_ctbbdc IS
        RECORD(tbcrapbdc typ_tab_crapbdc);
      TYPE typ_tab_ctabdc IS
        TABLE OF typ_reg_ctbbdc
          INDEX BY BINARY_INTEGER; --> O n�mero da conta ser� a chave
      -- Vetor para armazenar as contas encontradas na crapbdt
      vr_tab_ctabdc typ_tab_ctabdc;

      -- Tipo para armazenar as informa��es da cr_crapcdb
      TYPE typ_reg_crapcdb IS
        RECORD(nrdconta crapcdb.nrdconta%TYPE
              ,vlliquid crapcdb.vlliquid%TYPE
              ,dtlibera crapcdb.dtlibera%TYPE
              ,dtlibbdc crapcdb.dtlibbdc%TYPE
              ,cdcmpchq crapcdb.cdcmpchq%TYPE
              ,cdbanchq crapcdb.cdbanchq%TYPE
              ,cdagechq crapcdb.cdagechq%TYPE
              ,nrctachq crapcdb.nrctachq%TYPE
              ,nrcheque crapcdb.nrcheque%TYPE
              ,dtdevolu crapcdb.dtdevolu%TYPE);
      -- Tabela para armazenar registros do tipo acima
      TYPE typ_tab_crapcdb IS
        TABLE OF typ_reg_crapcdb
          INDEX BY VARCHAR2(50); --> Utilizaremos o ProgressRecid como chave
      vr_dschave_crapcdb VARCHAR2(50);
      -- Tambem criamos uma variavel baseada no tipo do vetor interno, para facilitar sua leitura
      vr_aux_reg_cdb typ_reg_crapcdb;

      -- Defini��o de tipo e tabela para armazenar
      -- as informa��es da crapbdc por border�
      TYPE typ_reg_bord_cdb IS
        RECORD(tbcrapcdb typ_tab_crapcdb);
      TYPE typ_tab_bord_cdb IS
        TABLE OF typ_reg_bord_cdb
          INDEX BY BINARY_INTEGER; --> O n�mero do border� ser� a chave
      -- Vetor para armazenar os borderos encontrados
      vr_tab_bord_cdb typ_tab_bord_cdb;

      -- Defini��o de tipo e tabela para armazenar as informa��es de saldo da conta
      -- sendo a chave o n�mero da conta, isto ajuda no desempenho
      TYPE typ_reg_crapsld IS
        RECORD(vlsddisp crapsld.vlsddisp%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE
              ,vlbloque NUMBER
              ,dtrisclq crapsld.dtrisclq%TYPE
              ,qtdriclq crapsld.qtdriclq%TYPE);
      TYPE typ_tab_crapsld IS
        TABLE OF typ_reg_crapsld
          INDEX BY BINARY_INTEGER; --> A conta ser� a chave
      -- Vetor para armazenar os dados de cta BNDES
      vr_tab_crapsld typ_tab_crapsld;

      -- Vetor para armazenar os dias de cada parcela a vencer e vencidas
      TYPE typ_tab_ddparcel IS
        TABLE OF PLS_INTEGER
          INDEX BY PLS_INTEGER;
      -- Instanciar dois vetores, um para vencidas e outro para a vencer
      vr_tab_ddavence typ_tab_ddparcel;
      vr_tab_ddvencid typ_tab_ddparcel;

      -- Tipo para vetor para armazenar valores
      -- das parcelas a vencer e vencidas
      TYPE typ_tab_vlparcel IS
        TABLE OF NUMBER
          INDEX BY PLS_INTEGER;
      -- Instanciamos dois vetores, um para parcelas
      -- a vencer e outro para as vencidas
      vr_tab_vlavence typ_tab_vlparcel;
      vr_tab_vlvencid typ_tab_vlparcel;

      -- Defini��o de tipo e tabela para armazenar as informa��es de vencimento
      TYPE typ_tab_vencto IS
        TABLE OF PLS_INTEGER
          INDEX BY BINARY_INTEGER; --> O c�digo de vcto ser� a chave
      -- Vetor para armazenar os dados de vencimento
      vr_tab_vencto typ_tab_vencto;

      -- Defini��o de tipo e tabela para armazenar se a conta existe em determinada tabela
      TYPE typ_tab_exicta IS
        TABLE OF crapass.nrdconta%TYPE
          INDEX BY BINARY_INTEGER; --> O n�mero da conta ser� a chave
      -- Vetor para armazenar as contas encontradas na crapbdt
      vr_tab_ctabdt typ_tab_exicta;

      -- Definicao de tipo e tabela para armazenar contas que possuem prejuizo
      TYPE typ_tab_prejuz IS
        TABLE OF crapepr.vlprejuz%type 
          INDEX BY VARCHAR2(20); --> O n�mero da conta + nr contrato ser�o as chaves
      vr_tab_prejuz typ_tab_prejuz;
      
      -- Definicao de tipo de registro e tabela para manter os vencimentos de risco
      TYPE typ_reg_crapvri IS
        RECORD (cdcooper crapvri.cdcooper%type
               ,nrdconta crapvri.nrdconta%type
               ,dtrefere crapvri.dtrefere%type
               ,innivris crapvri.innivris%type
               ,cdmodali crapvri.cdmodali%type
               ,cdvencto crapvri.cdvencto%type
               ,nrctremp crapvri.nrctremp%type
               ,nrseqctr crapvri.nrseqctr%type
               ,vldivida crapvri.vldivida%type);
      TYPE typ_tab_crapvri IS TABLE OF typ_reg_crapvri INDEX BY PLS_INTEGER; 
      vr_tab_crapvri typ_tab_crapvri;        
      TYPE typ_tab_crapvri_temp IS TABLE OF typ_reg_crapvri INDEX BY VARCHAR2(500);--BY PLS_INTEGER;
      vr_tab_crapvri_temp typ_tab_crapvri_temp;
      
      -- Definicao de tipo de registro e tabela para manter os riscos para posteriormente gravar
      TYPE typ_tab_crapris IS TABLE OF crapris%ROWTYPE INDEX BY PLS_INTEGER;
      vr_tab_crapris typ_tab_crapris;
      
      -- Definicao de tipo de registro e tabela para manter os vencimentos de risco
      TYPE typ_reg_crapvri_2 IS
        RECORD (innivris crapvri.innivris%type
               ,cdvencto crapvri.cdvencto%type
               ,vr_rowid rowid);
      TYPE typ_tab_crapvri_2 IS TABLE OF typ_reg_crapvri_2 INDEX BY PLS_INTEGER;
      vr_tab_crapvri_2 typ_tab_crapvri_2;
      
      -- Temp Table para armazenar dados para update na tabela crawepr
      TYPE typ_reg_crawepr_up IS 
         RECORD ( cdcooper crawepr.cdcooper%TYPE
                 ,nrdconta crawepr.nrdconta%TYPE
                 ,nrctremp crawepr.nrctremp%TYPE
                 ,dsnivcal crawepr.dsnivcal%TYPE);
      TYPE typ_tab_crawepr_up IS TABLE OF typ_reg_crawepr_up
        INDEX BY PLS_INTEGER;
      vr_tab_crawepr_up typ_tab_crawepr_up;
      
      -- Temp Table para armazenar a data do maior atraso
      TYPE typ_tab_crappep_maior IS TABLE OF DATE
        INDEX BY VARCHAR2(50); -- cdcooper + nrdconta + nrctremp
      vr_tab_crappep_maior typ_tab_crappep_maior;

      -- Temp Table para armazenar se � emprestimos de cessao de credito
      TYPE typ_tab_cessoes IS TABLE OF DATE
        INDEX BY VARCHAR2(50); -- cdcooper + nrdconta + nrctremp
      vr_tab_cessoes typ_tab_cessoes;
      
      --> TempTable para armazenar os emprestimos que devem ser processados
      TYPE typ_tab_rowid IS TABLE OF ROWID INDEX BY VARCHAR2(20);
      TYPE typ_tab_crapepr_rw IS TABLE OF typ_tab_rowid 
        INDEX BY VARCHAR2(20); -- cdcooper + nrdconta
      vr_tab_crapepr_rw typ_tab_crapepr_rw;
      
      -- TempTable para armazenar as contas que possuem risco soberano
      TYPE typ_reg_contas_risco_soberano IS 
         RECORD (innivris crapris.innivris%TYPE);      
      TYPE typ_tab_contas_risco_soberano IS TABLE OF typ_reg_contas_risco_soberano INDEX BY PLS_INTEGER;
      vr_tab_contas_risco_soberano typ_tab_contas_risco_soberano;
      

      -- Registro de Associado que precisam alterar o Risco
      TYPE typ_ass_ris IS
        RECORD(cdcooper      crapris.cdcooper%TYPE
              ,nrdconta      crapris.nrdconta%TYPE
              ,nrcpfcgc      crapris.nrcpfcgc%TYPE
              ,maxrisco      crapris.innivris%TYPE
              ,inpessoa      crapris.inpessoa%TYPE);
                  
      -- Defini��o de um tipo de tabela com o registro acima
      TYPE typ_tab_ass_ris IS
        TABLE OF typ_ass_ris
          INDEX BY PLS_INTEGER;
      vr_tab_ass_ris   typ_tab_ass_ris;



      -- Variaves do processo
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
      vr_dtrefere     DATE;                   --> Data de refer�ncia do processo
      vr_dtrefere_aux DATE;                   --> Data de refer�ncia auxiliar do processo
      vr_risco_rating PLS_INTEGER;            --> N�vel do risco auxiliar
      vr_risco_aux    PLS_INTEGER;            --> N�vel de risco auxiliar 2
      vr_nrseqctr     crapris.nrseqctr%TYPE;  --> Sequencia de contrato de empr�stimo
      vr_vlsddisp     NUMBER;                 --> Saldo dispon�vel na conta
      vr_dtfimvig     DATE;                   --> Data auxiliar de fim da vig�ncia do risco
      vr_nrctrlim     NUMBER(8);              --> N�mero do contrato quando risco de limite de conta
      vr_vlbloque     NUMBER;                 --> Sumarizar valor bloqueado na conta
      vr_vlsrisco     NUMBER;                 --> Valor saldo para o risco
      vr_vldivida     NUMBER;                 --> Valor da d�vida
      vr_dtinictr     DATE;                   --> Data inicial do contrato de risco
      vr_diasvenc     NUMBER;                 --> Dias vencidos do risco
      vr_cdvencto     NUMBER;                 --> C�digo do vencimento para lan�amento da crapvri
      vr_qtdiaatr     NUMBER;                 --> Qtde dias em atraso
      vr_qtdiapre     PLS_INTEGER;            --> Qtdade dias corridos do empr�stimo
      vr_vldeschq     NUMBER;                 --> Valor de desconto de cheques
      vr_vldes180     NUMBER;                 --> Guardar o valor a vencer para cheques de 180 dias
      vr_vldes360     NUMBER;                 --> Guardar o valor a vencer para cheques de 360 dias
      vr_vldes999     NUMBER;                 --> Guardar o valor a vencer para cheques outros prazos
      vr_qtdprazo     PLS_INTEGER;            --> Prazo para os cheques
      vr_vldestit     NUMBER;                 --> Valor de desconto de titulos
      vr_vltit180     NUMBER;                 --> Guardar o valor a vencer para titulos de 180 dias
      vr_vltit360     NUMBER;                 --> Guardar o valor a vencer para titulos de 360 dias
      vr_vltit999     NUMBER;                 --> Guardar o valor a vencer para titulos outros prazos
      vr_cdorigem     NUMBER;                 --> Inidice auxiliar para gravacao registro com e sem cobran�a
      vr_nrborder     NUMBER;                 --> N�mero do border�
      vr_innivris     NUMBER;                 --> Nivel de risco
      vr_dtrisclq     DATE;
      vr_dtvencop     DATE;                   --> Data de Vencimento da Operacao
      
      vr_vldiv060     crapris.vldiv060%TYPE; --> Valor do atraso quando prazo inferior a 60
      vr_vldiv180     crapris.vldiv180%TYPE; --> Valor do atraso quando prazo inferior a 180
      vr_vldiv360     crapris.vldiv360%TYPE; --> Valor do atraso quando prazo inferior a 360
      vr_vldiv999     crapris.vldiv999%TYPE; --> Valor do atraso para outros casos
      vr_vlvec180     crapris.vlvec180%TYPE; --> Valor a vencer nos pr�ximos 180 dias
      vr_vlvec360     crapris.vlvec360%TYPE; --> Valor a vencer nos pr�ximos 360 dias
      vr_vlvec999     crapris.vlvec999%TYPE; --> Valor a vencer para outros casos
      vr_vlprjano     crapris.vlprjano%TYPE; --> Valor prejuizo no ano corrente
      vr_vlprjaan     crapris.vlprjaan%TYPE; --> Valor prejuizo no ano anterior
      vr_vlprjant     crapris.vlprjant%TYPE; --> Valor prejuizo anterior
      
      vr_dtprxpar     crapris.dtprxpar%TYPE; --> Data da pr�xima parcela do Fluxo Financeiro
      vr_vlprxpar     crapris.vlprxpar%TYPE; --> Valor da pr�xima parcela do Fluxo Financeiro
      vr_qtparcel     crapris.qtparcel%TYPE; --> Quantidade de parcelas para o Fluxo Financeiro
      
      vr_dsinfaux     crapris.dsinfaux%TYPE; --> Campo gen�rico para envio de informa��o adicional ao risco
      
      -- Variaveis para o XML de dados
      vr_clobxml CLOB; --> crrl349
      -- Vari�vel para o caminho dos arquivos no rl
      vr_nom_direto  VARCHAR2(200);

      -- Variaveis de par�metros
      vr_qtdrisco NUMBER; -- Dias para considerar o atraso um risco

      -- ID para o paralelismo
      vr_idparale      integer;
      -- Qtde parametrizada de Jobs
      vr_qtdjobs       number;
      -- Quantidade de PA's com erro
      vr_tot_paerr     number;
      vr_qterro        number;
      -- Job name dos processos criados
      --vr_jobname       varchar2(30);

      --C�digo de controle retornado pela rotina gene0001.pc_grava_batch_controle
      vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
      vr_idlog_ini_ger tbgen_prglog.idprglog%type;
      vr_idlog_ini_par tbgen_prglog.idprglog%type;

      /* Cursores da rotina CRPS310 */

      -- Ag�ncias por cooperativa com clientes
      cursor cr_crapass_age (pr_cdcooper in crapass.cdcooper%type,
                             pr_dtmvtolt in crapdat.dtmvtolt%type,
                             pr_qterro   in number,
                             pr_cdprogra in tbgen_batch_controle.cdprogra%type) is
        SELECT distinct cdagenci
        FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
        --
        and (pr_qterro  = 0 or      -- Processamento Normal
            (pr_qterro >= 1         -- Reprocessamento
                          and exists (select 1
                                        from tbgen_batch_controle
                                       where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                         and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                         and tbgen_batch_controle.tpagrupador = 1
                                         and tbgen_batch_controle.cdagrupador = crapass.cdagenci
                                         and tbgen_batch_controle.insituacao  = 1
                                         and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
        order by cdagenci;

      -- Ag�ncias com erro
      cursor cr_crapass_err (pr_cdcooper in crapass.cdcooper%type,
                             pr_dtmvtolt in crapdat.dtmvtolt%type,
                             pr_cdprogra in tbgen_batch_controle.cdprogra%type) is
        SELECT distinct cdagenci
        FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
        and exists (select 1
                      from tbgen_batch_controle
                     where tbgen_batch_controle.cdcooper    = pr_cdcooper
                       and tbgen_batch_controle.cdprogra    = pr_cdprogra
                       and tbgen_batch_controle.tpagrupador = 1
                       and tbgen_batch_controle.cdagrupador = crapass.cdagenci
                       and tbgen_batch_controle.insituacao  = 1
                       and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)
        order by cdagenci;

      -- Variaveis de Indices para temp-tables
      vr_index_prejuz VARCHAR2(20);
      vr_idx_crawepr_up PLS_INTEGER;
      vr_index_crapvri PLS_INTEGER;
      vr_index_crapvri_temp varchar2(500); --PLS_INTEGER;
      vr_index_crapris PLS_INTEGER;
      vr_index_crapris_aux PLS_INTEGER;
      vr_idxpep            VARCHAR2(50);
      vr_idxepr            VARCHAR2(20);
      vr_idxepr_rw         VARCHAR2(20);
      
      vr_idx_ass_ris   PLS_INTEGER:=0;

      vr_dsmensag varchar2(400);


      -- variaveis para cria��o de rotina paralela
      vr_dsplsql VARCHAR2(4000);
      vr_jobname VARCHAR2(4000);
      
      -- Subrotina para escrever texto na vari�vel CLOB do XML
      PROCEDURE pc_escreve_xml(pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_clobxml,length(pr_desdados),pr_desdados);
      END;
      
      -- Funcao para calcular o Juros 60 do produto PP
      FUNCTION fn_calcula_juros_60d_pp(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE
                                      ,pr_dtdpagto IN crapepr.dtdpagto%TYPE
                                      ,pr_diarefju IN crapepr.diarefju%TYPE
                                      ,pr_mesrefju IN crapepr.mesrefju%TYPE
                                      ,pr_anorefju IN crapepr.anorefju%TYPE
                                      ,pr_txjuremp IN crapepr.txjuremp%TYPE
                                      ,pr_dtlibera IN crawepr.dtlibera%TYPE
                                      ,pr_vlsdeved IN crapepr.vlsdeved%TYPE) RETURN NUMBER IS
        vr_qtdiajur	 INTEGER;
    		vr_diavtolt  INTEGER;
        vr_mesvtolt  INTEGER;
        vr_anovtolt  INTEGER;
        vr_diarefju  INTEGER;
        vr_mesrefju  INTEGER;
        vr_anorefju  INTEGER;
		    vr_potencia  NUMBER(30,10);
    		vr_vljurmes  crapepr.vljurmes%TYPE;
        vr_ehmensal  BOOLEAN := FALSE;
      BEGIN
        --Dia/Mes/Ano Referencia
        IF pr_diarefju <> 0 AND pr_mesrefju <> 0 AND pr_anorefju <> 0 THEN
          --Setar Dia/mes?ano
        vr_diavtolt := pr_diarefju;
        vr_mesvtolt := pr_mesrefju;
        vr_anovtolt := pr_anorefju;        
        ELSE
          --Setar dia/mes/ano
          vr_diavtolt := to_number(to_char(pr_dtlibera, 'DD'));
          vr_mesvtolt := to_number(to_char(pr_dtlibera, 'MM'));
          vr_anovtolt := to_number(to_char(pr_dtlibera, 'YYYY'));
        END IF;     
      
        --Retornar Dia/mes/ano de referencia
        vr_diarefju := to_number(to_char(pr_dtmvtolt, 'DD'));
        vr_mesrefju := to_number(to_char(pr_dtmvtolt, 'MM'));
        vr_anorefju := to_number(to_char(pr_dtmvtolt, 'YYYY'));
        
        -- Condicao para verificar se eh mensal
        IF to_char(pr_dtmvtolt,'mm') != to_char(pr_dtmvtopr,'mm') THEN
          vr_ehmensal := TRUE;
        END IF;
        
        --Calcular Quantidade dias
        EMPR0001.pc_calc_dias360(pr_ehmensal => vr_ehmensal -- Indica se juros esta rodando na mensal
                                ,pr_dtdpagto => to_char(pr_dtdpagto, 'DD') -- Dia do primeiro vencimento do emprestimo
                                ,pr_diarefju => vr_diavtolt -- Dia da data de refer�ncia da �ltima vez que rodou juros
                                ,pr_mesrefju => vr_mesvtolt -- Mes da data de refer�ncia da �ltima vez que rodou juros
                                ,pr_anorefju => vr_anovtolt -- Ano da data de refer�ncia da �ltima vez que rodou juros
                                ,pr_diafinal => vr_diarefju -- Dia data final
                                ,pr_mesfinal => vr_mesrefju -- Mes data final
                                ,pr_anofinal => vr_anorefju -- Ano data final
                                ,pr_qtdedias => vr_qtdiajur); -- Quantidade de dias calculada
        -- Calcular Juros
        vr_potencia := POWER(1 + (pr_txjuremp / 100), vr_qtdiajur);
        -- Retornar Juros do Mes
        vr_vljurmes := pr_vlsdeved * (vr_potencia - 1);      
        -- Se valor for zero ou negativo
        IF vr_vljurmes <= 0 THEN
          -- zerar Valor
          vr_vljurmes := 0;
        END IF;
		
		    RETURN vr_vljurmes;        
      END;
      
      -- Procedure para calcular o Juros 60 do produto Pos Fixado
      PROCEDURE pc_calcula_juros_60d_pos(pr_cdcooper IN craplem.cdcooper%TYPE
                                        ,pr_nrdconta IN craplem.nrdconta%TYPE
                                        ,pr_nrctremp IN craplem.nrctremp%TYPE
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                        ,pr_qtdiaatr IN PLS_INTEGER
                                        ,pr_txmensal IN crapepr.txmensal%TYPE
                                        ,pr_qttolatr IN crapepr.qttolatr%TYPE
                                        ,pr_cdlcremp IN crapepr.cdlcremp%TYPE
                                        ,pr_vlemprst IN crapepr.vlemprst%TYPE
                                        ,pr_vlmrapar OUT crappep.vlmrapar%TYPE
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
                                        
        -- Busca as parcelas atrasadas
        CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                         ,pr_nrdconta IN crappep.nrdconta%TYPE
                         ,pr_nrctremp IN crappep.nrctremp%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_qtdiaatr IN PLS_INTEGER) IS
          SELECT crappep.nrparepr
                ,crappep.vlparepr
                ,crappep.dtvencto
                ,crappep.dtultpag
                ,crappep.vlsdvpar
            FROM crappep
           WHERE crappep.cdcooper = pr_cdcooper
             AND crappep.nrdconta = pr_nrdconta
             AND crappep.nrctremp = pr_nrctremp
             AND crappep.inliquid = 0 
             AND crappep.dtvencto > pr_dtmvtolt - (pr_qtdiaatr - 59);
                
        -- Lancamentos do Juros de Mora
        CURSOR cr_craplem_mora (pr_cdcooper	IN craplem.cdcooper%TYPE
                               ,pr_nrdconta IN craplem.nrdconta%TYPE
                               ,pr_nrctremp IN craplem.nrctremp%TYPE
                               ,pr_nrparepr IN craplem.nrparepr%TYPE) IS
          SELECT nvl(SUM(decode(cdhistor,
                                2373, vllanmto,
                                2371, vllanmto,
                                2377, vllanmto,
                                2375, vllanmto,
                                2347, vllanmto * -1,
                                2346, vllanmto * -1)), 0) vllanmto
            FROM craplem
           WHERE craplem.cdcooper = pr_cdcooper
             AND craplem.nrdconta = pr_nrdconta
             AND craplem.nrctremp = pr_nrctremp
             AND craplem.nrparepr = pr_nrparepr
             AND craplem.cdhistor IN (2373,2371,2377,2375,2347,2346);        
                
        vr_vljuros_mora_debito NUMBER(25,2);
        vr_vlmrapar            NUMBER(25,2);
        vr_vlmtapar	           NUMBER(25,2);
        vr_vliofcpl            NUMBER(25,2);
        vr_perjurmo            craplcr.perjurmo%TYPE;
           
        -- Variaveis para controle de critica
        vr_exc_saida           exception;
        vr_cdcritic            PLS_INTEGER;
        vr_dscritic            VARCHAR(4000);
      BEGIN
        vr_vlmrapar := 0;
        
        -- Condicao para verificar se a linha de credito existe
        vr_perjurmo := 0;
        IF vr_tab_craplcr.EXISTS(pr_cdlcremp) THEN
          vr_perjurmo := vr_tab_craplcr(pr_cdlcremp).perjurmo;
        END IF;
          
        -- Listagem das parcelas vencidas
        FOR rw_crappep IN cr_crappep(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_qtdiaatr => pr_qtdiaatr) LOOP

          -- Procedure para calcular o Valor de Juros de Mora
          EMPR0011.pc_calcula_atraso_pos_fixado(pr_cdcooper => pr_cdcooper
                                               ,pr_cdprogra => pr_cdprogra
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrctremp => pr_nrctremp
                                               ,pr_cdlcremp => pr_cdlcremp         
                                               ,pr_dtcalcul => pr_dtmvtolt
                                               ,pr_vlemprst => pr_vlemprst
                                               ,pr_nrparepr => rw_crappep.nrparepr
                                               ,pr_vlparepr => rw_crappep.vlparepr
                                               ,pr_dtvencto => rw_crappep.dtvencto
                                               ,pr_dtultpag => rw_crappep.dtultpag
                                               ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                               ,pr_perjurmo => vr_perjurmo
                                               ,pr_vlpagmta => 0
                                               ,pr_percmult => 0
                                               ,pr_txmensal => pr_txmensal
                                               ,pr_qttolatr => pr_qttolatr
                                               ,pr_vlmrapar => vr_vlmrapar
                                               ,pr_vlmtapar => vr_vlmtapar
                                               ,pr_vliofcpl => vr_vliofcpl
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          vr_vljuros_mora_debito := 0;
          OPEN cr_craplem_mora(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctremp => pr_nrctremp
                              ,pr_nrparepr => rw_crappep.nrparepr);
          FETCH cr_craplem_mora INTO vr_vljuros_mora_debito;
          CLOSE cr_craplem_mora;
        
          -- Somente lancar a diferenca do Juros de Mora do que jah foi lancado
          pr_vlmrapar := NVL(pr_vlmrapar,0) + NVL(vr_vlmrapar,0) + NVL(vr_vljuros_mora_debito,0);
        END LOOP;
        
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Apenas retornar a vari�vel de saida
          IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_dscritic := 'pc_calcula_juros_60d_pos --> Erro ao calcular o Juros.'||sqlerrm;       
      END pc_calcula_juros_60d_pos;
      
      -- Subrotina para calculo do c�digo de vencimento
      FUNCTION fn_calc_codigo_vcto(pr_diasvenc IN OUT NUMBER
                                  ,pr_qtdiapre IN NUMBER DEFAULT 0
                                  ,pr_flgempre IN BOOLEAN DEFAULT FALSE) RETURN NUMBER IS
      BEGIN
        -- Se for cr�dito a vencer
        IF pr_diasvenc >= 0  THEN
          IF  pr_diasvenc <= 30 THEN
            RETURN 110;
          ELSIF pr_diasvenc <= 60 THEN
            IF pr_qtdiapre <= 30 AND pr_flgempre THEN
              RETURN 110;
            ELSE
             RETURN 120;
            END IF;
          ELSIF pr_diasvenc <= 90 THEN
            IF pr_qtdiapre <= 60 AND pr_flgempre THEN
              RETURN 120;
            ELSE
              RETURN 130;
            END IF;
          ELSIF pr_diasvenc <= 180 THEN
            IF pr_qtdiapre <= 90 AND pr_flgempre THEN
              RETURN 130;
            ELSE
              RETURN 140;
            END IF;
          ELSIF pr_diasvenc <= 360 THEN
            IF pr_qtdiapre <= 180 AND pr_flgempre THEN
              RETURN 140;
            ELSE
              RETURN 150;
            END IF;
          ELSIF pr_diasvenc <= 720 THEN
            IF pr_qtdiapre <= 360 AND pr_flgempre THEN
              RETURN 150;
            ELSE
              RETURN 160;
            END IF;
          ELSIF pr_diasvenc <= 1080 THEN
            IF pr_qtdiapre <= 720 AND pr_flgempre THEN
              RETURN 160;
            ELSE
              RETURN 165;
            END IF;
          ELSIF  pr_diasvenc <= 1440 THEN
            IF pr_qtdiapre <= 1080 AND pr_flgempre THEN
              RETURN 165;
            ELSE
              RETURN 170;
            END IF;
          ELSIF pr_diasvenc <= 1800 THEN
            IF pr_qtdiapre <= 1440 AND pr_flgempre THEN
              RETURN 170;
            ELSE
              RETURN 175;
            END IF;
          ELSIF pr_diasvenc <= 5400 THEN
            IF pr_qtdiapre <= 1800 AND pr_flgempre THEN
              RETURN 175;
            ELSE
              RETURN 180;
            END IF;
          ELSIF pr_qtdiapre <= 5400 AND pr_flgempre THEN
            RETURN 180;
          ELSE
            RETURN 190;
          END IF;
        ELSE -- Creditos Vencidos
          -- Multiplicar por -1 para que os dias fiquem no passado
          pr_diasvenc := pr_diasvenc * -1;
          IF pr_diasvenc <= 14 THEN
            RETURN 205;
          ELSIF pr_diasvenc <= 30 THEN
            RETURN 210;
          ELSIF pr_diasvenc <= 60 THEN
            RETURN 220;
          ELSIF pr_diasvenc <= 90 THEN
            RETURN 230;
          ELSIF pr_diasvenc <= 120 THEN
            RETURN 240;
          ELSIF pr_diasvenc <= 150 THEN
            RETURN 245;
          ELSIF pr_diasvenc <= 180 THEN
            RETURN 250;
          ELSIF pr_diasvenc <= 240 THEN
            RETURN 255;
          ELSIF pr_diasvenc <= 300 THEN
            RETURN 260;
          ELSIF pr_diasvenc <= 360 THEN
            RETURN 270;
          ELSIF pr_diasvenc <= 540 THEN
            RETURN 280;
          ELSE
            RETURN 290;
          END IF;
        END IF;
      END;

      -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
      PROCEDURE pc_grava_crapris( pr_nrdconta crapris.nrdconta%TYPE,    --> numero da conta/dv do associado.
                                  pr_dtrefere crapris.dtrefere%TYPE,    --> data de referencia.
                                  pr_innivris crapris.innivris%TYPE,    --> nivel de risco do ge (1 a 9).
                                  pr_qtdiaatr crapris.qtdiaatr%TYPE,    --> dias em atraso.
                                  pr_vldivida crapris.vldivida%TYPE,    --> valor da divida.
                                  pr_vlvec180 crapris.vlvec180%TYPE,    --> valor a vencer em 180 dias.
                                  pr_vlvec360 crapris.vlvec360%TYPE,    --> valor a vencer em 360 dias.
                                  pr_vlvec999 crapris.vlvec999%TYPE,    --> valor a vencer acima de 360 dias.
                                  pr_vldiv060 crapris.vldiv060%TYPE,    --> valor da divida vencida a 60 dias.
                                  pr_vldiv180 crapris.vldiv180%TYPE,    --> valor da divida vencida a 180 dias.
                                  pr_vldiv360 crapris.vldiv360%TYPE,    --> valor da divida vencida a 360 dias.
                                  pr_vldiv999 crapris.vldiv999%TYPE,    --> valor da divida vencida a mais de 360 dias.
                                  pr_vlprjano crapris.vlprjano%TYPE,    --> valor do prejuizo lancado nos ultimos 12 meses.
                                  pr_vlprjaan crapris.vlprjaan%TYPE,    --> valor do prejuizo lancado a mais de 12 meses.
                                  pr_inpessoa crapris.inpessoa%TYPE,    --> tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
                                  pr_nrcpfcgc crapris.nrcpfcgc%TYPE,    --> numero do cpf/cgc do associado.
                                  pr_vlprjant crapris.vlprjant%TYPE,    --> prejuizo lancado a +48 meses.
                                  pr_inddocto crapris.inddocto%TYPE,    --> indica docto(0 - 3010 / 1 - 3020)
                                  pr_cdmodali crapris.cdmodali%TYPE,    --> modalidade
                                  pr_nrctremp crapris.nrctremp%TYPE,    --> numero contrato/conta
                                  pr_nrseqctr crapris.nrseqctr%TYPE,    --> nro seq.contrato
                                  pr_dtinictr crapris.dtinictr%TYPE,    --> data inicio contrato
                                  pr_cdorigem crapris.cdorigem%TYPE,    --> origem(1- conta , 2 - desconto cheques, 3 - emprestimos)
                                  pr_cdagenci crapris.cdagenci%TYPE,    --> numero do pa.
                                  pr_innivori crapris.innivori%TYPE,    --> nivel de risco original
                                  pr_cdcooper crapris.cdcooper%TYPE,    --> codigo que identifica a cooperativa.
                                  pr_vlprjm60 crapris.vlprjm60%TYPE,    --> valor do prejuizo a mais de 60 meses.
                                  pr_dtdrisco crapris.dtdrisco%TYPE,    --> data de entrada na central de risco.
                                  pr_qtdriclq crapris.qtdriclq%TYPE,    --> qtd.dias saldo negativo risco
                                  pr_nrdgrupo crapris.nrdgrupo%TYPE,    --> numero/codigo do grupo economico.
                                  pr_vljura60 crapris.vljura60%TYPE,    --> juros de parcelas em atraso a mais de 60 dias.
                                  pr_inindris crapris.inindris%TYPE,    --> nivel de risco do cooperado (1 a 9).
                                  pr_cdinfadi crapris.cdinfadi%TYPE,    --> contem o codigo da informacao adicional do bacen.
                                  pr_nrctrnov crapris.nrctrnov%TYPE,    --> contem o numero do novo contrato.
                                  pr_flgindiv crapris.flgindiv%TYPE,    --> operacao enviada individualizada para bc.                  
                                  pr_dsinfaux crapris.dsinfaux%TYPE,    --> campo para armazenamento de alguma informa��o complementar gen�rica
                                  pr_dtprxpar crapris.dtprxpar%TYPE,    --> data da proxima parcela para o fluxo financeiro
                                  pr_vlprxpar crapris.vlprxpar%TYPE,    --> valor da proxima parcela para o fluxo financeiro
                                  pr_qtparcel crapris.qtparcel%TYPE,    --> quantidade de parcelas para o fluxo financeiro
                                  pr_dtvencop crapris.dtvencop%TYPE,    --> data de vencimento da operacao
                                  pr_des_erro      OUT VARCHAR2,
                                  pr_index_crapris OUT PLS_INTEGER
                                  ) IS         
      BEGIN
         
        vr_index_crapris:= vr_tab_crapris.count+1;
        
        vr_tab_crapris(vr_index_crapris).nrdconta   := pr_nrdconta;
        vr_tab_crapris(vr_index_crapris).dtrefere   := pr_dtrefere;
        vr_tab_crapris(vr_index_crapris).innivris   := pr_innivris;
        vr_tab_crapris(vr_index_crapris).qtdiaatr   := pr_qtdiaatr;
        vr_tab_crapris(vr_index_crapris).vldivida   := pr_vldivida;
        vr_tab_crapris(vr_index_crapris).vlvec180   := pr_vlvec180;
        vr_tab_crapris(vr_index_crapris).vlvec360   := pr_vlvec360;
        vr_tab_crapris(vr_index_crapris).vlvec999   := pr_vlvec999;
        vr_tab_crapris(vr_index_crapris).vldiv060   := pr_vldiv060;
        vr_tab_crapris(vr_index_crapris).vldiv180   := pr_vldiv180;
        vr_tab_crapris(vr_index_crapris).vldiv360   := pr_vldiv360;
        vr_tab_crapris(vr_index_crapris).vldiv999   := pr_vldiv999;
        vr_tab_crapris(vr_index_crapris).vlprjano   := pr_vlprjano;
        vr_tab_crapris(vr_index_crapris).vlprjaan   := pr_vlprjaan;
        vr_tab_crapris(vr_index_crapris).inpessoa   := pr_inpessoa;
        vr_tab_crapris(vr_index_crapris).nrcpfcgc   := pr_nrcpfcgc;
        vr_tab_crapris(vr_index_crapris).vlprjant   := pr_vlprjant;
        vr_tab_crapris(vr_index_crapris).inddocto   := pr_inddocto;
        vr_tab_crapris(vr_index_crapris).cdmodali   := pr_cdmodali;
        vr_tab_crapris(vr_index_crapris).nrctremp   := pr_nrctremp;
        vr_tab_crapris(vr_index_crapris).nrseqctr   := pr_nrseqctr;
        vr_tab_crapris(vr_index_crapris).dtinictr   := pr_dtinictr;
        vr_tab_crapris(vr_index_crapris).cdorigem   := pr_cdorigem;
        vr_tab_crapris(vr_index_crapris).cdagenci   := pr_cdagenci;
        vr_tab_crapris(vr_index_crapris).innivori   := pr_innivori;
        vr_tab_crapris(vr_index_crapris).cdcooper   := pr_cdcooper;
        vr_tab_crapris(vr_index_crapris).vlprjm60   := pr_vlprjm60;
        vr_tab_crapris(vr_index_crapris).dtdrisco   := pr_dtdrisco;
        vr_tab_crapris(vr_index_crapris).qtdriclq   := pr_qtdriclq;
        vr_tab_crapris(vr_index_crapris).nrdgrupo   := pr_nrdgrupo;
        vr_tab_crapris(vr_index_crapris).vljura60   := pr_vljura60;
        vr_tab_crapris(vr_index_crapris).inindris   := pr_inindris;
        vr_tab_crapris(vr_index_crapris).cdinfadi   := pr_cdinfadi;
        vr_tab_crapris(vr_index_crapris).nrctrnov   := pr_nrctrnov;
        vr_tab_crapris(vr_index_crapris).flgindiv   := pr_flgindiv;
        vr_tab_crapris(vr_index_crapris).dsinfaux   := pr_dsinfaux;
        vr_tab_crapris(vr_index_crapris).dtprxpar   := pr_dtprxpar;
        vr_tab_crapris(vr_index_crapris).vlprxpar   := pr_vlprxpar;
        vr_tab_crapris(vr_index_crapris).qtparcel   := pr_qtparcel;
        vr_tab_crapris(vr_index_crapris).dtvencop   := pr_dtvencop;
        
        pr_index_crapris := vr_index_crapris;
        
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'pc_grava_crapris --> Erro ao incluir na tabela memoria vr_tab_crapris.'||sqlerrm;       
      END pc_grava_crapris;
      
      -- Subrotina para cria��o da crapvri
      PROCEDURE pc_grava_crapvri(pr_nrdconta IN crapass.nrdconta%TYPE --> Num. da conta
                                ,pr_dtrefere IN crapvri.dtrefere%TYPE --> Data de refer�ncia
                                ,pr_innivris IN crapvri.innivris%TYPE --> N�vel do risco
                                ,pr_cdmodali IN crapvri.cdmodali%TYPE --> Modalidade do risco
                                ,pr_cdvencto IN crapvri.cdvencto%TYPE --> Codigo do vencimento
                                ,pr_nrctremp IN crapvri.nrctremp%TYPE --> Nro contrato empr�stimo
                                ,pr_nrseqctr IN crapvri.nrseqctr%TYPE --> Seq contrato empr�stimo
                                ,pr_vlsrisco IN crapvri.vldivida%TYPE --> Valor do risco a lan�ar
                                ,pr_des_erro OUT VARCHAR2) IS
      BEGIN
        
        vr_index_crapvri_temp := lpad(pr_cdcooper,5, '0') || 
                                  to_char( pr_dtrefere,'RRRRMMDD')|| 
                                  lpad(pr_nrdconta,10, '0') || 
                                  lpad(pr_innivris,5,'0')|| 
                                  lpad(pr_cdmodali,5,'0')||
                                  lpad( pr_nrctremp,10,'0')|| 
                                  lpad(pr_nrseqctr,5,'0')||
                                  lpad(pr_cdvencto,5,'0');
      
        IF vr_tab_crapvri_temp.exists(vr_index_crapvri_temp) THEN
          vr_tab_crapvri_temp(vr_index_crapvri_temp).vldivida:= vr_tab_crapvri_temp(vr_index_crapvri_temp).vldivida + 
                                                      pr_vlsrisco;
        ELSE        
          --vr_index_crapvri:= vr_tab_crapvri.count+1;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).cdcooper:= pr_cdcooper;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).nrdconta:= pr_nrdconta;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).dtrefere:= pr_dtrefere;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).innivris:= pr_innivris;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).cdmodali:= pr_cdmodali;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).cdvencto:= pr_cdvencto;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).nrctremp:= pr_nrctremp;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).nrseqctr:= pr_nrseqctr;
          vr_tab_crapvri_temp(vr_index_crapvri_temp).vldivida:= pr_vlsrisco;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'pc_grava_crapvri --> Erro ao incluir na tabela memoria vr_tab_crapvri.'||sqlerrm;
      END;
      
      -- SubRotina para posicionar o valor da divida no campo 
      -- correspondente conforme o c�digo do vencimento enviado
      -- Subrotina para cria��o da crapris espec�fica para o dcto 3010
      PROCEDURE pc_posici_divida_vcto(pr_cdvencto  IN crapvri.cdvencto%TYPE  --> Codigo do vencimento
                                     ,pr_vldivida  IN crapvri.vldivida%TYPE  --> Valor do risco a lan�ar
                                     ,pr_rsvec180 OUT crapris.vlvec180%TYPE
                                     ,pr_rsvec360 OUT crapris.vlvec360%TYPE
                                     ,pr_rsvec999 OUT crapris.vlvec999%TYPE
                                     ,pr_rsdiv060 OUT crapris.vldiv060%TYPE
                                     ,pr_rsdiv180 OUT crapris.vldiv180%TYPE
                                     ,pr_rsdiv360 OUT crapris.vldiv360%TYPE
                                     ,pr_rsdiv999 OUT crapris.vldiv999%TYPE
                                     ,pr_rsprjano OUT crapris.vlprjano%TYPE
                                     ,pr_rsprjaan OUT crapris.vlprjaan%TYPE
                                     ,pr_rsprjant OUT crapris.vlprjant%TYPE) IS
      BEGIN
        -- Inicializar variaveis espec�fica para grava��o da d�vida
        pr_rsvec180 := 0;
        pr_rsvec360 := 0;
        pr_rsvec999 := 0;
        pr_rsdiv060 := 0;
        pr_rsdiv180 := 0;
        pr_rsdiv360 := 0;
        pr_rsdiv999 := 0;
        pr_rsprjano := 0;
        pr_rsprjaan := 0;
        pr_rsprjant := 0;  
        -- Gravar o valor da d�vida nos campos espec�ficos
        -- de acordo com o c�digo do vencimento encontrado
        IF pr_cdvencto >= 110 AND pr_cdvencto <= 140 THEN
          pr_rsvec180 := pr_vldivida;
        ELSIF pr_cdvencto = 150 THEN
          pr_rsvec360 := pr_vldivida;
        ELSIF pr_cdvencto > 150 AND pr_cdvencto <= 199 THEN
          pr_rsvec999 := pr_vldivida;
        ELSIF pr_cdvencto >= 205 AND pr_cdvencto <= 220 THEN
          pr_rsdiv060 := pr_vldivida;
        ELSIF pr_cdvencto >= 230 AND pr_cdvencto  <= 250 THEN
          pr_rsdiv180 := pr_vldivida;
        ELSIF pr_cdvencto >= 255 AND pr_cdvencto  <= 270 THEN
          pr_rsdiv360 := pr_vldivida;
        ELSIF pr_cdvencto >= 280 AND pr_cdvencto  <= 290 THEN
          pr_rsdiv999 := pr_vldivida;
        ELSIF pr_cdvencto = 310 THEN
          pr_rsprjano := pr_vldivida;
        ELSIF pr_cdvencto = 320 THEN
          pr_rsprjaan := pr_vldivida;
        ELSE
          pr_rsprjant := pr_vldivida;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Ignorar qualquer problema 
          Null;
      END;

      -- Subrotina que recebe um valor a lan�ar, o valor m�ximo da parcela
      -- e retorna o valor da parcela e o saldo a lan�ar na pr�xima parcela
      PROCEDURE pc_calc_vlparcel(pr_vllancto IN NUMBER      --> Valor do lan�amento desejado
                                ,pr_vlpreemp IN NUMBER      --> Valor m�ximo da parcela
                                ,pr_vlparcel OUT NUMBER     --> Valor da parcela atual
                                ,pr_vllsaldo OUT NUMBER) IS --> Retorna o saldo para a pr�xima
      BEGIN
        -- Se o valor a lan�ar for inferior ao valor da parcela
        IF pr_vllancto <= pr_vlpreemp THEN
          -- Lan�ar o valor da divida total
          pr_vlparcel := pr_vllancto;
          -- Zerar o saldo para pr�xima parcela
          pr_vllsaldo := 0;
        ELSE
          -- Lan�ar o valor da parcela
          pr_vlparcel := pr_vlpreemp;
          -- Diminuir do saldo o valor lan�ado
          pr_vllsaldo := pr_vllancto - pr_vlpreemp;
        END IF;
      END;

      -- Rotina para gerar vetor de parcelas a vencer
      PROCEDURE pc_gera_avencer(pr_vlpreemp     IN crapepr.vlpreemp%TYPE
                               ,pr_vlvenc180    IN OUT NUMBER
                               ,pr_vlvenc360    IN OUT NUMBER
                               ,pr_vlvenc999    IN OUT NUMBER
                               ,pr_vet_vlavence OUT typ_tab_vlparcel) IS
      BEGIN
        -- Inicializar a temp-table
        FOR vr_ind IN 1..23 LOOP
          pr_vet_vlavence(vr_ind) := 0;
        END LOOP;
        -- Prever null
        pr_vlvenc180 := NVL(pr_vlvenc180,0);
        pr_vlvenc360 := NVL(pr_vlvenc360,0);
        pr_vlvenc999 := NVL(pr_vlvenc999,0);
        -- Se houver valor a vencer nos primeiros 180 dias
        IF pr_vlvenc180 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 30 dias
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc180       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlavence(1) --> Valor da parcela atual na posi��o 30 dias
                          ,pr_vllsaldo => pr_vlvenc180);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor a vencer nos primeiros 180 dias
        IF pr_vlvenc180 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 60 dias
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc180       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlavence(2) --> Valor da parcela atual na posi��o 60 dias
                          ,pr_vllsaldo => pr_vlvenc180);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor a vencer nos primeiros 180 dias
        IF pr_vlvenc180 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 90 dias
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc180       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlavence(3) --> Valor da parcela atual na posi��o 90 dias
                          ,pr_vllsaldo => pr_vlvenc180);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor a vencer
        IF pr_vlvenc180 > 0 THEN
          -- Lan�ar na posi��o 4 - 180 dias
          pr_vet_vlavence(4) := pr_vlvenc180;
        END IF;
        -- Se foi enviado valor a vencer nos 360 dias
        IF pr_vlvenc360 > 0 THEN
          -- Lan�ar na posi��o 5 - 360 dias
          pr_vet_vlavence(5) := pr_vlvenc360;
        END IF;
        -- Se houver valor a vencer na variavel 999
        IF pr_vlvenc999 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 720 dias
          -- Obs: Considerar o valor da parcela * 12
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc999       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*12     --> Valor m�ximo da parcela * 12
                          ,pr_vlparcel => pr_vet_vlavence(6) --> Valor da parcela atual na posi��o 720 dias
                          ,pr_vllsaldo => pr_vlvenc999);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor a vencer na variavel 999
        IF pr_vlvenc999 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 1080 dias
          -- Obs: Considerar o valor da parcela * 12
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc999       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*12     --> Valor m�ximo da parcela * 12
                          ,pr_vlparcel => pr_vet_vlavence(7) --> Valor da parcela atual na posi��o 1080 dias
                          ,pr_vllsaldo => pr_vlvenc999);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor a vencer na variavel 999
        IF pr_vlvenc999 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 1440 dias
          -- Obs: Considerar o valor da parcela * 12
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc999       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*12     --> Valor m�ximo da parcela * 12
                          ,pr_vlparcel => pr_vet_vlavence(8) --> Valor da parcela atual na posi��o 1440 dias
                          ,pr_vllsaldo => pr_vlvenc999);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor a vencer na variavel 999
        IF pr_vlvenc999 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 1800 dias
          -- Obs: Considerar o valor da parcela * 12
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc999       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*12     --> Valor m�ximo da parcela * 12
                          ,pr_vlparcel => pr_vet_vlavence(9) --> Valor da parcela atual na posi��o 1800 dias
                          ,pr_vllsaldo => pr_vlvenc999);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Por fim testamos com o valor da parcela * 120 para lan�ar na parcela 10
        IF pr_vlvenc999 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 5400 dias
          -- Obs: Considerar o valor da parcela * 120
          pc_calc_vlparcel(pr_vllancto => pr_vlvenc999       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*120    --> Valor m�ximo da parcela * 120
                          ,pr_vlparcel => pr_vet_vlavence(10) --> Valor da parcela atual na posi��o 5400 dias
                          ,pr_vllsaldo => pr_vlvenc999);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se mesmo assim ainda houver valor na vari�vel
        IF pr_vlvenc999 > 0 THEN
          -- Lancar na posi��o 11 - 9999 dias
          pr_vet_vlavence(11) := pr_vlvenc999;
        END IF;
      END;

      -- Rotina para gerar vetor de parcelas vencidas
      PROCEDURE pc_gera_vencidos(pr_vlpreemp     IN crapepr.vlpreemp%TYPE
                                ,pr_qtdiaatr     IN crapris.qtdiaatr%TYPE
                                ,pr_vldivi060    IN OUT NUMBER
                                ,pr_vldivi180    IN OUT NUMBER
                                ,pr_vldivi360    IN OUT NUMBER
                                ,pr_vldivi999    IN OUT NUMBER
                                ,pr_vet_vlvencid OUT typ_tab_vlparcel) IS
      BEGIN
        -- Inicializar a temp-table
        FOR vr_ind IN 1..23 LOOP
          pr_vet_vlvencid(vr_ind) := 0;
        END LOOP;
        -- Prever problemas de null
        pr_vldivi060 := NVL(pr_vldivi060,0);
        pr_vldivi180 := NVL(pr_vldivi180,0);
        pr_vldivi360 := NVL(pr_vldivi360,0);
        pr_vldivi999 := NVL(pr_vldivi999,0);
        -- Se n�o houver divida vencida nos primeiros 180 dias
        IF pr_vldivi180 = 0 THEN
          -- Trabalhar com a divida dos 60 dias, lan�ando nas posi��es
          -- 1(15d), 2(30d) e 3(60d) em ordem crescente
          -- Se houver nos 60 dias e o atraso inferior a 15 dias
          IF pr_vldivi060 > 0 AND pr_qtdiaatr < 15 THEN
            -- Chamar rotina que calcula a parcela e devolve o saldo
            -- enviando o valor da parcela para a posi��o 15 dias
            pc_calc_vlparcel(pr_vllancto => pr_vldivi060       --> Valor do lan�amento desejado
                            ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                            ,pr_vlparcel => pr_vet_vlvencid(1) --> Valor da parcela atual na posi��o 15 dias
                            ,pr_vllsaldo => pr_vldivi060);     --> Saldo a lan�ar retorna na mesma vari�vel
          END IF;
          -- Se houver valor nos 60 dias e o atraso for inferior a 31 dias
          IF pr_vldivi060 > 0 AND pr_qtdiaatr < 31 THEN
            -- Chamar rotina que calcula a parcela e devolve o saldo
            -- enviando o valor da parcela para a posi��o 30 dias
            pc_calc_vlparcel(pr_vllancto => pr_vldivi060       --> Valor do lan�amento desejado
                            ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                            ,pr_vlparcel => pr_vet_vlvencid(2) --> Valor da parcela atual na posi��o 30 dias
                            ,pr_vllsaldo => pr_vldivi060);     --> Saldo a lan�ar retorna na mesma vari�vel
          END IF;
          -- Se ainda houver valor na variavel de divida 60 dias
          IF pr_vldivi060 > 0 THEN
            -- Lan�a-lo na posi��o 60 d do vetor
            pr_vet_vlvencid(3) := pr_vldivi060;
          END IF;
        ELSE
          -- Lan�ar sistematicamente os valores nas posi��es 3(60d),
          -- 2(30d) e 1(15d) em ordem decrescente mesmo
          IF pr_vldivi060 > 0 THEN
            -- Chamar rotina que calcula a parcela e devolve o saldo
            -- enviando o valor da parcela para a posi��o 60 dias
            pc_calc_vlparcel(pr_vllancto => pr_vldivi060       --> Valor do lan�amento desejado
                            ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                            ,pr_vlparcel => pr_vet_vlvencid(3) --> Valor da parcela atual na posi��o 60 dias
                            ,pr_vllsaldo => pr_vldivi060);     --> Saldo a lan�ar retorna na mesma vari�vel
          END IF;
          -- Se ainda houver valor de d�vida nos 60 dias
          IF pr_vldivi060 > 0 THEN
            -- Chamar rotina que calcula a parcela e devolve o saldo
            -- enviando o valor da parcela para a posi��o 30 dias
            pc_calc_vlparcel(pr_vllancto => pr_vldivi060       --> Valor do lan�amento desejado
                            ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                            ,pr_vlparcel => pr_vet_vlvencid(2) --> Valor da parcela atual na posi��o 30 dias
                            ,pr_vllsaldo => pr_vldivi060);     --> Saldo a lan�ar retorna na mesma vari�vel
          END IF;
          -- Se ainda houver valor na variavel de divida 60 dias
          IF pr_vldivi060 > 0 THEN
            -- Lan�a-lo na posi��o 15 d do vetor
            pr_vet_vlvencid(1) := pr_vldivi060;
          END IF;
        END IF;
        -- Trabalhar com a divida dos 180 dias, lan�ando nas posi��es 4(90d), 5(120d), 6(150d) e 7(180d)
        -- Se ainda houver valor de d�vida nos 180 dias
        IF pr_vldivi180 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 90 dias
          pc_calc_vlparcel(pr_vllancto => pr_vldivi180       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlvencid(4) --> Valor da parcela atual na posi��o 90 dias
                          ,pr_vllsaldo => pr_vldivi180);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor de d�vida nos 180 dias
        IF pr_vldivi180 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 120 dias
          pc_calc_vlparcel(pr_vllancto => pr_vldivi180       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlvencid(5) --> Valor da parcela atual na posi��o 120 dias
                          ,pr_vllsaldo => pr_vldivi180);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor de d�vida nos 180 dias
        IF pr_vldivi180 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 150 dias
          pc_calc_vlparcel(pr_vllancto => pr_vldivi180       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp        --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlvencid(6) --> Valor da parcela atual na posi��o 150 dias
                          ,pr_vllsaldo => pr_vldivi180);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor na variavel de divida 180 dias
        IF pr_vldivi180 > 0 THEN
          -- Lan�a-lo na posi��o 180 d do vetor
          pr_vet_vlvencid(7) := pr_vldivi180;
        END IF;
        -- Trabalhar com a divida dos 360 dias, lan�ando nas posi��es 8(240d),
        -- 9(300d) e 10(360d) e trabalhando com o valor da parcela * 2
        -- Se houver valor de d�vida nos 360 dias
        IF pr_vldivi360 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 240 dias
          -- Obs: considerar o valor da parcela * 2
          pc_calc_vlparcel(pr_vllancto => pr_vldivi360       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*2      --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlvencid(8) --> Valor da parcela atual na posi��o 240 dias
                          ,pr_vllsaldo => pr_vldivi360);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor de d�vida nos 180 dias
        IF pr_vldivi360 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 300 dias
          -- Obs: considerar o valor da parcela * 2
          pc_calc_vlparcel(pr_vllancto => pr_vldivi360       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*2      --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlvencid(9) --> Valor da parcela atual na posi��o 300 dias
                          ,pr_vllsaldo => pr_vldivi360);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor na variavel de divida 180 dias
        IF pr_vldivi360 > 0 THEN
          -- Lan�a-lo na posi��o 360 d do vetor
          pr_vet_vlvencid(10) := pr_vldivi360;
        END IF;
        -- Por fim, trabalhar com a coluna 999, lan�ando nas posi��es 11(540d)
        -- e 12(999d), utilizando o valor da parcela * 6 em cada lan�amento
        IF pr_vldivi999 > 0 THEN
          -- Chamar rotina que calcula a parcela e devolve o saldo
          -- enviando o valor da parcela para a posi��o 540 dias
          -- Obs: considerar o valor da parcela * 6
          pc_calc_vlparcel(pr_vllancto => pr_vldivi999       --> Valor do lan�amento desejado
                          ,pr_vlpreemp => pr_vlpreemp*6      --> Valor m�ximo da parcela
                          ,pr_vlparcel => pr_vet_vlvencid(11)--> Valor da parcela atual na posi��o 540 dias
                          ,pr_vllsaldo => pr_vldivi999);     --> Saldo a lan�ar retorna na mesma vari�vel
        END IF;
        -- Se ainda houver valor
        IF pr_vldivi999 > 0 THEN
          -- Lan�a-lo na posi��o 12 (999d)
          pr_vet_vlvencid(12) := pr_vldivi999;
        END IF;
      END;

      -- Varrer e processar empr�stimos price
      PROCEDURE pc_lista_emp_price(pr_rw_crapass   IN cr_crapass%ROWTYPE
                                  ,pr_rw_crapepr   IN cr_crapepr%ROWTYPE
                                  ,pr_des_erro    OUT VARCHAR2) IS
        -- ------------------------------------------- --
        --  vr_dias = se negativo - pagou antecipado  --
        --            se positivo - esta em atraso    --
        -- ------------------------------------------- --

        -- Variaveis auxiliares
        vr_dias             PLS_INTEGER; --> N�mero de dias em rela��o as parcelas pagas * meses decorridos
        vr_qtmesdec         PLS_INTEGER; --> Meses corridos do empr�stimo
        vr_qtprecal_retor   PLS_INTEGER; --> Quantidade % de parcelas calculadas
        vr_vlsdeved_atual   NUMBER;      --> Saldo devedor atual
        vr_aux_nivel        NUMBER;      --> N�vel do risco
        vr_aux_nivel_atraso NUMBER;      --> N�vel do risco de atraso
        vr_dsnivris         VARCHAR2(2); --> Nivel do risco atual
        vr_vlrpagos         crapepr.vlprejuz%TYPE; --> Valor pago no empr�stimo
        vr_qtdiaatr         PLS_INTEGER; --> Var auxiliar para manter o atraso
        vr_vlpresta         NUMBER;      --> Valor da presta��o do empr�stimo
        vr_vlatraso         NUMBER;      --> Valor do atraso
        vr_vlvencer         NUMBER;      --> Valor total a vencer
        vr_vlvencer180      NUMBER;      --> Calcular 6 parcelas a vencer nos pr�ximos 180 dias
        vr_vlvencer360      NUMBER;      --> Calcular 6 parcelas a vencer nos pr�ximos 360 dias
        vr_indocc           PLS_INTEGER;           --> Diferen�a de meses em preju�zo
        vr_valor_auxiliar   NUMBER;                --> Valor auxiliar para gravar o buffer 3020
        vr_cdmodali         crapris.cdmodali%TYPE; --> C�digo da modalidade montado cfme a linha de cr�dito
        vr_nrctremp         crapris.nrctremp%TYPE; --> N�mero do contrato
        
        vr_dtprxpar         crapris.dtprxpar%TYPE; --> Data Pr�ximo pagamento Epr
        vr_vlprxpar         crapris.vlprxpar%TYPE; --> Valor Pr�ximo pagamenro Epr
                 
      BEGIN
        -- Incializar vari�veis
        vr_qtmesdec := pr_rw_crapepr.qtmesdec;
        vr_qtdiapre := pr_rw_crapepr.qtpreemp * 30;
        vr_nrctremp := 0;
        vr_cdmodali := 0;
        vr_vldiv060 := 0;
        vr_vldiv180 := 0;
        vr_vldiv360 := 0;
        vr_vldiv999 := 0;
        vr_vlvec180 := 0;
        vr_vlvec360 := 0;
        vr_vlvec999 := 0;
        vr_vlprjano := 0;
        vr_vlprjaan := 0;
        vr_vlprjant := 0;
        -- Se o pr�ximo pagamento estiver setado
        IF pr_rw_crapepr.dtdpagto IS NOT NULL THEN
          -- Se o pagamento for no mes corrente e posterior ao dia atual
          -- OU
          -- Se o pagamento for posterior a data atual e estivermos no processamento semanal
          IF (trunc(pr_rw_crapepr.dtdpagto,'mm') = trunc(pr_rw_crapdat.dtmvtolt,'mm') AND to_char(pr_rw_crapepr.dtdpagto,'dd') > to_char(pr_rw_crapdat.dtmvtolt,'dd'))
          OR (trunc(pr_rw_crapdat.dtmvtolt,'mm') = trunc(pr_rw_crapdat.dtmvtopr,'mm') AND pr_rw_crapepr.dtdpagto > pr_rw_crapdat.dtmvtolt) THEN
            -- Decrementar a quantidade de meses decorridos
            vr_qtmesdec := vr_qtmesdec - 1;
          END IF;
        END IF;
        -- Se o m�s corrente � o mesmo do pr�ximo dia util
        IF trunc(pr_rw_crapdat.dtmvtolt,'mm') = trunc(pr_rw_crapdat.dtmvtopr,'mm') THEN
          /* Saldo calculado pelo crps616.p e crps665.p */
          vr_qtprecal_retor := nvl(pr_rw_crapepr.qtlcalat,0) + nvl(pr_rw_crapepr.qtprecal,0);
          vr_vlsdeved_atual := nvl(pr_rw_crapepr.vlsdevat,0);
        ELSE
          -- Utilizar informa��es da tabela mesmo
          vr_qtprecal_retor := pr_rw_crapepr.qtprecal;
          vr_vlsdeved_atual := pr_rw_crapepr.vlsdeved;
        END IF;
        
        --> Caso NAO esteja em prejuizo
        IF pr_rw_crapepr.inprejuz = 0 THEN
        
        -- Calcular n�mero de dias com base nos (meses decorridos - qtde parcelas calculas) * 30
        vr_dias := ((vr_qtmesdec - vr_qtprecal_retor) * 30);
        -- Efetuar o mesmo calculo para a variavel que ser� utilizada no insert posterior
        vr_qtdiaatr := ((vr_qtmesdec - vr_qtprecal_retor) * 30);
          
        --> Caso esteja em prejuizo
        ELSIF pr_rw_crapepr.inprejuz = 1 THEN
        
          vr_qtdiaatr := 0;
          --> Buscar ultimo nivel de risco
          rw_crapris_9 := NULL;
          
          --> Caso linha 100
          IF pr_rw_crapepr.cdlcremp = 100 THEN
            --> usar data de referencia a data que gerou o emprestimo de prejuizo
            OPEN cr_crapris_9_100 (pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_rw_crapepr.nrdconta,
                                   pr_nrctremp => pr_rw_crapepr.nrctremp);
            FETCH cr_crapris_9_100 INTO rw_crapris_9;
            CLOSE cr_crapris_9_100;
            
          ELSE
            
            OPEN cr_crapris_9 (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => pr_rw_crapepr.nrdconta,
                               pr_nrctremp => pr_rw_crapepr.nrctremp);
            FETCH cr_crapris_9 INTO rw_crapris_9;
            CLOSE cr_crapris_9;
          END IF;
          
          vr_qtdiaatr := (pr_rw_crapdat.dtmvtolt - rw_crapris_9.dtrefere);
          IF vr_qtdiaatr < 0 THEN
            vr_qtdiaatr := 0;
          END IF;
          
          --> incrementar qtd de dias em atraso antes de se tornar em prejuizo
          vr_qtdiaatr := nvl(vr_qtdiaatr,0) + nvl(rw_crapris_9.qtdiaatr,0);
          
          --> Caso ainda n�o tenha calculado a qtd de dias em atraso do prejuizo
          IF vr_qtdiaatr <= 0 THEN
            --> deve calcular conforma a data do ultimo pagamento
            vr_qtdiaatr := (pr_rw_crapdat.dtmvtolt - pr_rw_crapepr.dtultpag); 
          END IF;
          
          vr_dias     := vr_qtdiaatr;
        
        END IF;
        
        -- Por�m garantir que a mesma n�o fique negativa
        IF vr_qtdiaatr < 0 THEN
          vr_qtdiaatr := 0;
        END IF;
        -- Verificar o n�vel de risco conforme a quantidade de dias em atraso
        CASE
          WHEN vr_dias <= 0 THEN
            vr_aux_nivel := 2;
          WHEN vr_dias < 15 THEN
            vr_aux_nivel := 2;
          WHEN vr_dias <= 30 THEN
            vr_aux_nivel := 3;
          WHEN vr_dias <= 60 THEN
            vr_aux_nivel := 4;
          WHEN vr_dias <= 90 THEN
            vr_aux_nivel := 5;
          WHEN vr_dias <= 120 THEN
            vr_aux_nivel := 6;
          WHEN vr_dias <= 150 THEN
            vr_aux_nivel := 7;
          WHEN vr_dias <= 180 THEN
            vr_aux_nivel := 8;
          ELSE
            vr_aux_nivel := 9;
        END CASE;
        -- Armazenar o n�vel encontrado como o de atraso
        vr_aux_nivel_atraso := vr_aux_nivel;
        -- Buscar n�vel de risco do Empr�stimo
        vr_dsnivris := null;         
        -- Copi�-lo a variavel
        vr_dsnivris := pr_rw_crapepr.dsnivris;
        -- Buscar o seu valor conforme o char de risco encontrado
        IF vr_tab_risco.exists(vr_dsnivris) THEN
          vr_aux_nivel := vr_tab_risco(vr_dsnivris);
        ELSE
          vr_aux_nivel := 0;
        END IF;
        -- Se houve rating efetuado ap�s o empr�stimo
        IF vr_risco_rating <> 0 THEN
          -- Se houver informa��o na tabela de mem�ria da CRAPNRC
          IF vr_tab_crapnrc.EXISTS(pr_rw_crapepr.nrdconta) THEN
            -- Se a data do rating for superior ou igual a do vencimento da parcela
            IF vr_tab_crapnrc(pr_rw_crapepr.nrdconta).dtmvtolt >= pr_rw_crapepr.dtmvtolt THEN
                
              -- Verificar o pior risco, entre o Rating e o Risco da Operacao
              IF vr_risco_rating > vr_aux_nivel THEN
                vr_aux_nivel := vr_risco_rating;
                  
              END IF;
            END IF;
          END IF;
        END IF;     
        -- Se emprestimo tiver nivel maior que o atraso
        IF vr_aux_nivel_atraso > vr_aux_nivel THEN
          -- Assumir o n�vel do atraso
          vr_aux_nivel := vr_aux_nivel_atraso;
        END IF;
        -- Buscar valor pago do empr�stimo
        vr_vlrpagos := 0;
        -- Se o empr�stimo for de preju�zo
        IF pr_rw_crapepr.inprejuz = 1 THEN
          -- Assumir n�vel 9
          vr_aux_nivel := 9;
          -- Busca os pagamentos de preju�zo
          vr_index_prejuz:= lpad(pr_rw_crapepr.nrdconta,10,'0')||
                            lpad(pr_rw_crapepr.nrctremp,10,'0');
          IF vr_tab_prejuz.EXISTS(vr_index_prejuz) THEN
            vr_vlrpagos:= vr_tab_prejuz(vr_index_prejuz);
          END IF;  
          -- Se o valor pago for superior ou igual ao prejuizo OU o saldo de prejuizo estiver zerado
          IF vr_vlrpagos >= pr_rw_crapepr.vlprejuz OR pr_rw_crapepr.vlsdprej = 0 THEN
            RETURN;
          END IF;
        END IF;
        -- Se houver n�vel de rating e o mesmo for superior ao atual
        IF vr_risco_rating <> 0 AND vr_risco_rating > vr_aux_nivel THEN
          -- Assumir o n�vel do rating
          vr_aux_nivel := vr_risco_rating;
        END IF;
        -- Se houver rating para o empr�stimo e o mesmo estiver em dia
        IF vr_risco_rating <> 0 AND vr_dias <= 0 THEN
          -- Se houver informa��o na tabela de mem�ria da CRAPNRC
          IF vr_tab_crapnrc.EXISTS(pr_rw_crapepr.nrdconta) THEN
            -- Se a data do rating for superior ou igual a do vencimento da parcela
            IF vr_tab_crapnrc(pr_rw_crapepr.nrdconta).dtmvtolt >= pr_rw_crapepr.dtmvtolt THEN
              
              -- Verificar o pior risco, entre o Rating e o Risco da Operacao
              IF vr_risco_rating > vr_aux_nivel THEN
                -- Assumir o n�vel do rating
                vr_aux_nivel := vr_risco_rating;
                
              END IF;                
              
            END IF;
          END IF;
        END IF;
        -- Buscar valor original da presta��o do empr�stimo
        vr_vlpresta := pr_rw_crapepr.vlpreemp;
        -- Calcular o valor do atraso com base nos meses calculados
        vr_vlatraso := TRUNC(pr_rw_crapepr.vlpreemp * (vr_qtmesdec - vr_qtprecal_retor),2);
        -- Garantir que o valor de atraso n�o seja superior ao do saldo devedor
        IF vr_vlatraso > vr_vlsdeved_atual THEN
          vr_vlatraso := vr_vlsdeved_atual;
        END IF;
        -- Somente se o n�mero de dias for superior a zero, ou seja, est� atrasado
        IF vr_dias > 0 THEN
          /* Se o numero de prestacoes faltantes for <= 1 e esta em atraso a mais de 60 dias
                Obs.: Esta sendo feito desta forma, pois na atual forma de
                      calculo ha problema para emprestimos em que o valor do
                      atraso eh menor que o dobro da parcela e esta vencido a
                      mais de 60 dias (demanda bacen, reversao da receita 60d)
                      Esta situacao sera corrigida quando o novo sistema
                      de emprestimo entrar em vigor. */
          IF pr_rw_crapepr.qtpreemp - pr_rw_crapepr.qtprepag <= 2
          AND pr_rw_crapepr.qtpreemp - pr_rw_crapepr.qtprepag > 0
          AND vr_qtdiaatr > 60 THEN
            -- Guardar na variavel correspondente a quantidade de dias em atraso
            IF vr_qtdiaatr < 180 THEN
              vr_vldiv180 := vr_vlatraso;
            ELSIF vr_qtdiaatr < 360 THEN
              vr_vldiv360 := vr_vlatraso;
            ELSE
              vr_vldiv999 := vr_vlatraso;
            END IF;
          ELSE
            -- Se o valor do atraso for menor ou igual a duas presta��es
            IF vr_vlatraso <= vr_vlpresta * 2 THEN
              -- Lan�ar o valor na divida de 60 dias
              vr_vldiv060 := vr_vlatraso;
              -- Zerar o valor do atraso
              vr_vlatraso := 0;
            ELSE
              -- Lan�ar duas parcelas na divida de 60 dias
              vr_vldiv060 := vr_vlpresta * 2;
              -- Diminuir do atraso total o lan�ado na divida
              vr_vlatraso := vr_vlatraso - (vr_vlpresta * 2);
            END IF;
            -- Se ainda persistir valor em atraso
            IF vr_vlatraso > 0 THEN
              -- Se o valor do atraso for menor ou igual a quatro presta��es
              IF vr_vlatraso <= vr_vlpresta * 4 THEN
                -- Lan�ar o valor na divida de 180 dias
                vr_vldiv180 := vr_vlatraso;
                -- Zerar o valor do atraso
                vr_vlatraso := 0;
              ELSE
                -- Lan�ar quatro parcelas na divida de 180 dias
                vr_vldiv180 := vr_vlpresta * 4;
                -- Diminuir do atraso total o lan�ado na divida
                vr_vlatraso := vr_vlatraso - (vr_vlpresta * 4);
              END IF;
            END IF;
            -- Se ainda persistir valor em atraso
            IF vr_vlatraso > 0 THEN
              -- Se o valor do atraso for menor ou igual a doze presta��es
              IF vr_vlatraso <= vr_vlpresta * 12 THEN
                -- Lan�ar o valor na divida de 360 dias
                vr_vldiv360 := vr_vlatraso;
                -- Zerar o valor do atraso
                vr_vlatraso := 0;
              ELSE
                -- Lan�ar doze parcelas na divida de 180 dias
                vr_vldiv360 := vr_vlpresta * 12;
                -- Diminuir do atraso total o lan�ado na divida
                vr_vlatraso := vr_vlatraso - (vr_vlpresta * 12);
              END IF;
            END IF;
            -- Se mesmo assim ainda tivermos valor em atraso
            IF vr_vlatraso > 0 THEN
              -- Lan�aremos o valor na d�vida 999
              vr_vldiv999 := vr_vlatraso;
            END IF;
          END IF;
        END IF;
        -- Sumarizar todo o valor lan�ado a vencer descontando o saldo devedor
        vr_vlvencer := nvl(vr_vlsdeved_atual,0)
                     - nvl(vr_vldiv060,0) - nvl(vr_vldiv180,0)
                     - nvl(vr_vldiv360,0) - nvl(vr_vldiv999,0);
        -- Somente se houver valor a vencer
        IF vr_vlvencer > 0 THEN
          -- Somente montar valores da pr�xima parcela se meses decorridos
          -- for inferior a quantidade de parcelas do empr�stimo
          IF vr_qtmesdec < pr_rw_crapepr.qtpreemp THEN
            -- Armazenar valor da pr�xima parcela 
            -- (testar se o saldo devedor n�o � inferior)
            vr_vlprxpar := LEAST(pr_rw_crapepr.vlpreemp,vr_vlsdeved_atual);
            -- Inicialmente usamos a data calculada
            vr_dtprxpar := pr_rw_crapepr.dtdpagto;
            -- Efetuaremos um la�o para adicionarmos
            -- sempre um m�s at� que esta data seja futura
            LOOP
              EXIT WHEN vr_dtprxpar > pr_rw_crapdat.dtmvtolt;
              -- Adicionar +1 m�s           
              vr_dtprxpar := gene0005.fn_dtfun(pr_dtcalcul => vr_dtprxpar
                                              ,pr_qtdmeses => +1);
            END LOOP;                                
          END IF;
          -- Somar 6 parcelas a lan�ar na coluna a vencer de 180 dias
          vr_vlvencer180 := pr_rw_crapepr.vlpreemp * 6;
          -- Se o valor for superior ao valor a vencer
          IF vr_vlvencer180 > vr_vlvencer THEN
            -- Lan�ar o valor total na coluna
            vr_vlvec180 := vr_vlvencer;
            -- Zerar o valor a vencer
            vr_vlvencer := 0;
          ELSE
            -- Lan�ar o valor das parcelas calculadas
            vr_vlvec180 := vr_vlvencer180;
            -- Diminuir do valor a vencer o valor lan�ado
            vr_vlvencer := vr_vlvencer - vr_vlvencer180;
          END IF;
        END IF;
        -- Somente se ainda houver valor a vencer
        IF vr_vlvencer > 0 THEN
          -- Somar mais 6 parcelas a lan�ar na coluna a vencer de 360 dias
          vr_vlvencer360 := pr_rw_crapepr.vlpreemp * 6;
          -- Se o valor for superior ao valor a vencer
          IF vr_vlvencer360 > vr_vlvencer THEN
            -- Lan�ar o valor total na coluna
            vr_vlvec360 := vr_vlvencer;
            -- Zerar o valor a vencer
            vr_vlvencer := 0;
          ELSE
            -- Lan�ar o valor das parcelas calculadas
            vr_vlvec360 := vr_vlvencer360;
            -- Diminuir do valor a vencer o valor lan�ado
            vr_vlvencer := vr_vlvencer - vr_vlvencer360;
          END IF;
        END IF;
        -- Se mesmo assim persistir valor a vencer
        IF vr_vlvencer > 0 THEN
          -- Lan�aremos na coluna 999
          vr_vlvec999 := vr_vlvencer;
        END IF;
        -- Se o empr�stimos tiver prejuizo calculado
        IF pr_rw_crapepr.vlprejuz > 0 THEN
          -- Se a data do preju�zo for de um m�s superior ao corrente
          IF trunc(pr_rw_crapepr.dtprejuz,'mm') > trunc(pr_rw_crapdat.dtmvtolt,'mm') THEN
            -- Utilizamos fixo 50, pois a l�gica Progress sempre chegava nesse valor para prejuizos futuros
            vr_indocc := 50;
          ELSE
            -- Retornar a quantidade de meses de diferen�a
            -- entre a data atual e a data do prejuizo, utilizamos
            -- trunc para considerar somente a diferen�a exata de meses
            -- do c�lculo Oracle e somamos mais 1 inteiro
            vr_indocc := trunc(months_between(trunc(pr_rw_crapdat.dtmvtolt,'mm'),trunc(pr_rw_crapepr.dtprejuz,'mm')))+1;
          END IF;
          -- Lan�ar o preju�zo na coluna espec�fica a diferen�a de meses
          -- j� diminuindo o preju�zo os valores pagos somados na vr_vlrpagos
          IF vr_indocc <= 12 THEN
            vr_vlprjano := pr_rw_crapepr.vlprejuz - vr_vlrpagos;
          ELSIF vr_indocc >= 13 AND vr_indocc <= 48 THEN
            vr_vlprjaan := pr_rw_crapepr.vlprejuz - vr_vlrpagos;
          ELSE
            vr_vlprjant := pr_rw_crapepr.vlprejuz - vr_vlrpagos;
          END IF;
        END IF;
        -- Se houve prejuizo em algum dos per�odos
        IF vr_vlprjano <> 0 OR vr_vlprjaan <> 0 OR vr_vlprjant <> 0 THEN
          -- O pr�ximo fica com n�vel HH
          vr_aux_nivel := 10;
        END IF;
        -- Somar valor auxiliar para gravar o risco buffer (VlDivida - VlrPrj60)
        vr_valor_auxiliar := vr_vlsdeved_atual + (pr_rw_crapepr.vlprejuz - vr_vlrpagos);
        -- N�o gravar se divida for somente prejuizo
        IF vr_valor_auxiliar > 0 THEN
          -- Se temos prejuizo - somente prejuizo
          IF vr_aux_nivel = 10 AND (   nvl(vr_vlvec180,0) > 0 OR nvl(vr_vlvec360,0) > 0 OR nvl(vr_vlvec999,0) > 0
                                    OR nvl(vr_vldiv060,0) > 0 OR nvl(vr_vldiv180,0) > 0 OR nvl(vr_vldiv360,0) > 0
                                    OR nvl(vr_vldiv999,0) > 0) THEN
            -- Se houve prejuizo no ano corrente
            IF vr_vlprjano > 0 THEN
              -- Somar os valores de divida e a vencer na divida do ano
              vr_vlprjano := vr_vlprjano + nvl(vr_vlvec180,0) + nvl(vr_vlvec360,0)
                                         + nvl(vr_vlvec999,0) + nvl(vr_vldiv060,0)
                                         + nvl(vr_vldiv180,0) + nvl(vr_vldiv360,0) + nvl(vr_vldiv999,0);
            -- Se houve prejuizo no ano anterior
            ELSIF vr_vlprjaan > 0 THEN
              -- Somar os valores de divida e a vencer na divida do ano anterior
              vr_vlprjaan := vr_vlprjaan + nvl(vr_vlvec180,0) + nvl(vr_vlvec360,0)
                                         + nvl(vr_vlvec999,0) + nvl(vr_vldiv060,0)
                                         + nvl(vr_vldiv180,0) + nvl(vr_vldiv360,0) + nvl(vr_vldiv999,0);
            -- Senao houve prejuizo nos anos anteriores
            ELSE
              -- Somar os valores de divida e a vencer na divida do anos anteriores
              vr_vlprjant := vr_vlprjant + nvl(vr_vlvec180,0) + nvl(vr_vlvec360,0)
                                         + nvl(vr_vlvec999,0) + nvl(vr_vldiv060,0)
                                         + nvl(vr_vldiv180,0) + nvl(vr_vldiv360,0) + nvl(vr_vldiv999,0);
            END IF;
            -- Zerar os valores de divida e a vencer
            vr_vlvec180 := 0;
            vr_vlvec360 := 0;
            vr_vlvec999 := 0;
            vr_vldiv060 := 0;
            vr_vldiv180 := 0;
            vr_vldiv360 := 0;
            vr_vldiv999 := 0;
          END IF;
          -- Somar na variavel auxiliar os valores de divida e a vencer ainda
          -- persistentes nas variaveis e tambem os valores separados nas variaveis
          -- de pejuizo cfme o ano
          vr_valor_auxiliar := nvl(vr_vlvec180,0) + nvl(vr_vlvec360,0) + nvl(vr_vlvec999,0)
                             + nvl(vr_vldiv060,0) + nvl(vr_vldiv180,0) + nvl(vr_vldiv360,0)
                             + nvl(vr_vldiv999,0) + nvl(vr_vlprjano,0) + nvl(vr_vlprjaan,0) + nvl(vr_vlprjant,0);
          -- Se existe informa��o na tabela de linhas de cr�dito cfme a linha do empr�stimo
          IF vr_tab_craplcr.EXISTS(pr_rw_crapepr.cdlcremp) THEN
            -- Se for uma opera��o de financiamento
            IF vr_tab_craplcr(pr_rw_crapepr.cdlcremp).dsoperac = 'FINANCIAMENTO' THEN
              vr_cdmodali := 0499;
            ELSE
              vr_cdmodali := 0299;
            END IF;            
            -- Montar a data prevista do ultimo vencimento com base na data do 
            -- primeiro pagamento * qtde de parcelas do empr�stimo
            -- Obs: Quando empr�stimo tiver apenas 1 parcela, a data do 1�
            --      pagamento � tamb�m a data da �ltima. Apenas atentamos
            --      para que esta data n�o fique inferior a data da contrata��o
            --      ent�o usamos um greatest com a dtinictr
            --      Quando tiver mais de 1 parcela, descontamos a parcela 01
            --      para calculo de meses, j� que a mesma j� � cobrada na data
            --      de in�cio do pagamento
            IF pr_rw_crapepr.qtpreemp = 1 THEN
              vr_dtvencop := greatest(pr_rw_crapepr.dtmvtolt,pr_rw_crapepr.dtdpripg);
            ELSE   
              vr_dtvencop := gene0005.fn_dtfun(pr_dtcalcul => pr_rw_crapepr.dtdpripg
                                              ,pr_qtdmeses => pr_rw_crapepr.qtpreemp - 1);
            END IF;          
            -- Utilizar o contrato como n�mero do empr�stimo
            vr_nrctremp := pr_rw_crapepr.nrctremp;
            -- Incrementar sequencial do contrato
            vr_nrseqctr := vr_nrseqctr + 1;
            
            -- Gerar Informacoes Docto 3020(Buffer)
            -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
            pc_grava_crapris(  pr_nrdconta => pr_rw_crapass.nrdconta                             
                              ,pr_dtrefere => vr_dtrefere
                              ,pr_innivris => vr_aux_nivel                 
                              ,pr_qtdiaatr => nvl(vr_qtdiaatr,0)                  
                              ,pr_vldivida => vr_valor_auxiliar                  
                              ,pr_vlvec180 => nvl(vr_vlvec180,0)                                      
                              ,pr_vlvec360 => nvl(vr_vlvec360,0)                            
                              ,pr_vlvec999 => nvl(vr_vlvec999,0)               
                              ,pr_vldiv060 => nvl(vr_vldiv060,0)                     
                              ,pr_vldiv180 => nvl(vr_vldiv180,0)                     
                              ,pr_vldiv360 => nvl(vr_vldiv360,0)  
                              ,pr_vldiv999 => nvl(vr_vldiv999,0)  
                              ,pr_vlprjano => nvl(vr_vlprjano,0)                            
                              ,pr_vlprjaan => nvl(vr_vlprjaan,0)
                              ,pr_inpessoa => pr_rw_crapass.inpessoa                             
                              ,pr_nrcpfcgc => pr_rw_crapass.nrcpfcgc 
                              ,pr_vlprjant => nvl(vr_vlprjant,0) 
                              ,pr_inddocto => 1          -- Docto 3020
                              ,pr_cdmodali => vr_cdmodali -- Cfme a linha de cr�dito
                              ,pr_nrctremp => vr_nrctremp
                              ,pr_nrseqctr => vr_nrseqctr                     
                              ,pr_dtinictr => pr_rw_crapepr.dtmvtolt                                      
                              ,pr_cdorigem => 3   -- Emprestimos/Financiamentos 
                              ,pr_cdagenci => pr_rw_crapass.cdagenci 
                              ,pr_innivori => 0                     
                              ,pr_cdcooper => pr_cdcooper                      
                              ,pr_vlprjm60 => 0                     
                              ,pr_dtdrisco => NULL                     
                              ,pr_qtdriclq => 0                     
                              ,pr_nrdgrupo => 0                                      
                              ,pr_vljura60 => 0                                      
                              ,pr_inindris => vr_aux_nivel                                      
                              ,pr_cdinfadi => ' '                                    
                              ,pr_nrctrnov => 0                                      
                              ,pr_flgindiv => 0                                    
                              ,pr_dsinfaux => ' '                             
                              ,pr_dtprxpar => vr_dtprxpar                             
                              ,pr_vlprxpar => vr_vlprxpar                 
                              ,pr_qtparcel => pr_rw_crapepr.qtpreemp                         
                              ,pr_dtvencop => vr_dtvencop
                              ,pr_des_erro => vr_des_erro
                              ,pr_index_crapris => vr_index_crapris);
            -- Testar retorno de erro
            IF vr_des_erro IS NOT NULL THEN
              -- Gerar erro e roolback
              RAISE vr_exc_erro;
            END IF;
            
          END IF;
        ELSE --> vr_valor_auxiliar <= 0
          vr_vlvec180 := 0;
          vr_vlvec360 := 0;
          vr_vlvec999 := 0;
          vr_vldiv060 := 0;
          vr_vldiv180 := 0;
          vr_vldiv360 := 0;
          vr_vldiv999 := 0;
          vr_vlprjano := 0;
          vr_vlprjaan := 0;
          vr_vlprjant := 0;
        END IF;
        /* Se o numero de prestacoes faltantes for <= 1 e esta em atraso a mais de 60 dias
           Obs.: Esta sendo feito desta forma, pois na atual forma de
                 calculo ha problema para emprestimos em que o valor do
                 atraso eh menor que o dobro da parcela e esta vencido a
                 mais de 60 dias (demanda bacen, reversao da receita 60d)
                 Esta situacao sera corrigida quando o novo sistema
                 de emprestimo entrar em vigor. */
        IF pr_rw_crapepr.inprejuz <> 1 AND pr_rw_crapepr.qtpreemp - pr_rw_crapepr.qtprepag <= 1
        AND pr_rw_crapepr.qtpreemp - pr_rw_crapepr.qtprepag > 0 AND vr_qtdiaatr > 60 THEN
          -- Calcular dias em vencimento do risco
          vr_diasvenc := vr_qtdiaatr*-1;
          -- Buscar o c�digo do vencimento a lan�ar
          vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc
                                            ,pr_qtdiapre => vr_qtdiapre
                                            ,pr_flgempre => TRUE);
                                                                                        
          -- Chamar rotina de grava��o dos vencimentos do risco
          pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta --> Num. da conta
                          ,pr_dtrefere => vr_dtrefere            --> Data de refer�ncia
                          ,pr_innivris => vr_aux_nivel           --> N�vel do risco
                          ,pr_cdmodali => vr_cdmodali            --> Cfme a linha de cr�dito
                          ,pr_cdvencto => vr_cdvencto            --> Codigo do vencimento
                          ,pr_nrctremp => vr_nrctremp            --> Nro contrato
                          ,pr_nrseqctr => vr_nrseqctr            --> Seq contrato empr�stimo
                          ,pr_vlsrisco => vr_valor_auxiliar      --> Valor do risco a lan�ar
                          ,pr_des_erro => vr_des_erro);
          -- Testar retorno de erro
          IF vr_des_erro IS NOT NULL THEN
            -- Gerar erro e roolback
            RAISE vr_exc_erro;
          END IF;
                    
        ELSE
          -- Se houver valor nas variaveis de valor a vencer 180, 360 e 999 dias
          IF nvl(vr_vlvec180,0) > 0 OR nvl(vr_vlvec360,0) > 0 OR nvl(vr_vlvec999,0) > 0 THEN
            -- Chamar rotina para gerar vetor de parcelas a vencer
            pc_gera_avencer(pr_vlpreemp     => pr_rw_crapepr.vlpreemp
                           ,pr_vlvenc180    => vr_vlvec180
                           ,pr_vlvenc360    => vr_vlvec360
                           ,pr_vlvenc999    => vr_vlvec999
                           ,pr_vet_vlavence => vr_tab_vlavence);
          ELSE
            -- Limpar o vetor
            FOR vr_ind IN 1..23 LOOP
              vr_tab_vlavence(vr_ind) := 0;
            END LOOP;
          END IF;
          -- Para cada registro de parcelas no vetor a vencer
          IF vr_tab_vlavence.COUNT > 0 THEN
            FOR vr_ind IN vr_tab_vlavence.FIRST..vr_tab_vlavence.LAST LOOP
              -- Se existe valor nesta posi��o
              IF vr_tab_vlavence.EXISTS(vr_ind) AND vr_tab_vlavence(vr_ind) > 0 THEN
                -- Dias em vencimento vem do vetor
                vr_diasvenc := vr_tab_ddavence(vr_ind);
                -- Buscar o c�digo do vencimento a lan�ar
                vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc
                                                  ,pr_qtdiapre => vr_qtdiapre
                                                  ,pr_flgempre => TRUE);
                                                  
                -- Chamar rotina de grava��o dos vencimentos do risco
                pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta  --> Num. da conta
                                ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                                ,pr_innivris => vr_aux_nivel            --> N�vel do risco
                                ,pr_cdmodali => vr_cdmodali             --> Cfme a linha de cr�dito
                                ,pr_cdvencto => vr_cdvencto             --> Codigo do vencimento
                                ,pr_nrctremp => vr_nrctremp             --> Nro contrato
                                ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                                ,pr_vlsrisco => vr_tab_vlavence(vr_ind) --> Valor do risco a lan�ar
                                ,pr_des_erro => vr_des_erro);
                -- Testar retorno de erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar erro e roolback
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END LOOP;
          END IF;
          -- Se houver valor de d�vida em um dos quatro per�odos
          IF nvl(vr_vldiv060,0) > 0 OR nvl(vr_vldiv180,0) > 0
          OR nvl(vr_vldiv360,0) > 0 OR nvl(vr_vldiv999,0) > 0 THEN
            -- Rotina para gerar vetor de parcelas a vencer
            pc_gera_vencidos(pr_vlpreemp     => pr_rw_crapepr.vlpreemp
                            ,pr_qtdiaatr     => vr_qtdiaatr
                            ,pr_vldivi060    => vr_vldiv060
                            ,pr_vldivi180    => vr_vldiv180
                            ,pr_vldivi360    => vr_vldiv360
                            ,pr_vldivi999    => vr_vldiv999
                            ,pr_vet_vlvencid => vr_tab_vlvencid);
          ELSE
            -- Limpar o vetor
            FOR vr_ind IN 1..12 LOOP
              vr_tab_vlvencid(vr_ind) := 0;
            END LOOP;
          END IF;
          -- Para cada registro no vetor de parcelas vencidas
          IF vr_tab_vlvencid.COUNT > 0 THEN
            FOR vr_ind IN vr_tab_vlvencid.FIRST..vr_tab_vlvencid.LAST LOOP
              -- Se existe valor nesta posi��o
              IF vr_tab_vlvencid.EXISTS(vr_ind) AND vr_tab_vlvencid(vr_ind) > 0 THEN
                -- Dias em vencimento vem do vetor * -1
                vr_diasvenc := vr_tab_ddvencid(vr_ind) * -1;
                -- Buscar o c�digo do vencimento a lan�ar
                vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc
                                                  ,pr_qtdiapre => vr_qtdiapre
                                                  ,pr_flgempre => TRUE);
                                                  
                -- Chamar rotina de grava��o dos vencimentos do risco
                pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta  --> Num. da conta
                                ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                                ,pr_innivris => vr_aux_nivel            --> N�vel do risco
                                ,pr_cdmodali => vr_cdmodali             --> Cfme a linha de cr�dito
                                ,pr_cdvencto => vr_cdvencto             --> Codigo do vencimento
                                ,pr_nrctremp => vr_nrctremp             --> Nro contrato empr�stimo
                                ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                                ,pr_vlsrisco => vr_tab_vlvencid(vr_ind) --> Valor do risco a lan�ar
                                ,pr_des_erro => vr_des_erro);
                -- Testar retorno de erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar erro e roolback
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END LOOP;
          END IF;
        END IF;
        -- Se existir valor prejuizo ano atual
        IF vr_vlprjano > 0 THEN
          -- Utilizar c�digo vencimento 310
          vr_cdvencto := 310;
          
          -- Chamar rotina de grava��o dos vencimentos do risco passando este valor
          pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta --> Num. da conta
                          ,pr_dtrefere => vr_dtrefere            --> Data de refer�ncia
                          ,pr_innivris => vr_aux_nivel           --> N�vel do risco
                          ,pr_cdmodali => vr_cdmodali            --> Cfme a linha de cr�dito
                          ,pr_cdvencto => vr_cdvencto            --> Codigo do vencimento
                          ,pr_nrctremp => vr_nrctremp            --> Nro contrato empr�stimo
                          ,pr_nrseqctr => vr_nrseqctr            --> Seq contrato empr�stimo
                          ,pr_vlsrisco => vr_vlprjano            --> Valor do risco a lan�ar
                          ,pr_des_erro => vr_des_erro);
          -- Testar retorno de erro
          IF vr_des_erro IS NOT NULL THEN
            -- Gerar erro e roolback
            RAISE vr_exc_erro;
          END IF;
          
        END IF;
        -- Se existir valor prejuizo ano anterior
        IF vr_vlprjaan > 0 THEN
          -- Utilizar c�digo vencimento 320
          vr_cdvencto := 320;
                    
          -- Chamar rotina de grava��o dos vencimentos do risco passando este valor
          pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta --> Num. da conta
                          ,pr_dtrefere => vr_dtrefere            --> Data de refer�ncia
                          ,pr_innivris => vr_aux_nivel           --> N�vel do risco
                          ,pr_cdmodali => vr_cdmodali            --> Cfme a linha de cr�dito
                          ,pr_cdvencto => vr_cdvencto            --> Codigo do vencimento
                          ,pr_nrctremp => vr_nrctremp            --> Nro contrato empr�stimo
                          ,pr_nrseqctr => vr_nrseqctr            --> Seq contrato empr�stimo
                          ,pr_vlsrisco => vr_vlprjaan            --> Valor do risco a lan�ar
                          ,pr_des_erro => vr_des_erro);
          -- Testar retorno de erro
          IF vr_des_erro IS NOT NULL THEN
            -- Gerar erro e roolback
            RAISE vr_exc_erro;
          END IF;
          
        END IF;
        -- Se existir valor prejuizo anos anteriores
        IF vr_vlprjant > 0 THEN
          -- Utilizar c�digo vencimento 330
          vr_cdvencto := 330;
                    
          -- Chamar rotina de grava��o dos vencimentos do risco passando este valor
          pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta --> Num. da conta
                          ,pr_dtrefere => vr_dtrefere            --> Data de refer�ncia
                          ,pr_innivris => vr_aux_nivel           --> N�vel do risco
                          ,pr_cdmodali => vr_cdmodali            --> Cfme a linha de cr�dito
                          ,pr_cdvencto => vr_cdvencto            --> Codigo do vencimento
                          ,pr_nrctremp => vr_nrctremp            --> Nro contrato empr�stimo
                          ,pr_nrseqctr => vr_nrseqctr            --> Seq contrato empr�stimo
                          ,pr_vlsrisco => vr_vlprjant            --> Valor do risco a lan�ar
                          ,pr_des_erro => vr_des_erro);
          -- Testar retorno de erro
          IF vr_des_erro IS NOT NULL THEN
            -- Gerar erro e roolback
            RAISE vr_exc_erro;
          END IF;
                    
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pc_lista_emp_price --> Erro ao processar emprestimo price: '
                      || ' - Conta:' ||pr_rw_crapepr.nrdconta || ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||vr_des_erro;

        WHEN OTHERS THEN
          pr_des_erro := 'pc_lista_emp_price --> Erro n�o tratado ao processar emprestimo price: '
                      || ' - Conta:'||pr_rw_crapepr.nrdconta|| ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||sqlerrm;
      END;

      -- Varrer e processar empr�stimos pr�-fixado
      PROCEDURE pc_lista_emp_prefix(pr_rw_crapass IN cr_crapass%ROWTYPE
                                   ,pr_rw_crapepr IN cr_crapepr%ROWTYPE
                                   ,pr_risco_rating IN PLS_INTEGER
                                   ,pr_des_erro  OUT VARCHAR2) IS
        -- Vari�veis auxiliares
        vr_cdmodali         crapris.cdmodali%TYPE; --> C�digo da modalidade montado cfme a linha de cr�dito
        vr_aux_nivel        PLS_INTEGER;           --> Nivel do risco
        vr_nivel_atraso     PLS_INTEGER;           --> Nivel do risco
        vr_qtdiaatr         crapris.qtdiaatr%TYPE; --> Quantidade de dias em atraso
        vr_rowid            ROWID;                 --> Guardar o ID do registro criado
        --vr_vljura60         crapris.vljura60%TYPE; --> Juros do risco
        vr_vldiv060         crapris.vldiv060%TYPE; --> Valor do atraso quando prazo inferior a 60
        vr_vldiv180         crapris.vldiv180%TYPE; --> Valor do atraso quando prazo inferior a 180
        vr_vldiv360         crapris.vldiv360%TYPE; --> Valor do atraso quando prazo inferior a 360
        vr_vldiv999         crapris.vldiv999%TYPE; --> Valor do atraso para outros casos
        vr_vlvec180         crapris.vlvec180%TYPE; --> Valor a vencer nos pr�ximos 180 dias
        vr_vlvec360         crapris.vlvec360%TYPE; --> Valor a vencer nos pr�ximos 360 dias
        vr_vlvec999         crapris.vlvec999%TYPE; --> Valor a vencer para outros casos
        vr_vldivida_acum    NUMBER;                --> Valor da divida acumulada
        vr_totjur60         NUMBER;                --> Total dos juros 60 dias
        vr_nrparepr         NUMBER;                --> Ultima parcela
        vr_dsnivris         VARCHAR2(2);           --> Nivel do risco atual
         
        vr_vlprxpar         crapris.vlprxpar%TYPE; --> Valor da pr�xima parcela
        vr_dtprxpar         crapris.dtprxpar%TYPE; --> Data da pr�xima parcela
        vr_vlsdeved_atual   NUMBER;                --> Saldo devedor atual
       
        -- Busca da parcela de maior atraso
        CURSOR cr_crappep_maior IS
          SELECT min(dtvencto)
            FROM crappep
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_rw_crapepr.nrdconta
             AND nrctremp = pr_rw_crapepr.nrctremp
             AND inliquid = 0  --> N�o liquidada
             AND dtvencto <= pr_rw_crapdat.dtmvtoan; -- Anterior a data atual
--           ORDER BY dtvencto;
        vr_dtvencto crappep.dtvencto%TYPE;
        
        -- Busca da ultima n�o liquidada
        CURSOR cr_crappep_ultima IS
          SELECT MAX(nrparepr)
            FROM crappep 
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_rw_crapepr.nrdconta
             AND nrctremp = pr_rw_crapepr.nrctremp
             AND inliquid = 0; --> N�o liquidadar

        -- Busca de todas as parcelas em aberto
        CURSOR cr_crappep IS
          SELECT nrparepr
                ,dtvencto
                ,vlsdvatu
                ,vljura60
                ,vlparepr
            FROM crappep
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_rw_crapepr.nrdconta
             AND nrctremp = pr_rw_crapepr.nrctremp
             AND inliquid = 0 --> N�o liquidada
           ORDER BY nrparepr;  
             
        -- Cursor para juros em atraso ha mais de 60 dias
        CURSOR cr_craplem_60 (pr_qtdiaatr IN NUMBER) IS
          SELECT NVL(SUM(lem.vllanmto),0)
            FROM craplem lem
           WHERE lem.cdcooper = pr_cdcooper
             AND lem.nrdconta = pr_rw_crapepr.nrdconta
             AND lem.nrctremp = pr_rw_crapepr.nrctremp
             AND lem.cdhistor IN (1037,1038)
             AND lem.dtmvtolt > pr_rw_crapdat.dtmvtolt - (pr_qtdiaatr - 59);       

      BEGIN
        -- Se existe informa��o na tabela de linhas de cr�dito cfme a linha do empr�stimo
        IF vr_tab_craplcr.EXISTS(pr_rw_crapepr.cdlcremp) THEN
          -- Se for uma opera��o de financiamento
          IF vr_tab_craplcr(pr_rw_crapepr.cdlcremp).dsoperac = 'FINANCIAMENTO' THEN
            vr_cdmodali := 0499;
          ELSE
            vr_cdmodali := 0299;
          END IF;
        ELSE
          vr_cdmodali := 0299;
        END IF;
        
        -- Sem atraso e risco A
        vr_qtdiaatr := 0;
        vr_aux_nivel := 2;
           
        -- Buscar a parcela com maior atraso        
        vr_dtvencto := NULL;
        vr_idxpep := lpad(pr_cdcooper,5,'0')||lpad(pr_rw_crapepr.nrdconta,10,'0')||lpad(pr_rw_crapepr.nrctremp,10,'0');
        IF vr_tab_crappep_maior.exists(vr_idxpep) THEN
          vr_dtvencto := vr_tab_crappep_maior(vr_idxpep); 
        END if; 
         
        -- Se encontrou
        IF vr_dtvencto IS NOT NULL THEN
          -- Calcular a quantidade de dias em atraso
          vr_qtdiaatr := pr_rw_crapdat.dtmvtolt - vr_dtvencto;
          -- Calcular o n�vel de acordo com a quantidade de dias em atraso
          CASE
            WHEN vr_qtdiaatr  < 15   THEN
              vr_aux_nivel := 2;
            WHEN vr_qtdiaatr  <= 30   THEN
              vr_aux_nivel := 3;
            WHEN vr_qtdiaatr  <= 60   THEN
              vr_aux_nivel := 4;
            WHEN vr_qtdiaatr  <= 90   THEN
              vr_aux_nivel := 5;
            WHEN vr_qtdiaatr  <= 120   THEN
              vr_aux_nivel := 6;
            WHEN vr_qtdiaatr  <= 150   THEN
              vr_aux_nivel := 7;
            WHEN vr_qtdiaatr  <= 180   THEN
              vr_aux_nivel := 8;
            ELSE
              vr_aux_nivel := 9;
          END CASE;
        ELSE
          -- Sem atraso e risco A
          vr_qtdiaatr := 0;
          vr_aux_nivel := 2;
        END IF;        
        
        -- Backup da variavel vr_aux_nivel
        vr_nivel_atraso := vr_aux_nivel;
        
        -- Testar se existe algo na tabela de cadastro complementar
        -- Copi�-lo a variavel
        vr_dsnivris := pr_rw_crapepr.dsnivris; --  vt_tab_nivepr(LPAD(pr_rw_crapepr.nrdconta,10,'0')||lpad(pr_rw_crapepr.nrctremp,10,'0'));
        -- Vamos verificar qual nivel de risco esta na proposto do emprestimo
        CASE
          WHEN vr_dsnivris = ' '  THEN
            vr_aux_nivel := 2;
          WHEN vr_dsnivris = 'AA' THEN
            vr_aux_nivel := 1;
          WHEN vr_dsnivris = 'A'  THEN
            vr_aux_nivel := 2;
          WHEN vr_dsnivris = 'B'  THEN
            vr_aux_nivel := 3;
          WHEN vr_dsnivris = 'C'  THEN
            vr_aux_nivel := 4;
          WHEN vr_dsnivris = 'D'  THEN
            vr_aux_nivel := 5;
          WHEN vr_dsnivris = 'E'  THEN
            vr_aux_nivel := 6;
          WHEN vr_dsnivris = 'F'  THEN
            vr_aux_nivel := 7;
          WHEN vr_dsnivris = 'G'  THEN
            vr_aux_nivel := 8;  
          ELSE
            vr_aux_nivel := 9;
        END CASE;
          
        IF pr_risco_rating <> 0 THEN            
          IF vr_tab_crapnrc.EXISTS(pr_rw_crapepr.nrdconta) THEN
            -- Se a data do rating for superior ou igual a do vencimento da parcela
            IF vr_tab_crapnrc(pr_rw_crapepr.nrdconta).dtmvtolt >= pr_rw_crapepr.dtmvtolt THEN
              -- Verifica o pior Nivel entre o Rating e o Risco da Operacao
              IF pr_risco_rating > vr_aux_nivel THEN
                -- Assumir o n�vel do rating
                vr_aux_nivel := pr_risco_rating;
              END IF;
                  
            END IF;
              
          END IF;
            
        END IF; /* END IF pr_risco_rating <> 0 */
        
        /* Se emprestimo tiver nivel maior que o atraso....*/
        IF vr_nivel_atraso > vr_aux_nivel THEN 
          vr_aux_nivel := vr_nivel_atraso;
        END IF;
        
        -- Verifica se o emprestimo esta em prejuizo
        IF pr_rw_crapepr.inprejuz = 1 THEN
          vr_aux_nivel := 9;
        END IF;
        
        IF pr_risco_rating <> 0 AND pr_risco_rating > vr_aux_nivel THEN
          vr_aux_nivel := pr_risco_rating;
        END IF;
        
        IF pr_risco_rating <> 0 AND vr_qtdiaatr <= 0 THEN
          IF vr_tab_crapnrc.EXISTS(pr_rw_crapepr.nrdconta) THEN
            -- Se a data do rating for superior ou igual a do vencimento da parcela
            IF vr_tab_crapnrc(pr_rw_crapepr.nrdconta).dtmvtolt >= pr_rw_crapepr.dtmvtolt THEN
              -- Verifica o pior Nivel entre o Rating e o Risco da Operacao
              IF pr_risco_rating > vr_aux_nivel THEN
                -- Assumir o n�vel do rating
                vr_aux_nivel := pr_risco_rating;
              END IF;

            END IF;
              
          END IF;
          
        END IF;
        
        -- Calculo dos Juros em atraso a mais de 60 dias        
        vr_totjur60 := 0;        
        -- Calcular somente na mensal
        IF vr_qtdiaatr >= 60  THEN  -- Calcular o valor dos juros a mais de 60 dias
          OPEN cr_craplem_60 (pr_qtdiaatr => vr_qtdiaatr);
          FETCH cr_craplem_60 INTO vr_totjur60;
          CLOSE cr_craplem_60;
          
          -- Diario
          IF to_char(pr_rw_crapdat.dtmvtolt,'mm') = to_char(pr_rw_crapdat.dtmvtopr,'mm') THEN
            -- Obter valor de juros a mais de 60 dias
            vr_totjur60 := nvl(vr_totjur60,0) + nvl(fn_calcula_juros_60d_pp(pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                                                           ,pr_dtmvtopr => pr_rw_crapdat.dtmvtopr
                                                                           ,pr_dtdpagto => pr_rw_crapepr.dtdpagto
                                                                           ,pr_diarefju => pr_rw_crapepr.diarefju
                                                                           ,pr_mesrefju => pr_rw_crapepr.mesrefju
                                                                           ,pr_anorefju => pr_rw_crapepr.anorefju
                                                                           ,pr_txjuremp => pr_rw_crapepr.txjuremp
                                                                           ,pr_dtlibera => pr_rw_crapepr.dtlibera
                                                                           ,pr_vlsdeved => nvl(pr_rw_crapepr.vlsdevat,0)),0);
          END IF;
                                                                         
        END IF;
        --END IF;
        -- Montar a data prevista do ultimo vencimento com base na data do 
        -- primeiro pagamento * qtde de parcelas do empr�stimo
        -- Obs: Quando empr�stimo tiver apenas 1 parcela, a data do 1�
        --      pagamento � tamb�m a data da �ltima. Apenas atentamos
        --      para que esta data n�o fique inferior a data da contrata��o
        --      ent�o usamos um greatest com a dtinictr
        --      Quando tiver mais de 1 parcela, descontamos a parcela 01
        --      para calculo de meses, j� que a mesma j� � cobrada na data
        --      de in�cio do pagamento
        IF pr_rw_crapepr.qtpreemp = 1 THEN
          vr_dtvencop := greatest(pr_rw_crapepr.dtmvtolt,pr_rw_crapepr.dtdpripg);
        ELSE   
          vr_dtvencop := gene0005.fn_dtfun(pr_dtcalcul => pr_rw_crapepr.dtdpripg
                                          ,pr_qtdmeses => pr_rw_crapepr.qtpreemp - 1);
        END IF;
        -- Incrementar sequencial do contrato
        vr_nrseqctr := vr_nrseqctr + 1;
        vr_index_crapris_aux := NULL;
        -- Finalmente criar o registro de risco
        
        -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
        pc_grava_crapris(  pr_nrdconta => pr_rw_crapass.nrdconta                             
                          ,pr_dtrefere => vr_dtrefere
                          ,pr_innivris => vr_aux_nivel                 
                          ,pr_qtdiaatr => nvl(vr_qtdiaatr,0)                  
                          ,pr_vldivida => 0
                          ,pr_vlvec180 => 0
                          ,pr_vlvec360 => 0 
                          ,pr_vlvec999 => 0
                          ,pr_vldiv060 => 0
                          ,pr_vldiv180 => 0
                          ,pr_vldiv360 => 0
                          ,pr_vldiv999 => 0
                          ,pr_vlprjano => 0
                          ,pr_vlprjaan => 0
                          ,pr_inpessoa => pr_rw_crapass.inpessoa                             
                          ,pr_nrcpfcgc => pr_rw_crapass.nrcpfcgc 
                          ,pr_vlprjant => 0
                          ,pr_inddocto => 1           -- Docto 3020
                          ,pr_cdmodali => vr_cdmodali -- Cfme a linha de cr�dito
                          ,pr_nrctremp => pr_rw_crapepr.nrctremp
                          ,pr_nrseqctr => vr_nrseqctr                     
                          ,pr_dtinictr => pr_rw_crapepr.dtmvtolt                                      
                          ,pr_cdorigem => 3   -- Emprestimos/Financiamentos 
                          ,pr_cdagenci => pr_rw_crapass.cdagenci 
                          ,pr_innivori => 0                     
                          ,pr_cdcooper => pr_cdcooper                      
                          ,pr_vlprjm60 => 0                     
                          ,pr_dtdrisco => NULL                     
                          ,pr_qtdriclq => 0                     
                          ,pr_nrdgrupo => 0                                      
                          ,pr_vljura60 => vr_totjur60                                      
                          ,pr_inindris => vr_aux_nivel                                      
                          ,pr_cdinfadi => ' '                                    
                          ,pr_nrctrnov => 0                                      
                          ,pr_flgindiv => 0                                    
                          ,pr_dsinfaux => ' '                             
                          ,pr_dtprxpar => NULL                             
                          ,pr_vlprxpar => 0
                          ,pr_qtparcel => pr_rw_crapepr.qtpreemp                         
                          ,pr_dtvencop => vr_dtvencop
                          ,pr_des_erro => vr_des_erro
                          ,pr_index_crapris => vr_index_crapris_aux);
        -- Testar retorno de erro
        IF vr_des_erro IS NOT NULL THEN
          -- Gerar erro e roolback
          RAISE vr_exc_erro;
        END IF;
            
        -- Iniciar valor de juros e das parcelas a vencer e vencidas
        vr_vldiv060 := 0;
        vr_vldiv180 := 0;
        vr_vldiv360 := 0;
        vr_vldiv999 := 0;
        vr_vlvec180 := 0;
        vr_vlvec360 := 0;
        vr_vlvec999 := 0;
        vr_vldivida_acum := 0;
        

        --> Informa��o � necessaria apenas na mensal 
        IF  to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm')  THEN          
          -- Obter ultima parcela em aberto 
          OPEN cr_crappep_ultima;        
          FETCH cr_crappep_ultima 
           INTO vr_nrparepr;
          CLOSE cr_crappep_ultima;
        END IF;
        -- Buscar todas as parcelas n�o liquidadas
        FOR rw_crappep IN cr_crappep LOOP        
              -- Acumular o valor do saldo atual
          vr_vldivida_acum := vr_vldivida_acum + rw_crappep.vlsdvatu;         
              -- Saldo devedor atual
          vr_vlsrisco := rw_crappep.vlsdvatu;          
              -- Somente na mensal
              IF  to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm')  THEN          
                -- Se for a ultima parcela 
            IF  rw_crappep.nrparepr = vr_nrparepr  THEN          
                  IF  pr_rw_crapepr.vlsdeved != vr_vldivida_acum  THEN
                    vr_vlsrisco := (pr_rw_crapepr.vlsdeved - vr_vldivida_acum) +
                                rw_crappep.vlsdvatu;   
                  END IF;              
                END IF;          
              END IF;
            
          vr_idxpep := lpad(pr_cdcooper,5,'0')||lpad(pr_rw_crapass.nrdconta,10,'0')||
                       lpad(pr_rw_crapepr.nrctremp,10,'0');
          
          IF vr_tab_cessoes.exists(vr_idxpep) THEN    
              -- Calcular diferen�a de dias entre a parcela e o dia atual
            vr_diasvenc := vr_tab_cessoes(vr_idxpep) - pr_rw_crapdat.dtmvtolt;
          ELSE
            -- Calcular diferen�a de dias entre a parcela e o dia atual
          vr_diasvenc := rw_crappep.dtvencto - pr_rw_crapdat.dtmvtolt;
          END IF;
          
              -- Buscar o c�digo do vencimento a lan�ar
              vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc
                                                ,pr_qtdiapre => vr_diasvenc -- Enviar a mesma informa�ao
                                                ,pr_flgempre => TRUE);
              -- Chamar rotina de grava��o dos vencimentos do risco
              pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta  --> Num. da conta
                              ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                              ,pr_innivris => vr_aux_nivel            --> N�vel do risco
                              ,pr_cdmodali => vr_cdmodali             --> Cfme a linha de cr�dito
                              ,pr_cdvencto => vr_cdvencto             --> Codigo do vencimento
                              ,pr_nrctremp => pr_rw_crapepr.nrctremp  --> Nro contrato empr�stimo
                              ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                              ,pr_vlsrisco => vr_vlsrisco             --> Valor do risco a lan�ar
                              ,pr_des_erro => vr_des_erro);
              -- Testar retorno de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar erro e roolback
                RAISE vr_exc_erro;
              END IF;
              -- Para valores a vencer
              IF vr_diasvenc >= 0 THEN
                -- Se ainda n�o achou a primeira parcela em aberto (futuro)
            IF vr_dtprxpar IS NULL AND rw_crappep.dtvencto > pr_rw_crapdat.dtmvtolt THEN
                  -- Armazenar valor da pr�xima parcela
              vr_vlprxpar := rw_crappep.vlparepr;
              vr_dtprxpar := rw_crappep.dtvencto;
                END IF;
                -- Acumular na variavel correspondente de acordo com a quantidade de dias
                IF vr_diasvenc <= 180 THEN
                  vr_vlvec180 := vr_vlvec180 + vr_vlsrisco;
                ELSIF vr_diasvenc <= 360 THEN
                  vr_vlvec360 := vr_vlvec360 + vr_vlsrisco;
                ELSE
                  vr_vlvec999 := vr_vlvec999 + vr_vlsrisco;
                END IF;
              ELSE
                -- Negativar a diferen�a de dias pois o valor j� est� vencido
                -- e o calculo retornou o valor negativo
                vr_diasvenc := vr_diasvenc * -1;
                -- Acumular na variavel correspondente de acordo com a quantidade de dias
                IF vr_diasvenc <= 60 THEN
                  vr_vldiv060 := vr_vldiv060 + vr_vlsrisco;
                ELSIF vr_diasvenc <= 180 THEN
                  vr_vldiv180 := vr_vldiv180 + vr_vlsrisco;
                ELSIF vr_diasvenc <= 360 THEN
                  vr_vldiv360 := vr_vldiv360 + vr_vlsrisco;
                ELSE
                  vr_vldiv999 := vr_vldiv999 + vr_vlsrisco;
                END IF;
              END IF;
            END LOOP;

        -- Somente na mensal
        IF  to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm')  THEN
          vr_vldivida_acum := pr_rw_crapepr.vlsdeved;          
        END IF;      
        
        -- Ap�s calcular as parcelas em atraso, atualizar as variaveis de
        -- parcelas a vencer e dividas do risco
        vr_tab_crapris(vr_index_crapris_aux).vldiv060 :=  vr_vldiv060;
        vr_tab_crapris(vr_index_crapris_aux).vldiv180 :=  vr_vldiv180;
        vr_tab_crapris(vr_index_crapris_aux).vldiv360 :=  vr_vldiv360;
        vr_tab_crapris(vr_index_crapris_aux).vldiv999 :=  vr_vldiv999;
        vr_tab_crapris(vr_index_crapris_aux).vlvec180 :=  vr_vlvec180;
        vr_tab_crapris(vr_index_crapris_aux).vlvec360 :=  vr_vlvec360;
        vr_tab_crapris(vr_index_crapris_aux).vlvec999 :=  vr_vlvec999;
        vr_tab_crapris(vr_index_crapris_aux).vldivida :=  vr_vldivida_acum;
        vr_tab_crapris(vr_index_crapris_aux).vlprxpar :=  vr_vlprxpar;
        vr_tab_crapris(vr_index_crapris_aux).dtprxpar :=  vr_dtprxpar;
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pc_lista_emp_prefix --> Erro ao processar emprestimo pre-fixado: '
                      || ' - Conta:' ||pr_rw_crapepr.nrdconta || ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||vr_des_erro;

        WHEN OTHERS THEN
          pr_des_erro := 'pc_lista_emp_prefix --> Erro n�o tratado ao processar emprestimo pre-fixado: '
                      || ' - Conta:'||pr_rw_crapepr.nrdconta|| ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||sqlerrm;
      END;
      
      -- Varrer e processar empr�stimos pr�-fixado
      PROCEDURE pc_lista_emp_prefix_prejuizo(pr_rw_crapass   IN cr_crapass%ROWTYPE
                                            ,pr_rw_crapepr   IN cr_crapepr%ROWTYPE
                                            ,pr_des_erro     OUT VARCHAR2) IS

        vr_vlrpagos         crapepr.vlprejuz%TYPE; --> Valor pago no empr�stimo
        vr_cdmodali         crapris.cdmodali%TYPE; --> C�digo da modalidade montado cfme a linha de cr�dito
        vr_difmespr         PLS_INTEGER;           --> Diferen�a de meses em preju�zo
        vr_vldivida_acum    NUMBER;                --> Valor da divida acumulada
        vr_aux_nivel        PLS_INTEGER;           --> N�vel do risco        
        vr_qtdiaatr         PLS_INTEGER;            --> Var auxiliar para manter o atraso 
        vr_dtvencto         DATE;
        
      BEGIN
      
        -- Inicializa as variaveis
        vr_vlrpagos     := 0;
        vr_vlprjano     := 0;
        vr_vlprjaan     := 0;
        vr_vlprjant     := 0;
        vr_vlsrisco     := 0;
        vr_aux_nivel    := 10;
        vr_qtdiaatr     := 0;
        
        -- Buscar a parcela com maior atraso        
        vr_dtvencto := NULL;
        vr_idxpep := lpad(pr_cdcooper,5,'0')||lpad(pr_rw_crapepr.nrdconta,10,'0')||lpad(pr_rw_crapepr.nrctremp,10,'0');
        IF vr_tab_crappep_maior.exists(vr_idxpep) THEN
          vr_dtvencto := vr_tab_crappep_maior(vr_idxpep); 
        END if; 
         
        -- Se encontrou
        IF vr_dtvencto IS NOT NULL THEN
          -- Calcular a quantidade de dias em atraso
           vr_qtdiaatr := pr_rw_crapdat.dtmvtolt - vr_dtvencto;
        END IF; 
        
        --> incrementar qtd de dias em atraso antes de se tornar em prejuizo
        IF pr_rw_crapepr.cdlcremp = 100 THEN
        
          --> Buscar ultimo nivel de risco
          rw_crapris_9_100 := NULL;
          OPEN cr_crapris_9_100 ( pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => pr_rw_crapepr.nrdconta,
                                  pr_nrctremp => pr_rw_crapepr.nrctremp);
          FETCH cr_crapris_9_100 INTO rw_crapris_9_100;
          CLOSE cr_crapris_9_100;
          
          --> atribuir a quantidade de dias antes do prejuizo
          vr_qtdiaatr := nvl(rw_crapris_9_100.qtdiaatr,0);
          
          --> adicionar os dias at� a data do atual
          vr_qtdiaatr := nvl(vr_qtdiaatr,0) + (pr_rw_crapdat.dtmvtolt - rw_crapris_9_100.dtrefere);
        
        END IF;        
        
        -- Busca os pagamentos de preju�zo
        vr_index_prejuz := lpad(pr_rw_crapepr.nrdconta, 10, '0') ||
                           lpad(pr_rw_crapepr.nrctremp, 10, '0');
        IF vr_tab_prejuz.EXISTS(vr_index_prejuz) THEN
          vr_vlrpagos := vr_tab_prejuz(vr_index_prejuz);
        END IF;
        
        -- Se o valor pago for superior ou igual ao prejuizo OU o saldo de prejuizo estiver zerado
        IF vr_vlrpagos >= pr_rw_crapepr.vlprejuz OR pr_rw_crapepr.vlsdprej = 0 THEN
          RETURN;
        END IF;
        
        -- Se existe informa��o na tabela de linhas de cr�dito cfme a linha do empr�stimo
        IF vr_tab_craplcr.EXISTS(pr_rw_crapepr.cdlcremp) THEN
          -- Se for uma opera��o de financiamento
          IF vr_tab_craplcr(pr_rw_crapepr.cdlcremp).dsoperac = 'FINANCIAMENTO' THEN
            vr_cdmodali := 0499;
          ELSE
            vr_cdmodali := 0299;
          END IF;
        ELSE
          vr_cdmodali := 0299;
        END IF;
        
        vr_vldivida_acum := nvl(pr_rw_crapepr.vlprejuz,0) - nvl(vr_vlrpagos,0);
        IF vr_vldivida_acum > 0 THEN
          vr_difmespr := trunc(months_between(trunc(pr_rw_crapdat.dtmvtolt, 'mm'),trunc(pr_rw_crapepr.dtprejuz, 'mm'))) + 1;
          
          -- Lan�ar o preju�zo na coluna espec�fica a diferen�a de meses
          -- j� diminuindo o preju�zo os valores pagos somados na vr_vlrpagos
          IF vr_difmespr <= 12 THEN
            vr_vlprjano := nvl(pr_rw_crapepr.vlprejuz,0) - nvl(vr_vlrpagos,0);
          ELSIF vr_difmespr >= 13 AND vr_difmespr <= 48 THEN
            vr_vlprjaan := nvl(pr_rw_crapepr.vlprejuz,0) - nvl(vr_vlrpagos,0);
          ELSE
            vr_vlprjant := nvl(pr_rw_crapepr.vlprejuz,0) - nvl(vr_vlrpagos,0);
          END IF;
          
        END IF; /* END IF vr_vldivida_acum > 0 THEN */
                
        -- Montar a data prevista do ultimo vencimento com base na data do 
        -- primeiro pagamento * qtde de parcelas do empr�stimo
        -- Obs: Quando empr�stimo tiver apenas 1 parcela, a data do 1�
        --      pagamento � tamb�m a data da �ltima. Apenas atentamos
        --      para que esta data n�o fique inferior a data da contrata��o
        --      ent�o usamos um greatest com a dtinictr
        --      Quando tiver mais de 1 parcela, descontamos a parcela 01
        --      para calculo de meses, j� que a mesma j� � cobrada na data
        --      de in�cio do pagamento
        IF pr_rw_crapepr.qtpreemp = 1 THEN
          vr_dtvencop := greatest(pr_rw_crapepr.dtmvtolt,pr_rw_crapepr.dtdpripg);
        ELSE   
          vr_dtvencop := gene0005.fn_dtfun(pr_dtcalcul => pr_rw_crapepr.dtdpripg
                                          ,pr_qtdmeses => pr_rw_crapepr.qtpreemp - 1);
        END IF;        
        -- Incrementar sequencial do contrato
        vr_nrseqctr := vr_nrseqctr + 1;
        
        -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
        pc_grava_crapris(  pr_nrdconta => pr_rw_crapass.nrdconta                             
                          ,pr_dtrefere => vr_dtrefere
                          ,pr_innivris => vr_aux_nivel                 
                          ,pr_qtdiaatr => vr_qtdiaatr
                          ,pr_vldivida => nvl(vr_vldivida_acum,0)                  
                          ,pr_vlvec180 => 0
                          ,pr_vlvec360 => 0
                          ,pr_vlvec999 => 0
                          ,pr_vldiv060 => 0
                          ,pr_vldiv180 => 0
                          ,pr_vldiv360 => 0
                          ,pr_vldiv999 => 0
                          ,pr_vlprjano => nvl(vr_vlprjano,0)                            
                          ,pr_vlprjaan => nvl(vr_vlprjaan,0)
                          ,pr_inpessoa => pr_rw_crapass.inpessoa                             
                          ,pr_nrcpfcgc => pr_rw_crapass.nrcpfcgc 
                          ,pr_vlprjant => nvl(vr_vlprjant,0) 
                          ,pr_inddocto => 1          -- Docto 3020
                          ,pr_cdmodali => vr_cdmodali -- Cfme a linha de cr�dito
                          ,pr_nrctremp => pr_rw_crapepr.nrctremp
                          ,pr_nrseqctr => vr_nrseqctr                     
                          ,pr_dtinictr => pr_rw_crapepr.dtmvtolt                                      
                          ,pr_cdorigem => 3   -- Emprestimos/Financiamentos 
                          ,pr_cdagenci => pr_rw_crapass.cdagenci 
                          ,pr_innivori => 0                     
                          ,pr_cdcooper => pr_cdcooper                      
                          ,pr_vlprjm60 => 0                     
                          ,pr_dtdrisco => NULL                     
                          ,pr_qtdriclq => 0                     
                          ,pr_nrdgrupo => 0                                      
                          ,pr_vljura60 => 0                                      
                          ,pr_inindris => vr_aux_nivel                                      
                          ,pr_cdinfadi => ' '                                    
                          ,pr_nrctrnov => 0                                      
                          ,pr_flgindiv => 0                                    
                          ,pr_dsinfaux => ' '                             
                          ,pr_dtprxpar => NULL                             
                          ,pr_vlprxpar => 0
                          ,pr_qtparcel => pr_rw_crapepr.qtpreemp                         
                          ,pr_dtvencop => vr_dtvencop
                          ,pr_des_erro => vr_des_erro
                          ,pr_index_crapris => vr_index_crapris);
        -- Testar retorno de erro
        IF vr_des_erro IS NOT NULL THEN
          -- Gerar erro e fazer rollback
          vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:' ||
                         pr_rw_crapass.nrdconta || ' Emprestimo: ' ||
                         pr_rw_crapepr.nrctremp || '. Detalhes: ' || vr_des_erro;
          -- Gerar erro e roolback
          RAISE vr_exc_erro;
        END IF;
        
        vr_cdvencto := 0;
        vr_vlsrisco := 0;
        -- Se existir valor prejuizo ano atual
        IF vr_vlprjano > 0 THEN
          -- Utilizar c�digo vencimento 310
          vr_cdvencto := 310;
          vr_vlsrisco := vr_vlprjano;
        ELSIF vr_vlprjaan > 0 THEN
          -- Utilizar c�digo vencimento 320
          vr_cdvencto := 320;
          vr_vlsrisco := vr_vlprjaan;
        -- Se existir valor prejuizo anos anteriores
        ELSIF vr_vlprjant > 0 THEN
          -- Utilizar c�digo vencimento 330
          vr_cdvencto := 330;
          vr_vlsrisco := vr_vlprjant;
        END IF;
        
        IF vr_cdvencto > 0 THEN
          -- Chamar rotina de grava��o dos vencimentos do risco passando este valor
          pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta --> Num. da conta
                          ,pr_dtrefere => vr_dtrefere            --> Data de refer�ncia
                          ,pr_innivris => vr_aux_nivel           --> N�vel do risco
                          ,pr_cdmodali => vr_cdmodali            --> Cfme a linha de cr�dito
                          ,pr_cdvencto => vr_cdvencto            --> Codigo do vencimento
                          ,pr_nrctremp => pr_rw_crapepr.nrctremp --> Nro contrato empr�stimo
                          ,pr_nrseqctr => vr_nrseqctr            --> Seq contrato empr�stimo
                          ,pr_vlsrisco => vr_vlsrisco            --> Valor do risco a lan�ar
                          ,pr_des_erro => vr_des_erro);
                 
          IF vr_des_erro IS NOT NULL THEN
            -- Gerar erro e roolback
            RAISE vr_exc_erro;
          END IF;
            
        END IF; /* END IF vr_cdvencto > 0 THEN */
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pc_lista_emp_prefix_prejuizo --> Erro ao processar emprestimo pre-fixado: '
                      || ' - Conta:' ||pr_rw_crapepr.nrdconta || ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||vr_des_erro;

        WHEN OTHERS THEN
          pr_des_erro := 'pc_lista_emp_prefix_prejuizo --> Erro n�o tratado ao processar emprestimo pre-fixado: '
                      || ' - Conta:'||pr_rw_crapepr.nrdconta|| ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||sqlerrm;
      END;

      -- Varrer e processar emprestimos pos-fixado
      PROCEDURE pc_lista_emp_pos_fixado(pr_rw_crapass   IN cr_crapass%ROWTYPE
                                       ,pr_rw_crapepr   IN cr_crapepr%ROWTYPE
                                       ,pr_risco_rating IN PLS_INTEGER
                                       ,pr_des_erro    OUT VARCHAR2) IS
        -- Variaveis auxiliares
        vr_cdmodali      crapris.cdmodali%TYPE; --> Codigo da modalidade montado cfme a linha de credito
        vr_aux_nivel     PLS_INTEGER;           --> Nivel do risco
        vr_nivel_atraso  PLS_INTEGER;           --> Nivel do risco
        vr_qtdiaatr      crapris.qtdiaatr%TYPE; --> Quantidade de dias em atraso
        vr_vldiv060      crapris.vldiv060%TYPE; --> Valor do atraso quando prazo inferior a 60
        vr_vldiv180      crapris.vldiv180%TYPE; --> Valor do atraso quando prazo inferior a 180
        vr_vldiv360      crapris.vldiv360%TYPE; --> Valor do atraso quando prazo inferior a 360
        vr_vldiv999      crapris.vldiv999%TYPE; --> Valor do atraso para outros casos
        vr_vlvec180      crapris.vlvec180%TYPE; --> Valor a vencer nos proximos 180 dias
        vr_vlvec360      crapris.vlvec360%TYPE; --> Valor a vencer nos proximos 360 dias
        vr_vlvec999      crapris.vlvec999%TYPE; --> Valor a vencer para outros casos
        vr_vldivida_acum NUMBER;                --> Valor da divida acumulada
        vr_totjur60      NUMBER;                --> Total dos juros 60 dias
        vr_nrparepr      NUMBER;                --> Ultima parcela
        vr_dtvencto      crappep.dtvencto%TYPE; --> Data de vencimento
        vr_vlprxpar      crapris.vlprxpar%TYPE; --> Valor da proxima parcela
        vr_dtprxpar      crapris.dtprxpar%TYPE; --> Data da proxima parcela
        vr_vlju60mo      NUMBER(25,2);

        -- Cursor para juros mora em atraso ha mais de 60 dias
        CURSOR cr_craplem_60_mora(pr_qtdiaatr IN NUMBER) IS
          SELECT NVL(SUM(vllanmto),0)
            FROM craplem
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_rw_crapepr.nrdconta
             AND nrctremp = pr_rw_crapepr.nrctremp
             AND cdhistor IN (2347,2346)
             AND dtmvtolt > pr_rw_crapdat.dtmvtolt - (pr_qtdiaatr - 59);
             
        -- Busca da ultima nao liquidada
        CURSOR cr_crappep_ultima IS
          SELECT MAX(nrparepr)
            FROM crappep
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_rw_crapepr.nrdconta
             AND nrctremp = pr_rw_crapepr.nrctremp
             AND inliquid = 0; --> Nao liquidada

        -- Busca de todas as parcelas em aberto
        CURSOR cr_crappep IS
          SELECT nrparepr
                ,dtvencto
                ,vlsdvatu
                ,vljura60
                ,vlparepr
            FROM crappep
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_rw_crapepr.nrdconta
             AND nrctremp = pr_rw_crapepr.nrctremp
             AND inliquid = 0 --> Nao liquidada
        ORDER BY nrparepr;

      BEGIN
        -- Se existe informacao na tabela de linhas de credito cfme a linha do emprestimo
        IF vr_tab_craplcr.EXISTS(pr_rw_crapepr.cdlcremp) THEN
          -- Se for uma operacao de financiamento
          IF vr_tab_craplcr(pr_rw_crapepr.cdlcremp).dsoperac = 'FINANCIAMENTO' THEN
            vr_cdmodali := 0499;
          ELSE
            vr_cdmodali := 0299;
          END IF;
        ELSE
          vr_cdmodali := 0299;
        END IF;

        -- Buscar a parcela com maior atraso
        vr_dtvencto := NULL;
        vr_idxpep := lpad(pr_cdcooper,5,'0')||lpad(pr_rw_crapepr.nrdconta,10,'0')||lpad(pr_rw_crapepr.nrctremp,10,'0');
        IF vr_tab_crappep_maior.exists(vr_idxpep) THEN
          vr_dtvencto := vr_tab_crappep_maior(vr_idxpep);
        END IF;

        -- Se encontrou
        IF vr_dtvencto IS NOT NULL THEN
          -- Calcular a quantidade de dias em atraso
          vr_qtdiaatr := pr_rw_crapdat.dtmvtolt - vr_dtvencto;
          -- Calcular o nivel de acordo com a quantidade de dias em atraso
          CASE
            WHEN vr_qtdiaatr  < 15   THEN
              vr_aux_nivel := 2;
            WHEN vr_qtdiaatr  <= 30   THEN
              vr_aux_nivel := 3;
            WHEN vr_qtdiaatr  <= 60   THEN
              vr_aux_nivel := 4;
            WHEN vr_qtdiaatr  <= 90   THEN
              vr_aux_nivel := 5;
            WHEN vr_qtdiaatr  <= 120   THEN
              vr_aux_nivel := 6;
            WHEN vr_qtdiaatr  <= 150   THEN
              vr_aux_nivel := 7;
            WHEN vr_qtdiaatr  <= 180   THEN
              vr_aux_nivel := 8;
            ELSE
              vr_aux_nivel := 9;
          END CASE;
        ELSE
          -- Sem atraso e risco A
          vr_qtdiaatr  := 0;
          vr_aux_nivel := 2;
        END IF;        

        -- Backup da variavel vr_aux_nivel
        vr_nivel_atraso := vr_aux_nivel;

        -- Vamos verificar qual nivel de risco esta na proposta do emprestimo
        CASE
          WHEN pr_rw_crapepr.dsnivris = ' '  THEN
            vr_aux_nivel := 2;
          WHEN pr_rw_crapepr.dsnivris = 'AA' THEN
            vr_aux_nivel := 1;
          WHEN pr_rw_crapepr.dsnivris = 'A'  THEN
            vr_aux_nivel := 2;
          WHEN pr_rw_crapepr.dsnivris = 'B'  THEN
            vr_aux_nivel := 3;
          WHEN pr_rw_crapepr.dsnivris = 'C'  THEN
            vr_aux_nivel := 4;
          WHEN pr_rw_crapepr.dsnivris = 'D'  THEN
            vr_aux_nivel := 5;
          WHEN pr_rw_crapepr.dsnivris = 'E'  THEN
            vr_aux_nivel := 6;
          WHEN pr_rw_crapepr.dsnivris = 'F'  THEN
            vr_aux_nivel := 7;
          WHEN pr_rw_crapepr.dsnivris = 'G'  THEN
            vr_aux_nivel := 8;  
          ELSE
            vr_aux_nivel := 9;
        END CASE;

        IF pr_risco_rating <> 0 THEN
          -- Verifica o pior Nivel entre o Rating e o Risco da Operacao
          IF pr_risco_rating > vr_aux_nivel THEN
            -- Assumir o n�vel do rating
            vr_aux_nivel := pr_risco_rating;
          END IF;
        END IF;

        -- Se emprestimo tiver nivel maior que o atraso....
        IF vr_nivel_atraso > vr_aux_nivel THEN
          vr_aux_nivel := vr_nivel_atraso;
        END IF;

        -- Calculo dos Juros em atraso a mais de 60 dias
        vr_totjur60 := 0;
        vr_vlju60mo := 0;
        -- Calcular o valor dos juros a mais de 60 dias
        IF vr_qtdiaatr >= 60  THEN
          -- Obter valor de juros mora a mais de 60 dias          
          OPEN  cr_craplem_60_mora (pr_qtdiaatr => vr_qtdiaatr);
          FETCH cr_craplem_60_mora INTO vr_vlju60mo;
          CLOSE cr_craplem_60_mora;
          
          -- Valor Total do Juros60
          vr_totjur60 := NVL(vr_vlju60mo,0);          
          -- Diario
          IF to_char(pr_rw_crapdat.dtmvtolt,'mm') = to_char(pr_rw_crapdat.dtmvtopr,'mm') THEN
            -- Obter valor de juros a mais de 60 dias
            pc_calcula_juros_60d_pos(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_rw_crapepr.nrdconta
                                    ,pr_nrctremp => pr_rw_crapepr.nrctremp
                                    ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                    ,pr_qtdiaatr => vr_qtdiaatr
                                    ,pr_txmensal => pr_rw_crapepr.txmensal
                                    ,pr_qttolatr => pr_rw_crapepr.qttolatr
                                    ,pr_cdlcremp => pr_rw_crapepr.cdlcremp
                                    ,pr_vlemprst => pr_rw_crapepr.vlemprst
                                    ,pr_vlmrapar => vr_totjur60
                                    ,pr_dscritic => vr_des_erro);
            -- Condicao para verificar se houve erro
            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;          
        END IF; 

        -- Montar a data prevista do ultimo vencimento com base na data do 
        -- primeiro pagamento * qtde de parcelas do emprestimo
        -- Obs: Quando emprestimo tiver apenas 1 parcela, a data do 1�
        --      pagamento eh tambem a data da ultima. Apenas atentamos
        --      para que esta data nao fique inferior a data da contratacao
        --      entao usamos um greatest com a dtinictr
        --      Quando tiver mais de 1 parcela, descontamos a parcela 01
        --      para calculo de meses, ja que a mesma ja eh cobrada na data
        --      de inicio do pagamento
        IF pr_rw_crapepr.qtpreemp = 1 THEN
          vr_dtvencop := greatest(pr_rw_crapepr.dtmvtolt,pr_rw_crapepr.dtdpripg);
        ELSE
          vr_dtvencop := gene0005.fn_dtfun(pr_dtcalcul => pr_rw_crapepr.dtdpripg
                                          ,pr_qtdmeses => pr_rw_crapepr.qtpreemp - 1);
        END IF;

        -- Incrementar sequencial do contrato
        vr_nrseqctr := vr_nrseqctr + 1;
        vr_index_crapris_aux := NULL;

        -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
        pc_grava_crapris(pr_nrdconta => pr_rw_crapass.nrdconta
                        ,pr_dtrefere => vr_dtrefere
                        ,pr_innivris => vr_aux_nivel
                        ,pr_qtdiaatr => nvl(vr_qtdiaatr,0)
                        ,pr_vldivida => 0
                        ,pr_vlvec180 => 0
                        ,pr_vlvec360 => 0
                        ,pr_vlvec999 => 0
                        ,pr_vldiv060 => 0
                        ,pr_vldiv180 => 0
                        ,pr_vldiv360 => 0
                        ,pr_vldiv999 => 0
                        ,pr_vlprjano => 0
                        ,pr_vlprjaan => 0
                        ,pr_inpessoa => pr_rw_crapass.inpessoa
                        ,pr_nrcpfcgc => pr_rw_crapass.nrcpfcgc
                        ,pr_vlprjant => 0
                        ,pr_inddocto => 1 -- Docto 3020
                        ,pr_cdmodali => vr_cdmodali -- Cfme a linha de credito
                        ,pr_nrctremp => pr_rw_crapepr.nrctremp
                        ,pr_nrseqctr => vr_nrseqctr
                        ,pr_dtinictr => pr_rw_crapepr.dtmvtolt
                        ,pr_cdorigem => 3 -- Emprestimos/Financiamentos
                        ,pr_cdagenci => pr_rw_crapass.cdagenci
                        ,pr_innivori => 0
                        ,pr_cdcooper => pr_cdcooper
                        ,pr_vlprjm60 => 0
                        ,pr_dtdrisco => NULL
                        ,pr_qtdriclq => 0
                        ,pr_nrdgrupo => 0
                        ,pr_vljura60 => vr_totjur60
                        ,pr_inindris => vr_aux_nivel
                        ,pr_cdinfadi => ' '
                        ,pr_nrctrnov => 0
                        ,pr_flgindiv => 0
                        ,pr_dsinfaux => ' '
                        ,pr_dtprxpar => NULL
                        ,pr_vlprxpar => 0
                        ,pr_qtparcel => pr_rw_crapepr.qtpreemp
                        ,pr_dtvencop => vr_dtvencop
                        ,pr_des_erro => vr_des_erro
                        ,pr_index_crapris => vr_index_crapris_aux);
        -- Caso houve erro
        IF vr_des_erro IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Iniciar valor de juros e das parcelas a vencer e vencidas
        vr_vldiv060 := 0;
        vr_vldiv180 := 0;
        vr_vldiv360 := 0;
        vr_vldiv999 := 0;
        vr_vlvec180 := 0;
        vr_vlvec360 := 0;
        vr_vlvec999 := 0;
        vr_vldivida_acum := 0;

        -- Informacao eh necessaria apenas na mensal 
        IF  to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm')  THEN          
          -- Obter ultima parcela em aberto 
          OPEN  cr_crappep_ultima;        
          FETCH cr_crappep_ultima INTO vr_nrparepr;
          CLOSE cr_crappep_ultima;
        END IF;

        -- Buscar todas as parcelas nao liquidadas
        FOR rw_crappep IN cr_crappep LOOP

          -- Acumular o valor do saldo atual
          vr_vldivida_acum := vr_vldivida_acum + rw_crappep.vlsdvatu;
          -- Saldo devedor atual
          vr_vlsrisco := rw_crappep.vlsdvatu;

          -- Somente na mensal
          IF  to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm')  THEN
            -- Se for a ultima parcela
            IF  rw_crappep.nrparepr = vr_nrparepr  THEN
              IF  pr_rw_crapepr.vlsdeved != vr_vldivida_acum  THEN
                vr_vlsrisco := (pr_rw_crapepr.vlsdeved - vr_vldivida_acum) + rw_crappep.vlsdvatu;
              END IF;
            END IF;
          END IF;

          -- Calcular diferenca de dias entre a parcela e o dia atual
          vr_diasvenc := rw_crappep.dtvencto - pr_rw_crapdat.dtmvtolt;

          -- Buscar o codigo do vencimento a lancar
          vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc
                                            ,pr_qtdiapre => vr_diasvenc -- Enviar a mesma informacao
                                            ,pr_flgempre => TRUE);

          -- Chamar rotina de gravacao dos vencimentos do risco
          pc_grava_crapvri(pr_nrdconta => pr_rw_crapass.nrdconta  --> Num. da conta
                          ,pr_dtrefere => vr_dtrefere             --> Data de referencia
                          ,pr_innivris => vr_aux_nivel            --> N�vel do risco
                          ,pr_cdmodali => vr_cdmodali             --> Cfme a linha de credito
                          ,pr_cdvencto => vr_cdvencto             --> Codigo do vencimento
                          ,pr_nrctremp => pr_rw_crapepr.nrctremp  --> Nro contrato emprestimo
                          ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato emprestimo
                          ,pr_vlsrisco => vr_vlsrisco             --> Valor do risco a lancar
                          ,pr_des_erro => vr_des_erro);
          -- Caso houve erro
          IF vr_des_erro IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Para valores a vencer
          IF vr_diasvenc >= 0 THEN
            -- Se ainda nao achou a primeira parcela em aberto (futuro)
            IF vr_dtprxpar IS NULL AND rw_crappep.dtvencto > pr_rw_crapdat.dtmvtolt THEN
              -- Armazenar valor da proxima parcela
              vr_vlprxpar := rw_crappep.vlparepr;
              vr_dtprxpar := rw_crappep.dtvencto;
            END IF;

            -- Acumular na variavel correspondente de acordo com a quantidade de dias
            IF vr_diasvenc <= 180 THEN
              vr_vlvec180 := vr_vlvec180 + vr_vlsrisco;
            ELSIF vr_diasvenc <= 360 THEN
              vr_vlvec360 := vr_vlvec360 + vr_vlsrisco;
            ELSE
              vr_vlvec999 := vr_vlvec999 + vr_vlsrisco;
            END IF;
          ELSE
            -- Negativar a diferenca de dias pois o valor ja esta vencido e o calculo retornou o valor negativo
            vr_diasvenc := vr_diasvenc * -1;
            -- Acumular na variavel correspondente de acordo com a quantidade de dias
            IF vr_diasvenc <= 60 THEN
              vr_vldiv060 := vr_vldiv060 + vr_vlsrisco;
            ELSIF vr_diasvenc <= 180 THEN
              vr_vldiv180 := vr_vldiv180 + vr_vlsrisco;
            ELSIF vr_diasvenc <= 360 THEN
              vr_vldiv360 := vr_vldiv360 + vr_vlsrisco;
            ELSE
              vr_vldiv999 := vr_vldiv999 + vr_vlsrisco;
            END IF;
          END IF;

        END LOOP; -- cr_crappep

        -- Somente na mensal
        IF  to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm')  THEN
          vr_vldivida_acum := pr_rw_crapepr.vlsdeved;
        END IF;

        -- Apos calcular as parcelas em atraso, atualizar as variaveis de parcelas a vencer e dividas do risco
        vr_tab_crapris(vr_index_crapris_aux).vldiv060 := vr_vldiv060;
        vr_tab_crapris(vr_index_crapris_aux).vldiv180 := vr_vldiv180;
        vr_tab_crapris(vr_index_crapris_aux).vldiv360 := vr_vldiv360;
        vr_tab_crapris(vr_index_crapris_aux).vldiv999 := vr_vldiv999;
        vr_tab_crapris(vr_index_crapris_aux).vlvec180 := vr_vlvec180;
        vr_tab_crapris(vr_index_crapris_aux).vlvec360 := vr_vlvec360;
        vr_tab_crapris(vr_index_crapris_aux).vlvec999 := vr_vlvec999;
        vr_tab_crapris(vr_index_crapris_aux).vldivida := vr_vldivida_acum;
        vr_tab_crapris(vr_index_crapris_aux).vlprxpar := vr_vlprxpar;
        vr_tab_crapris(vr_index_crapris_aux).dtprxpar := vr_dtprxpar;
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pc_lista_emp_pos_fixado --> Erro ao processar emprestimo pos-fixado: '
                      || ' - Conta:' ||pr_rw_crapepr.nrdconta || ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||vr_des_erro;

        WHEN OTHERS THEN
          pr_des_erro := 'pc_lista_emp_pos_fixado --> Erro nao tratado ao processar emprestimo pos-fixado: '
                      || ' - Conta:'||pr_rw_crapepr.nrdconta|| ' Contrato: '||pr_rw_crapepr.nrctremp
                      || '. Detalhes: '||SQLERRM;
      END;

      -- Subrotina para atualiza��o do n�vel do risco na tabela do associado
      PROCEDURE pc_atualiza_risco_crapass(pr_nrdconta IN crapass.nrdconta%TYPE
                                         ,pr_innivris IN crapris.innivris%TYPE
                                         ,pr_des_erro OUT VARCHAR2) IS
        vr_chave_conta PLS_INTEGER;
      BEGIN
        -- Somente atualizar se o programa chamador do processo for o 310
--        IF pr_cdprogra = 'CRPS310' THEN
          -- Se foi passado conta e n�vel 0, quer dizer que � o processo final
          IF pr_nrdconta = 0 AND pr_innivris = 0 THEN
            -- Varremos a tabela de mem�ria e atualiza a conta somente
            -- com o ultimo n�vel gravado na tabela
            vr_chave_conta := vr_tab_assnivel.FIRST;
            LOOP
              EXIT WHEN vr_chave_conta IS NULL;
              -- Atualizar utilizar a tabela de-para de texto do n�vel com base no indice
              UPDATE crapass
                 SET dsnivris = vr_tab_assnivel(vr_chave_conta)
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = vr_chave_conta;
              -- Buscar o pr�ximo
              vr_chave_conta := vr_tab_assnivel.NEXT(vr_chave_conta);
            END LOOP;
          ELSE
            -- Apenas grava o n�vel na tabela (J� convertendo para texto)
            vr_tab_assnivel(pr_nrdconta) := vr_tab_risco_num(pr_innivris);
          END IF;
--        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'pc_atualiza_risco_crapass --> Erro n�o tratado ao atualizar o risco na conta (CRAPASS): '
                      || ' - Conta:'||pr_nrdconta|| ' N�vel Risco: '||pr_innivris
                      || '. Detalhes: '||sqlerrm;
      END;


      -- Controla Controla log
      PROCEDURE pc_controla_log_batch(pr_idtiplog     IN NUMBER       -- Tipo de Log
                                     ,pr_dscritic     IN VARCHAR2) IS -- Descri��o do Log
        vr_dstiplog VARCHAR2 (15);
      BEGIN
        -- Descri��o do tipo de log
        IF pr_idtiplog = 2 THEN
          vr_dstiplog := 'ERRO: ';
        ELSE
          vr_dstiplog := 'PROCESSANDO: ';
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => pr_idtiplog
                                  ,pr_cdprograma   => pr_cdprogra
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || pr_cdprogra || ' --> ' || vr_dstiplog
                                                              || pr_dscritic );     
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
      END pc_controla_log_batch;    

      -- Rotina gerar o arrasto, considerando o Menor Risco - Doctos 3020 e 3030
      PROCEDURE pc_efetua_arrasto(pr_des_erro OUT varchar2) IS

        -- Variaveis auxiliares
        vr_dtdrisco     crapris.dtdrisco%TYPE; -- Data da atualiza��o do risco
        vr_innivori     crapris.innivori%TYPE; -- N�vel original do risco
        vr_innivris     crapris.innivris%TYPE; -- Guardar n�vel do risco mais alto
        vr_innivris_upd crapris.innivris%TYPE; -- Guardar n�vel do risco para update
        vr_dtdrisco_upd crapris.dtdrisco%TYPE; -- Guardar data do risco para update
        vr_cdvencto_upd crapvri.cdvencto%TYPE; -- C�digo do vencimento para atualiza��o
        vr_updatass     PLS_INTEGER:=1;   -- Controlar se deve atualizar Risco no Associado
        vr_dttrfprj     DATE; -- Data prevista para prejuizo M324
        
        -- Busca de todas as contas de limite n�o utilizado
        CURSOR cr_crapris_1901 IS
          SELECT nrdconta
                ,innivris
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = vr_dtrefere
             AND inddocto = 3   
             AND cdmodali = 1901  --> Limite n�o utilizado 
           ORDER BY nrdconta;
        
        -- Busca de todos os riscos agrupando por conta e n�vel
        CURSOR cr_crapris IS
          SELECT nrdconta
                ,innivris
                ,nrctremp
                ,cdmodali
                ,cdorigem
                ,rowid
                ,ROW_NUMBER () OVER (PARTITION BY nrdconta,innivris
                                         ORDER BY nrdconta,innivris,progress_recid) seq_atu
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = vr_dtrefere
             AND inddocto = 1 --> Atual
           ORDER BY nrdconta,innivris,progress_recid;
           
        -- Busca dos dados do ultimo risco Doctos 3020/3030
        CURSOR cr_crapris_last(pr_nrdconta IN crapris.nrdconta%TYPE
                              ,pr_nrctremp IN crapris.nrctremp%TYPE
                              ,pr_cdmodali IN crapris.cdmodali%TYPE
                              ,pr_cdorigem IN crapris.cdorigem%TYPE
		                          ,pr_dtrefere in crapris.dtrefere%TYPE) IS
           -- Ajuste no cursor para tratar data do risco - Daniel(AMcom)
           SELECT r.dtrefere
                , r.innivris
                , r.dtdrisco
            FROM crapris r
           WHERE r.cdcooper = pr_cdcooper
             AND r.nrdconta = pr_nrdconta
             AND r.dtrefere = pr_dtrefere
             AND r.nrctremp = pr_nrctremp
             AND r.cdmodali = pr_cdmodali
             AND r.cdorigem = pr_cdorigem
             AND r.inddocto = 1 -- 3020 e 3030
            -- AND r.innivris < 10
           ORDER BY r.dtrefere DESC --> Retornar o ultimo gravado
                  , r.innivris DESC --> Retornar o ultimo gravado
                  , r.dtdrisco DESC;--> Retornar o ultimo gravado
        rw_crapris_last cr_crapris_last%ROWTYPE;

        -- Comentado cursor original cr_crapris_last Daniel(AMcom)
          /*SELECT dtrefere
                ,innivris
                ,dtdrisco                
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             -- Incluir um periodo de data pois n�o � necessario ler todos os registros
             -- e o mesmo � gerado todo m�s
             AND dtrefere BETWEEN last_day(add_months(vr_dtrefere,-2)) AND (vr_dtrefere -1) --desconsiderar ultimo dia
             AND dtrefere <> pr_dtrefere
             AND inddocto = 1 -- 3020 e 3030
             AND innivris < 10
           ORDER BY dtrefere DESC --> Retornar o ultimo gravado
                   ,innivris DESC --> Retornar o ultimo gravado
                   ,dtdrisco DESC;*/ --> Retornar o ultimo gravado

        -- Busca de todos os riscos Doctos 3020/3030
        -- com valor superior ao de arrasto e data igual a de refer�ncia
        -- retornando dentro da conta os riscos com n�vel mais elevado primeiro
        CURSOR cr_crapris_ord IS
          SELECT nrdconta
                ,nrcpfcgc
                ,innivris
                ,dtrefere
                ,innivori
                ,cdmodali
                ,cdorigem
                ,nrctremp
                ,nrseqctr
                ,dtdrisco
                ,inddocto
                ,vldivida
                ,qtdiaatr
                ,rowid
                ,ROW_NUMBER () OVER (PARTITION BY nrdconta
                                         ORDER BY nrdconta,innivris DESC) sequencia
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = vr_dtrefere
             AND inddocto = 1 --> 3020 
            -- AND vldivida > pr_vlarrasto --> Valor dos par�metros
             --AND innivris < 10 Tiago
           ORDER BY nrdconta
                   ,innivris DESC;

        -- Busca de todos os vencimentos do risco atual
        CURSOR cr_crapvri_ord(pr_nrdconta IN crapris.nrdconta%TYPE
                             ,pr_dtrefere IN crapris.dtrefere%TYPE
                             ,pr_innivori IN crapris.innivori%TYPE
                             ,pr_cdmodali IN crapris.cdmodali%TYPE
                             ,pr_nrctremp IN crapris.nrctremp%TYPE
                             ,pr_nrseqctr IN crapris.nrseqctr%TYPE) IS
          SELECT rowid
                ,cdvencto
                ,innivris
                ,vldivida
            FROM crapvri
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND dtrefere = pr_dtrefere
             AND innivris = pr_innivori
             AND cdmodali = pr_cdmodali
             AND nrctremp = pr_nrctremp
             AND nrseqctr = pr_nrseqctr;

        -- Buscar todos os riscos de empr�stimos ou financiamentos
        CURSOR cr_crapris_epr IS
          SELECT nrdconta
                ,nrctremp
                ,innivris
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = vr_dtrefere
             AND inddocto = 1
             AND cdorigem = 3
             AND cdmodali IN(0299,0499); -- Contratos de Emprestimo/Financiamento
        
        -- Auxiliar para busca da data
        vr_datautil DATE;
        vr_qtdrisco INTEGER:=0;
        
      BEGIN        
  
        -- Fun��o para retornar dia �til anterior a data base
        vr_datautil  := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,                -- Cooperativa
                                                    pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt - 1, -- Data de referencia
                                                    pr_tipo      => 'A',                        -- Se n�o for dia �til, retorna primeiro dia �til anterior
                                                    pr_feriado   => TRUE,                       -- Considerar feriados,
                                                    pr_excultdia => TRUE);                      -- Considerar 31/12
        

        -- Este tratamento esta sendo efetuado como solu��o para
        -- a situa��o do plsql n�o ter como efetuar comparativo <> NULL 
        IF to_char(vr_datautil,'MM') <> to_char(pr_rw_crapdat.dtmvtolt,'MM') THEN  
          vr_datautil := to_date('31/12/9999','DD/MM/RRRR');
        END IF;  
              
        -- Buscamos todos os contratos de limite n�o utilizado
        FOR rw_crapris IN cr_crapris_1901 LOOP
          -- Apenas atualizamos o n�vel na crapass, pois contas que nunca estiveram na 
          -- central de riscoe possuem apenas Limite N�o Utilizado, ficavam sem n�vel de risco
          pc_atualiza_risco_crapass(pr_nrdconta => rw_crapris.nrdconta
                                   ,pr_innivris => rw_crapris.innivris
                                   ,pr_des_erro => vr_des_erro);
          -- Se retornou erro
          IF vr_des_erro IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END LOOP;
        

/*
        -- Busca de todos os riscos
        FOR rw_crapris IN cr_crapris LOOP
          -- Somente no primeiro registro
          IF rw_crapris.seq_atu = 1 THEN
            -- Armazenar o n�vel original
            vr_innivori := rw_crapris.innivris;
            vr_innivris := rw_crapris.innivris;
            -- Condicao para verificar se a conta possui risco soberano
            IF vr_tab_contas_risco_soberano.EXISTS(rw_crapris.nrdconta) THEN
              IF vr_tab_contas_risco_soberano(rw_crapris.nrdconta).innivris > vr_innivris THEN
                vr_innivris := vr_tab_contas_risco_soberano(rw_crapris.nrdconta).innivris;
              END IF;
            END IF;

            -- Regra para carga de data para o cursor
            -- Se for rotina mensal - Daniel(AMcom)
            IF to_char(pr_rw_crapdat.dtmvtoan, 'MM') <> to_char(pr_rw_crapdat.dtmvtolt, 'MM') THEN
              -- Utilizar o final do m�s como data
              vr_dtrefere_aux := pr_rw_crapdat.dtultdma;
            ELSE
              -- Utilizar a data atual
              vr_dtrefere_aux := pr_rw_crapdat.dtmvtoan;
            END IF;

            -- Busca dos dados do ultimo risco de origem 1
            OPEN cr_crapris_last(pr_nrdconta => rw_crapris.nrdconta
                                ,pr_nrctremp => rw_crapris.nrctremp
                                ,pr_cdmodali => rw_crapris.cdmodali
                                ,pr_cdorigem => rw_crapris.cdorigem
                                ,pr_dtrefere => vr_dtrefere_aux); --Daniel(AMcom)
                                --,pr_dtrefere => vr_datautil);
            FETCH cr_crapris_last
             INTO rw_crapris_last;
            -- Se encontrou
            IF cr_crapris_last%FOUND THEN
              -- Se a data de ref�ncia � diferente do ultimo dia do m�s anterior
              -- OU o n�vel deste registro � diferente do n�vel do risco no cursor principal
              --    e o n�vel do risco principal seja diferente de HH(10)
              -- ATENCAO: caso seja alterada esta regra, ajustar em crps635_i tb
--              IF rw_crapris_last.dtrefere <> pr_rw_crapdat.dtultdma
--              OR (rw_crapris_last.innivris <> vr_innivris AND vr_innivris <> 10) THEN
                -- Utilizar a data de refer�ncia do processo
                vr_dtdrisco := vr_dtrefere;
              ELSE
                -- Utilizar a data do ultimo risco
                IF rw_crapris_last.dtdrisco IS NULL THEN
                vr_dtdrisco := vr_dtrefere;
              ELSE
                -- Utilizar a data do ultimo risco
                vr_dtdrisco := rw_crapris_last.dtdrisco;
              END IF;
              END IF;
            ELSE
              -- Utilizar a data de refer�ncia do processo
              vr_dtdrisco := vr_dtrefere;
            END IF;
            -- Fechar o cursor
            CLOSE cr_crapris_last;
          END IF;




          -- Atualiza a data do risco e n�vel anterior
          -- para todos os registros encontrados
          BEGIN
            UPDATE crapris
               SET innivori = vr_innivori
              --    ,dtdrisco = vr_dtdrisco
             WHERE rowid = rw_crapris.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao atualizar a data e n�vel anterior do risco --> '
                          || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                          || '. Detalhes:'||sqlerrm;
              RAISE vr_exc_erro;
          END;
          -- Atualizar todos os registros na crapass
          pc_atualiza_risco_crapass(pr_nrdconta => rw_crapris.nrdconta
                                   ,pr_innivris => rw_crapris.innivris
                                   ,pr_des_erro => vr_des_erro);
          -- Se retornou erro
          IF vr_des_erro IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END LOOP;*/
        
        /*
        O BLOCO ACIMA PERCORRIDA TODOS OS REGISTROS DA
        CRAPRIS APENAS PARA ATUALIZAR O INNIVORI.
        ESSA ATUALIZACAO FOI TRATADA DENTRO DO BLOCO
        ABAIXO JA EXISTENTE
        */
        
        
        
        
        -- Busca de todos os riscos Doctos 3020/3030
        -- com valor superior ao de arrasto e data igual a de refer�ncia
        -- retornando dentro da conta os riscos com n�vel mais elevado primeiro
        FOR rw_crapris IN cr_crapris_ord LOOP         

          vr_innivori := rw_crapris.innivris;

          -- ATENCAO: FOI RETIRADO CONDICIONAL DE MATERIALIDADE DO 
          -- CURSOR PRINCIPAL cr_crapris_ord, DESTA FORMA, A MATERIALIDADE
          -- PASSOU A SER TRATADA DENTRO DO BLOCO.
          
          -- O TRATAMENTO PARA INNIVRIS -1 � APENAS PARA N�O TRATAR
          -- MAIOR RISCO QUANDO ESSE RISCO FOR UM VALOR MENOR QUE MATERIALIDADE
          
          -- QUANDO MENOR QUE A MATERIALIDADE NAO ARRASTA O
          -- RISCO E TAMB�M N�O � ARRASTADO.

          -- Para o primeiro registro da conta
          IF rw_crapris.sequencia = 1
          OR vr_innivris = -1 THEN

            -- Zerar variaveis controle
          IF rw_crapris.sequencia = 1 THEN
              vr_updatass := 1;                        
            END IF;

            vr_innivris := -1;
            vr_qtdrisco := 0;

            IF rw_crapris.vldivida > pr_vlarrasto THEN
            vr_dtdrisco := rw_crapris.dtdrisco;
            -- Armazenar a data e n�vel deste risco, pois � o mais elevado
            vr_innivris := rw_crapris.innivris;
  
            -- Condicao para verificar se a conta possui risco soberano
            IF vr_tab_contas_risco_soberano.EXISTS(rw_crapris.nrdconta) THEN

              IF vr_tab_contas_risco_soberano(rw_crapris.nrdconta).innivris > vr_innivris THEN
                vr_innivris := vr_tab_contas_risco_soberano(rw_crapris.nrdconta).innivris;
                  vr_dtdrisco := vr_dtrefere;
                END IF;
              END IF;
              -- Usado para controlar a atualiza��o do ASS
              vr_qtdrisco := 1;
                          
            END IF;
          END IF;


          -- Se o n�vel mais elevado for HH e o n�vel atual n�o for
          IF vr_innivris = 10 AND rw_crapris.innivris <> 10 THEN
            -- Nao jogar p/prejuizo, prov.100
            vr_innivris_upd := 9;
          ELSE
            -- Usar n�vel do mais elevado
            vr_innivris_upd := vr_innivris;
          END IF;
          
          -- Atualizar a data com a data do mais elevado
          --vr_dtdrisco_upd := vr_dtdrisco;
          -- Efetuar atualiza��o do risco em processo cfme os valores encontrados acima


          /*************************/
          -- Regra para carga de data para o cursor
          -- Se for rotina mensal - Daniel(AMcom)
          IF to_char(pr_rw_crapdat.dtmvtoan, 'MM') <> to_char(pr_rw_crapdat.dtmvtolt, 'MM') THEN
            -- Utilizar o final do m�s como data
            vr_dtrefere_aux := pr_rw_crapdat.dtultdma;
          ELSE
            -- Utilizar a data atual
            vr_dtrefere_aux := pr_rw_crapdat.dtmvtoan;
          END IF;

          -- Busca dos dados do ultimo risco de origem 1
          OPEN cr_crapris_last(pr_nrdconta => rw_crapris.nrdconta
                              ,pr_nrctremp => rw_crapris.nrctremp
                              ,pr_cdmodali => rw_crapris.cdmodali
                              ,pr_cdorigem => rw_crapris.cdorigem
                              ,pr_dtrefere => vr_dtrefere_aux); 
          FETCH cr_crapris_last
           INTO rw_crapris_last;
          -- Se encontrou
          IF cr_crapris_last%FOUND THEN
            -- ATENCAO: caso seja alterada esta regra, ajustar em crps635_i tb
            -- O RISCO ANTERIOR � DIFERENTE DO RISCO PRA ONDE ELE SER� ALTERADO?
            IF (rw_crapris_last.innivris <> vr_innivris_upd)
            AND vr_innivris_upd <> -1 THEN
              -- Utilizar a data de refer�ncia do processo
                vr_dtdrisco_upd := vr_dtrefere;
            ELSE
              -- Utilizar a data do ultimo risco
              IF rw_crapris_last.dtdrisco IS NULL THEN
                vr_dtdrisco_upd := vr_dtrefere;
              ELSE
                -- Utilizar a data do ultimo risco
                vr_dtdrisco_upd := rw_crapris_last.dtdrisco;
              END IF;
            END IF;
          ELSE
            -- Utilizar a data de refer�ncia do processo
            vr_dtdrisco_upd := vr_dtrefere;
          END IF;
          -- Fechar o cursor
          CLOSE cr_crapris_last;
          /*************************/


          -- APENAS MENOR QUE MATERIALIDADE
          IF rw_crapris.vldivida <= pr_vlarrasto THEN
            -- O RISCO ATUAL � DIFERENTE DO RISCO PARA O QUAL ELE VAI?
            IF rw_crapris.innivori <> vr_innivori   THEN
              -- SE SIM, MUDA DATA DO RISCO
              vr_dtdrisco_upd := vr_dtrefere;
            END IF;
          -- M324
          vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                               vr_innivori,
                                                               rw_crapris.qtdiaatr,
                                                               vr_dtdrisco_upd);            
          BEGIN
              UPDATE crapris
                 SET innivori = vr_innivori
                    ,dtdrisco = vr_dtdrisco_upd
                    ,dttrfprj = vr_dttrfprj
               WHERE rowid = rw_crapris.rowid;

            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'Erro ao atualizar n�vel anterior do risco --> '
                            || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                            || '. Detalhes:'||sqlerrm;
                RAISE vr_exc_erro;
            END;
            
            -- SO LEVA PARA O ASSOCIADO QUANDO NAO HOUVER
            -- NENHUM OUTRO RISCO MAIOR QUE MATERIALIDADE
            IF vr_updatass = 1 THEN
            
            -- Atualizar o n�vel na conta
            pc_atualiza_risco_crapass(pr_nrdconta => rw_crapris.nrdconta
                                       ,pr_innivris => vr_innivori --rw_crapris.innivris
                                     ,pr_des_erro => vr_des_erro);
            -- Se retornou erro
            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            END IF;

            CONTINUE;
          END IF;


          -- APENAS PARA CONTRATOS COM DIVIDA MAIOR QUE MATERIALIDADE
          BEGIN
            IF vr_innivris_upd = -1 THEN
               vr_des_erro := 'ERRO DE ATUALIZACAO RISCO -1';
              RAISE vr_exc_erro;
            END IF;
            -- 
            vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                                 vr_innivris_upd,
                                                                 rw_crapris.qtdiaatr,
                                                                 vr_dtdrisco_upd);          
          
            UPDATE crapris
               SET innivris = vr_innivris_upd
                  ,inindris = vr_innivris_upd
                  ,innivori = vr_innivori
                  ,dtdrisco = vr_dtdrisco_upd
                  ,dttrfprj = vr_dttrfprj
             WHERE rowid = rw_crapris.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao atualizar a data e n�vel com base no risco mais elevado --> '
                          || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                          || '. Detalhes:'||sqlerrm;
              RAISE vr_exc_erro;
          END;



        -- Novamente somente para o primeiro risco da conta/Primeiro � o maior
          IF vr_qtdrisco = 1 THEN

            -- SE ENTROU, ATUALIZOU ASS APENAS 1 VEZ E NAO ATUALIZA MAIS
            vr_updatass := 0;
            vr_qtdrisco := 0;
            -- Atualizar o n�vel na conta
            pc_atualiza_risco_crapass(pr_nrdconta => rw_crapris.nrdconta
                                     ,pr_innivris => vr_innivris_upd
                                     ,pr_des_erro => vr_des_erro);
            -- Se retornou erro
            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Limpar tabela temporaria Vencimentos de risco
          vr_tab_crapvri_2.DELETE;
          -- Busca de todos os vencimentos do risco atual
          FOR rw_crapvri IN cr_crapvri_ord(pr_nrdconta => rw_crapris.nrdconta
                                          ,pr_dtrefere => rw_crapris.dtrefere
                                          ,pr_innivori => vr_innivori
                                          ,pr_cdmodali => rw_crapris.cdmodali
                                          ,pr_nrctremp => rw_crapris.nrctremp
                                          ,pr_nrseqctr => rw_crapris.nrseqctr) LOOP
            -- Se o prejuizo risco for HH E o do VctoRisco n�o for
            -- E o c�digo do vencimento for n�o for 310(Prejuizo 12 meses),
            -- 320(Prejuizo +12M ate 48M) ou 330(Prejuizo +48M ate 60M)
            IF vr_innivris_upd = 10 AND rw_crapvri.innivris <> 10 AND rw_crapvri.cdvencto NOT IN(310,320,330) THEN
              -- Se o vencimento for a vencer nos pr�ximox 360 dias (<=150)
              -- ou Vencidos ha 360 dias (>=205 e <=270)
              IF rw_crapvri.cdvencto <= 150 OR (rw_crapvri.cdvencto >= 205 AND rw_crapvri.cdvencto <= 270) THEN
                -- Utilizar novo vencimento como 310 - Prej. 12 meses
                vr_cdvencto_upd := 320;
              -- Sen�o se vencer maior que 360 dias (>=160 e <=170)
              -- ou Vencidos h� mais de 360 dias ( =280)
              ELSIF (rw_crapvri.cdvencto >= 160 AND rw_crapvri.cdvencto <= 170) OR rw_crapvri.cdvencto = 280 THEN
                -- Utilizar novo vencimento como 320 - Prej. +12M ate 48m
                vr_cdvencto_upd := 320;
              ELSE
                -- Usar vencimento 330 - Prej. +48M
                vr_cdvencto_upd := 330;
              END IF;
              -- Enviar as informa��es para o XML do relat�rio 349
              pc_escreve_xml('<preju>'
                           ||'  <nrdconta>'||LTRIM(gene0002.fn_mask_conta(rw_crapris.nrdconta))||'</nrdconta>'
                           ||'  <cdmodali>'||rw_crapris.cdmodali||'</cdmodali>'
                           ||'  <nrctremp>'||LTRIM(gene0002.fn_mask(rw_crapris.nrctremp,'zz.zzz.zz9'))||'</nrctremp>'
                           ||'  <innivori>'||rw_crapris.innivori||'</innivori>'
                           ||'  <innivris>'||vr_innivris_upd||'</innivris>'
                           ||'  <cdvencor>'||rw_crapvri.cdvencto||'</cdvencor>'
                           ||'  <cdvencnv>'||vr_cdvencto_upd||'</cdvencnv>'
                           ||'  <vldivida>'||to_char(rw_crapvri.vldivida,'fm999g999g990d00')||'</vldivida>'
                           ||'</preju>');
            ELSE
              -- Utilizar o vencimento atual, ou seja, n�o ser� alterado
              vr_cdvencto_upd := rw_crapvri.cdvencto;
            END IF;
            -- Atualizar o n�vel do vcto cfme o n�vel do risco e tamb�m
            -- o c�digo do vencimento conforme a l�gica de busca acima
            vr_index_crapvri:= vr_tab_crapvri_2.count+1;
            vr_tab_crapvri_2(vr_index_crapvri).cdvencto:= vr_cdvencto_upd;
            vr_tab_crapvri_2(vr_index_crapvri).innivris:= vr_innivris_upd;
            vr_tab_crapvri_2(vr_index_crapvri).vr_rowid:= rw_crapvri.rowid;

          END LOOP; -- Fim vctos
          
          --Atualizar vencimento risco
          BEGIN
            FORALL idx IN 1..vr_tab_crapvri_2.count SAVE EXCEPTIONS
              UPDATE crapvri
                 SET cdvencto = vr_tab_crapvri_2(idx).cdvencto
                    ,innivris = vr_tab_crapvri_2(idx).innivris
               WHERE rowid = vr_tab_crapvri_2(idx).vr_rowid; 
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao atualizar o codigo e nivel do vencimento com base no risco --> '
                            || '. Detalhes:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
                RAISE vr_exc_erro;
          END;      
        END LOOP; -- Fim riscos
        vr_tab_crapvri_2.delete;
        
        -- Ap�s processar todos os registros, efetuar o update na tabela crapass
        pc_atualiza_risco_crapass(pr_nrdconta => 0 --> Condi��o final para grava��o na tabela
                                 ,pr_innivris => 0 --> Condi��o final para grava��o na tabela
                                 ,pr_des_erro => vr_des_erro);
        -- Se retornou erro
        IF vr_des_erro IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Buscar todos os riscos de empr�stimos ou financiamentos
        FOR rw_crapris IN cr_crapris_epr LOOP
          -- Atualizar todos os complementos do cadastro do
          -- empr�stimo vinculado ao risco atual
          BEGIN
            vr_idx_crawepr_up := vr_tab_crawepr_up.count + 1; 
            vr_tab_crawepr_up(vr_idx_crawepr_up).cdcooper := pr_cdcooper; 
            vr_tab_crawepr_up(vr_idx_crawepr_up).nrdconta := rw_crapris.nrdconta;
            vr_tab_crawepr_up(vr_idx_crawepr_up).nrctremp := rw_crapris.nrctremp;
            vr_tab_crawepr_up(vr_idx_crawepr_up).dsnivcal := vr_tab_risco_num(rw_crapris.innivris);
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao atualizar o n�vel do emprestimo com base no risco --> '
                          || 'Conta: '||rw_crapris.nrdconta||', Empr�stimos: '||rw_crapris.nrctremp
                          || '. Detalhes:'||sqlerrm;
              RAISE vr_exc_erro;
          END;
          
        END LOOP;
        
        --Atualizar vencimento risco
        BEGIN
          FORALL idx IN 1..vr_tab_crawepr_up.count SAVE EXCEPTIONS                         
             UPDATE crawepr
               SET dsnivcal = vr_tab_crawepr_up(idx).dsnivcal
             WHERE cdcooper = vr_tab_crawepr_up(idx).cdcooper
               AND nrdconta = vr_tab_crawepr_up(idx).nrdconta
               AND nrctremp = vr_tab_crawepr_up(idx).nrctremp;
             
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Erro ao atualizar o n�vel do emprestimo com base no risco --> '
                          || '. Detalhes:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
              RAISE vr_exc_erro;
        END; 
        vr_tab_crawepr_up.delete;
        
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pc_efetua_arrasto --> Erro ao processar arrasto. Detalhes: '||vr_des_erro;
        WHEN OTHERS THEN
          pr_des_erro := 'pc_efetua_arrasto --> Erro n�o tratado ao processar arrasto. Detalhes: '||sqlerrm;
      END;

      


      PROCEDURE pc_popula_ass_arrasto(pr_cpfcnpj  IN VARCHAR2
                                     ,pr_inpessoa IN INTEGER
                                     ,pr_innivris IN INTEGER
                                     ,pr_des_erro OUT VARCHAR2) IS
      
        -- BUSCA TODAS AS CONTAS DE UM CNPJ RAIZ
        CURSOR cr_cpfcnpj IS
          SELECT ass.nrdconta, ass.nrcpfcgc
            FROM crapass ass
           WHERE ass.cdcooper = pr_cdcooper
             AND ((pr_inpessoa = 1 AND ass.nrcpfcgc  = to_number(pr_cpfcnpj)) Or
                  (pr_inpessoa = 2 AND ass.nrcpfcgc >= to_number(pr_cpfcnpj||'000000') 
                                   AND ass.nrcpfcgc <= to_number(pr_cpfcnpj||'999999')) );
      
      BEGIN  
        
        -- SE PF, POPULA DIRETO O CPF COM O RISCO (n�o ha variacoes de cpf)
        IF pr_inpessoa = 1 THEN
           --se for maior que ao ja existente, atualiza.
           IF vr_tab_ass_cpfcnpj.exists(pr_cpfcnpj) THEN
             IF pr_innivris > vr_tab_risco(vr_tab_ass_cpfcnpj(pr_cpfcnpj)) THEN
           vr_tab_ass_cpfcnpj(pr_cpfcnpj) := vr_tab_risco_num(pr_innivris);
             END IF;
        ELSE
             vr_tab_ass_cpfcnpj(pr_cpfcnpj) := vr_tab_risco_num(pr_innivris);
           END IF;
        ELSE
          -- SE FOR JURIDICA, PEGA TODAS AS CONTAS DO CNPJ RAIZ(8digitos)
          FOR rw_cpfcnpj IN cr_cpfcnpj LOOP
            IF vr_tab_ass_cpfcnpj.exists(rw_cpfcnpj.nrcpfcgc) THEN
              --se for maior que ao ja existente, atualiza.
              IF pr_innivris > vr_tab_risco(vr_tab_ass_cpfcnpj(rw_cpfcnpj.nrcpfcgc)) THEN
            vr_tab_ass_cpfcnpj(rw_cpfcnpj.nrcpfcgc) := vr_tab_risco_num(pr_innivris);
              END IF;
            ELSE
              vr_tab_ass_cpfcnpj(rw_cpfcnpj.nrcpfcgc) := vr_tab_risco_num(pr_innivris);              
            END IF;
          END LOOP;
        END IF;
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pc_popula_ass_arrasto --> Erro ao popular arrasto associado.'
                       ||' PARAM: CPF/CNPJ: ' || pr_cpfcnpj || ' RISCO: ' || pr_innivris                        
                       ||' Detalhes: '||vr_des_erro;
        WHEN OTHERS THEN
          pr_des_erro := 'pc_popula_ass_arrasto --> Erro n�o tratado ao popular arrasto associado.'
                       ||' PARAM: CPF/CNPJ: ' || pr_cpfcnpj || ' RISCO: ' || pr_innivris
                       ||' Detalhes: '||sqlerrm;
      END;
      
      -- Rotina gerar o arrasto para CPF/CNPJ
      PROCEDURE pc_efetua_arrasto_cpfcnpj(pr_des_erro OUT VARCHAR2) IS

        -- Variaveis auxiliares
        vr_dsmsgerr     VARCHAR2(200);
        vr_chave_ass    VARCHAR2(14);
        vr_chave_assris INTEGER;
        vr_maxrisco     INTEGER:=-10;
        vr_maxrisco_tmp INTEGER:=-10;
        vr_dttrfprj     DATE;


        -- LISTAR APENAS CPF/CNPJ(RAIZ) COM MAIS DE UMA CONTA (caso contr�rio, n�o precisa de arrasto)
        CURSOR cr_cpfcnpj_contas IS
          SELECT * FROM (
          SELECT tmp.cpf_cnpj
                ,COUNT(cpf_cnpj)   QTD_CTA
                ,MAX(inpessoa)     inpessoa
                ,MAX(tmp.dsnivris) dsnivris
            FROM (SELECT ass.nrcpfcgc
                        ,ass.nrdconta
                        ,ass.inpessoa
                        ,NVL(REPLACE(ass.dsnivris,' '),'A') dsnivris
                        ,DECODE(ass.inpessoa
                                       ,1,to_char(ass.nrcpfcgc,'FM00000000000')
                                         ,SUBSTR(to_char(ass.nrcpfcgc,'FM00000000000000')
                                              ,1,8) )   CPF_CNPJ -- Agrupar pela raiz do CNPJ
                    FROM crapass ass
                   WHERE ass.cdcooper = pr_cdcooper
                   ) tmp
           GROUP BY tmp.cpf_cnpj
          HAVING COUNT(cpf_cnpj) > 1) x ;

        -- Percorrer Associados daquele CPF ou CNPJ Raiz
        CURSOR cr_crapass(pr_cdcooper NUMBER,
                          pr_cpf_cnpj NUMBER) IS
          SELECT ass.nrdconta
            FROM crapass ass
           WHERE ass.cdcooper = pr_cdcooper
             AND ((ass.inpessoa = 1 AND ass.nrcpfcgc  = to_number(pr_cpf_cnpj)) OR
                  (ass.inpessoa = 2 AND ass.nrcpfcgc >= to_number(pr_cpf_cnpj||'000000')
                                    AND ass.nrcpfcgc <= to_number(pr_cpf_cnpj||'999999')) );   


        -- Busca maior risco do CPF e CNPJ(ra�z) - COM BASE NA CENTRAL DE RISCO
        CURSOR cr_max_risco_cpfcnpj(pr_nrdconta IN NUMBER
                                   ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
          SELECT *
            FROM (SELECT ris.innivris   Maior_risco
                    FROM crapris ris
                   WHERE ris.cdcooper = pr_cdcooper
                     AND ris.dtrefere = pr_dtrefere
                     AND ris.inddocto = 1
                     AND ris.vldivida > pr_vlarrasto --> Valor dos par�metros
                     AND ris.nrdconta = pr_nrdconta
                   ORDER BY ris.innivris DESC)
             WHERE ROWNUM = 1;
        rw_max_risco_cpfcnpj cr_max_risco_cpfcnpj%ROWTYPE;
           


        -- Busca todos os riscos que dever�o ser arrastados
        -- � passado apenas a ra�z do cnpj, por isso a fun��o
        CURSOR cr_riscos_cpfcnpj( pr_nrdconta IN crapass.nrdconta%TYPE
                                 ,pr_innivris IN crapris.innivris%TYPE) IS
          SELECT  ris.nrdconta
                 ,ris.innivris
                 ,ris.dtdrisco
                 ,ris.nrcpfcgc
                 -- CDCOOPER, DTREFERE, NRDCONTA, INNIVRIS, CDMODALI, NRCTREMP, NRSEQCTR, CDVENCTO
                 ,ris.cdmodali
                 ,ris.nrctremp
                 ,ris.nrseqctr
                 ,ris.qtdiaatr
                 ,rowid
                 ,ROW_NUMBER () OVER (PARTITION BY ris.nrdconta
                                          ORDER BY ris.nrcpfcgc,ris.nrdconta) SEQ_CTA
            FROM crapris ris
           WHERE ris.cdcooper = pr_cdcooper
             AND ris.nrdconta = pr_nrdconta
             AND ris.dtrefere = vr_dtrefere
             AND ris.inddocto = 1
             AND ris.vldivida > pr_vlarrasto --> Valor dos par�metros
             AND (ris.innivris < pr_innivris);

      BEGIN

        vr_tab_ass_cpfcnpj.delete;

        -- PERCORRER TODOS OS CPF/CNPJ(RAIZ) COM MAIS DE UMA CONTA - ARRASTO
        FOR rw_cpfcnpj_contas IN cr_cpfcnpj_contas LOOP

          vr_maxrisco_tmp := -10;
          vr_maxrisco     := -10;
          vr_tab_ass_ris.delete;

          FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper,
                                       pr_cpf_cnpj => rw_cpfcnpj_contas.cpf_cnpj ) LOOP

            -- RETORNA O MAIOR RISCO DO CPF/CNPJ RAIZ COM BASE NA CENTRAL DE RISCO DO DIA
            OPEN cr_max_risco_cpfcnpj(pr_nrdconta => rw_crapass.nrdconta
                                   ,pr_dtrefere => vr_dtrefere);
          FETCH cr_max_risco_cpfcnpj INTO rw_max_risco_cpfcnpj;

          IF cr_max_risco_cpfcnpj%NOTFOUND THEN
            CLOSE cr_max_risco_cpfcnpj;
                -- Se n�o encontrou central para o dia, Assume risco 2(A)
              vr_maxrisco_tmp := 2;

          ELSE
              vr_maxrisco_tmp := rw_max_risco_cpfcnpj.maior_risco;
              CLOSE cr_max_risco_cpfcnpj;          
          END IF;


            --> caso o encontrado for maior que o ja encontrado
            IF vr_maxrisco_tmp > vr_maxrisco THEN
              vr_maxrisco := vr_maxrisco_tmp;
            END IF;

            vr_tab_ass_ris(rw_crapass.nrdconta).cdcooper := pr_cdcooper;
            vr_tab_ass_ris(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
            vr_tab_ass_ris(rw_crapass.nrdconta).inpessoa := rw_cpfcnpj_contas.inpessoa;

          END LOOP;

          -- NAO LEVA PARA O PREJUIZO          
          IF vr_maxrisco = 10 THEN
            vr_maxrisco := 9;
          END IF;
          

          pc_popula_ass_arrasto(rw_cpfcnpj_contas.cpf_cnpj
                               ,rw_cpfcnpj_contas.inpessoa
                               ,vr_maxrisco
                               ,pr_des_erro => vr_des_erro);
          -- Se retornou derro
          IF vr_des_erro IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- PERCORRER TODAS AS CONTAS QUE PRECISAM SER AJUSTADAS
          vr_chave_assris := vr_tab_ass_ris.FIRST;
          LOOP
            EXIT WHEN vr_chave_assris IS NULL;

            --vr_tab_ass_cpfcnpj(vr_chave_assris)
          -- PERCORRER TODOS CONTRATOS DA RIS  
            FOR rw_riscos_cpfcnpj IN cr_riscos_cpfcnpj( pr_nrdconta => vr_chave_assris
                                                     ,pr_innivris => vr_maxrisco) LOOP
              -- M324
              vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                                   vr_maxrisco,
                                                                   rw_riscos_cpfcnpj.qtdiaatr,
                                                                   vr_dtrefere);
            -- Efetuar atualiza��o da CENTRAL RISCO cfme os valores maior risco
            BEGIN

              UPDATE crapris
                 SET innivris = vr_maxrisco
                    ,inindris = vr_maxrisco
                    ,dtdrisco = vr_dtrefere
                    ,dttrfprj = vr_dttrfprj
               WHERE rowid = rw_riscos_cpfcnpj.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'pc_efetua_arrasto_cpfcnpj - '
                            || 'Erro ao atualizar a data e Risco com base no risco mais elevado --> '
                            || 'Conta: '    ||rw_riscos_cpfcnpj.nrdconta
                            ||', Rowid: '   ||rw_riscos_cpfcnpj.rowid
                            || '. Detalhes:'||sqlerrm;
                RAISE vr_exc_erro;
            END;
            

            -- ATUALIZAR VENCIMENTOS RISCO COM BASE NO MAIOR RISCO
            BEGIN

              UPDATE crapvri
                 SET innivris = vr_maxrisco
               WHERE cdcooper = pr_cdcooper
                 AND dtrefere = vr_dtrefere
                 AND nrdconta = rw_riscos_cpfcnpj.nrdconta
                 AND cdmodali = rw_riscos_cpfcnpj.cdmodali
                 AND nrctremp = rw_riscos_cpfcnpj.nrctremp
                 AND nrseqctr = rw_riscos_cpfcnpj.nrseqctr;
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'pc_efetua_arrasto_cpfcnpj - '
                            || 'Erro ao atualizar Vencimentos Risco com base no risco mais elevado --> '
                            || 'Conta: '||rw_riscos_cpfcnpj.nrdconta
                            ||', Modalidade: '  ||rw_riscos_cpfcnpj.cdmodali
                            ||', Nr.Ctr.Emp.: ' ||rw_riscos_cpfcnpj.nrctremp
                            ||', Seq.Ctr.Emp.: '||rw_riscos_cpfcnpj.nrseqctr
                            || '. Detalhes:'||sqlerrm;
                RAISE vr_exc_erro;
            END;

          END LOOP; -- FIM LOOP - CONTRATOS DA CONTA

            -- Buscar o pr�ximo
            vr_chave_assris := vr_tab_ass_ris.NEXT(vr_chave_assris);

          END LOOP;

        END LOOP; -- FIM - cr_cpfcnpj_contas

        
       -- Atualiza todas as contas do CPF/CNPJ
        vr_chave_ass := vr_tab_ass_cpfcnpj.FIRST;
        LOOP
          EXIT WHEN vr_chave_ass IS NULL;

          -- Atualizar utilizar a tabela de-para de texto do n�vel com base no indice
          UPDATE crapass
             SET dsnivris = vr_tab_ass_cpfcnpj(vr_chave_ass)
           WHERE cdcooper = pr_cdcooper
             AND nrcpfcgc = to_number(vr_chave_ass);

          -- Buscar o pr�ximo
          vr_chave_ass := vr_tab_ass_cpfcnpj.NEXT(vr_chave_ass);

        END LOOP;

      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pc_efetua_arrasto_cpfcnpj --> Erro ao processar arrasto CPF/CNPJ. Detalhes: '||vr_des_erro;
        WHEN OTHERS THEN
          pr_des_erro := 'pc_efetua_arrasto_cpfcnpj --> Erro n�o tratado ao processar arrasto CPF/CNPJ. Detalhes: '||sqlerrm;
      END;
      

      -- Calculo dos juros para empr�stimos acima 60 dias
      PROCEDURE pc_calcula_juros_emp_60dias(pr_dtrefere  IN DATE
                                           ,pr_des_erro OUT VARCHAR2) IS
        -- Variaveis auxiliares
        vr_dtinicio DATE;
        vr_diascalc PLS_INTEGER;
        vr_vldjdmes NUMBER;

        -- Buscar todos os riscos de empr�stimos ou financiamentos
        CURSOR cr_crapris_epr IS
          SELECT ris.nrdconta
                ,ris.nrctremp
                ,ris.dtrefere
                ,ris.innivris
                ,ris.cdmodali
                ,ris.nrseqctr
                ,ris.qtdiaatr
                ,ris.vljura60
                ,epr.tpemprst
                ,ris.rowid
            FROM crapepr epr
                ,crapris ris
           WHERE epr.cdcooper = ris.cdcooper
             AND epr.nrdconta = ris.nrdconta
             AND epr.nrctremp = ris.nrctremp
             AND ris.cdcooper = pr_cdcooper
             AND ris.dtrefere = pr_dtrefere
             AND ris.inddocto = 1
             AND ris.cdmodali IN(0299,0499) -- Contratos de Emprestimo/Financiamento
           ORDER BY ris.nrdconta
                   ,ris.nrctremp
                   ,ris.nrseqctr;

        -- Busca o ultimo registro de vencimento do risco
        CURSOR cr_crapvri_ord(pr_nrdconta IN crapris.nrdconta%TYPE
                             ,pr_dtrefere IN crapris.dtrefere%TYPE
                             ,pr_innivris IN crapris.innivris%TYPE
                             ,pr_cdmodali IN crapris.cdmodali%TYPE
                             ,pr_nrctremp IN crapris.nrctremp%TYPE
                             ,pr_nrseqctr IN crapris.nrseqctr%TYPE) IS
          SELECT cdvencto
            FROM crapvri
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND dtrefere = pr_dtrefere
             AND innivris = pr_innivris
             AND cdmodali = pr_cdmodali
             AND nrctremp = pr_nrctremp
             AND nrseqctr = pr_nrseqctr
             AND cdvencto BETWEEN 230 AND 290
           ORDER BY cdvencto DESC;
           
        vr_cdvencto crapvri.cdvencto%TYPE;
        -- Buscar os registros de emprestimos a partir da data calculada e que
        -- esta data seja maior que a de inicio da reversao (cfme modalidade)
        CURSOR cr_craplem(pr_nrdconta IN crapris.nrdconta%TYPE
                         ,pr_nrctremp IN crapris.nrctremp%TYPE) IS
          SELECT NVL(SUM(vllanmto),0)
            FROM craplem
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrdocmto = pr_nrctremp
             AND dtmvtolt >= pr_dtrefere - vr_diascalc        -- Data de referencia - qtde dias calculada
             AND dtmvtolt BETWEEN vr_dtinicio AND pr_dtrefere -- Entre a data de revers�o e a de refer�ncia
             AND cdhistor = 98; -- JUROS EMPR.
        vr_vllanmto craplem.vllanmto%TYPE;
        -- Sumarizar os lan�amentos de divida do risco
        CURSOR cr_crapvri_sum(pr_nrdconta IN crapris.nrdconta%TYPE
                             ,pr_dtrefere IN crapris.dtrefere%TYPE
                             ,pr_innivris IN crapris.innivris%TYPE
                             ,pr_cdmodali IN crapris.cdmodali%TYPE
                             ,pr_nrctremp IN crapris.nrctremp%TYPE
                             ,pr_nrseqctr IN crapris.nrseqctr%TYPE) IS
          SELECT nvl( SUM (vldivida) , 0 )
            FROM crapvri
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND dtrefere = pr_dtrefere
             AND innivris = pr_innivris
             AND cdmodali = pr_cdmodali
             AND nrctremp = pr_nrctremp
             AND nrseqctr = pr_nrseqctr
             AND cdvencto BETWEEN 230 AND 290;
        vr_vldivida crapvri.vldivida%TYPE;

      BEGIN
          
        -- Buscar todos os riscos de empr�stimos ou financiamentos
        FOR rw_crapris IN cr_crapris_epr LOOP
                    
          -- Busca o ultimo registro de vencimento do risco
          OPEN cr_crapvri_ord(pr_nrdconta => rw_crapris.nrdconta
                             ,pr_dtrefere => rw_crapris.dtrefere
                             ,pr_innivris => rw_crapris.innivris
                             ,pr_cdmodali => rw_crapris.cdmodali
                             ,pr_nrctremp => rw_crapris.nrctremp
                             ,pr_nrseqctr => rw_crapris.nrseqctr);
                             
          FETCH cr_crapvri_ord INTO vr_cdvencto;
                      
          -- Somente continuar se encontrar registro
          IF cr_crapvri_ord%NOTFOUND THEN
            CLOSE cr_crapvri_ord;
            CONTINUE;
          END IF;         
          CLOSE cr_crapvri_ord;

          -- Inicializar o valor dos juros
          vr_vldjdmes := 0;          
          
          IF rw_crapris.tpemprst = 0 THEN
            -- Para empr�stimso
            IF rw_crapris.cdmodali = 0299 THEN
              -- Buscar at� 08/2010
              vr_dtinicio := to_date('01/08/2010','dd/mm/yyyy');
            ELSE
              -- Buscar somente at� 10/2011
              vr_dtinicio := to_date('01/10/2011','dd/mm/yyyy');
            END IF;
            -- calculo de dias para acima de 540 dias - codigo 290
            IF vr_cdvencto = 290 THEN
              -- Buscar quantidade de meses decorridos e a de parcelas do empr�stimo
              vr_diascalc := rw_crapris.qtdiaatr - 60;
            -- Se a quantidade de dias padr�o do vencimento for inferior ao atraso no risco
            ELSIF vr_tab_vencto(vr_cdvencto) < rw_crapris.qtdiaatr THEN
              -- Qtde dias para calculo recebe a quantidade padr�o do vencimento - 60 dias
              vr_diascalc := vr_tab_vencto(vr_cdvencto) - 60;
            ELSE
              -- Qtde dias para calculo recebe a quantidade em atraso do risco - 60 dias
              vr_diascalc := rw_crapris.qtdiaatr - 60;
            END IF;
            
            -- Buscar os registros de emprestimos a partir da data calculada e que
            -- esta data seja maior que a de inicio da reversao (cfme modalidade)
            OPEN cr_craplem(pr_nrdconta => rw_crapris.nrdconta
                           ,pr_nrctremp => rw_crapris.nrctremp);
            FETCH cr_craplem
             INTO vr_vllanmto;
            CLOSE cr_craplem;
          ELSE
            vr_vllanmto := nvl(rw_crapris.vljura60,0);
          END IF;          
          
          -- Acumular estes juros a variavel acumuladora
          vr_vldjdmes := vr_vldjdmes + nvl(vr_vllanmto,0);
          -- Sumarizar os lan�amentos de divida do risco
          OPEN cr_crapvri_sum(pr_nrdconta => rw_crapris.nrdconta
                             ,pr_dtrefere => rw_crapris.dtrefere
                             ,pr_innivris => rw_crapris.innivris
                             ,pr_cdmodali => rw_crapris.cdmodali
                             ,pr_nrctremp => rw_crapris.nrctremp
                             ,pr_nrseqctr => rw_crapris.nrseqctr);
          FETCH cr_crapvri_sum
           INTO vr_vldivida;           
          CLOSE cr_crapvri_sum;
                         
          -- Se o valor dos juros for superior ao da d�vida
          IF vr_vldjdmes >= vr_vldivida THEN
            -- Normalizar os juros
            IF (vr_vldjdmes - vr_vldivida) > 1 AND vr_vldivida > 1 THEN
              vr_vldjdmes := vr_vldivida - 1;
            ELSE
              vr_vldjdmes := vr_vldivida - 0.1;
            END IF;
          END IF;

          -- Gravar os juros do m�s
          BEGIN
            UPDATE crapris
               SET vljura60 = vr_vldjdmes
             WHERE rowid = rw_crapris.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao atualizar os juros no risco de empr�stimos --> '
                          || 'Conta: '||rw_crapris.nrdconta||', Emprestimo: '||rw_crapris.nrctremp
                          ||', Rowid: '||rw_crapris.rowid
                          || '. Detalhes:'||sqlerrm;
              RAISE vr_exc_erro;
          END;

        END LOOP; -- Termino leitura riscos de empr�stimo
      
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'pr_calcula_juros_emp_60dias --> Erro ao processar calculo juros. Detalhes: '||vr_des_erro;
        WHEN OTHERS THEN
          pr_des_erro := 'pr_calcula_juros_emp_60dias --> Erro n�o tratado ao processar calculo juros. Detalhes: '||sqlerrm;
      END;

      PROCEDURE pc_cria_table_risco_soberano(pr_cdcooper                   IN crapcop.cdcooper%TYPE
                                            ,pr_tab_contas_risco_soberano OUT typ_tab_contas_risco_soberano) IS

        -- Buscar as contas e seus riscos
        CURSOR cr_risco IS
          SELECT tcc.nrdconta
                ,tcc.cdnivel_risco
            FROM tbrisco_cadastro_conta tcc
           WHERE tcc.cdcooper = pr_cdcooper;

        BEGIN
          -- Buscar as contas e seus riscos
          FOR rw_risco IN cr_risco LOOP
            pr_tab_contas_risco_soberano(rw_risco.nrdconta).innivris := rw_risco.cdnivel_risco;
          END LOOP;
      END pc_cria_table_risco_soberano;
    
      
      --Executar Calculo Contas Associados  ***************
      PROCEDURE pc_atribui_risco_associado (pr_des_erro  OUT VARCHAR2) IS
      
      BEGIN      
                        
      -- Busca dos associados unindo com seu saldo na conta
      FOR rw_crapass IN cr_crapass LOOP
        BEGIN
          -- Para cada associado, rating efetivo inicia com n�vel 2
          vr_risco_rating := 2;

          -- Se encontrou notas de rating do contrato da conta e existir o indicador
          IF vr_tab_crapnrc.EXISTS(rw_crapass.nrdconta) AND vr_tab_crapnrc(rw_crapass.nrdconta).indrisco <> ' ' THEN
            -- Verificar o pior Risco entre o Rating e o Risco da operacao
            IF vr_tab_risco(vr_tab_crapnrc(rw_crapass.nrdconta).indrisco) > vr_risco_rating THEN
              vr_risco_rating := vr_tab_risco(vr_tab_crapnrc(rw_crapass.nrdconta).indrisco);
            END IF;
            
          END IF;
          -- Inicializar sequencia de contrato de empr�stimo
          vr_nrseqctr := 0;
          -- Vig�ncia inicial com base na data atual
          vr_dtfimvig := pr_rw_crapdat.dtmvtolt;
          -- Tomar como base de nro contrato a conta
          vr_nrctrlim := rw_crapass.nrdconta;
          -- Zerar valores de risco e divida
          vr_vlsrisco := 0;
          vr_vldivida := 0;
          -- Data inicial de contrato de risco baseia-se na admiss�o do associado
          vr_dtinictr := rw_crapass.dtadmiss;
          
          -- Sumarizar valor dispon�vel + valor bloqueado
          vr_vlsddisp := nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlsddisp,0) + nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlsdchsl,0);

          -- Se houver limite de cr�dito na conta
          IF rw_crapass.vllimcre <> 0 THEN
            -- Busca de linha de cr�dito em contratos de limite de cr�dito
            OPEN cr_craplim(pr_nrdconta => rw_crapass.nrdconta);
            FETCH cr_craplim
             INTO rw_craplim;
            -- Se encontrou
            IF cr_craplim%FOUND THEN
              -- Fechar o cursor
              CLOSE cr_craplim;
              -- Utlizaremos as informa��es do limite
              vr_dtfimvig := rw_craplim.dtinivig;
              vr_nrctrlim := rw_craplim.nrctrlim;
              vr_dtinictr := rw_craplim.dtinivig;
              -- Enquanto a data de fim for inferior a data vigente
              WHILE vr_dtfimvig < pr_rw_crapdat.dtmvtolt LOOP
                -- Adicionar a quantidade de dias do cr�dito rotativo
                vr_dtfimvig := vr_dtfimvig + rw_craplim.qtdiavig;
              END LOOP;
              -- Validaremos se haver� Limite N�o Utilizado, Ou seja:
              -- Conta Positiva OU Negativa que n�o consome o limite todo 
              IF vr_vlsddisp >= 0 OR rw_crapass.vllimcre + vr_vlsddisp > 0 THEN
                -- Conta positiva 
                IF vr_vlsddisp >= 0 THEN
                  -- Todo o limite n�o foi utilizado
                  vr_vlsrisco := rw_crapass.vllimcre;
                ELSE
                  -- Descontamos o limite utilizado
                  vr_vlsrisco := rw_crapass.vllimcre + vr_vlsddisp;                
                END IF;
                -- Os vencimentos 20(At� 360) e 40(Acima 360) s�o os �nicos poss�veis
                -- para a modalidade 1901 - Limite de Cr�dito contratado e n�o utilizado.
                IF rw_craplim.qtdiavig <= 360 THEN
                  vr_cdvencto := 20;
                ELSE
                  vr_cdvencto := 40;
                END IF;                                
                -- Incrementar sequencial do contrato
                vr_nrseqctr := vr_nrseqctr + 1;
                -- Gerar contrato de limite n�o utilizado
                -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
                pc_grava_crapris(  pr_nrdconta => rw_crapass.nrdconta                             
                                  ,pr_dtrefere => vr_dtrefere
                                  ,pr_innivris => 2    -- [Sempre A nesta categoria]                 
                                  ,pr_qtdiaatr => 0                  
                                  ,pr_vldivida => vr_vlsrisco -- [Contratado - Utilizado]                  
                                  ,pr_vlvec180 => 0
                                  ,pr_vlvec360 => 0
                                  ,pr_vlvec999 => 0
                                  ,pr_vldiv060 => 0
                                  ,pr_vldiv180 => 0
                                  ,pr_vldiv360 => 0
                                  ,pr_vldiv999 => 0
                                  ,pr_vlprjano => 0
                                  ,pr_vlprjaan => 0
                                  ,pr_inpessoa => rw_crapass.inpessoa                             
                                  ,pr_nrcpfcgc => rw_crapass.nrcpfcgc 
                                  ,pr_vlprjant => 0
                                  ,pr_inddocto => 3   -- [Usado somente para Limite n�o Utilizado]
                                  ,pr_cdmodali => 1901-- Lim. N�o Utilizado
                                  ,pr_nrctremp => vr_nrctrlim
                                  ,pr_nrseqctr => vr_nrseqctr                     
                                  ,pr_dtinictr => vr_dtinictr                                      
                                  ,pr_cdorigem => 1   -- Conta 
                                  ,pr_cdagenci => rw_crapass.cdagenci 
                                  ,pr_innivori => 0                     
                                  ,pr_cdcooper => pr_cdcooper                      
                                  ,pr_vlprjm60 => 0                     
                                  ,pr_dtdrisco => NULL                     
                                  ,pr_qtdriclq => 0                     
                                  ,pr_nrdgrupo => 0                                      
                                  ,pr_vljura60 => 0                                      
                                  ,pr_inindris => 2  -- [Sempre A nesta categoria]                                      
                                  ,pr_cdinfadi => ' '                                    
                                  ,pr_nrctrnov => 0                                      
                                  ,pr_flgindiv => 0                                    
                                  ,pr_dsinfaux => ' '                             
                                  ,pr_dtprxpar => NULL                             
                                  ,pr_vlprxpar => NULL
                                  ,pr_qtparcel => NULL
                                  ,pr_dtvencop => vr_dtfimvig
                                  ,pr_des_erro => vr_des_erro
                                  ,pr_index_crapris => vr_index_crapris);
                -- Testar retorno de erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar erro e fazer rollback
                  vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:'||rw_crapass.nrdconta||', Dcto 3020 - Modal 1901(Limite nao utilizado). Detalhes: ' || vr_des_erro;
                  -- Gerar erro e roolback
                  RAISE vr_exc_undo;
                END IF;
                
                -- Chamar rotina de grava��o dos vencimentos do risco
                pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta --> Num. da conta
                                ,pr_dtrefere => vr_dtrefere         --> Data de refer�ncia
                                ,pr_innivris => 2                   --> N�vel do risco (Sempre A)
                                ,pr_cdmodali => 1901                --> Modalidade do risco 1901 -- Limite n�o Utilizado
                                ,pr_cdvencto => vr_cdvencto         --> Codigo do vencimento
                                ,pr_nrctremp => vr_nrctrlim         --> Nro contrato empr�stimo
                                ,pr_nrseqctr => vr_nrseqctr         --> Seq contrato empr�stimo
                                ,pr_vlsrisco => vr_vlsrisco         --> Valor do risco a lan�ar
                                ,pr_des_erro => vr_des_erro);
                -- Testar retorno de erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar erro e roolback
                  RAISE vr_exc_undo;
                END IF;
              END IF;
            ELSE
              -- Apenas fechar o cursor
              CLOSE cr_craplim;
            END IF;
          END IF;
          
          -- Se o saldo estiver negativo
          IF vr_vlsddisp < 0 THEN -- Gerar Informacoes Docto 3020
            -- Sumarizar valor bloqueado
            vr_vlbloque := nvl(vr_tab_crapsld(rw_crapass.nrdconta).vlbloque,0); 
            -- Enviar no valor da d�vida o valor absoluto de saldo
            vr_vldivida := ABS(vr_vlsddisp);
            -- Se o valor da d�vida for superior a zero e existe valor de limite na conta
            IF vr_vldivida > 0 AND rw_crapass.vllimcre > 0 THEN            
              -- Busca de linha de cr�dito em contratos de limite de cr�dito
              OPEN cr_craplim(pr_nrdconta => rw_crapass.nrdconta);
              FETCH cr_craplim
               INTO rw_craplim;
              -- Se encontrou
              IF cr_craplim%FOUND THEN
                -- Fechar o cursor
                CLOSE cr_craplim;
                -- Utlizaremos as informa��es do limite
                vr_dtfimvig := rw_craplim.dtinivig;
                vr_nrctrlim := rw_craplim.nrctrlim;
                vr_dtinictr := rw_craplim.dtinivig;
                -- Enquanto a data de fim for inferior a data vigente
                WHILE vr_dtfimvig < pr_rw_crapdat.dtmvtolt LOOP
                  -- Adicionar a quantidade de dias do cr�dito rotativo
                  vr_dtfimvig := vr_dtfimvig + rw_craplim.qtdiavig;
                END LOOP;
                -- Se o valor da d�vida for inferior ao limite
                IF vr_vldivida < rw_crapass.vllimcre THEN
                  -- Assumir toda a d�vida como risco
                  vr_vlsrisco := vr_vldivida;
                  vr_vldivida := 0;
                ELSE
                  -- Assumir como risco o limite do cr�dito e
                  -- diminuir da d�vida este valor do risco
                  vr_vlsrisco := rw_crapass.vllimcre;
                  vr_vldivida := vr_vldivida - rw_crapass.vllimcre;
                END IF;
                
                -- Calcular dias em vencimento do risco
                vr_diasvenc := vr_dtfimvig - pr_rw_crapdat.dtmvtolt;
                -- Buscar o c�digo do vencimento a lan�ar
                vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc);              
                
                -- SubRotina para posicionar o valor da divida no campo 
                -- correspondente conforme o c�digo do vencimento enviado
                -- Subrotina para cria��o da crapris espec�fica para o dcto 3010
                pc_posici_divida_vcto(pr_cdvencto => vr_cdvencto  --> Codigo do vencimento
                                     ,pr_vldivida => vr_vlsrisco  --> Valor do risco a lan�ar
                                     ,pr_rsvec180 => vr_vlvec180
                                     ,pr_rsvec360 => vr_vlvec360
                                     ,pr_rsvec999 => vr_vlvec999
                                     ,pr_rsdiv060 => vr_vldiv060
                                     ,pr_rsdiv180 => vr_vldiv180
                                     ,pr_rsdiv360 => vr_vldiv360
                                     ,pr_rsdiv999 => vr_vldiv999
                                     ,pr_rsprjano => vr_vlprjano
                                     ,pr_rsprjaan => vr_vlprjaan
                                     ,pr_rsprjant => vr_vlprjant);
                
                -- Incrementar sequencial do contrato
                vr_nrseqctr := vr_nrseqctr + 1;
                -- Criar registro de risco para documento 3020
                -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
                pc_grava_crapris(  pr_nrdconta => rw_crapass.nrdconta                             
                                  ,pr_dtrefere => vr_dtrefere
                                  ,pr_innivris => vr_risco_rating
                                  ,pr_qtdiaatr => 0
                                  ,pr_vldivida => vr_vlsrisco -- [Contratado - Utilizado]                  
                                  ,pr_vlvec180 => nvl(vr_vlvec180,0)
                                  ,pr_vlvec360 => nvl(vr_vlvec360,0)
                                  ,pr_vlvec999 => nvl(vr_vlvec999,0)
                                  ,pr_vldiv060 => nvl(vr_vldiv060,0)
                                  ,pr_vldiv180 => nvl(vr_vldiv180,0)
                                  ,pr_vldiv360 => nvl(vr_vldiv360,0)
                                  ,pr_vldiv999 => nvl(vr_vldiv999,0)
                                  ,pr_vlprjano => nvl(vr_vlprjano,0)                            
                                  ,pr_vlprjaan => nvl(vr_vlprjaan,0)
                                  ,pr_inpessoa => rw_crapass.inpessoa                             
                                  ,pr_nrcpfcgc => rw_crapass.nrcpfcgc 
                                  ,pr_vlprjant => nvl(vr_vlprjant,0) 
                                  ,pr_inddocto => 1          -- Docto 3020
                                  ,pr_cdmodali => 0201-- Cheque Especial 
                                  ,pr_nrctremp => vr_nrctrlim
                                  ,pr_nrseqctr => vr_nrseqctr                     
                                  ,pr_dtinictr => vr_dtinictr                                      
                                  ,pr_cdorigem => 1   -- Conta 
                                  ,pr_cdagenci => rw_crapass.cdagenci 
                                  ,pr_innivori => 0                     
                                  ,pr_cdcooper => pr_cdcooper                      
                                  ,pr_vlprjm60 => 0                     
                                  ,pr_dtdrisco => NULL                     
                                  ,pr_qtdriclq => 0                     
                                  ,pr_nrdgrupo => 0                                      
                                  ,pr_vljura60 => 0                                      
                                  ,pr_inindris => vr_risco_rating
                                  ,pr_cdinfadi => ' '                                    
                                  ,pr_nrctrnov => 0                                      
                                  ,pr_flgindiv => 0                                    
                                  ,pr_dsinfaux => ' '                             
                                  ,pr_dtprxpar => NULL                             
                                  ,pr_vlprxpar => NULL
                                  ,pr_qtparcel => NULL
                                  ,pr_dtvencop => vr_dtfimvig
                                  ,pr_des_erro => vr_des_erro
                                  ,pr_index_crapris => vr_index_crapris);
                -- Testar retorno de erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar erro e fazer rollback
                  vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:'||rw_crapass.nrdconta||', Dcto 3020 - Modal 0201(Cheque Especial). Detalhes: ' || vr_des_erro;
                  -- Gerar erro e roolback
                  RAISE vr_exc_undo;
                END IF;
                
                -- Chamar rotina de grava��o dos vencimentos do risco
                pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta --> Num. da conta
                                ,pr_dtrefere => vr_dtrefere         --> Data de refer�ncia
                                ,pr_innivris => vr_risco_rating     --> N�vel do risco
                                ,pr_cdmodali => 0201                --> Modalidade do risco 0201 -- Cheque Especial
                                ,pr_cdvencto => vr_cdvencto         --> Codigo do vencimento
                                ,pr_nrctremp => vr_nrctrlim         --> Nro contrato empr�stimo
                                ,pr_nrseqctr => vr_nrseqctr         --> Seq contrato empr�stimo
                                ,pr_vlsrisco => vr_vlsrisco         --> Valor do risco a lan�ar
                                ,pr_des_erro => vr_des_erro);
                -- Testar retorno de erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar erro e roolback
                  RAISE vr_exc_undo;
                END IF;
              ELSE
                -- Fechar o cursor - Renato Darosci - 18/12/2015 
                CLOSE cr_craplim;
              END IF;
            END IF;
            -- Se ainda persistir valor de d�vida
            IF vr_vldivida > 0 THEN
              -- Assumir a divida todo como o risco
              vr_vlsrisco := vr_vldivida;
              -- Incrementar sequencial do contrato
              vr_nrseqctr := vr_nrseqctr + 1;
              -- Dias de Atraso
              vr_qtdiaatr := nvl(vr_tab_crapsld(rw_crapass.nrdconta).qtdriclq,1);              
              
              /* A informacao "qtdriclq" estah considerando o saldo disponivel em conta + Bloqueado + Cheque Salario.
                 Para a central de risco somente considera: Saldo Disponivel + Cheque Salario.
                 Entao caso a conta possuir Saldo Bloqueado, vamos considerar a quantidade de dias de Atraso: 1 dia. */
              IF vr_qtdiaatr <= 0 THEN
                vr_qtdiaatr := 1;
              END IF;
              
              vr_dtrisclq := nvl(vr_tab_crapsld(rw_crapass.nrdconta).dtrisclq,pr_rw_crapdat.dtmvtolt);
              -- Verificar qual nivel de risco o AD se encontra
              CASE
			    -- Regra alterada, considerar para o risco igual a dois somente at� o 14 dias de atraso
                WHEN vr_qtdiaatr < 15 THEN 
                  vr_risco_aux := 2;
                WHEN vr_qtdiaatr <= 30 THEN
                  vr_risco_aux := 3;
                WHEN vr_qtdiaatr <= 60 THEN
                  vr_risco_aux := 5;
                WHEN vr_qtdiaatr <= 90 THEN
                  vr_risco_aux := 7;
                ELSE
                  vr_risco_aux := 9;
              END CASE;
              
              vr_diasvenc := vr_qtdiaatr * -1;
              -- Buscar o c�digo do vencimento a lan�ar
              vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc);              
              -- SubRotina para posicionar o valor da divida no campo 
              -- correspondente conforme o c�digo do vencimento enviado
              -- Subrotina para cria��o da crapris espec�fica para o dcto 3010
              pc_posici_divida_vcto(pr_cdvencto => vr_cdvencto  --> Codigo do vencimento
                                   ,pr_vldivida => vr_vlsrisco  --> Valor do risco a lan�ar
                                   ,pr_rsvec180 => vr_vlvec180
                                   ,pr_rsvec360 => vr_vlvec360
                                   ,pr_rsvec999 => vr_vlvec999
                                   ,pr_rsdiv060 => vr_vldiv060
                                   ,pr_rsdiv180 => vr_vldiv180
                                   ,pr_rsdiv360 => vr_vldiv360
                                   ,pr_rsdiv999 => vr_vldiv999
                                   ,pr_rsprjano => vr_vlprjano
                                   ,pr_rsprjaan => vr_vlprjaan
                                   ,pr_rsprjant => vr_vlprjant);
              -- Se houver Saldo Bloqueado
              IF vr_vlbloque > 0 THEN
                -- Se a divida for inferior ao Saldo Bloqueado
                IF vr_vldivida < vr_vlbloque THEN
                  -- Assumimos somente a d�vida como desconto no Saldo Bloqueado
                  vr_dsinfaux := to_Char(vr_vldivida,'fm999g999g990d00');
                ELSE
                  -- Usaremos o valor m�ximo do Saldo Bloqueado, o restante � AD
                  vr_dsinfaux := to_Char(vr_vlbloque,'fm999g999g990d00');
                END IF;
              ELSE
                -- N�o h� informa��o adicional
                vr_dsinfaux := ' ';
              END IF;
              -- Criar registro de risco para documento 3020
              -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
              pc_grava_crapris(  pr_nrdconta => rw_crapass.nrdconta                             
                                ,pr_dtrefere => vr_dtrefere
                                ,pr_innivris => vr_risco_aux
                                ,pr_qtdiaatr => nvl(vr_qtdiaatr,0)                  
                                ,pr_vldivida => vr_vlsrisco -- [Contratado - Utilizado]                  
                                ,pr_vlvec180 => nvl(vr_vlvec180,0)
                                ,pr_vlvec360 => nvl(vr_vlvec360,0)
                                ,pr_vlvec999 => nvl(vr_vlvec999,0)
                                ,pr_vldiv060 => nvl(vr_vldiv060,0)
                                ,pr_vldiv180 => nvl(vr_vldiv180,0)
                                ,pr_vldiv360 => nvl(vr_vldiv360,0)
                                ,pr_vldiv999 => nvl(vr_vldiv999,0)
                                ,pr_vlprjano => nvl(vr_vlprjano,0)                            
                                ,pr_vlprjaan => nvl(vr_vlprjaan,0)
                                ,pr_inpessoa => rw_crapass.inpessoa                             
                                ,pr_nrcpfcgc => rw_crapass.nrcpfcgc 
                                ,pr_vlprjant => nvl(vr_vlprjant,0) 
                                ,pr_inddocto => 1          -- Docto 3020
                                ,pr_cdmodali => 0101-- Adiant.Depositante 
                                ,pr_nrctremp => rw_crapass.nrdconta
                                ,pr_nrseqctr => vr_nrseqctr                     
                                ,pr_dtinictr => vr_dtrisclq                                      
                                ,pr_cdorigem => 1   -- Conta 
                                ,pr_cdagenci => rw_crapass.cdagenci 
                                ,pr_innivori => 0                     
                                ,pr_cdcooper => pr_cdcooper                      
                                ,pr_vlprjm60 => 0                     
                                ,pr_dtdrisco => NULL                     
                                ,pr_qtdriclq => ABS(vr_qtdiaatr) --> valor absoluto                      
                                ,pr_nrdgrupo => 0                                      
                                ,pr_vljura60 => 0                                      
                                ,pr_inindris => vr_risco_aux
                                ,pr_cdinfadi => ' '                                    
                                ,pr_nrctrnov => 0                                      
                                ,pr_flgindiv => 0                                    
                                ,pr_dsinfaux => vr_dsinfaux                            
                                ,pr_dtprxpar => NULL                             
                                ,pr_vlprxpar => NULL
                                ,pr_qtparcel => NULL
                                ,pr_dtvencop => vr_dtrisclq
                                ,pr_des_erro => vr_des_erro
                                ,pr_index_crapris => vr_index_crapris);
              -- Testar retorno de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar erro e fazer rollback
                vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:'||rw_crapass.nrdconta||', Dcto 3020 - Modal 0101(Adiant.Depositante). Detalhes: ' || vr_des_erro;
                -- Gerar erro e roolback
                RAISE vr_exc_undo;
              END IF;              
              
              -- Chamar rotina de grava��o dos vencimentos do risco
              pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta --> Num. da conta
                              ,pr_dtrefere => vr_dtrefere         --> Data de refer�ncia
                              ,pr_innivris => vr_risco_aux        --> N�vel do risco
                              ,pr_cdmodali => 0101                --> Modalidade do risco 0101 -- Adiant.Depositante
                              ,pr_cdvencto => vr_cdvencto         --> Codigo do vencimento
                              ,pr_nrctremp => rw_crapass.nrdconta --> Nro contrato empr�stimo
                              ,pr_nrseqctr => vr_nrseqctr         --> Seq contrato empr�stimo
                              ,pr_vlsrisco => vr_vlsrisco         --> Valor do risco a lan�ar
                              ,pr_des_erro => vr_des_erro);
              -- Testar retorno de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar erro e roolback
                RAISE vr_exc_undo;
              END IF;
            END IF;
          END IF; -- Fim Gerar Informacoes Docto 3020

          -- Busca de todos os empr�stimos em aberto          
          FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => rw_crapass.nrdconta) LOOP                    
            -- Chamar rotinas espec�ficas cfme tipo do empr�stimo
            IF rw_crapepr.tpemprst = 0 THEN -- TR
                -- Risco Emprestimos Price
              pc_lista_emp_price(pr_rw_crapass   => rw_crapass
                                ,pr_rw_crapepr   => rw_crapepr
                                  ,pr_des_erro     => vr_des_erro);
                -- Testar sa�da com erro
                IF vr_des_erro IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;

            ELSIF rw_crapepr.tpemprst = 1 THEN -- PP
                -- Verificacao para saber se o contrato estah em prejuizo
              IF rw_crapepr.inprejuz = 0 THEN
                  -- Emprestimos Pre fixados
                pc_lista_emp_prefix(pr_rw_crapass   => rw_crapass
                                   ,pr_rw_crapepr   => rw_crapepr
                                     ,pr_risco_rating => vr_risco_rating
                                     ,pr_des_erro     => vr_des_erro);
                  -- Testar sa�da com erro
                  IF vr_des_erro IS NOT NULL THEN
                    RAISE vr_exc_erro;
                  END IF;
                ELSE 
                  -- Contrato em Prejuizo
                pc_lista_emp_prefix_prejuizo(pr_rw_crapass   => rw_crapass
                                            ,pr_rw_crapepr   => rw_crapepr
                                              ,pr_des_erro     => vr_des_erro);
                  -- Testar sa�da com erro
                  IF vr_des_erro IS NOT NULL THEN
                    RAISE vr_exc_erro;
                  END IF;
                END IF;

            ELSIF rw_crapepr.tpemprst = 2 THEN -- POS
              -- Emprestimos Pos-Fixados
              pc_lista_emp_pos_fixado(pr_rw_crapass   => rw_crapass
                                     ,pr_rw_crapepr   => rw_crapepr
                                     ,pr_risco_rating => vr_risco_rating
                                     ,pr_des_erro     => vr_des_erro);
              -- Caso houve erro
              IF vr_des_erro IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;

          END LOOP; -- Fim loop crapepr            
          
          -- Processar riscos de desconto de cheque --
          -- somente se a conta estiver no vetor de contas com informa��o na tabela
          IF vr_tab_ctabdc.EXISTS(rw_crapass.nrdconta) THEN
            -- Buscar dentro da tabela interna desta conta, a tabela de registros previamente carregados
            vr_dschave_bdc := vr_tab_ctabdc(rw_crapass.nrdconta).tbcrapbdc.FIRST;
            LOOP
              -- Sair quando n�o encontrar mais registros
              EXIT WHEN vr_dschave_bdc IS NULL;
              -- Inicializar variaveis do risco do border�
              vr_nrctrlim := vr_tab_ctabdc(rw_crapass.nrdconta).tbcrapbdc(vr_dschave_bdc).nrborder;
              vr_dtinictr := vr_tab_ctabdc(rw_crapass.nrdconta).tbcrapbdc(vr_dschave_bdc).dtlibbdc;
              vr_nrborder := vr_tab_ctabdc(rw_crapass.nrdconta).tbcrapbdc(vr_dschave_bdc).nrborder;                
              -- Somente se existir cheque para o border�
              IF vr_tab_bord_cdb.EXISTS(vr_nrborder) THEN
                -- Inicializar variaveis de controle
                vr_vlsrisco := 0;
                vr_cdvencto := 0;
                vr_vldeschq := 0;
                vr_vldes180 := 0;
                vr_vldes360 := 0;
                vr_vldes999 := 0;
                vr_vldiv060 := 0;
                vr_vldiv180 := 0;
                vr_vldiv360 := 0;
                vr_vldiv999 := 0;
                vr_qtdiaatr := 0;
                vr_dtprxpar := null;
                vr_vlprxpar := 0;
                vr_dtvencop := NULL;
                vr_qtparcel := 0;
                -- Limpar a temp-table de vencimentos
                FOR vr_ind IN 1..23 LOOP
                  vr_tab_vlavence(vr_ind) := 0;
                END LOOP;                
                -- Buscar todos os cheques contidos no bordero passado
                vr_dschave_crapcdb := vr_tab_bord_cdb(vr_nrborder).tbcrapcdb.FIRST;
                LOOP
                  -- Sair quando n�o encontrar mais registros na tabela interna do bordero
                  EXIT WHEN vr_dschave_crapcdb IS NULL;
                  -- Copiar o registro atual da pltable interna para
                  -- variavel tempor�ria do mesmo tipo de registro para
                  -- facilitar a leitura e entendimento do c�digo
                  vr_aux_reg_cdb := vr_tab_bord_cdb(vr_nrborder).tbcrapcdb(vr_dschave_crapcdb);
                  -- Acumular no valor do risco o valor l�quido do cheque
                  vr_vlsrisco := vr_aux_reg_cdb.vlliquid;
                  
                  -- Calcular prazo de vencimento do bordero do cheque para cr�dito
                  -- em conta e da data de libera��o do border� para cr�dito em conta
                  vr_qtdprazo := vr_aux_reg_cdb.dtlibera - pr_rw_crapdat.dtmvtolt;
                  -- Armazenar a data mais pr�xima de vencimento para o Fluxo Financeiro
                  -- Desde que seja superior a data de refer�ncia
                  IF vr_aux_reg_cdb.dtlibera > vr_dtrefere THEN
                    vr_dtprxpar := LEAST(vr_aux_reg_cdb.dtlibera,NVL(vr_dtprxpar,vr_aux_reg_cdb.dtlibera));
                  END IF;                  
                  -- Armazena o data do ultimo vencimento da operacao
                  IF vr_aux_reg_cdb.dtlibera > vr_dtvencop OR vr_dtvencop IS NULL THEN
                    vr_dtvencop := vr_aux_reg_cdb.dtlibera;
                  END IF;
                  -- Acumular quantidade de titulos para o Fluxo Financeiro
                  vr_qtparcel := vr_qtparcel + 1;
                  -- Sumarizar os juros no desconto do cheque
                  vr_vldjuros := 0;
                  OPEN cr_crapljd(pr_nrdconta => vr_aux_reg_cdb.nrdconta
                                 ,pr_nrborder => vr_nrborder
                                 ,pr_dtmvtolt => vr_aux_reg_cdb.dtlibbdc
                                 ,pr_dtrefere => pr_rw_crapdat.dtultdia + 1 -- Ultimo dia m�s corrente + 1
                                 ,pr_cdcmpchq => vr_aux_reg_cdb.cdcmpchq
                                 ,pr_cdbanchq => vr_aux_reg_cdb.cdbanchq
                                 ,pr_cdagechq => vr_aux_reg_cdb.cdagechq
                                 ,pr_nrctachq => vr_aux_reg_cdb.nrctachq
                                 ,pr_nrcheque => vr_aux_reg_cdb.nrcheque);
                  FETCH cr_crapljd
                   INTO vr_vldjuros;
                  CLOSE cr_crapljd;
                  -- Incrementar no valor do risco os juros encontrados
                  vr_vlsrisco := vr_vlsrisco + nvl(vr_vldjuros,0);
                  -- Acumular o valor do risco atual para a variavel espec�fica de desconto de cheque
                  vr_vldeschq := vr_vldeschq + vr_vlsrisco;
                  -- Acumular titulo no Fluxo Financeiro se o seu vencimento for no pr�ximo m�s
                  IF vr_aux_reg_cdb.dtlibera BETWEEN trunc(add_months(vr_dtrefere,1),'mm')
                                                 AND last_day(add_months(vr_dtrefere,1)) THEN
                    vr_vlprxpar := vr_vlprxpar + vr_vlsrisco;
                  END IF;
                  
                  -- Copiar o valor do risco para a variavel espec�fica de
                  -- valores a vencer conforme o prazo calculado
                  IF vr_qtdprazo <= 180   THEN
                    vr_vldes180 := vr_vldes180 + vr_vlsrisco;
                  ELSIF vr_qtdprazo <= 360   THEN
                    vr_vldes360 := vr_vldes360 + vr_vlsrisco;
                  ELSE
                    vr_vldes999 := vr_vldes999 + vr_vlsrisco;
                  END IF;
                  -- Copiar o valor calculado para o vetor de valores
                  -- a vencer conforme o prazo encontrado
                  CASE
                    WHEN vr_qtdprazo <= 30 THEN
                      vr_tab_vlavence(1) := vr_tab_vlavence(1) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 60 THEN
                      vr_tab_vlavence(2) := vr_tab_vlavence(2) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 90 THEN
                      vr_tab_vlavence(3) := vr_tab_vlavence(3) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 180 THEN
                      vr_tab_vlavence(4) := vr_tab_vlavence(4)+ vr_vlsrisco;
                    WHEN vr_qtdprazo <= 360 THEN
                      vr_tab_vlavence(5) := vr_tab_vlavence(5) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 720 THEN
                      vr_tab_vlavence(6) := vr_tab_vlavence(6) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 1080 THEN
                      vr_tab_vlavence(7) := vr_tab_vlavence(7) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 1440 THEN
                      vr_tab_vlavence(8) := vr_tab_vlavence(8) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 1800 THEN
                      vr_tab_vlavence(9) := vr_tab_vlavence(9)  + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 5400 THEN
                      vr_tab_vlavence(10) := vr_tab_vlavence(10) + vr_vlsrisco;
                    ELSE
                      vr_tab_vlavence(11) := vr_tab_vlavence(11)  + vr_vlsrisco;
                  END CASE;
                    
                  -- BUscar o pr�ximo registro dos chques
                  vr_dschave_crapcdb := vr_tab_bord_cdb(vr_nrborder).tbcrapcdb.NEXT(vr_dschave_crapcdb);
                END LOOP; -- Fim leitura cheques
                -- Se houver valor de desconto de cheque deste border�
                IF vr_vldeschq > 0  THEN
                  -- Gerar Informacoes Docto 3020 --
                  -- Incrementar sequencial do contrato
                  vr_nrseqctr := vr_nrseqctr + 1;
                  -- Criar registro de risco para documento 3020
                  -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
                  pc_grava_crapris(  pr_nrdconta => rw_crapass.nrdconta                             
                                    ,pr_dtrefere => vr_dtrefere
                                    ,pr_innivris => vr_risco_rating
                                    ,pr_qtdiaatr => ABS(vr_qtdiaatr)
                                    ,pr_vldivida => vr_vldeschq
                                    ,pr_vlvec180 => nvl(vr_vldes180,0)
                                    ,pr_vlvec360 => nvl(vr_vldes360,0)
                                    ,pr_vlvec999 => nvl(vr_vldes999,0)
                                    ,pr_vldiv060 => 0
                                    ,pr_vldiv180 => 0
                                    ,pr_vldiv360 => 0
                                    ,pr_vldiv999 => 0
                                    ,pr_vlprjano => 0                            
                                    ,pr_vlprjaan => 0
                                    ,pr_inpessoa => rw_crapass.inpessoa                             
                                    ,pr_nrcpfcgc => rw_crapass.nrcpfcgc 
                                    ,pr_vlprjant => 0
                                    ,pr_inddocto => 1          -- Docto 3020
                                    ,pr_cdmodali => 0302 -- Desconto Cheques
                                    ,pr_nrctremp => vr_nrctrlim
                                    ,pr_nrseqctr => vr_nrseqctr                     
                                    ,pr_dtinictr => vr_dtinictr                                      
                                    ,pr_cdorigem => 2   -- Desconto de cheques 
                                    ,pr_cdagenci => rw_crapass.cdagenci 
                                    ,pr_innivori => 0                     
                                    ,pr_cdcooper => pr_cdcooper                      
                                    ,pr_vlprjm60 => 0                     
                                    ,pr_dtdrisco => NULL                     
                                    ,pr_qtdriclq => 0                      
                                    ,pr_nrdgrupo => 0                                      
                                    ,pr_vljura60 => 0                                      
                                    ,pr_inindris => vr_risco_rating
                                    ,pr_cdinfadi => ' '                                    
                                    ,pr_nrctrnov => 0                                      
                                    ,pr_flgindiv => 0                                    
                                    ,pr_dsinfaux => ' '                            
                                    ,pr_dtprxpar => vr_dtprxpar                      
                                    ,pr_vlprxpar => vr_vlprxpar
                                    ,pr_qtparcel => vr_qtparcel
                                    ,pr_dtvencop => vr_dtvencop
                                    ,pr_des_erro => vr_des_erro
                                    ,pr_index_crapris => vr_index_crapris);
                  -- Testar retorno de erro
                  IF vr_des_erro IS NOT NULL THEN
                    -- Gerar erro e fazer rollback
                    vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:'||rw_crapass.nrdconta||', Dcto 3020 - Modal 0302(Desconto Cheques). Detalhes: ' || vr_des_erro;
                    -- Gerar erro e roolback
                    RAISE vr_exc_undo;
                  END IF;
                  
                  -- Para cada registro de parcelas no vetor a vencer
                  IF vr_tab_vlavence.COUNT > 0 THEN
                    FOR vr_ind IN vr_tab_vlavence.FIRST..vr_tab_vlavence.LAST LOOP
                      -- Se existe valor nesta posi��o
                      IF vr_tab_vlavence.EXISTS(vr_ind) AND vr_tab_vlavence(vr_ind) > 0 THEN
                        -- Dias em vencimento vem do vetor
                        vr_diasvenc := vr_tab_ddavence(vr_ind);
                        -- Buscar o c�digo do vencimento a lan�ar
                        vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc);
                        -- Chamar rotina de grava��o dos vencimentos do risco
                        pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta     --> Num. da conta
                                        ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                                        ,pr_innivris => vr_risco_rating         --> N�vel do risco
                                        ,pr_cdmodali => 0302                    --> Desconto Cheques
                                        ,pr_cdvencto => vr_cdvencto             --> Codigo do vencimento
                                        ,pr_nrctremp => vr_nrctrlim             --> Nro contrato emprestimo
                                        ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                                        ,pr_vlsrisco => vr_tab_vlavence(vr_ind) --> Valor do risco a lan�ar
                                        ,pr_des_erro => vr_des_erro);
                        -- Testar retorno de erro
                        IF vr_des_erro IS NOT NULL THEN
                          -- Gerar erro e roolback
                          RAISE vr_exc_erro;
                        END IF;
                      END IF;
                    END LOOP;
                  END IF;
                END IF;              
              END IF;-- Fim se existe registro de bordero
              -- Buscar o pr�ximo registro
              vr_dschave_bdc := vr_tab_ctabdc(rw_crapass.nrdconta).tbcrapbdc.NEXT(vr_dschave_bdc);
            END LOOP; -- Fim leitura border�s
          END IF;
          
          ------- Risco do desconto de titulos -------
          -- Somente processar as contas que possuem informa�ao na temp-table
          IF vr_tab_ctabdt.EXISTS(rw_crapass.nrdconta) THEN
            -- Buscar cadastro de borderos de descontos de titulos
            -- Esta busca deve obrigatoriamente ser igual ao relatorio
            -- 494 e 495 que sao gerados pelo fontes/crps518.p
            -- os comentarios sobre a busca estao la
            -- Considerar em risco titulos que vencem em glb_dtmvtolt
            FOR rw_crapbdt IN cr_crapbdt(pr_nrdconta => rw_crapass.nrdconta
                                        ,pr_dtrefere => vr_dtrefere) LOOP 
              -- Se estivermos processando o primeiro registro do Boleto + TpCobran�a
              IF rw_crapbdt.seq_atu = 1 THEN
                -- Primeiramente inicializar as variaveis --
                vr_vldestit := 0;
                vr_vltit180 := 0;
                vr_vltit360 := 0;
                vr_vltit999 := 0;
                vr_vldiv060 := 0;
                vr_vldiv180 := 0;
                vr_vldiv360 := 0;
                vr_vldiv999 := 0;
                vr_dtprxpar := null;
                vr_vlprxpar := 0;
                vr_qtdiaatr := 0;
                vr_qtparcel := 1; -- Para desconto de duplicata sempre gera 1 parcela do Fluxo Financeiro
                vr_dtvencop := NULL;
                -- Limpar a temp-table
                FOR vr_ind IN 1..23 LOOP
                  vr_tab_vlavence(vr_ind) := 0;
                END LOOP;
                -- Testar origem cfme a flag
                IF rw_crapbdt.flgregis = 0 THEN
                  -- Desconto Titulos - cob. sem reg
                  vr_cdorigem := 4;
                ELSE
                  -- Desconto Titulos - cob. com reg
                  vr_cdorigem := 5;
                END IF;
              END IF;
              -- Inicializar variaveis do risco
              vr_nrctrlim := rw_crapbdt.nrborder;
              vr_dtinictr := rw_crapbdt.dtlibbdt;
              vr_vlsrisco := 0;
              vr_cdvencto := 0;
              -- Se foi pago via CAIXA, InternetBank ou TAA ou compe 085
              -- Nao considera em risco, pois ja esta pago o dinheiro ja entrou para a cooperativa
              IF NOT (rw_crapbdt.insittit = 2 AND (rw_crapbdt.indpagto IN(1,3,4) OR (rw_crapbdt.indpagto = 0 AND rw_crapbdt.cdbandoc = 085))) THEN
                -- Acumular no valor do risco o valor l�quido do cheque
                vr_vlsrisco := rw_crapbdt.vlliquid;
                -- Calcular o prazo com base nas datas de vencimento do titulo
                -- e da data de libera��o do border� para cr�dito em conta

                vr_qtdprazo := rw_crapbdt.dtvencto - pr_rw_crapdat.dtmvtolt;
                -- Armazenar a data mais pr�xima de vencimento para o Fluxo Financeiro
                -- Desde que seja superior a data de refer�ncia
                IF rw_crapbdt.dtvencto > vr_dtrefere THEN
                  vr_dtprxpar := LEAST(rw_crapbdt.dtvencto,NVL(vr_dtprxpar,rw_crapbdt.dtvencto));
                END IF;
                -- Armazena o data do ultimo vencimento da operacao
                IF rw_crapbdt.dtvencto > vr_dtvencop OR vr_dtvencop IS NULL THEN
                  vr_dtvencop := rw_crapbdt.dtvencto;
                END IF;
                -- Se foi pago antecipado ele soma os juros restituidos como risco
                -- tambem pois o titulo ainda eh considerado em risco para a contabilidade
                IF rw_crapbdt.insittit = 2 AND rw_crapbdt.dtdpagto = pr_rw_crapdat.dtmvtolt AND rw_crapbdt.dtvencto > pr_rw_crapdat.dtmvtolt THEN
                  -- Sumarizar os juros no desconto do titulo
                  vr_vlrestit := 0;
                  OPEN cr_crapljt_rest(pr_nrdconta => rw_crapbdt.nrdconta
                                      ,pr_nrborder => rw_crapbdt.nrborder
                                      ,pr_dtmvtolt => rw_crapbdt.dtlibbdt
                                      ,pr_dtrefere => pr_rw_crapdat.dtultdia -- Ultimo dia m�s corrente
                                      ,pr_cdbandoc => rw_crapbdt.cdbandoc
                                      ,pr_nrdctabb => rw_crapbdt.nrdctabb
                                      ,pr_nrcnvcob => rw_crapbdt.nrcnvcob
                                      ,pr_nrdocmto => rw_crapbdt.nrdocmto);
                  FETCH cr_crapljt_rest
                   INTO vr_vlrestit;
                  CLOSE cr_crapljt_rest;
                  -- Acumular ao valor do risco os juros encontrados
                  vr_vlsrisco := vr_vlsrisco + nvl(vr_vlrestit,0);
                END IF;
                -- Sumarizar os juros e valor de restitui��o nos lan�amentos de juros de titulos
                vr_vldjuros := 0;
                OPEN cr_crapljt_soma(pr_nrdconta => rw_crapbdt.nrdconta
                                    ,pr_nrborder => rw_crapbdt.nrborder
                                    ,pr_dtmvtolt => rw_crapbdt.dtlibbdt
                                    ,pr_dtrefere => pr_rw_crapdat.dtultdia + 1  -- Ultimo dia m�s corrente + 1
                                    ,pr_cdbandoc => rw_crapbdt.cdbandoc
                                    ,pr_nrdctabb => rw_crapbdt.nrdctabb
                                    ,pr_nrcnvcob => rw_crapbdt.nrcnvcob
                                    ,pr_nrdocmto => rw_crapbdt.nrdocmto);
                FETCH cr_crapljt_soma
                 INTO vr_vldjuros;
                CLOSE cr_crapljt_soma;
                -- Acumular ao valor do risco os juros encontrados
                vr_vlsrisco := vr_vlsrisco + nvl(vr_vldjuros,0);
                -- Acumular o valor do risco atual para a variavel espec�fica de desconto de titulos
                vr_vldestit := vr_vldestit + vr_vlsrisco;
                -- Acumular titulo no Fluxo Financeiro se o seu vencimento for no pr�ximo m�s
                IF rw_crapbdt.dtvencto BETWEEN trunc(add_months(vr_dtrefere,1),'mm')
                                           AND last_day(add_months(vr_dtrefere,1)) THEN
                  vr_vlprxpar := vr_vlprxpar + vr_vlsrisco;
                END IF;                
                
                IF vr_qtdprazo > 0 THEN
                  -- Copiar o valor do risco para a variavel espec�fica de
                  -- valores a vencer conforme o prazo calculado
                  IF vr_qtdprazo <= 180   THEN
                    vr_vltit180 := vr_vltit180 + vr_vlsrisco;
                  ELSIF vr_qtdprazo <= 360   THEN
                    vr_vltit360 := vr_vltit360 + vr_vlsrisco;
                  ELSE
                    vr_vltit999 := vr_vltit999 + vr_vlsrisco;
                  END IF;
                  -- Copiar o valor calculado para o vetor de valores
                  -- a vencer conforme o prazo encontrado
                  CASE
                    WHEN vr_qtdprazo <= 30 THEN
                      vr_tab_vlavence(1) := vr_tab_vlavence(1) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 60 THEN
                      vr_tab_vlavence(2) := vr_tab_vlavence(2) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 90 THEN
                      vr_tab_vlavence(3) := vr_tab_vlavence(3) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 180 THEN
                      vr_tab_vlavence(4) := vr_tab_vlavence(4) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 360 THEN
                      vr_tab_vlavence(5) := vr_tab_vlavence(5) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 720 THEN
                      vr_tab_vlavence(6) := vr_tab_vlavence(6) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 1080 THEN
                      vr_tab_vlavence(7) := vr_tab_vlavence(7) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 1440 THEN
                      vr_tab_vlavence(8) := vr_tab_vlavence(8) + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 1800 THEN
                      vr_tab_vlavence(9) := vr_tab_vlavence(9)  + vr_vlsrisco;
                    WHEN vr_qtdprazo <= 5400 THEN
                      vr_tab_vlavence(10) := vr_tab_vlavence(10) + vr_vlsrisco;
                    ELSE
                      vr_tab_vlavence(11) := vr_tab_vlavence(11)  + vr_vlsrisco;
                  END CASE;
                ELSE
                  -- Grava a quantidade de dias que estah mais em atraso
                  IF vr_qtdiaatr >= vr_qtdprazo THEN
                    IF vr_qtdprazo = 0 THEN
                      vr_qtdiaatr := -1;
                    ELSE
                      vr_qtdiaatr := vr_qtdprazo;
                    END IF;
                  END IF;
                  
                  -- Negativar a diferen�a de dias pois o valor j� est� vencido
                  -- e o calculo retornou o valor negativo
                  vr_qtdprazo := vr_qtdprazo * -1;
                  
                  FOR idx IN 12..vr_tab_ddavence.last LOOP
                    -- Vencidos a mais de 541
                    IF idx = 23 AND vr_qtdprazo >= abs(vr_tab_ddavence(idx)) THEN
                      vr_tab_vlavence(idx) := vr_tab_vlavence(idx) + vr_vlsrisco;
                      EXIT;
                    ELSIF vr_qtdprazo <= abs(vr_tab_ddavence(idx))THEN
                      vr_tab_vlavence(idx) := vr_tab_vlavence(idx) + vr_vlsrisco;
                      EXIT;
                    END IF;
                  END LOOP; 
                   
                  -- Acumular na variavel correspondente de acordo com a quantidade de dias
                  IF vr_qtdprazo <= 60 THEN
                    vr_vldiv060 := vr_vldiv060 + vr_vlsrisco;
                  ELSIF vr_qtdprazo <= 180 THEN
                    vr_vldiv180 := vr_vldiv180 + vr_vlsrisco;
                  ELSIF vr_qtdprazo <= 360 THEN
                    vr_vldiv360 := vr_vldiv360 + vr_vlsrisco;
                  ELSE
                    vr_vldiv999 := vr_vldiv999 + vr_vlsrisco;
                  END IF;
                END IF;  
                
              END IF;
              -- Se estivermos processando o ultimo registro Boleto + TpCobran�a e houver valor acumulado
              IF rw_crapbdt.seq_atu = rw_crapbdt.qtd_max AND vr_vldestit > 0 THEN
                -- Gerar Informacoes Docto 3020 --
                -- Incrementar sequencial do contrato
                vr_nrseqctr := vr_nrseqctr + 1;
                -- Criar registro de risco para documento 3020
                -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
                pc_grava_crapris(  pr_nrdconta => rw_crapass.nrdconta                             
                                  ,pr_dtrefere => vr_dtrefere
                                  ,pr_innivris => vr_risco_rating
                                  ,pr_qtdiaatr => ABS(vr_qtdiaatr)
                                  ,pr_vldivida => vr_vldestit
                                  ,pr_vlvec180 => nvl(vr_vltit180,0)
                                  ,pr_vlvec360 => nvl(vr_vltit360,0)
                                  ,pr_vlvec999 => nvl(vr_vltit999,0)
                                  ,pr_vldiv060 => nvl(vr_vldiv060,0)
                                  ,pr_vldiv180 => nvl(vr_vldiv180,0)
                                  ,pr_vldiv360 => nvl(vr_vldiv360,0)
                                  ,pr_vldiv999 => nvl(vr_vldiv999,0)
                                  ,pr_vlprjano => 0                            
                                  ,pr_vlprjaan => 0
                                  ,pr_inpessoa => rw_crapass.inpessoa                             
                                  ,pr_nrcpfcgc => rw_crapass.nrcpfcgc 
                                  ,pr_vlprjant => 0
                                  ,pr_inddocto => 1          -- Docto 3020
                                  ,pr_cdmodali => 0301 -- Desconto Duplicatas
                                  ,pr_nrctremp => vr_nrctrlim
                                  ,pr_nrseqctr => vr_nrseqctr                     
                                  ,pr_dtinictr => vr_dtinictr                                      
                                  ,pr_cdorigem => vr_cdorigem -- Desconto Titulos (4 ou 5 - Vem do loop) 
                                  ,pr_cdagenci => rw_crapass.cdagenci 
                                  ,pr_innivori => 0                     
                                  ,pr_cdcooper => pr_cdcooper                      
                                  ,pr_vlprjm60 => 0                     
                                  ,pr_dtdrisco => NULL                     
                                  ,pr_qtdriclq => 0                      
                                  ,pr_nrdgrupo => 0                                      
                                  ,pr_vljura60 => 0                                      
                                  ,pr_inindris => vr_risco_rating
                                  ,pr_cdinfadi => ' '                                    
                                  ,pr_nrctrnov => 0                                      
                                  ,pr_flgindiv => 0                                    
                                  ,pr_dsinfaux => ' '                            
                                  ,pr_dtprxpar => vr_dtprxpar                      
                                  ,pr_vlprxpar => vr_vlprxpar
                                  ,pr_qtparcel => vr_qtparcel
                                  ,pr_dtvencop => vr_dtvencop
                                  ,pr_des_erro => vr_des_erro
                                  ,pr_index_crapris => vr_index_crapris);
                -- Testar retorno de erro
                IF vr_des_erro IS NOT NULL THEN
                  -- Gerar erro e fazer rollback
                  vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:'||rw_crapass.nrdconta||', Dcto 3020 - Modal 0301(Desconto Duplicatas), Origem: '||vr_cdorigem||'. Detalhes: ' || vr_des_erro;
                  -- Gerar erro e roolback
                  RAISE vr_exc_undo;
                END IF;
                            
                -- Para cada registro de parcelas no vetor a vencer
                IF vr_tab_vlavence.COUNT > 0 THEN
                  FOR vr_ind IN vr_tab_vlavence.FIRST..vr_tab_vlavence.LAST LOOP
                    -- Se existe valor nesta posi��o
                    IF vr_tab_vlavence.EXISTS(vr_ind) AND vr_tab_vlavence(vr_ind) > 0 THEN
                      -- Dias em vencimento vem do vetor
                      vr_diasvenc := vr_tab_ddavence(vr_ind);
                      -- Buscar o c�digo do vencimento a lan�ar
                      vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc);
                      -- Chamar rotina de grava��o dos vencimentos do risco
                      pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta     --> Num. da conta
                                      ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                                      ,pr_innivris => vr_risco_rating         --> N�vel do risco
                                      ,pr_cdmodali => 0301                    --> Desconto Duplicatas
                                      ,pr_cdvencto => vr_cdvencto             --> Codigo do vencimento
                                      ,pr_nrctremp => vr_nrctrlim             --> Nro contrato emprestimo
                                      ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                                      ,pr_vlsrisco => vr_tab_vlavence(vr_ind) --> Valor do risco a lan�ar
                                      ,pr_des_erro => vr_des_erro);
                      -- Testar retorno de erro
                      IF vr_des_erro IS NOT NULL THEN
                        -- Gerar erro e roolback
                        RAISE vr_exc_erro;
                      END IF;
                    END IF;
                  END LOOP; -- Fim lan�amentos registros a vencer
                END IF; 
              END IF; -- Fim tratamento ultimo registro da flag e valor acumulado
            END LOOP; -- Fim das buscas de titulos com e sem cobran�a        
          END IF;
               
          -- Contratos de emprestimos com o BNDES
          FOR rw_crapebn IN cr_crapebn (pr_nrdconta => rw_crapass.nrdconta ) LOOP
            -- Para os atrasados ou em preju�zo
            IF rw_crapebn.insitctr IN ('A','P') THEN                
              -- Contar os dias do atraso
              vr_qtdiaatr := to_char(pr_rw_crapdat.dtmvtolt - rw_crapebn.dtppvenc);
              -- Definir nivel do risco conforme faixas de vencimento
              IF rw_crapebn.vlprac48 <> 0 OR rw_crapebn.vlprej48 <> 0 OR rw_crapebn.vlprej12 <> 0  THEN
                -- Prejuizo
                vr_innivris := 10;
              ELSIF rw_crapebn.vlvac540 <> 0 OR rw_crapebn.vlven540 <> 0 
                 OR rw_crapebn.vlven360 <> 0 OR rw_crapebn.vlven300 <> 0 OR rw_crapebn.vlven240 <> 0 THEN
                vr_innivris := 9;
              ELSIF rw_crapebn.vlven180 <> 0 THEN 
                vr_innivris := 8;
              ELSIF rw_crapebn.vlven150 <> 0 THEN
                vr_innivris := 7;
              ELSIF rw_crapebn.vlven120 <> 0 THEN
                vr_innivris := 6;
              ELSIF rw_crapebn.vlvenc90 <> 0 THEN
                vr_innivris := 5;
              ELSIF rw_crapebn.vlvenc60 <> 0 THEN
                vr_innivris := 4;
              ELSIF rw_crapebn.vlvenc30 <> 0 THEN
                vr_innivris := 3;
              ELSIF rw_crapebn.vlvenc14 <> 0 THEN
                vr_innivris := 2;
              ELSE
                vr_innivris := 1;
              END IF;      
            ELSE
              -- Qualquer outra situa��o n�o h� atraso
              vr_qtdiaatr := 0;
              vr_innivris := 2; -- 'A'             
            END IF;
            
            -- Manter sempre o maior risco
            IF vr_risco_rating > vr_innivris THEN
              vr_innivris := vr_risco_rating;
            END IF;
            
             -- Incrementar sequencial do contrato
            vr_nrseqctr := vr_nrseqctr + 1;
            
            -- Criar registro de risco
            -- Gravar temptable da crapris para posteriormente realizar o insert na tabela fisica
            pc_grava_crapris(  pr_nrdconta => rw_crapass.nrdconta                             
                              ,pr_dtrefere => vr_dtrefere
                              ,pr_innivris => vr_innivris
                              ,pr_qtdiaatr => vr_qtdiaatr                  
                              ,pr_vldivida => rw_crapebn.vlsdeved                                             
                              ,pr_vlvec180 => rw_crapebn.vlaat180                                             
                              ,pr_vlvec360 => rw_crapebn.vlaat180 + rw_crapebn.vlave360                       
                              ,pr_vlvec999 => rw_crapebn.vlasu360                                             
                              ,pr_vldiv060 => rw_crapebn.vlveat60                                             
                              ,pr_vldiv180 => rw_crapebn.vlveat60 + rw_crapebn.vlvenc61                       
                              ,pr_vldiv360 => rw_crapebn.vlveat60 + rw_crapebn.vlvenc61 + rw_crapebn.vlven181 
                              ,pr_vldiv999 => rw_crapebn.vlvsu360                                             
                              ,pr_vlprjano => rw_crapebn.vlprej12                                                     
                              ,pr_vlprjaan => rw_crapebn.vlprej48                                             
                              ,pr_inpessoa => rw_crapass.inpessoa                             
                              ,pr_nrcpfcgc => rw_crapass.nrcpfcgc 
                              ,pr_vlprjant => rw_crapebn.vlprac48
                              ,pr_inddocto => 1          -- Docto 3020
                              ,pr_cdmodali => 0499
                              ,pr_nrctremp => rw_crapebn.nrctremp
                              ,pr_nrseqctr => vr_nrseqctr                     
                              ,pr_dtinictr => rw_crapebn.dtinictr                                      
                              ,pr_cdorigem => 3
                              ,pr_cdagenci => rw_crapass.cdagenci 
                              ,pr_innivori => 0                     
                              ,pr_cdcooper => pr_cdcooper                      
                              ,pr_vlprjm60 => 0                     
                              ,pr_dtdrisco => NULL                     
                              ,pr_qtdriclq => 0                      
                              ,pr_nrdgrupo => 0                                      
                              ,pr_vljura60 => 0                                      
                              ,pr_inindris => vr_innivris
                              ,pr_cdinfadi => ' '                                    
                              ,pr_nrctrnov => 0                                      
                              ,pr_flgindiv => 0                                    
                              ,pr_dsinfaux => 'BNDES'                                
                              ,pr_dtprxpar => rw_crapebn.dtvctpro                      
                              ,pr_vlprxpar => rw_crapebn.vlparepr
                              ,pr_qtparcel => rw_crapebn.qtparctr
                              ,pr_dtvencop => rw_crapebn.dtfimctr
                              ,pr_des_erro => vr_des_erro
                              ,pr_index_crapris => vr_index_crapris);
            -- Testar retorno de erro
            IF vr_des_erro IS NOT NULL THEN
              -- Gerar erro e fazer rollback
              vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:'||rw_crapass.nrdconta||', Dcto 3020 - Modal 0499(Desconto Duplicatas), Origem: '||vr_cdorigem||'. Detalhes: ' || vr_des_erro;
              -- Gerar erro e roolback
              RAISE vr_exc_undo;
            END IF;
            
            -- Posicionar os valores de vencimentos      
            vr_tab_vlavence(1) := rw_crapebn.vlaven30;  -- Valor
            vr_tab_vlavence(2) := rw_crapebn.vlaven60;  -- Valor
            vr_tab_vlavence(3) := rw_crapebn.vlaven90;  -- Valor
            vr_tab_vlavence(4) := rw_crapebn.vlave180;  -- Valor
            vr_tab_vlavence(5) := rw_crapebn.vlave360;  -- Valor
            vr_tab_vlavence(6) := rw_crapebn.vlave720;  -- Valor
            vr_tab_vlavence(7) := rw_crapebn.vlav1080;  -- Valor
            vr_tab_vlavence(8) := rw_crapebn.vlav1440;  -- Valor
            vr_tab_vlavence(9) := rw_crapebn.vlav1800;  -- Valor
            vr_tab_vlavence(10) := rw_crapebn.vlav5400;  -- Valor
            vr_tab_vlavence(11) := rw_crapebn.vlaa5400;  -- Valor            
            vr_tab_vlavence(12) := rw_crapebn.vlvenc14;  -- Valor
            vr_tab_vlavence(13) := rw_crapebn.vlvenc30;  -- Valor
            vr_tab_vlavence(14) := rw_crapebn.vlvenc60;  -- Valor                  
            vr_tab_vlavence(15) := rw_crapebn.vlvenc90;  -- Valor                        
            vr_tab_vlavence(16) := rw_crapebn.vlven120;  -- Valor                    
            vr_tab_vlavence(17) := rw_crapebn.vlven150;  -- Valor                      
            vr_tab_vlavence(18) := rw_crapebn.vlven180;  -- Valor                    
            vr_tab_vlavence(19) := rw_crapebn.vlven240;  -- Valor                 
            vr_tab_vlavence(20) := rw_crapebn.vlven300;  -- Valor                 
            vr_tab_vlavence(21) := rw_crapebn.vlven360;  -- Valor                 
            vr_tab_vlavence(22) := rw_crapebn.vlven540;  -- Valor                   
            vr_tab_vlavence(23) := rw_crapebn.vlvac540;  -- Valor
                              
            -- Gravar valores na crapvri
            FOR vr_ind IN vr_tab_vlavence.FIRST..vr_tab_vlavence.LAST LOOP
              -- Testar valor nullo no vetor
              IF  NOT vr_tab_vlavence.EXISTS(vr_ind) OR vr_tab_vlavence(vr_ind) = 0  THEN
                CONTINUE;
              END IF;
              
              -- Dias em vencimento vem do vetor
              vr_diasvenc := vr_tab_ddavence(vr_ind);
              -- Buscar o c�digo do vencimento a lan�ar
              vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc);
              -- Chamar rotina de grava��o dos vencimentos do risco
              pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta     --> Num. da conta
                              ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                              ,pr_innivris => vr_innivris             --> N�vel do risco
                              ,pr_cdmodali => 0499                    --> Modalidade Financiamento
                              ,pr_cdvencto => vr_cdvencto             --> Codigo do vencimento
                              ,pr_nrctremp => rw_crapebn.nrctremp     --> Nro contrato emprestimo
                              ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                              ,pr_vlsrisco => vr_tab_vlavence(vr_ind) --> Valor do risco a lan�ar
                              ,pr_des_erro => vr_des_erro);
              -- Testar retorno de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar erro e roolback
                RAISE vr_exc_erro;
              END IF;       
              -- Limpar o vetor                
              vr_tab_vlavence(vr_ind) := 0;
            END LOOP;
            
            -- Para credito baixado como prejuizo ate 12 meses.
            IF  rw_crapebn.vlprej12 <> 0  THEN            
              -- Chamar rotina de grava��o dos vencimentos do risco
              pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta     --> Num. da conta
                              ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                              ,pr_innivris => vr_risco_rating         --> N�vel do risco
                              ,pr_cdmodali => 0499                    --> Modalidade Financiamento
                              ,pr_cdvencto => 310                     --> Codigo do vencimento
                              ,pr_nrctremp => rw_crapebn.nrctremp     --> Nro contrato emprestimo
                              ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                              ,pr_vlsrisco => rw_crapebn.vlprej12     --> Valor do risco a lan�ar
                              ,pr_des_erro => vr_des_erro);                                
              -- Testar retorno de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar erro e roolback
                RAISE vr_exc_erro;
              END IF;             
            END IF;
            
            -- Para credito baixado como prejuizo de 12 a 48 meses.
            IF rw_crapebn.vlprej48 <> 0 THEN            
              -- Chamar rotina de grava��o dos vencimentos do risco
              pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta     --> Num. da conta
                              ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                              ,pr_innivris => vr_risco_rating         --> N�vel do risco
                              ,pr_cdmodali => 0499                    --> Modalidade Financiamento
                              ,pr_cdvencto => 320                     --> Codigo do vencimento
                              ,pr_nrctremp => rw_crapebn.nrctremp     --> Nro contrato emprestimo
                              ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                              ,pr_vlsrisco => rw_crapebn.vlprej48     --> Valor do risco a lan�ar
                              ,pr_des_erro => vr_des_erro);                                
              -- Testar retorno de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar erro e roolback
                RAISE vr_exc_erro;
              END IF;             
            END IF;
            
            -- Para credito baixado como prejuizo acima de 48 meses.
            IF rw_crapebn.vlprac48 <> 0 THEN            
              -- Chamar rotina de grava��o dos vencimentos do risco
              pc_grava_crapvri(pr_nrdconta => rw_crapass.nrdconta     --> Num. da conta
                              ,pr_dtrefere => vr_dtrefere             --> Data de refer�ncia
                              ,pr_innivris => vr_risco_rating         --> N�vel do risco
                              ,pr_cdmodali => 0499                    --> Modalidade Financiamento
                              ,pr_cdvencto => 330                     --> Codigo do vencimento
                              ,pr_nrctremp => rw_crapebn.nrctremp     --> Nro contrato emprestimo
                              ,pr_nrseqctr => vr_nrseqctr             --> Seq contrato empr�stimo
                              ,pr_vlsrisco => rw_crapebn.vlprac48     --> Valor do risco a lan�ar
                              ,pr_des_erro => vr_des_erro);                                
              -- Testar retorno de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar erro e roolback
                RAISE vr_exc_erro;
              END IF;             
            END IF;                      
          END LOOP;  -- Loop da crapebn     
          
          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informacoes no banco de dados a cada 2500 registros processados, gravar tbm o controle
            -- de restart, pois qualquer rollback que ser� efetuado vai retornar a situa��o at� o ultimo commit
            IF Mod(cr_crapass%ROWCOUNT,2500) = 0 THEN
              --> criar crapris
              BEGIN
                FORALL idx IN INDICES OF vr_tab_crapris SAVE EXCEPTIONS 
                  INSERT INTO crapris
                           (  nrdconta, 
                              dtrefere, 
                              innivris, 
                              qtdiaatr, 
                              vldivida, 
                              vlvec180, 
                              vlvec360, 
                              vlvec999, 
                              vldiv060, 
                              vldiv180, 
                              vldiv360, 
                              vldiv999, 
                              vlprjano, 
                              vlprjaan, 
                              inpessoa, 
                              nrcpfcgc, 
                              vlprjant, 
                              inddocto, 
                              cdmodali, 
                              nrctremp, 
                              nrseqctr, 
                              dtinictr, 
                              cdorigem, 
                              cdagenci, 
                              innivori, 
                              cdcooper, 
                              vlprjm60, 
                              dtdrisco, 
                              qtdriclq, 
                              nrdgrupo, 
                              vljura60, 
                              inindris, 
                              cdinfadi, 
                              nrctrnov, 
                              flgindiv, 
                              dsinfaux, 
                              dtprxpar, 
                              vlprxpar, 
                              qtparcel, 
                              dtvencop)  
                              
                      VALUES (vr_tab_crapris(idx).nrdconta,
                              vr_tab_crapris(idx).dtrefere,
                              vr_tab_crapris(idx).innivris,
                              vr_tab_crapris(idx).qtdiaatr,
                              vr_tab_crapris(idx).vldivida,
                              vr_tab_crapris(idx).vlvec180,
                              vr_tab_crapris(idx).vlvec360,
                              vr_tab_crapris(idx).vlvec999,
                              vr_tab_crapris(idx).vldiv060,
                              vr_tab_crapris(idx).vldiv180,
                              vr_tab_crapris(idx).vldiv360,
                              vr_tab_crapris(idx).vldiv999,
                              vr_tab_crapris(idx).vlprjano,
                              vr_tab_crapris(idx).vlprjaan,
                              vr_tab_crapris(idx).inpessoa,
                              vr_tab_crapris(idx).nrcpfcgc,
                              vr_tab_crapris(idx).vlprjant,
                              vr_tab_crapris(idx).inddocto,
                              vr_tab_crapris(idx).cdmodali,
                              vr_tab_crapris(idx).nrctremp,
                              vr_tab_crapris(idx).nrseqctr,
                              vr_tab_crapris(idx).dtinictr,
                              vr_tab_crapris(idx).cdorigem,
                              vr_tab_crapris(idx).cdagenci,
                              vr_tab_crapris(idx).innivori,
                              vr_tab_crapris(idx).cdcooper,
                              vr_tab_crapris(idx).vlprjm60,
                              vr_tab_crapris(idx).dtdrisco,
                              vr_tab_crapris(idx).qtdriclq,
                              vr_tab_crapris(idx).nrdgrupo,
                              vr_tab_crapris(idx).vljura60,
                              vr_tab_crapris(idx).inindris,
                              vr_tab_crapris(idx).cdinfadi,
                              vr_tab_crapris(idx).nrctrnov,
                              vr_tab_crapris(idx).flgindiv,
                              vr_tab_crapris(idx).dsinfaux,
                              vr_tab_crapris(idx).dtprxpar,
                              vr_tab_crapris(idx).vlprxpar,
                              vr_tab_crapris(idx).qtparcel,
                              vr_tab_crapris(idx).dtvencop);                  
              EXCEPTION
                 WHEN others THEN
                   -- Gerar erro
                   vr_des_erro := 'Erro ao inserir na tabela crapris. '||
                                  SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
                  RAISE vr_exc_erro;
              END;
              
              vr_index_crapvri_temp := vr_tab_crapvri_temp.first;
              WHILE vr_index_crapvri_temp IS NOT NULL LOOP
                
                vr_tab_crapvri(vr_tab_crapvri.count + 1) := vr_tab_crapvri_temp(vr_index_crapvri_temp);              
                vr_index_crapvri_temp := vr_tab_crapvri_temp.next(vr_index_crapvri_temp);
              END LOOP;
              
              
              -- Atualizar crapvri
              BEGIN
                FORALL idx IN 1..vr_tab_crapvri.count SAVE EXCEPTIONS
                  INSERT INTO crapvri (cdcooper
                             ,nrdconta
                             ,dtrefere
                             ,innivris
                             ,cdmodali
                             ,cdvencto
                             ,nrctremp
                             ,nrseqctr
                             ,vldivida)
                      VALUES (vr_tab_crapvri(idx).cdcooper
                             ,vr_tab_crapvri(idx).nrdconta
                             ,vr_tab_crapvri(idx).dtrefere
                             ,vr_tab_crapvri(idx).innivris
                             ,vr_tab_crapvri(idx).cdmodali
                             ,vr_tab_crapvri(idx).cdvencto
                             ,vr_tab_crapvri(idx).nrctremp
                             ,vr_tab_crapvri(idx).nrseqctr
                             ,nvl(vr_tab_crapvri(idx).vldivida,0)); 
                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_des_erro := 'Erro ao atualizar CRAPVRI com Merge. ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
                  RAISE vr_exc_erro;
              END;  
              --Limpar tabela memoria
              vr_tab_crapris.DELETE;
              vr_tab_crapvri.DELETE; 
              vr_tab_crapvri_temp.DELETE;
              -- Atualizar a tabela de restart
              BEGIN
                UPDATE crapres res
                   SET res.nrdconta = rw_crapass.nrdconta  -- conta da aplica��o atual
                 WHERE res.rowid = rw_crapres.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  vr_des_erro := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta:'||rw_crapass.nrdconta||'. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
              END;
              -- Finalmente efetua commit
              COMMIT;
                
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_undo THEN
            -- Desfazer transacoes desde o ultimo commit
            ROLLBACK;
            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_erro;
        END;
      END LOOP; --> Fim loop rw_crapass
      
      --> Criar crapris
      BEGIN
        FORALL idx IN INDICES OF vr_tab_crapris SAVE EXCEPTIONS 
          INSERT INTO crapris
                   (  nrdconta, 
                      dtrefere, 
                      innivris, 
                      qtdiaatr, 
                      vldivida, 
                      vlvec180, 
                      vlvec360, 
                      vlvec999, 
                      vldiv060, 
                      vldiv180, 
                      vldiv360, 
                      vldiv999, 
                      vlprjano, 
                      vlprjaan, 
                      inpessoa, 
                      nrcpfcgc, 
                      vlprjant, 
                      inddocto, 
                      cdmodali, 
                      nrctremp, 
                      nrseqctr, 
                      dtinictr, 
                      cdorigem, 
                      cdagenci, 
                      innivori, 
                      cdcooper, 
                      vlprjm60, 
                      dtdrisco, 
                      qtdriclq, 
                      nrdgrupo, 
                      vljura60, 
                      inindris, 
                      cdinfadi, 
                      nrctrnov, 
                      flgindiv, 
                      dsinfaux, 
                      dtprxpar, 
                      vlprxpar, 
                      qtparcel, 
                      dtvencop)  
                              
              VALUES (vr_tab_crapris(idx).nrdconta,
                      vr_tab_crapris(idx).dtrefere,
                      vr_tab_crapris(idx).innivris,
                      vr_tab_crapris(idx).qtdiaatr,
                      vr_tab_crapris(idx).vldivida,
                      vr_tab_crapris(idx).vlvec180,
                      vr_tab_crapris(idx).vlvec360,
                      vr_tab_crapris(idx).vlvec999,
                      vr_tab_crapris(idx).vldiv060,
                      vr_tab_crapris(idx).vldiv180,
                      vr_tab_crapris(idx).vldiv360,
                      vr_tab_crapris(idx).vldiv999,
                      vr_tab_crapris(idx).vlprjano,
                      vr_tab_crapris(idx).vlprjaan,
                      vr_tab_crapris(idx).inpessoa,
                      vr_tab_crapris(idx).nrcpfcgc,
                      vr_tab_crapris(idx).vlprjant,
                      vr_tab_crapris(idx).inddocto,
                      vr_tab_crapris(idx).cdmodali,
                      vr_tab_crapris(idx).nrctremp,
                      vr_tab_crapris(idx).nrseqctr,
                      vr_tab_crapris(idx).dtinictr,
                      vr_tab_crapris(idx).cdorigem,
                      vr_tab_crapris(idx).cdagenci,
                      vr_tab_crapris(idx).innivori,
                      vr_tab_crapris(idx).cdcooper,
                      vr_tab_crapris(idx).vlprjm60,
                      vr_tab_crapris(idx).dtdrisco,
                      vr_tab_crapris(idx).qtdriclq,
                      vr_tab_crapris(idx).nrdgrupo,
                      vr_tab_crapris(idx).vljura60,
                      vr_tab_crapris(idx).inindris,
                      vr_tab_crapris(idx).cdinfadi,
                      vr_tab_crapris(idx).nrctrnov,
                      vr_tab_crapris(idx).flgindiv,
                      vr_tab_crapris(idx).dsinfaux,
                      vr_tab_crapris(idx).dtprxpar,
                      vr_tab_crapris(idx).vlprxpar,
                      vr_tab_crapris(idx).qtparcel,
                      vr_tab_crapris(idx).dtvencop);                  
      EXCEPTION
         WHEN others THEN
           -- Gerar erro
           vr_des_erro := 'Erro ao inserir na tabela crapris. '||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_erro;
      END;
      
      vr_index_crapvri_temp := vr_tab_crapvri_temp.first;
      WHILE vr_index_crapvri_temp IS NOT NULL LOOP
                
        vr_tab_crapvri(vr_tab_crapvri.count + 1) := vr_tab_crapvri_temp(vr_index_crapvri_temp);              
        vr_index_crapvri_temp := vr_tab_crapvri_temp.next(vr_index_crapvri_temp);
      END LOOP;
              
      -- Atualizar crapvri
      BEGIN
        FORALL idx IN 1..vr_tab_crapvri.count SAVE EXCEPTIONS
          
          INSERT INTO crapvri (cdcooper
                     ,nrdconta
                     ,dtrefere
                     ,innivris
                     ,cdmodali
                     ,cdvencto
                     ,nrctremp
                     ,nrseqctr
                     ,vldivida)
              VALUES (vr_tab_crapvri(idx).cdcooper
                     ,vr_tab_crapvri(idx).nrdconta
                     ,vr_tab_crapvri(idx).dtrefere
                     ,vr_tab_crapvri(idx).innivris
                     ,vr_tab_crapvri(idx).cdmodali
                     ,vr_tab_crapvri(idx).cdvencto
                     ,vr_tab_crapvri(idx).nrctremp
                     ,vr_tab_crapvri(idx).nrseqctr
                     ,nvl(vr_tab_crapvri(idx).vldivida,0));
                    
      EXCEPTION
        WHEN OTHERS THEN
          vr_des_erro := 'Erro ao atualizar CRAPVRI com Merge. ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;
               
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'Erro pc_atribui_risco_associado. --> Detalhes: '||vr_des_erro ||' '||sqlerrm;
        WHEN OTHERS THEN
          pr_des_erro := 'Erro pc_atribui_risco_associado, Erro: ' || SQLERRM;
      END pc_atribui_risco_associado;

    -----------------------------------------
    -- Inicio Bloco Principal pc_CRPS310_i
    -----------------------------------------    
    BEGIN
      
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => pr_cdprogra
                                ,pr_action => 'PC_CRPS310_I');

      -- Incluido controle de Log inicio programa 
      pc_controla_log_batch(1, '01 Inicio crps310_i '||pr_cdagenci);

      -- Para os programas em paralelo devemos buscar o array crapdat.
      -- Leitura do calend�rio da cooperativa
      IF pr_rw_crapdat.dtmvtolt IS NULL THEN
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat
          INTO pr_rw_crapdat;
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Carregar a tabela de de-para do risco como texto e como valor
      vr_tab_risco(' ') := 2;
      vr_tab_risco('AA') := 1;
      vr_tab_risco('A') := 2;
      vr_tab_risco('B') := 3;
      vr_tab_risco('C') := 4;
      vr_tab_risco('D') := 5;
      vr_tab_risco('E') := 6;
      vr_tab_risco('F') := 7;
      vr_tab_risco('G') := 8;
      vr_tab_risco('H') := 9;
      vr_tab_risco('HH') := 10;
      -- Carregar a tabela de-para do risco como valor e seu texto
      vr_tab_risco_num(0) := 'A';
      vr_tab_risco_num(1) := 'AA';
      vr_tab_risco_num(2) := 'A';
      vr_tab_risco_num(3) := 'B';
      vr_tab_risco_num(4) := 'C';
      vr_tab_risco_num(5) := 'D';
      vr_tab_risco_num(6) := 'E';
      vr_tab_risco_num(7) := 'F';
      vr_tab_risco_num(8) := 'G';
      vr_tab_risco_num(9) := 'H';
      vr_tab_risco_num(10) := 'HH';
      -- Carregar a temp table com os dias de vencimento
      vr_tab_ddavence(1) := 30;
      vr_tab_ddavence(2) := 60;
      vr_tab_ddavence(3) := 90;
      vr_tab_ddavence(4) := 180;
      vr_tab_ddavence(5) := 360;
      vr_tab_ddavence(6) := 720;
      vr_tab_ddavence(7) := 1080;
      vr_tab_ddavence(8) := 1440;
      vr_tab_ddavence(9) := 1800;
      vr_tab_ddavence(10) := 5400;
      vr_tab_ddavence(11) := 9999;
      vr_tab_ddavence(11) := 5401;                 
      vr_tab_ddavence(12) := -14;  
      vr_tab_ddavence(13) := -30;   
      vr_tab_ddavence(14) := -60; 
      vr_tab_ddavence(15) := -90;
      vr_tab_ddavence(16) := -120;  
      vr_tab_ddavence(17) := -150; 
      vr_tab_ddavence(18) := -180; 
      vr_tab_ddavence(19) := -240; 
      vr_tab_ddavence(20) := -300;  
      vr_tab_ddavence(21) := -360; 
      vr_tab_ddavence(22) := -540;  
      vr_tab_ddavence(23) := -541; 
      
      -- Carregar a temp table com os dias vencidos
      vr_tab_ddvencid(1) := 14;
      vr_tab_ddvencid(2) := 30;
      vr_tab_ddvencid(3) := 60;
      vr_tab_ddvencid(4) := 90;
      vr_tab_ddvencid(5) := 120;
      vr_tab_ddvencid(6) := 150;
      vr_tab_ddvencid(7) := 180;
      vr_tab_ddvencid(8) := 240;
      vr_tab_ddvencid(9) := 300;
      vr_tab_ddvencid(10) := 360;
      vr_tab_ddvencid(11) := 540;
      vr_tab_ddvencid(12) := 9999;
      -- Carregar a temp-table de vencimentos e quantidade de dias
      vr_tab_vencto(230) := 90;
      vr_tab_vencto(240) := 120;
      vr_tab_vencto(245) := 150;
      vr_tab_vencto(250) := 180;
      vr_tab_vencto(255) := 240;
      vr_tab_vencto(260) := 300;
      vr_tab_vencto(270) := 360;
      vr_tab_vencto(280) := 540;
      vr_tab_vencto(290) := 540;
      
      --> Limpar variaveis
      vr_tab_craplcr.delete;
      vr_tab_crapnrc.delete;
      vr_tab_crapsld.delete;
      vr_tab_ctabdc.delete;
      vr_tab_contas_risco_soberano.delete;
      
      -- Busca do cadastro de linhas de cr�dito de empr�stimo
      FOR rw_craplcr IN cr_craplcr LOOP
        -- Armazenar na tabela de mem�ria a descri��o
        vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
        -- Percentual de Juros de Mora
        vr_tab_craplcr(rw_craplcr.cdlcremp).perjurmo := rw_craplcr.perjurmo;
      END LOOP;
      
      -- Buscar notas de rating do contrado da conta
      FOR rw_crapnrc IN cr_crapnrc LOOP
        -- Carregar a temp-table com as informa��es do
        -- registro. Este processo faz com que diminuamos
        -- as leituras no banco pois n�o teremos esse select
        -- para cada conta, mas sim direto na temp-table
        vr_tab_crapnrc(rw_crapnrc.nrdconta).indrisco := rw_crapnrc.indrisco;
        vr_tab_crapnrc(rw_crapnrc.nrdconta).dtmvtolt := rw_crapnrc.dtmvtolt;
      END LOOP;
      -- Buscar tamb�m as informa��es da CRAPSLD - Saldos da Conta
      -- seguimos o mesmo esquema acima, ou seja, diminuimos as idas ao
      -- banco para melhorar a performance
      FOR rw_crapsld IN cr_crapsld LOOP
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := rw_crapsld.vlsdchsl;        
        vr_tab_crapsld(rw_crapsld.nrdconta).vlbloque := nvl(rw_crapsld.vlsdbloq,0) + nvl(rw_crapsld.vlsdblpr,0) + nvl(rw_crapsld.vlsdblfp,0);                    
        vr_tab_crapsld(rw_crapsld.nrdconta).dtrisclq := rw_crapsld.dtrisclq;
        vr_tab_crapsld(rw_crapsld.nrdconta).qtdriclq := rw_crapsld.qtdriclq;
      END LOOP;
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
          vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 151);
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;
      -- Buscar par�metros de saldo devedor e risco em conta
      -- no par�metro de sistema RISCOBACEN
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'DIASCREDLQ'
                                               ,pr_tpregist => 000);
      -- Se a variavel voltou vazia
      IF vr_dstextab IS NULL THEN
        -- Buscar descri��o da cr�tica 210
        vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 210);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      ELSE
        -- Separar as informa��es retornadas no texto gen�rico
        vr_qtdrisco := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,5,3));
      END IF;
      -- Se o programa chamador � o 310
      IF pr_cdprogra = 'CRPS310' THEN
        -- Utilizar o final do m�s como data
        vr_dtrefere := pr_rw_crapdat.dtultdia;
      ELSE
        -- Utilizar a data atual
        vr_dtrefere := pr_rw_crapdat.dtmvtolt;
      END IF;
      -- Buscar somatorio prejuizo historico 382,383
      OPEN cr_craplem_prejuz(pr_dtrefere => vr_dtrefere) ; 
      LOOP
        FETCH cr_craplem_prejuz BULK COLLECT INTO r_craplem;
        EXIT WHEN r_craplem.COUNT = 0;
            
        FOR idx IN r_craplem.first..r_craplem.last LOOP
          vr_index_prejuz:= lpad(r_craplem(idx).nrdconta,10,'0')||
                            lpad(r_craplem(idx).nrctremp,10,'0');
          vr_tab_prejuz(vr_index_prejuz):= r_craplem(idx).vllanmto;
        END LOOP; 
            
      END LOOP; 
      CLOSE cr_craplem_prejuz;
      r_craplem.delete;
     
      -- Buscar todas as informa��es de Borderos de Cheques
      FOR rw_crapbdc IN cr_crapbdc(pr_dtrefere => vr_dtrefere) LOOP
        -- Criar a chave para grava��o na tabela interna da bdc
        vr_dschave_bdc := to_char(rw_crapbdc.dtmvtolt,'yyyymmdd')||to_char(rw_crapbdc.sqatureg,'fm000000000000');
        -- Adicionar o registro na temp-table interna, j� adicionando tamb�m na temp-table
        -- externa que � chaveada pela conta.
        vr_tab_ctabdc(rw_crapbdc.nrdconta).tbcrapbdc(vr_dschave_bdc).nrctrlim := rw_crapbdc.nrctrlim;
        vr_tab_ctabdc(rw_crapbdc.nrdconta).tbcrapbdc(vr_dschave_bdc).dtlibbdc := rw_crapbdc.dtlibbdc;
        vr_tab_ctabdc(rw_crapbdc.nrdconta).tbcrapbdc(vr_dschave_bdc).nrborder := rw_crapbdc.nrborder;
      END LOOP;
      -- Buscar contas com cadastro de borderos de descontos de titulos
      FOR rw_crapbdt IN cr_crapbdt_ini(pr_dtrefere => vr_dtrefere) LOOP
        -- Adiciona a conta ao vetor
        vr_tab_ctabdt(rw_crapbdt.nrdconta) := rw_crapbdt.nrdconta;
      END LOOP;      
      
      -- Buscar todos os cheques contidos por bordero
      FOR rw_crapcdb IN cr_crapcdb LOOP
        -- Somente considerar cheques sem devolu��o, ou com devolu��o posterior a data de refer�ncia
        IF rw_crapcdb.dtdevolu IS NULL OR rw_crapcdb.dtdevolu > vr_dtrefere THEN
           -- Criar os cheques na tabela interna de cheques dentro da tabela externa de border�s
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).nrdconta := rw_crapcdb.nrdconta;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).vlliquid := rw_crapcdb.vlliquid;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).dtlibera := rw_crapcdb.dtlibera;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).dtlibbdc := rw_crapcdb.dtlibbdc;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).cdcmpchq := rw_crapcdb.cdcmpchq;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).cdbanchq := rw_crapcdb.cdbanchq;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).cdagechq := rw_crapcdb.cdagechq;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).nrctachq := rw_crapcdb.nrctachq;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).nrcheque := rw_crapcdb.nrcheque;
           vr_tab_bord_cdb(rw_crapcdb.nrborder).tbcrapcdb(rw_crapcdb.progress_recid).dtdevolu := rw_crapcdb.dtdevolu;
        END IF;
      END LOOP;  
      
      --> Carregar temptable da maior atraso de parcela
      FOR rw_crappep_maior IN cr_crappep_maior_carga LOOP
        vr_idxpep := lpad(pr_cdcooper,5,'0')||lpad(rw_crappep_maior.nrdconta,10,'0')||lpad(rw_crappep_maior.nrctremp,10,'0');
        vr_tab_crappep_maior(vr_idxpep) := rw_crappep_maior.dtvencto;
      END LOOP;
      
      --> Buscar vencimentos daos emprestimos de cessao de cartao
      FOR rw_cessao_carga IN cr_cessao_carga LOOP
        vr_idxpep := lpad(pr_cdcooper,5,'0')||lpad(rw_cessao_carga.nrdconta,10,'0')||lpad(rw_cessao_carga.nrctremp,10,'0');
        vr_tab_crappep_maior(vr_idxpep) := rw_cessao_carga.dtvencto;
        vr_tab_cessoes(vr_idxpep) := rw_cessao_carga.dtvencto;
      END LOOP;
      
      --> Carrega Temp-Table contendo as contas com risco soberano
 	    pc_cria_table_risco_soberano(pr_cdcooper                  => pr_cdcooper
                                  ,pr_tab_contas_risco_soberano => vr_tab_contas_risco_soberano);


      -- Buscar quantidade parametrizada de Jobs - 13/03/2018
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo( pr_cdcooper   --pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da coopertiva
                                                   , pr_cdprogra); --pr_cdprogra  IN crapprg.cdprogra%TYPE --> C�digo do programa

      -- Rotina Paralelismo 1 - Processar quando n�o utiliza JOB ou � Executor Principal do Paralelismo
      --                      - Efetuar primeiras Valida��es
      --                      - Executar integracao todas cooperativas
      if (pr_rw_crapdat.inproces > 2   --  >2 Processo Batch
      and pr_cdagenci = 0              --  0=execu��o normal  >0 Paralelismo
      and vr_qtdjobs  > 0)             --  0=execu��o normar  >0 Paralelismo (Executor Principal)
      or (pr_rw_crapdat.inproces <= 2) --  1=On Line  2=Agendado             (N�o utiliza JOB)
      or (vr_qtdjobs) = 0  then        --  0=execu��o normar  >0 Paralelismo (N�p utiliza JOB)

        -- Log controle processo
        pc_controla_log_batch(1, '02 inicia processo - '||pr_cdagenci);

        --Grava LOG sobre o �nicio da execu��o da procedure na tabela tbgen_prglog
        vr_idlog_ini_ger := null;
        pc_log_programa(pr_dstiplog   => 'I',    
                        pr_cdprograma => pr_cdprogra,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger);
       
        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
           -- Levantar exce��o
           pr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
           RAISE vr_exc_erro;
        END IF;                   
      END IF; --Fim Paralelismo 1;

      -- Rotina Paralelismo 2 - Processo do Executor Principal do Paralelismo
      --                      - Selecionar Agencias para o Processo JOB, 
      --                      - Cria JOBS Paralelos e controle encerramento destes JOBS
      if pr_rw_crapdat.inproces > 2  -- Processo Batch
      and pr_cdagenci = 0            -- Execu��o sem paralelismo
      and vr_qtdjobs  > 0  then      -- Execu��o do paralelismo

        pc_controla_log_batch(1,'03 Controla JOBS - '||pr_cdagenci);

        --Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_ID_paralelo;
        
       -- Verifica se algum job paralelo executou com erro
        vr_qterro := 0;
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => pr_cdprogra,
                                                      pr_dtmvtolt    => pr_rw_crapdat.dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);          
                                                  
        -- Retorna as ag�ncias, com poupan�a programada
        for rw_crapass_age in cr_crapass_age (pr_cdcooper
                                             ,pr_rw_crapdat.dtmvtolt
                                             ,vr_qterro
                                             ,pr_cdprogra) loop
                                          
          -- Montar o prefixo do c�digo do programa para o jobname
          vr_jobname := 'crps310_i_' || rw_crapass_age.cdagenci || '$';  
    
          -- Cadastra o programa paralelo
          gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(rw_crapass_age.cdagenci,3,'0') --> Utiliza a ag�ncia como id programa
                                    ,pr_des_erro => pr_dscritic);
                                
          -- Testar saida com erro
          if pr_dscritic is not null then
            -- Levantar exce�ao
            raise vr_exc_erro;
          end if;
      
          -- Montar o bloco PLSQL que ser� executado
          -- Ou seja, executaremos a gera��o dos dados
          -- para a ag�ncia atual atraves de Job no banco
          vr_dsplsql := 'DECLARE' || chr(13) ||
                        '  wpr_cdcritic NUMBER;' || chr(13) ||
                        '  wpr_dscritic VARCHAR2(1500);' || chr(13) ||
                        '  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;' || chr(13) || 
                        'BEGIN' || chr(13) || 
                        '  CECRED.pc_crps310_i( '|| pr_cdcooper   || ',' ||
                                                    rw_crapass_age.cdagenci || ',' ||
                                                    vr_idparale   || ',' ||
                                                    'rw_crapdat'  || ',' || 
                                                    ''''|| pr_cdprogra   || ''',' ||
                                                    pr_vlarrasto  || ',' ||
                                                    pr_flgresta   || ',' ||
                                                    pr_nrctares   || ',' ||
                                                    ''''||pr_dsrestar   || ''',' ||
                                                    pr_inrestar   || ',' ||         
                                                   'wpr_cdcritic, wpr_dscritic);' ||
                                                chr(13) ||
                      'END;';
                     
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> C�digo da cooperativa
                                ,pr_cdprogra => pr_cdprogra  --> C�digo do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => pr_dscritic);    
                            
          -- Testar saida com erro
          if pr_dscritic is not null then 
            -- Levantar exce�ao
            raise vr_exc_erro;
          end if;
      
          -- Chama rotina que ir� pausar este processo controlador
          -- caso tenhamos excedido a quantidade de JOBS em execu�ao
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => vr_qtdjobs --> M�ximo de 10 jobs neste processo
                                      ,pr_des_erro => pr_dscritic);
          -- Testar saida com erro
          if pr_dscritic is not null then 
            -- Levantar exce�ao
            raise vr_exc_erro;
          end if;                                 
        end loop;
    
        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- at� que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => pr_dscritic);


         -- Retorna quantidade de PA (ag�ncias) com erro para reprocesso
         vr_tot_paerr := 0;
         for rw_crapass_err in cr_crapass_err (pr_cdcooper
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_cdprogra) loop          
           vr_tot_paerr := vr_tot_paerr +1;
         end loop;

         -- Segue o processamento caso n�o existam PA's com erro
         if vr_tot_paerr > 0 then
           -- Levantar exce�ao
           pr_dscritic := 'Processo interrompido. N�o copncluiram todos os PAs.';
           raise vr_exc_erro;
         end if;
      end if;  -- Fim Paralelismo 2


      -- Rotina Paralelismo 3 - Processar quando JOB ou N�o Paralelismmo
      --                      - Executar Integracao Cecred
      --                      - executar Cobranca (Emprestimo/Acordo)
      if (pr_rw_crapdat.inproces > 2     -- Processo Batch
      and pr_cdagenci > 0                -- Agencia
      and vr_qtdjobs  > 0)               -- Quantidade de jobs simultaneos
      or (vr_qtdjobs  = 0)               -- ou n�o utiliza JOB
      or (pr_rw_crapdat.inproces <= 2) then -- ou processo On Line/Agendado    
                                   
        -- Buscar informa��es da poupan�a programada

        -- Controla execucao dos JOBS
        if (pr_rw_crapdat.inproces > 2  -- Processo Batch
        and pr_cdagenci > 0             -- Agencia
        and vr_qtdjobs  > 0) then       -- Quantidade de jobs simultaneos
        
          -- Grava controle de batch por ag�ncia
          gene0001.pc_grava_batch_controle( pr_cdcooper              --pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                           ,pr_cdprogra              --pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                           ,pr_rw_crapdat.dtmvtolt   --pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                           ,1                        --pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                           ,pr_cdagenci              --pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE -- Codigo do agrupador conforme (tpagrupador)
                                           ,null                     --pr_cdrestart   IN tbgen_batch_controle.cdrestart%TYPE   -- Controle do registro de restart em caso de erro na execucao
                                           ,1                        --pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                           ,vr_idcontrole            --pr_idcontrole OUT tbgen_batch_controle.idcontrole%TYPE  -- ID de Controle
                                           ,pr_cdcritic              --pr_cdcritic   OUT crapcri.cdcritic%TYPE                 -- Codigo da critica
                                           ,pr_dscritic              --pr_dscritic   OUT crapcri.dscritic%TYPE
                                           );      

          -- Testar saida com erro
          if pr_dscritic is not null then 
            -- Levantar exce�ao
            raise vr_exc_erro;
          end if;  

          --Grava LOG sobre o �nicio da execu��o da procedure na tabela tbgen_prglog
          vr_idlog_ini_par := null;
          pc_log_programa(pr_dstiplog   => 'I',    
                          pr_cdprograma => pr_cdprogra||'_'||pr_cdagenci,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par);
        end if;

        --Executar Atribui��o Risco para os Associados  ***************
        pc_atribui_risco_associado (pr_des_erro => vr_des_erro);
        --Se ocorreu erro
        IF vr_des_erro IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        if (pr_rw_crapdat.inproces > 2  -- Processo Batch
        and pr_cdagenci > 0             -- Agencia
        and vr_qtdjobs  > 0) then       -- Quantidade de jobs simultaneos
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => pr_cdprogra||'_'||pr_cdagenci,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par);  
        end if;
      end if;  -- Fim Paralelismo 3

      --Limpar tabela memoria
      vr_tab_crapris.DELETE;
      vr_tab_crapvri.DELETE; 
      vr_tab_crapvri_temp.DELETE;
      vr_tab_crapsld.DELETE;
      vr_tab_bord_cdb.DELETE;
      vr_tab_ctabdc.DELETE;
                                           
      --
      -- Rotina Paralelismo 6 - Executar Processo JOB
      --                      - Finaliza o Paralismo do JOB Arquivo ABBC
      if pr_rw_crapdat.inproces > 2  -- Processo Batch
      and pr_cdagenci > 0         -- Paralelismo
      and vr_qtdjobs  > 0  then   -- Paralelismo
  
        -- Atualiza finaliza��o do batch na tabela de controle 
        if vr_idcontrole <> 0 then
          gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                             ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                             ,pr_dscritic   => pr_dscritic);  
        end if;  

        -- Encerrar o job do processamento paralelo dessa ag�ncia
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => pr_dscritic);  

        -- Incluido controle de Log fim programa - Chamado 714566 - 11/08/2017 
        pc_controla_log_batch(1, '14 Grava crps310_i - '||pr_cdagenci);

      -- Efetuar Commit de informa��es pendentes de grava��o
      COMMIT;
      end if;  -- Fim Paralelismo 6

      -- Rotina Paralelismo 7 - Executar principal ou N�o Paralelismo
      if (pr_rw_crapdat.inproces > 2   -- Processo Batch
      and pr_cdagenci = 0              -- N�o Paralelismo
      and vr_qtdjobs  > 0)             -- Paralelismo
      or (pr_rw_crapdat.inproces <= 2) -- Processo On Line/Agendado
      or (vr_qtdjobs  = 0)    then     -- N�o Paralelismo

        if vr_idcontrole <> 0 then
          -- Atualiza finaliza��o do batch na tabela de controle 
          gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                             ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                             ,pr_dscritic   => pr_dscritic);        
        end if;  

        --Grava LOG sobre o fim da execu��o da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => pr_cdprogra,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger);

        -- Incluido controle de Log fim programa - Chamado 714566 - 11/08/2017 
        pc_controla_log_batch(1, '15 Grava crps310_i - '||pr_cdagenci);

        --Salvar informacoes no banco de dados
        COMMIT; 
      
      -- Somente no processo mensal
      IF to_char(pr_rw_crapdat.dtmvtolt,'mm') != to_char(pr_rw_crapdat.dtmvtopr,'mm') THEN
        -- Acionar rotina para integra��o dos contratos oriundos de Cart�es Cr�dito BB
        vr_dsplsql := 'BEGIN'||chr(13)
                   || '  risc0002.pc_gera_risco_cartao_vip_proc('||pr_cdcooper
                                                              ||','''||pr_cdprogra||''''
                                                              ||','''||to_char(pr_rw_crapdat.dtmvtolt,'dd/mm/rrrr')||''''
                                                              ||','''||to_char(vr_dtrefere,'dd/mm/rrrr')||''');'||chr(13)
                   || 'END;';
        -- Montar o prefixo do c�digo do programa para o jobname
        vr_jobname := 'crps310_carga_vip_$';
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> C�digo da cooperativa
                              ,pr_cdprogra  => pr_cdprogra  --> C�digo do programa
                              ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva   => NULL          --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                              ,pr_jobname   => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro  => vr_des_erro);
      END IF;  
      
        pc_controla_log_batch(1, '16 Processa Arrasto: '||pr_cdagenci);
     
      -- Inicializa��o do XML para o relatorio 349
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
      -- Chamar rotina de gera��o do arrasto
      pc_efetua_arrasto(pr_des_erro => vr_des_erro);
      -- Se retornou derro
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Chamar rotina de gera��o do arrasto por CPF/CNPJ
      pc_efetua_arrasto_cpfcnpj(pr_des_erro => vr_des_erro);
      -- Se retornou derro
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      

      -- Fechar o xml de dados
      pc_escreve_xml('</raiz>');
      -- Busca do diret�rio base da cooperativa para a gera��o de relat�rios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper);
                                            
      -- Solicitar a gera��o do relat�rio crrl349
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/preju'                        --> N� base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl349.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem par�metros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl349.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Gera�ao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impress�o (Imprim.p)
                                 ,pr_nmformul  => '132col'                             --> Nome do formul�rio para impress�o
                                 ,pr_nrcopias  => 1                                    --> N�mero de c�pias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_des_erro);                        --> Sa�da com erro
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
      -- Testar se houve erro
      IF vr_des_erro IS NOT NULL THEN
        -- Gerar exce��o
        RAISE vr_exc_erro;
      END IF;

      -- Efetuar Commit de informa��es pendentes de grava��o
      COMMIT;
      
        pc_controla_log_batch(1, '17 Empr�stimos acima 60: '||pr_cdagenci);
      
      -- Calculo dos juros para empr�stimos acima 60 dias
      pc_calcula_juros_emp_60dias(pr_dtrefere => vr_dtrefere
                                 ,pr_des_erro => vr_des_erro);
      -- Se retornou derro
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

        pc_controla_log_batch(1, '18 FIM: '||pr_cdagenci);

      -- Efetuar Commit de informa��es pendentes de grava��o
      COMMIT;
      END IF;  --Fim Paralelismo 7

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        if pr_rw_crapdat.inproces > 2
        and pr_cdagenci > 0
        and vr_qtdjobs  > 0  then    
          -- Processo JOB           

          rollback;

          pc_controla_log_batch(1, 'Erro: '||pr_cdagenci||' - '||vr_des_erro);

          -- Grava LOG de ocorr�ncia final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => pr_cdprogra||'_'||pr_cdagenci,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,  -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par);  
  
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => pr_cdprogra||'_'||pr_cdagenci,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  
  
          -- Encerrar o job do processamento paralelo dessa ag�ncia
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                      ,pr_des_erro => pr_dscritic);  
        END IF;

        -- Se n�o foi passado o c�digo da critica
        IF pr_cdcritic IS NULL THEN
          -- Utilizaremos c�digo zero, pois foi erro n�o cadastrado
          pr_cdcritic := 0;
        END IF;
        -- Retornar o erro tratado
        pr_dscritic := 'Erro na rotina PC_CRPS310_I. Detalhes: '||vr_des_erro;

      WHEN OTHERS THEN

        -- Retornar o erro n�o tratado
        pc_controla_log_batch(1, 'Erro n�o tratado: '||pr_cdagenci||' - '||sqlerrm);
        
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        if pr_rw_crapdat.inproces > 2
        and pr_cdagenci > 0
        and vr_qtdjobs  > 0  then    
          -- Processo JOB           

          rollback;

          pc_controla_log_batch(1, 'Erro: '||pr_cdagenci||' - '||vr_des_erro);

          -- Grava LOG de ocorr�ncia final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => pr_cdprogra||'_'||pr_cdagenci,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,  -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par);  
  
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => pr_cdprogra||'_'||pr_cdagenci,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  
  
          -- Encerrar o job do processamento paralelo dessa ag�ncia
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                      ,pr_des_erro => pr_dscritic);  
        END IF;
    
        -- Retornar o erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro n�o tratado na rotina PC_CRPS310_I. Detalhes: '||sqlerrm;
    END;
  END PC_CRPS310_I;
/
