
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | b1wgen0153.p	                 | TARI0001                               |
  |  carrega_dados_tarifa_cobranca   |  .pc_carrega_dados_tarifa_cobr         |
  |  cria_lan_auto_tarifa            |  .pc_cria_lan_auto_tarifa              |
  |  carrega_dados_tarifa_vigente    |  .pc_carrega_dados_tarifa_vigente      |
  |  lan-tarifa-online               |  .pc_lan_tarifa_online                 |
  |  lan-tarifa-conta-corrente       |  .pc_lan_tafifa_conta_corrente         | 
  |  carrega_dados_tarifa_emprestimo |  .pc_carrega_dados_tarifa_empr         |  
  |  carrega_par_tarifa_vigente      |  .pc_carrega_par_tarifa_vigente        |
  +---------------------------------+-----------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/








/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0153.p
    Autor   : Tiago Machado/Daniel Zimmermann
    Data    : Fevereiro/2013                Ultima Atualizacao: 14/11/2018
    Dados referentes ao programa:
   
    Objetivo  : BO referente ao projeto tarifas
                 
    Alteracoes: 24/07/2013 - Retirado na leitura crapfco a verificacao da cdcooper 
                             na procedure rel-receita-tarifas (Daniel).

                02/08/2013 - Alteracoes na parte de cobranca nos cadastros e
                             buscas da cadtar(web) (Tiago).  
                             
                21/08/2013 - Incluso novo parametro na procedure 'buscar-cadtar'
                            (Daniel).         
                            
                23/08/2013 - Criada procedure carrega_dados_tarifa_emprestimo
                             (Tiago).            
                             
                26/08/2013 - Criado registro linha padrao na procedure
                             lista-linhas-credito (Tiago).             
                             
                03/10/2013 - Refeito a logica da procedure
                             carrega-atribuicao-detalhamento (Rodrigo/ Tiago).
                             
                10/10/2013 - Incluido parametro cdprogra nas procedures da 
                             b1wgen0153 que carregam dados de tarifas (Tiago).
                             
                28/10/2013 - Incluso na procedure carrega_dados_tarifa_cobranca 
                             novo processo de busca tarifa na craptar usando 
                             fixo cdmotivo = "00" (Daniel).     

                13/08/2013 - Nova forma de chamar as agências, alterado para
                             "Posto de Atendimento" (PA). (André Santos - SUPERO) 
                             
                14/11/2013 - Fixado valor do campo crapfco.flgvigen para FALSE na
                             inclusao e alteracao de registro (Daniel).
                             
                02/12/2013 - Fixado utilixacao filtro crapfvl quando utilizar
                             chave cdtarifa (Daniel).           
                             
                05/02/2014 - Tratamento para não dar erro de tarifa caso a
                             coop. não estiver ativa (crapcop.flgativo) (Lucas).
                
                12/02/2014 - Retirado condicao "craplcr.flgstlcr = TRUE" dos FINDs 
                             da craplcr (Tiago)
                             
                05/03/2014 - Incluso validate (Daniel).        
                
                24/03/2014 - Retirar FIND FIRST desnecessario. 
                             Retirar tratamento de sequencia da craplat.
                             (Gabriel).      
                
                05/05/2014 - Remoção de erro inserido no log e inclusão de 
                             funcionamento de envio de email com o erro, 
                             "solicitar_envio_email". (Jaison - SF: 142671)
                             
                16/05/2014 - Inclusão de verificacao de nmdatela para procedure
                             lista-cooperativas. (Jean Michel - Projeto Cartões)
                             
                21/01/2015 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                25/03/2015 - Inserido condicao para quando buscar coops
                             verificar se esta ativa (Tiago).
                             
                05/04/2015 - Adicionado parametro de cdprodut em procedures
                             envolvidos na tela CADPAR.
                             Criado proce. geralog_cadpar.
                             (Jorge/Rodrigo)            
                             
                14/08/2015 - Criacao do campo nmoperad na TEMP-TABLE de retorno
                             da procedure carrega-atribuicao-detalhamento
                             Projeto Melhorias Tarifas (Carlos Rafael Tanholi)
                             
                01/09/2015 - Criacao da procedure lista-fvl-tarifa e
                             incluir-lista-cadfco para o Projeto Melhorias 
                             Tarifas. (Jaison/Diego)
                             
                28/09/2015 - Ajustado rotina estorno-baixa-tarifa para quando retornar 
                             critica dar undo tbm nas alteracoes da craplat.
                             incluido logs das acoes de estorno e baixa das tarifas.
                             SD338081 (Odirlei-AMcom)             
                             
                26/11/2015 - Ajustando a lista de convenios para exibir os convenios
                             do servico de folha de pagamento.
                             (Andre Santos - SUPERO)

                08/01/2015 - Alterado procedimento solicitar_envio_email para chamar
                             a rotina convertida na b1wgen0011.p 
                             SD356863 (Odirlei-AMcom)
                             
               15/02/2016 - Chamada da pc_carrega_dados_tarifa_cobr do Oracle
                            na carrega_dados_tarifa_cobranca. (Jaison/Marcos)

               16/02/2016 - Migraçao das rotinas da CADCAT para Oracle. (Dionathan)

                01/03/2016 - Incluido log de monitoramento de lote em uso para TED.
                             Odirlei-AMcom

				08/03/2016 - Inclusao da procedure consulta-pacotes-tarifas,
                             Prj. 218 - Pacotes de Tarifas (Jean Michel).
				
				14/04/2016 - Alterada procedure buscar-cadtar para buscar também
							 o campo flutlpct. Prj. 218 - Pacotes de Tarifas (Lombardi).
							        
                17/04/2017 - Alterar for each com last-off por find last na busca-novo-cdfvlcop
                            (Lucas Ranghetti #633002)

				11/07/2017 - Melhoria 150 - Tarifação de operações de crédito por percentual

                07/11/2017 - Adicionados campos para comportar o cadastro de 
                             tarifas por porcentual na ALTTAR.
                             Everton (Mouts) - Melhoria 150.
			   
                21/11/2017 - Setado ordenacao na tabela crapcop na procedure carrega-atribuicao-detalhamento
                             pois estava pegando um indice diferente alterando o resultado em tela
                            (Tiago #782313) 
                            
                19/03/2018 - Procedure lista-tipo-conta deletada pois nao sera mais usada. 
                             Alteracao para buscar descricao do tipo de conta do Oracle.
                             PRJ366 (Lombardi).
                10/05/2018 - Incluido o tratamento de estorno e geração da tarifa quando for suspensão de tarifa.
                             Projeto Debitador Unico -- Josiane Stiehler (AMcom)

				26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

                08/06/2018  PRJ450 - Centralizaçao do lançamento em conta corrente Rangel Decker  AMcom.

............................................................................*/

{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0153tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1cabrelvar.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0200tt.i }


DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_dsemail AS CHAR INITIAL "tarifas@ailos.coop.br"            NO-UNDO.
DEF VAR aux_dsassunto AS CHAR                                          NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dslogpar AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dstipcta AS CHAR                                           NO-UNDO.
DEF VAR aux_des_erro AS CHAR                                           NO-UNDO.

DEF STREAM str_1.

/********************  Verifica campo Numerico  *****************************/
FUNCTION f_numericos RETURN LOGICAL(INPUT par_conteudo AS CHAR):
  
  DEF VAR aux_contador AS INT                                   NO-UNDO.

  DEF VAR aux_algarismos AS CHAR                                NO-UNDO.
  ASSIGN aux_algarismos = "0,1,2,3,4,5,6,7,8,9".

  IF   par_conteudo = " "  THEN
       RETURN FALSE.
  ELSE
       DO:
           DO   aux_contador = 1 TO LENGTH(par_conteudo):
                IF   NOT(CAN-DO(aux_algarismos,
                                SUBSTR(par_conteudo,aux_contador,1)))  THEN 
                     RETURN FALSE.
           END.
       END.
END. /* FUNCTION */


/******************************************************************************
 Listagem de Grupos
******************************************************************************/
PROCEDURE lista-grupos:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsdgrupo AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-grupos.

    DEF VAR aux_nrregist AS INT.
                            
    DO ON ERROR UNDO, LEAVE:
        
        EMPTY TEMP-TABLE tt-grupos.
    
        ASSIGN aux_nrregist = par_nrregist.
        
        FOR EACH crapgru NO-LOCK WHERE crapgru.cddgrupo >= par_cddgrupo AND
                                       crapgru.dsdgrupo MATCHES('*' + par_dsdgrupo + '*')
                                       BY crapgru.cddgrupo:

            ASSIGN par_qtregist = par_qtregist + 1.
    
            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.
    
            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-grupos.
                    ASSIGN tt-grupos.cddgrupo = crapgru.cddgrupo
                           tt-grupos.dsdgrupo = crapgru.dsdgrupo.
                END.
    
            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Inclusao de Grupos
******************************************************************************/
PROCEDURE incluir-cadgru:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsdgrupo AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapgru WHERE crapgru.cddgrupo = par_cddgrupo NO-LOCK NO-ERROR.

    IF  AVAIL(crapgru) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    CREATE crapgru.
    ASSIGN crapgru.cddgrupo = par_cddgrupo
           crapgru.dsdgrupo = par_dsdgrupo.
    VALIDATE crapgru.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao de Grupos
******************************************************************************/
PROCEDURE excluir-cadgru:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    FIND FIRST crapsgr WHERE crapsgr.cddgrupo = par_cddgrupo NO-LOCK NO-ERROR.

    IF AVAIL crapsgr THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Grupo vinculada a um sub-grupo!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    DO aux_contador = 1 TO 10:

        FIND crapgru WHERE crapgru.cddgrupo = par_cddgrupo EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapgru THEN
			DO:
				IF  LOCKED crapgru THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   DELETE crapgru.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Alteracao de Grupos
******************************************************************************/
PROCEDURE alterar-cadgru:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsdgrupo AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crapgru WHERE crapgru.cddgrupo = par_cddgrupo EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapgru THEN
			DO:
				IF  LOCKED crapgru THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN crapgru.cddgrupo = par_cddgrupo
                      crapgru.dsdgrupo = par_dsdgrupo.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Buscar de Grupos
******************************************************************************/
PROCEDURE buscar-cadgru:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dsdgrupo AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapgru WHERE crapgru.cddgrupo = par_cddgrupo NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapgru) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Grupo inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    par_dsdgrupo = crapgru.dsdgrupo.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapgru
******************************************************************************/
PROCEDURE busca-novo-cddgrupo:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cddgrupo AS INTE                   NO-UNDO.

    FIND LAST crapgru NO-LOCK NO-ERROR.

    IF  AVAIL(crapgru) THEN
        DO:
            par_cddgrupo = crapgru.cddgrupo + 1.
        END.
    ELSE
        DO:
            par_cddgrupo = 1.
        END.

END PROCEDURE.

/****************************************************************************/
/*                        Tela Cadint                                      */
/***************************************************************************/

/******************************************************************************
 Listagem de Tipo de Incidencia
******************************************************************************/
PROCEDURE lista-int:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-cadint.

    DEF VAR aux_nrregist AS INT.

    DO ON ERROR UNDO, LEAVE:
    

        EMPTY TEMP-TABLE tt-cadint.
    
        ASSIGN aux_nrregist = par_nrregist.
    
        FOR EACH crapint NO-LOCK BY crapint.cdinctar:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    CREATE tt-cadint.
                    ASSIGN tt-cadint.cdinctar = crapint.cdinctar
                           tt-cadint.dsinctar = crapint.dsinctar
                           tt-cadint.flgocorr = crapint.flgocorr
                           tt-cadint.flgmotiv = crapint.flgmotiv
                           aux_nrregist = aux_nrregist + 1.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Inclusao de Tipo de Ocorrencia
******************************************************************************/
PROCEDURE incluir-cadint:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsinctar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgocorr AS LOG                     NO-UNDO.
    DEF INPUT PARAM par_flgmotiv AS LOG                     NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapint WHERE crapint.cdinctar = par_cdinctar NO-LOCK NO-ERROR.

    IF  AVAIL(crapint) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    CREATE crapint.
    ASSIGN crapint.cdinctar = par_cdinctar
           crapint.dsinctar = par_dsinctar
           crapint.flgocorr = par_flgocorr
           crapint.flgmotiv = par_flgmotiv.
    VALIDATE crapint.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao de Tipo de Incidencia
******************************************************************************/
PROCEDURE excluir-cadint:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    FIND FIRST craptar WHERE craptar.cdinctar = par_cdinctar NO-LOCK NO-ERROR.

    IF AVAIL craptar THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Tipo de Incidencia vinculada a uma tarifa!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    DO aux_contador = 1 TO 10:

        FIND crapint WHERE crapint.cdinctar = par_cdinctar EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapint THEN
			DO:
				IF  LOCKED crapint THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   DELETE crapint.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Alteracao de Tipo de Incidencia
******************************************************************************/
PROCEDURE alterar-cadint:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsinctar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgocorr AS LOG                     NO-UNDO.
    DEF INPUT PARAM par_flgmotiv AS LOG                     NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crapint WHERE crapint.cdinctar = par_cdinctar EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapint THEN
			DO:
				IF  LOCKED crapint THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN crapint.cdinctar = par_cdinctar
                      crapint.dsinctar = par_dsinctar
                      crapint.flgocorr = par_flgocorr
                      crapint.flgmotiv = par_flgmotiv.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca de Tipos de Incidencias
******************************************************************************/
PROCEDURE buscar-cadint:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dsinctar AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_flgocorr AS LOG                    NO-UNDO.
    DEF OUTPUT PARAM par_flgmotiv AS LOG                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    IF  par_cdinctar = 0 THEN
        RETURN "OK".

    FIND crapint WHERE crapint.cdinctar = par_cdinctar NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapint) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_dsinctar = crapint.dsinctar
           par_flgocorr = crapint.flgocorr
           par_flgmotiv = crapint.flgmotiv.

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Busca de novo codigo crapint
******************************************************************************/
PROCEDURE busca-novo-cdinctar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdinctar AS INTE                   NO-UNDO.

    FIND LAST crapint NO-LOCK NO-ERROR.

    IF  AVAIL(crapint) THEN
        DO:
            par_cdinctar = crapint.cdinctar + 1.
        END.
    ELSE
        DO:
            par_cdinctar = 1.
        END.

END PROCEDURE.


/******************************************************************************
                             SUBGRUPOS
*******************************************************************************/

/******************************************************************************
 Listagem de SubGrupos
******************************************************************************/
PROCEDURE lista-subgrupos:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dssubgru AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-subgrupos.

    DEF VAR aux_nrregist AS INT.

    DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-subgrupos.
    
        ASSIGN aux_nrregist = par_nrregist.
    
        IF  par_cddgrupo > 0 THEN
            DO:
                FOR EACH crapsgr NO-LOCK WHERE crapsgr.cddgrupo = par_cddgrupo  AND
                                               crapsgr.cdsubgru >= par_cdsubgru AND
                                               crapsgr.dssubgru MATCHES('*' + par_dssubgru + '*')
                                               BY crapsgr.cddgrupo:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* Controles da Paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-subgrupos.
                            ASSIGN tt-subgrupos.cdsubgru = crapsgr.cdsubgru
                                   tt-subgrupos.dssubgru = crapsgr.dssubgru
                                   tt-subgrupos.cddgrupo = crapsgr.cddgrupo.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
    
            END.
        ELSE
            DO:
                FOR EACH crapsgr NO-LOCK WHERE crapsgr.cdsubgru >= par_cdsubgru AND
                                               crapsgr.dssubgru MATCHES('*' + par_dssubgru + '*')
                                               BY crapsgr.cddgrupo:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* Controles da Paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-subgrupos.
                            ASSIGN tt-subgrupos.cdsubgru = crapsgr.cdsubgru
                                   tt-subgrupos.dssubgru = crapsgr.dssubgru
                                   tt-subgrupos.cddgrupo = crapsgr.cddgrupo.
                        END.

                        ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
        
            END.

    END.
    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Busca de Sub-grupo
******************************************************************************/
PROCEDURE buscar-cadsgr:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cddgrupo AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_dsdgrupo AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_dssubgru AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapsgr WHERE crapsgr.cdsubgru = par_cdsubgru NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(crapsgr) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Sub-Grupo inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND crapgru WHERE crapgru.cddgrupo = crapsgr.cddgrupo NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapgru) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Grupo inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_cddgrupo = crapsgr.cddgrupo
           par_dssubgru = crapsgr.dssubgru
           par_dsdgrupo = crapgru.dsdgrupo.

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Busca de novo codigo crapsgr
******************************************************************************/
PROCEDURE busca-novo-cdsubgru:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdsubgru AS INTE                   NO-UNDO.

    FIND LAST crapsgr NO-LOCK NO-ERROR.

    IF  AVAIL(crapsgr) THEN
        DO:
            par_cdsubgru = crapsgr.cdsubgru + 1.
        END.
    ELSE
        DO:
            par_cdsubgru = 1.
        END.

END PROCEDURE.

/******************************************************************************
 Inclusao de Sub-grupo
******************************************************************************/
PROCEDURE incluir-cadsgr:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dssubgru AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapsgr WHERE crapsgr.cdsubgru = par_cdsubgru NO-LOCK NO-ERROR.

    IF  AVAIL(crapsgr) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE crapsgr.
    ASSIGN crapsgr.cdsubgru = par_cdsubgru
           crapsgr.dssubgru = par_dssubgru
           crapsgr.cddgrupo = par_cddgrupo.
    VALIDATE crapsgr.
           

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Exclusao de SubGrupo
******************************************************************************/
PROCEDURE excluir-cadsgr:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    FIND FIRST craptar WHERE craptar.cdsubgru = par_cdsubgru NO-LOCK NO-ERROR.

    IF AVAIL craptar THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Sub-Grupo vinculada a uma tarifa!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    FIND FIRST crapcat WHERE crapcat.cdsubgru = par_cdsubgru NO-LOCK NO-ERROR.

    IF AVAIL crapcat THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Sub-Grupo vinculada a uma categoria!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    DO aux_contador = 1 TO 10:

    FIND crapsgr WHERE crapsgr.cdsubgru = par_cdsubgru EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapsgr THEN
			DO:
				IF  LOCKED crapsgr THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   DELETE crapsgr.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Alteracao de SubGrupo
******************************************************************************/
PROCEDURE alterar-cadsgr:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dssubgru AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

    FIND crapsgr WHERE crapsgr.cdsubgru = par_cdsubgru EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapsgr THEN
			DO:
				IF  LOCKED crapsgr THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN crapsgr.cdsubgru = par_cdsubgru
                      crapsgr.dssubgru = par_dssubgru
                      crapsgr.cddgrupo = par_cddgrupo.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
                 TELA CADTIC
******************************************************************************/

/******************************************************************************
 Busca de novo codigo craptic
******************************************************************************/
PROCEDURE busca-novo-cdtipcat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdtipcat AS INTE                   NO-UNDO.

    FIND LAST craptic NO-LOCK NO-ERROR.

    IF  AVAIL(craptic) THEN
        DO:
            par_cdtipcat = craptic.cdtipcat + 1.
        END.
    ELSE
        DO:
            par_cdtipcat = 1.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Tipos de Categoria
******************************************************************************/
PROCEDURE lista-tipos-categoria:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-tipcat.

    DEF VAR aux_nrregist AS INT.


    DO ON ERROR UNDO, LEAVE:
    
        EMPTY TEMP-TABLE tt-tipcat.
    
        ASSIGN aux_nrregist = par_nrregist.
    
        IF  par_cdtipcat = 0 THEN
            DO:
                FOR EACH craptic NO-LOCK BY craptic.cdtipcat:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* Controles da Paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-tipcat.
                            ASSIGN tt-tipcat.cdtipcat = craptic.cdtipcat
                                   tt-tipcat.dstipcat = craptic.dstipcat.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist + 1.
                END.
            END.
        ELSE
            DO:
                FOR EACH craptic NO-LOCK WHERE craptic.cdtipcat >= par_cdtipcat
                                         BY craptic.cdtipcat:

                    ASSIGN par_qtregist = par_qtregist - 1.

                    /* Controles da Paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:                                              
                            CREATE tt-tipcat.
                            ASSIGN tt-tipcat.cdtipcat = craptic.cdtipcat
                                   tt-tipcat.dstipcat = craptic.dstipcat.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
            END.
    
    END.
    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Inclusao de Tipos de Categoria
******************************************************************************/
PROCEDURE incluir-cadtic:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dstipcat AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND craptic WHERE craptic.cdtipcat = par_cdtipcat NO-LOCK NO-ERROR.

    IF  AVAIL(craptic) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE craptic.
    ASSIGN craptic.cdtipcat = par_cdtipcat
           craptic.dstipcat = par_dstipcat.
    VALIDATE craptic.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao de Tipos de Categoria
******************************************************************************/
PROCEDURE excluir-cadtic:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    FIND FIRST crapcat WHERE crapcat.cdtipcat = par_cdtipcat NO-LOCK NO-ERROR.

    IF AVAIL crapcat THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Tipo de Categoria vinculada a uma Categoria!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    DO aux_contador = 1 TO 10:

        FIND craptic WHERE craptic.cdtipcat = par_cdtipcat EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL craptic THEN
			DO:
				IF  LOCKED craptic THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   DELETE craptic.
               LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Alteracao de Tipos de Categoria
******************************************************************************/
PROCEDURE alterar-cadtic:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dstipcat AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND craptic WHERE craptic.cdtipcat = par_cdtipcat EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL craptic THEN
			DO:
				IF  LOCKED craptic THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN craptic.cdtipcat = par_cdtipcat
                      craptic.dstipcat = par_dstipcat.
               LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Buscar de Tipos de Categoria
******************************************************************************/
PROCEDURE buscar-cadtic:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dstipcat AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

        
    FIND craptic WHERE craptic.cdtipcat = par_cdtipcat NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craptic) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    par_dstipcat = craptic.dstipcat.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Buscar Numero do convenio na crapcco
******************************************************************************/
PROCEDURE buscar-cadcco:
                                
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrconven AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND FIRST crapcco WHERE crapcco.nrconven = par_nrconven NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(crapcco) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Convenio inexistente na CADCCO!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Buscar Convenio na crapcco
******************************************************************************/
PROCEDURE buscar-convenio:
                                
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrconven AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dsconven AS CHAR                   NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgregis AS LOGICAL                         NO-UNDO.

    IF par_cdinctar <> 4 THEN DO:
    
        IF  par_cdocorre = 0 THEN
            ASSIGN aux_flgregis = FALSE.
        ELSE
            ASSIGN aux_flgregis = TRUE.
    
        FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcopatu AND
                                 crapcco.nrconven = par_nrconven AND 
                                 crapcco.flgregis = aux_flgregis AND
                                 crapcco.flgativo = TRUE 
                                 NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL(crapcco) THEN
            DO:
    
                IF  aux_flgregis = FALSE THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = 
                                "Convenio de cobranca sem registro inexistente!".
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = 
                                "Convenio de cobranca registrada inexistente!".
                    END.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        
        ASSIGN par_dsconven = crapcco.dsorgarq.

    END.
    ELSE DO:

        /* Se nao achar na CRAPCCO, verificar se o
        convenio e do servico de folha de pagamento */
        FIND FIRST crapcfp WHERE crapcfp.cdcooper = par_cdcopatu
                             AND crapcfp.cdcontar = par_nrconven
                             NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcfp THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = 
                      "Convenio de folha de pagamento inexistente!".
        
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

        ASSIGN par_dsconven = crapcfp.dscontar.

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Buscar Linha de Credito (craplcr)
******************************************************************************/
PROCEDURE buscar-linha-credito:
                                
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dslcremp AS CHAR                   NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND FIRST craplcr WHERE craplcr.cdcooper = par_cdcopatu AND
                             craplcr.cdlcremp = par_cdlcremp AND
							 craplcr.cdusolcr <> 1           AND
                             craplcr.flgtarif = FALSE        
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craplcr) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Linha de Credito inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_dslcremp = craplcr.dslcremp.

    RETURN "OK".                  
END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapcat
******************************************************************************/
PROCEDURE busca-novo-cdcatego:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdcatego AS INTE                   NO-UNDO.

    FIND LAST crapcat NO-LOCK NO-ERROR.

    IF  AVAIL(crapcat) THEN
        DO:
            par_cdcatego = crapcat.cdcatego + 1.
        END.
    ELSE
        DO:
            par_cdcatego = 1.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Convenios
******************************************************************************/
PROCEDURE lista-convenios:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrconven AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsconven AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-convenios.

    DEF VAR aux_nrregist AS INT.
    DEF VAR aux_flgregis AS LOGICAL                         NO-UNDO.

    EMPTY TEMP-TABLE tt-convenios.

    DO ON ERROR UNDO, LEAVE:
        
        IF  par_cdinctar <> 4 THEN DO: /* Outros tipos de incidencia */
            
            IF  par_cdocorre = 0 THEN
                ASSIGN aux_flgregis = FALSE.
            ELSE
                ASSIGN aux_flgregis = TRUE.

            ASSIGN aux_nrregist = par_nrregist.
            
            FOR EACH crapcco NO-LOCK WHERE crapcco.cdcooper =  par_cdcopatu AND
                                           crapcco.nrconven >= par_nrconven AND
                                           crapcco.flgativo =  TRUE         AND
                                           crapcco.flgregis =  aux_flgregis AND
                                           crapcco.dsorgarq MATCHES('*' + par_dsconven + '*')
                                           BY crapcco.nrconven:
    
                ASSIGN par_qtregist = par_qtregist + 1.
        
                /* controles da paginacao */
                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.
        
                IF  aux_nrregist > 0 THEN
                    DO:
                        CREATE tt-convenios.
                        ASSIGN tt-convenios.cdcooper = crapcco.cdcooper
                               tt-convenios.nrconven = crapcco.nrconven
                               tt-convenios.dsconven = crapcco.dsorgarq.
                    END.
        
                ASSIGN aux_nrregist = aux_nrregist - 1.
    
            END.
        END.
        ELSE DO: /* Incidencia - 4 FOLHA DE PAGAMENTO */

            ASSIGN aux_nrregist = par_nrregist.
            
            FOR EACH crapcfp WHERE crapcfp.cdcooper = par_cdcopatu
                               AND crapcfp.cdcontar >= par_nrconven
                               AND crapcfp.dscontar MATCHES('*' + par_dsconven + '*')
                               NO-LOCK:

                ASSIGN par_qtregist = par_qtregist + 1.

                /* controles da paginacao */
                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.

                IF  aux_nrregist > 0 THEN DO:
                    CREATE tt-convenios.
                    ASSIGN tt-convenios.cdcooper = crapcfp.cdcooper
                           tt-convenios.nrconven = crapcfp.cdcontar
                           tt-convenios.dsconven = crapcfp.dscontar.
                    END.
        
                ASSIGN aux_nrregist = aux_nrregist - 1.
            END.

        END.


    END. /* Fim do DO */

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Listagem de Linhas de Credito
******************************************************************************/
PROCEDURE lista-linhas-credito:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dslcremp AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-linhas-cred.

    DEF VAR aux_nrregist AS INT.

    DO ON ERROR UNDO, LEAVE:
        
        EMPTY TEMP-TABLE tt-linhas-cred.
    
        /*incluindo linha padrao*/
        CREATE tt-linhas-cred.
        ASSIGN tt-linhas-cred.cdcooper = par_cdcopatu
               tt-linhas-cred.cdlcremp = 0
               tt-linhas-cred.dslcremp = 'LINHA PADRAO'.

        ASSIGN aux_nrregist = par_nrregist.
        
        FOR EACH craplcr NO-LOCK WHERE craplcr.cdcooper =  par_cdcopatu AND
                                       craplcr.cdlcremp >= par_cdlcremp AND
                                       craplcr.flgtarif = FALSE         AND 
                                       craplcr.cdusolcr <> 1            AND /* Diferente MICROCREDITO */
                                       craplcr.dslcremp MATCHES('*' + par_dslcremp + '*')
                                       BY craplcr.cdlcremp:

            ASSIGN par_qtregist = par_qtregist + 1.
    
            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.
    
            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-linhas-cred.
                    ASSIGN tt-linhas-cred.cdcooper = craplcr.cdcooper
                           tt-linhas-cred.cdlcremp = craplcr.cdlcremp
                           tt-linhas-cred.dslcremp = craplcr.dslcremp.
                END.
    
            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Listagem de Categorias
******************************************************************************/
PROCEDURE lista-categorias:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcatego AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dscatego AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-categorias.

    DEF VAR aux_nrregist AS INT.
    DEF VAR aux_cddgrupo AS INTE.
    DEF VAR aux_dsdgrupo AS CHAR.
    DEF VAR aux_cdsubgru AS INTE.
    DEF VAR aux_dssubgru AS CHAR.

    DEF VAR aux_excluir AS CHAR.


    DO ON ERROR UNDO, LEAVE:
    
        EMPTY TEMP-TABLE tt-categorias.
    
        ASSIGN aux_nrregist = par_nrregist.
    
        IF  par_cddgrupo = 0 THEN
            DO:
     
                FOR EACH crapcat NO-LOCK
                                 WHERE (crapcat.cdcatego >= par_cdcatego)                   AND
                                       (crapcat.dscatego MATCHES('*' + par_dscatego + '*')) AND
                                       ((crapcat.cdsubgru >= par_cdsubgru) OR (crapcat.cdsubgru = 0) )
                                       BY crapcat.cdcatego:
    
                    ASSIGN par_qtregist = par_qtregist + 1.
    
                    IF par_cdtipcat > 0 THEN 
                         DO:
                            IF (crapcat.cdtipcat <> par_cdtipcat) THEN
                                NEXT.
                         END.
    
                    ASSIGN aux_cddgrupo = 0
                           aux_cdsubgru = 0
                           aux_cdsubgru = crapcat.cdsubgru. 
    
                    IF ( aux_cdsubgru > 0 ) THEN
                    DO:
        
                            FIND crapsgr WHERE crapsgr.cdsubgru = crapcat.cdsubgru 
                                               NO-LOCK NO-ERROR.
                
                            IF  NOT AVAIL(crapsgr) THEN
                                NEXT.
                
                            FIND crapgru WHERE crapgru.cddgrupo = crapsgr.cddgrupo
                                               NO-LOCK NO-ERROR.
                
                            IF  NOT AVAIL(crapgru) THEN
                                DO:
                                    NEXT.
                                END.
                            ELSE
                                aux_cddgrupo = crapgru.cddgrupo.
    
                    END.
    
                    /* controles da paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:  
                            CREATE tt-categorias.
                            ASSIGN tt-categorias.cdcatego = crapcat.cdcatego
                                   tt-categorias.dscatego = crapcat.dscatego
                                   tt-categorias.cddgrupo = aux_cddgrupo
                                   tt-categorias.cdsubgru = aux_cdsubgru
                                   tt-categorias.cdtipcat = crapcat.cdtipcat.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
                    
            END.
        ELSE
            DO:
    
                FOR EACH crapcat NO-LOCK
                                 WHERE crapcat.cdcatego >= par_cdcatego AND
                                      (crapcat.dscatego MATCHES('*' + par_dscatego + '*')) AND
                                      ((crapcat.cdsubgru >= par_cdsubgru) OR (crapcat.cdsubgru = 0) )
                                      BY crapcat.cdcatego:
                                                       
                    ASSIGN par_qtregist = par_qtregist + 1.

                    IF par_cdtipcat > 0 THEN 
                         DO:
                            IF (crapcat.cdtipcat <> par_cdtipcat) THEN
                                NEXT.
                         END.
    
                    ASSIGN aux_cddgrupo = 0
                           aux_cdsubgru = 0
                           aux_cdsubgru = crapcat.cdsubgru. 
    
                    IF ( aux_cdsubgru > 0 ) THEN
                        DO:
        
                            FIND crapsgr WHERE crapsgr.cdsubgru = crapcat.cdsubgru 
                                               NO-LOCK NO-ERROR.
                
                            IF  NOT AVAIL(crapsgr) THEN
                                NEXT.
                
                            FIND crapgru WHERE crapgru.cddgrupo = crapsgr.cddgrupo
                                               NO-LOCK NO-ERROR.
                
                            IF  NOT AVAIL(crapgru) THEN
                                DO:
                                    NEXT.
                                END.
                            ELSE
                                aux_cddgrupo = crapgru.cddgrupo.
    
                        END.
    
                    /* controles da paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-categorias.
                            ASSIGN tt-categorias.cdcatego = crapcat.cdcatego
                                   tt-categorias.dscatego = crapcat.dscatego
                                   tt-categorias.cddgrupo = aux_cddgrupo
                                   tt-categorias.cdsubgru = aux_cdsubgru
                                   tt-categorias.cdtipcat = crapcat.cdtipcat.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
    
                FOR EACH tt-categorias  EXCLUSIVE-LOCK:
    
                    ASSIGN aux_excluir = 'N'.
                    
                    IF par_cdsubgru > 0 THEN
                    DO:
                        IF tt-categorias.cddgrupo <> 0 THEN
                        DO:
                            IF tt-categorias.cdsubgru <> par_cdsubgru THEN
                                ASSIGN aux_excluir = 'S'.
                        END.
                    END.
    
                    IF ((par_cddgrupo > 0) AND ( aux_excluir = 'N'))  THEN
                    DO:
                        IF tt-categorias.cddgrupo <> 0 THEN
                        DO:
                            IF tt-categorias.cddgrupo <> par_cddgrupo THEN
                                ASSIGN aux_excluir = 'S'.
                        END.
                    END.
        
                    IF aux_excluir = 'S' THEN
                        DELETE tt-categorias.
                END.          
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
                                   TELA CADTAR
******************************************************************************/

