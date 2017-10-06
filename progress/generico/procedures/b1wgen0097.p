/*............................................................................
    
    Programa: sistema/generico/procedures/b1wgen0097.p
    Autor   : Gabriel, GATI - Diego
    Data    : Maio/2011               Ultima Atualizacao: 27/09/2017
    
    Dados referentes ao programa:
    
    Objetivo  : BO para a simulacao de Emprestimos
    
    Alteracoes: 21/07/2011 - Acerto de parametros da chamada do procedimento 
                             de calculo de emprestimo. (GATI - Diego)
                             
                11/08/2011 - Adicionado validacao de carencia maxima na
                             validacao da simulacao. (GATI - Diego)

                19/09/2011 - Atualizacao de parametros passados para a procedure
                             de validacao de novo calculo (valida_novo_calculo)
                             da b1wgen0084. (GATI - Diego B.)
                             
                05/10/2011 - Alterada mensagem de erro proveniente da execucao
                             do metodo valida_novo_calculo. (GATI - Oliver)
                             
                07/02/2012 - Criação da Procedure 'verifica-dia-util' para validar
                             a Data de Liberação e 1º Pag. como dia útil. (Lucas)
                
                23/02/2012 - Implementado novo parametro para a rotina
                             valida_novo_calculo (Tiago).
                             
                02/03/2012 - Implementado melhorias nas procedures 
                             "busca-dados-simulacao" e "grava-dados-simulacao"
                             para inclusao do novo campo dtlibera da tabela
                             crapsim (Tiago).             
                             
                07/03/2012 - Retirado a consulta de IOF e da tarifa de 
                             emprestimo de dentro da procedure 
                             calcula_emprestimo (Tiago).

                22/03/2012 - Modificado a rotina consulta_tarifa_emprst para
                             considerar tambem o valor da tarifa especial
                             (Tiago).                        
                             
                28/03/2012 - Mudada a mensagem de parcelas fora da faixa da 
                             linha de credito (Gabriel).     
                             
                30/03/2012 - Incluido campo %CET (Gabriel).                       

                10/04/2012 - Criado a funcao busca-feriados (Tiago).

                20/04/2012 - Tratar carencia (Gabriel)

                11/05/2012 - Permitir datas não uteis para vencimento
                             da parcela (Oscar).

                14/06/2012 - Tratamento para tarifa de emprestimo (Gabriel).

                10/07/2013 - Modificado a rotina consulta_tarifa_emprst para
                             utilizar processo de busca tarifas da b1wgwn0153
                             e incluso tratamento tarifa avaliacao (Daniel)

                19/09/2013 - Retirado validacao de permissao para departamento
                             (Irlan)

                10/10/2013 - Incluido parametro cdprogra nas procedures da 
                             b1wgen0153 que carregam dados de tarifas (Tiago).

                13/12/2013 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle Inclusao do VALIDATE
                             ( Guilherme / SUPERO)
                             
                18/03/2014 - Ajuste na validacao da linha de carencia na
                             procedure "valida_gravacao_simulacao" (James)
                             
                05/08/2014 - Ajustado para calcular o cet - Projeto CET
                             (Lucas R./Gielow)
                             
                25/06/2015 - Projeto 215 - DV 3 (Daniel)
                
                08/07/2015 - Adicionei o campo cdmodali, dsmodali no retorno da 
                             procedure busca_dados_simulacao, ira definir portabilidade.
                             Alterei o relatorio de simulacao para apresentar
                             a modalidade de portabilidade.
                             (Carlos Rafael Tanholi - Projeto Portabilidade)
                             
                25/11/2015 - Alteracao na forma de carregamento do campo 
                             tt-crapsim.cdmodali na procedure busca_dados_simulacao
                             (Carlos Rafael Tanholi - Projeto Portabilidade)
                             
                30/11/2015 - Apenas carregar taxa do IOF para linhas de 
                             crédito que estejam habilitadas (Lucas Lunelli SD 350241)
                             
                04/03/2015 - Correçao feita na procedure grava_simulacao para isentar o IOF 
                             das operaçoes de "Portabilidade de Crédito".
                             (Carlos Rafael Tanholi - SD 408032)

                07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)

                             
                03/04/2017 - Ajuste no calculo do IOF. (James)     
				
				07/04/2017 - Passar o tipo de emprestimo fixo como 1-PP na chamada da 
				             rotina pc_calcula_iof_epr, pois todas as simulações são 
							 empréstimos PP  ( Renato Darosci )

				27/09/2017 - Projeto 410 - Incluir campo Indicador de 
                            financiamento do IOF (Diogo - Mouts) e valor total da simulação

............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0084tt.i }
{ sistema/generico/includes/b1wgen0097tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR hb1wgen0084  AS HANDLE                                      NO-UNDO.
DEF VAR hb1wgen0024  AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                      NO-UNDO.

DEF VAR var_qtdiacar AS INTE                                        NO-UNDO.
DEF VAR var_vlajuepr AS DECI                                        NO-UNDO.
DEF VAR var_txdiaria AS DECI                                        NO-UNDO.
DEF VAR var_txmensal AS DECI                                        NO-UNDO.
DEF VAR var_vliofepr AS DECI                                        NO-UNDO.
DEF VAR var_vlrtarif AS DECI                                        NO-UNDO.
DEF VAR var_vllibera AS DECI                                        NO-UNDO.
DEF VAR var_permnovo AS LOGI                                        NO-UNDO.


DEF STREAM str_limcre.

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

FUNCTION fnRetornaDiasUteis RETURNS INTEGER
    (par_cdcooper AS INTE, par_dtiniper AS DATE, par_dtfinper AS DATE):
    /* Funcao para calcular o numero de dias uteis entre duas datas */
    
    DEF VAR aux_nrdialib AS INTE                   NO-UNDO.
    DEF VAR aux_datadper AS DATE                   NO-UNDO.

    DO   aux_datadper = par_dtiniper + 1 TO par_dtfinper:
         
         IF   NOT CAN-DO ("1,7",STRING(WEEKDAY(aux_datadper)))   AND
              NOT CAN-FIND(crapfer WHERE
                           crapfer.cdcooper = par_cdcooper AND
                           crapfer.dtferiad = aux_datadper)     THEN
              ASSIGN aux_nrdialib = aux_nrdialib + 1.
    END.

    RETURN aux_nrdialib.

END FUNCTION.

PROCEDURE busca-feriados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapfer.                       
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapfer.

    FOR EACH crapfer WHERE crapfer.cdcooper       =  par_cdcooper            AND
                           YEAR(crapfer.dtferiad) <= YEAR(par_dtmvtolt) + 1  AND 
                           YEAR(crapfer.dtferiad) >= YEAR(par_dtmvtolt) NO-LOCK
                           BY crapfer.dtferiad:
 
        CREATE tt-crapfer.
        BUFFER-COPY crapfer TO tt-crapfer.
    END.
        
    RETURN "OK".

END PROCEDURE.


