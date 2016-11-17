/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | procedures/b1wgen0084b.p        | EMPR0001                          |
  | valida_pagamentos_geral         | pc_valida_pagamentos_geral        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/









/*..............................................................................

    Programa: sistema/generico/procedures/b1wgen0084b.p
    Autor   : Gabriel
    Data    : Outubro/2012               ultima Atualizacao:  27/11/2015
     
    Dados referentes ao programa:
   
    Objetivo  : BO para rotinas do sistema referentes a pagamento e estorno
   
    Alteracoes: 14/12/2012 - Ajustes nas mensagens quando o cooperado esta
                             sem saldo para pagamento (Gabriel).
                             
                06/02/2013 - Tratar alcada do operado so quando pagamento via
                             online e retornar valor ok da valida pagamentos
                             geral (Gabriel).             
                             
                25/02/2013 - Tratar validacoes de pagamento (Gabriel). 
                
                27/02/2013 - Limitar os pagamentos somente para os operadores
                             da TI e PRODUTOS (Gabriel). 
                             
               11/09/2013 - Incluir os pacs liberados para emprestimos
                            prefixados. (Irlan) 
                            
               25/10/2013 - Realizado ajuste para retirar o bloqueio de 
                            emprestimos Pre-fixado da cooperativa Viacredi e
                            incluido a cooperativa Acredicoop.
                            Procedures alterdadas:    
                            - valida_pagamentos_geral
                            (Adriano)
                            
               28/10/2013 - Retirado restricao de departamento (Adriano). 
               
               12/03/2014 - Ajuste na procedure "valida_pagamentos_geral"
                            para liberar pagamento para Acredi (James).
                            
               17/10/2014 - Ajuste na mensagem quando efetuado um pagamento
                            no dia da liberacao do emprestimo. (James)

               05/11/2015 - Incluso procedure imprime_declaracao_pagamento (Daniel) 

               27/11/2015 - Ajustado para que a procedure valida_pagamentos_geral
                            utilize a rotina convertida em Oracle 
                            (Douglas - Chamado 285228)
..............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0001tt.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.

DEF STREAM str_1.

PROCEDURE valida_pagamentos_geral:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlapagar AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_vlsomato AS DECI                           NO-UNDO.    
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.    

    DEF VAR aux_des_reto          AS CHAR                           NO-UNDO.
    DEF VAR aux_inconfir          AS INTE                           NO-UNDO.
    DEF VAR aux_dsmensag          AS CHAR                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    /* Utilizar o tipo de busca A, para carregar do dia anterior
      (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
    RUN STORED-PROCEDURE pc_valida_pagto_geral_prog
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad, 
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_nrdconta,
                                 INPUT par_nrctremp,
                                 INPUT par_idseqttl,
                                 INPUT par_dtmvtolt,
                                 INPUT IF par_flgerlog THEN 1 ELSE 0,
                                 INPUT par_dtrefere,
                                 INPUT par_vlapagar,
                                 OUTPUT 0,   /* pr_vlsomato */
                                 OUTPUT "",  /* pr_des_reto */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT "",  /* pr_dscritic */
                                 OUTPUT 0,   /* pr_inconfir */
                                 OUTPUT ""). /* pr_dsmensag */

    CLOSE STORED-PROC pc_valida_pagto_geral_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_vlsomato = 0
           aux_des_reto = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_inconfir = 0
           aux_dsmensag = ""

           par_vlsomato = ROUND(pc_valida_pagto_geral_prog.pr_vlsomato,2)
                              WHEN pc_valida_pagto_geral_prog.pr_vlsomato <> ?
           aux_des_reto = pc_valida_pagto_geral_prog.pr_des_reto 
                              WHEN pc_valida_pagto_geral_prog.pr_des_reto <> ?
           aux_cdcritic = pc_valida_pagto_geral_prog.pr_cdcritic 
                              WHEN pc_valida_pagto_geral_prog.pr_cdcritic <> ?
           aux_dscritic = pc_valida_pagto_geral_prog.pr_dscritic
                              WHEN pc_valida_pagto_geral_prog.pr_dscritic <> ?
           aux_inconfir = pc_valida_pagto_geral_prog.pr_inconfir 
                              WHEN pc_valida_pagto_geral_prog.pr_inconfir <> ?
           aux_dsmensag = pc_valida_pagto_geral_prog.pr_dsmensag
                              WHEN pc_valida_pagto_geral_prog.pr_dsmensag <> ?. 

    IF  aux_cdcritic <> 0 OR
        aux_dscritic <> "" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
        END.
    
    IF aux_dsmensag <> "" THEN
        DO:
            CREATE tt-msg-confirma.
            ASSIGN tt-msg-confirma.inconfir = aux_inconfir
                   tt-msg-confirma.dsmensag = aux_dsmensag.
        END.

    RETURN aux_des_reto.

