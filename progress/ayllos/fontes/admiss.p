/* .............................................................................

   Programa: Fontes/admiss.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/92                           Ultima atualizacao: 03/06/2013 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ADMISS.

   Alteracoes: 21/05/1999 - Alterado para nao gerar capital inicial se 
                            o associado ja tiver capital (Deborah).
                            
               26/06/2000 - Tirar opcoes B,D (Odair).             
                
               31/07/2000 - Colocar no-lock na rotina (Deborah).

               01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).

               26/04/2004 - Tratar novos campos do crapmat (Edson).

               22/06/2004 - Inclusao da opcao "L" (Evandro).

               17/12/2004 - Inclusao Campos Desligados e Readmitidos no
                            mes(Mirtes).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapadm (Diego).
                            
               10/09/2006 - Unificacao dos bancos e dados - SQLWorks - Andre
               
               18/10/2006 - Inclusao da opcao "D" (Elton).
               
               08/11/2006 - Alteracao do Help dos campos e acertos nos labels 
                            (Elton).
                            
               07/12/2007 - Nao executar critica 197 para Transpocred (Diego).
               
               30/05/2008 - Incluir Opcao "N" (Guilherme).
               
               23/06/2008 - Mostrar total do relatorio(Guilherme).
               
               30/06/2008 - Opcao N usar dtmvtolt e nao dtadmiss (Magui).
               
               01/02/2013 - Convertido para a BO150 (Lucas).
               
               01/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Andrino-RKAM).
               
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0150tt.i }

DEF STREAM str_1.

DEF    VAR tel_vlcapsub AS DECI    FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
DEF    VAR tel_vlcapini AS DECI    FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
                                                                      
DEF    VAR tel_qtdslmes AS INTE    FORMAT "zzz,zz9"                   NO-UNDO. 
DEF    VAR tel_qtadmmes AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.  
DEF    VAR aux_contador AS INTE                                       NO-UNDO.
DEF    VAR aux_numdopac AS INTE    FORMAT "zz9"                       NO-UNDO.
DEF    VAR aux_qtadmmes AS INTE                                       NO-UNDO.
DEF    VAR aux_qtregist AS INTE                                       NO-UNDO.
DEF    VAR aux_qtdemmes AS INTE    FORMAT "zzzz9"                     NO-UNDO.
DEF    VAR tel_qtassmes AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
DEF    VAR tel_nrmatric AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
DEF    VAR tel_qtparcap AS INTE    FORMAT "z9"                        NO-UNDO.

DEF    VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF    VAR aux_confirma AS CHAR    FORMAT "!"                         NO-UNDO.
DEF    VAR tel_dsmotdem AS CHAR                                       NO-UNDO.


DEF    VAR tel_flgabcap AS LOGI    FORMAT "SIM/NAO"                   NO-UNDO.                                                                      

DEF    VAR tel_dtdemiss AS DATE    FORMAT "99/99/9999"                NO-UNDO.
DEF    VAR tel_dtdecons AS DATE    FORMAT "99/99/9999"                NO-UNDO.
DEF    VAR tel_dtatecon AS DATE    FORMAT "99/99/9999"                NO-UNDO.

/* variaveis para impressao */                                        
DEF    VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF    VAR aux_nmarqimp AS CHAR    FORMAT "x(40)"                     NO-UNDO.
DEF    VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                     NO-UNDO.
DEF    VAR tel_cddopcao AS CHAR    FORMAT "x(1)"                      NO-UNDO.
DEF    VAR par_flgrodar AS LOGI    INIT TRUE                          NO-UNDO.
DEF    VAR aux_flgescra AS LOGI                                       NO-UNDO.
DEF    VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF    VAR par_flgfirst AS LOGI    INIT TRUE                          NO-UNDO.
DEF    VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF    VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF    VAR par_flgcance AS LOGI                                       NO-UNDO.

DEF    VAR h-b1wgen0150 AS HANDLE                                     NO-UNDO.
                                                                      
DEF    QUERY q-admiss FOR tt-admiss.
DEF    QUERY q-demiss FOR tt-demiss.

DEF    BROWSE b-admiss QUERY q-admiss
       DISPLAY tt-admiss.cdagenci                        COLUMN-LABEL "PA"
               tt-admiss.nrdconta                        COLUMN-LABEL "Conta"
               tt-admiss.nrmatric                        COLUMN-LABEL "Matricula"
               tt-admiss.nmprimtl    FORMAT "x(45)"      COLUMN-LABEL "Nome"
               WITH 9 DOWN OVERLAY.                      
                                                         