/***************************************************************************
 Carregar os dados de uma determinada simulacao de emprestimo
***************************************************************************/
PROCEDURE busca_dados_simulacao:

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
    DEF  INPUT PARAM par_nrsimula AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapsim.
    DEF OUTPUT PARAM TABLE FOR tt-parcelas-epr.

    EMPTY TEMP-TABLE tt-erro.         
    EMPTY TEMP-TABLE tt-crapsim.      
    EMPTY TEMP-TABLE tt-parcelas-epr. 

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Carregar simulacao de emprestimo " + 
                               STRING(par_nrsimula).

    FIND crapsim WHERE crapsim.cdcooper = par_cdcooper   AND
                       crapsim.nrdconta = par_nrdconta   AND
                       crapsim.nrsimula = par_nrsimula   NO-LOCK NO-ERROR.
    
    IF   AVAIL crapsim   THEN
         DO:                 
             CREATE tt-crapsim.
             BUFFER-COPY crapsim EXCEPT percetop TO tt-crapsim 
             ASSIGN tt-crapsim.percetop = 
                                   DECI (STRING(crapsim.percetop,"zz9.99"))
                    tt-crapsim.nrdialib = 
                                   fnRetornaDiasUteis(par_cdcooper,
                                                      tt-crapsim.dtmvtolt,
                                                      tt-crapsim.dtlibera)
                    tt-crapsim.idfiniof = crapsim.idfiniof.
             FIND crapass OF crapsim NO-LOCK NO-ERROR.
             IF   AVAIL crapass   THEN
                  ASSIGN tt-crapsim.cdagenci = crapass.cdagenci.

             FIND craplcr WHERE 
                  craplcr.cdcooper = tt-crapsim.cdcooper   AND
                  craplcr.cdlcremp = tt-crapsim.cdlcremp   NO-LOCK NO-ERROR.
             IF   AVAIL craplcr   THEN
                  ASSIGN tt-crapsim.dslcremp = craplcr.dslcremp.

             FIND crapfin WHERE 
                  crapfin.cdcooper = tt-crapsim.cdcooper   AND
                  crapfin.cdfinemp = tt-crapsim.cdfinemp   NO-LOCK NO-ERROR.
             IF   AVAIL crapfin   THEN
                  ASSIGN tt-crapsim.dsfinemp = crapfin.dsfinemp.

             ASSIGN tt-crapsim.vlrtotal = tt-crapsim.vlemprst + tt-crapsim.vliofepr + tt-crapsim.vlrtarif.

             IF (AVAIL crapfin) AND (AVAIL craplcr) THEN
             DO:
                /* guarda o tipo da finalidade */
                tt-crapsim.tpfinali = crapfin.tpfinali.

                /* caso for portabilidade */
                IF (crapfin.tpfinali = 2) THEN
                DO:
                    /* monta campo descricao da modalidade */
                    FOR FIRST gnsbmod FIELDS (dssubmod) 
                        WHERE gnsbmod.cdmodali = craplcr.cdmodali
                          AND gnsbmod.cdsubmod = craplcr.cdsubmod NO-LOCK.
                    END.

                    IF AVAIL gnsbmod THEN
                    DO: 
                        /* armazena o nome da submodalidade e cdmodali */
                        ASSIGN tt-crapsim.dsmodali = gnsbmod.dssubmod
                               tt-crapsim.cdmodali = craplcr.cdmodali + craplcr.cdsubmod.
                    END.
                END.
             END.
                          
             RUN sistema/generico/procedures/b1wgen0084.p 
                 PERSISTENT SET hb1wgen0084.
             
             RUN calcula_emprestimo IN hb1wgen0084  
                                       (INPUT  par_cdcooper,  
                                        INPUT  par_cdagenci,  
                                        INPUT  par_nrdcaixa,  
                                        INPUT  par_cdoperad,  
                                        INPUT  par_nmdatela,  
                                        INPUT  par_idorigem,  
                                        INPUT  par_nrdconta,  
                                        INPUT  par_idseqttl,  
                                        INPUT  par_flgerlog,
                                        INPUT  0,
                                        INPUT  craplcr.cdlcremp,  
                                        INPUT  crapsim.vlemprst,  
                                        INPUT  crapsim.qtparepr,  
                                        INPUT  crapsim.dtmvtolt,
                                        INPUT  crapsim.dtdpagto,
                                        INPUT  NO,            
                                        INPUT  crapsim.dtlibera,
                                        OUTPUT var_qtdiacar,  
                                        OUTPUT var_vlajuepr,  
                                        OUTPUT var_txdiaria,  
                                        OUTPUT var_txmensal,  
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-parcelas-epr).
             
             DELETE OBJECT hb1wgen0084.
         
             IF   RETURN-VALUE <> "OK"   THEN 
                  RETURN "NOK".
         
         END.
    ELSE
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Registro de simulacao nao encontrado.".
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".

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

END PROCEDURE. /* busca_dados_simulacao */

/***************************************************************************
 Carregar os dados das simulacoes dos emprestimos na rotina de EMPRESTIMO 
 da ATENDA
***************************************************************************/
PROCEDURE busca_simulacoes:

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
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-crapsim.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Carregar as simulacoes de emprestimos.".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapsim.

    FOR EACH crapsim WHERE crapsim.cdcooper = par_cdcooper    AND
                           crapsim.nrdconta = par_nrdconta    NO-LOCK:

        CREATE tt-crapsim.
        BUFFER-COPY crapsim EXCEPT percetop TO tt-crapsim.
        ASSIGN tt-crapsim.percetop = 
                    DECI (STRING(crapsim.percetop,"zz9.99")).

        FIND crapass OF crapsim NO-LOCK NO-ERROR.

        IF   AVAIL crapass   THEN
             ASSIGN tt-crapsim.cdagenci = crapass.cdagenci.

        FIND craplcr WHERE 
             craplcr.cdcooper = tt-crapsim.cdcooper   AND
             craplcr.cdlcremp = tt-crapsim.cdlcremp   NO-LOCK NO-ERROR.
        IF   AVAIL craplcr   THEN
             ASSIGN tt-crapsim.dslcremp = craplcr.dslcremp
                    tt-crapsim.cdmodali = craplcr.cdmodali + craplcr.cdsubmod.

        FIND crapfin WHERE 
             crapfin.cdcooper = tt-crapsim.cdcooper   AND
             crapfin.cdfinemp = tt-crapsim.cdfinemp   NO-LOCK NO-ERROR.
        IF   AVAIL crapfin   THEN
             ASSIGN tt-crapsim.dsfinemp = crapfin.dsfinemp
                    tt-crapsim.tpfinali = crapfin.tpfinali.
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

END PROCEDURE. /* busca_simulacoes */

PROCEDURE exclui_simulacao:

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
    DEF  INPUT PARAM par_nrsimula AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
                                                                             
    DEF  VAR aux_contador         AS INTE                           NO-UNDO.

    
    EMPTY TEMP-TABLE tt-erro.

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Excluir simulacao de emprestimo " + 
                               STRING(par_nrsimula).
    
    DO   aux_contador = 1 TO 10:
         
         FIND crapsim WHERE crapsim.cdcooper = par_cdcooper   AND
                            crapsim.nrdconta = par_nrdconta   AND
                            crapsim.nrsimula = par_nrsimula   
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
         IF   NOT AVAIL crapsim   THEN
              DO:
                 IF   LOCKED crapsim   THEN
                      DO:
                         ASSIGN aux_cdcritic = 341 
                                aux_dscritic = "".
                         NEXT.
                 
                      END.
                 ELSE
                      DO:
                         ASSIGN aux_cdcritic = 0
                                aux_dscritic = "Registro de simulacao nao " 
                                               + "encontrado.".
                         
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                         RETURN "NOK".
                      
                      END.
              END.
         
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "".
         LEAVE.
    END. /* DO   aux_contador = 1 TO 10: */

    IF   aux_cdcritic = 0 AND aux_dscritic = ""   THEN
         DELETE crapsim.
    ELSE 
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
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

END PROCEDURE. /* exclui_simulacao */

