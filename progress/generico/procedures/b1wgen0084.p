 /***********************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-----------------------------------------+--------------------------------------+
  | Rotina Progress                         | Rotina Oracle PLSQL                  |
  +-----------------------------------------+--------------------------------------+
  |sistema/generico/procedures/b1wgen0084.p | EMPR0001                             |
  | Dias360                                 | EMPR0001.pc_calc_dias360             |
  | fnBuscaDataDoUltimoDiaUtilMes           | gene0005.fn_valida_dia_util          |
  | busca_parcelas_proposta                 | EMPR0004.pc_busca_parcelas_proposta  |
  | calcula_emprestimo                      | EMPR0004.pc_calcula_emprestimo       |
  | calcula_data_parcela                    | EMPR0004.pc_calcula_data_parcela     |
  | gera_parcelas_emprestimo                | EMPR0004.pc_gera_parcelas_emprest    |
  | calcula_emprestimo                      | EMPR0018.pc_calcula_emprestimo       |
  | valida_novo_calculo                     | EMPR0018.pc_valida_novo_calculo      |
  +-----------------------------------------+--------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/





/*............................................................................

    Programa: sistema/generico/procedures/b1wgen0084.p
    Autor   : Irlan
    Data    : Fevereiro/2011               ultima Atualizacao: 21/04/2019

    Dados referentes ao programa:

    Objetivo  : BO para rotinas do sistema
                "Novo Produto de Credito com taxa Pre-fixada".

    Alteracoes: 27/06/2011 - Incluidos procedimentos para tratativas de
                             antecipacao e estorno, cfme, novo calculo de
                             parcelas de emprestimos;
                           - Incluida validacao de utilizacao de novo calculo
                             de emprestimo para curto ou longo prazo
                             (GATI - Diego B./Eder).

                21/07/2011 - Inclusao de procedimentos para obtencao e
                             manipulacao de dados de parcelas da proposta.
                             (GATI - Diego B.)

                22/07/2011 - Procedimentos referentes a efetivacao
                 de
                             proposta. (GATI - Diego B.)

                10/08/2011 - Retirada de rotinas de aprovacao de proposta.
                             (GATI - Diego B.)

                15/08/2011 - Utilizar fixo Cooperativa = 3 na busca dos
                             parametros ao validar utilizacao do novo calculo.
                             (GATI - Diego B.)

                17/08/2011 - Desenvolvimento da rotina de impressao de
                             extratos - imprime extrato. (GATI - Diego B.)

                30/08/2011 - Adicionado novo parametro par_intpextr na rotina
                             de impressao de extrato (imprime extrato), esse
                             parametro diz se o relatorio sera simplificado
                             (sem impressao de historico) ou detalhado (com
                             impressao de historico) sendo que 1 = simplificado
                             e 2 = detalhado. (GATI - Diego B.)

                19/09/2011 - Adicionado codigo da linha de credito (cdlcremp)
                             como parametro (par_cdlcremp) da procedure de
                             validacao de novo calculo  (valida_novo_calculo).
                           - Adicionado validacao de linha de credito na
                             procedure de validacao de novo calculo
                             (valida_novo_calculo). (GATI - Diego B.)

                22/09/2011 - Alteracao da procedure verifica_alcada para
                             verifica_alcada_estorno. (GATI - Vitor)

                04/10/2011 - Foram retiradas as procedures
                             verifica alcada estorno,
                             busca antecipacao parcela,
                             gera antecipacao parcela,
                             calcula antecipacao parcela,
                             efetiva antecipacao parcela,
                             valida antecipacao parcela,
                             gera estorno lancamento,
                             efetiva estorno lancamento,
                             valida estorno lancamento,
                             busca lancamentos parcela,
                             busca pagamentos parcelas e
                             gera pagamentos_parcelas, pois foi criada a BO
                             b1wgen0084a.
                           - Alterada mensagem de erro gerada apos execucao
                             da valida_novo_calculo
                           - Efetuadas correcoes no relatorio gerado pela
                             procedure imprime extrato.
                           - Corrigida logica que define quantidade de dias
                             de carencia, agora considerando sempre o
                             calendario comercial, meses com 30 dias
                           - Retirado parametro aux_permnovo da procedure
                             valida_novo_calculo, e adicionado retorno mais
                             especifico de erros.
                             (GATI - Oliver)

                24/01/2012 - Problema de Handle preso (Oscar)

                25/01/2012 - Código desnecessario busca dados efetivacao proposta (Oscar)

                10/02/2012 - Correcao na procedure 'valida_dados_efetivacao_proposta'
                             para gerar crítica 36 como limitador de acesso. (Lucas)

                23/02/2012 - Implementado novo parametro para a rotina
                             valida_novo_calculo. (Tiago)

                28/02/2012 - Incluido critica 946. (Tiago)

                29/02/2012 - Incluido funcao fnValidaEmprTipo1. (Tiago)

                05/03/2012 - Alterada efetivacao da proposta (Gabriel)

                23/03/2012 - Tratamento para composicao do saldo do extrato
                             tt-extrato_epr.flgsaldo (Tiago)

                04/04/2012 - Incluir campo dtlibera , e campo vlsdvpar (Gabriel)

                17/04/2012 - Retirada a procedure imprime extrato (Tiago).

                11/05/2012 - Adicionar a funcao fnBuscaDataDoUltimoDiaUtilMes (Oscar).

                29/11/2012 - Tratar campo vlsdvsji (Gabriel).

                10/04/2013 - Incluido a chamada da procedure alerta_fraude
                             dentro das procedures grava_efetivacao_proposta,
                             valida_dados_efetivacao_proposta (Adriano).

                04/06/2013 - 2a Fase Projeto Credito (Gabriel).

                16/07/2013 - Voltar os historicos 1032, 1033 na efetivacao
                             da proposta (Gabriel)

                21/08/2013 - Nao criar historicos 1032, 1033 na efetivacao
                             da proposta e separar historicos de emprestimo
                             e financiamento (Lucas).

               11/09/2013 - Incluir os pacs liberados para emprestimos
                            prefixados. (Irlan)

               18/10/2013 - GRAVAMES - Valida bens alienados no
                            grava_efetivacao_proposta (Guilherme/SUPERO).

               25/10/2013 - Realizado ajuste para retirar o bloqueio de
                            emprestimos Pre-fixado da cooperativa Viacredi e
                            incluido a cooperativa Acredicoop.
                            Procedures alterdadas:
                            - valida_dados_efetivacao_proposta
                            (Adriano)

               29/10/2013 - Incluido cdcooper e tpctrato na consulta do
                            avalista terceiro na consulta da efetivacao.
                            (Irlan).

               01/11/2013 - Ajustes:
                            - valida_novo_calculo: bloquear a criacao de
                              emprestimos Prefixado com linhas de credito CDC
                            - grava_efetivacao_proposta: inclusao do parametro
                              cdpactra na chamada da cria_lancamento_lem
                            (Adriano).

               28/11/2013 - Ajuste na procedure valida_novo_calculo para
                            incluir restricao da linha de emprestimo
                            (Adriano).

               17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)

               10/02/2014 - Retirado restricao da Acredi para afetivar
                            propostas Prefixadas.(Irlan)

               11/03/2014 - Ajuste para gravar o campo crapepr.qttolatr na
                            procedure "grava_efetivacao_proposta" (James)

               10/04/2014 - Ajuste em proc. criar_emprestimo_avalista, retirado
                            critica de nao encontrado associado quando verificado
                            avalista. (Jorge) (liberado em emergencial Abril)

               29/04/2014 - Ajuste de verificacao da nova proposta na procedure
                            "valida_alteracao_numero_proposta_parcelas".(James)

               11/06/2014 - Incluir o parametro par_nrseqava na chamada da
                            procedure "cria_lancamento_lem". (James)

               27/08/2014 - Gravar o campo cdorigem na tabela crapepr. (James)

               04/09/2014 - Ajustar a procedure "grava_efetivacao_proposta"
                            para diminuir o valor contratado quando for
                            credito pre-aprovado. (James)

               03/11/2014 - Incluso nova procedure transf_contrato_prejuizo,
                            Projeto transf. prejuizo (Daniel/Oscar)

              18/11/2014 - Inclusao do parametro nrcpfope na
                           procedure "grava_efetivacao_proposta". (Jaison)

              29/01/2015 - Ajuste no tratamento de historico prejuizo. (Daniel)

              29/01/2015 - Ajuste para os contratos de prejuizo.(James)

              27/03/2015 - Ajuste na procedure "desfaz_transferencia_prejuizo"
                           para verificar se houve pagamento para os historicos
                           de emprestimo e financiamento. (James)

              06/04/2015 - Incluir nova validacao na procedure
                           "valida_novo_calculo". (James)

              30/04/2015 - Incluir a crapavl ja na proposta de emprestimo.
                           (Gabriel-RKAM).

              04/05/2015 - Validar situacao dos contratos a liquidar
                           "valida_dados_efetivacao_proposta" (Guilherme/SUPERO)

              07/05/2015 - Inclusao do contrato no log nas procedures:
                           grava_efetivacao_proposta, gera_parcelas_emprestimo,
                           busca_dados_efetivacao_proposta, exclui_parcelas_proposta
                           busca_desfazer_efetivacao_emprestimo e 
                           desfaz_efetivacao_emprestimo. (Jaison/Gielow - SD: 283541)
                           
              19/05/2015 - Liberacao das linhas do cartao para o produto PP (James)
              
              29/06/2015 - Ajuste na passagem de parametros da procedure
                           "obtem_emprestimo_risco". (James)

              10/07/2015 - Alterada PROCEDURE grava_efetivacao_proposta para 
                           tratar operacoes de portabilidade de credito. (Reinert)

              30/09/2015 - Desenvolvimento do Projeto 215 - Estorno. (James/Reinert)
              
              05/11/2015 - Incluso novo parametro "par_idorigem" na chamada das procedures
                           "cria_lancamento_lem" e "lanca_juro_contrato" (Daniel)
                           
              15/12/2015 - Não deverá ser considerado o prazo informado no parâmetro da tela 
                           Tab090 para a cooperativa Viacredi(Chamado: 374261). (James)
                           
              16/02/2016 - Adicionado verificacao se chassi informado ja se encontra em outro
                           emprestimo em aberto. (Jorge/Gielow) - SD 391096             
                           
              21/03/2016 - Incluido validacao da situacao esteira na valida_dados_efetivacao_proposta             
                           PRJ207 - Esteira (Odirlei-AMcom)
                           
              30/03/2016 - Gravar operador que realizou a efetivacao da proposta
                           PRJ207 - Esteira (Odirlei-AMcom)
                           

              13/01/2016 - Verificacao de carga ativa na grava_efetivacao_proposta
                           e desfaz_efetivacao_emprestimo - Pre-Aprovado fase II.
                           (Jaison/Anderson)

              16/02/2016 - Adicionado verificacao se chassi informado ja se encontra em outro
                           emprestimo em aberto. (Jorge/Gielow) - SD 391096             

              17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

              01/02/2017 - Inclusao de comando validate crapepr. Ao chamar a rotina de rating, esta
                           nao conseguia visualizar o contrato que estava sendo criado, considerando
                           apenas os antigos e impactando na geracao do rating.
                           Heitor (Mouts)

              04/01/2016 - Validar se as informações de Imóvel foram devidamente preenchidas
                           para o contrato de empréstimo (Renato Darosci - Supero) - M326
                           
              28/09/2016 - Incluido verificacao de contratos de acordos na procedure
                           transf_contrato_prejuizo e valida_dados_efetivacao_proposta,
                           Prj. 302 (Jean Michel).
                     
              17/02/2017 - Retirada a trava de efetivaçao de empréstimo sem que as informações 
                           de Imóveis estejam preenchidas, conforme solicitaçao antes da 
                           liberaçao do projeto (Renato - Supero)

              04/05/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

              07/07/2017 - Nao permitir utilizar linha 100, quando possuir acordo
                           de estouro de conta ativo. (Jaison/James)

              28/07/2017 - Ajuste na procedure valida_dados_efetivacao_proposta para nao validar
                           o capital minimo para as cessoes de credito (Anderson).
                           
              14/12/2017 - Bloqueio/Desbloqueio de Aplicacoes vinculadas ao Efetivar/Desfazer Efetivacao.
                           (Jaison/Marcos Martini - PRJ404)
                           
              27/12/2017 - Ajuste transferencia para prejuizo permitir transferir a partir 180 dias 
                           para prejuizo. (Oscar)
                           
              28/12/2017 - Buscar da central de risco do dia anterior inves do fechamento do mes anterior. (Oscar)
              
              29/12/2017 - Ajuste para desfazer prejuizo retirar agencia do loop. (Oscar)
                           
              16/03/2018 - Ajuste para ignorar validacao alerta_fraude quando for cessao de credito (crps714).
                           Chamado 858710 (Mateus Z / Mouts). 

              26/03/2018 - Corrigir os erros do IOF. (James)

              02/04/2018 - Corrigir para não apresentar no extrato de empréstimo histórico do IOF zerado. (James)
              
              12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)
                           
              21/11/2017 - Incluído condiçao na leitura da crappre na procedure
                           grava_efetivacao_proposta, incluido leitura da crawepr
                           na procedure desfaz_efetivacao_emprestimo 
                           (Jean Michel - Prj. 402).
                           
              20/12/2017 - Criados novos históricos(2013,2014) para demonstraçao da
                           parte contábil dos lançamentos de CDC, alteraçao nas
                           procedures desfaz_efetivacao_emprestimo, busca_desfazer_efetivacao_emprestimo
                           e grava_efetivacao_proposta, Prj. 402 (Jean Michel).

              27/06/2018 - P450 - Calculo e gravacao Risco Refin no emprestimo
                           (Guilherme/AMcom)
                           
              16/08/2018 - Qualificar a Operacao no ato da efetivacao da
                           proposta PJ 450 - Diego Simas (AMcom)
                           
              31/08/2018 - P438 - Efetivaçao seguro prestamista -- Paulo Martins -- Mouts         

              19/10/2018 - P442 - Inclusao de opcao OUTROS VEICULOS onde ha procura por CAMINHAO (Marcos-Envolti)     

              13/12/2018 - P442 - Ao checar Chassi alienado em outros contratos, descartar refinanciamentos (Marcos-Envolti)         
                           
              03/01/2019 - Ajuste na gravação do IOF do emprestimo (INC0029419) Daniel

              19/12/2018 - P298.2 - Inclusão dos campos tpemprst e vlprecar no retorno da procedure busca_dados_efetivacao_proposta
                           (Andre Clemer - Supero)

              27/12/2018 - PJ298.2 - Alterado gravacao do campo vlpreemp para o POS (Rafael Faria - Supero)

              28/03/2019 - P450 - Padronizaçao no tratamento do Status do Rating para todos produtos
                           (Fabio Adriano - AMcom).

              17/04/2019 - P450 - verificar o endividamento somado com o contrato atual, caso for maior que 
                           o parâmetro da tab056, gravar o rating com o status 4 - efetivado.
                           Fabio Adriano (AMcom).

              08/05/2019 - P450 - Ajuste na qualificacao da operacao quando
                           se tratar de uma Cessao de Cartao (Guilherme/AMcom)

              21/05/2019 - P450 - corrigido a forma de retornar erro na efetivacao
                           do emprestimo em vez usar o tt-erro usado o gera_erro.
                           Luiz Otávio Olinger Momm (AMcom).

              27/05/2019 - P450 - alterado o gera_erro para UNDO e LEAVE para.
                           Luiz Otávio Olinger Momm (AMcom).

              12/02/2019 - P442 - PreAprovado nova estrutura (Marcos-Envolti)

............................................................................. */

/*................................ DEFINICOES ............................... */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0084tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen0188tt.i  }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_flgalcad AS LOGI                                        NO-UNDO.
DEF VAR aux_dsnivris AS CHAR                                        NO-UNDO.

DEF VAR aux_valortax AS DECI DECIMALS 7 FORMAT  "zzz9.9999999"      NO-UNDO.
DEF VAR aux_valrnovo AS DECI DECIMALS 2                             NO-UNDO.
DEF VAR aux_mesrefer AS INTE                                        NO-UNDO.
DEF VAR aux_anorefer AS INTE                                        NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                        NO-UNDO.
DEF VAR aux_diavecto AS INTE                                        NO-UNDO.

DEF VAR var_qtdiacar AS INTE                                        NO-UNDO.
DEF VAR var_vlajuepr AS DECI                                        NO-UNDO.
DEF VAR var_txdiaria AS DECI DECIMALS 10                            NO-UNDO.
DEF VAR var_txmensal AS DECI                                        NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF VAR par_numipusr AS CHAR                                        NO-UNDO.


DEF VAR h-b1wgen0043 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.
DEF VAR hb1wgen0024  AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0134 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen084a AS HANDLE                                      NO-UNDO.

DEF VAR h-b1crapsab  AS HANDLE                                      NO-UNDO.
DEF TEMP-TABLE cratsab NO-UNDO LIKE crapsab.

DEF VAR aux_vlsdeved        AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"    NO-UNDO.
DEF BUFFER crabass   FOR crapass.
DEF BUFFER crablcr   FOR craplcr.
DEF BUFFER crablem   FOR craplem.
DEF BUFFER crabavl   FOR crapavl.
DEF BUFFER crabepr   FOR crapepr.

DEF VAR aux_titelavl AS CHARACTER FORMAT "x(61)"                    NO-UNDO.
DEF VAR aux_qtlintel AS INT     FORMAT "99"                         NO-UNDO.
DEF VAR aux_tpdsaldo AS INT                                         NO-UNDO.
DEF VAR aux_stimeout AS INT                                         NO-UNDO.
DEF VAR aux_inhst093 AS LOGICAL                                     NO-UNDO.
DEF VAR aux_qtprecal LIKE crapepr.qtprecal                          NO-UNDO.
DEF VAR aux_qtctaavl AS INT                                         NO-UNDO.
DEF VAR aux_avljaacu AS LOG                                         NO-UNDO.
DEF VAR aux_aprovavl AS LOG  FORMAT "Sim/Nao"                       NO-UNDO.
DEF VAR aux_cdempres AS INT                                         NO-UNDO.
DEF VAR tab_indpagto AS INT                                         NO-UNDO.
DEF VAR tab_dtcalcul AS DATE                                        NO-UNDO.
DEF VAR tab_dtlimcal AS DATE                                        NO-UNDO.
DEF VAR tab_flgfolha AS LOGICAL                                     NO-UNDO.
DEF VAR aux_inusatab AS LOGICAL                                     NO-UNDO.
DEF VAR tab_diapagto AS INTE                                        NO-UNDO.
DEF VAR tab_cdlcrbol AS INTE                                        NO-UNDO.

DEF  STREAM str_1.

DEF TEMP-TABLE  w-emprestimo                                        NO-UNDO
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD dtmvtolt LIKE crapepr.dtmvtolt
    FIELD vlemprst LIKE crapepr.vlemprst
    FIELD qtpreemp LIKE crapepr.qtpreemp
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD vlsdeved LIKE aux_vlsdeved.

/*............................. FUNCTIONS ................................... */

FUNCTION fnValidaEmprTipo1 RETURNS LOGICAL (
                     INPUT par_cdcooper    AS INT,
                     INPUT par_cdagenci    AS INT,
                     INPUT par_nrdcaixa    AS INT,
                     INPUT par_nrdconta    AS INT,
                     INPUT par_nrctremp    AS INT,
                     INPUT par_flgefeti    AS LOGI):

    FIND FIRST crawepr NO-LOCK WHERE crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp AND
                                     crawepr.tpemprst = 1 NO-ERROR.
    IF  NOT AVAIL crawepr THEN
        DO:
            ASSIGN aux_cdcritic = 0.

            IF   par_flgefeti  THEN /* Se esta efetivando */
                 ASSIGN aux_dscritic = "Efetive o contrato na tela Lote.".
            ELSE
                 ASSIGN aux_dscritic = "Opcao invalida para esse tipo de " +
                         "contrato. Efetue a exclusao atraves da tela Lote.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN FALSE.
        END.

    RETURN TRUE.
END.


FUNCTION fnFormataValor RETURNS CHAR
    (par_dsprefix AS CHAR,
     par_vlrvalor AS DEC,
     par_dsformat AS CHAR,
     par_dsdsufix AS CHAR):
    /* Funcao desenvolvida para montar valores a serem exibidos em conjunto
       com caracteres antes ou depois do mesmo, eliminando espacos excessivos
       entre os mesmos.  */
    RETURN par_dsprefix +
           TRIM(STRING(par_vlrvalor,par_dsformat)) +
           par_dsdsufix.

END FUNCTION.

FUNCTION fnBuscaDataDoUltimoDiaUtilMes RETURN DATE
    (par_cdcooper AS INT,
     par_dtrefmes AS DATE):


    DEF VAR aux_dtcalcul AS DATE   NO-UNDO.

    /* Calcular o ultimo dia do mes */
    ASSIGN aux_dtcalcul =
          ((DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4) -
            DAY(DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4)).

    /* Calcular o ultimo dia util do mes */
    DO WHILE TRUE:
       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))    OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper    AND
                                   crapfer.dtferiad = aux_dtcalcul    AND
                         NOT (MONTH(crapfer.dtferiad) = 12 AND
                                DAY(crapfer.dtferiad) = 31     ))     THEN
            DO:
              aux_dtcalcul = aux_dtcalcul - 1.
              NEXT.
            END.
            LEAVE.
    END.

    RETURN aux_dtcalcul.

END FUNCTION.

/*FUNCTION fnDias360 RETURNS INTEGER
    (par_cdcooper AS INT,
     par_dtinicio AS DATE ,
     par_datfinal AS DATE):

    DEF VAR ano_datfinal          AS INTE                           NO-UNDO.
    DEF VAR mes_datfinal          AS INTE                           NO-UNDO.
    DEF VAR dia_datfinal          AS INTE                           NO-UNDO.
    DEF VAR ano_dtinicio          AS INTE                           NO-UNDO.
    DEF VAR mes_dtinicio          AS INTE                           NO-UNDO.
    DEF VAR dia_dtinicio          AS INTE                           NO-UNDO.
    DEF VAR aux_qtdiacar          AS INTE                           NO-UNDO.


    ASSIGN /* final */
          ano_datfinal = YEAR(par_datfinal)
          mes_datfinal = MONTH(par_datfinal)
          dia_datfinal = DAY(par_datfinal)
          /* inicial */
          ano_dtinicio = YEAR(par_dtinicio)
          mes_dtinicio = MONTH(par_dtinicio)
          dia_dtinicio = DAY(par_dtinicio).

    /* Oscar - Considerar todos os meses com  30 dias */
    IF  par_datfinal >= fnBuscaDataDoUltimoDiaUtilMes(par_cdcooper, par_datfinal) THEN
        dia_datfinal = 30.

    /* Oscar - Considerar todos os meses com  30 dias */
    IF  par_dtinicio >= fnBuscaDataDoUltimoDiaUtilMes(par_cdcooper, par_dtinicio) THEN
        dia_dtinicio = 30.

   /* Para o mes de Fevereiro , considerar 30 dias */
   IF   mes_datfinal = 2    AND
        dia_datfinal >= 28  THEN
        ASSIGN dia_datfinal = 30.

   /* caso seja o ultimo dia do mes, o inicial, entao considera como 30 */
   IF  mes_dtinicio <> MONTH(par_dtinicio + 1) THEN
       ASSIGN dia_dtinicio = 30.

   /* para cada ano final maior que inicial, soma 12 */
   IF ano_datfinal <> ano_dtinicio THEN
       ASSIGN mes_datfinal = mes_datfinal + ((ano_datfinal - ano_dtinicio) * 12).

   IF dia_datfinal = 31 AND
      mes_datfinal = 12 AND
      ano_datfinal NE ano_dtinicio THEN
       ASSIGN dia_datfinal = 30.

   /* considera calendario comercial */
   ASSIGN aux_qtdiacar = (mes_datfinal - mes_dtinicio) * 30 +
                         dia_datfinal - dia_dtinicio.

    RETURN aux_qtdiacar.

END FUNCTION.*/

/* Retorna o ultimo dia do mes */
FUNCTION fnBuscaDataDoUltimoDiaMes RETURN DATE (par_dtrefmes AS DATE):

    DEF VAR aux_dtcalcul AS DATE   NO-UNDO.

    /* Calcular o ultimo dia do mes */
    ASSIGN aux_dtcalcul = ((DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4) -
                            DAY(DATE(MONTH(par_dtrefmes),28,YEAR(par_dtrefmes)) + 4)).

    RETURN aux_dtcalcul.
END.



/*............................. PROCEDURES .................................. */

PROCEDURE Dias360:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/


  /* Indica se juros esta rodando na mensal */
  DEF INPUT  PARAM par_ehmensal AS LOGI                   NO-UNDO.
  /* Dia do primeiro vencimento do emprestimo */
  DEF INPUT  PARAM par_dtdpagto AS INT                    NO-UNDO.

  /* Dia da data de referência da última vez que rodou juros */
  DEF INPUT  PARAM par_diarefju AS INT                    NO-UNDO.
  /* Mes da data de referência da última vez que rodou juros */
  DEF INPUT  PARAM par_mesrefju AS INT                    NO-UNDO.
  /* Ano da data de referência da última vez que rodou juros */
  DEF INPUT  PARAM par_anorefju AS INT                    NO-UNDO.

  /* Dia data final */
  DEF INPUT-OUTPUT PARAM par_diafinal AS INT              NO-UNDO.
  /* Mes data final */
  DEF INPUT-OUTPUT PARAM par_mesfinal AS INT              NO-UNDO.
  /* Ano data final */
  DEF INPUT-OUTPUT PARAM par_anofinal AS INT              NO-UNDO.
  /* Quantidade de dias calculada */
  DEF OUTPUT PARAM par_qtdedias AS INT                    NO-UNDO.

  DEF VAR ano_datfinal  AS INTE                           NO-UNDO.
  DEF VAR mes_datfinal  AS INTE                           NO-UNDO.
  DEF VAR dia_datfinal  AS INTE                           NO-UNDO.
  DEF VAR ano_dtinicio  AS INTE                           NO-UNDO.
  DEF VAR mes_dtinicio  AS INTE                           NO-UNDO.
  DEF VAR dia_dtinicio  AS INTE                           NO-UNDO.
  DEF VAR aux_qtdedias  AS INTE                           NO-UNDO.

         /* final */
  ASSIGN ano_datfinal = par_anofinal
         mes_datfinal = par_mesfinal
         dia_datfinal = par_diafinal

         /* inicial */
         ano_dtinicio = par_anorefju
         mes_dtinicio = par_mesrefju
         dia_dtinicio = par_diarefju.

  IF   dia_dtinicio = 31   THEN
       dia_dtinicio = 30.

  IF   dia_datfinal = 31   THEN
       dia_datfinal = 30.

  IF  (par_dtdpagto > 28)  AND
      (NOT par_ehmensal)   THEN
       DO:
          IF ((mes_datfinal = 2)     AND
              (dia_datfinal >= 28)   AND
              (dia_datfinal <> par_dtdpagto)) THEN
               dia_datfinal = IF   par_dtdpagto = 31 THEN
                                   30
                              ELSE
                                   par_dtdpagto.
       END.
  ELSE
  IF   par_ehmensal THEN
       DO:
          dia_datfinal = 30.
       END.

  IF   ABS(ano_datfinal - ano_dtinicio) = 0 THEN
       aux_qtdedias =
          (mes_datfinal - mes_dtinicio) * 30 + dia_datfinal - dia_dtinicio.
  ELSE
       aux_qtdedias =
       ABS(ano_datfinal - ano_dtinicio - 1) * 360 +
                          360 - mes_dtinicio * 30 +  30 - dia_dtinicio +
                          30 * ( mes_datfinal - 1) + dia_datfinal.

  ASSIGN par_qtdedias = aux_qtdedias
         par_diafinal = dia_datfinal
         par_mesfinal = mes_datfinal
         par_anofinal = ano_datfinal.

  RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/**      PROCEDURE para calcular as parcelas do emprestimo                  **/
