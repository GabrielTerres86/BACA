/* ............................................................................

   Programa: Fontes/dctrora.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela DCTROR.

   Alteracoes: 30/08/94 - Alterado para nao permitir alteracoes em associados
                          com dtelimin (Deborah).

               28/10/94 - Alterado para incluir o indicador de cheque 6 (Odair)

               06/07/95 - Se o indicador do crapchq e crapchr tiver 8 entao
                          enviar a critica 320 (Odair).

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               06/11/98 - Tratar situacao em prejuizo (Deborah).

               18/08/1999 - Tratar incheque = 6 (Deborah).

               23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).
                            
               31/07/2003 - Alterar a conta do convenio do BB de fixo para 
                            a variavel aux_lsconta2 ou aux_lsconta3 (Fernando).
                             
               08/09/2004 - Tratar conta integracao (Margarete).
               
               17/11/2004 - Diminuido tamanho da mensagem de tipo de transacao
                            errado. Pedir confirmacao de operacao (Evandro).
                            
               09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               21/10/2005 - Tratamento da tabela crapfdc (SQLWorks - Andre).
               
               22/10/2005 - Criacao da funcao para conta de integracao
                            (SQLWorks - Andre).
                            
               23/10/2005 - Retirada da variavel tel_nrtalchq dos FORMs f_erros
                            f_label e f_lanctos (SQLWorks - Andre).

               01/11/2005 - Implementar a chamada da rotina fontes/digbbx.p
                            (Edson).
                            
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               13/02/2007 - Incluidos novos campos utilizados na operacao tipo
                            2(contra-ordem), e efetuada alteracao para nova
                            estrutura crapcor (Diego).
                            Alterar consultas com indice crapfdc1 (David).

               05/03/2007 - Alteracao na crapcch para o BANCOOB (Evandro).
               
               11/05/2007 - Melhoria no controle da criacao da "crapcch"
                            (Evandro).
                            
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find e CAN-FIND" da tabela
                            CRAPHIS.
                          - Incluido parametro "glb_cdcooper" para possibilitar
                            a chamada do programa fontes/zoom_historicos.p.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               16/03/2010 - Adaptacao Projeto IF CECRED (Guilherme).
               
               25/03/2010 - Ajuste para o <F7> do historico (Gabriel).
               
               08/06/2011 - Adaptacao para uso de BO. (André - DB1)
               
               13/12/2011 - Inclusão de parametro de saída tel_dtvalcor 
                            (André R./Supero)
                            
               16/04/2012 - Ajuste na impressao da Contra-Ordem (Ze).
               
               18/05/2012 - Alterar Mensagem de Prov. p/ Permanente (Ze).
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................ */
{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0095tt.i }
{ includes/var_dctror.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM }

DEF VAR h-b1wgen0095 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dtvalcor AS DATE                                           NO-UNDO.
DEF VAR aux_flprovis AS LOGI INIT FALSE                                NO-UNDO.
DEF VAR aux_flgtroca AS LOGI INIT FALSE                                NO-UNDO.

ASSIGN glb_cdcritic = 0
       tel_dsprovis = "".
       
IF  NOT VALID-HANDLE(h-b1wgen0095)  THEN
    RUN sistema/generico/procedures/b1wgen0095.p
        PERSISTENT SET h-b1wgen0095.