/******************************************************************************
 Listagem de Tarifas
******************************************************************************/
PROCEDURE lista-tarifas:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dstarifa AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcatego AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-tarifas.

    DEF VAR aux_flggrupo AS LOGICAL INITIAL FALSE           NO-UNDO.
    DEF VAR aux_flsubgru AS LOGICAL INITIAL FALSE           NO-UNDO.
    DEF VAR aux_flcatego AS LOGICAL INITIAL FALSE           NO-UNDO.

    DEF VAR aux_nrregist AS INTE                            NO-UNDO.
    DEF VAR aux_cdinctar AS INTE                            NO-UNDO.
    DEF VAR aux_dsinctar AS CHAR                            NO-UNDO.

    DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-tarifas.
    
        ASSIGN aux_nrregist = par_nrregist.

        IF  par_cdcatego > 0 THEN
            DO:
                FIND crapcat WHERE crapcat.cdcatego = par_cdcatego
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcat) THEN
                    RETURN "NOK".

                ASSIGN aux_flcatego = TRUE.
            END.

        IF  par_cdsubgru > 0 THEN
            DO:
                FIND crapsgr WHERE crapsgr.cdsubgru = par_cdsubgru
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapsgr) THEN
                    RETURN "NOK".

                ASSIGN aux_flsubgru = TRUE.
            END.

        IF  par_cddgrupo > 0 THEN
            DO:
                FIND crapgru WHERE crapgru.cddgrupo = par_cddgrupo
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapgru) THEN
                    RETURN "NOK".

                ASSIGN aux_flggrupo = TRUE.
            END.

        FOR EACH craptar NO-LOCK WHERE craptar.cdtarifa >= par_cdtarifa AND
                            craptar.dstarifa MATCHES('*' + par_dstarifa + '*')
                                       BY craptar.cdtarifa:
          

            /*Dados categoria*/
            FIND crapcat WHERE crapcat.cdcatego = craptar.cdcatego
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapcat) THEN
                NEXT.


            IF  par_cdcatego > 0 THEN
                IF  par_cdcatego <> craptar.cdcatego THEN
                    NEXT.

            /*Dados do subgrupo*/
            IF  crapcat.cdsubgru > 0 THEN
                DO:
                    FIND crapsgr WHERE crapsgr.cdsubgru = crapcat.cdsubgru
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL(crapsgr) THEN
                        NEXT.

                END.
            ELSE
                DO:
                    FIND crapsgr WHERE crapsgr.cdsubgru = craptar.cdsubgru
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL(crapsgr) THEN
                        NEXT.
                END.

            IF  par_cdsubgru > 0 THEN
                IF  par_cdsubgru <> crapsgr.cdsubgru THEN
                    NEXT.

            /*dados do grupo*/
            FIND crapgru WHERE crapgru.cddgrupo = crapsgr.cddgrupo
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapgru) THEN
                NEXT.

            IF  par_cddgrupo > 0 THEN
                IF  par_cddgrupo <> crapgru.cddgrupo THEN
                    NEXT.

            IF  craptar.cdinctar > 0 THEN
                DO:
            
                    /*busca tipo incidencia*/
                    FIND crapint WHERE crapint.cdinctar = craptar.cdinctar 
                                       NO-LOCK NO-ERROR.
            
                    IF  NOT AVAIL(crapint) THEN
                        NEXT.

                    ASSIGN aux_cdinctar = crapint.cdinctar
                           aux_dsinctar = crapint.dsinctar.
                END.
            ELSE
                DO:
                    ASSIGN aux_cdinctar = 0
                           aux_dsinctar = 'Nenhum'.
                END.


            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    /*cria registro temp-table*/
                    CREATE tt-tarifas.
                    ASSIGN tt-tarifas.cdtarifa = craptar.cdtarifa
                           tt-tarifas.dstarifa = craptar.dstarifa
                           tt-tarifas.cddgrupo = crapgru.cddgrupo
                           tt-tarifas.dsdgrupo = crapgru.dsdgrupo
                           tt-tarifas.cdsubgru = crapsgr.cdsubgru
                           tt-tarifas.dssubgru = crapsgr.dssubgru
                           tt-tarifas.cdcatego = crapcat.cdcatego
                           tt-tarifas.dscatego = crapcat.dscatego
                           tt-tarifas.cdmotivo = craptar.cdmotivo
                           tt-tarifas.cdocorre = craptar.cdocorre
                           tt-tarifas.flglaman = craptar.flglaman
                           tt-tarifas.inpessoa = craptar.inpessoa
                           tt-tarifas.idinctar = aux_cdinctar
                           tt-tarifas.dsinctar = aux_dsinctar
                           tt-tarifas.dspessoa = IF craptar.inpessoa = 1 THEN
                                                    "FISICA"
                                                 ELSE
                                                    "JURIDICA".
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.
    END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE verifica-lanc-lat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    FIND FIRST craplat WHERE craplat.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

    IF  AVAIL(craplat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Ja existem lancamentos! " +
                                  "Impossivel realizar operacao.".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de Faixa de Valores
******************************************************************************/
PROCEDURE lista-fvl:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-faixavalores.

    DEF VAR aux_nrregist AS INTE                            NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                            NO-UNDO.
    DEF VAR aux_dshistor AS CHAR                            NO-UNDO.


    EMPTY TEMP-TABLE tt-faixavalores.

    ASSIGN aux_nrregist = 0.
                     
    FOR EACH crapfvl NO-LOCK WHERE crapfvl.cdtarifa = par_cdtarifa
                                USE-INDEX crapfvl4
                                BY crapfvl.cdfaixav:
                                

        ASSIGN aux_cdhistor = 0
               aux_dshistor = "".
        
        FIND craphis WHERE  craphis.cdcooper = par_cdcooper AND
                            craphis.cdhistor = crapfvl.cdhistor 
                                              NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            NEXT.

        ASSIGN aux_cdhistor = craphis.cdhistor
               aux_dshistor = craphis.dshistor.

        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                           craphis.cdhistor = crapfvl.cdhisest 
                                              NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            NEXT.
          
        CREATE tt-faixavalores.
        ASSIGN tt-faixavalores.cdfaixav = crapfvl.cdfaixav
               tt-faixavalores.vlinifvl = crapfvl.vlinifvl
               tt-faixavalores.vlfinfvl = crapfvl.vlfinfvl
               tt-faixavalores.cdhistor = aux_cdhistor
               tt-faixavalores.dshistor = aux_dshistor    
               tt-faixavalores.cdhisest = craphis.cdhistor
               tt-faixavalores.dshisest = craphis.dshistor  
               aux_nrregist = aux_nrregist + 1.
        
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Busca de novo codigo craptar
******************************************************************************/
PROCEDURE busca-novo-cdtarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdtarifa AS INTE                   NO-UNDO.

    FIND LAST craptar NO-LOCK NO-ERROR.

    IF  AVAIL(craptar) THEN
        DO:
            par_cdtarifa = craptar.cdtarifa + 1.
        END.
    ELSE
        DO:
            par_cdtarifa = 1.
        END.

END PROCEDURE.


/******************************************************************************
 Inclusao de Tarifas
******************************************************************************/
PROCEDURE incluir-cadtar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dstarifa AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdcatego AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotivo AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flglaman AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    /* Tratamento para verificar se cdtarifa esta zerado. */
    IF par_cdtarifa = 0 THEN
    DO:
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "Nao foi possivel obter o codigo da tarifa!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".

    END.
    
    FIND craptar WHERE craptar.cdtarifa = par_cdtarifa NO-LOCK NO-ERROR.

    IF  AVAIL(craptar) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE craptar.
    ASSIGN craptar.cdtarifa = par_cdtarifa
           craptar.dstarifa = par_dstarifa
           craptar.cdcatego = par_cdcatego
           craptar.inpessoa = par_inpessoa
           craptar.cdocorre = par_cdocorre
           craptar.cdmotivo = par_cdmotivo
           craptar.cdinctar = par_cdinctar
           craptar.flglaman = par_flglaman
           craptar.cdsubgru = par_cdsubgru.
    VALIDATE craptar.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao de Tarifas
******************************************************************************/
PROCEDURE excluir-cadtar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND craptar WHERE craptar.cdtarifa = par_cdtarifa EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL craptar THEN
			DO:
				IF  LOCKED craptar THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   FIND FIRST crapfvl WHERE crapfvl.cdtarifa = craptar.cdtarifa
                             USE-INDEX crapfvl4 NO-LOCK NO-ERROR.

                IF  AVAIL(crapfvl) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nao foi possivel excluir registro! " +
                                              "Existem detalhamentos para esta tarifa!".

                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
            
                DELETE craptar.
                LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Alteracao de Tarifas
******************************************************************************/
PROCEDURE alterar-cadtar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dstarifa AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdcatego AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotivo AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flglaman AS LOGICAL                 NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND craptar WHERE craptar.cdtarifa = par_cdtarifa EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL craptar THEN
			DO:
				IF  LOCKED craptar THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN craptar.dstarifa = par_dstarifa
                      craptar.cdcatego = par_cdcatego
                      craptar.inpessoa = par_inpessoa
                      craptar.cdocorre = par_cdocorre
                      craptar.cdmotivo = par_cdmotivo
                      craptar.cdsubgru = par_cdsubgru
                      craptar.cdinctar = par_cdinctar
                      craptar.flglaman = par_flglaman.
               LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Busca de Tarifas
******************************************************************************/
PROCEDURE buscar-cadtar:
                                
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_dstarifa AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_inpessoa AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_flglaman AS LOG                    NO-UNDO.
    DEF OUTPUT PARAM par_flgpacta AS LOG                    NO-UNDO.
    DEF OUTPUT PARAM par_cdocorre AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_cdmotivo AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_cddgrupo AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_dsdgrupo AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_cdsubgru AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_dssubgru AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_cdcatego AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_dscatego AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_cdinctar AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_cdtipcat AS INTE                   NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VARIABLE aux_qtregist     AS INTE.

    
    FIND craptar WHERE craptar.cdtarifa = par_cdtarifa NO-LOCK NO-ERROR.    
    
    IF  NOT AVAIL(craptar) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tarifa inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND crapcat WHERE crapcat.cdcatego = craptar.cdcatego NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapcat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Categoria inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  craptar.cdsubgru > 0 THEN
        DO:
            FIND crapsgr WHERE crapsgr.cdsubgru = craptar.cdsubgru
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapsgr) THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Sub-Grupo inexistente!".

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
            FIND crapsgr WHERE crapsgr.cdsubgru = crapcat.cdsubgru 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapsgr) THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Sub-Grupo inexistente!".

                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.

    FIND crapgru WHERE crapgru.cddgrupo = crapsgr.cddgrupo NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapgru) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Grupo inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.             

    ASSIGN  par_dstarifa = craptar.dstarifa
            par_inpessoa = craptar.inpessoa
            par_cdocorre = craptar.cdocorre
            par_cdmotivo = craptar.cdmotivo
            par_flglaman = craptar.flglaman
            par_flgpacta = craptar.flutlpct
            par_cdinctar = craptar.cdinctar
            par_cdcatego = crapcat.cdcatego
            par_dscatego = crapcat.dscatego
            par_cddgrupo = crapgru.cddgrupo
            par_dsdgrupo = crapgru.dsdgrupo
            par_cdsubgru = crapsgr.cdsubgru
            par_dssubgru = crapsgr.dssubgru
            par_cdtipcat = crapcat.cdtipcat.

    RETURN "OK".                  
END PROCEDURE.

/******************************************************************************
                                   TELA CADFVL
******************************************************************************/
/******************************************************************************
 Inclusao de Faixa valores
******************************************************************************/
PROCEDURE incluir-cadfvl:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vlinifvl AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlfinfvl AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR flg_faixacrt AS LOGICAL                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapfvl WHERE crapfvl.cdfaixav = par_cdfaixav NO-LOCK NO-ERROR.

    IF  AVAIL(crapfvl) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    /*verifica faixa de valores*/
    ASSIGN flg_faixacrt = TRUE.

    FOR EACH crapfvl WHERE crapfvl.cdtarifa = par_cdtarifa NO-LOCK
        USE-INDEX crapfvl4:

        IF ((par_vlinifvl    >= crapfvl.vlinifvl  AND
             par_vlinifvl    <= crapfvl.vlfinfvl) OR
            (par_vlfinfvl    >= crapfvl.vlinifvl  AND 
             par_vlfinfvl    <= crapfvl.vlfinfvl)) THEN
            DO:
                ASSIGN flg_faixacrt = FALSE. 
            END.

    END.

    IF  flg_faixacrt = FALSE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Faixa de valores ja cadastrada para esta tarifa!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.            
    /**/

    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craphis) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Historico de lancamento inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhisest NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craphis) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Historico de estorno inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE crapfvl.
    ASSIGN crapfvl.cdfaixav = par_cdfaixav
           crapfvl.cdtarifa = par_cdtarifa
           crapfvl.vlinifvl = par_vlinifvl
           crapfvl.vlfinfvl = par_vlfinfvl
           crapfvl.cdhistor = par_cdhistor
           crapfvl.cdhisest = par_cdhisest.
    VALIDATE crapfvl.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao de Faixa valores
******************************************************************************/
PROCEDURE excluir-cadfvl:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crapfvl WHERE crapfvl.cdfaixav = par_cdfaixav EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapfvl THEN
			DO:
				IF  LOCKED crapfvl THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			    FIND FIRST crapfco WHERE crapfco.cdfaixav = crapfvl.cdfaixav
                             NO-LOCK NO-ERROR.

                IF  AVAIL(crapfco) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
            				   aux_dscritic = "Necessario excluir primeiramente os registros de faixa por cooperativa!".
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
            
                DELETE crapfvl.
                LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Alteracao de Faixa valores
******************************************************************************/
PROCEDURE alterar-cadfvl:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vlinifvl AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlfinfvl AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crapfvl WHERE crapfvl.cdfaixav = par_cdfaixav EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapfvl THEN
			DO:
				IF  LOCKED crapfvl THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                   craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

                IF  NOT AVAIL(craphis) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
            				   aux_dscritic = "Historico de lancamento inexistente!".
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
            
                FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                   craphis.cdhistor = par_cdhisest NO-LOCK NO-ERROR.
            
                IF  NOT AVAIL(craphis) THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
            				   aux_dscritic = "Historico de estorno inexistente!".
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
            
                ASSIGN crapfvl.vlinifvl = par_vlinifvl
                       crapfvl.vlfinfvl = par_vlfinfvl
                       crapfvl.cdhistor = par_cdhistor
                       crapfvl.cdhisest = par_cdhisest.
                LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapfvl
******************************************************************************/
PROCEDURE busca-novo-cdfaixav:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdfaixav AS INTE                   NO-UNDO.

    FIND LAST crapfvl NO-LOCK NO-ERROR.

    IF  AVAIL(crapfvl) THEN
        DO:
            par_cdfaixav = crapfvl.cdfaixav + 1.
        END.
    ELSE
        DO:
            par_cdfaixav = 1.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de Historicos
******************************************************************************/
PROCEDURE lista-historicos:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dshistor AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-historicos.

    DEF VAR aux_nrregist AS INT.
    
    DO ON ERROR UNDO, LEAVE:
    
        EMPTY TEMP-TABLE tt-historicos.
    
        ASSIGN aux_nrregist = par_nrregist.
    
        IF  par_cdhistor  > 0  AND
            par_dshistor <> '' THEN
            DO:
                FOR EACH craphis NO-LOCK WHERE craphis.cdcooper =  par_cdcooper AND
                                               craphis.cdhistor >= par_cdhistor AND
                                               craphis.dshistor MATCHES('*' + par_dshistor + '*')
                                            BY craphis.cdhistor:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
            END.
        ELSE
        DO:
            IF  par_cdhistor > 0 THEN
                DO:
                    FOR EACH craphis NO-LOCK WHERE craphis.cdhistor >= par_cdhistor AND
                                                   craphis.cdcooper = par_cdcooper
                                                BY craphis.cdhistor:

                        ASSIGN par_qtregist = par_qtregist + 1.

                        /*controle paginacao*/
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.

                        IF  aux_nrregist > 0 THEN
                            DO:
                                CREATE tt-historicos.
                                ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                       tt-historicos.dshistor = craphis.dshistor.
                            END.

                        ASSIGN aux_nrregist = aux_nrregist - 1.
                    END.
                END.
            ELSE
                DO:
                    IF par_dshistor <> '' THEN
                    DO:
                        FOR EACH craphis NO-LOCK WHERE craphis.cdcooper =  par_cdcooper AND
                                                       craphis.dshistor MATCHES('*' + par_dshistor + '*')
                                                    BY craphis.dshistor:

                            ASSIGN par_qtregist = par_qtregist + 1.

                            /*controle paginacao*/
                            IF  (par_qtregist < par_nriniseq) OR
                                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                                NEXT.

                            IF  aux_nrregist > 0 THEN
                                DO:

                                    CREATE tt-historicos.
                                    ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                           tt-historicos.dshistor = craphis.dshistor.
                                END.

                            ASSIGN aux_nrregist = aux_nrregist - 1.
                        END.
                    END.
                    ELSE
                    DO:
                        FOR EACH craphis NO-LOCK WHERE craphis.cdcooper = par_cdcooper 
                                                    BY craphis.cdhistor:

                            ASSIGN par_qtregist = par_qtregist + 1.

                            /* controles da paginacao */
                            IF  (par_qtregist < par_nriniseq) OR
                                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                                NEXT.

                            IF  aux_nrregist > 0 THEN
                                DO:
                                    CREATE tt-historicos.
                                    ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                           tt-historicos.dshistor = craphis.dshistor.
                                END.

                            ASSIGN aux_nrregist = aux_nrregist - 1.
                        END.
                    END.
                END.
        END.

        LEAVE.
    END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Listagem de Historicos que tem tarifas vinculadas
******************************************************************************/
PROCEDURE lista-historicos-tarifa:
     /*tiago implementar*/
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dshistor AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-historicos.

    DEF VAR aux_nrregist AS INT.
    
    DO ON ERROR UNDO, LEAVE:
    
        EMPTY TEMP-TABLE tt-historicos.

        ASSIGN aux_nrregist = par_nrregist.

        IF  par_cdhistor = 0 AND par_dshistor = "" THEN
        DO: 

            FOR EACH crapfvl NO-LOCK BREAK BY crapfvl.cdhistor:
                
                IF  FIRST-OF(crapfvl.cdhistor) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                       craphis.cdhistor = crapfvl.cdhistor
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.
    
        /*filtrando por codigo e descricao do historico*/
        IF  par_cdhistor > 0 AND par_dshistor <> "" THEN
        DO:

            FOR EACH crapfvl NO-LOCK 
                             WHERE crapfvl.cdhistor >= par_cdhistor
                                          BREAK BY crapfvl.cdhistor:
                
                IF  FIRST-OF(crapfvl.cdhistor) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                       craphis.cdhistor = crapfvl.cdhistor AND
                                       craphis.dshistor MATCHES('*' + par_dshistor + '*')
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.

        /*filtrando por codigo do historico*/
        IF  par_cdhistor > 0 AND par_dshistor = "" THEN
        DO:

            FOR EACH crapfvl NO-LOCK 
                             WHERE crapfvl.cdhistor >= par_cdhistor
                                          BREAK BY crapfvl.cdhistor:
                
                IF  FIRST-OF(crapfvl.cdhistor) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                       craphis.cdhistor = crapfvl.cdhistor 
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.

        /*filtrando por descricao do historico*/
        IF  par_cdhistor = 0 AND par_dshistor <> "" THEN
        DO:

            FOR EACH crapfvl NO-LOCK BREAK BY crapfvl.cdhistor:
                
                IF  FIRST-OF(crapfvl.cdhistor) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                       craphis.cdhistor = crapfvl.cdhistor AND
                                       craphis.dshistor MATCHES('*' + par_dshistor + '*')
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.


        LEAVE.
    END.
    
    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Listagem de Historicos que tem tarifas vinculadas
******************************************************************************/
PROCEDURE lista-historicos-estorno-tarifa:
     /*tiago implementar*/
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dshisest AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-historicos.

    DEF VAR aux_nrregist AS INT.
    
    DO ON ERROR UNDO, LEAVE:
    
        EMPTY TEMP-TABLE tt-historicos.

        ASSIGN aux_nrregist = par_nrregist.

        IF  par_cdhisest = 0 AND par_dshisest = "" THEN
        DO: 

            FOR EACH crapfvl NO-LOCK BREAK BY crapfvl.cdhisest:
                
                IF  FIRST-OF(crapfvl.cdhisest) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                       craphis.cdhistor = crapfvl.cdhisest
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.
    
        /*filtrando por codigo e descricao do historico*/
        IF  par_cdhisest > 0 AND par_dshisest <> "" THEN
        DO:

            FOR EACH crapfvl NO-LOCK 
                             WHERE crapfvl.cdhisest >= par_cdhisest
                                          BREAK BY crapfvl.cdhisest:
                
                IF  FIRST-OF(crapfvl.cdhisest) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                       craphis.cdhistor = crapfvl.cdhisest AND
                                       craphis.dshistor MATCHES('*' + par_dshisest + '*')
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.

        /*filtrando por codigo do historico*/
        IF  par_cdhisest > 0 AND par_dshisest = "" THEN
        DO:

            FOR EACH crapfvl NO-LOCK 
                             WHERE crapfvl.cdhisest >= par_cdhisest
                                          BREAK BY crapfvl.cdhisest:
                
                IF  FIRST-OF(crapfvl.cdhisest) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                       craphis.cdhistor = crapfvl.cdhisest 
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.

        /*filtrando por descricao do historico*/
        IF  par_cdhisest = 0 AND par_dshisest <> "" THEN
        DO:

            FOR EACH crapfvl NO-LOCK BREAK BY crapfvl.cdhisest:
                
                IF  FIRST-OF(crapfvl.cdhisest) THEN
                DO:
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                       craphis.cdhistor = crapfvl.cdhisest AND
                                       craphis.dshistor MATCHES('*' + par_dshisest + '*')
                                       NO-LOCK NO-ERROR.
    
                    IF  AVAIL(craphis) THEN
                    DO: 
                        ASSIGN par_qtregist = par_qtregist + 1.
    
                        /* controles da paginacao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
    
                        IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-historicos.
                            ASSIGN tt-historicos.cdhistor = craphis.cdhistor
                                   tt-historicos.dshistor = craphis.dshistor.
                        END.
                    END.
    
                END.
            END.
        END.


        LEAVE.
    END.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE busca-subgrupo-historico:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdsubgru AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FIND FIRST crapfvl WHERE crapfvl.cdhistor = par_cdhistor NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(crapfvl) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Faixa nao cadastrada!".
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    FIND FIRST craptar WHERE craptar.cdtarifa = crapfvl.cdtarifa 
                              NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craptar) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tarifa nao cadastrada!".
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    
    ASSIGN par_cdsubgru = craptar.cdsubgru.

    RETURN "OK".
END PROCEDURE.

PROCEDURE busca-subgrupo-historico-estorno:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdsubgru AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FIND FIRST crapfvl WHERE crapfvl.cdhisest = par_cdhisest NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(crapfvl) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Faixa nao cadastrada!".
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    FIND FIRST craptar WHERE craptar.cdtarifa = crapfvl.cdtarifa 
                              NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craptar) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tarifa nao cadastrada!".
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    
    ASSIGN par_cdsubgru = craptar.cdsubgru.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca de Historicos
******************************************************************************/
PROCEDURE busca-historico:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dshistor AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craphis) THEN
        DO:
            ASSIGN aux_cdcritic = 526.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    par_dshistor = craphis.dshistor.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca de Historicos vinculados a tarifas
******************************************************************************/
PROCEDURE busca-historico-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dshistor AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craphis) THEN
        DO:
            ASSIGN aux_cdcritic = 526.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND FIRST crapfvl WHERE crapfvl.cdhistor = craphis.cdhistor 
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapfvl) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Este historico nao esta vinculado a uma tarifa".
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    par_dshistor = craphis.dshistor.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca de Historicos vinculados a tarifas
******************************************************************************/
PROCEDURE busca-historico-estorno-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dshisest AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhisest NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craphis) THEN
        DO:
            ASSIGN aux_cdcritic = 526.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND FIRST crapfvl WHERE crapfvl.cdhisest = craphis.cdhistor 
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapfvl) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Este historico nao esta vinculado a uma tarifa".
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    par_dshisest = craphis.dshistor.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca de Historicos Repetidos
******************************************************************************/
PROCEDURE busca-historico-repetido:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dshistor AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_cdhisest AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_dshisest AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    ASSIGN par_cdhisest = 0
           par_dshisest = ''.

    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craphis) THEN
        DO:
            ASSIGN aux_cdcritic = 526.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    par_dshistor = craphis.dshistor.

    FIND FIRST crapfvl WHERE crapfvl.cdhistor = par_cdhistor
                             NO-LOCK NO-ERROR.

    IF  AVAIL(crapfvl) THEN
        DO:
            FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                               craphis.cdhistor = crapfvl.cdhisest 
                               NO-LOCK NO-ERROR.

            IF  AVAIL(craphis) THEN
                DO:
                    ASSIGN par_cdhisest = craphis.cdhistor
                           par_dshisest = craphis.dshistor.
                END.

        END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
                                   TELA LANTAR
******************************************************************************/
/******************************************************************************
 Busca associado
******************************************************************************/
PROCEDURE busca-associado-lantar:

    DEF INPUT PARAM par_cdcooper    AS  INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS  INTE                    NO-UNDO.
    DEF INPUT PARAM par_telinpes    AS  INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdagenci   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_nrmatric   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdtipcta   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_dstipcta   AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl   AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_inpessoa   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_nmresage   AS  CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdconta   
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapass) THEN
        DO: 
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Conta inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF crapass.dtdemiss <> ? THEN
         DO: 
            ASSIGN aux_cdcritic = 64. /* Conta encerrada */

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF par_telinpes > 0 THEN
    DO:
        IF crapass.inpessoa <> par_telinpes THEN
             DO: 
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Todas contas selecionadas devem ter o mesmo tipo de pessoa!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
    END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT crapass.inpessoa, /* Tipo de pessoa */
                               INPUT crapass.cdtipcta, /* Tipo de conta */
                              OUTPUT "",               /* Descriçao do Tipo de conta */
                              OUTPUT "",               /* Flag Erro */
                              OUTPUT "").              /* Descriçao da crítica */

    CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dstipcta = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                           WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
           aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                           WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
           aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                           WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
    
    IF aux_des_erro = "NOK"  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        
    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = crapass.cdagenci
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapage) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Agencia inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_cdagenci = crapass.cdagenci
           par_nrmatric = crapass.nrmatric
           par_cdtipcta = crapass.cdtipcta
           par_dstipcta = aux_dstipcta
           par_nmprimtl = crapass.nmprimtl
           par_inpessoa = crapass.inpessoa
           par_nmresage = crapage.nmresage.

    RETURN "OK".
END PROCEDURE.                                                                 

/******************************************************************************
 lista-tarifa-pessoa
******************************************************************************/
PROCEDURE lista-tarifa-pessoa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-tarifas.

    DEF VAR aux_nrregist AS INT                             NO-UNDO.

    DEF VAR aux_cdcadast AS INT                             NO-UNDO.
    DEF VAR aux_bloqueia AS INT                             NO-UNDO. 

    EMPTY TEMP-TABLE tt-tarifas.

    ASSIGN aux_nrregist = 0.

    FOR EACH craptar WHERE craptar.inpessoa = par_inpessoa AND
                           craptar.flglaman = TRUE
                           NO-LOCK:

        FIND FIRST crapfvl WHERE crapfvl.cdtarifa = craptar.cdtarifa
                           USE-INDEX crapfvl4
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapfvl) THEN
            NEXT.

        FIND FIRST crapfco WHERE crapfco.cdcooper = par_cdcooper     AND
                           crapfco.cdfaixav = crapfvl.cdfaixav AND
                           crapfco.flgvigen = TRUE
                           NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL(crapfco) THEN
            NEXT.

        
        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                           craphis.cdhistor = crapfvl.cdhistor
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            NEXT.

                /* Tratamento para tarifa de cheque em custodia*/
        

        IF par_inpessoa = 1 THEN
            DO:
                FIND FIRST crapbat NO-LOCK WHERE crapbat.cdbattar = "CUSTDCTOPF".
                    IF AVAIL crapbat THEN
                    DO:
                        ASSIGN aux_cdcadast = crapbat.cdcadast.
                    END.
            END.
        ELSE
            DO:
                FIND FIRST crapbat NO-LOCK WHERE crapbat.cdbattar = "CUSTDCTOPJ".
                    IF AVAIL crapbat THEN
                    DO:
                        ASSIGN aux_cdcadast = crapbat.cdcadast.
                    END.
            END.

        /* Verifica se eh historico de cheque em custodia e
         se existe cheques a serem lancados*/
        ASSIGN aux_bloqueia = 0.
        IF ( craptar.cdtarifa = aux_cdcadast ) THEN
            DO:
                ASSIGN aux_bloqueia = 1.
            END.

        CREATE tt-tarifas.
        ASSIGN tt-tarifas.cdtarifa = craptar.cdtarifa
               tt-tarifas.dstarifa = craptar.dstarifa
               tt-tarifas.cdhistor = craphis.cdhistor
               tt-tarifas.dshistor = craphis.dshistor
               tt-tarifas.vltarifa = crapfco.vltarifa
               tt-tarifas.cdfaixav = crapfvl.cdfaixav
               tt-tarifas.cdfvlcop = crapfco.cdfvlcop
               tt-tarifas.bloqueia = aux_bloqueia.
      
    END.
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*                        tela cadmet                                      */
/***************************************************************************/

/******************************************************************************
 Listagem de Motivos de Estorno/Baixa Tarifa
******************************************************************************/
PROCEDURE lista-met:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotest AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-met.

    DEF VAR aux_nrregist AS INT.


    DO ON ERROR UNDO, LEAVE:
    
        EMPTY TEMP-TABLE tt-met.
    
        ASSIGN aux_nrregist = par_nrregist.
    
        FOR EACH crapmet WHERE crapmet.cdmotest >= par_cdmotest NO-LOCK:
             
            ASSIGN par_qtregist = par_qtregist + 1.
            
            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    CREATE tt-met.
                    ASSIGN tt-met.cdmotest = crapmet.cdmotest
                           tt-met.dsmotest = crapmet.dsmotest
                           tt-met.tpaplica = crapmet.tpaplica.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

    END.
    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Inclusao de Motivos de Estorno/Baixa Tarifa
******************************************************************************/
PROCEDURE incluir-cadmet:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotest AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsmotest AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_tpaplica AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapmet WHERE crapmet.cdmotest = par_cdmotest NO-LOCK NO-ERROR.

    IF  AVAIL(crapmet) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE crapmet.
    ASSIGN crapmet.cdmotest = par_cdmotest
           crapmet.dsmotest = par_dsmotest
           crapmet.tpaplica = par_tpaplica.
    VALIDATE crapmet.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao de Motivos de Estorno/Baixa Tarifa
******************************************************************************/
PROCEDURE excluir-cadmet:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotest AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    FIND FIRST craplat WHERE craplat.cdmotest = par_cdmotest NO-LOCK NO-ERROR.

    IF AVAIL craplat THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Motivo de Estorno vinculada a um Lancamento!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    DO aux_contador = 1 TO 10:

        FIND crapmet WHERE crapmet.cdmotest = par_cdmotest EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapmet THEN
			DO:
				IF  LOCKED crapmet THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   DELETE crapmet.
               LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Alteracao de Motivos de Estorno/Baixa Tarifa
******************************************************************************/
PROCEDURE alterar-cadmet:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotest AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsmotest AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_tpaplica AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crapmet WHERE crapmet.cdmotest = par_cdmotest EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapmet THEN
			DO:
				IF  LOCKED crapmet THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN crapmet.cdmotest = par_cdmotest
                      crapmet.dsmotest = par_dsmotest
                      crapmet.tpaplica = par_tpaplica.
               LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Busca de Motivos de Estorno/Baixa Tarifa
******************************************************************************/
PROCEDURE buscar-cadmet:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdmotest AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dsmotest AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_tpaplica AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapmet WHERE crapmet.cdmotest = par_cdmotest NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapmet) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_dsmotest = crapmet.dsmotest
           par_tpaplica = crapmet.tpaplica.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca de novo codigo crapmet
******************************************************************************/
PROCEDURE busca-novo-cdmotest:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdmotest AS INTE                   NO-UNDO.

    FIND LAST crapmet NO-LOCK NO-ERROR.

    IF  AVAIL(crapmet) THEN
        DO:
            par_cdmotest = crapmet.cdmotest + 1.
        END.
    ELSE
        DO:
            par_cdmotest = 1.
        END.

END PROCEDURE.

/******************************************************************************
 TELA RELTAR
******************************************************************************/


/******************************************************************************
 Busca associado
******************************************************************************/
PROCEDURE busca-associado-reltar:

    DEF INPUT PARAM par_cdcooper    AS  INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS  INTE                    NO-UNDO.
    DEF INPUT PARAM par_ccooptel    AS  INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel    AS  INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdagenci   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_nrmatric   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdtipcta   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_dstipcta   AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl   AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_inpessoa   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_nmresage   AS  CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcooper            AS  INTE                    NO-UNDO.


    ASSIGN aux_cdcooper = par_cdcooper.

    IF ( par_ccooptel > 0 ) THEN
        ASSIGN aux_cdcooper = par_ccooptel.


    FIND crapass WHERE crapass.cdcooper = aux_cdcooper AND 
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapass) THEN
        DO: 
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Cooperado inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT crapass.inpessoa, /* Tipo de pessoa */
                               INPUT crapass.cdtipcta, /* Tipo de conta */
                              OUTPUT "",               /* Descriçao do Tipo de conta */
                              OUTPUT "",               /* Flag Erro */
                              OUTPUT "").              /* Descriçao da crítica */

    CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dstipcta = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                           WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
           aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                           WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
           aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                           WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
    
    IF aux_des_erro = "NOK"  THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Tipo de conta inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        
    FIND crapage WHERE crapage.cdcooper = aux_cdcooper AND
                       crapage.cdagenci = crapass.cdagenci
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapage) THEN
        DO:
            ASSIGN aux_cdcritic = 15.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_cdagenci = crapass.cdagenci
           par_nrmatric = crapass.nrmatric
           par_cdtipcta = crapass.cdtipcta
           par_dstipcta = aux_dstipcta
           par_nmprimtl = crapass.nmprimtl
           par_inpessoa = crapass.inpessoa
           par_nmresage = crapage.nmresage.

    RETURN "OK".