/*****************************************************************************/
PROCEDURE calcula_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flggrava AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idfiniof AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtdiacar AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlajuepr AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_txdiaria AS DECI DECIMALS 10               NO-UNDO.
    DEF OUTPUT PARAM par_txmensal AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-parcelas-epr.


    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR aux_nrparepr          AS INTE INITIAL 0                 NO-UNDO.
    DEF VAR aux_vlparepr          AS DECI                           NO-UNDO.
    DEF VAR aux_nrsimula          AS INTE                           NO-UNDO.
    DEF VAR tab_dstextab          AS CHAR                           NO-UNDO.
    DEF VAR aux_vlexpone          AS DECI DECIMALS 10               NO-UNDO.
    DEF VAR aux_diapagto          AS INTE                           NO-UNDO.
    DEF VAR aux_mespagto          AS INTE                           NO-UNDO.
    DEF VAR aux_anopagto          AS INTE                           NO-UNDO.
    DEF VAR vr_ind                AS INTE                           NO-UNDO.
    DEF VAR vr_saldo_devedor      AS DECI                           NO-UNDO.
    DEF VAR aux_dscatbem          AS CHAR                           NO-UNDO.
    DEF VAR aux_dsctrliq          AS CHAR                           NO-UNDO.
    DEF VAR i            AS INTE                                      NO-UNDO.

    DEF BUFFER crabepr FOR crawepr.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Realizar o calculo do valor das parcelas do "
                               + "emprestimo.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-parcelas-epr.

    ASSIGN aux_dscatbem = "".
    FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper  AND
                           crapbpr.nrdconta = par_nrdconta  AND
                           crapbpr.nrctrpro = par_nrctremp  AND 
                           crapbpr.tpctrpro = 90 NO-LOCK:
        ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
    END.

    DO WHILE TRUE:

       FIND FIRST crabepr NO-LOCK WHERE
                   crabepr.cdcooper = par_cdcooper AND
                   crabepr.nrdconta = par_nrdconta AND
                   crabepr.nrctremp = par_nrctremp NO-ERROR.

       IF  AVAIL crabepr THEN DO:
           IF crabepr.tpemprst <> 1  THEN DO:
                ASSIGN aux_cdcritic = 946
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
           END.

               /* Montar contratos para liquidação */
               ASSIGN aux_dsctrliq = "".
               
               DO i = 1 TO 10:

                 IF  crabepr.nrctrliq[i] > 0  THEN
                   aux_dsctrliq = aux_dsctrliq +
                      (IF  aux_dsctrliq = ""  THEN
                           TRIM(STRING(crabepr.nrctrliq[i],
                                       "z,zzz,zz9"))
                       ELSE
                           ", " +
                           TRIM(STRING(crabepr.nrctrliq[i],
                                       "z,zzz,zz9"))).

               END. /** Fim do DO ... TO **/
               
           END.
           

       FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                          craplcr.cdlcremp = par_cdlcremp
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL craplcr   THEN
            DO:
                aux_cdcritic = 363.
                LEAVE.
            END.

       ASSIGN aux_diapagto = DAY(par_dtdpagto)
              aux_mespagto = MONTH(par_dtdpagto)
              aux_anopagto = YEAR(par_dtdpagto).

       RUN Dias360 (INPUT FALSE,
                    INPUT DAY(par_dtdpagto),
                    INPUT DAY(par_dtlibera),
                    INPUT MONTH(par_dtlibera),
                    INPUT YEAR(par_dtlibera),
                    INPUT-OUTPUT aux_diapagto,
                    INPUT-OUTPUT aux_mespagto,
                    INPUT-OUTPUT aux_anopagto,
                   OUTPUT par_qtdiacar).

                   
              /* considera calendario comercial */
       ASSIGN par_txmensal = craplcr.txmensal

              /* Calculo da Taxa Diaria definida pela Karina*/
              aux_vlexpone = EXP ((par_txmensal / 100) + 1 , (1 / 30))

                    par_txdiaria = ROUND( (100 * (EXP ((par_txmensal / 100) + 1 , (1 / 30)) - 1)), 10)

              /* Valor presente com ajuste da carencia */
                    par_vlajuepr = par_vlemprst * EXP( (1 + (par_txdiaria / 100 )), par_qtdiacar - 30)

             /* Valor da Prestacao */
                   aux_vlparepr = (par_vlajuepr * craplcr.txmensal / 100) / (1 - EXP ( (1 + craplcr.txmensal / 100) , ( -1 * par_qtparepr ) ) ).


                   
       IF par_idfiniof > 0 THEN 
        DO:
        
          FIND crapass WHERE crapass.cdcooper = par_cdcooper
                             AND crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.

            IF NOT AVAILABLE crapass THEN   
              DO:
                   ASSIGN aux_dscritic = "Associado nao cadastrado ".
                   UNDO.
              END.

           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
           
           /* Efetuar a chamada a rotina Oracle  */
           RUN STORED-PROCEDURE pc_calcula_iof_epr
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                   ,INPUT par_nrdconta
                                                   ,INPUT par_nrctremp
                                                   ,INPUT par_dtmvtolt
                                                   ,INPUT crapass.inpessoa
                                                   ,INPUT par_cdlcremp
                                                   ,INPUT par_cdfinemp
                                                   ,INPUT par_qtparepr
                                                   ,INPUT aux_vlparepr
                                                   ,INPUT par_vlemprst
                                                   ,INPUT par_dtdpagto
                                                   ,INPUT par_dtlibera
                                                   ,INPUT 1
                                                   ,INPUT par_dtmvtolt /* xxxxxxxx */
                                                   ,INPUT 0             /* xxxxxxxxxxx  */
                                                   ,INPUT aux_dscatbem 
                                                   ,INPUT par_idfiniof
                                                   ,INPUT aux_dsctrliq
                                                   ,INPUT "N" /* Nao grava valor nas parcelas ainda */
                                                   ,OUTPUT 0  /* pr_vlpreclc */
                                                   ,OUTPUT 0  /* pr_vliofpri */
                                                   ,OUTPUT 0  /* pr_vliofadi */
                                                   ,OUTPUT 0  /* pr_flgimune */
                                                   ,OUTPUT 0
                                                   ,OUTPUT "").

           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_calcula_iof_epr
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
          
           ASSIGN aux_dscritic = ""
                  aux_dscritic = pc_calcula_iof_epr.pr_dscritic
                                 WHEN pc_calcula_iof_epr.pr_dscritic <> ?
                  aux_vlparepr = pc_calcula_iof_epr.pr_vlpreclc
                                 WHEN pc_calcula_iof_epr.pr_vlpreclc <> ?.
                               
        END.
        ELSE
          DO:
             /* considera calendario comercial */
             ASSIGN par_txmensal = craplcr.txmensal

                    /* Calculo da Taxa Diaria definida pela Karina*/
                    aux_vlexpone = EXP ((par_txmensal / 100) + 1 , (1 / 30))

                    par_txdiaria = ROUND( (100 * (EXP ((par_txmensal / 100) + 1 , (1 / 30)) - 1)), 10)

                    /* Valor presente com ajuste da carencia */
                    par_vlajuepr = par_vlemprst * EXP( (1 + (par_txdiaria / 100 )), par_qtdiacar - 30)

                   /* Valor da Prestacao */
                   aux_vlparepr = (par_vlajuepr * craplcr.txmensal / 100) / (1 - EXP ( (1 + craplcr.txmensal / 100) , ( -1 * par_qtparepr ) ) ).
          END.

       /* Datas das Prestacoes */
       RUN calcula_data_parcela (par_cdcooper, par_dtdpagto, par_qtparepr).

       DO aux_nrparepr = 1 TO par_qtparepr:

          FIND tt-datas-parcelas WHERE tt-datas-parcelas.nrparepr = aux_nrparepr
                                       NO-LOCK NO-ERROR.
          IF  AVAIL tt-datas-parcelas THEN
              DO:
                  CREATE tt-parcelas-epr.
                  ASSIGN tt-parcelas-epr.cdcooper = par_cdcooper
                         tt-parcelas-epr.nrdconta = par_nrdconta
                         tt-parcelas-epr.nrparepr = aux_nrparepr
                         tt-parcelas-epr.vlparepr = aux_vlparepr
                         tt-parcelas-epr.dtparepr = tt-datas-parcelas.dtparepr.
              END.
       END.

       ASSIGN aux_flgtrans = TRUE.
       LEAVE.

  END.

  IF   NOT aux_flgtrans   THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF   NOT AVAIL tt-erro   THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

           ELSE
               ASSIGN aux_dscritic = tt-erro.dscritic.

           IF   par_flgerlog   THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT 1,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).
           RETURN "NOK".

       END.

  IF   par_flggrava   THEN
       DO:
           IF   CAN-FIND(crabepr WHERE crabepr.cdcooper = par_cdcooper    AND
                                       crabepr.nrdconta = par_nrdconta    AND
                                       crabepr.nrctremp = par_nrctremp)   THEN

                 RUN gera_parcelas_emprestimo (INPUT  par_cdcooper,
                                               INPUT  par_cdagenci,
                                               INPUT  par_nrdcaixa,
                                               INPUT  par_cdoperad,
                                               INPUT  par_nmdatela,
                                               INPUT  par_idorigem,
                                               INPUT  par_nrdconta,
                                               INPUT  par_idseqttl,
                                               INPUT  par_dtmvtolt,
                                               INPUT  par_flgerlog,
                                               INPUT  par_nrctremp,
                                               INPUT  TABLE tt-parcelas-epr,
                                               OUTPUT TABLE tt-erro).

                FOR FIRST crabepr EXCLUSIVE-LOCK    WHERE
                          crabepr.nrdconta = par_nrdconta AND
                          crabepr.nrctremp = par_nrctremp AND
                          crabepr.cdcooper = par_cdcooper,
                    FIRST tt-parcelas-epr.

                    ASSIGN  crabepr.vlpreemp = tt-parcelas-epr.vlparepr
                            crabepr.txdiaria = par_txdiaria
                            crabepr.txmensal = par_txmensal.

                END.

       END.

  IF   par_flgerlog   THEN
       RUN proc_gerar_log (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT "",
                           INPUT aux_dsorigem,
                           INPUT aux_dstransa,
                           INPUT TRUE,
                           INPUT par_idseqttl,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                          OUTPUT aux_nrdrowid).

  RETURN "OK".

END PROCEDURE. /* calcula emprestimo */

PROCEDURE calcula_data_parcela:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparcel AS INTE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-datas-parcelas.

    DEF VAR aux_dtcalcul AS DATE                                    NO-UNDO.
    DEF VAR aux_nrparcel AS INTE                                    NO-UNDO.
    DEF VAR aux_dia      AS INTE                                    NO-UNDO.
    DEF VAR aux_mes      AS INTE                                    NO-UNDO.
    DEF VAR aux_ano      AS INTE                                    NO-UNDO.

    ASSIGN  aux_dtcalcul = par_dtvencto
            aux_dia      = DAY(aux_dtcalcul)
            aux_mes      = MONTH(aux_dtcalcul)
            aux_ano      = YEAR(aux_dtcalcul).

    DO  aux_nrparcel = 1 TO par_nrparcel:
        IF  aux_dia >= 29 THEN
            DO: /*  Se nao existir o dia no mes, joga o vencimento para
                    o ultimo deste mesmo mes. */
                aux_dtcalcul = DATE(aux_mes,aux_dia,aux_ano) NO-ERROR.
                IF  ERROR-STATUS:ERROR THEN
                    DO:
                      /* Calcular o ultimo dia do mes */
                      ASSIGN aux_dtcalcul = DATE((DATE(aux_mes, 28, aux_ano) + 4) -
                                                 DAY(DATE(aux_mes,28, aux_ano) + 4)).
                    END.
            END.
        ELSE
            DO:
                aux_dtcalcul = DATE(aux_mes, aux_dia, aux_ano).
            END.

        CREATE tt-datas-parcelas.
        ASSIGN tt-datas-parcelas.nrparepr = aux_nrparcel
               tt-datas-parcelas.dtparepr = aux_dtcalcul.

        IF  aux_mes = 12 THEN
            DO:
                aux_mes = 1.
                aux_ano = aux_ano + 1.
            END.
        ELSE
            aux_mes = aux_mes + 1.
    END.

END PROCEDURE. /* calcula data parcela */

PROCEDURE regulariza_saldo_parcela:

    DEF  INPUT PARAM par_cdcooper LIKE crappep.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crappep.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_nrctremp LIKE crappep.nrctremp             NO-UNDO.
    DEF  INPUT PARAM par_nrparepr LIKE crappep.nrparepr             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-parcelas-epr.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-parcelas-epr.

END PROCEDURE. /* regulariza saldo parcela */


PROCEDURE busca_parcelas_proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-parcelas-epr.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-parcelas-epr.

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Buscar parcelas da proposta.".

    IF   CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper    AND
                                crawepr.nrdconta = par_nrdconta    AND
                                crawepr.nrctremp = par_nrctremp)   THEN
         DO:
             FOR EACH crappep WHERE
                      crappep.cdcooper = par_cdcooper   AND
                      crappep.nrdconta = par_nrdconta   AND
                      crappep.nrctremp = par_nrctremp   NO-LOCK:

                 CREATE tt-parcelas-epr.
                 ASSIGN tt-parcelas-epr.cdcooper = crappep.cdcooper
                        tt-parcelas-epr.nrdconta = crappep.nrdconta
                        tt-parcelas-epr.nrctremp = crappep.nrctremp
                        tt-parcelas-epr.nrparepr = crappep.nrparepr
                        tt-parcelas-epr.vlparepr = crappep.vlparepr
                        tt-parcelas-epr.dtparepr = crappep.dtvencto
                        tt-parcelas-epr.indpagto = crappep.inliquid
                        tt-parcelas-epr.dtvencto = crappep.dtvencto.
             END.
         END.
    /*
    ELSE
         DO:
             RUN calcula_emprestimo   (INPUT  par_cdcooper,
                                       INPUT  par_cdagenci,
                                       INPUT  par_nrdcaixa,
                                       INPUT  par_cdoperad,
                                       INPUT  par_nmdatela,
                                       INPUT  par_idorigem,
                                       INPUT  par_nrdconta,
                                       INPUT  par_idseqttl,
                                       INPUT  par_flgerlog,
                                       INPUT  par_nrctremp,
                                       INPUT  par_cdlcremp,
                                       INPUT  par_cdfinemp,
                                       INPUT  par_vlemprst,
                                       INPUT  par_qtparepr,
                                       INPUT  par_dtmvtolt,
                                       INPUT  par_dtdpagto,
                                       INPUT  NO,
                                       INPUT  par_dtlibera,
                                       OUTPUT var_qtdiacar,
                                       OUTPUT var_vlajuepr,
                                       OUTPUT var_txdiaria,
                                       OUTPUT var_txmensal,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-parcelas-epr).

             IF   RETURN-VALUE <> "OK"   THEN
                  RETURN "NOK".
         END.
    */
    IF   par_flgerlog   THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                             OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE. /* busca parcelas proposta */


PROCEDURE gera_parcelas_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-parcelas-epr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Gerar parcelas de emprestimo.".

    FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper   AND
                           crappep.nrdconta = par_nrdconta   AND
                           crappep.nrctremp = par_nrctremp   EXCLUSIVE-LOCK:
        DELETE crappep.
    END.

    FOR EACH tt-parcelas-epr:
        FIND crappep  WHERE
             crappep.cdcooper = par_cdcooper               AND
             crappep.nrdconta = par_nrdconta               AND
             crappep.nrctremp = par_nrctremp               AND
             crappep.nrparepr = tt-parcelas-epr.nrparepr   NO-LOCK NO-ERROR.
        IF   NOT AVAIL crappep   THEN
             DO:
                CREATE crappep.
                ASSIGN crappep.cdcooper = par_cdcooper
                       crappep.nrdconta = par_nrdconta
                       crappep.nrctremp = par_nrctremp
                       crappep.nrparepr = tt-parcelas-epr.nrparepr
                       crappep.vlparepr = tt-parcelas-epr.vlparepr
                       crappep.vlsdvpar = crappep.vlparepr
                       crappep.vlsdvsji = crappep.vlsdvpar
                       crappep.dtvencto = tt-parcelas-epr.dtparepr
                       crappep.inliquid = 0.
                VALIDATE crappep.
             END.
    END.

    IF  par_flgerlog   THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).
        END.

    RETURN "OK".

END PROCEDURE. /* gera parcelas emprestimo */

PROCEDURE grava_parcelas_proposta:

    DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF INPUT PARAM par_qtparepr AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_idfiniof AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF  par_flgerlog THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Gravar parcelas proposta.".

    RUN valida_gravacao_parcelas (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_flgerlog,
                                  INPUT par_nrctremp,
                                  INPUT par_cdlcremp,
                                  INPUT par_vlemprst,
                                  INPUT par_qtparepr,
                                  INPUT par_dtlibera,
                                  INPUT par_dtdpagto).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper   AND
                           crappep.nrdconta = par_nrdconta   AND
                           crappep.nrctremp = par_nrctremp   EXCLUSIVE-LOCK:
        DELETE crappep.
    END.

    RUN calcula_emprestimo   (INPUT  par_cdcooper,
                              INPUT  par_cdagenci,
                              INPUT  par_nrdcaixa,
                              INPUT  par_cdoperad,
                              INPUT  par_nmdatela,
                              INPUT  par_idorigem,
                              INPUT  par_nrdconta,
                              INPUT  par_idseqttl,
                              INPUT  par_flgerlog,
                              INPUT  par_nrctremp,
                              INPUT  par_cdlcremp,
                              INPUT  par_cdfinemp,
                              INPUT  par_vlemprst,
                              INPUT  par_qtparepr,
                              INPUT  par_dtmvtolt,
                              INPUT  par_dtdpagto,
                              INPUT  TRUE,
                              INPUT  par_dtlibera,
                              INPUT  par_idfiniof,
                              OUTPUT var_qtdiacar,
                              OUTPUT var_vlajuepr,
                              OUTPUT var_txdiaria,
                              OUTPUT var_txmensal,
                              OUTPUT TABLE tt-erro,
                              OUTPUT TABLE tt-parcelas-epr).

    IF   RETURN-VALUE <> "OK" THEN
         RETURN "NOK".

    IF  par_flgerlog   THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE. /* grava parcelas proposta */


PROCEDURE valida_gravacao_parcelas:

    DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF INPUT PARAM par_qtparepr AS INTE                           NO-UNDO.
    DEF INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.

    DEF VAR         aux_permnovo AS LOGI                           NO-UNDO.

    FIND crapass WHERE crapass.nrdconta = par_nrdconta   AND
                       crapass.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    IF   par_vlemprst <= 0   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Valor do emprestimo deve ser maior que " +
                                  "zero.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    IF   par_qtparepr <= 0   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Quantidade de parcelas deve ser " +
                                   "informada.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RUN valida_novo_calculo (INPUT  par_cdcooper,
                             INPUT  par_cdagenci,
                             INPUT  par_nrdcaixa,
                             INPUT  par_qtparepr,
                             INPUT  par_cdlcremp,
                             INPUT  FALSE,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                       craplcr.cdlcremp = par_cdlcremp   NO-LOCK NO-ERROR.

    IF   NOT AVAIL craplcr   THEN
         DO:
             ASSIGN aux_cdcritic = 363
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.
    ELSE
         DO:
             IF   NOT craplcr.flgstlcr   THEN
                  DO:
                     /* Linha de credito nao liberada. */
                     ASSIGN aux_cdcritic = 470
                            aux_dscritic = "".

                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).

                     RETURN "NOK".
                 END.
         END.

    IF   par_qtparepr < craplcr.nrinipre   OR
         par_qtparepr > craplcr.nrfimpre   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Quantidade de parcelas deve estar dentro "
                                   + "da faixa limite parametrizada para a "
                                   + "linha de credito".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    IF   par_dtlibera < par_dtmvtolt   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Data de Liberacao de Emprestimo nao pode "
                                   + "ser menor que data atual de movimento.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    IF   par_dtdpagto < par_dtmvtolt   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Data de pagamento da primeira parcela "
                                   + " nao pode ser menor que data atual de "
                                   + " movimento.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    IF   par_dtlibera >= par_dtdpagto   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Atencao! A data de liberacao do recurso e "         +
                                   "igual ou menor que a data do primeiro vencimento. " +
                                   "Altere a data de vencimento na proposta".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* valida gravacao parcelas */


PROCEDURE altera_numero_proposta_parcelas:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT  PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrctrnov AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR          aux_nrctrnov AS INTE                              NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Alterar o numero da proposta de parcelas.".

    RUN valida_alteracao_numero_proposta_parcelas (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_flgerlog,
                                                   INPUT par_nrctremp,
                                                   INPUT par_nrctrnov).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper   AND
                           crappep.nrdconta = par_nrdconta   AND
                           crappep.nrctremp = par_nrctremp   EXCLUSIVE-LOCK:
        ASSIGN
            aux_nrctrnov     = crappep.nrctremp
            crappep.nrctremp = par_nrctrnov.
    END.

    IF  par_flgerlog   THEN
        DO:

            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).

            IF  aux_nrctrnov <> par_nrctrnov   THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrctrnov",
                                         INPUT aux_nrctrnov,
                                         INPUT par_nrctrnov).

        END. /* IF  par_flgerlog   THEN */
    RETURN "OK".

END PROCEDURE. /* altera numero proposta parcelas */


PROCEDURE valida_alteracao_numero_proposta_parcelas:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT  PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrctrnov AS INTE                              NO-UNDO.

    FIND crapass WHERE crapass.nrdconta = par_nrdconta   AND
                       crapass.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    FIND crappep WHERE crappep.cdcooper = par_cdcooper   AND
                       crappep.nrdconta = par_nrdconta   AND
                       crappep.nrctremp = par_nrctrnov   NO-LOCK NO-ERROR.
    IF   AVAIL crappep   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Ja existem parcelas para cooperativa, "
                                   + "conta e novo numero de contrato.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* valida alteracao numero proposta parcelas */


PROCEDURE exclui_parcelas_proposta:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Excluir parcelas da proposta.".

    RUN valida_exclusao_parcelas (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_flgerlog,
                                  INPUT par_nrctremp).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper   AND
                           crappep.nrdconta = par_nrdconta   AND
                           crappep.nrctremp = par_nrctremp   EXCLUSIVE-LOCK:
        DELETE crappep.
    END.

    IF  par_flgerlog   THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).
        END.

    RETURN "OK".

END PROCEDURE. /* exclui parcelas proposta */


PROCEDURE valida_exclusao_parcelas:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.

    DEF VAR         aux_parcrela AS LOGI                              NO-UNDO.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                       crawepr.nrdconta = par_nrdconta   AND
                       crawepr.nrctremp = par_nrctremp   NO-LOCK NO-ERROR.
    IF   NOT AVAIL crawepr   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Proposta informada deve estar cadastrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    ASSIGN aux_parcrela = NO.
    validar-parcela:
    FOR EACH crappep WHERE crappep.cdcooper = par_cdcooper   AND
                           crappep.nrdconta = par_nrdconta   AND
                           crappep.nrctremp = par_nrctremp   NO-LOCK,
       FIRST craplem OF crappep                NO-LOCK:

        ASSIGN aux_parcrela = YES.
        LEAVE validar-parcela.
    END.

    IF   aux_parcrela   THEN
         DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Proposta possui parcela(s) com "
                                   + "lancamentos relacionados.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* valida exclusao parcelas */

/*****************************************************************************
 Procedure para validar a utilizacao do novo calculo conforme prazo do
 emprestimo
*****************************************************************************/
PROCEDURE valida_novo_calculo:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_qtparepr AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_flgpagto AS LOGICAL                         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    valida:
    DO:
        FIND craptab WHERE craptab.cdcooper = 3            AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "USUARI"     AND
                           craptab.cdempres = 11           AND
                           craptab.cdacesso = "PAREMPCTL"  AND
                           craptab.tpregist = 1
                           USE-INDEX craptab1 NO-LOCK NO-ERROR.

        IF NOT AVAIL craptab THEN
           DO:
               ASSIGN  aux_cdcritic = 55
                       aux_dscritic = "".

               LEAVE valida.

           END.

        IF par_qtparepr > INT(SUBSTRING(craptab.dstextab,8,3)) THEN
           DO:
               ASSIGN aux_dscritic = "Produto nao permitido para " +
                                     "emprestimos de longo prazo."
                      aux_cdcritic = 0.
               LEAVE valida.
           END.        

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                           craplcr.cdlcremp = par_cdlcremp
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL craplcr THEN
           DO:
               ASSIGN aux_cdcritic = 817
                      aux_dscritic = "".

               LEAVE valida.

           END.

        IF craplcr.tpdescto = 2 THEN
           DO:
               ASSIGN aux_dscritic = "Linha nao permitida para esse produto."
                      aux_cdcritic = 0.

               LEAVE valida.

           END.

        IF craplcr.dslcremp MATCHES("*CDC*") THEN
           DO:
               ASSIGN aux_dscritic = "Linha nao permitida para esse produto."
                      aux_cdcritic = 0.

               LEAVE valida.

           END.

        IF craplcr.dslcremp MATCHES("*CREDITO DIRETO AO COOPERADO*") THEN
           DO:
               ASSIGN aux_dscritic = "Linha nao permitida para esse produto."
                      aux_cdcritic = 0.

               LEAVE valida.

           END.

        IF par_flgpagto THEN
           DO:
               ASSIGN aux_dscritic = "Tipo de debito folha bloqueado para todas as operacoes"
                      aux_cdcritic = 0.
               LEAVE valida.
           END.

    END. /* valida */

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* valida novo calculo */

