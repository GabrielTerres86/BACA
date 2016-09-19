/* ..........................................................................

   Programa: Fontes/lisepr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Junho/2007                       Ultima atualizacao: 25/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LISEPR.

   Alteracoes: 06/05/2009  - Incluir campos "Data da proposta" e "Saldo Medio"
                           (Fernando).

               02/03/2010  - Alteracao feita para tratar cheques e titulos
                             (GATI - Daniel).

               15/04/2013 - Incluido totalizador  de lancamentos (Daniele).

               23/07/2013 - Criando BO para atender as necessidade da tela
                            (Andre Santos - SUPERO)
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)             

               05/05/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
                            
               25/02/2015 - Correcao e validacao para liberacao da conversao
                            realizada pela SUPERO 
                            (Adriano)             
............................................................................. */

{ sistema/generico/includes/b1wgen0161tt.i }
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR tel_cdlcremp AS INT  FORMAT "zzz9"                           NO-UNDO.
DEF VAR tel_tipsaida AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX       
                             INNER-LINES 2                           NO-UNDO.
DEF VAR tel_cdagenci AS INT  FORMAT "zz9"                            NO-UNDO.
DEF VAR tel_dtinicio AS DATE FORMAT "99/99/9999"                     NO-UNDO.
DEF VAR tel_dttermin AS DATE FORMAT "99/99/9999"                     NO-UNDO.
DEF VAR tel_cddotipo AS CHAR FORMAT "!" INITIAL "E"                  NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.

DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"           NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"           NO-UNDO. 
DEF VAR tel_nmarquiv AS CHAR FORMAT "x(25)"                          NO-UNDO.
DEF VAR tel_nmdireto AS CHAR FORMAT "x(20)"                          NO-UNDO.

DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.

DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                        NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR    FORMAT "x(30)"                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR    FORMAT "x(30)"                       NO-UNDO. 
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_totvlemp AS DECI                                         NO-UNDO.
DEF VAR aux_nrregist AS INTE                                         NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.

DEF VAR h-b1wgen0161 AS HANDLE                                       NO-UNDO.

FORM SKIP(1)
    glb_cddopcao COLON 10 LABEL "Opcao"   AUTO-RETURN
          HELP "Informe a opcao desejada (T ou I)."
                          VALIDATE (glb_cddopcao = "T" OR glb_cddopcao = "I", 
                                    "014 - Opcao errada.") 
    SKIP(14)
    WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_lisepr.

FORM SKIP(1)
     "PA:"
     tel_cdagenci HELP "Informe o numero do PA ou '0'(zero) para listar todos."
     SPACE(5)
     tel_cdlcremp LABEL "Linha Credito" 
     HELP "Informe a linha de credito ou '0'(zero) para listar todas."
     tel_cddotipo   AT 40   LABEL "Tipo" AUTO-RETURN
     HELP "Informe a opcao (E=Emprestimos, T=Titulos, C=Cheques, X=Todos)."
                        VALIDATE (CAN-DO("E,T,C,X",tel_cddotipo),
                                  "014 - Opcao errada.") 
     SKIP 
     "Data Inicial:"    AT 1
     tel_dtinicio HELP "Informe a data inicial da consulta." 
     SPACE(3)
     "Data Final:"  
     tel_dttermin HELP "Informe a data final da consulta."   
     WITH FRAME f_dados OVERLAY NO-BOX NO-LABEL SIDE-LABEL ROW 5 COLUMN 19.

FORM tel_tipsaida LABEL "Saida" HELP "Selecione o tipo de saida." SKIP(1)
     WITH FRAME f_saida OVERLAY NO-BOX NO-LABEL SIDE-LABEL ROW 8 COLUMN 19.

FORM "Diretorio:   "     AT 5
     tel_nmdireto
     aux_nmarquiv        HELP "Informe o nome do arquivo."
     WITH OVERLAY ROW 11 NO-LABEL SIDE-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.

DEF QUERY q_emprestimo FOR tt-emprestimo.

DEF BROWSE b_emprestimo QUERY q_emprestimo
    DISP tt-emprestimo.cdagenci COLUMN-LABEL "PA"
         tt-emprestimo.nrdconta COLUMN-LABEL "Conta/dv"
         tt-emprestimo.nrctremp COLUMN-LABEL "Contrato"  FORMAT "zz,zzz,zz9" 
         tt-emprestimo.dtmvtolt COLUMN-LABEL "Data Emp"  FORMAT "99/99/9999" 
         tt-emprestimo.vlemprst COLUMN-LABEL "Valor"     FORMAT "z,zzz,zz9.99"
         tt-emprestimo.vlsdeved COLUMN-LABEL "Saldo"     FORMAT "z,zzz,zz9.99-"
         tt-emprestimo.cdlcremp COLUMN-LABEL "Linha"
         WITH 4 DOWN.    