Princ: DO WHILE TRUE:

    HIDE FRAME f_prov_a NO-PAUSE.
    
    RUN busca-dados.
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            IF  aux_msgretor <> "" THEN
                DO:
                    MESSAGE aux_msgretor.
                    CLEAR FRAME f_dctror.
                    LEAVE Princ.
                END.
        END.
    
    FIND FIRST tt-dctror NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-dctror THEN
        DO:
            ASSIGN tel_nmprimtl = tt-dctror.nmprimtl
                   tel_cdsitdtl = tt-dctror.cdsitdtl
                   tel_dssitdtl = tt-dctror.dssitdtl
                   tel_cdhistor = tt-dctror.cdhistor
                   tel_nrinichq = tt-dctror.nrinichq
                   tel_nrfinchq = tt-dctror.nrfinchq
                   tel_nrctachq = tt-dctror.nrctachq
                   tel_cdbanchq = tt-dctror.cdbanchq
                   tel_cdagechq = tt-dctror.cdagechq.
    
            DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl WITH FRAME f_dctror.
    
            RUN busca-ctachq IN h-b1wgen0095
                ( INPUT glb_cdcooper,
                  INPUT 0,
                  INPUT 0,
                  INPUT tel_nrdconta,
                  INPUT glb_cdoperad,
                  INPUT glb_nmdatela,
                  INPUT 1,
                  INPUT 1,
                  INPUT YES,
                  INPUT tel_nrinichq,
                  INPUT tel_cdbanchq,
                  INPUT tel_cdagechq,
                  INPUT tel_nrctachq,
                  INPUT glb_cddopcao,
                  INPUT tel_cdsitdtl,
                  INPUT aux_dsdctitg,
                  INPUT 1,
                 OUTPUT tel_dtemscor,
                 OUTPUT tel_cdhistor,
                 OUTPUT tel_nrfinchq,
                 OUTPUT tel_dtvalcor,
                 OUTPUT aux_flprovis,
                 OUTPUT TABLE tt-erro ).
    
                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                LEAVE Princ.  
                            END.
                    END.
    
                IF   tel_dtvalcor <> ? THEN
                     tel_dsprovis = "SIM".
                ELSE
                     tel_dsprovis = "NAO".

                DISPLAY tel_dtemscor tel_cdhistor tel_cdbanchq tel_cdagechq 
                        tel_nrctachq tel_nrinichq tel_nrfinchq tel_dtvalcor 
                        WITH FRAME f_dctror.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                ASSIGN aux_flgtroca = FALSE.
                
                SET tel_cdbanchq WITH FRAME f_dctror
    
                EDITING:
                    READKEY.
                    APPLY LASTKEY.
    
                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN INPUT tel_cdbanchq.
    
                            RUN valida-agechq IN h-b1wgen0095
                                ( INPUT glb_cdcooper, 
                                  INPUT 0,            
                                  INPUT 0,            
                                  INPUT glb_cdoperad, 
                                  INPUT glb_nmdatela, 
                                  INPUT 1,            
                                  INPUT tel_nrdconta, 
                                  INPUT 1, 
                                  INPUT YES,
                                  INPUT tel_cdbanchq,
                                  INPUT glb_cddopcao,
                                 OUTPUT tel_cdagechq,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-erro ).
                
                            IF  RETURN-VALUE <> "OK"  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-erro  THEN
                                        DO:
                                            MESSAGE tt-erro.dscritic.
                                            {sistema/generico/includes/foco_campo.i
                                                &VAR-GERAL=SIM
                                                &NOME-FRAME="f_dctror"
                                                &NOME-CAMPO=aux_nmdcampo }
                                        END.
                                END.
                        END.
                END.
    
                DISPLAY tel_cdagechq WITH FRAME f_dctror.
    
                SET tel_nrctachq tel_nrinichq WITH FRAME f_dctror
    
                EDITING:
    
                    READKEY.
                    APPLY LASTKEY.
    
                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN INPUT tel_nrctachq
                                   INPUT tel_nrinichq.
    
                            RUN valida-ctachq IN h-b1wgen0095
                                ( INPUT glb_cdcooper, 
                                  INPUT 0,            
                                  INPUT 0,            
                                  INPUT glb_cdoperad, 
                                  INPUT glb_nmdatela, 
                                  INPUT 1,            
                                  INPUT tel_nrdconta, 
                                  INPUT 1, 
                                  INPUT YES,
                                  INPUT glb_dtmvtolt,
                                  INPUT tel_dtemscor,
                                  INPUT tel_nrctachq,
                                  INPUT tel_nrinichq,
                                  INPUT tel_nrfinchq,
                                  INPUT glb_cddopcao,
                                  INPUT tel_cdbanchq,
                                  INPUT tel_cdhistor,
                                 OUTPUT aux_dsdctitg,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-erro ).
    
                            IF  RETURN-VALUE <> "OK"  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-erro  THEN
                                        DO:
                                            MESSAGE tt-erro.dscritic.
                                                
                                            ASSIGN tel_cdhistor = 0
                                                   tel_nrfinchq = 0
                                                   tel_dtemscor = ?.
                                            DISPLAY tel_dtemscor 
                                                    tel_cdhistor 
                                                    tel_nrfinchq
                                                    WITH FRAME f_dctror.
                
                                            {sistema/generico/includes/foco_campo.i
                                                &NOME-FRAME="f_dctror"
                                                &NOME-CAMPO=aux_nmdcampo }
                                        END.
                                END.
                        END.
                END.
    
                LEAVE.
            END.
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                LEAVE Princ.  /* Volta pedir a opcao para o operador */
    
            DO WHILE TRUE:
    
                RUN busca-ctachq IN h-b1wgen0095
                    ( INPUT glb_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT tel_nrdconta,
                      INPUT glb_cdoperad,
                      INPUT glb_nmdatela,
                      INPUT 1,
                      INPUT 1,
                      INPUT YES,
                      INPUT tel_nrinichq,
                      INPUT tel_cdbanchq,
                      INPUT tel_cdagechq,
                      INPUT tel_nrctachq,
                      INPUT glb_cddopcao,
                      INPUT tel_cdsitdtl,
                      INPUT aux_dsdctitg,
                      INPUT 2,
                     OUTPUT tel_dtemscor,
                     OUTPUT tel_cdhistor,
                     OUTPUT tel_nrfinchq,
                     OUTPUT tel_dtvalcor,
                     OUTPUT aux_flprovis,
                     OUTPUT TABLE tt-erro ).
    
                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                CLEAR FRAME f_dctror.
                                LEAVE Princ.  
                            END.
                    END.

                IF   tel_dtvalcor <> ? THEN
                     tel_dsprovis = "SIM".
                ELSE
                     tel_dsprovis = "NAO".
                
                DISPLAY tel_dtemscor tel_cdhistor tel_dtvalcor tel_dsprovis
                        WITH FRAME f_dctror.

                IF  aux_flprovis THEN DO:

                    /* Validacao Provisorio/Permanente */

                    ASSIGN aux_confirma = "".

                    UPDATE aux_confirma WITH FRAME f_prov_a.
                    
                    HIDE FRAME f_prov_a NO-PAUSE.
                    
                    IF  aux_confirma = "S"   THEN
                        DO:
                            ASSIGN aux_flprovis = FALSE
                                   aux_dtvalcor = ?
                                   tel_dtvalcor = ?
                                   tel_dsprovis = "NAO"
                                   aux_flgtroca = TRUE.
                            
                            DISPLAY tel_dtvalcor tel_dsprovis 
                                    WITH FRAME f_dctror.
                        END.
                    /* Fim Validacao Provisorio/Permanente */
                    
                END.
    
                UPDATE tel_cdhistor WITH FRAME f_dctror
    
                EDITING:
    
                    READKEY.
    
                    IF  LASTKEY = KEYCODE("F7")       AND
                        FRAME-FIELD = "tel_cdhistor"  THEN
                        DO:
                            RUN fontes/zoom_historicos.p
                                ( INPUT glb_cdcooper,  
                                  INPUT FALSE, 
                                  INPUT 9, 
                                 OUTPUT tel_cdhistor ).
                              
                            DISPLAY tel_cdhistor WITH FRAME f_dctror.    
                        END.
                    ELSE
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                            LEAVE.
                        ELSE
                            APPLY LASTKEY.
    
                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN INPUT tel_cdhistor.
    
                            RUN valida-hist IN h-b1wgen0095
                                ( INPUT glb_cdcooper, 
                                  INPUT 0,            
                                  INPUT 0,            
                                  INPUT glb_cdoperad, 
                                  INPUT glb_nmdatela, 
                                  INPUT 1,            
                                  INPUT tel_nrdconta, 
                                  INPUT 1, 
                                  INPUT YES,
                                  INPUT tel_cdhistor,
                                 OUTPUT aux_tplotmov,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-erro ).
                          
                            IF  RETURN-VALUE <> "OK"  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-erro  THEN
                                        DO:
                                            MESSAGE tt-erro.dscritic.
                                            {sistema/generico/includes/foco_campo.i
                                                &NOME-FRAME="f_dctror"
                                                &NOME-CAMPO=aux_nmdcampo }
                                        END.
                                END.
                        END.
                END.  /*  Fim do EDITING  */
    
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE Princ.  /* Volta pedir a opcao para o operador */
    
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                    ASSIGN aux_confirma = "N"
                           glb_cdcritic = 78.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                    ASSIGN glb_cdcritic = 0.
                    LEAVE.
                
                END.
    
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S"                  THEN
                    DO:
                        ASSIGN glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        ASSIGN glb_cdcritic = 0.
                        LEAVE.
                    END.
    
                RUN grava-dados.
    
                IF  RETURN-VALUE <> "OK"  THEN
                    NEXT.
                
                MESSAGE "Alteracao efetuada com sucesso!".
                PAUSE 2 NO-MESSAGE.
                HIDE MESSAGE NO-PAUSE.
                CLEAR FRAME f_dctror NO-PAUSE.
      
                IF   aux_flgtroca THEN
                     DO:
                         RUN imprimir.
                     END.
                     
                LEAVE Princ.
                
            END.  /* Fim do DO WHILE TRUE */
    
        END.

        LEAVE Princ.
    END.