END PROCEDURE.                                                                 

/******************************************************************************
 Busca Descricao PAC
******************************************************************************/
PROCEDURE buscar-pac:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_nmresage AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapage) THEN
        DO:
            ASSIGN aux_cdcritic = 15.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_nmresage = crapage.nmresage.

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Busca Descricao PAC RELTAR
******************************************************************************/
PROCEDURE buscar-pac-reltar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_ccooptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_nmresage AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    IF ( par_cdcooper = 3 ) THEN /* Cecred */ 
        DO:
            FIND crapage WHERE crapage.cdcooper = par_ccooptel AND
                               crapage.cdagenci = par_cdagetel NO-LOCK NO-ERROR.
        
            IF  NOT AVAIL(crapage) THEN
                DO:
                    ASSIGN aux_cdcritic = 15.
        
                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        
            ASSIGN par_nmresage = crapage.nmresage.
        END.
    ELSE
        DO:
            FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                               crapage.cdagenci = par_cdagetel NO-LOCK NO-ERROR.
        
            IF  NOT AVAIL(crapage) THEN
                DO:
                    ASSIGN aux_cdcritic = 15.
        
                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        
            ASSIGN par_nmresage = crapage.nmresage.
        END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de PACs
******************************************************************************/
PROCEDURE lista-pacs:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-agenci.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-agenci.

    ASSIGN aux_nrregist = 0.

    FOR EACH crapage NO-LOCK WHERE crapage.cdagenci >= par_cdagenci AND
                                   crapage.cdcooper = par_cdcooper
                                BY crapage.cdagenci:

        FIND crapcop WHERE crapcop.cdcooper = crapage.cdcooper 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapcop) THEN
            NEXT.

        CREATE tt-agenci.
        ASSIGN tt-agenci.cdagenci = crapage.cdagenci
               tt-agenci.nmresage = crapage.nmresage
               tt-agenci.cdcooper = crapcop.cdcooper
               tt-agenci.nmrescop = crapcop.nmrescop
               aux_nrregist = aux_nrregist + 1.
    END.

    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*                        tela cadpar                                      */
/***************************************************************************/

/******************************************************************************
 Busca de novo codigo crappat
******************************************************************************/
PROCEDURE busca-novo-cdpartar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdpartar AS INTE                   NO-UNDO.

    FIND LAST crappat NO-LOCK NO-ERROR.

    IF  AVAIL(crappat) THEN
        DO:
            par_cdpartar = crappat.cdpartar + 1.
        END.
    ELSE
        DO:
            par_cdpartar = 1.
        END.

END PROCEDURE.

/******************************************************************************
 Listagem de paramentros
******************************************************************************/
PROCEDURE lista-parametros:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmpartar AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-partar.

    DEF VAR aux_nrregist AS INT.


    DO ON ERROR UNDO, LEAVE:
    
        EMPTY TEMP-TABLE tt-partar.
    
        ASSIGN aux_nrregist = par_nrregist.
    
        IF  par_cdpartar = 0 THEN
            DO: 
                FOR EACH crappat WHERE crappat.nmpartar MATCHES ("*" + par_nmpartar + "*")
                                NO-LOCK BY crappat.cdpartar:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-partar.
                            ASSIGN tt-partar.cdpartar = crappat.cdpartar
                                   tt-partar.nmpartar = crappat.nmpartar
                                   tt-partar.tpdedado = crappat.tpdedado.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
            END.
        ELSE
            DO:
                FOR EACH crappat NO-LOCK WHERE crappat.cdpartar >= par_cdpartar AND
                                               crappat.nmpartar MATCHES ("*" + par_nmpartar + "*") 
                                               BY crappat.cdpartar:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-partar.
                            ASSIGN tt-partar.cdpartar = crappat.cdpartar
                                   tt-partar.nmpartar = crappat.nmpartar
                                   tt-partar.tpdedado = crappat.tpdedado.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
            END.

    END.
    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Inclusao de parametros
******************************************************************************/
PROCEDURE incluir-cadpar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmpartar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_tpdedado AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdprodut AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crappat WHERE crappat.cdpartar = par_cdpartar NO-LOCK NO-ERROR.

    IF  AVAIL(crappat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    CREATE crappat.
    ASSIGN crappat.cdpartar = par_cdpartar
           crappat.nmpartar = par_nmpartar
           crappat.tpdedado = par_tpdedado
           crappat.cdprodut = par_cdprodut.
    VALIDATE crappat.
    
    ASSIGN aux_dslogpar = "Incluiu novo parametro " + STRING(par_cdpartar) + ".".

    RUN geralog_cadpar(INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_nmdatela,
                       INPUT par_idorigem,
                       INPUT aux_dslogpar).
    
    IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".    
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Exclusao de parametros
******************************************************************************/
PROCEDURE excluir-cadpar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    FIND FIRST crappta WHERE crappta.cdpartar = par_cdpartar NO-LOCK NO-ERROR.

    IF AVAIL crappta THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Parametro vinculada a uma Tarifa!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.


    FIND FIRST crappco WHERE crappco.cdpartar = par_cdpartar NO-LOCK NO-ERROR.

    IF AVAIL crappco THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Operacao nao permitida. Parametro vinculada a uma Cooperativa!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    DEF BUFFER crabpco FOR crappco.

    TRANS_1:
    DO TRANSACTION ON ERROR UNDO:

        DO aux_contador = 1 TO 10:
    
            FIND crappat WHERE crappat.cdpartar = par_cdpartar
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAIL crappat THEN
    			DO:
    				IF  LOCKED crappat THEN
    					DO:
    						IF  aux_contador = 10 THEN
                                DO:
        							ASSIGN aux_cdcritic = 77.

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
                                    PAUSE 1 NO-MESSAGE.
    							    NEXT.
                                END.
    					END.
    				ELSE
        				DO:
                            ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
                LEAVE.
        END.


        FOR EACH crabpco WHERE crabpco.cdpartar = crappat.cdpartar
                   NO-LOCK:
        
            DO aux_contador = 1 TO 10:

                FIND crappco WHERE crappco.cdcooper = crabpco.cdcooper AND
                                   crappco.cdpartar = crabpco.cdpartar 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF  NOT AVAIL crappco THEN
                    DO:
                        IF  LOCKED crappco THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 77.

                                        RUN gera_erro (INPUT par_cdcooper,        
                                                       INPUT par_cdagenci,
                                                       INPUT 1, /* nrdcaixa  */
                                                       INPUT 1, /* sequencia */
                                                       INPUT aux_cdcritic,        
                                                       INPUT-OUTPUT aux_dscritic).
                                        UNDO TRANS_1, RETURN "NOK".
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Tentativa de excluir registro inexistente!".
        
                                RUN gera_erro (INPUT par_cdcooper,        
                                               INPUT par_cdagenci,
                                               INPUT 1, /* nrdcaixa  */
                                               INPUT 1, /* sequencia */
                                               INPUT aux_cdcritic,        
                                               INPUT-OUTPUT aux_dscritic).
                                UNDO TRANS_1, RETURN "NOK".
                            END.
                    END.
                ELSE
                    DO:
                        DELETE crappco.
                        LEAVE .
                    END.
                   
            END.
        END.
        
        DELETE crappat.
        LEAVE TRANS_1.

    END. /* Fim Transaction */
    
    ASSIGN aux_dslogpar = "Excluiu parametro " + STRING(par_cdpartar) + ".".
    
    RUN geralog_cadpar(INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_nmdatela,
                       INPUT par_idorigem,
                       INPUT aux_dslogpar).
    
    IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Alteracao de parametros
******************************************************************************/
PROCEDURE alterar-cadpar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmpartar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_tpdedado AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdprodut AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.
    DEF VAR aux_gerarlog         AS LOGI                    NO-UNDO.
    DEF VAR aux_nmpartar         AS CHAR                    NO-UNDO.
    DEF VAR aux_cdprodut         AS INTE                    NO-UNDO.
    
    DEF BUFFER crabprd FOR crapprd.

    DO aux_contador = 1 TO 10:

        FIND crappat WHERE crappat.cdpartar = par_cdpartar EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crappat THEN
			DO:
				IF  LOCKED crappat THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN aux_nmpartar = crappat.nmpartar
                      aux_cdprodut = crappat.cdprodut
                      crappat.cdpartar = par_cdpartar
                      crappat.nmpartar = par_nmpartar
                      crappat.tpdedado = par_tpdedado
                      crappat.cdprodut = par_cdprodut.
               LEAVE.
            END.
    END.

    ASSIGN aux_dslogpar = "Alterou parametro " + STRING(par_cdpartar) + ".".

    IF aux_nmpartar <> par_nmpartar THEN
        ASSIGN aux_gerarlog = TRUE 
               aux_dslogpar = aux_dslogpar + 
                              " Nome do parametro de: " + aux_nmpartar + " " +
                              "para: " + par_nmpartar + ".".

    IF aux_cdprodut <> par_cdprodut THEN
    DO: 
        IF aux_cdprodut <> 0 THEN
        DO:
            FIND FIRST crapprd WHERE crapprd.cdprodut = aux_cdprodut NO-LOCK NO-ERROR.
            IF NOT AVAIL crapprd THEN
            DO:
                ASSIGN aux_cdcritic = 0
    			       aux_dscritic = "Codigo produto nao encontrado 1!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        END.

        IF par_cdprodut <> 0 THEN
        DO:
            FIND FIRST crabprd WHERE crabprd.cdprodut = par_cdprodut NO-LOCK NO-ERROR.
            IF NOT AVAIL crapprd THEN
            DO:
                ASSIGN aux_cdcritic = 0
    			       aux_dscritic = "Codigo produto nao encontrado 2!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        END.

        ASSIGN aux_gerarlog = TRUE
               aux_dslogpar = aux_dslogpar + 
                              "Produto alterado de: " + crapprd.dsprodut + 
                              " para: " + crabprd.dsprodut + ".".

    END.

    IF aux_gerarlog THEN
        RUN geralog_cadpar(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT aux_dslogpar).
    
    IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".
                
END PROCEDURE.

/******************************************************************************
 Buscar de Parametros
******************************************************************************/
PROCEDURE buscar-cadpar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_nmpartar AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_tpdedado AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_cdprodut AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_dsprodut AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crappat WHERE crappat.cdpartar = par_cdpartar NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(crappat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND FIRST crapprd WHERE crapprd.cdprodut = crappat.cdprodut NO-LOCK NO-ERROR.

    IF  AVAIL(crapprd) THEN
        DO:
            ASSIGN par_cdprodut = crapprd.cdprodut
                   par_dsprodut = crapprd.dsprodut.    
        END.
    
    ASSIGN par_nmpartar = crappat.nmpartar
           par_tpdedado = crappat.tpdedado.
           
    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Gera log da tela cadpar 
******************************************************************************/
PROCEDURE geralog_cadpar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_descrlog AS CHAR                    NO-UNDO.
    
    DEF VAR aux_nmoperad AS CHAR                            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Erro ao procurar Cooperativa!".
    
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
        RUN sistema/generico/procedures/b1wgen0060.p
            PERSISTENT SET h-b1wgen0060.

    DYNAMIC-FUNCTION("BuscaOperador" IN h-b1wgen0060,
                                  INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                 OUTPUT aux_nmoperad,
                                 OUTPUT aux_dscritic).
    
    UNIX SILENT VALUE
        ("echo " + STRING(TODAY,"99/99/9999")          +
        " "     + STRING(TIME,"HH:MM:SS")+ "' --> '"   +
        " Operador " + par_cdoperad      + " - "       +
        aux_nmoperad + " " + par_descrlog              +
        " >> /usr/coop/" + TRIM(crapcop.dsdircop)      +
                         "/log/cadpar.log").

    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*                        tela cadpco                                      */
/***************************************************************************/

/******************************************************************************
 Inclusao de parametros pco
******************************************************************************/
PROCEDURE incluir-cadpco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsconteu AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND crappco WHERE crappco.cdpartar = par_cdpartar AND 
                       crappco.cdcooper = par_cdcopatu NO-LOCK NO-ERROR.

    IF  AVAIL(crappco) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    CREATE crappco.
    ASSIGN crappco.cdpartar = par_cdpartar
           crappco.cdcooper = par_cdcopatu
           crappco.dsconteu = par_dsconteu.
    VALIDATE crappco.

    ASSIGN aux_dslogpar = "Incluiu novo valor de parametro " + STRING(par_cdpartar) + ". " + 
                          "Cooperativa: " + STRING(par_cdcopatu) + 
                          ", Conteudo: "  + par_dsconteu.

    RUN geralog_cadpar(INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_cdoperad,
                       INPUT par_nmdatela,
                       INPUT par_idorigem,
                       INPUT aux_dslogpar).

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao de parametros pco
******************************************************************************/
PROCEDURE excluir-cadpco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.
    DEF VAR aux_gerarlog         AS LOGI                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crappco WHERE crappco.cdpartar = par_cdpartar AND
                           crappco.cdcooper = par_cdcopatu
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crappco THEN
			DO:
				IF  LOCKED crappco THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   ASSIGN aux_gerarlog = TRUE
                      aux_dslogpar = "Excluiu valor de parametro " + 
                                     STRING(par_cdpartar) + ". " + 
                                     "Cooperativa: " + STRING(par_cdcopatu) + 
                                     ", Conteudo: "  + crappco.dsconteu.
               DELETE crappco.
               LEAVE.
            END.
    END.

    IF  aux_gerarlog THEN
        RUN geralog_cadpar(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT aux_dslogpar).
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Alteracao de parametros pco
******************************************************************************/
PROCEDURE alterar-cadpco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dsconteu AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.
    DEF VAR aux_dsconteu         AS CHAR                    NO-UNDO.
    DEF VAR aux_gerarlog         AS LOGI                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crappco WHERE crappco.cdpartar = par_cdpartar AND
                           crappco.cdcooper = par_cdcopatu
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crappco THEN
			DO:
				IF  LOCKED crappco THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN crappco.cdpartar = par_cdpartar
                      crappco.cdcooper = par_cdcopatu
                      aux_dsconteu     = crappco.dsconteu
                      crappco.dsconteu = par_dsconteu.
               LEAVE.
            END.
    END.

    ASSIGN aux_dslogpar = "Alterou valor de parametro " + STRING(par_cdpartar) + ".".

    IF  aux_dsconteu <> par_dsconteu THEN
        ASSIGN aux_gerarlog = TRUE 
               aux_dslogpar = aux_dslogpar + 
                              " Cooperativa: " + STRING(par_cdcopatu) + 
                              " Conteudo de: " + aux_dsconteu + " " +
                              "para: " + par_dsconteu + ".".


    IF  aux_gerarlog THEN
        RUN geralog_cadpar(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT aux_dslogpar).
    
    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Buscar de Parametros pco
******************************************************************************/
PROCEDURE buscar-cadpco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_dsconteu AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_cdcoppar AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crappco WHERE crappco.cdpartar = par_cdpartar AND
                       crappco.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crappco) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    ASSIGN par_dsconteu = crappco.dsconteu
           par_cdcoppar = crappco.cdcooper.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Validar de Parametros pco
******************************************************************************/
PROCEDURE validar-cadpco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FIND crappco WHERE crappco.cdpartar = par_cdpartar AND
                       crappco.cdcooper = par_cdcopatu
                       NO-LOCK NO-ERROR.
    
    IF  AVAIL(crappco) THEN
        DO:
    
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro ja cadastrado!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Replicacao de parametros pco
******************************************************************************/
PROCEDURE replicar-cadpco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstcdcop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdscon AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cont    AS  INTE                            NO-UNDO.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):
        RUN incluir-cadpco(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT INTE(ENTRY(aux_cont,par_lstcdcop,';')),
                           INPUT par_cdpartar,
                           INPUT ENTRY(aux_cont,par_lstdscon,';'),
                           OUTPUT TABLE tt-erro).

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL(tt-erro) THEN
            DO:
                MESSAGE tt-erro.dscritic.
                RETURN "NOK".
            END.


    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de cooperativas
******************************************************************************/
PROCEDURE lista-cooperativas:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdcopaux AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-cooper.

    DEF VAR aux_nrregist AS INT.
    
    DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-cooper.
    
        ASSIGN aux_nrregist = par_nrregist.
        
        
        IF par_nmdatela = "TRNBCB" THEN
        	DO:
        		ASSIGN par_qtregist = par_qtregist + 1.
        		CREATE tt-cooper.
        		ASSIGN tt-cooper.cdcooper = 00
        			   tt-cooper.nmrescop = "TODAS".   
        	END.
        
        IF  par_cdcopaux = 0 THEN
            DO: 
                FOR EACH crapcop WHERE crapcop.nmrescop MATCHES("*" + par_nmrescop + "*")
                                   AND crapcop.flgativo = TRUE
                                 NO-LOCK BY crapcop.cdcooper:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-cooper.
                            ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
                                   tt-cooper.nmrescop = crapcop.nmrescop.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.

                END.
            END.
        ELSE
            DO:
                FOR EACH crapcop NO-LOCK WHERE crapcop.cdcooper >= par_cdcopaux AND
                                               crapcop.nmrescop MATCHES("*" + par_nmrescop + "*")  AND
                                               crapcop.flgativo = TRUE
                                         BY crapcop.cdcooper:

                    ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginacao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.

                    IF  aux_nrregist > 0 THEN
                        DO:
                            CREATE tt-cooper.
                            ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
                                   tt-cooper.nmrescop = crapcop.nmrescop.
                        END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Buscar de Cooperativas
******************************************************************************/
PROCEDURE buscar-cooperativa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM par_nmrescop AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcopatu AND 
                       crapcop.flgativo = TRUE NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapcop) THEN
        DO:
            ASSIGN aux_cdcritic = 794.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    par_nmrescop = crapcop.nmrescop.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de cooperativas para replicacao
******************************************************************************/
PROCEDURE replica-cooperativas:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-cooper.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-cooper.

    ASSIGN aux_nrregist = 0.

    FOR EACH crapcop NO-LOCK WHERE crapcop.cdcooper <> par_cdcopatu
                                BY crapcop.cdcooper:
        
        FIND crappco WHERE crappco.cdpartar = par_cdpartar AND
                           crappco.cdcooper = crapcop.cdcooper
                           NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL(crappco) THEN
            DO: 
                CREATE tt-cooper.
                ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
                       tt-cooper.nmrescop = crapcop.nmrescop
                       aux_nrregist = aux_nrregist + 1.
            END.

    END.


    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 carrega a tabela com os parametros por cooperativa
******************************************************************************/
PROCEDURE carrega-tabcadpar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdprodut AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-parametros.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-parametros.

    ASSIGN aux_nrregist = 0.
    
    FIND crappat WHERE crappat.cdpartar = par_cdpartar
                   AND crappat.cdprodut = par_cdprodut
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crappat) THEN
        RETURN "NOK".
    
    FOR EACH crappco NO-LOCK WHERE crappco.cdpartar = crappat.cdpartar
                                BY crappco.cdcooper:

        FIND crapcop WHERE crapcop.cdcooper = crappco.cdcooper 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapcop) THEN
            NEXT.
        
        CREATE tt-parametros.
        ASSIGN tt-parametros.cdcooper = crapcop.cdcooper
               tt-parametros.nmrescop = crapcop.nmrescop
               tt-parametros.cdpartar = crappat.cdpartar
               tt-parametros.dsconteu = crappco.dsconteu
               aux_nrregist = aux_nrregist + 1.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 vincula parametros para uma tarifa
******************************************************************************/
PROCEDURE vincula-parametro-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
          
    EMPTY TEMP-TABLE tt-erro.

    FIND crappta WHERE crappta.cdtarifa = par_cdtarifa AND
                       crappta.cdpartar = par_cdpartar
                       NO-LOCK NO-ERROR.

    IF  AVAIL(crappta) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE crappta.
    ASSIGN crappta.cdtarifa = par_cdtarifa
           crappta.cdpartar = par_cdpartar.
    VALIDATE crappta.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 desvincula parametros para uma tarifa
******************************************************************************/
PROCEDURE desvincula-parametro-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
          
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crappta WHERE crappta.cdtarifa = par_cdtarifa AND
                           crappta.cdpartar = par_cdpartar
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crappta THEN
			DO:
				IF  LOCKED crappta THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de desvincular registro inexistente!".

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
			   DELETE crappta.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de crappat 
******************************************************************************/
PROCEDURE lista-pat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-partar.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-partar.

    ASSIGN aux_nrregist = 0.
    
    FOR EACH crappta WHERE crappta.cdtarifa = par_cdtarifa NO-LOCK:

        FOR EACH crappat NO-LOCK WHERE crappat.cdpartar = crappta.cdpartar 
                                 BY crappta.cdpartar:
            CREATE tt-partar.
            ASSIGN tt-partar.cdpartar = crappat.cdpartar
                   tt-partar.nmpartar = crappat.nmpartar
                   aux_nrregist = aux_nrregist + 1.

        END.
    END.

END PROCEDURE.


/******************************************************************************
                                    TELA CADFCO
******************************************************************************/

/******************************************************************************
 Busca de novo codigo crapfco
******************************************************************************/
PROCEDURE busca-novo-cdfvlcop:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdfvlcop AS INTE                   NO-UNDO.

    ASSIGN par_cdfvlcop = 1.

    FIND LAST crapfco NO-LOCK NO-ERROR NO-WAIT.
            
    IF  AVAILABLE crapfco THEN
        ASSIGN par_cdfvlcop = crapfco.cdfvlcop + 1.

END PROCEDURE.

/******************************************************************************
 Inclusao de crapfco
******************************************************************************/
PROCEDURE incluir-cadfco:
    
    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfvlcop AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgvigen AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_vltarifa AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlrepass AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_dtdivulg AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtvigenc AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_flgnegat AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_nrconven AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
	DEF INPUT PARAM par_tpcobtar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vlpertar AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlmintar AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlmaxtar AS DECI                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgregis AS LOGICAL                         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  par_cdocorre = 0 THEN
        ASSIGN aux_flgregis = FALSE.
    ELSE
        ASSIGN aux_flgregis = TRUE.
    
    FIND crapfco WHERE crapfco.cdfaixav = par_cdfaixav AND
                       crapfco.cdcooper = par_cdcopatu AND
                       crapfco.dtvigenc = par_dtvigenc AND
                       crapfco.nrconven = par_nrconven AND 
                       crapfco.cdlcremp = par_cdlcremp 
                       NO-LOCK NO-ERROR.
    
    IF  AVAIL(crapfco) THEN
        DO:
            ASSIGN aux_cdcritic = 0
    			   aux_dscritic = "Registro ja existente!".
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    IF par_nrconven > 0 THEN DO:
    
        IF  par_cdinctar <> 4 THEN DO: /* Outros tipo de incidencias */

            FIND crapcco WHERE crapcco.cdcooper = par_cdcopatu
                           AND crapcco.nrconven = par_nrconven
                           AND crapcco.flgregis = aux_flgregis
                           AND crapcco.flgativo = TRUE
                           NO-LOCK NO-ERROR.
        
            IF  NOT AVAIL(crapcco) THEN DO:
                IF  aux_flgregis = FALSE THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = 
                              "Convenio de cobranca sem registro inexistente!".
                END.
                ELSE DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = 
                              "Convenio de cobranca registrada inexistente!".
                END.
        
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        END.
        ELSE DO: /* Tipo de incidencia 4 - FOLHA DE PAGAMENTO */

            FIND FIRST crapcfp WHERE crapcfp.cdcooper = par_cdcopatu
                                 AND crapcfp.cdcontar = par_nrconven
                                 NO-LOCK NO-ERROR.
                
            IF  NOT AVAIL(crapcfp) THEN DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Convenio de folha de pagamento inexistente!".
                
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

    IF par_cdlcremp > 0 THEN
    DO:
        FIND craplcr WHERE craplcr.cdcooper = par_cdcopatu AND
                           craplcr.cdlcremp = par_cdlcremp AND
                           craplcr.flgtarif = FALSE 
                           NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL(craplcr) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Linha de Credito inexistente!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
    END.

    CREATE crapfco.
    ASSIGN crapfco.cdfvlcop = par_cdfvlcop
           crapfco.cdcooper = par_cdcopatu
           crapfco.cdfaixav = par_cdfaixav
           crapfco.flgvigen = FALSE /* par_flgvigen */
           crapfco.vltarifa = par_vltarifa
           crapfco.vlrepass = par_vlrepass
           crapfco.dtdivulg = par_dtdivulg
           crapfco.dtvigenc = par_dtvigenc
           crapfco.nrconven = par_nrconven
           crapfco.cdlcremp = par_cdlcremp
           crapfco.cdoperad = par_cdoperad
		   crapfco.tpcobtar = par_tpcobtar
		   crapfco.vlpertar = par_vlpertar
		   crapfco.vlmintar = par_vlmintar
		   crapfco.vlmaxtar = par_vlmaxtar.
    VALIDATE crapfco.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Exclusao da crapfco
******************************************************************************/
PROCEDURE excluir-cadfco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfvlcop AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crapfco WHERE crapfco.cdfvlcop = par_cdfvlcop EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapfco THEN
			DO:
				IF  LOCKED crapfco THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de excluir registro inexistente!".

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
			   DELETE crapfco.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Alteracao da crapfco
******************************************************************************/
PROCEDURE alterar-cadfco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfvlcop AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgvigen AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_vltarifa AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlrepass AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_dtdivulg AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtvigenc AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_flgnegat AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_nrconven AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
	DEF INPUT PARAM par_tpcobtar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_vlpertar AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlmintar AS DECI                    NO-UNDO.
    DEF INPUT PARAM par_vlmaxtar AS DECI                    NO-UNDO.	

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.
    DEF VAR aux_flgregis         AS LOGICAL                 NO-UNDO.

    FIND crapfco WHERE crapfco.cdfvlcop <> par_cdfvlcop AND
                       crapfco.cdfaixav =  par_cdfaixav AND
                       crapfco.cdcooper =  par_cdcopatu AND
                       crapfco.dtvigenc =  par_dtvigenc AND
                       crapfco.nrconven =  par_nrconven AND
                       crapfco.cdlcremp =  par_cdlcremp 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapfco) THEN
    DO:

        DO aux_contador = 1 TO 10:
    
            FIND crapfco WHERE crapfco.cdfvlcop = par_cdfvlcop EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAIL crapfco THEN
    			DO:
    				IF  LOCKED crapfco THEN
    					DO:
    						IF  aux_contador = 10 THEN
                                DO:
        							ASSIGN aux_cdcritic = 77.

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
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
    					END.
    				ELSE
        				DO:
                            ASSIGN aux_cdcritic = 0
    				               aux_dscritic = "Tentativa de alterar registro inexistente!".
    
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
                    IF  par_cdinctar <> 4 THEN DO: /* Outros tipo de incidencias */
                    
                        IF  par_cdocorre = 0 THEN
                            ASSIGN aux_flgregis = FALSE.
                        ELSE
                            ASSIGN aux_flgregis = TRUE.
    
                        IF  par_nrconven > 0 THEN DO:
    
                            FIND crapcco WHERE crapcco.cdcooper = par_cdcopatu AND
                                               crapcco.nrconven = par_nrconven AND
                                               crapcco.flgativo = TRUE         AND
                                               crapcco.flgregis = aux_flgregis
                                               NO-LOCK NO-ERROR.
        
                            IF  NOT AVAIL(crapcco) THEN DO:
                                IF  aux_flgregis = FALSE THEN DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = 
                                              "Convenio de cobranca sem registro inexistente!".
                                END.
                                ELSE DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = 
                                              "Convenio de cobranca registrada inexistente!".
                                END.
            
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
                    ELSE DO: /* Tipo de incidencia 4 - FOLHA DE PAGAMENTO */
                        IF  par_nrconven > 0 THEN DO:
                            FIND FIRST crapcfp WHERE crapcfp.cdcooper = par_cdcopatu
                                                 AND crapcfp.cdcontar = par_nrconven
                                                 NO-LOCK NO-ERROR.
                            
                            IF  NOT AVAIL(crapcfp) THEN DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Convenio de folha de pagamento inexistente!".
                            
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

                   IF par_cdlcremp > 0 THEN
                   DO:
                        FIND craplcr WHERE craplcr.cdcooper = par_cdcopatu AND
                                           craplcr.cdlcremp = par_cdlcremp AND
                                           craplcr.flgtarif = FALSE
                                           NO-LOCK NO-ERROR.
                    
                        IF  NOT AVAIL(craplcr) THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Linha de Credito inexistente!".
                    
                                RUN gera_erro (INPUT par_cdcooper,        
                                               INPUT par_cdagenci,
                                               INPUT 1, /* nrdcaixa  */
                                               INPUT 1, /* sequencia */
                                               INPUT aux_cdcritic,        
                                               INPUT-OUTPUT aux_dscritic).
                                RETURN "NOK".
                            END.
                   END.

    			   ASSIGN crapfco.flgvigen = FALSE /* par_flgvigen */
                          crapfco.vltarifa = par_vltarifa
                          crapfco.vlrepass = par_vlrepass
                          crapfco.dtdivulg = par_dtdivulg
                          crapfco.dtvigenc = par_dtvigenc
                          crapfco.nrconven = par_nrconven
                          crapfco.cdlcremp = par_cdlcremp
                          crapfco.cdoperad = par_cdoperad
						  crapfco.tpcobtar = par_tpcobtar
		                  crapfco.vlpertar = par_vlpertar
		                  crapfco.vlmintar = par_vlmintar
		                  crapfco.vlmaxtar = par_vlmaxtar.
                   LEAVE.
                END.
        END.

    END.
    ELSE
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Ja existe registro para a mesma data de vigencia!".

        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT 1, /* nrdcaixa  */
                       INPUT 1, /* sequencia */
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Buscar da crapfco
******************************************************************************/
PROCEDURE buscar-cadfco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdfvlcop AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_flgvigen AS LOGICAL                NO-UNDO.
    DEF OUTPUT PARAM par_vltarifa AS DECI                   NO-UNDO.
    DEF OUTPUT PARAM par_vlrepass AS DECI                   NO-UNDO.
    DEF OUTPUT PARAM par_dtdivulg AS DATE                   NO-UNDO.
    DEF OUTPUT PARAM par_dtvigenc AS DATE                   NO-UNDO.
    DEF OUTPUT PARAM par_flgnegat AS LOGICAL                NO-UNDO.
    DEF OUTPUT PARAM par_nrconven AS INTE                   NO-UNDO.
	DEF OUTPUT PARAM par_tpcobtar AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_vlpertar AS DECI                   NO-UNDO.
    DEF OUTPUT PARAM par_vlmintar AS DECI                   NO-UNDO.
    DEF OUTPUT PARAM par_vlmaxtar AS DECI                   NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapfco WHERE crapfco.cdcooper = par_cdcopatu AND
                       crapfco.cdfaixav = par_cdfaixav NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapfco) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_cdfvlcop = crapfco.cdfvlcop
           par_flgvigen = crapfco.flgvigen
           par_vltarifa = crapfco.vltarifa
           par_vlrepass = crapfco.vlrepass
           par_dtdivulg = crapfco.dtdivulg
           par_dtvigenc = crapfco.dtvigenc
		   par_tpcobtar = crapfco.tpcobtar
           par_vlpertar = crapfco.vlpertar
           par_vlmintar = crapfco.vlmintar
           par_vlmaxtar = crapfco.vlmaxtar.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de Atribuicao Detalhamento
