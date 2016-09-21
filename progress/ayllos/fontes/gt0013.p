/* .............................................................................

   Programa: Fontes/gt0013.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego    
   Data    : Junho/2006.                       Ultima atualizacao: 06/12/2013
       
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Controle de Informativos e Formas de Envio Disponiveis.

   Alteracoes: 23/04/2007 - Alterado para buscar Forma de Envio da tabela
                            craptab (Diego).
                            
               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
               
               16/04/2012 - Fonte substituido por gt0013p.p (Tiago). 
               
               06/12/2013 - Inclusao de VALIDATE gnfepri (Carlos)
.............................................................................*/

{ includes/var_online.i }

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Incluir",
                                            "Alterar",
                                            "Excluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["I","A","E"]               NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.

DEF VAR tel_cdprogra AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR tel_nmrelato AS CHAR     FORMAT "x(25)"                        NO-UNDO.
DEF VAR tel_cdrelato AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR tel_cdfenvio AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR tel_dsfenvio AS CHAR     FORMAT "x(14)"                        NO-UNDO.
DEF VAR tel_cdperiod AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR tel_dsperiod AS CHAR     FORMAT "x(15)"                        NO-UNDO.
DEF VAR tel_flgtitul AS LOGICAL  FORMAT "Sim/Nao"                      NO-UNDO.

DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                          NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF TEMP-TABLE w-informa                                               NO-UNDO
    FIELD cdprogra    AS INT    FORMAT "zz9"
    FIELD cdrelato    AS INT    FORMAT "zz9"
    FIELD cdfenvio    AS INT    FORMAT "99"
    FIELD cdperiod    AS INT    FORMAT "9"
    FIELD envcpttl    AS INT    FORMAT "9"
    FIELD nmrelato    AS CHAR   FORMAT "x(25)"
    FIELD dsfenvio    AS CHAR   FORMAT "x(14)"
    FIELD dsperiod    AS CHAR   FORMAT "x(10)"
    FIELD nrdrowid    AS ROWID.

                      
DEF BUFFER b-gnfepri FOR gnfepri.


/* Browse Programas */
DEF QUERY q_programas FOR gnrlema.
    
DEF BROWSE b_programas QUERY q_programas    
    DISPLAY gnrlema.cdprogra  COLUMN-LABEL "Programa"
            gnrlema.cdrelato  COLUMN-LABEL "Rel."
            gnrlema.nmrelato  COLUMN-LABEL "Informativo"
            WITH 5 DOWN.
            
FORM b_programas 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 9 COLUMN 39 WIDTH 40 OVERLAY NO-BOX FRAME f_programas.
     

/* Browse Formas de Envio */
DEF QUERY q_envios FOR craptab.
    
DEF BROWSE b_envios QUERY q_envios    
    DISPLAY craptab.tpregist               COLUMN-LABEL "Cod."
            ENTRY(1,craptab.dstextab,",")  COLUMN-LABEL "Forma"  FORMAT "x(19)"
            WITH 5 DOWN.
            
FORM b_envios 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 12 COLUMN 39 WIDTH 30 OVERLAY NO-BOX FRAME f_envios.
     

/* Browse Periodos */
DEF QUERY q_periodos FOR craptab.
    
DEF BROWSE b_periodos QUERY q_periodos    
    DISPLAY craptab.tpregist  COLUMN-LABEL "Cod."
            craptab.dstextab  COLUMN-LABEL "Periodo"   FORMAT "x(15)"
            WITH 5 DOWN.
            
FORM b_periodos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 12 COLUMN 39 WIDTH 26 OVERLAY NO-BOX FRAME f_periodos.


DEF QUERY q_informativos FOR w-informa.

DEF BROWSE b_informativos QUERY q_informativos
    DISPLAY w-informa.cdprogra   COLUMN-LABEL "Prog."
            w-informa.cdrelato   COLUMN-LABEL "Rel."
            w-informa.nmrelato   COLUMN-LABEL "Informativo"
            w-informa.dsfenvio   COLUMN-LABEL "Forma Envio"
            w-informa.dsperiod   COLUMN-LABEL "Periodo"
            IF w-informa.envcpttl = 0 THEN "Sim" 
            ELSE "Nao"           COLUMN-LABEL "Todos Tit."
            WITH 5 DOWN.

