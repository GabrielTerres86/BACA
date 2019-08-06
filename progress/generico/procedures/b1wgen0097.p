/******************************************************************************
                           ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+-------------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                       |
  +-------------------------------------+-------------------------------------------+
  | calcula_data_parcela_sim            | empr0018.pc_calcula_data_parcela_sim      |
  | busca_dados_simulacao               | empr0018.pc_busca_dados_simulacao         |
  | busca_simulacoes                    | empr0018.pc_busca_simulacoes              |
  | exclui_simulacao                    | empr0018.pc_exclui_simulacao              |
  | grava_simulacao                     | empr0018.pc_grava_simulacao               |
  | valida_gravacao_simulacao           | empr0018.pc_valida_gravacao_simulacao     |
  | imprime_simulacao                   | empr0018.pc_imprime_simulacao             |
  | consulta_tarifa_emprst              | empr0018.pc_consulta_tarifa_emprst        |
  +-------------------------------------+-------------------------------------------+
*******************************************************************************/


/*............................................................................
    
    Programa: sistema/generico/procedures/b1wgen0097.p
    Autor   : Gabriel, GATI - Diego
    Data    : Maio/2011               Ultima Atualizacao: 28/06/2019
    
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

                09/05/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

				27/09/2017 - Projeto 410 - Incluir campo Indicador de 
                            financiamento do IOF (Diogo - Mouts) e valor total da simulação

                12/10/2017 - Projeto 410 - passar como parametro da pc_calcula_iof_epr, 
				             o numero do contrato (Jean - Mout´s)
                     
                04/04/2018 - Corrigir o calculo do CET. (James)     
                
                12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)
                
                14/12/2018 - P298 - Inclusos campos tpemprst e carencia para simulação (Andre Clemer - Supero)
                
                28/06/2019 - P438 - Remocao de  rotinas convertidas e sem dependencias. 
                            (Douglas Pagel / AMcom)
                
                
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
DEF VAR aux_vlemprst AS DECI                                        NO-UNDO.
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
*             PROCEDURE Consulta tarifa do contrato do emprestimo            *
******************************************************************************/
PROCEDURE consulta_tarifa_emprst:
    
    DEF INPUT        PARAM par_cdcooper AS INT                      NO-UNDO.
    DEF INPUT        PARAM par_cdlcremp AS INT                      NO-UNDO.
    DEF INPUT        PARAM par_vlemprst AS DEC                      NO-UNDO.
    DEF INPUT        PARAM par_nrdconta AS INT                      NO-UNDO.    
    DEF INPUT        PARAM par_nrctremp AS INT                      NO-UNDO.
    DEF INPUT        PARAM par_dscatbem AS CHAR                     NO-UNDO.
    
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
    DEF        VAR aux_dscatbem         AS CHAR                     NO-UNDO.
    DEF        VAR aux_dscritic         AS CHAR                     NO-UNDO.

    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                       craplcr.cdlcremp = par_cdlcremp
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplcr THEN
        DO:
            aux_cdcritic = 363.
            RETURN "NOK".
        END.

           ASSIGN aux_inpessoa = 1. /* Fisica */ 

           FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                              crapass.nrdconta = par_nrdconta
                              NO-LOCK NO-ERROR .

           /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
           IF AVAIL crapass THEN
           DO:
        ASSIGN aux_inpessoa = crapass.inpessoa.
           END.
            
           IF NOT VALID-HANDLE(h-b1wgen0153) THEN
               RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

           /* Caso enviado Numero Contrato, buscamos os bens, senão usamos a lista passada */
           IF par_nrctremp > 0 THEN 
           DO:
           ASSIGN aux_dscatbem = "".
           FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper  AND
                                  crapbpr.nrdconta = par_nrdconta  AND
                                  crapbpr.nrctrpro = par_nrctremp  AND 
                                  crapbpr.tpctrpro = 90 NO-LOCK:
               ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
           END.
           END.
           ELSE
           DO:
               ASSIGN aux_dscatbem = par_dscatbem.
           END.
          
          /* Buscar a tarifa */
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
          RUN STORED-PROCEDURE pc_calcula_tarifa
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper       /* Código da cooperativa */
                                              ,INPUT par_nrdconta       /* Número da conta */
                                              ,INPUT par_cdlcremp   /* Linha de crédito */
                                              ,INPUT par_vlemprst   /* Valor do emprestimo */
                                              ,INPUT craplcr.cdusolcr   /* Uso da linha de crédito */
                                              ,INPUT craplcr.tpctrato   /* Tipo de contrato */
                                              ,INPUT aux_dscatbem       /* Bens em garantia */
                                              ,INPUT 'ATENDA'           /* Nome do programa */
                                              ,INPUT 'N'                /* Flag de envio de e-mail */
                                              ,INPUT 0                  /* Identificador se financia iof e tarifa */
                                              ,OUTPUT 0                 /* Tipo de empréstimo */
                                              ,OUTPUT 0                 /* Valor da tarifa */
                                              ,OUTPUT 0                 /* Valor da tarifa especial */
                                              ,OUTPUT 0                 /* Valor da tarifa garantia */
                                              ,OUTPUT 0                 /* Histórico do lançamento */
                                              ,OUTPUT 0                 /* Faixa de valor por cooperativa */
                                              ,OUTPUT 0                        /* Historico Garantia */
                                              ,OUTPUT 0                        /* Faixa de valor garantia */
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
          DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 1,
                            INPUT 1,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
          END.
          
          
            
          /* Valor tarifa */
          ASSIGN par_vlrtarif = 0.
          IF pc_calcula_tarifa.pr_vlrtarif <> ? THEN
            DO:
              ASSIGN par_vlrtarif = par_vlrtarif + ROUND(DECI(pc_calcula_tarifa.pr_vlrtarif),2).
            END.
          IF pc_calcula_tarifa.pr_vltrfesp <> ? THEN
            DO:
              ASSIGN par_vlrtarif = par_vlrtarif + ROUND(DECI(pc_calcula_tarifa.pr_vltrfesp),2).
            END.
          IF pc_calcula_tarifa.pr_vltrfgar <> ? THEN
            DO:
              ASSIGN par_vlrtarif = par_vlrtarif + ROUND(DECI(pc_calcula_tarifa.pr_vltrfgar),2).
            END.
        
          /* Faremos o cálculo abaixo somente se não recebemos bens nem contrato */
          IF par_nrctremp = 0 AND par_dscatbem = "" THEN
          DO:
          
    /* Buscar tarifas de Alienação pois a rotina acima não tem os Bens na simulação */
           IF  VALID-HANDLE(h-b1wgen0153)  THEN
                DELETE PROCEDURE h-b1wgen0153.
            
           IF  RETURN-VALUE = "NOK"  THEN
                RETURN "NOK".

           IF ( craplcr.tpctrato = 2 ) OR       /* Avaliacao de garantia de bem movel */
              ( craplcr.tpctrato = 3 ) THEN     /* Avaliacao de garantia de bem imovel */
           DO:

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
           
    /* Acumular tarifa de alienação (Se aplicavel) */
    par_vlrtarif = par_vlrtarif + aux_taravali.

          END.
           

    RETURN "OK".
