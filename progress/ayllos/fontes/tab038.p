/* .............................................................................

   Programa: Fontes/tab038.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Maio/2006                         Ultima Atualizacao: 13/12/2013

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Cadastro das Formas de Envio de Correspondencias.

   Alteracoes: 30/05/2006 - Concertado para possibilitar a utilizacao de "F2"
                            na tela (Diego).
                            
               16/05/2007 - Modificado para gravar dados com letras maiusculas
                            nas tabelas (Diego). 
          
               16/04/2012 - Fonte substituido por tab038p.p (Tiago).  
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)            
..............................................................................*/

{ includes/var_online.i }

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Incluir",
                                            "Alterar",
                                            "Excluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["I","A","E"]               NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.


DEF VAR tel_cdfenvio AS INT  FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_dsfenvio AS CHAR FORMAT "x(24)"  CASE-SENSITIVE            NO-UNDO.
DEF VAR tel_dstabela AS CHAR FORMAT "x(8)"                             NO-UNDO.
DEF VAR tel_tpregist AS INT  FORMAT "zz"                               NO-UNDO.

DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF TEMP-TABLE w-formas                                                NO-UNDO
    FIELD cdfenvio AS INT   FORMAT "z9"
    FIELD dsfenvio AS CHAR  FORMAT "x(24)"
    FIELD dstabela AS CHAR  FORMAT "x(8)"
    FIELD tpregist AS INT   FORMAT "zz"
    FIELD nrdrowid    AS ROWID.


DEF QUERY q_informativos FOR w-formas.

DEF BROWSE b_informativos QUERY q_informativos
    DISPLAY w-formas.cdfenvio COLUMN-LABEL "Codigo"      
            w-formas.dsfenvio COLUMN-LABEL "Descricao"   
            w-formas.dstabela COLUMN-LABEL "Tabela"
            w-formas.tpregist COLUMN-LABEL "Tipo"
            WITH 5 DOWN.

FORM b_informativos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 7 COLUMN 16 OVERLAY NO-BOX FRAME f_browse.

FORM SKIP(2)
     "Codigo Descricao                Tabela   Tipo" AT 2
     SKIP
     tel_cdfenvio       AT 4
     tel_dsfenvio       AT 9  HELP "Informe a Forma de Envio"
                              VALIDATE(tel_dsfenvio <> "",
                                       "375 - O campo deve ser preenchido.")
     tel_dstabela       AT 34 HELP "Informe o nome da tabela"
                              VALIDATE(tel_dstabela <> "", 
                                       "375 - O campo deve ser preenchido.")
     tel_tpregist       AT 44
     SKIP(2)
     WITH ROW 8 COLUMN 17 OVERLAY NO-LABEL  FRAME f_inform.

FORM SKIP(10)
     reg_dsdopcao[1]  AT 11  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 26  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 41  NO-LABEL FORMAT "x(7)"
     SKIP(1)
     WITH ROW 6 COLUMN 11 WIDTH 60 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     " CADASTRO FORMAS ENVIO DE CORRESPONDENCIAS"  FRAME f_regua.


FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.

/* Para Visualizar MESSAGE do F2 ao entrar na Tela */
ON VALUE-CHANGED, ENTRY OF b_informativos IN FRAME f_browse DO:

   RUN fontes/inicia.p.
    
END.

ON ANY-KEY OF b_informativos IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.

            IF   reg_contador > 3   THEN
                 reg_contador = 1.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 3.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           IF   AVAILABLE w-formas   THEN
                DO:
                    ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_informativos")
                           aux_nrdrowid = w-formas.nrdrowid.
                           
                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_informativos:DESELECT-ROWS().
                END.
           ELSE
                DO:
                    ASSIGN aux_nrdlinha = 0
                           aux_nrdrowid = ?.
                           
                    IF   glb_cddopcao <> "I"  THEN 
                         NEXT.
                END.
                
           APPLY "GO".
        END.
   ELSE         
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
        RETURN.
                           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
END.


VIEW FRAME f_moldura.
PAUSE (0).

