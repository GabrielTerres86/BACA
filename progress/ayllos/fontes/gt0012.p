/* .............................................................................

   Programa: Fontes/gt0012.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego    
   Data    : Junho/2006.                         Ultima atualizacao: 06/12/2013    
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Controle de Informativos Disponiveis.

   Alteracoes: 16/05/2007 - Modificado para gravar os dados com letras
                            maiusculas na tabela (Diego).
   
               16/04/2012 - Fonte substituido por gt0012p.p (Tiago). 
               
               06/12/2013 - Inclusao de VALIDATE gnrlema (Carlos)
.............................................................................*/

{ includes/var_online.i }

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Incluir",
                                            "Alterar",
                                            "Excluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["I","A","E"]               NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.


DEF VAR tel_cdinform AS INT  FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_dsinform AS CHAR FORMAT "x(25)"                            NO-UNDO.
DEF VAR tel_dscompl1 AS CHAR FORMAT "x(51)"                            NO-UNDO.
DEF VAR tel_dscompl2 AS CHAR FORMAT "x(28)"                            NO-UNDO.
DEF VAR tel_cdprogra AS INT  FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_nmrelato AS CHAR FORMAT "x(25)"                            NO-UNDO.
DEF VAR tel_cdrelato AS INT  FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_cdtipdoc AS INT  FORMAT "zz,zz9"                           NO-UNDO.
DEF VAR tel_flgcodem AS LOGICAL  FORMAT "Sim/Nao"                      NO-UNDO.

DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF BUFFER b-gnrlema FOR gnrlema.

DEF TEMP-TABLE w-informa                                               NO-UNDO
    FIELD cdinform    AS INT    FORMAT "zz9"
    FIELD dsinform    AS CHAR   FORMAT "x(25)".

DEF QUERY q_grupos FOR w-informa.
    
DEF BROWSE b_grupos QUERY q_grupos    
    DISPLAY w-informa.cdinform  COLUMN-LABEL "Cod."
            w-informa.dsinform  COLUMN-LABEL "Grupo"
            WITH 5 DOWN.
            
FORM b_grupos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 9 COLUMN 25  WIDTH 36 OVERLAY NO-BOX FRAME f_grupo.


DEF QUERY q_informativos FOR gnrlema, w-informa.

DEF BROWSE b_informativos QUERY q_informativos
    DISPLAY gnrlema.cdprogra   COLUMN-LABEL "Prog."
            gnrlema.cdrelato   COLUMN-LABEL "Rel."
            w-informa.dsinform COLUMN-LABEL "Grupo"  FORMAT "x(20)"
            gnrlema.nmrelato   COLUMN-LABEL "Informativo"
            gnrlema.cdtipdoc   COLUMN-LABEL "Tipo"
            gnrlema.flgcodem   COLUMN-LABEL "Sol.Codigo"
            WITH 5 DOWN.

FORM b_informativos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 7 COLUMN 4  WIDTH 80 OVERLAY NO-BOX FRAME f_browse.

FORM SKIP(1)
     "        Programa:" tel_cdprogra  
                      HELP "Informe o codigo do programa." SKIP
     "       Relatorio:" tel_cdrelato
                      HELP "Informe o codigo do relatorio." SKIP
     "           Grupo:" tel_cdinform 
                         HELP "Informe o codigo do grupo ou F7 p/ Listar."
                         VALIDATE(CAN-FIND(w-informa WHERE w-informa.cdinform = 
                                                           INPUT tel_cdinform),
                                           "878 - Codigo nao cadastrado")
     tel_dsinform                      SKIP
     "     Informativo:" tel_nmrelato  
                      HELP "Informe o nome do Informativo." SKIP
     "       Descricao:" tel_dscompl1  
                      HELP "Descricao do Informativo." SKIP
     "                 " tel_dscompl2  
                      HELP "Descricao do Informativo." SKIP
     "            Tipo:" tel_cdtipdoc  
                      HELP "Informe o tipo de documento impresso pela laser."
     SKIP
     "Solicitar Codigo:" tel_flgcodem
            HELP "Informe se necessita de codigo para emissao de relatorio."
     SKIP(1)
     WITH ROW 8 COLUMN 7 OVERLAY NO-LABEL TITLE COLOR MESSAGE "INFORMATIVO"
     FRAME f_inform.

