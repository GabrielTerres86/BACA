/*..............................................................................

   Programa : Fontes/cadchq.p
   Sistena  : Conta-Corrente -  Cooperativa de Credito
   Sigla    : CRED
   Autor    : Guilherme
   Data     : Dezembro/07.                     Ultima atualizacao: 20/08/2008 

   Dados referentes ao programa:

   Frequencia : Dario (on-line)
   Objetivo   : Mostrar a tela CADCHQ, cadastro folhas de cheque da TRANSPOCRED.
                 
   Alteracoes : 20/08/2008 - Tratar pracas de compensacao (Magui).
..............................................................................*/

{ includes/var_online.i }
        
DEF VAR  tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF VAR  tel_dstitula AS CHAR    FORMAT "x(55)"                NO-UNDO.
DEF VAR  aux_continua AS LOGICAL                               NO-UNDO.

DEF VAR  tel_folhaini AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF VAR  tel_folhafim AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF VAR  tel_qtfolhas AS INT     FORMAT "zzz9"                 NO-UNDO.

DEF VAR  tel_dtentreg AS DATE FORMAT "99/99/9999"              NO-UNDO.

DEF VAR  aux_cddopcao AS CHAR                                  NO-UNDO.
DEF VAR  aux_contador AS INTEGER                               NO-UNDO.
DEF VAR  aux_confirma AS CHAR     FORMAT "!"                   NO-UNDO.

DEF VAR  aux_contaitg AS INT                                   NO-UNDO.
DEF VAR  aux_nrflcheq AS INT                                   NO-UNDO.
DEF VAR  aux_nrultchq AS INT                                   NO-UNDO.
DEF VAR  aux_nrtalchq AS INT                                   NO-UNDO.
DEF VAR  aux_nrdigchq AS INT                                   NO-UNDO.
DEF VAR  aux_dsdocmc7 AS CHAR                                  NO-UNDO.
DEF VAR  aux_primvez  AS LOGICAL                               NO-UNDO.

DEF BUFFER crabfdc FOR crapfdc.

/* caso o digito da ctitg for X a funcao coloca '0' */
FUNCTION f_ver_contaitg RETURN INTEGER(INPUT  par_nrdctitg AS CHAR):
       
    IF   par_nrdctitg = "" THEN
         RETURN 0.
    ELSE
         DO:
             IF   CAN-DO("1,2,3,4,5,6,7,8,9,0",
                         SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                  RETURN INTEGER(STRING(par_nrdctitg,"99999999")).
             ELSE
                  RETURN INTEGER(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                        1,LENGTH(par_nrdctitg) - 1) + "0").
         END.
       
  END. /* FUNCTION */

FORM SKIP(1)
     glb_cddopcao AT 02 
                  LABEL "Opcao" AUTO-RETURN
                  HELP  "Informe a opcao desejada (I)."
                  VALIDATE(glb_cddopcao = "I", "014 - Opcao errada.")
     SKIP(2)                            
     tel_nrdconta AT 05 
                  LABEL "Conta/dv" AUTO-RETURN
                  HELP "Informe o numero da conta."
     tel_dstitula AT 05 
                  LABEL "Nome    "             
     SKIP(1)
     tel_folhaini AT 05
                  LABEL "Folha inicial" AUTO-RETURN
                  HELP "Informe o numero da folha de cheque inicial."
     tel_folhafim AT 05
                  LABEL "Folha final  " AUTO-RETURN
                  HELP "Informe o numero da folha de cheque final."
     tel_qtfolhas AT 5
                  LABEL "Qtde Folhas  "
     SKIP(1)
     tel_dtentreg AT 05
                  LABEL "Data de entrega" AUTO-RETURN
                  HELP "Informe a data de entrega do cheque."
     SKIP(4)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_cadchq.

glb_cddopcao = "I".

RUN fontes/inicia.p.

