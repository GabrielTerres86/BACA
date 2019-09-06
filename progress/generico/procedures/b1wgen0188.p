/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+----------------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL                    |
  +------------------------------------------+----------------------------------------+
  | sistema/generico/procedures/b1wgen0188.p |                                        |
  |   busca_dados                            |	EMPR0002.pc_busca_dados_cpa           |
  |   valida_dados                            |	EMPR0002.pc_valid_dados_cpa           |
  +------------------------------------------+----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
    
*******************************************************************************/

/*..............................................................................

    Programa  : b1wgen0188.p
    Autor     : James Prust Junior
    Data      : Julho/2014                Ultima Atualizacao: 22/02/2019
    
    Dados referentes ao programa:

    Objetivo  : BO ref. Rotina credito pre-aprovado

    Alteracoes: 08/09/2014 - Automatização de Consultas em Propostas 
                             de Crédito (Jonata-RKAM).

                18/11/2014 - Inclusao do parametro par_nrcpfope na
                             procedure "busca_dados, valida_dados, 
                             grava_dados". (Jaison)
                
                21/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                             
                21/05/2015 - Ajuste para verificar se Cobra Multa. (James)
                
                28/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
                             de nova proposta de emprestimo para menores nao 
                             emancipados. (Reinert)
                             
                29/05/2015 - Padronizacao das consultas automatizadas
                             (GAbriel-RKAM). 
				
				19/08/2015 - Passagem do parametro cdmodali para a procedure 
						                 valida-dados-gerais da BO2. (Projeto Portabilidade
							               (Carlos Rafael Tanholi)
                             
                30/06/2015 - Ajuste nos parametros da procedure 
                             "valida-dados-gerais".(James)
                             
                12/01/2016 - Criacao da procedure imprime_demonstrativo_ayllos_web
                             para gerar demonstrativo para impressão no Ayllos Web, 
                             através da procedure pc_gera_demonstrativo_pre_aprovado
                             (Projeto 261 – Pré-Aprovado fase II - Carlos Rafael Tanholi)

                13/01/2016 - Criacao da procedure busca_carga_ativa - Pre-Aprovado fase II.
                             (Jaison/Anderson)
                             
                19/01/2016 - Alteracao na calcula_parcelas_emprestimo eliminar os registros da 
                             temp-table, quando par_idorigem = [4 – TAA] e flgdispo = false.
                             Se o pre-aprovado for contratado no fim de semana nao sera lancada
                             a tarifa direto na conta do associado, mas sim no agendamento de 
                             tarifas,para que seja lançado no próximo dia útil e quando houver saldo.
                             (Carlos Rafael Tanholi - PRJ261 – Pré-Aprovado fase II)
                             
                28/01/2016 - Criada verifica_mostra_banner_taa (Lucas Luenlli  - PRJ261 – Pré-Aprovado fase II)

                16/03/2016 - Adição do campo vllimctr na tt-dados-cpa (Dionathan)
				
				05/05/2016 - Ajustar FORMAT da variável aux_nrcpfcgc na procedure
				             imprime_previa_demonstrativo (David).
                
				11/03/2016 - Inclusao do parametro par_cdpactra na chamada da rotina
				             grava-proposta-completa.
							 PRJ 207 - Esteira de credito (Odirlei-AMcom)
                
                14/07/2016 - Ajuste nas procedures calcula_parcelas_emprestimo, calcula_taxa_emprestimo,
                             imprime_previa_demonstrativo, grava_dados para buscar a linha de crédito do
                             pré-aprovado da tabela crapcpa.
                             Ajuste no metodo verifica_mostra_banner_taa para que o código da finalidade 
                             seja buscado através da tabela crappre e a linha de crédito da tabela crapcpa 
                             e nao mais de forma fixa no código.
                
                01/08/2016 - Agora podem existir mais de uma carga ativa em caso de cargas manuais. Portanto
                             agora é preciso passar nrdconta na procedure "busca_carga_ativa" para buscar a 
                             carga ativa mais atual. Projeto 299/3 Pre aprovado fase 3 (Lombardi).
                
                10/05/2017 - Passagem dos campos de carencia. (Jaison/James - PRJ298)

                12/05/2017 - Passagem de 0 para a nacionalidade. (Jaison/Andrino)

                13/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                 crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							 (Adriano - P339).
                
                08/12/2017 - Projeto 410 - Ajuste na chamada à procedure pc_calcula_iof_epr, passando como parametro 
                             o numero do contrato - Jean (Mout´S)
                
                15/12/2017 - Inserção do campo idcobope. PRJ404 (Lombardi)
									   
                21/11/2017 - Incluir campo cdcoploj e nrcntloj na chamada da rotina 
                             grava-proposta-completa. PRJ402 - Integracao CDC
                             (Reinert)                                                                  
                
                12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)
                
                15/06/2018 - sctask0014400 Utilizacao do retorno de cdfvlcop da 
                             rotina pc_calcula_tarifa para lançar o código da 
                             faixa de valor (rotina grava_dados_conta) (Carlos)

				28/06/2018 - Ajustes projeto CDC. PRJ439 - CDC (Odirlei-AMcom)
                
                27/11/2018 - P410 - Ajuste nrseqdig na chamada pc_insere_iof ORACLE. (Douglas Pagel/AMcom)

                13/12/2018  HANDLE sem delete h-b1wgen0060 INC0027352 (Oscar).

                20/12/2018 - P298.2.2 - Apresentar pagamento na carencia (Adriano Nagasava - Supero)
                
                08/01/2019 - Ajuste da taxa mensal na impressao do contrato 
                             INC0028548 (Douglas Pagel / AMcom).

				22/02/2019 - P485. Validaçao de conta salário na exibiçao do banner Pré Aprovado no TAA. (Augusto/Supero)
				
                07/02/2019 - P442 - Direcionar para a chamada da rotina convertida 
                             na valida_dados e troca da pc_busca_carga_ativa para
                             pc_idcarga_pre_aprovado_cta (Marcos-Envolti)
                
..............................................................................*/

/*................................ DEFINICOES ............................... */
{ sistema/generico/includes/b1wgen0188tt.i  }
{ sistema/generico/includes/b1wgen0002tt.i  }
{ sistema/generico/includes/b1wgen0024tt.i  }
{ sistema/generico/includes/b1wgen0038tt.i  }
{ sistema/generico/includes/b1wgen0043tt.i  }
{ sistema/generico/includes/b1wgen0056tt.i  }
{ sistema/generico/includes/b1wgen0069tt.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen9999tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_des_reto AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF TEMP-TABLE tt-tipo-rendi                                           NO-UNDO
    FIELD tpdrendi  AS INTE
    FIELD dsdrendi  AS CHAR.

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem
    USE-INDEX crapbem2 USE-INDEX tt-crapbem AS PRIMARY.

FUNCTION rPadTexto RETURNS CHAR(INPUT par_destexto AS CHAR,
                                INPUT par_nrformat AS INTE):

    RETURN par_destexto + FILL("*",par_nrformat - LENGTH(par_destexto)).

END FUNCTION.

PROCEDURE busca_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-dados-cpa.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
                
    DEF VAR aux_des_reto AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcooper AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagenci AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdcaixa AS INTE                                    NO-UNDO.
    DEF VAR aux_nrsequen AS INTE                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
	DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_idcarga  AS INTE                                    NO-UNDO.
    DEF VAR aux_cdlcremp AS INTE                                    NO-UNDO.
    DEF VAR aux_vldiscrd AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
    DEF VAR aux_txmensal AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
    DEF VAR aux_vllimctr AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
	DEF VAR aux_vlcalpar AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
    DEF VAR aux_flprapol AS INTE                                    NO-UNDO.
    DEF VAR aux_msgmanua AS CHAR FORMAT "x(1000)"                   NO-UNDO.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.
    DEF VAR xRoot         AS HANDLE   NO-UNDO.
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.
    DEF VAR xField        AS HANDLE   NO-UNDO.
    DEF VAR xText         AS HANDLE   NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO.
    DEF VAR aux_cont_raiz AS INTE     NO-UNDO.
    DEF VAR aux_cont      AS INTE     NO-UNDO.
    DEF VAR xml_req       AS CHAR     NO-UNDO.

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

    EMPTY TEMP-TABLE tt-dados-cpa.
    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_dados_cpa_prog
         aux_handproc = PROC-HANDLE NO-ERROR
                       (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_cdoperad,
                        INPUT par_nmdatela,
                        INPUT par_idorigem,
                        INPUT par_nrdconta,
                        INPUT par_idseqttl,
                        INPUT par_nrcpfope,
                       OUTPUT "",  /* pr_clob_cpa */
                       OUTPUT "",  /* pr_des_reto */
                       OUTPUT ""). /* pr_clob_erro */

    CLOSE STORED-PROC pc_busca_dados_cpa_prog
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_des_reto = pc_busca_dados_cpa_prog.pr_des_reto.

    /* Se possui erro */
    IF  aux_des_reto = "NOK" THEN
       DO:
            /* Buscar o XML de retorno */ 
            ASSIGN xml_req = pc_busca_dados_cpa_prog.pr_clob_erro.

            /* Efetuar a leitura do XML */ 
            SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
            PUT-STRING(ponteiro_xml,1) = xml_req. 

            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.

            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

              xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

              IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                   NEXT. 

              /* Limpar variaveis  */ 
              ASSIGN aux_cdcooper = 0
                     aux_cdagenci = 0
                     aux_nrdcaixa = 0
                     aux_nrsequen = 0
                     aux_cdcritic = 0
                  aux_dscritic = "".
        
              DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

                xRoot2:GET-CHILD(xField,aux_cont) NO-ERROR. 

                IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 

                xField:GET-CHILD(xText,1) NO-ERROR. 

                /* Se nao vier conteudo na TAG */ 
                IF ERROR-STATUS:ERROR             OR  
                   ERROR-STATUS:NUM-MESSAGES > 0  THEN
                   NEXT.

                ASSIGN aux_cdcooper = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "cdcooper"
                       aux_cdagenci = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "cdagenci"
                       aux_nrdcaixa = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "nrdcaixa"
                       aux_nrsequen = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "nrsequen"
                       aux_cdcritic = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "cdcritic"
                       aux_dscritic = xText:NODE-VALUE        WHEN xField:NAME = "dscritic".

              END. /* Fim loop elemento */

              /* Gerar registro de critica, somente se tiver critica */
              IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
              DO:
                RUN gera_erro (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_nrsequen,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
       END.
    
            END. /* Fim loop raiz */
    
            SET-SIZE(ponteiro_xml) = 0.

            RETURN "NOK".
        END.
    ELSE
       DO:
            /* Buscar o XML de retorno */ 
            ASSIGN xml_req = pc_busca_dados_cpa_prog.pr_clob_cpa.
            /* Se existe XML */
            IF  xml_req <> ? THEN
                DO:
                    /* Efetuar a leitura do XML */ 
                    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
                    PUT-STRING(ponteiro_xml,1) = xml_req. 
        
                    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                    xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
        
                    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
                      xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 
        
                      IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                           NEXT. 
        
                      /* Limpar variaveis  */ 
                      ASSIGN aux_cdcooper = 0
                             aux_nrdconta = 0
                             aux_inpessoa = 0
                             aux_nrcpfcgc = 0
                             aux_idcarga  = 0
                             aux_vldiscrd = 0
                             aux_txmensal = 0
                             aux_vllimctr = 0
                             aux_vlcalpar = 0 
                             aux_flprapol = 0
                             aux_msgmanua = "".
        
                      DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 
        
                        xRoot2:GET-CHILD(xField,aux_cont) NO-ERROR. 

                        IF xField:SUBTYPE <> "ELEMENT" THEN 
                            NEXT. 
    
                        xField:GET-CHILD(xText,1) NO-ERROR. 
    
                        /* Se nao vier conteudo na TAG */ 
                        IF ERROR-STATUS:ERROR             OR  
                           ERROR-STATUS:NUM-MESSAGES > 0  THEN
                           NEXT.

                        ASSIGN aux_cdcooper = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "cdcooper"
                               aux_nrdconta = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "nrdconta"
                               aux_inpessoa = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "inpessoa"
                               aux_nrcpfcgc = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "nrcpfcgc"
                               aux_idcarga  = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "idcarga"
                               aux_vldiscrd = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "vldiscrd"
                               aux_txmensal = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "txmensal"
                               aux_vllimctr = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "vllimctr"
                               aux_vlcalpar = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "vlcalpar"
                               aux_flprapol = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "flprapol"
                               aux_cdlcremp = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "cdlcremp"
                               aux_msgmanua = xText:NODE-VALUE WHEN xField:NAME = "msgmanua" .
        
                      END. /* Fim loop elemento */

    CREATE tt-dados-cpa.
                      ASSIGN tt-dados-cpa.cdcooper = aux_cdcooper
                             tt-dados-cpa.nrdconta = aux_nrdconta
                             tt-dados-cpa.inpessoa = aux_inpessoa
                             tt-dados-cpa.nrcpfcgc = aux_nrcpfcgc
                             tt-dados-cpa.idcarga  = aux_idcarga 
                             tt-dados-cpa.vldiscrd = aux_vldiscrd
                             tt-dados-cpa.txmensal = aux_txmensal
                             tt-dados-cpa.vllimctr = aux_vllimctr
                             tt-dados-cpa.vlcalpar = aux_vlcalpar
                             tt-dados-cpa.cdlcremp = aux_cdlcremp
                             tt-dados-cpa.flprapol = aux_flprapol
                             tt-dados-cpa.msgmanua = aux_msgmanua .
    VALIDATE tt-dados-cpa.

                    END. /* Fim loop raiz */
        
                    SET-SIZE(ponteiro_xml) = 0.
                END.
        END.

    RETURN "OK".
    
END. /* END PROCEDURE busca_dados */

PROCEDURE valida_dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_diapagto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_valida_dados_cpa
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                         ,INPUT par_cdagenci
                                         ,INPUT par_nrdcaixa
                                         ,INPUT par_cdoperad
                                         ,INPUT par_nmdatela
                                         ,INPUT par_idorigem
                                         ,INPUT par_nrdconta                                                 
                                         ,INPUT par_idseqttl
                                         ,INPUT par_vlemprst
                                         ,INPUT par_diapagto
                                         ,INPUT par_nrcpfope
                                         ,INPUT 0
                                         ,OUTPUT 0
                                         ,OUTPUT "").
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valida_dados_cpa
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = pc_valida_dados_cpa.pr_cdcritic
                             WHEN pc_valida_dados_cpa.pr_cdcritic <> ?           
           aux_dscritic = pc_valida_dados_cpa.pr_dscritic
                             WHEN pc_valida_dados_cpa.pr_dscritic <> ?.
                      
    IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> "" THEN
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
    
END PROCEDURE. /* END PROCEDURE valida_dados */

PROCEDURE valida_dados_contrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_diapagto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }


    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_valida_dados_cpa
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                         ,INPUT par_cdagenci
                                         ,INPUT par_nrdcaixa
                                         ,INPUT par_cdoperad
                                         ,INPUT par_nmdatela
                                         ,INPUT par_idorigem
                                         ,INPUT par_nrdconta                                                 
                                         ,INPUT par_idseqttl
                                         ,INPUT par_vlemprst
                                         ,INPUT par_diapagto
                                         ,INPUT par_nrcpfope
                                         ,INPUT par_nrctremp
                                         ,OUTPUT 0
                                         ,OUTPUT "").
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valida_dados_cpa
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = pc_valida_dados_cpa.pr_cdcritic
                             WHEN pc_valida_dados_cpa.pr_cdcritic <> ?           
           aux_dscritic = pc_valida_dados_cpa.pr_dscritic
                             WHEN pc_valida_dados_cpa.pr_dscritic <> ?.
                      
    IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> "" THEN
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
    
