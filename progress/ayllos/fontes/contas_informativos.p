/* .............................................................................

   Programa: Fontes/contas_informativos.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego    
   Data    : Marco/2007.                     Ultima atualizacao: 08/04/2014
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar controle sobre informativos que o cooperado deseja
               receber. 

   Alteracoes: 01/08/2007 - Efetuados acertos no LOG e no "F7" de enderecos
                            (Diego).
                            
               10/09/2007 - Permitir o envio de Extrato somente para tipos de
                            conta <> de 5,6,7,17,18 (Diego). 
                            
               29/04/2010 - Adaptacao para uso de BO's (Jose Luis, DB1)  
               
               08/04/2014 - Ajuste "WHOLE-INDEX" na leitura da tt-crapcra
                            (Adriano).

.............................................................................*/

{ sistema/generico/includes/b1wgen0064tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }
{ includes/var_contas.i }

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]               NO-UNDO.
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.

DEF VAR tel_nmrelato AS CHAR     FORMAT "x(25)"                        NO-UNDO.
DEF VAR tel_dsfenvio AS CHAR     FORMAT "x(18)"                        NO-UNDO.
DEF VAR tel_dsperiod AS CHAR     FORMAT "x(15)"                        NO-UNDO.
DEF VAR tel_recebime AS CHAR     FORMAT "x(30)"                        NO-UNDO.

DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdseqinc AS INT                                            NO-UNDO.
DEF VAR aux_cdperiod AS INT                                            NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_dsperiod AS CHAR                                           NO-UNDO.
DEF VAR aux_dsfenvio AS CHAR                                           NO-UNDO.
DEF VAR ant_cdendere AS INT                                            NO-UNDO.
DEF VAR ant_dsendere AS CHAR                                           NO-UNDO.
DEF VAR ant_cdperiod AS INT                                            NO-UNDO.
DEF VAR ant_dsperiod AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0064 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                         NO-UNDO.
DEF VAR aux_qtregist AS INTEGER                                        NO-UNDO.
DEF VAR aux_titfrenv AS CHAR                                           NO-UNDO.
DEF VAR aux_cddfrenv AS INTEGER                                        NO-UNDO.
DEF VAR aux_cdprogra AS INTEGER                                        NO-UNDO.
DEF VAR aux_cdrelato AS INTEGER                                        NO-UNDO.
DEF VAR aux_cdselimp AS INTEGER                                        NO-UNDO.
DEF VAR aux_sqincant AS INTEGER                                        NO-UNDO.

/* Handle para a BO */
DEFINE VARIABLE h-b1crapcra      AS HANDLE                             NO-UNDO.

DEF TEMP-TABLE cratcra  NO-UNDO LIKE crapcra.

DEF TEMP-TABLE tt-informativos-aux NO-UNDO LIKE tt-informativos.

DEF TEMP-TABLE tt-periodo
    FIELD cdperiod    AS INT     FORMAT "9"
    FIELD dsperiod    AS CHAR.

/* Forma Envio */
DEF QUERY q_formaenv FOR tt-recebto.

DEF BROWSE b_formaenv QUERY q_formaenv
    DISPLAY tt-recebto.dsrecebe NO-LABEL FORMAT "x(35)" 
           WITH 8 DOWN NO-BOX. 

FORM b_formaenv 
    HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 12 COLUMN 38 OVERLAY FRAME f_formaenv TITLE aux_titfrenv.

/* Browse Periodos */
DEF QUERY q_periodos FOR tt-periodo.
    
DEF BROWSE b_periodos QUERY q_periodos    
    DISPLAY tt-periodo.dsperiod  NO-LABEL FORMAT "x(20)"
            WITH 4 DOWN NO-BOX.
            
FORM b_periodos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 15 COLUMN 34  OVERLAY TITLE "PERIODO" FRAME f_periodos.

/* Informativos cooperado */ 
DEF QUERY q_informativos FOR tt-crapcra.