******************************************************************************/
PROCEDURE carrega-atribuicao-detalhamento:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_flgtodos AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-atribdet.

    DEF VAR aux_nrregist AS INT                             NO-UNDO.
    DEF VAR aux_qtregist AS INT                             NO-UNDO.

    DEF VAR aux_nrconven AS INT                             NO-UNDO.
    DEF VAR aux_dsconven AS CHAR                            NO-UNDO.

    DEF VAR aux_cdlcremp        LIKE craplcr.cdlcremp       NO-UNDO.
    DEF VAR aux_dslcremp        LIKE craplcr.dslcremp       NO-UNDO.
    DEF VAR aux_nmoperad        LIKE crapope.nmoperad       NO-UNDO.

    DEF VAR aux_nrseqatu AS INTE                            NO-UNDO.
    DEF VAR aux_nrseqini AS INTE                            NO-UNDO.
    DEF VAR aux_nrseqfim AS INTE                            NO-UNDO.

    EMPTY TEMP-TABLE tt-atribdet.

    ASSIGN aux_nrregist = 0.

    ASSIGN aux_nrseqatu = 0
           aux_nrseqini = par_nriniseq
           aux_nrseqfim = par_nriniseq + par_nrregist.

    IF par_cdtipcat <> 3 THEN /* Credito */
    DO:
    
        FOR EACH crapcop NO-LOCK BY cdcooper:
    
            ASSIGN aux_qtregist = 0.
    
            IF par_cdcooper <> 3 THEN
                DO:
                    IF crapcop.cdcooper <> par_cdcooper  THEN
                        NEXT.
                END.
    
            FOR EACH crapfco NO-LOCK WHERE crapfco.cdcooper = crapcop.cdcooper AND
                                           crapfco.cdfaixav = par_cdfaixav     
                                           BY crapfco.nrconven
                                           BY crapfco.dtdivulg DESC:

                IF  aux_nrconven <> crapfco.nrconven THEN
                    ASSIGN aux_qtregist = 0.

                IF aux_qtregist = 3 THEN
                    DO:
                        IF aux_nrconven = 0 THEN 
                            LEAVE.
            
                        NEXT.   /* Cobranca */
                    END.

                IF ( par_flgtodos = FALSE ) THEN
                    ASSIGN aux_qtregist = aux_qtregist + 1.
        
                FIND crapcco WHERE crapcco.cdcooper = crapfco.cdcooper AND
                                   crapcco.nrconven = crapfco.nrconven 
                                   NO-LOCK NO-ERROR.
    
                ASSIGN aux_nrconven = 0
                       aux_dsconven = "".
    
                IF  AVAIL(crapcco) THEN
                    ASSIGN aux_nrconven = crapcco.nrconven
                           aux_dsconven = crapcco.dsorgarq.
                ELSE DO:

                    /* Se nao achar na CRAPCCO, verificar se o
                    convenio e do servico de folha de pagamento */

                    FIND FIRST crapcfp WHERE crapcfp.cdcooper = crapfco.cdcooper
                                         AND crapcfp.cdcontar = crapfco.nrconven 
                                         NO-LOCK NO-ERROR.

                    IF  AVAIL crapcfp THEN
                        ASSIGN aux_nrconven = crapcfp.cdcontar
                               aux_dsconven = crapcfp.dscontar.
                END.

    
                /* Busca o nome do operador (PRJ - 218) */
                ASSIGN aux_nmoperad = "".
                FOR FIRST crapope FIELDS(nmoperad) WHERE crapope.cdoperad = crapfco.cdoperad NO-LOCK.
                    aux_nmoperad = STRING(crapfco.cdoperad) + " - " + crapope.nmoperad.
                END.  

                ASSIGN aux_nrseqatu = aux_nrseqatu + 1.

                IF aux_nrseqatu < aux_nrseqini  OR
                       aux_nrseqatu >= aux_nrseqfim THEN
                        DO:
                            NEXT.
                        END.

                CREATE tt-atribdet.
                ASSIGN tt-atribdet.cdfvlcop = crapfco.cdfvlcop
                       tt-atribdet.cdfaixav = crapfco.cdfaixav
                       tt-atribdet.cdcooper = crapfco.cdcooper 
                       tt-atribdet.vltarifa = crapfco.vltarifa
                       tt-atribdet.vlrepass = crapfco.vlrepass
                       tt-atribdet.dtdivulg = crapfco.dtdivulg
                       tt-atribdet.dtvigenc = crapfco.dtvigenc  
                       tt-atribdet.nmrescop = crapcop.nmrescop 
                       tt-atribdet.nrconven = aux_nrconven
                       tt-atribdet.dsconven = aux_dsconven
                       tt-atribdet.nmoperad = aux_nmoperad
					   tt-atribdet.tpcobtar = crapfco.tpcobtar
					   tt-atribdet.vlpertar = crapfco.vlpertar
					   tt-atribdet.vlmintar = crapfco.vlmintar
					   tt-atribdet.vlmaxtar = crapfco.vlmaxtar
                       aux_nrregist = aux_nrregist + 1.

            END.
    
        END.

    END.
    ELSE
    DO:
        FOR EACH crapcop NO-LOCK BY cdcooper:
    
            ASSIGN aux_qtregist = 0.
    
            IF par_cdcooper <> 3 THEN
                DO:
                    IF crapcop.cdcooper <> par_cdcooper  THEN
                        NEXT.
                END.
			
			FOR EACH crapfco NO-LOCK WHERE crapfco.cdcooper = crapcop.cdcooper AND
                                           crapfco.cdfaixav = par_cdfaixav     
                                           BY crapfco.cdlcremp
                                           BY crapfco.dtdivulg DESC:
    
                IF  aux_cdlcremp <> crapfco.cdlcremp THEN
                    ASSIGN aux_qtregist = 0.

                IF  aux_qtregist = 3 THEN
                    NEXT.   
    
                IF ( par_flgtodos = FALSE ) THEN
                    ASSIGN aux_qtregist = aux_qtregist + 1.
        
                FIND craplcr WHERE craplcr.cdcooper = crapfco.cdcooper AND
                                   craplcr.cdlcremp = crapfco.cdlcremp 
                                   NO-LOCK NO-ERROR.
    
                ASSIGN aux_cdlcremp = 0
                       aux_dsconven = "".
    
                IF  AVAIL(craplcr) THEN
                    ASSIGN aux_cdlcremp = craplcr.cdlcremp
                           aux_dslcremp = craplcr.dslcremp.

                /* Busca o nome do operador (PRJ - 218) */
                ASSIGN aux_nmoperad = "".
                FOR FIRST crapope FIELDS(nmoperad) WHERE crapope.cdoperad = crapfco.cdoperad NO-LOCK:
                    aux_nmoperad = STRING(crapfco.cdoperad) + " - " + crapope.nmoperad. 
                END.

                ASSIGN aux_nrseqatu = aux_nrseqatu + 1.
                
                IF aux_nrseqatu < aux_nrseqini  OR
                       aux_nrseqatu >= aux_nrseqfim THEN
                        DO:
                            NEXT.
                        END.

                CREATE tt-atribdet.
                ASSIGN tt-atribdet.cdfvlcop = crapfco.cdfvlcop
                       tt-atribdet.cdfaixav = crapfco.cdfaixav
                       tt-atribdet.cdcooper = crapfco.cdcooper 
                       tt-atribdet.vltarifa = crapfco.vltarifa
                       tt-atribdet.vlrepass = crapfco.vlrepass
                       tt-atribdet.dtdivulg = crapfco.dtdivulg
                       tt-atribdet.dtvigenc = crapfco.dtvigenc  
                       tt-atribdet.nmrescop = crapcop.nmrescop 
                       tt-atribdet.cdlcremp = aux_cdlcremp
                       tt-atribdet.dslcremp = aux_dslcremp
                       tt-atribdet.nmoperad = aux_nmoperad
					   tt-atribdet.tpcobtar = crapfco.tpcobtar
					   tt-atribdet.vlpertar = crapfco.vlpertar
					   tt-atribdet.vlmintar = crapfco.vlmintar
					   tt-atribdet.vlmaxtar = crapfco.vlmaxtar					   
                       aux_nrregist = aux_nrregist + 1.
    
            END.
        END.
    END.

	ASSIGN par_qtregist = aux_nrseqatu.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Listagem de cooperativas para replicacao no detalhamento de tarifas
******************************************************************************/
PROCEDURE replica-cooperativas-det:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdlcratu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcat AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-cooper.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-cooper.

    ASSIGN aux_nrregist = 0.

    IF par_cdtipcat <> 3 THEN
    DO:

        FOR EACH crapcop NO-LOCK WHERE crapcop.cdcooper <> par_cdcopatu
                                    BY crapcop.cdcooper:
           
            CREATE tt-cooper.
            ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
                   tt-cooper.nmrescop = crapcop.nmrescop
                   aux_nrregist = aux_nrregist + 1.
    
        END.  
    END.
    ELSE
    DO:

        FOR EACH crapcop NO-LOCK:

            IF ( ( crapcop.cdcooper = par_cdcopatu ) AND ( par_cdlcratu = 0 ) ) THEN
            DO:
                /* Nao deve criar registro */
            END.
            ELSE
            DO:

                CREATE tt-cooper.
                ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
                       tt-cooper.nmrescop = crapcop.nmrescop
                       tt-cooper.cdlcremp = 0
                       aux_nrregist = aux_nrregist + 1.
            END.


            FOR EACH craplcr NO-LOCK WHERE NOT(craplcr.cdcooper = par_cdcopatu  AND
                                               craplcr.cdlcremp = par_cdlcratu) AND
                                               craplcr.flgtarif = FALSE         AND
                                               craplcr.cdcooper =  crapcop.cdcooper
                                               BY craplcr.cdcooper:
    
               /* FIND FIRST crapcop WHERE crapcop.cdcooper = craplcr.cdcooper 
                                         NO-LOCK NO-ERROR.*/
    
                CREATE tt-cooper.
                ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
                       tt-cooper.nmrescop = crapcop.nmrescop
                       tt-cooper.cdlcremp = craplcr.cdlcremp
                       aux_nrregist = aux_nrregist + 1.
    
            END.
        END.

    END.


    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de cooperativas para replicacao no detalhamento de tarifas cobranca
******************************************************************************/
PROCEDURE replica-cooperativas-det-cob:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcopatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrcnvatu AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-cooper.

    DEF VAR aux_nrregist AS INTE                            NO-UNDO.
    DEF VAR aux_flgregis AS LOGICAL                         NO-UNDO.
    
    EMPTY TEMP-TABLE tt-cooper.

    ASSIGN aux_nrregist = 0.

    IF  par_cdocorre = 0 THEN
        aux_flgregis = FALSE.
    ELSE
        aux_flgregis = TRUE.

    IF  par_cdinctar <> 4  THEN DO:
        
        FOR EACH crapcco NO-LOCK WHERE NOT(crapcco.cdcooper = par_cdcopatu  AND
                                           crapcco.nrconven = par_nrcnvatu) AND
                                           crapcco.flgregis = aux_flgregis AND
                                           crapcco.flgativo = TRUE
                                           BY crapcco.cdcooper:
    
            FIND crapcop WHERE crapcop.cdcooper = crapcco.cdcooper 
                               NO-LOCK NO-ERROR.
    
            CREATE tt-cooper.
            ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
                   tt-cooper.nmrescop = crapcop.nmrescop
                   tt-cooper.nrconven = crapcco.nrconven
                   aux_nrregist = aux_nrregist + 1.
    
        END.

    END.
    ELSE DO:

        FOR EACH crapcfp NO-LOCK WHERE NOT(crapcfp.cdcooper = par_cdcopatu  AND
                                           crapcfp.cdcontar = par_nrcnvatu)
                                           BY crapcfp.cdcooper:
    
            FIND crapcop WHERE crapcop.cdcooper = crapcfp.cdcooper 
                               NO-LOCK NO-ERROR.
    
            CREATE tt-cooper.
            ASSIGN tt-cooper.cdcooper = crapcfp.cdcooper
                   tt-cooper.nmrescop = crapcop.nmrescop
                   tt-cooper.nrconven = crapcfp.cdcontar
                   aux_nrregist = aux_nrregist + 1.
    
        END.

    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Replicacao de parametros fco
******************************************************************************/
PROCEDURE replicar-cadfco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstcdcop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtdiv AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtvig AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvlrep AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvltar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgvigen AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_flgnegat AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_lstconve AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstlcrem AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
	DEF INPUT PARAM par_lsttptar AS CHAR                    NO-UNDO.
	DEF INPUT PARAM par_lstvlper AS CHAR                    NO-UNDO.
	DEF INPUT PARAM par_lstvlmin AS CHAR                    NO-UNDO.
	DEF INPUT PARAM par_lstvlmax AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cont             AS INTE                    NO-UNDO.
    DEF VAR aux_cdfvlcop         AS INTE                    NO-UNDO.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        RUN busca-novo-cdfvlcop(INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                OUTPUT aux_cdfvlcop).

        RUN incluir-cadfco(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT aux_cdfvlcop,
                           INPUT INTE(ENTRY(aux_cont,par_lstcdcop,';')),
                           INPUT par_cdfaixav,
                           INPUT par_flgvigen,
                           INPUT DECI(ENTRY(aux_cont,par_lstvltar,';')),
                           INPUT DECI(ENTRY(aux_cont,par_lstvlrep,';')),
                           INPUT DATE(ENTRY(aux_cont,par_lstdtdiv,';')),
                           INPUT DATE(ENTRY(aux_cont,par_lstdtvig,';')),
                           INPUT par_flgnegat,
                           INPUT INTE(ENTRY(aux_cont,par_lstconve,';')),
                           INPUT par_cdocorre,
                           INPUT INTE(ENTRY(aux_cont,par_lstlcrem,';')),
                           INPUT par_cdinctar,
						   INPUT INTE(ENTRY(aux_cont,par_lsttptar,';')),
						   INPUT DECI(ENTRY(aux_cont,par_lstvlper,';')),
						   INPUT DECI(ENTRY(aux_cont,par_lstvlmin,';')),
						   INPUT DECI(ENTRY(aux_cont,par_lstvlmax,';')),
                           OUTPUT TABLE tt-erro).

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL(tt-erro) THEN
           DO:
               RETURN "NOK".
           END.

    END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE valida-replicacao:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstcdcop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtdiv AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtvig AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvlrep AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvltar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgvigen AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_flgnegat AS LOGICAL                 NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cont             AS INTE                    NO-UNDO.
    DEF VAR aux_cdfvlcop         AS INTE                    NO-UNDO.
    DEF VAR aux_msgerr           AS CHAR                    NO-UNDO.
    DEF VAR aux_flgerr           AS LOGICAL INITIAL FALSE   NO-UNDO.
    DEF VAR aux_quebra           AS INTE                    NO-UNDO.

    /*verificacao de registro duplicado*/
    ASSIGN aux_msgerr = 'Ja existem registros com mesma data' +
                        ' de vigencia para a(s) Cooperativa(s): </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        FIND FIRST crapfco WHERE crapfco.cdfaixav = par_cdfaixav        AND
                                 crapfco.cdcooper = 
                                 INTE(ENTRY(aux_cont,par_lstcdcop,';')) AND
                                 crapfco.dtvigenc = 
                                 DATE(ENTRY(aux_cont,par_lstdtvig,';')) 
                                 NO-LOCK NO-ERROR.

        IF  AVAIL(crapfco) THEN
            DO:
                ASSIGN aux_quebra = aux_quebra + 1
                       aux_msgerr = aux_msgerr + 
                                    ENTRY(aux_cont,par_lstcdcop,';') + ', '
                       aux_flgerr = TRUE.

                IF  aux_quebra = 10 THEN
                    DO:
                        ASSIGN aux_msgerr = aux_msgerr + '</br>'
                               aux_quebra = 0.
                    END.             
            END.

    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    /*verifica registros com data vigencia menor que a data atual*/
    ASSIGN aux_msgerr = 'Existem registros com data' +
                        ' de vigencia menor ou igual a data atual' +
                        ' para a(s) Cooperativa(s): </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  AVAIL(crapdat) THEN
            DO:
                IF  DATE(ENTRY(aux_cont,par_lstdtvig,';')) <= 
                    crapdat.dtmvtolt THEN
                DO:
                    ASSIGN aux_quebra = aux_quebra + 1
                           aux_msgerr = aux_msgerr + 
                                        ENTRY(aux_cont,par_lstcdcop,';') + ', '
                           aux_flgerr = TRUE.

                    IF  aux_quebra = 10 THEN
                        DO:
                            ASSIGN aux_msgerr = aux_msgerr + '</br>'
                                   aux_quebra = 0.
                        END.

                END.
            END.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.    

    /*verifica registros com data divulgacao menor que a data vigencia*/
    ASSIGN aux_msgerr = 'Existem registros com data' +
                        ' de divulgacao maior ou igual a data vigencia' +
                        ' para a(s) Cooperativa(s): </br>'
            aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        IF  DATE(ENTRY(aux_cont,par_lstdtdiv,';')) >=
            DATE(ENTRY(aux_cont,par_lstdtvig,';')) THEN
        DO:
            ASSIGN aux_quebra = aux_quebra + 1
                   aux_msgerr = aux_msgerr + 
                                ENTRY(aux_cont,par_lstcdcop,';') + ', '
                   aux_flgerr = TRUE.

            IF  aux_quebra = 10 THEN
                DO:
                    ASSIGN aux_msgerr = aux_msgerr + '</br>'
                           aux_quebra = 0.
                END. 
        END.

    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.    

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-replicacao-cob: 

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstcdcop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtdiv AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtvig AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvlrep AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvltar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgvigen AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_flgnegat AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_lstconve AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cont             AS INTE                    NO-UNDO.
    DEF VAR aux_cdfvlcop         AS INTE                    NO-UNDO.
    DEF VAR aux_msgerr           AS CHAR                    NO-UNDO.
    DEF VAR aux_flgerr           AS LOGICAL INITIAL FALSE   NO-UNDO.
    DEF VAR aux_quebra           AS INTE                    NO-UNDO.


    /*verificacao de registro duplicado*/
    ASSIGN aux_msgerr = 'Ja existem registros com mesma data' +
                        ' de vigencia para o(s) Convenio(s): </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        FIND FIRST crapfco WHERE crapfco.cdfaixav = par_cdfaixav        AND
                                 crapfco.cdcooper = 
                                 INTE(ENTRY(aux_cont,par_lstcdcop,';')) AND
                                 crapfco.dtvigenc = 
                                 DATE(ENTRY(aux_cont,par_lstdtvig,';')) AND
                                 crapfco.nrconven = 
                                 INTE(ENTRY(aux_cont,par_lstconve,';')) 
                                 NO-LOCK NO-ERROR.

        IF  AVAIL(crapfco) THEN
            DO:
                ASSIGN aux_quebra = aux_quebra + 1
                       aux_msgerr = aux_msgerr + 
                                    ENTRY(aux_cont,par_lstconve,';') + ', '
                       aux_flgerr = TRUE.

                IF  aux_quebra = 10 THEN
                    DO:
                        ASSIGN aux_msgerr = aux_msgerr + '</br>'
                               aux_quebra = 0.
                    END.
            END.

    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    /*verifica registros com data vigencia menor que a data atual*/
    ASSIGN aux_msgerr = 'Existem registros com data' +
                        ' de vigencia menor ou igual a data atual' +
                        ' para o(s) Convenio(s): </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  AVAIL(crapdat) THEN
            DO:
                IF  DATE(ENTRY(aux_cont,par_lstdtvig,';')) <= 
                    crapdat.dtmvtolt THEN
                DO:
                    ASSIGN aux_quebra = aux_quebra + 1
                           aux_msgerr = aux_msgerr + 
                                        ENTRY(aux_cont,par_lstconve,';') + ', '
                           aux_flgerr = TRUE.

                    IF  aux_quebra = 10 THEN
                        DO:
                            ASSIGN aux_msgerr = aux_msgerr + '</br>'
                                   aux_quebra = 0.
                        END.

                END.
            END.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.    

    /*verifica registros com data divulgacao maior que a data vigencia*/
    ASSIGN aux_msgerr = 'Existem registros com data' +
                        ' de divulgacao maior ou igual a data vigencia' +
                        ' para o(s) Convenio(s): </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        IF  DATE(ENTRY(aux_cont,par_lstdtdiv,';')) >=
            DATE(ENTRY(aux_cont,par_lstdtvig,';')) THEN
        DO:
            ASSIGN aux_quebra = aux_quebra + 1
                   aux_msgerr = aux_msgerr + 
                                ENTRY(aux_cont,par_lstconve,';') + ', '
                   aux_flgerr = TRUE.

            IF  aux_quebra = 10 THEN
                DO:
                    ASSIGN aux_msgerr = aux_msgerr + '</br>'
                           aux_quebra = 0.
                END.     
        END.

    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.    

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Carrega a tabela pesquisa associados
******************************************************************************/
PROCEDURE carrega-tabassociado:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdpartar AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cagencia AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtipcta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nmprimtl AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgchcus AS LOGICAL                 NO-UNDO.
    DEF INPUT PARAM par_mespsqch AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_anopsqch AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO. /* Nro Registros a serem mostrados */
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-associados.

    DEF VAR aux_nrregist        AS INT.

    DEF VAR aux_data            AS CHAR.

    DEF VAR aux_dtinipes        AS DATE.
    DEF VAR aux_dtfimpes        AS DATE.

    EMPTY TEMP-TABLE tt-associados.

    ASSIGN aux_nrregist = par_nrregist.

    IF  par_nmprimtl = ""  THEN
        ASSIGN par_nmprimtl = "*".
    ELSE
    DO:
        ASSIGN par_nmprimtl = RIGHT-TRIM(par_nmprimtl," ") + "*".
        ASSIGN par_nmprimtl = "*" + LEFT-TRIM(par_nmprimtl," ").
    END.

    IF ( par_flgchcus = FALSE ) THEN
    DO:

        FOR EACH crapass NO-LOCK WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.inpessoa = par_inpessoa AND
                                       crapass.dtdemiss = ?            AND  
                                       crapass.nmprimtl MATCHES par_nmprimtl:
    
            IF par_cagencia > 0 THEN
            DO:
                IF crapass.cdagenci <> par_cagencia THEN
                    NEXT.
            END.
    
            IF par_cdtipcta > 0 THEN
             DO:
                IF crapass.cdtipcta <> par_cdtipcta THEN
                    NEXT.
            END.  
    
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
            RUN STORED-PROCEDURE pc_descricao_tipo_conta
              aux_handproc = PROC-HANDLE NO-ERROR
                                      (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                       INPUT crapass.cdtipcta, /* Tipo de conta */
                                      OUTPUT "",               /* Descriçao do Tipo de conta */
                                      OUTPUT "",               /* Flag Erro */
                                      OUTPUT "").              /* Descriçao da crítica */
    
            CLOSE STORED-PROC pc_descricao_tipo_conta
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_dstipcta = ""
                   aux_des_erro = ""
                   aux_dscritic = ""
                   aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                                   WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
                   aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                                   WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
                   aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                                   WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
            
            IF aux_des_erro = "NOK"  THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
    
            ASSIGN par_qtregist = par_qtregist + 1.
    
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.
    
            IF aux_nrregist > 0 THEN
            DO:
    
                CREATE tt-associados.
                ASSIGN tt-associados.nrdconta = crapass.nrdconta
                       tt-associados.nmprimtl = crapass.nmprimtl
                       tt-associados.cdagenci = crapass.cdagenci
                       tt-associados.inpessoa = crapass.inpessoa
                       tt-associados.cdtipcta = crapass.cdtipcta
                       tt-associados.dstipcta = aux_dstipcta
                       tt-associados.nrmatric = crapass.nrmatric.

            END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
    
        END.
    END.

    IF ( par_flgchcus = TRUE ) THEN
    DO:

        aux_data = "01/" + STRING(par_mespsqch) + "/" + STRING(par_anopsqch). 

        aux_dtinipes = DATE(aux_data).
        aux_dtfimpes = ADD-INTERVAL(aux_dtinipes,1,'months') - 1.

        FOR EACH crapcst NO-LOCK WHERE crapcst.cdcooper = par_cdcooper  AND
                                       crapcst.dtmvtolt >= aux_dtinipes AND
                                       crapcst.dtmvtolt <= aux_dtfimpes 
                                       BREAK BY crapcst.nrdconta: 

            IF FIRST-OF(crapcst.nrdconta)  THEN 
            DO:

                FIND FIRST crapass WHERE crapass.cdcooper = crapcst.cdcooper  AND
                                         crapass.nrdconta = crapcst.nrdconta  AND 
                                         crapass.inpessoa = par_inpessoa      AND
                                         crapass.nmprimtl MATCHES par_nmprimtl
                                         NO-LOCK NO-ERROR.
    
                IF AVAIL(crapass) THEN
                DO:
            
                    IF par_cagencia > 0 THEN
                    DO:
                        IF crapass.cdagenci <> par_cagencia THEN
                            NEXT.
                    END.
            
                    IF par_cdtipcta > 0 THEN
                     DO:
                        IF crapass.cdtipcta <> par_cdtipcta THEN
                            NEXT.
                    END.  
            
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                    RUN STORED-PROCEDURE pc_descricao_tipo_conta
                      aux_handproc = PROC-HANDLE NO-ERROR
                                              (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                               INPUT crapass.cdtipcta, /* Tipo de conta */
                                              OUTPUT "",               /* Descriçao do Tipo de conta */
                                              OUTPUT "",               /* Flag Erro */
                                              OUTPUT "").              /* Descriçao da crítica */
                    
                    CLOSE STORED-PROC pc_descricao_tipo_conta
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                    
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    ASSIGN aux_dstipcta = ""
                           aux_des_erro = ""
                           aux_dscritic = ""
                           aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                                           WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
                           aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                                           WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
                           aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                                           WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
                    
                    IF aux_des_erro = "NOK"  THEN
                        DO:
                            RUN gera_erro (INPUT par_cdcooper,        
                                           INPUT par_cdagenci,
                                           INPUT 1, /* nrdcaixa  */
                                           INPUT 1, /* sequencia */
                                           INPUT aux_cdcritic,        
                                           INPUT-OUTPUT aux_dscritic).
                            RETURN "NOK".
                        END.
            
                   ASSIGN par_qtregist = par_qtregist + 1.
            
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.
            
                    IF aux_nrregist > 0 THEN
                    DO:

                        CREATE tt-associados.
                        ASSIGN tt-associados.nrdconta = crapass.nrdconta
                               tt-associados.nmprimtl = crapass.nmprimtl
                               tt-associados.cdagenci = crapass.cdagenci
                               tt-associados.inpessoa = crapass.inpessoa
                               tt-associados.cdtipcta = crapass.cdtipcta
                               tt-associados.dstipcta = aux_dstipcta
                               tt-associados.nrmatric = crapass.nrmatric
                               tt-associados.qtdchcus = 0.

                    END.

                    ASSIGN aux_nrregist = aux_nrregist - 1.
            
                END.
            END.
        END.
    END.

    FOR EACH tt-associados EXCLUSIVE-LOCK:

        FOR EACH crapcst NO-LOCK WHERE crapcst.cdcooper = par_cdcooper  AND
                                       crapcst.dtmvtolt >= aux_dtinipes AND
                                       crapcst.dtmvtolt <= aux_dtfimpes AND
                                       crapcst.nrdconta = tt-associados.nrdconta: 


            ASSIGN tt-associados.qtdchcus = tt-associados.qtdchcus + 1.

        END.

    END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
 Lista dados do associado a partir de uma lista de contas
*****************************************************************************/
PROCEDURE lista-associado:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstconta AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-associados.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.
    DEF VAR aux_nrdconta         AS INTE                    NO-UNDO.

    EMPTY TEMP-TABLE tt-associados.

    /*Iterar sobre a lista de contas separadas por ';'*/
    DO aux_contador=1 TO NUM-ENTRIES(par_lstconta,';'):

        aux_nrdconta = INTE(ENTRY(aux_contador,par_lstconta,';')).

        /*busca conta na crapass*/
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.

        /*se encontrou cria a temp table tt-associados*/
        IF  AVAIL(crapass) THEN
            DO:

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                RUN STORED-PROCEDURE pc_descricao_tipo_conta
                  aux_handproc = PROC-HANDLE NO-ERROR
                                          (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                           INPUT crapass.cdtipcta, /* Tipo de conta */
                                          OUTPUT "",               /* Descriçao do Tipo de conta */
                                          OUTPUT "",               /* Flag Erro */
                                          OUTPUT "").              /* Descriçao da crítica */
                
                CLOSE STORED-PROC pc_descricao_tipo_conta
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                ASSIGN aux_dstipcta = ""
                       aux_des_erro = ""
                       aux_dscritic = ""
                       aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                                       WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
                       aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                                       WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
                       aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                                       WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.

                IF aux_des_erro = "OK"  THEN
                    DO:
                        CREATE tt-associados.
                        ASSIGN tt-associados.nrdconta = crapass.nrdconta
                               tt-associados.nrctafmt = STRING(crapass.nrdconta,"zzzz,zzz.9")
                               tt-associados.nrctafmt = REPLACE(tt-associados.nrctafmt,",","-")
                               tt-associados.nmprimtl = crapass.nmprimtl
                               tt-associados.cdagenci = crapass.cdagenci
                               tt-associados.inpessoa = crapass.inpessoa
                               tt-associados.cdtipcta = crapass.cdtipcta
                               tt-associados.dstipcta = aux_dstipcta
                               tt-associados.nrmatric = crapass.nrmatric
                               tt-associados.qtdchcus = 0.
                    END.

            END.
    END.


    RETURN "OK".
END PROCEDURE.

/*****************************************************************************
Lancamento manul de tarifas
******************************************************************************/
PROCEDURE lancamento-manual-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstconta AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lsthisto AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstqtdla AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lsvlrtar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lsqtdchq AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lsfvlcop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_flgerlog AS LOGICAL                 NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_cont        AS  INTE                            NO-UNDO.
    DEF VAR aux_conta       AS  INTE                            NO-UNDO.
    DEF VAR aux_qtd         AS  INTE                            NO-UNDO.

    DEF VAR par_cdhistor    AS  INTE                            NO-UNDO.
    DEF VAR qtd_lancamen    AS  INTE                            NO-UNDO.
    DEF VAR par_vllanaut    AS  DECI                            NO-UNDO.
    DEF VAR par_nrdconta    AS  INTE                            NO-UNDO.
    DEF VAR par_cdfvlcop    AS  INTE                            NO-UNDO.

    DEF VAR aux_cdcadast    AS  INTE                            NO-UNDO.
    DEF VAR qtd_chqcusto    AS  INTE                            NO-UNDO. 

    DEF VAR aux_vllanaut    AS DEC                              NO-UNDO.

    DO aux_cont=1 TO NUM-ENTRIES(par_lsthisto,';'):

        /* Codigo Historico*/
        par_cdhistor = INTE(ENTRY(aux_cont,par_lsthisto,';')).

        /* Quantidade de Lancamento */ 
        qtd_lancamen = INTE(ENTRY(aux_cont,par_lstqtdla,';')).

        /* Valor do Lancamento */ 
        par_vllanaut = DECI(ENTRY(aux_cont,par_lsvlrtar,';')).

        /* Codigo Lancamento crapfco */
        par_cdfvlcop = INTE(ENTRY(aux_cont,par_lsfvlcop,';')).

        /* Leitura Lista de Contas*/
        DO aux_conta=1 TO NUM-ENTRIES(par_lstconta,';'):

            /* Conta */
            par_nrdconta = INTE(ENTRY(aux_conta,par_lstconta,';')).

            /* Quantidade Cheque Custodia */
            qtd_chqcusto = INTE(ENTRY(aux_conta,par_lsqtdchq,';')).

            FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                     crapass.nrdconta = par_nrdconta  
                                     NO-LOCK NO-ERROR.

            IF AVAIL crapass THEN
            DO:

                /* Tratamento para cheque em custodia*/
                IF par_inpessoa = 1 THEN
                    DO:
                        FIND FIRST crapbat NO-LOCK WHERE crapbat.cdbattar = "CUSTDCTOPF" AND 
                                                         crapbat.tpcadast = 1 NO-ERROR.

                        IF AVAIL crapbat THEN
                        DO:
                            FIND FIRST crapfvl NO-LOCK WHERE crapfvl.cdtarifa = crapbat.cdcadast 
                                USE-INDEX crapfvl4 NO-ERROR.

                                IF NOT AVAIL crapfvl THEN
                                    DO:
                                        ASSIGN aux_cdcadast = 0.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcadast = crapfvl.cdhistor.
                                    END.
                                    
                        END.
                        
    
                    END.
                ELSE
                    DO:
                        FIND FIRST crapbat NO-LOCK WHERE crapbat.cdbattar = "CUSTDCTOPJ" AND
                                                         crapbat.tpcadast = 1 NO-ERROR.

                        IF AVAIL crapbat THEN
                        DO:
                            FIND FIRST crapfvl NO-LOCK WHERE crapfvl.cdtarifa = crapbat.cdcadast 
                                USE-INDEX crapfvl4 NO-ERROR.

                                IF NOT AVAIL crapfvl THEN
                                    DO:
                                        ASSIGN aux_cdcadast = 0.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcadast = crapfvl.cdhistor.
                                    END.
                        END.
                    END.

                /* Verifica se eh historico de cheque em custodia e se existe cheques a serem lancados*/
                IF ( par_cdhistor = aux_cdcadast ) AND ( qtd_chqcusto > 0)THEN
                    DO:

                        /* Conforme orientacao Felipe deve ser efetuado um unico lancamento com 
                        o valor total dos cheques em custodia */
                        ASSIGN aux_vllanaut = ( par_vllanaut * qtd_chqcusto ).
                        
                        /* CRAPLAT*/
                        RUN cria_lan_auto_tarifa(INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_cdhistor,
                                                 INPUT aux_vllanaut,
                                                 INPUT par_cdoperad,
                                                 INPUT crapass.cdagenci,
                                                 INPUT 100,                 /* cdbccxlt */
                                                 INPUT 10127,               /* nrdolote */
                                                 INPUT 1,                   /* tpdolote */
                                                 INPUT 0,                   /* nrdocmto */
                                                 INPUT crapass.nrdconta,    /* nrdctabb */
                                                 INPUT crapass.nrdctitg,    /* nrdctitg */
                                                 INPUT 'LANTAR',            /* cdpesqbb */
                                                 INPUT 0,                   /* cdbanchq */
                                                 INPUT 0,                   /* cdagechq */
                                                 INPUT 0,                   /* nrctachq */
                                                 INPUT FALSE,               /* flgaviso */
                                                 INPUT 0,                   /* tpdaviso */
                                                 INPUT par_cdfvlcop,        /* cdfvlcop */
                                                 INPUT par_inproces,        /* inproces */
                                                 OUTPUT TABLE tt-erro).

                    END.
                ELSE
                    IF qtd_lancamen > 0 THEN
                    DO:
                        /* Efetua lancamento conforme quantidade informada */
                        DO aux_qtd=1 TO qtd_lancamen:
        
                            /* CRAPLAT*/
                            RUN cria_lan_auto_tarifa(INPUT par_cdcooper,
                                                     INPUT par_nrdconta,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_cdhistor,
                                                     INPUT par_vllanaut,
                                                     INPUT par_cdoperad,
                                                     INPUT crapass.cdagenci,
                                                     INPUT 100,                 /* cdbccxlt */
                                                     INPUT 10127,               /* nrdolote */
                                                     INPUT 1,                   /* tpdolote */
                                                     INPUT 0,                   /* nrdocmto */
                                                     INPUT crapass.nrdconta,    /* nrdctabb */
                                                     INPUT crapass.nrdctitg,    /* nrdctitg */
                                                     INPUT 'LANTAR',            /* cdpesqbb */
                                                     INPUT 0,                   /* cdbanchq */
                                                     INPUT 0,                   /* cdagechq */
                                                     INPUT 0,                   /* nrctachq */
                                                     INPUT FALSE,               /* flgaviso */
                                                     INPUT 0,                   /* tpdaviso */
                                                     INPUT par_cdfvlcop,        /* cdfaixav */
                                                     INPUT par_inproces,        /* inproces */
                                                     OUTPUT TABLE tt-erro).
                                         
                        END.
                    END.
            END.
        END.


        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL(tt-erro) THEN
            DO:
                MESSAGE tt-erro.dscritic.
                RETURN "NOK".
            END.

    END.

  

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Busca associado - ESTTAR
******************************************************************************/
PROCEDURE busca-associado:

    DEF INPUT PARAM par_cdcooper    AS  INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS  INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_cdagenci   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_nrmatric   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdtipcta   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_dstipcta   AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl   AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_inpessoa   AS  INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_nmresage   AS  CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapass) THEN
        DO: 
            ASSIGN aux_cdcritic = 9. /* Associado nao cadastrado*/ 

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF crapass.dtdemiss <> ? THEN
        DO: 
            ASSIGN aux_cdcritic = 64.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    RUN STORED-PROCEDURE pc_descricao_tipo_conta
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT crapass.inpessoa, /* Tipo de pessoa */
                               INPUT crapass.cdtipcta, /* Tipo de conta */
                              OUTPUT "",               /* Descriçao do Tipo de conta */
                              OUTPUT "",               /* Flag Erro */
                              OUTPUT "").              /* Descriçao da crítica */
    
    CLOSE STORED-PROC pc_descricao_tipo_conta
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dstipcta = ""
           aux_des_erro = ""
           aux_dscritic = ""
           aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                           WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
           aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                           WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
           aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                           WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.

    IF aux_des_erro = "NOK"  THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Tipo de conta inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        
    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = crapass.cdagenci
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapage) THEN
        DO:
            ASSIGN aux_cdcritic = 15.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_cdagenci = crapass.cdagenci
           par_nrmatric = crapass.nrmatric
           par_cdtipcta = crapass.cdtipcta
           par_dstipcta = aux_dstipcta
           par_nmprimtl = crapass.nmprimtl
           par_inpessoa = crapass.inpessoa
           par_nmresage = crapage.nmresage.

    RETURN "OK".