END PROCEDURE. /* END PROCEDURE valida_dados_contrato */

PROCEDURE grava_dados:

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
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_percetop AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM nov_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrgarope LIKE crapprp.nrgarope                      NO-UNDO.
    DEF VAR aux_nrliquid LIKE crapprp.nrliquid                      NO-UNDO.
    DEF VAR aux_nrpatlvr LIKE crapprp.nrpatlvr                      NO-UNDO.
    DEF VAR aux_nrinfcad LIKE crapprp.nrinfcad                      NO-UNDO.
    DEF VAR aux_nrperger LIKE crapprp.nrperger                      NO-UNDO.
    DEF VAR aux_dtdrisco LIKE crapris.dtdrisco                      NO-UNDO.
    DEF VAR aux_dtoutris LIKE crapprp.dtoutris                      NO-UNDO.
    DEF VAR aux_vltotsfn LIKE crapprp.vltotsfn                      NO-UNDO.
    DEF VAR aux_qtopescr LIKE crapprp.qtopescr                      NO-UNDO.
    DEF VAR aux_qtifoper LIKE crapprp.qtifoper                      NO-UNDO.
    DEF VAR aux_vlopescr LIKE crapprp.vlopescr                      NO-UNDO.
    DEF VAR aux_vlrpreju LIKE crapprp.vlrpreju                      NO-UNDO.
    DEF VAR aux_vlsfnout LIKE crapprp.vlsfnout                      NO-UNDO.
    DEF VAR aux_vlsalari LIKE crapttl.vlsalari                      NO-UNDO.
    DEF VAR aux_vloutras LIKE crapprp.vloutras                      NO-UNDO.
    DEF VAR aux_vlalugue LIKE crapprp.vlalugue                      NO-UNDO.
    DEF VAR aux_vlsalcon LIKE crapprp.vlsalcon                      NO-UNDO.
    DEF VAR aux_nmempcje LIKE crapprp.nmempcje                      NO-UNDO.
    DEF VAR aux_flgdocje LIKE crapprp.flgdocje                      NO-UNDO.
    DEF VAR aux_nrctacje LIKE crapprp.nrctacje                      NO-UNDO.
    DEF VAR aux_nrcpfcje LIKE crapprp.nrcpfcje                      NO-UNDO.
    DEF VAR aux_perfatcl LIKE crapjfn.perfatcl                      NO-UNDO.
    DEF VAR aux_vlmedfat LIKE crapprp.vlmedfat                      NO-UNDO.
    DEF VAR aux_dsjusren LIKE craprpr.dsjusren                      NO-UNDO.
    DEF VAR aux_vltarifa LIKE crapepr.vltarifa                      NO-UNDO.
    DEF VAR aux_vltaxiof LIKE crapepr.vltaxiof                      NO-UNDO.
    DEF VAR aux_vltariof LIKE crapepr.vltariof                      NO-UNDO.
    DEF VAR aux_dsmesage AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
    DEF VAR aux_nomcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdbeavt AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdfinan AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrendi AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdebens AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdalien AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinterv AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgerlog AS LOG                                     NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_recidepr AS INTE                                    NO-UNDO.
    DEF VAR aux_flmudfai AS CHAR                                    NO-UNDO.
    DEF VAR aux_nivrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlprecar AS CHAR                                    NO-UNDO.
    DEF VAR aux_idcarga  AS INTE                                    NO-UNDO.
	DEF VAR aux_cdlcremp AS INTE                                    NO-UNDO.
  DEF VAR          aux_dsassdig  AS CHAR                          NO-UNDO.
  DEF VAR          aux_des_reto  AS CHAR                          NO-UNDO.

    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0084 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-dados-coope.
    EMPTY TEMP-TABLE tt-dados-assoc.
    EMPTY TEMP-TABLE tt-tipo-rendi.
    EMPTY TEMP-TABLE tt-itens-topico-rating.
    EMPTY TEMP-TABLE tt-proposta-epr.
    EMPTY TEMP-TABLE tt-crapbem.
    EMPTY TEMP-TABLE tt-bens-alienacao.
    EMPTY TEMP-TABLE tt-rendimento.
    EMPTY TEMP-TABLE tt-faturam.
    EMPTY TEMP-TABLE tt-dados-analise.
    EMPTY TEMP-TABLE tt-interv-anuentes.
    EMPTY TEMP-TABLE tt-hipoteca.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-aval-crapbem.

    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.

    IF NOT VALID-HANDLE(h-b1wgen0043) THEN
       RUN sistema/generico/procedures/b1wgen0043.p 
           PERSISTENT SET h-b1wgen0043.

    IF NOT VALID-HANDLE(h-b1wgen0084) THEN
       RUN sistema/generico/procedures/b1wgen0084.p 
           PERSISTENT SET h-b1wgen0084.

    ASSIGN aux_nrinfcad = 1 /* Informacao Cadastral */
           aux_flgerlog = TRUE
           aux_flgtrans = FALSE
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gravacao pre-aprovado"
           aux_cdcritic = 0
           aux_dscritic = "".


    GRAVA: DO TRANSACTION ON ERROR  UNDO GRAVA, LEAVE GRAVA
                          ON ENDKEY UNDO GRAVA, LEAVE GRAVA:
           
       RUN obtem-dados-proposta-emprestimo 
           IN h-b1wgen0002(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT 0,    /* par_inproces */
                           INPUT par_idorigem,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_dtmvtolt,
                           INPUT 0,    /* par_nrctremp */
                           INPUT "I",  /* par_cddopcao */
                           INPUT 0,
                           INPUT aux_flgerlog,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-dados-coope,
                           OUTPUT TABLE tt-dados-assoc,
                           OUTPUT TABLE tt-tipo-rendi,
                           OUTPUT TABLE tt-itens-topico-rating,
                           OUTPUT TABLE tt-proposta-epr,
                           OUTPUT TABLE tt-crapbem,
                           OUTPUT TABLE tt-bens-alienacao,
                           OUTPUT TABLE tt-rendimento,
                           OUTPUT TABLE tt-faturam,
                           OUTPUT TABLE tt-dados-analise,
                           OUTPUT TABLE tt-interv-anuentes,
                           OUTPUT TABLE tt-hipoteca,
                           OUTPUT TABLE tt-dados-avais,
                           OUTPUT TABLE tt-aval-crapbem,
                           OUTPUT TABLE tt-msg-confirma).
                        
       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.

       /* Dados gerais da cooperativa */
       FIND FIRST tt-dados-coope NO-LOCK NO-ERROR.
       /* Dados na crawepr */
       FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.
       /* Dados gerais do cooperado */
       FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.
       IF tt-dados-assoc.inpessoa = 1 THEN
          DO:
              ASSIGN aux_nrgarope = 10 /* Garantia */
                     aux_nrliquid = 9  /* Liquidez */
                     aux_nrpatlvr = 4  /* Patr. Pessoal livre  */
                     aux_nrperger = 0. /* Percepcao com relacao empresa */

              FOR crapttl FIELDS(nrinfcad nrpatlvr)
                          WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = 1
                                NO-LOCK: END.
              IF AVAIL crapttl THEN
                 DO:
                     IF crapttl.nrinfcad > 0 THEN
                        ASSIGN aux_nrinfcad = crapttl.nrinfcad.

                     IF crapttl.nrpatlvr > 0 THEN
                        ASSIGN aux_nrpatlvr = crapttl.nrpatlvr.
                 END.

          END. /* END IF tt-dados-assoc.inpessoa = 1 THEN */
       ELSE
          DO:
              ASSIGN aux_nrgarope = 11 /* Garantia */
                     aux_nrliquid = 11 /* Liquidez */
                     aux_nrpatlvr = 5  /* Patr. Pessoal livre  */
                     aux_nrperger = 1. /* Percepcao com relacao empresa */

              FOR crapjur FIELDS(nrinfcad nrpatlvr nrperger)
                          WHERE crapjur.cdcooper = par_cdcooper AND
                                crapjur.nrdconta = par_nrdconta 
                                NO-LOCK: END.
               
              IF AVAIL crapjur THEN
                 DO:
                     IF crapjur.nrinfcad > 0 THEN
                        ASSIGN aux_nrinfcad = crapjur.nrinfcad.

                     IF crapjur.nrpatlvr > 0 THEN
                        ASSIGN aux_nrpatlvr = crapjur.nrpatlvr.

                     IF crapjur.nrperger > 0 THEN
                        ASSIGN aux_nrperger = crapjur.nrperger.
                            
                 END.
          END.

          /* Verifica se existe limite disponível */
          RUN busca_dados (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT par_nrdconta,
                           INPUT par_idseqttl,
                           INPUT par_nrcpfope,
                           OUTPUT TABLE tt-dados-cpa,
                           OUTPUT TABLE tt-erro).
                           
          FIND tt-dados-cpa NO-LOCK NO-ERROR.
              IF  AVAIL tt-dados-cpa THEN
                  DO:
                      ASSIGN aux_idcarga  = tt-dados-cpa.idcarga
                             aux_cdlcremp = tt-dados-cpa.cdlcremp.
                  END.
        
        /*  Caso nao possua carga ativa */
        IF  aux_idcarga = 0 OR aux_cdlcremp = 0 THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Associado nao relacionado a nenhuma carga ativa.".

               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
               UNDO GRAVA, LEAVE GRAVA.
           END.
       
       /* Dados de parametrizacao do credito pre-aprovado */
        FOR crappre FIELDS(cdfinemp)
                   WHERE crappre.cdcooper = par_cdcooper            AND
                         crappre.inpessoa = tt-dados-assoc.inpessoa
                         NO-LOCK: END.

       IF NOT AVAIL crappre THEN
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Parametros pre-aprovado nao cadastrado".
           
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
              
              UNDO GRAVA, LEAVE GRAVA.
          END.

       /* Rendimento */
       FIND FIRST tt-rendimento NO-LOCK NO-ERROR.
       IF AVAIL tt-rendimento THEN
          DO:
              ASSIGN aux_vlsalari = tt-rendimento.vlsalari
                     aux_vloutras = tt-rendimento.vloutras
                     aux_vlalugue = tt-rendimento.vlalugue
                     aux_vlsalcon = tt-rendimento.vlsalcon
                     aux_nmempcje = tt-rendimento.nmextemp
                     aux_flgdocje = tt-rendimento.flgdocje
                     aux_nrctacje = tt-rendimento.nrctacje
                     aux_nrcpfcje = tt-rendimento.nrcpfcjg
                     aux_vlmedfat = tt-rendimento.vlmedfat
                     aux_dsjusren = tt-rendimento.dsjusren.

              IF tt-rendimento.perfatcl = 0 THEN
                 ASSIGN aux_perfatcl = 15.
              ELSE
                 ASSIGN aux_perfatcl = tt-rendimento.perfatcl.
          END.
    
       /* Dados do risco */
       FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.
       IF AVAIL tt-dados-analise THEN
          DO:
              ASSIGN aux_dtdrisco = tt-dados-analise.dtdrisco
                     aux_vltotsfn = tt-dados-analise.vltotsfn
                     aux_dtoutris = tt-dados-analise.dtoutris
                     aux_qtopescr = tt-dados-analise.qtopescr
                     aux_qtifoper = tt-dados-analise.qtifoper
                     aux_vlopescr = tt-dados-analise.vlopescr
                     aux_vlrpreju = tt-dados-analise.vlrpreju
                     aux_vlsfnout = tt-dados-analise.vlsfnout.
          END.
    
       RUN valida-dados-gerais IN h-b1wgen0002(INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT "I",  /* par_cddopcao */
                                               INPUT 0,    /* par_inproces */
                                               INPUT tt-dados-assoc.cdagenci,
                                               INPUT 0,    /* par_nrctremp */
                                               INPUT aux_cdlcremp,
                                               INPUT par_qtpreemp,
                                               INPUT "",   /* par_dsctrliq */
                                               INPUT tt-dados-coope.vlmaxutl,
                                               INPUT tt-dados-coope.vlmaxleg,
                                               INPUT tt-dados-coope.vlcnsscr,
                                               INPUT par_vlemprst,
                                               INPUT par_dtdpagto,
                                               INPUT 1,    /* par_inconfir */
                                               INPUT 1,    /* par_tpaltera */
                                               INPUT tt-dados-assoc.cdempres,
                                               INPUT FALSE,/* par_flgpagto */
                                               INPUT ?,    /* par_dtdpagt2 */
                                               INPUT 0,    /* par_ddmesnov */
                                               INPUT crappre.cdfinemp,
                                               INPUT 0,    /* par_qtdialib */
                                               INPUT tt-dados-assoc.inmatric,
                                               INPUT aux_flgerlog,
                                               INPUT 1,    /* par_tpemprst */
                                               INPUT par_dtmvtolt,
                                               INPUT 30,   /* par_inconfi2 */
                                               INPUT par_nrcpfope,
											   INPUT "", /* cdmodali */
                                               INPUT ?, /* par_idcarenc */
                                               INPUT ?, /* par_dtcarenc */
                                               INPUT 0,  /* par_idfiniof */
                                               INPUT 1, /* par_idquapro */
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT TABLE tt-msg-confirma,
                                               OUTPUT TABLE tt-ge-epr,
                                               OUTPUT aux_dsmesage,
                                               OUTPUT tt-proposta-epr.vlpreemp,
                                               OUTPUT tt-proposta-epr.dslcremp,
                                               OUTPUT tt-proposta-epr.dsfinemp,
                                               OUTPUT tt-proposta-epr.tplcremp,
                                               OUTPUT tt-proposta-epr.flgpagto,
                                               OUTPUT tt-proposta-epr.dtdpagto,
                                               OUTPUT aux_vlutiliz,
                                               OUTPUT aux_nivrisco,
                                               OUTPUT aux_vlprecar).
    
       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.
    
       RUN valida-itens-rating IN h-b1wgen0043(INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrdconta,
                                               INPUT aux_nrgarope,
                                               INPUT aux_nrinfcad,
                                               INPUT aux_nrliquid,
                                               INPUT aux_nrpatlvr,
                                               INPUT aux_nrperger,
                                               INPUT par_idseqttl,
                                               INPUT par_idorigem,
                                               INPUT par_nmdatela,
                                               INPUT aux_flgerlog,
                                               OUTPUT TABLE tt-erro).
    
       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.
    
       RUN valida-analise-proposta IN h-b1wgen0002(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT aux_flgerlog,
                                                   INPUT ?, /* par_dtcnsspc  */
                                                   INPUT aux_nrinfcad,
                                                   INPUT ?, /* par_dtoutspc */
                                                   INPUT aux_dtdrisco,
                                                   INPUT aux_dtoutris,
                                                   INPUT aux_nrgarope,
                                                   INPUT aux_nrliquid,
                                                   INPUT aux_nrpatlvr,
                                                   INPUT aux_nrperger,
                                                   OUTPUT aux_nomcampo,
                                                   OUTPUT TABLE tt-erro).
    
       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.
    
       RUN monta_registros_proposta IN h-b1wgen0002(INPUT TABLE tt-aval-crapbem,
                                                    INPUT TABLE tt-faturam,
                                                    INPUT TABLE tt-crapbem,
                                                    INPUT TABLE tt-bens-alienacao,
                                                    INPUT TABLE tt-hipoteca,
                                                    INPUT TABLE tt-interv-anuentes,
                                                    INPUT TABLE tt-rendimento,
                                                    OUTPUT aux_dsdbeavt,
                                                    OUTPUT aux_dsdfinan,
                                                    OUTPUT aux_dsdrendi,
                                                    OUTPUT aux_dsdebens,
                                                    OUTPUT aux_dsdalien,
                                                    OUTPUT aux_dsinterv).

       RUN grava-proposta-completa IN h-b1wgen0002(INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
												   INPUT par_cdagenci, /*par_cdpactra*/
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT tt-dados-assoc.inpessoa,
                                                   INPUT 0, /* par_nrctremp */
                                                   INPUT 1, /* par_tpemprst */
                                                   INPUT FALSE, /* par_flgcmtlc */
                                                   INPUT aux_vlutiliz,
                                                   INPUT 0, /* par_vllimapv */
                                                   INPUT "I",
                                                   /*---Dados para a crawepr---*/
                                                   INPUT par_vlemprst,
                                                   INPUT 0, /* par_vlpreant */
                                                   INPUT par_vlpreemp,
                                                   INPUT par_qtpreemp,
                                                   INPUT tt-proposta-epr.nivrisco,
                                                   INPUT aux_cdlcremp,
                                                   INPUT crappre.cdfinemp,
                                                   INPUT 0, /* par_qtdialib */
                                                   INPUT FALSE, /* par_flgimppr */
                                                   INPUT FALSE, /* par_flgimpnp */
                                                   INPUT par_percetop,
                                                   INPUT 1, /* par_idquapro */
                                                   INPUT par_dtdpagto,
                                                   INPUT 1, /* par_qtpromis */
                                                   INPUT FALSE, /* par_flgpagto */
                                                   INPUT "", /* par_dsctrliq */
                                                   INPUT 0,  /* par_nrctaava */
                                                   INPUT 0,  /* par_nrctaav2 */
                                                   INPUT 0,  /* par_idcarenc */
                                                   INPUT ?,  /* par_dtcarenc */
                                                   /*-------Rating------ */
                                                   INPUT aux_nrgarope,
                                                   INPUT aux_nrperger,
                                                   INPUT ?, /* par_dtcnsspc */
                                                   INPUT aux_nrinfcad,
                                                   INPUT aux_dtdrisco,
                                                   INPUT aux_vltotsfn,
                                                   INPUT aux_qtopescr,
                                                   INPUT aux_qtifoper,
                                                   INPUT aux_nrliquid,
                                                   INPUT aux_vlopescr,
                                                   INPUT aux_vlrpreju,
                                                   INPUT aux_nrpatlvr,
                                                   INPUT ?, /* par_dtoutspc */
                                                   INPUT aux_dtoutris,
                                                   INPUT aux_vlsfnout,
                                                   /* Dados Salario/Faturamento */
                                                   INPUT aux_vlsalari,
                                                   INPUT aux_vloutras,
                                                   INPUT aux_vlalugue,
                                                   INPUT aux_vlsalcon,
                                                   INPUT aux_nmempcje,
                                                   INPUT aux_flgdocje,
                                                   INPUT aux_nrctacje,
                                                   INPUT aux_nrcpfcje,
                                                   INPUT aux_perfatcl,
                                                   INPUT aux_vlmedfat,
                                                   INPUT FALSE,
                                                   INPUT FALSE,
                                                   /* par_dsobserv */
                                                   INPUT "Credito Pre-Aprovado",
                                                   INPUT aux_dsdfinan,
                                                   INPUT aux_dsdrendi,
                                                   INPUT aux_dsdebens,
                                                   /* Alienacao */
                                                   INPUT aux_dsdalien,
                                                   INPUT aux_dsinterv,
                                                   INPUT tt-dados-coope.lssemseg,
                                                   /* Avalista 1 */
                                                   INPUT "", /* par_nmdaval1 */
                                                   INPUT 0,  /* par_nrcpfav1 */
                                                   INPUT "", /* par_tpdocav1 */
                                                   INPUT "", /* par_dsdocav1 */
                                                   INPUT "", /* par_nmdcjav1 */
                                                   INPUT 0,  /* par_cpfcjav1 */
                                                   INPUT "", /* par_tdccjav1 */
                                                   INPUT "", /* par_doccjav1 */
                                                   INPUT "", /* par_ende1av1 */
                                                   INPUT "", /* par_ende2av1 */
                                                   INPUT "", /* par_nrfonav1 */
                                                   INPUT "", /* par_emailav1 */
                                                   INPUT "", /* par_nmcidav1 */
                                                   INPUT "", /* par_cdufava1 */
                                                   INPUT 0,  /* par_nrcepav1 */
                                                   INPUT 0,  /* par_cdnacio1 */
                                                   INPUT 0,  /* par_vledvmt1 */
                                                   INPUT 0,  /* par_vlrenme1 */
                                                   INPUT 0,  /* par_nrender1 */
                                                   INPUT "", /* par_complen1 */
                                                   INPUT 0,  /* par_nrcxaps1 */
                                                   INPUT 0,
                                                   INPUT ?,
												   INPUT 0, /* par_vlrecjg1 */
                                                   /* Avalista 2 */
                                                   INPUT "", /* aux_nmdaval2 */
                                                   INPUT 0,  /* aux_nrcpfav2 */
                                                   INPUT "", /* aux_tpdocav2 */
                                                   INPUT "", /* aux_dsdocav2 */
                                                   INPUT "", /* aux_nmdcjav2 */
                                                   INPUT 0,  /* aux_cpfcjav2 */
                                                   INPUT "", /* aux_tdccjav2 */
                                                   INPUT "", /* aux_doccjav2 */
                                                   INPUT "", /* aux_ende1av2 */
                                                   INPUT "", /* aux_ende2av2 */
                                                   INPUT "", /* aux_nrfonav2 */
                                                   INPUT "", /* aux_emailav2 */
                                                   INPUT "", /* aux_nmcidav2 */
                                                   INPUT "", /* aux_cdufava2 */
                                                   INPUT 0,  /* aux_nrcepav2 */
                                                   INPUT 0,  /* aux_cdnacio2 */
                                                   INPUT 0,  /* aux_vledvmt2 */
                                                   INPUT 0,  /* aux_vlrenme2 */
                                                   INPUT 0,  /* aux_nrender2 */
                                                   INPUT "", /* aux_complen2 */
                                                   INPUT 0,  /* aux_nrcxaps2 */
                                                   INPUT 0,
                                                   INPUT ?,
												   INPUT 0, /* par_vlrecjg2 */
                                                   INPUT "",
                                                   INPUT aux_flgerlog,
                                                   INPUT aux_dsjusren,
                                                   INPUT par_dtmvtolt,
                                                   INPUT 0, /* idcobope */
                                                   INPUT 0, /* idfiniof */
                                                   INPUT "", /* DSCATBEM */
												   INPUT 1,
												   INPUT "TP", /*par_dsdopcao*/
                                                   INPUT 0,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-msg-confirma,
                                                   OUTPUT aux_recidepr,
                                                   OUTPUT nov_nrctremp,
                                                   OUTPUT aux_flmudfai).

       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.

       RUN grava_dados_conta (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT tt-dados-assoc.inpessoa,
                              INPUT par_dtmvtolt,
                              INPUT nov_nrctremp,
                              INPUT aux_cdlcremp,
                              INPUT par_vlemprst,
                              INPUT par_dtdpagto,
                              INPUT par_cdcoptfn,
                              INPUT par_cdagetfn,
                              INPUT par_nrterfin,
                              INPUT par_qtpreemp,
                              INPUT par_vlpreemp,
                              OUTPUT aux_vltarifa,
                              OUTPUT aux_vltaxiof,
                              OUTPUT aux_vltariof,
                              OUTPUT TABLE tt-erro).

       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.

       RUN grava_efetivacao_proposta IN h-b1wgen0084(INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_cdoperad,
                                                     INPUT "CMAPRV", /*par_nmdatela*/
                                                     INPUT par_idorigem,
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT par_dtmvtolt,
                                                     INPUT aux_flgerlog,
                                                     INPUT nov_nrctremp,
                                                     INPUT 0,  /*par_insitapr*/
                                                     INPUT "", /*par_dsobscmt*/
                                                     INPUT par_dtdpagto,
                                                     INPUT 0, /*par_cdbccxlt*/
                                                     INPUT 0, /*par_nrdolote*/
                                                     INPUT par_dtmvtopr,
                                                     INPUT 0, /*par_inproces*/
                                                     /* calculo de tarifa sera
                                                     realizado na propria rotina
                                                     INPUT aux_vltarifa,
                                                     INPUT aux_vltaxiof,
                                                     INPUT aux_vltariof,*/
                                                     INPUT par_nrcpfope,
                                                     OUTPUT aux_dsmesage,
                                                     OUTPUT TABLE tt-ratings,
                                                     OUTPUT TABLE tt-erro).

       IF RETURN-VALUE <> "OK" THEN
          UNDO GRAVA, LEAVE GRAVA.
          
       IF par_idorigem = 3 OR par_idorigem = 4 THEN
        DO:
          /* P442 - Criar assinaturas para o contrato recem criado (aprovado) */
          /* Criar registros na tabela de assinaturas */
          /* Efetuar a chamada a rotina Oracle */ 
          RUN STORED-PROCEDURE pc_assinatura_contrato_pre
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                    ,INPUT par_cdagenci
                                                    ,INPUT par_nrdconta
                                                    ,INPUT 1                                               
                                                    ,INPUT par_dtmvtolt
                                                    ,INPUT par_idorigem
                                                    ,INPUT nov_nrctremp
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
            
          
          IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
            DO:
              CREATE tt-erro.
              ASSIGN tt-erro.cdcritic = aux_cdcritic
                     tt-erro.dscritic = aux_dscritic.
               UNDO GRAVA, LEAVE GRAVA.
           END.
        END. /* END par_idorigem = 3 TH */
       

       ASSIGN aux_flgtrans = TRUE.

    END. /* END GRAVA: DO TRANSACTION */

    IF NOT TEMP-TABLE tt-erro:HAS-RECORDS AND
       (aux_cdcritic > 0 OR aux_dscritic <> "") THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
       END.

    FIND FIRST tt-erro EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL tt-erro THEN
       DO:
           /* Gera Log */
           RUN proc_gerar_log (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT SUBSTR(tt-erro.dscritic,1,65),
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT FALSE,
                               INPUT par_idseqttl,
                               INPUT par_nmdatela,
                               INPUT par_nrdconta,
                              OUTPUT aux_nrdrowid).
           
           ASSIGN tt-erro.cdcritic = 0
                  tt-erro.dscritic = "Nao foi possivel concluir sua "     +
                                     "solicitacao. Dirija-se a um Posto " +
                                     "de Atendimento".

       END. /* END IF AVAIL tt-erro THEN */

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    IF VALID-HANDLE(h-b1wgen0043) THEN
       DELETE PROCEDURE h-b1wgen0043.

    IF VALID-HANDLE(h-b1wgen0084) THEN
       DELETE PROCEDURE h-b1wgen0084.

    IF NOT aux_flgtrans THEN
       RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE. /* END grava_dados */