FORM b_emprestimo  HELP "Use as SETAS para navegar ou <F4> para sair." 
     SKIP
     WITH  NO-BOX CENTERED OVERLAY ROW 10 FRAME f_emprestimo.

FORM tt-emprestimo.nmprimtl LABEL "Nome"         AT 01 SKIP
     tt-emprestimo.dtmvtprp LABEL "Data Prop"    AT 01
     aux_contador           LABEL "Qtd. "        AT 35 SKIP
     tt-emprestimo.diaprmed LABEL "Prazo Med"    AT 01
     aux_totvlemp           LABEL "Valor TOTAL " AT 35 FORMAT "zzz,zzz,zz9.99" 
     SKIP
     WITH NO-BOX SIDE-LABELS CENTERED OVERLAY ROW 18 FRAME f_nome.

ON VALUE-CHANGED OF b_emprestimo
   DO:
      DISPLAY tt-emprestimo.nmprimtl 
              tt-emprestimo.dtmvtprp
              tt-emprestimo.diaprmed 
              WITH FRAME f_nome.

   END.

ON RETURN OF tel_tipsaida 
   DO:
      ASSIGN tel_tipsaida = tel_tipsaida:SCREEN-VALUE.
      
      APPLY "GO".

   END.

ASSIGN glb_cddopcao = "T".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   HIDE FRAME f_diretorio  NO-PAUSE.
   HIDE FRAME f_dados      NO-PAUSE.
   HIDE FRAME f_saida      NO-PAUSE.
   HIDE FRAME f_emprestimo NO-PAUSE.

   CLEAR FRAME f_dados      NO-PAUSE.
   CLEAR FRAME f_saida      NO-PAUSE.
   CLEAR FRAME f_diretorio  NO-PAUSE.
   CLEAR FRAME f_emprestimo NO-PAUSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
      ASSIGN tel_cdlcremp = 0
             tel_cdagenci = 0
             glb_cdcritic = 0
             tel_dtinicio = ?
             tel_cddotipo = "E"
             tel_dttermin = ?
             aux_nmarquiv = ""
             aux_nmarqpdf = ""
             glb_cddopcao = "T"
             tel_tipsaida:LIST-ITEM-PAIRS = "ARQUIVO,1,IMPRESSAO,2".

      IF glb_cdcritic > 0 THEN 
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0.
             PAUSE 2 NO-MESSAGE.
         END.

      UPDATE glb_cddopcao
             WITH FRAME f_lisepr.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
      DO:
         RUN fontes/novatela.p.
         
         IF CAPS(glb_nmdatela) <> "LISEPR" THEN 
            DO:
               HIDE FRAME f_lisepr.
               HIDE FRAME f_dados.
               HIDE FRAME f_diretorio.
               HIDE FRAME f_saida.
               HIDE FRAME f_emprestimo.

               RETURN.
               
            END.
         ELSE 
            NEXT.

      END.

   IF aux_cddopcao <> glb_cddopcao   THEN 
      DO:  
        { includes/acesso.i }
        
         ASSIGN aux_cddopcao = glb_cddopcao
                glb_cdcritic = 0.
        
      END.
          
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_cdagenci
             tel_cdlcremp
             tel_cddotipo
             tel_dtinicio 
             tel_dttermin
             WITH FRAME f_dados

         EDITING:

            READKEY.

            IF FRAME-FIELD = "tel_dtinicio" THEN
               DO:
                  IF KEYFUNCTION(LASTKEY) = "RETURN"   OR
                     KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                     KEYFUNCTION(LASTKEY) = "GO"       THEN 
                     DO:
                        ASSIGN tel_dtinicio.

                        IF tel_dtinicio = ? THEN
                           tel_dtinicio = DATE("01/" + STRING(MONTH(glb_dtmvtolt)) + "/" + 
                                          STRING(YEAR(glb_dtmvtolt))).
                  
                        DISPLAY tel_dtinicio 
                                WITH FRAME f_dados.

                        APPLY LASTKEY.

                     END.
                  ELSE         
                     APPLY LASTKEY.

               END.
            ELSE
            IF FRAME-FIELD = "tel_dttermin" THEN
               DO:
                  IF KEYFUNCTION(LASTKEY) = "RETURN"   OR
                     KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                     KEYFUNCTION(LASTKEY) = "GO"       THEN 
                     DO:
                        ASSIGN tel_dttermin.

                        IF tel_dttermin = ? THEN
                           tel_dttermin = glb_dtmvtolt.
                  
                        DISPLAY tel_dttermin 
                                WITH FRAME f_dados.

                        APPLY LASTKEY.

                     END.
                  ELSE         
                     APPLY LASTKEY.

               END.
            ELSE
               APPLY LASTKEY.

         END.
      
      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
      NEXT.

   ASSIGN aux_contador = 0
          aux_totvlemp = 0.

   IF glb_cddopcao = "I" THEN  
      DO:
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_tipsaida
                   WITH FRAME f_saida.

            LEAVE.

         END.

         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
            NEXT.

         FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                            NO-LOCK NO-ERROR. 
        
         IF INT(tel_tipsaida) = 1 THEN 
            DO:
               ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/".
               
               DISP tel_nmdireto 
                    aux_nmarquiv 
                    WITH FRAME f_diretorio.
               
               UPDATE aux_nmarquiv 
                      WITH FRAME f_diretorio.
            
            END.

      END.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
   
      RUN fontes/critic.p.
      ASSIGN glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
      aux_confirma <> "S"                THEN 
      DO:
         ASSIGN glb_cdcritic = 79.
         RUN fontes/critic.p.
         ASSIGN glb_cdcritic = 0.
         BELL.
         MESSAGE glb_dscritic.
         PAUSE 2 NO-MESSAGE.
         CLEAR FRAME f_cadgps.
         NEXT.

      END. /* Mensagem de confirmacao */

   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.

   MESSAGE "Buscando informacoes. Aguarde...".

   /* Busca Emprestimos */
   IF NOT VALID-HANDLE(h-b1wgen0161) THEN
      RUN sistema/generico/procedures/b1wgen0161.p
          PERSISTENT SET h-b1wgen0161.

   RUN busca_emprestimos IN h-b1wgen0161
                       ( INPUT glb_cdcooper,
                         INPUT glb_cdagenci,
                         INPUT 0, /*nrdcaixa*/
                         INPUT 1, /*idorigem*/
                         INPUT glb_cdoperad,
                         INPUT 'LISEPR',
                         INPUT glb_cddopcao,
                         INPUT glb_dtmvtolt,
                         INPUT glb_dtmvtopr,
                         INPUT tel_cdagenci,
                         INPUT tel_dtinicio,
                         INPUT tel_dttermin,
                         INPUT tel_cdlcremp,
                         INPUT tel_cddotipo,
                         INPUT 0, /*_nrregist*/
                         INPUT 0, /*nriniseq*/
                         INPUT aux_nmendter,
                         INPUT aux_nmarquiv,
                         INPUT tel_tipsaida,
                         OUTPUT aux_nmdcampo,
                         OUTPUT aux_contador,
                         OUTPUT aux_totvlemp,
                         OUTPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-emprestimo).

   HIDE MESSAGE NO-PAUSE.

   IF VALID-HANDLE(h-b1wgen0161) THEN
      DELETE PROCEDURE h-b1wgen0161.

   IF TEMP-TABLE tt-erro:HAS-RECORDS  THEN 
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
         IF AVAIL tt-erro  THEN 
            DO:
               MESSAGE tt-erro.dscritic.
               PAUSE.
               HIDE MESSAGE.
               NEXT.
            END.
         ELSE
            DO:
               MESSAGE "Nao foi possivel consultar as informacoes.".
               PAUSE.
               HIDE MESSAGE.
               NEXT.
            END.

      END.
   
   IF glb_cddopcao = "T" THEN 
      DO:
         OPEN QUERY q_emprestimo FOR EACH tt-emprestimo.
         ENABLE b_emprestimo WITH FRAME f_emprestimo.
         PAUSE 0. 

         IF AVAILABLE tt-emprestimo THEN
            DO:
               DISPLAY tt-emprestimo.nmprimtl 
                       aux_contador
                       tt-emprestimo.dtmvtprp 
                       aux_totvlemp
                       tt-emprestimo.diaprmed
                       WITH FRAME f_nome.
            
            END.
           
         HIDE MESSAGE NO-PAUSE.   
         
         WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
         
         HIDE FRAME f_emprestimo.
         HIDE FRAME f_nome.
         CLOSE QUERY q_emprestimo.
                          
      END.    
   ELSE 
      DO: 
         IF INT(tel_tipsaida) = 1 THEN
            DO:
               MESSAGE "Arquivo gerado com sucesso.".
               PAUSE 3 NO-MESSAGE.
            END.
         ELSE
            DO:
               ASSIGN glb_nmformul = "132col"
                      glb_nrcopias = 1.
                    
               FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                        NO-LOCK NO-ERROR.
                 
               { includes/impressao.i }
            END.

      END.
   
END. /* Fim  DO WHILE TRUE */

/* ........................................................................... */