END.

PROCEDURE busca_parcelas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrsimula AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-parcelas-epr.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR                               NO-UNDO. 

    EMPTY TEMP-TABLE tt-parcelas-epr.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle  */
    RUN STORED-PROCEDURE pc_retorna_simulacao_parc_prog
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /*pr_cdcooper*/
                                           INPUT par_nrdconta, /*pr_nrdconta*/
                                           INPUT par_nrsimula, /*pr_nrsimula*/
                                           OUTPUT "", /* pr_tab_parcelas */
                                           OUTPUT 0,   /* pr_cdcritic */
                                           OUTPUT ""). /* pr_dscritic */  

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_retorna_simulacao_parc_prog
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = INT(pc_retorna_simulacao_parc_prog.pr_cdcritic)
                          WHEN pc_retorna_simulacao_parc_prog.pr_cdcritic <> ?
           aux_dscritic = pc_retorna_simulacao_parc_prog.pr_dscritic
                          WHEN pc_retorna_simulacao_parc_prog.pr_dscritic <> ?.
  
    IF aux_cdcritic <> 0    OR
       aux_dscritic <> ""   THEN
      RETURN "NOK".

    EMPTY TEMP-TABLE tt-parcelas-epr.

    /* Leitura do XML de retorno da proc e criacao dos registros na tt-extrato_conta
       para visualizacao dos registros na tela */

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_retorna_simulacao_parc_prog.pr_tab_parcelas. 

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    IF ponteiro_xml <> ? THEN
      DO:
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).

        DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

          IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
            NEXT. 

          IF xRoot2:NUM-CHILDREN > 0 THEN
            CREATE tt-parcelas-epr.

          DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

            xRoot2:GET-CHILD(xField,aux_cont).

            IF xField:SUBTYPE <> "ELEMENT" THEN 
              NEXT. 

            xField:GET-CHILD(xText,1).

            ASSIGN tt-parcelas-epr.cdcooper = par_cdcooper
                   tt-parcelas-epr.nrdconta = par_nrdconta
                   tt-parcelas-epr.nrparepr = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrparepr"
                   tt-parcelas-epr.vlparepr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlparepr"
                   tt-parcelas-epr.dtparepr = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto".

          END. /* DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:*/

        END. /* DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: */

        SET-SIZE(ponteiro_xml) = 0. 

      END. /* ponteiro_xml <> ? */

      /*Elimina os objetos criados*/
      DELETE OBJECT xDoc. 
      DELETE OBJECT xRoot. 
      DELETE OBJECT xRoot2. 
      DELETE OBJECT xField. 
      DELETE OBJECT xText.
      
   RETURN "OK".

END.

/* ......................................................................... */