END PROCEDURE.    

/*****************************************************************************
Estorno/Baixa de lancamento de tarifas
******************************************************************************/
PROCEDURE estorno-baixa-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddopcap AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lscdlant AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lscdmote AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOGICAL                 NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cont        AS  INTE                        NO-UNDO.
    DEF VAR aux_contador    AS  INTE                        NO-UNDO.
    DEF VAR aux_qtd         AS  INTE                        NO-UNDO.

    DEF VAR aux_cdlantar    AS  INTE                        NO-UNDO.
    DEF VAR aux_cdmotest    AS  INTE                        NO-UNDO.
    DEF VAR par_cdhisest    AS  INTE                        NO-UNDO.

    DEF VAR aux_dstransa    AS CHAR                         NO-UNDO.
    DEF VAR aux_dsorigem    AS CHAR                         NO-UNDO.
    DEF VAR aux_nrdrowid    AS ROWID                        NO-UNDO.
    DEF VAR aux_dscritic    AS CHAR                         NO-UNDO.
    DEF VAR aux_cdhistor    AS INTE                         NO-UNDO.

    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF par_cddopcap = 1 THEN 
                             "Estorno de tarifa."
                          ELSE IF par_cddopcap = 3 THEN 
                             "Suspensao de tarifa." 
                           ELSE
                             "Baixa de tarifa.".

    DO aux_cont=1 TO NUM-ENTRIES(par_lscdlant,';'):

        /* Codigo Lantar*/
        aux_cdlantar = INTE(ENTRY(aux_cont,par_lscdlant,';')).

        /* Motivo Estorno */ 
        aux_cdmotest = INTE(ENTRY(aux_cont,par_lscdmote,';')).

        
        lat:
        DO TRANSACTION ON ERROR UNDO,  LEAVE
                   ON ENDKEY UNDO, LEAVE:

            DO aux_contador = 1 TO 10:
    
                FIND craplat WHERE craplat.cdlantar = aux_cdlantar
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAIL craplat THEN
                    DO:
                        IF  LOCKED craplat THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    UNDO, LEAVE.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                            END.
                        ELSE
                             UNDO, LEAVE.
                    END.
                ELSE
                    DO:
                        IF par_cddopcap = 1 OR
                           par_cddopcap = 3 THEN /* 1 - Estorno  3- Suspensão*/
                            DO:
                                ASSIGN craplat.insitlat = 4 /* Estornado */
                                       craplat.cdmotest = aux_cdmotest 
                                       craplat.dtdestor = par_dtmvtolt
                                       craplat.cdopeest = par_cdoperad.

                                ASSIGN aux_cdhistor = craplat.cdhistor.
                                
                                FIND crapfco WHERE crapfco.cdfvlcop =  craplat.cdfvlcop
                                                                       NO-LOCK NO-ERROR.

                                IF AVAIL crapfco THEN
                                DO:

                                    FIND crapfvl WHERE crapfvl.cdfaixav =  crapfco.cdfaixav
                                                                           NO-LOCK NO-ERROR.
    
                                    IF AVAIL crapfvl THEN
                                    DO:
                                        ASSIGN par_cdhisest = crapfvl.cdhisest. 
    
    
                                        FIND crapass WHERE crapass.nrdconta = par_nrdconta AND
                                                           crapass.cdcooper = par_cdcooper
                                                           NO-LOCK NO-ERROR.
    
                                        IF AVAIL crapass THEN
                                        DO:
                    
                                            /* Gerar Lancamento Estorno CRAPLCM*/
                                            RUN lan_tarifa_conta_corrente(INPUT par_cdcooper,
                                                                          INPUT craplat.cdagenci,
                                                                          INPUT par_nrdconta,
                                                                          INPUT craplat.cdbccxlt,       /* cdbccxlt */
                                                                          INPUT craplat.nrdolote,       /* nrdolote */
                                                                          INPUT 1,                      /* tplotmov */
                                                                          INPUT par_cdoperad,
                                                                          INPUT par_dtmvtolt,
                                                                          INPUT craplat.nrdctabb,       /* nrdctabb */
                                                                          INPUT craplat.nrdctitg,       /* nrdctitg */
                                                                          INPUT par_cdhisest,
                                                                          INPUT craplat.cdpesqbb,       /* cdpesqbb */
                                                                          INPUT craplat.cdbanchq,       /* cdbanchq */
                                                                          INPUT craplat.cdagechq,       /* cdagechq */
                                                                          INPUT craplat.nrctachq,       /* nrctachq */
                                                                          INPUT FALSE,                  /* flgaviso */
                                                                          INPUT 0,                      /* cdsecext */
                                                                          INPUT 0,                      /* tpdaviso */
                                                                          INPUT craplat.vltarifa,       /* vltarifa */
                                                                          INPUT craplat.nrdocmto,       /* nrdocmto */
                                                                          INPUT crapass.cdagenci,       /* cdageass */
																		  INPUT 0,                      /* cdcoptfn */
                                                                          INPUT 0,                      /* cdagetfn */
                                                                          INPUT 0,                      /* nrterfin */
                                                                          INPUT 0,                      /* nrsequni */
                                                                          INPUT 0,                      /* nrautdoc */
                                                                          INPUT "",                     /* dsidenti */
                                                                          INPUT par_inproces,           /* inproces */
                                                                          OUTPUT TABLE tt-erro).

                                            ASSIGN aux_dscritic = "".

                                            /* Buscar Critica */
                                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                            IF AVAIL(tt-erro) THEN
                                                DO:
                                                    ASSIGN aux_dscritic = tt-erro.dscritic
                                                           aux_cdhistor = craplat.cdhistor.                                        
                                                END.
                                        END.
                                      END.
                                END.
                                IF par_cddopcap = 3 THEN /* 3- Suspensão*/
                                   DO:
                                    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
                                    /* CRAPLAT*/
                                    RUN cria_lan_auto_tarifa(INPUT par_cdcooper,
                                                             INPUT par_nrdconta,
                                                             INPUT crapdat.dtmvtopr,
                                                             INPUT craplat.cdhistor,
                                                             INPUT craplat.vltarifa,
                                                             INPUT par_cdoperad,
                                                             INPUT craplat.cdagenci,
                                                             INPUT craplat.cdbccxlt,    /* cdbccxlt */
                                                             INPUT craplat.nrdolote,    /* nrdolote */
                                                             INPUT craplat.tpdolote,    /* tpdolote */
                                                             INPUT craplat.nrdocmto,    /* nrdocmto */
                                                             INPUT craplat.nrdconta,    /* nrdctabb */
                                                             INPUT craplat.nrdctitg,    /* nrdctitg */
                                                             INPUT 'ESTTAR',            /* cdpesqbb */
                                                             INPUT craplat.cdbanchq,    /* cdbanchq */
                                                             INPUT craplat.cdagechq,    /* cdagechq */
                                                             INPUT craplat.nrctachq,    /* nrctachq */
                                                             INPUT FALSE,               /* flgaviso */
                                                             INPUT 0,                   /* tpdaviso */
                                                             INPUT craplat.cdfvlcop,    /* cdfaixav */
                                                             INPUT par_inproces,        /* inproces */
                                                             OUTPUT TABLE tt-erro).


                                    ASSIGN aux_dscritic = "".

                                    /* Buscar Critica */
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    IF AVAIL(tt-erro) THEN
                                       DO:
                                        ASSIGN aux_dscritic = tt-erro.dscritic.
                                                                                  
                                      END.

                            END.

                            END.
                        ELSE /* 2 - Baixa */
                            DO:      
                                ASSIGN craplat.insitlat = 3             /* Baixado */
                                       craplat.cdmotest = aux_cdmotest 
                                       craplat.dtdestor = par_dtmvtolt
                                       craplat.cdopeest = par_cdoperad.

                                ASSIGN aux_cdhistor = craplat.cdhistor.

                            END.
                    END.
    
                LEAVE.
            END. /* fim do do contador */
                                                         
            /* Se encontrar critica */
            IF aux_dscritic <> "" THEN
                DO:
                    /* apagar as alteraçoes*/
                    UNDO lat, LEAVE. /* Sair do loop */
                END.
            ELSE
                DO:
                
                    /* Gerar log */
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT "",
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT TRUE,
                                        INPUT 1,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                       
                    /* Chave */
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "cdlantar",
                                             INPUT "",
                                             INPUT aux_cdlantar).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "cdhistor",
                                             INPUT "",
                                             INPUT aux_cdhistor).
                    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "dtdestor",
                                             INPUT "",
                                             INPUT par_dtmvtolt).
                    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "cdmotest",
                                             INPUT "",
                                             INPUT aux_cdmotest).
    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "cdopeest",
                                             INPUT "",
                                             INPUT par_cdoperad).
    
                END.

            /* ////////////////////////////
            NAO APAGAR ESTA PARTE COMENTADA
            ///////////////////////////////
            NAO APAGAR ESTA PARTE COMENTADA
            ///////////////////////////////
            NAO APAGAR ESTA PARTE COMENTADA
            ///////////////////////////// */

/*
            DO aux_contador = 1 TO 10:

                FIND FIRST craplau WHERE craplau.cdcooper = craplat.cdcooper AND
                                         craplau.dtmvtolt = craplat.dtmvtolt AND
                                         craplau.cdbccxlt = craplat.cdbccxlt AND
                                         craplau.nrdolote = craplat.nrdolote AND
                                         craplau.nrdctabb = craplat.nrdctabb AND
                                         craplau.nrdocmto = craplat.nrdocmto
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                    IF  NOT AVAIL craplau THEN
                        DO:
                            IF  LOCKED craplau THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        UNDO, LEAVE.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE
                            DO:
                                  UNDO, LEAVE.
                            END.
                        END.
                    ELSE
                        DO:
                            ASSIGN craplau.insitlau = 3. /* Baixado */
                        END.
            END.
*/
            

        END.


        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL(tt-erro) THEN
            DO:
                MESSAGE tt-erro.dscritic.

                /* Gerar log */
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
                /* Chave */
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdlantar",
                                         INPUT "",
                                         INPUT aux_cdlantar).
                
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdhistor",
                                         INPUT "",
                                         INPUT aux_cdhistor).

                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtdestor",
                                         INPUT "",
                                         INPUT par_dtmvtolt).
                
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdmotest",
                                         INPUT "",
                                         INPUT aux_cdmotest).

                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdopeest",
                                         INPUT "",
                                         INPUT par_cdoperad).

                RETURN "NOK".
            END.

    END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE carrega_dados_tarifa_cobranca:

    DEF INPUT  PARAM par_cdcooper   AS      INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrdconta   AS      INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrconven   LIKE    crapcco.nrconven            NO-UNDO.
    DEF INPUT  PARAM par_dsincide   AS      CHAR                        NO-UNDO.
    DEF INPUT  PARAM par_cdocorre   LIKE    craptar.cdocorre            NO-UNDO.
    DEF INPUT  PARAM par_cdmotivo   LIKE    craptar.cdmotivo            NO-UNDO.
    DEF INPUT  PARAM par_inpessoa   LIKE    craptar.inpessoa            NO-UNDO.
    DEF INPUT  PARAM par_vllanmto   AS      DEC                         NO-UNDO.
    DEF INPUT  PARAM par_cdprogra   AS      CHAR                        NO-UNDO.
	DEF INPUT  PARAM par_flaputar   AS      INTE                        NO-UNDO.

    DEF OUTPUT PARAM par_cdhistor   AS      INTE                        NO-UNDO.
    DEF OUTPUT PARAM par_cdhisest   AS      INTE                        NO-UNDO.
    DEF OUTPUT PARAM par_vltarifa   AS      DEC                         NO-UNDO.
    DEF OUTPUT PARAM par_dtdivulg   AS      DATE                        NO-UNDO.
    DEF OUTPUT PARAM par_dtvigenc   AS      DATE                        NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcop   AS      INTE                        NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_cdhistor            AS      INTE                        NO-UNDO.
    DEF VAR aux_cdhisest            AS      INTE                        NO-UNDO.
    DEF VAR aux_vltarifa            AS      DEC                         NO-UNDO.
    DEF VAR aux_dtdivulg            AS      DATE                        NO-UNDO.
    DEF VAR aux_dtvigenc            AS      DATE                        NO-UNDO.
    DEF VAR aux_cdfvlcop            AS      INTE                        NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_carrega_dados_tarifa_cobr aux_handproc = PROC-HANDLE NO-ERROR
       (INPUT  par_cdcooper
       ,INPUT  par_nrdconta
       ,INPUT  par_nrconven
       ,INPUT  par_dsincide
       ,INPUT  par_cdocorre
       ,INPUT  par_cdmotivo
       ,INPUT  par_inpessoa
       ,INPUT  par_vllanmto
       ,INPUT  par_cdprogra
	   ,INPUT  par_flaputar
       ,OUTPUT 0    /* cdhistor */
       ,OUTPUT 0    /* cdhisest */
       ,OUTPUT 0    /* vltarifa */
       ,OUTPUT ?    /* dtdivulg */
       ,OUTPUT ?    /* dtvigenc */
       ,OUTPUT 0    /* cdfvlcop */
       ,OUTPUT 0    /* cdcritic */
       ,OUTPUT ""). /* dscritic */

    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.

        ASSIGN aux_msgerora = "Erro ao executar Stored Procedure: " + aux_msgerora.
                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT 1, /* cdagenci  */
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                       INPUT 0, /* cdcritic */
                       INPUT-OUTPUT aux_msgerora).
                    RETURN "NOK".
    END.

    CLOSE STORED-PROCEDURE pc_carrega_dados_tarifa_cobr WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
                ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdhistor = 0
           aux_cdhisest = 0
           aux_vltarifa = 0
           aux_dtdivulg = ?
           aux_dtvigenc = ?
           aux_cdfvlcop = 0
           aux_cdcritic = pc_carrega_dados_tarifa_cobr.pr_cdcritic 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_cdcritic <> ?
           aux_dscritic = pc_carrega_dados_tarifa_cobr.pr_dscritic 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_dscritic <> ?
           aux_cdhistor = pc_carrega_dados_tarifa_cobr.pr_cdhistor 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_cdhistor <> ?
           aux_cdhisest = pc_carrega_dados_tarifa_cobr.pr_cdhisest 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_cdhisest <> ?
           aux_vltarifa = pc_carrega_dados_tarifa_cobr.pr_vltarifa 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_vltarifa <> ?
           aux_dtdivulg = pc_carrega_dados_tarifa_cobr.pr_dtdivulg 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_dtdivulg <> ?
           aux_dtvigenc = pc_carrega_dados_tarifa_cobr.pr_dtvigenc 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_dtvigenc <> ?
           aux_cdfvlcop = pc_carrega_dados_tarifa_cobr.pr_cdfvlcop 
                          WHEN pc_carrega_dados_tarifa_cobr.pr_cdfvlcop <> ?.

    /* Se possui critica */
    IF  aux_dscritic <> "" THEN
        DO: 
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_cdhistor = aux_cdhistor
           par_cdhisest = aux_cdhisest
           par_vltarifa = aux_vltarifa
           par_dtdivulg = aux_dtdivulg
           par_dtvigenc = aux_dtvigenc
           par_cdfvlcop = aux_cdfvlcop.


            RETURN "OK".
END PROCEDURE.


PROCEDURE carrega_dados_tarifa_emprestimo:

    DEF INPUT  PARAM par_cdcooper   AS      INTE                        NO-UNDO.
    DEF INPUT  PARAM par_cdlcremp   LIKE    crapfco.cdlcremp            NO-UNDO.
    DEF INPUT  PARAM par_cdmotivo   LIKE    craptar.cdmotivo            NO-UNDO.
    DEF INPUT  PARAM par_inpessoa   LIKE    craptar.inpessoa            NO-UNDO.
    DEF INPUT  PARAM par_vllanmto   AS      DEC                         NO-UNDO.
    DEF INPUT  PARAM par_cdprogra   AS      CHAR                        NO-UNDO.

    DEF OUTPUT PARAM par_cdhistor   AS      INTE                        NO-UNDO.
    DEF OUTPUT PARAM par_cdhisest   AS      INTE                        NO-UNDO.
    DEF OUTPUT PARAM par_vltarifa   AS      DEC                         NO-UNDO.
    DEF OUTPUT PARAM par_dtdivulg   AS      DATE                        NO-UNDO.
    DEF OUTPUT PARAM par_dtvigenc   AS      DATE                        NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcop   AS      INTE                        NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_contador            AS      INTE                        NO-UNDO.
    DEF VAR aux_cdfvlcop            AS      INTE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST  craptar WHERE craptar.cdmotivo = par_cdmotivo     AND
                              craptar.inpessoa = par_inpessoa
                              NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craptar) THEN
        DO: 
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Erro Tarifa!" +
                                  " Mot: "     + par_cdmotivo         +
                                  " Lcr: "     + STRING(par_cdlcremp) +
                                  " P"         + IF par_inpessoa = 1 THEN
                                                     "F"
                                                 ELSE
                                                     "J".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND LAST crapfvl WHERE crapfvl.cdtarifa  = craptar.cdtarifa AND
                            crapfvl.vlinifvl <= par_vllanmto     AND
                            crapfvl.vlfinfvl >= par_vllanmto
                            USE-INDEX crapfvl4 NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapfvl THEN
        DO: 
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Erro Faixa Valor!" +
                                  "Tar: " + STRING(craptar.cdtarifa) +
                                  " Vlr: " + STRING(par_vllanmto).

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                       craplcr.cdlcremp = par_cdlcremp 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craplcr) THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Erro Linha Credito! " +
                                  "Linha: " + STRING(par_cdlcremp).
    
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  craplcr.flgtarif = TRUE THEN
        DO:
          ASSIGN par_cdlcremp = 0.
        END.
    ELSE
        DO:
          ASSIGN par_cdhistor = crapfvl.cdhistor
                 par_cdhisest = crapfvl.cdhisest
                 par_vltarifa = 0.
                 
          RETURN "OK".
          
        END.
        
    ASSIGN aux_contador = 0.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  AVAIL(crapdat)        AND 
        crapdat.inproces > 1 THEN
    DO:
        EMPTY TEMP-TABLE tt-vigenc.

        FOR EACH crapfco WHERE crapfco.cdcooper = par_cdcooper     AND
                               crapfco.cdlcremp = par_cdlcremp     AND
                               crapfco.cdfaixav = crapfvl.cdfaixav AND
                               crapfco.flgvigen = TRUE NO-LOCK:

            CREATE tt-vigenc.
            ASSIGN tt-vigenc.cdfvlcop = crapfco.cdfvlcop
                   tt-vigenc.dtvigenc = crapfco.dtvigenc
                   tt-vigenc.cdlcremp = crapfco.cdlcremp
                   tt-vigenc.cdocorre = craptar.cdocorre
                   tt-vigenc.cdmotivo = craptar.cdmotivo
                   tt-vigenc.cdfaixav = crapfvl.cdfaixav
                   tt-vigenc.qtdiavig = crapdat.dtmvtolt - crapfco.dtvigenc 
                   aux_contador = aux_contador + 1.

        END.
    END.

    IF  aux_contador > 1 THEN
        DO:
            /* tiago */
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + par_cdprogra + "' --> '"  +
                              "ERRO: Multiplos detalhamentos vigentes: Tar " +
                              STRING(crapfvl.cdtarifa)
                              +  " >> log/proc_batch.log").

            FOR EACH tt-vigenc NO-LOCK BY tt-vigenc.qtdiavig:

                IF  aux_cdfvlcop = 0        AND
                    tt-vigenc.qtdiavig >= 0 THEN
                    DO:
                        FIND crapfco WHERE crapfco.cdfvlcop = tt-vigenc.cdfvlcop
                                           NO-LOCK NO-ERROR.

                        ASSIGN aux_cdfvlcop = tt-vigenc.cdfvlcop.
                    END.

                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")     +
                                  " - " + par_cdprogra + "' --> '"    +
                                  "Fvl: " + STRING(tt-vigenc.cdfaixav)  +
                                  " Fco: " + STRING(tt-vigenc.cdfvlcop) + 
                                  " Vig: " + STRING(tt-vigenc.dtvigenc) +
                                  " Lcr: " + STRING(tt-vigenc.cdlcremp) +
                                  " Mot: " + STRING(tt-vigenc.cdmotivo) +
                                  " >> log/proc_batch.log").
            END.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + par_cdprogra + "' --> '"  +
                              "Selecionado detalhamento: " +
                              STRING(aux_cdfvlcop)
                              +  " >> log/proc_batch.log").
        END.
    ELSE
        DO: 
            FIND crapfco WHERE crapfco.cdcooper = par_cdcooper     AND
                               crapfco.cdlcremp = par_cdlcremp     AND
                               crapfco.cdfaixav = crapfvl.cdfaixav AND
                               crapfco.flgvigen = TRUE
                               NO-LOCK NO-ERROR.
        END.

    IF  NOT AVAIL crapfco THEN
        DO: 
            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

            ASSIGN aux_cdcritic  = 0
                   aux_dscritic  = "Tarifa: "  + STRING(craptar.cdtarifa) + chr(13) +
                                   "Faixa Valor: " + STRING(crapfvl.cdfaixav) + chr(13) +
                                   "Linha Credito: " + STRING(par_cdlcremp)
                   aux_dsassunto = "Erro Faixa Valor Coop.: " + crapcop.nmrescop.  

            /* Faz a solicitacao de envio de email informando Erro de faixa de Valor */
            RUN solicitar_envio_email(INPUT par_cdcooper,
                                      INPUT par_cdprogra,
                                      INPUT aux_dsemail,
                                      INPUT aux_dsassunto,
                                      INPUT aux_dscritic).
            RETURN "OK".
        END.

      /*Retornar valores*/
      /* TARIFA POR PERCENTUAL*/
      IF crapfco.tpcobtar = 2 THEN
        DO:
		  ASSIGN par_vltarifa = par_vllanmto * (crapfco.vlpertar / 100).
 
          /*VERIFICA LIMITE MÍNIMO*/
          IF par_vltarifa < crapfco.vlmintar THEN
            DO:
			  ASSIGN par_vltarifa = crapfco.vlmintar.
			END.
          /*VERIFICA LIMITE MÁXIMO*/
          IF par_vltarifa > crapfco.vlmaxtar THEN
            DO:
			  ASSIGN par_vltarifa = crapfco.vlmaxtar.
			END.
		END.
        /* TARIFA FIXA*/
      ELSE
	    DO:
          ASSIGN par_vltarifa = crapfco.vltarifa.
		END.	


    ASSIGN par_cdhistor = crapfvl.cdhistor
           par_cdhisest = crapfvl.cdhisest
           par_dtdivulg = crapfco.dtdivulg
           par_dtvigenc = crapfco.dtvigenc
           par_cdfvlcop = crapfco.cdfvlcop.


    RETURN "OK".
END PROCEDURE.

/****************************************************************************
#############################################################################
****************************************************************************/

/****************************************************************************/
/******** Procedure responsavel em carregar dados da tarifa vigente *********/
/****************************************************************************/

PROCEDURE carrega_dados_tarifa_vigente:

    DEF INPUT  PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT  PARAM par_cdbattar AS CHAR                               NO-UNDO.
    DEF INPUT  PARAM par_vllanmto AS DEC                                NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM par_cdhistor AS INTE                               NO-UNDO.
    DEF OUTPUT PARAM par_cdhisest AS INTE                               NO-UNDO.
    DEF OUTPUT PARAM par_vltarifa AS DEC                                NO-UNDO.
    DEF OUTPUT PARAM par_dtdivulg AS DATE                               NO-UNDO.
    DEF OUTPUT PARAM par_dtvigenc AS DATE                               NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcop AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_contador          AS INTE                               NO-UNDO.
    DEF VAR aux_cdfvlcop          AS INTE                               NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(crapcop) THEN
        DO:
            ASSIGN aux_cdcritic = 794.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1,  /* cdagenci  */ 
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    IF  NOT crapcop.flgativo THEN
        RETURN "OK".
    
    FIND FIRST crapbat WHERE crapbat.cdbattar = par_cdbattar /* Sigla Tarifa */
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapbat THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = par_cdbattar + 
                                  " - Sigla da tarifa nao cadastrada!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */ 
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND craptar WHERE craptar.cdtarifa = crapbat.cdcadast /* Codigo Tarifa */
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptar THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = par_cdbattar + 
                                  " - Tarifa nao cadastrada!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND LAST crapfvl WHERE crapfvl.cdtarifa  = craptar.cdtarifa AND
                            crapfvl.vlinifvl <= par_vllanmto     AND
                            crapfvl.vlfinfvl >= par_vllanmto
                            USE-INDEX crapfvl4 NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapfvl THEN
        DO: 
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = par_cdbattar +
                                  " - Erro Faixa Valor! " +
                                  "Tar: " + STRING(craptar.cdtarifa) +
                                  " Vlr: " + STRING(par_vllanmto).

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN aux_contador = 0.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  AVAIL(crapdat)        AND 
        crapdat.inproces > 1 THEN
    DO:
        EMPTY TEMP-TABLE tt-vigenc.

        FOR EACH crapfco WHERE crapfco.cdcooper = par_cdcooper     AND
                               crapfco.cdfaixav = crapfvl.cdfaixav AND
                               crapfco.flgvigen = TRUE NO-LOCK:

            CREATE tt-vigenc.
            ASSIGN tt-vigenc.cdfvlcop = crapfco.cdfvlcop
                   tt-vigenc.dtvigenc = crapfco.dtvigenc
                   tt-vigenc.cdfaixav = crapfvl.cdfaixav
                   tt-vigenc.qtdiavig = crapdat.dtmvtolt - crapfco.dtvigenc
                   aux_contador = aux_contador + 1.

        END.
    END.

    IF  aux_contador > 1 THEN
        DO:
            /* tiago */
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + par_cdprogra + "' --> '"  +
                              "ERRO: Multiplos detalhamentos vigentes: Tar " +
                              STRING(crapfvl.cdtarifa)
                              +  " >> log/proc_batch.log").

            FOR EACH tt-vigenc NO-LOCK BY tt-vigenc.qtdiavig:

                IF  aux_cdfvlcop = 0        AND
                    tt-vigenc.qtdiavig >= 0 THEN
                    DO:
                        FIND crapfco WHERE crapfco.cdfvlcop = tt-vigenc.cdfvlcop
                                           NO-LOCK NO-ERROR.

                        ASSIGN aux_cdfvlcop = tt-vigenc.cdfvlcop.
                    END.

                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + par_cdprogra + "' --> '"  +
                                  "Fvl: " + STRING(tt-vigenc.cdfaixav) +
                                  " Fco: " + STRING(tt-vigenc.cdfvlcop) + 
                                  " Vig: " + STRING(tt-vigenc.dtvigenc) +
                                  " >> log/proc_batch.log").
            END.
                
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + par_cdprogra + "' --> '"  +
                              "Selecionado detalhamento: " +
                              STRING(aux_cdfvlcop)
                              +  " >> log/proc_batch.log").
        END.
    ELSE
        DO: 
            FIND crapfco WHERE crapfco.cdcooper = par_cdcooper     AND
                               crapfco.cdfaixav = crapfvl.cdfaixav AND
                               crapfco.flgvigen = TRUE
                               NO-LOCK NO-ERROR.
        END.

    IF  NOT AVAIL crapfco THEN
        DO: 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = par_cdbattar +
                                  " - Erro Faixa Valor Coop. " +
                                  "Tar: "  + STRING(craptar.cdtarifa) +
                                  " Fvl: " + STRING(crapfvl.cdfaixav).

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

      /*Retornar valores*/
      /* TARIFA POR PERCENTUAL*/
      IF crapfco.tpcobtar = 2 THEN
        DO:
		  ASSIGN par_vltarifa = par_vllanmto * (crapfco.vlpertar / 100).
 
          /*VERIFICA LIMITE MÍNIMO*/
          IF par_vltarifa < crapfco.vlmintar THEN
            DO:
			  ASSIGN par_vltarifa = crapfco.vlmintar.
			END.
          /*VERIFICA LIMITE MÁXIMO*/
          IF par_vltarifa > crapfco.vlmaxtar THEN
            DO:
			  ASSIGN par_vltarifa = crapfco.vlmaxtar.
			END.
		END.
        /* TARIFA FIXA*/
      ELSE
	    DO:
          ASSIGN par_vltarifa = crapfco.vltarifa.
		END.

            
    ASSIGN par_cdhistor = crapfvl.cdhistor
           par_cdhisest = crapfvl.cdhisest
           par_dtdivulg = crapfco.dtdivulg
           par_dtvigenc = crapfco.dtvigenc
           par_cdfvlcop = crapfco.cdfvlcop.

    RETURN "OK".

END.

/****************************************************************************/
/***** Procedure responsavel por carregar parametros da tarifa vigente ******/
/****************************************************************************/
PROCEDURE carrega_par_tarifa_vigente:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdbattar AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM par_dsconteu AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapbat WHERE crapbat.cdbattar = par_cdbattar /*Sigla Parametro*/
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapbat THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = par_cdbattar + " - Sigla do parametro nao cadastrado.".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND FIRST crappco WHERE crappco.cdcooper = par_cdcooper AND
                             crappco.cdpartar = crapbat.cdcadast /* Cod. Par */
                             NO-LOCK NO-ERROR.

    IF  AVAIL crappco THEN
        ASSIGN par_dsconteu = crappco.dsconteu.
     ELSE
         DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = par_cdbattar + " - Conteudo do parametro nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.

    RETURN "OK".

END.

