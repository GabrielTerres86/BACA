/*.............................................................................

   Programa: Fontes/juslav.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MAIO/2011                          Ultima Atualizacao: 06/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Listar justificativas de suspeitas de lavagem de dinheiro.
   
   Alteracoes: 06/12/2013 - Inclusao de VALIDATE craptab (Carlos)
..............................................................................*/

{ includes/var_online.i }

DEF TEMP-TABLE tt-just NO-UNDO
    FIELD cddjusti AS INTE FORMAT "z9"      COLUMN-LABEL "Codigo"
    FIELD dsdjusti AS CHAR FORMAT "x(65)"   COLUMN-LABEL "Descricao"
    FIELD nrdrowid AS ROWID.

DEF QUERY q-just FOR tt-just.

DEF BROWSE b-just QUERY q-just
    DISP tt-just.cddjusti
         tt-just.dsdjusti
    WITH 09 DOWN NO-BOX.

DEF VAR aux_confirma AS  CHAR   FORMAT "(!)"                            NO-UNDO.

DEF VAR tel_cddjusti AS  INTE                                           NO-UNDO.
DEF VAR tel_dsdjusti AS  CHAR                                           NO-UNDO.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE " Justificativas de suspeita de lavagem de dinheiro " FRAME f_moldura.
    
FORM SKIP 
     glb_cddopcao LABEL "Opcao" AUTO-RETURN
        HELP "(A - Alteracao, C - Consulta, I - Inclusao)"
        VALIDATE (CAN-DO("A,C,I",glb_cddopcao),"014 - Opcao Errada.") AT 3
     WITH ROW 5 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_juslav.

FORM b-just
     WITH  ROW 7 OVERLAY WIDTH 78 CENTERED FRAME f_browse.

FORM SKIP(1)
     tt-just.cddjusti              LABEL "Codigo" AT 4
     tel_dsdjusti   FORMAT "x(65)" LABEL "Descricao"
                    VALIDATE (tel_dsdjusti <> "", "Descricao nao pode ser vazia")
     SKIP(1)
     WITH SIDE-LABELS OVERLAY TITLE " Informacoes da Justificafiva " ROW 10
          COLUMN 2 FRAME f_altera.


ON "RETURN" OF b-just DO:
    IF  glb_cddopcao = "A" THEN
        DO TRANSACTION:                
            DISP tt-just.cddjusti
                WITH FRAME f_altera.
            PAUSE 0.
            
            ASSIGN tel_dsdjusti = tt-just.dsdjusti.
          
          
            UPDATE tel_dsdjusti 
                   WITH FRAME f_altera.
                      
            FIND craptab WHERE ROWID(craptab) = tt-just.nrdrowid 
                               EXCLUSIVE-LOCK NO-ERROR.
            
            IF  AVAIL craptab THEN
                ASSIGN craptab.dstextab = tel_dsdjusti
                       tt-just.dsdjusti = tel_dsdjusti
                       tel_dsdjusti     = "".
            
            HIDE FRAME f_altera.

            FIND CURRENT craptab NO-LOCK.

            b-just:REFRESH().
        
        END.
END.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_juslav.
PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_juslav.

        IF  (glb_cddopcao =  "A"            OR
             glb_cddopcao =  "I")           AND
            glb_dsdepart <> "TI"            AND
            glb_dsdepart <> "CONTABILIDADE" THEN
            DO:
                MESSAGE "Acesso nao permitido.".
                NEXT.    
            END.

        { includes/acesso.i }

        LEAVE.

    END.
    

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
            DO:
               RUN fontes/novatela.p.
               IF  CAPS(glb_nmdatela) <> "JUSLAV"  THEN
                   DO:
                      HIDE FRAME f_juslav.
                      HIDE FRAME f_browse.
                      HIDE FRAME f_altera.
                      HIDE FRAME f_moldura.
                      RETURN.
                   END.
                ELSE
                    NEXT.
            END.

    IF  glb_cddopcao = "C" THEN
        DO:
            b-just:HELP = "Tecle <F4> para sair.".

             RUN carrega-dados.

             HIDE FRAME f_browse NO-PAUSE. 
        END.
    ELSE
    IF  glb_cddopcao = "A" THEN
        DO:
            b-just:HELP = "Tecle ENTER para selecionar o registro" + 
                             " e <F4> para sair.".

             RUN carrega-dados.

             HIDE FRAME f_altera.
             HIDE FRAME f_browse NO-PAUSE. 
        END.
    ELSE
    IF  glb_cddopcao = "I" THEN
        DO TRANSACTION:
            ASSIGN tel_dsdjusti = "".
            
            FIND LAST craptab WHERE craptab.cdcooper = glb_cdcooper
                                AND craptab.nmsistem = "JDP"
                                AND craptab.tptabela = "CONFIG"
                                AND craptab.cdempres = 0
                                AND craptab.cdacesso = "JUSTDEPOS" 
                                NO-LOCK NO-ERROR.

            IF  AVAIL craptab THEN
                ASSIGN tel_cddjusti = craptab.tpregist + 1.    
            ELSE
                ASSIGN tel_cddjusti = 1.
            
            CREATE craptab.
            ASSIGN craptab.cdcooper = glb_cdcooper  
                   craptab.nmsistem = "JDP"         
                   craptab.tptabela = "CONFIG"      
                   craptab.cdempres = 0             
                   craptab.cdacesso = "JUSTDEPOS" 
                   craptab.tpregist = tel_cddjusti.

            VALIDATE craptab.

            DISP craptab.tpregist @ tt-just.cddjusti
                 WITH FRAME f_altera.

            PAUSE 0.

            UPDATE tel_dsdjusti
                   WITH FRAME f_altera.

            
                ASSIGN craptab.dstextab = tel_dsdjusti
                       tel_dsdjusti     = "".
            
            HIDE FRAME f_altera.
                                        
        END.

END. /* Fim do DO WHILE TRUE */

PROCEDURE carrega-dados:

    CLOSE QUERY q-just.
    EMPTY TEMP-TABLE tt-just.
    
    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper
                       AND craptab.nmsistem = "JDP"
                       AND craptab.tptabela = "CONFIG"
                       AND craptab.cdempres = 0
                       AND craptab.cdacesso = "JUSTDEPOS" NO-LOCK:

        CREATE tt-just.
        ASSIGN tt-just.cddjusti = craptab.tpregist
               tt-just.dsdjusti = craptab.dstextab
               tt-just.nrdrowid = ROWID(craptab).

    END.

    FIND FIRST tt-just NO-LOCK NO-ERROR.

    IF  AVAIL tt-just THEN
        DO:
            OPEN QUERY q-just FOR EACH tt-just.

            UPDATE b-just WITH FRAME f_browse.
        END.
    ELSE
        MESSAGE "Justificativas nao cadastradas.".

END PROCEDURE.