PROCEDURE busca_dados_efetivacao_proposta:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtopr AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-efetiv-epr.
    DEF OUTPUT PARAM TABLE FOR tt-msg-aval.
    DEF OUTPUT PARAM TABLE FOR tt-empr-aval-1.
    DEF OUTPUT PARAM TABLE FOR tt-empr-aval-2.

    DEF VAR aux_cdempres AS INTE                                       NO-UNDO.
    DEF VAR aux_cdtpinsc AS INTE                                       NO-UNDO.
    DEF VAR aux_nrinssac AS DECI                                       NO-UNDO.
    DEF VAR aux_nmdsacad AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrendsac AS INTE                                       NO-UNDO.
    DEF VAR aux_dsendsac AS CHAR                                       NO-UNDO.
    DEF VAR aux_complend AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmbaisac AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmcidsac AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdufsaca AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrcepsac AS DECI                                       NO-UNDO.

    DEF VAR aux_totlinha AS INTE                                       NO-UNDO.
    DEF VAR aux_vlsdeved AS DECI                                       NO-UNDO.
    DEF VAR aux_qtprecal AS DECI                                       NO-UNDO.
    DEF VAR aux_vltotpre AS DECI                                       NO-UNDO.
    DEF VAR aux_vlmaxass AS DECI                                       NO-UNDO.
    DEF VAR aux_aprovavl AS LOGI                                       NO-UNDO.
    DEF VAR aux_avljaacu AS LOGI                                       NO-UNDO.
    DEF VAR aux_qtctaavl AS INTE                                       NO-UNDO.
    DEF VAR aux_dtdpagto AS DATE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  par_flgerlog THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Busca dados de efetivacao da proposta.".

    /* Se a proposta de emprestimo for TR, exibe critica */
    IF  CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                           AND crawepr.nrdconta = par_nrdconta
                           AND crawepr.nrctremp = par_nrctremp
                           AND crawepr.tpemprst = 0) THEN
        DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Efetive o contrato na tela Lote.".

             RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
        END.

    RUN valida_dados_efetivacao_proposta ( INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_flgerlog,
                                           INPUT par_nrctremp).
    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF   AVAILABLE crapass   THEN
         DO:
             IF   crapass.inpessoa = 1   THEN
                  DO:
                      FIND crapttl WHERE
                           crapttl.cdcooper = par_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                      IF   AVAIL crapttl  THEN
                           ASSIGN aux_cdempres = crapttl.cdempres
                                  aux_cdtpinsc = crapass.inpessoa
                                  aux_nrinssac = crapttl.nrcpfcgc.

                   END.
              ELSE
                   DO:
                       FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                          crapjur.nrdconta = crapass.nrdconta
                            NO-LOCK NO-ERROR.

                       IF   AVAIL crapjur  THEN
                            ASSIGN aux_cdempres = crapjur.cdempres
                                   aux_cdtpinsc = crapass.inpessoa
                                   aux_nrinssac = crapass.nrcpfcgc.
                   END.

             IF   NOT AVAILABLE crapenc   THEN
                  ASSIGN aux_nmdsacad = crapass.nmprimtl
                         aux_dsendsac = ""
                         aux_nrendsac = 0
                         aux_complend = ""
                         aux_nmbaisac = ""
                         aux_nmcidsac = ""
                         aux_cdufsaca = ""
                         aux_nrcepsac = 0.
             ELSE
                  ASSIGN aux_nmdsacad = crapass.nmprimtl
                         aux_dsendsac = crapenc.dsendere
                         aux_nrendsac = crapenc.nrendere
                         aux_complend = crapenc.complend
                         aux_nmbaisac = crapenc.nmbairro
                         aux_nmcidsac = crapenc.nmcidade
                         aux_cdufsaca = crapenc.cdufende
                         aux_nrcepsac = crapenc.nrcepend.
         END.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             ASSIGN aux_cdcritic = 9.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    FIND crapemp WHERE crapemp.cdcooper = par_cdcooper     AND
                       crapemp.cdempres = aux_cdempres     NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapemp   THEN
         DO:
             ASSIGN aux_cdcritic = 40.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "LCREMISBOL"   AND
                       craptab.tpregist = 0              NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab THEN
        DO:
            ASSIGN aux_cdcritic = 55
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN tab_cdlcrbol = INT(craptab.dstextab).


    FIND FIRST crawepr NO-LOCK WHERE crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp NO-ERROR.


    CREATE tt-efetiv-epr.
    ASSIGN tt-efetiv-epr.cdcooper = crawepr.cdcooper
           tt-efetiv-epr.nrdconta = crawepr.nrdconta
           tt-efetiv-epr.nrctremp = crawepr.nrctremp
           tt-efetiv-epr.cdfinemp = crawepr.cdfinemp
           tt-efetiv-epr.cdlcremp = crawepr.cdlcremp
           tt-efetiv-epr.nivrisco = crawepr.dsnivris
           tt-efetiv-epr.vlemprst = crawepr.vlemprst
           tt-efetiv-epr.vlpreemp = crawepr.vlpreemp
           tt-efetiv-epr.qtpreemp = crawepr.qtpreemp
           tt-efetiv-epr.flgpagto = crawepr.flgpagto
           tt-efetiv-epr.nrctaav1 = crawepr.nrctaav1
           tt-efetiv-epr.nrctaav2 = crawepr.nrctaav2
           tt-efetiv-epr.altdtpgt = NO
           tt-efetiv-epr.avalist1 = " "
           tt-efetiv-epr.avalist2 = " "
           tt-efetiv-epr.dtdpagto = crawepr.dtdpagto
           tt-efetiv-epr.idcobope = crawepr.idcobope
           tt-efetiv-epr.idfiniof = crawepr.idfiniof
           tt-efetiv-epr.tpemprst = crawepr.tpemprst
           tt-efetiv-epr.vlprecar = crawepr.vlprecar.

    /* Se tiver contrato em liquidacao, envia para efetivacao da proposta 
       para refinanciamento */        
    IF (crawepr.nrctrliq[1] > 0 OR
        crawepr.nrctrliq[2] > 0 OR
        crawepr.nrctrliq[3] > 0 OR
        crawepr.nrctrliq[4] > 0 OR
        crawepr.nrctrliq[5] > 0 OR
        crawepr.nrctrliq[6] > 0 OR
        crawepr.nrctrliq[7] > 0 OR
        crawepr.nrctrliq[8] > 0 OR
        crawepr.nrctrliq[9] > 0 OR
        crawepr.nrctrliq[10] > 0
        OR crawepr.nrliquid > 0) THEN                
      ASSIGN tt-efetiv-epr.flliquid = 1.
    ELSE
      ASSIGN tt-efetiv-epr.flliquid = 0.

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper     AND
                           crapavt.tpctrato = 1                AND /*Emprest*/
                           crapavt.nrdconta = crawepr.nrdconta AND
                           crapavt.nrctremp = crawepr.nrctremp NO-LOCK:

        IF  crawepr.nrctaav1 = 0 AND
            tt-efetiv-epr.avalist1   = " " THEN
            ASSIGN tt-efetiv-epr.avalist1   = "CPF " + STRING(crapavt.nrcpfcgc).
        ELSE
        IF  crawepr.nrctaav2 = 0 AND
            tt-efetiv-epr.avalist2 = " " THEN
            ASSIGN tt-efetiv-epr.avalist2 = "CPF " + STRING(crapavt.nrcpfcgc).
    END.

    IF  tt-efetiv-epr.avalist1   = " "   AND
        crawepr.nrctaav1         = 0    THEN
        ASSIGN tt-efetiv-epr.avalist1 = crawepr.dscpfav1.

    IF  tt-efetiv-epr.avalist2   = " "   AND
        crawepr.nrctaav2         = 0    THEN
        ASSIGN tt-efetiv-epr.avalist2 = crawepr.dscpfav2.

    IF  AVAIL craplcr           AND
      ((craplcr.vlmaxass > 0    AND
        crapass.inpessoa = 1)    OR    /* Pessoa Fisica */
       (craplcr.vlmaxasj > 0    AND
        crapass.inpessoa <> 1))THEN   /* Pessoa Juridica */
        DO:

           ASSIGN aux_totlinha = 0.

           FOR EACH crabass WHERE crabass.cdcooper  = par_cdcooper AND
                                  crabass.nrcpfcgc  = crapass.nrcpfcgc
                                  NO-LOCK,
               EACH crapepr WHERE crapepr.cdcooper = par_cdcooper      AND
                                  crapepr.nrdconta = par_nrdconta AND
                                  crapepr.inliquid = 0                 AND
                                  crapepr.cdlcremp = crawepr.cdlcremp  NO-LOCK:

               RUN sistema/generico/procedures/b1wgen0002.p
                                              PERSISTENT SET h-b1wgen0002.

               RUN saldo-devedor-epr IN h-b1wgen0002 ( INPUT  par_cdcooper,
                                                       INPUT  par_cdagenci,
                                                       INPUT  par_nrdcaixa,
                                                       INPUT  par_cdoperad,
                                                       INPUT  par_nmdatela,
                                                       INPUT  par_idorigem,
                                                       INPUT  par_nrdconta,
                                                       INPUT  par_idseqttl,
                                                       INPUT  par_dtmvtolt,
                                                       INPUT  par_dtmvtopr,
                                                       INPUT  par_nrctremp,
                                                       INPUT  par_cdprogra,
                                                       INPUT  par_inproces,
                                                       INPUT  par_flgerlog,
                                                       OUTPUT aux_vlsdeved,
                                                       OUTPUT aux_vltotpre,
                                                       OUTPUT aux_qtprecal,
                                                       OUTPUT TABLE tt-erro).

               DELETE PROCEDURE h-b1wgen0002.

               IF   RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".

               IF   aux_vlsdeved < 0   THEN
                    ASSIGN aux_vlsdeved = 0.

               ASSIGN aux_totlinha = aux_totlinha + aux_vlsdeved.

           END.

            IF  crapass.inpessoa = 1 THEN
                ASSIGN aux_vlmaxass = craplcr.vlmaxass.
            ELSE
                ASSIGN aux_vlmaxass = craplcr.vlmaxasj.

           IF  (aux_totlinha + crawepr.vlemprst) >
                aux_vlmaxass THEN
                DO:
                   ASSIGN aux_aprovavl = NO.
                   CREATE tt-msg-confirma.
                   ASSIGN tt-msg-confirma.inconfir = 1
                          tt-msg-confirma.dsmensag =
                              "Vlrs(Linha) Excedidos" +
                              "(Utiliz. "  +
                              TRIM(STRING(aux_totlinha,"zzz,zzz,zz9.99")) +
                              " Excedido " +
                              TRIM(STRING((aux_totlinha + crawepr.vlemprst
                              - aux_vlmaxass),"zzz,zzz,zz9.99")) +
                              ")Confirma? ".
                END.
        END.

    IF   crawepr.cdlcremp <> tab_cdlcrbol   THEN
         DO:

             IF  crapass.inpessoa <> 3 THEN
                 DO:

                     FOR EACH crapavl WHERE
                              crapavl.cdcooper  = crawepr.cdcooper AND
                              crapavl.nrdconta  = crawepr.nrctaav1 AND
                              crapavl.nrctaavd <> crawepr.nrdconta AND
                              crapavl.nrctravd <> crawepr.nrctremp AND
                              crapavl.tpctrato  = 1            NO-LOCK
                              BREAK BY crapavl.nrctaavd:
                         IF  FIRST-OF(crapavl.nrctaavd)  THEN
                             ASSIGN aux_avljaacu = NO.

                         FIND crapepr WHERE
                              crapepr.cdcooper = crapavl.cdcooper AND
                              crapepr.nrdconta = crapavl.nrctaavd AND
                              crapepr.nrctremp = crapavl.nrctravd
                              USE-INDEX crapepr2 NO-LOCK NO-ERROR.

                         IF   AVAILABLE crapepr  THEN
                              DO:
                                  IF  crapepr.inliquid = 0  AND
                                      NOT  aux_avljaacu      THEN
                                      ASSIGN aux_qtctaavl  = aux_qtctaavl + 1
                                             aux_avljaacu  = yes.
                              END.
                     END.

                     IF  aux_qtctaavl >= 2  THEN
                         DO:
                             CREATE tt-msg-aval.
                             ASSIGN tt-msg-aval.cdavalis = 1
                                    tt-msg-aval.dsmensag = "Confirma fiador " +
                                                           "nestas condicoes?".
                         END.

                     FOR EACH crapavl WHERE
                              crapavl.cdcooper  = crawepr.cdcooper AND
                              crapavl.nrdconta  = crawepr.nrctaav2 AND
                              crapavl.nrctaavd <> crawepr.nrdconta AND
                              crapavl.nrctravd <> crawepr.nrctremp AND
                              crapavl.tpctrato  = 1            NO-LOCK
                              BREAK BY crapavl.nrctaavd:
                         IF  FIRST-OF(crapavl.nrctaavd)  THEN
                             ASSIGN aux_avljaacu = NO.

                         FIND crapepr WHERE
                              crapepr.cdcooper = crapavl.cdcooper AND
                              crapepr.nrdconta = crapavl.nrctaavd AND
                              crapepr.nrctremp = crapavl.nrctravd
                              USE-INDEX crapepr2 NO-LOCK NO-ERROR.

                         IF   AVAILABLE crapepr  THEN
                              DO:
                                  IF  crapepr.inliquid = 0  AND
                                      NOT  aux_avljaacu      THEN
                                      ASSIGN aux_qtctaavl  = aux_qtctaavl + 1
                                             aux_avljaacu  = YES.
                              END.
                     END.

                     IF  aux_qtctaavl >= 2  THEN
                         DO:
                             CREATE tt-msg-aval.
                             ASSIGN tt-msg-aval.cdavalis = 2
                                    tt-msg-aval.dsmensag = "Confirma fiador "
                                                           + "nestas condicoes?".
                         END.

                 END.

                 RUN criar_emprestimo_avalista (  INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT par_nmdatela,
                                                  INPUT par_idorigem,
                                                  INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT par_dtmvtolt,
                                                  INPUT par_flgerlog,
                                                  INPUT par_dtmvtopr,
                                                  INPUT par_inproces,
                                                  INPUT par_nrctremp,
                                                  INPUT par_cdprogra,
                                                  INPUT crawepr.nrctaav1,
                                                  OUTPUT TABLE tt-erro).

                 IF   RETURN-VALUE <> "OK" THEN
                      RETURN "NOK".

                 FOR EACH w-emprestimo.
                     CREATE tt-empr-aval-1.
                     BUFFER-COPY w-emprestimo TO tt-empr-aval-1.
                 END.

                 RUN criar_emprestimo_avalista (  INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT par_nmdatela,
                                                  INPUT par_idorigem,
                                                  INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT par_dtmvtolt,
                                                  INPUT par_flgerlog,
                                                  INPUT par_dtmvtopr,
                                                  INPUT par_inproces,
                                                  INPUT par_nrctremp,
                                                  INPUT par_cdprogra,
                                                  INPUT crawepr.nrctaav2,
                                                  OUTPUT TABLE tt-erro).

                 IF   RETURN-VALUE <> "OK" THEN
                      RETURN "NOK".

                 FOR EACH w-emprestimo.
                     CREATE tt-empr-aval-2.
                     BUFFER-COPY w-emprestimo TO tt-empr-aval-2.
                 END.
         END.

    IF  par_flgerlog  THEN
        DO:

            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                                OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).

            IF  aux_dtdpagto <> ? AND
                aux_dtdpagto <> tt-efetiv-epr.dtdpagto THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdlcremp",
                                         INPUT aux_dtdpagto,
                                         INPUT tt-efetiv-epr.dtdpagto).


        END.
        
    RETURN "OK".

END PROCEDURE. /* busca dados efetivacao proposta */


PROCEDURE valida_dados_efetivacao_proposta:

    DEFINE INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEFINE INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEFINE INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEFINE INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEFINE INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEFINE INPUT PARAM par_nrctremp AS INTE                            NO-UNDO.

    DEF VAR aux_contador AS INTE    NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGI    NO-UNDO.
    DEF VAR aux_cdempres AS INTE    NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR    NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE  NO-UNDO.
    DEF VAR aux_nrctrliq AS CHAR    NO-UNDO.
    DEF VAR aux_flgativo AS INTEGER NO-UNDO.
    DEF VAR aux_flgcescr AS LOG INIT FALSE                             NO-UNDO.
/* DEF VAR aux_flimovel AS INTEGER NO-UNDO. 17/02/2017 - Validacao removida */
    DEF VAR aux_flgportb AS LOGI INIT FALSE                            NO-UNDO.

    DEF BUFFER crabbpr FOR crapbpr.
    
     ASSIGN aux_cdcritic = 0
            aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK.

    IF   aux_cdcritic <> 0 OR aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    RUN dig_fun IN h-b1wgen9999 ( INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT-OUTPUT par_nrdconta,
                                  OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen9999.
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".


    FIND crapass WHERE crapass.nrdconta = par_nrdconta   AND
                       crapass.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de efetivar proposta de "         +
                          "emprestimo/financiamento na conta "         +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")        +
                          " - CPF/CNPJ "                               +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    ASSIGN aux_cdempres = 0.

    IF  crapass.inpessoa = 1 THEN /*  Fisica */
        DO:
            FIND crapttl NO-LOCK WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = par_idseqttl NO-ERROR.
            IF   AVAIL crapttl THEN
                 ASSIGN aux_cdempres = crapttl.cdempres.
        END.
    ELSE /*  Juridica */
        DO:
            FIND crapjur NO-LOCK WHERE crapjur.cdcooper = par_cdcooper AND
                                       crapjur.nrdconta = par_nrdconta NO-ERROR.
            IF   AVAIL crapjur THEN
                 ASSIGN aux_cdempres = crapjur.cdempres.
        END.

    FIND crapemp NO-LOCK WHERE
         crapemp.cdcooper = crapass.cdcooper AND
         crapemp.cdempres = aux_cdempres NO-ERROR.

    IF   NOT AVAIL crapemp THEN
         DO:
            ASSIGN aux_cdcritic = 40
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    IF  CAN-FIND(crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                               crapepr.nrdconta = par_nrdconta   AND
                               crapepr.nrctremp = par_nrctremp
                               USE-INDEX crapepr2)               THEN
        DO:
            ASSIGN aux_cdcritic = 92
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.


    FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper  AND
                           crapepr.nrdconta = par_nrdconta  AND
                           crapepr.nrctremp = par_nrctremp  AND
                           crapepr.dtmvtolt = par_dtmvtolt  NO-LOCK,
       FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                           crawepr.nrdconta = par_nrdconta  AND
                           crawepr.nrctremp = par_nrctremp  NO-LOCK:

        ASSIGN aux_contador = 1.

        DO  aux_contador = 1 TO 10 :

            IF  crawepr.nrctrliq[aux_contador] > 0 THEN
                DO:

                    IF  crawepr.nrctrliq[1]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[2]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[3]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[4]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[5]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[6]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[7]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[8]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[9]  =
                        crawepr.nrctrliq[aux_contador] OR
                        crawepr.nrctrliq[10] =
                        crawepr.nrctrliq[aux_contador] THEN

                        DO:
                            ASSIGN aux_cdcritic = 805
                                   aux_dscritic = "".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).

                            RETURN "NOK".

                        END.

                END. /* IF */
        END. /* DO */
    END. /* FOR EACH */

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                       crawepr.nrdconta = par_nrdconta   AND
                       crawepr.nrctremp = par_nrctremp   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crawepr   THEN
         DO:
            ASSIGN aux_cdcritic = 535
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.
    ELSE DO:
        IF crawepr.insitapr <> 1  AND   /* Aprovado */
           crawepr.insitapr <> 3  THEN DO:  /* Aprovado com Restricao */
    
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "A proposta deve estar aprovada.".
         
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
        
              RETURN "NOK".
        END.
     
    FOR FIRST tbepr_portabilidade
       FIELDS (nrdconta)
        WHERE tbepr_portabilidade.cdcooper = par_cdcooper
          AND tbepr_portabilidade.nrdconta = par_nrdconta
          AND tbepr_portabilidade.nrctremp = par_nrctremp
        NO-LOCK:
        ASSIGN aux_flgportb = TRUE.
    END.
   
   FOR FIRST crapfin FIELDS(tpfinali)
        WHERE crapfin.cdcooper = par_cdcooper AND
              crapfin.cdfinemp = crawepr.cdfinemp
              NO-LOCK: END.    
    
    IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
       ASSIGN aux_flgcescr = TRUE.
          
    /* Validar apenas se nao for cessao de credito */
    IF  NOT aux_flgcescr THEN
        DO:
            /*Verifica se o associado esta no cadastro restritivo*/
            RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_dtmvtolt,
                                              INPUT par_idorigem,
                                              INPUT crapass.nrcpfcgc,
                                              INPUT crapass.nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT TRUE, /*bloqueia operacao*/
                                              INPUT 33, /*cdoperac*/
                                              INPUT aux_dsoperac,
                                              OUTPUT TABLE tt-erro).

            IF VALID-HANDLE(h-b1wgen0110) THEN
               DELETE PROCEDURE(h-b1wgen0110).

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                     DO:
                        ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                              "cadastro restritivo.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
        
                     END.

              RETURN "NOK".

                END.
        END.
     
         /* Verificar se a analise foi finalizada */
        IF crawepr.insitest <> 3 THEN DO:
         ASSIGN aux_cdcritic = 0
                aux_dscritic = " A proposta nao pode ser efetivada, "
                                + " verifique a situacao da proposta".
        
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
        
              RETURN "NOK".
        END.

        /** Verificar "inliquid" do contrato relacionado a ser liquidado **/
        DO  aux_contador = 1 TO 10 :
            IF  crawepr.nrctrliq[aux_contador] > 0 THEN DO:

                IF  CAN-FIND(FIRST crabepr
                             WHERE crabepr.cdcooper = crawepr.cdcooper
                               AND crabepr.nrdconta = crawepr.nrdconta
                               AND crabepr.nrctremp = crawepr.nrctrliq[aux_contador]
                               AND crabepr.inliquid = 1) THEN DO:

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Atencao: Exclua da proposta os contratos ja liquidados!".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 2,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".
                END.
            END.
        END.

        /* Verificar se um dos bens da proposta ja se encontra alienado em outro contrato
           OBS: Nao eh feito para Portabilidade */
        IF  aux_flgportb = FALSE THEN
                DO:

        FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper
                           AND crapbpr.nrdconta = par_nrdconta
                           AND crapbpr.nrctrpro = par_nrctremp
                           AND crapbpr.flgalien = TRUE
                           AND CAN-DO("AUTOMOVEL,MOTO,CAMINHAO,OUTROS VEICULOS",crapbpr.dscatbem)
                           NO-LOCK:
            FOR EACH crapepr WHERE crapepr.cdcooper = crapbpr.cdcooper
                               AND crapepr.nrdconta = crapbpr.nrdconta
                               AND crapepr.inliquid = 0
                     AND crapepr.nrctremp <> crawepr.nrctrliq[1]  
                     AND crapepr.nrctremp <> crawepr.nrctrliq[2]  
                     AND crapepr.nrctremp <> crawepr.nrctrliq[3]
                     AND crapepr.nrctremp <> crawepr.nrctrliq[4]  
                     AND crapepr.nrctremp <> crawepr.nrctrliq[5]  
                     AND crapepr.nrctremp <> crawepr.nrctrliq[6]
                     AND crapepr.nrctremp <> crawepr.nrctrliq[7]
                     AND crapepr.nrctremp <> crawepr.nrctrliq[8]
                     AND crapepr.nrctremp <> crawepr.nrctrliq[9]
                     AND crapepr.nrctremp <> crawepr.nrctrliq[10] NO-LOCK:
                FOR FIRST crabbpr WHERE crabbpr.cdcooper = crapepr.cdcooper
                                    AND crabbpr.nrdconta = crapepr.nrdconta
                                    AND crabbpr.nrctrpro = crapepr.nrctremp
                                    AND crabbpr.flgalien = TRUE
                                    AND crabbpr.dschassi = crapbpr.dschassi
                                    AND (crabbpr.cdsitgrv <> 4 AND
                                         crabbpr.cdsitgrv <> 5)
                                    NO-LOCK: END.
                IF AVAIL crabbpr THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Ja existe o mesmo chassi alienado em um contrato liberado!".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 2,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".
    END.
            END.
        END.
    END.
      END.

           

/*
    /* Nao permitir utilizar linha 100, quando possuir acordo de estouro de conta ativo */
    IF   crawepr.cdlcremp = 100  THEN
         DO:
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

             /* Verifica se ha contratos de acordo */
             RUN STORED-PROCEDURE pc_verifica_acordo_ativo
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                 ,INPUT par_nrdconta
                                                 ,INPUT par_nrdconta
                                                 ,INPUT 1
                                                 ,0
                                                 ,0
                                                 ,"").

             CLOSE STORED-PROC pc_verifica_acordo_ativo
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

             ASSIGN aux_flgativo = 0
                    aux_cdcritic = 0
                    aux_dscritic = ""
                    aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                    aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                    aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo) WHEN pc_verifica_acordo_ativo.pr_flgativo <> ?.
                              
              IF   aux_cdcritic > 0   OR
                   (aux_dscritic <> ? AND aux_dscritic <> "") THEN
                   DO:
                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).

                       RETURN "NOK".
                   END.
                            
              IF   aux_flgativo = 1  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Operacao nao permitida, conta corrente esta em acordo.".

                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).

                       RETURN "NOK".
                   END.
         END.
         */

    /* Condicao para a Finalidade for Cessao de Credito */
    FOR FIRST crapfin FIELDS(tpfinali)
                       WHERE crapfin.cdcooper = crawepr.cdcooper AND 
                             crapfin.cdfinemp = crawepr.cdfinemp
                             NO-LOCK: END.

    IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
       ASSIGN aux_flgcescr = TRUE.

    /* Vamos validar o capital minimo apenas se nao for cessao de credito  */
    IF NOT aux_flgcescr THEN
       DO:
          RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

          IF  VALID-HANDLE(h-b1wgen0001)   THEN
              DO:
                  RUN ver_capital IN h-b1wgen0001(INPUT  par_cdcooper,
                                                  INPUT  par_nrdconta,
                                                  INPUT  par_cdagenci,
                                                  INPUT  par_nrdcaixa,
                                                  INPUT  0, /* vllanmto */
                                                  INPUT  par_dtmvtolt,
                                                  INPUT  "lanctri",
                                                  INPUT  1, /* AYLLOS */
                                                  OUTPUT TABLE tt-erro).
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF  AVAILABLE tt-erro   THEN
                      DO.
                        DELETE PROCEDURE h-b1wgen0001.
                        RETURN "NOK".
                      END.
                  ELSE
                     DELETE PROCEDURE h-b1wgen0001.

              END.
       END.


    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                       craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplcr   THEN
        DO:
           ASSIGN aux_cdcritic = 363
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
        END.

    /* 17/02/2017 - Retirado a validaçao conforme solicitaçao 
    ELSE DO:  /* Se encontrar linha de crédito */
    
        /* Se o tipo do contrato for igual a 3 -> Contratos de imóveis */
        IF craplcr.tpctrato = 3 THEN DO:
            
            ASSIGN aux_flimovel = 0.

            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

            /* Verifica se ha contratos de acordo */
            RUN STORED-PROCEDURE pc_valida_imoveis_epr
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                ,INPUT par_nrdconta
                                                ,INPUT crawepr.nrctremp
                                                ,INPUT 3
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT "").

            CLOSE STORED-PROC pc_valida_imoveis_epr
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = INT(pc_valida_imoveis_epr.pr_cdcritic) WHEN pc_valida_imoveis_epr.pr_cdcritic <> ?
                   aux_dscritic = pc_valida_imoveis_epr.pr_dscritic WHEN pc_valida_imoveis_epr.pr_dscritic <> ?
                   aux_flimovel = INT(pc_valida_imoveis_epr.pr_flimovel).
        
            IF aux_cdcritic > 0 OR (aux_dscritic <> ? AND aux_dscritic <> "") THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.        
          
            IF aux_flimovel = 1 THEN
            DO:
            
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "A proposta nao pode ser efetivada, dados dos Imoveis nao cadastrados.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
             
            END. /* IF aux_flimovel = 1 THEN */
        END. /* IF craplcr.tpctrato = 3 */
    END. /* IF  NOT AVAIL craplcr */
    FIM - 17/02/2017 - Retirado a validaçao conforme solicitaçao */
    
    IF  par_dtmvtolt > crawepr.dtlibera THEN
        DO:
            ASSIGN  aux_cdcritic = 0
                    aux_dscritic = "Data de movimento nao pode ser maior "
                                 + "que a data de liberacao do emprestimo.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    /* Verificacao de contrato de acordo */  
    DO  aux_contador = 1 TO 10:

      IF  crawepr.nrctrliq[aux_contador] > 0 THEN DO:
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        /* Verifica se ha contratos de acordo */
        RUN STORED-PROCEDURE pc_verifica_acordo_ativo
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                              ,INPUT par_nrdconta
                                              ,INPUT crawepr.nrctrliq[aux_contador]
                                              ,INPUT 3
                                              ,OUTPUT 0
                                              ,OUTPUT 0
                                              ,OUTPUT "").

        CLOSE STORED-PROC pc_verifica_acordo_ativo
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
               aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
               aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
        
        IF aux_cdcritic > 0 OR (aux_dscritic <> ? AND aux_dscritic <> "") THEN
          DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

        IF aux_flgativo = 1 THEN
          DO:
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "A proposta nao pode ser efetivada, contrato marcado para liquidar esta em acordo.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
             
          END.
     END.   
   END.
   /* Fim verificacao contrato acordo */  
   
    RETURN "OK".

END PROCEDURE. /*   valida dados efetivacao proposta    */