PROCEDURE gera_log_lote_uso:
  DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
  DEF INPUT PARAM par_nrdolote AS INTE                    NO-UNDO.
  DEF INPUT-OUTPUT PARAM par_flgerlog AS CHAR             NO-UNDO.
  DEF INPUT PARAM par_des_log  AS CHAR                    NO-UNDO.
  
  DEF VAR aux_dsdircop AS CHAR                            NO-UNDO.
  DEF VAR aux_lotmonit AS CHAR                            NO-UNDO.

  
  IF par_flgerlog = "" THEN
  do:

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
       (INPUT "CRED",           /* pr_nmsistem */
        INPUT par_cdcooper,     /* pr_cdcooper */
        INPUT "GERA_LOG_LOTE_USO",  /* pr_cdacesso */
        OUTPUT ""               /* pr_dsvlrprm */
        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


	  ASSIGN par_flgerlog = ""
           par_flgerlog = pc_param_sistema.pr_dsvlrprm
                          WHEN pc_param_sistema.pr_dsvlrprm <> ?.
  end.
  
  /* Verificar se é para gerar log(variavel in-out para nao precisar carregar a toda hora)*/
  IF par_flgerlog = 'S' THEN
  DO:
  
    /* Verificar se o lote passado deve ser monitorado */ 
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
       (INPUT "CRED",           /* pr_nmsistem */
        INPUT par_cdcooper,     /* pr_cdcooper */
        INPUT "MONIT_LOTE_USO", /* pr_cdacesso */
        OUTPUT ""               /* pr_dsvlrprm */
        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


	  ASSIGN aux_lotmonit = ""
           aux_lotmonit = pc_param_sistema.pr_dsvlrprm
                          WHEN pc_param_sistema.pr_dsvlrprm <> ?.
    
    /* se o lote passado nao precisa ser monitorado, deve sair da rotina*/
    IF  CAN-DO(aux_lotmonit,STRING(par_nrdconta)) THEN
      RETURN "OK".
    
    /* Buscar dados coop*/
    FIND FIRST crapcop
      WHERE crapcop.cdcooper = par_cdcooper
      NO-LOCK NO-ERROR.
    
    IF AVAILABLE crapcop THEN
       ASSIGN aux_dsdircop = crapcop.dsdircop.    
    ELSE
       ASSIGN aux_dsdircop = "cecred".    
    
    
    /* Criar log */
	  OUTPUT TO VALUE ("/usr/coop/" + aux_dsdircop + "/log/monitlot.log") APPEND.
    
    PUT UNFORMATTED STRING(TODAY,"99/99/9999") + " " +
                    STRING(TIME,"HH:MM:SS") + " -> " + 
                    par_des_log SKIP.
    
    OUTPUT CLOSE.
        
  END.  

  RETURN "OK".
END PROCEDURE.



/*****************************************************************************/
/** Procedure responsavel por fazer lancamento de tarifas em conta corrente **/
/*****************************************************************************/
PROCEDURE lan_tarifa_conta_corrente:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_tplotmov AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctabb AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctitg AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdpesqbb AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_cdagechq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctachq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_flgaviso AS LOGI                               NO-UNDO.
    DEF INPUT PARAM par_cdsecext AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_tpdaviso AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_vltarifa AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_cdageass AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdcoptfn AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagetfn AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrterfin AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrsequni AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrautdoc AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dsidenti AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_ctrdocmt AS CHAR EXTENT 9
                        INIT ["1","2","3","4","5","6","7","8","9"]     NO-UNDO.
    DEF VAR aux_contapli AS INT                                        NO-UNDO.
    DEF VAR aux_nraplica AS CHAR                                       NO-UNDO.
    DEF VAR aux_nraplfun AS CHAR                                       NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI INIT FALSE                            NO-UNDO.
	  DEF VAR aux_flgerlog AS CHAR                                       NO-UNDO.  
	  DEF VAR aux_des_log  AS CHAR                                       NO-UNDO.  

    DEF VAR h-b1wgen0200 AS HANDLE  NO-UNDO.
    DEF VAR aux_incrineg AS INT     NO-UNDO.
    DEF VAR aux_cdcritic AS INT     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_contapli = 9
	         aux_flgerlog = "".
           
    IF  par_vltarifa = 0 THEN
        RETURN "OK".

    /**** inproces = 1 On-Line ****/
    /**** inproces > 1 bacth   ****/

    DO  TRANSACTION ON ENDKEY UNDO, LEAVE 
                    ON ERROR UNDO, LEAVE:
        
        ASSIGN aux_contador = 0.
        
		    ASSIGN aux_des_log  = "Alocando lote -> " +
                              "cdcooper: " +  string(par_cdcooper) + " " +
                              "dtmvtolt: " +  string(par_dtmvtolt,"99/99/9999") + " " +
                              "cdagenci: " +  string(par_cdagenci) + " " +
                              "cdbccxlt: " +  string(par_cdbccxlt) + " " +
                              "nrdolote: " +  string(par_nrdolote) + " " +
							                "nrdconta: " +  string(par_nrdconta) + " " +
                              "cdhistor: " +  string(par_cdhistor) + " " +
                              "rotina: b1wgen0153.lan_tarifa_conta_corrente ".

        RUN gera_log_lote_uso( INPUT par_cdcooper,
		                           INPUT par_nrdconta,
                               INPUT par_nrdolote,
				                		   INPUT-OUTPUT aux_flgerlog,
            						       INPUT aux_des_log).
		
		DO WHILE TRUE:
        
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = par_cdagenci AND
                               craplot.cdbccxlt = par_cdbccxlt AND
                               craplot.nrdolote = par_nrdolote
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL craplot THEN
                DO:
                    IF  LOCKED craplot THEN
                        DO:
                            IF  par_inproces = 1  THEN  /* On-Line */
                                DO:
                                    ASSIGN aux_contador = aux_contador + 1.
        
                                    ASSIGN aux_des_log  = "Lote já Alocado -> " +
														  "cdcooper: " +  string(par_cdcooper) + " " +
														  "dtmvtolt: " +  string(par_dtmvtolt,"99/99/9999") + " " +
														  "cdagenci: " +  string(par_cdagenci) + " " +
														  "cdbccxlt: " +  string(par_cdbccxlt) + " " +
														  "nrdolote: " +  string(par_nrdolote) + " " +
														  "nrdconta: " +  string(par_nrdconta) + " " +
														  "cdhistor: " +  string(par_cdhistor) + " " +
														  "rotina: b1wgen0153.lan_tarifa_conta_corrente ".

									RUN gera_log_lote_uso( INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_nrdolote,
                                         INPUT-OUTPUT aux_flgerlog,
                                         INPUT aux_des_log).
									
									IF  aux_contador = 10  THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 0
											       aux_dscritic = "Tabela CRAPLOT em uso" + string(par_nrdolote) + ".".
                                
                                            RUN gera_erro (INPUT par_cdcooper,        
                                                           INPUT par_cdagenci,
                                                           INPUT 1, /* nrdcaixa  */
                                                           INPUT 1, /* sequencia */
                                                           INPUT aux_cdcritic,        
                                                           INPUT-OUTPUT aux_dscritic).
                                            UNDO, RETURN "NOK".    
                                        END.
                                END.
        
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.cdcooper = par_cdcooper
                                   craplot.dtmvtolt = par_dtmvtolt
                                   craplot.cdagenci = par_cdagenci
                                   craplot.cdbccxlt = par_cdbccxlt
                                   craplot.nrdolote = par_nrdolote
                                   craplot.tplotmov = par_tplotmov
                                   craplot.cdoperad = par_cdoperad.
                            VALIDATE craplot.
                        END.
                END.
        
            LEAVE.
        
        END.

        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                           craphis.cdhistor = par_cdhistor 
                           NO-LOCK NO-ERROR.

        IF  AVAIL craphis THEN
            DO:
               IF  craphis.indebcre = "D" THEN
                   ASSIGN craplot.vlinfodb = craplot.vlinfodb + par_vltarifa
                          craplot.vlcompdb = craplot.vlcompdb + par_vltarifa.
               ELSE
                   ASSIGN craplot.vlinfocr = craplot.vlinfocr + par_vltarifa
                          craplot.vlcompcr = craplot.vlcompcr + par_vltarifa.
            END.
        ELSE
            DO:
               ASSIGN aux_cdcritic = 0
    				  aux_dscritic = "Historico nao encontrado!".
    
               RUN gera_erro (INPUT par_cdcooper,        
                              INPUT par_cdagenci,
                              INPUT 1, /* nrdcaixa  */
                              INPUT 1, /* sequencia */
                              INPUT aux_cdcritic,        
                              INPUT-OUTPUT aux_dscritic). 
               UNDO, RETURN "NOK".  
            END.

        ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1.
               
        ASSIGN aux_nraplica = STRING(par_nrdocmto)
               aux_nraplfun = STRING(par_nrdocmto).
        
        DO WHILE TRUE:
        
            /* Responsavel por criar lancamento em conta corrente */
           FIND craplcm WHERE craplcm.cdcooper = craplot.cdcooper AND
                              craplcm.dtmvtolt = craplot.dtmvtolt AND
                              craplcm.cdagenci = craplot.cdagenci AND
                              craplcm.cdbccxlt = craplot.cdbccxlt AND
                              craplcm.nrdolote = craplot.nrdolote AND
                              craplcm.nrdctabb = par_nrdctabb AND
                              craplcm.nrdocmto = IF par_nrdocmto > 0 THEN 
                                                    INT(aux_nraplica)
                                                 ELSE 
                                                    craplot.nrseqdig
                              NO-LOCK NO-ERROR NO-WAIT.
             
            IF  NOT AVAIL craplcm THEN
                DO:
               
			    IF NOT VALID-HANDLE(h-b1wgen0200) THEN
				   RUN sistema/generico/procedures/b1wgen0200.p
				     PERSISTENT SET h-b1wgen0200. 

                RUN gerar_lancamento_conta_comple IN h-b1wgen0200
                      ( INPUT craplot.dtmvtolt  /* par_dtmvtolt */
                       ,INPUT par_cdagenci      /* par_cdagenci */
                       ,INPUT par_cdbccxlt      /* par_cdbccxlt */
                       ,INPUT par_nrdolote      /* par_nrdolote */
                       ,INPUT par_nrdconta      /* par_nrdconta */
                       ,INPUT IF par_nrdocmto > 0 THEN
                                 INT(aux_nraplica)
                              ELSE
                                 craplot.nrseqdig  /* par_nrdocmto */
                       ,INPUT par_cdhistor      /* par_cdhistor */
                       ,INPUT craplot.nrseqdig  /* par_nrseqdig */
                       ,INPUT par_vltarifa      /* par_vllanmto */
                       ,INPUT par_nrdctabb      /* par_nrdctabb */
                       ,INPUT par_cdpesqbb      /* par_cdpesqbb */
                       ,INPUT 0                 /* par_vldoipmf */
                       ,INPUT par_nrautdoc      /* par_nrautdoc */
                       ,INPUT IF par_nrsequni = 0 THEN 
                                 craplot.nrseqdig
                              ELSE
                                 par_nrsequni    /* par_nrsequni */
                       ,INPUT par_cdbanchq      /* par_cdbanchq */
                       ,INPUT 0                 /* par_cdcmpchq */
                       ,INPUT par_cdagechq      /* par_cdagechq */
                       ,INPUT par_nrctachq      /* par_nrctachq */
                       ,INPUT 0                 /* par_nrlotchq */
                       ,INPUT 0                 /* par_sqlotchq */
                       ,INPUT craplot.dtmvtolt  /* par_dtrefere */
                       ,INPUT TIME              /* par_hrtransa */
                       ,INPUT par_cdoperad      /* par_cdoperad */                               
                       ,INPUT par_dsidenti     /* par_dsidenti */
                       ,INPUT par_cdcooper      /* par_cdcooper */
                       ,INPUT par_nrdctitg     /* par_nrdctitg */
                       ,INPUT ""               /* par_dscedent */
                       ,INPUT par_cdcoptfn     /* par_cdcoptfn */
                       ,INPUT par_cdagetfn     /* par_cdagetfn */
                       ,INPUT par_nrterfin     /* par_nrterfin */
                       ,INPUT 0                /* par_nrparepr */
                       ,INPUT 0                /* par_nrseqava */
                       ,INPUT 0                /* par_nraplica */
                       ,INPUT 0                /*par_cdorigem*/
                       ,INPUT 0                /* par_idlautom */
                       ,INPUT 0                /*par_inprolot*/ 
                       ,INPUT 0                /*par_tplotmov */
                       ,OUTPUT TABLE tt-ret-lancto
                       ,OUTPUT aux_incrineg
                       ,OUTPUT aux_cdcritic
                       ,OUTPUT aux_dscritic).

                       IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO:  
							  RUN gera_erro (INPUT par_cdcooper,        
											 INPUT par_cdagenci,
											 INPUT 1, /* nrdcaixa  */
											 INPUT 1, /* sequencia */
											 INPUT aux_cdcritic,        
											 INPUT-OUTPUT aux_dscritic).
							  UNDO, RETURN "NOK". 
                        END.  
                END.
            ELSE
                DO:
                    IF  par_nrdocmto = 0 THEN
                        DO:
                           ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1.
                           NEXT.
                        END.
                   
                    ASSIGN aux_nraplica = aux_ctrdocmt[aux_contapli] + 
                                          aux_nraplica.
                  
                    INT(aux_nraplica) NO-ERROR.  
                  
                    IF   ERROR-STATUS:ERROR   OR
                         f_numericos(INPUT aux_nraplica) = FALSE  THEN
                         DO:
                            aux_contapli = aux_contapli - 1.
                            
                            ASSIGN aux_nraplica = aux_ctrdocmt[aux_contapli] + 
                                                  aux_nraplfun.
                  
                            NEXT.
                  
                         END.
                  
                    NEXT.
                END.
        
            LEAVE.
    
        END. /*fim do while true*/
         
        /* Cria aviso de debito em CC se necessario */
        IF  par_flgaviso THEN
            DO:
                CREATE crapavs.
                ASSIGN crapavs.cdcooper = craplcm.cdcooper
                       crapavs.dtmvtolt = craplcm.dtmvtolt
                       crapavs.nrdconta = craplcm.nrdconta
                       crapavs.cdhistor = craplcm.cdhistor
                       crapavs.nrdocmto = craplcm.nrdocmto
                       crapavs.nrseqdig = craplcm.nrseqdig
                       crapavs.cdagenci = par_cdageass
                       crapavs.cdsecext = par_cdsecext
                       crapavs.dtdebito = craplcm.dtmvtolt
                       crapavs.dtrefere = craplcm.dtmvtolt
                       crapavs.tpdaviso = par_tpdaviso
                       crapavs.vllanmto = craplcm.vllanmto
                       crapavs.flgproce = FALSE.
                VALIDATE crapavs.
            END.

        ASSIGN aux_flgtrans = TRUE.

    END. /* fim do transaction */
  
    IF  AVAIL craplot THEN
        DO:
            FIND CURRENT craplot NO-LOCK NO-ERROR.
            RELEASE craplot.
        END.

    IF  AVAIL crapavs THEN
        DO:
            FIND CURRENT crapavs NO-LOCK NO-ERROR.
            RELEASE crapavs.
        END.

    IF  AVAIL craplcm THEN
        DO:
            FIND CURRENT craplcm NO-LOCK NO-ERROR.
            RELEASE craplcm.
        END.

    IF  NOT aux_flgtrans THEN
        DO: 
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Erro na gravacao do lancamento!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            UNDO, RETURN "NOK".
        END.
    ELSE
        RETURN "OK".

END.

/*****************************************************************************/
/********** Responsavel em criar lancamentos automaticos de tarifas **********/
/*****************************************************************************/
PROCEDURE cria_lan_auto_tarifa:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_vllanaut AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_tpdolote AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdpesqbb AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgaviso AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_tpdaviso AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdfvlcop AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                              NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_idseqlat AS INTE                                       NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI INIT FALSE                            NO-UNDO.

    DEF BUFFER crablat FOR craplat.

    EMPTY TEMP-TABLE tt-erro.
    
    IF  par_vllanaut = 0  THEN
        RETURN "OK".

    DO TRANSACTION ON ENDKEY UNDO, LEAVE 
                   ON ERROR UNDO, LEAVE:
       
       /* Busca a proxima sequencia do campo CRAPLAT.IDSEQLAT */
    	RUN STORED-PROCEDURE pc_sequence_progress
    	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLAT"
    										,INPUT "IDSEQLAT"
    										,INPUT STRING(par_cdcooper)      + ";" + STRING(DEC(par_nrdconta)) + ";" + STRING(par_dtmvtolt,"99/99/9999")
    										,INPUT "N"
    										,"").
    	
    	CLOSE STORED-PROC pc_sequence_progress
    	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    			  
    	ASSIGN aux_idseqlat = INTE(pc_sequence_progress.pr_sequence)
    						  WHEN pc_sequence_progress.pr_sequence <> ?.

       CREATE craplat.
       ASSIGN craplat.cdcooper = par_cdcooper
              craplat.nrdconta = par_nrdconta
              craplat.dtmvtolt = par_dtmvtolt
              craplat.cdlantar = NEXT-VALUE(seqlat_cdlantar)
              craplat.dttransa = aux_datdodia 
              craplat.hrtransa = TIME                 
              craplat.insitlat = 1 /** PENDENTE **/
              craplat.cdhistor = par_cdhistor
              craplat.vltarifa = par_vllanaut
              craplat.cdoperad = par_cdoperad
              craplat.cdagenci = par_cdagenci
              craplat.cdbccxlt = par_cdbccxlt
              craplat.nrdolote = par_nrdolote
              craplat.tpdolote = par_tpdolote
              craplat.nrdocmto = par_nrdocmto 
              craplat.nrdctabb = par_nrdctabb
              craplat.nrdctitg = par_nrdctitg
              craplat.cdpesqbb = par_cdpesqbb
              craplat.cdbanchq = par_cdbanchq
              craplat.cdagechq = par_cdagechq
              craplat.nrctachq = par_nrctachq
              craplat.flgaviso = par_flgaviso
              craplat.tpdaviso = par_tpdaviso
              craplat.idseqlat = aux_idseqlat
              craplat.cdfvlcop = par_cdfvlcop.

       VALIDATE craplat.

       ASSIGN aux_nrdrowid = ROWID(craplat)
	          aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION **/

    IF  AVAIL craplat THEN
        DO:
            FIND CURRENT craplat NO-LOCK NO-ERROR.
            RELEASE craplat.
        END.

    IF  NOT aux_flgtrans THEN
        DO: 
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Erro na gravacao da tarifa!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            UNDO, RETURN "NOK".
        END.
    ELSE
        RETURN "OK".

END.

PROCEDURE lan-tarifa-online:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_cdbccxlt AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_nrdolote AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_tplotmov AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.  
    DEF  INPUT PARAM par_dtmvtlat AS DATE                              NO-UNDO.  
    DEF  INPUT PARAM par_dtmvtlcm AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_nrdctitg AS CHAR                              NO-UNDO.  
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.   
    DEF  INPUT PARAM par_cdpesqbb AS CHAR                              NO-UNDO.   
    DEF  INPUT PARAM par_cdbanchq AS DECI                              NO-UNDO.  
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_flgaviso AS LOGI                              NO-UNDO.  
    DEF  INPUT PARAM par_tpdaviso AS INTE                              NO-UNDO.  
    DEF  INPUT PARAM par_vltarifa AS DECI                              NO-UNDO.   
    DEF  INPUT PARAM par_nrdocmto AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrsequni AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrautdoc AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dsidenti AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdfvlcop AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                              NO-UNDO.  

    DEF OUTPUT PARAM par_cdlantar LIKE craplat.cdlantar                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_flgtrans AS LOGI INIT FALSE                            NO-UNDO.

    IF  par_vltarifa = 0  THEN
        RETURN "OK".

    DO TRANSACTION ON ENDKEY UNDO, LEAVE 
                   ON ERROR  UNDO, LEAVE:

        RUN cria_lan_auto_tarifa (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_dtmvtlat,
                                  INPUT par_cdhistor,
                                  INPUT par_vltarifa,
                                  INPUT par_cdoperad,
                                  INPUT par_cdagenci,
                                  INPUT par_cdbccxlt,
                                  INPUT par_nrdolote,
                                  INPUT par_tplotmov,
                                  INPUT par_nrdocmto,
                                  INPUT par_nrdctabb,
                                  INPUT par_nrdctitg,
                                  INPUT par_cdpesqbb,
                                  INPUT par_cdbanchq,
                                  INPUT par_cdagechq,
                                  INPUT par_nrctachq,
                                  INPUT par_flgaviso,
                                  INPUT par_tpdaviso,
                                  INPUT par_cdfvlcop,
                                  INPUT par_inproces,
                                 OUTPUT TABLE tt-erro). 

        IF  RETURN-VALUE <> "OK"  THEN
            UNDO, LEAVE.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 0
				       aux_dscritic = "Associado nao encontrado.".

                UNDO, LEAVE.
            END.

        FIND craplat WHERE ROWID(craplat) = aux_nrdrowid EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL craplat  THEN
            DO:
                ASSIGN aux_cdcritic = 0
				       aux_dscritic = "Agendamento de tarifa nao encontrado.".

                UNDO, LEAVE.
            END.

        RUN lan_tarifa_conta_corrente (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdconta,
                                       INPUT par_cdbccxlt,
                                       INPUT par_nrdolote,
                                       INPUT par_tplotmov,
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtlcm,
                                       INPUT par_nrdctabb,
                                       INPUT par_nrdctitg,
                                       INPUT par_cdhistor,
                                       INPUT par_cdpesqbb,
                                       INPUT par_cdbanchq,
                                       INPUT par_cdagechq,
                                       INPUT par_nrctachq,
                                       INPUT par_flgaviso,
                                       INPUT crapass.cdsecext,
                                       INPUT par_tpdaviso,
                                       INPUT par_vltarifa,
                                       INPUT par_nrdocmto,
                                       INPUT crapass.cdagenci,
                                       INPUT par_cdcoptfn,
                                       INPUT par_cdagetfn,
                                       INPUT par_nrterfin,
                                       INPUT par_nrsequni,
                                       INPUT par_nrautdoc,
                                       INPUT par_dsidenti,
                                       INPUT par_inproces,
                                      OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"  THEN
            UNDO, LEAVE.

        ASSIGN craplat.dtefetiv = par_dtmvtlcm
               craplat.insitlat = 2  /** Efetivado **/
               par_cdlantar     = craplat.cdlantar
               aux_flgtrans     = TRUE.

    END. /** Fim do DO TRANSACTION **/

    IF  AVAIL craplat THEN
        DO:
            FIND CURRENT craplat NO-LOCK NO-ERROR.
            RELEASE craplat.
        END.

    IF  NOT aux_flgtrans THEN
        DO: 
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Erro no lancamento da tarifa.".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT 1, /* cdagenci  */
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    ELSE
        RETURN "OK".
                                                                                 
END PROCEDURE.
/******************************************************************************
                     Tela CADBAT
******************************************************************************/


/******************************************************************************
 Listagem de CADBAT
******************************************************************************/
PROCEDURE lista-cadbat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdbattar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmidenti AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-battar.

    DEF VAR aux_nrregist AS INT.
                            
    DO ON ERROR UNDO, LEAVE:
        
        EMPTY TEMP-TABLE tt-battar.
    
        ASSIGN aux_nrregist = par_nrregist.
        
        FOR EACH crapbat NO-LOCK  
            WHERE crapbat.cdbattar MATCHES("*" + par_cdbattar + "*") AND
                  crapbat.nmidenti MATCHES("*" + par_nmidenti + "*") 
                                   BY crapbat.cdbattar:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                CREATE tt-battar.
                ASSIGN tt-battar.cdbattar = crapbat.cdbattar
                       tt-battar.nmidenti = crapbat.nmidenti
                       tt-battar.cdprogra = crapbat.cdprogra
                       tt-battar.tpcadast = crapbat.tpcadast
                       tt-battar.cdcadast = crapbat.cdcadast
                       tt-battar.dscadast = IF crapbat.tpcadast = 1 THEN
                                               "Tarifa"
                                            ELSE
                                               "Parametro".
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
                   
        END.

    END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Buscar de Cadbat
******************************************************************************/
PROCEDURE buscar-cadbat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbattar AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_nmidenti AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_cdprogra AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_tpcadast AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_cdcadast AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapbat WHERE crapbat.cdbattar = par_cdbattar NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapbat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN par_nmidenti = crapbat.nmidenti
           par_cdprogra = crapbat.cdprogra
           par_tpcadast = crapbat.tpcadast
           par_cdcadast = crapbat.cdcadast.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Inclusao de Cadbat
******************************************************************************/
PROCEDURE incluir-cadbat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbattar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmidenti AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_tpcadast AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcadast AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
       
    FIND crapbat WHERE crapbat.cdbattar = par_cdbattar NO-LOCK NO-ERROR.

    IF  AVAIL(crapbat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Registro ja existente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    CREATE crapbat.
    ASSIGN crapbat.cdbattar = par_cdbattar
           crapbat.nmidenti = par_nmidenti
           crapbat.tpcadast = par_tpcadast
           crapbat.cdcadast = par_cdcadast
           crapbat.cdprogra = par_cdprogra.
    VALIDATE crapbat.
               
    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Vincular cadbat
******************************************************************************/
PROCEDURE vincular-cadbat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbattar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdcadast AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    FIND crapbat WHERE crapbat.cdbattar = par_cdbattar AND
                       crapbat.cdcadast = par_cdcadast
                       NO-LOCK NO-ERROR.

    IF  AVAIL(crapbat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Sigla ja vinculada!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    
    DO aux_contador = 1 TO 10:

        FIND crapbat WHERE crapbat.cdbattar = par_cdbattar
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapbat THEN
			DO:
				IF  LOCKED crapbat THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
							    NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN crapbat.cdbattar = par_cdbattar
                      crapbat.cdcadast = par_cdcadast.
               LEAVE.
            END.
    END.
 
    RETURN "OK".
END PROCEDURE.

/******************************************************************************
 Listagem de Tarifas para Baixa/Estorno
******************************************************************************/
PROCEDURE lista_tarifas_estorno:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cddopcap AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM par_vlrtotal AS DECI                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-estorno.

    DEF VAR aux_nrregist AS INTE                            NO-UNDO.
    DEF VAR aux_dshistor AS CHAR                            NO-UNDO.

    EMPTY TEMP-TABLE tt-estorno.

    ASSIGN aux_nrregist = 0.

    /* Estorno */
    IF par_cddopcap = 1 THEN
        DO:
                     
            FOR EACH craplat NO-LOCK WHERE  craplat.cdcooper  = par_cdcooper AND 
                                            craplat.nrdconta  = par_nrdconta AND
                                            craplat.dtefetiv >= par_dtinicio AND
                                            craplat.dtefetiv <= par_dtafinal:
        
                /* Estorno */
                IF par_cddopcap = 1 THEN
                    DO:
                        /* Efetivado */
                        IF craplat.insitlat <> 2 THEN
                        NEXT.
                    END.
                ELSE
                    DO:
                        /* Baixa */
                        IF par_cddopcap = 2 THEN
                        DO:
                            /* Pendente */
                            IF craplat.insitlat <> 1 THEN
                            NEXT.
                        END.
        
                    END.
        
                IF par_cdhistor > 0 THEN
                DO:
                    IF craplat.cdhistor <> par_cdhistor THEN
                        NEXT.
                END.
        
                ASSIGN aux_dshistor = "".
                
                FIND craphis WHERE  craphis.cdcooper = par_cdcooper AND
                                    craphis.cdhistor = craplat.cdhistor 
                                                      NO-LOCK NO-ERROR.
        
                IF  NOT AVAIL(craphis) THEN
                    NEXT.
        
                ASSIGN aux_dshistor = craphis.dshistor.
        
                ASSIGN par_qtregist = par_qtregist + 1
                       par_vlrtotal = par_vlrtotal + craplat.vltarifa. 
                  
                CREATE tt-estorno.
                ASSIGN tt-estorno.cdlantar = craplat.cdlantar
                       tt-estorno.dtmvtolt = craplat.dtefetiv
                       tt-estorno.cdhistor = craplat.cdhistor
                       tt-estorno.dshistor = aux_dshistor
                       tt-estorno.nrdocmto = craplat.nrdocmto
                       tt-estorno.vltarifa = craplat.vltarifa    
                       aux_nrregist = aux_nrregist + 1.
            
            END.
        END.
    ELSE
    DO:
        FOR EACH craplat NO-LOCK WHERE  craplat.cdcooper  = par_cdcooper AND 
                                        craplat.nrdconta  = par_nrdconta AND
                                        craplat.dtmvtolt >= par_dtinicio AND
                                        craplat.dtmvtolt <= par_dtafinal:
    
            /* Estorno */
            IF par_cddopcap = 1 THEN
                DO:
                    /* Efetivado */
                    IF craplat.insitlat <> 2 THEN
                    NEXT.
                END.
            ELSE
                DO:
                    /* Baixa */
                    IF par_cddopcap = 2 THEN
                    DO:
                        /* Pendente */
                        IF craplat.insitlat <> 1 THEN
                        NEXT.
                    END.
    
                END.
    
            IF par_cdhistor > 0 THEN
            DO:
                IF craplat.cdhistor <> par_cdhistor THEN
                    NEXT.
            END.
    
            ASSIGN aux_dshistor = "".
            
            FIND craphis WHERE  craphis.cdcooper = par_cdcooper AND
                                craphis.cdhistor = craplat.cdhistor 
                                                  NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL(craphis) THEN
                NEXT.
    
            ASSIGN aux_dshistor = craphis.dshistor.
    
            ASSIGN par_qtregist = par_qtregist + 1
                   par_vlrtotal = par_vlrtotal + craplat.vltarifa. 
              
            CREATE tt-estorno.
            ASSIGN tt-estorno.cdlantar = craplat.cdlantar
                   tt-estorno.dtmvtolt = craplat.dtmvtolt
                   tt-estorno.cdhistor = craplat.cdhistor
                   tt-estorno.dshistor = aux_dshistor
                   tt-estorno.nrdocmto = craplat.nrdocmto
                   tt-estorno.vltarifa = craplat.vltarifa    
                   aux_nrregist = aux_nrregist + 1.
    
        END.

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
 Alteracao de crapbat
******************************************************************************/
PROCEDURE alterar-cadbat:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdbattar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmidenti AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador         AS INTE                    NO-UNDO.

    DO aux_contador = 1 TO 10:

        FIND crapbat WHERE crapbat.cdbattar = par_cdbattar EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapbat THEN
			DO:
				IF  LOCKED crapbat THEN
					DO:
						IF  aux_contador = 10 THEN
                            DO:
    							ASSIGN aux_cdcritic = 77.

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
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
					END.
				ELSE
    				DO:
                        ASSIGN aux_cdcritic = 0
				               aux_dscritic = "Tentativa de alterar registro inexistente!".

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
			   ASSIGN crapbat.cdprogra = par_cdprogra
                      crapbat.nmidenti = par_nmidenti.
               LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
 Busca qtd dias estorno
******************************************************************************/
PROCEDURE busca-qtd-dias-estorno:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE FORMAT "99/99/9999"                   NO-UNDO.
    DEF INPUT PARAM par_cdbattar AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM par_dsconteu AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM par_dtlimest AS DATE FORMAT "99/99/9999"                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND FIRST crapbat NO-LOCK WHERE TRIM(UPPER(crapbat.cdbattar)) = TRIM(par_cdbattar) NO-ERROR.

    IF AVAIL crapbat THEN
        DO:

            FIND FIRST crappco NO-LOCK WHERE crappco.cdpartar = crapbat.cdcadast AND 
                                             crappco.cdcooper = par_cdcooper NO-ERROR.

            IF AVAIL crappco THEN
                DO:
      
                    ASSIGN  par_dtlimest = par_dtmvtolt - INTE(crappco.dsconteu)
                            par_dsconteu = INTE(crappco.dsconteu).
                END.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
        				   aux_dscritic = "Registro de prazo de estorno inexistente!".
        
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
				   aux_dscritic = "Registro inexistente!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.

/*tiago*/
PROCEDURE busca-lista-historico:

    DEF INPUT PARAM par_cddgrupo    AS  INTEGER                     NO-UNDO.
    DEF INPUT PARAM par_cdsubgru    AS  INTEGER                     NO-UNDO.
    DEF OUTPUT PARAM par_lshistor   AS  CHAR                        NO-UNDO.
    DEF OUTPUT PARAM par_lssubgru   AS  CHAR                        NO-UNDO.

    DEF VAR lst_cdsubgru            AS  CHAR                        NO-UNDO.
    DEF VAR lst_cdhistor            AS  CHAR                        NO-UNDO.
    DEF VAR aux_cont                AS  INTE                        NO-UNDO.

    
    IF  par_cdsubgru > 0 THEN
        DO:
            ASSIGN lst_cdsubgru = STRING(par_cdsubgru).
        END.
    ELSE
    DO: 
        FOR EACH  crapsgr WHERE crapsgr.cddgrupo = par_cddgrupo NO-LOCK:
            lst_cdsubgru = lst_cdsubgru + STRING(crapsgr.cdsubgru) + ",".
        END.
        
        ASSIGN lst_cdsubgru = 
               SUBSTRING(TRIM(lst_cdsubgru),1,LENGTH(lst_cdsubgru) - 1).
    END.

    IF  lst_cdsubgru <> "" THEN
    DO:
        FOR EACH crapfvl NO-LOCK BREAK BY crapfvl.cdhistor:
             
            IF  FIRST-OF(crapfvl.cdhistor) THEN
                DO:
            
                    lista_subgru:
                    DO  aux_cont=1 TO NUM-ENTRIES(lst_cdsubgru):

                        FIND FIRST craptar 
                             WHERE craptar.cdsubgru = 
                                   INTEGER(ENTRY(aux_cont, lst_cdsubgru)) AND
                                   craptar.cdtarifa = crapfvl.cdtarifa
                                   NO-LOCK NO-ERROR.

                        IF  NOT AVAIL(craptar) THEN
                            NEXT.

                        lst_cdhistor = lst_cdhistor + 
                                       STRING(crapfvl.cdhistor) +
                                       ",".      
                        LEAVE lista_subgru.
                    END.
        
                END.
        END.

        ASSIGN lst_cdhistor = 
        SUBSTRING(TRIM(lst_cdhistor),1,LENGTH(lst_cdhistor) - 1).
    END.
   
    ASSIGN par_lssubgru = lst_cdsubgru
           par_lshistor = lst_cdhistor.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
Relatorio Receita Tarifa
******************************************************************************/
PROCEDURE rel-receita-tarifa:                                   

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.

    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.    
    DEF VAR aux_vlrepass        AS DECI                     NO-UNDO.    
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-receita.dtmvtolt AT  1 LABEL "DATA"            FORMAT "99/99/9999"
         tt-receita.cdhistor AT 18 LABEL "HISTORICO"       
         tt-receita.dshistor AT 34 LABEL "SIGLA"           FORMAT "x(40)"
         tt-receita.inpessoa AT 75 LABEL "TIPO"            FORMAT "x(4)"
         tt-receita.nrdconta AT 82 LABEL "CONTA/DV"        
         tt-receita.vltarifa AT 99 LABEL "VALOR"           FORMAT "zz,zzz,zz9.99"
         tt-receita.vlrepass AT 119 LABEL "CUSTO"          FORMAT "zz,zzz,zz9.99"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_receita.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 88 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 88 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_qtregpac = 0
           aux_vltotpac = 0
           aux_fill = FILL("-",130)
           aux_lssubgru = "".

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.
    
    FOR EACH craplat WHERE craplat.insitlat  = 2             AND
                          (craplat.dtmvtolt >= par_dtinicio  AND
                           craplat.dtmvtolt <= par_dtafinal) NO-LOCK:
           
        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.
             
        IF  par_cdhistor > 0 THEN
            DO:
                IF  par_cdhistor <> craplat.cdhistor THEN
                    NEXT.
            END.
                           
        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.
          

        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta 
                            NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.
                
                IF  par_inpessoa <> crapass.inpessoa AND 
                    par_inpessoa  >  0               THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Historico nao encontrado!".

                RUN gera_erro (INPUT par_cdcooper,       
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        FIND crapfco WHERE  crapfco.cdfvlcop = craplat.cdfvlcop   
                            NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapfco) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Faixa de valor nao encontrada!".

                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
       
        ASSIGN aux_vlrepass = 0.

        IF ( craplat.vltarifa = crapfco.vltarifa ) THEN
            ASSIGN aux_vlrepass = crapfco.vlrepass.
        ELSE
            DO:
                ASSIGN aux_vlrepass = INTE((craplat.vltarifa / crapfco.vltarifa)) * crapfco.vlrepass.
            END.

        CREATE tt-receita.
        ASSIGN tt-receita.dtmvtolt = craplat.dtmvtolt
               tt-receita.cdhistor = craplat.cdhistor
               tt-receita.dshistor = craphis.dshistor
               tt-receita.nrdconta = craplat.nrdconta
               tt-receita.vltarifa = craplat.vltarifa
               tt-receita.cdcooper = craplat.cdcooper
               tt-receita.cdagenci = crapass.cdagenci
               tt-receita.vlrepass = aux_vlrepass
               tt-receita.inpessoa = IF crapass.inpessoa = 1 THEN
                                        "PF"
                                     ELSE
                                         "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.
    END.
        
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.

    { sistema/generico/includes/b1cabrel132.i "11" 643 }.

    /* VIEW STREAM str_1 FRAME f_cabrel132_1. */
                                                     
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0
           aux_vltotpac = 0
           aux_vlrepass = 0.
                                         
    FOR EACH tt-receita NO-LOCK BREAK BY tt-receita.cdcooper
								      BY tt-receita.cdagenci
                                      BY tt-receita.dtmvtolt: 

        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1
               aux_vlrepass = aux_vlrepass + tt-receita.vlrepass
               aux_vltotpac = aux_vltotpac + tt-receita.vltarifa.
            
        IF  FIRST-OF (tt-receita.cdagenci)         OR 
            LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
            DO:
                                 
                FIND crapcop WHERE crapcop.cdcooper = tt-receita.cdcooper
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.

                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
    
                ASSIGN aux_nmrescop = crapcop.nmrescop.
                                 
                FIND crapage WHERE crapage.cdcooper = tt-receita.cdcooper AND
                                   crapage.cdagenci = tt-receita.cdagenci 
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL(crapage) THEN
                    DO: 
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic). 
                        RETURN "NOK".
                    END.
    
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.


                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.                  
                    END.
                    
                  
                ASSIGN aux_flquebra = TRUE.       
                
                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.
                 
            END.
                       
            DISPLAY STREAM str_1 tt-receita.dtmvtolt
                             tt-receita.cdhistor
                             tt-receita.dshistor
                             tt-receita.inpessoa
                             tt-receita.nrdconta
                             tt-receita.vltarifa
                             tt-receita.vlrepass
                             WITH FRAME f_receita.

         DOWN STREAM str_1 WITH FRAME f_receita.

         IF  LAST-OF(tt-receita.cdagenci) THEN
             DO:
                IF  aux_qtdregis > 1 THEN
                    DO:

                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac 
                                             aux_vltotpac 
                                             WITH FRAME f_resumo.
                    END.

                 ASSIGN aux_vlrepass = 0
                        aux_qtregpac = 0
                        aux_vltotpac = 0.

                 IF  aux_controle < aux_qtdregis THEN
                     DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1.
                        PAGE STREAM str_1.
                     END.                 
             END.
             
    END.
    
    IF  aux_qtquebra > 1 THEN
        DO:
            ASSIGN aux_descresu = "TOTAL GERAL".
            DISPLAY STREAM str_1 aux_fill
                                 aux_descresu
                                 aux_qtdregis
                                 aux_vlrtotal
                                 WITH FRAME f_total.
        END.
    

    OUTPUT STREAM str_1 CLOSE.


    /* Gera relatorio em PDF */ 
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

        
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                              OUTPUT par_nmarqpdf,
                              OUTPUT TABLE tt-erro).     


    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".


    RETURN "OK".
END PROCEDURE.


/******************************************************************************
Relatorio Receita Tarifa
******************************************************************************/
PROCEDURE rel-receita-tarifa-resumido:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.

    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.    
    DEF VAR aux_vlrepass        AS DECI                     NO-UNDO.    
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.
    DEF VAR aux_vlhistor        AS DECI                     NO-UNDO.
    DEF VAR aux_hisrepas        AS DECI                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-receita.cdhistor AT 1  LABEL "HISTORICO"       
         tt-receita.dshistor AT 16 LABEL "SIGLA"           FORMAT "x(66)"
         tt-receita.inpessoa AT 87 LABEL "TIPO"            FORMAT "x(8)"
         aux_vlhistor        AT 99 LABEL "VALOR"           FORMAT "zz,zzz,zz9.99"
         aux_hisrepas        AT 119 LABEL "CUSTO"          FORMAT "zz,zzz,zz9.99"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_receita.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 42 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 87 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 88 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.
    

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_qtregpac = 0
           aux_vltotpac = 0
           aux_fill = FILL("-",130)
           aux_lssubgru = "".

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 2             AND
                          (craplat.dtmvtolt >= par_dtinicio  AND
                           craplat.dtmvtolt <= par_dtafinal) NO-LOCK:

        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhistor > 0 THEN
            DO:
                IF  par_cdhistor <> craplat.cdhistor THEN
                    NEXT.
            END.
                           
        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.
          

        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta 
                            NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.
                
                IF  par_inpessoa <> crapass.inpessoa AND 
                    par_inpessoa  >  0               THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Historico nao encontrado!".

                RUN gera_erro (INPUT par_cdcooper,       
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        FIND crapfco WHERE  crapfco.cdfvlcop = craplat.cdfvlcop   
                            NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapfco) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Faixa de valor nao encontrada!".
                
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
       
        ASSIGN aux_vlrepass = 0.

        IF ( craplat.vltarifa = crapfco.vltarifa ) THEN
            ASSIGN aux_vlrepass = crapfco.vlrepass.
        ELSE
            DO:
                ASSIGN aux_vlrepass = INTE((craplat.vltarifa / crapfco.vltarifa)) * crapfco.vlrepass.
            END.

        CREATE tt-receita.
        ASSIGN tt-receita.dtmvtolt = craplat.dtmvtolt
               tt-receita.cdhistor = craplat.cdhistor
               tt-receita.dshistor = craphis.dshistor
               tt-receita.nrdconta = craplat.nrdconta
               tt-receita.vltarifa = craplat.vltarifa
               tt-receita.cdcooper = craplat.cdcooper
               tt-receita.cdagenci = crapass.cdagenci
               tt-receita.vlrepass = aux_vlrepass
               tt-receita.inpessoa = IF crapass.inpessoa = 1 THEN
                                        "PF"
                                     ELSE
                                         "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.
    END.
        
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.

    { sistema/generico/includes/b1cabrel132.i "11" "643" }.
                                                     
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0
           aux_vlrepass = 0.
    
    FOR EACH tt-receita NO-LOCK BREAK BY tt-receita.cdcooper
								      BY tt-receita.cdagenci
                                      BY tt-receita.cdhistor:

        ASSIGN aux_vlrepass = aux_vlrepass + tt-receita.vlrepass
               aux_vltotpac = aux_vltotpac + tt-receita.vltarifa
               aux_hisrepas = aux_hisrepas + tt-receita.vlrepass
               aux_vlhistor = aux_vlhistor + tt-receita.vltarifa
               aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1.


        IF  FIRST-OF (tt-receita.cdagenci)         OR 
            LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = tt-receita.cdcooper
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
    
                ASSIGN aux_nmrescop = crapcop.nmrescop.
    
                FIND crapage WHERE crapage.cdcooper = tt-receita.cdcooper AND
                                   crapage.cdagenci = tt-receita.cdagenci 
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
    
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.


                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.                  
                    END.
                    

                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.
            END.


         IF  LAST-OF(tt-receita.cdhistor) THEN
             DO:
                DISPLAY STREAM str_1  tt-receita.cdhistor
                                      tt-receita.dshistor
                                      tt-receita.inpessoa
                                      aux_vlhistor
                                      aux_hisrepas
                                      WITH FRAME f_receita.
    
                DOWN STREAM str_1 WITH FRAME f_receita.

                ASSIGN aux_vlhistor = 0
                       aux_hisrepas = 0.
             END.

         IF  LAST-OF(tt-receita.cdagenci) THEN
             DO:
                DISPLAY STREAM str_1 aux_fill
                                     aux_qtregpac
                                     aux_vltotpac    
                                     WITH FRAME f_resumo.

                ASSIGN aux_vlrepass = 0
                       aux_vltotpac = 0
                       aux_qtregpac = 0.
             END.

    END.

    ASSIGN aux_descresu = "TOTAL GERAL"
           aux_qtregpac = 0.

    DISPLAY STREAM str_1 aux_fill
                         aux_descresu
                         aux_qtdregis
                         aux_vlrtotal
                         WITH FRAME f_total.

    IF  aux_controle < aux_qtdregis THEN
        DO:
           ASSIGN aux_qtquebra = aux_qtquebra + 1.
           PAGE STREAM str_1.
        END.                 

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */ 
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

        
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                              OUTPUT par_nmarqpdf,
                              OUTPUT TABLE tt-erro).     

    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".


    RETURN "OK".
END PROCEDURE.
  

/******************************************************************************
Relatorio Estorno Tarifa
******************************************************************************/
PROCEDURE rel-estorno-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.
    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.dtmvtolt AT  1 LABEL "DATA"            FORMAT "99/99/9999"
         tt-relestorno.cdhistor AT 12 LABEL "HISTORICO"       
         tt-relestorno.dshistor AT 27 LABEL "SIGLA"           FORMAT "x(30)"
         tt-relestorno.inpessoa AT 58 LABEL "TIPO"            FORMAT "x(7)"
         tt-relestorno.nrdconta AT 66 LABEL "CONTA/DV"        
         tt-relestorno.vltarifa AT 79 LABEL "VALOR"           FORMAT "zzz,zzz,zz9.99"
         tt-relestorno.dsmotest AT 95 LABEL "MOTIVO"          FORMAT "x(35)"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_estorno.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 30 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 69 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 30 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 70 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_qtregpac = 0
           aux_vltotpac = 0
           aux_fill = FILL("-",130).

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 4             AND
                          (craplat.dtmvtolt >= par_dtinicio  AND
                           craplat.dtmvtolt <= par_dtafinal) NO-LOCK:

        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhisest > 0 THEN
            DO:
                IF  par_cdhisest <> craplat.cdhistor THEN
                    NEXT.
            END.
                           
        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.

        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.

                IF  par_inpessoa <> crapass.inpessoa AND
                    par_inpessoa  > 0                THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Historico nao encontrado!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.


        FIND crapmet WHERE crapmet.cdmotest = craplat.cdmotest NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapmet) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Motivo de estorno nao encontrado!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.dsmotest = crapmet.dsmotest
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.

    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
    
   { sistema/generico/includes/b1cabrel132.i "11" "644" }.
                                                     
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.dtmvtolt
                                         BY tt-relestorno.cdhistor:
                                              
        aux_controle = aux_controle + 1.

        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa.
            
        IF  FIRST-OF(tt-relestorno.cdagenci) THEN
            DO:

                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " +
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle = aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                               PAGE STREAM str_1.
                            END.
                    END.

                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.

            END.

         DISPLAY STREAM str_1 tt-relestorno.dtmvtolt
                              tt-relestorno.cdhistor
                              tt-relestorno.dshistor
                              tt-relestorno.nrdconta
                              tt-relestorno.vltarifa
                              tt-relestorno.dsmotest
                              WITH FRAME f_estorno.

         DOWN STREAM str_1 WITH FRAME f_estorno. 

         IF LAST-OF(tt-relestorno.cdagenci) THEN
             DO:    
                IF  aux_qtdregis > 1 THEN 
                    DO:
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac 
                                             aux_vltotpac 
                                             WITH FRAME f_resumo.
                    END.

                ASSIGN aux_qtregpac = 0
                       aux_vltotpac = 0.  

                IF  aux_controle < aux_qtdregis THEN
                    DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1. 
                        PAGE STREAM str_1. 
                    END.

             END.

         
    END.
    
    IF  aux_qtquebra >= 1 THEN
        DO:
            ASSIGN aux_descresu = "TOTAL GERAL".
            DISPLAY STREAM str_1 aux_fill 
                                 aux_descresu
                                 aux_qtdregis
                                 aux_vlrtotal
                                 WITH FRAME f_total.
        END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

    
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).     
    
    
    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
