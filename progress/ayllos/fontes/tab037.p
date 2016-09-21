/* .............................................................................

   Programa: Fontes/tab037.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Maio/2006                         Ultima Atualizacao: 06/03/2014

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Cadastro de Operadoras de Telefonia.

   Alteracoes: 30/05/2006 - Concertado para possibilitar a utilizacao de "F2"
                            na tela (Diego).
                            
               19/12/2006 - Alterado para permitir informar codigo na inclusao
                            (Diego).
                            
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)              
                            
               06/03/2014 - Convertido craptab.tpregist para INTEGER. (Reinert)                            

..............................................................................*/

{ includes/var_online.i }

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Incluir",
                                            "Alterar",
                                            "Excluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["I","A","E"]               NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.


DEF VAR tel_cdinform AS INT  FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_dsinform AS CHAR FORMAT "x(24)"  CASE-SENSITIVE            NO-UNDO.

DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.


DEF QUERY q_informativos FOR craptab.

DEF BROWSE b_informativos QUERY q_informativos
    DISPLAY craptab.tpregist COLUMN-LABEL "Codigo"       FORMAT "z9"
            craptab.dstextab COLUMN-LABEL "Descricao"    FORMAT "x(25)"
            WITH 5 DOWN.

FORM b_informativos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 7 COLUMN 22 OVERLAY NO-BOX FRAME f_browse.

FORM SKIP(1)
     "Codigo Descricao" AT 2
     SKIP
     tel_cdinform       AT 4  
     tel_dsinform       AT 9  HELP "Informe o nome do Informativo"
                              VALIDATE(tel_dsinform <> "",
                                       "375 - O campo deve ser preenchido")
     SKIP(2)
     WITH ROW 8 COLUMN 24 OVERLAY NO-LABEL FRAME f_inform.

FORM SKIP(10)
     reg_dsdopcao[1]  AT 11  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 26  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 41  NO-LABEL FORMAT "x(7)"
     SKIP(1)
     WITH ROW 6 COLUMN 11 WIDTH 60 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     " OPERADORAS DE TELEFONIA "  FRAME f_regua.


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
           IF   AVAILABLE craptab   THEN
                DO:
                    ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_informativos")
                           aux_nrdrowid = ROWID(craptab).
                           
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
   
   OPEN QUERY q_informativos 
        FOR EACH craptab WHERE 
                 craptab.cdcooper = 0              AND
                 craptab.nmsistem = "CRED"         AND
                 craptab.tptabela = "USUARI"       AND
                 craptab.cdempres = 11             AND
                 craptab.cdacesso = "OPETELEFON" NO-LOCK.
                                         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_informativos WITH FRAME f_browse.
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB037"   THEN
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
            DO WHILE TRUE:
            
               UPDATE  tel_cdinform tel_dsinform WITH FRAME f_inform.
               
               FIND  craptab WHERE craptab.cdcooper = 0              AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "USUARI"       AND
                                   craptab.cdempres = 11             AND
                                   craptab.cdacesso = "OPETELEFON"   AND
                                   craptab.tpregist = tel_cdinform
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
                    
               LEAVE.
               
            END.
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     CREATE craptab.
                     ASSIGN craptab.nmsistem = "CRED"
                            craptab.tptabela = "USUARI"
                            craptab.cdempres = 11
                            craptab.cdacesso = "OPETELEFON"
                            craptab.cdcooper = 0
                            craptab.tpregist = tel_cdinform
                            craptab.dstextab = tel_dsinform.
                     VALIDATE craptab.

                 END.
        END.
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:
            ASSIGN tel_cdinform = craptab.tpregist
                   tel_dsinform = craptab.dstextab.
                     
            DISPLAY tel_cdinform WITH FRAME f_inform.
            UPDATE tel_dsinform  WITH FRAME f_inform.
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     FIND craptab WHERE 
                          craptab.cdcooper = 0              AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "USUARI"       AND
                          craptab.cdempres = 11             AND
                          craptab.cdacesso = "OPETELEFON"   AND
                          craptab.tpregist = tel_cdinform
                          EXCLUSIVE-LOCK NO-ERROR.  
                    
                     ASSIGN craptab.dstextab = tel_dsinform.
                     
                     RELEASE craptab.
                 END.
        END.
   ELSE        
   IF   glb_cddopcao = "E"   THEN
        DO:
            FIND craptab WHERE ROWID(craptab) = aux_nrdrowid
                          EXCLUSIVE-LOCK NO-ERROR.
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     FIND FIRST craptfc WHERE
                                craptfc.cdcooper = glb_cdcooper AND
                                craptfc.cdopetfn = INTE(craptab.tpregist)
                                NO-LOCK NO-ERROR.
                                
                     IF   AVAIL craptfc  THEN
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
    
/*...........................................................................*/