PROCEDURE criar_emprestimo_avalista:

   DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_idorigem AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_nrdconta AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_idseqttl AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_flgerlog AS LOGI                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtopr AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_inproces AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_nrctremp AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_cdprogra AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nrctaavl AS INTE                              NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.


   DEF VAR par_vlsdeved AS DECI                                       NO-UNDO.
   DEF VAR par_vltotpre AS DECI                                       NO-UNDO.
   DEF VAR par_qtprecal LIKE crapepr.qtprecal                         NO-UNDO.
   DEF VAR aux_diapagto AS INTE                                       NO-UNDO.
   DEF VAR aux_indpagto AS INTE                                       NO-UNDO.
   DEF VAR aux_dtcalcul AS DATE                                       NO-UNDO.
   DEF VAR aux_txdjuros AS DECI                                       NO-UNDO.
   DEF VAR aux_vltotpre AS DECI                                       NO-UNDO.
   DEF VAR aux_nmprimtl AS CHAR                                       NO-UNDO.

   EMPTY TEMP-TABLE w-emprestimo.

   FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
                      crabass.nrdconta = par_nrctaavl NO-LOCK NO-ERROR.

   IF   AVAIL crabass THEN
        ASSIGN aux_nmprimtl = crabass.nmprimtl.
   ELSE
        DO:

            FIND FIRST crapavt NO-LOCK WHERE
                       crapavt.cdcooper = par_cdcooper AND
                       crapavt.tpctrato = 1            AND
                       crapavt.nrdconta = par_nrctaavl AND
                       crapavt.nrctremp = par_nrctremp NO-ERROR.

            IF   AVAIL  crapavt THEN
                 ASSIGN aux_nmprimtl = crapavt.nmdavali.

        END.

   FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "USUARI"     AND
                      craptab.cdempres = 11           AND
                      craptab.cdacesso = "TAXATABELA" AND
                      craptab.tpregist = 0 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        aux_inusatab = FALSE.
   ELSE
        aux_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                          THEN FALSE
                          ELSE TRUE.

   ASSIGN aux_titelavl = "Fiador = " + STRING(par_nrctaavl, ">>>,>>>,>")
                         + " - " + aux_nmprimtl.

   FOR EACH crabavl WHERE crabavl.cdcooper  = par_cdcooper AND
                          crabavl.nrdconta  = par_nrctaavl AND
                          crabavl.nrctaavd <> par_nrdconta AND
                          crabavl.nrctravd <> par_nrctremp AND
                          crabavl.tpctrato  = 1 NO-LOCK:

       FIND crapepr WHERE crapepr.cdcooper = par_cdcooper     AND
                          crapepr.nrdconta = crabavl.nrctaavd AND
                          crapepr.nrctremp = crabavl.nrctravd
                          USE-INDEX crapepr2 NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapepr THEN
            DO:
                NEXT.
                /*  10/04/2014 - Jorge, emprestimo nao encontrado, provavel
                                 avl q nao foi excluido apos epr.
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
                */
           END.

       IF  crapepr.inliquid <> 0 THEN
           NEXT.

       FIND crabass WHERE crabass.cdcooper = par_cdcooper     AND
                          crabass.nrdconta = crapepr.nrdconta NO-LOCK NO-ERROR.

       IF   AVAIL crabass  THEN
            DO:
                IF   crabass.inpessoa = 1   THEN
                     DO:
                         FIND crapttl WHERE
                              crapttl.cdcooper = par_cdcooper       AND
                              crapttl.nrdconta = crabass.nrdconta   AND
                              crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                         IF   AVAIL crapttl  THEN
                              ASSIGN aux_cdempres = crapttl.cdempres.
                     END.
                ELSE
                     DO:
                         FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                            crapjur.nrdconta = crabass.nrdconta
                              NO-LOCK NO-ERROR.

                         IF   AVAIL crapjur  THEN
                              ASSIGN aux_cdempres = crapjur.cdempres.
                     END.
            END.


       FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                          craptab.nmsistem = "CRED"       AND
                          craptab.tptabela = "GENERI"     AND
                          craptab.cdempres = 00           AND
                          craptab.cdacesso = "DIADOPAGTO" AND
                          craptab.tpregist = aux_cdempres NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craptab   THEN
            DO:

                ASSIGN  aux_cdcritic = 55
                        aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            END.

       IF   CAN-DO("1,3,4",STRING(crabass.cdtipsfx))   THEN
            aux_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)). /*Mensal*/
       ELSE
            aux_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)). /*Horis. */

       aux_indpagto = INTEGER(SUBSTRING(craptab.dstextab,14,1)).

       aux_dtcalcul = DATE(MONTH(par_dtmvtolt),aux_diapagto,
                           YEAR(par_dtmvtolt)).

       DO WHILE TRUE:

          IF   WEEKDAY(aux_dtcalcul) = 1   OR
               WEEKDAY(aux_dtcalcul) = 7   THEN
               DO:
                   aux_dtcalcul = aux_dtcalcul + 1.
                   NEXT.
               END.

          FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                             crapfer.dtferiad = aux_dtcalcul NO-LOCK NO-ERROR.

          IF   AVAILABLE crapfer   THEN
               DO:
                   aux_dtcalcul = aux_dtcalcul + 1.
                   NEXT.
               END.

          aux_diapagto = DAY(aux_dtcalcul).

          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */


       IF   aux_inusatab  THEN
            DO:

               FIND crablcr WHERE crablcr.cdcooper = par_cdcooper AND
                                  crablcr.cdlcremp = crapepr.cdlcremp
                                  NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crablcr   THEN
                    DO:

                        ASSIGN  aux_cdcritic = 363
                                aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                     END.
                ELSE
                     aux_txdjuros = crablcr.txdiaria.
            END.
       ELSE
            aux_txdjuros = crapepr.txjuremp.

       RUN sistema/generico/procedures/b1wgen0002.p
                                       PERSISTENT SET h-b1wgen0002.

       RUN saldo-devedor-epr IN h-b1wgen0002 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_nrdconta,
                                              INPUT 1,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT crapepr.nrctremp,
                                              INPUT "",
                                              INPUT par_inproces,
                                              INPUT FALSE,
                                              OUTPUT aux_vlsdeved,
                                              OUTPUT aux_vltotpre,
                                              OUTPUT aux_qtprecal,
                                              OUTPUT TABLE tt-erro).
       DELETE PROCEDURE h-b1wgen0002.

       CREATE w-emprestimo.
       ASSIGN w-emprestimo.nrdconta = crapepr.nrdconta
              w-emprestimo.nrctremp = crapepr.nrctremp
              w-emprestimo.dtmvtolt = crapepr.dtmvtolt
              w-emprestimo.vlemprst = crapepr.vlemprst
              w-emprestimo.qtpreemp = crapepr.qtpreemp
              w-emprestimo.vlpreemp = crapepr.vlpreemp
              w-emprestimo.vlsdeved = IF aux_vlsdeved > 0 THEN
                                         aux_vlsdeved
                                      ELSE 0.

   END.  /*  Fim do FOR EACH  */

   RETURN "OK".

END PROCEDURE. /*  criar emprestimo avalista  */