DEF BROWSE b_informativos QUERY q_informativos
    DISPLAY tt-crapcra.nmrelato COLUMN-LABEL "Informativo" FORMAT "x(16)"
            tt-crapcra.dsdfrenv COLUMN-LABEL "Forma Envio" FORMAT "x(15)"
            tt-crapcra.dsperiod COLUMN-LABEL "Periodo"     FORMAT "x(10)"
            tt-crapcra.dsrecebe COLUMN-LABEL "Recebimento" FORMAT "x(30)"
            WITH 5 DOWN NO-BOX.

FORM b_informativos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 11 COLUMN 2 OVERLAY NO-BOX  FRAME f_browse.

/* Informativos Cooperativa */ 
DEF QUERY q_informa FOR tt-informativos.

DEF BROWSE b_informa QUERY q_informa
    DISPLAY tt-informativos.nmrelato COLUMN-LABEL "Informativo" FORMAT "x(25)"
            tt-informativos.dsdfrenv COLUMN-LABEL "Forma Envio" FORMAT "x(18)"
            tt-informativos.dsperiod COLUMN-LABEL "Periodo"     FORMAT "x(15)"
            tt-informativos.envcobrg COLUMN-LABEL "Sugerido"
            WITH 7 DOWN.

FORM b_informa 
     HELP "Pressione ENTER p/ INCLUIR informativo a ser enviado ao cooperado."
     WITH ROW 11 CENTERED  WIDTH 75 OVERLAY NO-BOX FRAME f_informa.


FORM SKIP(9)
     reg_dsdopcao[1]  AT 19  NO-LABEL FORMAT "x(7)" 
     reg_dsdopcao[2]  AT 36  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 53  NO-LABEL FORMAT "x(7)"
     WITH ROW 10 WIDTH 80 OVERLAY SIDE-LABELS CENTERED 
     TITLE " RECEBIMENTO INFORMATIVOS " FRAME f_regua.

FORM SKIP(1)
     tel_nmrelato  AT 5   LABEL "Informativo"
     SKIP(1)
     tel_dsfenvio  AT 5   LABEL "Forma Envio"
     SKIP(1)
     tel_dsperiod  AT 9  LABEL "Periodo"
              HELP "Pressione F7 para ESCOLHER o periodo de recebimento."
     SKIP(1)
     tel_recebime  AT 5  LABEL "Recebimento"
              VALIDATE(tel_recebime <> "", "375 - O campo deve ser preenchido")
              HELP "Pressione F7 para ESCOLHER onde recebera o informativo."
     SKIP(1)
     WITH ROW 11 COLUMN 16 WIDTH 50 OVERLAY SIDE-LABELS  
     FRAME f_inf_cooperado.


ON RETURN OF b_formaenv
   DO:
       IF   AVAIL tt-recebto  THEN
            DO:
                ASSIGN aux_cdseqinc = tt-recebto.cdrecebe
                       tel_recebime = tt-recebto.dsrecebe.
                       
                DISPLAY tel_recebime WITH FRAME f_inf_cooperado.
            END.

       APPLY "GO".
   END.

ON RETURN OF b_periodos
   DO:    
       IF   AVAIL tt-periodo  THEN
            DO:
                ASSIGN aux_cdperiod = tt-periodo.cdperiod
                       tel_dsperiod = tt-periodo.dsperiod.
       
                DISPLAY tel_dsperiod WITH FRAME f_inf_cooperado.
            END. 

       APPLY "GO".
   END.

