/* .............................................................................

   Programa: Fontes/compvi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Dezembro/2012                        Ultima alteracao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario 
   Objetivo  : Mostrar a tela COMPVI
               C - Consulta os beneficios de um determinado beneficario e 
                   permite a comprovacao de vida pelo procurador ou, pelo 
                   proprio beneficiario. 
               G - Acesso permitido somente a cooperativa CECRED. Gera
                   um arquivo, para cada cooperativa (quando tiver alguma
                   comprovacao), com todas as comprovacoes da cooperativa
                   e data informadas.
                   
                  
   Alteracao : 17/05/2013 - Alterado a chamada da procedure busca-benefic-beinss
                            para busca-benefic-compvi (Adriano).
                            
               04/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow).     
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

............................................................................. */
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0091tt.i }

DEF VAR tel_nmrecben LIKE crapcbi.nmrecben                      NO-UNDO.
DEF VAR tel_cdagenci LIKE crapcbi.cdagenci                      NO-UNDO.
DEF VAR tel_nrcpfcgc LIKE crapcbi.nrcpfcgc                      NO-UNDO.
DEF VAR tel_nrbenefi LIKE crapcbi.nrbenefi                      NO-UNDO.
DEF VAR tel_nrrecben LIKE crapcbi.nrrecben                      NO-UNDO.
DEF VAR tel_nmprimtl LIKE crapass.nmprimtl                      NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                    NO-UNDO.
DEF VAR aux_nmprocur LIKE crappbi.nmprocur                      NO-UNDO.
DEF VAR aux_dsdocpcd LIKE crappbi.dsdocpcd                      NO-UNDO.
DEF VAR aux_cdoedpcd LIKE crappbi.cdoedpcd                      NO-UNDO.
DEF VAR aux_cdufdpcd LIKE crappbi.cdufdpcd                      NO-UNDO.
DEF VAR aux_dtvalprc LIKE crappbi.dtvalprc                      NO-UNDO.
DEF VAR aux_nrbenefi AS DECI                                    NO-UNDO.
DEF VAR aux_nrrecben AS DECI                                    NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 2 
                        INIT ["Comprovar pelo Procurador",
                              "Comprovar pelo Beneficiario"]    NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                         NO-UNDO.
DEF VAR aux_nrprocur AS DEC                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
DEF VAR par_flgrodar AS LOG INIT TRUE                           NO-UNDO.
DEF VAR aux_flgescra AS LOG                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.
DEF VAR par_flgfirst AS LOG INIT TRUE                           NO-UNDO.
DEF VAR aux_contador AS INT                                     NO-UNDO.
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR par_flgcance AS LOG                                     NO-UNDO.
DEF VAR aux_ultlinha AS INT                                     NO-UNDO.
DEF VAR tel_cdcooper AS CHAR FORMAT "x(13)" VIEW-AS COMBO-BOX   
                             INNER-LINES 11                     NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                    NO-UNDO.

