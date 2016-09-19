/* .............................................................................

   Programa: Fontes/tab039.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Maio/2006                         Ultima Atualizacao: 13/12/2013

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar controle dos Grupos de Informativos.

   Alteracoes: 31/05/2006 - Consertado para possibilitar a utilizacao de "F2"
                            na tela, e modificadas opcoes "A" e "I" (Diego).
                            
               16/05/2007 - Modificado para gravar dados com letras maiusculas
                            na tabela (Diego).
              
               16/04/2012 - Fonte substituido por tab039p.p (Tiago). 
               
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


DEF VAR tel_cdinform AS INT  FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_dsinform AS CHAR FORMAT "x(25)"  CASE-SENSITIVE            NO-UNDO.
DEF VAR tel_dscompl1 AS CHAR FORMAT "x(50)"  CASE-SENSITIVE            NO-UNDO.
DEF VAR tel_dscompl2 AS CHAR FORMAT "x(50)"  CASE-SENSITIVE            NO-UNDO.

DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF TEMP-TABLE w-informa                                               NO-UNDO
    FIELD cdinform    AS INT    FORMAT "zz9"
    FIELD dsinform    AS CHAR   FORMAT "x(25)"
    FIELD nrdrowid    AS ROWID.


DEF QUERY q_informativos FOR w-informa.

DEF BROWSE b_informativos QUERY q_informativos
    DISPLAY w-informa.cdinform COLUMN-LABEL "Codigo"       FORMAT "z9"
            w-informa.dsinform COLUMN-LABEL "Grupo"        FORMAT "x(25)"
            WITH 5 DOWN.

FORM b_informativos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 7 COLUMN 22 OVERLAY NO-BOX FRAME f_browse.

FORM SKIP(1)
     "   Codigo:" tel_cdinform
     SKIP(1)
     "    Grupo:" tel_dsinform 
                  HELP "Informe o nome do Grupo"
                  VALIDATE(tel_dsinform <> "",
                                "375 - O campo deve ser preenchido")
     SKIP(1)
     "Descricao:" tel_dscompl1  HELP "Informe a descricao do Grupo"
                                VALIDATE(tel_dscompl1 <> "",
                                         "375 - O campo deve ser preenchido")
     SKIP
     "          " tel_dscompl2
     SKIP(1)
     WITH ROW 8 COLUMN 9 OVERLAY NO-LABEL FRAME f_inform.

FORM SKIP(10)
     reg_dsdopcao[1]  AT 11  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 26  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 41  NO-LABEL FORMAT "x(7)"
     SKIP(1)
     WITH ROW 6 COLUMN 8 WIDTH 65 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     " CADASTRO DE GRUPOS " FRAME f_regua.


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
           IF   AVAILABLE w-informa   THEN
                DO:
                    ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_informativos")
                           aux_nrdrowid = w-informa.nrdrowid.
                           
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
   
   EMPTY TEMP-TABLE w-informa.
   
   FOR EACH craptab WHERE 
            craptab.cdcooper = 0              AND
            craptab.nmsistem = "CRED"         AND
            craptab.tptabela = "USUARI"       AND
            craptab.cdempres = 11             AND
            craptab.cdacesso = "GRPINFORMA" NO-LOCK.
    
       CREATE w-informa.
       ASSIGN w-informa.cdinform = craptab.tpregist
              w-informa.nrdrowid = ROWID(craptab)
              w-informa.dsinform = ENTRY(1,craptab.dstextab,";").
       
   END.
   
   OPEN QUERY q_informativos 
        FOR EACH w-informa NO-LOCK.
                                             
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_informativos WITH FRAME f_browse.
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB039"   THEN
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
            ASSIGN tel_cdinform = 0
                   tel_dsinform = ""
                   tel_dscompl1 = ""
                   tel_dscompl2 = "".
                   
            FIND LAST craptab WHERE 
                      craptab.cdcooper = 0              AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "USUARI"       AND
                      craptab.cdempres = 11             AND
                      craptab.cdacesso = "GRPINFORMA"  
                      NO-LOCK NO-ERROR.  
            
            IF   AVAIL craptab  THEN
                 ASSIGN tel_cdinform = craptab.tpregist + 1.
            ELSE
                 ASSIGN tel_cdinform = 1.
            
            DISPLAY tel_cdinform WITH FRAME f_inform.
            
            UPDATE tel_dsinform tel_dscompl1 tel_dscompl2 WITH FRAME f_inform
            
            EDITING:

              READKEY.

              IF   FRAME-FIELD = "tel_dsinform"  OR 
                   FRAME-FIELD = "tel_dscompl1"  OR
                   FRAME-FIELD = "tel_dscompl2"  THEN
                   IF   LASTKEY =  KEYCODE(";")   THEN
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
                           craptab.cdacesso = "GRPINFORMA"   AND
                           craptab.tpregist = tel_cdinform
                           EXCLUSIVE-LOCK NO-ERROR. 
                     
                     IF   AVAIL craptab THEN
                          DO:
                              MESSAGE "Reistro ja Cadastrado".
                              PAUSE 2 NO-MESSAGE.
                              LEAVE.
                          END.
                       
                     CREATE craptab.
                     ASSIGN craptab.nmsistem = "CRED"
                            craptab.tptabela = "USUARI"
                            craptab.cdempres = 11
                            craptab.cdacesso = "GRPINFORMA"
                            craptab.cdcooper = 0
                            craptab.tpregist = tel_cdinform
                            craptab.dstextab = UPPER(tel_dsinform) + ";" + 
                                               UPPER(tel_dscompl1) + 
                                               (IF tel_dscompl2 = "" THEN "" 
                                                ELSE ";" + UPPER(tel_dscompl2)).
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
                 craptab.cdacesso = "GRPINFORMA"   AND
                 craptab.tpregist = w-informa.cdinform
                 EXCLUSIVE-LOCK NO-ERROR.
            
            ASSIGN tel_cdinform = w-informa.cdinform
                   tel_dsinform = ""
                   tel_dscompl1 = ""
                   tel_dscompl2 = "".
            
            DO  aux_contador = 1  TO  NUM-ENTRIES(craptab.dstextab,";"):
       
                IF   aux_contador = 1  THEN
                     ASSIGN tel_dsinform = ENTRY(1,craptab.dstextab,";").
                ELSE
                IF   aux_contador = 2  THEN
                     ASSIGN tel_dscompl1 = ENTRY(2,craptab.dstextab,";").
                ELSE
                     ASSIGN tel_dscompl2 = ENTRY(3,craptab.dstextab,";").
            END. 
            
            DISPLAY tel_cdinform WITH FRAME f_inform.
            
            UPDATE tel_dsinform tel_dscompl1 tel_dscompl2 WITH FRAME f_inform
            
            EDITING:

              READKEY.

              IF   FRAME-FIELD = "tel_dsinform"  OR 
                   FRAME-FIELD = "tel_dscompl1"  OR
                   FRAME-FIELD = "tel_dscompl2"  THEN
                   IF   LASTKEY =  KEYCODE(";")   THEN
                        NEXT.
                   ELSE
                        APPLY LASTKEY.
              ELSE
                   APPLY LASTKEY.
               
            END.  /*  Fim do EDITING  */
            
            RUN Confirma.
            IF  aux_confirma = "S"  THEN
                ASSIGN craptab.dstextab = UPPER(tel_dsinform) + ";" + 
                                          UPPER(tel_dscompl1) + 
                                          (IF tel_dscompl2 = "" THEN ""
                                           ELSE ";" + UPPER(tel_dscompl2)).
            RELEASE craptab.
                    
        END.
   ELSE        
   IF   glb_cddopcao = "E"   THEN
        DO:
            FIND craptab WHERE ROWID(craptab) = aux_nrdrowid
                 EXCLUSIVE-LOCK NO-ERROR.
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     FIND FIRST gnrlema WHERE 
                                gnrlema.cdgrprel = craptab.tpregist 
                                NO-LOCK NO-ERROR.
                          
                     IF   AVAIL gnrlema  THEN
                          DO:
                              glb_cdcritic = 872.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              IF   AVAIL craptab  THEN
                                   DELETE craptab.
                          END.
                 
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