PROCEDURE grava_dados_conta PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_vltottar AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltaxiof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltariof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdpesqbb AS CHAR                                    NO-UNDO.
    /* Variaveis para IOF */
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgtaiof AS LOGI                                    NO-UNDO.
    /* Variaveis para tarifa */
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisgar AS INTE                                    NO-UNDO.
    DEF VAR aux_vlrtarif AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhistmp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdfvltmp AS INTE                                    NO-UNDO.
    DEF VAR aux_cdlantar LIKE craplat.cdlantar                      NO-UNDO.
    DEF VAR aux_vltrfesp AS DECI                                    NO-UNDO.
    DEF VAR aux_datatual AS DATE                                    NO-UNDO.
    DEF VAR aux_dscatbem AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_vltrfgar AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpreclc AS DECI                                    NO-UNDO.
    DEF VAR aux_vliofpri AS DECI                                    NO-UNDO.
    DEF VAR aux_vliofadi AS DECI                                    NO-UNDO.
    DEF VAR aux_flgimune AS INTE                                    NO-UNDO.

    DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0159 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    ASSIGN aux_flgtrans = FALSE.

    TRANS_1: DO TRANSACTION ON ERROR  UNDO TRANS_1, LEAVE TRANS_1
                            ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1:

        IF NOT VALID-HANDLE(h-b1wgen0153) THEN
           RUN sistema/generico/procedures/b1wgen0153.p 
               PERSISTENT SET h-b1wgen0153.

        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper AND crawepr.nrdconta = par_nrdconta AND crawepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR.
        IF NOT AVAIL crawepr THEN DO:
          ASSIGN aux_cdcritic = 535
                 aux_dscritic = "".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          UNDO TRANS_1, RETURN "NOK".
        END.

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND craplcr.cdlcremp = par_cdlcremp NO-LOCK NO-ERROR.
        IF NOT AVAIL craplcr THEN DO:
          ASSIGN aux_cdcritic = 363
                 aux_dscritic = "".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          UNDO TRANS_1, RETURN "NOK".
        END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_calcula_tarifa
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper  /* Cooperativa conectada */
                                                ,INPUT par_nrdconta  /* Conta do associado */
                                                ,INPUT par_cdlcremp  /* Codigo da linha de credito do emprestimo. */
                                                ,INPUT par_vlemprst  /* Valor do emprestimo. */
                                                ,INPUT craplcr.cdusolcr  /* Codigo de uso da linha de credito (0-Normal/1-CDC/2-Boletos) */
                                                ,INPUT craplcr.tpctrato  /* Tipo de contrato utilizado por esta linha de credito. */
                                                ,INPUT ""  /* Relaçao de categoria de bens em garantia 
                                                                     Deve iniciar com o primeiro tipo de bem em garantia
                                                                     deve ser separado por |
                                                                     deve terminar com | */
                                                ,INPUT "IOF"         /* Nome do programa chamador */
                                                ,INPUT "N"           /* Envia e-mail S/N, se N interrompe o processo em caso de erro */
                                                ,INPUT crawepr.tpemprst  /* tipo de emprestimo */
                                                ,INPUT crawepr.idfiniof  /* financia iof */
                                                ,OUTPUT 0 /* Valor da tarifa calculada */
                                                ,OUTPUT 0 /* Valor da tarifa especial calculada */
                                                ,OUTPUT 0 /* Valor da tarifa garantia calculada */
                                                ,OUTPUT 0 /* Codigo do historico do lancamento. */
                                                ,OUTPUT 0 /* Codigo da faixa de valor por cooperativa. */
                                                ,OUTPUT 0 /* Codigo do historico de bens em garantia */
                                                ,OUTPUT 0 /* Código da faixa de valor dos bens em garantia */
                                                ,OUTPUT 0 /* Critica encontrada */
                                                ,OUTPUT ""). /* Texto de erro/critica encontrada */

        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_calcula_tarifa
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN  aux_vlrtarif = 0
                aux_vltrfesp = 0
                aux_vltrfgar = 0
                par_vltottar = 0
                aux_vlrtarif = DECI(pc_calcula_tarifa.pr_vlrtarif) WHEN pc_calcula_tarifa.pr_vlrtarif <> ?
                aux_vltrfesp = DECI(pc_calcula_tarifa.pr_vltrfesp) WHEN pc_calcula_tarifa.pr_vltrfesp <> ?
                aux_vltrfgar = DECI(pc_calcula_tarifa.pr_vltrfgar) WHEN pc_calcula_tarifa.pr_vltrfgar <> ?
                aux_cdfvlcop = DECI(pc_calcula_tarifa.pr_cdfvlcop) WHEN pc_calcula_tarifa.pr_cdfvlcop <> ?
                aux_dscritic = pc_calcula_tarifa.pr_dscritic WHEN pc_calcula_tarifa.pr_dscritic <> ?.   
                aux_cdhistor = pc_calcula_tarifa.pr_cdhistor.
                aux_cdhisgar = pc_calcula_tarifa.pr_cdhisgar.
                                  
        IF aux_dscritic <> ""  THEN
           UNDO TRANS_1, LEAVE TRANS_1.


        IF aux_vlrtarif > 0 THEN DO:
               IF par_idorigem = 3 THEN
                  ASSIGN aux_cdpesqbb = "INTERNET".
               ELSE 
                  IF par_idorigem = 4 THEN
                     ASSIGN aux_cdpesqbb = "CASH".

               /* data atual para validacao */
               ASSIGN aux_datatual = TODAY.
               /* filtra a data na tabela de feriados */
               FIND FIRST crapfer WHERE crapfer.cdcooper = par_cdcooper AND crapfer.dtferiad = aux_datatual NO-LOCK NO-ERROR.
               /* Se for sabado ou domingo ou feriado */
               IF ((weekday(aux_datatual) = 1) OR (weekday(aux_datatual) = 7) OR (AVAIL(crapfer))) THEN
                DO:
                   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper  
                                        AND crapass.nrdconta = par_nrdconta  
                                    NO-LOCK NO-ERROR.
    
                   IF AVAIL crapass THEN
                    DO:
    
                       RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                               (INPUT par_cdcooper,
                                                INPUT par_nrdconta, 
                                                INPUT par_dtmvtolt,
                                                INPUT aux_cdhistor, 
                                            INPUT aux_vlrtarif,
                                                INPUT par_cdoperad,
                                                INPUT crapass.cdagenci,
                                                INPUT 100,   /*cdbccxlt*/
                                                INPUT 50003, /*nrdolote*/
                                                INPUT 1,     /*tpdolote*/
                                                INPUT 0,     /* nrdocmto */
                                                INPUT crapass.nrdconta,
                                                INPUT crapass.nrdctitg,
                                                INPUT "",    /*par_cdpesqbb*/
                                                INPUT 0,     /*par_cdbanchq*/   
                                                INPUT 0,     /*par_cdagechq*/   
                                                INPUT 0,     /*par_nrctachq*/   
                                                INPUT FALSE, /*par_flgaviso*/
                                                INPUT 0,     /*par_tpaviso*/
                                                INPUT aux_cdfvlcop,
                                                INPUT 0,
                                                OUTPUT TABLE tt-erro).
                    END.


                END.
               ELSE /* se eh dia util */
                DO:

               RUN lan-tarifa-online 
                   IN h-b1wgen0153 (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdconta,
                                    INPUT 100,  /* par_cdbccxlt */
                                    INPUT 50003,/* par_nrdolote */
                                    INPUT 1,    /* par_tpdolote */
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtolt, /* par_dtmvtlcm */
                                    INPUT par_nrdconta,
                                    INPUT STRING(par_nrdconta,"99999999"),
                                    INPUT aux_cdhistor,
                                    INPUT aux_cdpesqbb,
                                    INPUT 0,     /* par_cdbanchq */
                                    INPUT 0,     /* par_cdagechq */
                                    INPUT 0,     /* par_nrctachq */
                                    INPUT FALSE, /* par_flgaviso */
                                    INPUT 0,     /* par_tpdaviso */
                                      INPUT aux_vlrtarif,
                                    INPUT par_nrctremp,
                                    /* Variaveis TAA */
                                    INPUT par_cdcoptfn,
                                    INPUT par_cdagetfn,
                                    INPUT par_nrterfin,
                                    INPUT 0,  /* par_nrsequni */
                                    INPUT 0,  /* par_nrautdoc */
                                    INPUT "", /* par_dsidenti */
                                    INPUT aux_cdfvlcop,
                                    INPUT 0,  /* par_inproces */
                                    OUTPUT aux_cdlantar,
                                    OUTPUT TABLE tt-erro).
              

                END.

               IF RETURN-VALUE <> "OK"  THEN
                  UNDO TRANS_1, LEAVE TRANS_1.

           END. /* IF par_vltottar > 0 */


        IF aux_vltrfgar > 0 THEN DO:
               IF par_idorigem = 3 THEN
                  ASSIGN aux_cdpesqbb = "INTERNET".
               ELSE 
                  IF par_idorigem = 4 THEN
                     ASSIGN aux_cdpesqbb = "CASH".

               /* data atual para validacao */
               ASSIGN aux_datatual = TODAY.
               /* filtra a data na tabela de feriados */
               FIND FIRST crapfer WHERE crapfer.cdcooper = par_cdcooper AND crapfer.dtferiad = aux_datatual NO-LOCK NO-ERROR.
               /* Se for sabado ou domingo ou feriado */
               IF ((weekday(aux_datatual) = 1) OR (weekday(aux_datatual) = 7) OR (AVAIL(crapfer))) THEN
                DO:
                   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper  
                                        AND crapass.nrdconta = par_nrdconta  
                                    NO-LOCK NO-ERROR.
    
                   IF AVAIL crapass THEN
                    DO:
    
                       RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                               (INPUT par_cdcooper,
                                                INPUT par_nrdconta, 
                                                INPUT par_dtmvtolt,
                                            INPUT aux_cdhisgar, 
                                            INPUT aux_vltrfgar,
                                                INPUT par_cdoperad,
                                                INPUT crapass.cdagenci,
                                                INPUT 100,   /*cdbccxlt*/
                                                INPUT 50003, /*nrdolote*/
                                                INPUT 1,     /*tpdolote*/
                                                INPUT 0,     /* nrdocmto */
                                                INPUT crapass.nrdconta,
                                                INPUT crapass.nrdctitg,
                                                INPUT "",    /*par_cdpesqbb*/
                                                INPUT 0,     /*par_cdbanchq*/   
                                                INPUT 0,     /*par_cdagechq*/   
                                                INPUT 0,     /*par_nrctachq*/   
                                                INPUT FALSE, /*par_flgaviso*/
                                                INPUT 0,     /*par_tpaviso*/
                                                INPUT aux_cdfvlcop,
                                                INPUT 0,
                                                OUTPUT TABLE tt-erro).
                    END.


                END.
               ELSE /* se eh dia util */
                DO:

               RUN lan-tarifa-online 
                   IN h-b1wgen0153 (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdconta,
                                    INPUT 100,  /* par_cdbccxlt */
                                    INPUT 50003,/* par_nrdolote */
                                    INPUT 1,    /* par_tpdolote */
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtolt, /* par_dtmvtlcm */
                                    INPUT par_nrdconta,
                                    INPUT STRING(par_nrdconta,"99999999"),
                                      INPUT aux_cdhisgar,
                                    INPUT aux_cdpesqbb,
                                    INPUT 0,     /* par_cdbanchq */
                                    INPUT 0,     /* par_cdagechq */
                                    INPUT 0,     /* par_nrctachq */
                                    INPUT FALSE, /* par_flgaviso */
                                    INPUT 0,     /* par_tpdaviso */
                                      INPUT aux_vltrfgar,
                                    INPUT par_nrctremp,
                                    /* Variaveis TAA */
                                    INPUT par_cdcoptfn,
                                    INPUT par_cdagetfn,
                                    INPUT par_nrterfin,
                                    INPUT 0,  /* par_nrsequni */
                                    INPUT 0,  /* par_nrautdoc */
                                    INPUT "", /* par_dsidenti */
                                    INPUT aux_cdfvlcop,
                                    INPUT 0,  /* par_inproces */
                                    OUTPUT aux_cdlantar,
                                    OUTPUT TABLE tt-erro).
              

                END.

               IF RETURN-VALUE <> "OK"  THEN
                  UNDO TRANS_1, LEAVE TRANS_1.

           END. /* IF aux_vltrfgar > 0 */
           
           

        IF VALID-HANDLE(h-b1wgen0153)  THEN
           DELETE PROCEDURE h-b1wgen0153.

        DO WHILE TRUE:
    
           FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                              craplot.dtmvtolt = par_dtmvtolt   AND
                              craplot.cdagenci = 1              AND
                              craplot.cdbccxlt = 100            AND
                              craplot.nrdolote = 50001
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
           IF NOT AVAILABLE craplot THEN
              IF LOCKED craplot THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                     CREATE craplot.
                     ASSIGN craplot.dtmvtolt = par_dtmvtolt
                            craplot.cdagenci = 1
                            craplot.cdbccxlt = 100
                            craplot.nrdolote = 50001
                            craplot.tplotmov = 1
                            craplot.cdcooper = par_cdcooper.
                     VALIDATE craplot.
                 END.
    
           LEAVE.
    
        END.  /*  Fim do DO WHILE TRUE  */
              
        CREATE craplcm.
        ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
               craplcm.cdagenci = craplot.cdagenci
               craplcm.cdbccxlt = craplot.cdbccxlt
               craplcm.nrdolote = craplot.nrdolote
               craplcm.nrdconta = par_nrdconta
               craplcm.nrdctabb = par_nrdconta
               craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
               craplcm.nrdocmto = par_nrctremp
               craplcm.cdhistor = 15
               craplcm.nrseqdig = craplot.nrseqdig + 1
               craplcm.cdpesqbb = STRING(par_nrctremp,"99999999")
               craplcm.cdcooper = par_cdcooper
               craplcm.vllanmto = par_vlemprst
			   craplcm.cdcoptfn = par_cdcoptfn
			   craplcm.cdagetfn = par_cdagetfn
			   craplcm.nrterfin = par_nrterfin
			   craplcm.cdorigem = par_idorigem
               craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
               craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1.
        VALIDATE craplcm.
    
        /* Calcula o IOF */
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
        FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND crapjur.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_calcula_iof_epr
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                ,INPUT par_nrdconta
                                                ,INPUT par_nrctremp
                                                ,INPUT par_dtmvtolt
                                                ,INPUT crapass.inpessoa                                                
                                                ,INPUT par_cdlcremp
                                                ,INPUT crawepr.cdfinemp
                                                ,INPUT crawepr.qtpreemp
                                                ,INPUT crawepr.vlpreemp
                                                ,INPUT par_vlemprst
                                                ,INPUT crawepr.dtdpagto
                                                ,INPUT crawepr.dtmvtolt
                                                ,INPUT crawepr.tpemprst
                                                ,INPUT ?
                                                ,INPUT 0
                                                ,INPUT ""
                                                ,INPUT crawepr.idfiniof
                                                ,INPUT ""
                                                ,INPUT "S" /* Gravar valor IOF parcelas no cadastro de Parcelas */
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT 0
                                                ,OUTPUT "").
       
           
         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_calcula_iof_epr
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

         ASSIGN aux_vlpreclc = 0
                aux_vliofpri = 0
                aux_vliofadi = 0
                aux_flgimune = 0
                par_vltottar = 0
                par_vltariof = 0
                aux_vlpreclc = DECI(pc_calcula_iof_epr.pr_vlpreclc) WHEN pc_calcula_iof_epr.pr_vlpreclc <> ?
                par_vltariof = DECI(pc_calcula_iof_epr.pr_valoriof) WHEN pc_calcula_iof_epr.pr_valoriof <> ?
                aux_vliofpri = DECI(pc_calcula_iof_epr.pr_vliofpri) WHEN pc_calcula_iof_epr.pr_vliofpri <> ?
                aux_vliofadi = DECI(pc_calcula_iof_epr.pr_vliofadi) WHEN pc_calcula_iof_epr.pr_vliofadi <> ?
                aux_dscritic = pc_calcula_iof_epr.pr_dscritic WHEN pc_calcula_iof_epr.pr_dscritic <> ?
                aux_flgimune = pc_calcula_iof_epr.pr_flgimune WHEN pc_calcula_iof_epr.pr_flgimune <> ?.   

         IF aux_dscritic <> ""  THEN
           UNDO TRANS_1, LEAVE TRANS_1.

        /* Caso for imune, nao podemos cobrar IOF */
        IF (par_vltariof) > 0 AND aux_flgimune = 0 THEN
           DO:
           
               DO WHILE TRUE:
        
                  FIND craplot 
                       WHERE craplot.cdcooper = par_cdcooper AND
                             craplot.dtmvtolt = par_dtmvtolt AND
                             craplot.cdagenci = 1            AND
                             craplot.cdbccxlt = 100          AND
                             craplot.nrdolote = 50002
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
                  IF NOT AVAILABLE craplot THEN
                     IF LOCKED craplot THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                   craplot.cdagenci = 1
                                   craplot.cdbccxlt = 100
                                   craplot.nrdolote = 50002
                                   craplot.tplotmov = 1
                                   craplot.cdcooper = par_cdcooper.
                            VALIDATE craplot.
                        END.
          
                  LEAVE.
        
               END.  /*  Fim do DO WHILE TRUE  */
        
               /* Condicao para verificar se eh Financiamento */
               IF craplcr.dsoperac = 'FINANCIAMENTO' THEN
                  ASSIGN aux_cdhistor = 2309.
               ELSE
                  ASSIGN aux_cdhistor = 2308.
        
        
               CREATE craplcm.
               ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                      craplcm.cdagenci = craplot.cdagenci
                      craplcm.cdbccxlt = craplot.cdbccxlt
                      craplcm.nrdolote = craplot.nrdolote
                      craplcm.nrdconta = par_nrdconta
                      craplcm.nrdctabb = par_nrdconta
                      craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
                      craplcm.nrdocmto = par_nrctremp
                      craplcm.cdhistor = aux_cdhistor
                      craplcm.nrseqdig = craplot.nrseqdig + 1
                      craplcm.cdpesqbb = 
                                 STRING(par_vlemprst,"zzz,zzz,zz9.99") + 
                                 STRING(par_vlemprst,"zzz,zzz,zz9.99") +
                                 STRING(0,"zzz,zzz,zz9.99")
                      craplcm.vllanmto = par_vltariof
                      craplcm.cdcooper = par_cdcooper
					  craplcm.cdcoptfn = par_cdcoptfn
			          craplcm.cdagetfn = par_cdagetfn
			          craplcm.nrterfin = par_nrterfin
					  craplcm.cdorigem = par_idorigem
                      craplot.vlinfodb = 
                                 craplot.vlinfodb + craplcm.vllanmto
                      craplot.vlcompdb = 
                                 craplot.vlcompdb + craplcm.vllanmto
                      craplot.qtinfoln = craplot.qtinfoln + 1
                      craplot.qtcompln = craplot.qtcompln + 1
                      craplot.nrseqdig = craplot.nrseqdig + 1.
               VALIDATE craplcm.
        
               /* Projeto 410 - Gera lancamento de IOF complementar na TBGEN_IOF_LANCAMENTO - Jean (Mout´S) */
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
               RUN STORED-PROCEDURE pc_insere_iof
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da cooperativa referente ao contrato de empréstimos */
                                                   ,INPUT par_nrdconta     /* Número da conta referente ao empréstimo */
                                                   ,INPUT craplot.dtmvtolt /* data de movimento */
                                                   ,INPUT 1                /* tipo de produto - 1 - Emprestimo */
                                                   ,INPUT par_nrctremp     /* Número do contrato de empréstimo */
                                                   ,INPUT ?                /* lancamento automatico */
                                                   ,INPUT craplot.dtmvtolt /* data de movimento LCM*/
                                                   ,INPUT craplot.cdagenci /* codigo da agencia  */
                                                   ,INPUT craplot.cdbccxlt /* Codigo caixa*/
                                                   ,INPUT craplot.nrdolote /* numero do lote */
                                                   ,INPUT craplot.nrseqdig  /* sequencia do lote */
                                                   ,INPUT aux_vliofpri     /* iof principal */
                                                   ,INPUT aux_vliofadi     /* iof adicional */
                                                   ,INPUT 0                /* iof complementar */
                                                   ,INPUT aux_flgimune     /* flag IMUNE*/
                                                   ,OUTPUT 0               /* codigo da critica */
                                                   ,OUTPUT "").            /* Critica */
         
               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_insere_iof

               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

               /* Se retornou erro */
               ASSIGN aux_dscritic = ""
                      aux_dscritic = pc_insere_iof.pr_dscritic WHEN pc_insere_iof.pr_dscritic <> ?.
                
               IF aux_dscritic <> "" THEN
                  RETURN "NOK".
               
               /* Atualiza IOF pago e base de calculo no crapcot */
               DO WHILE TRUE:
        
                  FIND crapcot 
                       WHERE crapcot.cdcooper = par_cdcooper AND
                             crapcot.nrdconta = par_nrdconta
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
                  IF NOT AVAILABLE crapcot THEN
                     IF LOCKED crapcot THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        DO:
                            ASSIGN aux_cdcritic = 169
                                   aux_dscritic = "".
        
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            UNDO TRANS_1, RETURN "NOK".
        
                        END.
               
                  LEAVE.
               
               END.  /*  Fim do DO WHILE TRUE  */
        
               ASSIGN crapcot.vliofepr = 
                              crapcot.vliofepr + craplcm.vllanmto
                      crapcot.vlbsiepr = 
                              crapcot.vlbsiepr + par_vlemprst.

           END.
           
           ELSE DO:
           
              /* Projeto 410 - Gera lancamento de IOF complementar na TBGEN_IOF_LANCAMENTO - Jean (Mout´S) */
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
             RUN STORED-PROCEDURE pc_insere_iof
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da cooperativa referente ao contrato de empréstimos */
                                                 ,INPUT par_nrdconta     /* Número da conta referente ao empréstimo */
                                                 ,INPUT par_dtmvtolt     /* data de movimento */
                                                 ,INPUT 1                /* tipo de produto - 1 - Emprestimo */
                                                 ,INPUT par_nrctremp     /* Número do contrato de empréstimo */
                                                 ,INPUT ?                /* lancamento automatico */
                                                 ,INPUT ?  /* data de movimento LCM*/
                                                 ,INPUT 0  /* codigo da agencia  */
                                                 ,INPUT 0  /* Codigo caixa*/
                                                 ,INPUT 0  /* numero do lote */
                                                 ,INPUT 0  /* sequencia do lote */
                                                 ,INPUT aux_vliofpri     /* iof principal */
                                                 ,INPUT aux_vliofadi     /* iof adicional */
                                                 ,INPUT 0                /* iof complementar */
                                                 ,INPUT aux_flgimune     /* flag IMUNE*/
                                                 ,OUTPUT 0               /* codigo da critica */
                                                 ,OUTPUT "").            /* Critica */
       
             /* Fechar o procedimento para buscarmos o resultado */ 
             CLOSE STORED-PROC pc_insere_iof

             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

             /* Se retornou erro */
             ASSIGN aux_cdcritic = 0
                    aux_cdcritic = INTE(pc_insere_iof.pr_cdcritic) WHEN pc_insere_iof.pr_cdcritic <> ?
                    aux_dscritic = ""
                    aux_dscritic = pc_insere_iof.pr_dscritic WHEN pc_insere_iof.pr_dscritic <> ?.
              
             IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                DO:
                
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                  UNDO TRANS_1, RETURN "NOK".
                END.
           
           
           END. /* END IF aux_vltxaiof > 0 THEN */

        ASSIGN aux_flgtrans = TRUE.

    END. /* END TRANS_1 */

    IF NOT aux_flgtrans THEN
       RETURN "NOK".

    RETURN "OK".

