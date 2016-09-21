/* ............................................................................

   Programa: Fontes/improp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2010                          Ultima Atualizaçao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: On-line
   Objetivo  : Listar / Imprimir propostas de emprestimo.
                             
   Alterecoes: 09/08/2010 - Implementar opcao de consulta (Gabriel).
   
               19/11/2010 - Retiraros os 'by' na tt-contratos pois agora
                            os registros ja vem organziados na bo.
                            Adicionado parametro do PDF para o Ayllos
                            Web (Gabriel).            
                            
               28/04/2011 - Esconder frame dos contratos quando erro na
                            monta contratos (Gabriel).             
                            
               08/08/2011 - Obter ID da sessao para impressao (David).
               
               22/07/2013 - Paginar a listagem (Gabriel).
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

............................................................................ */

{ includes/var_online.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0024tt.i }

/* Variaveis da tela */
DEF VAR tel_nrdconta AS INTE                                          NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR                                          NO-UNDO.
DEF VAR tel_cdagenci AS INTE                                          NO-UNDO.
DEF VAR tel_dtiniper AS DATE                                          NO-UNDO.
DEF VAR tel_dtfimper AS DATE                                          NO-UNDO.
DEF VAR tel_nmrelato AS CHAR VIEW-AS SELECTION-LIST MULTIPLE INNER-LINES 5
                             INNER-CHARS 31 LIST-ITEMS
    "1 - Emprestimo.",
    "2 - Limite de credito.",
    "3 - Desconto de cheque.",
    "4 - Desconto de titulo.",
    "5 - Todas Operacoes."                                            NO-UNDO.                                                           

/* Variaveis auxiliares */
DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                          NO-UNDO.
DEF VAR aux_nmrelato AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma AS CHAR                                          NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                          NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                          NO-UNDO.

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"           NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"           NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                          NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                          NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                          NO-UNDO.
DEF VAR par_flgcance AS LOGI                                          NO-UNDO.
DEF VAR par_qtregist AS INTE                                          NO-UNDO.

/* Handle´s */
DEF VAR h-b1wgen0024 AS HANDLE                                        NO-UNDO.


DEF BUFFER bk-contratos FOR tt-contratos. 

DEF QUERY q-contratos FOR tt-contratos.

DEF BROWSE b-contratos QUERY q-contratos
    DISPLAY cdagenci COLUMN-LABEL "PA"           FORMAT "zz9"
            nrdconta COLUMN-LABEL "Conta/dv"      FORMAT "zzzz,zzz,9"
            dsoperac COLUMN-LABEL "Operacao"      FORMAT "x(13)"
            nrctrato COLUMN-LABEL "Contrato"      FORMAT "z,zzz,zz9"
            vloperac COLUMN-LABEL "Valor"         FORMAT "zzz,zz9.99"
            dtmvtolt COLUMN-LABEL "Data     Hora" FORMAT  "99/99/99 HH:MM:SS"
            dsdimpri COLUMN-LABEL "Imp."          FORMAT "!"
        ENABLE tt-contratos.dsdimpri AUTO-RETURN
        VALIDATE(CAN-DO("S,N,T",tt-contratos.dsdimpri),"014 - Opcao errada.")
              
    WITH 8 DOWN TITLE " Contratos ".


FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     WITH FRAME f_moldura.

FORM glb_cddopcao AT 01 LABEL "Opcao"                         AUTO-RETURN
     HELP "Informe a opcao desejada (C,I,E)."
     VALIDATE(CAN-DO("C,I,E",glb_cddopcao),"014 - Opcao errada.")

     tel_nmprimtl AT 27 NO-LABEL FORMAT "x(30)" 

     WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM SKIP(1)
     tel_nrdconta AT 03 LABEL "Conta/dv"  FORMAT "zzzz,zzz,9" AUTO-RETURN
     HELP "Informe o numero da conta, <F7> p/ pesquisa ou <zero> p/ todas."
    
     tel_cdagenci AT 27 LABEL "PA"       FORMAT "zz9"        AUTO-RETURN
     HELP "Informe o numero do PA ou 0 <zero> p/ todos."

     tel_dtiniper AT 37 LABEL "Data"      FORMAT "99/99/9999" AUTO-RETURN
     HELP "Informe a data inicial da geracao da impressao do contrato."
     
     "a"          AT 55
     tel_dtfimper AT 58 NO-LABEL          FORMAT "99/99/9999" AUTO-RETURN   
      HELP "Informe a data final da geracao da impressao do contrato."
        
     SKIP(1)
     "Tipo:"       AT 07 

     WITH CENTERED NO-BOX OVERLAY ROW 7 SIDE-LABELS WIDTH 78 FRAME f_improp.