FORM b_informativos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 7 COLUMN 3  WIDTH 79 OVERLAY NO-BOX FRAME f_browse.

FORM SKIP(2)
     "         Programa:" tel_cdprogra  
               HELP "Informe o codigo do programa ou Pressione F7 p/ listar." 
     SKIP
     "        Relatorio:" tel_cdrelato  SKIP               
     "      Informativo:" tel_nmrelato  SKIP
     "      Forma Envio:" tel_cdfenvio  
                    HELP "Informe a forma de envio ou Pressione F7 p/ listar." 
                    VALIDATE(CAN-FIND(craptab WHERE 
                                      craptab.cdcooper = 0              AND
                                      craptab.nmsistem = "CRED"         AND
                                      craptab.tptabela = "USUARI"       AND
                                      craptab.cdempres = 11             AND
                                      craptab.cdacesso = "FORENVINFO"   AND
                                      craptab.tpregist = INPUT tel_cdfenvio
                                      NO-LOCK ),
                                "893 - Codigo nao cadastrado.")      
     tel_dsfenvio    SKIP 
     "          Periodo:" tel_cdperiod 
                       HELP "Informe o periodo ou Pressione F7 p/ listar." 
                       VALIDATE(CAN-FIND(craptab WHERE 
                                         craptab.cdcooper = 0              AND
                                         craptab.nmsistem = "CRED"         AND
                                         craptab.tptabela = "USUARI"       AND
                                         craptab.cdempres = 11             AND
                                         craptab.cdacesso = "PERIODICID"   AND
                                         craptab.tpregist = INPUT tel_cdperiod
                                         NO-LOCK ),
                                   "893 - Codigo nao cadastrado.")
     tel_dsperiod 
     SKIP
     "  Todos Titulares:" tel_flgtitul
                       HELP "Informa (S)im  ou  (N)ao."
     SKIP(1)
     WITH ROW 8 COLUMN 21 WIDTH 50 OVERLAY NO-LABEL TITLE COLOR 
     MESSAGE "INFORMATIVO E FORMA DE ENVIO"  FRAME f_inform.


FORM SKIP(10)
     reg_dsdopcao[1]  AT 19  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 34  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 49  NO-LABEL FORMAT "x(7)"
     SKIP(1)
     WITH ROW 6 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     " INFORMATIVOS E FORMAS DE ENVIO DISPONIVEIS " FRAME f_regua.


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

/* Retorna Programa */    
ON RETURN OF b_programas
   DO:    
       IF   AVAIL gnrlema  THEN
            DO:
                ASSIGN tel_cdprogra = gnrlema.cdprogra
                       tel_cdrelato = gnrlema.cdrelato
                       tel_nmrelato = gnrlema.nmrelato.
       
                DISPLAY tel_cdprogra tel_cdrelato tel_nmrelato
                        WITH FRAME f_inform.
            END. 

       APPLY "GO".
   END.

   
/* Retorna Forma de Envio */    
ON RETURN OF b_envios
   DO:    
       IF   AVAIL craptab  THEN
            DO:
                ASSIGN tel_cdfenvio = craptab.tpregist
                       tel_dsfenvio = ENTRY(1,craptab.dstextab,",").
       
                DISPLAY tel_cdfenvio tel_dsfenvio WITH FRAME f_inform.
            END. 

       APPLY "GO".
   END.
   
ON LEAVE OF tel_cdfenvio IN FRAME f_inform  DO:

   FIND craptab WHERE 
        craptab.cdcooper = 0              AND
        craptab.nmsistem = "CRED"         AND
        craptab.tptabela = "USUARI"       AND
        craptab.cdempres = 11             AND
        craptab.cdacesso = "FORENVINFO"   AND
        craptab.tpregist = INPUT tel_cdfenvio NO-LOCK NO-ERROR.      
            
   IF   AVAIL craptab THEN
        DO:
            ASSIGN tel_dsfenvio = ENTRY(1,craptab.dstextab,",").
            
            DISPLAY tel_dsfenvio WITH FRAME f_inform.
        END.
END.