Relatorio Estorno Tarifa
******************************************************************************/
PROCEDURE rel-estorno-tarifa-resumido:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.
    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.
    DEF VAR aux_vlhistor        AS DECI                     NO-UNDO.
    DEF VAR aux_dsmotest        AS CHAR                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.cdhistor AT 1  LABEL "HISTORICO"       
         tt-relestorno.dshistor AT 14 LABEL "SIGLA"           FORMAT "x(54)"
         tt-relestorno.inpessoa AT 70 LABEL "TIPO"            FORMAT "x(7)"
         aux_vlhistor           AT 79 LABEL "VALOR"           FORMAT "z,zzz,zzz,zz9.99"
         aux_dsmotest           AT 97 LABEL "MOTIVO"          FORMAT "x(33)"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_estorno.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 30 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 70 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 30 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 70 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_qtregpac = 0
           aux_vltotpac = 0
           aux_fill = FILL("-",130).

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 4             AND
                          (craplat.dtmvtolt >= par_dtinicio  AND
                           craplat.dtmvtolt <= par_dtafinal) NO-LOCK:

        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhisest > 0 THEN
            DO:
                IF  par_cdhisest <> craplat.cdhistor THEN
                    NEXT.
            END.
                           
        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.

        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.

                IF  par_inpessoa <> crapass.inpessoa AND
                    par_inpessoa  > 0                THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Historico nao encontrado!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.


        FIND crapmet WHERE crapmet.cdmotest = craplat.cdmotest NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapmet) THEN
            DO:
                ASSIGN aux_cdcritic = 0
    				   aux_dscritic = "Motivo de estorno nao encontrado!".
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.dsmotest = crapmet.dsmotest
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.

    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
    
   { sistema/generico/includes/b1cabrel132.i "11" "644" }.
                                                     
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0
           aux_dsmotest = ""
           aux_qtregpac = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.cdhistor:

        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa
               aux_vlhistor = aux_vlhistor + tt-relestorno.vltarifa
               aux_dsmotest = tt-relestorno.dsmotest
               aux_controle = aux_controle + 1.
            
        IF  FIRST-OF(tt-relestorno.cdagenci) THEN
            DO:

                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " +
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle = aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                               PAGE STREAM str_1.
                            END.
                    END.

                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.

            END.

         IF  LAST-OF(tt-relestorno.cdhistor) THEN
             DO:
         
                 DISPLAY STREAM str_1 tt-relestorno.cdhistor
                                      tt-relestorno.dshistor
                                      tt-relestorno.inpessoa
                                      aux_vlhistor
                                      aux_dsmotest
                                      WITH FRAME f_estorno.
        
                 DOWN STREAM str_1 WITH FRAME f_estorno. 

                 ASSIGN aux_vlhistor = 0
                        aux_dsmotest = "".

             END.

         IF LAST-OF(tt-relestorno.cdagenci) THEN
             DO:    
                IF  aux_qtdregis > 1 THEN 
                    DO:
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac 
                                             aux_vltotpac 
                                             WITH FRAME f_resumo.
                    END.

                ASSIGN aux_qtregpac = 0
                       aux_vltotpac = 0
                       aux_dsmotest = "".  

                IF  aux_controle < aux_qtdregis THEN
                    DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1. 
                        PAGE STREAM str_1. 
                    END.

             END.

         
    END.
    
    IF  aux_qtquebra >= 1 THEN
        DO:
            ASSIGN aux_descresu = "TOTAL GERAL".
            DISPLAY STREAM str_1 aux_fill 
                                 aux_descresu
                                 aux_qtdregis
                                 aux_vlrtotal
                                 WITH FRAME f_total.
        END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

    
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).     
    
    
    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
Relatorio Tarifa Baixada
******************************************************************************/
PROCEDURE rel-tarifa-baixada:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.

    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.
    DEF VAR aux_dsmotest        AS CHAR                     NO-UNDO. 

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.dtmvtolt AT  1 LABEL "DATA"          FORMAT "99/99/9999"
         tt-relestorno.cdhistor AT 13 LABEL "HISTORICO"       
         tt-relestorno.dshistor AT 25 LABEL "SIGLA"         FORMAT "x(30)"
         tt-relestorno.inpessoa AT 56 LABEL "TIPO"          FORMAT "x(7)"
         tt-relestorno.nrdconta AT 65 LABEL "CONTA/DV"        
         tt-relestorno.vltarifa AT 77 LABEL "VALOR"         FORMAT "z,zzz,zzz,zz9.99"
         tt-relestorno.dsmotest AT 95 LABEL "MOTIVO"        FORMAT "x(35)"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_baixas.
                                               
    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 30 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 70 LABEL "VALOR"                  FORMAT "z,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 83 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_fill = FILL("-",130).

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 3             AND
                          (craplat.dtmvtolt >= par_dtinicio  AND
                           craplat.dtmvtolt <= par_dtafinal) NO-LOCK:

        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhisest > 0 THEN
            DO:
                IF  par_cdhisest <> craplat.cdhistor THEN
                    NEXT.
            END.
                           
        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.

        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.

                IF  par_inpessoa <> crapass.inpessoa AND 
                    par_inpessoa  > 0                THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 526.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.


        FIND crapmet WHERE crapmet.cdmotest = craplat.cdmotest NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapmet) THEN
            ASSIGN aux_dsmotest = "".
        ELSE
            ASSIGN aux_dsmotest = crapmet.dsmotest.
            

        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.dsmotest = aux_dsmotest
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.
    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
    
   { sistema/generico/includes/b1cabrel132.i "11" "645" }.
                                                     
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    DISPLAY STREAM str_1 aux_cdagenci
                     par_dtinicio
                     aux_varchara
                     par_dtafinal
                     WITH FRAME f_cabtar.
            
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.dtmvtolt:
        
        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa.

        IF  FIRST-OF(tt-relestorno.cdagenci) OR 
            (LINE-COUNTER(str_1) > PAGE-SIZE(str_1)) THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci 
                                   NO-LOCK NO-ERROR.
        
                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
        
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.
                    END.
                    

                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.

            END.

        DISPLAY STREAM str_1 tt-relestorno.dtmvtolt
                             tt-relestorno.cdhistor
                             tt-relestorno.dshistor
                             tt-relestorno.inpessoa
                             tt-relestorno.nrdconta
                             tt-relestorno.vltarifa
                             tt-relestorno.dsmotest
                             WITH FRAME f_baixas.

         DOWN STREAM str_1 WITH FRAME f_baixas.

         IF  LAST-OF(tt-relestorno.cdagenci) THEN
             DO:
                IF  aux_qtdregis > 1 THEN
                    DO:
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac 
                                             aux_vltotpac 
                                             WITH FRAME f_resumo.
                    END.

                ASSIGN aux_qtregpac = 0
                       aux_vltotpac = 0.

                IF  aux_controle < aux_qtdregis THEN
                    DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1.
                        PAGE STREAM str_1.
                    END.
                

             END.

    END.                      

    IF  aux_qtquebra > 1 THEN
        DO:
            ASSIGN aux_descresu = "TOTAL GERAL".
            DISPLAY STREAM str_1 aux_fill 
                     aux_descresu
                     aux_qtdregis
                     aux_vlrtotal
                     WITH FRAME f_total.
        END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

        
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).     

    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
Relatorio Tarifa Baixada
******************************************************************************/
PROCEDURE rel-tarifa-baixada-resumido:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.

    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.
    DEF VAR aux_vlhistor        AS DECI                     NO-UNDO.
    DEF VAR aux_dsmotest        AS CHAR                     NO-UNDO. 

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.cdhistor AT 1  LABEL "HISTORICO"       
         tt-relestorno.dshistor AT 14 LABEL "SIGLA"         FORMAT "x(54)"
         tt-relestorno.inpessoa AT 70 LABEL "TIPO"          FORMAT "x(7)"
         aux_vlhistor           AT 79 LABEL "VALOR"         FORMAT "z,zzz,zzz,zz9.99"
         aux_dsmotest           AT 97 LABEL "MOTIVO"        FORMAT "x(32)"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_baixas.
                                               
    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 30 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 72 LABEL "VALOR"                  FORMAT "z,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 83 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_vltotpac = 0
           aux_qtregpac = 0
           aux_fill = FILL("-",130).

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 3             AND
                          (craplat.dtmvtolt >= par_dtinicio  AND
                           craplat.dtmvtolt <= par_dtafinal) NO-LOCK:

        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhisest > 0 THEN
            DO:
                IF  par_cdhisest <> craplat.cdhistor THEN
                    NEXT.
            END.
                           
        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.

        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.

                IF  par_inpessoa <> crapass.inpessoa AND 
                    par_inpessoa  > 0                THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 526.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.


        FIND crapmet WHERE crapmet.cdmotest = craplat.cdmotest NO-LOCK NO-ERROR.

        IF  NOT AVAIL(crapmet) THEN
            ASSIGN aux_dsmotest = "".
        ELSE
            ASSIGN aux_dsmotest = crapmet.dsmotest.
            

        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.dsmotest = aux_dsmotest
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.
    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
    
   { sistema/generico/includes/b1cabrel132.i "11" "645" }.
                                                     
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    DISPLAY STREAM str_1 aux_cdagenci
                     par_dtinicio
                     aux_varchara
                     par_dtafinal
                     WITH FRAME f_cabtar.
            
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0
           aux_dsmotest = ""
           aux_qtregpac = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.cdhistor:
        
        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa
               aux_vlhistor = aux_vlhistor + tt-relestorno.vltarifa
               aux_dsmotest = tt-relestorno.dsmotest.

        IF  FIRST-OF(tt-relestorno.cdagenci) OR 
            (LINE-COUNTER(str_1) > PAGE-SIZE(str_1)) THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci 
                                   NO-LOCK NO-ERROR.
        
                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
        
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.
                    END.
                    

                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.

            END.

        IF  LAST-OF(tt-relestorno.cdhistor) THEN
            DO: 
                DISPLAY STREAM str_1 tt-relestorno.cdhistor
                                     tt-relestorno.dshistor
                                     tt-relestorno.inpessoa
                                     aux_vlhistor
                                     aux_dsmotest
                                     WITH FRAME f_baixas.
        
                DOWN STREAM str_1 WITH FRAME f_baixas.

                ASSIGN aux_vlhistor = 0
                       aux_dsmotest = "".

            END.

         IF  LAST-OF(tt-relestorno.cdagenci) THEN
             DO:
                IF  aux_qtdregis > 1 THEN
                    DO:
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac 
                                             aux_vltotpac 
                                             WITH FRAME f_resumo.
                    END.

                ASSIGN aux_qtregpac = 0
                       aux_vltotpac = 0
                       aux_dsmotest = "".

                IF  aux_controle < aux_qtdregis THEN
                    DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1.
                        PAGE STREAM str_1.
                    END.
                

             END.

    END.                      

    IF  aux_qtquebra > 1 THEN
        DO:
            ASSIGN aux_descresu = "TOTAL GERAL".
            DISPLAY STREAM str_1 aux_fill 
                     aux_descresu
                     aux_qtdregis
                     aux_vlrtotal
                     WITH FRAME f_total.
        END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

        
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).     

    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
Relatorio Tarifa Pendente
******************************************************************************/
PROCEDURE rel-tarifa-pendente:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.
    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.dtmvtolt AT  1 LABEL "DATA"          FORMAT "99/99/9999"
         tt-relestorno.cdhistor AT 15 LABEL "HISTORICO"       
         tt-relestorno.dshistor AT 30 LABEL "SIGLA"         FORMAT "x(56)"
         tt-relestorno.inpessoa AT 90 LABEL "TIPO"          FORMAT "x(7)"
         tt-relestorno.nrdconta AT 100 LABEL "CONTA/DV"        
         tt-relestorno.vltarifa AT 114 LABEL "VALOR"        FORMAT "z,zzz,zzz,zz9.99"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_pendente.
                                               
    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 108 LABEL "VALOR"                  FORMAT "z,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 83 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_fill = FILL("-",130).

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 1                AND
                          (craplat.dtmvtolt >= par_dtinicio     AND
                           craplat.dtmvtolt <= par_dtafinal)    NO-LOCK:
        
        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhisest > 0 THEN
            DO:
                IF  par_cdhisest <> craplat.cdhistor THEN
                    NEXT.
            END.
        
        IF  par_cdhistor > 0 THEN
            DO:
                IF  par_cdhistor <> craplat.cdhistor THEN
                    NEXT.
            END.

        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.
        
        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.
        
        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
            
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.
                
                IF  par_inpessoa <> crapass.inpessoa AND
                    par_inpessoa  > 0                THEN
                    NEXT.
                
            END.
        ELSE
            NEXT.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 526.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        
        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.


    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
    
   { sistema/generico/includes/b1cabrel132.i "11" "646" }.
                                                     
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    DISPLAY STREAM str_1 aux_cdagenci
                     par_dtinicio
                     aux_varchara
                     par_dtafinal
                     WITH FRAME f_cabtar.
            
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.dtmvtolt:

        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa.

        IF  FIRST-OF(tt-relestorno.cdagenci) OR 
            (LINE-COUNTER(str_1) > PAGE-SIZE(str_1)) THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci 
                                   NO-LOCK NO-ERROR.
        
                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
        
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.
                    END.
                    

                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.

            END.


        DISPLAY STREAM str_1 tt-relestorno.dtmvtolt
                             tt-relestorno.cdhistor
                             tt-relestorno.dshistor
                             tt-relestorno.inpessoa
                             tt-relestorno.nrdconta
                             tt-relestorno.vltarifa
                             WITH FRAME f_pendente.

         DOWN STREAM str_1 WITH FRAME f_pendente.

         IF  LAST-OF(tt-relestorno.cdagenci) THEN
             DO:
                IF  aux_qtdregis > 1 THEN
                    DO:
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac
                                             aux_vltotpac
                                             WITH FRAME f_resumo.
                    END.

                 ASSIGN aux_qtregpac = 0
                        aux_vltotpac = 0.

                 IF  aux_controle < aux_qtdregis THEN
                     DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1.
                        PAGE STREAM str_1.
                     END. 
             END.
    END.                      

    IF  aux_qtquebra > 1 THEN
    DO:
        ASSIGN aux_descresu = "TOTAL GERAL".
        DISPLAY STREAM str_1 aux_fill
                             aux_descresu
                             aux_qtdregis
                             aux_vlrtotal
                             WITH FRAME f_total.
    END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

        
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).  

    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        DO:
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.



/******************************************************************************
Relatorio Tarifa Pendente
******************************************************************************/
PROCEDURE rel-tarifa-pendente-resumido:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.
    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.
    DEF VAR aux_vlhistor        AS DECI                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.cdhistor AT 1 LABEL "HISTORICO"       
         tt-relestorno.dshistor AT 16 LABEL "SIGLA"         FORMAT "x(54)"
         tt-relestorno.inpessoa AT 72 LABEL "TIPO"          FORMAT "x(7)"
         aux_vlhistor           AT 81 LABEL "VALOR"         FORMAT "zzz,zzz,zzz,zz9.99"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_pendente.
                                               
    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 83 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 83 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_qtregpac = 0
           aux_vltotpac = 0
           aux_fill = FILL("-",130)
           aux_lssubgru = "".

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    ASSIGN aux_controle = 0
           aux_qtquebra = 0
           aux_vltotpac = 0. 

    FOR EACH craplat WHERE craplat.insitlat  = 1                AND
                          (craplat.dtmvtolt >= par_dtinicio     AND
                           craplat.dtmvtolt <= par_dtafinal)    NO-LOCK:
        
        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhisest > 0 THEN
            DO:
                IF  par_cdhisest <> craplat.cdhistor THEN
                    NEXT.
            END.
        
        IF  par_cdhistor > 0 THEN
            DO:
                IF  par_cdhistor <> craplat.cdhistor THEN
                    NEXT.
            END.

        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.
        
        /* Selecionou cooperativa logado na CECRED */
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.
        
        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.

                IF  par_inpessoa <> crapass.inpessoa AND 
                    par_inpessoa  > 0                THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN aux_cdcritic = 526.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        ASSIGN aux_vltotpac = aux_vltotpac + craplat.vltarifa.

        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa
               aux_vltotpac = 0.

    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
    
   { sistema/generico/includes/b1cabrel132.i "11" "646" }.
                                                     
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    DISPLAY STREAM str_1 aux_cdagenci
                     par_dtinicio
                     aux_varchara
                     par_dtafinal
                     WITH FRAME f_cabtar.
            
    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0
           aux_vltotpac = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.cdhistor:

        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa
               aux_vlhistor = aux_vlhistor + tt-relestorno.vltarifa.

        IF  FIRST-OF(tt-relestorno.cdagenci) OR 
            (LINE-COUNTER(str_1) > PAGE-SIZE(str_1)) THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci 
                                   NO-LOCK NO-ERROR.
        
                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
        
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.
                    END.
                    

                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.

            END.

        IF  LAST-OF(tt-relestorno.cdhistor) THEN
            DO:
                DISPLAY STREAM str_1 tt-relestorno.cdhistor
                                     tt-relestorno.dshistor
                                     tt-relestorno.inpessoa
                                     aux_vlhistor
                                     WITH FRAME f_pendente.
    
                DOWN STREAM str_1 WITH FRAME f_pendente.

                ASSIGN aux_vlhistor = 0.
            END.

         IF  LAST-OF(tt-relestorno.cdagenci) THEN
             DO:
                IF  aux_qtdregis > 1 THEN
                    DO:
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac
                                             aux_vltotpac
                                             WITH FRAME f_resumo.
                    END.

                 ASSIGN aux_qtregpac = 0
                        aux_vltotpac = 0.

                 IF  aux_controle < aux_qtdregis THEN
                     DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1.
                        PAGE STREAM str_1.
                     END. 
             END.
    END.                      

    IF  aux_qtquebra > 1 THEN
    DO:
        ASSIGN aux_descresu = "TOTAL GERAL".
        DISPLAY STREAM str_1 aux_fill
                             aux_descresu
                             aux_qtdregis
                             aux_vlrtotal
                             WITH FRAME f_total.
    END.

    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.

        
    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).  

    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        DO:
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.

/******************************************************************************
Relatorio Estouro CC
******************************************************************************/
PROCEDURE rel-estouro-cc:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.
    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.dtmvtolt AT  1 LABEL "DATA"          FORMAT "99/99/9999"
         tt-relestorno.cdhistor AT 15 LABEL "HISTORICO"
         tt-relestorno.dshistor AT 30 LABEL "SIGLA"         FORMAT "x(50)"
         tt-relestorno.inpessoa AT 85 LABEL "TIPO"          FORMAT "x(7)"
         tt-relestorno.nrdconta AT 98 LABEL "CONTA/DV"
         tt-relestorno.vltarifa AT 113 LABEL "VALOR"         FORMAT "zzz,zzz,zzz,zz9.99"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_pendente.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 106 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 106 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_fill = FILL("-",130).

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    IF  par_cdcoptel > 0 THEN
        FIND crapdat WHERE crapdat.cdcooper = par_cdcoptel NO-LOCK NO-ERROR.
    ELSE
        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapdat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Data atual nao encontrada!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 3                AND
                          (craplat.dtmvtolt >= par_dtinicio     AND
                           craplat.dtmvtolt <= par_dtafinal)    AND 
                           craplat.cdmotest = 99999             NO-LOCK:

        IF  NOT ( craplat.dtmvtolt < crapdat.dtmvtolt ) THEN
            NEXT.

        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhistor > 0 THEN
            DO:
                IF  par_cdhistor <> craplat.cdhistor THEN
                    NEXT.
            END.

        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.

        /*Selecionou cooperativa logado na CECRED*/
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.

                IF  par_inpessoa <> crapass.inpessoa AND 
                    par_inpessoa  > 0                THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO: 
                ASSIGN aux_cdcritic = 526.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.
    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.

   { sistema/generico/includes/b1cabrel132.i "11" "647" }.

    VIEW STREAM str_1 FRAME f_cabrel132_1.
    DISPLAY STREAM str_1 aux_cdagenci
                         par_dtinicio
                         aux_varchara
                         par_dtafinal
                         WITH FRAME f_cabtar.

    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.dtmvtolt:

        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa.

        IF  FIRST-OF(tt-relestorno.cdagenci) OR 
            (LINE-COUNTER(str_1) > PAGE-SIZE(str_1)) THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci 
                                   NO-LOCK NO-ERROR.
        
                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
        
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.
                    END.      


                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.
            END.

        DISPLAY STREAM str_1 tt-relestorno.dtmvtolt
                             tt-relestorno.cdhistor
                             tt-relestorno.dshistor
                             tt-relestorno.inpessoa
                             tt-relestorno.nrdconta
                             tt-relestorno.vltarifa
                             WITH FRAME f_pendente.

         DOWN STREAM str_1 WITH FRAME f_pendente.

         IF  LAST-OF(tt-relestorno.cdagenci) THEN
             DO:
                IF  aux_qtdregis > 1 THEN
                    DO:
                        ASSIGN aux_descresu = "".
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac
                                             aux_vltotpac
                                             WITH FRAME f_resumo.
                    END.

                 ASSIGN aux_qtregpac = 0
                        aux_vltotpac = 0.

                 IF  aux_controle < aux_qtdregis THEN
                     DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1.
                        PAGE STREAM str_1.
                     END. 
             END.
    END.                      

    IF  aux_qtquebra > 1 THEN
        DO:
            ASSIGN aux_descresu = "TOTAL GERAL".
            DISPLAY STREAM str_1 aux_fill 
                                 aux_descresu
                                 aux_qtdregis
                                 aux_vlrtotal
                                 WITH FRAME f_total.
        END.
    
    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.


    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).     

     DELETE PROCEDURE h-b1wgen0024. 

    IF  RETURN-VALUE <> "OK"   THEN
        DO:
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.


