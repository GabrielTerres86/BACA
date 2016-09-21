/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+---------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL             |
  +------------------------------------------+---------------------------------+
  | sistema/generico/procedures/b1wgen0159.p |                                 |
  |    verifica-imunidade-tributaria         | IMUT0001.pc_verifica_imunidade_trib |
  |    verifica-periodo-imune                | IMUT0001.pc_verifica_periodo_imune  |
  +------------------------------------------+---------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/*..............................................................................

    Programa: b1wgen0159.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andre Santos - Supero
    Data    : Junho/2013                        Ultima atualizacao: 13/06/2014

    Dados referentes ao programa:

    Objetivo  : BO referente a Imunidade Tributaria.
               
    Alteracoes: 14/08/2013 - Alterado para que seja possivel imprimir relatorio
                             de imunidade por periodo e situação.
                             (Anderson/Amcom).
                            
                27/08/2013 - Ajustando BO para Ayllos(WEB)
                             (Andre Santos - SUPERO)
                             
                31/10/2013 - Solicitar Nivel GERENTE para aprovacao (Ze).
                
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                13/06/2014 - Alteração de Cód Rel. 664 para 666 e 
                             totalização por entidade para rel666 e 
                             rel665 (SD. 167168 - Lunelli)
                
..............................................................................*/
DEF STREAM str_1.  /*  Para relatorio de entidade  */

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0159tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0159 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.


PROCEDURE verifica-imunidade-tributaria:

   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
   DEF  INPUT PARAM par_flgrvvlr AS LOGI  /* Grava Valor ? */          NO-UNDO.
   DEF  INPUT PARAM par_cdinsenc AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_vlinsenc AS DECI  /* Valor a ser gravado */    NO-UNDO.

   DEF OUTPUT PARAM par_flgimune AS LOGI  /* Retorna se eh Imune */    NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   
   ASSIGN par_flgimune = FALSE.
   
   IF   par_nrdconta = 0 THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informar o numero da Conta".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

   FIND LAST crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

   IF  NOT AVAIL crapass THEN 
       DO:
           ASSIGN aux_cdcritic = 9.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN 
       RETURN "OK".

   FIND LAST crapimt WHERE crapimt.cdcooper = par_cdcooper     AND
                           crapimt.nrcpfcgc = crapass.nrcpfcgc
                           NO-LOCK NO-ERROR. 
    
   IF   NOT AVAILABLE crapimt THEN 
        RETURN "OK". 
   ELSE
        DO:
            IF   crapimt.dtcadast <= par_dtmvtolt AND
                 crapimt.cdsitcad = 1             THEN  /* Situacao Aprovado */
                 DO:
                     IF   par_flgrvvlr THEN 
                          DO:
                               IF   par_cdinsenc = 0 OR
                                    par_vlinsenc = 0 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = 
                                          "Informar os parametros de gravacao".
    
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 1, /*sequencia*/
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT
                                                             aux_dscritic).
    
                                        RETURN "NOK".
                                    END.
                                    
                               /*  Tratamento para o debito do IR em cotas -
                                   Nao grava com o ultimo dia do ano        */
                               IF   par_cdinsenc = 6 THEN
                                    DO:
                                        FIND FIRST crapdat WHERE 
                                             crapdat.cdcooper = par_cdcooper
                                             NO-LOCK NO-ERROR.
                                             
                                        IF   AVAILABLE crapdat THEN
                                             par_dtmvtolt = crapdat.dtmvtolt.
                                    END.
                               
                               
                               DO TRANSACTION:
                                    
                                  CREATE crapvin.
                                  ASSIGN crapvin.cdcooper = par_cdcooper
                                         crapvin.dtmvtolt = par_dtmvtolt
                                         crapvin.nrdconta = par_nrdconta
                                         crapvin.nrcpfcgc = crapass.nrcpfcgc
                                         crapvin.cdinsenc = par_cdinsenc
                                         crapvin.vlinsenc = par_vlinsenc.
                                  VALIDATE crapvin.
                                    
                               END.  
                          END.
                      
                     ASSIGN par_flgimune = TRUE.

                 END.
        END.
 
   RETURN "OK".

END PROCEDURE.


PROCEDURE verifica-imunidade-tributaria-poupanca:

   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
   DEF  INPUT PARAM par_flgrvvlr AS LOGI  /* Grava Valor ? */          NO-UNDO.
   DEF  INPUT PARAM par_cdinsenc AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_vlinsenc AS DECI  /* Valor a ser gravado */    NO-UNDO.

   DEF OUTPUT PARAM par_flgimune AS LOGI  /* Retorna se eh Imune */    NO-UNDO.
   DEF OUTPUT PARAM par_cdcritic AS INTE                               NO-UNDO.
   
   ASSIGN par_flgimune = FALSE.
   
   IF   par_nrdconta = 0 THEN 
        DO:
            par_cdcritic = 127.
            RETURN "NOK".
        END.

   FIND LAST crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

   IF  NOT AVAIL crapass THEN 
       DO:
           ASSIGN aux_cdcritic = 9.
           RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN 
       RETURN "OK".

   FIND LAST crapimt WHERE crapimt.cdcooper = par_cdcooper     AND
                           crapimt.nrcpfcgc = crapass.nrcpfcgc
                           NO-LOCK NO-ERROR. 
    
   IF   NOT AVAILABLE crapimt THEN 
        RETURN "OK". 
   ELSE
        DO:
            IF   crapimt.dtcadast <= par_dtmvtolt AND
                 crapimt.cdsitcad = 1             THEN  /* Situacao Aprovado */
                 DO:
                     IF   par_flgrvvlr THEN 
                          DO:
                               IF   par_cdinsenc = 0 OR
                                    par_vlinsenc = 0 THEN
                                    DO:
                                        ASSIGN par_cdcritic = 527.
                                        RETURN "NOK".
                                    END.
                                    
                               DO TRANSACTION:
                                    
                                  CREATE crapvin.
                                  ASSIGN crapvin.cdcooper = par_cdcooper
                                         crapvin.dtmvtolt = par_dtmvtolt
                                         crapvin.nrdconta = par_nrdconta
                                         crapvin.nrcpfcgc = crapass.nrcpfcgc
                                         crapvin.cdinsenc = par_cdinsenc
                                         crapvin.vlinsenc = par_vlinsenc.
                                  VALIDATE crapvin.
                                    
                               END.  
                          END.
                      
                     ASSIGN par_flgimune = TRUE.

                 END.
        END.
 
   RETURN "OK".

END PROCEDURE.



PROCEDURE verifica-periodo-imune:

   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.

   DEF OUTPUT PARAM par_flgimune AS LOGI  /* Retorna se eh Imune */    NO-UNDO.
   DEF OUTPUT PARAM par_dtinicio AS DATE                               NO-UNDO.
   DEF OUTPUT PARAM par_dttermin AS DATE                               NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   
   ASSIGN par_flgimune = FALSE
          par_dtinicio = ?
          par_dttermin = ?.
   
   IF   par_nrdconta = 0 THEN 
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informar o numero da Conta".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

   FIND LAST crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

   IF  NOT AVAIL crapass THEN 
       DO:
           ASSIGN aux_cdcritic = 9.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN 
       RETURN "OK".

   FIND LAST crapimt WHERE crapimt.cdcooper = par_cdcooper     AND
                           crapimt.nrcpfcgc = crapass.nrcpfcgc
                           NO-LOCK NO-ERROR. 
    
   IF   NOT AVAILABLE crapimt THEN 
        RETURN "OK". 
   ELSE
        DO:
            IF   crapimt.cdsitcad > 0  THEN
                 ASSIGN par_dtinicio = crapimt.dtcadast
                        par_dttermin = crapimt.dtcancel
                        par_flgimune = TRUE.
        END.
 
   RETURN "OK".

END PROCEDURE.

/*****************************************************************************/