DO WHILE TRUE:

   ASSIGN tel_nrdconta = 0
          tel_folhaini = 0
          tel_folhafim = 0
          tel_dtentreg = ?
          tel_qtfolhas = 0
          tel_dstitula = "".
           
   DISPLAY tel_nrdconta
           tel_dstitula
           tel_folhaini
           tel_folhafim
           tel_dtentreg
           tel_qtfolhas 
           WITH FRAME f_cadchq.   
           
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE glb_cddopcao WITH FRAME f_cadchq.
      LEAVE.
   END.
   
   IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /*  F4 ou fim  */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS (glb_nmdatela) <> "CADCHQ"   THEN
                 DO:
                     HIDE FRAME f_cadchq.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.     
      
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.
   
   tel_dtentreg = glb_dtmvtolt.     
        
   IF   glb_cddopcao = "I"   THEN
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               aux_continua = FALSE.
               UPDATE tel_nrdconta
                      WITH FRAME f_cadchq.
           
               FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                        crapass.nrdconta = tel_nrdconta
                                        NO-LOCK NO-ERROR.
                                    
               IF   NOT AVAIL crapass   THEN
                    DO:
                       glb_cdcritic = 9.
                       RUN fontes/critic.p.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.
                    END.
               ELSE 
                    DO:
                       ASSIGN tel_dstitula = crapass.nmprimtl
                              aux_continua = TRUE.
                       
                       DISPLAY tel_dstitula
                               WITH FRAME f_cadchq.
                    END.
              
               LEAVE.
           END.
           FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                              crapage.cdagenci = crapass.cdagenci
                              NO-LOCK NO-ERROR.
           IF   NOT AVAILABLE crapage   THEN
                DO:
                    glb_cdcritic = 15.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    ASSIGN glb_cdcritic = 0
                           aux_continua = NO.
                END.        
                                        
           IF   NOT aux_continua   THEN
                NEXT.

           aux_continua = FALSE.
           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE tel_folhaini
                      tel_folhafim
                      tel_qtfolhas
                      WITH FRAME f_cadchq.

               IF   tel_qtfolhas <> ((tel_folhafim + 1) - tel_folhaini)   THEN
                    DO:
                       MESSAGE "Quantidade de folhas incorreta.".
                       NEXT.
                    END.
               
               aux_continua = TRUE.
               LEAVE.
           END.

           IF   NOT aux_continua   THEN
                NEXT.
           
           UPDATE tel_dtentreg
                  WITH FRAME f_cadchq.
                  
           /* pede confirmacao */
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.

               RUN fontes/critic.p.
               BELL.
               glb_cdcritic = 0.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               LEAVE.
           END.
                             
           IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S"                   THEN
                DO:
                   glb_cdcritic = 79.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   glb_cdcritic = 0.
                   NEXT.
                END.
                
           DO aux_contador = 1 TO 10 TRANSACTION:

              FIND FIRST crapfdc WHERE crapfdc.cdcooper  = glb_cdcooper AND
                                       crapfdc.nrdconta  = tel_nrdconta AND
                                       crapfdc.nrcheque >= tel_folhaini AND
                                       crapfdc.nrcheque <= tel_folhafim
                                       NO-LOCK NO-ERROR.
              
              /* Cria as folhas de cheque */
              IF   NOT AVAIL crapfdc   THEN
                   DO:
                      ASSIGN aux_contaitg = f_ver_contaitg(crapass.nrdctitg)
                             aux_nrflcheq = tel_folhaini
                             aux_nrultchq = tel_folhafim
                             aux_primvez  = TRUE.
                      
                      /* Cria as folhas de cheque do determinado talao */
                      DO WHILE TRUE: 
                          /* Pega o numero do talao */
                          IF   aux_primvez   THEN
                               DO:

                                  FIND LAST crabfdc WHERE
                                            crabfdc.cdcooper = glb_cdcooper AND
                                            crabfdc.nrdconta = tel_nrdconta
                                            NO-LOCK NO-ERROR.

                                  IF   AVAIL crabfdc   THEN
                                       DO:
                                          aux_nrtalchq = crabfdc.nrseqems + 1.
                                          aux_primvez = FALSE.
                                       END.
                                  ELSE
                                       aux_nrtalchq = 1.
                                  
                               END.

                          /*   Calcula Digito do Cheque   */
                          ASSIGN aux_primvez = FALSE
                                 glb_nrcalcul = (aux_nrflcheq * 10).
                          RUN fontes/digfun.p.
                          aux_nrdigchq = INTEGER(SUBSTR(STRING(glb_nrcalcul),
                                         LENGTH(STRING(glb_nrcalcul)),1)).
                          /* caso o digito da ctitg for 
                             "X" a funcao coloca '0'(zero) */
                          aux_contaitg = f_ver_contaitg(crapass.nrdctitg).    
              
                          /*   Calcula CMC-7 do Cheque   */
                          RUN fontes/calc_cmc7_difcompe.p (INPUT  1,
                                                  INPUT crapage.cdcomchq,
                                                  INPUT  3420,
                                                  INPUT  aux_contaitg,
                                                  INPUT  aux_nrflcheq,
                                                  INPUT  1,
                                                  OUTPUT aux_dsdocmc7).
              
                          CREATE crapfdc.
                          ASSIGN crapfdc.nrdconta = crapass.nrdconta
                                 crapfdc.nrdctabb = aux_contaitg
                                 crapfdc.nrctachq = aux_contaitg
                                 crapfdc.nrdctitg = crapass.nrdctitg
                                 crapfdc.nrpedido = 1
                                 crapfdc.nrcheque = aux_nrflcheq
                                 crapfdc.nrseqems = aux_nrtalchq
                                 crapfdc.nrdigchq = aux_nrdigchq
                                 crapfdc.tpcheque = 1
                                 crapfdc.dsdocmc7 = aux_dsdocmc7
                                 crapfdc.cdagechq = 3420
                                 crapfdc.cdbanchq = 1
                                 crapfdc.cdcmpchq = crapage.cdcomchq
                                 crapfdc.cdcooper = glb_cdcooper
                                 crapfdc.incheque = 0
                                 crapfdc.tpforchq = "TL"
                                 crapfdc.dtretchq = glb_dtmvtolt
                                 crapfdc.dtemschq = glb_dtmvtolt.

                          RELEASE crapfdc.
                          
                          IF   aux_nrflcheq = aux_nrultchq   THEN
                               LEAVE.
                          ELSE     
                               aux_nrflcheq = aux_nrflcheq + 1.
              
                      END. /* Fim do DO WHILE TRUE */
                      
                      MESSAGE "Folha(s) de cheque cadastrada(s) com sucesso!".
                      
                      LEAVE. 
                       
                   END.
              ELSE
                   DO:
                       MESSAGE "Folha(s) de cheque ja cadastrada(s)."
                               "Operacao cancelada!".
                       LEAVE.
                   END.
              
           END. /*   Fim do DO TO   */
            
           IF   glb_cdcritic > 0   THEN
                DO: 
                   RUN fontes/critic.p.
                   BELL.
                   glb_cdcritic = 0.
                   MESSAGE glb_dscritic.
                   NEXT.
                END.     
             
       END.          
                     
END. /*  Fim do DO WHILE TRUE  */

/*............................................................................*/