PROCEDURE grava_efetivacao_proposta:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_insitapr AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dsobscmt AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_dtdpagto AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrcpfope AS DECI                              NO-UNDO.

    DEFINE OUTPUT PARAM par_mensagem AS CHAR                          NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-ratings.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdempres LIKE crapttl.cdempres                        NO-UNDO.
    DEF VAR aux_txiofepr AS DECI                                      NO-UNDO.
    DEF VAR aux_floperac AS LOGI                                      NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                                      NO-UNDO.
    DEF VAR aux_cdhistor_tar AS INTE                                  NO-UNDO.
    DEF VAR aux_nrdolote AS INTE                                      NO-UNDO.
    DEF VAR aux_vltotctr AS DECI                                      NO-UNDO.
    DEF VAR aux_vltotjur AS DECI                                      NO-UNDO.
    DEF VAR aux_vltotemp AS DECI                                      NO-UNDO.
    DEF VAR aux_contador AS INTE                                      NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                      NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR                                      NO-UNDO.
    DEF VAR aux_flgportb AS LOGI INIT FALSE                           NO-UNDO.
    DEF VAR aux_flcescrd AS LOGI INIT FALSE                           NO-UNDO.
    DEF VAR aux_idcarga  AS INTE                                      NO-UNDO.
    DEF VAR aux_flgativo AS INTE                                      NO-UNDO.
    DEF VAR aux_vltottar AS DECI                                      NO-UNDO.
    DEF VAR aux_vltariof AS DECI                                      NO-UNDO.
    DEF VAR aux_tpfinali AS INTE                                      NO-UNDO.
    DEF VAR aux_flgimune AS INTE                                      NO-UNDO.
    DEF VAR aux_vltotiof AS DECI                                      NO-UNDO.
    DEF VAR aux_qtdiaiof AS INTE                                      NO-UNDO.
    DEF VAR aux_vlaqiofc AS DECI                                      NO-UNDO.    
    DEF VAR aux_cdhistar_cad  AS INTE                                 NO-UNDO.
    DEF VAR aux_cdhistar_gar  AS INTE                                 NO-UNDO.    
    DEF VAR aux_vlpreclc AS DECI                                      NO-UNDO.
    DEF VAR aux_vliofpri AS DECI                                      NO-UNDO.    
    DEF VAR aux_vliofadi AS DECI                                      NO-UNDO.    
    DEF VAR aux_nrseqdig AS INTE                                      NO-UNDO.
    DEF VAR aux_nrdolote_cred AS INTE                                 NO-UNDO.   
    DEF VAR aux_cdhistor_cred AS INTE                                 NO-UNDO.

    DEF VAR h-b1wgen0097 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0134 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0171 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0188 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_dscatbem AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsctrliq AS CHAR                                      NO-UNDO.
    DEF VAR i            AS INTE                                      NO-UNDO.
    DEF VAR aux_vltrfgar AS DECI                                      NO-UNDO.    
    DEF VAR aux_vltarifa AS DECI                                      NO-UNDO.
    DEF VAR aux_vltaxiof AS DECI                                      NO-UNDO.    
    DEF VAR aux_dtrisref AS DATE /* DATA RISCO REFIN */               NO-UNDO.
    DEF VAR aux_qtdiaatr AS INTE                                      NO-UNDO.
    DEF VAR aux_idquapro AS INTE                                      NO-UNDO.
    DEF VAR aux_vlendivi AS DECI                                      NO-UNDO. /* P450 - Rating */
    DEF VAR aux_vlrating AS DECI                                      NO-UNDO. /* P450 - Rating */
    DEF VAR aux_flrating AS INT                                       NO-UNDO. /* P450 - Rating */
    DEF VAR aux_flgcescr AS LOGI INIT FALSE                           NO-UNDO.
    DEF VAR aux_vlemprstcalc AS DECI                                  NO-UNDO.
    DEF VAR aux_vlpreempcalc AS DECI                                  NO-UNDO.
    DEF VAR aux_dsassdig AS CHAR                                      NO-UNDO.
    DEF VAR aux_des_reto AS CHAR                                      NO-UNDO.
    
    DEF VAR aux_habrat   AS CHAR                                      NO-UNDO. /* P450 - Rating */
    DEF VAR aux_dispensa AS CHAR                                      NO-UNDO. /* P450 - Rating */

    DEF BUFFER b-crawepr FOR crawepr.

    DEF  VAR         aux_nivrisco           AS CHAR                   NO-UNDO. /* P450 - Rating */
    DEF  VAR         aux_nivrisco_num       AS INTE                   NO-UNDO. /* P450 - Rating */
    DEF  VAR         aux_nivrisco_ope       AS INTE                   NO-UNDO. /* P450 - Rating */
    DEF  VAR         vr_strating            AS INTE                   NO-UNDO. /* P450 - Rating */
    DEF  VAR         vr_orrating            AS INTE                   NO-UNDO. /* P450 - Rating */

    
    EMPTY TEMP-TABLE tt-erro.

    IF par_flgerlog   THEN
       ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
              aux_dstransa = "Grava dados de efetivacao da proposta.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR FIRST tbepr_portabilidade
       FIELDS (nrdconta)
        WHERE tbepr_portabilidade.cdcooper = par_cdcooper
          AND tbepr_portabilidade.nrdconta = par_nrdconta
          AND tbepr_portabilidade.nrctremp = par_nrctremp
        NO-LOCK:
        ASSIGN aux_flgportb = TRUE.
    END.

    IF  aux_flgportb = FALSE THEN
        DO:
    /** GRAVAMES **/
    RUN sistema/generico/procedures/b1wgen0171.p PERSISTENT SET h-b1wgen0171.

    RUN valida_bens_alienados IN h-b1wgen0171 (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctremp,
                                               INPUT "",
                                              OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0171.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
      END.

    RUN valida_dados_efetivacao_proposta (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_flgerlog,
                                          INPUT par_nrctremp).

    IF RETURN-VALUE <> "OK"   THEN
       RETURN "NOK".

    FOR FIRST crapfin FIELDS(tpfinali)
        WHERE crapfin.cdcooper = par_cdcooper AND
              crapfin.cdfinemp = crawepr.cdfinemp
              NO-LOCK: END.

    IF AVAILABLE crapfin THEN     
       /* cessao de credito */
       IF crapfin.tpfinali = 1 THEN
          ASSIGN aux_flcescrd = TRUE.

    EFETIVACAO:
    DO TRANSACTION ON ERROR UNDO, LEAVE:

       ASSIGN aux_vltotemp = crawepr.vlemprst
              aux_vltotctr = crawepr.qtpreemp * crawepr.vlpreemp
              aux_vltotjur = aux_vltotctr - crawepr.vlemprst
              aux_floperac = ( craplcr.dsoperac = "FINANCIAMENTO" )
              aux_idcarga  = 0.

        DO aux_contador = 1 TO 10:

           FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                              craplcr.cdlcremp = crawepr.cdlcremp
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE craplcr   THEN
              IF LOCKED craplcr   THEN
                 DO:
                     ASSIGN aux_cdcritic = 77.
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                     ASSIGN aux_cdcritic = 363.

                     UNDO EFETIVACAO, LEAVE EFETIVACAO.
                 END.

           ASSIGN aux_cdcritic = 0.
           LEAVE.

       END.

       /*** Comentado por Lucas Lunelli - 21/08/2013

       IF   aux_floperac   THEN             /* Financiamento*/
            ASSIGN aux_cdhistor = 1033
                   aux_nrdolote = 600002.
       ELSE                                 /* Emprestimo */
            ASSIGN aux_cdhistor = 1032
                   aux_nrdolote = 600001.

       RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

       /* Lancamento Contrato de Financiamento / Emprestimo e atualizar lote */
       RUN cria_lancamento_lem IN h-b1wgen0134
                               (INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT crapope.cdpactra,
                                INPUT 100,          /* cdbccxlt */
                                INPUT par_cdoperad,
                                INPUT 4, /* tplotmov */
                                INPUT aux_nrdolote,
                                INPUT par_nrdconta,
                                INPUT aux_cdhistor,
                                INPUT par_nrctremp,
                                INPUT aux_vltotctr, /* Empréstimo +  Juros */
                                INPUT par_dtmvtolt,
                                INPUT craplcr.txdiaria,
                                INPUT 0,
                                INPUT 0,
                                INPUT 0,
                                INPUT TRUE,
                                INPUT TRUE).

       DELETE PROCEDURE h-b1wgen0134.

       IF   RETURN-VALUE <> "OK"   THEN
            DO:
                ASSIGN aux_dscritic = "Erro na criacao do lancamento".

                UNDO EFETIVACAO , LEAVE EFETIVACAO.
            END.
       ****/

       FOR FIRST crappre FIELDS(cdfinemp vlmulpli vllimmin) WHERE crappre.cdcooper = par_cdcooper     
                                                              AND crappre.inpessoa = crapass.inpessoa
                                                              AND (crappre.cdfinemp = crawepr.cdfinemp
                                                               OR crawepr.flgpreap = 1) NO-LOCK: END.

       /* Verifica se o emprestimo eh pre-aprovado */
       IF AVAIL crappre THEN
          DO:

              FIND crapass WHERE crapass.cdcooper = par_cdcooper
                   AND crapass.nrdconta = par_nrdconta
                   NO-LOCK NO-ERROR.

              IF NOT AVAILABLE crapass THEN   
                DO:
                   ASSIGN aux_dscritic = "Associado nao cadastrado ".
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.
                END.

              IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                 RUN sistema/generico/procedures/b1wgen0188.p 
                     PERSISTENT SET h-b1wgen0188.
                     
              /* Busca a carga ativa */
              RUN busca_carga_ativa IN h-b1wgen0188(INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_idcarga).
        
              IF VALID-HANDLE(h-b1wgen0188) THEN
                 DELETE PROCEDURE(h-b1wgen0188).

              /* Verificar se existe carga ativa para o cooperado */
              IF aux_idcarga = 0 THEN
                DO:
                  ASSIGN aux_dscritic = "Associado sem pre-aprovado liberado".
                  UNDO EFETIVACAO, LEAVE EFETIVACAO.
                END.

              Contador: DO aux_contador = 1 TO 10:

                 FIND crapcpa WHERE crapcpa.cdcooper       = par_cdcooper AND
                                    crapcpa.tppessoa       = crapass.inpessoa AND
                                    crapcpa.nrcpfcnpj_base = 
                                    crapass.nrcpfcnpj_base AND
                                    crapcpa.iddcarga       = aux_idcarga
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF NOT AVAILABLE crapcpa THEN
                    IF LOCKED crapcpa THEN
                        DO:
                           ASSIGN aux_cdcritic = 77.
                           PAUSE 2 NO-MESSAGE.
                           NEXT.
                       END.
                    ELSE
                       DO:
                           ASSIGN aux_dscritic = "Associado nao cadastrado " +
                                                 "no pre-aprovado".
                           UNDO EFETIVACAO, LEAVE EFETIVACAO.
                       END.

                 ASSIGN aux_cdcritic = 0.
                 LEAVE Contador.

              END. /* END Contador: DO aux_contador = 1 TO 10: */

              /* Depois de alocado o registro, vamos verificar se possui saldo
                 disponivel */
              IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                 RUN sistema/generico/procedures/b1wgen0188.p
                     PERSISTENT SET h-b1wgen0188.

              /* Valida os dados do credito pre-aprovado */
              RUN valida_dados_contrato IN h-b1wgen0188 (INPUT par_cdcooper,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdoperad,
                                                         INPUT par_nmdatela,
                                                         INPUT par_idorigem,
                                                         INPUT par_nrdconta,
                                                         INPUT par_idseqttl,
                                                         INPUT crawepr.vlemprst,
                                                         INPUT DAY(par_dtdpagto),
                                                         INPUT par_nrcpfope,
                                                         INPUT par_nrctremp,
                                                         OUTPUT TABLE tt-erro).

              IF VALID-HANDLE(h-b1wgen0188) THEN
                 DELETE PROCEDURE(h-b1wgen0188).

              IF RETURN-VALUE <> "OK" THEN
                 RETURN "NOK".

              /* Atualiza o valor contratado do credito pre-aprovado */
              ASSIGN crapcpa.vlctrpre = crapcpa.vlctrpre + crawepr.vlemprst.
          END. /* END IF AVAIL crappre AND par_cdfinemp = crappre.cdfinemp  */
      RUN buscar_historico_e_lote_efet_prop(INPUT crawepr.tpemprst
                                           ,INPUT crawepr.idfiniof
                                           ,INPUT craplcr.dsoperac
                                           ,OUTPUT aux_cdhistor
                                           ,OUTPUT aux_cdhistor_tar
                                           ,OUTPUT aux_nrdolote).
        
      /* Projeto 410 - Novo IOF */
      ASSIGN aux_flgimune = 0
             aux_vltotiof = 0
             aux_qtdiaiof = 1
             aux_dscatbem = "".

      FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                         crapjur.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.
      FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper  AND
                             crapbpr.nrdconta = crawepr.nrdconta  AND
                             crapbpr.nrctrpro = crawepr.nrctremp  AND
                             crapbpr.tpctrpro = 90 NO-LOCK:
          ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
      END.

       ASSIGN aux_dsctrliq = "".
       
       DO i = 1 TO 10:

         IF  crawepr.nrctrliq[i] > 0  THEN
           aux_dsctrliq = aux_dsctrliq +
              (IF  aux_dsctrliq = ""  THEN
                   TRIM(STRING(crawepr.nrctrliq[i],
                               "z,zzz,zz9"))
               ELSE
                   ", " +
                   TRIM(STRING(crawepr.nrctrliq[i],
                               "z,zzz,zz9"))).

       END. /** Fim do DO ... TO **/

      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
      RUN STORED-PROCEDURE pc_calcula_iof_epr
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper       /* Código da cooperativa */
                                          ,INPUT par_nrdconta       /* Número da conta */
                                          ,INPUT crawepr.nrctremp   /* Numero do contrato */
                                          ,INPUT par_dtmvtolt       /* Data do movimento para busca na tabela de IOF */
                                          ,INPUT crapass.inpessoa   /* Tipo de Pessoa */
                                          ,INPUT crawepr.cdlcremp   /* Linha de crédito */
                                          ,INPUT crawepr.cdfinemp   /* Finalidade */
                                          ,INPUT crawepr.qtpreemp   /* Quantidade de parcelas */
                                          ,INPUT crawepr.vlpreemp   /* Valor da parcela do emprestimo */
                                          ,INPUT crawepr.vlemprst   /* Valor do emprestimo */
                                          ,INPUT crawepr.dtdpagto   /* Data de pagamento */
                                          ,INPUT crawepr.dtlibera   /* Data de liberação */
                                          ,INPUT crawepr.tpemprst   /* Tipo de emprestimo */
                                          ,INPUT crawepr.dtcarenc
                                          ,INPUT 0 /* dias de carencia */
                                          ,INPUT aux_dscatbem       /* Bens em garantia */
                                          ,INPUT crawepr.idfiniof   /* Indicador de financiamento de iof e tarifa */
                                          ,INPUT aux_dsctrliq       /* pr_dsctrliq */
                                          ,INPUT "S"                /* Gravar valor do IOF p/parcela nas parcelas */
                                          ,OUTPUT 0                 /* Valor calculado da Parcela */
                                          ,OUTPUT 0                 /* Retorno do valor do IOF */
                                          ,OUTPUT 0                 /* pr_vliofpri Valor calculado do iof principal */
                                          ,OUTPUT 0                 /* pr_vliofadi Valor calculado do iof adicional */
                                          ,OUTPUT 0                 /* pr_flgimune Possui imunidade tributária (1 - Sim / 0 - Nao) */
                                          ,OUTPUT "").              /* Critica */

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_calcula_iof_epr
      
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

      /* Se retornou erro */
      ASSIGN aux_dscritic = ""
             aux_dscritic = pc_calcula_iof_epr.pr_dscritic WHEN pc_calcula_iof_epr.pr_dscritic <> ?.
             
      IF aux_dscritic <> "" THEN
        UNDO EFETIVACAO, LEAVE EFETIVACAO.
        
      /* Retorno do calculo */
      ASSIGN aux_vlpreclc = 0
             aux_vltotiof = 0
             aux_vliofpri = 0
             aux_vliofadi = 0
             aux_flgimune = 0.
      ASSIGN aux_vlpreclc = pc_calcula_iof_epr.pr_vlpreclc WHEN pc_calcula_iof_epr.pr_vlpreclc <> ?
             aux_vltotiof = pc_calcula_iof_epr.pr_valoriof WHEN pc_calcula_iof_epr.pr_valoriof <> ?
             aux_vliofpri = pc_calcula_iof_epr.pr_vliofpri WHEN pc_calcula_iof_epr.pr_vliofpri <> ?
             aux_vliofadi = pc_calcula_iof_epr.pr_vliofadi WHEN pc_calcula_iof_epr.pr_vliofadi <> ? 
             aux_flgimune = pc_calcula_iof_epr.pr_flgimune WHEN pc_calcula_iof_epr.pr_flgimune <> ?.
      

      /* Buscar a tarifa */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
      RUN STORED-PROCEDURE pc_calcula_tarifa
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper       /* Código da cooperativa */
                                          ,INPUT par_nrdconta       /* Número da conta */
                                          ,INPUT crawepr.cdlcremp   /* Linha de crédito */
                                          ,INPUT crawepr.vlemprst   /* Valor do emprestimo */
                                          ,INPUT craplcr.cdusolcr   /* Uso da linha de crédito */
                                          ,INPUT craplcr.tpctrato   /* Tipo de contrato */
                                          ,INPUT aux_dscatbem       /* Bens em garantia */
                                          ,INPUT 'ATENDA'           /* Nome do programa */
                                          ,INPUT 'N'                /* Flag de envio de e-mail */
                                          ,INPUT crawepr.tpemprst   /* Tipo de empréstimo */
                                          ,INPUT crawepr.idfiniof   /* Identificador se financia iof e tarifa */                                          
                                          ,OUTPUT 0                 /* Valor da tarifa */
                                          ,OUTPUT 0                 /* Valor da tarifa especial */
                                          ,OUTPUT 0                 /* Valor da tarifa garantia */
                                          ,OUTPUT 0                 /* Histórico do lançamento */
                                          ,OUTPUT 0                 /* Faixa de valor por cooperativa */
                                          ,OUTPUT 0                 /* Historico Garantia */
                                          ,OUTPUT 0                 /* Faixa de valor garantia */
                                          ,OUTPUT 0                 /* Crítica encontrada */
                                          ,OUTPUT "").              /* Critica */

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_calcula_tarifa
      
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

      /* Se retornou erro */
      ASSIGN aux_dscritic = ""
             aux_dscritic = pc_calcula_tarifa.pr_dscritic WHEN pc_calcula_tarifa.pr_dscritic <> ?.
      IF aux_dscritic <> "" THEN
        UNDO EFETIVACAO, LEAVE EFETIVACAO.
            
      /* Valor tarifa */
      ASSIGN aux_vltarifa = 0.
      IF pc_calcula_tarifa.pr_vlrtarif <> ? THEN
          ASSIGN aux_vltarifa = aux_vltarifa + ROUND(DECI(pc_calcula_tarifa.pr_vlrtarif),2).
      IF pc_calcula_tarifa.pr_vltrfesp <> ? THEN
          ASSIGN aux_vltarifa = aux_vltarifa + ROUND(DECI(pc_calcula_tarifa.pr_vltrfesp),2).
      IF pc_calcula_tarifa.pr_vltrfgar <> ? THEN
          ASSIGN aux_vltrfgar = ROUND(DECI(pc_calcula_tarifa.pr_vltrfgar),2).
        
     ASSIGN aux_cdhistar_cad = 0
            aux_cdhistar_gar = 0
            aux_cdhistar_cad = pc_calcula_tarifa.pr_cdhistor WHEN pc_calcula_tarifa.pr_cdhistor <> ?
            aux_cdhistar_gar = pc_calcula_tarifa.pr_cdhisgar WHEN pc_calcula_tarifa.pr_cdhisgar <> ?.
     
     
     /* Se for Pos-Fixado */
     IF  crawepr.tpemprst = 2  THEN DO:
             ASSIGN aux_nrdolote_cred = 650004.

             IF   aux_floperac   THEN             /* Financiamento*/
                ASSIGN aux_cdhistor_cred = 2327.
             ELSE                                 /* Emprestimo */
                  ASSIGN aux_cdhistor_cred = 2326.
         END.
     ELSE
         DO:
            FIND crapfin WHERE crapfin.cdcooper = crawepr.cdcooper
                           AND crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR NO-WAIT.
         
            IF AVAILABLE crapfin THEN
              ASSIGN aux_tpfinali = crapfin.tpfinali.                
         
            IF aux_floperac THEN /* Financiamento*/
              DO:
                IF aux_tpfinali = 3 THEN /* CDC */
                  ASSIGN aux_cdhistor_cred = 2014.
                ELSE
                  ASSIGN aux_cdhistor_cred = 1059.
                  
                ASSIGN  aux_nrdolote_cred = 600030.
              END.
           ELSE /* Emprestimo */
             DO:
              IF aux_tpfinali = 3 THEN /* CDC */
                ASSIGN aux_cdhistor_cred = 2013.
              ELSE
                ASSIGN aux_cdhistor_cred = 1036.
              
              ASSIGN aux_nrdolote_cred = 600005.
             END.
         END.

     RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

     RUN cria_lancamento_lem IN h-b1wgen0134
                             (INPUT par_cdcooper,
                              INPUT par_dtmvtolt,
                              INPUT par_cdagenci,
                              INPUT 100,          /* cdbccxlt */
                              INPUT par_cdoperad,
                              INPUT par_cdagenci,
                              INPUT 4,            /* tplotmov */
                              INPUT aux_nrdolote_cred, /* nrdolote */
                              INPUT par_nrdconta,
                              INPUT aux_cdhistor_cred,
                              INPUT par_nrctremp,
                              INPUT aux_vltotemp, /* Valor total emprestado */
                              INPUT par_dtmvtolt,
                              INPUT craplcr.txdiaria,
                              INPUT 0,
                              INPUT 0,
                              INPUT 0,
                              INPUT TRUE,
                              INPUT TRUE,
                              INPUT 0,
                              INPUT par_idorigem).

        DELETE PROCEDURE h-b1wgen0134.

        IF RETURN-VALUE <> "OK"   THEN
          DO:
              ASSIGN aux_dscritic = "Erro na criacao do lancamento".

              UNDO EFETIVACAO , LEAVE EFETIVACAO.
          END.

       /* Caso nao cobrou IOF pois é imune, mas possui valor principal ou adicional */
       IF aux_flgimune = 1 AND (aux_vliofpri > 0 OR aux_vliofadi > 0 ) THEN
       DO:
           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
           /* Efetuar a chamada a rotina Oracle */
           RUN STORED-PROCEDURE pc_insere_iof
           aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                               ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                                               ,INPUT par_dtmvtolt        /* Data de Movimento        */
                                               ,INPUT 1                   /* Emprestimo       */
                                               ,INPUT par_nrctremp        /* Numero do Bordero        */
                                               ,INPUT ?                   /* ID Lautom                */
                                               ,INPUT ?                   /* Data Movimento LCM       */
                                               ,INPUT ?                   /* Numero da Agencia LCM    */
                                               ,INPUT ?                   /* Numero do Caixa LCM      */
                                               ,INPUT ?                   /* Numero do Lote LCM       */
                                               ,INPUT ?                   /* Sequencia LCM            */
                                               ,INPUT aux_vliofpri        /* Valor Principal IOF      */
                                               ,INPUT aux_vliofadi        /* Valor Adicional IOF      */
                                               ,INPUT 0                   /* Valor Complementar IOF   */
                                               ,INPUT aux_flgimune        /* Possui imunidade tributária (1 - Sim / 0 - Nao)*/
                                               ,OUTPUT 0                  /* Codigo da Critica */
                                               ,OUTPUT "").               /* Descriçao da crítica */
           
           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_insere_iof
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = ""
                  aux_cdcritic = pc_insere_iof.pr_cdcritic
                                 WHEN pc_insere_iof.pr_cdcritic <> ?
                  aux_dscritic = pc_insere_iof.pr_dscritic
                                 WHEN pc_insere_iof.pr_dscritic <> ?.
           /* Se retornou erro */
           IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
           DO:
               /*MESSAGE "(2) Erro ao inserir lancamento de IOF.".*/
               ASSIGN aux_dscritic = "Erro ao inserir lancamento de IOF.".
               UNDO EFETIVACAO , LEAVE EFETIVACAO.
           END.
        
      END.

      /* Se Financia IOF, gera lancamento na LEM */             
      IF crawepr.idfiniof = 1 THEN 
      DO:  
          IF aux_vltotiof > 0 THEN
            DO:
              /* Gera a LEM se for financiado IOF */
              RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

              RUN cria_lancamento_lem_chave IN h-b1wgen0134
                                  (INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT par_cdagenci,
                                   INPUT 100,          /* cdbccxlt */
                                   INPUT par_cdoperad,
                                   INPUT par_cdagenci,
                                   INPUT 4,            /* tplotmov */
                                   INPUT aux_nrdolote, /* nrdolote */
                                   INPUT par_nrdconta,
                                   INPUT aux_cdhistor,
                                   INPUT par_nrctremp,
                                   INPUT aux_vltotiof, /* Valor IOF */
                                   INPUT par_dtmvtolt,
                                   INPUT craplcr.txdiaria,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT TRUE,
                                   INPUT TRUE,
                                   INPUT 0,
                                   INPUT par_idorigem,
                                   OUTPUT aux_nrseqdig ).

              DELETE PROCEDURE h-b1wgen0134.

              IF RETURN-VALUE <> "OK"   THEN
              DO:
                  ASSIGN aux_dscritic = "Erro na criacao do lancamento".

                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.
           
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
              /* Efetuar a chamada a rotina Oracle */
              RUN STORED-PROCEDURE pc_insere_iof
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                                  ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                                                  ,INPUT par_dtmvtolt        /* Data de Movimento        */
                                                  ,INPUT 1                   /* Emprestimo       */
                                                  ,INPUT par_nrctremp        /* Numero do Bordero        */
                                                  ,INPUT ?                   /* ID Lautom                */
                                                  ,INPUT par_dtmvtolt       /* Data Movimento LCM       */
                                                  ,INPUT par_cdagenci       /* Numero da Agencia LCM    */
                                                  ,INPUT 100                /* Numero do Caixa LCM      */
                                                  ,INPUT aux_nrdolote       /* Numero do Lote LCM       */
                                                  ,INPUT aux_nrseqdig        /* Sequencia LCM            */
                                                  ,INPUT aux_vliofpri        /* Valor Principal IOF      */
                                                  ,INPUT aux_vliofadi        /* Valor Adicional IOF      */
                                                  ,INPUT 0                   /* Valor Complementar IOF   */
                                                  ,INPUT aux_flgimune        /* Possui imunidade tributária (1 - Sim / 0 - Nao)*/
                                                  ,OUTPUT 0                  /* Codigo da Critica */
                                                  ,OUTPUT "").               /* Descriçao da crítica */
                                               
               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_insere_iof
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = ""
                      aux_cdcritic = pc_insere_iof.pr_cdcritic
                                     WHEN pc_insere_iof.pr_cdcritic <> ?
                      aux_dscritic = pc_insere_iof.pr_dscritic
                                     WHEN pc_insere_iof.pr_dscritic <> ?.
               /* Se retornou erro */
               IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
                  DO:
                      /*MESSAGE "(1) Erro ao inserir lancamento de IOF.".*/
                      ASSIGN aux_dscritic = "Erro ao inserir lancamento de IOF.".
                      UNDO EFETIVACAO , LEAVE EFETIVACAO.
               END.

           END.    


          /* Gera a tarifa na LEM se for financiado IOF */
          IF aux_vltarifa > 0 THEN
          DO:
              IF aux_cdhistar_cad = 0 THEN DO:         
                  ASSIGN aux_dscritic = "Historico de tarifa nao encontrado".
                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.

              RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

              RUN cria_lancamento_lem IN h-b1wgen0134
                                      (INPUT par_cdcooper,
                                       INPUT par_dtmvtolt,
                                       INPUT par_cdagenci,
                                       INPUT 100,          /* cdbccxlt */
                                       INPUT par_cdoperad,
                                       INPUT par_cdagenci,
                                       INPUT 4,            /* tplotmov */
                                       INPUT aux_nrdolote, /* nrdolote */
                                       INPUT par_nrdconta,
                                       INPUT aux_cdhistar_cad,
                                       INPUT par_nrctremp,
                                       INPUT aux_vltarifa, /* Valor TARIFA */
                                       INPUT par_dtmvtolt,
                                       INPUT craplcr.txdiaria,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT TRUE,
                                       INPUT TRUE,
                                       INPUT 0,
                                       INPUT par_idorigem).
         
              DELETE PROCEDURE h-b1wgen0134.

              IF RETURN-VALUE <> "OK"   THEN
              DO:
                  ASSIGN aux_dscritic = "Erro na criacao do lancamento".

                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.
          END.
          /* Gerar tarifa de bens */
          IF aux_vltrfgar > 0 THEN
          DO:
              IF aux_cdhistar_gar = 0 THEN DO:
                
                  ASSIGN aux_dscritic = "Historico de tarifa nao encontrado".
                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.

          /* Gera a LEM se for financiado IOF */
          RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.

          RUN cria_lancamento_lem IN h-b1wgen0134
                                  (INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT par_cdagenci,
                                   INPUT 100,          /* cdbccxlt */
                                   INPUT par_cdoperad,
                                   INPUT par_cdagenci,
                                   INPUT 4,            /* tplotmov */
                                   INPUT aux_nrdolote, /* nrdolote */
                                   INPUT par_nrdconta,
                                   INPUT aux_cdhistar_gar,
                                   INPUT par_nrctremp,
                                   INPUT aux_vltrfgar, /* Valor TARIFA */
                                   INPUT par_dtmvtolt,
                                   INPUT craplcr.txdiaria,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT TRUE,
                                   INPUT TRUE,
                                   INPUT 0,
                                   INPUT par_idorigem).
          
          DELETE PROCEDURE h-b1wgen0134.
          
          IF RETURN-VALUE <> "OK"   THEN
              DO:
                  ASSIGN aux_dscritic = "Erro na criacao do lancamento".
          
                  UNDO EFETIVACAO , LEAVE EFETIVACAO.
              END.
          
          END.

      END. /* IF crawepr.idfiniof = 0 THEN */
        
      /* Agrupar valor de tarifas cobradas */
      ASSIGN aux_vltarifa = aux_vltarifa + aux_vltrfgar. 
        
      
      /* Busca a taxa de IOF principal contratada */
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

      /* Efetuar a chamada a rotina Oracle  */
      RUN STORED-PROCEDURE pc_busca_taxa_iof_prg
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctremp,
                                               INPUT par_dtmvtolt,
                                               INPUT crawepr.cdlcremp,
                                               INPUT crawepr.cdfinemp,
                                               INPUT crawepr.vlemprst,
                                               OUTPUT "",
                                               OUTPUT "",
                                               OUTPUT 0,
                                               OUTPUT 0,
                                               OUTPUT "").

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_busca_taxa_iof_prg
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
      
      ASSIGN aux_dscritic = ""
             aux_vlaqiofc = 0
             aux_vlaqiofc = DECI(pc_busca_taxa_iof_prg.pr_vltxiofpri) WHEN pc_busca_taxa_iof_prg.pr_vltxiofpri <> ?
             aux_dscritic = pc_busca_taxa_iof_prg.pr_dscritic WHEN pc_busca_taxa_iof_prg.pr_dscritic <> ?.
      IF aux_vlaqiofc = 0 THEN    
         ASSIGN aux_vlaqiofc = DECI(pc_busca_taxa_iof_prg.pr_vltxiofcpl) WHEN pc_busca_taxa_iof_prg.pr_vltxiofcpl <> ?.

      IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         UNDO EFETIVACAO , LEAVE EFETIVACAO.
      /* Inicio P438 */
      /* Se for PP e origem Ayllos Web*/
      IF  crawepr.tpemprst = 1 AND crawepr.cdorigem = 5 THEN
          DO:
              /* Caso NAO seja Refinanciamento efetua credito na conta  */
              IF  NOT CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                                         AND crawepr.nrdconta = par_nrdconta
                                         AND crawepr.nrctremp = par_nrctremp
                                         AND (crawepr.nrctrliq[1]  > 0   OR
                                              crawepr.nrctrliq[2]  > 0   OR
                                              crawepr.nrctrliq[3]  > 0   OR
                                              crawepr.nrctrliq[4]  > 0   OR
                                              crawepr.nrctrliq[5]  > 0   OR
                                              crawepr.nrctrliq[6]  > 0   OR
                                              crawepr.nrctrliq[7]  > 0   OR
                                              crawepr.nrctrliq[8]  > 0   OR
                                              crawepr.nrctrliq[9]  > 0   OR
                                              crawepr.nrctrliq[10] > 0)) THEN
                  DO:
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
         
                      /* Efetuar a chamada a rotina Oracle  */
                      RUN STORED-PROCEDURE pc_credito_online_pp
                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                               INPUT par_nrdconta,
                                                               INPUT par_nrctremp,
                                                               INPUT par_nmdatela,
                                                               INPUT crapass.inpessoa,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_cdagenci, /* pr_cdpactra */
                                                               INPUT par_cdoperad,
                                                              OUTPUT 0,   /* pr_vltottar */
                                                              OUTPUT 0,   /* pr_vltariof */
                                                              OUTPUT 0,   /* pr_cdcritic */
                                                              OUTPUT ""). /* pr_dscritic */

                      /* Fechar o procedimento para buscarmos o resultado */ 
                      CLOSE STORED-PROC pc_credito_online_pp
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                      
                      ASSIGN aux_vltottar = 0
                             aux_vltariof = 0
                             aux_cdcritic = 0
                             aux_dscritic = ""
                             aux_vltottar = pc_credito_online_pp.pr_vltottar
                                            WHEN pc_credito_online_pp.pr_vltottar <> ?
                             aux_vltariof = pc_credito_online_pp.pr_vltariof
                                            WHEN pc_credito_online_pp.pr_vltariof <> ?
                             aux_cdcritic = INT(pc_credito_online_pp.pr_cdcritic) 
                                            WHEN pc_credito_online_pp.pr_cdcritic <> ?
                             aux_dscritic = pc_credito_online_pp.pr_dscritic
                                            WHEN pc_credito_online_pp.pr_dscritic <> ?
                             aux_vltarifa = aux_vltottar.

                      IF   aux_cdcritic <> 0    OR
                           aux_dscritic <> ""   THEN
                        DO:
                         CREATE tt-erro.
                         ASSIGN tt-erro.cdcritic = aux_cdcritic
                                tt-erro.dscritic = aux_dscritic.
                           UNDO EFETIVACAO , LEAVE EFETIVACAO.
                        END.
         
                  END. /* NOT CAN-FIND */

          END. /* crawepr.tpemprst = 1 */
      /* Fim P438 */
      /**/
      /* Se for Pos-Fixado */
      IF  crawepr.tpemprst = 2  THEN
          DO:
              /* Caso NAO seja Refinanciamento efetua credito na conta  */
              IF  NOT CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                                         AND crawepr.nrdconta = par_nrdconta
                                         AND crawepr.nrctremp = par_nrctremp
                                         AND (crawepr.nrctrliq[1]  > 0   OR
                                              crawepr.nrctrliq[2]  > 0   OR
                                              crawepr.nrctrliq[3]  > 0   OR
                                              crawepr.nrctrliq[4]  > 0   OR
                                              crawepr.nrctrliq[5]  > 0   OR
                                              crawepr.nrctrliq[6]  > 0   OR
                                              crawepr.nrctrliq[7]  > 0   OR
                                              crawepr.nrctrliq[8]  > 0   OR
                                              crawepr.nrctrliq[9]  > 0   OR
                                              crawepr.nrctrliq[10] > 0)) THEN
                  DO:
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                              
                      /* Efetuar a chamada a rotina Oracle  */
                      RUN STORED-PROCEDURE pc_efetua_credito_conta
                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                               INPUT par_nrdconta,
                                                               INPUT par_nrctremp,
                                                               INPUT par_dtmvtolt,
                                                               INPUT par_nmdatela,
                                                               INPUT crapass.inpessoa,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_cdagenci, /* pr_cdpactra */
                                                               INPUT par_cdoperad,
                                                              OUTPUT 0,   /* pr_vltottar */
                                                              OUTPUT 0,   /* pr_vltariof */
                                                              OUTPUT 0,   /* pr_cdcritic */
                                                              OUTPUT ""). /* pr_dscritic */

                      /* Fechar o procedimento para buscarmos o resultado */ 
                      CLOSE STORED-PROC pc_efetua_credito_conta
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                      
                      ASSIGN aux_vltottar = 0
                             aux_vltariof = 0
                             aux_cdcritic = 0
                             aux_dscritic = ""
                             aux_vltottar = pc_efetua_credito_conta.pr_vltottar
                                            WHEN pc_efetua_credito_conta.pr_vltottar <> ?
                             aux_vltariof = pc_efetua_credito_conta.pr_vltariof
                                            WHEN pc_efetua_credito_conta.pr_vltariof <> ?
                             aux_cdcritic = INT(pc_efetua_credito_conta.pr_cdcritic) 
                                            WHEN pc_efetua_credito_conta.pr_cdcritic <> ?
                             aux_dscritic = pc_efetua_credito_conta.pr_dscritic
                                            WHEN pc_efetua_credito_conta.pr_dscritic <> ?
                             aux_vltarifa = aux_vltottar.

                      IF   aux_cdcritic <> 0    OR
                           aux_dscritic <> ""   THEN
                        DO:
                         CREATE tt-erro.
                         ASSIGN tt-erro.cdcritic = aux_cdcritic
                                tt-erro.dscritic = aux_dscritic.
                           UNDO EFETIVACAO , LEAVE EFETIVACAO.
                        END.

                  END. /* NOT CAN-FIND */

          END. /* crawepr.tpemprst = 2 */

       FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF AVAILABLE crapass   THEN
          DO:
              IF crapass.inpessoa = 1   THEN
                 DO:
                     FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1
                                        NO-LOCK NO-ERROR.

                     IF AVAIL crapttl  THEN
                        ASSIGN aux_cdempres = crapttl.cdempres.

                  END.
              ELSE
                 DO:
                    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                       crapjur.nrdconta = crapass.nrdconta
                                       NO-LOCK NO-ERROR.

                    IF AVAIL crapjur  THEN
                       ASSIGN aux_cdempres = crapjur.cdempres.

                 END.

                 END.

       /* Diego Simas (AMcom) - PJ 450                       */
       /* Início                                             */
       /* Verifica se existe algum contrato limite/adp       */
       /* e adiciona a lista de contratos para qualificar    */ 
       IF aux_dsctrliq <> "" THEN DO:
            IF crawepr.nrliquid <> 0 THEN
               aux_dsctrliq = aux_dsctrliq + 
                 ", " + TRIM(STRING(crawepr.nrliquid, "z,zzz,zz9")).                           
                 END.
       ELSE DO:
            IF crawepr.nrliquid <> 0 THEN
               aux_dsctrliq = aux_dsctrliq + 
                 TRIM(STRING(crawepr.nrliquid, "z,zzz,zz9")).               
            END.
       /***********************
          CALCULO DATA RISCO REFIN
          Se houve alguma liquidacao de contrato
       ***********************/
       IF (crawepr.nrctrliq[1]  > 0
       OR  crawepr.nrctrliq[2]  > 0
       OR  crawepr.nrctrliq[3]  > 0
       OR  crawepr.nrctrliq[4]  > 0
       OR  crawepr.nrctrliq[5]  > 0
       OR  crawepr.nrctrliq[6]  > 0
       OR  crawepr.nrctrliq[7]  > 0
       OR  crawepr.nrctrliq[8]  > 0
       OR  crawepr.nrctrliq[9]  > 0
       OR  crawepr.nrctrliq[10] > 0
       OR  crawepr.nrliquid     > 0) THEN DO:

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
           /* Verifica se ha contratos de acordo */
           RUN STORED-PROCEDURE pc_dias_atraso_liquidados
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                 ,INPUT par_nrdconta
                                                 ,INPUT crawepr.nrctremp
                                                 ,OUTPUT 0
                                                 ,OUTPUT "").
    
           CLOSE STORED-PROC pc_dias_atraso_liquidados
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
           ASSIGN aux_qtdiaatr = 0
                  aux_dscritic = ""
                  aux_dscritic = pc_dias_atraso_liquidados.pr_dscritic WHEN pc_dias_atraso_liquidados.pr_dscritic <> ?
                  aux_qtdiaatr = INT(pc_dias_atraso_liquidados.pr_qtdatref).
            
           IF (aux_dscritic <> ? AND aux_dscritic <> "") THEN
              ASSIGN aux_dtrisref = par_dtmvtolt
                     aux_qtdiaatr = 0.
    
           ASSIGN aux_dtrisref = par_dtmvtolt - aux_qtdiaatr.
       END.
       ELSE 
           ASSIGN aux_dtrisref = ?.
       /***********************/

       /* Acionar rotina que gera a qualificacao da operacao */
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       RUN STORED-PROCEDURE pc_proc_qualif_operacao
           aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,     /* Cooperativa       */
                             INPUT par_cdagenci,     /* Cod Agencia       */
                             INPUT par_nrdcaixa,     /* Nr do Caixa       */
                             INPUT par_cdoperad,     /* Cod Operador      */ 
                             INPUT par_nmdatela,     /* Programa Chamador */
                             INPUT par_idorigem,     /* Origem            */
                             INPUT par_nrdconta,     /* Conta             */
                             INPUT aux_dsctrliq,     /* Contratos Liquidados */
                             INPUT par_dtmvtolt,     /* Data do Movimento    */
                             INPUT par_dtmvtopr,     /* Data do Proximo dia de movimento */
                            /* -- OUTPUTS -- */
                            OUTPUT 0,                /* Id Qualif Operacao  */
                            OUTPUT "",               /* Descricao Qualif Operacao        */
                            OUTPUT 0,                /* ERRO - Id da critica */ 
                            OUTPUT "").              /* ERRO - Descricao da critica      */

       CLOSE STORED-PROC pc_proc_qualif_operacao 
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_cdcritic = 0
              aux_dscritic = ""
              aux_idquapro = 1
              aux_cdcritic = pc_proc_qualif_operacao.pr_cdcritic 
                             WHEN pc_proc_qualif_operacao.pr_cdcritic <> ?
              aux_dscritic = pc_proc_qualif_operacao.pr_dscritic 
                             WHEN pc_proc_qualif_operacao.pr_dscritic <> ?
              aux_idquapro = pc_proc_qualif_operacao.pr_idquapro 
                             WHEN pc_proc_qualif_operacao.pr_idquapro <> ?.
           
       IF  aux_cdcritic <> 0   OR
           aux_dscritic <> ""  THEN
           DO:                                    
               CREATE tt-erro.
               ASSIGN tt-erro.cdcritic = aux_cdcritic
                      tt-erro.dscritic = aux_dscritic.
               UNDO EFETIVACAO, LEAVE EFETIVACAO.
          END.

       FOR FIRST crapfin FIELDS(tpfinali)
          WHERE crapfin.cdcooper = par_cdcooper
                    AND crapfin.cdfinemp = crawepr.cdfinemp
        NO-LOCK: END.    
    
       IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
         ASSIGN aux_flgcescr = TRUE.

       /* CESSAO DE CARTAO - sempre sera 5-Cessao Cartao */
       IF  aux_flgcescr THEN
           ASSIGN aux_idquapro = 5.
           
       /* Requalifica a operacao na proposta                 */
       /* INICIO                                             */       
       FIND FIRST b-crawepr
          WHERE b-crawepr.cdcooper = par_cdcooper AND
                b-crawepr.nrdconta = par_nrdconta AND
                b-crawepr.nrctremp = par_nrctremp
                EXCLUSIVE-LOCK NO-ERROR.
       
       IF AVAIL b-crawepr THEN
          ASSIGN b-crawepr.idquapro = aux_idquapro.
       /* FIM                                                */
       /* Requalifica a operacao na proposta                 */
       
       /* Fim                                                */    
       /* Diego Simas (AMcom) - PJ 450                       */

       CREATE crapepr.
       ASSIGN crapepr.dtmvtolt = par_dtmvtolt
              crapepr.cdagenci = par_cdagenci
              /* Gravar operador que efetivou a proposta */
              crapepr.cdopeefe = par_cdoperad
              crapepr.cdbccxlt = 100
              crapepr.nrdolote = aux_nrdolote_cred
              crapepr.nrdconta = par_nrdconta
              /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
              crapepr.cdopeori = par_cdoperad
              crapepr.cdageori = par_cdagenci
              crapepr.dtinsori = TODAY
              /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
              crapepr.nrctremp = par_nrctremp
              crapepr.cdorigem = par_idorigem

              crapepr.cdfinemp = crawepr.cdfinemp
              crapepr.cdlcremp = crawepr.cdlcremp
              crapepr.vlemprst = crawepr.vlemprst
              crapepr.vlpreemp = IF (crawepr.idcarenc > 1) THEN
                                      crawepr.vlprecar
                                 ELSE crawepr.vlpreemp
              crapepr.qtpreemp = crawepr.qtpreemp
              crapepr.nrctaav1 = crawepr.nrctaav1
              crapepr.nrctaav2 = crawepr.nrctaav2
              crapepr.txjuremp = crawepr.txdiaria
              crapepr.vlsdeved = crawepr.vlemprst
              crapepr.dtultpag = crawepr.dtmvtolt
              crapepr.tpemprst = crawepr.tpemprst
              crapepr.txmensal = crawepr.txmensal
              crapepr.cdempres = aux_cdempres
              crapepr.nrcadast = crapass.nrcadast
              /* PJ 450 - Diego Simas (AMcom)  */
              /* Requalificar a Operacao       */
              crapepr.idquaprc = aux_idquapro
              crapepr.flgpagto = FALSE
              crapepr.dtdpagto = par_dtdpagto
              crapepr.qtmesdec = 0
              crapepr.qtprecal = 0
              crapepr.dtinipag = ?
              crapepr.tpdescto = crawepr.tpdescto
              crapepr.vliofepr = aux_vltotiof
              crapepr.vliofpri = aux_vliofpri
              crapepr.vliofadc = aux_vliofadi
              crapepr.cdcooper = par_cdcooper
              crapepr.qttolatr = crawepr.qttolatr
              crapepr.vltarifa = aux_vltarifa
              crapepr.vlaqiofc = aux_vlaqiofc
              /*P438 Incluir a tratativa para PP*/
              crapepr.vltariof = aux_vltotiof /* (IF CAN-DO("1,2", STRING(crawepr.tpemprst)) THEN aux_vltariof ELSE aux_vltotiof) */
              crapepr.iddcarga = aux_idcarga
              crapepr.idfiniof = crawepr.idfiniof
              crapepr.dtinicio_atraso_refin = aux_dtrisref.

              if crawepr.idfiniof > 0 then do:
                assign crapepr.vlsdeved = crawepr.vlemprst + aux_vltotiof + aux_vltarifa.
                       crapepr.vlemprst = crawepr.vlemprst + aux_vltotiof + aux_vltarifa.
              end.


       /* Se for Pos-Fixado */
       IF   crawepr.tpemprst = 2   THEN
            DO:
                ASSIGN crapepr.vlsprojt = crawepr.vlemprst.
                IF crawepr.idfiniof > 0  THEN
                   ASSIGN crapepr.vlsprojt = crawepr.vlemprst + aux_vltotiof + aux_vltarifa.
            END.

       IF   crapepr.cdlcremp = 100   THEN
            DO:
                ASSIGN crapepr.dtprejuz = par_dtmvtolt
                       crapepr.inprejuz = 1
                       crapepr.vlsdprej = crapepr.vlsdeved
                       crapepr.vlprejuz = crapepr.vlsdeved
                       crapepr.inliquid = 1
                       crapepr.vlsdeved = 0.

                VALIDATE crapepr.

                FOR EACH crappep FIELDS(inliquid inprejuz)
                                  WHERE crappep.cdcooper = par_cdcooper AND
                                        crappep.nrdconta = par_nrdconta AND
                                        crappep.nrctremp = par_nrctremp AND
                                        crappep.inliquid = 0
                                 EXCLUSIVE-LOCK:
                    ASSIGN crappep.inliquid = 1
                           crappep.inprejuz = 1.
                END.
            END.
       ELSE
         VALIDATE crapepr.

       IF  crawepr.idcobope > 0  THEN
           DO:
              DO i = 1 TO 10:

                 IF  crawepr.nrctrliq[i] > 0  THEN
                     DO:

                        FOR FIRST b-crawepr FIELDS(idcobope)
                                            WHERE b-crawepr.cdcooper = par_cdcooper   AND
                                                  b-crawepr.nrdconta = par_nrdconta   AND
                                                  b-crawepr.nrctremp = crawepr.nrctrliq[i] NO-LOCK:
                           IF  b-crawepr.idcobope > 0  THEN
                               DO:
                                  /* Efetuar o desbloqueio de possiveis coberturas vinculadas ao mesmo */
                                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                  RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                                        ,INPUT b-crawepr.idcobope
                                                                        ,INPUT "D"
                                                                        ,INPUT par_cdoperad
                                                                        ,INPUT ""
                                                                        ,INPUT 0
                                                                        ,INPUT "S"
                                                                        ,"").

                                  CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                  ASSIGN aux_dscritic  = ""
                                         aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                                         WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                                  IF aux_dscritic <> "" THEN
                                     UNDO EFETIVACAO , LEAVE EFETIVACAO.
                               END.
                        END. /* FOR FIRST b-crawepr */

                     END. /* crawepr.nrctrliq[i] > 0 */

              END. /** Fim do DO ... TO **/
        
              /* Efetuar o bloqueio de possiveis coberturas vinculadas ao mesmo */
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                    ,INPUT crawepr.idcobope
                                                    ,INPUT "B"
                                                    ,INPUT par_cdoperad
                                                    ,INPUT ""
                                                    ,INPUT 0
                                                    ,INPUT "S"
                                                    ,"").

              CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_dscritic  = ""
                     aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                     WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

              IF aux_dscritic <> "" THEN
                 UNDO EFETIVACAO , LEAVE EFETIVACAO.


           END. /* crawepr.idcobope > 0 */

           
