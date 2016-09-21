/*.............................................................................

   Programa: Fontes/parlav.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MAIO/2011                          Ultima Atualizacao: 26/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Parametros para controle de lavagem de dinheiro.
   
   Alteracoes: 16/12/2013 - Inclusao de VALIDATE craptab e crabtab (Carlos)

               26/05/2014 - Ajustado o acesso de "CONTABILIDADE" para 
                            "SEGURANCA" (Douglas - Chamado 161631)
..............................................................................*/

{ includes/var_online.i }

DEF BUFFER crabtab FOR craptab.

DEFINE VARIABLE tel_dsemlcof AS CHARACTER   FORMAT "x(40)"              NO-UNDO.
DEFINE VARIABLE tel_qtcopfis AS INTEGER     FORMAT "z9"                 NO-UNDO.
DEFINE VARIABLE tel_qtcopjur AS INTEGER     FORMAT "z9"                 NO-UNDO.
DEFINE VARIABLE tel_vldirfis AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE tel_vldirjur AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE tel_vlmenfis AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE tel_vlmenjur AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE tel_qtcenfis AS INTEGER     FORMAT "z9"                 NO-UNDO.
DEFINE VARIABLE tel_qtcenjur AS INTEGER     FORMAT "z9"                 NO-UNDO.                                                    

/* UTILIZADO PARA O LOG DA TELA */
DEFINE VARIABLE aux_dsemlcof AS CHARACTER   FORMAT "x(40)"              NO-UNDO.
DEFINE VARIABLE aux_qtcopfis AS INTEGER     FORMAT "z9"                 NO-UNDO.
DEFINE VARIABLE aux_qtcopjur AS INTEGER     FORMAT "z9"                 NO-UNDO.
DEFINE VARIABLE aux_vldirfis AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE aux_vldirjur AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE aux_vlmenfis AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE aux_vlmenjur AS DECIMAL     FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEFINE VARIABLE aux_qtcenfis AS INTEGER     FORMAT "z9"                 NO-UNDO.
DEFINE VARIABLE aux_qtcenjur AS INTEGER     FORMAT "z9"                 NO-UNDO.                                                    


DEFINE VARIABLE aux_confirma AS CHARACTER   FORMAT "(!)"                NO-UNDO.
DEFINE VARIABLE aux_dstabcop AS CHARACTER                               NO-UNDO.
DEFINE VARIABLE aux_dstabcen AS CHARACTER                               NO-UNDO.

FORM SKIP
     glb_cddopcao LABEL "Opcao" AUTO-RETURN                             
        VALIDATE (CAN-DO("A,C",glb_cddopcao),"014 - Opcao errada.")
        HELP "A - Alteracao, C - Consulta"                              AT 3
     SKIP(1)                                                            
     tel_dsemlcof LABEL "E-mail que cadastra COAF"                      AT 3
     SKIP(1)
     "Quantidade de vezes a renda do cooperado p/diario da cooperativa" AT 3
     SKIP
     tel_qtcopfis LABEL "Pessoa Fisica"                                 AT 9
     SKIP
     tel_qtcopjur LABEL "Pessoa Juridica"                               AT 7
     SKIP
     "Total de creditos do cooperado p/diario da cooperativa"           AT 3
     SKIP                                                                  
     tel_vldirfis LABEL "Pessoa Fisica"                                 AT 9
     SKIP
     tel_vldirjur LABEL "Pessoa Juridica"                               AT 7
     SKIP
     "Total de creditos do cooperado p/mensal da cooperativa"           AT 3
     SKIP
     tel_vlmenfis LABEL "Pessoa Fisica"                                 AT 9
     SKIP
     tel_vlmenjur LABEL "Pessoa Juridica"                               AT 7
     SKIP
     "Quantidade vezes a renda do cooperado p/diario da central"        AT 3
     SKIP
     tel_qtcenfis LABEL "Pessoa Fisica"                                 AT 9
     SKIP
     tel_qtcenjur LABEL "Pessoa Juridica"                               AT 7
     WITH ROW 5 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_parlav.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE " Parametros de controle de lavagem de dinheiro " FRAME f_moldura.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_parlav.
PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE TRANSACTION:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_parlav.

        IF  glb_cddopcao =  "A"             AND
            glb_dsdepart <> "TI"            AND
            glb_dsdepart <> "SEGURANCA"     THEN
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
               IF  CAPS(glb_nmdatela) <> "PARLAV"  THEN
                   DO:
                      HIDE FRAME f_parlav.
                      HIDE FRAME f_moldura.
                      RETURN.
                   END.
                ELSE
                    NEXT.
            END.
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    IF AVAIL crapcop THEN
        ASSIGN tel_dsemlcof = crapcop.dsemlcof
               aux_dsemlcof = crapcop.dsemlcof. /* PARA O LOG */
             
    /* DADOS DA COOPERATIVA */
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper
                   AND craptab.nmsistem = "LAV"
                   AND craptab.tptabela = "CONFIG"
                   AND craptab.cdempres = 0
                   AND craptab.cdacesso = "PARLVDNCP"
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL craptab THEN
        DO:
            IF  LOCKED craptab THEN
                DO:
                    MESSAGE "Registro sendo utilizado por outro usuario.".
                    NEXT.
                END.
            ELSE
                DO:
                    CREATE craptab.
                    ASSIGN craptab.cdcooper = glb_cdcooper
                           craptab.nmsistem = "LAV"       
                           craptab.tptabela = "CONFIG"    
                           craptab.cdempres = 0           
                           craptab.cdacesso = "PARLVDNCP".
                    VALIDATE craptab.
                END.
        END.
    ELSE
        ASSIGN aux_dstabcop = craptab.dstextab.


    /* DADOS DA COOPERATIVA CADASTRADOS NA CECRED */
    FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper
                   AND crabtab.nmsistem = "LAV"
                   AND crabtab.tptabela = "CONFIG"
                   AND crabtab.cdempres = 0
                   AND crabtab.cdacesso = "PARLVDNCR"
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL crabtab THEN
        DO:
            IF  LOCKED crabtab THEN
                DO:
                    MESSAGE "Registro sendo utilizado por outro usuario.".
                    NEXT.
                END.
            ELSE
                DO:
                    CREATE crabtab.
                    ASSIGN crabtab.cdcooper = glb_cdcooper
                           crabtab.nmsistem = "LAV"       
                           crabtab.tptabela = "CONFIG"    
                           crabtab.cdempres = 0           
                           crabtab.cdacesso = "PARLVDNCR".
                    VALIDATE crabtab.
                END.
        END.
    ELSE
        ASSIGN aux_dstabcen = crabtab.dstextab.

    /* Caso exista carrega dados cooperativa */
    IF  TRIM(aux_dstabcop) <> "" THEN
        DO:
            ASSIGN tel_qtcopfis = INT(ENTRY(1,aux_dstabcop,";"))
                   tel_qtcopjur = INT(ENTRY(2,aux_dstabcop,";"))
                   tel_vldirfis = DEC(ENTRY(3,aux_dstabcop,";"))
                   tel_vldirjur = DEC(ENTRY(4,aux_dstabcop,";"))
                   tel_vlmenfis = DEC(ENTRY(5,aux_dstabcop,";"))
                   tel_vlmenjur = DEC(ENTRY(6,aux_dstabcop,";"))
                   /* PARA O LOG */
                   aux_qtcopfis = INT(ENTRY(1,aux_dstabcop,";"))
                   aux_qtcopjur = INT(ENTRY(2,aux_dstabcop,";"))
                   aux_vldirfis = DEC(ENTRY(3,aux_dstabcop,";"))
                   aux_vldirjur = DEC(ENTRY(4,aux_dstabcop,";"))
                   aux_vlmenfis = DEC(ENTRY(5,aux_dstabcop,";"))
                   aux_vlmenjur = DEC(ENTRY(6,aux_dstabcop,";")).
        END.
    
    
    /* Caso exista carrega dados CECRED */
    IF  TRIM(aux_dstabcen) <> "" THEN
        DO:
            ASSIGN tel_qtcenfis = INT(ENTRY(1,aux_dstabcen,";"))
                   tel_qtcenjur = INT(ENTRY(2,aux_dstabcen,";"))
                   /* PARA O LOG */
                   aux_qtcenfis = INT(ENTRY(1,aux_dstabcen,";"))
                   aux_qtcenjur = INT(ENTRY(2,aux_dstabcen,";")).
        END.
    
    IF  glb_cddopcao = "A" THEN
        DO:
            DISP tel_dsemlcof
                 tel_qtcopfis tel_qtcopjur
                 tel_vldirfis tel_vldirjur
                 tel_vlmenfis tel_vlmenjur
                 tel_qtcenfis tel_qtcenjur
                 WITH FRAME f_parlav.

            UPDATE tel_dsemlcof
                   tel_qtcopfis tel_qtcopjur
                   tel_vldirfis tel_vldirjur
                   tel_vlmenfis tel_vlmenjur
                   tel_qtcenfis tel_qtcenjur
                   WITH FRAME f_parlav.

            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).

            IF  aux_confirma = "S" THEN
                DO:
                    FIND CURRENT crapcop EXCLUSIVE-LOCK.

                    ASSIGN crapcop.dsemlcof = tel_dsemlcof
                           craptab.dstextab = STRING(tel_qtcopfis) + ";" + 
                                              STRING(tel_qtcopjur) + ";" +
                                              STRING(tel_vldirfis) + ";" + 
                                              STRING(tel_vldirjur) + ";" +
                                              STRING(tel_vlmenfis) + ";" + 
                                              STRING(tel_vlmenjur)
                           crabtab.dstextab = STRING(tel_qtcenfis) + ";" + 
                                              STRING(tel_qtcenjur).

                    FIND CURRENT crapcop NO-LOCK.
                    
                    /* GRAVAR LOG DA TELA */
                    RUN gera_log(INPUT "E-mail que cadastra COAF",
                                 INPUT tel_dsemlcof,
                                 INPUT aux_dsemlcof).

                    RUN gera_log(INPUT "Quantidade de vezes a renda do " +
                                 "cooperado p/diario da cooperativa - Fisica",
                                 INPUT tel_qtcopfis,
                                 INPUT aux_qtcopfis).

                    RUN gera_log(INPUT "Quantidade de vezes a renda do " +
                                 "cooperado p/diario da cooperativa - Juridica",
                                 INPUT tel_qtcopjur,
                                 INPUT aux_qtcopjur).

                    RUN gera_log(INPUT "Total de creditos do cooperado " +
                                 "p/diario da cooperativa - Fisica",
                                 INPUT tel_vldirfis,
                                 INPUT aux_vldirfis).

                    RUN gera_log(INPUT "Total de creditos do cooperado " +
                                 "p/diario da cooperativa - Juridica",
                                 INPUT tel_vldirjur,
                                 INPUT aux_vldirjur).

                    RUN gera_log(INPUT "Total de creditos do cooperado " +
                                 "p/mensal da cooperativa - Fisica",
                                 INPUT tel_vlmenfis,
                                 INPUT aux_vlmenfis).
                    
                    RUN gera_log(INPUT "Total de creditos do cooperado " +
                                 "p/mensal da cooperativa - Juridica",
                                 INPUT tel_vlmenjur,
                                 INPUT aux_vlmenjur).

                    RUN gera_log(INPUT "Quantidade vezes a renda do " +
                                 "cooperado p/diario da central - Fisica",
                                 INPUT tel_qtcenfis,
                                 INPUT aux_qtcenfis).
                    
                    RUN gera_log(INPUT "Quantidade vezes a renda do " +
                                 "cooperado p/diario da central - Juridica",
                                 INPUT tel_qtcenjur,
                                 INPUT aux_qtcenjur).
                    
                END.

        END.
    ELSE
    IF  glb_cddopcao = "C" THEN
        DO:
            DISP tel_dsemlcof
                 tel_qtcopfis tel_qtcopjur
                 tel_vldirfis tel_vldirjur
                 tel_vlmenfis tel_vlmenjur
                 tel_qtcenfis tel_qtcenjur
                 WITH FRAME f_parlav.

        END.

    FIND CURRENT craptab NO-LOCK.
    FIND CURRENT crabtab NO-LOCK.

END. /* END WHILE TRUE */

/* .......................................................................... */

PROCEDURE gera_log:

    DEF INPUT PARAM par_dsdcampo AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vldepois AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vldantes AS CHAR NO-UNDO.

    IF  par_vldepois = par_vldantes   THEN
        RETURN.

    ASSIGN par_vldepois = "---" WHEN par_vldepois = ""
           par_vldantes = "---" WHEN par_vldantes = ""
           par_vldepois = REPLACE(REPLACE(par_vldepois,"("," "),")","-")
           par_vldantes = REPLACE(REPLACE(par_vldantes,"("," "),")","-").

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "       +
                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "      +
                      glb_cdoperad + " '-->' Alterou o campo " + par_dsdcampo +
                      " de " + par_vldantes + " para " + par_vldepois + "."   +
                      " >> log/parlav.log").
    
END PROCEDURE.
