/* .............................................................................

   Programa: Fontes/desext.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/92                       Ultima atualizacao: 21/07/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela DESEXT.

   Alteracoes: 28/07/94 - Alteracoes para o controle do recadastramento e
                          atualizacao do arquivo crapalt.

               24/05/95 - Quando alterado o cdsecext, alterar para os associados
                          que nao sejam da empresa 4 (Odair).

               09/08/95 - Eliminar a diferenciacao feita para empresa 4 (Odair).

               22/09/95 - Quando alterar secao de extrato, alterar no craprda
                          (Odair).

               31/07/96 - Alterado para consistir a secao de extrato conforme
                          a agencia (Deborah).

               06/08/96 - Acerto na faixa de numeracao da secao de extrato do
                          pac 12 (Deborah).

               24/03/97 - Acerto na faixa de numeracao da secao de extrato do
                          pac 15 - entre 975 e 998 (Edson).

               03/07/97 - Incluir alteracao do tipo de extrato (Deborah).

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               16/04/98 - Pac 15 - acrescentado faixa 600 a 650 (Deborah).

               29/05/98 - PAC 16 - acrescentado a faixa 200 a 299 (Edson).

               10/09/98 - Tratar tipo de conta 7 (Deborah).
               
               13/04/1999 - Tratar emissao de avisos de debito (Deborah).

               28/04/2000 - PAC 17 - faixa de 350 a 399 (Deborah).

               21/07/2000 - Tratar CrediTextil (Deborah).
               
               27/02/2002 - Incluir secoes de extrato para o PAC 18 (Junior).
               
               29/01/2004 - Permitir tipo de extrato de conta 0 para nao 
                            emitir nem o extrato mensal (Deborah).

               08/06/2005 - Tratar tipo de conta 17 / 18 (Mirtes).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               10/07/2009 - Incluidas restricoes para Tipo Extrato Conta
                            (Diego).
                            
               21/07/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
                            
............................................................................. */