DEF VAR h-b1wgen0091 AS HANDLE                                  NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (C, G)."
                        VALIDATE(CAN-DO("C,G",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM SKIP(1)
     tel_nrcpfcgc LABEL "CPF"
           HELP "Informe o CPF ou pressione <ENTER> para procurar por nome."
     tel_nrbenefi AT 23  LABEL "NB"
           HELP "Informe o NB para a procura do beneficiario."
     tel_nrrecben AT 44  LABEL "NIT"
           HELP "Informe o NIT para a procura do beneficiario."
     SKIP
     tel_cdagenci LABEL "PA"
           HELP "Informe o PA credenciado ao INSS."
           VALIDATE(tel_cdagenci <> 0, "Numero do PA incorreto.")
     tel_nmrecben AT 21  LABEL "Nome"   FORMAT "X(37)"
           HELP "Informe o nome do beneficiario ou pressione <ENTER> p/ listar."
     WITH ROW 5 COLUMN 15 OVERLAY SIDE-LABELS WIDTH 64 NO-BOX FRAME f_comprova.

FORM SKIP(1)
     tel_cdcooper LABEL "Cooperativa"
                  HELP "Selecione a Cooperativa."
     WITH ROW 5 COLUMN 15 OVERLAY SIDE-LABELS WIDTH 64 NO-BOX FRAME f_gera_arq.

FORM 
    "                        ---Dados do Procurador---" SKIP
    "  Nome                                          RG OE         UF Validade"
    SKIP
    aux_nmprocur    AT 3 FORMAT "x(35)"
    aux_dsdocpcd                 
    aux_cdoedpcd 
    aux_cdufdpcd 
    aux_dtvalprc         FORMAT "99/99/99" 
    SKIP(1)
    WITH ROW 16 COLUMN 3 OVERLAY NO-LABELS NO-BOX WIDTH 73 FRAME f_dadosp.
     
FORM "                      ---Beneficio sem Procurador---" SKIP
     SKIP(1)
     WITH ROW 16 COLUMN 3 OVERLAY NO-LABELS NO-BOX WIDTH 73 FRAME f_dadospn.

FORM reg_dsdopcao[1] AT 10  FORMAT "X(25)"
         HELP "Pressione <ENTER> p/ comprovar pelo procurador."
     reg_dsdopcao[2] AT 40 FORMAT "X(27)"
         HELP "Pressione <ENTER> p/ comprovar pelo beneficiario."
     WITH ROW 20 COLUMN 3 OVERLAY NO-LABELS NO-BOX WIDTH 73 FRAME f_comprovar.


DEF QUERY q_beneficio FOR tt-benefic.

DEF BROWSE b_beneficio QUERY q_beneficio
    DISP tt-benefic.nrbenefi COLUMN-LABEL "NB/NIT"
         SPACE(2)
         tt-benefic.dtcompvi COLUMN-LABEL "Ultima Comprovacao" 
                                          FORMAT "99/99/9999"
         tt-benefic.dtprcomp COLUMN-LABEL "Proxima Comprovacao"
                                          FORMAT "99/99/9999"
         tt-benefic.dscresvi COLUMN-LABEL "Responsavel" FORMAT "X(12)"
         SPACE(3)
         WITH 3 DOWN WIDTH 70 NO-BOX SCROLLBAR-VERTICAL.

DEF FRAME f_beneficio
          b_beneficio  
          HELP "Pressione <ENTER> p/ selecionar ou <SETAS> p/ navegar."
          WITH CENTERED OVERLAY ROW 9 TITLE " Dados do Beneficio ".  

DEF QUERY q_nome FOR tt-benefic.

DEF BROWSE b_nome QUERY q_nome
    DISP tt-benefic.nmrecben COLUMN-LABEL "Nome"        FORMAT "x(30)"
         tt-benefic.nrbenefi COLUMN-LABEL "NB"
         tt-benefic.dtnasben COLUMN-LABEL "Nascimento"
         tt-benefic.nmmaeben COLUMN-LABEL "Nome da mae" FORMAT "x(25)"
         tt-benefic.dtatucad COLUMN-LABEL "Dt.Alt.Cad"  FORMAT "99/99/9999"
         WITH 8 DOWN WIDTH 76 NO-BOX SCROLLBAR-VERTICAL.

DEF FRAME f_nome
          b_nome  
    HELP "Pressione <ENTER> p/ detalhar ou <SETAS> p/ navegar."
    WITH CENTERED OVERLAY ROW 09 TITLE " Nomes ".  


DEF QUERY q_arquivos FOR tt-arquivos-comp-vida.

DEF BROWSE b_arquivos QUERY q_arquivos
    DISP tt-arquivos-comp-vida.nmrescop COLUMN-LABEL "Cooperativa"
         tt-arquivos-comp-vida.nmarquiv FORMAT "x(46)" 
                                        COLUMN-LABEL "Arquivo" 
         tt-arquivos-comp-vida.dscsitua FORMAT "X(31)"
                                        COLUMN-LABEL "Situacao" 
         WITH 9 DOWN WIDTH 76 NO-BOX SCROLLBAR-VERTICAL.

DEF FRAME f_arquivos
          b_arquivos  
          HELP "Pressione <F4> p/ sair ou <SETAS> p/ navegar."
          WITH CENTERED OVERLAY ROW 8 TITLE " Arquivos Gerados ".  


ON RETURN OF tel_cdcooper IN FRAME f_gera_arq
   DO:                   
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE 
                             IN FRAME f_gera_arq.

       APPLY "GO".

   END.

ON RETURN OF b_beneficio IN FRAME f_beneficio 
   DO:
      EMPTY TEMP-TABLE tt-lancred.

      ASSIGN aux_ultlinha = 0.

      HIDE MESSAGE.
      
      CHOOSE FIELD reg_dsdopcao[1]
                   reg_dsdopcao[2]
                   WITH FRAME f_comprovar.

      IF FRAME-VALUE = reg_dsdopcao[1] THEN
         DO:
            IF NOT DYNAMIC-FUNCTION("busca_procurador_beneficio" 
                                               IN h-b1wgen0091,
                                               INPUT glb_cdcooper,
                                               INPUT glb_cdagenci,
                                               INPUT glb_cdoperad,
                                               INPUT 0, /*nrdcaixa*/
                                               INPUT glb_nmdatela,
                                               INPUT glb_cdcooper,
                                               INPUT tt-benefic.nrrecben,
                                               INPUT tt-benefic.nrbenefi,
                                               OUTPUT TABLE tt-lancred) THEN
               DO:
                  MESSAGE "Procurador nao cadastrado pelo INSS. Comprovacao " + 
                          "nao permitida.".
                
                  NEXT.
               END.
            ELSE
               DO:
                  FIND FIRST tt-lancred NO-LOCK NO-ERROR.

                  IF tt-lancred.dtvalprc < glb_dtmvtolt THEN
                     DO:
                        MESSAGE "Procurador com validade ja expirada.".
                        NEXT.

                     END.

                  ASSIGN aux_confirma = "N".
      
                  RUN fontes/confirma.p (INPUT "Confira a documentacao do "    + 
                                               "procurador. Deseja confirmar " +
                                               "operacao?",
                                         OUTPUT aux_confirma).
                      
                  IF aux_confirma = "N" THEN 
                     NEXT.
                  
                  INPUT THROUGH basename `tty` NO-ECHO.
      
                  SET aux_nmendter WITH FRAME f_terminal.
                  INPUT CLOSE.
                  
                  aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                        aux_nmendter.
                 
                  RUN comprova_vida IN h-b1wgen0091(INPUT glb_cdcooper,
                                                    INPUT glb_cdoperad,
                                                    INPUT 0, /*nrdcaixa*/
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_nmdatela,
                                                    INPUT tel_cdagenci,
                                                    INPUT 1, /*ayllos*/
                                                    INPUT tel_nrrecben,
                                                    INPUT tel_nrbenefi,
                                                    INPUT tel_nrcpfcgc,
                                                    INPUT tel_nmrecben,
                                                    INPUT STRING(TIME,"HH:MM:SS"),
                                                    INPUT 2, /*Pelo Procurador*/
                                                    INPUT tt-lancred.nmprocur,
                                                    INPUT tt-lancred.dsdocpcd,
                                                    INPUT tt-lancred.cdoedpcd,
                                                    INPUT tt-lancred.cdufdpcd,
                                                    INPUT tt-lancred.dtvalprc,
                                                    INPUT aux_nmendter,
                                                    OUTPUT aux_nmarqimp,
                                                    OUTPUT TABLE tt-erro).
      
                  IF RETURN-VALUE <> "OK" THEN
                     DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
                        IF AVAIL tt-erro THEN
                           MESSAGE tt-erro.dscritic.
                        ELSE
                           MESSAGE "Nao foi possivel comprovar vida " + 
                                   "pelo procurador.".
                              
                        PAUSE(2) NO-MESSAGE.
                        HIDE MESSAGE.
      
                        NEXT.
      
                     END.
      
               END.
      
         END.
      ELSE
         DO:
            ASSIGN aux_confirma = "N".
      
            RUN fontes/confirma.p (INPUT "Confira a documentacao do "      + 
                                         "beneficiario. Deseja confirmar " + 
                                         "operacao?",
                                   OUTPUT aux_confirma).
                
            IF aux_confirma = "N" THEN 
               NEXT.
      
            INPUT THROUGH basename `tty` NO-ECHO.
      
            SET aux_nmendter WITH FRAME f_terminal.
            INPUT CLOSE.
            
            aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                  aux_nmendter.
            
            RUN comprova_vida IN h-b1wgen0091(INPUT glb_cdcooper,
                                              INPUT glb_cdoperad,
                                              INPUT 0, /*nrdcaixa*/
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_nmdatela,
                                              INPUT tel_cdagenci,
                                              INPUT 1, /*ayllos*/
                                              INPUT tel_nrrecben,
                                              INPUT tel_nrbenefi,
                                              INPUT tel_nrcpfcgc,
                                              INPUT tel_nmrecben,
                                              INPUT STRING(TIME,"HH:MM:SS"),
                                              INPUT 1,  /*Pelo Beneficiario*/
                                              INPUT "", /*nmprocur*/
                                              INPUT "", /*dsdocpcd*/
                                              INPUT "", /*cdoedpcd*/
                                              INPUT "", /*cdufdpcd*/
                                              INPUT ?,  /*dtvalprc*/
                                              INPUT aux_nmendter,
                                              OUTPUT aux_nmarqimp,
                                              OUTPUT TABLE tt-erro).
      
            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
                  IF AVAIL tt-erro THEN
                     MESSAGE tt-erro.dscritic.
                  ELSE
                     MESSAGE "Nao foi possivel comprovar vida " + 
                             "pelo beneficiario.".
                        
                  PAUSE(2) NO-MESSAGE.
                  HIDE MESSAGE.
      
                  NEXT.
      
               END.
            
         END.
      
      ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_beneficio").

      OPEN QUERY q_beneficio FOR EACH tt-benefic NO-LOCK.

      REPOSITION q_beneficio TO ROW aux_ultlinha.
      
      ASSIGN glb_nmformul = ""
             glb_nrdevias = 1.
      
      FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                               NO-LOCK NO-ERROR.
      
      { includes/impressao.i }
        
      UNIX SILENT VALUE("rm " + aux_nmarqimp + "* 2> /dev/null").
      
      
END.


ON VALUE-CHANGED, ENTRY OF b_beneficio
   DO:
      HIDE FRAME f_dadosp.
      HIDE FRAME f_Dadosspn.
      HIDE FRAME f_comprovar.

      HIDE MESSAGE.

      FIND CURRENT tt-benefic NO-LOCK NO-ERROR.

      ASSIGN tel_nrcpfcgc = tt-benefic.nrcpfcgc
             tel_nmrecben = tt-benefic.nmrecben
             tel_nrrecben = tt-benefic.nrrecben
             tel_nrbenefi = tt-benefic.nrbenefi
             tel_cdagenci = tt-benefic.cdagenci.

      DISP tel_nrcpfcgc
           tel_nmrecben  
           tel_nrrecben 
           tel_nrbenefi 
           tel_cdagenci 
           WITH FRAME f_comprova.

      IF DYNAMIC-FUNCTION("busca_procurador_beneficio" IN h-b1wgen0091,
                                    INPUT glb_cdcooper,
                                    INPUT glb_cdagenci,
                                    INPUT glb_cdoperad,
                                    INPUT 0, /*nrdcaixa*/
                                    INPUT glb_nmdatela,
                                    INPUT glb_cdcooper,
                                    INPUT tt-benefic.nrrecben,
                                    INPUT tt-benefic.nrbenefi,
                                    OUTPUT TABLE tt-lancred) THEN
         DO:
            FIND FIRST tt-lancred 
                 WHERE tt-lancred.nrrecben = tt-benefic.nrrecben AND
                       tt-lancred.nrbenefi = tt-benefic.nrbenefi
                       NO-LOCK NO-ERROR.
         
            
            DISPLAY tt-lancred.nmprocur @ aux_nmprocur 
                    tt-lancred.dsdocpcd @ aux_dsdocpcd
                    tt-lancred.cdoedpcd @ aux_cdoedpcd
                    tt-lancred.cdufdpcd @ aux_cdufdpcd
                    tt-lancred.dtvalprc @ aux_dtvalprc
                    WITH FRAME f_dadosp.

            DISPLAY reg_dsdopcao[1]  
                    reg_dsdopcao[2]
                    WITH FRAME f_comprovar.
         

         END.
      ELSE
         DO:
            VIEW FRAME f_dadospn.

            DISP reg_dsdopcao[1]  
                 reg_dsdopcao[2]
                 WITH FRAME f_comprovar.

         END.


   END. /* Fim do ON VALUE-CHANGED */   


ON RETURN OF b_nome IN FRAME f_nome
   DO:
      FIND CURRENT tt-benefic NO-LOCK NO-ERROR.

      ASSIGN tel_nrcpfcgc = tt-benefic.nrcpfcgc
             tel_nmrecben = tt-benefic.nmrecben
             tel_nrrecben = tt-benefic.nrrecben
             tel_nrbenefi = tt-benefic.nrbenefi
             tel_cdagenci = tt-benefic.cdagenci.

      DISP tel_nrcpfcgc
           tel_nmrecben  
           tel_nrrecben 
           tel_nrbenefi 
           tel_cdagenci 
           WITH FRAME f_comprova.

      CLOSE QUERY q_nome.
      HIDE FRAME f_nome.
      
   END.

   
ASSIGN glb_cdcritic = 0
       glb_cddopcao = "C".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE 0. 

IF NOT VALID-HANDLE(h-b1wgen0091)  THEN
   RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h-b1wgen0091.

RUN carrega_cooperativas IN  h-b1wgen0091 (OUTPUT aux_nmcooper).

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_gera_arq = aux_nmcooper.


INICIO: DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       IF glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
        
           END.

       VIEW FRAME f_opcao.
       HIDE FRAME f_comprova 
            FRAME f_gera_arq NO-PAUSE.

       UPDATE glb_cddopcao
              WITH FRAME f_opcao.

       LEAVE.

    END. /* Fim do DO WHILE TRUE */

    IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
       DO:
           RUN fontes/novatela.p.

           IF CAPS(glb_nmdatela) <> "COMPVI"   THEN
              DO:
                  DISABLE b_nome WITH FRAME f_nome.

                  HIDE FRAME f_procurador
                       FRAME f_comprova
                       FRAME f_dados
                       FRAME f_moldura
                       FRAME f_opcao.

                  IF VALID-HANDLE(h-b1wgen0091)  THEN
                     DELETE OBJECT h-b1wgen0091.

                  RETURN.

              END.
           ELSE
              LEAVE.

       END.

    IF aux_cddopcao <> glb_cddopcao   THEN
       DO:
           { includes/acesso.i }
           aux_cddopcao = glb_cddopcao.
     
       END.


    IF glb_cddopcao = "C" THEN
       DO:
          Principal:
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
             ASSIGN tel_nrcpfcgc = 0
                    tel_nrrecben = 0
                    tel_nrbenefi = 0
                    tel_cdagenci = 0
                    tel_nmrecben = ""
                    aux_nmprocur = ""
                    aux_dsdocpcd = ""
                    aux_cdoedpcd = ""
                    aux_cdufdpcd = ""
                    aux_dtvalprc = ?
                    aux_nrprocur = 0
                    aux_ultlinha = 0.
          
             DISPLAY tel_nrcpfcgc 
                     tel_nrbenefi
                     tel_nrrecben
                     tel_cdagenci
                     tel_nmrecben
                     WITH FRAME f_comprova.
           
             HIDE FRAME f_dadospn.
             HIDE FRAME f_dadossp.
             HIDE FRAME f_comprovar.
             

             Cpf:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
                EMPTY TEMP-TABLE tt-benefic.
          
                HIDE FRAME f_dadosp
                     FRAME f_dadospn.
          
                UPDATE tel_nrcpfcgc 
                       WITH FRAME f_comprova.
          
                IF tel_nrcpfcgc <> 0  THEN
                   DO:
                      RUN busca-dados.
                      
                      IF RETURN-VALUE <> "OK" THEN
                         NEXT INICIO.
                      
                      OPEN QUERY q_beneficio FOR EACH tt-benefic NO-LOCK.
                      
                      ENABLE b_beneficio WITH FRAME f_beneficio.
          
                      PAUSE 0.
          
                      WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                      
                      IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                         DO: 
                             HIDE FRAME f_beneficio.
                             HIDE FRAME f_comprovar.
                             CLOSE QUERY q_beneficio.
                             NEXT Principal.
                         
                         END.
          
                      HIDE FRAME f_beneficio.
          
                      HIDE MESSAGE NO-PAUSE.
                       
                   END.

                LEAVE Cpf.

             END.

             IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                NEXT INICIO.

             IF NOT TEMP-TABLE tt-benefic:HAS-RECORDS  THEN
                DO:
                   Beneficio:
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                      UPDATE tel_nrbenefi 
                             WITH FRAME f_comprova.

                      IF tel_nrbenefi <> 0  THEN
                         DO:
                             FIND FIRST crapcbi 
                                  WHERE crapcbi.cdcooper = glb_cdcooper AND
                                        crapcbi.nrrecben = 0            AND
                                        crapcbi.nrbenefi = tel_nrbenefi
                                        NO-LOCK NO-ERROR.

                             IF NOT AVAIL crapcbi THEN
                                DO:
                                    MESSAGE "Nenhum beneficio encontrado.".
                                    BELL.
                                    NEXT INICIO.

                                END.
                            
                             ASSIGN tel_nrcpfcgc = crapcbi.nrcpfcgc.
                   
                             RUN busca-dados.
                   
                             IF RETURN-VALUE <> "OK" THEN
                                NEXT INICIO.
                   
                             OPEN QUERY q_beneficio 
                                        FOR EACH tt-benefic NO-LOCK.
                          
                             ENABLE b_beneficio WITH FRAME f_beneficio.
                          
                             PAUSE 0.
                          
                             WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                          
                             IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                DO:
                                    HIDE FRAME f_beneficio.
                                    HIDE FRAME f_comprovar.
                                    CLOSE QUERY q_beneficio.
                                    NEXT Principal.
                          
                                END.
                          
                             HIDE FRAME f_beneficio.
                          
                             HIDE MESSAGE NO-PAUSE.
                   
                         END.

                      LEAVE Beneficio.

                   END.

                   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                      NEXT INICIO.

                END.
                   
          
             IF NOT TEMP-TABLE tt-benefic:HAS-RECORDS  THEN
                DO:
                   Recben:
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                      
                      UPDATE tel_nrrecben WITH FRAME f_comprova.
                      
                      IF tel_nrrecben <> 0  THEN
                         DO:
                             FIND FIRST crapcbi 
                                  WHERE crapcbi.cdcooper = glb_cdcooper AND
                                        crapcbi.nrrecben = tel_nrrecben AND
                                        crapcbi.nrbenefi = 0
                                        NO-LOCK NO-ERROR.

                             IF NOT AVAIL crapcbi THEN
                                DO:
                                    MESSAGE "Nenhum beneficio encontrado.".
                                    BELL.
                                    NEXT INICIO.

                                END.
                            
                             ASSIGN tel_nrcpfcgc = crapcbi.nrcpfcgc.
                          
                             RUN busca-dados.
                      
                             IF RETURN-VALUE <> "OK" THEN
                                NEXT INICIO.
                      
                             OPEN QUERY q_beneficio FOR EACH tt-benefic NO-LOCK.
                          
                             ENABLE b_beneficio WITH FRAME f_beneficio.
                          
                             PAUSE 0.
                          
                             WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                          
                             IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                DO:
                                    HIDE FRAME f_beneficio.
                                    HIDE FRAME f_comprovar.
                                    CLOSE QUERY q_beneficio.
                                    NEXT Principal.
                          
                                END.
                          
                             HIDE FRAME f_beneficio.
                          
                             HIDE MESSAGE NO-PAUSE.
                      
                         END.

                      LEAVE Recben.

                   END.

                   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                      NEXT INICIO.
               
                END.
             
          
             IF NOT TEMP-TABLE tt-benefic:HAS-RECORDS  THEN
                DO:
                   Pac:
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       UPDATE tel_cdagenci 
                              tel_nmrecben 
                              WITH FRAME f_comprova.
   
                       RUN busca-dados.
   
                       IF RETURN-VALUE <> "OK" THEN
                          NEXT INICIO.
   
                       OPEN QUERY q_nome FOR EACH tt-benefic NO-LOCK.
                        
                       ENABLE b_nome WITH FRAME f_nome.

                       PAUSE 0.
   
                       WAIT-FOR END-ERROR, RETURN OF DEFAULT-WINDOW.
                       
                       IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                          DO: 
                              HIDE FRAME f_nome.
                              CLOSE QUERY q_beneficio.
                              NEXT Principal.
   
                          END.
   
                       RUN busca-dados.
   
                       IF RETURN-VALUE <> "OK" THEN
                          LEAVE Pac.
   
                       OPEN QUERY q_beneficio FOR EACH tt-benefic NO-LOCK.
   
                       ENABLE b_beneficio WITH FRAME f_beneficio.
   
                       PAUSE 0.
   
                       WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
   
                       IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                          DO: 
                              HIDE FRAME f_beneficio.
                              HIDE FRAME f_comprovar.
                              CLOSE QUERY q_beneficio.
                              NEXT Principal.
   
                          END.
   
                       HIDE FRAME f_beneficio.
   
                       HIDE MESSAGE NO-PAUSE.

                       LEAVE Pac.
   
                   END.

                   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                      NEXT INICIO.

                END.
                      
             LEAVE Principal.
           
          END. /* Fim do DO WHILE TRUE - Principal*/


       END.
    ELSE
       DO:
          ASSIGN tel_cdcooper = "0".

          EMPTY TEMP-TABLE tt-arquivos-comp-vida.

          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             UPDATE tel_cdcooper
                    WITH FRAME f_gera_arq.

             LEAVE.

          END.

          IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
             NEXT INICIO.

          MESSAGE "Aguarde...Gerando arquivo.".

          RUN gera_arquivo_comprovacao_vida IN h-b1wgen0091
                                          (INPUT glb_cdcooper,
                                           INPUT glb_cdoperad,
                                           INPUT 0, /*nrdcaixa*/
                                           INPUT glb_dtmvtolt,
                                           INPUT glb_nmdatela,
                                           INPUT glb_cdagenci,
                                           INPUT 1, /*ayllos*/
                                           INPUT INT(tel_cdcooper),
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-arquivos-comp-vida).

          HIDE MESSAGE NO-PAUSE.

          IF RETURN-VALUE <> "OK" THEN
             DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
           
                IF AVAIL tt-erro THEN
                   MESSAGE tt-erro.dscritic.
                ELSE
                   MESSAGE "Nao foi possivel gerar o(s) arquivo(s).".
                      
                PAUSE(2) NO-MESSAGE.
                HIDE MESSAGE.
           
                NEXT INICIO.
           
             END.

          OPEN QUERY q_arquivos FOR EACH tt-arquivos-comp-vida NO-LOCK.

          ENABLE b_arquivos WITH FRAME f_arquivos.
          
          PAUSE 0.
       
          WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
          
          IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
             DO:
                HIDE FRAME f_arquivos.
                CLOSE QUERY q_arquivos.
                NEXT INICIO.

             END.

       END.

END.


IF VALID-HANDLE(h-b1wgen0091)  THEN
   DELETE PROCEDURE h-b1wgen0091.


PROCEDURE busca-dados:
                              
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    MESSAGE "Aguarde...".

    RUN busca-benefic-compvi IN h-b1wgen0091(INPUT glb_cdcooper,
                                             INPUT 0, /*cdagenci*/
                                             INPUT 0, /*nrdcaixa*/
                                             INPUT glb_nmdatela,
                                             INPUT glb_dtmvtolt,
                                             INPUT 1, /*ayllos*/
                                             INPUT glb_cdoperad,
                                             INPUT tel_nmrecben,
                                             INPUT tel_cdagenci,
                                             INPUT tel_nrcpfcgc,
                                             INPUT aux_nrprocur,
                                             INPUT 9999999,
                                             INPUT 1,
                                             OUTPUT aux_qtregist,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-benefic).


    HIDE MESSAGE NO-PAUSE.

    IF RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           FIND FIRST tt-erro NO-ERROR.
         
           IF AVAILABLE tt-erro THEN
              MESSAGE tt-erro.dscritic.
         
           RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE.



/* .......................................................................... */