/*****************************************************************************
 Procedure para a gravacao da simulacao do Emprestimo (inclusao e alteracao)
*****************************************************************************/
PROCEDURE grava_simulacao:

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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrsimula AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.  
    DEF  INPUT PARAM par_percetop AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
	DEF  INPUT PARAM par_idfiniof AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nrgravad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_txcetano AS DECI                           NO-UNDO.
    
    DEF  VAR aux_contador AS INTE                                   NO-UNDO.
    DEF  VAR aux_nrsimula AS INTE                                   NO-UNDO.
    DEF  VAR aux_cdlcremp AS INTE                                   NO-UNDO.
    DEF  VAR aux_vlemprst AS DECI                                   NO-UNDO.
    DEF  VAR aux_qtparepr AS INTE                                   NO-UNDO.
    DEF  VAR aux_dtlibera AS DATE                                   NO-UNDO.
    DEF  VAR aux_dtdpagto AS DATE                                   NO-UNDO.
    DEF  VAR aux_txcetano AS DECI                                   NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
	
	/* valida o cadastro/alteracao de simulacao de portabilidade para PJ */
	IF par_cddopcao = "A" OR par_cddopcao = "I" THEN
	DO:
	
		FIND LAST crapass WHERE
				  crapass.cdcooper = par_cdcooper   AND
                  crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.
		IF   AVAIL crapass   THEN
		DO:
		
			FIND LAST crapfin WHERE
			          crapfin.cdfinemp = par_cdfinemp AND
					  crapfin.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
			IF   AVAIL crapfin   THEN
			DO:		
				IF crapass.inpessoa = 2 AND crapfin.tpfinali = 2 THEN
				DO:
				
					ASSIGN aux_cdcritic = 0
						   aux_dscritic = "Operação não permitida para conta PJ".

					RUN gera_erro (INPUT par_cdcooper,
								   INPUT par_cdagenci,
								   INPUT par_nrdcaixa,
								   INPUT 1,
								   INPUT aux_cdcritic,
								   INPUT-OUTPUT aux_dscritic).
					RETURN "NOK".				
				END.
			END.	
		END.
	
	END.

    IF   par_cddopcao = "I"   THEN
         DO:
             FIND LAST crapsim WHERE
                       crapsim.cdcooper = par_cdcooper   AND
                       crapsim.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.
             IF   AVAIL crapsim   THEN
                  ASSIGN aux_nrsimula = crapsim.nrsimula + 1.
             ELSE
                  ASSIGN aux_nrsimula = 1.

             RELEASE crapsim.
         END.
    
    IF   par_flgerlog   THEN
         DO:
            ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

            IF   par_cddopcao = "I"   THEN
                 ASSIGN aux_dstransa = "Incluir simulacao de emprestimo " + 
                                       STRING(aux_nrsimula).
            ELSE
                 ASSIGN aux_dstransa = "Alterar simulacao de emprestimo " + 
                                       STRING(par_nrsimula).
         END.

    RUN valida_gravacao_simulacao (INPUT par_cdcooper, 
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nrdconta,
                                   INPUT par_dtmvtolt,
                                   INPUT par_vlemprst,
                                   INPUT par_qtparepr,
                                   INPUT par_cdlcremp,
                                   INPUT par_dtlibera,
                                   INPUT par_dtdpagto,
                                   INPUT par_cddopcao,
                                   INPUT par_nrsimula,
                                   INPUT par_cdfinemp).

    IF   RETURN-VALUE = "NOK"   THEN 
         RETURN "NOK".

    RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET hb1wgen0084.
  
    RUN calcula_emprestimo IN hb1wgen0084  (INPUT  par_cdcooper,  
                                            INPUT  par_cdagenci,  
                                            INPUT  par_nrdcaixa,  
                                            INPUT  par_cdoperad,  
                                            INPUT  par_nmdatela,  
                                            INPUT  par_idorigem,  
                                            INPUT  par_nrdconta,  
                                            INPUT  par_idseqttl,  
                                            INPUT  par_flgerlog,
                                            INPUT  0,
                                            INPUT  par_cdlcremp,  
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
         
    DELETE OBJECT hb1wgen0084.
    
    FIND FIRST tt-parcelas-epr NO-ERROR.
  
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           var_vliofepr = 0.

    /* Apenas carregar valor do IOF para linhas de crédito que estejam habilitadas para isso */
    IF  craplcr.flgtaiof = TRUE AND crapfin.tpfinali <> 2 THEN /* 2 - Portabilidade(408032) */
        DO:
            RUN consulta_iof(INPUT  par_cdcooper,
                             INPUT  par_dtmvtolt,
                             INPUT  par_vlemprst,
                             INPUT  par_nrdconta,
                             INPUT  par_dtdpagto,
                             INPUT  par_qtparepr,
                             INPUT  par_cdlcremp,
                             INPUT  IF AVAIL tt-parcelas-epr THEN 
                                             tt-parcelas-epr.vlparepr
                                    ELSE 0, 
                             INPUT  par_dtlibera,
                             OUTPUT var_vliofepr,
                             OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".
        END.

    RUN consulta_tarifa_emprst(INPUT  par_cdcooper,
                               INPUT  par_cdlcremp,
                               INPUT  par_vlemprst,
                               INPUT  par_nrdconta,
                               OUTPUT var_vlrtarif,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    ASSIGN var_vllibera = par_vlemprst - var_vlrtarif - var_vliofepr.

    /* Criacao ou busca do registro de simulacao */
    IF   par_cddopcao = "I"   THEN
         DO:
             CREATE crapsim.
             ASSIGN crapsim.cdcooper = par_cdcooper
                    crapsim.nrdconta = par_nrdconta
                    crapsim.nrsimula = aux_nrsimula.
         END.
    ELSE
         DO:
             DO   aux_contador = 1 TO 10:
             
                  FIND crapsim WHERE crapsim.cdcooper = par_cdcooper   AND
                                     crapsim.nrdconta = par_nrdconta   AND
                                     crapsim.nrsimula = par_nrsimula   
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  
                  IF   NOT AVAIL crapsim   THEN
                       DO:
                  
                           IF   LOCKED crapsim   THEN
                                DO:
                                   ASSIGN aux_cdcritic = 341
                                          aux_dscritic = "".
                                   NEXT.
                                END.
                           ELSE
                                DO:
                                   ASSIGN aux_cdcritic = 0
                                          aux_dscritic = 
                                              "Registro de simulacao nao " + 
                                              "encontrado.".
                                   
                                   RUN gera_erro (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT 1,
                                                  INPUT aux_cdcritic,
                                                  INPUT-OUTPUT aux_dscritic).
                                   RETURN "NOK".
                                END.
                       END.
                  
                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = "".
                  LEAVE.
         
             END. /* DO   aux_contador = 1 TO 10: */

         END.
    
    IF   aux_cdcritic <> 0 AND aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
         
             RETURN "NOK".
         END.

    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.

    RUN calcula-cet IN h-b1wgen0002 (INPUT par_cdcooper, 
                                     INPUT par_cdagenci, 
                                     INPUT par_nrdcaixa, 
                                     INPUT par_cdoperad, 
                                     INPUT par_nmdatela, 
                                     INPUT par_idorigem, 
                                     INPUT par_dtmvtolt, 
                                
                                     INPUT par_qtparepr, 
                                     INPUT IF AVAIL tt-parcelas-epr THEN 
                                              tt-parcelas-epr.vlparepr 
                                           ELSE 0, 
                                     INPUT var_vllibera,
                                     INPUT par_dtlibera, 
                                     INPUT par_dtdpagto,
                                    OUTPUT aux_txcetano,
                                    OUTPUT TABLE tt-erro).

    ASSIGN par_txcetano = ROUND(aux_txcetano,2).

    IF   par_cddopcao = "A"   THEN
         ASSIGN aux_cdlcremp = crapsim.cdlcremp
                aux_vlemprst = crapsim.vlemprst
                aux_qtparepr = crapsim.qtparepr
                aux_dtlibera = crapsim.dtlibera
                aux_dtdpagto = crapsim.dtdpagto.

    ASSIGN par_nrgravad     = crapsim.nrsimula
           crapsim.cdlcremp = par_cdlcremp
           crapsim.vlemprst = par_vlemprst
           crapsim.qtparepr = par_qtparepr
           crapsim.vlparepr = IF AVAIL tt-parcelas-epr THEN 
                                       tt-parcelas-epr.vlparepr 
                              ELSE 0
           crapsim.dtmvtolt = par_dtmvtolt
           crapsim.dtdpagto = par_dtdpagto
           crapsim.dtlibera = par_dtlibera
           crapsim.txmensal = var_txmensal
           crapsim.txdiaria = var_txdiaria
           crapsim.vliofepr = var_vliofepr
           crapsim.vlrtarif = var_vlrtarif
           crapsim.vllibera = var_vllibera
           crapsim.hrtransa = TIME
           crapsim.percetop = aux_txcetano
           crapsim.cdoperad = par_cdoperad
           crapsim.vlajuepr = var_vlajuepr
           crapsim.cdfinemp = par_cdfinemp
           crapsim.idfiniof = par_idfiniof.

    VALIDATE crapsim.

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
            
            IF  par_cddopcao = "A"   THEN
                DO:
                     IF   aux_cdlcremp <> par_cdlcremp   THEN
                          RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                   INPUT "cdlcremp",
                                                   INPUT aux_cdlcremp,
                                                   INPUT par_cdlcremp).
            
                     IF   aux_vlemprst <> par_vlemprst   THEN
                          RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                   INPUT "vlemprst",
                                                   INPUT aux_vlemprst,
                                                   INPUT par_vlemprst).
            
                     IF   aux_qtparepr <> par_qtparepr   THEN
                          RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                   INPUT "qtparepr",
                                                   INPUT aux_qtparepr,
                                                   INPUT par_qtparepr).
            
                     IF   aux_dtlibera <> par_dtlibera   THEN
                          RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                   INPUT "dtmvtolt",
                                                   INPUT aux_dtlibera,
                                                   INPUT par_dtlibera).
            
                     IF   aux_dtdpagto <> par_dtdpagto   THEN
                          RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                   INPUT "dtdpagto",
                                                   INPUT aux_dtdpagto,
                                                   INPUT par_dtdpagto).
            
                 END. /* IF   par_cddopcao = "A"   THEN */
            
        END. /* IF   par_flgerlog   THEN */

    RETURN "OK".

