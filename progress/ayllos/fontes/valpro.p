/* ..........................................................................

   Programa: Fontes/valpro.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Julho/2007                        Ultima atualizacao: 06/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela VALPRO - Validacao de Protocolo.

   
   Alteracoes: 31/07/2008 - Incluir parametro na procedure gera_protocolo
                            (David).
                            
               27/10/2011 - Paramentro de operador na gera_protocolo
                          - Parametro de critica na gera_protocolo (Guilherme).
                          
               18/11/2011 - Adaptado fonte para o uso de BO. (Gabriel - DB1 ).
               
               06/10/2015 - Incluindo validacao de protocolo MD5 - Sicredi
                            (Andre Santos - SUPERO)
                
............................................................................. */

{ sistema/generico/includes/b1wgen0127tt.i }
{ sistema/generico/includes/var_internet.i }
{includes/var_online.i}

DEF VAR h-b1wgen0127 AS HANDLE                                      NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR aux_msgretur AS CHAR                                        NO-UNDO.
DEF VAR aux_msgerror AS CHAR FORMAT "x(37)"                         NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                        NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.

DEF VAR tel_dtmvtolt AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR tel_nrdconta         LIKE crapass.nrdconta                  NO-UNDO.
DEF VAR tel_horproto AS INT  FORMAT "99"                            NO-UNDO.
DEF VAR tel_minproto AS INT  FORMAT "99"                            NO-UNDO.
DEF VAR tel_segproto AS INT  FORMAT "99"                            NO-UNDO.
DEF VAR tel_nrdocmto         LIKE craplcm.nrdocmto                  NO-UNDO.
DEF VAR tel_nrseqaut AS INT  FORMAT "zz,zzz,zz9"                    NO-UNDO.
DEF VAR tel_vlprotoc         LIKE craplcm.vllanmto                  NO-UNDO.
DEF VAR tel_dsprotoc         LIKE crappro.dsprotoc                  NO-UNDO.
DEF VAR tel_flvalgps AS LOGICAL FORMAT "SIM/NAO"                    NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     "Opcao:"           AT 5
     glb_cddopcao       AT 12 NO-LABEL AUTO-RETURN
                        HELP "Informe a opcao desejada (C)"
                        VALIDATE (glb_cddopcao = "C", "014 - Opcao errada.") 
     SKIP(1)     
     tel_nrdconta       AUTO-RETURN 
                        LABEL "Conta/dv"             AT 14
                        HELP "Informe o numero do conta/dv"
     SKIP(1)
     tel_nrdocmto       LABEL "Nr. Documento"        AT 9
                        HELP "Informe o numero documento do comprovante" 
    
     tel_nrseqaut       LABEL "Seq. Autenticacao"    AT 35
                        HELP "Informe a sequencia da autenticacao"
     SKIP(1)
     tel_dtmvtolt       LABEL "Data"                 AT 18
                        HELP "Informe a data do comprovante"         
     SKIP(1)
     tel_horproto       AUTO-RETURN 
                        LABEL "Hora"                 AT 18
                        HELP "Informe a(s) hora(s) do comprovante"   
                        ":"                          AT 26        
     tel_minproto       AUTO-RETURN                  AT 27
                        HELP "Informe o(s) minuto(s) do comprovante" 
                        ":"                          AT 29 
     tel_segproto                                    AT 30   
                        HELP "Informe o(s) segundo(s) do comprovante"

     SKIP(1)
     tel_vlprotoc      LABEL "Valor"                 AT 17
                       HELP "Informe o valor do comprovante"

     SKIP(1)
     tel_dsprotoc      LABEL "Protocolo"             AT 13
                       HELP "Informe o protocolo do comprovante"
     SKIP(1)
     tel_flvalgps      LABEL "Pagamento refere-se a GPS"  AT 13
                       HELP "Este pagamento refere-se a GPS?"
     WITH OVERLAY NO-BOX NO-LABEL SIDE-LABEL ROW 5 COLUMN 2 FRAME f_dados.
  
VIEW FRAME f_moldura.
PAUSE (0).