/*-----------inicio p450 rating------------------------------------*/

       FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                                crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                                crapprm.cdcooper = par_cdcooper
                                NO-LOCK NO-ERROR.
       
       ASSIGN aux_habrat   = 'N'.
       ASSIGN aux_dispensa = 'N'.
       IF AVAIL crapprm THEN DO:
         ASSIGN aux_habrat = crapprm.dsvlrprm.
       END.

       /* Habilita novo rating */
       IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:

           IF (craplcr.flgdisap        and  /* Dispensa aprovacao             */
              crawepr.cdfinemp <> 68 )  or  /* finalidade 68 - PRE-APROVADO   */ 
              craplcr.cdlcremp = 6901 THEN  /* Cessao de Cartao               */
           DO: 

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            /* Efetuar a chamada a rotina Oracle, para Rating calculado como
               feito na contingencia, buscando da Central de Risco do dia anterior
              P450 Rating */
                RUN STORED-PROCEDURE pc_busca_rat_contigencia
                   aux_handproc = PROC-HANDLE NO-ERROR (
                            INPUT par_cdcooper
                                                         ,INPUT Crapass.nrcpfcnpj_base
                                                         ,OUTPUT 0     /* pr_innivris */
                                                         ,OUTPUT 0     /* pr_cdcritic */
                                                         ,OUTPUT "").  /* pr_dscritic */  

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_busca_rat_contigencia
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic          = 0
                       aux_dscritic          = ""
                       aux_nivrisco_ope      = 0
                       aux_cdcritic = pc_busca_rat_contigencia.pr_cdcritic
                                         WHEN pc_busca_rat_contigencia.pr_cdcritic <> ?
                       aux_dscritic = pc_busca_rat_contigencia.pr_dscritic
                                         WHEN pc_busca_rat_contigencia.pr_dscritic <> ?
                       aux_nivrisco_ope = pc_busca_rat_contigencia.pr_innivris
                                         WHEN pc_busca_rat_contigencia.pr_innivris <> ?. 
                IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:

                    ASSIGN aux_flgtrans = FALSE.
                    UNDO EFETIVACAO, LEAVE EFETIVACAO.

                END.

                ASSIGN aux_dispensa = 'S'.
                ASSIGN vr_strating  = 3   /* 3 -- Expirado */
                       vr_orrating  = 4.  /* 4 --contingencia */
                
           END.  /* Fim da condicao Dispensa */ 
           ELSE IF crawepr.cdfinemp = 68 THEN DO: /* finalidade 68 - PRE-APROVADO   */ 

             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

             RUN STORED-PROCEDURE pc_busca_risco_rat_preapr
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                      ,INPUT par_nrdconta
                                                      ,OUTPUT 0     /* pr_inrisco_rating */
                                                      ,OUTPUT 0     /* pr_cdcritic */
                                                      ,OUTPUT "").  /* pr_dscritic */  

             /* Fechar o procedimento para buscarmos o resultado */ 
             CLOSE STORED-PROC pc_busca_risco_rat_preapr
                     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

             ASSIGN aux_cdcritic     = 0
                    aux_dscritic     = ""
                    aux_nivrisco_ope = 0                   
                    aux_cdcritic = pc_busca_risco_rat_preapr.pr_cdcritic
                                      WHEN pc_busca_risco_rat_preapr.pr_cdcritic <> ?
                    aux_dscritic = pc_busca_risco_rat_preapr.pr_dscritic
                                      WHEN pc_busca_risco_rat_preapr.pr_dscritic <> ?
                    aux_nivrisco_ope = pc_busca_risco_rat_preapr.pr_inrisco_rating                                  
                                      WHEN pc_busca_risco_rat_preapr.pr_inrisco_rating <> ?. 
             IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
               DO:
                 ASSIGN aux_flgtrans = FALSE.
                 UNDO EFETIVACAO, LEAVE EFETIVACAO.
               END.          

             IF  aux_nivrisco_ope = 0 THEN DO:

               ASSIGN aux_flgtrans = FALSE. 
               ASSIGN aux_dscritic = "Proposta nao pode ser efetivada," +
                                   " pois nao ha risco rating pre-aprovado!".
               UNDO EFETIVACAO, LEAVE EFETIVACAO.
             END. 

             ASSIGN vr_strating = 2   /* 2 -- proposto */
                    vr_orrating = 5.  /* 5 -- herdado do limite */
           
           END.  /* fim pre-aprovado   */

           IF craplcr.flgdisap        or   /* Dispensa aprovacao             */
              crawepr.cdfinemp = 68   or   /* finalidade 68 - PRE-APROVADO   */ 
              craplcr.cdlcremp = 6901 THEN /* Cessao de Cartao               */
           DO: 
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              RUN STORED-PROCEDURE pc_grava_rating_operacao
                   aux_handproc = PROC-HANDLE NO-ERROR 
                            (INPUT par_cdcooper
                            ,INPUT par_nrdconta
                            ,INPUT 90            /* Tipo Contrato */
                            ,INPUT par_nrctremp
                            ,INPUT ?   /* pr_ntrating */ 
                            ,INPUT aux_nivrisco_ope  /*pr_ntrataut */
                            ,INPUT ?  /* pr_dtrating */
                            ,INPUT vr_strating  
                            ,INPUT vr_orrating  
                            ,INPUT par_cdoperad
                            ,INPUT par_dtmvtolt  /* pr_dtrataut */
                            ,INPUT ?             /* null pr_innivel_rating */
                            ,INPUT Crapass.nrcpfcnpj_base
                            ,INPUT ?             /* pr_inpontos_rating     */
                            ,INPUT ?             /* pr_insegmento_rating   */
                            ,INPUT ?             /* pr_inrisco_rat_inc     */
                            ,INPUT ?             /* pr_innivel_rat_inc     */
                            ,INPUT ?             /* pr_inpontos_rat_inc    */
                            ,INPUT ?             /* pr_insegmento_rat_inc  */
                            ,INPUT ?             /* pr_efetivacao_rating   */
                            ,INPUT "1" /* pr_cdoperad*/
                            ,INPUT par_dtmvtolt
                            ,INPUT crawepr.vlpreemp
                            ,INPUT ? /*sugerido*/
                            ,INPUT "" /*Justif*/
                            ,INPUT ?
                            ,OUTPUT 0            /* pr_cdcritic */
                            ,OUTPUT "").         /* pr_dscritic */  

              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_grava_rating_operacao
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

              ASSIGN aux_cdcritic  = 0
                     aux_dscritic  = ""
                     aux_cdcritic = pc_grava_rating_operacao.pr_cdcritic
                                       WHEN pc_grava_rating_operacao.pr_cdcritic <> ?
                     aux_dscritic = pc_grava_rating_operacao.pr_dscritic
                                       WHEN pc_grava_rating_operacao.pr_dscritic <> ?.
              IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
                          
                ASSIGN aux_flgtrans = FALSE.
                UNDO EFETIVACAO, LEAVE EFETIVACAO.
              
              END.  

           END. /* fim da pc_grava_rating_operacao  */

       END. /* Habilita novo rating */ 

       RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

       RUN obtem_emprestimo_risco IN h-b1wgen0043
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_idorigem,
                                   INPUT par_nmdatela,
                                   INPUT FALSE,
                                   INPUT crawepr.cdfinemp,
                                   INPUT crawepr.cdlcremp,
                                   INPUT crawepr.nrctrliq,
                                   INPUT aux_dsctrliq, /* par_dsctrliq */
                                   INPUT crawepr.nrctremp,  /* P450 */
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT aux_dsnivris).
       /* aux_dsnivris retornado é o pior risco */

       DELETE PROCEDURE h-b1wgen0043.

       /* converte para numérico */
       CASE aux_dsnivris:
             WHEN "AA" THEN ASSIGN aux_nivrisco_num = 1.
             WHEN "A"  THEN ASSIGN aux_nivrisco_num = 2.
             WHEN "B"  THEN ASSIGN aux_nivrisco_num = 3.
             WHEN "C"  THEN ASSIGN aux_nivrisco_num = 4.
             WHEN "D"  THEN ASSIGN aux_nivrisco_num = 5.
             WHEN "E"  THEN ASSIGN aux_nivrisco_num = 6.
             WHEN "F"  THEN ASSIGN aux_nivrisco_num = 7.
             WHEN "G"  THEN ASSIGN aux_nivrisco_num = 8.
             WHEN "H"  THEN ASSIGN aux_nivrisco_num = 9.
             WHEN "HH" THEN ASSIGN aux_nivrisco_num = 10.

             OTHERWISE aux_nivrisco_num = 2.
       END CASE.

       /* VALIDA RATING - INICIO - P450 ********************************/
       /* Habilita novo rating */
       IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:

         { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

         RUN STORED-PROCEDURE pc_busca_status_rating aux_handproc = PROC-HANDLE
            (INPUT  par_cdcooper
            ,INPUT  par_nrdconta
            ,INPUT  90           /* Tipo do contrato */
            ,INPUT  par_nrctremp /* Numero do contrato  */
            ,OUTPUT 0            /* Status do Rating */
            ,OUTPUT 0            /* Flag do Rating */
            ,OUTPUT 0
            ,OUTPUT "").

         CLOSE STORED-PROCEDURE pc_busca_status_rating
               WHERE PROC-HANDLE = aux_handproc.

         { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

         ASSIGN aux_dscritic = ""
                aux_cdcritic = 0
                aux_flrating = 0
                aux_dscritic = pc_busca_status_rating.pr_dscritic
                                 WHEN pc_busca_status_rating.pr_dscritic <> ?
                aux_cdcritic = pc_busca_status_rating.pr_cdcritic
                                 WHEN pc_busca_status_rating.pr_cdcritic <> ?
                aux_flrating = pc_busca_status_rating.pr_flgrating
                                 WHEN pc_busca_status_rating.pr_flgrating <> ?
                .

         IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:

             ASSIGN aux_flgtrans = FALSE.
                     UNDO EFETIVACAO, LEAVE EFETIVACAO.

          END.

         /* RATING - Se nao tem rating valido */
         IF  aux_flrating = 0 THEN DO:

             ASSIGN aux_flgtrans = FALSE.
             ASSIGN aux_dscritic = "Contrato nao pode ser efetivado," +
                                   " pois nao ha Rating valido".
             UNDO EFETIVACAO, LEAVE EFETIVACAO.

         END.

         { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

         RUN STORED-PROCEDURE pc_busca_endivid_param aux_handproc = PROC-HANDLE
             (INPUT  par_cdcooper
             ,INPUT par_nrdconta
             ,OUTPUT 0  /*pr_vlendivi */
             ,OUTPUT 0  /*pr_vlrating */
             ,OUTPUT "").

         CLOSE STORED-PROCEDURE pc_busca_endivid_param WHERE PROC-HANDLE = aux_handproc.

         { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

         ASSIGN aux_dscritic = ""
              aux_vlendivi = 0
              aux_vlrating = 0
              aux_dscritic = pc_busca_endivid_param.pr_dscritic
                               WHEN pc_busca_endivid_param.pr_dscritic <> ?
              aux_vlrating = pc_busca_endivid_param.pr_vlrating
                               WHEN pc_busca_endivid_param.pr_vlrating <> ?
              aux_vlendivi = pc_busca_endivid_param.pr_vlendivi
                               WHEN pc_busca_endivid_param.pr_vlendivi <> ?
              .

         IF  aux_dscritic <> "" THEN DO:

           ASSIGN aux_flgtrans = FALSE.
           UNDO EFETIVACAO, LEAVE EFETIVACAO.

         END.
          
         /* RATING - Se tem rating valido */
         /* Se Endividamento + Contrato atual > Parametro Rating (TAB056) */
         IF ((aux_vlendivi + crawepr.vlemprst) > aux_vlrating)  THEN DO:
           /* Gravar o Rating da operaçao, efetivando-o */
           { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

           RUN STORED-PROCEDURE pc_grava_rating_operacao aux_handproc = PROC-HANDLE
                (INPUT par_cdcooper
                ,INPUT par_nrdconta
                ,INPUT 90            /* Tipo Contrato */
                ,INPUT par_nrctremp
                ,?                    /* pr_ntrating P450 2019-08-28 */
                ,?                    /* pr_ntrataut P450 2019-08-28 */
                ,INPUT par_dtmvtolt   /* pr_dtrating */
                ,INPUT IF aux_dispensa = "S" THEN 5 
                          ELSE 4      /* pr_strating => 4-efetivado 5-efetivado Vencido*/
                ,INPUT ?              /* pr_orrating */
                ,INPUT par_cdoperad
                ,INPUT par_dtmvtolt  /* para pr_dtrataut */
                ,INPUT ?             /* null pr_innivel_rating */
                ,INPUT Crapass.nrcpfcnpj_base
                ,INPUT ?             /* pr_inpontos_rating     */
                ,INPUT ?             /* pr_insegmento_rating   */
                ,INPUT ?             /* pr_inrisco_rat_inc     */
                ,INPUT ?             /* pr_innivel_rat_inc     */
                ,INPUT ?             /* pr_inpontos_rat_inc    */
                ,INPUT ?             /* pr_insegmento_rat_inc  */
                ,INPUT ?             /* pr_efetivacao_rating   */
                ,INPUT "1" /* pr_cdoperad*/
                ,INPUT par_dtmvtolt
                ,INPUT crawepr.vlpreemp
                ,INPUT ? /*sugerido*/
                ,INPUT "" /*Justif*/
                ,INPUT ?
                ,OUTPUT 0            /* pr_cdcritic */
                ,OUTPUT "").         /* pr_dscritic */

           CLOSE STORED-PROCEDURE pc_grava_rating_operacao WHERE PROC-HANDLE = aux_handproc.

           { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

           ASSIGN aux_dscritic = pc_grava_rating_operacao.pr_dscritic
                              WHEN pc_grava_rating_operacao.pr_dscritic <> ?.

           IF aux_dscritic <> "" THEN DO:

             ASSIGN aux_flgtrans = FALSE.
             UNDO EFETIVACAO, LEAVE EFETIVACAO.

           END.
         END.
       
       END. /* Habilita novo rating */
       /*--------  fim - P450 Rating ------------------   */

/************* fim teste posição chamada   */

       ASSIGN par_mensagem = ''.

       IF crawepr.dsnivris <> aux_dsnivris AND           
          /* nao atualizar o risco no caso de cessao */
          aux_flcescrd = FALSE THEN 
          DO:
               FIND CURRENT crawepr EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               IF AVAIL crawepr THEN DO:
                  ASSIGN par_mensagem = 'O risco da proposta foi de "' +
                                        crawepr.dsnivris +
                                        '" e o do contrato sera de "' +
                                        aux_dsnivris + '".'
                         crawepr.dsnivris = aux_dsnivris
                         crawepr.dsnivori = aux_dsnivris.

                         RUN proc_gerar_log (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT "",
                           INPUT aux_dsorigem,
                           INPUT par_mensagem,
                           INPUT TRUE,
                           INPUT par_idseqttl,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                          OUTPUT aux_nrdrowid).

                  IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                  
                    /* Efetuar a chamada a rotina Oracle para gravar o risco inclusão -P450 Rating */
                    RUN STORED-PROCEDURE pc_grava_risco_inclusao
                       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                           ,INPUT par_nrdconta
                                                           ,INPUT crawepr.nrctremp
                                                           ,INPUT 90  /* Tipo Contrato */
                                                           ,INPUT Crapass.nrcpfcnpj_base
                                                           ,INPUT aux_nivrisco_num
                                                           ,OUTPUT "").  /* pr_dscritic */  
         
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_grava_risco_inclusao
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
                     ASSIGN aux_dscritic = ""
                            aux_dscritic = pc_grava_risco_inclusao.pr_dscritic
                                           WHEN pc_grava_risco_inclusao.pr_dscritic <> ?.
                    IF aux_dscritic <> "" THEN
                      DO:
                        ASSIGN aux_flgtrans = FALSE.
                        UNDO EFETIVACAO, LEAVE EFETIVACAO.                      
                      END.  
                  END. /* aux_habrat = 'S' */
               END.

          END.
       ELSE IF par_nmdatela = "CMAPRV" AND (par_idorigem = 7  OR   /* 7-PROCESSO       -cessão Cartão */ 
                                            par_idorigem = 3  OR   /* 3-INTERNET 4-TAA -Pré-aprovado  */
                                            par_idorigem = 4) THEN    
          DO:
           /* Por motivo de evitar deadlock na tabela tbrisco_operacoes, esta rotina será chamada nestes casos acima
             neste ponto e não na b1wgen0002.grava-proposta-completa*/

            IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
              /* Efetuar a chamada a rotina Oracle para gravar o risco inclusão -P450 Rating */
              RUN STORED-PROCEDURE pc_grava_risco_inclusao
                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                     ,INPUT par_nrdconta
                                                     ,INPUT crawepr.nrctremp
                                                     ,INPUT 90  /* Tipo Contrato */
                                                     ,INPUT Crapass.nrcpfcnpj_base
                                                     ,INPUT aux_nivrisco_num
                                                     ,OUTPUT "").  /* pr_dscritic */  
         
              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_grava_risco_inclusao
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
               ASSIGN aux_dscritic = ""
                      aux_dscritic = pc_grava_risco_inclusao.pr_dscritic
                                     WHEN pc_grava_risco_inclusao.pr_dscritic <> ?.
              IF aux_dscritic <> "" THEN
                DO:
                  ASSIGN aux_flgtrans = FALSE.
                  UNDO EFETIVACAO, LEAVE EFETIVACAO.                      
                END.  
            END. /* aux_habrat = 'S' */          
       
          END.  /* par_nmdatela  */

       IF crawepr.nrctaav1 > 0   THEN
          DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                crapass.nrdconta = crawepr.nrctaav1
                                NO-LOCK NO-ERROR.

             IF NOT AVAIL crapass THEN
                DO:
                   ASSIGN aux_cdcritic = 9.
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

                END.

             /*Monta a mensagem da operacao para envio no e-mail*/
             ASSIGN aux_dsoperac = "Inclusao/alteracao "                      +
                                   "do Avalista conta "                       +
                                   STRING(crapass.nrdconta,"zzzz,zzz,9")      +
                                   " - CPF/CNPJ "                             +
                                  (IF crapass.inpessoa = 1 THEN
                                      STRING((STRING(crapass.nrcpfcgc,
                                            "99999999999")),"xxx.xxx.xxx-xx")
                                    ELSE
                                       STRING((STRING(crapass.nrcpfcgc,
                                             "99999999999999")),
                                             "xx.xxx.xxx/xxxx-xx" ))          +
                                   " na conta "                               +
                                   STRING(crawepr.nrdconta,"zzzz,zzz,9").

             IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                RUN sistema/generico/procedures/b1wgen0110.p
                    PERSISTENT SET h-b1wgen0110.

             /*Verifica se o primeiro avalista esta no cadastro restritivo. Se
               estiver, sera enviado um e-mail informando a situacao*/
             RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_dtmvtolt,
                                               INPUT par_idorigem,
                                               INPUT crapass.nrcpfcgc,
                                               INPUT crapass.nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT FALSE, /*nao bloq. operacao*/
                                               INPUT 33, /*cdoperac*/
                                               INPUT aux_dsoperac,
                                               OUTPUT TABLE tt-erro).

             IF VALID-HANDLE(h-b1wgen0110) THEN
                DELETE PROCEDURE(h-b1wgen0110).

             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      ASSIGN aux_dscritic = "Nao foi possivel verificar " +
                                            "o cadastro restritivo.".

                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

                END.

          END.

       IF crawepr.nrctaav2 > 0   THEN
          DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                crapass.nrdconta = crawepr.nrctaav2
                                NO-LOCK NO-ERROR.

             IF NOT AVAIL crapass THEN
                DO:
                   ASSIGN aux_cdcritic = 9.
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

                END.

             /*Monta a mensagem da operacao para envio no e-mail*/
             ASSIGN aux_dsoperac = "Inclusao/alteracao "                      +
                                   "do Avalista conta "                       +
                                   STRING(crapass.nrdconta,"zzzz,zzz,9")      +
                                   " - CPF/CNPJ "                             +
                                  (IF crapass.inpessoa = 1 THEN
                                      STRING((STRING(crapass.nrcpfcgc,
                                            "99999999999")),"xxx.xxx.xxx-xx")
                                    ELSE
                                       STRING((STRING(crapass.nrcpfcgc,
                                             "99999999999999")),
                                             "xx.xxx.xxx/xxxx-xx" ))          +
                                   " na conta "                               +
                                   STRING(crawepr.nrdconta,"zzzz,zzz,9").

             IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                RUN sistema/generico/procedures/b1wgen0110.p
                    PERSISTENT SET h-b1wgen0110.

             /*Verifica se o primeiro avalista esta no cadastro restritivo. Se
               estiver, sera enviado um e-mail informando a situacao*/
             RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_dtmvtolt,
                                               INPUT par_idorigem,
                                               INPUT crapass.nrcpfcgc,
                                               INPUT crapass.nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT FALSE, /*nao bloq. operacao*/
                                               INPUT 33, /*cdoperac*/
                                               INPUT aux_dsoperac,
                                               OUTPUT TABLE tt-erro).

             IF VALID-HANDLE(h-b1wgen0110) THEN
                DELETE PROCEDURE(h-b1wgen0110).

             IF RETURN-VALUE <> "OK" THEN
                DO:
                   IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      ASSIGN aux_dscritic = "Nao foi possivel verificar " +
                                            "o cadastro restritivo.".
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.

                 END.

       END.

       IF aux_cdcritic <> 0   THEN
          UNDO EFETIVACAO , LEAVE EFETIVACAO.

       ASSIGN craplcr.flgsaldo = TRUE.

       RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

       IF NOT VALID-HANDLE(h-b1wgen0043)  THEN
          DO:
              ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0043.".

              UNDO EFETIVACAO, LEAVE EFETIVACAO.
          END.

       RUN gera_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                         INPUT 0,   /** Pac   **/
                                         INPUT 0,   /** Caixa **/
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT 1,   /** Titular **/
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtopr,
                                         INPUT par_inproces,
                                         INPUT 90, /*Emprestimo/Financiamento*/
                                         INPUT par_nrctremp,
                                         INPUT TRUE, /*Gravar Rating*/
                                         INPUT TRUE, /** Log **/
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabrel,
                                        OUTPUT TABLE tt-impressao-coop,
                                        OUTPUT TABLE tt-impressao-rating,
                                        OUTPUT TABLE tt-impressao-risco,
                                        OUTPUT TABLE tt-impressao-risco-tl,
                                        OUTPUT TABLE tt-impressao-assina,
                                        OUTPUT TABLE tt-efetivacao,
                                        OUTPUT TABLE tt-ratings).

       DELETE PROCEDURE h-b1wgen0043.

       IF RETURN-VALUE <> "OK"   THEN
          UNDO EFETIVACAO , LEAVE EFETIVACAO.

       /* Para proposta PreAprovado */
       IF AVAIL crappre AND AVAIL crapcpa THEN
          DO:
             /* Chamaremos a rotina que ira verificar se eh necessario atualizar  */
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

             RUN STORED-PROCEDURE pc_verifica_rating_sas
                 aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper, /* Cooperativa */
                                   INPUT par_dtmvtolt, /* Data Movimento */
                                   INPUT crapass.inpessoa, /* Indicativo de pessoa */
                                   INPUT crapass.nrcpfcnpj_base, /* CPF/CNPJ raiz de pessoa */
                                   INPUT crapepr.nrctremp, /* Contrato */
                                   INPUT crapcpa.iddcarga, /* ID Carga CPA */
                                  OUTPUT "").

             CLOSE STORED-PROC pc_verifica_rating_sas 
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

             ASSIGN aux_dscritic = ""
                    aux_dscritic = pc_verifica_rating_sas.pr_dscritic 
                                   WHEN pc_verifica_rating_sas.pr_dscritic <> ?.
                 
             IF  aux_dscritic <> ""  THEN
                 DO:                                    
                     CREATE tt-erro.
                     ASSIGN tt-erro.cdcritic = aux_cdcritic
                            tt-erro.dscritic = aux_dscritic.

                     UNDO EFETIVACAO, LEAVE EFETIVACAO.
                 END.
          END.

       /* Acionar rotina de Gravacao do Calculo CET gerado */
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

       RUN STORED-PROCEDURE pc_calculo_cet_emprestimos
           aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper, /* Cooperativa */
                             INPUT par_dtmvtolt, /* Data Movimento */
                             INPUT par_nrdconta, /* Conta */
                             INPUT par_nmdatela, /* Programa chamador */
                             INPUT crapass.inpessoa, /* Indicativo de pessoa */
                             INPUT craplcr.cdusolcr, /* Codigo de uso da linha de credito */
                             INPUT crawepr.cdlcremp, /* Linha de credio  */
                             INPUT crawepr.tpemprst, /* Tipo da operacao */
                             INPUT crawepr.nrctremp, /* Contrato         */
                             INPUT crawepr.dtlibera, /* Data liberacao   */
                             INPUT crawepr.vlemprst, /* Valor emprestado */
                             INPUT crawepr.txmensal, /* Taxa mensal */
                             INPUT crawepr.vlpreemp, /* valor parcela    */  
                             INPUT crawepr.qtpreemp, /* prestacoes       */
                             INPUT crawepr.dtdpagto, /* data pagamento   */
                             INPUT crawepr.cdfinemp, /* finalidade */
                             INPUT aux_dscatbem, /* Categoria Bem */
                             INPUT crawepr.idfiniof, /* */
                             INPUT aux_dsctrliq, /* Contratos Liquidados */
                             INPUT "S", /* Gravar */
                             INPUT crawepr.dtcarenc, /* Data de carencia*/
                            OUTPUT 0,
                            OUTPUT 0,
                            OUTPUT 0,
                            OUTPUT "").

       CLOSE STORED-PROC pc_calculo_cet_emprestimos 
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_cdcritic = 0
              aux_dscritic = ""
              aux_cdcritic = pc_calculo_cet_emprestimos.pr_cdcritic 
                             WHEN pc_calculo_cet_emprestimos.pr_cdcritic <> ?
              aux_dscritic = pc_calculo_cet_emprestimos.pr_dscritic 
                             WHEN pc_calculo_cet_emprestimos.pr_dscritic <> ?.
           
       IF  aux_cdcritic <> 0   OR
           aux_dscritic <> ""  THEN
           DO:                                    
               CREATE tt-erro.
               ASSIGN tt-erro.cdcritic = aux_cdcritic
                      tt-erro.dscritic = aux_dscritic.

               UNDO EFETIVACAO, LEAVE EFETIVACAO.
           END.
        
        /* P442 - Validar valores de pre-aprovado no momento da liberacao do contrato
           incluido aqui para reduzir problemas de contratacao simultanea entre canais*/
        /*IF crawepr.cdfinemp = 68 THEN
          DO:
            /* Buscar valores atualizados no momento da confirmacao */
            IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                  RUN sistema/generico/procedures/b1wgen0188.p 
                      PERSISTENT SET h-b1wgen0188.

               /* Verifica se existe limite disponível */
               RUN busca_dados IN h-b1wgen0188
                               (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT 0,
                                OUTPUT TABLE tt-dados-cpa,
                                OUTPUT TABLE tt-erro).
               
               FIND tt-dados-cpa NO-LOCK NO-ERROR.
               IF  AVAIL tt-dados-cpa THEN
                 DO:
                 
                   aux_vlemprstcalc = tt-dados-cpa.vldiscrd + crawepr.vlemprst.
                   aux_vlpreempcalc = tt-dados-cpa.vlcalpar + crawepr.vlpreemp.
                 
                    /* Verifica se retornou ID de carga */
                    IF tt-dados-cpa.idcarga = 0 THEN
                      DO:
                        aux_dscritic = "Nao foi localizado pre-aprovado para o associado".
                        UNDO EFETIVACAO , LEAVE EFETIVACAO.
                      END.
                      
                    /* Verifica se o valor limite permite a liberacao*/
                    IF crawepr.vlemprst > aux_vlemprstcalc THEN
                      DO:
                        aux_dscritic = "Valor total nao permitido para pre-aprovado".
                        UNDO EFETIVACAO , LEAVE EFETIVACAO.
                      END.
                      
                    /* Verifica se o valor da parcela permite a liberacao*/
                    IF crawepr.vlpreemp > aux_vlpreempcalc THEN
                      DO:
                        aux_dscritic = "Valor da parcela nao permitido para pre-aprovado".
                        UNDO EFETIVACAO , LEAVE EFETIVACAO.
                      END.
                 END.
               ELSE
                 DO:
                   aux_dscritic = "Pre-aprovado nao disponivel para usuario".
                   UNDO EFETIVACAO , LEAVE EFETIVACAO.
                 END.
          END.*/
        /**/

        /*Validaçao e efetivaçao do seguro prestamista -- PRJ438 - Paulo Martins (Mouts)*/     
        IF crapass.inpessoa = 1 THEN
        DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          RUN STORED-PROCEDURE pc_efetiva_proposta_sp
                               aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT par_cdcooper,      /* Cooperativa */
                         INPUT par_nrdconta,      /* Número da conta */
                         INPUT par_nrctremp,      /* Número emrepstimo */
                         INPUT par_cdagenci,      /* Agencia */
                         INPUT par_nrdcaixa,      /* Caixa */
                         INPUT par_cdoperad,      /* Operador   */
                         INPUT par_nmdatela,      /* Tabela   */
                         INPUT par_idorigem,      /* Origem  */
                        OUTPUT 0,
                        OUTPUT "").

          CLOSE STORED-PROC pc_efetiva_proposta_sp 
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
          ASSIGN aux_cdcritic = pc_efetiva_proposta_sp.pr_cdcritic
                                   WHEN pc_efetiva_proposta_sp.pr_cdcritic <> ?
                 aux_dscritic = pc_efetiva_proposta_sp.pr_dscritic
                                   WHEN pc_efetiva_proposta_sp.pr_dscritic <> ?.
          IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
            DO:
              CREATE tt-erro.
              ASSIGN tt-erro.cdcritic = aux_cdcritic
                     tt-erro.dscritic = aux_dscritic.
               UNDO EFETIVACAO, LEAVE EFETIVACAO.
           END.
        END.
        
        
        IF crawepr.cdorigem = 3 OR crawepr.cdorigem = 4 THEN
          DO:
            /* P442 - Criar assinaturas para o contrato recem criado (aprovado) */
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            /* Criar registros na tabela de assinaturas */
            /* Efetuar a chamada a rotina Oracle */ 
            RUN STORED-PROCEDURE pc_assinatura_contrato_pre
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.cdcooper
                                                      ,INPUT crawepr.cdagenci
                                                      ,INPUT crawepr.nrdconta
                                                      ,INPUT 1
                                                      ,INPUT par_dtmvtolt
                                                      ,INPUT crawepr.cdorigem
                                                      ,INPUT crawepr.nrctremp
                                                      ,INPUT 1
                                                      ,OUTPUT ""
                                                      ,OUTPUT ""
                                                      ,OUTPUT 0
                                                      ,OUTPUT "").
            
            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_assinatura_contrato_pre
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
            
            ASSIGN aux_dsassdig = pc_assinatura_contrato_pre.pr_assinatu
                   aux_des_reto = pc_assinatura_contrato_pre.pr_des_reto
                   aux_cdcritic = pc_assinatura_contrato_pre.pr_cdcritic WHEN pc_assinatura_contrato_pre.pr_cdcritic <> ?
                   aux_dscritic = pc_assinatura_contrato_pre.pr_dscritic WHEN pc_assinatura_contrato_pre.pr_dscritic <> ?.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
                DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.cdcritic = aux_cdcritic
                         tt-erro.dscritic = aux_dscritic.
                   UNDO EFETIVACAO, LEAVE EFETIVACAO.
               END.
          
          END. /**END crawepr.cdorigem = 3 OR crawepr.cdorigem = 4 THEN*/
        
       
       ASSIGN aux_flgtrans = TRUE.

    END.  /*  DO TRANSACTION  */

    IF NOT aux_flgtrans   THEN
       DO:
           IF CAN-FIND(FIRST tt-erro)   THEN
            DO:
            
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
              RETURN "NOK".
            END.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.

    IF  par_flgerlog   THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).
        END.
    RETURN "OK".