/* Retorna Periodo */    
ON RETURN OF b_periodos
   DO:    
       IF   AVAIL craptab  THEN
            DO:
                ASSIGN tel_cdperiod = craptab.tpregist
                       tel_dsperiod = craptab.dstextab.
       
                DISPLAY tel_cdperiod tel_dsperiod WITH FRAME f_inform.
            END. 

       APPLY "GO".
   END.
        
ON LEAVE OF tel_cdperiod IN FRAME f_inform  DO:

   FIND craptab WHERE 
        craptab.cdcooper = 0              AND
        craptab.nmsistem = "CRED"         AND
        craptab.tptabela = "USUARI"       AND
        craptab.cdempres = 11             AND
        craptab.cdacesso = "PERIODICID"   AND
        craptab.tpregist = INPUT tel_cdperiod NO-LOCK NO-ERROR.      
            
   IF   AVAIL craptab THEN
        DO:
            ASSIGN tel_dsperiod = craptab.dstextab.
            
            DISPLAY tel_dsperiod WITH FRAME f_inform.
        END.
END.


VIEW FRAME f_moldura.
PAUSE (0).  

DO WHILE TRUE: 
   
   ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
   
   DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
   
   EMPTY TEMP-TABLE w-informa.
                                             
   FOR EACH gnfepri NO-LOCK:
   
       CREATE w-informa.
       ASSIGN w-informa.cdprogra = gnfepri.cdprogra
              w-informa.cdrelato = gnfepri.cdrelato
              w-informa.cdfenvio = gnfepri.cddfrenv
              w-informa.cdperiod = gnfepri.cdperiod
              w-informa.envcpttl = gnfepri.envcpttl
              w-informa.nrdrowid = ROWID(gnfepri).
       
       FIND gnrlema WHERE gnrlema.cdprogra = gnfepri.cdprogra AND
                          gnrlema.cdrelato = gnfepri.cdrelato
                          NO-LOCK NO-ERROR.
            
       IF   AVAIL gnrlema  THEN
            ASSIGN w-informa.nmrelato = gnrlema.nmrelato.
            
       FIND craptab WHERE 
            craptab.cdcooper = 0              AND
            craptab.nmsistem = "CRED"         AND
            craptab.tptabela = "USUARI"       AND
            craptab.cdempres = 11             AND
            craptab.cdacesso = "FORENVINFO"   AND
            craptab.tpregist = gnfepri.cddfrenv NO-LOCK NO-ERROR.
           
       IF   AVAIL craptab  THEN
            ASSIGN w-informa.dsfenvio = ENTRY(1,craptab.dstextab,",").
            
       FIND craptab WHERE 
            craptab.cdcooper = 0              AND
            craptab.nmsistem = "CRED"         AND
            craptab.tptabela = "USUARI"       AND
            craptab.cdempres = 11             AND
            craptab.cdacesso = "PERIODICID"   AND
            craptab.tpregist = gnfepri.cdperiod NO-LOCK NO-ERROR.
       
       IF   AVAIL craptab  THEN
            ASSIGN w-informa.dsperiod = craptab.dstextab.
        
   END.
   
   OPEN QUERY q_informativos 
        FOR EACH w-informa NO-LOCK
            BY w-informa.cdprogra.
                                         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_informativos WITH FRAME f_browse. 
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "GT0013"   THEN
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
            ASSIGN tel_cdprogra = 0
                   tel_cdrelato = 0
                   tel_nmrelato = ""
                   tel_cdfenvio = 0
                   tel_dsfenvio = ""
                   tel_cdperiod = 0
                   tel_dsperiod = ""
                   tel_flgtitul = FALSE.
               
            DISPLAY tel_cdprogra tel_cdrelato tel_nmrelato tel_cdfenvio
                    tel_dsfenvio tel_cdperiod tel_dsperiod tel_flgtitul
                    WITH FRAME f_inform.
            
            DO WHILE TRUE:
            
               UPDATE tel_cdprogra tel_cdrelato WITH FRAME f_inform
               
               EDITING:

                 READKEY.

                 IF   LASTKEY = KEYCODE("F7") AND 
                      FRAME-FIELD = "tel_cdprogra"  THEN
                      DO:
                          OPEN QUERY q_programas 
                               FOR EACH gnrlema BY gnrlema.cdprogra.
                             
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_programas WITH FRAME f_programas.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_programas.
                          NEXT.
                       
                      END.
                 ELSE
                      APPLY LASTKEY.
                 
               END.  /*  Fim do EDITING  */

               FIND gnrlema WHERE gnrlema.cdprogra = tel_cdprogra  AND
                                  gnrlema.cdrelato = tel_cdrelato
                                  NO-LOCK NO-ERROR.
                                  
               IF   AVAIL gnrlema  THEN
                    DO:
                        ASSIGN tel_nmrelato = gnrlema.nmrelato.
                        
                        DISPLAY tel_nmrelato WITH FRAME f_inform.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 841.
                        RUN fontes/critic.p.
                        BELL. 
                        MESSAGE glb_dscritic. 
                        glb_cdcritic = 0.
                        tel_nmrelato = "".
                        DISPLAY tel_nmrelato WITH FRAME f_inform.
                        NEXT.
                    END.

               UPDATE tel_cdfenvio tel_cdperiod tel_flgtitul 
                      WITH FRAME f_inform
               
               EDITING:

                 READKEY.

                 IF   FRAME-FIELD = "tel_cdfenvio"  AND
                      LASTKEY = KEYCODE("F7")  THEN
                      DO:
                          OPEN QUERY q_envios 
                               FOR EACH craptab WHERE
                                        craptab.cdcooper = 0              AND
                                        craptab.nmsistem = "CRED"         AND
                                        craptab.tptabela = "USUARI"       AND
                                        craptab.cdempres = 11             AND
                                        craptab.cdacesso = "FORENVINFO"
                                        NO-LOCK.
                               
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_envios WITH FRAME f_envios.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_envios.
                          NEXT.
                      END.
                 ELSE
                 IF   FRAME-FIELD = "tel_cdperiod"  AND
                      LASTKEY = KEYCODE("F7")  THEN
                      DO:
                          OPEN QUERY q_periodos 
                               FOR EACH craptab WHERE
                                        craptab.cdcooper = 0              AND
                                        craptab.nmsistem = "CRED"         AND
                                        craptab.tptabela = "USUARI"       AND
                                        craptab.cdempres = 11             AND
                                        craptab.cdacesso = "PERIODICID"
                                        NO-LOCK.
                             
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_periodos WITH FRAME f_periodos.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_periodos.
                          NEXT.
                      END.
                 ELSE     
                      APPLY LASTKEY.
               
               END.  /*  Fim do EDITING  */
               
               FIND gnfepri WHERE gnfepri.cdprogra = tel_cdprogra AND
                                  gnfepri.cdrelato = tel_cdrelato AND
                                  gnfepri.cddfrenv = tel_cdfenvio AND
                                  gnfepri.cdperiod = tel_cdperiod
                                  NO-LOCK NO-ERROR.
                                          
               IF   AVAIL gnfepri  THEN
                    DO:
                        MESSAGE "Informativo ja Cadastrado".
                        NEXT.
                    END.
               
               RUN Confirma.
               IF   aux_confirma = "S"  THEN
                    DO:
                        CREATE gnfepri.
                        ASSIGN gnfepri.cddfrenv = tel_cdfenvio
                               gnfepri.cdperiod = tel_cdperiod
                               gnfepri.cdprogra = tel_cdprogra
                               gnfepri.cdrelato = tel_cdrelato
                               gnfepri.envcpttl = (IF tel_flgtitul = TRUE 
                                                      THEN 0 
                                                   ELSE 1).
                    
                        VALIDATE gnfepri.

                    END.
              
              LEAVE.
            END.
        END.
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:
            ASSIGN tel_cdprogra = w-informa.cdprogra
                   tel_cdrelato = w-informa.cdrelato
                   tel_nmrelato = w-informa.nmrelato
                   tel_cdfenvio = w-informa.cdfenvio
                   tel_dsfenvio = w-informa.dsfenvio
                   tel_cdperiod = w-informa.cdperiod
                   tel_dsperiod = w-informa.dsperiod
                   tel_flgtitul = (IF w-informa.envcpttl = 0  
                                      THEN TRUE
                                   ELSE FALSE).
               
            DISPLAY tel_cdprogra tel_cdrelato tel_nmrelato tel_cdfenvio
                    tel_dsfenvio tel_cdperiod tel_dsperiod tel_flgtitul
                    WITH FRAME f_inform.
                       
            DO WHILE TRUE:

               /* Para locar registro a ser ALTERADO na transacao */
               FIND gnfepri WHERE gnfepri.cdprogra = w-informa.cdprogra AND
                                  gnfepri.cdrelato = w-informa.cdrelato AND
                                  gnfepri.cddfrenv = w-informa.cdfenvio AND
                                  gnfepri.cdperiod = w-informa.cdperiod 
                                  EXCLUSIVE-LOCK NO-ERROR.
               
               UPDATE tel_cdfenvio tel_cdperiod tel_flgtitul 
                      WITH FRAME f_inform
               
               EDITING:

                 READKEY.

                 IF   FRAME-FIELD = "tel_cdfenvio"  AND
                      LASTKEY = KEYCODE("F7")  THEN
                      DO:
                          OPEN QUERY q_envios 
                               FOR EACH craptab WHERE
                                        craptab.cdcooper = 0              AND
                                        craptab.nmsistem = "CRED"         AND
                                        craptab.tptabela = "USUARI"       AND
                                        craptab.cdempres = 11             AND
                                        craptab.cdacesso = "FORENVINFO"
                                        NO-LOCK.
                               
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_envios WITH FRAME f_envios.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_envios.
                          NEXT.
                      END.
                 ELSE
                 IF   FRAME-FIELD = "tel_cdperiod"  AND
                      LASTKEY = KEYCODE("F7")  THEN
                      DO:
                          OPEN QUERY q_periodos 
                               FOR EACH craptab WHERE
                                        craptab.cdcooper = 0              AND
                                        craptab.nmsistem = "CRED"         AND
                                        craptab.tptabela = "USUARI"       AND
                                        craptab.cdempres = 11             AND
                                        craptab.cdacesso = "PERIODICID"
                                        NO-LOCK.
                             
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_periodos WITH FRAME f_periodos.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_periodos.
                          NEXT.
                      END.
                 ELSE     
                      APPLY LASTKEY.
               
               END.  /*  Fim do EDITING  */
                              
               FIND b-gnfepri WHERE b-gnfepri.cdprogra = tel_cdprogra AND
                                    b-gnfepri.cdrelato = tel_cdrelato AND
                                    b-gnfepri.cddfrenv = tel_cdfenvio AND
                                    b-gnfepri.cdperiod = tel_cdperiod AND
                                      ROWID(b-gnfepri) <> ROWID(gnfepri)
                                    NO-LOCK NO-ERROR.
               
               IF   AVAIL b-gnfepri  THEN
                    DO:
                        MESSAGE "Informativo ja Cadastrado".
                        NEXT.
                    END.

               RUN Confirma.
               IF   aux_confirma = "S"  THEN
                    ASSIGN gnfepri.cddfrenv = tel_cdfenvio
                           gnfepri.cdperiod = tel_cdperiod
                           gnfepri.envcpttl = IF tel_flgtitul = TRUE
                                                 THEN 0
                                              ELSE 1. 

               LEAVE.
            END.
        END.
   ELSE        
   IF   glb_cddopcao = "E"   THEN
        DO:
            FIND gnfepri WHERE ROWID(gnfepri) = aux_nrdrowid 
                 EXCLUSIVE-LOCK NO-ERROR.
            
            RUN Confirma.
            IF   aux_confirma = "S"  THEN
                 DO:
                     FIND crapifc WHERE 
                          crapifc.cdcooper = glb_cdcooper     AND
                          crapifc.cdprogra = gnfepri.cdprogra AND
                          crapifc.cdrelato = gnfepri.cdrelato AND
                          crapifc.cddfrenv = gnfepri.cddfrenv AND
                          crapifc.cdperiod = gnfepri.cdperiod
                          NO-LOCK NO-ERROR.
                          
                     IF   AVAIL crapifc  THEN
                          DO:
                              glb_cdcritic = 872.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              PAUSE 3 NO-MESSAGE.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                     ELSE
                          IF   AVAIL gnfepri  THEN
                               DELETE gnfepri.
                 
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
