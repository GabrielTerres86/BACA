/* .............................................................................

   Programa: Fontes/tab089.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano/CECRED 
   Data    : Abril/2011                          Ultima alteracao: 05/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : TAB089 - Parametros Op. Taxas Pre-fixadas
   
   Alteracao : 02/08/2011 - Incluido o campo "Prazo máximo para liberação do 
                            empréstimo" e ajustado log (Adriano).
                            
               30/11/2012 - Retirar campo de Prazo de tolerancia para 
                            incidencia de juros de mora (Gabriel).
                            
               05/08/2015 - Adicionado parametro "Valor maximo de estorno 
                            permitido sem autorizacao da coordenacao/gerencia"
                            e alterado label da coluna do prazo maximo de 
                            estorno. (Reinert)
                                                                 
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)             
                                                                 
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cdagenci AS INT                                    NO-UNDO.
DEF        VAR tel_prtlmult AS INT FORMAT "999"                       NO-UNDO.
DEF        VAR tel_prestorn AS INT FORMAT "999"                       NO-UNDO.
DEF        VAR tel_vlempres AS DEC FORMAT "999999999.99"              NO-UNDO.  
DEF        VAR tel_pzmaxepr AS INT FORMAT "9999"                      NO-UNDO.
DEF        VAR tel_vlmaxest AS DEC FORMAT "999999999.99"              NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                     NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                   NO-UNDO.

DEF        VAR aux_contador AS INT                                    NO-UNDO.

DEF        VAR tel_prpropos AS CHAR FORMAT "x(8)"
               VIEW-AS COMBO-BOX LIST-ITEMS "DTLIBERA",
                                            "DTVENPAR"
                                            PFCOLOR 2                NO-UNDO.

DEF        VAR log_prtlmult AS INT FORMAT "999"                       NO-UNDO.
DEF        VAR log_prtljuro AS INT FORMAT "999"                       NO-UNDO.
DEF        VAR log_prestorn AS INT FORMAT "999"                       NO-UNDO.
DEF        VAR log_prpropos AS CHAR FORMAT "x(8)"                     NO-UNDO.
DEF        VAR log_vlempres AS DEC  FORMAT "999999999.99"             NO-UNDO. 
DEF        VAR log_pzmaxepr AS INT  FORMAT "9999"                     NO-UNDO.
DEF        VAR log_vlmaxest AS DEC  FORMAT "999999999.99"             NO-UNDO.

FORM WITH ROW 4 COLUMN 1 OVERLAY TITLE glb_tldatela SIZE 80 BY 18 
     FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT 10 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                           HELP "Entre com a opcao desejada (A,C)."
                           VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(2)
     tel_prtlmult AT 03 
          LABEL "Prazo de tolerancia para incidencia de multa e juros de mora"
          HELP "Informe a tolerancia para multa."
          VALIDATE(tel_prtlmult <> '' ,"357 - O campo deve ser prenchido.")
    SKIP(1)
     tel_prestorn LABEL "Prazo maximo para estorno de contratos com alienacao/hipoteca de imoveis"
         HELP "Informe o prazo para estorno."
         VALIDATE (tel_prestorn >0 AND tel_prestorn <=30  ,"Permitido no maximo 30 dias.") 
     SKIP(1)
     tel_prpropos AT 18 AUTO-RETURN LABEL "Prazo maximo de validade da proposta"      
        HELP "Informe o prazo da proposta."
     SKIP(1)
     tel_vlempres AT 14 LABEL "Valor minimo para cobranca de emprestimo" 
        HELP "Informe o valor minimo do emprestimo."
     SKIP(1)
     tel_pzmaxepr AT 13 LABEL "Prazo maximo para liberacao do emprestimo"
        HELP "Informe o prazo maximo de liberacao do emprestimo."
     "dias"
     SKIP(1)
     "Valor maximo de estorno permitido sem" AT 17
     SKIP
     tel_vlmaxest LABEL "autorizacao da coordenacao/gerencia" AT 19
     WITH WIDTH 78 CENTERED ROW 5 OVERLAY NO-BOX SIDE-LABELS FRAME f_tab089.


ON RETURN OF tel_prpropos
   DO:
      APPLY "TAB".
   END.


ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_cdprogra = "tab089".
       

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   glb_cdcritic <> 0  THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab089.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "tab089"   THEN
                 DO:
                     HIDE FRAME f_tab089.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF glb_cddopcao = "C" THEN
      DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                            craptab.nmsistem = "CRED"       AND
                            craptab.tptabela = "USUARI"     AND
                            craptab.cdempres = 11           AND
                            craptab.cdacesso = "PAREMPREST" AND
                            craptab.tpregist = 01
                            NO-LOCK NO-ERROR.

         IF AVAIL craptab THEN
            DO:
                ASSIGN tel_prtlmult = INT(SUBSTRING(craptab.dstextab,1,3))
                       tel_prestorn = INT(SUBSTRING(craptab.dstextab,9,3))
                       tel_prpropos:SCREEN-VALUE = SUBSTRING(craptab.dstextab,13,8)
                       tel_vlempres = DEC(SUBSTRING(craptab.dstextab,22,12))
                       tel_pzmaxepr = INT(SUBSTRING(craptab.dstextab,35,4))
                       tel_vlmaxest = DEC(SUBSTRING(craptab.dstextab,40,12)).
                
            END.
         ELSE 
            DO:
               MESSAGE "Informacoes nao encontradas.".
               BELL.
               PAUSE(2) NO-MESSAGE.
               RETURN.
      
            END.
           
         DISP tel_prtlmult
              tel_prestorn
              tel_prpropos 
              tel_vlempres
              tel_pzmaxepr
              tel_vlmaxest
              WITH FRAME f_tab089.

      END.
  ELSE
     IF glb_cddopcao = "A" THEN      
        DO TRANSACTION:

            IF   glb_cddepart <> 20  AND  /* TI             */
                 glb_cddepart <>  9  AND  /* COORD.PRODUTOS */
                 glb_cddepart <> 14  THEN /* PRODUTOS       */
                 DO:
                    glb_cdcritic = 36.
                    NEXT.
                 END.
                
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "PAREMPREST" AND
                               craptab.tpregist = 01           
                               EXCLUSIVE-LOCK NO-ERROR.

            IF AVAIL craptab THEN
               DO:
                  ASSIGN tel_prtlmult = INT(SUBSTRING(craptab.dstextab,1,3))
                         tel_prestorn = INT(SUBSTRING(craptab.dstextab,9,3))
                         tel_prpropos:SCREEN-VALUE = SUBSTRING(craptab.dstextab,13,8)
                         tel_vlempres = DEC(SUBSTRING(craptab.dstextab,22,12))
                         tel_pzmaxepr = INT(SUBSTRING(craptab.dstextab,35,4))
                         tel_vlmaxest = DEC(SUBSTRING(craptab.dstextab,40,12))
                         log_prtlmult = INT(SUBSTRING(craptab.dstextab,1,3))
                         log_prtljuro = INT(SUBSTRING(craptab.dstextab,5,3))
                         log_prestorn = INT(SUBSTRING(craptab.dstextab,9,3))
                         log_prpropos = SUBSTRING(craptab.dstextab,13,8)
                         log_vlempres = DEC(SUBSTRING(craptab.dstextab,22,12))
                         log_pzmaxepr = INT(SUBSTRING(craptab.dstextab,35,4))
                         log_vlmaxest = DEC(SUBSTRING(craptab.dstextab,40,12)).


                  DO ON ENDKEY UNDO, LEAVE:

                      UPDATE tel_prtlmult
                             tel_prestorn 
                             tel_prpropos
                             tel_vlempres 
                             tel_pzmaxepr
                             tel_vlmaxest
                             WITH FRAME f_tab089.
                                     
                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                           NEXT.
                   
                      /* Se nao modificou nada ... NEXT */
                      IF   NOT (tel_prtlmult <> log_prtlmult              OR 
                                tel_prestorn <> log_prestorn              OR
                                tel_prpropos:SCREEN-VALUE <> log_prpropos OR
                                tel_vlempres <> log_vlempres              OR 
                                tel_pzmaxepr <> log_pzmaxepr              OR
                                tel_vlmaxest <> log_vlmaxest)             THEN
                           NEXT.
                      
                      RUN fontes/confirma.p (INPUT "",
                                             OUTPUT aux_confirma).
                   
                      IF   aux_confirma <> "S"   THEN
                           NEXT.
                                             
                      ASSIGN SUBSTRING(craptab.dstextab,1,3)   = STRING(tel_prtlmult,"999")
                             SUBSTRING(craptab.dstextab,9,3)   = STRING(tel_prestorn,"999")
                             SUBSTRING(craptab.dstextab,13,8)  = tel_prpropos:SCREEN-VALUE
                             SUBSTRING(craptab.dstextab,22,12) = STRING(tel_vlempres,"999999999.99")
                             SUBSTRING(craptab.dstextab,35,4)  = STRING(tel_pzmaxepr,"9999")
                             SUBSTRING(craptab.dstextab,40,12) = STRING(tel_vlmaxest,"999999999.99").
                             
                      RUN gera_log (INPUT glb_cddopcao,
                                    INPUT log_prtlmult, 
                                    INPUT log_prtljuro, 
                                    INPUT log_prestorn, 
                                    INPUT log_prpropos, 
                                    INPUT log_vlempres, 
                                    INPUT log_pzmaxepr,
                                    INPUT log_vlmaxest,
                                    INPUT tel_prtlmult, 
                                    INPUT tel_prestorn, 
                                    INPUT tel_prpropos:SCREEN-VALUE, 
                                    INPUT tel_vlempres,
                                    INPUT tel_pzmaxepr,
                                    INPUT tel_vlmaxest).
                                              
                      LEAVE.
                      
                  END.
               END.
            ELSE
               DO:
                  MESSAGE "Informacoes nao encontradas.".
                  BELL.
                  PAUSE(2) NO-MESSAGE.
                  RETURN.

               END.         
        END.