DEF    BROWSE b-demiss QUERY q-demiss                    
       DISPLAY tt-demiss.dtdemiss                        COLUMN-LABEL "Data"
               tt-demiss.cdagenci                        COLUMN-LABEL "PA"
               tt-demiss.nrdconta                        COLUMN-LABEL "Conta"
               tt-demiss.nmprimtl    FORMAT "x(20)"      COLUMN-LABEL "Nome"
               tt-demiss.cdmotdem                        COLUMN-LABEL "Motivo"
               tt-demiss.dsmotdem    FORMAT "x(18)"      COLUMN-LABEL "Descricao"
               WITH 9 DOWN OVERLAY.

FORM   "     Ass. Admitidos"
       aux_numdopac    AT  24      LABEL "PA"
       HELP "Informe o numero do PA ou zero para todos os Pas."
       aux_qtadmmes    AT  44      LABEL "Total"
       SKIP
       b-admiss HELP "Use as SETAS para navegar e <F4> para sair." SKIP 
       WITH NO-BOX SIDE-LABELS CENTERED OVERLAY ROW 7 FRAME f_pac.
       
FORM   " Ass. Demitidos"
       aux_numdopac    AT 20       LABEL "PA."
       HELP "Informe o numero do PA ou zero para todos os Pas."
       tel_dtdemiss    AT 35       LABEL "A partir de"
       HELP "Informe a data inicial para gerar o relatorio."
       aux_qtdemmes    AT 60       LABEL "Total"
       SKIP
       b-demiss HELP "Use as SETAS para navegar e <F4> para sair" SKIP
       WITH NO-BOX SIDE-LABELS CENTERED OVERLAY ROW 7 frame f-pac-dem.
     
FORM   "Ass. Novos"
       aux_numdopac    AT 13       LABEL "PA."
       HELP "Informe o numero do PA ou zero para todos os Pas."
       tel_dtdecons    AT 25       LABEL "De"
       HELP "Informe a data inicial para gerar o relatorio."
       VALIDATE (tel_dtdecons <> ?, "Informe a data inicial do periodo.")      
       tel_dtatecon    AT 40       LABEL "Ate"
       HELP "Informe a data final para gerar o relatorio."      
       VALIDATE (tel_dtatecon <> ?, "Informe a data inicial do periodo.") 
       "           "
       SKIP(13)
       WITH NO-BOX SIDE-LABELS CENTERED OVERLAY ROW 7 frame f_pac_nov.      