PROCEDURE consulta-imunidade:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR tt-imunidade.
   DEF OUTPUT PARAM TABLE FOR tt-contas-ass.
   
   DEF VAR aux_dssitcad AS CHAR                                        NO-UNDO.
   DEF VAR aux_dsdentid AS CHAR                                        NO-UNDO.
   DEF VAR aux_nmoperad AS CHAR                                        NO-UNDO.
   
   EMPTY TEMP-TABLE tt-erro.
   EMPTY TEMP-TABLE tt-imunidade.
   EMPTY TEMP-TABLE tt-contas-ass.

   IF  par_nrcpfcgc = 0 THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Informe o numero do CNPJ".
       
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    
       RETURN "NOK".
   END.

   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                        AND crapass.nrcpfcgc = par_nrcpfcgc
                        NO-LOCK NO-ERROR.


   IF  NOT AVAIL crapass THEN 
       DO:
         ASSIGN aux_cdcritic = 9.

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN DO:
       ASSIGN aux_cdcritic = 331.

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
   END.

   FIND LAST crapimt WHERE crapimt.cdcooper = par_cdcooper
                       AND crapimt.nrcpfcgc = par_nrcpfcgc
                        NO-LOCK NO-ERROR. 
    
   IF  AVAIL crapimt THEN DO:
       CASE crapimt.cdsitcad:
            WHEN 0 THEN DO:
                   aux_dssitcad = "Pendente".

                   FIND FIRST crapope 
                        WHERE crapope.cdcooper = par_cdcooper
                          AND crapope.cdoperad = crapimt.cdopecad
                              NO-LOCK NO-ERROR. 
            
                   IF AVAIL crapope THEN
                      aux_nmoperad = crapope.nmoperad.
                   ELSE
                      aux_nmoperad = "OPERADOR NAO ENCONTRADO".

            END.
            WHEN 1 THEN DO:
                   aux_dssitcad = "Aprovado".
           
                   FIND FIRST crapope
                        WHERE crapope.cdcooper = par_cdcooper
                          AND crapope.cdoperad = crapimt.cdopeapr
                              NO-LOCK NO-ERROR. 
                
                   IF AVAIL crapope THEN
                      aux_nmoperad = crapope.nmoperad.
                   ELSE
                      aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.
            WHEN 2 THEN DO:
                   aux_dssitcad = "Nao Aprovado".
        
                   FIND FIRST crapope
                        WHERE crapope.cdcooper = par_cdcooper
                          AND crapope.cdoperad = crapimt.cdopeapr
                              NO-LOCK NO-ERROR. 

                   IF AVAIL crapope THEN
                      aux_nmoperad = crapope.nmoperad.
                   ELSE
                      aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.
            WHEN 3 THEN DO:
                   aux_dssitcad = "Cancelado".
        
                   FIND FIRST crapope
                        WHERE crapope.cdcooper = par_cdcooper
                          AND crapope.cdoperad = crapimt.cdopecad
                              NO-LOCK NO-ERROR. 
                
                   IF AVAIL crapope THEN
                      aux_nmoperad = crapope.nmoperad.
                   ELSE
                      aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.
       END CASE.

       CASE crapimt.cddentid:
            WHEN 1 THEN
                   aux_dsdentid = "Templo de qualquer culto".
            WHEN 2 THEN
                   aux_dsdentid = "Partido Politico, fundacao de " +
                                  "Partido Politico".
            WHEN 3 THEN
                   aux_dsdentid = "Entidade Sindical de Trabalhadores".
            WHEN 4 THEN
                   aux_dsdentid = "Instituicao de Educacao s/ fins " +
                                  "lucrativos".
            WHEN 5 THEN
                   aux_dsdentid = "Instituicao de Assistencia Social " +
                                  "s/ fins lucrativos".
       END CASE.

       CREATE tt-imunidade.
       BUFFER-COPY crapimt TO tt-imunidade.
       ASSIGN tt-imunidade.dssitcad = aux_dssitcad
              tt-imunidade.dsdentid = aux_dsdentid
              tt-imunidade.nmoperad = aux_nmoperad.
       END.
   ELSE 
       ASSIGN aux_dsdentid = ""
              aux_nmoperad = ""
              aux_dssitcad = "".
   
   FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper 
                      AND crapass.nrcpfcgc = par_nrcpfcgc
                      NO-LOCK:
   
       CREATE tt-contas-ass.
       BUFFER-COPY crapass TO tt-contas-ass.
   
   END.

   RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE altera-imunidade:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.
   DEF  INPUT PARAM par_cdsitcad AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_dscancel AS CHAR                               NO-UNDO.
   DEF  INPUT PARAM par_cdopecad AS CHAR                               NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_dssitcad AS CHAR                                        NO-UNDO. 

   EMPTY TEMP-TABLE tt-erro.
   
   IF  par_nrcpfcgc = 0 THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Informe o numero do CNPJ".
    
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    
       RETURN "NOK".
    END.
   
   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                        AND crapass.nrcpfcgc = par_nrcpfcgc
                        NO-LOCK NO-ERROR.
   
   IF  NOT AVAIL crapass THEN 
       DO:
         ASSIGN aux_cdcritic = 9.

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN DO:
       ASSIGN aux_cdcritic = 331.

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
   END.

   FIND FIRST crapimt WHERE crapimt.cdcooper = par_cdcooper
                        AND crapimt.nrcpfcgc = par_nrcpfcgc
                        EXCLUSIVE-LOCK NO-ERROR.

   IF  NOT AVAIL crapimt THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "CNPJ sem cadastro de Imunidade " +
                             "Tributaria".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK". 
   END.

   /* Verifica Cadastro de Situacao Imunidade Triburaria */
   IF  NOT CAN-DO("0,1,2,3",STRING(par_cdsitcad)) THEN DO:
      
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Codigo da Situacao Cadastral " +
                             "invalido".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.
   
   IF  par_cdsitcad      = 3   AND  /* Cancelado */
       crapimt.cdsitcad <> 3   AND
       par_nmdatela <> "CONTAS" THEN DO:
      
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Cancelamento apenas " +
                             "atraves da tela CONTAS".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.

   IF  par_cdsitcad = 2  AND
       par_dscancel = "" AND
       par_nmdatela = "IMUNE" THEN DO:
      
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Obrigatorio informar " +
                             "motivo de Nao Aprovacao!".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.
   
   IF    par_cdsitcad = 1 OR    /* 1 - APROVADO   */
         par_cdsitcad = 2 THEN  /* 2 - NAO APROV. */
         DO:
             FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper AND
                                      crapope.cdoperad = par_cdopecad
                                      NO-LOCK NO-ERROR.
    
             IF   NOT AVAIL crapope THEN
                  DO:
                      ASSIGN aux_cdcritic = 67
                             aux_dscritic = "".

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                      RETURN "NOK".
                  END.
             ELSE
                  DO:
                      IF   crapope.nvoperad < 3 THEN /* Inferior a GERENTE */
                           DO:
                               ASSIGN aux_cdcritic = 0
                                      aux_dscritic = 
                                        "E necessario que o operador seja " +
                                        "GERENTE para aprovacao da Imunidade.".

                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT 1, /*sequencia*/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).
                               RETURN "NOK".
                           END.
                  END.
         END.
   

   
   IF  par_cdsitcad = crapimt.cdsitcad THEN DO: 
   
       IF  par_cdsitcad = 2 THEN /* 2 - Nao Aprovado */
           
           ASSIGN crapimt.dscancel = par_dscancel
                  crapimt.dtcancel = par_dtmvtolt
                  crapimt.cdopeapr = par_cdopecad
                  crapimt.dtdaprov = ?.

       ELSE DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Situacao informada igual a " +
                                  "situacao atual!".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
           RETURN "NOK".

       END.
   END.
   ELSE DO:
        IF  par_cdsitcad = 0 THEN DO: /* 0 - Pendente */
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel atualizar " +
                                  "situacao para Pendente (0)".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".

        END.
        ELSE
        IF  par_cdsitcad = 1 OR   /* 1 - Aprovado */
            par_cdsitcad = 3 THEN /* 3 - Cancelado */

            ASSIGN crapimt.dtdaprov = par_dtmvtolt
                   crapimt.cdopeapr = par_cdopecad
                   crapimt.cdsitcad = par_cdsitcad
                   crapimt.dtcancel = ?
                   crapimt.dscancel = "".

        ELSE
        IF  par_cdsitcad = 3 THEN /* 3 - Cancelado */

            ASSIGN crapimt.dtdaprov = par_dtmvtolt
                   crapimt.cdopecad = par_cdopecad
                   crapimt.cdsitcad = par_cdsitcad
                   crapimt.dtcancel = ?
                   crapimt.dscancel = "".
        ELSE
        IF  par_cdsitcad = 2 THEN /* 2 - Nao Aprovado */
           
            ASSIGN crapimt.dscancel = par_dscancel
                   crapimt.cdsitcad = par_cdsitcad
                   crapimt.dtcancel = par_dtmvtolt
                   crapimt.cdopeapr = par_cdopecad
                   crapimt.dtdaprov = ?.
   END.

   RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE consulta-imunidade-contas:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR tt-imunidade.
   
   DEF VAR aux_dssitcad AS CHAR                                        NO-UNDO.
   DEF VAR aux_dsdentid AS CHAR                                        NO-UNDO.
   DEF VAR aux_nmoperad AS CHAR                                        NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.
   
   IF  par_nrcpfcgc = 0 THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Informe o numero do CNPJ".
    
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    
       RETURN "NOK".
    END.

   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                        AND crapass.nrcpfcgc = par_nrcpfcgc
                        NO-LOCK NO-ERROR.

   IF  NOT AVAIL crapass THEN 
       DO:
         ASSIGN aux_cdcritic = 9.

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN DO:
       ASSIGN aux_cdcritic = 331.

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
   END.

   FIND FIRST crapimt WHERE crapimt.cdcooper = par_cdcooper
                        AND crapimt.nrcpfcgc = par_nrcpfcgc
                         NO-LOCK NO-ERROR. 
    
   IF  AVAIL crapimt THEN DO:
       
       CASE crapimt.cdsitcad:
            WHEN 0 THEN DO:
                aux_dssitcad = "Pendente".
    
                FIND FIRST crapope 
                     WHERE crapope.cdcooper = par_cdcooper
                       AND crapope.cdoperad = crapimt.cdopecad
                       NO-LOCK NO-ERROR. 
                    
                IF AVAIL crapope THEN
                    aux_nmoperad = crapope.nmoperad.
                ELSE
                    aux_nmoperad = "OPERADOR NAO ENCONTRADO".
    
            END.
            
            WHEN 1 THEN DO:
                   aux_dssitcad = "Aprovado".
                   
                   FIND FIRST crapope
                        WHERE crapope.cdcooper = par_cdcooper
                          AND crapope.cdoperad = crapimt.cdopeapr
                          NO-LOCK NO-ERROR. 
                        
                   IF AVAIL crapope THEN
                      aux_nmoperad = crapope.nmoperad.
                   ELSE
                      aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.
            
            WHEN 2 THEN DO:
                   aux_dssitcad = "Nao Aprovado".
                
                   FIND FIRST crapope
                        WHERE crapope.cdcooper = par_cdcooper
                          AND crapope.cdoperad = crapimt.cdopeapr
                          NO-LOCK NO-ERROR. 
    
                   IF AVAIL crapope THEN
                      aux_nmoperad = crapope.nmoperad.
                    ELSE
                      aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.
            
            WHEN 3 THEN DO:
                   aux_dssitcad = "Cancelado".
                
                   FIND FIRST crapope
                        WHERE crapope.cdcooper = par_cdcooper
                          AND crapope.cdoperad = crapimt.cdopecad
                          NO-LOCK NO-ERROR. 
                        
                   IF AVAIL crapope THEN
                      aux_nmoperad = crapope.nmoperad.
                   ELSE
                      aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.
       END CASE.
    
       
       CASE crapimt.cddentid:
            WHEN 1 THEN
                aux_dsdentid = "Templo de qualquer culto".
            WHEN 2 THEN
                aux_dsdentid = "Partido Politico, fundacao de " +
                               "Partido Politico".
            WHEN 3 THEN
                aux_dsdentid = "Entidade Sindical de Trabalhadores".
            WHEN 4 THEN
                aux_dsdentid = "Instituicao de Educacao s/ fins " +
                               "lucrativos".
            WHEN 5 THEN
                aux_dsdentid = "Instituicao de Assistencia Social " +
                               "s/ fins lucrativos".
       END CASE.
    
       CREATE tt-imunidade.
       BUFFER-COPY crapimt TO tt-imunidade.
       ASSIGN tt-imunidade.dssitcad = aux_dssitcad
              tt-imunidade.dsdentid = aux_dsdentid
              tt-imunidade.nmoperad = aux_nmoperad.
    
       RETURN "OK".
   END. /* ELSE DO do IF AVAIL crapimt */
   
   RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravar-imunidade:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.
   DEF  INPUT PARAM par_cdsitcad AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_cddentid AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
   DEF  INPUT PARAM par_cdopecad AS CHAR                               NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-erro.

   EMPTY TEMP-TABLE tt-erro.
   
   IF  par_cddentid = 99 THEN DO:
      ASSIGN aux_cdcritic = 0
             aux_dscritic = "Informe a entidade.".
   
      RUN gera_erro (INPUT par_cdcooper,
                     INPUT 0,
                     INPUT 0,
                     INPUT 1, /*sequencia*/
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
   
      RETURN "NOK".
   END.
   
   IF  par_cdsitcad = 99 THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Informe a situcao do cadastro.".
    
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    
       RETURN "NOK".
   END.

   IF  par_nrcpfcgc = 0 THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Informe o numero do CNPJ".
    
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    
       RETURN "NOK".
    END.
   
   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                        AND crapass.nrcpfcgc = par_nrcpfcgc
                        NO-LOCK NO-ERROR.
   
   IF  NOT AVAIL crapass THEN 
       DO:
         ASSIGN aux_cdcritic = 9.

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN DO:
       ASSIGN aux_cdcritic = 331.

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
   END.

   /* Verifica Entidade */
   IF  NOT CAN-DO("1,2,3,4,5",STRING(par_cddentid)) THEN DO:
      
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Codigo de Entidade invalido".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.

   /* Verifica Cadastro de Situacao Imunidade Triburaria */
   IF  NOT CAN-DO("0,1,2,3",STRING(par_cdsitcad)) THEN DO:
      
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Codigo da Situacao Cadastral " +
                             "invalido".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.

   IF  par_cdsitcad = 1 OR   /* 1 - Aprovado */
       par_cdsitcad = 2 AND  /* 2 - Nao Aprovado */
       par_nmdatela = "CONTAS" THEN DO:
              
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Alteracao p/ Aprovado " +
                             "e Nao Aprovado apenas " +
                             "atraves da tela IMUNE".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".

   END.

   IF  par_cdsitcad      = 3      AND  /* Cancelado */
       par_nmdatela <> "CONTAS"   THEN DO:
      
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Cancelamento apenas " +
                             "atraves da tela CONTAS".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.
   
   IF    par_cdsitcad = 1 OR    /* 1 - APROVADO   */
         par_cdsitcad = 2 THEN  /* 2 - NAO APROV. */
         DO:
             FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper AND
                                      crapope.cdoperad = par_cdopecad
                                      NO-LOCK NO-ERROR.
    
             IF   NOT AVAIL crapope THEN
                  DO:
                      ASSIGN aux_cdcritic = 67
                             aux_dscritic = "".

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                      RETURN "NOK".
                  END.
             ELSE
                  DO:
                      IF   crapope.nvoperad < 3 THEN /* Inferior a GERENTE */
                           DO:
                               ASSIGN aux_cdcritic = 0
                                      aux_dscritic = 
                                   "E necessario que o operador seja " +
                                   "GERENTE para aprovacao da Imunidade.".
                                        
                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT 1, /*sequencia*/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).
                               RETURN "NOK".
                           END.
                  END.
         END.
   
   FIND FIRST crapimt WHERE crapimt.cdcooper = par_cdcooper
                        AND crapimt.nrcpfcgc = par_nrcpfcgc
                        EXCLUSIVE-LOCK NO-ERROR.

   IF  NOT AVAIL crapimt THEN DO:
       
       /* Gravar registro na crapimt */
       CREATE crapimt.
       ASSIGN crapimt.cdcooper = par_cdcooper
              crapimt.nrcpfcgc = par_nrcpfcgc
              crapimt.cdsitcad = par_cdsitcad /* Sempre Pendente */
              crapimt.cddentid = par_cddentid
              crapimt.dtcadast = par_dtmvtolt
              crapimt.dtdaprov = ?
              crapimt.dtcancel = ?
              crapimt.dscancel = ""
              crapimt.cdopeapr = ""
              crapimt.cdopecad = par_cdopecad.
       VALIDATE crapimt.

   END.
   ELSE DO:
        IF  par_cddentid <> crapimt.cddentid THEN 

            ASSIGN crapimt.dscancel = ""
                   crapimt.cdopeapr = ""
                   crapimt.dtcancel = ?
                   crapimt.dtdaprov = par_dtmvtolt
                   crapimt.cdsitcad = 0 /* Sempre Pendente */
                   crapimt.cddentid = par_cddentid
                   crapimt.cdopeapr = par_cdopecad.

        ELSE DO:
             IF  par_cdsitcad = crapimt.cdsitcad THEN DO:
           
                 IF  par_cdsitcad      = 3   AND /* 3 - Cancelado */
                     crapimt.cdsitcad <> 3   AND
                     par_nmdatela = "CONTAS" THEN 
                   
                     ASSIGN crapimt.cdopeapr = par_cdopecad
                            crapimt.dtdaprov = par_dtmvtolt
                            crapimt.dtcancel = ?
                            crapimt.dscancel = "".
                            
                 ELSE DO:

                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Situacao informada igual " +
                                            "a situacao atual!".
        
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                      RETURN "NOK".
        
                 END.
             END.
             ELSE DO:
                  IF  par_cdsitcad = 0 THEN DO: /* 0 - Pendente */
                        
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = "Nao foi possivel atualizar " +
                                            "situacao para Pendente (0)".
                
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                      RETURN "NOK".
            
                  END.
                  ELSE
                  IF  par_cdsitcad = 3 THEN /* 3 - Cancelado */
                    
                      ASSIGN crapimt.cdsitcad = par_cdsitcad
                             crapimt.cdopeapr = par_cdopecad
                             crapimt.dtdaprov = par_dtmvtolt
                             crapimt.dtcancel = ?
                             crapimt.dscancel = "".

             END.
        END.
   END. /* Fim IF NOT AVAIL */

   RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE imprime-imunidade:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.
   DEF  INPUT PARAM par_cddentid AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_cdopcimp AS CHAR                               NO-UNDO.
   DEF OUTPUT PARAM par_nmarquiv AS CHAR                               NO-UNDO.
   DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                               NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-erro.

   EMPTY TEMP-TABLE tt-erro.

   IF  par_nrcpfcgc = 0 THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Informe o numero do CNPJ".
    
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    
       RETURN "NOK".
   END.

   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                        AND crapass.nrcpfcgc = par_nrcpfcgc
                        NO-LOCK NO-ERROR.

   IF  NOT AVAIL crapass THEN 
       DO:
         ASSIGN aux_cdcritic = 9.

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
       END.
       
   IF  crapass.inpessoa <> 2 THEN DO:
       ASSIGN aux_cdcritic = 331.

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
   END.

   FIND FIRST crapimt WHERE crapimt.cdcooper = par_cdcooper
                        AND crapimt.nrcpfcgc = par_nrcpfcgc
                         NO-LOCK NO-ERROR. 
    
   IF  NOT AVAIL crapimt THEN DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "CNPJ sem cadastro de Imunidade " +
                             "Tributaria".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK". 
   END.

   CASE par_cddentid:
        WHEN 1 THEN DO:
             RUN trata-impressao-modelo1(INPUT par_cdcooper,
                                         INPUT par_nrcpfcgc,
                                         INPUT par_cddentid,
                                         INPUT par_idorigem,
                                         INPUT par_cdopcimp,
                                        OUTPUT par_nmarquiv,
                                        OUTPUT ret_nmarqpdf,
                                        OUTPUT TABLE tt-erro).
             
             IF  RETURN-VALUE <> "OK" THEN
                 RETURN "NOK".

             RETURN "OK".

        END.
        WHEN 2 OR WHEN 3 THEN DO:
             RUN trata-impressao-modelo2(INPUT par_cdcooper,
                                         INPUT par_nrcpfcgc,
                                         INPUT par_cddentid,
                                         INPUT par_idorigem,
                                         INPUT par_cdopcimp,
                                        OUTPUT par_nmarquiv,
                                        OUTPUT ret_nmarqpdf,
                                        OUTPUT TABLE tt-erro).
             
             IF  RETURN-VALUE <> "OK" THEN
                 RETURN "NOK".

            RETURN "OK".

        END.
        WHEN 4 OR WHEN 5 THEN DO:
             RUN trata-impressao-modelo3(INPUT par_cdcooper,
                                         INPUT par_nrcpfcgc,
                                         INPUT par_cddentid,
                                         INPUT par_idorigem,
                                         INPUT par_cdopcimp,
                                        OUTPUT par_nmarquiv,
                                        OUTPUT ret_nmarqpdf,
                                        OUTPUT TABLE tt-erro).
             
             IF  RETURN-VALUE <> "OK" THEN
                 RETURN "NOK".
             
             RETURN "OK".
        END.

   END CASE.
   