END PROCEDURE.


PROCEDURE imprime_declaracao_pagamento:

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
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(14)"                     NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR FORMAT "x(10)"                     NO-UNDO.
    DEF VAR aux_inpessoa LIKE crapass.inpessoa                      NO-UNDO.
    DEF VAR aux_percmult AS DECI                                    NO-UNDO.
    DEF VAR aux_dsestcvl LIKE gnetcvl.dsestcvl                      NO-UNDO.
    
    DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_returnvl = "NOK".

    FOR crapcop FIELDS(dsdircop dsendweb) 
                WHERE crapcop.cdcooper = par_cdcooper 
                      NO-LOCK: END.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/".
           aux_nmarquiv = aux_nmarquiv + "DPIB_" + STRING(par_cdcooper) + "_" + 
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


        FOR crapepr FIELDS(dtapgoib)
                    WHERE crapepr.cdcooper = par_cdcooper
                      AND crapepr.nrdconta = par_nrdconta
                      AND crapepr.nrctremp = par_nrctremp
                      NO-LOCK: END.
        
        IF crapass.inpessoa = 1 THEN
           DO:
               ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                      aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").

           END.
        ELSE
           DO:
               ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                      aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
           END.


        ASSIGN aux_nrdconta = TRIM(STRING(crapass.nrdconta,"zzzz,zzz,9")).

        PUT STREAM str_1
           "DECLARAÇÃO PAGAMENTO PARCELAS CONTRATO" AT 20
           SKIP(2).

        PUT STREAM str_1 
            "Conta: " aux_nrdconta " - " crapass.nmprimtl
            SKIP(1)
            "Contrato: " TRIM(STRING(par_nrctremp,"zz,zzz,zz9"))
            SKIP(2).


        PUT STREAM str_1 
            "Declaro ter ciência que, além da possibilidade de liquidação antecipada da operação de crédito, prevista na "
            SKIP
            "Cédula de Crédito Bancário e/ou Contrato de Crédito Simplificado assinada(o) por mim no momento da "
            SKIP
            "contratação, também poderei efetuar o pagamento de parcelas em atraso, bem como, realizar a liquidação "
            SKIP
            "antecipada parcial ou total, por meio de acesso a minha conta online, mediante digitação de senha eletrônica, "
            SKIP
            "observadas as regras estipuladas pela Cooperativa. Ficam ratificadas todas as demais condições desta "
            SKIP
            "contratação, constantes na Cédula de Crédito Bancário e/ou Contrato de Crédito Simplificado, sendo "
            SKIP
            "que a senha eletrônica aqui digitada, necessária à aceitação deste conteúdo, substitui minha assinatura física."
            SKIP(2).

         PUT STREAM str_1 
            "Data da assinatura eletrônica: " crapepr.dtapgoib FORMAT "99/99/9999"
             SKIP.
        OUTPUT STREAM str_1 CLOSE.

    END. /* Imprime */

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

END PROCEDURE. /* END imprime_relatorio */

/* .......................................................................... */