END PROCEDURE. /*   grava efetivacao proposta */


PROCEDURE busca_desfazer_efetivacao_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Busca desfazer efetivacao emprestimo.".

    RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-b1wgen9999.

    RUN dig_fun IN h-b1wgen9999
        ( INPUT par_cdcooper,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT-OUTPUT par_nrdconta,
         OUTPUT TABLE tt-erro ).

    DELETE PROCEDURE h-b1wgen9999.

    /* Se a proposta de emprestimo for TR, exibe critica */
    IF  CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                           AND crawepr.nrdconta = par_nrdconta
                           AND crawepr.nrctremp = par_nrctremp
                           AND crawepr.tpemprst = 0) THEN
        DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Opcao invalida para esse tipo de contrato.".

             RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
        END.

    FIND   crapass WHERE crapass.nrdconta = par_nrdconta   AND
                         crapass.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapass   THEN
         DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
         END.

    /*  Verifica codigo de situacao do titular  */
    CASE   crapass.cdsitdtl:
           /* 5 (NORMAL C/PREJ.), 6 (NORMAL BLQ.PREJ),
              7 (DEMITIDO C/PREJ) ou 8 (DEM. BLOQ.PREJ.)*/
           WHEN   5 OR    WHEN 6 OR    WHEN 7 OR    WHEN 8 THEN
                  DO:
                      ASSIGN aux_cdcritic = 695
                             aux_dscritic = "".

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                      RETURN "NOK".

                  END.
           /* 2 (NORMAL C/BLOQ.), 4 (DEMITIDO C/BLOQ),
              6 (NORMAL BLQ.PREJ) ou 8 (DEM. BLOQ.PREJ.)*/
           WHEN   2 OR    WHEN 4 OR    WHEN 8 THEN
                  DO:
                      ASSIGN aux_cdcritic = 95
                             aux_dscritic = "".

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                      RETURN "NOK".
                  END.
    END CASE. /* CASE   crapass.cdsitdtl */


    IF   par_nrctremp < 0 THEN
         DO:
             ASSIGN aux_cdcritic = 361
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.


    FIND   crapepr  NO-LOCK WHERE
           crapepr.cdcooper = par_cdcooper AND
           crapepr.nrdconta = par_nrdconta AND
           crapepr.nrctremp = par_nrctremp NO-ERROR.

    IF   NOT AVAIL crapepr THEN
         DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Emprestimo nao cadastrado".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    /* Se for Pos-Fixado */
    /*INICIO P438*/
    IF CAN-DO("1,2", STRING(crapepr.tpemprst)) THEN
        DO:
           /* Caso NAO seja Refinanciamento, exibe critica  */
           IF  NOT CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                                      AND crawepr.nrdconta = par_nrdconta
                                      AND crawepr.nrctremp = par_nrctremp
                                      AND (crawepr.nrctrliq[1]  > 0   OR
                                           crawepr.nrctrliq[2]  > 0   OR
                                           crawepr.nrctrliq[3]  > 0   OR
                                           crawepr.nrctrliq[4]  > 0   OR
                                           crawepr.nrctrliq[5]  > 0   OR
                                           crawepr.nrctrliq[6]  > 0   OR
                                           crawepr.nrctrliq[7]  > 0   OR
                                           crawepr.nrctrliq[8]  > 0   OR
                                           crawepr.nrctrliq[9]  > 0   OR
                                           crawepr.nrctrliq[10] > 0)) THEN
               DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Nao e possivel desfazer a efetivacao. Efetue a liquidacao do contrato.".

                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 1,
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).

                   RETURN "NOK".

               END. /* NOT CAN-FIND */

        END. /* crapepr.tpemprst = 2 */
        /*FIM P438*/
    FIND   FIRST craplem NO-LOCK WHERE
                 craplem.cdcooper = crapepr.cdcooper AND
                 craplem.dtmvtolt = crapepr.dtmvtolt AND
                 craplem.cdagenci = crapepr.cdagenci AND
                 craplem.cdbccxlt = crapepr.cdbccxlt AND
                 craplem.nrdolote = crapepr.nrdolote AND
                 craplem.nrdconta = crapepr.nrdconta AND
                 craplem.nrctremp = crapepr.nrctremp NO-ERROR.

    IF   NOT AVAIL craplem THEN
         DO:

             ASSIGN aux_cdcritic = 90
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    IF   crapepr.dtmvtolt <> par_dtmvtolt THEN
         DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Emprestimo nao foi efetivado na data atual"
                                 + " de movimento".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.


    IF   par_flgerlog THEN
         DO:

             RUN proc_gerar_log (INPUT  par_cdcooper,
                                 INPUT  par_cdoperad,
                                 INPUT  aux_dscritic,
                                 INPUT  aux_dsorigem,
                                 INPUT  aux_dstransa,
                                 INPUT  FALSE,
                                 INPUT  par_idseqttl,
                                 INPUT  par_nmdatela,
                                 INPUT  par_nrdconta,
                                 OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).

         END.

    RETURN "OK".

END PROCEDURE.  /* busca desfazer efetivacao emprestimo */


PROCEDURE desfaz_efetivacao_emprestimo.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador          AS INTE                           NO-UNDO.
    DEF VAR aux_floperac          AS LOGI                           NO-UNDO.
    DEF VAR aux_cdhistor          AS INTE                           NO-UNDO.
    DEF VAR aux_nrdolote          AS INTE                           NO-UNDO.
    DEF VAR aux_vltotemp          AS DECI                           NO-UNDO.
    DEF VAR aux_vltotctr          AS DECI                           NO-UNDO.
    DEF VAR aux_vltotjur          AS DECI                           NO-UNDO.
    DEF VAR aux_nrseqdig          AS INTE                           NO-UNDO.
    DEF VAR i                     AS INTE                           NO-UNDO.

    DEF VAR aux_flgtrans          AS LOGI                           NO-UNDO.
    DEF VAR aux_idcarga           AS INTE                           NO-UNDO.
    DEF VAR aux_tpfinali          AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen0134          AS HANDLE                         NO-UNDO.
    DEF VAR h-b1craplot           AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0188          AS HANDLE                         NO-UNDO.

    DEF BUFFER b-crawepr FOR crawepr.

    IF   par_flgerlog THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Desfaz efetivacao empresimo.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Desfaz:
    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":

        DO aux_contador = 1 TO 10:

           FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                              crapepr.nrdconta = par_nrdconta AND
                              crapepr.nrctremp = par_nrctremp
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAIL crapepr   THEN
                IF   LOCKED crapepr   THEN
                     DO:
                         ASSIGN aux_cdcritic = 356.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         ASSIGN aux_cdcritic = 77.
                         LEAVE.
                     END.

           ASSIGN aux_cdcritic = 0.
           LEAVE.

        END.

        IF   aux_cdcritic <> 0   THEN
             UNDO Desfaz , LEAVE Desfaz.

        FIND crapope WHERE crapope.cdcooper = crapepr.cdcooper   AND
                           crapope.cdoperad = par_cdoperad
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapope   THEN
             DO:
                 ASSIGN aux_cdcritic = 67.
                 UNDO Desfaz , LEAVE Desfaz.
             END.

        FIND crapass WHERE crapass.nrdconta = par_nrdconta AND
                           crapass.cdcooper = par_cdcooper
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapass THEN
           DO:
               ASSIGN aux_cdcritic = 9.
               UNDO Desfaz , LEAVE Desfaz.
           END.

        FIND craplcr WHERE craplcr.cdcooper = crapepr.cdcooper   AND
                           craplcr.cdlcremp = crapepr.cdlcremp
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplcr   THEN
             DO:
                 ASSIGN aux_cdcritic = 363.
                 UNDO Desfaz , LEAVE Desfaz.
             END.

        /* Caso jah possuir lancamento na conta nao podemos desefetivar */
        FOR FIRST craplcm FIELDS(cdcooper)
                          WHERE craplcm.cdcooper = crapepr.cdcooper AND
                                craplcm.nrdconta = crapepr.nrdconta AND
                                craplcm.nrdocmto = crapepr.nrctremp AND
                                craplcm.dtmvtolt = crapepr.dtmvtolt AND
                                craplcm.cdhistor = 15
                                NO-LOCK: END.
        IF AVAIL craplcm THEN
           DO:
               ASSIGN aux_dscritic = "Ja possui lancamento em conta".
               UNDO Desfaz , LEAVE Desfaz.
           END.
        /* INICIO P438 - Se for PP */
        IF  crapepr.tpemprst = 1  THEN
            DO:
               /* Caso NAO seja Refinanciamento, exibe critica  */
               IF  NOT CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                                          AND crawepr.nrdconta = par_nrdconta
                                          AND crawepr.nrctremp = par_nrctremp
                                          AND (crawepr.nrctrliq[1]  > 0   OR
                                               crawepr.nrctrliq[2]  > 0   OR
                                               crawepr.nrctrliq[3]  > 0   OR
                                               crawepr.nrctrliq[4]  > 0   OR
                                               crawepr.nrctrliq[5]  > 0   OR
                                               crawepr.nrctrliq[6]  > 0   OR
                                               crawepr.nrctrliq[7]  > 0   OR
                                               crawepr.nrctrliq[8]  > 0   OR
                                               crawepr.nrctrliq[9]  > 0   OR
                                               crawepr.nrctrliq[10] > 0)) THEN
                   DO:
                       ASSIGN aux_dscritic = "Operacao nao permitida para emprestimo do tipo PP.".
                       UNDO Desfaz , LEAVE Desfaz.

                   END. /* NOT CAN-FIND */

            END. /* FIM P438 crapepr.tpemprst = 1 */           

        /* Se for Pos-Fixado */
        IF  crapepr.tpemprst = 2  THEN
            DO:
               /* Caso NAO seja Refinanciamento, exibe critica  */
               IF  NOT CAN-FIND(crawepr WHERE crawepr.cdcooper = par_cdcooper
                                          AND crawepr.nrdconta = par_nrdconta
                                          AND crawepr.nrctremp = par_nrctremp
                                          AND (crawepr.nrctrliq[1]  > 0   OR
                                               crawepr.nrctrliq[2]  > 0   OR
                                               crawepr.nrctrliq[3]  > 0   OR
                                               crawepr.nrctrliq[4]  > 0   OR
                                               crawepr.nrctrliq[5]  > 0   OR
                                               crawepr.nrctrliq[6]  > 0   OR
                                               crawepr.nrctrliq[7]  > 0   OR
                                               crawepr.nrctrliq[8]  > 0   OR
                                               crawepr.nrctrliq[9]  > 0   OR
                                               crawepr.nrctrliq[10] > 0)) THEN
                   DO:
                       ASSIGN aux_dscritic = "Operacao nao permitida para emprestimo do tipo Pos-Fixado.".
                       UNDO Desfaz , LEAVE Desfaz.

                   END. /* NOT CAN-FIND */

            END. /* crapepr.tpemprst = 2 */

        ASSIGN aux_floperac = ( craplcr.dsoperac = "FINANCIAMENTO" )
               aux_vltotemp = crapepr.vlemprst
               aux_vltotctr = crapepr.qtpreemp * crapepr.vlpreemp
               aux_vltotjur = aux_vltotctr - crapepr.vlemprst.

        /* Caso o emprestimo for pre-aprovado, precisamos atualizar saldo disponivel */
        FIND FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper
                             AND crawepr.nrdconta = par_nrdconta
                             AND crawepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAILABLE crawepr THEN
          DO:
            ASSIGN aux_dscritic = "Registro de proposta de emprestimo nao encontrado.".
            UNDO Desfaz , LEAVE Desfaz.
          END.
        
        FOR crappre FIELDS(cdfinemp vlmulpli) WHERE crappre.cdcooper = par_cdcooper
                                                AND crappre.inpessoa = crapass.inpessoa
                                                AND (crappre.cdfinemp = crapepr.cdfinemp 
                                                 OR crawepr.flgpreap = 1) NO-LOCK: END.

        /* Verifica se o emprestimo eh pre-aprovado */
        IF AVAIL crappre THEN
           DO:
           
             FIND crapass WHERE crapass.cdcooper = par_cdcooper
                              AND crapass.nrdconta = par_nrdconta
                              NO-LOCK NO-ERROR.
                              
               IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                  RUN sistema/generico/procedures/b1wgen0188.p 
                      PERSISTENT SET h-b1wgen0188.
                     
               /* Busca a carga ativa */
               RUN busca_carga_ativa IN h-b1wgen0188(INPUT par_cdcooper,
                                                     INPUT par_nrdconta,
                                                     OUTPUT aux_idcarga).
            
               IF VALID-HANDLE(h-b1wgen0188) THEN
                  DELETE PROCEDURE(h-b1wgen0188).

               /* Buscaremos o registro do Cooperado na Carga, para lockar o mesmo */
               Contador: DO aux_contador = 1 TO 10:

                 FIND crapcpa WHERE crapcpa.cdcooper       = par_cdcooper AND
                                    crapcpa.tppessoa       = crapass.inpessoa AND
                                    crapcpa.nrcpfcnpj_base = crapass.nrcpfcnpj_base AND
                                    crapcpa.iddcarga       = aux_idcarga
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF NOT AVAILABLE crapcpa THEN
                    IF LOCKED crapcpa THEN
                       DO:
                        ASSIGN aux_cdcritic = 77.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                       END.
                    ELSE
                       DO:
                           ASSIGN aux_dscritic = "Associado nao cadastrado " +
                                                 "no pre-aprovado".
                           UNDO Desfaz , LEAVE Desfaz.
                       END.

                 ASSIGN aux_cdcritic = 0.
                 LEAVE Contador.

               END. /* END Contador: DO aux_contador = 1 TO 10: */

               /* Atualizar o valor Contratado caso o ID da Carga seja igual a carga corrente */
               /*IF crapcpa.iddcarga = crapepr.idcarga THEN
                  DO:
                      /* Atualiza o valor contratado do credito pre-aprovado */
                      ASSIGN crapcpa.vlctrpre = crapcpa.vlctrpre - crapepr.vlemprst.
                  END.*/

           END. /* END IF AVAIL crappre THEN */

        FIND crapfin WHERE crapfin.cdcooper = crapepr.cdcooper
                       AND crapfin.cdfinemp = crapepr.cdfinemp NO-LOCK NO-ERROR NO-WAIT.
           
        IF AVAILABLE crapfin THEN
          ASSIGN aux_tpfinali = crapfin.tpfinali. 
        
       IF   aux_floperac   THEN             /* Financiamento*/
          DO:
            IF aux_tpfinali = 3 THEN /* CDC */
              ASSIGN aux_cdhistor = 2014.
            ELSE
              ASSIGN aux_cdhistor = 1059.
              
            ASSIGN  aux_nrdolote = 600030.
          END.
       ELSE                                 /* Emprestimo */
         DO:
          IF aux_tpfinali = 3 THEN /* CDC */
            ASSIGN aux_cdhistor = 2013.
          ELSE
            ASSIGN aux_cdhistor = 1036.
          
          ASSIGN aux_nrdolote = 600005.
         END.

        RUN sistema/generico/procedures/b1craplot.p PERSISTENT SET h-b1craplot.

        /* Lancamento de Liberar valor de Emprestimo  */
        RUN inclui-altera-lote IN h-b1craplot
                               (INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT par_cdagenci,
                                INPUT 100,          /* cdbccxlt */
                                INPUT aux_nrdolote,
                                INPUT 4,            /* tplotmov */
                                INPUT par_cdoperad,
                                INPUT aux_cdhistor,
                                INPUT par_dtmvtolt,
                                INPUT aux_vltotemp, /* Valor total emprestado */
                                INPUT FALSE,
                                INPUT TRUE,
                               OUTPUT aux_nrseqdig,
                               OUTPUT aux_cdcritic).

        DELETE PROCEDURE h-b1craplot.

        RUN sistema/generico/procedures/b1wgen0134.p
            PERSISTENT SET h-b1wgen0134.

        RUN desfaz_lancamentos_lem IN h-b1wgen0134
                                        (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_nrctremp,
                                        OUTPUT aux_cdcritic).
        DELETE PROCEDURE h-b1wgen0134.

        IF   RETURN-VALUE <> "OK"   THEN
             UNDO Desfaz , LEAVE Desfaz.

              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
              /* Efetuar a chamada a rotina Oracle */
              RUN STORED-PROCEDURE pc_exclui_iof
              aux_handproc = PROC-HANDLE NO-ERROR 
                          (INPUT par_cdcooper        /* Cooperativa              */ 
                          ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                          ,INPUT par_nrctremp        /* Numero do Bordero        */
                          ,OUTPUT 0                  /* Codigo da Critica */
                          ,OUTPUT "").               /* Descriçao da crítica */

              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_exclui_iof
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
      
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_cdcritic = pc_exclui_iof.pr_cdcritic
                               WHEN pc_exclui_iof.pr_cdcritic <> ?
                     aux_dscritic = pc_exclui_iof.pr_dscritic
                               WHEN pc_exclui_iof.pr_dscritic <> ?.

              /* Se retornou erro */
              IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
                DO:
                  UNDO Desfaz , LEAVE Desfaz.
                END.
        
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
              /* Efetuar a chamada a rotina Oracle */
              RUN STORED-PROCEDURE pc_exclui_calculo_CET
              aux_handproc = PROC-HANDLE NO-ERROR 
                          (INPUT par_cdcooper        /* Cooperativa              */ 
                          ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                          ,INPUT par_nrctremp        /* Numero do Bordero        */
                          ,OUTPUT 0                  /* Codigo da Critica */
                          ,OUTPUT "").               /* Descriçao da crítica */
                                                                                   
              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_exclui_calculo_CET
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
      
              ASSIGN aux_cdcritic = 0
                                 aux_dscritic = ""
                                 aux_cdcritic = pc_exclui_calculo_CET.pr_cdcritic
                                                                        WHEN pc_exclui_calculo_CET.pr_cdcritic <> ?
                                 aux_dscritic = pc_exclui_calculo_CET.pr_dscritic
                                                                        WHEN pc_exclui_calculo_CET.pr_dscritic <> ?.
            
              /* Se retornou erro */
              IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
                DO:
                  UNDO Desfaz , LEAVE Desfaz.
                END.        

        RUN sistema/generico/procedures/b1wgen0043.p PERSISTEN SET h-b1wgen0043.

        RUN volta-atras-rating IN h-b1wgen0043 ( INPUT  par_cdcooper,
                                                 INPUT  0,
                                                 INPUT  0,
                                                 INPUT  par_cdoperad,
                                                 INPUT  par_dtmvtolt,
                                                 INPUT  par_dtmvtopr,
                                                 INPUT  par_nrdconta,
                                                 INPUT  90, /* Emprestimo */
                                                 INPUT  par_nrctremp,
                                                 INPUT  1,
                                                 INPUT  1,
                                                 INPUT  par_nmdatela,
                                                 INPUT  par_inproces,
                                                 INPUT  FALSE,
                                                 OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0043.

        IF   RETURN-VALUE <> "OK" THEN
             UNDO, RETURN "NOK".

        /* Busca dados da proposta */
        FOR FIRST crawepr FIELDS(crawepr.nrctrliq[1] crawepr.nrctrliq[2]
                                 crawepr.nrctrliq[3] crawepr.nrctrliq[4]
                                 crawepr.nrctrliq[5] crawepr.nrctrliq[6]
                                 crawepr.nrctrliq[7] crawepr.nrctrliq[8]
                                 crawepr.nrctrliq[9] crawepr.nrctrliq[10]
                                 idcobope)
                          WHERE crawepr.cdcooper = par_cdcooper   AND
                                crawepr.nrdconta = par_nrdconta   AND
                                crawepr.nrctremp = par_nrctremp   NO-LOCK:

           IF  crawepr.idcobope > 0  THEN
               DO:
            
                  /* Efetuar o desbloqueio de possiveis coberturas vinculadas ao mesmo */
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                  RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                        ,INPUT crawepr.idcobope
                                                        ,INPUT "D"
                                                        ,INPUT par_cdoperad
                                                        ,INPUT ""
                                                        ,INPUT 0
                                                        ,INPUT "S"
                                                        ,"").

                  CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  ASSIGN aux_dscritic  = ""
                         aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                         WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                  IF aux_dscritic <> "" THEN
                     UNDO Desfaz , LEAVE Desfaz.

                  DO i = 1 TO 10:

                     IF  crawepr.nrctrliq[i] > 0  THEN
                         DO:

                            FOR FIRST b-crawepr FIELDS(idcobope)
                                                WHERE b-crawepr.cdcooper = par_cdcooper   AND
                                                      b-crawepr.nrdconta = par_nrdconta   AND
                                                      b-crawepr.nrctremp = crawepr.nrctrliq[i] NO-LOCK:
                               IF  b-crawepr.idcobope > 0  THEN
                                   DO:
                                      /* Efetuar o bloqueio de possiveis coberturas vinculadas ao mesmo */
                                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                      RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                                                            ,INPUT b-crawepr.idcobope
                                                                            ,INPUT "B"
                                                                            ,INPUT par_cdoperad
                                                                            ,INPUT ""
                                                                            ,INPUT 0
                                                                            ,INPUT "S"
                                                                            ,"").

                                      CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                      ASSIGN aux_dscritic  = ""
                                             aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic 
                                                             WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                                      IF aux_dscritic <> "" THEN
                                         UNDO Desfaz , LEAVE Desfaz.
                                   END.
                            END. /* FOR FIRST b-crawepr */

                         END. /* crawepr.nrctrliq[i] > 0 */

                  END. /** Fim do DO ... TO **/

               END. /* crawepr.idcobope > 0 */

        END. /* FOR FIRST crawepr */

        DELETE crapepr.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    IF   par_flgerlog THEN
         DO:
             RUN proc_gerar_log ( INPUT  par_cdcooper,
                                  INPUT  par_cdoperad,
                                  INPUT  aux_dscritic,
                                  INPUT  aux_dsorigem,
                                  INPUT  aux_dstransa,
                                  INPUT  FALSE,
                                  INPUT  par_idseqttl,
                                  INPUT  par_nmdatela,
                                  INPUT  par_nrdconta,
                                  OUTPUT aux_nrdrowid).

            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctremp",
                                     INPUT par_nrctremp,
                                     INPUT par_nrctremp).

         END.

    RETURN "OK".

END PROCEDURE. /* desfaz efetivacao emprestimo */