END PROCEDURE. /* grava_simulacao */

/*****************************************************************************
 Procedure para validar a gravacao de uma simulacao de emprestimo
*****************************************************************************/
PROCEDURE valida_gravacao_simulacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlibera AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrsimula AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    
    DEF  VAR         aux_cdempres AS INTE                           NO-UNDO.
    DEF  VAR         aux_qtdiacar AS INTE                           NO-UNDO.
    DEF  VAR         aux_flgdutil AS LOGI                           NO-UNDO.


    VALIDA:
    DO ON ERROR UNDO, LEAVE:
    
       IF   par_cddopcao = "A"                             AND 
            NOT CAN-FIND(FIRST crapsim WHERE
                         crapsim.cdcooper = par_cdcooper   AND
                         crapsim.nrdconta = par_nrdconta   AND
                         crapsim.nrsimula = par_nrsimula)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Simulacao nao encontrada com"
                                      + " a chave informada".                     
                LEAVE VALIDA.
            END.

       IF   NOT CAN-FIND(crapass WHERE crapass.nrdconta = par_nrdconta    AND
                                       crapass.cdcooper = par_cdcooper)   THEN
            DO:            
                ASSIGN aux_cdcritic = 251
                       aux_dscritic = "".  

                LEAVE VALIDA.
            END.

       IF   par_vlemprst <= 0   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor simulado para o emprestimo nao " +
                                      "informado.".    
                LEAVE VALIDA.
            END.
       
       IF   par_qtparepr <= 0   THEN
            DO:                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Quantidade de parcelas nao informada.".     
                LEAVE VALIDA.
            END.
         
       RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET hb1wgen0084.
                
       RUN valida_novo_calculo IN hb1wgen0084 (INPUT  par_cdcooper,
                                               INPUT  par_cdagenci,
                                               INPUT  par_nrdcaixa,
                                               INPUT  par_qtparepr,
                                               INPUT  par_cdlcremp,
                                               INPUT  FALSE,
                                               OUTPUT TABLE tt-erro).
       
       DELETE OBJECT hb1wgen0084.
       
       IF  RETURN-VALUE <> "OK" THEN
           RETURN "NOK".

       FIND craplcr WHERE
            craplcr.cdcooper = par_cdcooper   AND 
            craplcr.cdlcremp = par_cdlcremp   NO-LOCK NO-ERROR.
       
       IF   NOT AVAIL craplcr   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Linha nao permitida para esse produto".
            
                LEAVE VALIDA.
            END.

       IF   NOT craplcr.flgstlcr   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Linha de credito nao liberada.".
            
                LEAVE VALIDA.
            END.

       /* ******* Novas Validacoes ******* */

       /* Finalidade da operaçao */
       FIND crapfin WHERE crapfin.cdcooper = par_cdcooper   AND
          			      crapfin.cdfinemp = par_cdfinemp
       				      NO-LOCK NO-ERROR.
        
       IF   NOT AVAIL crapfin   THEN
       DO:
             ASSIGN aux_cdcritic = 362.
             LEAVE VALIDA.
       END.
        
       IF   NOT crapfin.flgstfin   THEN
       DO:
            ASSIGN aux_cdcritic = 469.
            LEAVE VALIDA.
       END.
        	 
       FIND craplch WHERE craplch.cdcooper = par_cdcooper AND
        				  craplch.cdfinemp = par_cdfinemp AND
        				  craplch.cdlcrhab = par_cdlcremp
        				  NO-LOCK NO-ERROR.
        
       IF   NOT AVAIL craplch THEN
       DO:
            ASSIGN aux_cdcritic = 364.
            LEAVE VALIDA.
       END.


       /* ************* Fim ************* */


       IF   par_qtparepr < craplcr.nrinipre   OR 
            par_qtparepr > craplcr.nrfimpre   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Quantidade de parcelas acima do permitido " 
                                      + "para linha de credito.".         
                LEAVE VALIDA.

            END.
			
		/* validacao da data de liberacao que agora fica obrigatoria - Portabilidade */	
	   IF  par_dtlibera = ? 
		   THEN
		   DO:
			   ASSIGN aux_cdcritic = 0
					  aux_dscritic = "Informe a data de liberacao".
				
			   LEAVE VALIDA.
            END.

		   
		/* validacao da data de primeiro pagamento que agora fica obrigatoria - Portabilidade */	
	   IF  par_dtdpagto = ? 
		   THEN
		   DO:
			   ASSIGN aux_cdcritic = 0
					  aux_dscritic = "Informe a data de primeiro pagamento".
				
			   LEAVE VALIDA.
		   END.					   
		   
		   
       IF   par_dtlibera < par_dtmvtolt   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de movimento nao pode ser maior que a data de liberacao.".
       
                LEAVE VALIDA.
            END.

       IF   par_dtlibera >= par_dtdpagto   THEN 
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de liberacao de emprestimo igual " +
                                      "ou maior que data de pagamento da "     +
                                      "primeira parcela.".         
                 LEAVE VALIDA.
            END.

       /* Verifica de Data do 1º Pagamento é um dia útil */
       RUN verifica-dia-util (INPUT        par_cdcooper,
                              INPUT        TRUE, /* Feriado  */
                              INPUT-OUTPUT par_dtlibera,
                              OUTPUT       aux_flgdutil ).

       IF   NOT aux_flgdutil THEN
            DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Data de liberação deve ser " +
                                                  "um dia útil. ".            
              LEAVE VALIDA. 
            END.

       IF  par_dtdpagto < par_dtmvtolt   THEN 
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Data de pagamento da primeira parcela " +
                                     "deve ser maior ou igual a data atual.".
            
               LEAVE VALIDA.
           END.

       FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                          craptab.nmsistem = "CRED"       AND
                          craptab.tptabela = "USUARI"     AND
                          craptab.cdempres = 11           AND
                          craptab.cdacesso = "PAREMPREST" AND
                          craptab.tpregist = 01
                          NO-ERROR.
       
       IF  NOT AVAIL craptab THEN
           DO:
               ASSIGN  aux_cdcritic = 55
                       aux_dscritic = "".
               
               LEAVE VALIDA.               
           END.

       IF  par_dtlibera > par_dtmvtolt + INT(SUBSTRING(craptab.dstextab,35,4)) 
           THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Data de liberacao nao deve ser superior"
                                   + " ao prazo maximo de dias parametrizados.".
                
               LEAVE VALIDA.
           END.
    
       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.
      
       IF  NOT AVAIL crapass   THEN
           DO: 
               ASSIGN aux_cdcritic = 9
                      aux_dscritic = "".
       
               LEAVE VALIDA.
           END.
    
       IF  crapass.inpessoa = 1   THEN
           DO:
               FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                  crapttl.nrdconta = par_nrdconta   AND
                                  crapttl.idseqttl = 1
                                  NO-LOCK NO-ERROR.
       
               IF  NOT AVAIL crapttl   THEN
                   DO:           
                       ASSIGN aux_cdcritic = 821
                              aux_dscritic = "".
             
                       LEAVE VALIDA.
                   END.
       
               ASSIGN aux_cdempres = crapttl.cdempres.
       
           END.
       ELSE
           DO:
               FIND crapjur WHERE crapjur.cdcooper = par_cdcooper   AND
                                  crapjur.nrdconta = par_nrdconta
                                  NO-LOCK NO-ERROR.
       
               IF  NOT AVAIL crapjur   THEN
                   DO:
                       ASSIGN aux_cdcritic = 821
                              aux_dscritic = "".
             
                       LEAVE VALIDA.
                   END.
       
               ASSIGN aux_cdempres = crapjur.cdempres.
       
           END.

       ASSIGN aux_qtdiacar = craplcr.qtcarenc.
       
       IF   aux_qtdiacar <> 0   THEN
            DO:
                IF   par_dtdpagto - par_dtlibera > aux_qtdiacar   THEN
                     DO:
                          ASSIGN aux_dscritic = 
                            "Carencia da linha deve ser ate " + 
                              TRIM (STRING(aux_qtdiacar,"zz9")) +
                               " dias." .
                           LEAVE VALIDA.
                     END.                               
            END.
       ELSE 
            DO: /* Temporariamente solicitado para ficar 60 dias
                   Foi mantido o IF e ELSE pois será reavaliado
                   pelo negócio essa carência e será alterado
                   posteriormente */

                IF   DAY(par_dtlibera) <= 19   THEN
                     DO:
                         IF   par_dtdpagto - par_dtlibera > 60   THEN
                              DO:
                                  ASSIGN aux_dscritic = 
                                "Carencia da linha deve ser ate 60" + 
                                " dias." .
                                  LEAVE VALIDA.
                              END. 
                     END.
                ELSE 
                     DO:
                         IF   par_dtdpagto - par_dtlibera > 60   THEN
                              DO:
                                  ASSIGN aux_dscritic = 
                                "Carencia da linha deve ser ate 60" + 
                                " dias." .
                                  LEAVE VALIDA.
                              END. 
                     END.
            END.
    END.

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* valida_gravacao_simulacao */