FORM SKIP(10)
     reg_dsdopcao[1]  AT 17  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 32  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 47  NO-LABEL FORMAT "x(7)"
     SKIP(1)
     WITH ROW 6 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     " INFORMATIVOS DISPONIVEIS " FRAME f_regua.


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
           IF   AVAILABLE gnrlema   THEN
                DO:
                    ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_informativos")
                           aux_nrdrowid = ROWID(gnrlema).
                   
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

/* Retorna Grupo */    
ON RETURN OF b_grupos
   DO:    
       IF   AVAIL w-informa  THEN
            DO:
                ASSIGN tel_cdinform = w-informa.cdinform
                       tel_dsinform = w-informa.dsinform. 
       
                DISPLAY tel_cdinform tel_dsinform WITH FRAME f_inform.
            END. 

       APPLY "GO".
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
       ASSIGN w-informa.cdinform = craptab.tpregist.
       
       DO  aux_contador = 1  TO  NUM-ENTRIES(craptab.dstextab,";"):
       
           ASSIGN w-informa.dsinform = ENTRY(1,craptab.dstextab,";").
       END.  

   END.                                        
                       
   OPEN QUERY q_informativos 
        FOR EACH gnrlema NO-LOCK,
            FIRST w-informa WHERE 
                  w-informa.cdinform = gnrlema.cdgrprel NO-LOCK
                  BY gnrlema.cdprogra.
                                         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_informativos WITH FRAME f_browse. 
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "GT0012"   THEN
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
                   tel_cdprogra = 0
                   tel_cdrelato = 0
                   tel_nmrelato = ""
                   tel_dscompl1 = ""
                   tel_dscompl2 = ""
                   tel_cdtipdoc = 0
                   tel_flgcodem = FALSE.
               
            DISPLAY tel_dsinform tel_cdprogra tel_cdrelato
                    tel_nmrelato tel_dscompl1 tel_dscompl2
                    tel_cdtipdoc tel_flgcodem 
                    WITH FRAME f_inform.
            
            DO WHILE TRUE:
            
               UPDATE tel_cdprogra tel_cdrelato tel_cdinform   
                      WITH FRAME f_inform
               
               EDITING:

                 READKEY.

                 IF   LASTKEY = KEYCODE("F7") AND 
                      FRAME-FIELD = "tel_cdinform"  THEN
                      DO:
                          OPEN QUERY q_grupos FOR EACH w-informa.
                             
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_grupos WITH FRAME f_grupo.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_grupo.
                          NEXT.
                       
                      END.
                 ELSE
                      APPLY LASTKEY.
               
               END.  /*  Fim do EDITING  */
            
               FIND FIRST w-informa WHERE w-informa.cdinform = tel_cdinform 
                    NO-LOCK NO-ERROR.
            
               IF   AVAILABLE w-informa  THEN
                    DO:
                        ASSIGN tel_dsinform = w-informa.dsinform.
                        DISPLAY tel_dsinform WITH FRAME f_inform.
                    END.
            
               UPDATE tel_nmrelato tel_dscompl1 tel_dscompl2 tel_cdtipdoc
                      tel_flgcodem WITH FRAME f_inform.
               
               FIND gnrlema WHERE gnrlema.cdprogra = tel_cdprogra AND
                                  gnrlema.cdrelato = tel_cdrelato 
                                  NO-LOCK NO-ERROR.
                               
               IF   AVAIL gnrlema  THEN
                    DO:
                        glb_cdcritic = 873.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               RUN Confirma.
               IF   aux_confirma = "S"  THEN
                    DO:
                        CREATE gnrlema.
                        ASSIGN gnrlema.cdgrprel = tel_cdinform
                               gnrlema.cdprogra = tel_cdprogra
                               gnrlema.cdrelato = tel_cdrelato
                               gnrlema.nmrelato = UPPER(tel_nmrelato)
                               gnrlema.dsrelato = UPPER(tel_dscompl1) + " " +
                                                  UPPER(tel_dscompl2)
                               gnrlema.cdtipdoc = tel_cdtipdoc
                               gnrlema.flgcodem = tel_flgcodem.

                        VALIDATE gnrlema.

                    END.

               LEAVE.

            END.
        END.
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:
            ASSIGN tel_cdinform = w-informa.cdinform
                   tel_dsinform = w-informa.dsinform
                   tel_cdprogra = gnrlema.cdprogra
                   tel_cdrelato = gnrlema.cdrelato
                   tel_nmrelato = gnrlema.nmrelato
                   tel_dscompl1 = SUBSTRING(gnrlema.dsrelato,1,51)
                   tel_dscompl2 = SUBSTRING(gnrlema.dsrelato,52,28)
                   tel_cdtipdoc = gnrlema.cdtipdoc
                   tel_flgcodem = gnrlema.flgcodem.
               
            DISPLAY tel_dsinform tel_cdprogra tel_cdrelato
                    tel_nmrelato tel_dscompl1 tel_dscompl2
                    tel_cdtipdoc tel_flgcodem 
                    WITH FRAME f_inform.
           
            DO WHILE TRUE:

               /* Para Locar o registro na trasacao */
               FIND gnrlema WHERE gnrlema.cdprogra = tel_cdprogra  AND
                                  gnrlema.cdrelato = tel_cdrelato
                                  EXCLUSIVE-LOCK NO-ERROR.
               
               UPDATE tel_cdinform WITH FRAME f_inform
               
               EDITING:

                 READKEY.

                 IF   LASTKEY = KEYCODE("F7") AND 
                      FRAME-FIELD = "tel_cdinform"  THEN
                      DO:
                          OPEN QUERY q_grupos FOR EACH w-informa.
                             
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_grupos WITH FRAME f_grupo.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_grupo.
                          NEXT.
                       
                      END.
                 ELSE
                      APPLY LASTKEY.
               
               END.  /*  Fim do EDITING  */
            
               FIND FIRST w-informa WHERE w-informa.cdinform = tel_cdinform 
                    NO-LOCK NO-ERROR.
            
               IF   AVAILABLE w-informa  THEN
                    DO:
                        ASSIGN tel_dsinform = w-informa.dsinform.
                        DISPLAY tel_dsinform WITH FRAME f_inform.
                    END.
            
               UPDATE tel_nmrelato tel_dscompl1 tel_dscompl2 tel_cdtipdoc
                      tel_flgcodem WITH FRAME f_inform.
               
               RUN Confirma.
               IF   aux_confirma = "S"  THEN
                    ASSIGN gnrlema.cdgrprel = tel_cdinform
                           gnrlema.nmrelato = UPPER(tel_nmrelato)
                           gnrlema.dsrelato = UPPER(tel_dscompl1) + " " +
                                              UPPER(tel_dscompl2)
                           gnrlema.cdtipdoc = tel_cdtipdoc
                           gnrlema.flgcodem = tel_flgcodem.
                   
               LEAVE.

            END.
        END.
   ELSE        
   IF   glb_cddopcao = "E"   THEN
        DO:
            FIND gnrlema WHERE ROWID(gnrlema) = aux_nrdrowid
                         EXCLUSIVE-LOCK NO-ERROR.
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     FIND FIRST gnfepri WHERE 
                                gnfepri.cdprogra = gnrlema.cdprogra AND
                                gnfepri.cdrelato = gnrlema.cdrelato
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
                          IF   AVAIL gnrlema  THEN
                               DELETE gnrlema.
                 
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
            CLEAR FRAME f_cadgps.
        END. /* Mensagem de confirmacao */

END PROCEDURE.  
    
/*............................................................................*/