PROCEDURE transf_contrato_prejuizo.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR         h-b1wgen0043  AS HANDLE                         NO-UNDO.
    DEF VAR         h-b1wgen0084a AS HANDLE                         NO-UNDO.
    DEF VAR         h-b1wgen0134  AS HANDLE                         NO-UNDO.

    DEF VAR     aux_vlttmupr LIKE crapepr.vlttmupr                  NO-UNDO.
    DEF VAR     aux_vlttjmpr LIKE crapepr.vlttjmpr                  NO-UNDO.
    DEF VAR     aux_vliofcpl LIKE crapepr.vliofcpl                  NO-UNDO.
    DEF VAR     aux_cdhistor LIKE craplem.cdhistor EXTENT 3         NO-UNDO.
    DEF VAR     aux_flgtrans AS LOGICAL                             NO-UNDO.
    DEF VAR     aux_dstransa AS CHAR                                NO-UNDO.
    DEF VAR     aux_vlrtotal AS DEC                                 NO-UNDO.
    DEF VAR     aux_dtcalcul AS DATE                                NO-UNDO.
    DEF VAR     aux_ehmensal AS LOGICAL                             NO-UNDO.
    DEF VAR     aux_qtdiaris AS INTE                                NO-UNDO.

    DEF VAR aux_vljurmes     AS DECI                                NO-UNDO.
    DEF VAR aux_diarefju     AS INTE                                NO-UNDO.
    DEF VAR aux_mesrefju     AS INTE                                NO-UNDO.
    DEF VAR aux_anorefju     AS INTE                                NO-UNDO.

    DEF VAR aux_flgativo     AS DEC                                 NO-UNDO.
  
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_flgtrans = FALSE.

    TRANSFERE:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO , LEAVE:
      
       FOR FIRST crapdat FIELDS(dtmvtoan dtultdma)
                         WHERE crapdat.cdcooper = par_cdcooper
                               NO-LOCK: END.

       IF NOT AVAIL(crapdat) THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Erro ao buscar informacao CRAPDAT.".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT 1, /* nrdcaixa  */
                          INPUT 1, /* sequencia */
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.
            
       /* Verificacao de contrato de acordo
      
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Verifica se ha contratos de acordo */
        RUN STORED-PROCEDURE pc_verifica_acordo_ativo
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                              ,INPUT par_nrdconta
                                              ,INPUT par_nrctremp
                                              ,INPUT 3
                                              ,0
                                              ,0
                                              ,"").

        CLOSE STORED-PROC pc_verifica_acordo_ativo
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
               aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
               aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
        
        IF aux_cdcritic > 0 OR (aux_dscritic <> ? AND aux_dscritic <> "") THEN
          DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
          END.        
          
        IF aux_flgativo = 1 THEN
          DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Transferencia para prejuizo nao permitida, emprestimo em acordo.".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT 1, /* nrdcaixa  */
                          INPUT 1, /* sequencia */
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
             
       END.
       */
          
       /* Fim verificacao contrato acordo */     
       FOR LAST crapris FIELDS(innivris dtdrisco)
                        WHERE crapris.cdcooper = par_cdcooper     AND
                              crapris.nrdconta = par_nrdconta     AND
                              crapris.nrctremp = par_nrctremp     AND
                              crapris.dtrefere = crapdat.dtultdma AND
                              crapris.cdorigem = 3                AND
                              crapris.inddocto = 1
                              NO-LOCK: END.
                            
       IF AVAIL(crapris) THEN
       DO:
           /* Precisa estar 180 dias com risco em H */
           ASSIGN aux_qtdiaris = par_dtmvtolt - crapris.dtdrisco.
           
           IF crapris.innivris = 9 AND aux_qtdiaris > 179 THEN
           DO:
               FOR FIRST crapepr
                   WHERE crapepr.cdcooper = par_cdcooper
                     AND crapepr.nrdconta = par_nrdconta
                     AND crapepr.nrctremp = par_nrctremp
                     EXCLUSIVE-LOCK: END.

               IF AVAIL(crapepr) THEN
               DO:
                   IF crapepr.inprejuz = 1 THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Contrato ja esta em prejuizo!".

                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT 1, /* nrdcaixa  */
                                      INPUT 1, /* sequencia */
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).

                       RETURN "NOK".
                   END.
                   ELSE
                   DO:
                       /* Tratamento Juros */

                       aux_dtcalcul = fnBuscaDataDoUltimoDiaUtilMes(par_cdcooper,par_dtmvtolt).

                       IF   par_dtmvtolt > aux_dtcalcul   THEN
                           DO:
                               ASSIGN aux_ehmensal = TRUE.
                           END.
                        ELSE
                           DO:
                               ASSIGN aux_ehmensal = FALSE.
                           END.

                        RUN sistema/generico/procedures/b1wgen0084a.p
                        PERSISTENT SET h-b1wgen0084a.


                        RUN lanca_juro_contrato IN h-b1wgen0084a (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT par_nrdconta,
                                                                INPUT par_nrctremp,
                                                                INPUT par_dtmvtolt,
                                                                INPUT par_cdoperad,
                                                                INPUT par_cdagenci,
                                                                INPUT TRUE,
                                                                INPUT par_dtmvtolt,
                                                                INPUT aux_ehmensal,
                                                                INPUT crapepr.dtdpagto,
                                                                INPUT par_idorigem,
                                                               OUTPUT TABLE tt-erro,
                                                               OUTPUT aux_vljurmes,
                                                               OUTPUT aux_diarefju,
                                                               OUTPUT aux_mesrefju,
                                                               OUTPUT aux_anorefju).

                        DELETE PROCEDURE h-b1wgen0084a.

                        IF RETURN-VALUE <> "OK" THEN
                        DO:
                             ASSIGN aux_cdcritic = 0
                                    aux_dscritic = "Erro ao calcular juros.".

                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT 1, /* nrdcaixa  */
                                                   INPUT 1, /* sequencia */
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).

                                     RETURN "NOK".

                        END.

                        IF   aux_vljurmes > 0   THEN
                          ASSIGN crapepr.diarefju = aux_diarefju
                                 crapepr.mesrefju = aux_mesrefju
                                 crapepr.anorefju = aux_anorefju.

                          ASSIGN crapepr.vlsdeved = crapepr.vlsdeved + aux_vljurmes
                                 crapepr.vljuracu = crapepr.vljuracu + aux_vljurmes
                                 crapepr.vljurmes = crapepr.vljurmes + aux_vljurmes
                                 crapepr.vljuratu = crapepr.vljuratu + aux_vljurmes.

                       IF NOT VALID-HANDLE(h-b1wgen0084a) THEN
                          RUN sistema/generico/procedures/b1wgen0084a.p
                              PERSISTENT SET h-b1wgen0084a.
                              
                       RUN busca_pagamentos_parcelas IN h-b1wgen0084a
                                                   (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT par_idorigem,
                                                    INPUT crapepr.nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT par_dtmvtolt,
                                                    INPUT FALSE,
                                                    INPUT crapepr.nrctremp,
                                                    INPUT crapdat.dtmvtoan,
                                                    INPUT 0, /* Todas */
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-pagamentos-parcelas,
                                                   OUTPUT TABLE tt-calculado).

                       IF VALID-HANDLE(h-b1wgen0084a) THEN
                          DELETE PROCEDURE h-b1wgen0084a.

                       IF RETURN-VALUE <> "OK" THEN
                       DO:
                           ASSIGN aux_cdcritic = 0
                                  aux_dscritic = "Erro ao Buscar Dados Parcelas.".

                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT 1, /* nrdcaixa  */
                                          INPUT 1, /* sequencia */
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).

                           RETURN "NOK".
                       END.


                       ASSIGN aux_vlttmupr = 0
                              aux_vlttjmpr = 0
                              aux_vliofcpl = 0.

                       FOR EACH tt-pagamentos-parcelas
                          WHERE tt-pagamentos-parcelas.inliquid = 0 /* Nao Liquidadas */
                           NO-LOCK:

                           ASSIGN aux_vlttmupr = aux_vlttmupr + tt-pagamentos-parcelas.vlmtapar
                                  aux_vlttjmpr = aux_vlttjmpr + tt-pagamentos-parcelas.vlmrapar
                                  aux_vliofcpl = aux_vliofcpl + tt-pagamentos-parcelas.vliofcpl.

                       END.

                       IF NOT VALID-HANDLE(h-b1wgen0043) THEN
                          RUN sistema/generico/procedures/b1wgen0043.p
                              PERSISTENT SET h-b1wgen0043.

                       /* Desativar Rating */
                       RUN desativa_rating IN h-b1wgen0043
                                           (INPUT par_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT par_cdoperad,
                                            INPUT par_dtmvtolt,
                                            INPUT par_dtmvtopr,
                                            INPUT par_nrdconta,
                                            INPUT 90,
                                            INPUT par_nrctremp,
                                            INPUT TRUE,
                                            INPUT 1,
                                            INPUT 1,
                                            INPUT "ATENDA",
                                            INPUT par_inproces,
                                            INPUT FALSE,
                                            OUTPUT TABLE tt-erro).

                       IF VALID-HANDLE(h-b1wgen0043) THEN
                          DELETE PROCEDURE h-b1wgen0043.

                       IF RETURN-VALUE <> "OK"   THEN
                       DO:
                           ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Erro ao desativar Rating!".

                                  RUN gera_erro (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT 1, /* nrdcaixa  */
                                                 INPUT 1, /* sequencia */
                                                 INPUT aux_cdcritic,
                                                 INPUT-OUTPUT aux_dscritic).
                                  RETURN "NOK".
                       END.

                       /* Criar lancamentos CRAPLEM */
                       FOR FIRST craplcr FIELDS(dsoperac)
                           WHERE craplcr.cdcooper = par_cdcooper
                             AND craplcr.cdlcremp = crapepr.cdlcremp
                                 NO-LOCK: END.

                       IF NOT AVAIL(craplcr) THEN
                       DO:
                          ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Linha de Credito nao Cadastra!".

                                  RUN gera_erro (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT 1, /* nrdcaixa  */
                                                 INPUT 1, /* sequencia */
                                                 INPUT aux_cdcritic,
                                                 INPUT-OUTPUT aux_dscritic).
                       END.

                       FOR FIRST tt-calculado
                           NO-LOCK: END.

                       IF NOT AVAIL(tt-calculado) OR
                          tt-calculado.vlsdeved = 0  THEN
                       DO:
                           ASSIGN aux_cdcritic = 0
                                  aux_dscritic = "Erro ao buscar saldos do contrato.".

                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT 1, /* nrdcaixa  */
                                          INPUT 1, /* sequencia */
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic).

                           RETURN "NOK".
                       END.

                       /* Atualizar Emprestimo */
                       ASSIGN crapepr.vlprejuz = tt-calculado.vlsderel
                              crapepr.vlsdprej = tt-calculado.vlsderel
                              crapepr.inprejuz = 1 /* Em prejuizo */
                              crapepr.inliquid = 1 /* Liquidado   */
                              crapepr.dtprejuz = par_dtmvtolt
                              crapepr.vlttmupr = aux_vlttmupr          /* Multa das Parcelas */
                              crapepr.vlttjmpr = aux_vlttjmpr          /* Juros de Mora das Parcelas */
                              crapepr.vliofcpl = aux_vliofcpl          /* valor do IOF complementar de atraso */
                              crapepr.vlpgmupr = 0
                              crapepr.vlpgjmpr = 0
                              /* crapepr.vlpiofpr = 0 --> Como nao ha estorno de IOF Prejuizo, manter valor pago anteriormente */                                
                              crapepr.vlsdeved = 0
                              crapepr.vlsdevat = 0.
                       /*
                           IF RETURN-VALUE <> "OK"   THEN
                               UNDO TRANSFERE , LEAVE TRANSFERE.
                       */

                       IF craplcr.dsoperac = "FINANCIAMENTO" THEN /* Financiamento */
                         ASSIGN aux_cdhistor[1] = 1732  /* FINANCIAMENTO PRE-FIXADO TRANSFERIDO PARA PREJUIZO */
                                aux_cdhistor[2] = 1734  /* MULTA MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                                aux_cdhistor[3] = 1736. /* JUROS MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                       ELSE /* Emprestimo */
                         ASSIGN aux_cdhistor[1] = 1731  /* EMPRESTIMO PRE-FIXADO TRANSFERIDO PARA PREJUIZO  */
                                aux_cdhistor[2] = 1733  /* MULTA MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */
                                aux_cdhistor[3] = 1735. /* JUROS MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */

                       RUN sistema/generico/procedures/b1wgen0134.p
                           PERSISTENT SET h-b1wgen0134.


                       IF crapepr.vlprejuz > 0 THEN
                           RUN cria_lancamento_lem IN h-b1wgen0134
                                                       (INPUT par_cdcooper,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_cdagenci,
                                                        INPUT 100, /* cdbccxlt */
                                                        INPUT par_cdoperad,
                                                        INPUT par_cdagenci,
                                                        INPUT 5,       /* tplotmov */
                                                        INPUT 600029,  /* nrdolote */
                                                        INPUT par_nrdconta,
                                                        INPUT aux_cdhistor[1],
                                                        INPUT par_nrctremp,
                                                        INPUT crapepr.vlprejuz,
                                                        INPUT par_dtmvtolt,
                                                        INPUT 0,  /* txjurepr */
                                                        INPUT 0,  /* vlpreemp */
                                                        INPUT 0,  /* nrsequni */
                                                        INPUT 0,
                                                        INPUT TRUE,
                                                        INPUT FALSE,   /* flgcredi */
                                                        INPUT 0,
                                                        INPUT par_idorigem).

                       IF crapepr.vlttmupr > 0 THEN
                           RUN cria_lancamento_lem IN h-b1wgen0134
                                                       (INPUT par_cdcooper,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_cdagenci,
                                                        INPUT 100, /* cdbccxlt */
                                                        INPUT par_cdoperad,
                                                        INPUT par_cdagenci,
                                                        INPUT 5,       /* tplotmov */
                                                        INPUT 600029,  /* nrdolote */
                                                        INPUT par_nrdconta,
                                                        INPUT aux_cdhistor[2],
                                                        INPUT par_nrctremp,
                                                        INPUT crapepr.vlttmupr,
                                                        INPUT par_dtmvtolt,
                                                        INPUT 0,  /* txjurepr */
                                                        INPUT 0,  /* vlpreemp */
                                                        INPUT 0,  /* nrsequni */
                                                        INPUT 0,
                                                        INPUT TRUE,
                                                        INPUT FALSE,   /* flgcredi */
                                                        INPUT 0,
                                                        INPUT par_idorigem).

                       IF crapepr.vlttjmpr > 0 THEN
                           RUN cria_lancamento_lem IN h-b1wgen0134
                                                       (INPUT par_cdcooper,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_cdagenci,
                                                        INPUT 100, /* cdbccxlt */
                                                        INPUT par_cdoperad,
                                                        INPUT par_cdagenci,
                                                        INPUT 5,       /* tplotmov */
                                                        INPUT 600029,  /* nrdolote */
                                                        INPUT par_nrdconta,
                                                        INPUT aux_cdhistor[3],
                                                        INPUT par_nrctremp,
                                                        INPUT crapepr.vlttjmpr,
                                                        INPUT par_dtmvtolt,
                                                        INPUT 0,  /* txjurepr */
                                                        INPUT 0,  /* vlpreemp */
                                                        INPUT 0,  /* nrsequni */
                                                        INPUT 0,
                                                        INPUT TRUE,
                                                        INPUT FALSE,   /* flgcredi */
                                                        INPUT 0,
                                                        INPUT par_idorigem).

                       DELETE PROCEDURE h-b1wgen0134.

                       /* Liquidar Parcelas CRAPPEP */
                       FOR EACH crappep FIELDS(inliquid inprejuz)
                          WHERE crappep.cdcooper = par_cdcooper
                            AND crappep.nrdconta = par_nrdconta
                            AND crappep.nrctremp = par_nrctremp
                            AND crappep.inliquid = 0
                            EXCLUSIVE-LOCK:

                            ASSIGN crappep.inliquid = 1
                                   crappep.inprejuz = 1.

                       END.

                       ASSIGN aux_vlrtotal = crapepr.vlttjmpr + crapepr.vlttmupr + crapepr.vlprejuz.

                       /* Registrar LOG */
                       ASSIGN aux_dstransa = STRING(par_dtmvtolt,"99/99/9999") + " - " +
                                             STRING(TIME,"HH:MM:SS") +
                                             " - TRANSFERENCIA P/ PREJUIZO" + "'-->'" +
                                             " Operador: " + par_cdoperad +
                                             " Hst: " + STRING(aux_cdhistor[1]) +
                                             " Conta: " + TRIM(STRING(par_nrdconta,"zz,zzz,zzz,z")) +
                                             " Contrato: " + STRING(par_nrctremp) +
                                             " Valor: " + TRIM(STRING(aux_vlrtotal,"zzzzzz,zzz,zz9.99")) +
                                             " Lote: " + TRIM(STRING(600029,"zzz,zz9")) +
                                             " PA: " + STRING(par_cdagenci,"999") +
                                             " Banco/Caixa: " + STRING(100,"999").

                       RUN sistema/generico/procedures/b1wgen0014.p
                           PERSISTENT SET h-b1wgen0014.

                       IF  VALID-HANDLE(h-b1wgen0014)  THEN
                           DO:
                               RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                                             INPUT par_cdoperad,
                                                             INPUT "",
                                                             INPUT "AIMARO",
                                                             INPUT aux_dstransa,
                                                             INPUT par_dtmvtolt,
                                                             INPUT TRUE,
                                                             INPUT TIME,
                                                             INPUT 1,
                                                             INPUT "ATENDA",
                                                             INPUT par_nrdconta,
                                                             OUTPUT aux_nrdrowid).

                               DELETE PROCEDURE h-b1wgen0014.
                           END.


                       ASSIGN aux_flgtrans = TRUE.

                   END.

               END.
               ELSE
               DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Erro ao localizar Emprestimo!".

                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT 1, /* nrdcaixa  */
                                      INPUT 1, /* sequencia */
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).

                       RETURN "NOK".
               END.


           END.
           ELSE
           DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Operacao nao permitida. Verifique Risco e Dias no Risco!".

               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT 1, /* nrdcaixa  */
                              INPUT 1, /* sequencia */
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).

               RETURN "NOK".
           END.
       END.
       ELSE
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Operacao nao permitida. Verifique Risco e Dias no Risco!".

               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT 1, /* nrdcaixa  */
                              INPUT 1, /* sequencia */
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).

               RETURN "NOK".
       END.

    END.

    IF NOT aux_flgtrans THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Erro ao efetuar Transferencia para Prejuizo.".

        IF NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".


END PROCEDURE.


PROCEDURE desfaz_transferencia_prejuizo.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR         h-b1wgen0027  AS HANDLE                         NO-UNDO.
    DEF VAR         h-b1wgen0043  AS HANDLE                         NO-UNDO.
    DEF VAR         h-b1wgen0084a AS HANDLE                         NO-UNDO.
    DEF VAR         h-b1wgen0134  AS HANDLE                         NO-UNDO.
    DEF VAR         h-b1craplot   AS HANDLE                         NO-UNDO.

    DEF VAR     aux_vlttmupr LIKE crapepr.vlttmupr                  NO-UNDO.
    DEF VAR     aux_vlttjmpr LIKE crapepr.vlttjmpr                  NO-UNDO.
    DEF VAR     aux_vliofcpl LIKE crapepr.vliofcpl                  NO-UNDO.
    DEF VAR     aux_cdhistor LIKE craplem.cdhistor EXTENT 6         NO-UNDO.
    DEF VAR     aux_flgtrans AS LOGICAL                             NO-UNDO.
    DEF VAR     aux_dstransa AS CHAR                                NO-UNDO.
    DEF VAR     aux_vlrtotal AS DEC                                 NO-UNDO.
    DEF VAR     aux_dtcalcul AS DATE                                NO-UNDO.
    DEF VAR     aux_ehmensal AS LOGICAL                             NO-UNDO.
    DEF VAR     aux_valor    AS DECI                                NO-UNDO.

    DEF VAR     aux_cdcritic AS INTE                                NO-UNDO.
    DEF VAR     aux_nrseqdig AS INTE                                NO-UNDO.

    DEF VAR     aux_flgativo AS DEC                                 NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.


    ASSIGN aux_flgtrans = FALSE.

    TRANSFERE:
    DO ON ENDKEY UNDO , LEAVE ON ERROR UNDO , LEAVE:

        FOR FIRST crapepr
            WHERE crapepr.cdcooper = par_cdcooper
              AND crapepr.nrdconta = par_nrdconta
              AND crapepr.nrctremp = par_nrctremp
              AND crapepr.inprejuz = 1
              EXCLUSIVE-LOCK: END.

        IF NOT AVAIL(crapepr) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Contrato nao esta em prejuizo!".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
        ELSE
        DO:

            IF crapepr.dtprejuz <> par_dtmvtolt THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de Envio Prejuizo diferente Data Atual!".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.

            ASSIGN aux_cdhistor[1] = 1732  /* FINANCIAMENTO PRE-FIXADO TRANSFERIDO PARA PREJUIZO */
                   aux_cdhistor[2] = 1734  /* MULTA MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                   aux_cdhistor[3] = 1736  /* JUROS MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */

                   aux_cdhistor[4] = 1731  /* EMPRESTIMO PRE-FIXADO TRANSFERIDO PARA PREJUIZO  */
                   aux_cdhistor[5] = 1733  /* MULTA MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */
                   aux_cdhistor[6] = 1735. /* JUROS MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */

            /* Verifica existencia de pagamentos */
            FOR FIRST craplem FIELDS(cdcooper)
                WHERE craplem.cdcooper = par_cdcooper
                  AND craplem.dtmvtolt = par_dtmvtolt
                  AND craplem.nrdconta = par_nrdconta
                  AND craplem.nrctremp = par_nrctremp
                  AND craplem.cdhistor <> 1037 /* Juros normais */
                  AND craplem.cdhistor <> 1038 /* Juros normais */
                  AND craplem.cdhistor <> aux_cdhistor[1]
                  AND craplem.cdhistor <> aux_cdhistor[2]
                  AND craplem.cdhistor <> aux_cdhistor[3]
                  AND craplem.cdhistor <> aux_cdhistor[4]
                  AND craplem.cdhistor <> aux_cdhistor[5]
                  AND craplem.cdhistor <> aux_cdhistor[6]

                  NO-LOCK: END.


            /* Caso possua registro abosrta processo */
            IF AVAIL(craplem)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Existem pagamentos na data atual. Operacao Cancelada!".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.

                        /* Verificacao de contrato de acordo */  
      
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        /* Verifica se ha contratos de acordo */
                        RUN STORED-PROCEDURE pc_verifica_acordo_ativo
                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                                                                ,INPUT par_nrdconta
                                                                                                ,INPUT par_nrctremp
                                                                                                ,INPUT 3
                                                                                                ,0
                                                                                                ,0
                                                                                                ,"").

                        CLOSE STORED-PROC pc_verifica_acordo_ativo
                                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                        ASSIGN aux_cdcritic = 0
                                        aux_dscritic = ""
                                        aux_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                                        aux_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                                        aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
      
                        IF aux_cdcritic > 0 OR (aux_dscritic <> ? AND aux_dscritic <> "") THEN
                        DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.

                        IF aux_flgativo = 1 THEN
                        DO:
                                ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao e possivel desfazer prejuizo, emprestimo em acordo.".

                                RUN gera_erro (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT 1, /* nrdcaixa  */
                                                                INPUT 1, /* sequencia */
                                                                INPUT aux_cdcritic,
                                                                INPUT-OUTPUT aux_dscritic).

                                RETURN "NOK".
           
                        END.
     
                        /* Fim verificacao contrato acordo */

            IF NOT VALID-HANDLE(h-b1wgen0043) THEN
               RUN sistema/generico/procedures/b1wgen0043.p
                   PERSISTENT SET h-b1wgen0043.

            /* Ativar Rating */
            RUN ativa_rating IN h-b1wgen0043
                                (INPUT par_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_dtmvtopr,
                                 INPUT par_nrdconta,
                                 INPUT 90,
                                 INPUT par_nrctremp,
                                 INPUT TRUE,
                                 INPUT 1,
                                 INPUT 1,
                                 INPUT "ATENDA",
                                 INPUT par_inproces,
                                 INPUT FALSE,
                                 OUTPUT TABLE tt-erro).

            IF VALID-HANDLE(h-b1wgen0043) THEN
               DELETE PROCEDURE h-b1wgen0043.

            IF RETURN-VALUE <> "OK"   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Erro ao Ativar Rating!".

                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT 1, /* nrdcaixa  */
                                      INPUT 1, /* sequencia */
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).
                       RETURN "NOK".
            END.

            /* Atualiza lote */
            RUN sistema/generico/procedures/b1craplot.p PERSISTENT SET h-b1craplot.

            /* Eliminar registros criados na CRAPLEM */
            FOR EACH craplem
                WHERE craplem.cdcooper = par_cdcooper
                  AND craplem.dtmvtolt = par_dtmvtolt
                  AND craplem.cdbccxlt = 100
                  AND craplem.nrdolote = 600029
                  AND craplem.nrdconta = par_nrdconta
                  AND craplem.nrctremp = par_nrctremp
                  EXCLUSIVE-LOCK:

                  ASSIGN aux_valor = 0.

                  IF crapepr.vlprejuz > 0                 AND
                     (craplem.cdhistor = aux_cdhistor[1]  OR
                      craplem.cdhistor = aux_cdhistor[4]) THEN
                     ASSIGN aux_valor = crapepr.vlprejuz.

                  IF crapepr.vlttmupr > 0                 AND
                     (craplem.cdhistor = aux_cdhistor[2]  OR
                      craplem.cdhistor = aux_cdhistor[5]) THEN
                     ASSIGN aux_valor = crapepr.vlttmupr.

                  IF crapepr.vlttjmpr > 0                 AND
                     (craplem.cdhistor = aux_cdhistor[3]  OR
                      craplem.cdhistor = aux_cdhistor[6]) THEN
                     ASSIGN aux_valor = crapepr.vlttjmpr.

                  IF aux_valor > 0 THEN
                  DO:
                      RUN inclui-altera-lote IN h-b1craplot (INPUT par_cdcooper,
                                                  INPUT craplem.dtmvtolt,
                                                  INPUT craplem.cdagenci,
                                                  INPUT craplem.cdbccxlt,
                                                  INPUT craplem.nrdolote,
                                                  INPUT 5,
                                                  INPUT par_cdoperad,
                                                  INPUT 0,
                                                  INPUT craplem.dtmvtolt,
                                                  INPUT aux_valor,
                                                  INPUT FALSE,
                                                  INPUT TRUE,
                                                 OUTPUT aux_nrseqdig,
                                                 OUTPUT aux_cdcritic).
                     DELETE craplem.
                  END.

            END.

            DELETE PROCEDURE h-b1craplot.


            /* Liquidar Parcelas CRAPPEP */
            FOR EACH crappep FIELDS(inliquid inprejuz)
               WHERE crappep.cdcooper = par_cdcooper
                 AND crappep.nrdconta = par_nrdconta
                 AND crappep.nrctremp = par_nrctremp
                 AND crappep.inliquid = 1
                 AND crappep.inprejuz = 1
                 EXCLUSIVE-LOCK:

                 ASSIGN crappep.inliquid = 0
                        crappep.inprejuz = 0.

            END.

            /* Atualizar Emprestimo */
            ASSIGN crapepr.vlsdeved = crapepr.vlprejuz
                   crapepr.vlsdevat = crapepr.vlsdprej.

            ASSIGN crapepr.vlprejuz = 0
                   crapepr.vlsdprej = 0
                   crapepr.inprejuz = 0
                   crapepr.inliquid = 0
                   crapepr.dtprejuz = ?
                   crapepr.vlttmupr = 0
                   crapepr.vlttjmpr = 0
                   crapepr.vltiofpr = 0
                   crapepr.vlpgmupr = 0
                   crapepr.vlpgjmpr = 0
                   /* crapepr.vlpiofpr = 0 --> Como nao ha estorno de IOF Prejuizo, manter valor pago anteriormente */
                   .

            /* Registrar LOG */
            ASSIGN aux_dstransa = STRING(par_dtmvtolt,"99/99/9999") + " - " +
                                  STRING(TIME,"HH:MM:SS") +
                                  " - DESFAZ TRANSFERENCIA P/ PREJUIZO" + "'-->'" +
                                  " Operador: " + par_cdoperad +
                                  " Conta: " + TRIM(STRING(par_nrdconta,"zz,zzz,zzz,z")) +
                                  " Contrato: " + STRING(par_nrctremp) +
                                  " Lote: " + TRIM(STRING(600029,"zzz,zz9")) +
                                  " PA: " + STRING(par_cdagenci,"999") +
                                  " Banco/Caixa: " + STRING(100,"999").

            RUN sistema/generico/procedures/b1wgen0014.p
                PERSISTENT SET h-b1wgen0014.

            IF  VALID-HANDLE(h-b1wgen0014)  THEN
                DO:
                    RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                                  INPUT par_cdoperad,
                                                  INPUT "",
                                                  INPUT "AIMARO",
                                                  INPUT aux_dstransa,
                                                  INPUT par_dtmvtolt,
                                                  INPUT TRUE,
                                                  INPUT TIME,
                                                  INPUT 1,
                                                  INPUT "ATENDA",
                                                  INPUT par_nrdconta,
                                                  OUTPUT aux_nrdrowid).

                    DELETE PROCEDURE h-b1wgen0014.
                END.


            ASSIGN aux_flgtrans = TRUE.


            END.

    END. /* Transaction */

    IF NOT aux_flgtrans THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Erro ao efetuar Transferencia para Prejuizo.".

        IF NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".


END PROCEDURE.

PROCEDURE efetua_estorno_pagamentos_pp:
  
    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.   
    DEF  INPUT PARAM par_nrctremp AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dsjustificativa AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.    
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_tela_estornar_pagamentos
         aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_nmdatela,
                       INPUT par_idorigem,
                       INPUT par_nrdconta,
                       INPUT par_idseqttl,
                       INPUT par_dtmvtolt,
                       INPUT par_dtmvtopr,
                       INPUT par_nrctremp,
                       INPUT par_dsjustificativa,
                      OUTPUT 0,
                      OUTPUT "").

    CLOSE STORED-PROC pc_tela_estornar_pagamentos 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    ASSIGN aux_cdcritic = pc_tela_estornar_pagamentos.pr_cdcritic
                             WHEN pc_tela_estornar_pagamentos.pr_cdcritic <> ?
           aux_dscritic = pc_tela_estornar_pagamentos.pr_dscritic
                             WHEN pc_tela_estornar_pagamentos.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
       DO:
           CREATE tt-erro.
           ASSIGN tt-erro.cdcritic = aux_cdcritic
                  tt-erro.dscritic = aux_dscritic.
           RETURN "NOK".
       END.
    
    IF NOT VALID-HANDLE(h-b1wgen0043) THEN
       RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

    /* Verificar se tem que ativar/desativar Rating da operacao */
    RUN verifica_contrato_rating IN h-b1wgen0043
                       (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_cdoperad,
                        INPUT par_dtmvtolt,
                        INPUT par_dtmvtopr,
                        INPUT par_nrdconta,
                        INPUT 90,
                        INPUT par_nrctremp,
                        INPUT 1,
                        INPUT par_idorigem,
                        INPUT par_nmdatela,
                        INPUT par_inproces,
                        INPUT TRUE,
                        OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0043) THEN
       DELETE PROCEDURE h-b1wgen0043.

    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
        
    RETURN "OK".

END PROCEDURE.

PROCEDURE buscar_historico_e_lote_efet_prop: 
    DEF  INPUT PARAM par_tpemprst AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idfiniof AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dsoperac AS CHAR                            NO-UNDO.
    
    DEF  OUTPUT PARAM par_cdhistor AS INTE                            NO-UNDO.
    DEF  OUTPUT PARAM par_cdhistor_tar AS INTE                            NO-UNDO.
    DEF  OUTPUT PARAM par_nrdolote AS INTE                            NO-UNDO.
    
    ASSIGN par_cdhistor = 0
           par_nrdolote = 0.
           
    
    /* Financia IOF - se financiar IOF, nunca vai ser TR */
    IF par_idfiniof = 1 THEN
      DO:        
        IF par_tpemprst = 1 THEN /* Pre-Fixado */
          DO:
            IF par_dsoperac = "FINANCIAMENTO" THEN
              ASSIGN par_cdhistor = 2305
                     par_cdhistor_tar = 2307
                     par_nrdolote = 600030.
                
            ELSE
              ASSIGN par_cdhistor = 2304
                     par_cdhistor_tar = 2306
                     par_nrdolote = 600005.
          END.
        ELSE
          IF par_tpemprst = 2 THEN /* Pos-Fixado */
            DO:
              IF par_dsoperac = "FINANCIAMENTO" THEN
                ASSIGN par_cdhistor = 2536
                       par_cdhistor_tar = 2307
                       par_nrdolote = 600030.
              ELSE
                ASSIGN par_cdhistor = 2535
                     par_cdhistor_tar = 2306
                       par_nrdolote = 600005.
            END.
      END.
    ELSE
      DO:
        /* Nao financia IOF */
        IF par_tpemprst = 1 THEN /* Pre-Fixado */
          DO:
          IF par_dsoperac = "FINANCIAMENTO" THEN
              ASSIGN par_cdhistor = 2309
                     par_nrdolote = 600030.
          ELSE
              ASSIGN par_cdhistor = 2308
                     par_nrdolote = 600005.
          END.
        ELSE
          IF par_tpemprst = 2 THEN /* Pos-Fixado */
            DO:
              IF par_dsoperac = "FINANCIAMENTO" THEN
                ASSIGN par_cdhistor = 2538
                       par_nrdolote = 600030.
                ELSE
                ASSIGN par_cdhistor = 2537
                       par_nrdolote = 600005.
            END.
        ELSE /* TR */             
          DO:
            ASSIGN par_cdhistor = 2310.
            IF par_dsoperac = "FINANCIAMENTO" THEN
                ASSIGN par_nrdolote = 600013.
            ELSE
                ASSIGN par_nrdolote = 600012.
          END.
      END.
        
    RETURN "OK".

END PROCEDURE.
/* ......................................................................... */