FORM tel_nmrelato 
     HELP "Pressione <ESPACO> p/ selecionar / <F1> p/ continuar."
     WITH COLUMN 15 NO-BOX NO-LABEL OVERLAY ROW 10 WIDTH 35
      FRAME f_relato.

FORM b-contratos
     HELP "Use as SETAS para navegar. <F4> / <END> para voltar."
     WITH NO-BOX ROW 9 WIDTH 78 OVERLAY CENTERED FRAME f_contratos.   


/* Permitir só a barra de espaco */
ON RETURN OF tel_nmrelato IN FRAME f_relato DO:
    
    RETURN NO-APPLY.

END.


ON VALUE-CHANGED OF tel_nmrelato IN FRAME f_relato DO:

    /* Se selecionou todas , sai do update */
    IF    INPUT tel_nmrelato MATCHES "*5*"  THEN
          DO:
              aux_nmrelato = "5".
              APPLY "GO".              
          END.                 
             
END.
    

/* Montar lista de relatorios a listar */
ON LEAVE OF tel_nmrelato IN FRAME f_relato DO: 

    HIDE MESSAGE NO-PAUSE.

    /* Se nao selecionou nenhum relatorio */
    IF   NUM-ENTRIES(INPUT tel_nmrelato) = ?   THEN
         DO:
             MESSAGE "014 - Opcao errada.".   
             RETURN NO-APPLY.
         END.
        
    ASSIGN aux_nmrelato = "".

    /* Montar lista de relatorios */
    DO aux_contador = 1 TO NUM-ENTRIES(INPUT tel_nmrelato):

        aux_nmrelato = IF   aux_nmrelato = ""   THEN
                            SUBSTR(ENTRY(aux_contador,INPUT tel_nmrelato),1,1)
                       ELSE 
                            aux_nmrelato + "," +
                            SUBSTR(ENTRY(aux_contador,INPUT tel_nmrelato),1,1).
    END.

END.

ON ENTRY, VALUE-CHANGED OF b-contratos DO:

  /* Mostrar o nome do cooperado */
  IF   tel_nmprimtl <> tt-contratos.nmprimtl   THEN
       DO:
           ASSIGN tel_nmprimtl = tt-contratos.nmprimtl.
       
           DISPLAY tel_nmprimtl WITH FRAME f_opcao.
       END.
            
END.


ON ENTRY, GO, END-ERROR OF tt-contratos.dsdimpri DO:

    /* Se selecinou todos */
    IF   CAN-FIND (FIRST tt-contratos WHERE tt-contratos.dsdimpri = "T") THEN
         DO:              
              /* Seta no buffer "sim" para todos */
             FOR EACH bk-contratos WHERE bk-contratos.dsdimpri <> "S":
             
                  bk-contratos.dsdimpri = "S".
             
             END.

             OPEN QUERY q-contratos FOR EACH tt-contratos EXCLUSIVE-LOCK.
         END.       
END.

VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "I".

/* Obtem ID da sessao */
INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.