ON RETURN OF b_informa
   DO:
       /* inclusao */
       IF  AVAIL tt-informativos  THEN
           DO:
               ASSIGN 
                   aux_cdseqinc = 0
                   tel_recebime = ""
                   tel_nmrelato = tt-informativos.nmrelato
                   tel_dsfenvio = tt-informativos.dsdfrenv
                   tel_dsperiod = tt-informativos.dsperiod
                   aux_cddfrenv = tt-informativos.cddfrenv
                   aux_cdprogra = tt-informativos.cdprogra
                   aux_cdrelato = tt-informativos.cdrelato
                   aux_cdperiod = tt-informativos.cdperiod
                   aux_cdselimp = 0.

               RUN Valida_Relatorios.

               IF  RETURN-VALUE <> "OK" THEN
                   RETURN NO-APPLY.

               HIDE MESSAGE NO-PAUSE.

               DISPLAY tel_nmrelato tel_dsfenvio tel_dsperiod 
                   WITH FRAME f_inf_cooperado.
                        
               UPDATE tel_recebime WITH FRAME f_inf_cooperado
                
               EDITING:
                        
                 DO WHILE TRUE:
                    
                    READKEY PAUSE 1.

                    IF  NOT CAN-DO("RETURN,TAB,BACKSPACE," +
                                   "BACK-TAB,CURSOR-LEFT," +
                                   "END-ERROR,HELP,GO,RECALL",
                                   KEYFUNCTION(LASTKEY))  THEN
                        LEAVE.
                                                      
                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            RUN Busca_Forma_Envio
                                ( INPUT aux_cddfrenv,
                                  INPUT 0 ).

                            OPEN QUERY q_formaenv FOR EACH tt-recebto.

                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               UPDATE b_formaenv WITH FRAME f_formaenv.
                               LEAVE.
                            END.
                        END.

                    APPLY LASTKEY.
                    
                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 IF  GO-PENDING THEN
                     DO:
                         ASSIGN INPUT tel_recebime.

                         RUN Valida_Dados.
    
                         IF  RETURN-VALUE <> "OK" THEN
                             NEXT.
                     END.
               END.  /*  Fim do EDITING  */.
               
               RUN Confirma.
               IF   aux_confirma = "S"  THEN
                    DO:
                       RUN Grava_Dados.
    
                       IF  RETURN-VALUE <> "OK" THEN
                           RETURN NO-APPLY.
                    END.
           END.
                
       APPLY "GO".
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
           IF   AVAILABLE tt-crapcra   THEN
                DO:
                    ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_informativos") 
                           aux_nrdrowid = tt-crapcra.nrdrowid.
                           
                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_informativos:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdlinha = 0
                       aux_nrdrowid = ?.
                
           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].

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
                               
