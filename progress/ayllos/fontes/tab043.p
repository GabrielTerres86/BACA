/* .............................................................................

   Programa: Fontes/tab043.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton         
   Data    : Novembro/2006                        Ultima alteracao:   /  /    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Desbloquear sequencia da conta integracao.
   
   Alteracoes: 

............................................................................. */
DEF  VAR  tel_tpregist    AS INT     FORMAT "zzz"                     NO-UNDO.
DEF  VAR  tel_sequenci    AS INT     FORMAT "99999"                   NO-UNDO.
DEF  VAR  aux_situacao    AS CHAR    FORMAT "x"                       NO-UNDO.
DEF  VAR  tel_situacao    AS LOG     FORMAT "Liberado/Bloqueado"      NO-UNDO.
DEF  VAR  tel_hora        AS INT     FORMAT "99"                      NO-UNDO.
DEF  VAR  tel_minutos     AS INT     FORMAT "99"                      NO-UNDO.

DEF  VAR  aux_cddopcao    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_confirma    AS CHAR    FORMAT "!(1)"                    NO-UNDO.
DEF  VAR  aux_contador    AS INT     FORMAT "z9"                      NO-UNDO.

{ includes/var_online.i }

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao   LABEL "Opcao" 
                    HELP "Informe 'A' para alterar ou 'C' para consultar." 
                    VALIDATE(CAN-DO("A,C",glb_cddopcao), "014 - Opcao errada.")
                    SKIP(2) WITH FRAME f_opcao 
                    COLUMN 6 ROW 6 SIDE-LABEL NO-BOX OVERLAY.
                    
FORM tel_tpregist   LABEL "Arquivo  "  AT 10
                    HELP "Informe numero do arquivo."   
                    VALIDATE(tel_tpregist >= 400 AND tel_tpregist <= 600, 
                             "Arquivo deve estar entre 400 e 600.") 
                    SKIP(2)
     tel_sequenci   LABEL "Sequencia"   AT 10
                    HELP "Informe numero da sequencia." SKIP(1)     
     
     tel_situacao   LABEL "Situacao " AT 10
                    HELP "Informe 'L' para liberar ou 'B' para bloquear."
                    
     tel_hora       LABEL "Hora     "  AT 10
                    HELP "Informe a hora (00:00 a 23:00)."
          VALIDATE (tel_hora < 24, "Valor da hora deve estar entre '0' e '23'.")
     ":" AT 23
     tel_minutos    NO-LABEL  AT 24
                    HELP "Informe os minutos (0 a 59)."
                    VALIDATE (tel_minutos < 60, 
                    "Valor dos minutos devem estar entre '0' e '59'.")
     WITH FRAME f_dados WITH SIDE-LABELS  NO-BOX ROW 9 COLUMN 10 OVERLAY.


RUN fontes/inicia.p.
          
VIEW FRAME f_moldura.
PAUSE (0).