FORM   SKIP(1)
        glb_cddopcao AT 7 LABEL "Opcao" AUTO-RETURN
                          HELP "Informe a opcao desejada (A, C, L, D ou N)"
                          VALIDATE(CAN-DO("A,C,L,D,N",glb_cddopcao),
                                   "014 - Opcao errada.")
       SKIP(1)
       "Ultimo numero de matricula utilizado:" AT 12
       tel_nrmatric AT 57 NO-LABEL
       SKIP(1)
       "Quantidade de admissoes no mes:" AT 18
       tel_qtassmes AT 57 NO-LABEL
       SKIP(1)
       "Cooperados desligados no mes:" AT 20
       tel_qtdslmes AT 57 NO-LABEL
       "Cooperados readmitidos no mes:" AT 19
       tel_qtadmmes AT 57 NO-LABEL
       SKIP(1)
       tel_vlcapsub AT 18 LABEL "Valor da subscricao de capital" AUTO-RETURN
                          HELP "Informe o valor da subscricao de capital."
       SKIP
       tel_vlcapini AT 25 LABEL "Valor do capital minimo" AUTO-RETURN
       HELP "Informe o valor do capital minimo (min. de 50% da subscricao)."
       SKIP(1)
       "Quantidade maxima de parcelamento mensal:" AT 8
       tel_qtparcap AT 62 NO-LABEL AUTO-RETURN
               HELP "Informe a quantidade maxima de parcelamento do capital."
       SKIP(1)
       "Abonar CPMF sobre lancamentos do capital:" AT 8
       tel_flgabcap AT 61 NO-LABEL 
       WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_admiss.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DISPLAY glb_cddopcao WITH FRAME f_admiss.


    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        SET glb_cddopcao WITH FRAME f_admiss.
        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "ADMISS"   THEN
                DO:
                    HIDE FRAME f_admiss.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    IF  glb_cddopcao = "A"   THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0150.p 
               PERSISTENT SET h-b1wgen0150.
                      
            RUN consulta-admiss IN h-b1wgen0150 (INPUT glb_cdcooper,
                                                 INPUT 0, /* Agencia*/
                                                 INPUT 0, /* Caixa  */
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 OUTPUT tel_qtassmes,
                                                 OUTPUT tel_qtadmmes,
                                                 OUTPUT tel_qtdslmes,
                                                 OUTPUT tel_vlcapini,
                                                 OUTPUT tel_nrmatric,
                                                 OUTPUT tel_qtparcap,
                                                 OUTPUT tel_vlcapsub,
                                                 OUTPUT tel_flgabcap,
                                                 OUTPUT TABLE tt-erro).
                                        
            DELETE PROCEDURE h-b1wgen0150.
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
    
                    NEXT.
                END.
    
            DISPLAY tel_qtassmes 
                    tel_qtadmmes
                    tel_qtdslmes
                    tel_vlcapini  
                    tel_nrmatric
                    tel_qtparcap  
                    tel_vlcapsub  
                    tel_flgabcap
                    WITH FRAME f_admiss.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_vlcapsub tel_vlcapini tel_qtparcap 
                       tel_flgabcap
                       WITH FRAME f_admiss
    
                EDITING:
                 
                   READKEY.
                 
                   IF   FRAME-FIELD = "tel_vlcapsub"   OR
                        FRAME-FIELD = "tel_vlcapini"   THEN
                        IF   LASTKEY =  KEYCODE(".")   THEN
                             APPLY 44.
                        ELSE
                             APPLY LASTKEY.
                   ELSE
                        APPLY LASTKEY.
                END.
    
                ASSIGN aux_confirma = "N".
                RUN fontes/confirma.p (INPUT  "",
                                       OUTPUT aux_confirma).
                    
                IF  aux_confirma = "S" THEN 
                    DO:
                        /* Valida e Realiza as alterações */
                        RUN sistema/generico/procedures/b1wgen0150.p 
                           PERSISTENT SET h-b1wgen0150.
    
                        RUN altera-admiss IN h-b1wgen0150 (INPUT glb_cdcooper,
                                                           INPUT 0, /* Agencia*/
                                                           INPUT 0, /* Caixa  */
                                                           INPUT glb_cdoperad,
                                                           INPUT glb_dtmvtolt,
                                                           INPUT TRUE /* LOG */,
                                                           INPUT tel_vlcapini,
                                                           INPUT tel_vlcapsub,
                                                           INPUT tel_qtparcap,
                                                           INPUT tel_flgabcap,
                                                           OUTPUT TABLE tt-erro).
                                                  
                        DELETE PROCEDURE h-b1wgen0150.  
    
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                                IF  AVAILABLE tt-erro  THEN
                                    MESSAGE tt-erro.dscritic.
                        
                                NEXT.
                            END.
                        ELSE
                            MESSAGE "Registro alterado com sucesso.".
                    END.
    
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
        END.
    ELSE
    IF  glb_cddopcao = "C"   THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0150.p 
                PERSISTENT SET h-b1wgen0150.
                      
            RUN consulta-admiss IN h-b1wgen0150 (INPUT glb_cdcooper,
                                                 INPUT 0, /* Agencia*/
                                                 INPUT 0, /* Caixa  */
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 OUTPUT tel_qtassmes,
                                                 OUTPUT tel_qtadmmes,
                                                 OUTPUT tel_qtdslmes,
                                                 OUTPUT tel_vlcapini,
                                                 OUTPUT tel_nrmatric,
                                                 OUTPUT tel_qtparcap,
                                                 OUTPUT tel_vlcapsub,
                                                 OUTPUT tel_flgabcap,
                                                 OUTPUT TABLE tt-erro).
                                        
            DELETE PROCEDURE h-b1wgen0150.
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
    
                    NEXT.
                END.
    
            DISPLAY tel_qtassmes 
                    tel_qtadmmes
                    tel_qtdslmes
                    tel_vlcapini  
                    tel_nrmatric
                    tel_qtparcap  
                    tel_vlcapsub  
                    tel_flgabcap
                    WITH FRAME f_admiss.
        END.
    ELSE
    IF  glb_cddopcao = "L"   THEN
        DO:
            CLOSE QUERY q-admiss.
            DISABLE b-admiss WITH FRAME f_pac.

            ASSIGN aux_numdopac = 0
                   aux_qtadmmes = 0.

            DISPLAY aux_qtadmmes WITH FRAME f_pac.
            UPDATE aux_numdopac WITH FRAME f_pac.

            RUN sistema/generico/procedures/b1wgen0150.p 
                PERSISTENT SET h-b1wgen0150.

            RUN lista-admiss-pac IN h-b1wgen0150 (INPUT glb_cdcooper,
                                                  INPUT 0, /* Agencia*/
                                                  INPUT 0, /* Caixa  */
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT aux_numdopac,
                                                  INPUT 999999,
                                                  INPUT 0,
                                                  OUTPUT aux_qtregist,
                                                  OUTPUT aux_qtadmmes,
                                                  OUTPUT TABLE tt-admiss,
                                                  OUTPUT TABLE tt-erro).
                                        
            DELETE PROCEDURE h-b1wgen0150.
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
    
                    NEXT.
                END.

           OPEN QUERY q-admiss FOR EACH tt-admiss NO-LOCK.

           DISPLAY aux_qtadmmes WITH FRAME f_pac.
           UPDATE b-admiss WITH FRAME f_pac.
            
        END.
    ELSE
    IF   glb_cddopcao = "N"  THEN
         DO:
             ASSIGN  tel_dtdecons = glb_dtmvtolt - DAY(glb_dtmvtolt) + 1
                     tel_dtatecon = glb_dtmvtolt
                     aux_numdopac = 0.
    
             UPDATE aux_numdopac 
                    tel_dtdecons 
                    tel_dtatecon
                    WITH FRAME f_pac_nov.
                    
             INPUT THROUGH basename `tty` NO-ECHO.
    
             SET aux_nmendter WITH FRAME f_terminal.

             INPUT CLOSE.

             aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                            aux_nmendter.

             RUN sistema/generico/procedures/b1wgen0150.p 
                PERSISTENT SET h-b1wgen0150.

             RUN impressao-admiss IN h-b1wgen0150 (INPUT glb_cdcooper,
                                                   INPUT 0, /* Agencia*/
                                                   INPUT 0, /* Caixa  */
                                                   INPUT glb_cdoperad,
                                                   INPUT aux_nmendter,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT 1 /* Ayllos */,
                                                   INPUT aux_numdopac,
                                                   INPUT tel_dtdecons,
                                                   INPUT tel_dtatecon,
                                                   OUTPUT aux_nmarqimp,
                                                   OUTPUT aux_nmarqpdf,
                                                   OUTPUT TABLE tt-erro).
                                         
             DELETE PROCEDURE h-b1wgen0150.
                  
             IF  RETURN-VALUE = "NOK"  THEN
                 DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
                     IF  AVAILABLE tt-erro  THEN
                         MESSAGE tt-erro.dscritic.
         
                     NEXT.
                 END.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
                MESSAGE "(T)erminal ou (I)mpressora: " 
                        UPDATE tel_cddopcao FORMAT "!(1)".
     
                IF   tel_cddopcao = "I"   THEN
                     DO:

                        /*** nao necessario ao programa somente para nao dar erro 
                          de compilacao na rotina de impressao.i ****/
                         FIND FIRST crapass 
                                    WHERE crapass.cdcooper = glb_cdcooper       
                                    NO-LOCK NO-ERROR.
    
                         glb_nmformul = "80col".
                         
                         { includes/impressao.i }
                     END.
                ELSE
                IF   tel_cddopcao = "T"   THEN
                     RUN fontes/visrel.p (INPUT aux_nmarqimp).
                ELSE
                     DO: 
                        glb_cdcritic = 14.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                     END.

                LEAVE.

             END.
         END.
    ELSE
    IF  glb_cddopcao = "D" THEN
        DO:
            CLOSE QUERY q-demiss.
            DISABLE b-demiss WITH FRAME f-pac-dem.

            ASSIGN tel_dtdemiss = glb_dtmvtolt - DAY(glb_dtmvtolt) + 1
                   aux_numdopac = 0
                   aux_qtdemmes = 0.
                  
            DISPLAY aux_qtdemmes WITH FRAME f-pac-dem.
            UPDATE aux_numdopac tel_dtdemiss WITH FRAME f-pac-dem.

            RUN sistema/generico/procedures/b1wgen0150.p 
                PERSISTENT SET h-b1wgen0150.

            RUN lista-demiss-pac IN h-b1wgen0150 (INPUT glb_cdcooper,
                                                  INPUT 0, /* Agencia*/
                                                  INPUT 0, /* Caixa  */
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT aux_numdopac,
                                                  INPUT tel_dtdemiss,
                                                  INPUT 999999,
                                                  INPUT 0,
                                                  OUTPUT aux_qtregist,
                                                  OUTPUT aux_qtdemmes,
                                                  OUTPUT TABLE tt-demiss,
                                                  OUTPUT TABLE tt-erro).
                                        
            DELETE PROCEDURE h-b1wgen0150.
                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
    
                    NEXT.
                END.

            OPEN QUERY q-demiss FOR EACH tt-demiss NO-LOCK.

            DISPLAY aux_qtdemmes WITH FRAME f-pac-dem.
            UPDATE b-demiss WITH FRAME f-pac-dem.

        END.
END.

/* .......................................................................... */