END PROCEDURE.

/******************************************************************************/

PROCEDURE trata-impressao-modelo1:

    /* Rotina para tratamento da impressao declaracao de Imunidade IRRF
    sobre rendimento de aplicacoes Financeiras e IOF sobre operacoes de
    credito - Chamada: tela CONTAS_IMUNIDADE */

    DEF  INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                         NO-UNDO.
    DEF  INPUT PARAM par_cddentid AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdopcimp AS CHAR                         NO-UNDO.

    DEF OUTPUT PARAM ret_nmarqimp AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                         NO-UNDO.

    DEF VAR aux_nmprimtl AS CHAR FORMAT "x(69)"                   NO-UNDO.
    DEF VAR aux_dsendere AS CHAR FORMAT "x(79)"                   NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(18)"                   NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR FORMAT "x(79)"                   NO-UNDO.
    DEF VAR aux_endereco AS CHAR FORMAT "x(78)"                   NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    /** Pagina 1 **/
    FORM SKIP(2)
         "DECLARACAO - Imunidade IRRF sobre"                         AT 5
         "rendimentos de aplicacoes Financeiras"                     AT 40
         SKIP(2)
         "Templos de Qualquer Culto"                                 AT 28
         WITH NO-BOX NO-LABELS FRAME f_cabecalho.

    /* Sem a quebra de linha de aux_endereco */
    FORM SKIP(2)
         aux_nmprimtl                             FORMAT "x(69)"     AT 1
         ", com sede"                                                AT 70
         SKIP                                                       
         aux_endereco                             FORMAT "x(78)"     AT 1
         ","                                                         AT 79
         SKIP                                                       
         "inscrita no C.N.P.J sob o Nr"                              AT 1
         aux_nrcpfcgc                             FORMAT "x(18)"     AT 30
         ", para  fins da  nao retencao do"                          AT 48
         SKIP                                                       
         "Imposto de  Renda  sobre rendimentos de  aplicacoes"       AT 1
         "financeiras, realizadas por"                               AT 53
         SKIP                                                       
         "meio da"                                                   AT 1  
         aux_nmextcop                             FORMAT "x(71)"     AT 9
         WITH NO-BOX NO-LABELS FRAME f_introducao_1a.

    /* Com a quebra de linha de aux_endereco */
    FORM SKIP(2)
         aux_nmprimtl                             FORMAT "x(69)"     AT 1
         ", com sede"                                                AT 70
         SKIP                                                       
         aux_endereco                             FORMAT "x(80)"     AT 1
         SKIP                                                       
         aux_dsendere                             FORMAT "x(78)"     AT 1
         ","                                                         AT 79
         SKIP                                                       
         "inscrita no C.N.P.J sob o Nr"                              AT 1
         aux_nrcpfcgc                             FORMAT "x(18)"     AT 30
         ", para  fins da  nao retencao do"                          AT 48
         SKIP                                                       
         "Imposto de  Renda  sobre rendimentos de  aplicacoes"       AT 1
         "financeiras, realizadas por"                               AT 53
         SKIP                                                       
         "meio da"                                                   AT 1  
         aux_nmextcop                             FORMAT "x(71)"     AT 9
         WITH NO-BOX NO-LABELS FRAME f_introducao_1b.               
                                                                    
    FORM SKIP(1)                                                    
         "a) Que  esta enquadrada  no Artigo 150,"                   AT 1
         'Inciso  VI, Alinea  "b" da Constituicao'                   AT 41
         SKIP                                                       
         "Federal (templos de qualquer culto) e"                     AT 1
         "no  Artigo  168 do  RIR/99, aprovado pelo"                 AT 39
         SKIP                                                       
         "decreto Nr 3000, de 26.03.1999, e,"                        AT 1
         "portanto, imune ao referido imposto;"                      AT 36
         SKIP(1)                                                    
         "b) Que o signatario e o representante"                     AT 1
         "legal desta entidade, assumindo o compro-"                 AT 39
         SKIP                                                       
         "misso de informar a esta Cooperativa"                      AT 1
         "de Credito, imediatamente,"                                AT 38
         "eventual desen-"                                           AT 65
         SKIP                                                       
         "quadramento da presente situacao;"                         AT 1
         SKIP(1)                                                    
         "c) Que esta ciente de que a dispensa de"                   AT 1
         "retencao do Imposto de Renda na Fonte e"                   AT 41
         SKIP                                                       
         "restrita as  aplicacoes  financeiras"                      AT 1
         "realizadas para  as finalidades"                           AT 38
         "essenciais"                                                AT 70
         SKIP                                                       
         "desta  entidade e que a falsidade  na"                     AT 1
         "prestacao destas informacoes o sujeitara,"                 AT 39
         SKIP                                                       
         "juntamente com as demais pessoas que para"                 AT 1
         "ela  concorrerem, as penalidades pre-"                     AT 43
         SKIP                                                       
         "vistas na  legislacao criminal e"                          AT 1
         "tributaria, relativas a  falsidade"                        AT 35
         "ideologica"                                                AT 70
         SKIP                                                       
         "(art. 299 do Codigo Penal) e ao crime"                     AT 1
         "contra a ordem tributaria (art. 1o da Lei"                 AT 39
         SKIP                                                       
         "Nr 8.137, de 27 de dezembro de 1990)."                     AT 1
         WITH NO-BOX NO-LABELS FRAME f_clausula.                    
                                                                    
    /** Pagina 2 **/                                                
    FORM SKIP(2)                                                    
         "DECLARACAO - Imunidade IOF sobre"                          AT 15
         "operacoes de credito"                                      AT 48
         SKIP(2)                                                    
         "Templos de Qualquer Culto"                                 AT 28
         WITH NO-BOX NO-LABELS FRAME f_cabecalho2.

    /* Sem a quebra de linha de aux_endereco */
    FORM SKIP(2)
         aux_nmprimtl                              FORMAT "x(69)"    AT 1
         ", com sede"                                                AT 70
         SKIP                                                        
         aux_endereco                              FORMAT "x(78)"    AT 1
         ","                                                         AT 79
         SKIP                                                        
         "inscrita no C.N.P.J sob o Nr"                              AT 1
         aux_nrcpfcgc                              FORMAT "x(18)"    AT 30
         ", para fins da Nao Incidencia do"                          AT 48
         SKIP                                                        
         "Imposto sobre Operacoes de Credito (IOF),"                 AT 1
         "de que trata o inciso III do pargrafo"                     AT 43
         SKIP
         "3o do  art. 2o do  Decreto Nr 6.306,"                      AT 1
         "de  14 de  dezembro de  2007, declara  que"                AT 38
         SKIP                                                        
         "e Templo de Qualquer Culto e que:"                         AT 1
         WITH NO-BOX NO-LABELS FRAME f_introducao_2a.                
                                                                     
    /* Com a quebra de linha de aux_endereco */                      
    FORM SKIP(2)                                                     
         aux_nmprimtl                              FORMAT "x(69)"    AT 1
         ", com sede"                                                AT 70
         SKIP                                                        
         aux_endereco                              FORMAT "x(80)"    AT 1
         SKIP                                                        
         aux_dsendere                              FORMAT "x(78)"    AT 1
         ","                                                         AT 79
         SKIP                                                        
         "inscrita no C.N.P.J sob o Nr"                              AT 1
         aux_nrcpfcgc                              FORMAT "x(18)"    AT 30
         ", para fins da Nao Incidencia do"                          AT 48
         SKIP                                                        
         "Imposto sobre Operacoes de Credito (IOF),"                 AT 1
         "de que trata o inciso III do pargrafo"                     AT 43
         SKIP
         "3o do  art. 2o do  Decreto Nr 6.306,"                      AT 1
         "de  14 de  dezembro de  2007, declara  que"                AT 38
         SKIP                                                        
         "e Templo de Qualquer Culto e que:"                         AT 1
         WITH NO-BOX NO-LABELS FRAME f_introducao_2b.                
                                                                     
    FORM SKIP(1)                                                     
         "a) Que  esta enquadrada  no Artigo 150,"                   AT 1
         'Inciso  VI, Alinea  "b" da Constituicao'                   AT 41
         SKIP                                                        
         "Federal (templos de qualquer culto) e"                     AT 1
         "no  Artigo  168 do  RIR/99, aprovado pelo"                 AT 39
         SKIP                                                        
         "decreto Nr 3000, de 26.03.1999, e,"                        AT 1
         "portanto, imune ao referido imposto;"                      AT 36
         SKIP(1)                                                     
         "b) Que o signatario e o representante"                     AT 1
         "legal desta entidade, assumindo o compro-"                 AT 39
         SKIP                                                        
         "misso de informar a esta Cooperativa"                      AT 1
         "de Credito, imediatamente,"                                AT 38
         "eventual desen-"                                           AT 65
         SKIP                                                        
         "quadramento da presente situacao;"                         AT 1
         SKIP(1)                                                     
         "c) Que esta  ciente de que  a dispensa do"                 AT 1
         "IOF e restrita  sobre  operacoes  de"                      AT 44
         SKIP                                                        
         "credito realizadas para as finalidades"                    AT 1
         "essenciais desta entidade e que a falsi-"                  AT 40
         SKIP                                                        
         "dade na  prestacao  destas informacoes"                    AT 1
         "o sujeitara, juntamente  com as  demais"                   AT 41
         SKIP                                                        
         "pessoas que  para ela  concorrerem, as"                    AT 1
         "penalidades previstas na legislacao cri-"                  AT 40
         SKIP                                                        
         "minal e tributaria, relativas a falsidade"                 AT 1
         "ideologica (art. 299 do Codigo Penal)"                     AT 43
         SKIP                                                        
         "e  ao crime  contra a  ordem  tributaria"                  AT 1
         "(art.  1o da  Lei Nr  8.137, de  27 de"                    AT 42
         SKIP                                                     
         "dezembro  de  1990)."                                      AT 1
         WITH NO-BOX NO-LABELS FRAME f_clausula2.
    
    /* Todas as Paginas */
    FORM SKIP(1)
         "Declaro-me ciente de que este documento"                   AT 1
         "sera submetido a analise da cooperativa"                   AT 41
         SKIP                                                        
         "para fins de verificacao de enquadramento"                 AT 1
         "juridico tributario."                                      AT 43
         SKIP(3)                                                     
         "_______________________________"                           AT 1
         SKIP                                                        
         "Local e data"                                              AT 1
         SKIP(2)                                                     
         "_______________________________"                           AT 1
         SKIP                                                        
         "Assinatura do Representante Legal"                         AT 1
         SKIP
         aux_nmprimtl                              FORMAT "x(50)"    AT 1
         "/"                                                         AT 51
         aux_nrcpfcgc                              FORMAT "x(18)"    AT 53
         SKIP(1)
         WITH NO-BOX NO-LABELS FRAME f_assinatura.
    
    IF  par_nrcpfcgc = 0 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Informe o numero do CNPJ".
    
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        RETURN "NOK".
    END.

    /* Busca dados do associado */
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                         AND crapass.nrcpfcgc = par_nrcpfcgc
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN 
        DO:
           ASSIGN aux_cdcritic = 9.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
        END.

    IF  crapass.inpessoa <> 2 THEN DO:  /* Pessoa Juridica */
        ASSIGN aux_cdcritic = 331.
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    ASSIGN aux_nmprimtl = TRIM(crapass.nmprimtl)
           aux_nrcpfcgc = TRIM(STRING(STRING(par_nrcpfcgc,"99999999999999"),
                          "xx.xxx.xxx/xxxx-xx")).

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.

    IF  AVAIL crapcop THEN
        
        ASSIGN aux_nmextcop = TRIM(crapcop.nmextcop) + ", declara:"
               aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/" + crapcop.dsdircop + "_termo1_" +
                              STRING(TIME)
               ret_nmarqimp = aux_nmarquiv + ".lst"
               aux_nmarqpdf = aux_nmarquiv + ".ex".

    ELSE DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Descricao da Coop. " +
                              "Nao Localizada.".
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    
    /* Busca endereco completo do associado */
    FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper
                         AND crapenc.nrdconta = crapass.nrdconta
                         NO-LOCK NO-ERROR.

    IF  AVAIL crapenc THEN DO:

        IF  crapenc.complend = "" THEN  DO: /* Nao tem Complemento */
            /* Monta de forma simples para nao precisar de 2 linhas */
            ASSIGN aux_endereco = "na "  + TRIM(crapenc.dsendere) 
                                + " Nr " + TRIM(STRING(crapenc.nrendere))
                                + " - "  + TRIM(crapenc.nmbairro)
                                + " - "  + TRIM(crapenc.nmcidade)
                                + "/"    + TRIM(crapenc.cdufende).

            /* Verifica se endereco completo coube em 1 linha */
            IF  LENGTH(aux_endereco) > 79 THEN DO:
    
                /* Se nao coube, tenta ocupar o maior parte da linha 1 */
                ASSIGN aux_endereco = ""
                       aux_endereco = "na "         + TRIM(crapenc.dsendere) 
                                    + " Nr " + TRIM(STRING(crapenc.nrendere))
                                    + " - Bairro  " + TRIM(crapenc.nmbairro)
                                    + " - Cidade de "
                       aux_dsendere = TRIM(crapenc.nmcidade)
                                    + "/"           + TRIM(crapenc.cdufende).
    
                /* Verifica se a 1 linha ainda esta passando do limite */
                IF  LENGTH(aux_endereco) > 79 THEN
    
                    /* faz a quebra em 2 linhas para ajustar */
                    ASSIGN aux_endereco = ""
                           aux_endereco = "na "        + TRIM(crapenc.dsendere) 
                                        + " Nr " + TRIM(STRING(crapenc.nrendere))
                                        + " - Bairro " + TRIM(crapenc.nmbairro)
                           aux_dsendere = "Cidade "    + TRIM(crapenc.nmcidade)
                                        + "/"          + TRIM(crapenc.cdufende).
            END.
        END.
        ELSE DO:
             /* Monta de forma simples para nao precisar de 2 linhas */
             ASSIGN aux_endereco = "na "   + TRIM(crapenc.dsendere) 
                                 + " Nr " + TRIM(STRING(crapenc.nrendere))
                                 + " - "  + TRIM(crapenc.complend)
                                 + " - "  + TRIM(crapenc.nmbairro)
                                 + " - "  + TRIM(crapenc.nmcidade)
                                 + "/"    + TRIM(crapenc.cdufende).

             /* Verifica se endereco completo coube em 1 linha */
             IF  LENGTH(aux_endereco) > 79 THEN DO:
    
                 /* Se nao coube, tenta ocupar o maior parte da linha 1 */
                 ASSIGN aux_endereco = ""
                        aux_endereco = "na "        + TRIM(crapenc.dsendere) 
                                     + " Nr " + TRIM(STRING(crapenc.nrendere))
                                     + " - "        + TRIM(crapenc.complend)
                                     + " - Bairro " + TRIM(crapenc.nmbairro) 
                        aux_dsendere = "Cidade "    + TRIM(crapenc.nmcidade)
                                     + "/"          + TRIM(crapenc.cdufende).
    
                 /* Verifica se a 1 linha ainda esta passando do limite */
                 IF  LENGTH(aux_endereco) > 79 THEN
    
                     /* faz a quebra em 2 linhas para ajustar */
                     ASSIGN aux_endereco = ""
                            aux_endereco = "na "        + TRIM(crapenc.dsendere) 
                                         + " Nr " + TRIM(STRING(crapenc.nrendere))
                                         + " - Bairro " + TRIM(crapenc.nmbairro)
                            aux_dsendere = " - "        + TRIM(crapenc.complend)
                                         + " - Cidade " + TRIM(crapenc.nmcidade)
                                         + "/"          + TRIM(crapenc.cdufende).
            END.
        END.
    END.
    ELSE DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Endereco do Associado " +
                              "Nao foi Localizado.".
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".

    END.

    OUTPUT STREAM str_1 TO VALUE (ret_nmarqimp) PAGED PAGE-SIZE 64.

    IF  par_idorigem = 5 OR par_cdopcimp = "I" THEN DO:
        /** Configura a impressora para 1/6" **/
        PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.
    END.

    VIEW STREAM str_1 FRAME f_cabecalho.
    
    /* Se o endereco do associado estiver completo*/
    IF  aux_dsendere <> "" THEN 
        
        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                             aux_dsendere
                             aux_nmextcop
                WITH FRAME f_introducao_1b.

    ELSE        
        DISPLAY STREAM str_1 aux_nmprimtl 
                             aux_nrcpfcgc
                             aux_endereco
                             aux_nmextcop
                WITH FRAME f_introducao_1a.

    /* Exibe os demais FORM da pagina 1 */
    VIEW STREAM str_1 FRAME f_clausula.
    DISPLAY STREAM str_1 aux_nmprimtl
                         aux_nrcpfcgc           
              WITH FRAME f_assinatura.

    PAGE STREAM str_1.

    IF  par_idorigem = 5 OR par_cdopcimp = "I" THEN DO:
       /** Configura a impressora para 1/6" **/
       PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.
    END.

    VIEW STREAM str_1 FRAME f_cabecalho2.

    /* Se o endereco do associado estiver completo*/
    IF  aux_dsendere <> "" THEN
        
        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                             aux_dsendere
                WITH FRAME f_introducao_2b.

    ELSE        
        DISPLAY STREAM str_1 aux_nmprimtl 
                             aux_nrcpfcgc
                             aux_endereco
                WITH FRAME f_introducao_2a.
    
    /* Exibe os demais FORM da pagina 2 */
    VIEW STREAM str_1 FRAME f_clausula2.  
    DISPLAY STREAM str_1 aux_nmprimtl
                         aux_nrcpfcgc           
              WITH FRAME f_assinatura.
    
    OUTPUT STREAM str_1 CLOSE.
    
    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarqimp + " " + aux_nmarqpdf +
                          " 2> /dev/null").
    
        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.
    
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO " +
                                     "b1wgen0024.".
      
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
    
               RETURN "NOK".
            END.
            
        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT aux_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).
    
        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.
    
        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE trata-impressao-modelo2:

    /* Rotina para tratamento da impressao declaracao de Imunidade IRRF
    sobre rendimento de aplicacoes Financeiras e IOF sobre operacoes de
    credito - Chamada: tela CONTAS_IMUNIDADE */

    DEF  INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                         NO-UNDO.
    DEF  INPUT PARAM par_cddentid AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdopcimp AS CHAR                         NO-UNDO.

    DEF OUTPUT PARAM ret_nmarqimp AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR FORMAT "x(69)"                   NO-UNDO.
    DEF VAR aux_dsendere AS CHAR FORMAT "x(79)"                   NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(18)"                   NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR FORMAT "x(79)"                   NO-UNDO.
    DEF VAR aux_endereco AS CHAR FORMAT "x(75)"                   NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    
    /** Pagina 1 **/
    FORM SKIP(2)
         "DECLARACAO – Imunidade IRRF sobre"                      AT 5
         "rendimentos de aplicacoes Financeiras"                  AT 39
         SKIP(2)
         "Partido Politico, Fundacao de Partido Politico"         AT 19 
         "ou Entidade Sindical de Trabalhadores"                  AT 24
         WITH NO-BOX NO-LABELS FRAME f_cabecalho1.

    /* Sem a quebra de linha de aux_endereco */
    FORM SKIP(2)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da  nao  retencao do"                       AT 48
         SKIP
         "Imposto  de  Renda sobre  rendimentos  de"              AT 1
         "aplicacoes  financeiras , realizadas"                   AT 44
         SKIP
         "atraves da"                                             AT 1
         aux_nmextcop                             FORMAT "x(68)"  AT 12
         WITH NO-BOX NO-LABELS FRAME f_introducao_1a.

    /* Com a quebra de linha de aux_endereco */
    FORM SKIP(2)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(80)" AT 1
         SKIP
         aux_dsendere                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da  nao  retencao do"                       AT 48
         SKIP
         "Imposto  de  Renda sobre  rendimentos  de"              AT 1
         "aplicacoes  financeiras , realizadas"                   AT 44
         SKIP
         "atraves da"                                             AT 1
         aux_nmextcop                             FORMAT "x(68)"  AT 12
         WITH NO-BOX NO-LABELS FRAME f_introducao_1b.

    FORM SKIP(1)                                                  
         "a) que e"                                               AT 1
         SKIP
         "(  ) Partido Politico"                                  AT 1
         SKIP
         "(  ) Fundacao de Partido Politico"                      AT 1
         SKIP
         "(  ) Entidade Sindical de Trabalhadores"                AT 1
         SKIP(1)                                                  
         "b) Que o  signatario e  o  representante"               AT 1
         "legal  desta  entidade,  assumindo  o"                  AT 43
         SKIP                                                     
         "compromisso de informar a  esta Cooperativa"            AT 1
         "de Credito, imediatamente, eventual"                    AT 45
         SKIP                                                     
         "desenquadramento da presente situacao;"                 AT 1
         SKIP(1)                                                  
         "c) Que esta ciente de que a dispensa de retencao do"    AT 1
         "Imposto de Renda na Fonte e"                            AT 53
         SKIP                                                     
         "restrita as aplicacoes  financeiras realizadas"         AT 1
         "para as  finalidades essenciais"                        AT 49
         SKIP                                                     
         "desta entidade e  que a  falsidade na prestacao"        AT 1
         "destas informacoes o sujeitara,"                        AT 49
         SKIP                                                     
         "juntamente  com  as  demais pessoas  que para  ela"     AT 1
         "concorrerem, as penalidades"                            AT 53
         SKIP                                                     
         "previstas na legislacao criminal e tributaria"          AT 1
         ", relativas a falsidade ideologica"                     AT 46
         SKIP                                                     
         "(art. 299 do Codigo Penal) e ao crime contra a"         AT 1
         "ordem tributaria (art. 1o da Lei"                       AT 48
         SKIP                                                     
         "Nr 8.137, de 27 de dezembro de 1990)."                  AT 1
         WITH NO-BOX NO-LABELS FRAME f_clausula1.

    /** Pagina 2 **/
    FORM SKIP(2)
         "DECLARACAO – Imunidade IOF sobre operacoes de credito"  AT 15
         SKIP(2)
         "Partido Politico, Fundacao de Partido Politico"         AT 19 
         "ou Entidade Sindical de Trabalhadores"                  AT 24
         WITH NO-BOX NO-LABELS FRAME f_cabecalho2.

    /* Sem a quebra de linha de aux_endereco */
    FORM SKIP(2)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da Nao Incidencia do"                       AT 48
         SKIP
         "Imposto sobre Operacoes de Credito (IOF),"                 AT 1
         "de que trata o inciso III do pargrafo"                     AT 43
         SKIP
         "3o do  art. 2o do  Decreto Nr 6.306,"                      AT 1
         "de  14 de  dezembro de  2007, declara:"                    AT 38
         WITH NO-BOX NO-LABELS FRAME f_introducao_2a.

    /* Com a quebra de linha de aux_endereco */
    FORM SKIP(2)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(80)" AT 1
         SKIP
         aux_dsendere                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da Nao Incidencia do"                       AT 48
         SKIP
         "Imposto sobre Operacoes de Credito (IOF),"              AT 1
         "de que trata o inciso III do pargrafo"                  AT 43
         SKIP
         "3o do  art. 2o do  Decreto Nr 6.306,"                   AT 1
         "de  14 de  dezembro de  2007, declara:"                 AT 38
         WITH NO-BOX NO-LABELS FRAME f_introducao_2b.
                                                                  
    FORM SKIP(1)                                                  
         "a) que e"                                               AT 1
         SKIP
         "(  ) Partido Politico"                                  AT 1
         SKIP
         "(  ) Fundacao de Partido Politico"                      AT 1
         SKIP
         "(  ) Entidade Sindical de Trabalhadores"                AT 1
         SKIP(1)                                                  
         "b) Que o  signatario e o representante"                 AT 1
         "legal  desta  entidade,  assumindo  o"                  AT 43
         SKIP                                                     
         "compromisso de informar a  esta Cooperativa"            AT 1
         "de Credito, imediatamente, eventual"                    AT 45
         SKIP                                                     
         "desenquadramento da presente situacao;"                 AT 1
         SKIP(1)                                                  
         "c) Que esta  ciente  de que  a dispensa  do"            AT 1
         "IOF e  restrita sobre operacoes de"                     AT 46
         SKIP                                                     
         "credito realizadas para as finalidades"                 AT 1
         "essenciais desta entidade e que a falsi-"               AT 40
         SKIP                                                     
         "dade na prestacao  destas  informacoes"                 AT 1
         "o  sujeitara, juntamente  com  as demais"               AT 40
         SKIP                                                     
         "pessoas  que  para  ela  concorrerem, as"               AT 1
         "penalidades  previstas na  legislacao"                  AT 43
         SKIP                                                     
         "criminal  e  tributaria, relativas a  falsidade"        AT 1
         "ideologica (art. 299 do Codigo"                         AT 50
         SKIP                                                     
         "Penal) e ao crime contra a ordem tributaria"            AT 1
         "(art. 1o da Lei  Nr 8.137, de 27 de"                    AT 45
         SKIP                                                     
         "dezembro de 1990)."                                     AT 1
         WITH NO-BOX NO-LABELS FRAME f_clausula2.
    
    /* Todas as Paginas */
    FORM SKIP(1)
         "Declaro-me ciente de que este documento"                AT 1
         "sera submetido a analise da cooperativa"                AT 41
         SKIP                                                     
         "para fins de verificacao de enquadramento"              AT 1
         "juridico tributario."                                   AT 43
         SKIP(3)                                                  
         "_______________________________"                        AT 1
         SKIP                                                     
         "Local e data"                                           AT 1
         SKIP(2)                                                  
         "_______________________________"                        AT 1
         SKIP                                                     
         "Assinatura do Representante Legal"                      AT 1
         SKIP
         aux_nmprimtl                           FORMAT "x(50)"    AT 1
         "/"                                                      AT 51
         aux_nrcpfcgc                           FORMAT "x(18)"    AT 53
         SKIP(1)
         WITH NO-BOX NO-LABELS FRAME f_assinatura.

    IF  par_nrcpfcgc = 0 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Informe o numero do CNPJ".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    /* Busca dados do associado */
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                         AND crapass.nrcpfcgc = par_nrcpfcgc
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN 
        DO:
           ASSIGN aux_cdcritic = 9.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
        END.

    IF  crapass.inpessoa <> 2 THEN DO:  /* Pessoa Juridica */
        ASSIGN aux_cdcritic = 331.

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    ASSIGN aux_nmprimtl = TRIM(crapass.nmprimtl)
           aux_nrcpfcgc = TRIM(STRING(STRING(par_nrcpfcgc,"99999999999999"),
                          "xx.xxx.xxx/xxxx-xx")).

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.

    IF  AVAIL crapcop THEN 
           
        ASSIGN aux_nmextcop = TRIM(crapcop.nmextcop) + ", declara:"
               aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/" + crapcop.dsdircop + "_termo2_" +
                              STRING(TIME)
               ret_nmarqimp = aux_nmarquiv + ".lst"
               aux_nmarqpdf = aux_nmarquiv + ".ex".

    ELSE DO:
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "Descricao da Coop. " +
                               "Nao Localizada.".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
    END.

    /* Busca endereco completo do associado */
    FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper
                         AND crapenc.nrdconta = crapass.nrdconta
                         NO-LOCK NO-ERROR.

    IF  AVAIL crapenc THEN DO:

        IF  crapenc.complend = "" THEN  DO: /* Nao tem Complemento */
            /* Monta de forma simples para nao precisar de 2 linhas */
            ASSIGN aux_endereco = "na "  + TRIM(crapenc.dsendere) 
                                + " Nr " + TRIM(STRING(crapenc.nrendere))
                                + " - "  + TRIM(crapenc.nmbairro)
                                + " - "  + TRIM(crapenc.nmcidade)
                                + "/"    + TRIM(crapenc.cdufende).

            /* Verifica se endereco completo coube em 1 linha */
            IF  LENGTH(aux_endereco) > 79 THEN DO:

                /* Se nao coube, tenta ocupar o maior parte da linha 1 */
                ASSIGN aux_endereco = ""
                       aux_endereco = "na "         + TRIM(crapenc.dsendere) 
                                    + " Nr " + TRIM(STRING(crapenc.nrendere))
                                    + " - Bairro  " + TRIM(crapenc.nmbairro)
                                    + " - Cidade de "
                       aux_dsendere = TRIM(crapenc.nmcidade)
                                    + "/"           + TRIM(crapenc.cdufende).

                /* Verifica se a 1 linha ainda esta passando do limite */
                IF  LENGTH(aux_endereco) > 79 THEN

                    /* faz a quebra em 2 linhas para ajustar */
                    ASSIGN aux_endereco = ""
                           aux_endereco = "na "        + TRIM(crapenc.dsendere) 
                                        + " Nr " + TRIM(STRING(crapenc.nrendere))
                                        + " - Bairro " + TRIM(crapenc.nmbairro)
                           aux_dsendere = "Cidade "    + TRIM(crapenc.nmcidade)
                                        + "/"          + TRIM(crapenc.cdufende).
            END.
        END.
        ELSE DO:
             /* Monta de forma simples para nao precisar de 2 linhas */
             ASSIGN aux_endereco = "na "  + TRIM(crapenc.dsendere) 
                                 + " Nr " + TRIM(STRING(crapenc.nrendere))
                                 + " - "  + TRIM(crapenc.complend)
                                 + " - "  + TRIM(crapenc.nmbairro)
                                 + " - "  + TRIM(crapenc.nmcidade)
                                 + "/"    + TRIM(crapenc.cdufende).

             /* Verifica se endereco completo coube em 1 linha */
             IF  LENGTH(aux_endereco) > 79 THEN DO:

                 /* Se nao coube, tenta ocupar o maior parte da linha 1 */
                 ASSIGN aux_endereco = ""
                        aux_endereco = "na "        + TRIM(crapenc.dsendere) 
                                     + " Nr " + TRIM(STRING(crapenc.nrendere))
                                     + " - "        + TRIM(crapenc.complend)
                                     + " - Bairro " + TRIM(crapenc.nmbairro) 
                        aux_dsendere = "Cidade "    + TRIM(crapenc.nmcidade)
                                     + "/"          + TRIM(crapenc.cdufende).

                 /* Verifica se a 1 linha ainda esta passando do limite */
                 IF  LENGTH(aux_endereco) > 79 THEN

                     /* faz a quebra em 2 linhas para ajustar */
                     ASSIGN aux_endereco = ""
                            aux_endereco = "na "        + TRIM(crapenc.dsendere) 
                                         + " Nr " + TRIM(STRING(crapenc.nrendere))
                                         + " - Bairro " + TRIM(crapenc.nmbairro)
                            aux_dsendere = " - "        + TRIM(crapenc.complend)
                                         + " - Cidade " + TRIM(crapenc.nmcidade)
                                         + "/"          + TRIM(crapenc.cdufende).
            END.
        END.
    END.
    ELSE DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Endereco do Associado " +
                              "Nao foi Localizado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".

    END.
    
    OUTPUT STREAM str_1 TO VALUE (ret_nmarqimp) PAGED PAGE-SIZE 82.

    IF  par_idorigem = 5 OR par_cdopcimp = "I" THEN DO:
        /** Configura a impressora para 1/6" **/
        PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.
    END.

    VIEW STREAM str_1 FRAME f_cabecalho1.
    
    /* Se o endereco do associado estiver completo*/
    IF  aux_dsendere <> "" THEN 
        
        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                             aux_dsendere
                             aux_nmextcop
                WITH FRAME f_introducao_1b.

    ELSE        
        DISPLAY STREAM str_1 aux_nmprimtl 
                             aux_nrcpfcgc
                             aux_endereco
                             aux_nmextcop
                WITH FRAME f_introducao_1a.

    /* Exibe os demais FORM da pagina 1 */
    VIEW STREAM str_1 FRAME f_clausula1.
    DISPLAY STREAM str_1 aux_nmprimtl
                         aux_nrcpfcgc           
              WITH FRAME f_assinatura.

    PAGE STREAM str_1.

    IF  par_idorigem = 5 OR par_cdopcimp = "I" THEN DO:
        /** Configura a impressora para 1/6" **/
        PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.
    END.

    VIEW STREAM str_1 FRAME f_cabecalho2.

    /* Se o endereco do associado estiver completo*/
    IF  aux_dsendere <> "" THEN 
        
        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                             aux_dsendere
                WITH FRAME f_introducao_2b.

    ELSE        
        DISPLAY STREAM str_1 aux_nmprimtl 
                             aux_nrcpfcgc
                             aux_endereco
                WITH FRAME f_introducao_2a.
    
    /* Exibe os demais FORM da pagina 2 */
    VIEW STREAM str_1 FRAME f_clausula2.  
    DISPLAY STREAM str_1 aux_nmprimtl
                         aux_nrcpfcgc           
              WITH FRAME f_assinatura.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarqimp + " " + aux_nmarqpdf +
                          " 2> /dev/null").
    
    
        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.
    
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0024.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
    
                RETURN "NOK".
            END.
            
        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT aux_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).
    
        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.
        
        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE trata-impressao-modelo3:

    /* Rotina para tratamento da impressao DECLARAÇÃO – Imunidade IRRF sobre
    rendimentos de aplicações Financeiras Inst. Educação e Inst.
    Assist. Social sem Fins Lucrativos*/

    DEF  INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                         NO-UNDO.
    DEF  INPUT PARAM par_cddentid AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdopcimp AS CHAR                         NO-UNDO.

    DEF OUTPUT PARAM ret_nmarqimp AS CHAR                         NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR FORMAT "x(69)"                   NO-UNDO.
    DEF VAR aux_dsendere AS CHAR FORMAT "x(79)"                   NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(18)"                   NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR FORMAT "x(79)"                   NO-UNDO.
    DEF VAR aux_endereco AS CHAR FORMAT "x(75)"                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /** Pagina 1 **/
    FORM SKIP(1)
         "DECLARACAO – Imunidade IRRF sobre"                      AT 5
         "rendimentos de aplicacoes Financeiras"                  AT 39
         SKIP(1)
         "Inst. Educacao e Inst. Assist. Social"                  AT 12
         "sem Fins Lucrativos"                                    AT 50
         WITH NO-BOX NO-LABELS FRAME f_cabecalho1.

    /* Sem a quebra de linha de aux_endereco */
    FORM SKIP(1)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da  nao  retencao do"                       AT 48
         SKIP
         "Imposto de Renda  sobre rendimentos de"                 AT 1
         "aplicacoes  financeiras, realizadas por"                AT 41
         SKIP
         "meio da"                                                AT 1
         aux_nmextcop                             FORMAT "x(68)"  AT 9
         WITH NO-BOX NO-LABELS FRAME f_introducao_1a.

    /* Com a quebra de linha de aux_endereco */
    FORM SKIP(1)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(80)" AT 1
         SKIP
         aux_dsendere                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da  nao  retencao do"                       AT 48
         SKIP
         "Imposto de Renda  sobre rendimentos de"                 AT 1
         "aplicacoes  financeiras, realizadas por"                AT 41
         SKIP
         "meio da"                                                AT 1
         aux_nmextcop                             FORMAT "x(68)"  AT 9
         WITH NO-BOX NO-LABELS FRAME f_introducao_1b.

    FORM SKIP(1)
         "a) que e:"                                              AT 1
         SKIP
         "(  ) Instituicao de Educacao sem fins lucrativos"       AT 1
         SKIP
         "(  ) Instituicao de Assistencia Social sem"             AT 1
         "fins lucrativos."                                       AT 44
         SKIP(1)
         "b) que  preenche  os  requisitos  do"                   AT 1
         "art. 14  do  Codigo Tributario  Nacional,"              AT 39
         SKIP
         "quais sejam:"                                            AT 1
         SKIP(1)
         "I-   nao distribui qualquer  parcela de seu"            AT 5
         "patrimonio  ou  de suas rendas,"                        AT 49
         SKIP
         "a titulo de lucro ou participacao no seu resultado;"    AT 10
         SKIP
         "II-  aplica integralmente no Pais os  seus recursos,"   AT 5
         "na  manutencao de seus"                                 AT 58
         SKIP
         "objetivos institucionais;"                              AT 10
         SKIP
         "III- mantem  escrituracao de suas receitas e despesas"  AT 5
         "em livros revestidos"                                   AT 60
         SKIP
         "de formalidades capazes de assegurar sua exatidao."     AT 10
         SKIP(1)
         "c) que atende aos requisitos  do  art. 12, e"           AT 1
         'seus paragrafos 2o letras "a", "d",'                    AT 45
         SKIP
         '"e", "g" e "h" e 3o da  Lei n.9.532, de 10'             AT 1
         "de dezembro de 1.997, a saber:"                         AT 44
         SKIP(1)
         "I-   não  remunera, por  qualquer  forma, seus"         AT 5
         "dirigentes  pelos  serviços"                            AT 53
         SKIP
         "prestados;"                                             AT 10
         SKIP
         "II-  presta os  servicos  para  os quais houver"        AT 5
         "sido instituida e os coloca"                            AT 53
         SKIP
         "a  disposicao  da  populacao  em  geral,"               AT 10
         "em carater  complementar  as"                           AT 52
         SKIP
         "atividades do Estado, sem fins lucrativos;"             AT 10
         SKIP
         "III- conserva em boa ordem, pelo prazo de cinco"        AT 5
         "anos, contados  da  data da"                            AT 53
         SKIP
         "emissao, os  documentos que  comprovem a origem"        AT 10
         "de suas  receitas e a"                                  AT 59
         SKIP
         "efetivacao de  suas  despesas, bem  assim  a"           AT 10
         "realizacao  de quaisquer"                               AT 56
         SKIP
         "outros atos  ou operacoes  que venham a modificar"      AT 10
         "sua situacao patri-"                                    AT 61
         SKIP
         "monial;"                                                AT 10
         SKIP
         "IV-  apresenta, anualmente, Declaracao de Rendimentos," AT 5
         "em  conformidade com"                                   AT 60
         SKIP
         "o disposto em ato da Secretaria da Receita Federal;"    AT 10
         SKIP
         "V-   assegura  a   destinacao  de seu"                  AT 5
         "patrimonio  a outra  instituicao que"                   AT 44
         SKIP
         "atenda as condicoes para  gozo  da imunidade,"          AT 10
         "no caso de incorporacao,"                               AT 56
         SKIP
         "fusao, cisao, ou  de  encerramento "                    AT 10
         "de  suas  atividades, ou  a orgao"                      AT 47
         SKIP
         "publico;"                                               AT 10
         SKIP
         "as condicoes para gozo  da  imunidade, no caso de "     AT 10
         "incorporacao, fusao,"                                   AT 60
         SKIP
         "cisao, ou de encerramento de suas atividades, ou a"     AT 10
         "orgao publico;"                                         AT 61
         SKIP
         "VI-  atende outros requisitos, estabelecidos"            AT 5
         "em lei especifica, relacionados"                        AT 49
         SKIP
         "com o seu funcionamento;"                               AT 10
         SKIP
         "VII-  nao apresenta  superavit em suas  contas ou, caso" AT 5
         "venha  apresentar em"                                   AT 60
         SKIP
         "determinado exercicio, destinara  referido  resultado"  AT 10
         "integralmente, a"                                       AT 64
         SKIP
         "manutencao e ao desenvolvimento dos seus"               AT 10
         "objetivos sociais;"                                     AT 51
         SKIP(1)
         "d) que a dispensa de  retencao e restrita as"           AT 1
         "aplicacoes  financeiras realizadas"                     AT 46
         SKIP
         "para atender as finalidades essenciais da entidade;"    AT 1
         SKIP(1)
         "e) que o signatario e  representante legal desta"       AT 1
         "entidade, assumindo o compro-"                          AT 51
         SKIP
         "misso de informar a essa instituicao financeira,"       AT 1
         "imediatamente, eventual desen-"                         AT 50
         SKIP
         "quadramento da  presente situacao e esta ciente de"     AT 1
         "que a falsidade na prestacao"                           AT 52
         SKIP
         "destas informacoes o  sujeitara, juntamente  com  as"   AT 1
         "demais  pessoas  que a ela"                             AT 54
         SKIP
         "concorrerem, as  penalidades  previstas  na legislacao" AT 1
         "criminal  e tributaria,"                                AT 57
         SKIP
         "relativas a falsidade  ideologica (art. 299  do Codigo" AT 1
         "Penal) e ao crime contra"                               AT 56
         SKIP
         "a ordem tributaria (art. 1o da Lei Nr 8.137,"           AT 1
         "de 27 de dezembro de 1990)."                            AT 46
         WITH NO-BOX NO-LABELS FRAME f_clausula1.

    /** Pagina 2 **/
    FORM SKIP(1)
         "DECLARACAO – Imunidade IOF sobre operacoes de credito"  AT 15
         SKIP(1)
         "Inst. Educacao e Inst. Assist. Social"                  AT 12
         "sem Fins Lucrativos"                                    AT 50
         WITH NO-BOX NO-LABELS FRAME f_cabecalho2.

    /* Sem a quebra de linha de aux_endereco */
    FORM SKIP(1)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da Nao Incidencia do"                       AT 48
         SKIP
         "Imposto  sobre  Operacoes  de  Credito (IOF)"           AT 1
         ", de  que  trata  o  inciso  III do"                    AT 45
         SKIP
         "paragrafo  3º  do  art.  2º do  Decreto nº  6.306,"     AT 1
         "de  14 de  dezembro de 2007,"                           AT 52
         SKIP
         "declara:"                                               AT 1
         WITH NO-BOX NO-LABELS FRAME f_introducao_2a.

    /* Com a quebra de linha de aux_endereco */
    FORM SKIP(1)
         aux_nmprimtl                              FORMAT "x(69)" AT 1
         ", com sede"                                             AT 70
         SKIP
         aux_endereco                              FORMAT "x(78)" AT 1
         SKIP
         aux_dsendere                              FORMAT "x(78)" AT 1
         ","                                                      AT 79
         SKIP
         "inscrita no C.N.P.J sob o Nr"                           AT 1
         aux_nrcpfcgc                              FORMAT "x(18)" AT 30
         ", para fins da Nao Incidencia do"                       AT 48
         SKIP
         "Imposto  sobre  Operacoes  de  Credito (IOF)"           AT 1
         ", de  que  trata  o  inciso  III do"                    AT 45
         SKIP
         "paragrafo  3º  do  art.  2º do  Decreto nº  6.306,"     AT 1
         "de  14 de  dezembro de 2007,"                           AT 52
         SKIP
         "declara:"                                               AT 1
         WITH NO-BOX NO-LABELS FRAME f_introducao_2b.

    FORM SKIP(1)
         "a) que e:"                                              AT 1
         SKIP
         "(  ) Instituicao de Educacao sem fins lucrativos"       AT 1
         SKIP
         "(  ) Instituicao de Assistencia Social sem"             AT 1
         "fins lucrativos."                                       AT 44
         SKIP(1)
         "b) que  preenche  os  requisitos  do"                   AT 1
         "art. 14  do Codigo  Tributario  Nacional,"              AT 39
         SKIP
         "quais sejam:"                                           AT 1
         SKIP(1)
         "I-   nao distribui qualquer  parcela de seu"            AT 5
         "patrimonio  ou  de suas rendas,"                        AT 49
         SKIP
         "a titulo de lucro ou participacao no seu resultado;"    AT 10
         SKIP
         "II-  aplica integralmente no Pais os  seus recursos,"   AT 5
         "na  manutencao de seus"                                 AT 58
         SKIP
         "objetivos institucionais;"                              AT 10
         SKIP
         "III- mantem  escrituracao de suas receitas e despesas"  AT 5
         "em livros revestidos"                                   AT 60
         SKIP
         "de formalidades capazes de assegurar sua exatidao."     AT 10
         SKIP(1)
         "c) que atende aos requisitos do  art. 12, e"            AT 1
         'seus paragrafos 2o letras "a", "d",'                    AT 45
         SKIP
         '"e","g" e "h" e 3o da Lei n.9.532, de 10'               AT 1
         "de dezembro de 1.997, a saber:"                         AT 42
         SKIP(1)
         "I-   não  remunera, por  qualquer  forma, seus"         AT 5
         "dirigentes  pelos  serviços"                            AT 53
         SKIP
         "prestados;"                                             AT 10
         SKIP
         "II-  presta os  servicos para os  quais houver"          AT 5
         "sido  instituida e os coloca"                           AT 52
         SKIP
         "a  disposicao  da  populacao  em  geral,"               AT 10
         "em  carater  complementar  as"                          AT 51
         SKIP
         "atividades do Estado, sem fins lucrativos;"             AT 10
         SKIP
         "III- conserva em  boa ordem, pelo prazo de cinco"        AT 5
         "anos, contados  da  data da"                            AT 53
         SKIP
         "emissao, os  documentos que  comprovem a origem"        AT 10
         "de suas  receitas e a"                                  AT 59
         SKIP
         "efetivacao de  suas  despesas, bem  assim  a"           AT 10
         "realizacao  de quaisquer"                               AT 56
         SKIP
         "outros atos  ou operacoes  que venham a modificar"      AT 10
         "sua situacao patri-"                                    AT 61
         SKIP
         "monial;"                                                AT 10
         SKIP
         "IV - apresenta, anualmente, Declaracao de Rendimentos," AT 5
         "em  conformidade com"                                   AT 60
         SKIP
         "o disposto em ato da Secretaria da Receita Federal;"    AT 10
         SKIP
         "V-   assegura  a   destinacao  de seu"                  AT 5
         "patrimonio  a outra  instituicao que"                   AT 44
         SKIP
         "atenda as condicoes para  gozo  da imunidade,"          AT 10
         "no caso de incorporacao,"                               AT 56
         SKIP
         "fusao, cisao, ou  de  encerramento "                    AT 10
         "de  suas  atividades, ou  a orgao"                      AT 47
         SKIP
         "publico;"                                               AT 10
         SKIP
         "VI-  atende outros requisitos, estabelecidos"           AT 5
         "em lei especifica, relacionados"                        AT 49
         SKIP
         "com o seu funcionamento;"                               AT 10
         SKIP
         "VII- nao apresenta  superavit  em suas  contas ou, caso" AT 5
         "venha  apresentar em"                                   AT 60
         SKIP
         "determinado exercicio, destinara  referido  resultado"  AT 10
         "integralmente, a"                                       AT 64
         SKIP
         "manutencao e ao desenvolvimento dos seus"               AT 10
         "objetivos sociais;"                                     AT 51
         SKIP(1)
         "d) Que esta  ciente  de que a  dispensa  do IOF"        AT 1
         "e restrita sobre  operacoes de"                         AT 50
         SKIP
         "credito realizadas para as finalidades"                 AT 1
         "essenciais desta entidade."                             AT 40
         SKIP(1)
         "e) que o signatario e  representante legal desta"       AT 1
         "entidade, assumindo o compro-"                          AT 51
         SKIP
         "misso de informar a essa instituicao financeira,"       AT 1
         "imediatamente, eventual desen-"                         AT 50
         SKIP
         "quadramento da  presente situacao e esta ciente de"     AT 1
         "que a falsidade na prestacao"                           AT 52
         SKIP
         "destas informacoes o  sujeitara, juntamente  com  as"   AT 1
         "demais  pessoas  que a ela"                             AT 54
         SKIP
         "concorrerem, as  penalidades  previstas  na legislacao" AT 1
         "criminal  e tributaria,"                                AT 57
         SKIP
         "relativas a falsidade  ideologica (art. 299  do Codigo" AT 1
         "Penal) e ao crime contra"                               AT 56
         SKIP
         "a ordem tributaria (art. 1o da Lei Nr 8.137,"           AT 1
         "de 27 de dezembro de 1990)."                            AT 46
         WITH NO-BOX NO-LABELS FRAME f_clausula2.

    /* Todas as Paginas */
    FORM SKIP(1)
         "Declaro-me ciente de que este documento"                AT 1
         "sera submetido a analise da cooperativa"                AT 41
         SKIP
         "para fins de verificacao de enquadramento"              AT 1
         "juridico tributario."                                   AT 43
         SKIP(2)
         "_______________________________"                        AT 1
         SKIP
         "Local e data"                                           AT 1
         SKIP(2)
         "_______________________________"                        AT 1
         SKIP
         "Assinatura do Representante Legal"                      AT 1
         SKIP
         aux_nmprimtl                           FORMAT "x(50)"    AT 1
         "/"                                                      AT 51
         aux_nrcpfcgc                           FORMAT "x(18)"    AT 53
         WITH NO-BOX NO-LABELS FRAME f_assinatura.

    IF  par_nrcpfcgc = 0 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Informe o numero do CNPJ".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    /* Busca dados do associado */
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrcpfcgc = par_nrcpfcgc
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
           ASSIGN aux_cdcritic = 9.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
        END.

    IF  crapass.inpessoa <> 2 THEN DO:  /* Pessoa Juridica */
        ASSIGN aux_cdcritic = 331.

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    ASSIGN aux_nmprimtl = TRIM(crapass.nmprimtl)
           aux_nrcpfcgc = TRIM(STRING(STRING(par_nrcpfcgc,"99999999999999"),
                          "xx.xxx.xxx/xxxx-xx")).

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.

    IF  AVAIL crapcop THEN 
        
        ASSIGN aux_nmextcop = TRIM(crapcop.nmextcop) + ", declara:"

               aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/" + crapcop.dsdircop + "_termo3_" +
                              STRING(TIME)
               ret_nmarqimp = aux_nmarquiv + ".lst"
               aux_nmarqpdf = aux_nmarquiv + ".ex".

    ELSE DO:
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "Descricao da Coop. " +
                               "Nao Localizada.".

         RUN gera_erro (INPUT par_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         RETURN "NOK".
    END.

    /* Busca endereco completo do associado */
    FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper
                         AND crapenc.nrdconta = crapass.nrdconta
                         NO-LOCK NO-ERROR.

    IF  AVAIL crapenc THEN DO:

        IF  crapenc.complend = "" THEN  DO: /* Nao tem Complemento */
            /* Monta de forma simples para nao precisar de 2 linhas */
            ASSIGN aux_endereco = "na "  + TRIM(crapenc.dsendere)
                                + " Nr " + TRIM(STRING(crapenc.nrendere))
                                + " - "  + TRIM(crapenc.nmbairro)
                                + " - "  + TRIM(crapenc.nmcidade)
                                + "/"    + TRIM(crapenc.cdufende).

            /* Verifica se endereco completo coube em 1 linha */
            IF  LENGTH(aux_endereco) > 79 THEN DO:

                /* Se nao coube, tenta ocupar o maior parte da linha 1 */
                ASSIGN aux_endereco = ""
                       aux_endereco = "na "         + TRIM(crapenc.dsendere)
                                    + " Nr " + TRIM(STRING(crapenc.nrendere))
                                    + " - Bairro  " + TRIM
                    (crapenc.nmbairro)
                                    + " - Cidade de "
                       aux_dsendere = TRIM(crapenc.nmcidade)
                                    + "/"           + TRIM(crapenc.cdufende).

                /* Verifica se a 1 linha ainda esta passando do limite */
                IF  LENGTH(aux_endereco) > 79 THEN

                    /* faz a quebra em 2 linhas para ajustar */
                    ASSIGN aux_endereco = ""
                           aux_endereco = "na "        + TRIM(crapenc.dsendere)
                                        + " Nr " + TRIM(STRING(crapenc.nrendere))
                                        + " - Bairro " + TRIM(crapenc.nmbairro)
                           aux_dsendere = "Cidade "    + TRIM(crapenc.nmcidade)
                                        + "/"          + TRIM(crapenc.cdufende).
            END.
        END.
        ELSE DO:
             /* Monta de forma simples para nao precisar de 2 linhas */
             ASSIGN aux_endereco = "na "  + TRIM(crapenc.dsendere)
                                 + " Nr " + TRIM(STRING(crapenc.nrendere))
                                 + " - "  + TRIM(crapenc.complend)
                                 + " - "  + TRIM(crapenc.nmbairro)
                                 + " - "  + TRIM(crapenc.nmcidade)
                                 + "/"    + TRIM(crapenc.cdufende).

             /* Verifica se endereco completo coube em 1 linha */
             IF  LENGTH(aux_endereco) > 79 THEN DO:

                 /* Se nao coube, tenta ocupar o maior parte da linha 1 */
                 ASSIGN aux_endereco = ""
                        aux_endereco = "na "        + TRIM(crapenc.dsendere)
                                     + " Nr " + TRIM(STRING(crapenc.nrendere))
                                     + " - "        + TRIM(crapenc.complend)
                                     + " - Bairro " + TRIM(crapenc.nmbairro)
                        aux_dsendere = "Cidade "    + TRIM(crapenc.nmcidade)
                                     + "/"          + TRIM(crapenc.cdufende).

                 /* Verifica se a 1 linha ainda esta passando do limite */
                 IF  LENGTH(aux_endereco) > 79 THEN

                     /* faz a quebra em 2 linhas para ajustar */
                     ASSIGN aux_endereco = ""
                            aux_endereco = "na "        + TRIM(crapenc.dsendere)
                                         + " Nr " + TRIM(STRING(crapenc.nrendere))
                                         + " - Bairro " + TRIM(crapenc.nmbairro)
                            aux_dsendere = " - "        + TRIM(crapenc.complend)
                                         + " - Cidade " + TRIM(crapenc.nmcidade)
                                         + "/"          + TRIM(crapenc.cdufende).
            END.
        END.
    END.
    ELSE DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Endereco do Associado " +
                              "Nao foi Localizado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".

    END.

    OUTPUT STREAM str_1 TO VALUE (ret_nmarqimp) PAGED PAGE-SIZE 82.

    IF  par_idorigem = 5 OR par_cdopcimp = "I" THEN DO:
        /** Configura a impressora para 1/6" **/
        PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.
    END.

    VIEW STREAM str_1 FRAME f_cabecalho1.

    /* Se o endereco do associado estiver completo*/
    IF  aux_dsendere <> "" THEN

        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                             aux_dsendere
                             aux_nmextcop
                WITH FRAME f_introducao_1b.

    ELSE
        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                             aux_nmextcop
                WITH FRAME f_introducao_1a.

    /* Exibe os demais FORM da pagina 1 */
    VIEW STREAM str_1 FRAME f_clausula1.
    DISPLAY STREAM str_1 aux_nmprimtl
                         aux_nrcpfcgc           
              WITH FRAME f_assinatura.

    PAGE STREAM str_1.

    IF  par_idorigem = 5 OR par_cdopcimp = "I" THEN DO:
        /** Configura a impressora para 1/6" **/
        PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.
    END.

    VIEW STREAM str_1 FRAME f_cabecalho2.

    /* Se o endereco do associado estiver completo*/
    IF  aux_dsendere <> "" THEN

        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                             aux_dsendere
                  WITH FRAME f_introducao_2b.

    ELSE
        DISPLAY STREAM str_1 aux_nmprimtl
                             aux_nrcpfcgc
                             aux_endereco
                WITH FRAME f_introducao_2a.

    /* Exibe os demais FORM da pagina 2 */
    VIEW STREAM str_1 FRAME f_clausula2.
    DISPLAY STREAM str_1 aux_nmprimtl
                         aux_nrcpfcgc           
              WITH FRAME f_assinatura.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarqimp + " " + aux_nmarqpdf +
                          " 2> /dev/null").
    
    
        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.
    
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0024.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
    
                RETURN "NOK".
            END.
    
        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT aux_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).
    
        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.
    
        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

    END.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_impressao.
    
    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_tprelimt AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtrefini AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtreffim AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdsitcad AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
                                                                   
    DEF OUTPUT PARAM ret_nmarquiv AS CHAR FORMAT "X(30)"               NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR FORMAT "X(30)"               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
                                                                   
    EMPTY TEMP-TABLE tt-erro.
    
    IF  par_dtrefini = ? THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe data de inicio".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    IF  par_dtreffim = ? THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe data de termino".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.


    /* Tipos de Relatorios */
    IF  par_tprelimt = 1 THEN /* Razao social */ 

        RUN gera_impressao_razao ( INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtrefini,
                                   INPUT par_dtreffim,
                                   INPUT par_cdsitcad,
                                   INPUT par_idorigem,
                                   OUTPUT ret_nmarquiv,
                                   OUTPUT ret_nmarqpdf,
                                   OUTPUT TABLE tt-erro).
    ELSE /* Contas Associado */

        RUN gera_impressao_contas ( INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtrefini,
                                    INPUT par_dtreffim,
                                    INPUT par_cdsitcad,
                                    INPUT par_idorigem,
                                   OUTPUT ret_nmarquiv,
                                   OUTPUT ret_nmarqpdf,
                                   OUTPUT TABLE tt-erro).

   IF  RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
   
   RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_impressao_razao.
    
    DEF  INPUT PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtrefini AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtreffim AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdsitcad AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
                                                                   
    DEF OUTPUT PARAM ret_nmarquiv AS CHAR FORMAT "X(30)"               NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR FORMAT "X(30)"               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
                                                                   
    DEF VAR aux_nmdircop AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdoperad AS CHAR   FORMAT "X(24)"                      NO-UNDO.
    DEF VAR aux_dsregdat AS CHAR                                       NO-UNDO.
    DEF VAR aux_dtregdat AS DATE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    

    IF  par_dtrefini = ? THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe data de inicio".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    IF  par_dtreffim = ? THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe data de termino".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.
   
    IF  AVAIL crapcop THEN
        ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/"
               ret_nmarquiv = aux_nmdircop + "crrl666_" + 
                              STRING(RANDOM(1,999999999)) + ".lst"
               ret_nmarqpdf = aux_nmdircop + "crrl666_" + 
                              STRING(RANDOM(1,999999999)) + ".ex".
        
    RUN consulta-impressao-relat(INPUT par_cdcooper,
                                 INPUT par_dtrefini,
                                 INPUT par_dtreffim,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-imunidade,
                                 OUTPUT TABLE tt-contas-ass).
    
    OUTPUT STREAM str_1 TO VALUE(ret_nmarquiv) PAGED PAGE-SIZE 62.

    /* Cdempres = 11 , Relatorio 666 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "666" "132" }

    EMPTY TEMP-TABLE tt-totalizador-entid.

    FIND FIRST tt-imunidade 
         WHERE (tt-imunidade.cdsitcad  = par_cdsitcad   OR
                         par_cdsitcad  = 9)
       NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-imunidade THEN DO:

        PUT STREAM str_1
           SKIP(5)
           "NENHUM REGISTRO ENCONTRADO !" FORMAT "X(29)" AT 60
           SKIP(5)
           "PARAMETROS INFORMADOS:"       FORMAT "X(22)" AT 9
           SKIP(1)
           "COOPERATIVA:"                 FORMAT "X(12)" AT 19  
           STRING(par_cdcooper)           FORMAT "X(2)"  AT 32
           SKIP
           "DATA INICIO:"                 FORMAT "X(12)" AT 19
           STRING(par_dtrefini)           FORMAT "X(8)"  AT 32
           SKIP                        
           "DATA FIM:"                    FORMAT "X(9)"  AT 22
           STRING(par_dtreffim)           FORMAT "X(8)"  AT 32
           SKIP                        
           "SITUACAO:"                    FORMAT "X(9)"  AT 22
           STRING(par_cdsitcad)           FORMAT "X(10)" AT 32.

    END.
    ELSE DO:
    
        PUT STREAM str_1
            "PERIODO:"    FORMAT "X(8)" AT 1
            par_dtrefini                AT 10
            "ATE"         FORMAT "X(3)" AT 19
            par_dtreffim                AT 23.
        
        FOR EACH tt-imunidade NO-LOCK
           WHERE (tt-imunidade.cdsitcad  = par_cdsitcad   OR
                           par_cdsitcad  = 9)
           BREAK BY tt-imunidade.cdsitcad
                 BY tt-imunidade.cddentid
                 BY tt-imunidade.dtcadast:
                   
            FIND FIRST tt-contas-ass 
                 WHERE tt-contas-ass.nrcpfcgc = tt-imunidade.nrcpfcgc
                    NO-LOCK NO-ERROR.
    
            ASSIGN aux_nrcpfcgc = STRING(STRING(tt-contas-ass.nrcpfcgc,
                                    "99999999999999"),"xx.xxx.xxx/xxxx-xx")
                   aux_dsregdat = ""
                   aux_dtregdat = ?.
    
            IF  tt-imunidade.cdsitcad = 1 THEN DO:
                ASSIGN aux_dtregdat = tt-imunidade.dtdaprov
                       aux_dsregdat = "DT APROVAC".
            END.
            ELSE
            IF  tt-imunidade.cdsitcad = 2 THEN DO:
                ASSIGN aux_dtregdat = tt-imunidade.dtdaprov
                       aux_dsregdat = "DT ATUALIZ".
            END.
            ELSE
            IF  tt-imunidade.cdsitcad = 3 THEN DO:
                ASSIGN aux_dtregdat = tt-imunidade.dtcancel
                       aux_dsregdat = "DT  CANCEL".
            END.
            ELSE DO:
                ASSIGN aux_dtregdat = tt-imunidade.dtcadast
                       aux_dsregdat = "DT CADASTR".
            END.
            
            IF FIRST-OF(tt-imunidade.cdsitcad) THEN DO:
            
               PUT STREAM str_1
                   SKIP(2)
                   "SITUACAO:"             FORMAT "X(9)"    AT 1
                   tt-imunidade.cdsitcad   FORMAT "9"       AT 11
                   "-"                                      AT 13   
                   tt-imunidade.dssitcad   FORMAT "X(20)"   AT 15
                   SKIP(1)
                   "RAZAO SOCIAL"          FORMAT "X(12)"  AT 5
                   aux_dsregdat            FORMAT "X(10)"  AT 65
                   "ENTIDADE"              FORMAT "X(8)"   AT 77
                   "OPERADOR"              FORMAT "X(8)"   AT 87.
                   
               IF  tt-imunidade.cdsitcad = 2 THEN
                   PUT STREAM str_1
                           "MOTIVO NAO APROVACAO" FORMAT "X(20)" AT 112.
            END.
    
           FIND FIRST crapope WHERE crapope.cdcooper = tt-imunidade.cdcooper
                                AND crapope.cdoperad = tt-imunidade.cdopecad
                                NO-LOCK NO-ERROR.
    
           IF AVAIL crapope THEN
              ASSIGN aux_cdoperad = TRIM(crapope.cdoperad) + " - " + 
                                    TRIM(crapope.nmoperad).
           ELSE
              ASSIGN aux_cdoperad = TRIM(tt-imunidade.cdopecad) + " - " +
                                    "OPE. NAO ENCONT".
    
           PUT STREAM str_1
               aux_nrcpfcgc            FORMAT "X(18)"      AT 5
               tt-contas-ass.nmprimtl  FORMAT "X(40)"      AT 24
               aux_dtregdat            FORMAT "99/99/99"   AT 67
               tt-imunidade.cddentid   FORMAT "9"          AT 77.

    
           IF  tt-imunidade.cdsitcad = 2 THEN DO:
               PUT STREAM str_1
                   aux_cdoperad           FORMAT "X(24)"   AT 87
                   tt-imunidade.dscancel  FORMAT "X(24)"   AT 112
                   SKIP.
           END.
           ELSE DO:
               PUT STREAM str_1
                   aux_cdoperad           FORMAT "X(24)"   AT 87
                   SKIP.
           END.

           /* Alimenta Totalizador por Entidade */
           FOR FIRST tt-totalizador-entid WHERE tt-totalizador-entid.cddentid = INTE(tt-imunidade.cddentid) NO-LOCK.
           END.

           IF  NOT AVAIL tt-totalizador-entid THEN
               DO:
                   CREATE tt-totalizador-entid.
                   ASSIGN tt-totalizador-entid.cddentid = tt-imunidade.cddentid
                          tt-totalizador-entid.totentid = 1.
               END.
           ELSE 
               ASSIGN tt-totalizador-entid.totentid = tt-totalizador-entid.totentid + 1.
        END.
    END.   

    /* Totalizador por Entidade  */
    PUT STREAM str_1 SKIP(2).

    FOR EACH tt-totalizador-entid NO-LOCK BREAK BY tt-totalizador-entid.cddentid:

        IF  FIRST-OF(tt-totalizador-entid.cddentid) THEN
            DO:
                PUT STREAM str_1 ("TOTAL ENTIDADE " + STRING(tt-totalizador-entid.cddentid) + ": ") AT 01 FORMAT "x(18)".
                PUT STREAM str_1 STRING(tt-totalizador-entid.totentid, "zz9") AT 20.
                PUT STREAM str_1 SKIP.
            END.
    END.
    
    PUT STREAM str_1
            SKIP(3)
            "Codigos da Entidade:"                   FORMAT "X(28)"  AT 1
            SKIP(1)
            "1 - Templo de qualquer culto"           FORMAT "X(28)"  AT 1
            SKIP
            "2 - Partido Politico, fundacao de "     FORMAT "X(34)"  AT 1
            "Partido Politico"                       FORMAT "X(16)"  AT 35
            SKIP
            "3 - Entidade Sindical de Trabalhadores" FORMAT "X(38)"  AT 1
            SKIP
            "4 - Instituicao de Educacao s/ fins "   FORMAT "X(36)"  AT 1
            "lucrativos"                             FORMAT "X(10)"  AT 37
            SKIP
            "5 - Instituicao de Assistencia Social " FORMAT "X(38)"  AT 1
            "s/ fins lucrativos"                     FORMAT "X(18)"  AT 39
            SKIP.

    
    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarquiv + " " + ret_nmarqpdf +
                          " 2> /dev/null").
    
        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.
    
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO " +
                                     "b1wgen0024.".
      
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
    
               RETURN "NOK".
            END.
            
        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT ret_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).

       
        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.
    
        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

    END.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_impressao_contas.
    
    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtrefini AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtreffim AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdsitcad AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
                                                                   
    DEF OUTPUT PARAM ret_nmarquiv AS CHAR FORMAT "X(30)"               NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR FORMAT "X(30)"               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
                                                                   
    DEF VAR aux_nmdircop AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdoperad AS CHAR   FORMAT "X(24)"                      NO-UNDO.
    DEF VAR aux_dsregdat AS CHAR                                       NO-UNDO.
    DEF VAR aux_dtregdat AS DATE                                       NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    IF  par_dtrefini = ? THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe data de Inicio".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    IF  par_dtreffim = ? THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Informe data de Termino".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    ASSIGN aux_contador = 0.

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.
   
    IF  AVAIL crapcop THEN
        ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/"
               ret_nmarquiv = aux_nmdircop + "crrl665_" + 
                              STRING(RANDOM(1,999999999)) + ".lst"
               ret_nmarqpdf = aux_nmdircop + "crrl665_" + 
                              STRING(RANDOM(1,999999999)) + ".ex".
        
    RUN consulta-impressao-relat(INPUT par_cdcooper,
                                 INPUT par_dtrefini,
                                 INPUT par_dtreffim,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-imunidade,
                                 OUTPUT TABLE tt-contas-ass).

    OUTPUT STREAM str_1 TO VALUE(ret_nmarquiv) PAGED PAGE-SIZE 62.

    /* Cdempres = 11 , Relatorio 665 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "665" "132" }

    EMPTY TEMP-TABLE tt-totalizador-entid.

    PUT STREAM str_1
        "PERIODO:"    FORMAT "X(8)" AT 1
        par_dtrefini                AT 10
        "ATE"         FORMAT "X(3)" AT 19
        par_dtreffim                AT 23
        SKIP(2).

    FOR EACH  tt-imunidade NO-LOCK
       WHERE (tt-imunidade.cdsitcad  = par_cdsitcad   OR
                       par_cdsitcad  = 9),
        EACH  tt-contas-ass 
       WHERE ((tt-contas-ass.nrcpfcgc = tt-imunidade.nrcpfcgc AND
               tt-contas-ass.cdagenci = par_cdagenci)          OR
              (tt-contas-ass.nrcpfcgc = tt-imunidade.nrcpfcgc AND
                         par_cdagenci = 0))
       BREAK BY tt-contas-ass.nrcpfcgc
                BY tt-contas-ass.cdagenci
                   BY tt-contas-ass.nrdconta:
        
        ASSIGN aux_contador = aux_contador + 1.

        IF  aux_contador = 1 THEN
            PUT STREAM str_1
                "PA:"        FORMAT "X(3)"    AT 1
                "CONTA/DV"   FORMAT "X(8)"    AT 8
                "NOME"       FORMAT "X(4)"    AT 17
                "CNPJ"       FORMAT "X(4)"    AT 49
                "ENTIDADE"   FORMAT "X(8)"    AT 67
                "SITUACAO"   FORMAT "X(8)"    AT 76
                "DT.CADAST." FORMAT "X(10)"   AT 87
                "DT.APROV."  FORMAT "X(9)"    AT 98
                "DT.CANCEL"  FORMAT "X(9)"    AT 108
                "OPERADOR"   FORMAT "X(8)"    AT 118
                SKIP.

        /* Configura CNPJ */

        ASSIGN aux_nrcpfcgc = STRING(STRING(tt-contas-ass.nrcpfcgc,
                                "99999999999999"),"xx.xxx.xxx/xxxx-xx")
               aux_dsregdat = ""
               aux_dtregdat = ?.

        /* Verifica Operador */
        FIND FIRST crapope WHERE crapope.cdcooper = tt-imunidade.cdcooper
                             AND crapope.cdoperad = tt-imunidade.cdopecad
                         NO-LOCK NO-ERROR.

        IF AVAIL crapope THEN
           ASSIGN aux_cdoperad = /*TRIM(crapope.cdoperad) + " - " + */
                                 TRIM(crapope.nmoperad).
        ELSE
           ASSIGN aux_cdoperad = /*TRIM(tt-imunidade.cdopecad) + " - " +*/
                                 "OPE. NAO ENCONT".

        PUT STREAM str_1
            SKIP
            tt-contas-ass.cdagenci FORMAT "999"         AT   1
            tt-contas-ass.nrdconta FORMAT "zzzz,zzz,9"  AT   6
            tt-contas-ass.nmprimtl FORMAT "X(30)"       AT  17
            aux_nrcpfcgc           FORMAT "X(18)"       AT  49
            STRING(tt-imunidade.cddentid) FORMAT "X(1)" AT  74
            tt-imunidade.dssitcad  FORMAT "X(9)"        AT  76
            tt-imunidade.dtcadast  FORMAT "99/99/99"    AT  87
            tt-imunidade.dtdaprov  FORMAT "99/99/99"    AT  98
            tt-imunidade.dtcancel  FORMAT "99/99/99"    AT 108
            aux_cdoperad           FORMAT "X(14)"       AT 118
            SKIP.

        /* Alimenta Totalizador por Entidade */
        FOR FIRST tt-totalizador-entid WHERE tt-totalizador-entid.cddentid = INTE(tt-imunidade.cddentid) NO-LOCK.
        END.
        
        IF  NOT AVAIL tt-totalizador-entid THEN
            DO:
               CREATE tt-totalizador-entid.
               ASSIGN tt-totalizador-entid.cddentid = tt-imunidade.cddentid
                      tt-totalizador-entid.totentid = 1.
            END.
        ELSE 
            ASSIGN tt-totalizador-entid.totentid = tt-totalizador-entid.totentid + 1.

    END.
        
    IF aux_contador = 0 THEN
       PUT STREAM str_1
           SKIP(5)
           "NENHUM REGISTRO ENCONTRADO !" FORMAT "X(29)" AT 60
           SKIP(5)
           "PARAMETROS INFORMADOS:"       FORMAT "X(22)" AT 9
           SKIP(1)
           "COOPERATIVA:"                 FORMAT "X(12)" AT 19  
           STRING(par_cdcooper)           FORMAT "X(2)"  AT 32
           SKIP
           "PA:"                          FORMAT "X(3)"  AT 28  
           STRING(par_cdagenci)           FORMAT "X(3)"  AT 32
           SKIP
           "DATA INICIO:"                 FORMAT "X(12)" AT 19
           STRING(par_dtrefini)           FORMAT "X(8)"  AT 32
           SKIP                        
           "DATA FIM:"                    FORMAT "X(9)"  AT 22
           STRING(par_dtreffim)           FORMAT "X(8)"  AT 32
           SKIP                        
           "SITUACAO:"                    FORMAT "X(9)"  AT 22
           STRING(par_cdsitcad)           FORMAT "X(10)" AT 32.

    ELSE
        DO:
            /* Totalizador por Entidade  */
            PUT STREAM str_1 SKIP(2).
        
            FOR EACH tt-totalizador-entid NO-LOCK BREAK BY tt-totalizador-entid.cddentid:
        
                IF  FIRST-OF(tt-totalizador-entid.cddentid) THEN
                    DO:
                        PUT STREAM str_1 ("TOTAL ENTIDADE " + STRING(tt-totalizador-entid.cddentid) + ": ") AT 01 FORMAT "x(18)".
                        PUT STREAM str_1 STRING(tt-totalizador-entid.totentid, "zz9") AT 20.
                        PUT STREAM str_1 SKIP.
                    END.
            END.

            /* Help do Relatorio */
            PUT STREAM str_1
                SKIP(4)
                "Codigos da Entidade:"                   FORMAT "X(28)"  AT 1
                SKIP(1)
                "1 - Templo de qualquer culto"           FORMAT "X(28)"  AT 1
                SKIP
                "2 - Partido Politico, fundacao de "     FORMAT "X(34)"  AT 1
                "Partido Politico"                       FORMAT "X(16)"  AT 35
                SKIP
                "3 - Entidade Sindical de Trabalhadores" FORMAT "X(38)"  AT 1
                SKIP
                "4 - Instituicao de Educacao s/ fins "   FORMAT "X(36)"  AT 1
                "lucrativos"                             FORMAT "X(10)"  AT 37
                SKIP
                "5 - Instituicao de Assistencia Social " FORMAT "X(38)"  AT 1
                "s/ fins lucrativos"                     FORMAT "X(18)"  AT 39
                SKIP.
        END.
    
    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarquiv + " " + ret_nmarqpdf +
                          " 2> /dev/null").
    
        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.
    
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO " +
                                     "b1wgen0024.".
      
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
    
               RETURN "NOK".
            END.
            
        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT ret_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).

       
        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.
    
        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

    END.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE consulta-impressao-relat:

   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_dtrefini AS DATE                               NO-UNDO.
   DEF  INPUT PARAM par_dtreffim AS DATE                               NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR tt-imunidade.
   DEF OUTPUT PARAM TABLE FOR tt-contas-ass.
   
   DEF VAR aux_dssitcad AS CHAR                                        NO-UNDO.
   DEF VAR aux_dsdentid AS CHAR                                        NO-UNDO.
   DEF VAR aux_nmoperad AS CHAR                                        NO-UNDO.
   
   EMPTY TEMP-TABLE tt-erro.
   EMPTY TEMP-TABLE tt-imunidade.
   EMPTY TEMP-TABLE tt-contas-ass.

   FOR EACH crapimt
      WHERE crapimt.cdcooper = par_cdcooper
        AND ( (crapimt.dtcadast >= par_dtrefini
        AND    crapimt.dtcadast <= par_dtreffim)
         OR   (crapimt.dtdaprov >= par_dtrefini
        AND    crapimt.dtdaprov <= par_dtreffim)
         OR   (crapimt.dtcancel >= par_dtrefini
        AND    crapimt.dtcancel <= par_dtreffim))
    NO-LOCK:
        
       CASE crapimt.cdsitcad:

            WHEN 0 THEN DO:
                 aux_dssitcad = "Pendente".

                 FIND FIRST crapope 
                      WHERE crapope.cdcooper = par_cdcooper
                        AND crapope.cdoperad = crapimt.cdopecad
                        NO-LOCK NO-ERROR. 

                 IF AVAIL crapope THEN
                     aux_nmoperad = crapope.nmoperad.
                 ELSE
                     aux_nmoperad = "OPERADOR NAO ENCONTRADO".

            END.
            WHEN 1 THEN DO:

                 aux_dssitcad = "Aprovado".

                 FIND FIRST crapope
                              WHERE crapope.cdcooper = par_cdcooper
                                AND crapope.cdoperad = crapimt.cdopeapr
                                NO-LOCK NO-ERROR. 

                 IF AVAIL crapope THEN
                    aux_nmoperad = crapope.nmoperad.
                 ELSE
                    aux_nmoperad = "OPERADOR NAO ENCONTRADO".

            END.

            WHEN 2 THEN DO:
                 aux_dssitcad = "Nao Aprovado".

                 FIND FIRST crapope
                      WHERE crapope.cdcooper = par_cdcooper
                        AND crapope.cdoperad = crapimt.cdopecad
                        NO-LOCK NO-ERROR. 

                 IF AVAIL crapope THEN
                    aux_nmoperad = crapope.nmoperad.
                 ELSE
                    aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.

            WHEN 3 THEN DO:
                 aux_dssitcad = "Cancelado".

                 FIND FIRST crapope
                              WHERE crapope.cdcooper = par_cdcooper
                                AND crapope.cdoperad = crapimt.cdopeapr
                                NO-LOCK NO-ERROR. 

                 IF AVAIL crapope THEN
                    aux_nmoperad = crapope.nmoperad.
                 ELSE
                    aux_nmoperad = "OPERADOR NAO ENCONTRADO".
            END.

        END CASE.

        CASE crapimt.cddentid:
             WHEN 1 THEN
                 aux_dsdentid = "Templo de qualquer culto".
             WHEN 2 THEN
                 aux_dsdentid = "Partido Politico, fundacao de " +
                                "Partido Politico".
             WHEN 3 THEN
                 aux_dsdentid = "Entidade Sindical de Trabalhadores".
             WHEN 4 THEN
                 aux_dsdentid = "Instituicao de Educacao s/ fins " +
                                "lucrativos".
             WHEN 5 THEN
                 aux_dsdentid = "Instituicao de Assistencia Social " +
                                "s/ fins lucrativos".
        END CASE.

        CREATE tt-imunidade.
        BUFFER-COPY crapimt TO tt-imunidade.
        ASSIGN tt-imunidade.dssitcad = aux_dssitcad
               tt-imunidade.dsdentid = aux_dsdentid
               tt-imunidade.nmoperad = aux_nmoperad.


        FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper 
                           AND crapass.nrcpfcgc = crapimt.nrcpfcgc
                           NO-LOCK:

            CREATE tt-contas-ass.
            BUFFER-COPY crapass TO tt-contas-ass.

        END.
        
    END. /* fim do for each crapimt */

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