END PROCEDURE. /* END grava_dados_lancamento_conta */

PROCEDURE calcula_iof:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_vltaxiof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltariof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0159 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_flgimune AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgtaiof AS LOGI                                    NO-UNDO.
    DEF VAR aux_qtdiaiof AS INTE                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTEGER INIT 0                          NO-UNDO.
	  DEF VAR aux_tpemprst AS INTEGER                                 NO-UNDO.
    DEF VAR aux_dscatbem AS CHAR                                    NO-UNDO.
    
    ASSIGN par_vltaxiof = 0.
    
    FOR craplcr FIELDS(flgtaiof) WHERE craplcr.cdcooper = par_cdcooper AND
                                       craplcr.cdlcremp = par_cdlcremp
                                       NO-LOCK: END.
    
    IF NOT AVAIL craplcr THEN
       ASSIGN aux_flgtaiof = YES.
    ELSE
       ASSIGN aux_flgtaiof = craplcr.flgtaiof.
    
    IF aux_flgtaiof AND par_vlemprst > 0 THEN
       DO:
           ASSIGN par_vltariof = 0.
           
           FOR FIRST crapass FIELDS(inpessoa)
                             WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK: END.
           
           IF AVAILABLE crapass THEN
              ASSIGN aux_inpessoa = crapass.inpessoa.
       
		   FIND FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper AND
		                            crawepr.nrdconta = par_nrdconta AND
									crawepr.nrctremp = par_nrctremp 
									NO-LOCK NO-ERROR.
		   
       ASSIGN aux_tpemprst = 1. /* PP */
		   IF AVAILABLE crawepr THEN
			  ASSIGN aux_tpemprst = crawepr.tpemprst.
			  
          /* Busca os bens em garantia */
          ASSIGN aux_dscatbem = "".
          FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper  AND
                                 crapbpr.nrdconta = crawepr.nrdconta  AND
                                 crapbpr.tpctrpro = 90                AND
                                 crapbpr.nrctrpro = crawepr.nrctremp NO-LOCK:
              ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
          END.
			  
       
           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

           /* Efetuar a chamada a rotina Oracle */ 
           RUN STORED-PROCEDURE pc_calcula_iof_epr
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrctremp,
                                                 INPUT par_dtmvtolt,
                                                 INPUT aux_inpessoa,
                                                 INPUT par_cdlcremp,
                                                 INPUT par_cdfinemp,                                                 
                                                 INPUT par_nrparepr,
                                                 INPUT par_vlpreemp,
                                                 INPUT par_vlemprst,
                                                 INPUT par_dtvencto,
                                                 INPUT par_dtmvtolt,
                                                 INPUT aux_tpemprst, /* pr_tpemprst */
                                                 INPUT par_dtmvtolt, /* pr_dtcarenc */
                                                 INPUT 0, /* pr_qtdias_carencia */
                                                 INPUT aux_dscatbem,      /* Bens em garantia */
                                                 INPUT (IF AVAILABLE crawepr THEN crawepr.idfiniof ELSE 0),  /* Indicador de financiamento de IOF e tarifa */
                                                 INPUT "0", /* passar assim para nao gerar erro no Oracle */
                                                 INPUT "N",
                                                OUTPUT 0, 
                                                OUTPUT 0,
                                                OUTPUT 0,
                                                OUTPUT 0,
                                                OUTPUT 0,
                                                OUTPUT "").
           
           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_calcula_iof_epr
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

           ASSIGN par_vltariof = pc_calcula_iof_epr.pr_valoriof
                                    WHEN pc_calcula_iof_epr.pr_valoriof <> ?           
                  aux_dscritic = pc_calcula_iof_epr.pr_dscritic
                                    WHEN pc_calcula_iof_epr.pr_dscritic <> ?.
                             
           IF TRIM(aux_dscritic) <> "" THEN
             DO:
                RETURN "NOK".
             END.
                                                    
           IF par_vltariof > 0 THEN
            DO:
           IF NOT VALID-HANDLE(h-b1wgen0159) THEN
              RUN sistema/generico/procedures/b1wgen0159.p 
                  PERSISTENT SET h-b1wgen0159.
        
           RUN verifica-imunidade-tributaria 
               IN h-b1wgen0159(INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_dtmvtolt,
                               INPUT TRUE, /* par_flgrvvlr */
                               INPUT 1,    /* par_cdinsenc */
                               INPUT par_vltariof,
                               OUTPUT aux_flgimune,
                               OUTPUT TABLE tt-erro).
        
           IF VALID-HANDLE(h-b1wgen0159) THEN
              DELETE PROCEDURE h-b1wgen0159.

               IF RETURN-VALUE <> "OK" THEN DO:
              RETURN "NOK".
               END.

           /* Caso for imune, nao podemos cobrar IOF */
           IF aux_flgimune THEN
              ASSIGN par_vltariof = 0.
          END.
              
       END. /* IF aux_flgtaiof AND par_vlemprst > 0 THEN */