DO WHILE TRUE: 
   
   ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
   
   DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
   
   EMPTY TEMP-TABLE w-formas.
   
   FOR EACH craptab WHERE craptab.cdcooper = 0              AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "USUARI"       AND
                          craptab.cdempres = 11             AND
                          craptab.cdacesso = "FORENVINFO" NO-LOCK.
                          
       CREATE w-formas.
       ASSIGN w-formas.cdfenvio = craptab.tpregist
              w-formas.nrdrowid = ROWID(craptab).

       DO   aux_contador = 1  TO  NUM-ENTRIES(craptab.dstextab):
       
            IF   aux_contador = 1  THEN
                 ASSIGN w-formas.dsfenvio = ENTRY(1,craptab.dstextab,",").
            ELSE
            IF   aux_contador = 2  THEN
                 ASSIGN w-formas.dstabela = ENTRY(2,craptab.dstextab,",").
            ELSE
                 ASSIGN w-formas.tpregist = INT(ENTRY(3,craptab.dstextab,",")).
                    
       END.
                                        
   END.    
   
   OPEN QUERY q_informativos 
        FOR EACH w-formas.
         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_informativos WITH FRAME f_browse.
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB038"   THEN
                 DO:
                     HIDE FRAME f_regua.
                     HIDE FRAME f_browse. 
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
   
   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse. 
   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_informativos TO ROW(aux_nrdlinha).
               
   { includes/acesso.i } 
        
   IF   glb_cddopcao = "I"   THEN
        DO:
            FIND LAST craptab WHERE 
                      craptab.cdcooper = 0              AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "USUARI"       AND
                      craptab.cdempres = 11             AND
                      craptab.cdacesso = "FORENVINFO"  
                      EXCLUSIVE-LOCK NO-ERROR. 
            
            IF   AVAIL craptab  THEN
                 ASSIGN tel_cdfenvio = craptab.tpregist + 1.
            ELSE
                 ASSIGN tel_cdfenvio = 1.
            
            DISPLAY tel_cdfenvio WITH FRAME f_inform.
            UPDATE tel_dsfenvio tel_dstabela tel_tpregist WITH FRAME f_inform
            
            EDITING:

              READKEY.

              IF   FRAME-FIELD = "tel_dsfenvio"  OR 
                   FRAME-FIELD = "tel_dstabela"  THEN
                   IF   LASTKEY =  KEYCODE(",")   THEN
                        NEXT.
                   ELSE
                        APPLY LASTKEY.
              ELSE
                   APPLY LASTKEY.
               
            END.  /*  Fim do EDITING  */
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     /* Caso 2 operadores estejam inserindo ao mesmo tempo */
                     FIND  craptab WHERE 
                           craptab.cdcooper = 0              AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "FORENVINFO"   AND
                           craptab.tpregist = tel_cdfenvio
                           EXCLUSIVE-LOCK NO-ERROR. 
                     
                     IF   AVAIL craptab THEN
                          DO:
                              glb_cdcritic = 873.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                     
                     CREATE craptab.
                     ASSIGN craptab.nmsistem = "CRED"
                            craptab.tptabela = "USUARI"
                            craptab.cdempres = 11
                            craptab.cdacesso = "FORENVINFO"
                            craptab.cdcooper = 0
                            craptab.tpregist = tel_cdfenvio
                            craptab.dstextab = UPPER(tel_dsfenvio) + "," +
                                               tel_dstabela + 
                                               (IF tel_tpregist = 0 THEN "" 
                                                ELSE "," +
                                                     STRING(tel_tpregist)).
                     VALIDATE craptab.
                 END.
        END.
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:
            FIND craptab WHERE 
                 craptab.cdcooper = 0              AND
                 craptab.nmsistem = "CRED"         AND
                 craptab.tptabela = "USUARI"       AND
                 craptab.cdempres = 11             AND
                 craptab.cdacesso = "FORENVINFO"   AND
                 craptab.tpregist = w-formas.cdfenvio
                 EXCLUSIVE-LOCK NO-ERROR.
            
            ASSIGN tel_cdfenvio = w-formas.cdfenvio.
                   
            DO   aux_contador = 1  TO  NUM-ENTRIES(craptab.dstextab):
                                        
                 IF   aux_contador = 1  THEN 
                      ASSIGN tel_dsfenvio = ENTRY(1,craptab.dstextab,",").
                 ELSE
                 IF   aux_contador = 2  THEN 
                      ASSIGN tel_dstabela = ENTRY(2,craptab.dstextab,",").
                 ELSE 
                      ASSIGN tel_tpregist = INT(ENTRY(3,craptab.dstextab,",")).
            END.
                     
            DISPLAY tel_cdfenvio WITH FRAME f_inform.
            UPDATE tel_dsfenvio tel_dstabela tel_tpregist WITH FRAME f_inform
            
            EDITING:

              READKEY.

              IF   FRAME-FIELD = "tel_dsfenvio"  OR 
                   FRAME-FIELD = "tel_dstabela"  THEN
                   IF   LASTKEY =  KEYCODE(",")   THEN
                        NEXT.
                   ELSE
                        APPLY LASTKEY.
              ELSE
                   APPLY LASTKEY.
               
            END.  /*  Fim do EDITING  */
            
            RUN Confirma.
            IF  aux_confirma = "S"  THEN
                ASSIGN craptab.dstextab = UPPER(tel_dsfenvio) + "," +
                                          tel_dstabela + 
                                          (IF tel_tpregist = 0 THEN "" 
                                           ELSE "," + STRING(tel_tpregist)).
        END.
   ELSE        
   IF   glb_cddopcao = "E"   THEN
        DO:
            FIND craptab WHERE ROWID(craptab) = aux_nrdrowid
                          EXCLUSIVE-LOCK NO-ERROR.
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     FIND FIRST gnfepri WHERE 
                                gnfepri.cddfrenv = craptab.tpregist 
                                NO-LOCK NO-ERROR.
                          
                     IF   AVAIL gnfepri  THEN
                          DO:
                              glb_cdcritic = 872.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                     ELSE
                          IF   AVAIL craptab  THEN
                               DELETE craptab.
                 
                     RELEASE craptab.
                 END.
        END.
   
   LEAVE.   
        
END.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.  
    
/*............................................................................*/