PROCEDURE imprime_simulacao:
    
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
    DEF  INPUT PARAM par_nrsimula AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nmarquiv          AS CHAR                           NO-UNDO.
    DEF VAR aux_carencia          AS CHAR                           NO-UNDO.
    DEF VAR aux_contador          AS INTE                           NO-UNDO.
    DEF VAR aux_contaesq          AS INTE INIT 1                    NO-UNDO.
    DEF VAR aux_contadir          AS INTE                           NO-UNDO.
    DEF VAR aux_codigesq          AS CHAR                           NO-UNDO.
    DEF VAR aux_datadesq          AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF VAR aux_valoresq          AS CHAR FORMAT "x(18)"            NO-UNDO.
    DEF VAR aux_codigdir          LIKE aux_codigesq                 NO-UNDO.
    DEF VAR aux_dataddir          LIKE aux_datadesq                 NO-UNDO.
    DEF VAR aux_valordir          LIKE aux_valoresq                 NO-UNDO.
    DEF VAR aux_vlrsolic          AS CHAR                           NO-UNDO.
    DEF VAR aux_txmensal          AS CHAR                           NO-UNDO.
    DEF VAR aux_vlparepr          AS CHAR                           NO-UNDO.
    DEF VAR aux_tributos          AS CHAR                           NO-UNDO.
    DEF VAR aux_vlajuepr          AS CHAR                           NO-UNDO.
    DEF VAR aux_vlrtarif          AS CHAR                           NO-UNDO.
    DEF VAR aux_vllibera          AS CHAR                           NO-UNDO.
    DEF VAR aux_percetop          AS DECI FORMAT "zz9.99"           NO-UNDO.
    DEF VAR aux_diapagto          AS INTE                           NO-UNDO.
    DEF VAR aux_mespagto          AS INTE                           NO-UNDO.
    DEF VAR aux_anopagto          AS INTE                           NO-UNDO.
    DEF VAR aux_cdmodali          AS CHAR FORMAT "x(5)"             NO-UNDO.
    DEF VAR aux_lbmodali          AS CHAR FORMAT "x(11)"            NO-UNDO.
    DEF VAR aux_dsmodali          AS CHAR FORMAT "x(45)"            NO-UNDO.

    FORM 
        crapcop.nmextcop FORMAT "X(40)"    AT 01 NO-LABEL
        "-"                                AT 42   
        crapcop.nmrescop FORMAT "X(10)"    AT 44 NO-LABEL
        par_dtmvtolt     FORMAT "99/99/99" AT 55 LABEL "Data Emissao"
        SKIP                                        
        tt-crapsim.nrdconta                AT 01 LABEL "Conta"
        tt-crapsim.nrsimula                AT 26 LABEL "Simulacao"
        tt-crapsim.cdagenci                AT 66 LABEL "Pac" 
        SKIP(2)
        "SIMULACAO DE EMPRESTIMO"          AT 29   
        SKIP(1)
        tt-crapsim.cdfinemp                AT 17 LABEL "Finalidade"
        "-"                                AT 33
        crapfin.dsfinemp                   AT 35 NO-LABEL  
        SKIP(1)
        /* imprime modalidade caso for uma PORTABILIDADE */
        aux_lbmodali                       AT 17 NO-LABEL
        aux_cdmodali                       AT 30 NO-LABEL
        aux_dsmodali                       AT 35 NO-LABEL  
        SKIP(1)
        tt-crapsim.cdlcremp                AT 10
        "-"                                AT 33
        craplcr.dslcremp                   AT 35 NO-LABEL  
        SKIP(1)
        aux_vlrsolic     FORMAT "x(18)"    AT 05 LABEL "Valor Solicitado"
        tt-crapsim.dtlibera                AT 42 LABEL "Data de Liberacao"
        SKIP
        aux_txmensal     FORMAT "x(10)"    AT 10 LABEL "Taxa Mensal"
        aux_vlparepr     FORMAT "x(18)"    AT 45 LABEL "Vl. da Parcela"
        SKIP
        tt-crapsim.qtparepr                AT 05
        aux_carencia                       AT 50 LABEL "*Carencia"
        SKIP
        aux_tributos     FORMAT "x(18)"    AT 13 LABEL "Tributos"
        SKIP
        aux_vlrtarif     FORMAT "x(13)"    AT 15 LABEL "Tarifa"
        SKIP
        aux_vllibera     FORMAT "x(18)"    AT 02 LABEL "Vl.Liquido Liberado"
        aux_percetop                       AT 11 LABEL "CET(%a.a.)"
        SKIP(1)
        WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_cabec.

    FORM aux_codigesq AT 01 FORMAT "X(4)" 
         aux_datadesq AT 06 
         aux_valoresq AT 17 FORMAT "X(18)"

         aux_codigdir AT 41 FORMAT "X(4)" 
         aux_dataddir AT 46
         aux_valordir AT 57
         WITH FRAME f-parcela DOWN NO-LABELS.

    IF   par_dsiduser = "" OR par_dsiduser = ?   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Sessao de usuario nao informada. " + 
                                   "Problema ao gerar arquivos de impressao.".
         
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Imprime simulacao " + 
                               STRING(par_nrsimula).

    RUN busca_dados_simulacao (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT par_flgerlog,
                               INPUT par_nrsimula,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-crapsim,
                               OUTPUT TABLE tt-parcelas-epr).
    
    IF   RETURN-VALUE = "NOK"  THEN
         RETURN "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.

    IF   par_dsiduser <> "" AND par_dsiduser <> ?   THEN
         UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null"). 
    
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           par_nmarqimp = aux_nmarquiv + ".ex"
           par_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_limcre TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 66.
    FOR EACH tt-crapsim:

        FIND craplcr WHERE 
             craplcr.cdcooper = tt-crapsim.cdcooper AND
             craplcr.cdlcremp = tt-crapsim.cdlcremp NO-LOCK NO-ERROR.

        FIND crapfin WHERE 
             crapfin.cdcooper = tt-crapsim.cdcooper AND
             crapfin.cdfinemp = tt-crapsim.cdfinemp NO-LOCK NO-ERROR.

        /* Ajuste de valores exibidos */
        ASSIGN aux_vlrsolic = fnFormataValor("R$ ",
                                             tt-crapsim.vlemprst,
                                             "zzz,zzz,zz9.99",
                                             "")
               aux_txmensal = fnFormataValor("",
                                             tt-crapsim.txmensal,
                                             ">9.99",
                                             " %")
               aux_vlparepr = fnFormataValor("R$ ",
                                             tt-crapsim.vlparepr,
                                             "zzz,zzz,zz9.99",
                                             "")
               aux_tributos = fnFormataValor("R$ ",
                                             tt-crapsim.vliofepr,
                                             "zzz,zzz,zz9.99",
                                             "")
               aux_vlrtarif = fnFormataValor("R$ ",
                                             tt-crapsim.vlrtarif,
                                             ">>>,>>9.99",
                                             "")
               aux_vllibera = fnFormataValor("R$ ",
                                             tt-crapsim.vllibera,
                                             "zzz,zzz,zz9.99",
                                             "")
            
               aux_percetop = tt-crapsim.percetop
            
               aux_diapagto = DAY(tt-crapsim.dtdpagto)

               aux_mespagto = MONTH(tt-crapsim.dtdpagto)
               
               aux_anopagto = YEAR(tt-crapsim.dtdpagto).

               RUN sistema/generico/procedures/b1wgen0084.p 
                   PERSISTENT SET hb1wgen0084.
    
               RUN Dias360 IN hb1wgen0084 
                           (INPUT FALSE,
                            INPUT DAY(tt-crapsim.dtdpagto),
                            INPUT DAY(tt-crapsim.dtlibera),
                            INPUT MONTH(tt-crapsim.dtlibera),
                            INPUT YEAR(tt-crapsim.dtlibera) ,
                            INPUT-OUTPUT aux_diapagto,
                            INPUT-OUTPUT aux_mespagto,
                            INPUT-OUTPUT aux_anopagto,
                           OUTPUT aux_carencia).
                
               DELETE PROCEDURE hb1wgen0084.
    
               aux_carencia = fnFormataValor("",INT(aux_carencia), ">>>9", " dias").


        /* imprime modalidade caso for uma PORTABILIDADE */
        IF tt-crapsim.tpfinali = 2 THEN
        DO:
            ASSIGN aux_lbmodali = "Modalidade:"
                   aux_cdmodali = TRIM(tt-crapsim.cdmodali)
                   aux_dsmodali = "- " + TRIM(tt-crapsim.dsmodali).
        END.
        ELSE
        DO:
            ASSIGN aux_lbmodali = ""
                   aux_cdmodali = ""
                   aux_dsmodali = "".
        END.



        DISPLAY STREAM str_limcre
                crapcop.nmextcop
                crapcop.nmrescop
                par_dtmvtolt
                tt-crapsim.nrdconta
                tt-crapsim.nrsimula
                tt-crapsim.cdagenci
                tt-crapsim.cdfinemp
                crapfin.dsfinemp WHEN AVAIL crapfin
                tt-crapsim.cdlcremp
                craplcr.dslcremp WHEN AVAIL craplcr
                aux_vlrsolic
                tt-crapsim.dtlibera
                aux_txmensal
                aux_vlparepr
                tt-crapsim.qtparepr
                aux_carencia
                aux_tributos
                aux_vlrtarif
                aux_vllibera
                aux_percetop
                aux_cdmodali
                aux_lbmodali
                aux_dsmodali
                WITH FRAME f_cabec.
                                     
        PUT STREAM str_limcre "PARCELAS" AT 01 SKIP.

        ASSIGN aux_contadir = INT(tt-crapsim.qtparepr / 2) + 1.

        DO    aux_contador = 1 TO tt-crapsim.qtparepr:

              IF aux_contador MOD 2 = 1 THEN DO:
                  FIND tt-parcelas-epr WHERE 
                       tt-parcelas-epr.nrparepr = aux_contaesq NO-ERROR.
                  ASSIGN aux_contaesq = aux_contaesq + 1.
              END.
              ELSE DO:
                  FIND tt-parcelas-epr WHERE 
                       tt-parcelas-epr.nrparepr = aux_contadir NO-ERROR.
                  ASSIGN aux_contadir = aux_contadir + 1.
              END.
        
              IF NOT AVAIL tt-parcelas-epr THEN LEAVE.

              ASSIGN 
                  aux_codigesq = fnFormataValor("",
                                                DEC(tt-parcelas-epr.nrparepr),
                                                ">>9",
                                                ") ")
                  aux_valoresq = fnFormataValor("R$ ",
                                                tt-parcelas-epr.vlparepr,
                                                "zzz,zzz,zz9.99",
                                                "")
                  aux_codigdir = fnFormataValor("",
                                                DEC(tt-parcelas-epr.nrparepr),
                                                ">>9",
                                                ") ")
                  aux_valordir = fnFormataValor("R$ ",
                                                tt-parcelas-epr.vlparepr,
                                                "zzz,zzz,zz9.99",
                                                "").
        
              IF aux_contador MOD 2 = 1 THEN
                  DISP STREAM str_limcre
                       aux_codigesq
                       tt-parcelas-epr.dtparepr @ aux_datadesq
                       aux_valoresq
                       WITH FRAME f-parcela.
              ELSE DO:
                  DISP STREAM str_limcre
                       aux_codigdir
                       tt-parcelas-epr.dtparepr @ aux_dataddir
                       aux_valordir 
                       WITH FRAME f-parcela.
                  DOWN STREAM str_limcre WITH FRAME f-parcela.
              END.

        END. /* DO    aux_contador = 1 TO tt-crapsim.qtparepr: */

    END.

    PUT STREAM str_limcre UNFORMATTED  
        SKIP(2)
        "Esta simulacao nao vale como proposta,  e apenas uma ferramenta " +
        "para auxiliar na" SKIP
        "sua decisao.  A taxa utilizada,  as tarifas e eventuais despesas " + 
        "podem variar de" SKIP
        "acordo  com  o  perfil  do  cooperado  e  as  caracteristicas  de  " + 
        "cada produto." SKIP
        "A efetivacao  do  emprestimo/financiamento esta sujeita  a analise " +
        "e a aprovacao" SKIP
        "de credito.".

    PUT STREAM str_limcre UNFORMATTED
        SKIP(2)
        "*Para efeito de calculo todos os meses sao considerados com 30 dias.".

    OUTPUT STREAM str_limcre CLOSE.

    IF   par_idorigem = 5   THEN  /** Ayllos Web **/
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            Bloco_Imprime: 
            DO   WHILE TRUE:
                 RUN sistema/generico/procedures/b1wgen0024.p 
                                                PERSISTENT SET hb1wgen0024.
            
                 IF   NOT VALID-HANDLE(hb1wgen0024)   THEN
                      DO:
                          ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                "b1wgen0024.".
                          LEAVE Bloco_Imprime.
                      END.
                      
                 RUN gera-pdf-impressao IN hb1wgen0024 (INPUT par_nmarqimp,
                                                        INPUT par_nmarqpdf).
                 
                 IF   SEARCH(par_nmarqpdf) = ?   THEN
                      DO:
                          ASSIGN aux_dscritic = "Nao foi possivel gerar " + 
                                                "a impressao.".
                          LEAVE BLoco_Imprime.
                      END.
                      
                 
                 UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                      '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra 
                      + ':/var/www/ayllos/documentos/' + crapcop.dsdircop 
                      + '/temp/" 2>/dev/null').
                 
                 LEAVE Bloco_Imprime.
            END. /** Fim do DO WHILE TRUE **/

            IF   VALID-HANDLE(hb1wgen0024)   THEN
                 DELETE OBJECT hb1wgen0024.
            
         END.
    ELSE
         DO:
             IF   par_dsiduser <> "" AND par_dsiduser <> ?   THEN
                  UNIX SILENT VALUE ("rm " + par_nmarqpdf + " 2>/dev/null").
         END.

    ASSIGN par_nmarqpdf = 
               ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/").
         
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