DO WHILE TRUE: 
   /* BO principal */
   IF  NOT VALID-HANDLE(h-b1wgen0064) THEN
       RUN sistema/generico/procedures/b1wgen0064.p
           PERSISTENT SET h-b1wgen0064.
   
   /* BO para consultas/zoom */
   IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
       RUN sistema/generico/procedures/b1wgen0059.p 
           PERSISTENT SET h-b1wgen0059.

   ASSIGN glb_nmrotina = "INFORMATIVOS"
          glb_cddopcao = reg_cddopcao[reg_contador].
   
   DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   ASSIGN 
       glb_cddopcao = "C"
       aux_nrdrowid = ?.

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.
   
   OPEN QUERY q_informativos FOR EACH tt-crapcra 
                                WHERE tt-crapcra.cdcooper = glb_cdcooper
                                      NO-LOCK BY tt-crapcra.cdprogra.
                                         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_informativos WITH FRAME f_browse. 
      LEAVE.
   END.
   
   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
           
   VIEW FRAME f_browse. 
   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_informativos TO ROW(aux_nrdlinha).
   
   { includes/acesso.i }
   
   IF   glb_cddopcao = "I"   THEN
        DO: 
            ASSIGN
                aux_cddfrenv = 0
                aux_cdprogra = 0
                aux_cdrelato = 0
                aux_cdperiod = 0
                aux_nrdrowid = ?.

            RUN Busca_Relatorios.

            DO WHILE TRUE:
            
               OPEN QUERY q_informa FOR EACH tt-informativos NO-LOCK
                                        BY tt-informativos.cdprogra.
                                         
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                  UPDATE b_informa WITH FRAME f_informa. 
                  LEAVE.

               END.

               LEAVE.
               
            END. /* Do While */
        END.     
   ELSE        
   IF   glb_cddopcao = "A"   THEN
        DO:
            /* Se foi selecionado algum registro */
            IF  aux_nrdrowid <> ?   THEN
                DO:
                    ASSIGN tel_nmrelato = tt-crapcra.nmrelato
                           tel_dsfenvio = tt-crapcra.dsdfrenv
                           tel_dsperiod = tt-crapcra.dsperiod
                           tel_recebime = tt-crapcra.dsrecebe
                           aux_cddfrenv = tt-crapcra.cddfrenv
                           aux_cdperiod = tt-crapcra.cdperiod
                           aux_cdseqinc = tt-crapcra.cdseqinc
                           ant_cdendere = tt-crapcra.cdseqinc
                           aux_cdprogra = tt-crapcra.cdprogra
                           aux_cdrelato = tt-crapcra.cdrelato.
                         
                    DISPLAY tel_nmrelato tel_dsfenvio tel_dsperiod 
                            WITH FRAME f_inf_cooperado.
                       
                    UPDATE tel_dsperiod tel_recebime WITH FRAME f_inf_cooperado
                
                    EDITING:
                        
                      DO WHILE TRUE:
                    
                         READKEY PAUSE 1.
                           
                         IF  NOT CAN-DO("RETURN,TAB,BACKSPACE," +
                                        "BACK-TAB,CURSOR-LEFT," +
                                        "END-ERROR,HELP,GO,RECALL",
                                        KEYFUNCTION(LASTKEY))  THEN
                             LEAVE.
                                                      
                         IF  FRAME-FIELD = "tel_dsperiod"  AND
                             LASTKEY = KEYCODE("F7")  THEN
                             DO:
                                 EMPTY TEMP-TABLE tt-periodo.

                                 RUN Busca_Periodos.
                                 
                                 OPEN QUERY q_periodos FOR EACH tt-periodo. 
                             
                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    UPDATE b_periodos WITH FRAME f_periodos.
                                    LEAVE.
                                 END.
                          
                                 HIDE FRAME f_periodos.
                                 NEXT.
                             END.
                         ELSE
                         IF  FRAME-FIELD = "tel_recebime"  AND
                             LASTKEY = KEYCODE("F7")  THEN
                             DO:
                                 RUN Busca_Forma_Envio
                                     ( INPUT aux_cddfrenv,
                                       INPUT 0 ).
    
                                 OPEN QUERY q_formaenv FOR EACH tt-recebto.
    
                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    UPDATE b_formaenv WITH FRAME f_formaenv.
                                    LEAVE.
                                 END.

                             END.

                         APPLY LASTKEY.
                         LEAVE.

                      END.  /*  Fim do DO WHILE TRUE  */
                      IF  GO-PENDING THEN
                          DO:
                              ASSIGN 
                                  INPUT tel_dsperiod
                                  INPUT tel_recebime.

                              RUN Valida_Dados.
    
                              IF  RETURN-VALUE <> "OK" THEN
                                  NEXT.
                          END.
                    END.  /*  Fim do EDITING  */.
                        
                    RUN Confirma.

                    IF   aux_confirma = "S" THEN
                         DO:
                            RUN Grava_Dados.
    
                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.
                         END.
                END.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            /* Se foi selecionado algum registro */
            IF   aux_nrdrowid <> ?   THEN
                 DO:
                     ASSIGN aux_cddfrenv = tt-crapcra.cddfrenv
                            aux_cdperiod = tt-crapcra.cdperiod
                            aux_cdseqinc = tt-crapcra.cdseqinc
                            aux_cdprogra = tt-crapcra.cdprogra
                            aux_cdrelato = tt-crapcra.cdrelato.

                     /* valida e efetiva a exclusao */
                     RUN Valida_Dados.

                     IF  RETURN-VALUE <> "OK" THEN
                         NEXT.

                     RUN Confirma.

                     IF   aux_confirma = "S" THEN
                          DO:
                             RUN Grava_Dados.
    
                             IF  RETURN-VALUE <> "OK" THEN
                                 NEXT.
                          END.
                 END.
        END.    
END.

HIDE MESSAGE NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0064) THEN
    DELETE OBJECT h-b1wgen0064.

IF  VALID-HANDLE(h-b1wgen0059) THEN
    DELETE OBJECT h-b1wgen0059.

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
    
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN h-b1wgen0064
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
          INPUT aux_nrdrowid,
         OUTPUT TABLE tt-crapcra,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".
END.