DO WHILE TRUE:

   RUN fontes/inicia.p.
    
   HIDE FRAME f_improp.
   HIDE FRAME f_contratos.
    
   ASSIGN tel_nrdconta = 0
          tel_nmprimtl = ""
          tel_cdagenci = 0
          tel_dtiniper = ?
          tel_dtfimper = ?
          tel_nmrelato = "".

   DISPLAY tel_nmprimtl WITH FRAME f_opcao.
                                
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE glb_cddopcao 
              WITH FRAME f_opcao.
       LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            RUN fontes/novatela.p.
        
            IF   glb_nmdatela <> "IMPROP"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     RETURN.
                 END.
            NEXT.
        END.
       
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   HIDE MESSAGE NO-PAUSE.
        
   IF   CAN-DO("C,I,E",glb_cddopcao)   THEN /* Consulta/Impressao/Exclusao  */
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            ASSIGN tt-contratos.dsdimpri:READ-ONLY = NO.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_nrdconta 
                       tel_cdagenci
                       tel_dtiniper
                       tel_dtfimper WITH FRAME f_improp

                EDITING:

                    READKEY.

                    /* Zoom do associado  */
                    IF   LASTKEY = KEYCODE("F7")  THEN
                         DO:
                             IF   FRAME-FIELD = "tel_nrdconta"   THEN
                                  DO:
                                      RUN fontes/zoom_associados.p 
                                                       (INPUT glb_cdcooper,
                                                        OUTPUT tel_nrdconta).

                                      DISPLAY tel_nrdconta
                                              WITH FRAME f_improp.

                                  END.
                             ELSE
                                  APPLY LASTKEY.

                         END.
                    ELSE
                         APPLY LASTKEY.

                END. /* Fim do EDITING */

                RUN sistema/generico/procedures/b1wgen0024.p 
                                     PERSISTENT SET h-b1wgen0024.

                RUN valida-dados-contratos IN h-b1wgen0024
                                               (INPUT glb_cdcooper,
                                                INPUT tel_cdagenci,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_nmdatela,
                                                INPUT 1,
                                                INPUT glb_dtmvtolt,
                                                INPUT tel_nrdconta,
                                                INPUT tel_dtiniper,
                                                INPUT tel_dtfimper,
                                                OUTPUT TABLE tt-erro). 
                DELETE PROCEDURE h-b1wgen0024.

                IF   RETURN-VALUE <> "OK"    THEN
                     DO:
                         FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                         IF   AVAIL tt-erro   THEN
                              MESSAGE tt-erro.dscritic.
                         ELSE
                              MESSAGE "Erro na listagem dos contratos.".
                    
                         PAUSE 3 NO-MESSAGE.
                    
                         NEXT.                
                     END.

                /* Deixar todos deselecionados */
                ASSIGN tel_nmrelato = "".

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE tel_nmrelato WITH FRAME f_relato.
                    LEAVE.
                END.

                HIDE FRAME f_relato.

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                     NEXT.

                LEAVE.                                
                
            END. /* Fim do DO WHILE TRUE */ 

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 LEAVE.

            RUN sistema/generico/procedures/b1wgen0024.p 
                                 PERSISTENT SET h-b1wgen0024.
    
            RUN lista-contratos-sede IN h-b1wgen0024 
                                            (INPUT glb_cdcooper,
                                             INPUT tel_cdagenci,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT 1,
                                             INPUT glb_dtmvtolt,
                                             INPUT aux_nmrelato,
                                             INPUT tel_nrdconta,
                                             INPUT tel_dtiniper,
                                             INPUT tel_dtfimper,
                                             INPUT 9999999,
                                             INPUT 1,
                                            OUTPUT par_qtregist,
                                            OUTPUT TABLE tt-contratos).
       
            DELETE PROCEDURE h-b1wgen0024.

            IF   NOT TEMP-TABLE tt-contratos:HAS-RECORDS THEN
                 DO:
                     MESSAGE "Nao ha contrato(os) para estas condicoes.".
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                 END.

            IF   glb_cddopcao = "I"   THEN
                 ASSIGN tt-contratos.dsdimpri:HELP = 
                        "Informe para imprimir ((S)im / (N)ao / (T)odos).".
            ELSE
            IF   glb_cddopcao = "E"   THEN
                 ASSIGN tt-contratos.dsdimpri:HELP =
                        "Informe para excluir ((S)im / (N)ao / (T)odos). ".
            ELSE
            IF   glb_cddopcao = "C"   THEN    
                 ASSIGN tt-contratos.dsdimpri:READ-ONLY = YES.
                  
            OPEN QUERY q-contratos FOR EACH tt-contratos EXCLUSIVE-LOCK.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b-contratos WITH FRAME f_contratos.
               LEAVE.
            END.

            /* Opcao C é só de Consulta */
            IF   glb_cddopcao = "C"   THEN
                 LEAVE.

            /* Se nao selecionou nenhum para imprimir, volta */
            IF   NOT CAN-FIND (FIRST tt-contratos WHERE 
                                     tt-contratos.dsdimpri = "S") THEN
                 LEAVE.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).   

            IF   aux_confirma <> "S" THEN
                 LEAVE.


            ASSIGN aux_nomedarq = "".

            /* Colocar numa lista todos os contratos */
            FOR EACH tt-contratos WHERE tt-contratos.dsdimpri = "S" NO-LOCK:

                IF   aux_nomedarq <> "" THEN
                     aux_nomedarq = aux_nomedarq + ",".

                ASSIGN aux_nomedarq = aux_nomedarq  + tt-contratos.nomedarq.

            END.

            IF   glb_cddopcao = "I"   THEN /* Impressao */
                 DO:
                    RUN sistema/generico/procedures/b1wgen0024.p
                                 PERSISTENT SET h-b1wgen0024.

                     RUN monta-contratos IN h-b1wgen0024 
                                            (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT 1,
                                             INPUT glb_dtmvtolt,
                                             INPUT aux_nomedarq,
                                             INPUT aux_nmendter,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqpdf).

                     DELETE PROCEDURE h-b1wgen0024.   

                     IF   RETURN-VALUE <> "OK"    THEN
                          DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
                          
                              IF   AVAIL tt-erro   THEN
                                   MESSAGE tt-erro.dscritic.
                              ELSE
                                   MESSAGE "Erro na impressao dos contratos.".
                          
                              HIDE FRAME f_contratos.

                              PAUSE 3 NO-MESSAGE.
                          
                              NEXT.                
                          END.

                     ASSIGN par_flgrodar = TRUE
                            glb_nmformul = "132col"
                            glb_nrdevias = 1.
                     
                     RUN proc-impressao.

                /* Mostrar mensagem de impressao nao efetuada se acontecer */
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             PAUSE 2 NO-MESSAGE.
                             LEAVE.
                          END.

                 END.  /* Fim Opcao I 'IMPRESSAO ' */
            ELSE
            IF   glb_cddopcao = "E"   THEN
                 DO:
                     RUN sistema/generico/procedures/b1wgen0024.p 
                                         PERSISTENT SET h-b1wgen0024.

                     RUN deleta-contratos IN h-b1wgen0024
                                             (INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT 1,
                                              INPUT glb_dtmvtolt,
                                              INPUT aux_nomedarq,
                                              OUTPUT TABLE tt-erro).

                     DELETE PROCEDURE h-b1wgen0024.
        
                     IF   RETURN-VALUE <> "OK"    THEN
                          DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
                          
                              IF   AVAIL tt-erro   THEN
                                   MESSAGE tt-erro.dscritic.
                              ELSE
                                   MESSAGE "Erro na exclusao dos contratos.".
                          
                              PAUSE 3 NO-MESSAGE.
                          
                              NEXT.                
                          END.

                     DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                        MESSAGE "Operacao efetuada com sucesso.".
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                        LEAVE.
                     END.                     

                 END. /* Fim Opcao E 'EXCLUSAO' */

            LEAVE.

        END. /* Fim DO WHILE TRUE - Opcao C, I e E */

END. /* Fim do DO WHILE TRUE */


/*  Procedure para nao quebrar o programa por se o usuario der F4/END-ERROR  */
/*  na hora de digitacao da impressao                                        */
PROCEDURE proc-impressao:

   FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   { includes/impressao.i }

END.

/* ......................................................................... */