{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_altera.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_cdsecext AS INT                                   NO-UNDO.
DEF        VAR tel_tpextcta AS INT                                   NO-UNDO.
DEF        VAR tel_tpavsdeb AS INT                                   NO-UNDO.

DEF        VAR tel_dtaltera AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_cdsecext AS INT                                   NO-UNDO.
DEF        VAR aux_tpextcta AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmdcampo AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdconta AS INTE  FORMAT "zzzz,zzz,9"             NO-UNDO.
DEF        VAR h-b1wgen0103 AS HANDLE                                NO-UNDO.
DEF        VAR aux_cdagenci AS INTE                                  NO-UNDO.

DEF NEW SHARED VAR shr_cdsecext LIKE crapdes.cdsecext                NO-UNDO.
DEF NEW SHARED VAR shr_nmsecext LIKE crapdes.nmsecext                NO-UNDO.

FORM tel_nrdconta      AT  3 FORMAT "zzzz,zzz,9" LABEL "Conta/dv" AUTO-RETURN
         HELP "Informe o numero da conta ou <F7> para pesquisar"
     tel_nmprimtl        FORMAT "x(40)"      LABEL "Titular"
     tel_cdsecext        FORMAT "zz9"        LABEL "Destino" AUTO-RETURN
         HELP "Informe a secao para envio do extrato ou <F7> para listar"

     tel_tpextcta        FORMAT "9"          LABEL "Extrato" AUTO-RETURN
         HELP "Tipo de extrato de conta (0-nao emite,1-mensal,2-quinzenal)"

     tel_tpavsdeb        FORMAT "9"          LABEL "Avisos" AUTO-RETURN
         HELP "Entre com tipo de emissao dos avisos (0-nao emite,1-emite)"

    WITH ROW 4 TITLE glb_tldatela WIDTH 80 DOWN NO-LABEL FRAME f_desext.

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "A".

INICIO :

DO WHILE TRUE:
    
    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
           PERSISTENT SET h-b1wgen0103.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nrdconta WITH FRAME f_desext
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
                            DISPLAY tel_nrdconta WITH FRAME f_desext.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.
        END.
       
        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "DESEXT"   THEN
                DO:                            
                    IF  VALID-HANDLE(h-b1wgen0103) THEN
                        DELETE OBJECT h-b1wgen0103.

                    HIDE FRAME f_desext.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

    RUN Busca_Dados.

    IF  RETURN-VALUE = "NOK" THEN
        NEXT.

    DISPLAY tel_nmprimtl WITH FRAME f_desext.

    ALTERA: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_cdsecext tel_tpextcta tel_tpavsdeb WITH FRAME f_desext
        EDITING:
      
            READKEY.

            HIDE MESSAGE NO-PAUSE.

            IF  LASTKEY = KEYCODE("F7")  THEN
                DO:

                    IF  FRAME-FIELD = "tel_cdsecext"  THEN
                        DO:
                            ASSIGN shr_cdsecext = INPUT tel_cdsecext.
                            
                            RUN fontes/zoom_destino_extrato.p 
                               ( INPUT glb_cdcooper,
                                 INPUT aux_cdagenci).
        
                            IF  shr_cdsecext <> 0 THEN
                                DO:
                                    ASSIGN tel_cdsecext = shr_cdsecext.
                                  
                                    DISPLAY tel_cdsecext 
                                        WITH FRAME f_desext.
        
                                    NEXT-PROMPT tel_cdsecext
                                          WITH FRAME f_desext.
                                END.
                         END.
                END.
            ELSE
                APPLY LASTKEY.
      
            IF  GO-PENDING THEN
                DO:
                    RUN Valida_Dados.
      
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            {sistema/generico/includes/foco_campo.i
                                &VAR-GERAL=SIM
                                &NOME-FRAME="f_desext"
                                &NOME-CAMPO=aux_nmdcampo }
                        
                        END.
                END.
         
        END. /*  Fim do EDITING  */

        LEAVE ALTERA.

    END. /* ALTERA */

    IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN /* F4 OU FIM */
        RUN Grava_Dados.
    
    
    ASSIGN aux_cdsecext = 0
           tel_nrdconta = 0
           aux_tpextcta = 0.

    DOWN WITH FRAME f_desext.

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0103) THEN
    DELETE OBJECT h-b1wgen0103.

/* .......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.
    
    RUN Busca_Desext IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT TRUE, /* flgerlog */
         OUTPUT TABLE tt-desext,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    FIND FIRST tt-desext NO-ERROR.

    ASSIGN tel_nmprimtl = tt-desext.nmprimtl
           tel_cdsecext = tt-desext.cdsecext
           tel_tpextcta = tt-desext.tpextcta
           tel_tpavsdeb = tt-desext.tpavsdeb
           aux_cdagenci = tt-desext.cdagenci.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-erro.
    
    DO WITH FRAME f_desext:
    
        ASSIGN tel_cdsecext
               tel_tpextcta
               tel_tpavsdeb.
    END.
    
    RUN Valida_Desext IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT tel_cdsecext,
          INPUT tel_tpextcta,
          INPUT tel_tpavsdeb,
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
             
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE Grava_Dados:
    
    EMPTY TEMP-TABLE tt-erro.
    
    RUN Grava_Desext IN h-b1wgen0103
        ( INPUT glb_cdcooper,  
          INPUT 0,             
          INPUT 0,             
          INPUT glb_cdoperad,  
          INPUT glb_nmdatela,  
          INPUT 1,             
          INPUT glb_dtmvtolt,  
          INPUT tel_nrdconta,  
          INPUT 1, /*idseqttl*/
          INPUT tel_cdsecext,  
          INPUT tel_tpextcta,  
          INPUT tel_tpavsdeb,
          INPUT glb_cddopcao,
          INPUT TRUE, /*flgerlog*/
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT aux_msgrecad,
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.
          
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".
        END.

    /* Verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0103.p").

    IF  VALID-HANDLE(h-b1wgen0103) THEN
        DELETE OBJECT h-b1wgen0103.
    
    RETURN "OK".

END PROCEDURE. /* Grava_Dados */