PROCEDURE Grava_Dados:

    IF  VALID-HANDLE(h-b1wgen0064) THEN
        DELETE OBJECT h-b1wgen0064.

    RUN sistema/generico/procedures/b1wgen0064.p PERSISTENT SET h-b1wgen0064.

    RUN Grava_Dados IN h-b1wgen0064
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT aux_nrdrowid,
          INPUT glb_cddopcao,
          INPUT aux_cdrelato,
          INPUT aux_cdprogra,
          INPUT aux_cddfrenv,
          INPUT aux_sqincant,
          INPUT aux_cdseqinc,
          INPUT aux_cdselimp,
          INPUT aux_cdperiod,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    IF  VALID-HANDLE(h-b1wgen0064) THEN
        DELETE OBJECT h-b1wgen0064.

    RETURN "OK".
END.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN h-b1wgen0064
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
          INPUT aux_nrdrowid,
          INPUT aux_cdseqinc,
          INPUT aux_cdprogra,
          INPUT aux_cdrelato,
          INPUT aux_cddfrenv,
          INPUT aux_cdperiod,
          INPUT 0,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".
END.

PROCEDURE Busca_Relatorios:

    RUN Busca_Relatorios IN h-b1wgen0064
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
          INPUT aux_cdrelato, /* cdrelato */
          INPUT aux_cdprogra, /* cdprogra */
          INPUT aux_cddfrenv, /* cddfrenv */
          INPUT aux_cdperiod, /* cdperiod */
         OUTPUT TABLE tt-informativos,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".
END.

PROCEDURE Valida_Relatorios:

    RUN Valida_Relatorios IN h-b1wgen0064
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT glb_cddopcao,
          INPUT aux_cdrelato, /* cdrelato */
          INPUT aux_cdprogra, /* cdprogra */
          INPUT aux_cddfrenv, /* cddfrenv */
          INPUT aux_cdperiod, /* cdperiod */
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".
END.

PROCEDURE Busca_Forma_Envio:

    DEFINE INPUT  PARAMETER par_cddfrenv AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdseqinc AS INTEGER     NO-UNDO.

    RUN busca-recebto IN h-b1wgen0059
        ( INPUT glb_cdcooper, /* cdcooper */ 
          INPUT tel_nrdconta, /* nrdconta */
          INPUT tel_idseqttl, /* idseqttl */
          INPUT par_cddfrenv, /* cddfrenv */
          INPUT par_cdseqinc, /* cdseqinc */
          INPUT 99999,        /* nrregist */
          INPUT 1,            /* nriniseq */
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-recebto ).

    IF  tel_dsfenvio MATCHES "E-MAIL" THEN
        ASSIGN aux_titfrenv = "ENDERECO ELETRONICO".
    ELSE 
        IF  tel_dsfenvio = "CELULAR" OR tel_dsfenvio MATCHES "FONE" THEN
            ASSIGN aux_titfrenv = "TELEFONE".
        ELSE 
            ASSIGN aux_titfrenv = "ENDERECO".

    RETURN "OK".
END.

PROCEDURE Busca_Periodos:

    EMPTY TEMP-TABLE tt-informativos-aux.

    RUN busca-crapifc IN h-b1wgen0059
        ( INPUT glb_cdcooper, /* cdcooper */ 
          INPUT aux_cdrelato, /* cdrelato */
          INPUT aux_cdprogra, /* cdprogra */
          INPUT aux_cddfrenv, /* cddfrenv */
          INPUT 0,            /* cdperiod */
          INPUT 99999,        /* nrregist */
          INPUT 1,            /* nriniseq */
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-informativos-aux ).

    FOR EACH tt-informativos-aux:
        FIND FIRST tt-periodo WHERE 
             tt-periodo.cdperiod = tt-informativos-aux.cdperiod NO-ERROR.

        IF  NOT AVAILABLE tt-periodo THEN
            DO:
               CREATE tt-periodo.
               ASSIGN 
                   tt-periodo.cdperiod = tt-informativos-aux.cdperiod
                   tt-periodo.dsperiod = tt-informativos-aux.dsperiod.
            END.
    END.

    RETURN "OK".
END.

/*...........................................................................*/