/******************************************************************************
Relatorio Estouro CC
******************************************************************************/
PROCEDURE rel-estouro-cc-resumido:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_tprelato AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                    NO-UNDO.

    DEF INPUT PARAM par_cdcoptel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagetel AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtafinal AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_nmendter AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                   NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                          NO-UNDO.

    DEF VAR aux_cdagenci        AS CHAR                     NO-UNDO.
    DEF VAR aux_qtdregis        AS INTE                     NO-UNDO.
    DEF VAR aux_vlrtotal        AS DECI                     NO-UNDO.
    DEF VAR aux_qtregpac        AS INTE                     NO-UNDO.
    DEF VAR aux_vltotpac        AS DECI                     NO-UNDO.
    DEF VAR aux_controle        AS INTE                     NO-UNDO.
    DEF VAR aux_qtquebra        AS INTE                     NO-UNDO.
    DEF VAR aux_varchara        AS CHAR INITIAL "A"         NO-UNDO.
    DEF VAR aux_fill            AS CHAR                     NO-UNDO.
    DEF VAR aux_flquebra        AS LOGICAL                  NO-UNDO.
    DEF VAR aux_nmrescop        AS CHAR                     NO-UNDO.
    DEF VAR aux_descresu        AS CHAR                     NO-UNDO.
    DEF VAR aux_lssubgru        AS CHAR                     NO-UNDO.
    DEF VAR aux_lshistor        AS CHAR                     NO-UNDO.
    DEF VAR aux_vlhistor        AS DECI                     NO-UNDO.

    FORM aux_nmrescop              LABEL "Cooperativa"     FORMAT "x(40)"
         aux_cdagenci              LABEL "PA"              FORMAT "x(30)"
         par_dtinicio              LABEL "PERIODO"         FORMAT "99/99/9999"
         aux_varchara              NO-LABEL                FORMAT "x(1)"
         par_dtafinal              NO-LABEL                FORMAT "99/99/9999"
         SKIP(1)
         WITH NO-BOX NO-ATTR-SPACE SIDE-LABEL DOWN WIDTH 132 FRAME f_cabtar.

    FORM tt-relestorno.cdhistor AT 1  LABEL "HISTORICO"
         tt-relestorno.dshistor AT 16 LABEL "SIGLA"         FORMAT "x(83)"
         tt-relestorno.inpessoa AT 103 LABEL "TIPO"          FORMAT "x(7)"
         aux_vlhistor           AT 113 LABEL "VALOR"         FORMAT "zzz,zzz,zzz,zz9.99"
         WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_pendente.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_qtregpac AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vltotpac AT 106 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_resumo.

    FORM SKIP(1)
         aux_fill           NO-LABEL                       FORMAT "X(130)" 
         SKIP        
         aux_descresu AT 01 NO-LABEL                       FORMAT "x(15)"
         aux_qtdregis AT 43 LABEL "QUANTIDADE DE REGISTROS"        
         aux_vlrtotal AT 106 LABEL "VALOR"                  FORMAT "zzz,zzz,zzz,zz9.99"
         WITH SIDE-LABEL DOWN WIDTH 132 FRAME f_total.

    ASSIGN par_nmarqimp = "/usr/coop/viacredi/rl/" + par_nmendter + STRING(TIME) + ".ex"
           aux_qtdregis = 0
           aux_vlrtotal = 0
           aux_vltotpac = 0
           aux_qtregpac = 0
           aux_fill = FILL("-",130).

    /*cria lista de subgrupos caso usuario 
    tem filtrado apenas por grupo*/
    IF  par_cdhistor = 0 AND 
        par_cddgrupo > 0 THEN
        DO:   
           RUN busca-lista-historico(INPUT  par_cddgrupo,
                                     INPUT  par_cdsubgru,
                                     OUTPUT aux_lshistor,
                                     OUTPUT aux_lssubgru).
        END.

    IF  par_cdcoptel > 0 THEN
        FIND crapdat WHERE crapdat.cdcooper = par_cdcoptel NO-LOCK NO-ERROR.
    ELSE
        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapdat) THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Data atual nao encontrada!".

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FOR EACH craplat WHERE craplat.insitlat  = 3                AND
                          (craplat.dtmvtolt >= par_dtinicio     AND
                           craplat.dtmvtolt <= par_dtafinal)    AND 
                           craplat.cdmotest = 99999             NO-LOCK:

        IF  NOT ( craplat.dtmvtolt < crapdat.dtmvtolt ) THEN
            NEXT.

        IF  aux_lshistor <> "" THEN
            DO: 
                IF  NOT CAN-DO(aux_lshistor,STRING(craplat.cdhistor)) THEN
                    NEXT.
            END.

        IF  par_cdhistor > 0 THEN
            DO:
                IF  par_cdhistor <> craplat.cdhistor THEN
                    NEXT.
            END.

        IF  par_nrdconta > 0 THEN
            DO:
                IF  par_nrdconta <> craplat.nrdconta THEN
                    NEXT.
            END.

        /*Selecionou cooperativa logado na CECRED*/
        IF  par_cdcoptel > 0 THEN
            DO:
                IF  par_cdcoptel <> craplat.cdcooper THEN
                    NEXT.
            END.
        ELSE
            DO:
                IF  par_cdcooper <> 3 THEN
                    DO:
                        IF  par_cdcooper <> craplat.cdcooper THEN
                            NEXT.
                    END.
            END.

        FIND crapass WHERE  crapass.cdcooper = craplat.cdcooper AND
                            crapass.nrdconta = craplat.nrdconta NO-LOCK NO-ERROR.

        IF  AVAIL(crapass) THEN
            DO:
                IF  par_cdagetel > 0 THEN
                    DO:
                        IF  par_cdagetel <> crapass.cdagenci THEN
                            NEXT.
                    END.

                IF  par_inpessoa <> crapass.inpessoa AND 
                    par_inpessoa  > 0                THEN
                    NEXT.
            END.

        FIND craphis WHERE craphis.cdcooper = craplat.cdcooper AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO: 
                ASSIGN aux_cdcritic = 526.
    
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT 1, /* nrdcaixa  */
                               INPUT 1, /* sequencia */
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        CREATE tt-relestorno.
        ASSIGN tt-relestorno.dtmvtolt = craplat.dtmvtolt
               tt-relestorno.cdhistor = craplat.cdhistor
               tt-relestorno.dshistor = craphis.dshistor
               tt-relestorno.nrdconta = craplat.nrdconta
               tt-relestorno.vltarifa = craplat.vltarifa
               tt-relestorno.cdcooper = craplat.cdcooper
               tt-relestorno.cdagenci = crapass.cdagenci
               tt-relestorno.inpessoa = IF crapass.inpessoa = 1 THEN
                                            "PF"
                                        ELSE
                                            "PJ"
               aux_qtdregis = aux_qtdregis + 1
               aux_vlrtotal = aux_vlrtotal + craplat.vltarifa.
    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.

   { sistema/generico/includes/b1cabrel132.i "11" "647" }.

    VIEW STREAM str_1 FRAME f_cabrel132_1.
    DISPLAY STREAM str_1 aux_cdagenci
                         par_dtinicio
                         aux_varchara
                         par_dtafinal
                         WITH FRAME f_cabtar.

    ASSIGN aux_flquebra = FALSE
           aux_controle = 0
           aux_qtquebra = 0
           aux_qtregpac = 0.

    FOR EACH tt-relestorno NO-LOCK BREAK BY tt-relestorno.cdcooper
                                         BY tt-relestorno.cdagenci
                                         BY tt-relestorno.cdhistor:

        ASSIGN aux_qtregpac = aux_qtregpac + 1
               aux_controle = aux_controle + 1
               aux_vltotpac = aux_vltotpac + tt-relestorno.vltarifa 
               aux_vlhistor = aux_vlhistor + tt-relestorno.vltarifa.

        IF  FIRST-OF(tt-relestorno.cdagenci) OR 
            (LINE-COUNTER(str_1) > PAGE-SIZE(str_1)) THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = tt-relestorno.cdcooper
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcop) THEN
                    DO:
                        ASSIGN aux_cdcritic = 794.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.

                ASSIGN aux_nmrescop = crapcop.nmrescop.

                FIND crapage WHERE crapage.cdcooper = tt-relestorno.cdcooper AND
                                   crapage.cdagenci = tt-relestorno.cdagenci 
                                   NO-LOCK NO-ERROR.
        
                IF  NOT AVAIL(crapage) THEN
                    DO:
                        ASSIGN aux_cdcritic = 15.
            
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
        
                ASSIGN aux_cdagenci = STRING(crapage.cdagenci) + " - " + 
                                      crapage.nmresage.

                IF  aux_flquebra = TRUE THEN
                    DO:
                        IF  aux_controle < aux_qtdregis THEN
                            DO:
                                ASSIGN aux_qtquebra = aux_qtquebra + 1.
                                PAGE STREAM str_1.
                            END.
                    END.      


                ASSIGN aux_flquebra = TRUE.

                VIEW STREAM str_1 FRAME f_cabrel132_1.
                DISPLAY STREAM str_1 aux_nmrescop
                                     aux_cdagenci
                                     par_dtinicio
                                     aux_varchara
                                     par_dtafinal
                                     WITH FRAME f_cabtar.
            END.

        IF  LAST-OF(tt-relestorno.cdhistor) THEN
            DO:
                DISPLAY STREAM str_1 tt-relestorno.cdhistor
                                     tt-relestorno.dshistor
                                     tt-relestorno.inpessoa
                                     aux_vlhistor
                                     WITH FRAME f_pendente.
        
                 DOWN STREAM str_1 WITH FRAME f_pendente.

                 ASSIGN aux_vlhistor = 0.
            END.

         IF  LAST-OF(tt-relestorno.cdagenci) THEN
             DO:
                IF  aux_qtdregis > 1 THEN
                    DO:
                        ASSIGN aux_descresu = "".
                        DISPLAY STREAM str_1 aux_fill
                                             aux_qtregpac
                                             aux_vltotpac
                                             WITH FRAME f_resumo.
                    END.

                 ASSIGN aux_qtregpac = 0
                        aux_vltotpac = 0.

                 IF  aux_controle < aux_qtdregis THEN
                     DO:
                        ASSIGN aux_qtquebra = aux_qtquebra + 1.
                        PAGE STREAM str_1.
                     END. 
             END.
    END.                      

    IF  aux_qtquebra > 1 THEN
        DO:
            ASSIGN aux_descresu = "TOTAL GERAL".
            DISPLAY STREAM str_1 aux_fill 
                                 aux_descresu
                                 aux_qtdregis
                                 aux_vlrtotal
                                 WITH FRAME f_total.
        END.
    
    OUTPUT STREAM str_1 CLOSE.

    /* Gera relatorio em PDF */
    RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.


    RUN envia-arquivo-web IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_nmarqimp,
                             OUTPUT par_nmarqpdf,
                             OUTPUT TABLE tt-erro).     

     DELETE PROCEDURE h-b1wgen0024. 

    IF  RETURN-VALUE <> "OK"   THEN
        DO:
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE valida-replicacao-credito: 

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdfaixav AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_lstcdcop AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtdiv AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstdtvig AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvlrep AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvltar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstlcrem AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cont             AS INTE                    NO-UNDO.
    DEF VAR aux_cdfvlcop         AS INTE                    NO-UNDO.
    DEF VAR aux_msgerr           AS CHAR                    NO-UNDO.
    DEF VAR aux_flgerr           AS LOGICAL INITIAL FALSE   NO-UNDO.
    DEF VAR aux_quebra           AS INTE                    NO-UNDO.


    /*verificacao de registro duplicado*/
    ASSIGN aux_msgerr = 'Ja existem registros com mesma data' +
                        ' de vigencia para a(s) Linha(s) de Credito: </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        FIND FIRST crapfco WHERE crapfco.cdfaixav = par_cdfaixav        AND
                                 crapfco.cdcooper = 
                                 INTE(ENTRY(aux_cont,par_lstcdcop,';')) AND
                                 crapfco.dtvigenc = 
                                 DATE(ENTRY(aux_cont,par_lstdtvig,';')) AND
                                 crapfco.cdlcremp = 
                                 INTE(ENTRY(aux_cont,par_lstlcrem,';')) 
                                 NO-LOCK NO-ERROR.

        IF  AVAIL(crapfco) THEN
            DO:

                ASSIGN aux_quebra = aux_quebra + 1
                       aux_msgerr = aux_msgerr + 
                                    ENTRY(aux_cont,par_lstlcrem,';') + ', '
                       aux_flgerr = TRUE.

                IF  aux_quebra = 10 THEN
                    DO:
                        ASSIGN aux_msgerr = aux_msgerr + '</br>'
                               aux_quebra = 0.
                    END.
            END.

    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.


    /*verifica registros com data vigencia menor que a data atual*/
    ASSIGN aux_msgerr = 'Existem registros com data' +
                        ' de vigencia menor ou igual a data atual' +
                        ' para a(s) Linha(s) de Credito: </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  AVAIL(crapdat) THEN
            DO:
                IF  DATE(ENTRY(aux_cont,par_lstdtvig,';')) <= 
                    crapdat.dtmvtolt THEN
                DO:
                    ASSIGN aux_quebra = aux_quebra + 1
                           aux_msgerr = aux_msgerr + 
                                        ENTRY(aux_cont,par_lstlcrem,';') + ', '
                           aux_flgerr = TRUE.

                    IF  aux_quebra = 10 THEN
                        DO:
                            ASSIGN aux_msgerr = aux_msgerr + '</br>'
                                   aux_quebra = 0.
                        END.

                END.
            END.
    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.    


    /*verifica registros com data divulgacao maior que a data vigencia*/
    ASSIGN aux_msgerr = 'Existem registros com data' +
                        ' de divulgacao maior ou igual a data vigencia' +
                        ' para a(s) Linha(s) de Credito: </br>'
           aux_quebra = 0.

    DO aux_cont=1 TO NUM-ENTRIES(par_lstcdcop,';'):

        IF  DATE(ENTRY(aux_cont,par_lstdtdiv,';')) >=
            DATE(ENTRY(aux_cont,par_lstdtvig,';')) THEN
        DO:
            ASSIGN aux_quebra = aux_quebra + 1
                   aux_msgerr = aux_msgerr + 
                                ENTRY(aux_cont,par_lstlcrem,';') + ', '
                   aux_flgerr = TRUE.

            IF  aux_quebra = 10 THEN
                DO:
                    ASSIGN aux_msgerr = aux_msgerr + '</br>'
                           aux_quebra = 0.
                END.     
        END.

    END.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_flgerr = TRUE THEN
        DO:
            ASSIGN aux_cdcritic = 0
				   aux_dscritic = aux_msgerr.

            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,
                           INPUT 1, /* nrdcaixa  */
                           INPUT 1, /* sequencia */
                           INPUT aux_cdcritic,        
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.   


    RETURN "OK".
END PROCEDURE.


/* Solicitacao de envio para o responsavel para monitoracao dos erros */
PROCEDURE solicitar_envio_email:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_destino  AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_assunto  AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_conteudo AS CHAR                    NO-UNDO.
    
    DEF   VAR b1wgen0011   AS HANDLE                        NO-UNDO.
    DEF   VAR aux_dscritic AS CHAR                          NO-UNDO.

    /* envio de email */
    RUN sistema/generico/procedures/b1wgen0011.p
        PERSISTENT SET b1wgen0011.
         
    RUN solicita_email_oracle IN b1wgen0011
                     ( INPUT  par_cdcooper        /* par_cdcooper         */
                      ,INPUT  par_cdprogra        /* par_cdprogra         */
                      ,INPUT  par_destino         /* par_des_destino      */
                      ,INPUT  par_assunto         /* par_des_assunto      */
                      ,INPUT  par_conteudo        /* par_des_corpo        */
                      ,INPUT  ""                  /* par_des_anexo        */
                      ,INPUT  "S"                 /* par_flg_remove_anex  */
                      ,INPUT  "N"                 /* par_flg_remete_coop  */
                      ,INPUT  ""                  /* par_des_nome_reply   */
                      ,INPUT  ""                  /* par_des_email_reply  */
                      ,INPUT  "S"                 /* par_flg_log_batch    */
                      ,INPUT  "N"                 /* par_flg_enviar       */
                      ,OUTPUT aux_dscritic        /* par_des_erro         */
                       ).
  
    DELETE PROCEDURE b1wgen0011. 
    
    IF aux_dscritic <> "" THEN
    DO:
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + par_cdprogra + "' --> '"  +
                              "Erro ao rodar: " + 
                              "'" + aux_dscritic + "'" + " >> log/proc_batch.log").
      RETURN.
    END.

END PROCEDURE.

/******************************************************************************
 Listagem de Faixa de Valores com as suas tarifas
******************************************************************************/
PROCEDURE lista-fvl-tarifa:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcatego AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdlcremp AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrconven AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-faixavalores.

    DEF VAR aux_nrregist AS INTE                            NO-UNDO.
    DEF VAR aux_cdocorre AS INTE                            NO-UNDO.

    EMPTY TEMP-TABLE tt-faixavalores.

    ASSIGN aux_nrregist = 0.
                     
    FOR EACH crapfco  WHERE  crapfco.cdcooper = par_cdcooper    
                        AND  crapfco.flgvigen = TRUE
                        AND (crapfco.cdlcremp = par_cdlcremp OR -1 = par_cdlcremp)
                        AND (crapfco.nrconven = par_nrconven OR 0 = par_nrconven)
                        NO-LOCK,

        FIRST crapfvl WHERE crapfvl.cdfaixav = crapfco.cdfaixav NO-LOCK,

        FIRST craptar WHERE  craptar.cdtarifa = crapfvl.cdtarifa 
                        AND (craptar.cdtarifa = par_cdtarifa OR 0 = par_cdtarifa)
                        AND (craptar.cdsubgru = par_cdsubgru OR 0 = par_cdsubgru)
                        AND (craptar.cdcatego = par_cdcatego OR 0 = par_cdcatego)
                        NO-LOCK:

        FIND crapcco WHERE crapcco.cdcooper = par_cdcooper AND
                           crapcco.nrconven = par_nrconven AND
                           crapcco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

        ASSIGN aux_cdocorre = 0.
        IF  AVAIL(crapcco) THEN 
            DO:
                ASSIGN aux_cdocorre = IF crapcco.flgregis = FALSE
                                      THEN 0
                                      ELSE 1.
            END.
        
        CREATE tt-faixavalores.
        ASSIGN tt-faixavalores.cdtarifa = craptar.cdtarifa
               tt-faixavalores.dstarifa = craptar.dstarifa
               tt-faixavalores.cdfaixav = crapfvl.cdfaixav
               tt-faixavalores.vlinifvl = crapfvl.vlinifvl
               tt-faixavalores.vlfinfvl = crapfvl.vlfinfvl
               tt-faixavalores.vltarifa = crapfco.vltarifa
               tt-faixavalores.cdlcremp = crapfco.cdlcremp
               tt-faixavalores.nrconven = crapfco.nrconven
               tt-faixavalores.cdocorre = aux_cdocorre
               tt-faixavalores.tpcobtar = crapfco.tpcobtar
               tt-faixavalores.vlpertar = crapfco.vlpertar
               tt-faixavalores.vlmintar = crapfco.vlmintar
               tt-faixavalores.vlmaxtar = crapfco.vlmaxtar
               aux_nrregist = aux_nrregist + 1.
    END.
      
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Inclusao de lista de tarifas na fco
******************************************************************************/
PROCEDURE incluir-lista-cadfco:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtdivulg AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtvigenc AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_lstfaixa AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstvltar AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstconve AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstocorr AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_lstlcrem AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdinctar AS INTE                    NO-UNDO.
	DEF INPUT PARAM par_lstvlper AS CHAR                    NO-UNDO.
	DEF INPUT PARAM par_lstvlmin AS CHAR                    NO-UNDO.
	DEF INPUT PARAM par_lstvlmax AS CHAR                    NO-UNDO.	
	DEF INPUT PARAM par_lsttptar AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cont             AS INTE                    NO-UNDO.
    DEF VAR aux_cdfvlcop         AS INTE                    NO-UNDO.

    DO aux_cont = 1 TO NUM-ENTRIES(par_lstfaixa,';'):

        RUN busca-novo-cdfvlcop(INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                OUTPUT aux_cdfvlcop).

        RUN incluir-cadfco(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT aux_cdfvlcop,
                           INPUT par_cdcooper,
                           INPUT INTE(ENTRY(aux_cont,par_lstfaixa,';')),
                           INPUT FALSE,
                           INPUT DECI(REPLACE(ENTRY(aux_cont,par_lstvltar,';'), ".", ",")),
                           INPUT 0,
                           INPUT DATE(par_dtdivulg),
                           INPUT DATE(par_dtvigenc),
                           INPUT FALSE,
                           INPUT INTE(ENTRY(aux_cont,par_lstconve,';')),
                           INPUT INTE(ENTRY(aux_cont,par_lstocorr,';')),
                           INPUT INTE(ENTRY(aux_cont,par_lstlcrem,';')),
                           INPUT par_cdinctar,
						   INPUT INTE(ENTRY(aux_cont,par_lsttptar,';')),
						   INPUT DECI(REPLACE(ENTRY(aux_cont,par_lstvlper,';'), ".", ",")),
						   INPUT DECI(REPLACE(ENTRY(aux_cont,par_lstvlmin,';'), ".", ",")),
						   INPUT DECI(REPLACE(ENTRY(aux_cont,par_lstvlmax,';'), ".", ",")),					   
                           OUTPUT TABLE tt-erro).

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL(tt-erro) THEN
           DO:
               RETURN "NOK".
           END.

    END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE consulta-pacotes-tarifas:
                                                                
    DEFINE INPUT  PARAMETER par_cdcooper AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdpacote AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dspacote AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrregist AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nriniseq AS INTE                NO-UNDO.
    DEFINE OUTPUT PARAMETER par_qtregist AS INTE                NO-UNDO.
                                                                
    DEFINE OUTPUT PARAMETER TABLE FOR tt-tbtarif-pacotes.               
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.                  
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-tbtarif-pacotes.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
   
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
   
   /* Efetuar a chamada a rotina Oracle  */
   RUN STORED-PROCEDURE pc_consulta_pct_tar_car
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cddopcao /* Opcao Selecionado em Tela */
                                           ,INPUT par_cdpacote /* Código do Pacote de Tarifas */
                                           ,INPUT par_dspacote /* Descricao do Pacote de Tarifas */
                                           ,INPUT par_nrregist /* Numero de Registros Exibidos */
                                           ,INPUT par_nriniseq /* Registro Inicial */
                                           ,OUTPUT 0           /* Quantidade de Registros */
                                           ,OUTPUT ?           /* XML com dos Pacotes de tarifas */
                                           ,OUTPUT 0           /* Código da crítica */
                                           ,OUTPUT "").        /* Descrição da crítica */

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_consulta_pct_tar_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
   
   /* Busca possíveis erros */ 
   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          
          aux_cdcritic = pc_consulta_pct_tar_car.pr_cdcritic 
                         WHEN pc_consulta_pct_tar_car.pr_cdcritic <> ?
          aux_dscritic = pc_consulta_pct_tar_car.pr_dscritic 
                         WHEN pc_consulta_pct_tar_car.pr_dscritic <> ?
          par_qtregist = pc_consulta_pct_tar_car.pr_qtregist 
                         WHEN pc_consulta_pct_tar_car.pr_qtregist <> ?.
                                
   IF aux_cdcritic <> 0 OR
      aux_dscritic <> "" THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        RETURN "NOK".
        
     END.

   EMPTY TEMP-TABLE tt-tbtarif-pacotes.

   /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
   
   /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_pct_tar_car.pr_clobxmlc. 
        
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
        DO:
        
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
                IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 
        
                IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-tbtarif-pacotes.
        
                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
                    xRoot2:GET-CHILD(xField,aux_cont).
                        
                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
                    
                    xField:GET-CHILD(xText,1).
                    
                    ASSIGN tt-tbtarif-pacotes.cdpacote            =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdpacote".
                    ASSIGN tt-tbtarif-pacotes.dspacote            =      xText:NODE-VALUE  WHEN xField:NAME = "dspacote".
                    ASSIGN tt-tbtarif-pacotes.cdtarifa_lancamento =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtarifa_lancamento".
                    ASSIGN tt-tbtarif-pacotes.dstarifa            =      xText:NODE-VALUE  WHEN xField:NAME = "dstarifa".
                    ASSIGN tt-tbtarif-pacotes.flgsituacao         =  INT(xText:NODE-VALUE) WHEN xField:NAME = "flgsituacao".
                    ASSIGN tt-tbtarif-pacotes.dtmvtolt            = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt" AND xText:NODE-VALUE <> "01/01/1900".
                    ASSIGN tt-tbtarif-pacotes.dtcancelamento      = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcancelamento" AND xText:NODE-VALUE <> "01/01/1900".
                    ASSIGN tt-tbtarif-pacotes.dspessoa            =      xText:NODE-VALUE  WHEN xField:NAME = "dspessoa".
                    ASSIGN tt-tbtarif-pacotes.tppessoa            =  INT(xText:NODE-VALUE) WHEN xField:NAME = "tppessoa".
                    ASSIGN tt-tbtarif-pacotes.cddopcao            =      xText:NODE-VALUE  WHEN xField:NAME = "cddopcao".
					ASSIGN tt-tbtarif-pacotes.vlpacote            = STRING(DEC(xText:NODE-VALUE),"zzz,zz9.99")  WHEN xField:NAME = "vlpacote".
                END. 
                
            END.
        
            SET-SIZE(ponteiro_xml) = 0. 
        END.
                                                             
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE consulta_pacote_manpac:
                                                                
    DEFINE INPUT  PARAMETER par_cdcooper AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdpacote AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dspacote AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrregist AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nriniseq AS INTE                NO-UNDO.
    DEFINE OUTPUT PARAMETER par_qtregist AS INTE                NO-UNDO.
                                                                
    DEFINE OUTPUT PARAMETER TABLE FOR tt-tbtarif-pacotes.               
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.                  
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-tbtarif-pacotes.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
   
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
   
   /* Efetuar a chamada a rotina Oracle  */
   RUN STORED-PROCEDURE pc_pesquisa_manpac_car
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cddopcao /* Opcao Selecionado em Tela */
										   ,INPUT par_cdcooper /* Codigo da Cooperativa */
                                           ,INPUT par_cdpacote /* Código do Pacote de Tarifas */
                                           ,INPUT par_dspacote /* Descricao do Pacote de Tarifas */
                                           ,INPUT par_nrregist /* Numero de Registros Exibidos */
                                           ,INPUT par_nriniseq /* Registro Inicial */
                                           ,OUTPUT 0           /* Quantidade de Registros */
                                           ,OUTPUT ?           /* XML com dos Pacotes de tarifas */
                                           ,OUTPUT 0           /* Código da crítica */
                                           ,OUTPUT "").        /* Descrição da crítica */

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_pesquisa_manpac_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
   
   /* Busca possíveis erros */ 
   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          
          aux_cdcritic = pc_pesquisa_manpac_car.pr_cdcritic 
                         WHEN pc_pesquisa_manpac_car.pr_cdcritic <> ?
          aux_dscritic = pc_pesquisa_manpac_car.pr_dscritic 
                         WHEN pc_pesquisa_manpac_car.pr_dscritic <> ?
          par_qtregist = pc_pesquisa_manpac_car.pr_qtregist 
                         WHEN pc_pesquisa_manpac_car.pr_qtregist <> ?.
                                
   IF aux_cdcritic <> 0 OR
      aux_dscritic <> "" THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
               RETURN "NOK".
        
           END.

   EMPTY TEMP-TABLE tt-tbtarif-pacotes.

   /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
   
   /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_pesquisa_manpac_car.pr_clobxmlc. 
        
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
        DO:
        
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
                IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 
        
                IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-tbtarif-pacotes.
        
                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
                    xRoot2:GET-CHILD(xField,aux_cont).
                        
                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
                    
                    xField:GET-CHILD(xText,1).
                    
                    ASSIGN tt-tbtarif-pacotes.cdpacote            =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdpacote".
                    ASSIGN tt-tbtarif-pacotes.dspacote            =      xText:NODE-VALUE  WHEN xField:NAME = "dspacote".
                    ASSIGN tt-tbtarif-pacotes.cdtarifa_lancamento =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtarifa_lancamento".
                    ASSIGN tt-tbtarif-pacotes.dstarifa            =      xText:NODE-VALUE  WHEN xField:NAME = "dstarifa".
                    ASSIGN tt-tbtarif-pacotes.flgsituacao         =  INT(xText:NODE-VALUE) WHEN xField:NAME = "flgsituacao".
                    ASSIGN tt-tbtarif-pacotes.dtmvtolt            = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt" AND xText:NODE-VALUE <> "01/01/1900".
                    ASSIGN tt-tbtarif-pacotes.dtcancelamento      = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcancelamento" AND xText:NODE-VALUE <> "01/01/1900".
                    ASSIGN tt-tbtarif-pacotes.dspessoa            =      xText:NODE-VALUE  WHEN xField:NAME = "dspessoa".
                    ASSIGN tt-tbtarif-pacotes.tppessoa            =  INT(xText:NODE-VALUE) WHEN xField:NAME = "tppessoa".
                    ASSIGN tt-tbtarif-pacotes.cddopcao            =      xText:NODE-VALUE  WHEN xField:NAME = "cddopcao".
                    ASSIGN tt-tbtarif-pacotes.vlpacote            = STRING(DEC(xText:NODE-VALUE),"zzz,zz9.99")  WHEN xField:NAME = "vlpacote".
                END. 
                
            END.
        
            SET-SIZE(ponteiro_xml) = 0. 
        END.
                                                             
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE lista-tarifas-pactar:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdtarifa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dstarifa AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cddgrupo AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdsubgru AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdcatego AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-tarifas.

    DEF VAR aux_flggrupo AS LOGICAL INITIAL FALSE           NO-UNDO.
    DEF VAR aux_flsubgru AS LOGICAL INITIAL FALSE           NO-UNDO.
    DEF VAR aux_flcatego AS LOGICAL INITIAL FALSE           NO-UNDO.

    DEF VAR aux_nrregist AS INTE                            NO-UNDO.
    DEF VAR aux_cdinctar AS INTE                            NO-UNDO.
    DEF VAR aux_dsinctar AS CHAR                            NO-UNDO.
    
    DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-tarifas.
    
        ASSIGN aux_nrregist = par_nrregist.

        IF  par_cdcatego > 0 THEN
            DO:
                FIND crapcat WHERE crapcat.cdcatego = par_cdcatego
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapcat) THEN
                    RETURN "NOK".

                ASSIGN aux_flcatego = TRUE.
            END.

        IF  par_cdsubgru > 0 THEN
            DO:
                FIND crapsgr WHERE crapsgr.cdsubgru = par_cdsubgru
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapsgr) THEN
                    RETURN "NOK".

                ASSIGN aux_flsubgru = TRUE.
            END.

        IF  par_cddgrupo > 0 THEN
            DO:
                FIND crapgru WHERE crapgru.cddgrupo = par_cddgrupo
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapgru) THEN
                    RETURN "NOK".

                ASSIGN aux_flggrupo = TRUE.
            END.

        FOR EACH craptar NO-LOCK WHERE craptar.cdtarifa >= par_cdtarifa
                                   AND craptar.dstarifa MATCHES('*' + par_dstarifa + '*')
                                   AND craptar.inpessoa = par_inpessoa BY craptar.cdtarifa:
          

            /*Dados categoria*/
            FIND crapcat WHERE crapcat.cdcatego = craptar.cdcatego
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapcat) THEN
                NEXT.


            IF  par_cdcatego > 0 THEN
                IF  par_cdcatego <> craptar.cdcatego THEN
                    NEXT.

            /*Dados do subgrupo*/
            IF  crapcat.cdsubgru > 0 THEN
                DO:
                    FIND crapsgr WHERE crapsgr.cdsubgru = crapcat.cdsubgru
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL(crapsgr) THEN
                        NEXT.

                END.
            ELSE
                DO:
                    FIND crapsgr WHERE crapsgr.cdsubgru = craptar.cdsubgru
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAIL(crapsgr) THEN
                        NEXT.
                END.

            IF  par_cdsubgru > 0 THEN
                IF  par_cdsubgru <> crapsgr.cdsubgru THEN
                    NEXT.

            /*dados do grupo*/
            FIND crapgru WHERE crapgru.cddgrupo = crapsgr.cddgrupo
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapgru) THEN
                NEXT.

            IF  par_cddgrupo > 0 THEN
                IF  par_cddgrupo <> crapgru.cddgrupo THEN
                    NEXT.

            IF  craptar.cdinctar > 0 THEN
                DO:
            
                    /*busca tipo incidencia*/
                    FIND crapint WHERE crapint.cdinctar = craptar.cdinctar 
                                       NO-LOCK NO-ERROR.
            
                    IF  NOT AVAIL(crapint) THEN
                        NEXT.

                    ASSIGN aux_cdinctar = crapint.cdinctar
                           aux_dsinctar = crapint.dsinctar.
                END.
            ELSE
                DO:
                    ASSIGN aux_cdinctar = 0
                           aux_dsinctar = 'Nenhum'.
                END.


            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    /*cria registro temp-table*/
                    CREATE tt-tarifas.
                    ASSIGN tt-tarifas.cdtarifa = craptar.cdtarifa
                           tt-tarifas.dstarifa = craptar.dstarifa
                           tt-tarifas.cddgrupo = crapgru.cddgrupo
                           tt-tarifas.dsdgrupo = crapgru.dsdgrupo
                           tt-tarifas.cdsubgru = crapsgr.cdsubgru
                           tt-tarifas.dssubgru = crapsgr.dssubgru
                           tt-tarifas.cdcatego = crapcat.cdcatego
                           tt-tarifas.dscatego = crapcat.dscatego
                           tt-tarifas.cdmotivo = craptar.cdmotivo
                           tt-tarifas.cdocorre = craptar.cdocorre
                           tt-tarifas.flglaman = craptar.flglaman
                           tt-tarifas.inpessoa = craptar.inpessoa
                           tt-tarifas.idinctar = aux_cdinctar
                           tt-tarifas.dsinctar = aux_dsinctar
                           tt-tarifas.dspessoa = IF craptar.inpessoa = 1 THEN
                                                    "FISICA"
                                                 ELSE
                                                    "JURIDICA".
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.
    END.

    RETURN "OK".
END PROCEDURE.