IF  VALID-HANDLE(h-b1wgen0095)  THEN
    DELETE PROCEDURE h-b1wgen0095.

/* ......................................................................... */

PROCEDURE busca-dados:

    RUN busca-dados IN h-b1wgen0095
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT TRUE,
          INPUT glb_cddopcao,
          INPUT tel_tptransa,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-dctror ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                END.
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE grava-dados:
    DEF VAR par_cdsitdtl AS CHAR                                       NO-UNDO.
    DEF VAR par_dssitdtl AS CHAR                                       NO-UNDO.

    RUN grava-dados IN h-b1wgen0095
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT 1,
          INPUT TRUE,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_tptransa,
          INPUT aux_tplotmov,
          INPUT tel_cdbanchq,
          INPUT tel_cdagechq,
          INPUT tel_nrctachq, 
          INPUT tel_nrinichq,
          INPUT tel_cdhistor,
          INPUT 2,            /*  par_stlcmexc - Exclusão */
          INPUT 1,            /*  par_stlcmcad - Inclusão */
          INPUT tel_dtemscor, /* aux_dtemscch */
          INPUT aux_dsdctitg,
          INPUT aux_flprovis,
          INPUT aux_dtvalcor,
          INPUT TABLE tt-cheques,
          INPUT TABLE tt-custdesc,
         OUTPUT par_cdsitdtl,
         OUTPUT par_dssitdtl,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT aux_msgrecad,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-criticas,
         OUTPUT TABLE tt-contra ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                END.
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE imprimir:

/*    VIEW FRAME f_aguarde.*/

    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter. 

    RUN imprimir-dados IN h-b1wgen0095
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT aux_nmendter,
          INPUT glb_cddopcao,
          INPUT TABLE tt-contra,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro ).

    HIDE FRAME f_aguarde NO-PAUSE.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                END.
            NEXT.
        END.

    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper AND
                             crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

    ASSIGN glb_nmformul = "132col"
           glb_nrdevias = 1
           par_flgrodar = TRUE
           glb_nmarqimp = aux_nmarqimp.

    PAUSE 0.

    { includes/impressao.i }

END PROCEDURE.