END PROCEDURE.
/* ..........................................................................*/

/*****************************************************************************
 Procedure para validar a gravacao de uma simulacao de emprestimo
*****************************************************************************/
PROCEDURE valida_simulacao:

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
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.
    /*
    IF   NOT CAN-DO ("14,18,20",STRING(par_cddepart))  THEN
        ASSIGN aux_cdcritic = 36.
    */
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
END.
/* ..........................................................................*/

/*****************************************************************************
            PROCEDURE para verificar se o dia é útil ou não.
*****************************************************************************/
PROCEDURE verifica-dia-util:

    DEF INPUT        PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF INPUT        PARAM par_flgferia AS LOGI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dtdiacal AS DATE                     NO-UNDO.
    DEF OUTPUT       PARAM par_flgdutil AS LOGI                     NO-UNDO.

    IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtdiacal)))              OR
       (par_flgferia                                             AND
        CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                               crapfer.dtferiad = par_dtdiacal)) THEN

         ASSIGN par_flgdutil = FALSE. /* Não é dia útil */
    ELSE
         ASSIGN par_flgdutil = TRUE.  /* É dia útil */
                    
    RETURN "OK".

END.

/*****************************************************************************
*                           PROCEDURE consulta IOF                           *
******************************************************************************/
PROCEDURE consulta_iof:
    
    DEF INPUT        PARAM par_cdcooper AS INT                      NO-UNDO.
    DEF INPUT        PARAM par_dtmvtolt AS DATE                     NO-UNDO.
    DEF INPUT        PARAM par_vlemprst AS DEC                      NO-UNDO.
    DEF INPUT        PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF INPUT        PARAM par_dtdpagto AS DATE                     NO-UNDO.
    DEF INPUT        PARAM par_qtpreemp AS INTE                     NO-UNDO.
    DEF INPUT        PARAM par_cdlcremp AS INTEGER                  NO-UNDO.
    DEF INPUT        PARAM par_vlpreemp AS DECI                     NO-UNDO.
    DEF INPUT        PARAM par_dtlibera AS DATE                     NO-UNDO.
    DEF OUTPUT       PARAM par_vliofepr AS DEC                      NO-UNDO.        
    DEF OUTPUT       PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_inpessoa AS INTEGER INIT 0                          NO-UNDO.
    
    FOR FIRST crapass FIELDS(inpessoa)
                      WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta
                            NO-LOCK: END.
    
    IF AVAILABLE crapass THEN
       ASSIGN aux_inpessoa = crapass.inpessoa.
       
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_calcula_iof_epr
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_dtmvtolt,
                                          INPUT aux_inpessoa,
                                          INPUT par_cdlcremp,
                                          INPUT par_qtpreemp,
                                          INPUT par_vlpreemp,
                                          INPUT par_vlemprst,
                                          INPUT par_dtdpagto,
                                          INPUT par_dtlibera,
                                          INPUT 1, /* tpemprst -> 1-PP */
                                         OUTPUT 0,
                                         OUTPUT "").
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_calcula_iof_epr
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_vliofepr = pc_calcula_iof_epr.pr_valoriof
                             WHEN pc_calcula_iof_epr.pr_valoriof <> ?           
           aux_dscritic = pc_calcula_iof_epr.pr_dscritic
                             WHEN pc_calcula_iof_epr.pr_dscritic <> ?.
 
    IF aux_dscritic <> "" THEN
       DO:
           ASSIGN aux_cdcritic = 0.
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 1,
                          INPUT 1,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
					RETURN "NOK".	
       END.    
          
    RETURN "OK".
    
