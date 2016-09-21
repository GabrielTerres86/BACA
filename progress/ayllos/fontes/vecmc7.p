/* .............................................................................

   Programa: Fontes/vecmc7.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Dezembro/2006                       Ultima atualizacao:           

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Entrar com o CMC-7 manualmente.


............................................................................. */

{ includes/var_online.i  } 

DEF VAR par_dsdocmc7 AS CHAR                                         NO-UNDO.

DEF VAR tel_nrcampo1 AS INT     FORMAT "99999999"                    NO-UNDO.
DEF VAR tel_nrcampo2 AS DECIMAL FORMAT "9999999999"                  NO-UNDO.
DEF VAR tel_nrcampo3 AS DECIMAL FORMAT "999999999999"                NO-UNDO.

DEF VAR aux_lsdigctr AS CHAR                                         NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM "Opcao: " glb_cddopcao HELP 'Informe "C" para consultar CMC-7.'
                            VALIDATE(glb_cddopcao = "C","014 - Opcao errada.")
     WITH FRAME f_opcao NO-LABEL NO-BOX ROW 6 COLUMN 3 OVERLAY.

FORM SKIP(1)
     "Informe o CMC-7:" AT 3
     "<"                AT 20 
     tel_nrcampo1       AT 21  
     "<"                AT 29  
     tel_nrcampo2       AT 30 
     ">"                AT 40  
     tel_nrcampo3       AT 41  
     ":  "              AT 53  
     SKIP(1)
     WITH ROW 8  COLUMN 5 NO-LABEL  NO-BOX OVERLAY  FRAME f_cmc7.

RUN fontes/inicia.p. 

VIEW FRAME f_moldura.

PAUSE (0).

glb_cddopcao = "C".

DISPLAY glb_cddopcao WITH FRAME f_opcao.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
        
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
             RUN  fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "VECMC7"   THEN
                  LEAVE. 
             ELSE
                  NEXT.
        END.

   UPDATE glb_cddopcao WITH FRAME f_opcao.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
        END. 
  
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
      UPDATE tel_nrcampo1 
             tel_nrcampo2
             tel_nrcampo3 WITH FRAME f_cmc7.
      LEAVE.
   END.
      
   par_dsdocmc7 = "<" + STRING(tel_nrcampo1,"99999999") +
                  "<" + STRING(tel_nrcampo2,"9999999999") +
                  ">" + STRING(tel_nrcampo3,"999999999999") + ":".

   /*  Confere os digitos do CMC-7  */
   
   RUN dig_cmc7 (INPUT  par_dsdocmc7, 
                 OUTPUT glb_nrcalcul,
                 OUTPUT aux_lsdigctr).
   
   IF   glb_nrcalcul > 0   THEN
        DO:
            IF   glb_nrcalcul = 1   THEN
                 NEXT-PROMPT tel_nrcampo1 WITH FRAME f_cmc7.
            ELSE
            IF   glb_nrcalcul = 2   THEN
                 NEXT-PROMPT tel_nrcampo2 WITH FRAME f_cmc7.
            ELSE
            IF   glb_nrcalcul = 3   THEN
                 NEXT-PROMPT tel_nrcampo3 WITH FRAME f_cmc7.
 
            glb_cdcritic = 8.
            NEXT.
        END.
    
/*   LEAVE.    */

END.  /*  Fim do DO WHILE TRUE  */



PROCEDURE dig_cmc7:


DEF INPUT  PARAM par_dsdocmc7 AS CHAR FORMAT "x(35)"                 NO-UNDO.
DEF OUTPUT PARAM par_nrdcampo AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_lsdigctr AS CHAR                                NO-UNDO.

DEF VAR aux_nrcalcul AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrdigito AS INT                                          NO-UNDO.
DEF VAR aux_stsnrcal AS LOGICAL                                      NO-UNDO.

DEF VAR aux_nrcampo1 AS INT                                          NO-UNDO.
DEF VAR aux_nrcampo2 AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrcampo3 AS DECIMAL                                      NO-UNDO.

IF   LENGTH(par_dsdocmc7) <> 34   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.

/*  Conteudo do par_dsdocmc7 =  <00100950<0168086015>870000575178:  */

ASSIGN aux_nrcampo1 = INT(SUBSTRING(par_dsdocmc7,2,8)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.
 
ASSIGN aux_nrcampo2 = DECIMAL(SUBSTRING(par_dsdocmc7,11,10)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.

ASSIGN aux_nrcampo3 = DECIMAL(SUBSTRING(par_dsdocmc7,22,12)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.

par_nrdcampo = 0.
       
DO WHILE TRUE:

   /*  Calcula o digito do terceiro campo  - DV 1  */
           
   aux_nrcalcul = aux_nrcampo1.
                   
   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   aux_nrcampo1 = aux_nrcalcul.

   /*  Calcula o digito do primeiro campo  - DV 2  */
       
   aux_nrcalcul = aux_nrcampo2 * 10.
               
   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   aux_nrcampo2 = aux_nrcalcul.
                               
   /*  Calcula digito DV 3  */
   
   aux_nrcalcul = DECIMAL(SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11)).

   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   aux_nrcampo3 = aux_nrcalcul.
 
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

DISPLAY SKIP(1)
        "Campo 1: " AT 13 aux_nrcampo1 format "99999999"      SKIP    
        "Campo 2: " AT 13 aux_nrcampo2 format "9999999999"    SKIP 
        "Campo 3: " AT 13 aux_nrcampo3 format "999999999999"  
        WITH OVERLAY .

par_dsdocmc7 = "<" + 
               SUBSTRING(STRING(aux_nrcampo1,"99999999"),1,7) +
               SUBSTRING(STRING(aux_nrcampo2,"99999999999"),11,1) +
               "<" + 
               SUBSTRING(STRING(aux_nrcampo2,"99999999999"),1,10) +
               ">" + 

               SUBSTRING(STRING(aux_nrcampo1,"999999999"),9,1) +
               SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11) + ":".

DISPLAY SKIP(2) "CMC-7 CERTO ==>" AT 6  par_dsdocmc7 
                WITH NO-LABEL NO-BOX COLUMN 3 .


END PROCEDURE.

/* .......................................................................... */