ASSIGN glb_cddopcao = "C".
RUN fontes/inicia.p.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DISPLAY glb_cddopcao WITH FRAME f_dados.
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        HIDE FRAME f_incor.
         
        UPDATE glb_cddopcao WITH FRAME f_dados.

        UPDATE tel_nrdconta tel_nrdocmto
               tel_nrseqaut tel_dtmvtolt
               tel_horproto tel_minproto 
               tel_segproto tel_vlprotoc
               tel_dsprotoc tel_flvalgps
               WITH FRAME f_dados
        EDITING:
            READKEY.
            IF  FRAME-FIELD = "tel_nrdconta"   AND
                LASTKEY = KEYCODE("F7")        THEN
                DO: 
                    RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                  OUTPUT aux_nrdconta).
       
                    IF  aux_nrdconta > 0   THEN
                        DO:
                            ASSIGN tel_nrdconta = aux_nrdconta.
                            DISPLAY tel_nrdconta WITH FRAME f_dados.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.
      
            IF  GO-PENDING THEN
                DO:
                    RUN Valida_Protocolo.
      
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            {sistema/generico/includes/foco_campo.i
                                &VAR-GERAL=SIM
                                &NOME-FRAME="f_dados"
                                &NOME-CAMPO=aux_nmdcampo }
                        
                        END.
                END.

        END. /*  Fim do EDITING  */

        LEAVE.
    END.                     

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
            RUN  fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "VALPRO" THEN
                LEAVE.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:  
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
        END.     

    IF  aux_msgretur <> "" THEN
        MESSAGE aux_msgretur.
    ELSE 
    IF  aux_msgerror <> "" THEN
        DISPLAY aux_msgerror NO-LABEL
                WITH CENTERED OVERLAY COLOR MESSAGE TITLE "ATENCAO!" 
                     FRAME f_incor.

    ASSIGN tel_nrdconta = 0
           tel_nrdocmto = 0
           tel_nrseqaut = 0
           tel_dtmvtolt = ?
           tel_horproto = 0
           tel_minproto = 0
           tel_segproto = 0
           tel_vlprotoc = 0
           tel_dsprotoc = ""
           tel_flvalgps = FALSE.

END. /* Fim do DO WHILE TRUE */
/* .......................................................................... */

PROCEDURE Valida_Protocolo:

    EMPTY TEMP-TABLE tt-erro.
    
    DO WITH FRAME f_dados:
    
        ASSIGN tel_nrdconta
               tel_nrdocmto
               tel_dtmvtolt
               tel_horproto
               tel_minproto
               tel_segproto
               tel_vlprotoc
               tel_dsprotoc
               tel_nrseqaut
               tel_flvalgps.
    END.

    IF  NOT tel_flvalgps THEN DO:
        
        IF  NOT VALID-HANDLE(h-b1wgen0127) THEN
            RUN sistema/generico/procedures/b1wgen0127.p
               PERSISTENT SET h-b1wgen0127.
    
        RUN Valida_Protocolo IN h-b1wgen0127
            ( INPUT glb_cdcooper,
              INPUT 0,
              INPUT 0,
              INPUT glb_cdoperad,
              INPUT glb_cdprogra,
              INPUT 1, /* idorigem */
              INPUT glb_dtmvtolt,
              INPUT glb_dtmvtopr,
              INPUT glb_nmdatela,
              INPUT glb_cddopcao,
              INPUT tel_nrdconta,   
              INPUT tel_nrdocmto,
              INPUT tel_dtmvtolt,
              INPUT tel_horproto,
              INPUT tel_minproto,
              INPUT tel_segproto,
              INPUT tel_vlprotoc,
              INPUT tel_dsprotoc,
              INPUT tel_nrseqaut,
              INPUT TRUE, /* flgerlog */
             OUTPUT aux_nmdcampo,
             OUTPUT aux_msgretur,
             OUTPUT aux_msgerror,
             OUTPUT TABLE tt-erro).
    
        IF  VALID-HANDLE(h-b1wgen0127) THEN
            DELETE OBJECT h-b1wgen0127.
        
        IF  RETURN-VALUE <> "OK" OR
            TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
            
            FIND FIRST tt-erro NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                 
            RETURN "NOK".
        END.
    
    END.
    ELSE DO:

        IF  NOT VALID-HANDLE(h-b1wgen0127) THEN
            RUN sistema/generico/procedures/b1wgen0127.p
               PERSISTENT SET h-b1wgen0127.
    
        RUN pc_valida_protocolo IN h-b1wgen0127
            ( INPUT glb_cdcooper,
              INPUT 0,
              INPUT 0,
              INPUT glb_cdoperad,
              INPUT glb_cdprogra,
              INPUT 1, /* idorigem */
              INPUT glb_dtmvtolt,
              INPUT glb_dtmvtopr,
              INPUT glb_nmdatela,
              INPUT glb_cddopcao,
              INPUT tel_nrdconta,   
              INPUT tel_nrdocmto,
              INPUT tel_dtmvtolt,
              INPUT tel_horproto,
              INPUT tel_minproto,
              INPUT tel_segproto,
              INPUT tel_vlprotoc,
              INPUT tel_dsprotoc,
              INPUT tel_nrseqaut,
              INPUT TRUE, /* flgerlog */
             OUTPUT aux_nmdcampo,
             OUTPUT aux_msgretur,
             OUTPUT aux_msgerror,
             OUTPUT TABLE tt-erro).
    
        IF  VALID-HANDLE(h-b1wgen0127) THEN
            DELETE OBJECT h-b1wgen0127.
        
        IF  RETURN-VALUE <> "OK" OR
            TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
            
            FIND FIRST tt-erro NO-ERROR.
    
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                 
            RETURN "NOK".
        END.

    END.

    RETURN "OK".

END PROCEDURE. /* Valida_Protocolo */