END.

/*****************************************************************************
*             PROCEDURE Consulta tarifa do contrato do emprestimo            *
******************************************************************************/
PROCEDURE consulta_tarifa_emprst:
    
    DEF INPUT        PARAM par_cdcooper AS INT                      NO-UNDO.
    DEF INPUT        PARAM par_cdlcremp AS INT                      NO-UNDO.
    DEF INPUT        PARAM par_vlemprst AS DEC                      NO-UNDO.
    DEF INPUT        PARAM par_nrdconta AS INT                      NO-UNDO.    
    DEF OUTPUT       PARAM par_vlrtarif AS DEC                      NO-UNDO.

    DEF OUTPUT       PARAM TABLE FOR tt-erro.
    
    DEF VAR                tab_dstextab AS CHAR                     NO-UNDO.
    DEF VAR                aux_vltrfesp AS DEC                      NO-UNDO.
    DEF VAR                aux_chaveate AS INTE                     NO-UNDO.
    DEF VAR                aux_chavetar AS INTE                     NO-UNDO.
    DEF VAR                aux_valorate AS DECI                     NO-UNDO. 
    DEF VAR                aux_contador AS INTE                     NO-UNDO.

    DEF        VAR h-b1wgen0153         AS HANDLE                   NO-UNDO.

    DEF        VAR aux_cdbattar         AS CHAR                     NO-UNDO.
    DEF        VAR aux_cdhisest         AS INTE                     NO-UNDO.
    DEF        VAR aux_dtdivulg         AS DATE                     NO-UNDO.
    DEF        VAR aux_dtvigenc         AS DATE                     NO-UNDO.
    DEF        VAR aux_cdhistor         AS INTE                     NO-UNDO.
    DEF        VAR aux_cdfvlcop         AS INTE                     NO-UNDO.
    DEF        VAR aux_taravali         AS INTE                     NO-UNDO.
    DEF        VAR aux_inpessoa         AS INTE                     NO-UNDO.

    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                       craplcr.cdlcremp = par_cdlcremp
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplcr THEN
        DO:
            aux_cdcritic = 363.
            RETURN "NOK".
        END.