ASSIGN glb_cddopcao = "C".

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE :  

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE : 
        UPDATE glb_cddopcao WITH FRAME f_opcao. 
        LEAVE.
    END.
    

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:            
             RUN  fontes/novatela.p.
                  IF   CAPS(glb_nmdatela) <> "TAB043"   THEN
                       LEAVE.                       
                  ELSE
                       NEXT.
         END.    

    IF   aux_cddopcao <> glb_cddopcao THEN
         DO:
            { includes/acesso.i }
             aux_cddopcao = glb_cddopcao.
         END.
                    
    
    UPDATE tel_tpregist WITH FRAME f_dados.         
      
    IF  glb_cddopcao = "C" THEN
        DO: 
            FIND  craptab   WHERE   
                            craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "NRARQMVITG"  AND
                            craptab.tpregist = tel_tpregist  
                            NO-LOCK NO-ERROR NO-WAIT.

            IF  AVAIL craptab THEN
                DO:
                     ASSIGN  tel_sequenci = DEC(SUBSTR(craptab.dstextab,1,5)) 
                             aux_situacao = SUBSTR(craptab.dstextab,7,1)
                             tel_hora     = DEC(SUBSTR(craptab.dstextab,9,2))
                             tel_minutos  = DEC(SUBSTR(craptab.dstextab,12,2)).
                   
                     
                     IF  aux_situacao = '1' THEN    /*BLOQUEADO*/
                            tel_situacao = FALSE.
                        ELSE
                            tel_situacao  = TRUE.    /*LIBERADO*/
  
                     DISPLAY  tel_sequenci tel_situacao 
                              tel_hora     tel_minutos    WITH FRAME f_dados.
                END.
            ELSE
                 DO:
                     glb_cdcritic = 55.
                     CLEAR FRAME f_dados.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     NEXT.                                
                 END.
        END.   
    ELSE
        IF  glb_cddopcao = "A" THEN
            DO:
                DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                   DO  aux_contador = 1 TO 10:

                       FIND  craptab  WHERE   
                                      craptab.cdcooper = glb_cdcooper  AND
                                      craptab.nmsistem = "CRED"        AND
                                      craptab.tptabela = "GENERI"      AND
                                      craptab.cdempres = 00            AND
                                      craptab.cdacesso = "NRARQMVITG"  AND
                                      craptab.tpregist = tel_tpregist  
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                                
                       IF   NOT AVAILABLE craptab   THEN
                            IF   LOCKED craptab   THEN
                                 DO:
                                     glb_cdcritic = 77.
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:
                                     glb_cdcritic = 55.
                                     CLEAR FRAME f_dados.
                                     LEAVE.
                                 END.
                       ELSE
                            DO:
                                aux_contador = 0.
                                LEAVE.
                            END.
                   END.

                   IF   aux_contador <> 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            NEXT.
                        END.
 
                   ASSIGN tel_sequenci = DEC(SUBSTR(craptab.dstextab,1,5)) 
                          aux_situacao = SUBSTR(craptab.dstextab,7,1)
                          tel_hora     = DEC(SUBSTR(craptab.dstextab,9,2))
                          tel_minutos  = DEC(SUBSTR(craptab.dstextab,12,2)).
               
                   IF  aux_situacao = '1' THEN   /** BLOQUEADO */
                       tel_situacao = FALSE.
                   ELSE
                       tel_situacao = TRUE.       /*LIBERADO*/
                   
                   
                   DISPLAY  tel_sequenci tel_situacao 
                            tel_hora     tel_minutos    WITH FRAME f_dados.
                   
                   IF  (tel_tpregist >= 500) THEN
                       UPDATE tel_sequenci WITH FRAME f_dados.
                   ELSE
                       DO:        
                          UPDATE  tel_sequenci tel_situacao
                                  tel_hora     tel_minutos WITH FRAME f_dados.
               
                          IF  tel_situacao = TRUE THEN
                              ASSIGN aux_situacao = '0'.
                          ELSE
                              IF tel_situacao = FALSE THEN
                                 ASSIGN aux_situacao = '1'.
                         
                       END.

                   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic 
                       UPDATE aux_confirma.
                       LEAVE.
                   END.

                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                        aux_confirma <> "S" THEN
                        DO:
                            glb_cdcritic = 79.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            CLEAR FRAME f_dados.
                            NEXT.
                        END.
    
                 IF  tel_tpregist >= 500 THEN
                     craptab.dstextab = STRING(tel_sequenci,"99999").
                 ELSE
                     craptab.dstextab  =  STRING(tel_sequenci, "99999") 
                                          + " " +
                                          aux_situacao + " " + 
                                          STRING(tel_hora, "99") + ":"+
                                          STRING(tel_minutos, "99").
                
                
                END. /*fim transacao*/     
                
                RELEASE craptab.

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                     NEXT.

                CLEAR FRAME f_dados NO-PAUSE.
                       
            END. /* FIM OPCAO "A"   */
        
END.