END PROCEDURE. /* END calcula_iof */


PROCEDURE calcula_parcelas_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_diapagto AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-parcelas-cpa.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtdpagto LIKE crapepr.dtdpagto                      NO-UNDO.
    DEF VAR aux_qtpreemp LIKE crapepr.qtpreemp INITIAL 0            NO-UNDO.
    DEF VAR aux_qtdiacar AS INTE                                    NO-UNDO.
    DEF VAR aux_vlajuepr AS DECI                                    NO-UNDO.
    DEF VAR aux_txdiaria AS DECI                                    NO-UNDO.
    DEF VAR aux_txmensal AS DECI                                    NO-UNDO.
    DEF VAR aux_idcarga  AS INTE                                    NO-UNDO.
	DEF VAR aux_cdlcremp AS INTE                                    NO-UNDO.
    DEF VAR aux_vlcalpar AS DECI                                    NO-UNDO.
	
    DEF VAR h-b1wgen0084 AS HANDLE                                  NO-UNDO.
    
    IF NOT VALID-HANDLE(h-b1wgen0084) THEN
       RUN sistema/generico/procedures/b1wgen0084.p 
           PERSISTENT SET h-b1wgen0084.

    /* Buscar carga ativa */
    RUN busca_dados (INPUT par_cdcooper,
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
            ASSIGN aux_idcarga  = tt-dados-cpa.idcarga
                   aux_cdlcremp = tt-dados-cpa.cdlcremp
                   aux_vlcalpar = tt-dados-cpa.vlcalpar.
        END.
		
    /*  Caso nao possua carga ativa */
    IF  aux_idcarga = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Associado nao vinculado a nenhuma carga ativa.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    /* Buscar dados do associado e informações do pre aprovado */
    FOR crapass FIELDS (inpessoa)
                WHERE crapass.cdcooper = par_cdcooper 
                  AND crapass.nrdconta = par_nrdconta 
                      NO-LOCK: END.
    
    FOR crappre FIELDS(cdfinemp) 
                WHERE crappre.cdcooper = par_cdcooper 
                  AND crappre.inpessoa = crapass.inpessoa
                      NO-LOCK: END.

    IF NOT AVAIL crappre THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Parametros pre-aprovado nao cadastrado".
        
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.

    /* Buscar linha de credito */
    FOR craplcr FIELDS(cdlcremp nrinipre nrfimpre)
                WHERE craplcr.cdcooper = par_cdcooper     AND
                      craplcr.cdlcremp = aux_cdlcremp
                      NO-LOCK: END.

    IF NOT AVAIL craplcr THEN
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

    /* Calculo da data de pagamento */
    ASSIGN aux_dtdpagto = DATE(MONTH(par_dtmvtolt),par_diapagto,YEAR(par_dtmvtolt)).
           aux_dtdpagto = ADD-INTERVAL(aux_dtdpagto,1,"MONTH").

    DO aux_qtpreemp = 1 TO craplcr.nrfimpre:

       EMPTY TEMP-TABLE tt-erro.
       EMPTY TEMP-TABLE tt-parcelas-epr.

       RUN calcula_emprestimo IN h-b1wgen0084(INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT FALSE, /* par_flgerlog */
                                              INPUT 0,     /* par_nrctremp */
                                              INPUT aux_cdlcremp,
                                              INPUT crappre.cdfinemp,
                                              INPUT par_vlemprst,
                                              INPUT aux_qtpreemp,
                                              INPUT par_dtmvtolt,
                                              INPUT aux_dtdpagto,
                                              INPUT FALSE, /*par_flggrava*/
                                              INPUT par_dtmvtolt,
                                              INPUT 0, /* Indicador de IOF - Deve-se rever */
                                              OUTPUT aux_qtdiacar,
                                              OUTPUT aux_vlajuepr,
                                              OUTPUT aux_txdiaria,
                                              OUTPUT aux_txmensal,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-parcelas-epr).

       IF RETURN-VALUE <> "OK" THEN
          RETURN "NOK".

       FIND FIRST tt-parcelas-epr NO-LOCK NO-ERROR.
       IF AVAIL tt-parcelas-epr THEN
          DO:
              CREATE tt-parcelas-cpa.
              BUFFER-COPY tt-parcelas-epr TO tt-parcelas-cpa.
              ASSIGN tt-parcelas-cpa.nrparepr = aux_qtpreemp
                     tt-parcelas-cpa.dtvencto = tt-parcelas-epr.dtparepr.

              /* Valor calculado da parcela nao pode ser maior que o valor 
                 maximo configurado */
              IF tt-parcelas-cpa.vlparepr > aux_vlcalpar THEN
              DO:
                 ASSIGN tt-parcelas-cpa.flgdispo = FALSE.

                /* se for origem 4 TAA, remove a parcela */
                IF par_idorigem = 4  THEN
                DO:
                    DELETE tt-parcelas-cpa.
                END.

              END.

              VALIDATE tt-parcelas-cpa.
          END.
    END.

    IF VALID-HANDLE(h-b1wgen0084) THEN
       DELETE PROCEDURE h-b1wgen0084.

    RETURN "OK".

END PROCEDURE. /* END calcula_parcelas_emprestimo */

PROCEDURE calcula_taxa_emprestimo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlparepr AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrparepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_vlrtarif AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_percetop AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltaxiof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltariof AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlliquid AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_txcetmes AS DECI                                    NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR aux_vlrtarif AS DECI                                    NO-UNDO.
    DEF VAR aux_vltrfesp AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_idcarga  AS inte                                    NO-UNDO.
	DEF VAR aux_cdlcremp AS INTE                                    NO-UNDO.
	
    DEF VAR h-b1wgen0084 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.

    
    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.

    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
       RUN sistema/generico/procedures/b1wgen0153.p 
           PERSISTENT SET h-b1wgen0153.

    /* Verifica se existe limite disponível */
    RUN busca_dados (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT 1,
                     INPUT 0,
                     OUTPUT TABLE tt-dados-cpa,
                     OUTPUT TABLE tt-erro).

    FIND tt-dados-cpa NO-LOCK NO-ERROR.
    IF  AVAIL tt-dados-cpa THEN
        DO:
            ASSIGN aux_idcarga  = tt-dados-cpa.idcarga
                   aux_cdlcremp = tt-dados-cpa.cdlcremp.
        END.
		
    /*  Caso nao possua carga ativa */
    IF  aux_idcarga = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Associado nao vinculado a nenhuma carga ativa.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            IF VALID-HANDLE(h-b1wgen0002) THEN
               DELETE PROCEDURE h-b1wgen0002.

            IF VALID-HANDLE(h-b1wgen0153) THEN
               DELETE PROCEDURE h-b1wgen0153.
                           
            RETURN "NOK".
        END.

    FOR crapass FIELDS(inpessoa) WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta
                                       NO-LOCK: END.

    /* Busca a tarifa do emprestimo */
    RUN carrega_dados_tarifa_emprestimo IN h-b1wgen0153
                                     (INPUT  par_cdcooper,
                                      INPUT  aux_cdlcremp,
                                      INPUT  "EM",
                                      INPUT  crapass.inpessoa,
                                      INPUT  par_vlemprst,
                                      INPUT  par_nmdatela,
                                      OUTPUT aux_cdhistor,
                                      OUTPUT aux_cdhisest,
                                      OUTPUT aux_vlrtarif,
                                      OUTPUT aux_dtdivulg,
                                      OUTPUT aux_dtvigenc,
                                      OUTPUT aux_cdfvlcop,
                                      OUTPUT TABLE tt-erro).

    
    IF RETURN-VALUE <> "OK"  THEN
       DO:
     
         IF VALID-HANDLE(h-b1wgen0002) THEN
            DELETE PROCEDURE h-b1wgen0002.

         IF VALID-HANDLE(h-b1wgen0153) THEN
            DELETE PROCEDURE h-b1wgen0153.
        
       RETURN "NOK".
    
       END.
    
    /* Busca a tarifa especial */
    RUN carrega_dados_tarifa_emprestimo IN h-b1wgen0153
                                     (INPUT  par_cdcooper,
                                      INPUT  aux_cdlcremp,
                                      INPUT  "ES",
                                      INPUT  crapass.inpessoa,
                                      INPUT  par_vlemprst,
                                      INPUT  par_nmdatela,
                                      OUTPUT aux_cdhistor,
                                      OUTPUT aux_cdhisest,
                                      OUTPUT aux_vltrfesp,
                                      OUTPUT aux_dtdivulg,
                                      OUTPUT aux_dtvigenc,
                                      OUTPUT aux_cdfvlcop,
                                      OUTPUT TABLE tt-erro).
                                      
    IF RETURN-VALUE <> "OK"  THEN
       DO:
     
         IF VALID-HANDLE(h-b1wgen0002) THEN
            DELETE PROCEDURE h-b1wgen0002.

         IF VALID-HANDLE(h-b1wgen0153) THEN
            DELETE PROCEDURE h-b1wgen0153.
        
       RETURN "NOK".
    
       END.
    
    /* Valor da tarifa */
    ASSIGN par_vlrtarif = aux_vlrtarif + aux_vltrfesp.
	
	/* Calcula o IOF */
    RUN calcula_iof (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,									 
                     INPUT par_nrdconta,
                     INPUT 0, /* par_nrctremp */
                     INPUT 0, /* cdfinemp */
                     INPUT aux_cdlcremp,									 
                     INPUT par_vlemprst,
                     INPUT par_dtmvtolt,
                     INPUT par_nrparepr,
                     INPUT par_dtvencto,
                     INPUT par_vlparepr,
                     OUTPUT par_vltaxiof,
                     OUTPUT par_vltariof,									  
                     OUTPUT TABLE tt-erro).
                     
    IF RETURN-VALUE <> "OK"  THEN
       DO:
     
         IF VALID-HANDLE(h-b1wgen0002) THEN
            DELETE PROCEDURE h-b1wgen0002.

         IF VALID-HANDLE(h-b1wgen0153) THEN
            DELETE PROCEDURE h-b1wgen0153.
        
         RETURN "NOK".
       
       END.

    ASSIGN par_vlliquid = par_vlemprst - ROUND(par_vlrtarif,2) - ROUND(par_vltariof,2).

    /* Calcula o custo efetivo total */
    RUN calcula_cet_novo IN h-b1wgen0002 (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_dtmvtolt,
                                          INPUT par_nrdconta,
                                          INPUT crapass.inpessoa,
                                          INPUT 2, /* cdusolcr */
                                          INPUT aux_cdlcremp,
                                          INPUT 1, /* tpemprst */
                                          INPUT 0, /* nrctremp */
                                          INPUT par_dtmvtolt,
                                          INPUT par_vlliquid,
                                          INPUT par_vlparepr,
                                          INPUT par_nrparepr,
                                          INPUT par_dtvencto,
                                          INPUT 0, /* cdfinemp */
                                          INPUT "", /* dscatbem */
                                          INPUT 1, /* idfiniof */
                                          INPUT "", /* dsctrliq */
                                          INPUT "N",
                                          INPUT ?, /*par_dtcarenc*/
                                          OUTPUT par_percetop,
                                          OUTPUT aux_txcetmes,
                                          OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK"  THEN
       DO:
     
         IF VALID-HANDLE(h-b1wgen0002) THEN
            DELETE PROCEDURE h-b1wgen0002.

         IF VALID-HANDLE(h-b1wgen0153) THEN
            DELETE PROCEDURE h-b1wgen0153.
        
       RETURN "NOK".

       END.

    ASSIGN par_vlliquid = par_vlemprst - par_vlrtarif - par_vltariof.
    
    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    IF VALID-HANDLE(h-b1wgen0153) THEN
       DELETE PROCEDURE h-b1wgen0153.
    
    RETURN "OK".

END. /* END calcula_taxa_emprestimo */

PROCEDURE imprime_demonstrativo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
	DEF VAR aux_nmdireto AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_reto AS CHAR                                    NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

																	

    FOR crawepr FIELDS(vlemprst txmensal qtpreemp vlpreemp percetop dtdpagto dtpreapv hrpreapv)
                WHERE crawepr.cdcooper = par_cdcooper AND
                      crawepr.nrdconta = par_nrdconta AND
                      crawepr.nrctremp = par_nrctremp
                      NO-LOCK: END.
                       
    IF NOT AVAIL crawepr THEN
       DO:
           ASSIGN aux_cdcritic = 356.
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.

    FOR crapepr FIELDS(dtmvtolt vltarifa vltaxiof vltariof)
                WHERE crapepr.cdcooper = par_cdcooper AND
                      crapepr.nrdconta = par_nrdconta AND
                      crapepr.nrctremp = par_nrctremp
                      NO-LOCK: END.

    IF NOT AVAIL crapepr THEN
       DO:
           ASSIGN aux_cdcritic = 356.
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".
       END.

																	 
	
    RUN imprime_previa_demonstrativo (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT crapepr.dtmvtolt,
                                      INPUT par_nrctremp,
                                      INPUT crawepr.vlemprst,
                                      INPUT crawepr.txmensal,
                                      INPUT crawepr.qtpreemp,
                                      INPUT crawepr.vlpreemp,
                                      INPUT crawepr.percetop,
                                      INPUT crapepr.vltarifa,
                                      INPUT crawepr.dtdpagto,
                                      INPUT crapepr.vltaxiof,
                                      INPUT crapepr.vltariof,
                                      INPUT crawepr.dtpreapv,
                                      INPUT crawepr.hrpreapv,
                                      OUTPUT par_nmarqimp,
                                      OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE imprime_previa_demonstrativo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_txmensal AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtpreemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_percetop AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrtarif AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vltaxiof AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vltariof AS DECI                           NO-UNDO.
	DEF  INPUT PARAM par_dtpreapv AS DATE                           NO-UNDO. 
    DEF  INPUT PARAM par_hrpreapv AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(18)"                     NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpessoa LIKE crapass.inpessoa                      NO-UNDO.
    DEF VAR aux_idcarga  AS INTE                                    NO-UNDO.
    DEF VAR aux_cdlcremp AS INTE                                    NO-UNDO.
    DEF VAR aux_percmult AS DECI                                    NO-UNDO.
    DEF VAR aux_dsestcvl LIKE gnetcvl.dsestcvl                      NO-UNDO.
    DEF VAR aux_dsendere LIKE tt-endereco-cooperado.dsendere        NO-UNDO.
    DEF VAR aux_nrendere LIKE tt-endereco-cooperado.nrendere        NO-UNDO.
    DEF VAR aux_nmbairro LIKE tt-endereco-cooperado.nmbairro        NO-UNDO.
    DEF VAR aux_nmcidade LIKE tt-endereco-cooperado.nmcidade        NO-UNDO.
    DEF VAR aux_cdufende LIKE tt-endereco-cooperado.cdufende        NO-UNDO.
    DEF VAR aux_nrcepend LIKE tt-endereco-cooperado.nrcepend        NO-UNDO.
    DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsvlempr1 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsvlempr2 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsvlpres1 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsvlpres2 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsvlriof1 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsvlriof2 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsvlrtar1 AS CHAR                                   NO-UNDO.
    DEF VAR aux_dsvlrtar2 AS CHAR                                   NO-UNDO.
	DEF VAR aux_dsassdig  AS CHAR                                   NO-UNDO.
	DEF VAR aux_des_reto  AS CHAR                                   NO-UNDO.		
    DEF VAR h-b1wgen0060  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0038  AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen9999  AS HANDLE                                 NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_returnvl = "NOK".

    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

    FOR crapcop FIELDS(dsdircop dsendweb) 
                WHERE crapcop.cdcooper = par_cdcooper 
                      NO-LOCK: END.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/".
           aux_nmarquiv = aux_nmarquiv + "CPA_" + STRING(par_cdcooper) + "_" + 
                          STRING(par_nrdconta).

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           par_nmarqimp = aux_nmarquiv + ".ex".

    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp).

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        FOR crapass FIELDS(nmprimtl nrdconta inpessoa nrcpfcgc nrdocptl) 
                    WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK: END.
    
        IF NOT AVAIL crapass THEN
           DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Imprime.

           END. /* END IF NOT AVAIL crapass */

        
        IF par_nrctremp = 0 THEN
          DO:
        /* Verifica se existe limite disponível */
            RUN busca_dados (INPUT par_cdcooper,
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
                    ASSIGN aux_idcarga  = tt-dados-cpa.idcarga
                           aux_cdlcremp = tt-dados-cpa.cdlcremp.
                END.
            
            /*  Caso nao possua carga ativa */
        IF  aux_idcarga = 0 THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Nenhuma carga ativa para o Associado.".
    
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
               RETURN "NOK".
               END.

          END. /*IF par_nrctremp = 0 THEN*/
        ELSE 
          DO:
            FOR crapepr FIELDS(cdlcremp)
                        WHERE crapepr.cdcooper = par_cdcooper AND
                              crapepr.nrdconta = par_nrdconta AND
                              crapepr.nrctremp = par_nrctremp
                              NO-LOCK: END.
        
            IF NOT AVAIL crapepr THEN
               DO:
                   ASSIGN aux_dscritic = "Emprestimo nao cadastrado".
                   LEAVE Imprime.
               END.
            ASSIGN aux_cdlcremp = crapepr.cdlcremp.
           END.

        FOR craplcr FIELDS(txmensal perjurmo flgcobmu)
                    WHERE craplcr.cdcooper = par_cdcooper     AND
                          craplcr.cdlcremp = aux_cdlcremp
                          NO-LOCK: END.
    
        IF NOT AVAIL craplcr THEN
           DO:
               ASSIGN aux_cdcritic = 363.
               LEAVE Imprime.
           END.

        /* Verifica se a Linha de Credito Cobra Multa */
        IF craplcr.flgcobmu THEN
           DO:
               /* Obter o % de multa da CECRED - TAB090 */
               FIND craptab WHERE craptab.cdcooper = 3           AND
                                  craptab.nmsistem = "CRED"      AND
                                  craptab.tptabela = "USUARI"    AND
                                  craptab.cdempres = 11          AND
                                  craptab.cdacesso = "PAREMPCTL" AND
                                  craptab.tpregist = 01
                                  NO-LOCK NO-ERROR.
            
               IF NOT AVAIL craptab THEN
                  DO:
                      ASSIGN aux_cdcritic = 55.
                      LEAVE Imprime.
                  END.
            
               ASSIGN aux_percmult = DEC(SUBSTRING(craptab.dstextab,1,6)).
           END.
        ELSE
           ASSIGN aux_percmult = 0.

        IF crapass.inpessoa = 1 THEN
           DO:
               ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                      aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").

               FOR crapttl FIELDS(cdestcvl)
                           WHERE crapttl.cdcooper = par_cdcooper AND
                                 crapttl.nrdconta = par_nrdconta AND
                                 crapttl.idseqttl = par_idseqttl
                                 NO-LOCK: END.

               IF AVAIL crapttl THEN
                  DO:
                      IF NOT VALID-HANDLE(h-b1wgen0060)  THEN
                         RUN sistema/generico/procedures/b1wgen0060.p 
                             PERSISTENT SET h-b1wgen0060.

                      /* Busca o estado Civil */
                      DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060, 
                                       INPUT crapttl.cdestcvl, "dsestcvl",
                                       OUTPUT aux_dsestcvl,
                                       OUTPUT aux_dscritic).

                      IF VALID-HANDLE(h-b1wgen0060) THEN
                         DELETE PROCEDURE h-b1wgen0060.

                  END. /* END IF IF AVAIL crapttl THEN */

           END. /* END IF crapass.inpessoa = 1 THEN */
        ELSE
           DO:
               ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                      aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
           END.

        IF NOT VALID-HANDLE(h-b1wgen0038)  THEN
           RUN sistema/generico/procedures/b1wgen0038.p 
               PERSISTENT SET h-b1wgen0038.

        /* Busca endereco Pessoa Fisica/Juridica */
        RUN obtem-endereco IN h-b1wgen0038 (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT FALSE,
                                            OUTPUT aux_msgconta,
                                            OUTPUT aux_inpessoa,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-endereco-cooperado).
                         
        IF VALID-HANDLE(h-b1wgen0038)  THEN
           DELETE OBJECT h-b1wgen0038.

        IF RETURN-VALUE = "NOK" THEN
           LEAVE Imprime.

        FIND FIRST tt-endereco-cooperado NO-LOCK NO-ERROR.
        IF AVAIL tt-endereco-cooperado THEN
           DO:
               ASSIGN aux_dsendere = tt-endereco-cooperado.dsendere
                      aux_nrendere = tt-endereco-cooperado.nrendere
                      aux_nmbairro = tt-endereco-cooperado.nmbairro
                      aux_nmcidade = tt-endereco-cooperado.nmcidade
                      aux_cdufende = tt-endereco-cooperado.cdufende
                      aux_nrcepend = tt-endereco-cooperado.nrcepend.

           END. /* END IF AVAIL tt-endereco-cooperado */

        ASSIGN aux_nrdconta = TRIM(STRING(crapass.nrdconta,"zzzz,zz9,9")).

        IF par_nrctremp = 0 THEN
           DO:
               PUT STREAM str_1
                   "DEMONSTRATIVO DE CONTRATACAO DO PRODUTO PRE-APROVADO" AT 20
                   SKIP(2).

           END. /* END IF par_nrctremp = 0 THEN */
        ELSE
           DO:
               PUT STREAM str_1
                   "DEMONSTRATIVO DE CONTRATACAO DO PRODUTO PRE-APROVADO Nº " 
                   par_nrctremp
                   SKIP(2).
           END.

        IF crapass.inpessoa = 1 THEN
           DO:
               /* Valor do emprestimo por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlemprst,
                                                  INPUT 60,
                                                  INPUT 10,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlempr1,
                                                  OUTPUT aux_dsvlempr2).
        
               /* Valor da prestacao por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlpreemp,
                                                  INPUT 86,
                                                  INPUT 0,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlpres1,
                                                  OUTPUT aux_dsvlpres2).

               /* Valor do IOF por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vltariof,
                                                  INPUT 42,
                                                  INPUT 28,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlriof1,
                                                  OUTPUT aux_dsvlriof2).

               /* Valor da tarifa por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlrtarif,
                                                  INPUT 36,
                                                  INPUT 34,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlrtar1,
                                                  OUTPUT aux_dsvlrtar2).             
												  
               PUT STREAM str_1
                   "Eu (" rPadTexto(INPUT crapass.nmprimtl, INPUT 47) FORMAT "x(47)" 
                   "), inscrito no CPF n " aux_nrcpfcgc " e "				  
                   SKIP
                   "portador do RG nº "
                   rPadTexto(INPUT crapass.nrdocptl, INPUT 40) FORMAT "x(40)" 
                   ", com estado civil "
                   rPadTexto(INPUT aux_dsestcvl, INPUT 36) FORMAT "x(36)"
                   ", "
                   SKIP
                   "residente e domiciliado na "
                   rPadTexto(INPUT aux_dsendere, INPUT 42) FORMAT "x(42)"
                   ", ns "
                   rPadTexto(INPUT STRING(aux_nrendere), INPUT 7) FORMAT "x(7)"
                   ", bairro "
                   SKIP
                   rPadTexto(INPUT aux_nmbairro, INPUT 40) FORMAT "x(40)"
                   ", da cidade "
                   rPadTexto(INPUT aux_nmcidade, INPUT 33) FORMAT "x(33)"
                   "/" aux_cdufende FORMAT "x(2)" ", "
                   SKIP
                   "CEP: " aux_nrcepend ", titular da conta "
                   rPadTexto(INPUT aux_nrdconta, INPUT 10) FORMAT "x(10)"
                   ". Pagarei a Cooperativa o valor contratado em "
                   SKIP
                   par_dtmvtolt FORMAT "99/99/9999"
                   " de R$ " par_vlemprst " (" 
                   aux_dsvlempr1 FORMAT "x(60)"
                   SKIP
                   aux_dsvlempr2 FORMAT "x(10)"
                   "), acrescido de juros  remuneratorios  capitalizados  "
                   "mensalmente,  a  taxa  de "				  
                   SKIP
                   IF par_txmensal > 0 THEN par_txmensal ELSE craplcr.txmensal FORMAT "zz9.99"
                   "% a.m.  estipulada  na  quantidade  de  "
                   par_qtpreemp  FORMAT "z9" "  parcelas,  no  valor  de  R$ " 
                   par_vlpreemp  FORMAT "zzz,zz9.99" " "
                   SKIP
                   "("
                   aux_dsvlpres1 FORMAT "x(86)" "), "
                   SKIP
                   "CET de " 
                   par_percetop FORMAT "zz9.99" "% a.a, IOF de "
                   "R$ "
                   par_vltariof FORMAT "zz9.99"
                   "(" aux_dsvlriof1 FORMAT "x(42)"
                   SKIP
                   aux_dsvlriof2 FORMAT "x(28)" ") "
                   "e tarifa de R$ " par_vlrtarif FORMAT "zz9.99"
                   " (" 
                   aux_dsvlrtar1 FORMAT "x(36)"
                   SKIP
                   aux_dsvlrtar2 FORMAT "x(34)"
                   " ) com data do primeiro vencimento em "
                   par_dtdpagto FORMAT "99/99/9999" ". ".

           END. /* END IF crapass.inpessoa = 1 THEN */
        ELSE
           DO:
               /* Valor do emprestimo por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlemprst,
                                                  INPUT 60,
                                                  INPUT 10,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlempr1,
                                                  OUTPUT aux_dsvlempr2).
        
               /* Valor da prestacao por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlpreemp,
                                                  INPUT 8,
                                                  INPUT 62,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlpres1,
                                                  OUTPUT aux_dsvlpres2).

               /* Valor do IOF por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vltariof,
                                                  INPUT 70,
                                                  INPUT 0,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlriof1,
                                                  OUTPUT aux_dsvlriof2).

               /* Valor da tarifa por extenso */
               RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlrtarif,
                                                  INPUT 70,
                                                  INPUT 0,
                                                  INPUT "M",
                                                  OUTPUT aux_dsvlrtar1,
                                                  OUTPUT aux_dsvlrtar2).

               PUT STREAM str_1
                   "(" rPadTexto(INPUT crapass.nmprimtl, INPUT 48) FORMAT "x(48)"
                   "), pessoa juridica de  direito  privado, "
                   SKIP
                   "inscrita     no     CNPJ     sob     o     nº     " 
                   aux_nrcpfcgc ",     com     sede     na "
                   SKIP
                   rPadTexto(INPUT aux_dsendere, INPUT 60) FORMAT "x(60)"
                   ",   nº   "
                   rPadTexto(INPUT STRING(aux_nrendere), INPUT 10) FORMAT "x(10)"
                   ",   bairro "
                   SKIP
                   rPadTexto(INPUT aux_nmbairro, INPUT 40) FORMAT "x(40)" ", "
                   "da cidade de "
                   rPadTexto(INPUT aux_nmcidade, INPUT 25) FORMAT "x(25)"
                   "/" aux_cdufende FORMAT "x(2)"
                   ", CEP: "  
                   SKIP
                   aux_nrcepend ", titular da conta "
                   rPadTexto(INPUT aux_nrdconta, INPUT 10) FORMAT "x(10)"
                   ". Pagarei a  Cooperativa  o  valor  contratado  em "
                   SKIP
                   par_dtmvtolt FORMAT "99/99/9999"
                   " de R$ " par_vlemprst " ("
                   aux_dsvlempr1 FORMAT "x(60)"
                   SKIP
                   aux_dsvlempr2 FORMAT "x(10)"
                   "), acrescido de juros  remuneratorios  "
                   "capitalizados  mensalmente,  a  taxa  de "
                   SKIP
                   IF par_txmensal > 0 THEN par_txmensal ELSE craplcr.txmensal FORMAT "zz9.99"
                   "% a.m. estipulada na quantidade de "
                   par_qtpreemp FORMAT "z9"
                   " parcelas, no valor de R$  " 
                   par_vlpreemp FORMAT "zzz,zz9.99"
                   "("
                   aux_dsvlpres1 FORMAT "x(8)"
                   SKIP
                   aux_dsvlpres2 FORMAT "x(62)"
                   "), CET de " par_percetop FORMAT "zz9.99" 
                   "% a.a,  IOF "
                   SKIP
                   "de R$ "
                   par_vltariof FORMAT "zz9.99" "("
                   aux_dsvlriof1 FORMAT "x(66)"
                   ") "
                   SKIP
                   "e tarifa de R$ " 
                   par_vlrtarif FORMAT "zz9.99"
                   "("
                   aux_dsvlrtar1 FORMAT "x(66)"
                   ") "
                   SKIP
                   "com data do primeiro vencimento em " 
                   par_dtdpagto FORMAT "99/99/9999" ".".
           END.
            
        PUT STREAM str_1
            SKIP(1)
            "*Atraso: No caso de atraso, pagarei encargos moratorios de "
            craplcr.perjurmo FORMAT "zz9.99"
            "% a.m. e multa moratoria " 
            SKIP
            "de " aux_percmult FORMAT "zz9.99" "% sobre o valor de atraso."
            SKIP
            "*Liquidacao antecipada: Poderei solicitar, em qualquer  Posto  de "
            " Atendimento  de  minha "
            SKIP
            "preferencia, a liquidacao antecipada  do  contrato,  hipotese  em "
            " que  terei  a  reducao "
            SKIP
            "proporcional de juros."
            SKIP(1)
            "*Desistencia: Poderei desistir do contrato no prazo de "
            "ate sete dias do  recebimento  dos "
            SKIP
            "valores, mediante requerimento formal direcionado ao "
            "Posto de Atendimento  onde  mantenho "
            SKIP
            "minha conta, devendo restituir o valor  que  me  foi  entregue, "
            " acrescido  de  eventuais "
            SKIP
            "tributos e juros incidentes ate a data da efetiva devolucao."
            SKIP(1)
            "As    condicoes    gerais    do    Credito-Aprovado    estao    "
            "disponiveis    no    site "
            SKIP
            rPadTexto(INPUT crapcop.dsendweb, INPUT 40) FORMAT "x(40)"
            ",  bem  como  nos  Postos   de   Atendimento   da "
            SKIP
            "Cooperativa, e contem informacoes detalhadas "
            "das regras do produto."
            SKIP(1)
            "A senha eletronica digitada, necessaria para esta  contratacao, "
            " substitui  a  assinatura fisica."
            SKIP.

              /* P442 - Validar assinado Digitalmente */
               /* Buscar dados do contrato de emprestimo */
               FIND FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper AND
                                        crawepr.nrdconta = par_nrdconta AND
                                        crawepr.nrctremp = par_nrctremp
                                        NO-LOCK NO-ERROR.

               IF AVAIL crawepr THEN
                DO:
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
                  
                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                  
                  ASSIGN aux_dsassdig = pc_assinatura_contrato_pre.pr_assinatu
                         aux_des_reto = pc_assinatura_contrato_pre.pr_des_reto
                         aux_cdcritic = pc_assinatura_contrato_pre.pr_cdcritic WHEN pc_assinatura_contrato_pre.pr_cdcritic <> ?
                         aux_dscritic = pc_assinatura_contrato_pre.pr_dscritic WHEN pc_assinatura_contrato_pre.pr_dscritic <> ?.

                  PUT STREAM str_1
                      SKIP(1)
                      aux_dsassdig FORMAT "x(" + STRING(LENGTH(aux_dsassdig, "CHARACTER")) + ")"
                      SKIP.
                END.

        OUTPUT STREAM str_1 CLOSE.

    END. /* Imprime */

    IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE PROCEDURE h-b1wgen9999.

    IF aux_dscritic <> "" OR aux_cdcritic <> 0 OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           ASSIGN aux_returnvl = "NOK".
           
           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

       END.
    ELSE
       ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* END imprime_previa_demonstrativo */


PROCEDURE imprime_demonstrativo_ayllos_web:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

        
    RUN imprime_demonstrativo(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_dtmvtolt,
                              INPUT par_nrctremp,
                              OUTPUT par_nmarqimp,
                              OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
    DO:
        RETURN "NOK".
    END.
    ELSE 
    DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* EXECUTA EMPR0003.pc_gera_demonst_pre_aprovado */
        RUN STORED-PROCEDURE pc_gera_demonst_pre_aprovado
             aux_handproc = PROC-HANDLE NO-ERROR
                          ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,                            
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_dtmvtolt,
                            INPUT par_nmarqimp,
                           OUTPUT "", /* pr_nmarqpdf */
                           OUTPUT ""). /* pr_nmarqpdf */

        CLOSE STORED-PROC pc_gera_demonst_pre_aprovado 
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_des_reto = ""
               par_nmarqpdf = ""
               aux_des_reto = pc_gera_demonst_pre_aprovado.pr_des_reto 
                         WHEN pc_gera_demonst_pre_aprovado.pr_des_reto <> ?
               par_nmarqpdf = pc_gera_demonst_pre_aprovado.pr_nmarqpdf 
                         WHEN pc_gera_demonst_pre_aprovado.pr_nmarqpdf <> ?.

 
        IF aux_des_reto <> "OK" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = 0
                   tt-erro.dscritic = aux_des_reto.
            RETURN "NOK".
        END.

        MESSAGE par_nmarqpdf.

    END.

END PROCEDURE.


PROCEDURE busca_carga_ativa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_idcarga  AS INTE                           NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_idcarga_pre_aprovado_cta
         aux_handproc = PROC-HANDLE NO-ERROR
                       (INPUT par_cdcooper,
                        INPUT par_nrdconta,
                       OUTPUT 0). /* idcarga */

    CLOSE STORED-PROC pc_idcarga_pre_aprovado_cta 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_idcarga = 0
           par_idcarga = pc_idcarga_pre_aprovado_cta.pr_idcarga 
                         WHEN pc_idcarga_pre_aprovado_cta.pr_idcarga <> ?.

END PROCEDURE.

PROCEDURE verifica_mostra_banner_taa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_flgdobnr AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrsemana AS INTE                                    NO-UNDO.
    DEF VAR aux_ponteiro AS INTE                                    NO-UNDO.
    DEF VAR aux_dtmvtolt AS CHAR                                    NO-UNDO.
    DEF VAR aux_idcarga  AS INTE                                    NO-UNDO.
    DEF VAR aux_cdmodali AS INTE                                    NO-UNDO.

    ASSIGN par_flgdobnr = TRUE
           aux_dtmvtolt = STRING(DAY(par_dtmvtolt), "99")      + "/" +
                          STRING(MONTH(par_dtmvtolt), "99")    + "/" +
                          STRING(YEAR(par_dtmvtolt), "9999").

    
    /* P485 - Validaçao para conta salário */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_busca_modalidade_conta aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT  par_cdcooper 
                  ,INPUT  par_nrdconta 
                  ,OUTPUT 0
                  ,OUTPUT ""
                  ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_busca_modalidade_conta aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_cdmodali = 0
           aux_dscritic = pc_busca_modalidade_conta.pr_dscritic 
                          WHEN pc_busca_modalidade_conta.pr_dscritic <> ?
           aux_cdmodali = pc_busca_modalidade_conta.pr_cdmodalidade_tipo 
                          WHEN pc_busca_modalidade_conta.pr_cdmodalidade_tipo <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    /* Se retornou crítica */
    IF  aux_dscritic <> "" THEN
      DO:
           RETURN "NOK".
      END.
    
    /* Se a modalidade for 2 entao é conta salário */
    IF aux_cdmodali = 2 THEN
      DO:
        par_flgdobnr = FALSE.
        RETURN "OK".
      END.
    
    /* P485 - Validaçao para conta salário */    
    
    
    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    /* Pega a semana no mês corrente. */
    RUN STORED-PROCEDURE {&sc2_dboraayl}.send-sql-statement
                       aux_ponteiro = PROC-HANDLE 
        ("SELECT TRUNC((dtatual - next_day(TRUNC(dtatual, 'mm') - 7, 1)) / 7) + 1 numero_semana FROM (SELECT to_date('" + aux_dtmvtolt + "', 'dd/mm/yyyy') dtatual FROM dual)").

    FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
       ASSIGN aux_nrsemana = INT(proc-text).
    END.
    
    CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement WHERE PROC-HANDLE = aux_ponteiro.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  (aux_nrsemana MOD 2 ) > 0 THEN
        ASSIGN par_flgdobnr = FALSE.

    /* Verifica se existe limite disponível */
    RUN busca_dados (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_nrcpfope,
                     OUTPUT TABLE tt-dados-cpa,
                     OUTPUT TABLE tt-erro).

    FIND tt-dados-cpa NO-LOCK NO-ERROR.
    IF  AVAIL tt-dados-cpa THEN
        DO:
            IF  tt-dados-cpa.vldiscrd <= 0 THEN
            DO:
                ASSIGN par_flgdobnr = FALSE.
                RETURN "OK".
            END.    
        END.
    ELSE
        DO:
            ASSIGN par_flgdobnr = FALSE.
            RETURN "OK".
        END. 
		
    /* Dados de parametrizacao do credito pre-aprovado */
    FOR crappre FIELDS(cdfinemp)
                WHERE crappre.cdcooper = par_cdcooper            AND
                      crappre.inpessoa = tt-dados-cpa.inpessoa
                      NO-LOCK: END.

    IF NOT AVAIL crappre THEN
       DO:
           ASSIGN par_flgdobnr = FALSE.
		   RETURN "OK".
       END.
   
   /* Verifica se já contratou pré-aprovado esse mês */
   FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper        AND
                          crapepr.nrdconta = par_nrdconta        AND
                          crapepr.cdfinemp = crappre.cdfinemp    AND
                          crapepr.inliquid = 0 /* ATIVO*/
                          NO-LOCK:

       IF  MONTH(crapepr.dtmvtolt) = MONTH(par_dtmvtolt) THEN
           DO:
               ASSIGN par_flgdobnr = FALSE.
               LEAVE.
           END.
           
   END.

   RETURN "OK".

END PROCEDURE.


/* ......................................................................... */