/*
    IF  craplcr.vltrfesp > 0 THEN
        aux_vltrfesp = craplcr.vltrfesp.

    IF  craplcr.flgtarif THEN
        DO: 
           FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND
                              craptab.nmsistem = "CRED"             AND
                              craptab.tptabela = "USUARI"           AND
                              craptab.cdempres = 11                 AND
                              craptab.cdacesso = "TRFACTREMP"       AND
                              craptab.tpregist = 1
                              USE-INDEX craptab1 NO-LOCK NO-ERROR.
      
           IF   NOT AVAILABLE craptab   THEN
                DO:
                    ASSIGN aux_cdcritic = 487.                             
                    RETURN "NOK".
                END.
           
           ASSIGN tab_dstextab = craptab.dstextab      
                  aux_chaveate = -1
                  aux_chavetar =  0.
                    
           /* Obter o valor da tarifa dependendo do valor do emprestimo */
           DO aux_contador = 1 TO 10:

              ASSIGN aux_chavetar = aux_chavetar + 2 /* Chave tarifa */
                     aux_chaveate = aux_chaveate + 2 /* Chave faixa ate */
                     aux_valorate = 
                          DECIMAL(ENTRY(aux_chaveate,tab_dstextab,"#"))
                     par_vlrtarif = 
                          DECIMAL(ENTRY(aux_chavetar,tab_dstextab,"#"))
                             NO-ERROR.

                /* Se valor da tarifa eh >= ao do emprestimo ou */
                /* Se chegou na ultima faixa ou  */
                /* Se nao existe a faixa */
                IF   aux_valorate >= par_vlemprst       OR 
                     aux_contador = 10                  OR 
                     ERROR-STATUS:ERROR                 THEN
                     DO:
                         /* Se deu erro, pegar a anterior */
                         IF   ERROR-STATUS:ERROR    THEN
                              DO:
                                  ASSIGN aux_chavetar = aux_chavetar - 2
                                         par_vlrtarif = 
                               DECIMAL(ENTRY(aux_chavetar , tab_dstextab ,"#")).
                              END.
                         LEAVE.
                     END.
           END.   */

           ASSIGN aux_inpessoa = 1. /* Fisica */ 

           FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                              crapass.nrdconta = par_nrdconta
                              NO-LOCK NO-ERROR .

           /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
           IF AVAIL crapass THEN
           DO:
               ASSIGN aux_inpessoa = crapass.inpessoa. /* 
               IF crapass.inpessoa = 1 THEN /* Fisica */
                    ASSIGN aux_cdbattar = "FINANCIAPF".
               ELSE
                    ASSIGN aux_cdbattar = "FINANCIAPJ". 
           END.
           ELSE
               ASSIGN aux_cdbattar = "FINANCIAPJ".      */
           END.
            
           IF NOT VALID-HANDLE(h-b1wgen0153) THEN
               RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

           IF  craplcr.cdusolcr = 1 THEN DO:

                IF  aux_inpessoa = 1 THEN
                    aux_cdbattar = "MICROCREPF".
                ELSE
                    aux_cdbattar = "MICROCREPJ".
    
                RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                (INPUT  par_cdcooper,
                                                 INPUT  aux_cdbattar,       
                                                 INPUT  par_vlemprst,
                                                 INPUT  "", /* cdprogra */
                                                 OUTPUT aux_cdhistor,
                                                 OUTPUT aux_cdhisest,
                                                 OUTPUT par_vlrtarif,
                                                 OUTPUT aux_dtdivulg,
                                                 OUTPUT aux_dtvigenc,
                                                 OUTPUT aux_cdfvlcop,
                                                 OUTPUT TABLE tt-erro).
    
           END.
           ELSE DO:

               RUN carrega_dados_tarifa_emprestimo IN h-b1wgen0153
                                                  (INPUT  par_cdcooper,
                                                   INPUT  par_cdlcremp,
                                                   INPUT  "EM",
                                                   INPUT  aux_inpessoa,
                                                   INPUT  par_vlemprst,
                                                   INPUT  "", /* cdprogra */
                                                   OUTPUT aux_cdhistor,
                                                   OUTPUT aux_cdhisest,
                                                   OUTPUT par_vlrtarif,
                                                   OUTPUT aux_dtdivulg,
                                                   OUTPUT aux_dtvigenc,
                                                   OUTPUT aux_cdfvlcop,
                                                   OUTPUT TABLE tt-erro).

           
               RUN carrega_dados_tarifa_emprestimo IN h-b1wgen0153
                                                  (INPUT  par_cdcooper,
                                                   INPUT  par_cdlcremp,
                                                   INPUT  "ES",
                                                   INPUT  aux_inpessoa,
                                                   INPUT  par_vlemprst,
                                                   INPUT  "", /* cdprogra */
                                                   OUTPUT aux_cdhistor,
                                                   OUTPUT aux_cdhisest,
                                                   OUTPUT aux_vltrfesp,
                                                   OUTPUT aux_dtdivulg,
                                                   OUTPUT aux_dtvigenc,
                                                   OUTPUT aux_cdfvlcop,
                                                   OUTPUT TABLE tt-erro).
           END.

           IF  VALID-HANDLE(h-b1wgen0153)  THEN
                DELETE PROCEDURE h-b1wgen0153.
            
           IF  RETURN-VALUE = "NOK"  THEN
                RETURN "NOK".

           IF ( craplcr.tpctrato = 2 ) OR       /* Avaliacao de garantia de bem movel */
              ( craplcr.tpctrato = 3 ) THEN     /* Avaliacao de garantia de bem imovel */
           DO:
                /* Assume pessoa fisica quando nao encontrar registro na crapass. */
                ASSIGN aux_inpessoa = 1.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF AVAIL crapass THEN
                    ASSIGN aux_inpessoa = crapass.inpessoa.

                IF craplcr.tpctrato = 2 THEN    
                    DO:
                        /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
                        IF aux_inpessoa = 1 THEN /* Fisica */
                            ASSIGN aux_cdbattar = "AVALBMOVPF".
                        ELSE
                            ASSIGN aux_cdbattar = "AVALBMOVPJ".

                    END.
                ELSE                            
                    DO:
                        IF aux_inpessoa = 1 THEN /* Fisica */
                            ASSIGN aux_cdbattar = "AVALBIMVPF".
                        ELSE
                            ASSIGN aux_cdbattar = "AVALBIMVPJ".
                    END.
            
                IF NOT VALID-HANDLE(h-b1wgen0153) THEN
                    RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

                /*  Busca valor da tarifa de Emprestimo pessoa fisica*/
                RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                (INPUT par_cdcooper,
                                                 INPUT  aux_cdbattar,       
                                                 INPUT  par_vlemprst,                 
                                                 INPUT  "", /* cdprogra */
                                                 OUTPUT aux_cdhistor,
                                                 OUTPUT aux_cdhisest,
                                                 OUTPUT aux_taravali,
                                                 OUTPUT aux_dtdivulg,
                                                 OUTPUT aux_dtvigenc,
                                                 OUTPUT aux_cdfvlcop,
                                                 OUTPUT TABLE tt-erro).

                IF  VALID-HANDLE(h-b1wgen0153)  THEN
                    DELETE PROCEDURE h-b1wgen0153.

                IF  RETURN-VALUE = "NOK"  THEN
                    RETURN "NOK".

           END.
/*      END.
    ELSE
    DO:
        par_vlrtarif = 0.
        aux_taravali = 0.        
    END.
*/    
    par_vlrtarif = par_vlrtarif + aux_vltrfesp + aux_taravali.

    RETURN "OK".
END.

/* ......................................................................... */