END.  /*  Fim do DO WHILE TRUE  */


/* .......................................................................... */


PROCEDURE gera_log:

    DEF INPUT PARAM par_cddopcao LIKE glb_cddopcao      NO-UNDO.    
    DEF INPUT PARAM par_prtlmult AS INT                 NO-UNDO.    
    DEF INPUT PARAM par_prtljuro AS INT                 NO-UNDO.    
    DEF INPUT PARAM par_prestorn AS INT                 NO-UNDO.    
    DEF INPUT PARAM par_prpropos AS CHAR                NO-UNDO.    
    DEF INPUT PARAM par_vlempres AS DEC                 NO-UNDO. 
    DEF INPUT PARAM par_pzmaxepr AS INT                 NO-UNDO.
    DEF INPUT PARAM par_log_vlmaxest AS DECI            NO-UNDO.    
    DEF INPUT PARAM par_przmulta AS INT                 NO-UNDO.    
    DEF INPUT PARAM par_przestor AS INT                 NO-UNDO.   
    DEF INPUT PARAM par_proposta AS CHAR                NO-UNDO.   
    DEF INPUT PARAM par_vlrdempr AS DEC                 NO-UNDO.
    DEF INPUT PARAM par_pzlibmax AS INT                 NO-UNDO.
    DEF INPUT PARAM par_vlmaxest AS DECI                NO-UNDO.


    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"           +
                      " Operador " + glb_cdoperad + " - " + "Alterou"          +
                      (IF par_prtlmult <> par_przmulta THEN
                          " a tolerancia da multa de " + STRING(par_prtlmult) +
                          " para " + STRING(par_przmulta) 
                       ELSE
                          "") +
                      (IF par_prestorn <> par_przestor THEN
                          " o prazo do estorno de " + STRING(par_prestorn) +
                          " para " + STRING(par_przestor) 
                       ELSE
                          "") +
                      (IF par_prpropos <> par_proposta THEN
                          " a validade da proposta de " + par_prpropos + 
                          " para " + par_proposta 
                       ELSE
                          "") +
                      (IF par_vlempres <> par_vlrdempr THEN
                          " a cobranca do emprestimo de " + STRING(par_vlempres,"999999999.99") +
                          " para " + STRING(par_vlrdempr,"999999999.99")
                       ELSE
                          "") +
                      (IF par_pzmaxepr <> par_pzlibmax THEN
                          " a validade da proposta de " + STRING(par_pzmaxepr) + 
                          " para " + STRING(par_pzlibmax) 
                       ELSE
                          "") +
                      (IF par_vlmaxest <> par_log_vlmaxest THEN
                          " o valor maximo de estorno de " + STRING(par_log_vlmaxest,"999999999.99") + 
                          " para " + STRING(par_vlmaxest,"999999999.99")
                       ELSE
                          "") 
                      + "." + " >> log/tab089.log").

END PROCEDURE.
