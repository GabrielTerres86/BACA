/* ............................................................................

   Programa: Fontes/dctrore.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 11/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela DCTROR.

   Alteracoes: 30/08/94 - Alterado para nao permitir alteracoes em associados
                          com dtelimin (Deborah).

               28/10/94 - Alterado para incluir o indicador de cheque 6 (Odair)

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               06/11/98 - Tratar situacao em prejuizo (Deborah).
               
               10/11/98 - Logar a alteracao de situacao do titular (Deborah).

               18/08/1999 - Tratar incheque = 6 (Deborah). 
                
               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               30/09/2002 - Log da pessoa de exclui a contra-ordem (Margarete).

               31/07/2003 - Alterar a conta do convenio do BB de fixo para   
                            a variavel aux_lsconta2 ou aux_lsconta3 (Fernando).
 
               20/08/2004 - Alterado para criar registro de baixa da
                            contra-ordem a ser enviada ao BANCO DO BRASIL
                            (Edson).
 
               08/09/2004 - Tratar conta integracao (Margarete).
               
               17/11/2004 - Pedir confirmacao de operacao (Evandro).

               01/07/2005 - Alimentado campo cdcooper das tabelas craprej
                            e crapalt (Diego).

               26/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               22/10/2005 - Criacao da funcao para conta de integracao
                            (SQLWorks - Andre).
                            
               23/10/2005 - Retirada da variavel tel_nrtalchq dos FORMs f_erros
                            f_label e f_lanctos (SQLWorks - Andre).

               31/10/2005 - Implementar a chamada da rotina fontes/digbbx.p
                            (Edson).

               19/01/2006 - Gera log exclusao conta ordem (Mirtes)

               20/01/2006 - Gera log exclusao NAO CONFIRMADA(Mirtes)
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               27/06/2006 - Desprezar critica 219(Problemas no sistema BB que
                            nao cadastra contra-ordens para cheques que
                            passaram pela compe)(Mirtes)
                            
               14/02/2007 - Incluidos novos campos utilizados na operacao tipo
                            2(contra-ordem), e efetuada alteracao para nova
                            estrutura crapcor (Diego).
                            Alterar consultas com indice crapfdc1 (David).
                             
               11/05/2007 - Melhoria no controle da criacao da "crapcch"
                            (Evandro).

               24/10/2007 - Alteracao forma de gerar log na hora de 
                            cancelamento de contra-ordem (Guilherme).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

              19/10/2009 - Alteracao Codigo Historico (Kbase).
              
              16/03/2010 - Adaptacao Projeto IF CECRED (Guilherme).
              
              11/01/2011 - Excluir contra-ordem apos ter compensado o cheque,
                           solicitando a senha de coordenador (Ze).
                           
              11/02/2011 - Opcao de excluir de varios registros de contra-ordem
                           Impressao de termo de exclusao de contra-ordem
                          (GATI - Daniel/Eder)             
                          
              28/03/2011 - Acerto na alteracao acima, esta dando message de OK
                           porem todas alteracoes nao estao na mesma transacao
                           e o operador tecla END-ERROR (Guilherme).
                           
              08/06/2011 - Adaptacao para uso de BO. (André - DB1)
              
              13/12/2011 - Inclusão de parametro de saída tel_dtvalcor 
                           (André R./Supero)
                           
              30/05/2014 - Concatena o numero do servidor no endereco do
                           terminal (Tiago-RKAM).
                           
              11/09/2014 - Incluido tratamento para habilitar o campo agencia, 
                           quando for uma conta migrada da concredi 
                           ou credimilsul (Odirlei/AMcom).                 
                                       
............................................................................ */
{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0095tt.i }
{ includes/var_dctror.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF STREAM str_1.

DEF VAR h-b1wgen0095 AS HANDLE                                         NO-UNDO.
DEF VAR cdhistor AS CHARACTER                                          NO-UNDO.

DEF VAR aux_dtvalcor AS DATE                                           NO-UNDO.
DEF VAR aux_flprovis AS LOGI INIT FALSE                                NO-UNDO.
DEF VAR aux_flimprim AS LOGI INIT FALSE                                NO-UNDO.
DEF VAR aux_cdagechq AS INTEGER                                        NO-UNDO.
DEF VAR aux_cdageant AS INTEGER                                        NO-UNDO.

DEF QUERY q_contra FOR tt-contra.

DEF BROWSE b_contra QUERY q_contra
    DISP cdhistor NO-LABEL FORMAT "zzzz"
         tt-contra.cdbanchq NO-LABEL FORMAT ">>>>>>9"       
         tt-contra.cdagechq NO-LABEL FORMAT ">>>>>>"
         tt-contra.nrctachq NO-LABEL FORMAT ">>>>>>,>>>,>>>,>"
         tt-contra.nrinichq NO-LABEL FORMAT "zzz,zzz,z "   
         tt-contra.nrfinchq NO-LABEL FORMAT "zzz,zzz,z"   
         tt-contra.flprovis NO-LABEL FORMAT "  SIM/  NAO"
    WITH 5 DOWN  NO-BOX.

FORM b_contra AT 1 
    WITH ROW 14 COLUMN 2 FRAME f_browse OVERLAY NO-BOX.

FORM " Aguarde... Imprimindo CANCELAMENTO SUSTACAO/CONTRAORDEM! "
    WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.


IF  NOT VALID-HANDLE(h-b1wgen0095)  THEN
    RUN sistema/generico/procedures/b1wgen0095.p
        PERSISTENT SET h-b1wgen0095.

Princ: DO WHILE TRUE ON ENDKEY UNDO Princ, LEAVE Princ:

    EMPTY TEMP-TABLE tt-dctror.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cheques.
    EMPTY TEMP-TABLE tt-custdesc.
    EMPTY TEMP-TABLE tt-contra.
    EMPTY TEMP-TABLE tt-criticas.
    ASSIGN tel_nmprimtl = ""
           tel_cdsitdtl = 0
           tel_dssitdtl = ""
           tel_dtemscor = ?
           tel_cdhistor = 0
           tel_nrinichq = 0
           tel_nrfinchq = 0
           tel_nrctachq = 0.
                            
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
            FIND FIRST tt-dctror NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-dctror  THEN
                DO:
                    CLEAR FRAME f_dctror NO-PAUSE.
                    
                    ASSIGN tel_nmprimtl = tt-dctror.nmprimtl
                           tel_cdsitdtl = tt-dctror.cdsitdtl
                           tel_dssitdtl = tt-dctror.dssitdtl.

                    DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl
                        WITH FRAME f_dctror.
                END.
    
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    NEXT-PROMPT tel_nrdconta WITH FRAME f_dctror.
                    LEAVE Princ.
                END.
        END.
    
    FIND FIRST tt-dctror NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-dctror  THEN
        DO:
            ASSIGN tel_nmprimtl = tt-dctror.nmprimtl
                   tel_cdsitdtl = tt-dctror.cdsitdtl
                   tel_dssitdtl = tt-dctror.dssitdtl
                   tel_dtemscor = tt-dctror.dtemscor
                   tel_cdhistor = tt-dctror.cdhistor
                   tel_nrinichq = tt-dctror.nrinichq
                   tel_nrfinchq = tt-dctror.nrfinchq
                   tel_nrctachq = tt-dctror.nrctachq
                   tel_dtemscor = tt-dctror.dtemscor 
                   tel_cdbanchq = tt-dctror.cdbanchq 
                   tel_cdagechq = tt-dctror.cdagechq.
        END.
    IF  tel_tptransa = 2 THEN
        DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl tel_dtemscor
                /*tel_cdhistor tel_cdbanchq tel_cdagechq tel_nrctachq
                tel_nrinichq tel_nrfinchq*/
                WITH FRAME f_dctror.
    
    IF  tel_tptransa = 1 OR tel_tptransa = 3  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE Princ:
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
                    LEAVE Princ.
                END.
    
            RUN grava-dados.
            IF  RETURN-VALUE <> "OK" THEN
                LEAVE Princ.
    
            DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl tel_dtemscor
                    tel_cdhistor tel_nrctachq tel_nrinichq tel_nrfinchq
                    WITH FRAME f_dctror.
    
            /* trata a critica 401 */
            IF  aux_msgrecad <> "" THEN
                DO:
                   ASSIGN aux_confirma = "N".
                   MESSAGE aux_msgrecad UPDATE aux_confirma.
                END.
            ELSE
                ASSIGN aux_confirma = "S".
         
            IF  aux_confirma = "S" THEN
                /* verificar se é necessario registrar o crapalt */
                RUN proc_altcad (INPUT "b1wgen0095.p").
    
            CLEAR FRAME f_dctror NO-PAUSE.
            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Exclusao efetuada com sucesso!".
            PAUSE 2 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.
    
        END.
    ELSE
        DO:
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
                  INPUT 0,
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
                            NEXT-PROMPT tel_nrdconta WITH FRAME f_dctror.
                            LEAVE Princ.  
                        END.
                END.
    
            EMPTY TEMP-TABLE tt-contra.
           
            Editar: DO WHILE TRUE ON ENDKEY UNDO, LEAVE Princ:
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    DO:
                        CLEAR FRAME f_dctror NO-PAUSE.
                        LEAVE.
                    END.
    
                IF  aux_lcontrat = YES  THEN 
                    DO:
                        ASSIGN tel_cdhistor = 0
                               tel_nrinichq = 0
                               tel_nrfinchq = 0
                               tel_nrctachq = 0
                               tel_cdbanchq = 0
                               tel_cdagechq = 0.
    
                        DISPLAY tel_nmprimtl tel_cdsitdtl tel_dssitdtl tel_dtemscor
                                tel_cdhistor tel_cdbanchq tel_cdagechq tel_nrctachq
                                tel_nrinichq tel_nrfinchq tel_dtvalcor
                                WITH FRAME f_dctror. 
                        ASSIGN aux_lcontrat = NO.
                    END.
               
                IF  CAN-FIND(FIRST tt-contra)   THEN 
                    DO:
                        OPEN QUERY q_contra FOR EACH tt-contra.
                        DISP b_contra WITH FRAME f_browse.
                        ENABLE ALL WITH FRAME f_browse.
                    END.

                ASSIGN tel_cdhistor = 0
                       tel_cdbanchq = 0
                       tel_cdagechq = 0
                       tel_nrctachq = 0
                       tel_nrinichq = 0
                       tel_nrfinchq = 0
                       tel_dtvalcor = ?.
    
                DISPLAY tel_cdhistor tel_cdbanchq tel_cdagechq tel_nrctachq 
                        tel_nrinichq tel_nrfinchq tel_dtvalcor
                        WITH FRAME f_dctror.
    
                Banco: DO WHILE TRUE:
    
                    ASSIGN glb_cdcritic = 0.
                    MESSAGE COLOR NORMAL
                        "F1 - Confirmar exclusao, F4/END - Cancelar exclusao.".
               
                    SET tel_cdbanchq WITH FRAME f_dctror
               
                    EDITING:
    
                        READKEY.
    
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
                            DO:
                                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    aux_confirma = "N".
                             
                                    BELL.
                                    HIDE MESSAGE NO-PAUSE.
                                    MESSAGE COLOR NORMAL "Deseja abandonar " +  
                                                          "esta inclusão?(S/N)"
                                         UPDATE aux_confirma.
                                    glb_cdcritic = 0.
                                    LEAVE.
                                END.
    
                                IF  aux_confirma = "n" THEN
                                    NEXT Banco.
            
                                IF  aux_confirma = "s"   THEN 
                                    DO:
                                        RUN gera-log.
                                        CLEAR FRAME f_dctror NO-PAUSE.
                                        UNDO Princ, LEAVE Princ. 
                                    END. 
                            END.
        
                        IF  LASTKEY = KEYCODE("F1")   THEN 
                            DO:
                                HIDE MESSAGE NO-PAUSE.
        
                                IF  NOT CAN-FIND(FIRST tt-contra)   THEN 
                                    DO:
                                        MESSAGE 
                                        "Nenhuma Contra Ordem foi Informada!".
                                    END.
                                ELSE 
                                    DO:
                                        glb_cdcritic = 78.
                                        RUN fontes/critic.p.
                                        BELL.
                                        aux_confirma = "N".
                                        MESSAGE COLOR NORMAL glb_dscritic 
                                                UPDATE aux_confirma.
                                        glb_cdcritic = 0.
    
                                        IF   aux_confirma = "S"   THEN
                                             LEAVE Editar.
                                    END.
                            END.
                        ELSE
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
                                  END. /* Fim EDITING */
                                            
                                  DISPLAY tel_cdagechq WITH FRAME f_dctror.
                                    
                                  /*odirlei*/                    
                                  /* Verificar se é uma conta migrada da 
                                     concredi ou credimilsul*/
                                  FIND FIRST craptco 
                                      WHERE craptco.cdcooper = glb_cdcooper AND
                                            craptco.nrdconta = tel_nrdconta AND
                                           (craptco.cdcopant = 4 OR 
                                            craptco.cdcopant = 15 ) 
                                      NO-LOCK NO-ERROR.
                
                                    /* Se localizar a conta, então deve permitir 
                                    informar a agencia*/
                                    IF  AVAIL(craptco) THEN 
                                    DO:
                                        MESSAGE COLOR NORMAL
                                          "F1 - Confirmar inclusao, F4/END - " +
                                          "Cancelar inclusao.".
                                        /* Guardar valor atual para verificar 
                                          se foi alterado*/
                                        ASSIGN aux_cdagechq = tel_cdagechq.                                                               
            
                                        SET tel_cdagechq WITH FRAME f_dctror
            
                                        EDITING:
                                            READKEY.
                                       
                                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                                NEXT Banco.
                                       
                                            IF  LASTKEY = KEYCODE("F1")   THEN 
                                            DO:
                                                HIDE MESSAGE NO-PAUSE.
                                   
                                                IF  NOT CAN-FIND(FIRST tt-contra)   THEN 
                                                DO:
                                                    MESSAGE 
                                                    "Nenhuma Contra Ordem foi Informada!".
                                                END.
                                                ELSE
                                                DO:
                                                    glb_cdcritic = 78.
                                                    RUN fontes/critic.p.
                                                    BELL.
                                                    aux_confirma = "N".
                                                    MESSAGE COLOR NORMAL glb_dscritic 
                                                            UPDATE aux_confirma.
                                                    glb_cdcritic = 0.
                                                   
                                                    IF  aux_confirma = "S"   THEN
                                                        LEAVE Editar.
                                                END.
                                            END.
                                            ELSE
                                               APPLY LASTKEY.
                            
                                            IF  GO-PENDING  THEN
                                            DO:
                                                ASSIGN INPUT tel_cdagechq.
                                                
                                                /* somente necessario validar 
                                                   se foi alterado*/
                                                IF aux_cdagechq <> tel_cdagechq THEN 
                                                DO:
                                                    /*validar agencia na cooperativa antiga*/
                                                    RUN valida-agechq IN h-b1wgen0095
                                                        ( INPUT craptco.cdcopant, 
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
                                                         OUTPUT aux_cdageant,
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
                                                    IF tel_cdagechq <> aux_cdageant THEN
                                                      DO:
                                                        MESSAGE "Agencia do cheque invalida, para este "
                                                                + "banco são permitidas agencias " 
                                                                + STRING(aux_cdageant) + " e " 
                                                                + STRING(aux_cdagechq).
                                                        {sistema/generico/includes/foco_campo.i
                                                                &NOME-FRAME="f_dctror"
                                                                &NOME-CAMPO=aux_nmdcampo }
                                                      END.            
                                                END. /* Fim aux_cdagechq <> tel_cdagechq*/              
            
                                            END.
                                        END. /*  Fim do EDITING  */ 
                                    END. /* Fim avail craptco*/
                                    /*fim odirlei*/
                                        
                                        MESSAGE COLOR NORMAL 
                                        "F1 - Confirmar exclusao, F4/END - Cancelar exclusao.".
                                        
                                        SET tel_nrctachq tel_nrinichq tel_nrfinchq WITH FRAME f_dctror
                                        
                                        EDITING:
                                        
                        READKEY.
                            

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            NEXT Banco.
    
                        IF  LASTKEY = KEYCODE("F1")   THEN 
                            DO:
                                HIDE MESSAGE NO-PAUSE.
                           
                                IF  NOT CAN-FIND(FIRST tt-contra)   THEN 
                                    DO:
                                        MESSAGE 
                                        "Nenhuma Contra Ordem foi Informada!".
                                    END.
                                ELSE 
                                    DO:
                                        glb_cdcritic = 78.
                                        RUN fontes/critic.p.
                                        BELL.
                                        aux_confirma = "N".
                                        MESSAGE COLOR NORMAL glb_dscritic 
                                                UPDATE aux_confirma.
                                        glb_cdcritic = 0.
                           
                                        IF  aux_confirma = "S"   THEN
                                            LEAVE Editar.
                                    END.
                            END.
                        ELSE
                            APPLY LASTKEY.
                             
                        IF  GO-PENDING  THEN
                            DO:
                                ASSIGN FRAME f_dctror tel_nrctachq
                                       FRAME f_dctror tel_nrinichq
                                       FRAME f_dctror tel_nrfinchq.

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
                                
                                                {sistema/generico/includes/foco_campo.i
                                                    &NOME-FRAME="f_dctror"
                                                    &NOME-CAMPO=aux_nmdcampo }
                                            END.
                                    END.
                            END.
                    END. /* FIM EDITING */
                    LEAVE.
                END.
            
                CLEAR FRAME f_lanctos ALL NO-PAUSE.

                RUN busca-contra-ordens IN h-b1wgen0095
                    ( INPUT glb_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT tel_cdagechq,
                      INPUT tel_nrctachq,
                      INPUT tel_cdbanchq,
                      INPUT glb_cddopcao,
                      INPUT tel_nrinichq,
                      INPUT tel_nrfinchq,
                      INPUT tel_cdhistor,
                      INPUT tel_nrdconta,
                      INPUT FALSE, /* Se Provisorio ou nao */
                      INPUT TABLE tt-contra,
                     OUTPUT TABLE tt-dctror,
                     OUTPUT TABLE tt-erro ).

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                            END.
                        NEXT.
                    END.

                FIND FIRST tt-dctror NO-LOCK NO-ERROR NO-WAIT.
           
                IF  AVAIL tt-dctror  THEN
                DO:
                        ASSIGN tel_nrfinchq = tt-dctror.nrfinchq
                               tel_nrinichq = tt-dctror.nrinichq
                               tel_dshistor = tt-dctror.dshistor
                               tel_dtemscor = tt-dctror.dtemscor
                               tel_nrtalchq = tt-dctror.nrtalchq
                               tel_nrctachq = tt-dctror.nrctachq
                               tel_dtvalcor = tt-dctror.dtvalcor.
                END.
    
                CREATE tt-contra.
                ASSIGN tt-contra.cdhistor =  tt-dctror.cdhistor
                       tt-contra.cdbanchq =  tt-dctror.cdbanchq
                       tt-contra.nrdconta =  tt-dctror.nrdconta
                       tt-contra.cdagechq =  tt-dctror.cdagechq
                       tt-contra.nrctachq =  tt-dctror.nrctachq
                       tt-contra.nrinichq =  tt-dctror.nrinichq
                       tt-contra.nrfinchq =  tt-dctror.nrfinchq
                       tt-contra.flprovis =  tt-dctror.flprovis
                       tt-contra.flgativo =  tt-dctror.flgativo.
        
                ASSIGN aux_lcontrat = YES.
    
                IF   tt-dctror.flprovis = FALSE THEN
                     aux_flimprim = TRUE.
            
            END. /* Fim WHILE TRUE */
           
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S" THEN
                DO:
                    LEAVE.
                END.
    
            MESSAGE "Aguarde...".
    
            IF  CAN-FIND(FIRST tt-contra)  THEN 
                DO:
        
                    RUN valida-contra IN h-b1wgen0095
                        ( INPUT glb_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT tel_nrdconta,
                          INPUT glb_cddopcao,
                          INPUT aut_flgsenha,
                          INPUT aut_cdoperad,
                          INPUT aux_dsdctitg,
                          INPUT aux_flprovis, /*Se provisorio */
                          INPUT TABLE tt-contra,
                         OUTPUT par_pedsenha,
                         OUTPUT TABLE tt-cheques,
                         OUTPUT TABLE tt-custdesc ).

                    IF  par_pedsenha = TRUE THEN
                        DO:
                            PAUSE MESSAGE 
                            "Para continuar, peca liberacao ao Coordenador". 
                                
                            RUN fontes/pedesenha.p ( INPUT glb_cdcooper,
                                                     INPUT 2, 
                                                    OUTPUT aut_flgsenha,
                                                    OUTPUT aut_cdoperad ).
        
                            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
                                LEAVE.
        
                            RUN valida-contra IN h-b1wgen0095
                                ( INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT tel_nrdconta,
                                  INPUT glb_cddopcao,
                                  INPUT aut_flgsenha,
                                  INPUT aut_cdoperad,
                                  INPUT aux_dsdctitg,
                                  INPUT aux_flprovis, /*Se provisorio */
                                  INPUT TABLE tt-contra,
                                 OUTPUT par_pedsenha,
                                 OUTPUT TABLE tt-cheques,
                                 OUTPUT TABLE tt-custdesc ).
                        END.
                END.
    
            RUN grava-dados.
    
            IF  CAN-FIND(FIRST tt-criticas) THEN
                DO:
                    HIDE FRAME f_lanctos NO-PAUSE.
            
                    BELL.
            
                    aux_contador = 0.
            
                    FOR EACH tt-criticas NO-LOCK 
                        BREAK BY tt-criticas.cdbanchq
                                 BY tt-criticas.cdagechq
                                    BY tt-criticas.nrctachq
                                       BY tt-criticas.nrcheque:
            
                        ASSIGN aux_contador = aux_contador + 1
                               aux_flgerros = FALSE.
        
                        DISPLAY tt-criticas.cdbanchq 
                                tt-criticas.cdagechq
                                tt-criticas.nrctachq
                                tt-criticas.nrcheque  
                                tt-criticas.dscritic
                                WITH FRAME f_erros.
            
                        IF  aux_contador = 3 AND
                            NOT LAST(tt-criticas.nrcheque) THEN
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                                    aux_contador = 0.
                                    PAUSE MESSAGE
                                    "Tecle <Entra> para continuar...".
                                    CLEAR FRAME f_erros ALL NO-PAUSE.
                                    LEAVE.
            
                                END.  /*  Fim do DO WHILE TRUE  */
            
                                IF  KEYFUNCTION(LASTKEY) = 
                                    "END-ERROR"  
                                    THEN
                                    DO:
                                        CLEAR FRAME 
                                            f_erros ALL NO-PAUSE.
        
                                        HIDE FRAME f_erros.
                                        LEAVE.
                                    END.
                            END.
                        ELSE
                            DOWN WITH FRAME f_erros.
            
                    END.  /*  Fim do FOR EACH  */
            
                    IF  aux_contador > 0   THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                                PAUSE MESSAGE 
                                "Tecle <Entra> para continuar...".
                                CLEAR FRAME f_erros ALL NO-PAUSE.
                                HIDE FRAME f_erros.
                                LEAVE.
            
                            END.  /*  Fim do DO WHILE TRUE  */
            
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" 
                                THEN
                                DO:
                                    CLEAR FRAME f_erros ALL NO-PAUSE.
                                    HIDE FRAME f_erros.
                                    LEAVE Princ.
                                END.
                        END.
                END.
            ELSE
                DO:
                    CLEAR FRAME f_dctror NO-PAUSE.
                END.
    
            IF  NOT CAN-FIND(FIRST tt-criticas)   THEN 
                DO:
                    CLEAR FRAME f_dctror NO-PAUSE.
                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Exclusao efetuada com sucesso!".
                    PAUSE 2 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                END.
        
            IF  CAN-FIND(FIRST tt-contra) AND
                aux_flimprim              THEN
                RUN imprimir.

        END. /* Fim ELSE DO */

        LEAVE Princ.
    END.

IF  VALID-HANDLE(h-b1wgen0095)  THEN
    DELETE PROCEDURE h-b1wgen0095.


PROCEDURE imprimir:

    VIEW FRAME f_aguarde.

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

/* ......................................................................... */

PROCEDURE gera-log:

    RUN gera-log IN h-b1wgen0095
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT 1,
          INPUT TABLE tt-contra,
         OUTPUT aux_msgretor ).

    CLEAR FRAME f_dctror NO-PAUSE.
    MESSAGE aux_msgretor.
    NEXT-PROMPT tel_nrdconta WITH FRAME f_dctror.

    RETURN "OK".

END PROCEDURE.



PROCEDURE grava-dados:

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
          INPUT 1, /*  Inclusão */
          INPUT 2, /*  Exclusão */
          INPUT tel_dtemscor, /* aux_dtemscch */
          INPUT aux_dsdctitg,
          INPUT aux_flprovis,
          INPUT aux_dtvalcor,
          INPUT TABLE tt-cheques,
          INPUT TABLE tt-custdesc,
         OUTPUT tel_cdsitdtl,
         OUTPUT tel_dssitdtl,
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


